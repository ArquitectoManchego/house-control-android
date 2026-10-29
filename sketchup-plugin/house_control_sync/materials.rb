# encoding: UTF-8
module HouseControlSync
  module Materials
    # Catálogo Lumion de Materiales Arquitectónicos de Alta Fidelidad
    CATALOG_MATERIALS = {
      # --- MADERAS (WOODS) ---
      'wood_oak' => {
        name: 'Roble Europeo Natural',
        category: 'Maderas',
        skp_name: 'HC_Mat_Roble_Natural',
        hex: '#C8A26A',
        roughness: 0.4
      },
      'wood_walnut' => {
        name: 'Nogal Americano Oscuro',
        category: 'Maderas',
        skp_name: 'HC_Mat_Nogal_Oscuro',
        hex: '#4A3528',
        roughness: 0.35
      },
      'wood_ash' => {
        name: 'Fresno Nórdico Claro',
        category: 'Maderas',
        skp_name: 'HC_Mat_Fresno_Claro',
        hex: '#D9C9A8',
        roughness: 0.45
      },
      'wood_teak' => {
        name: 'Teca Escandinava',
        category: 'Maderas',
        skp_name: 'HC_Mat_Teca',
        hex: '#8B5A2B',
        roughness: 0.4
      },
      'wood_ebony' => {
        name: 'Ébano Carbón',
        category: 'Maderas',
        skp_name: 'HC_Mat_Ebano_Negro',
        hex: '#201B18',
        roughness: 0.3
      },
      'wood_white' => {
        name: 'Madera Blanca Decapé',
        category: 'Maderas',
        skp_name: 'HC_Mat_Madera_Blanca',
        hex: '#EAE6DD',
        roughness: 0.5
      },

      # --- PIEDRAS Y CERÁMICAS (STONES & TILES) ---
      'stone_carrara' => {
        name: 'Mármol Blanco Carrara',
        category: 'Piedras y Porcelanatos',
        skp_name: 'HC_Mat_Marmol_Carrara',
        hex: '#EAEBED',
        roughness: 0.15
      },
      'stone_black_galaxy' => {
        name: 'Granito Negro Galaxy',
        category: 'Piedras y Porcelanatos',
        skp_name: 'HC_Mat_Granito_Negro',
        hex: '#1B1E23',
        roughness: 0.1
      },
      'stone_slate' => {
        name: 'Piedra Pizarra Gris',
        category: 'Piedras y Porcelanatos',
        skp_name: 'HC_Mat_Pizarra_Gris',
        hex: '#5A6577',
        roughness: 0.6
      },
      'tile_white_subway' => {
        name: 'Azulejo Satinado Blanco',
        category: 'Piedras y Porcelanatos',
        skp_name: 'HC_Mat_Azulejo_Blanco',
        hex: '#E2E6E8',
        roughness: 0.2
      },
      'tile_terrazzo' => {
        name: 'Terrazo Veneciano Moderno',
        category: 'Piedras y Porcelanatos',
        skp_name: 'HC_Mat_Terrazo',
        hex: '#D6D2C9',
        roughness: 0.3
      },
      'concrete_polished' => {
        name: 'Microcemento / Hormigón Pulido',
        category: 'Piedras y Porcelanatos',
        skp_name: 'HC_Mat_Microcemento',
        hex: '#9AA0A6',
        roughness: 0.5
      },

      # --- METALES (METALS) ---
      'metal_black_matte' => {
        name: 'Aluminio Negro Mate',
        category: 'Metales',
        skp_name: 'HC_Mat_Negro_Mate',
        hex: '#181A1F',
        roughness: 0.3
      },
      'metal_brass_gold' => {
        name: 'Latón Dorado Cepillado',
        category: 'Metales',
        skp_name: 'HC_Mat_Laton_Dorado',
        hex: '#D4AF37',
        roughness: 0.25
      },
      'metal_chrome' => {
        name: 'Cromo Brillante Espejo',
        category: 'Metales',
        skp_name: 'HC_Mat_Cromo',
        hex: '#E2E6EA',
        roughness: 0.05
      },
      'metal_stainless' => {
        name: 'Acero Inoxidable Satinado',
        category: 'Metales',
        skp_name: 'HC_Mat_Acero_Inox',
        hex: '#A8ADB5',
        roughness: 0.25
      },
      'metal_copper' => {
        name: 'Cobre Cepillado Cálido',
        category: 'Metales',
        skp_name: 'HC_Mat_Cobre',
        hex: '#B87333',
        roughness: 0.3
      },
      'metal_bronze' => {
        name: 'Bronce Arquitectónico',
        category: 'Metales',
        skp_name: 'HC_Mat_Bronce',
        hex: '#6E5642',
        roughness: 0.35
      },

      # --- CRISTALES Y VIDRIOS (GLASS) ---
      'glass_clear' => {
        name: 'Vidrio Cristalino Ultraclaro',
        category: 'Cristales',
        skp_name: 'HC_Mat_Vidrio_Claro',
        hex: '#D6EBF8',
        alpha: 0.25
      },
      'glass_blue' => {
        name: 'Vidrio Smart Tint Azul',
        category: 'Cristales',
        skp_name: 'HC_Mat_Vidrio_Azul',
        hex: '#9CC0FF',
        alpha: 0.35
      },
      'glass_smoked' => {
        name: 'Vidrio Fumé Ahumado',
        category: 'Cristales',
        skp_name: 'HC_Mat_Vidrio_Fume',
        hex: '#3B3E45',
        alpha: 0.45
      },
      'glass_frosted' => {
        name: 'Vidrio Esmerilado Traslúcido',
        category: 'Cristales',
        skp_name: 'HC_Mat_Vidrio_Esmerilado',
        hex: '#F0F4F8',
        alpha: 0.65
      },

      # --- PINTURAS Y PAREDES (WALL PAINTS) ---
      'paint_warm_white' => {
        name: 'Blanco Cálido Architectural',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Blanco_Calido',
        hex: '#F5F4EE',
        roughness: 0.7
      },
      'paint_pure_white' => {
        name: 'Blanco Nieve Puro',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Blanco_Puro',
        hex: '#FFFFFF',
        roughness: 0.7
      },
      'paint_soft_gray' => {
        name: 'Gris Neutro Suave',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Gris_Suave',
        hex: '#B8BCBE',
        roughness: 0.7
      },
      'paint_deep_navy' => {
        name: 'Azul Profundo Medianoche',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Azul_Medianoche',
        hex: '#1D2A44',
        roughness: 0.7
      },
      'paint_sage_green' => {
        name: 'Verde Salvia Nórdico',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Verde_Salvia',
        hex: '#7C8B7A',
        roughness: 0.7
      },
      'paint_terracotta' => {
        name: 'Terracota Mediterráneo',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Terracota',
        hex: '#BD664F',
        roughness: 0.7
      },
      'paint_charcoal' => {
        name: 'Antracita Urbano',
        category: 'Pinturas',
        skp_name: 'HC_Mat_Antracita',
        hex: '#2A2D34',
        roughness: 0.7
      },

      # --- TELAS Y TAPICERÍA (FABRICS & LEATHER) ---
      'fabric_linen_light' => {
        name: 'Lino Textil Gris Perla',
        category: 'Telas y Tapicería',
        skp_name: 'HC_Mat_Lino_Gris',
        hex: '#CBCDC8',
        roughness: 0.8
      },
      'fabric_linen_navy' => {
        name: 'Lino Azul Marino',
        category: 'Telas y Tapicería',
        skp_name: 'HC_Mat_Lino_Azul',
        hex: '#2C3A50',
        roughness: 0.8
      },
      'fabric_leather_caramel' => {
        name: 'Cuero Caramelo Vintage',
        category: 'Telas y Tapicería',
        skp_name: 'HC_Mat_Cuero_Caramelo',
        hex: '#94593B',
        roughness: 0.5
      },
      'fabric_velvet_emerald' => {
        name: 'Terciopelo Esmeralda',
        category: 'Telas y Tapicería',
        skp_name: 'HC_Mat_Terciopelo_Esmeralda',
        hex: '#1F4E3D',
        roughness: 0.6
      },
      'fabric_velvet_mustard' => {
        name: 'Terciopelo Mostaza Ocre',
        category: 'Telas y Tapicería',
        skp_name: 'HC_Mat_Terciopelo_Mostaza',
        hex: '#D8A232',
        roughness: 0.6
      },
      'fabric_dark_gray' => {
        name: 'Tapicería Gris Marengo',
        category: 'Telas y Tapicería',
        skp_name: 'HC_Mat_Tapiceria_Gris',
        hex: '#3A3F4D',
        roughness: 0.85
      }
    }.freeze

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

    # Aplica un material del catálogo Lumion a la selección activa o lo carga en el pincel
    def self.apply_catalog_material(model, mat_id)
      spec = CATALOG_MATERIALS[mat_id.to_s]
      return { success: false, name: 'Material no encontrado' } unless spec

      mat = get_or_create(model, spec[:skp_name], spec[:hex], spec[:alpha] || 1.0)
      model.materials.current = mat

      sel = model.selection
      applied_count = 0

      unless sel.empty?
        model.start_operation("Aplicar Material #{spec[:name]}", true)
        sel.each do |e|
          if e.is_a?(Sketchup::Face) || e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)
            e.material = mat
            applied_count += 1
          end
        end
        model.commit_operation
      end

      {
        success: true,
        id: mat_id,
        name: spec[:name],
        category: spec[:category],
        hex: spec[:hex],
        applied_count: applied_count
      }
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
