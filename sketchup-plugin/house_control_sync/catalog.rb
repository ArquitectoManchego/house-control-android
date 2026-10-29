# encoding: UTF-8
require 'json'

module HouseControlSync
  module Catalog
    @dialog = nil

    def self.show_dialog
      model = Sketchup.active_model

      if @dialog && @dialog.visible?
        @dialog.bring_to_front
        return
      end

      dialog_options = {
        dialog_title: "Catálogo de Objetos y Materiales - House Control (Estilo Lumion)",
        preferences_key: "HouseControl_Lumion_Catalog",
        scrollable: false,
        resizable: true,
        width: 1040,
        height: 720,
        left: 120,
        top: 80,
        min_width: 820,
        min_height: 540,
        style: UI::HtmlDialog::STYLE_DIALOG
      }

      @dialog = UI::HtmlDialog.new(dialog_options)

      html_path = File.join(File.dirname(__FILE__), 'web', 'catalog.html')
      @dialog.set_file(html_path)

      # Callback: Colocar Objeto en el Modelo de forma interactiva (estilo Lumion)
      @dialog.add_action_callback("place_object") do |_action_context, data_raw|
        data = parse_payload(data_raw)
        place_object_interactively(data)
      end

      # Callback: Insertar Objeto directamente en el Centro / Origen
      @dialog.add_action_callback("insert_object_at_center") do |_action_context, data_raw|
        data = parse_payload(data_raw)
        insert_object_at_origin(data)
      end

      # Callback: Aplicar Material Lumion a la selección o cargarlo en el Paint Bucket
      @dialog.add_action_callback("apply_material") do |_action_context, mat_id|
        model = Sketchup.active_model
        res = Materials.apply_catalog_material(model, mat_id.to_s)
        msg = if res[:applied_count] && res[:applied_count] > 0
                "✓ #{res[:name]} aplicado a #{res[:applied_count]} elemento(s) seleccionado(s)"
              else
                "✓ #{res[:name]} cargado en el cubo de pintura (B)"
              end
        @dialog.execute_script("showToast(#{msg.to_json})") if @dialog
      end

      # Callback: UI lista, sincronizar habitaciones del plano
      @dialog.add_action_callback("ready") do |_action_context|
        sync_rooms_to_ui
      end

      @dialog.show
    end

    def self.parse_payload(data_raw)
      if data_raw.is_a?(Hash)
        data_raw
      elsif data_raw.is_a?(String)
        JSON.parse(data_raw) rescue {}
      else
        {}
      end
    end

    def self.sync_rooms_to_ui
      return unless @dialog
      model = Sketchup.active_model
      return unless model

      rooms = []
      model.entities.grep(Sketchup::Group).each do |g|
        cat = g.get_attribute('HouseControl', 'category')
        if cat == 'room'
          r_id = g.get_attribute('HouseControl', 'id')
          r_name = g.get_attribute('HouseControl', 'name') || r_id
          rooms << { id: r_id, name: r_name } if r_id
        end
      end

      unless rooms.empty?
        js_code = "if (window.updateRoomsList) { updateRoomsList(#{rooms.to_json}); }"
        @dialog.execute_script(js_code)
      end
    end

    def self.create_definition_for_item(data)
      model = Sketchup.active_model
      category = data['category'] || 'furniture'
      type = data['type'] || 'sofa'
      name = data['name'] || type.capitalize
      room = data['room'] || 'living'
      color = data['color'] || '#8B93A7'
      is_custom = data['custom_dimensions']

      safe_name = name.gsub(/[^a-zA-Z0-9_]/, '_')
      def_name = if is_custom
                   "HC_#{type}_#{safe_name}_#{rand(1000..9999)}"
                 else
                   "HC_#{type}_#{safe_name}"
                 end

      comp_def = model.definitions[def_name]
      if comp_def.nil? || comp_def.deleted? || is_custom
        comp_def = model.definitions.add(def_name)

        # Configurar metadatos para House Control
        comp_def.set_attribute('HouseControl', 'category', category)
        comp_def.set_attribute('HouseControl', 'type', type)
        comp_def.set_attribute('HouseControl', 'name', name)
        comp_def.set_attribute('HouseControl', 'room', room)
        comp_def.set_attribute('HouseControl', 'color', color)
        comp_def.set_attribute('HouseControl', 'width', data['width']) if data['width']
        comp_def.set_attribute('HouseControl', 'depth', data['depth']) if data['depth']
        comp_def.set_attribute('HouseControl', 'height', data['height']) if data['height']
        comp_def.set_attribute('HouseControl', 'tuya', data['tuya']) if data['tuya'] && !data['tuya'].to_s.empty?
        comp_def.set_attribute('HouseControl', 'id', "#{room}.#{type}_#{rand(1000..9999)}")

        # Construir geometría 3D en la definición
        case category
        when 'lighting'
          wall_height = (model.get_attribute('HouseControl', 'wallHeight') || 2.6).to_f.m
          Builder.create_light_geometry(comp_def, data, wall_height, model)
        when 'clima'
          Builder.create_ac_geometry(comp_def, data, model)
        else
          Builder.create_furniture_geometry(comp_def, data, model)
        end
      end

      comp_def
    end

    def self.place_object_interactively(data)
      model = Sketchup.active_model
      comp_def = create_definition_for_item(data)
      category = data['category'] || 'furniture'

      layer_name = case category
                   when 'lighting' then 'HC_Luces'
                   when 'clima' then 'HC_Climas'
                   when 'vehicles' then 'HC_Muebles'
                   else 'HC_Muebles'
                   end
      layer = model.layers[layer_name] || model.layers.add(layer_name)
      model.active_layer = layer

      # Activa la colocación interactiva como en Lumion
      is_continuous = data['continuous'] == true
      model.place_component(comp_def, is_continuous)
    end

    def self.insert_object_at_origin(data)
      model = Sketchup.active_model
      comp_def = create_definition_for_item(data)
      category = data['category'] || 'furniture'

      layer_name = case category
                   when 'lighting' then 'HC_Luces'
                   when 'clima' then 'HC_Climas'
                   when 'vehicles' then 'HC_Muebles'
                   else 'HC_Muebles'
                   end
      layer = model.layers[layer_name] || model.layers.add(layer_name)

      model.start_operation("Insertar #{data['name']}", true)
      target_point = Geom::Point3d.new(0, 0, 0)

      inst = model.active_entities.add_instance(comp_def, Geom::Transformation.translation(target_point))
      inst.layer = layer
      inst.name = data['name']
      inst.set_attribute('HouseControl', 'category', category)
      inst.set_attribute('HouseControl', 'type', data['type'])
      inst.set_attribute('HouseControl', 'name', data['name'])
      inst.set_attribute('HouseControl', 'room', data['room'] || 'living')
      inst.set_attribute('HouseControl', 'tuya', data['tuya']) if data['tuya'] && !data['tuya'].to_s.empty?
      inst.set_attribute('HouseControl', 'id', "#{data['room'] || 'living'}.#{data['type']}_#{rand(1000..9999)}")

      model.commit_operation

      model.selection.clear
      model.selection.add(inst)
    end
  end
end
