# encoding: UTF-8
require 'json'

module HouseControlSync
  module Importer
    def self.prompt_and_import(model)
      file = UI.openpanel('Importar Plano House Control (*.json)', '', 'Archivos JSON (*.json)|*.json;*.JSON||')
      return unless file && File.exist?(file)

      import_file(model, file)
    end

    def self.import_file(model, filepath)
      content = File.read(filepath, encoding: 'UTF-8')
      import_json_string(model, content, File.basename(filepath), true)
    end

    def self.import_json_string(model, content, source_name = 'Plano', show_msg = true)
      plan = JSON.parse(content)

      unless plan['rooms'] && plan['rooms'].is_a?(Array) && !plan['rooms'].empty?
        UI.messagebox("Error: #{source_name} no contiene un plano válido de House Control (falta la lista 'rooms').")
        return false
      end

      model.start_operation("Importar Plano #{plan['name'] || 'Home'}", true)

      # Asegurar Tags / Capas de organización arquitectónica en SketchUp
      tag_pisos     = get_or_create_layer(model, 'HC_Pisos')
      tag_paredes   = get_or_create_layer(model, 'HC_Paredes')
      tag_aberturas = get_or_create_layer(model, 'HC_Aberturas')
      tag_muebles   = get_or_create_layer(model, 'HC_Muebles')
      tag_luces     = get_or_create_layer(model, 'HC_Luces')
      tag_climas    = get_or_create_layer(model, 'HC_Climas')

      # Guardar metadatos generales del plano en el Modelo
      model.set_attribute('HouseControl', 'name', plan['name'] || 'Home')
      model.set_attribute('HouseControl', 'version', plan['version'] || 1)
      model.set_attribute('HouseControl', 'wallHeight', (plan['wallHeight'] || 2.6).to_f)
      model.set_attribute('HouseControl', 'interiorWallHeight', (plan['interiorWallHeight'] || 1.25).to_f)
      model.set_attribute('HouseControl', 'outdoorTemp', (plan['outdoorTemp'] || 25).to_f)
      model.set_attribute('HouseControl', 'camera_azimuth', plan['camera'] ? plan['camera']['azimuth'].to_f : 34.0)
      model.set_attribute('HouseControl', 'camera_elevation', plan['camera'] ? plan['camera']['elevation'].to_f : 47.0)
      model.set_attribute('HouseControl', 'scenes_json', (plan['scenes'] || []).to_json)
      model.set_attribute('HouseControl', 'raw_plan_json', content)

      root_group = model.active_entities.add_group
      root_group.name = "HouseControl - #{plan['name'] || 'Home'}"
      ents = root_group.entities

      wall_height = (plan['wallHeight'] || 2.6).to_f.m
      int_wall_height = (plan['interiorWallHeight'] || 1.25).to_f.m

      # 1. Habitaciones (Pisos)
      rooms = plan['rooms'] || []
      rooms.each do |room|
        r_group = ents.add_group
        r_group.name = "Habitación: #{room['name'] || room['id']}"
        r_group.layer = tag_pisos

        rx = room['rect'][0].to_f.m
        rz = room['rect'][1].to_f.m
        rw = room['rect'][2].to_f.m
        rd = room['rect'][3].to_f.m

        # 4 puntos del suelo en SketchUp: (X = rx, Y = -rz, Z = 0)
        pts = [
          Geom::Point3d.new(rx,      -rz,      0),
          Geom::Point3d.new(rx + rw, -rz,      0),
          Geom::Point3d.new(rx + rw, -(rz + rd), 0),
          Geom::Point3d.new(rx,      -(rz + rd), 0)
        ]
        face = r_group.entities.add_face(pts)
        if face
          # Normal hacia arriba (+Z) para que el grosor quede debajo del nivel 0
          face.reverse! if face.normal.z < 0
          mat = Materials.floor_material(model, room['floor'])
          face.material = mat
          face.back_material = mat
          face.pushpull(-0.04.m) # Losa hacia abajo del nivel 0.00
        end

        r_group.set_attribute('HouseControl', 'category', 'room')
        r_group.set_attribute('HouseControl', 'id', room['id'].to_s)
        r_group.set_attribute('HouseControl', 'name', (room['name'] || room['id']).to_s)
        r_group.set_attribute('HouseControl', 'floor', (room['floor'] || 'oak').to_s)
        r_group.set_attribute('HouseControl', 'rect', room['rect'].to_json)
        r_group.set_attribute('HouseControl', 'raw_json', room.to_json)
      end

      # 2. Paredes y Aberturas (Puertas y Ventanas en Z positivo)
      build_walls_and_openings(ents, plan, model, tag_paredes, tag_aberturas, wall_height, int_wall_height)

      # 3. Muebles (En Z positivo con bordes redondeados y acolchados)
      (plan['furniture'] || []).each_with_index do |item, idx|
        next unless item['pos'] && item['pos'].is_a?(Array)
        f_group = ents.add_group
        f_group.name = "Mueble: #{item['type']} (#{idx + 1})"
        f_group.layer = tag_muebles

        Builder.create_furniture_geometry(f_group, item, model)

        px = item['pos'][0].to_f.m
        pz = item['pos'][1].to_f.m
        py = (item['y'] || 0).to_f.m
        rot_deg = (item['rot'] || 0).to_f

        t_pos = Geom::Transformation.translation(Geom::Vector3d.new(px, -pz, py))
        t_rot = Geom::Transformation.rotation(Geom::Point3d.new(px, -pz, py), Geom::Vector3d.new(0, 0, 1), -rot_deg.degrees)
        f_group.transformation = t_rot * t_pos

        f_group.set_attribute('HouseControl', 'category', 'furniture')
        f_group.set_attribute('HouseControl', 'id', (item['id'] || "furniture_#{idx}").to_s)
        f_group.set_attribute('HouseControl', 'type', item['type'].to_s)
        f_group.set_attribute('HouseControl', 'rot', rot_deg)
        f_group.set_attribute('HouseControl', 'color', item['color'].to_s)
        f_group.set_attribute('HouseControl', 'raw_json', item.to_json)
      end

      # 4. Luces (Suspendidas desde el techo o situadas sobre mesas/piso a su altura real Z)
      (plan['lights'] || []).each do |light|
        next unless light['pos'] && light['pos'].is_a?(Array)
        l_group = ents.add_group
        l_group.name = "Luz: #{light['name'] || light['id']}"
        l_group.layer = tag_luces

        Builder.create_light_geometry(l_group, light, wall_height, model)

        px = light['pos'][0].to_f.m
        pz = light['pos'][1].to_f.m
        rot_deg = (light['rot'] || 0).to_f

        t_pos = Geom::Transformation.translation(Geom::Vector3d.new(px, -pz, 0))
        t_rot = Geom::Transformation.rotation(Geom::Point3d.new(px, -pz, 0), Geom::Vector3d.new(0, 0, 1), -rot_deg.degrees)
        l_group.transformation = t_rot * t_pos

        l_group.set_attribute('HouseControl', 'category', 'light')
        l_group.set_attribute('HouseControl', 'id', light['id'].to_s)
        l_group.set_attribute('HouseControl', 'name', (light['name'] || light['id']).to_s)
        l_group.set_attribute('HouseControl', 'room', light['room'].to_s)
        l_group.set_attribute('HouseControl', 'type', light['type'].to_s)
        l_group.set_attribute('HouseControl', 'y', (light['y'] || (light['type'] == 'ceiling' ? wall_height.to_m : 0.8)).to_f)
        l_group.set_attribute('HouseControl', 'capabilities', (light['capabilities'] || []).to_json)
        l_group.set_attribute('HouseControl', 'link', light['link'] ? light['link'].to_json : '')
        l_group.set_attribute('HouseControl', 'tuya', light['tuya'] ? light['tuya'].to_json : '')
        l_group.set_attribute('HouseControl', 'color', light['color'].to_s)
        l_group.set_attribute('HouseControl', 'raw_json', light.to_json)
      end

      # 5. Aires Acondicionados (Suspendidos en muro a 2.20 m sobre el piso)
      (plan['acs'] || []).each do |ac|
        next unless ac['pos'] && ac['pos'].is_a?(Array)
        a_group = ents.add_group
        a_group.name = "Clima: #{ac['name'] || ac['id']}"
        a_group.layer = tag_climas

        Builder.create_ac_geometry(a_group, ac, model)

        px = ac['pos'][0].to_f.m
        pz = ac['pos'][1].to_f.m

        rot_deg = case ac['wall'].to_s.downcase
                  when 'north' then 0.0
                  when 'south' then 180.0
                  when 'east'  then 90.0
                  when 'west'  then -90.0
                  else 0.0
                  end

        t_pos = Geom::Transformation.translation(Geom::Vector3d.new(px, -pz, 0))
        t_rot = Geom::Transformation.rotation(Geom::Point3d.new(px, -pz, 0), Geom::Vector3d.new(0, 0, 1), rot_deg.degrees)
        a_group.transformation = t_rot * t_pos

        a_group.set_attribute('HouseControl', 'category', 'ac')
        a_group.set_attribute('HouseControl', 'id', ac['id'].to_s)
        a_group.set_attribute('HouseControl', 'name', (ac['name'] || ac['id']).to_s)
        a_group.set_attribute('HouseControl', 'room', ac['room'].to_s)
        a_group.set_attribute('HouseControl', 'wall', ac['wall'].to_s)
        a_group.set_attribute('HouseControl', 'y', (ac['y'] || 2.2).to_f)
        a_group.set_attribute('HouseControl', 'link', ac['link'] ? ac['link'].to_json : '')
        a_group.set_attribute('HouseControl', 'tuya', ac['tuya'] ? ac['tuya'].to_json : '')
        a_group.set_attribute('HouseControl', 'sensor', ac['sensor'] ? ac['sensor'].to_json : '')
        a_group.set_attribute('HouseControl', 'raw_json', ac.to_json)
      end

      model.commit_operation
      model.active_view.zoom_extents

      if show_msg
        UI.messagebox("¡Plano '#{plan['name'] || 'Home'}' sincronizado correctamente!\n\n" +
                      "• Origen: #{source_name}\n" +
                      "• Altura de muros: #{(plan['wallHeight'] || 2.6)} m (Eje Z hacia arriba)\n" +
                      "• Habitaciones: #{rooms.size}\n" +
                      "• Muebles: #{(plan['furniture'] || []).size} (con aristas suavizadas)\n" +
                      "• Luces: #{(plan['lights'] || []).size} (a su altura real de techo o mesa)\n" +
                      "• Climas (AC): #{(plan['acs'] || []).size} (a 2.20 m sobre pared)\n\n" +
                      "Todo el modelo se encuentra en coordenadas positivas sobre el nivel 0.00.")
      end
      true
    end

    def self.build_walls_and_openings(ents, plan, model, tag_paredes, tag_aberturas, wall_h, int_wall_h)
      rooms = plan['rooms'] || []
      openings = plan['openings'] || []
      wall_mat = Materials.wall_material(model)
      glass_mat = Materials.glass_material(model)
      frame_mat = Materials.frame_material(model)

      # Muros perimetrales por habitación
      rooms.each do |room|
        rx = room['rect'][0].to_f.m
        rz = room['rect'][1].to_f.m
        rw = room['rect'][2].to_f.m
        rd = room['rect'][3].to_f.m

        p_nw = Geom::Point3d.new(rx,      -rz, 0)
        p_ne = Geom::Point3d.new(rx + rw, -rz, 0)
        p_se = Geom::Point3d.new(rx + rw, -(rz + rd), 0)
        p_sw = Geom::Point3d.new(rx,      -(rz + rd), 0)

        [
          [p_nw, p_ne],
          [p_ne, p_se],
          [p_se, p_sw],
          [p_sw, p_nw]
        ].each do |p1, p2|
          seg = Builder.add_wall_segment(ents, p1, p2, 0.15.m, 0, wall_h, wall_mat)
          seg.layer = tag_paredes if seg
        end
      end

      # Modelar Aberturas (Ventanas, Puertas y Vanos en Z positivo)
      openings.each_with_index do |op, idx|
        next unless op['from'] && op['to']
        ox1 = op['from'][0].to_f.m
        oz1 = op['from'][1].to_f.m
        ox2 = op['to'][0].to_f.m
        oz2 = op['to'][1].to_f.m

        p1 = Geom::Point3d.new(ox1, -oz1, 0)
        p2 = Geom::Point3d.new(ox2, -oz2, 0)

        type = op['type'].to_s
        sill = (op['sill'] || 0.85).to_f.m
        head = (op['head'] || 2.10).to_f.m

        op_group = ents.add_group
        op_group.name = "Abertura: #{type} (#{idx + 1})"
        op_group.layer = tag_aberturas

        case type
        when 'window'
          # Antepecho (sill) desde 0 hasta la altura del antepecho (ej. 0.85m o 1.50m)
          if sill > 0.05.m
            Builder.add_wall_segment(op_group.entities, p1, p2, 0.16.m, 0, sill, wall_mat)
          end
          # Vidrio y marco transparente desde sill hasta dintel (head)
          Builder.add_wall_segment(op_group.entities, p1, p2, 0.04.m, sill, head, glass_mat)
          # Dintel superior desde head (2.10m) hasta la altura del techo
          if head < wall_h
            Builder.add_wall_segment(op_group.entities, p1, p2, 0.16.m, head, wall_h, wall_mat)
          end

        when 'door'
          # Marco de puerta desde 0 hasta 2.10m
          Builder.add_wall_segment(op_group.entities, p1, p2, 0.08.m, 0, head, frame_mat)
          # Dintel superior de 2.10m al techo
          if head < wall_h
            Builder.add_wall_segment(op_group.entities, p1, p2, 0.16.m, head, wall_h, wall_mat)
          end

        when 'open'
          # Vano abierto (solo dintel superior de 2.10m al techo)
          if head < wall_h
            Builder.add_wall_segment(op_group.entities, p1, p2, 0.16.m, head, wall_h, wall_mat)
          end
        end

        op_group.set_attribute('HouseControl', 'category', 'opening')
        op_group.set_attribute('HouseControl', 'type', type)
        op_group.set_attribute('HouseControl', 'from', op['from'].to_json)
        op_group.set_attribute('HouseControl', 'to', op['to'].to_json)
        op_group.set_attribute('HouseControl', 'sill', op['sill'] || 0.85)
        op_group.set_attribute('HouseControl', 'head', op['head'] || 2.10)
        op_group.set_attribute('HouseControl', 'raw_json', op.to_json)
      end
    end

    def self.get_or_create_layer(model, name)
      layer = model.layers[name]
      return layer if layer
      model.layers.add(name)
    end
  end
end
