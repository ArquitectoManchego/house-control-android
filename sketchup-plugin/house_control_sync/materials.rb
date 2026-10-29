# encoding: UTF-8
module HouseControlSync
  module Materials
    def self.get_or_create(model, name, rgb_hex, alpha = 1.0)
      mat = model.materials[name]
      return mat if mat

      mat = model.materials.add(name)
      # Parse hex color
      hex = rgb_hex.sub(/^#/, '')
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
        get_or_create(model, 'HC_Piso_Nogal', '#5A4334')
      when 'tile'
        get_or_create(model, 'HC_Piso_Azulejo', '#D5D8DC')
      when 'stone'
        get_or_create(model, 'HC_Piso_Piedra', '#7F8C8D')
      else # oak / default
        get_or_create(model, 'HC_Piso_Roble', '#C8A26A')
      end
    end

    def self.wall_material(model)
      get_or_create(model, 'HC_Pared', '#E7E3DB')
    end

    def self.wall_cap_material(model)
      get_or_create(model, 'HC_Pared_Remate', '#262B3A')
    end

    def self.glass_material(model)
      get_or_create(model, 'HC_Vidrio', '#9CC0FF', 0.35)
    end

    def self.frame_material(model)
      get_or_create(model, 'HC_Marco', '#2C3142')
    end

    def self.light_material(model, hex_color = nil)
      color = hex_color && !hex_color.empty? ? hex_color : '#FFDE59'
      get_or_create(model, "HC_Luz_#{color.sub('#', '')}", color)
    end

    def self.ac_material(model)
      get_or_create(model, 'HC_Clima_Cuerpo', '#F2F4F4')
    end

    def self.ac_vent_material(model)
      get_or_create(model, 'HC_Clima_Rejilla', '#1B1C21')
    end

    def self.furniture_material(model, hex_color = nil)
      color = hex_color && !hex_color.empty? ? hex_color : '#8B93A7'
      get_or_create(model, "HC_Mueble_#{color.sub('#', '')}", color)
    end
  end
end
