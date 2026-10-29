# encoding: UTF-8
module HouseControlSync
  module Materials
    def self.get_or_create(model, name, rgb_hex, alpha = 1.0)
      mat = model.materials[name]
      return mat if mat

      mat = model.materials.add(name)
      hex = rgb_hex.to_s.sub(/^#/, '')
      hex = '888888' if hex.empty?
      r = hex[0..1].to_i(16)
      g = hex[2..3].to_i(16)
      b = hex[4..5].to_i(16)
      mat.color = Sketchup::Color.new(r, g, b)
      mat.alpha = alpha if alpha < 1.0
      mat
    end

    def self.floor_material(model, floor_type)
      case floor_type.to_s.downcase
      when 'walnut'
        get_or_create(model, 'HC_Piso_Nogal', '#4A3528')
      when 'tile'
        get_or_create(model, 'HC_Piso_Azulejo', '#D8DCDE')
      when 'stone'
        get_or_create(model, 'HC_Piso_Piedra', '#6C7A89')
      else # oak / roble default
        get_or_create(model, 'HC_Piso_Roble', '#C8A26A')
      end
    end

    def self.wall_material(model)
      get_or_create(model, 'HC_Pared', '#E8E5DC')
    end

    def self.wall_cap_material(model)
      get_or_create(model, 'HC_Pared_Remate', '#262B3A')
    end

    def self.glass_material(model)
      get_or_create(model, 'HC_Vidrio_Azul', '#9CC0FF', 0.35)
    end

    def self.frame_material(model)
      get_or_create(model, 'HC_Carpinteria_Negra', '#242730')
    end

    def self.light_material(model, hex_color = nil)
      color = hex_color && !hex_color.empty? ? hex_color : '#FFDE59'
      clean_hex = color.sub('#', '')
      get_or_create(model, "HC_Luz_#{clean_hex}", color)
    end

    def self.ac_material(model)
      get_or_create(model, 'HC_Clima_Cuerpo', '#F5F7F8')
    end

    def self.ac_vent_material(model)
      get_or_create(model, 'HC_Clima_Rejilla', '#1A1C20')
    end

    def self.furniture_material(model, hex_color = nil)
      color = hex_color && !hex_color.empty? ? hex_color : '#8B93A7'
      clean_hex = color.sub('#', '')
      get_or_create(model, "HC_Mueble_#{clean_hex}", color)
    end

    # Extrae el color hexadecimal de cualquier material aplicado por el usuario en SketchUp
    def self.extract_hex(material)
      return nil unless material
      c = material.color
      return nil unless c
      sprintf('#%02X%02X%02X', c.red, c.green, c.blue)
    end

    # Detecta el tipo de piso según el material aplicado en SketchUp
    def self.detect_floor_type(material)
      return 'oak' unless material
      name = material.name.to_s.downcase
      if name.include?('nogal') || name.include?('walnut') || name.include?('madera_oscura')
        'walnut'
      elsif name.include?('azulejo') || name.include?('tile') || name.include?('ceram')
        'tile'
      elsif name.include?('piedra') || name.include?('stone') || name.include?('marmol') || name.include?('slate')
        'stone'
      else
        'oak'
      end
    end
  end
end
