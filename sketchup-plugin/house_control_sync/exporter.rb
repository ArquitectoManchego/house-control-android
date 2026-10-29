# encoding: UTF-8
require 'json'

module HouseControlSync
  module Exporter
    def self.prompt_and_export(model)
      file = UI.savepanel('Exportar Plano House Control (*.json)', '', 'plan.json')
      return unless file

      file += '.json' unless file.downcase.end_with?('.json')
      export_file(model, file)
    end

    def self.get_hc_attr(ent, key)
      val = ent.get_attribute('HouseControl', key)
      if val.nil? && ent.respond_to?(:definition)
        val = ent.definition.get_attribute('HouseControl', key)
      end
      val
    end

    def self.export_file(model, filepath)
      plan = {}

      # Metadatos generales del Modelo
      plan['version'] = (model.get_attribute('HouseControl', 'version') || 1).to_i
      plan['name'] = (model.get_attribute('HouseControl', 'name') || 'Home').to_s
      plan['wallHeight'] = (model.get_attribute('HouseControl', 'wallHeight') || 2.6).to_f
      plan['interiorWallHeight'] = (model.get_attribute('HouseControl', 'interiorWallHeight') || 1.25).to_f
      plan['outdoorTemp'] = (model.get_attribute('HouseControl', 'outdoorTemp') || 25).to_f

      az = (model.get_attribute('HouseControl', 'camera_azimuth') || 34).to_f
      el = (model.get_attribute('HouseControl', 'camera_elevation') || 47).to_f
      plan['camera'] = { 'azimuth' => az, 'elevation' => el }

      scenes_raw = model.get_attribute('HouseControl', 'scenes_json')
      plan['scenes'] = scenes_raw ? (JSON.parse(scenes_raw) rescue []) : []

      rooms = []
      openings = []
      furniture = []
      lights = []
      acs = []

      # Recorrer entidades en el modelo buscando elementos de House Control o por Tags
      find_all_relevant_entities(model.active_entities).each do |ent|
        cat = get_hc_attr(ent, 'category') || infer_category_from_layer(ent)

        raw_str = get_hc_attr(ent, 'raw_json')
        raw_data = raw_str ? (JSON.parse(raw_str) rescue {}) : {}

        case cat
        when 'room'
          bb = ent.bounds
          rx = bb.min.x.to_m.round(2)
          rz = (-bb.max.y).to_m.round(2)
          rw = bb.width.to_m.round(2)
          rd = bb.height.to_m.round(2)

          item = raw_data.dup
          item['id'] = (get_hc_attr(ent, 'id') || item['id'] || "room_#{rooms.size + 1}").to_s
          item['name'] = (get_hc_attr(ent, 'name') || item['name'] || item['id']).to_s

          # Detectar si el usuario pintó el piso con un nuevo material en SketchUp
          mat_floor = Materials.detect_floor_type(ent.material)
          item['floor'] = (get_hc_attr(ent, 'floor') || mat_floor || 'oak').to_s
          item['rect'] = [rx, rz, rw, rd]
          rooms << item

        when 'opening'
          item = raw_data.dup
          item['type'] = (get_hc_attr(ent, 'type') || item['type'] || 'door').to_s
          item['sill'] = (get_hc_attr(ent, 'sill') || item['sill'] || 0.85).to_f
          item['head'] = (get_hc_attr(ent, 'head') || item['head'] || 2.10).to_f
          openings << item

        when 'furniture'
          tr = ent.transformation
          pos_x = tr.origin.x.to_m.round(2)
          pos_z = (-tr.origin.y).to_m.round(2)
          pos_y = tr.origin.z.to_m.round(2)

          rot_deg = extract_rotation_degrees(tr)

          item = raw_data.dup
          item['type'] = (get_hc_attr(ent, 'type') || item['type'] || 'sofa').to_s
          item['pos'] = [pos_x, pos_z]
          item['rot'] = rot_deg if rot_deg != 0
          item['y'] = pos_y if pos_y > 0.02

          # Dimensiones si fueron personalizadas
          w = get_hc_attr(ent, 'width')
          d = get_hc_attr(ent, 'depth')
          h = get_hc_attr(ent, 'height')
          item['size'] = [w.to_f, d.to_f] if w && d

          # Si el arquitecto aplicó un material/color personalizado en SketchUp
          custom_color = Materials.extract_hex(ent.material) || get_hc_attr(ent, 'color')
          item['color'] = custom_color if custom_color

          furniture << item

        when 'light'
          tr = ent.transformation
          pos_x = tr.origin.x.to_m.round(2)
          pos_z = (-tr.origin.y).to_m.round(2)
          rot_deg = extract_rotation_degrees(tr)

          item = raw_data.dup
          item['id'] = (get_hc_attr(ent, 'id') || item['id'] || "light_#{lights.size + 1}").to_s
          item['name'] = (get_hc_attr(ent, 'name') || item['name'] || item['id']).to_s
          item['room'] = (get_hc_attr(ent, 'room') || item['room'] || 'living').to_s
          item['type'] = (get_hc_attr(ent, 'type') || item['type'] || 'ceiling').to_s
          item['pos'] = [pos_x, pos_z]
          item['rot'] = rot_deg if rot_deg != 0

          # Mantener la elevación Y original o leer la de la geometría
          saved_y = get_hc_attr(ent, 'y')
          item['y'] = saved_y.to_f if saved_y

          caps_raw = get_hc_attr(ent, 'capabilities')
          item['capabilities'] = JSON.parse(caps_raw) if caps_raw && !caps_raw.empty? rescue item['capabilities']

          link_raw = get_hc_attr(ent, 'link')
          item['link'] = JSON.parse(link_raw) if link_raw && !link_raw.empty? rescue item['link']

          tuya_raw = get_hc_attr(ent, 'tuya')
          if tuya_raw && !tuya_raw.to_s.empty?
            item['tuya'] = (tuya_raw.is_a?(String) && tuya_raw.start_with?('{')) ? (JSON.parse(tuya_raw) rescue tuya_raw) : tuya_raw
          end

          custom_color = Materials.extract_hex(ent.material) || get_hc_attr(ent, 'color')
          item['color'] = custom_color if custom_color

          lights << item

        when 'ac'
          tr = ent.transformation
          pos_x = tr.origin.x.to_m.round(2)
          pos_z = (-tr.origin.y).to_m.round(2)

          item = raw_data.dup
          item['id'] = (get_hc_attr(ent, 'id') || item['id'] || "ac_#{acs.size + 1}").to_s
          item['name'] = (get_hc_attr(ent, 'name') || item['name'] || item['id']).to_s
          item['room'] = (get_hc_attr(ent, 'room') || item['room'] || 'living').to_s
          item['wall'] = (get_hc_attr(ent, 'wall') || item['wall'] || 'north').to_s
          item['pos'] = [pos_x, pos_z]
          item['y'] = (get_hc_attr(ent, 'y') || item['y'] || 2.2).to_f

          link_raw = get_hc_attr(ent, 'link')
          item['link'] = JSON.parse(link_raw) if link_raw && !link_raw.empty? rescue item['link']

          tuya_raw = get_hc_attr(ent, 'tuya')
          if tuya_raw && !tuya_raw.to_s.empty?
            item['tuya'] = (tuya_raw.is_a?(String) && tuya_raw.start_with?('{')) ? (JSON.parse(tuya_raw) rescue tuya_raw) : tuya_raw
          end

          sensor_raw = get_hc_attr(ent, 'sensor')
          item['sensor'] = JSON.parse(sensor_raw) if sensor_raw && !sensor_raw.empty? rescue item['sensor']

          acs << item
        end
      end

      # Si no hay habitaciones registradas dinámicamente, conservar respaldo
      if rooms.empty?
        raw_rooms = JSON.parse(model.get_attribute('HouseControl', 'raw_plan_json'))['rooms'] rescue []
        plan['rooms'] = raw_rooms
      else
        plan['rooms'] = rooms
      end

      plan['openings'] = openings.empty? ? (JSON.parse(model.get_attribute('HouseControl', 'raw_plan_json'))['openings'] rescue []) : openings
      plan['furniture'] = furniture
      plan['lights'] = lights
      plan['acs'] = acs

      # Serializar JSON limpio
      json_output = JSON.pretty_generate(plan)
      File.write(filepath, json_output, encoding: 'UTF-8')

      UI.messagebox("¡Plano exportado exitosamente para House Control!\n\n" +
                    "Archivo: #{File.basename(filepath)}\n" +
                    "• Habitaciones: #{plan['rooms'].size}\n" +
                    "• Muebles: #{plan['furniture'].size}\n" +
                    "• Luces: #{plan['lights'].size}\n" +
                    "• Climas: #{plan['acs'].size}\n\n" +
                    "Puedes transferir este archivo a tu celular e importarlo en la app House Control.")
    end

    def self.find_all_relevant_entities(entities)
      results = []
      entities.each do |e|
        next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
        if get_hc_attr(e, 'category') || infer_category_from_layer(e)
          results << e
        else
          sub_ents = e.is_a?(Sketchup::Group) ? e.entities : e.definition.entities
          results.concat(find_all_relevant_entities(sub_ents))
        end
      end
      results
    end

    def self.infer_category_from_layer(entity)
      layer_name = entity.layer.name.to_s.downcase
      if layer_name.include?('piso') || layer_name.include?('room')
        'room'
      elsif layer_name.include?('mueble') || layer_name.include?('furn')
        'furniture'
      elsif layer_name.include?('luz') || layer_name.include?('light') || layer_name.include?('lamp')
        'light'
      elsif layer_name.include?('clima') || layer_name.include?('ac') || layer_name.include?('aire')
        'ac'
      elsif layer_name.include?('abertura') || layer_name.include?('open') || layer_name.include?('puerta') || layer_name.include?('ventana')
        'opening'
      else
        nil
      end
    end

    def self.extract_rotation_degrees(transformation)
      xaxis = transformation.xaxis
      angle_rad = Math.atan2(xaxis.y, xaxis.x)
      angle_deg = (-angle_rad * 180.0 / Math::PI).round
      angle_deg += 360 if angle_deg < -180
      angle_deg -= 360 if angle_deg > 180
      angle_deg
    end
  end
end
