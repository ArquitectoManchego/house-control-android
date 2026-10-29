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

    def self.export_file(model, filepath)
      plan = {}

      # Metadatos del Modelo
      plan['version'] = (model.get_attribute('HouseControl', 'version') || 1).to_i
      plan['name'] = (model.get_attribute('HouseControl', 'name') || 'Home').to_s
      plan['wallHeight'] = (model.get_attribute('HouseControl', 'wallHeight') || 2.6).to_f
      plan['interiorWallHeight'] = (model.get_attribute('HouseControl', 'interiorWallHeight') || 1.25).to_f
      plan['outdoorTemp'] = (model.get_attribute('HouseControl', 'outdoorTemp') || 25).to_f

      az = (model.get_attribute('HouseControl', 'camera_azimuth') || 34).to_f
      el = (model.get_attribute('HouseControl', 'camera_elevation') || 47).to_f
      plan['camera'] = { 'azimuth' => az, 'elevation' => el }

      # Escenas guardadas
      scenes_raw = model.get_attribute('HouseControl', 'scenes_json')
      plan['scenes'] = scenes_raw ? JSON.parse(scenes_raw) : []

      rooms = []
      openings = []
      furniture = []
      lights = []
      acs = []

      # Recorrer entidades buscando elementos con diccionario 'HouseControl'
      find_house_control_entities(model.active_entities).each do |ent|
        cat = ent.get_attribute('HouseControl', 'category')
        raw_str = ent.get_attribute('HouseControl', 'raw_json')
        raw_data = raw_str ? (JSON.parse(raw_str) rescue {}) : {}

        case cat
        when 'room'
          bb = ent.bounds
          rx = bb.min.x.to_m.round(2)
          rz = (-bb.max.y).to_m.round(2)
          rw = bb.width.to_m.round(2)
          rd = bb.height.to_m.round(2)

          item = raw_data.dup
          item['id'] = (ent.get_attribute('HouseControl', 'id') || item['id'] || "room_#{rooms.size + 1}").to_s
          item['name'] = (ent.get_attribute('HouseControl', 'name') || item['name'] || item['id']).to_s
          item['floor'] = (ent.get_attribute('HouseControl', 'floor') || item['floor'] || 'oak').to_s
          item['rect'] = [rx, rz, rw, rd]
          rooms << item

        when 'opening'
          item = raw_data.dup
          item['type'] = (ent.get_attribute('HouseControl', 'type') || item['type'] || 'door').to_s
          item['sill'] = (ent.get_attribute('HouseControl', 'sill') || item['sill'] || 0.85).to_f
          item['head'] = (ent.get_attribute('HouseControl', 'head') || item['head'] || 2.10).to_f
          openings << item

        when 'furniture'
          tr = ent.transformation
          pos_x = tr.origin.x.to_m.round(2)
          pos_z = (-tr.origin.y).to_m.round(2)
          pos_y = tr.origin.z.to_m.round(2)

          # Calcular rotación en grados
          rot_deg = extract_rotation_degrees(tr)

          item = raw_data.dup
          item['type'] = (ent.get_attribute('HouseControl', 'type') || item['type'] || 'sofa').to_s
          item['pos'] = [pos_x, pos_z]
          item['rot'] = rot_deg if rot_deg != 0
          item['y'] = pos_y if pos_y > 0.01
          furniture << item

        when 'light'
          tr = ent.transformation
          pos_x = tr.origin.x.to_m.round(2)
          pos_z = (-tr.origin.y).to_m.round(2)
          pos_y = tr.origin.z.to_m.round(2)
          rot_deg = extract_rotation_degrees(tr)

          item = raw_data.dup
          item['id'] = (ent.get_attribute('HouseControl', 'id') || item['id']).to_s
          item['name'] = (ent.get_attribute('HouseControl', 'name') || item['name'] || item['id']).to_s
          item['room'] = (ent.get_attribute('HouseControl', 'room') || item['room'] || 'living').to_s
          item['type'] = (ent.get_attribute('HouseControl', 'type') || item['type'] || 'ceiling').to_s
          item['pos'] = [pos_x, pos_z]
          item['y'] = pos_y if pos_y > 0.01
          item['rot'] = rot_deg if rot_deg != 0

          # Restaurar capacidades y vinculaciones de dispositivo
          caps_raw = ent.get_attribute('HouseControl', 'capabilities')
          item['capabilities'] = JSON.parse(caps_raw) if caps_raw && !caps_raw.empty? rescue item['capabilities']

          link_raw = ent.get_attribute('HouseControl', 'link')
          item['link'] = JSON.parse(link_raw) if link_raw && !link_raw.empty? rescue item['link']

          tuya_raw = ent.get_attribute('HouseControl', 'tuya')
          item['tuya'] = JSON.parse(tuya_raw) if tuya_raw && !tuya_raw.empty? rescue item['tuya']

          lights << item

        when 'ac'
          tr = ent.transformation
          pos_x = tr.origin.x.to_m.round(2)
          pos_z = (-tr.origin.y).to_m.round(2)
          pos_y = tr.origin.z.to_m.round(2)

          item = raw_data.dup
          item['id'] = (ent.get_attribute('HouseControl', 'id') || item['id']).to_s
          item['name'] = (ent.get_attribute('HouseControl', 'name') || item['name'] || item['id']).to_s
          item['room'] = (ent.get_attribute('HouseControl', 'room') || item['room'] || 'living').to_s
          item['wall'] = (ent.get_attribute('HouseControl', 'wall') || item['wall'] || 'north').to_s
          item['pos'] = [pos_x, pos_z]
          item['y'] = pos_y if pos_y > 0.01

          link_raw = ent.get_attribute('HouseControl', 'link')
          item['link'] = JSON.parse(link_raw) if link_raw && !link_raw.empty? rescue item['link']

          tuya_raw = ent.get_attribute('HouseControl', 'tuya')
          item['tuya'] = JSON.parse(tuya_raw) if tuya_raw && !tuya_raw.empty? rescue item['tuya']

          sensor_raw = ent.get_attribute('HouseControl', 'sensor')
          item['sensor'] = JSON.parse(sensor_raw) if sensor_raw && !sensor_raw.empty? rescue item['sensor']

          acs << item
        end
      end

      # Si no se encontraron por búsqueda individual, cargar los respaldos para no perder listas vacías
      plan['rooms'] = rooms.empty? ? (JSON.parse(model.get_attribute('HouseControl', 'raw_plan_json'))['rooms'] rescue []) : rooms
      plan['openings'] = openings.empty? ? (JSON.parse(model.get_attribute('HouseControl', 'raw_plan_json'))['openings'] rescue []) : openings
      plan['furniture'] = furniture
      plan['lights'] = lights
      plan['acs'] = acs

      # Serializar JSON con indentación limpia
      json_output = JSON.pretty_generate(plan)
      File.write(filepath, json_output, encoding: 'UTF-8')

      UI.messagebox("¡Plano exportado con éxito a:\n#{filepath}\n\n" +
                    "• Habitaciones: #{plan['rooms'].size}\n" +
                    "• Muebles: #{plan['furniture'].size}\n" +
                    "• Luces: #{plan['lights'].size}\n" +
                    "• Climas (AC): #{plan['acs'].size}\n\n" +
                    "Ya puedes importar este archivo directamente en la app House Control de tu celular.")
    end

    def self.find_house_control_entities(entities)
      results = []
      entities.each do |e|
        next unless e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
        if e.get_attribute('HouseControl', 'category')
          results << e
        else
          # Explorar recursivamente si es un grupo contenedor
          sub_ents = e.is_a?(Sketchup::Group) ? e.entities : e.definition.entities
          results.concat(find_house_control_entities(sub_ents))
        end
      end
      results
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
