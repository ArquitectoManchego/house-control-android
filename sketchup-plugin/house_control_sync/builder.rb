# encoding: UTF-8
module HouseControlSync
  module Builder
    # Dibuja un prisma rectangular (box) asegurando que extruya hacia +Z (arriba del piso)
    def self.add_box(entities, width, depth, height, material = nil, smooth = false)
      group = entities.add_group
      pts = [
        Geom::Point3d.new(-width / 2.0, -depth / 2.0, 0),
        Geom::Point3d.new( width / 2.0, -depth / 2.0, 0),
        Geom::Point3d.new( width / 2.0,  depth / 2.0, 0),
        Geom::Point3d.new(-width / 2.0,  depth / 2.0, 0)
      ]
      face = group.entities.add_face(pts)
      if face
        # Corregir la orientación nativa de SketchUp: forzar normal hacia arriba (+Z)
        face.reverse! if face.normal.z < 0
        face.material = material if material
        face.back_material = material if material
        face.pushpull(height) if height > 0
        group.material = material if material
      end

      if smooth
        group.entities.grep(Sketchup::Edge).each do |edge|
          edge.soft = true
          edge.smooth = true
        end
      end

      group
    end

    # Dibuja un cilindro con normal hacia arriba (+Z) y aristas laterales suavizadas
    def self.add_cylinder(entities, radius, height, material = nil, segments = 24, smooth = true)
      group = entities.add_group
      center = Geom::Point3d.new(0, 0, 0)
      normal = Geom::Vector3d.new(0, 0, 1)
      circle = group.entities.add_circle(center, normal, radius, segments)
      face = group.entities.add_face(circle)
      if face
        face.reverse! if face.normal.z < 0
        face.material = material if material
        face.back_material = material if material
        face.pushpull(height) if height > 0
        group.material = material if material
      end

      if smooth
        group.entities.grep(Sketchup::Edge).each do |edge|
          if edge.line[1].z.abs > 0.8
            edge.soft = true
            edge.smooth = true
          end
        end
      end

      group
    end

    # Crea un cojín o almohada con bordes suavizados/redondeados orgánicos
    def self.add_rounded_cushion(entities, width, depth, height, material)
      group = entities.add_group
      ents = group.entities

      # Base del cojín
      h_base = height * 0.6
      b = add_box(ents, width, depth, h_base, material, false)

      # Cúpula o bisel superior suavizado
      inset = [width * 0.08, depth * 0.08].min
      w_top = width - inset * 2
      d_top = depth - inset * 2
      h_top = height * 0.4

      pts_base = [
        Geom::Point3d.new(-width / 2.0, -depth / 2.0, h_base),
        Geom::Point3d.new( width / 2.0, -depth / 2.0, h_base),
        Geom::Point3d.new( width / 2.0,  depth / 2.0, h_base),
        Geom::Point3d.new(-width / 2.0,  depth / 2.0, h_base)
      ]
      pts_top = [
        Geom::Point3d.new(-w_top / 2.0, -d_top / 2.0, height),
        Geom::Point3d.new( w_top / 2.0, -d_top / 2.0, height),
        Geom::Point3d.new( w_top / 2.0,  d_top / 2.0, height),
        Geom::Point3d.new(-w_top / 2.0,  d_top / 2.0, height)
      ]

      # Caras del bisel
      4.times do |i|
        j = (i + 1) % 4
        f = ents.add_face([pts_base[i], pts_base[j], pts_top[j], pts_top[i]])
        if f
          f.material = material
          f.back_material = material
        end
      end
      # Tapa superior
      f_top = ents.add_face(pts_top)
      if f_top
        f_top.reverse! if f_top.normal.z < 0
        f_top.material = material
        f_top.back_material = material
      end

      # Suavizar todas las aristas interiores para aspecto acolchado
      ents.grep(Sketchup::Edge).each do |edge|
        edge.soft = true
        edge.smooth = true
      end

      group.material = material
      group
    end

    # Dibuja un tramo de muro 3D garantizando altura positiva (+Z)
    def self.add_wall_segment(entities, p1, p2, thickness, y_bottom, y_top, material)
      height = y_top - y_bottom
      return nil if height <= 0

      dx = p2.x - p1.x
      dy = p2.y - p1.y
      len = Math.sqrt(dx * dx + dy * dy)
      return nil if len < 0.001.m

      nx = -dy / len
      ny =  dx / len
      half_t = thickness / 2.0

      pts = [
        Geom::Point3d.new(p1.x + nx * half_t, p1.y + ny * half_t, y_bottom),
        Geom::Point3d.new(p2.x + nx * half_t, p2.y + ny * half_t, y_bottom),
        Geom::Point3d.new(p2.x - nx * half_t, p2.y - ny * half_t, y_bottom),
        Geom::Point3d.new(p1.x - nx * half_t, p1.y - ny * half_t, y_bottom)
      ]

      group = entities.add_group
      face = group.entities.add_face(pts)
      if face
        # Forzar normal hacia arriba (+Z) para que pushpull extruya hacia el techo
        face.reverse! if face.normal.z < 0
        face.material = material if material
        face.back_material = material if material
        face.pushpull(height)
        group.material = material if material
      end
      group
    end

    # Dibuja un mueble estilizado según su tipo respetando alturas reales y esquinas redondeadas
    def self.create_furniture_geometry(group, item, model)
      ents = group.entities
      type = item['type'].to_s
      color = item['color']
      mat = Materials.furniture_material(model, color)
      wood = Materials.floor_material(model, 'oak')
      dark = Materials.get_or_create(model, 'HC_Metal_Oscuro', '#1B1C21')
      white = Materials.get_or_create(model, 'HC_Blanco_Puro', '#FFFFFF')

      w = (item['width'] || item['size']&.first || default_width(type)).to_f.m
      d = (item['depth'] || item['size']&.last || default_depth(type)).to_f.m
      h = (item['height'] || default_height(type)).to_f.m

      case type
      when 'sofa'
        # Base de patas
        add_box(ents, w, d, 0.10.m, dark)
        # Asiento acolchado
        add_rounded_cushion(ents, w, d, 0.35.m, mat).transformation = Geom::Transformation.translation([0, 0, 0.10.m])
        # Respaldo acolchado
        back = add_rounded_cushion(ents, w, 0.22.m, 0.42.m, mat)
        back.transformation = Geom::Transformation.translation([0, d / 2.0 - 0.11.m, 0.45.m])
        # Brazos con esquinas redondeadas
        arm_l = add_rounded_cushion(ents, 0.18.m, d, 0.25.m, mat)
        arm_l.transformation = Geom::Transformation.translation([-w / 2.0 + 0.09.m, 0, 0.45.m])
        arm_r = add_rounded_cushion(ents, 0.18.m, d, 0.25.m, mat)
        arm_r.transformation = Geom::Transformation.translation([w / 2.0 - 0.09.m, 0, 0.45.m])

      when 'bed'
        # Cabecera de madera
        head = add_box(ents, w + 0.10.m, 0.10.m, 1.02.m, wood)
        head.transformation = Geom::Transformation.translation([0, d / 2.0 - 0.05.m, 0])
        # Base de cama
        add_box(ents, w + 0.04.m, d, 0.26.m, wood)
        # Colchón con suavizado de esquinas
        mattress = add_rounded_cushion(ents, w, d - 0.08.m, 0.22.m, white)
        mattress.transformation = Geom::Transformation.translation([0, -0.04.m, 0.26.m])
        # Almohadas suaves redondeadas
        pw = (w - 0.20.m) / 2.0
        p1 = add_rounded_cushion(ents, pw, 0.42.m, 0.14.m, white)
        p1.transformation = Geom::Transformation.translation([-pw / 2.0 - 0.04.m, d / 2.0 - 0.32.m, 0.48.m])
        p2 = add_rounded_cushion(ents, pw, 0.42.m, 0.14.m, white)
        p2.transformation = Geom::Transformation.translation([pw / 2.0 + 0.04.m, d / 2.0 - 0.32.m, 0.48.m])
        # Edredón / Manta doblada
        blanket = add_rounded_cushion(ents, w + 0.02.m, d * 0.55, 0.06.m, mat)
        blanket.transformation = Geom::Transformation.translation([0, -d * 0.20, 0.48.m])

      when 'tv'
        # Mueble bajo consola
        stand = add_box(ents, w + 0.20.m, 0.38.m, 0.45.m, wood)
        # Pantalla de TV plana
        screen = add_box(ents, w, 0.05.m, 0.72.m, dark)
        screen.transformation = Geom::Transformation.translation([0, 0, 0.45.m])

      when 'diningSet'
        # Mesa de comedor
        table = add_box(ents, w, 0.90.m, 0.05.m, wood)
        table.transformation = Geom::Transformation.translation([0, 0, 0.72.m])
        # 4 Patas cilíndricas
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([-w/2.0 + 0.1.m, -0.35.m, 0])
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([ w/2.0 - 0.1.m, -0.35.m, 0])
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([-w/2.0 + 0.1.m,  0.35.m, 0])
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([ w/2.0 - 0.1.m,  0.35.m, 0])
        # Sillas
        chairs_count = item['chairs'] || 4
        chairs_count.times do |i|
          cx = -w/2.0 + (w / (chairs_count/2.0 + 1)) * (i % (chairs_count/2) + 1)
          cy = (i < chairs_count / 2) ? -0.65.m : 0.65.m
          ch = add_box(ents, 0.42.m, 0.42.m, 0.45.m, mat)
          ch.transformation = Geom::Transformation.translation([cx, cy, 0])
        end

      when 'rug'
        # Alfombra con aristas suavizadas sobre el piso
        add_box(ents, w, d, 0.015.m, mat, true)

      when 'plant'
        # Maceta cónica/cilíndrica
        add_cylinder(ents, 0.18.m, 0.32.m, dark)
        # Planta verde
        green = Materials.get_or_create(model, 'HC_Planta_Verde', '#4F9462')
        plant_h = h > 0.4.m ? (h - 0.32.m) : 0.65.m
        foliage = add_cylinder(ents, 0.28.m, plant_h, green, 16, true)
        foliage.transformation = Geom::Transformation.translation([0, 0, 0.32.m])

      when 'kitchen', 'island'
        # Mueble bajo de cocina y encimera
        stone = Materials.floor_material(model, 'stone')
        add_box(ents, w, d, 0.86.m, dark)
        counter = add_box(ents, w + 0.04.m, d + 0.04.m, 0.04.m, stone)
        counter.transformation = Geom::Transformation.translation([0, 0, 0.86.m])

      when 'fridge'
        # Refrigerador vertical
        add_box(ents, 0.70.m, 0.68.m, 1.85.m, mat, true)

      when 'bathtub'
        add_box(ents, 1.70.m, 0.75.m, 0.55.m, white, true)

      when 'toilet'
        bowl = add_box(ents, 0.40.m, 0.55.m, 0.42.m, white, true)
        tank = add_box(ents, 0.40.m, 0.22.m, 0.40.m, white, true)
        tank.transformation = Geom::Transformation.translation([0, 0.20.m, 0.42.m])

      when 'armchair'
        add_rounded_cushion(ents, w, d, 0.45.m, mat)
        back = add_rounded_cushion(ents, w, 0.20.m, 0.35.m, mat)
        back.transformation = Geom::Transformation.translation([0, d / 2.0 - 0.10.m, 0.45.m])

      else
        # Elemento genérico / Personalizado (mesas, escritorios, autos, etc.)
        add_box(ents, w, d, h, mat, true)
      end
    end

    # Dibuja luminarias con su geometría real suspendida hacia abajo desde el techo o parada en el piso
    def self.create_light_geometry(group, light, wall_height, model)
      ents = group.entities
      type = light['type'].to_s
      color = light['color']
      light_mat = Materials.light_material(model, color)
      brass = Materials.get_or_create(model, 'HC_Luz_Metal', '#D4AF37')
      dark = Materials.get_or_create(model, 'HC_Metal_Oscuro', '#1B1C21')

      case type
      when 'ceiling'
        # Lámpara adosada al techo: fixture contra el techo, difusor hacia abajo
        h_ceil = wall_height
        add_cylinder(ents, 0.22.m, 0.03.m, brass).transformation = Geom::Transformation.translation([0, 0, h_ceil - 0.03.m])
        add_cylinder(ents, 0.18.m, 0.04.m, light_mat).transformation = Geom::Transformation.translation([0, 0, h_ceil - 0.07.m])

      when 'pendant'
        # Lámpara colgante: florón en techo, cable que baja hasta la altura 'y', y pantalla esférica
        py = light['y'] ? light['y'].to_f.m : 1.75.m
        h_ceil = wall_height
        # Florón techo
        add_cylinder(ents, 0.06.m, 0.03.m, dark).transformation = Geom::Transformation.translation([0, 0, h_ceil - 0.03.m])
        # Cable colgante desde el techo hasta py
        cable_len = [h_ceil - py - 0.20.m, 0.1.m].max
        add_cylinder(ents, 0.006.m, cable_len, dark).transformation = Geom::Transformation.translation([0, 0, py + 0.20.m])
        # Pantalla / Esfera iluminada
        shade = add_cylinder(ents, 0.18.m, 0.18.m, brass)
        shade.transformation = Geom::Transformation.translation([0, 0, py + 0.04.m])
        bulb = add_cylinder(ents, 0.10.m, 0.08.m, light_mat)
        bulb.transformation = Geom::Transformation.translation([0, 0, py - 0.04.m])

      when 'spots'
        # Riel de focos adosado al techo
        h_ceil = wall_height
        rail = add_box(ents, 0.95.m, 0.06.m, 0.03.m, dark)
        rail.transformation = Geom::Transformation.translation([0, 0, h_ceil - 0.03.m])
        # 3 focos direccionales
        [-0.32.m, 0, 0.32.m].each do |sx|
          spot = add_cylinder(ents, 0.045.m, 0.08.m, light_mat)
          spot.transformation = Geom::Transformation.translation([sx, 0, h_ceil - 0.11.m])
        end

      when 'floor'
        # Lámpara de pie parada en el piso
        add_cylinder(ents, 0.18.m, 0.025.m, dark)
        add_cylinder(ents, 0.012.m, 1.30.m, brass).transformation = Geom::Transformation.translation([0, 0, 0.025.m])
        shade = add_cylinder(ents, 0.20.m, 0.30.m, light_mat)
        shade.transformation = Geom::Transformation.translation([0, 0, 1.30.m])

      when 'table'
        # Lámpara de mesa situada sobre mesita / buró a altura 'y'
        py = light['y'] ? light['y'].to_f.m : 0.50.m
        add_cylinder(ents, 0.10.m, 0.02.m, brass).transformation = Geom::Transformation.translation([0, 0, py])
        add_cylinder(ents, 0.012.m, 0.22.m, brass).transformation = Geom::Transformation.translation([0, 0, py + 0.02.m])
        shade = add_cylinder(ents, 0.14.m, 0.18.m, light_mat)
        shade.transformation = Geom::Transformation.translation([0, 0, py + 0.20.m])

      when 'strip'
        # Tira LED lineal a la altura indicada
        py = light['y'] ? light['y'].to_f.m : 1.10.m
        len = (light['length'] || 1.5).to_f.m
        strip = add_box(ents, len, 0.04.m, 0.025.m, light_mat)
        strip.transformation = Geom::Transformation.translation([0, 0, py])

      else
        # Foco genérico
        py = light['y'] ? light['y'].to_f.m : wall_height - 0.15.m
        add_cylinder(ents, 0.12.m, 0.06.m, light_mat).transformation = Geom::Transformation.translation([0, 0, py])
      end
    end

    # Dibuja un mini-split (Aire Acondicionado) suspendido en muro a su altura real
    def self.create_ac_geometry(group, ac, model)
      ents = group.entities
      ac_body = Materials.ac_material(model)
      ac_vent = Materials.ac_vent_material(model)
      ac_led = Materials.get_or_create(model, 'HC_AC_LED', '#00D2FF')

      w = 0.90.m
      d = 0.22.m
      h = 0.30.m
      py = (ac['y'] || 2.2).to_f.m

      # Cuerpo principal a la altura 'py' con esquinas suavizadas
      body = add_box(ents, w, d, h, ac_body, true)
      body.transformation = Geom::Transformation.translation([0, 0, py])

      # Rejilla inferior de ventilación
      vent = add_box(ents, w - 0.10.m, 0.06.m, 0.04.m, ac_vent)
      vent.transformation = Geom::Transformation.translation([0, -d/2.0 + 0.04.m, py + 0.02.m])

      # Indicador LED digital
      led = add_box(ents, 0.06.m, 0.01.m, 0.03.m, ac_led)
      led.transformation = Geom::Transformation.translation([w/2.0 - 0.15.m, -d/2.0 + 0.005.m, py + h/2.0])
    end

    def self.default_width(type)
      case type
      when 'rug' then 2.0
      when 'sofa' then 2.2
      when 'armchair' then 0.92
      when 'coffeeTable' then 1.1
      when 'tv' then 1.7
      when 'sideboard' then 1.6
      when 'diningSet' then 1.8
      when 'island' then 2.0
      when 'kitchen' then 3.0
      when 'fridge' then 0.7
      when 'bed' then 1.8
      when 'nightstand' then 0.46
      when 'dresser' then 1.3
      when 'plant' then 0.45
      when 'vanity' then 1.0
      when 'bathtub' then 1.7
      when 'toilet' then 0.4
      when 'desk' then 1.4
      when 'wardrobe' then 1.6
      when 'bookshelf' then 1.0
      else 0.8
      end
    end

    def self.default_depth(type)
      case type
      when 'rug' then 1.5
      when 'sofa' then 0.95
      when 'armchair' then 0.88
      when 'coffeeTable' then 0.58
      when 'tv' then 0.40
      when 'sideboard' then 0.42
      when 'diningSet' then 1.90
      when 'island' then 1.10
      when 'kitchen' then 0.65
      when 'fridge' then 0.68
      when 'bed' then 2.10
      when 'nightstand' then 0.40
      when 'dresser' then 0.45
      when 'plant' then 0.45
      when 'vanity' then 0.50
      when 'bathtub' then 0.78
      when 'toilet' then 0.66
      when 'desk' then 0.65
      when 'wardrobe' then 0.60
      when 'bookshelf' then 0.35
      else 0.8
      end
    end

    def self.default_height(type)
      case type
      when 'rug' then 0.02
      when 'sofa' then 0.85
      when 'armchair' then 0.80
      when 'coffeeTable' then 0.45
      when 'tv' then 1.20
      when 'sideboard' then 0.80
      when 'diningSet' then 0.76
      when 'island' then 0.90
      when 'kitchen' then 0.90
      when 'fridge' then 1.85
      when 'bed' then 0.95
      when 'nightstand' then 0.50
      when 'dresser' then 0.85
      when 'plant' then 1.10
      when 'vanity' then 0.85
      when 'bathtub' then 0.55
      when 'toilet' then 0.80
      when 'desk' then 0.75
      when 'wardrobe' then 2.10
      when 'bookshelf' then 1.80
      else 0.8
      end
    end
  end
end
