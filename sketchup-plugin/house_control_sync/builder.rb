# encoding: UTF-8
module HouseControlSync
  module Builder
    # Dibuja un prisma rectangular (box) en el sistema local
    def self.add_box(entities, width, depth, height, material = nil)
      group = entities.add_group
      pts = [
        Geom::Point3d.new(-width / 2.0, -depth / 2.0, 0),
        Geom::Point3d.new( width / 2.0, -depth / 2.0, 0),
        Geom::Point3d.new( width / 2.0,  depth / 2.0, 0),
        Geom::Point3d.new(-width / 2.0,  depth / 2.0, 0)
      ]
      face = group.entities.add_face(pts)
      if face
        face.material = material if material
        face.back_material = material if material
        face.pushpull(height) if height > 0
        group.material = material if material
      end
      group
    end

    # Dibuja un cilindro vertical
    def self.add_cylinder(entities, radius, height, material = nil, segments = 16)
      group = entities.add_group
      center = Geom::Point3d.new(0, 0, 0)
      normal = Geom::Vector3d.new(0, 0, 1)
      circle = group.entities.add_circle(center, normal, radius, segments)
      face = group.entities.add_face(circle)
      if face
        face.material = material if material
        face.pushpull(height) if height > 0
        group.material = material if material
      end
      group
    end

    # Dibuja un tramo de muro 3D entre dos puntos en coordenadas de SketchUp
    def self.add_wall_segment(entities, p1, p2, thickness, y_bottom, y_top, material)
      height = y_top - y_bottom
      return nil if height <= 0

      dx = p2.x - p1.x
      dy = p2.y - p1.y
      len = Math.sqrt(dx * dx + dy * dy)
      return nil if len < 0.001.m

      # Vector perpendicular horizontal (normal al muro)
      nx = -dy / len
      ny =  dx / len
      half_t = thickness / 2.0

      # 4 esquinas de la base
      pts = [
        Geom::Point3d.new(p1.x + nx * half_t, p1.y + ny * half_t, y_bottom),
        Geom::Point3d.new(p2.x + nx * half_t, p2.y + ny * half_t, y_bottom),
        Geom::Point3d.new(p2.x - nx * half_t, p2.y - ny * half_t, y_bottom),
        Geom::Point3d.new(p1.x - nx * half_t, p1.y - ny * half_t, y_bottom)
      ]

      group = entities.add_group
      face = group.entities.add_face(pts)
      if face
        face.material = material if material
        face.pushpull(height)
        group.material = material if material
      end
      group
    end

    # Dibuja un mueble estilizado según su tipo
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
        add_box(ents, w, d, 0.12.m, dark)
        # Asiento
        add_box(ents, w, d, 0.45.m, mat).transformation = Geom::Transformation.translation([0, 0, 0.12.m])
        # Respaldo
        back = add_box(ents, w, 0.22.m, 0.40.m, mat)
        back.transformation = Geom::Transformation.translation([0, d / 2.0 - 0.11.m, 0.45.m])
        # Brazos
        arm_l = add_box(ents, 0.18.m, d, 0.25.m, mat)
        arm_l.transformation = Geom::Transformation.translation([-w / 2.0 + 0.09.m, 0, 0.45.m])
        arm_r = add_box(ents, 0.18.m, d, 0.25.m, mat)
        arm_r.transformation = Geom::Transformation.translation([w / 2.0 - 0.09.m, 0, 0.45.m])

      when 'bed'
        # Base / Cabecera
        head = add_box(ents, w, 0.12.m, 0.95.m, wood)
        head.transformation = Geom::Transformation.translation([0, d / 2.0 - 0.06.m, 0])
        # Colchón
        mattress = add_box(ents, w - 0.08.m, d - 0.16.m, 0.45.m, mat)
        mattress.transformation = Geom::Transformation.translation([0, -0.06.m, 0])
        # Almohadas
        p1 = add_box(ents, (w - 0.2.m) / 2.0, 0.40.m, 0.12.m, white)
        p1.transformation = Geom::Transformation.translation([-(w - 0.2.m) / 4.0, d / 2.0 - 0.35.m, 0.45.m])
        p2 = add_box(ents, (w - 0.2.m) / 2.0, 0.40.m, 0.12.m, white)
        p2.transformation = Geom::Transformation.translation([(w - 0.2.m) / 4.0, d / 2.0 - 0.35.m, 0.45.m])

      when 'tv'
        # Pantalla
        screen = add_box(ents, w, 0.06.m, 0.70.m, dark)
        screen.transformation = Geom::Transformation.translation([0, 0, 0.65.m])
        # Mueble soporte
        stand = add_box(ents, w + 0.2.m, 0.38.m, 0.45.m, wood)

      when 'diningSet'
        # Mesa
        table = add_box(ents, w, 0.90.m, 0.06.m, wood)
        table.transformation = Geom::Transformation.translation([0, 0, 0.72.m])
        # Patas
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([-w/2.0 + 0.1.m, -0.35.m, 0])
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([ w/2.0 - 0.1.m, -0.35.m, 0])
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([-w/2.0 + 0.1.m,  0.35.m, 0])
        add_cylinder(ents, 0.03.m, 0.72.m, dark).transformation = Geom::Transformation.translation([ w/2.0 - 0.1.m,  0.35.m, 0])
        # Sillas representativas
        chairs_count = item['chairs'] || 4
        chairs_count.times do |i|
          cx = -w/2.0 + (w / (chairs_count/2.0 + 1)) * (i % (chairs_count/2) + 1)
          cy = (i < chairs_count / 2) ? -0.65.m : 0.65.m
          ch = add_box(ents, 0.42.m, 0.42.m, 0.45.m, mat)
          ch.transformation = Geom::Transformation.translation([cx, cy, 0])
        end

      when 'rug'
        # Alfombra plana
        add_box(ents, w, d, 0.015.m, mat)

      when 'plant'
        # Maceta cilíndrica
        pot = add_cylinder(ents, 0.20.m, 0.35.m, dark)
        # Follaje verde
        green = Materials.get_or_create(model, 'HC_Planta_Verde', '#4F9462')
        foliage = add_cylinder(ents, 0.32.m, h > 0.4.m ? (h - 0.35.m) : 0.60.m, green)
        foliage.transformation = Geom::Transformation.translation([0, 0, 0.35.m])

      when 'kitchen', 'island'
        # Mueble bajo y encimera
        stone = Materials.floor_material(model, 'stone')
        add_box(ents, w, d, 0.86.m, dark)
        counter = add_box(ents, w + 0.04.m, d + 0.04.m, 0.04.m, stone)
        counter.transformation = Geom::Transformation.translation([0, 0, 0.86.m])

      when 'bathtub'
        add_box(ents, 1.70.m, 0.75.m, 0.55.m, white)

      when 'toilet'
        bowl = add_box(ents, 0.40.m, 0.55.m, 0.42.m, white)
        tank = add_box(ents, 0.40.m, 0.22.m, 0.40.m, white)
        tank.transformation = Geom::Transformation.translation([0, 0.22.m, 0.40.m])

      else
        # Forma cúbica estándar proporcional
        add_box(ents, w, d, h, mat)
      end
    end

    # Dibuja una lámpara o luz en 3D
    def self.create_light_geometry(group, light, model)
      ents = group.entities
      type = light['type'].to_s
      color = light['color']
      light_mat = Materials.light_material(model, color)
      brass = Materials.get_or_create(model, 'HC_Luz_Metal', '#D4AF37')
      dark = Materials.get_or_create(model, 'HC_Metal_Oscuro', '#1B1C21')

      case type
      when 'pendant'
        # Cable colgante y pantalla
        add_cylinder(ents, 0.008.m, 0.60.m, dark).transformation = Geom::Transformation.translation([0, 0, -0.60.m])
        shade = add_cylinder(ents, 0.18.m, 0.22.m, brass)
        shade.transformation = Geom::Transformation.translation([0, 0, -0.82.m])
        bulb = add_cylinder(ents, 0.06.m, 0.08.m, light_mat)
        bulb.transformation = Geom::Transformation.translation([0, 0, -0.85.m])

      when 'ceiling'
        # Plafón de techo circular
        base = add_cylinder(ents, 0.22.m, 0.04.m, brass)
        diffuser = add_cylinder(ents, 0.20.m, 0.03.m, light_mat)
        diffuser.transformation = Geom::Transformation.translation([0, 0, -0.03.m])

      when 'spots'
        # Riel o foco direccional
        add_box(ents, 0.10.m, 0.10.m, 0.04.m, dark)
        spot = add_cylinder(ents, 0.045.m, 0.09.m, light_mat)
        spot.transformation = Geom::Transformation.translation([0, 0, -0.09.m])

      when 'floor'
        # Lámpara de pie
        add_cylinder(ents, 0.18.m, 0.02.m, dark)
        add_cylinder(ents, 0.015.m, 1.40.m, brass)
        shade = add_cylinder(ents, 0.20.m, 0.32.m, light_mat)
        shade.transformation = Geom::Transformation.translation([0, 0, 1.35.m])

      when 'table'
        # Lámpara de mesa
        add_cylinder(ents, 0.10.m, 0.02.m, brass)
        add_cylinder(ents, 0.012.m, 0.35.m, brass)
        shade = add_cylinder(ents, 0.14.m, 0.20.m, light_mat)
        shade.transformation = Geom::Transformation.translation([0, 0, 0.30.m])

      when 'strip'
        # Tira LED lineal
        len = (light['length'] || 1.5).to_f.m
        add_box(ents, len, 0.03.m, 0.02.m, light_mat)

      else
        # Marcador genérico de luz
        add_cylinder(ents, 0.12.m, 0.06.m, light_mat)
      end
    end

    # Dibuja un mini-split (Aire Acondicionado)
    def self.create_ac_geometry(group, ac, model)
      ents = group.entities
      ac_body = Materials.ac_material(model)
      ac_vent = Materials.ac_vent_material(model)
      ac_led = Materials.get_or_create(model, 'HC_AC_LED', '#00D2FF')

      w = 0.90.m
      d = 0.22.m
      h = 0.30.m

      # Cuerpo principal blanco con perfil aerodinámico
      add_box(ents, w, d, h, ac_body)
      # Rejilla inferior de ventilación
      vent = add_box(ents, w - 0.10.m, 0.06.m, 0.04.m, ac_vent)
      vent.transformation = Geom::Transformation.translation([0, -d/2.0 + 0.04.m, 0.02.m])
      # Indicador LED digital
      led = add_box(ents, 0.06.m, 0.01.m, 0.03.m, ac_led)
      led.transformation = Geom::Transformation.translation([w/2.0 - 0.15.m, -d/2.0 + 0.005.m, h/2.0])
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
