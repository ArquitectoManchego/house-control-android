/**
 * LUMION 3D OBJECTS & MATERIALS CATALOG - JAVASCRIPT CONTROLLER
 * Full interactive controller connecting SketchUp Ruby API with CEF UI
 */

// ============================================================================
// BASE DE DATOS DEL CATÁLOGO DE OBJETOS
// ============================================================================
const CATALOG_ITEMS = [
  // --- MOBILIARIO (LIVING / SALÓN / OFICINA) ---
  {
    id: 'sofa_3p',
    type: 'sofa',
    category: 'furniture',
    sub: 'sofa',
    name: 'Sofá Moderno 3 Plazas',
    tag: 'Salón',
    width: 2.20,
    depth: 0.95,
    height: 0.85,
    color: '#3B4D66',
    icon: 'sofa'
  },
  {
    id: 'sofa_l_sec',
    type: 'sofa_l',
    category: 'furniture',
    sub: 'sofa',
    name: 'Sofá Seccional en L',
    tag: 'Salón',
    width: 2.70,
    depth: 1.75,
    height: 0.85,
    color: '#4A5568',
    icon: 'sofa_l'
  },
  {
    id: 'armchair_mod',
    type: 'armchair',
    category: 'furniture',
    sub: 'sofa',
    name: 'Sillón Individual Butaca',
    tag: 'Salón',
    width: 0.92,
    depth: 0.88,
    height: 0.80,
    color: '#D97736',
    icon: 'armchair'
  },
  {
    id: 'coffee_table_wood',
    type: 'coffeeTable',
    category: 'furniture',
    sub: 'table',
    name: 'Mesa de Centro Roble & Metal',
    tag: 'Salón',
    width: 1.10,
    depth: 0.58,
    height: 0.45,
    color: '#C8A26A',
    icon: 'coffee_table'
  },
  {
    id: 'side_table_round',
    type: 'side_table',
    category: 'furniture',
    sub: 'table',
    name: 'Mesita Auxiliar Redonda',
    tag: 'Salón',
    width: 0.50,
    depth: 0.50,
    height: 0.52,
    color: '#262A33',
    icon: 'side_table'
  },
  {
    id: 'tv_unit_65',
    type: 'tv',
    category: 'furniture',
    sub: 'storage',
    name: 'Mueble TV con Pantalla 65"',
    tag: 'Salón',
    width: 1.70,
    depth: 0.40,
    height: 1.20,
    color: '#1B1C21',
    icon: 'tv'
  },
  {
    id: 'dining_set_6p',
    type: 'diningSet',
    category: 'furniture',
    sub: 'table',
    name: 'Mesa de Comedor 6 Personas',
    tag: 'Comedor',
    width: 1.80,
    depth: 1.90,
    height: 0.76,
    color: '#C8A26A',
    icon: 'dining_set'
  },
  {
    id: 'dining_round_4p',
    type: 'dining_round',
    category: 'furniture',
    sub: 'table',
    name: 'Mesa Redonda con 4 Sillas',
    tag: 'Comedor',
    width: 1.20,
    depth: 1.20,
    height: 0.76,
    color: '#4A3528',
    icon: 'dining_round'
  },
  {
    id: 'desk_office',
    type: 'desk',
    category: 'furniture',
    sub: 'office',
    name: 'Escritorio Moderno de Trabajo',
    tag: 'Oficina',
    width: 1.40,
    depth: 0.65,
    height: 0.75,
    color: '#C8A26A',
    icon: 'desk'
  },
  {
    id: 'office_chair_erg',
    type: 'office_chair',
    category: 'furniture',
    sub: 'office',
    name: 'Silla Ergonómica Giratoria',
    tag: 'Oficina',
    width: 0.60,
    depth: 0.60,
    height: 0.95,
    color: '#1F2430',
    icon: 'office_chair'
  },
  {
    id: 'bookshelf_mod',
    type: 'bookshelf',
    category: 'furniture',
    sub: 'storage',
    name: 'Librero Moderno Abierto',
    tag: 'Salón / Estudio',
    width: 1.00,
    depth: 0.35,
    height: 1.80,
    color: '#C8A26A',
    icon: 'bookshelf'
  },
  {
    id: 'rug_living',
    type: 'rug',
    category: 'furniture',
    sub: 'decor',
    name: 'Alfombra de Salón Suavizada',
    tag: 'Salón',
    width: 2.00,
    depth: 1.50,
    height: 0.02,
    color: '#8E9AA8',
    icon: 'rug'
  },

  // --- DORMITORIO ---
  {
    id: 'bed_king',
    type: 'bed',
    category: 'bedroom',
    sub: 'bed',
    name: 'Cama King Size con Almohadas',
    tag: 'Dormitorio',
    width: 1.80,
    depth: 2.10,
    height: 1.00,
    color: '#34495E',
    icon: 'bed'
  },
  {
    id: 'bed_queen',
    type: 'bed_queen',
    category: 'bedroom',
    sub: 'bed',
    name: 'Cama Queen Size',
    tag: 'Dormitorio',
    width: 1.60,
    depth: 2.00,
    height: 1.00,
    color: '#5D6D7E',
    icon: 'bed'
  },
  {
    id: 'bed_single',
    type: 'bed_single',
    category: 'bedroom',
    sub: 'bed',
    name: 'Cama Individual Juvenil',
    tag: 'Dormitorio',
    width: 1.00,
    depth: 1.90,
    height: 0.90,
    color: '#4B6584',
    icon: 'bed'
  },
  {
    id: 'nightstand_drawer',
    type: 'nightstand',
    category: 'bedroom',
    sub: 'storage',
    name: 'Buró de Noche con Cajón',
    tag: 'Dormitorio',
    width: 0.48,
    depth: 0.40,
    height: 0.50,
    color: '#C8A26A',
    icon: 'nightstand'
  },
  {
    id: 'dresser_6d',
    type: 'dresser',
    category: 'bedroom',
    sub: 'storage',
    name: 'Cómoda 6 Cajones',
    tag: 'Dormitorio',
    width: 1.30,
    depth: 0.45,
    height: 0.85,
    color: '#4A3528',
    icon: 'dresser'
  },
  {
    id: 'wardrobe_2d',
    type: 'wardrobe',
    category: 'bedroom',
    sub: 'storage',
    name: 'Armario Clóset 2 Puertas',
    tag: 'Dormitorio',
    width: 1.80,
    depth: 0.60,
    height: 2.20,
    color: '#D8D4CC',
    icon: 'wardrobe'
  },

  // --- ILUMINACIÓN ---
  {
    id: 'light_ceiling_led',
    type: 'ceiling',
    category: 'lighting',
    sub: 'ceiling',
    name: 'Plafón Circular LED Techo',
    tag: 'Smart Life',
    width: 0.45,
    depth: 0.45,
    height: 0.07,
    color: '#FFEAA7',
    tuya: 'smart_ceiling_light',
    icon: 'light_ceiling'
  },
  {
    id: 'light_pendant_globe',
    type: 'pendant',
    category: 'lighting',
    sub: 'pendant',
    name: 'Lámpara Colgante Globo',
    tag: 'Smart Life',
    width: 0.36,
    depth: 0.36,
    height: 1.75,
    color: '#FFDE59',
    tuya: 'smart_pendant_light',
    icon: 'light_pendant'
  },
  {
    id: 'light_spots_track',
    type: 'spots',
    category: 'lighting',
    sub: 'spots',
    name: 'Riel 3 Focos Spots Direccionales',
    tag: 'Smart Life',
    width: 0.95,
    depth: 0.12,
    height: 0.15,
    color: '#FFFA65',
    tuya: 'smart_spots_light',
    icon: 'light_spots'
  },
  {
    id: 'light_floor_arch',
    type: 'floor',
    category: 'lighting',
    sub: 'floor',
    name: 'Lámpara de Pie Arquitectónica',
    tag: 'Smart Life',
    width: 0.40,
    depth: 0.40,
    height: 1.65,
    color: '#FFF275',
    tuya: 'smart_floor_lamp',
    icon: 'light_floor'
  },
  {
    id: 'light_table_bedside',
    type: 'table',
    category: 'lighting',
    sub: 'table',
    name: 'Lámpara de Sobremesa / Buró',
    tag: 'Smart Life',
    width: 0.28,
    depth: 0.28,
    height: 0.45,
    color: '#FFDF00',
    tuya: 'smart_table_lamp',
    icon: 'light_table'
  },
  {
    id: 'light_strip_led',
    type: 'strip',
    category: 'lighting',
    sub: 'strip',
    name: 'Tira LED Lineal Cálida 1.5m',
    tag: 'Smart Life',
    width: 1.50,
    depth: 0.04,
    height: 0.03,
    color: '#FFC048',
    tuya: 'smart_strip_led',
    icon: 'light_strip'
  },
  {
    id: 'light_wall_sconce',
    type: 'wall_sconce',
    category: 'lighting',
    sub: 'sconce',
    name: 'Aplique de Pared Contemporáneo',
    tag: 'Smart Life',
    width: 0.10,
    depth: 0.08,
    height: 0.40,
    color: '#FFEAA7',
    tuya: 'smart_wall_sconce',
    icon: 'light_sconce'
  },

  // --- COCINA ---
  {
    id: 'kitchen_module_3m',
    type: 'kitchen',
    category: 'kitchen',
    sub: 'cabinets',
    name: 'Módulo de Cocina con Encimera',
    tag: 'Cocina',
    width: 3.00,
    depth: 0.65,
    height: 0.90,
    color: '#1E232E',
    icon: 'kitchen'
  },
  {
    id: 'kitchen_island_2m',
    type: 'island',
    category: 'kitchen',
    sub: 'cabinets',
    name: 'Isla Central de Cocina',
    tag: 'Cocina',
    width: 2.00,
    depth: 1.10,
    height: 0.90,
    color: '#2C3E50',
    icon: 'kitchen_island'
  },
  {
    id: 'kitchen_fridge_inox',
    type: 'fridge',
    category: 'kitchen',
    sub: 'appliances',
    name: 'Refrigerador Vertical Acero Inox',
    tag: 'Cocina',
    width: 0.70,
    depth: 0.68,
    height: 1.85,
    color: '#C0C6CF',
    icon: 'fridge'
  },
  {
    id: 'kitchen_bar_stool',
    type: 'bar_stool',
    category: 'kitchen',
    sub: 'seating',
    name: 'Banco de Barra Alto',
    tag: 'Cocina',
    width: 0.42,
    depth: 0.42,
    height: 0.75,
    color: '#34495E',
    icon: 'bar_stool'
  },

  // --- BAÑO & SANITARIOS ---
  {
    id: 'bath_tub_mod',
    type: 'bathtub',
    category: 'bathroom',
    sub: 'bath',
    name: 'Bañera Moderna Bordes Redondeados',
    tag: 'Baño',
    width: 1.70,
    depth: 0.78,
    height: 0.55,
    color: '#FFFFFF',
    icon: 'bathtub'
  },
  {
    id: 'bath_shower_glass',
    type: 'shower',
    category: 'bathroom',
    sub: 'bath',
    name: 'Cabina de Ducha Mampara Cristal',
    tag: 'Baño',
    width: 1.00,
    depth: 1.00,
    height: 2.10,
    color: '#9CC0FF',
    icon: 'shower'
  },
  {
    id: 'bath_toilet_wc',
    type: 'toilet',
    category: 'bathroom',
    sub: 'sanitary',
    name: 'Inodoro WC con Cisterna',
    tag: 'Baño',
    width: 0.40,
    depth: 0.66,
    height: 0.80,
    color: '#FFFFFF',
    icon: 'toilet'
  },
  {
    id: 'bath_vanity_mirror',
    type: 'vanity',
    category: 'bathroom',
    sub: 'vanity',
    name: 'Mueble Lavamanos con Espejo',
    tag: 'Baño',
    width: 1.10,
    depth: 0.50,
    height: 1.80,
    color: '#C8A26A',
    icon: 'vanity'
  },

  // --- NATURALEZA & PLANTAS ---
  {
    id: 'nature_plant_indoor',
    type: 'plant',
    category: 'nature',
    sub: 'indoor',
    name: 'Planta de Interior en Maceta',
    tag: 'Decoración',
    width: 0.45,
    depth: 0.45,
    height: 0.95,
    color: '#4F9462',
    icon: 'plant'
  },
  {
    id: 'nature_ficus_tree',
    type: 'ficus',
    category: 'nature',
    sub: 'indoor',
    name: 'Árbol Ficus Interior',
    tag: 'Decoración',
    width: 0.60,
    depth: 0.60,
    height: 1.65,
    color: '#3E7D50',
    icon: 'plant'
  },
  {
    id: 'nature_sansevieria',
    type: 'plant_tall',
    category: 'nature',
    sub: 'indoor',
    name: 'Sansevieria en Macetero Alto',
    tag: 'Decoración',
    width: 0.40,
    depth: 0.40,
    height: 1.40,
    color: '#2ECC71',
    icon: 'plant'
  },

  // --- CLIMATIZACIÓN ---
  {
    id: 'clima_split_north',
    type: 'ac',
    category: 'clima',
    sub: 'split',
    name: 'Aire Acondicionado Split Muro',
    tag: 'Smart Life',
    width: 0.90,
    depth: 0.22,
    height: 0.30,
    color: '#F5F7F8',
    tuya: 'termostato_ac',
    icon: 'ac'
  },
  {
    id: 'clima_vent_ceiling',
    type: 'ac',
    category: 'clima',
    sub: 'vent',
    name: 'Rejilla Difusora de Clima Techo',
    tag: 'HVAC',
    width: 1.20,
    depth: 0.15,
    height: 0.05,
    color: '#1A1C20',
    icon: 'ac'
  },

  // --- VEHÍCULOS ---
  {
    id: 'car_sedan_exec',
    type: 'car_sedan',
    category: 'vehicles',
    sub: 'car',
    name: 'Sedán Ejecutivo Moderno',
    tag: 'Exterior / Garaje',
    width: 1.85,
    depth: 4.60,
    height: 1.45,
    color: '#2C3E50',
    icon: 'car_sedan'
  },
  {
    id: 'car_suv_family',
    type: 'car_suv',
    category: 'vehicles',
    sub: 'car',
    name: 'SUV Todoterreno Familiar',
    tag: 'Exterior / Garaje',
    width: 1.95,
    depth: 4.80,
    height: 1.75,
    color: '#E74C3C',
    icon: 'car_suv'
  }
];

// ============================================================================
// BASE DE DATOS DEL CATÁLOGO DE MATERIALES ARCHITECTURAL
// ============================================================================
const CATALOG_MATERIALS = [
  // --- MADERAS ---
  { id: 'wood_oak', name: 'Roble Europeo Natural', category: 'Maderas', sub: 'wood', hex: '#C8A26A', desc: 'Veta natural clara' },
  { id: 'wood_walnut', name: 'Nogal Americano Oscuro', category: 'Maderas', sub: 'wood', hex: '#4A3528', desc: 'Madera noble oscura' },
  { id: 'wood_ash', name: 'Fresno Nórdico Claro', category: 'Maderas', sub: 'wood', hex: '#D9C9A8', desc: 'Tono escandinavo' },
  { id: 'wood_teak', name: 'Teca Escandinava', category: 'Maderas', sub: 'wood', hex: '#8B5A2B', desc: 'Resistente y cálido' },
  { id: 'wood_ebony', name: 'Ébano Carbón', category: 'Maderas', sub: 'wood', hex: '#201B18', desc: 'Negro elegante lustrado' },
  { id: 'wood_white', name: 'Madera Blanca Decapé', category: 'Maderas', sub: 'wood', hex: '#EAE6DD', desc: 'Estilo rústico moderno' },

  // --- PIEDRAS Y PORCELANATOS ---
  { id: 'stone_carrara', name: 'Mármol Blanco Carrara', category: 'Piedras y Porcelanatos', sub: 'stone', hex: '#EAEBED', desc: 'Vetas grises sutiles' },
  { id: 'stone_black_galaxy', name: 'Granito Negro Galaxy', category: 'Piedras y Porcelanatos', sub: 'stone', hex: '#1B1E23', desc: 'Reflejo mineral pulido' },
  { id: 'stone_slate', name: 'Piedra Pizarra Gris', category: 'Piedras y Porcelanatos', sub: 'stone', hex: '#5A6577', desc: 'Textura rugosa grafito' },
  { id: 'tile_white_subway', name: 'Azulejo Satinado Blanco', category: 'Piedras y Porcelanatos', sub: 'stone', hex: '#E2E6E8', desc: 'Cerámica moderna para baños' },
  { id: 'tile_terrazzo', name: 'Terrazo Veneciano Moderno', category: 'Piedras y Porcelanatos', sub: 'stone', hex: '#D6D2C9', desc: 'Piedra aglomerada italiana' },
  { id: 'concrete_polished', name: 'Microcemento / Hormigón', category: 'Piedras y Porcelanatos', sub: 'stone', hex: '#9AA0A6', desc: 'Acabado industrial liso' },

  // --- METALES ---
  { id: 'metal_black_matte', name: 'Aluminio Negro Mate', category: 'Metales', sub: 'metal', hex: '#181A1F', desc: 'Perfilería y cerrajería' },
  { id: 'metal_brass_gold', name: 'Latón Dorado Cepillado', category: 'Metales', sub: 'metal', hex: '#D4AF37', desc: 'Detalles de lujo y lámparas' },
  { id: 'metal_chrome', name: 'Cromo Brillante Espejo', category: 'Metales', sub: 'metal', hex: '#E2E6EA', desc: 'Grifería y accesorios' },
  { id: 'metal_stainless', name: 'Acero Inoxidable Satinado', category: 'Metales', sub: 'metal', hex: '#A8ADB5', desc: 'Electrodomésticos e islas' },
  { id: 'metal_copper', name: 'Cobre Cepillado Cálido', category: 'Metales', sub: 'metal', hex: '#B87333', desc: 'Tono cobrizo reflectante' },
  { id: 'metal_bronze', name: 'Bronce Arquitectónico', category: 'Metales', sub: 'metal', hex: '#6E5642', desc: 'Elegancia clásica' },

  // --- CRISTALES ---
  { id: 'glass_clear', name: 'Vidrio Cristalino Ultraclaro', category: 'Cristales', sub: 'glass', hex: '#D6EBF8', desc: 'Transparencia alta' },
  { id: 'glass_blue', name: 'Vidrio Smart Tint Azul', category: 'Cristales', sub: 'glass', hex: '#9CC0FF', desc: 'Control solar azulado' },
  { id: 'glass_smoked', name: 'Vidrio Fumé Ahumado', category: 'Cristales', sub: 'glass', hex: '#3B3E45', desc: 'Privacidad y sofisticación' },
  { id: 'glass_frosted', name: 'Vidrio Esmerilado Traslúcido', category: 'Cristales', sub: 'glass', hex: '#F0F4F8', desc: 'Mamparas y divisiones' },

  // --- PINTURAS ARQUITECTÓNICAS ---
  { id: 'paint_warm_white', name: 'Blanco Cálido Architectural', category: 'Pinturas', sub: 'paint', hex: '#F5F4EE', desc: 'Ambientes luminosos y acogedores' },
  { id: 'paint_pure_white', name: 'Blanco Nieve Puro', category: 'Pinturas', sub: 'paint', hex: '#FFFFFF', desc: 'Máxima reflectancia de luz' },
  { id: 'paint_soft_gray', name: 'Gris Neutro Suave', category: 'Pinturas', sub: 'paint', hex: '#B8BCBE', desc: 'Fondos modernos equilibrados' },
  { id: 'paint_deep_navy', name: 'Azul Profundo Medianoche', category: 'Pinturas', sub: 'paint', hex: '#1D2A44', desc: 'Pared de acento en dormitorios' },
  { id: 'paint_sage_green', name: 'Verde Salvia Nórdico', category: 'Pinturas', sub: 'paint', hex: '#7C8B7A', desc: 'Serenidad y toque natural' },
  { id: 'paint_terracotta', name: 'Terracota Mediterráneo', category: 'Pinturas', sub: 'paint', hex: '#BD664F', desc: 'Calidez artesanal' },
  { id: 'paint_charcoal', name: 'Antracita Urbano', category: 'Pinturas', sub: 'paint', hex: '#2A2D34', desc: 'Contraste dramático elegante' },

  // --- TELAS Y TAPICERÍA ---
  { id: 'fabric_linen_light', name: 'Lino Textil Gris Perla', category: 'Telas y Tapicería', sub: 'fabric', hex: '#CBCDC8', desc: 'Textura natural transpirable' },
  { id: 'fabric_linen_navy', name: 'Lino Azul Marino', category: 'Telas y Tapicería', sub: 'fabric', hex: '#2C3A50', desc: 'Tejido denso tapicería' },
  { id: 'fabric_leather_caramel', name: 'Cuero Caramelo Vintage', category: 'Telas y Tapicería', sub: 'fabric', hex: '#94593B', desc: 'Piel con pátina envejecida' },
  { id: 'fabric_velvet_emerald', name: 'Terciopelo Esmeralda', category: 'Telas y Tapicería', sub: 'fabric', hex: '#1F4E3D', desc: 'Textura suave con brillo' },
  { id: 'fabric_velvet_mustard', name: 'Terciopelo Mostaza Ocre', category: 'Telas y Tapicería', sub: 'fabric', hex: '#D8A232', desc: 'Acento de color vibrante' },
  { id: 'fabric_dark_gray', name: 'Tapicería Gris Marengo', category: 'Telas y Tapicería', sub: 'fabric', hex: '#3A3F4D', desc: 'Tejido resistente anti-manchas' }
];

// ============================================================================
// DIBUJO ISOMÉTRICO SVG PARA LAS TARJETAS (ESTILO LUMION PREVIEW)
// ============================================================================
function generateSvgPreview(item) {
  const c = item.color || '#4A5568';
  const type = item.type || 'generic';

  switch (type) {
    case 'sofa':
    case 'sofa_l':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="80" rx="36" ry="12" fill="rgba(0,0,0,0.3)"/>
          <path d="M18 48 L50 32 L82 48 L50 64 Z" fill="${c}"/>
          <path d="M18 48 L18 64 L50 80 L50 64 Z" fill="rgba(0,0,0,0.25)"/>
          <path d="M82 48 L82 64 L50 80 L50 64 Z" fill="rgba(0,0,0,0.12)"/>
          <!-- Respaldo acolchado -->
          <path d="M22 34 L50 20 L78 34 L78 44 L50 30 L22 44 Z" fill="#2D3748"/>
          <!-- Cojines -->
          <ellipse cx="36" cy="46" rx="10" ry="5" fill="#E2E8F0" opacity="0.8"/>
          <ellipse cx="64" cy="46" rx="10" ry="5" fill="#E2E8F0" opacity="0.8"/>
        </svg>`;

    case 'armchair':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="82" rx="26" ry="10" fill="rgba(0,0,0,0.3)"/>
          <path d="M28 50 L50 38 L72 50 L50 62 Z" fill="${c}"/>
          <path d="M28 50 L28 64 L50 76 L50 62 Z" fill="rgba(0,0,0,0.3)"/>
          <path d="M72 50 L72 64 L50 76 L50 62 Z" fill="rgba(0,0,0,0.15)"/>
          <path d="M30 36 L50 24 L70 36 L70 46 L50 34 L30 46 Z" fill="#E2E8F0"/>
        </svg>`;

    case 'bed':
    case 'bed_queen':
    case 'bed_single':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="82" rx="40" ry="12" fill="rgba(0,0,0,0.3)"/>
          <!-- Cabecera -->
          <path d="M20 30 L50 16 L80 30 L80 44 L50 30 L20 44 Z" fill="#C8A26A"/>
          <!-- Colchón -->
          <path d="M22 46 L50 32 L78 46 L50 60 Z" fill="#FFFFFF"/>
          <path d="M22 46 L22 62 L50 76 L50 60 Z" fill="#E2E8F0"/>
          <path d="M78 46 L78 62 L50 76 L50 60 Z" fill="#CBD5E0"/>
          <!-- Manta -->
          <path d="M22 55 L50 41 L78 55 L50 69 Z" fill="${c}"/>
          <!-- Almohadas -->
          <ellipse cx="36" cy="38" rx="8" ry="4" fill="#FFFFFF"/>
          <ellipse cx="64" cy="38" rx="8" ry="4" fill="#FFFFFF"/>
        </svg>`;

    case 'coffeeTable':
    case 'side_table':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="82" rx="30" ry="10" fill="rgba(0,0,0,0.3)"/>
          <path d="M24 52 L50 38 L76 52 L50 66 Z" fill="${c}"/>
          <path d="M24 52 L24 56 L50 70 L50 66 Z" fill="rgba(0,0,0,0.3)"/>
          <path d="M76 52 L76 56 L50 70 L50 66 Z" fill="rgba(0,0,0,0.15)"/>
          <!-- Patas -->
          <line x1="26" y1="56" x2="26" y2="76" stroke="#1A202C" stroke-width="3"/>
          <line x1="74" y1="56" x2="74" y2="76" stroke="#1A202C" stroke-width="3"/>
          <line x1="50" y1="70" x2="50" y2="84" stroke="#1A202C" stroke-width="3"/>
        </svg>`;

    case 'tv':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="84" rx="36" ry="10" fill="rgba(0,0,0,0.3)"/>
          <!-- Mueble bajo -->
          <path d="M16 60 L50 44 L84 60 L50 76 Z" fill="#C8A26A"/>
          <path d="M16 60 L16 72 L50 88 L50 76 Z" fill="rgba(0,0,0,0.3)"/>
          <path d="M84 60 L84 72 L50 88 L50 76 Z" fill="rgba(0,0,0,0.15)"/>
          <!-- Pantalla TV -->
          <path d="M22 30 L50 16 L78 30 L78 54 L50 40 L22 54 Z" fill="#0B0F17"/>
          <rect x="48" y="52" width="4" height="12" fill="#718096"/>
        </svg>`;

    case 'diningSet':
    case 'dining_round':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="84" rx="38" ry="12" fill="rgba(0,0,0,0.3)"/>
          <path d="M20 46 L50 32 L80 46 L50 60 Z" fill="#C8A26A"/>
          <path d="M20 46 L20 52 L50 66 L50 60 Z" fill="rgba(0,0,0,0.3)"/>
          <path d="M80 46 L80 52 L50 66 L50 60 Z" fill="rgba(0,0,0,0.15)"/>
          <line x1="22" y1="52" x2="22" y2="76" stroke="#1A202C" stroke-width="3"/>
          <line x1="78" y1="52" x2="78" y2="76" stroke="#1A202C" stroke-width="3"/>
          <!-- Sillas -->
          <rect x="28" y="32" width="12" height="16" rx="2" fill="#4A5568"/>
          <rect x="60" y="32" width="12" height="16" rx="2" fill="#4A5568"/>
          <rect x="44" y="60" width="12" height="16" rx="2" fill="#4A5568"/>
        </svg>`;

    case 'desk':
    case 'office_chair':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="84" rx="34" ry="10" fill="rgba(0,0,0,0.3)"/>
          <path d="M18 44 L50 28 L82 44 L50 60 Z" fill="#C8A26A"/>
          <path d="M18 44 L18 50 L50 66 L50 60 Z" fill="rgba(0,0,0,0.3)"/>
          <path d="M82 44 L82 50 L50 66 L50 60 Z" fill="rgba(0,0,0,0.15)"/>
          <!-- Patas en U -->
          <line x1="20" y1="50" x2="20" y2="76" stroke="#1A202C" stroke-width="4"/>
          <line x1="80" y1="50" x2="80" y2="76" stroke="#1A202C" stroke-width="4"/>
          <!-- Laptop -->
          <polygon points="46,38 54,34 58,40 50,44" fill="#00E5FF"/>
        </svg>`;

    case 'ceiling':
    case 'pendant':
    case 'spots':
    case 'floor':
    case 'table':
    case 'strip':
    case 'wall_sconce':
      return `
        <svg viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="32" fill="rgba(255, 222, 89, 0.15)"/>
          <circle cx="50" cy="50" r="22" fill="rgba(255, 222, 89, 0.3)"/>
          <!-- Lámpara moderna con halo de luz -->
          <circle cx="50" cy="46" r="14" fill="#FFDE59" stroke="#D4AF37" stroke-width="3"/>
          <line x1="50" y1="12" x2="50" y2="32" stroke="#1A202C" stroke-width="2.5"/>
          <ellipse cx="50" cy="80" rx="20" ry="6" fill="rgba(255, 222, 89, 0.4)"/>
        </svg>`;

    case 'kitchen':
    case 'island':
    case 'fridge':
    case 'bar_stool':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="84" rx="36" ry="10" fill="rgba(0,0,0,0.3)"/>
          <path d="M16 48 L50 32 L84 48 L50 64 Z" fill="#9AA0A6"/>
          <path d="M16 48 L16 68 L50 84 L50 64 Z" fill="#2C3E50"/>
          <path d="M84 48 L84 68 L50 84 L50 64 Z" fill="#1A252F"/>
          <!-- Tiradores -->
          <line x1="30" y1="62" x2="38" y2="66" stroke="#FFFFFF" stroke-width="2"/>
          <line x1="62" y1="66" x2="70" y2="62" stroke="#FFFFFF" stroke-width="2"/>
        </svg>`;

    case 'bathtub':
    case 'shower':
    case 'toilet':
    case 'vanity':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="82" rx="36" ry="12" fill="rgba(0,0,0,0.3)"/>
          <!-- Tina bañera bordes suaves -->
          <ellipse cx="50" cy="52" rx="34" ry="16" fill="#FFFFFF" stroke="#CBD5E0" stroke-width="3"/>
          <ellipse cx="50" cy="52" rx="26" ry="11" fill="#9CC0FF" opacity="0.6"/>
          <!-- Grifo cromo -->
          <path d="M30 46 Q26 32 32 28 Q38 28 36 38" fill="none" stroke="#CBD5E0" stroke-width="3"/>
        </svg>`;

    case 'plant':
    case 'ficus':
    case 'plant_tall':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="84" rx="24" ry="8" fill="rgba(0,0,0,0.3)"/>
          <!-- Maceta cilíndrica -->
          <path d="M34 60 L66 60 L62 82 L38 82 Z" fill="#FFFFFF" stroke="#E2E8F0" stroke-width="2"/>
          <!-- Hojas verdes frondosas -->
          <ellipse cx="50" cy="42" rx="14" ry="24" fill="#2ECC71" transform="rotate(-20 50 42)"/>
          <ellipse cx="50" cy="42" rx="14" ry="24" fill="#27AE60" transform="rotate(20 50 42)"/>
          <ellipse cx="50" cy="36" rx="12" ry="26" fill="#3E7D50"/>
        </svg>`;

    case 'ac':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="78" rx="34" ry="8" fill="rgba(0,0,0,0.2)"/>
          <rect x="18" y="38" width="64" height="26" rx="4" fill="#F8FAFC" stroke="#CBD5E0" stroke-width="2"/>
          <!-- Rejilla y LED -->
          <line x1="24" y1="56" x2="76" y2="56" stroke="#94A3B8" stroke-width="2"/>
          <circle cx="72" cy="46" r="3" fill="#00E5FF"/>
        </svg>`;

    case 'car_sedan':
    case 'car_suv':
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="84" rx="42" ry="12" fill="rgba(0,0,0,0.35)"/>
          <!-- Carrocería coche -->
          <path d="M12 60 Q20 50 34 50 L66 50 Q80 50 88 60 L84 72 L16 72 Z" fill="${c}"/>
          <!-- Cabina / Ventanillas -->
          <path d="M28 50 L38 34 L64 34 L72 50 Z" fill="#2B384A" stroke="#4A5568" stroke-width="1.5"/>
          <!-- Ruedas -->
          <circle cx="28" cy="72" r="10" fill="#1A202C" stroke="#718096" stroke-width="3"/>
          <circle cx="72" cy="72" r="10" fill="#1A202C" stroke="#718096" stroke-width="3"/>
          <!-- Faros -->
          <circle cx="86" cy="62" r="3" fill="#FFFFFF"/>
        </svg>`;

    default:
      return `
        <svg viewBox="0 0 100 100">
          <ellipse cx="50" cy="80" rx="30" ry="10" fill="rgba(0,0,0,0.3)"/>
          <path d="M24 50 L50 36 L76 50 L50 64 Z" fill="${c}"/>
          <path d="M24 50 L24 66 L50 80 L50 64 Z" fill="rgba(0,0,0,0.3)"/>
          <path d="M76 50 L76 66 L50 80 L50 64 Z" fill="rgba(0,0,0,0.15)"/>
        </svg>`;
  }
}

// ============================================================================
// ESTADO DE LA APLICACIÓN
// ============================================================================
let currentCategory = 'furniture';
let currentSubfilter = 'all';
let searchQuery = '';
let selectedItemForCustom = null;

// ============================================================================
// INICIALIZACIÓN
// ============================================================================
document.addEventListener('DOMContentLoaded', () => {
  setupCategoryTabs();
  setupSearch();
  setupModal();
  renderCurrentView();

  // Notificar a SketchUp que la interfaz está lista
  if (window.sketchup && typeof sketchup.ready === 'function') {
    sketchup.ready();
  }
});

// ============================================================================
// CONFIGURACIÓN DE PESTAÑAS DE CATEGORÍA (LUMION SIDEBAR)
// ============================================================================
function setupCategoryTabs() {
  const tabs = document.querySelectorAll('.cat-tab');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      currentCategory = tab.dataset.category;
      currentSubfilter = 'all';
      renderSubfilters();
      renderCurrentView();
    });
  });
}

// ============================================================================
// CONFIGURACIÓN DE BUSCADOR EN TIEMPO REAL
// ============================================================================
function setupSearch() {
  const input = document.getElementById('search-input');
  const clearBtn = document.getElementById('clear-search');

  input.addEventListener('input', (e) => {
    searchQuery = e.target.value.trim().toLowerCase();
    clearBtn.style.display = searchQuery.length > 0 ? 'block' : 'none';
    renderCurrentView();
  });

  clearBtn.addEventListener('click', () => {
    input.value = '';
    searchQuery = '';
    clearBtn.style.display = 'none';
    renderCurrentView();
  });
}

// ============================================================================
// SUBFILTROS / CHIPS DINÁMICOS
// ============================================================================
function renderSubfilters() {
  const bar = document.getElementById('subfilter-bar');
  bar.innerHTML = '';

  let chips = [{ id: 'all', label: 'Todos los elementos' }];

  if (currentCategory === 'materials') {
    chips = [
      { id: 'all', label: 'Todos los materiales' },
      { id: 'Maderas', label: '🪵 Maderas' },
      { id: 'Piedras y Porcelanatos', label: '🏛️ Piedras & Porcelanatos' },
      { id: 'Metales', label: '🔩 Metales' },
      { id: 'Cristales', label: '🪟 Cristales' },
      { id: 'Pinturas', label: '🎨 Pinturas de Muro' },
      { id: 'Telas y Tapicería', label: '🧶 Telas & Tapicería' }
    ];
  } else if (currentCategory === 'furniture') {
    chips = [
      { id: 'all', label: 'Todos' },
      { id: 'sofa', label: 'Sofás y Sillones' },
      { id: 'table', label: 'Mesas' },
      { id: 'storage', label: 'Muebles TV y Estanterías' },
      { id: 'office', label: 'Oficina y Escritorios' },
      { id: 'decor', label: 'Alfombras' }
    ];
  } else if (currentCategory === 'bedroom') {
    chips = [
      { id: 'all', label: 'Todos' },
      { id: 'bed', label: 'Camas' },
      { id: 'storage', label: 'Armarios y Burós' }
    ];
  } else if (currentCategory === 'lighting') {
    chips = [
      { id: 'all', label: 'Todas' },
      { id: 'ceiling', label: 'Plafones Techo' },
      { id: 'pendant', label: 'Colgantes' },
      { id: 'spots', label: 'Spots / Rieles' },
      { id: 'floor', label: 'Lámparas de Pie' },
      { id: 'table', label: 'Sobremesa' },
      { id: 'strip', label: 'Tiras LED' },
      { id: 'sconce', label: 'Apliques de Pared' }
    ];
  } else if (currentCategory === 'kitchen') {
    chips = [
      { id: 'all', label: 'Todos' },
      { id: 'cabinets', label: 'Módulos e Islas' },
      { id: 'appliances', label: 'Electrodomésticos' },
      { id: 'seating', label: 'Bancos' }
    ];
  } else if (currentCategory === 'bathroom') {
    chips = [
      { id: 'all', label: 'Todos' },
      { id: 'bath', label: 'Bañeras y Duchas' },
      { id: 'sanitary', label: 'Inodoros' },
      { id: 'vanity', label: 'Lavamanos' }
    ];
  }

  chips.forEach(chip => {
    const btn = document.createElement('button');
    btn.className = `chip ${currentSubfilter === chip.id ? 'active' : ''}`;
    btn.textContent = chip.label;
    btn.dataset.sub = chip.id;
    btn.addEventListener('click', () => {
      document.querySelectorAll('.chip').forEach(c => c.classList.remove('active'));
      btn.classList.add('active');
      currentSubfilter = chip.id;
      renderCurrentView();
    });
    bar.appendChild(btn);
  });
}

// ============================================================================
// RENDERIZADO DEL GRID PRINCIPAL
// ============================================================================
function renderCurrentView() {
  const grid = document.getElementById('cards-grid');
  const countLabel = document.getElementById('items-count-label');
  grid.innerHTML = '';

  if (currentCategory === 'materials') {
    renderMaterialsView(grid, countLabel);
  } else {
    renderObjectsView(grid, countLabel);
  }
}

// RENDERIZADO DE OBJETOS 3D
function renderObjectsView(grid, countLabel) {
  let filtered = CATALOG_ITEMS.filter(item => {
    // Filtro por categoría principal
    if (item.category !== currentCategory) return false;
    // Filtro por subcategoría chip
    if (currentSubfilter !== 'all' && item.sub !== currentSubfilter) return false;
    // Filtro por búsqueda
    if (searchQuery) {
      const matchName = item.name.toLowerCase().includes(searchQuery);
      const matchTag = item.tag && item.tag.toLowerCase().includes(searchQuery);
      const matchType = item.type.toLowerCase().includes(searchQuery);
      if (!matchName && !matchTag && !matchType) return false;
    }
    return true;
  });

  countLabel.textContent = `Mostrando ${filtered.length} elemento(s)`;

  if (filtered.length === 0) {
    grid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 48px; color: #64748B;">
        <p style="font-size: 16px; font-weight: 600; margin-bottom: 8px;">No se encontraron objetos</p>
        <p style="font-size: 12px;">Intenta cambiar el término de búsqueda o selecciona otra categoría.</p>
      </div>`;
    return;
  }

  filtered.forEach(item => {
    const card = document.createElement('div');
    card.className = 'item-card';

    const svgIcon = generateSvgPreview(item);
    const room = document.getElementById('room-select').value;

    card.innerHTML = `
      <div class="card-preview">
        <span class="badge-tag">${item.tag || 'Objeto'}</span>
        ${svgIcon}
      </div>
      <div class="card-info">
        <span class="card-title" title="${item.name}">${item.name}</span>
        <span class="card-dimensions">${item.width.toFixed(2)} × ${item.depth.toFixed(2)} × ${item.height.toFixed(2)} m</span>
      </div>
      <div class="card-actions">
        <button class="btn-place" title="Colocar en SketchUp (clic interactivo en el modelo)">
          <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2A10 10 0 1 0 22 12A10 10 0 0 0 12 2M12 4A8 8 0 0 1 20 12A8 8 0 0 1 12 20A8 8 0 0 1 4 12A8 8 0 0 1 12 4M11 7V11H7V13H11V17H13V13H17V11H13V7Z"/></svg>
          Colocar
        </button>
        <button class="btn-icon-secondary btn-custom" title="Ajustar medidas y color antes de colocar">
          <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 15.5A3.5 3.5 0 0 1 8.5 12A3.5 3.5 0 0 1 12 8.5A3.5 3.5 0 0 1 15.5 12A3.5 3.5 0 0 1 12 15.5M19.43 12.97C19.47 12.65 19.5 12.33 19.5 12C19.5 11.67 19.47 11.34 19.43 11L21.54 9.37C21.73 9.22 21.78 8.95 21.66 8.73L19.66 5.27C19.54 5.05 19.27 4.97 19.05 5.05L16.56 6.05C16.04 5.65 15.48 5.32 14.87 5.07L14.49 2.42C14.46 2.18 14.25 2 14 2H10C9.75 2 9.54 2.18 9.51 2.42L9.13 5.07C8.52 5.32 7.96 5.66 7.44 6.05L4.95 5.05C4.73 4.96 4.46 5.05 4.34 5.27L2.34 8.73C2.21 8.95 2.27 9.22 2.46 9.37L4.57 11C4.53 11.34 4.5 11.67 4.5 12C4.5 12.33 4.53 12.65 4.57 12.97L2.46 14.63C2.27 14.78 2.21 15.05 2.34 15.27L4.34 18.73C4.46 18.95 4.73 19.03 4.95 18.95L7.44 17.95C7.96 18.35 8.52 18.68 9.13 18.93L9.51 21.58C9.54 21.82 9.75 22 10 22H14C14.25 22 14.46 21.82 14.49 21.58L14.87 18.93C15.48 18.68 16.04 18.34 16.56 17.95L19.05 18.95C19.27 19.04 19.54 18.95 19.66 18.73L21.66 15.27C21.78 15.05 21.73 14.78 21.54 14.63L19.43 12.97Z"/></svg>
        </button>
        <button class="btn-icon-secondary btn-center" title="Insertar directamente en el centro / origen (0,0,0)">
          <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 8A4 4 0 0 1 16 12A4 4 0 0 1 12 16A4 4 0 0 1 8 12A4 4 0 0 1 12 8M12 10A2 2 0 0 0 10 12A2 2 0 0 0 12 14A2 2 0 0 0 14 12A2 2 0 0 0 12 10M12 2A10 10 0 0 1 22 12A10 10 0 0 1 12 22A10 10 0 0 1 2 12A10 10 0 0 1 12 2Z"/></svg>
        </button>
      </div>
    `;

    // Botón Colocar (Interactiva)
    card.querySelector('.btn-place').addEventListener('click', () => {
      placeObjectInSketchUp(item, false);
    });

    // Botón Personalizar
    card.querySelector('.btn-custom').addEventListener('click', () => {
      openCustomModal(item);
    });

    // Botón Insertar en Centro
    card.querySelector('.btn-center').addEventListener('click', () => {
      insertObjectAtCenter(item);
    });

    grid.appendChild(card);
  });
}

// RENDERIZADO DE MATERIALES ARCHITECTURAL
function renderMaterialsView(grid, countLabel) {
  let filtered = CATALOG_MATERIALS.filter(mat => {
    if (currentSubfilter !== 'all' && mat.category !== currentSubfilter) return false;
    if (searchQuery) {
      const matchName = mat.name.toLowerCase().includes(searchQuery);
      const matchCat = mat.category.toLowerCase().includes(searchQuery);
      if (!matchName && !matchCat) return false;
    }
    return true;
  });

  countLabel.textContent = `Mostrando ${filtered.length} material(es)`;

  filtered.forEach(mat => {
    const card = document.createElement('div');
    card.className = 'mat-card';

    card.innerHTML = `
      <div class="mat-sphere-wrap">
        <div class="mat-sphere" style="background-color: ${mat.hex};"></div>
      </div>
      <div class="mat-info">
        <span class="mat-name" title="${mat.name}">${mat.name}</span>
        <span class="mat-category">${mat.category}</span>
        <span class="mat-apply-hint">Clic para aplicar a selección</span>
      </div>
    `;

    card.addEventListener('click', () => {
      applyMaterialInSketchUp(mat);
    });

    grid.appendChild(card);
  });
}

// ============================================================================
// ACCIONES SKETCHUP BRIDGE (LLAMADAS A RUBY)
// ============================================================================
function placeObjectInSketchUp(item, customDimensions = false) {
  const room = document.getElementById('room-select').value;
  const isContinuous = document.getElementById('continuous-placement').checked;

  const payload = {
    category: item.category,
    type: item.type,
    name: item.name,
    room: room,
    width: item.width,
    depth: item.depth,
    height: item.height,
    color: item.color,
    tuya: item.tuya || '',
    continuous: isContinuous,
    custom_dimensions: customDimensions
  };

  showToast(`🎯 Colocando "${item.name}": Haz clic en la vista 3D de SketchUp`);

  if (window.sketchup && typeof sketchup.place_object === 'function') {
    sketchup.place_object(JSON.stringify(payload));
  } else {
    console.log('[Dev Mode] sketchup.place_object:', payload);
  }
}

function insertObjectAtCenter(item) {
  const room = document.getElementById('room-select').value;
  const payload = {
    category: item.category,
    type: item.type,
    name: item.name,
    room: room,
    width: item.width,
    depth: item.depth,
    height: item.height,
    color: item.color,
    tuya: item.tuya || ''
  };

  showToast(`✓ "${item.name}" insertado en el modelo`);

  if (window.sketchup && typeof sketchup.insert_object_at_center === 'function') {
    sketchup.insert_object_at_center(JSON.stringify(payload));
  } else {
    console.log('[Dev Mode] sketchup.insert_object_at_center:', payload);
  }
}

function applyMaterialInSketchUp(mat) {
  showToast(`🎨 Material "${mat.name}" aplicado / cargado en pincel`);

  if (window.sketchup && typeof sketchup.apply_material === 'function') {
    sketchup.apply_material(mat.id);
  } else {
    console.log('[Dev Mode] sketchup.apply_material:', mat.id);
  }
}

// ============================================================================
// MODAL DE PERSONALIZACIÓN
// ============================================================================
function setupModal() {
  const modal = document.getElementById('custom-modal');
  const closeBtn = document.getElementById('modal-close-btn');
  const cancelBtn = document.getElementById('modal-cancel-btn');
  const placeBtn = document.getElementById('modal-place-btn');
  const colorPicker = document.getElementById('param-color');
  const colorHex = document.getElementById('param-color-hex');

  colorPicker.addEventListener('input', (e) => {
    colorHex.textContent = e.target.value.toUpperCase();
  });

  const closeModal = () => modal.classList.remove('open');
  closeBtn.addEventListener('click', closeModal);
  cancelBtn.addEventListener('click', closeModal);

  placeBtn.addEventListener('click', () => {
    if (!selectedItemForCustom) return;

    const customItem = {
      ...selectedItemForCustom,
      name: document.getElementById('param-name').value || selectedItemForCustom.name,
      width: parseFloat(document.getElementById('param-w').value) || selectedItemForCustom.width,
      depth: parseFloat(document.getElementById('param-d').value) || selectedItemForCustom.depth,
      height: parseFloat(document.getElementById('param-h').value) || selectedItemForCustom.height,
      color: colorPicker.value,
      tuya: document.getElementById('param-tuya').value.trim()
    };

    closeModal();
    placeObjectInSketchUp(customItem, true);
  });
}

function openCustomModal(item) {
  selectedItemForCustom = item;
  document.getElementById('modal-title').textContent = `Personalizar ${item.name}`;
  document.getElementById('param-name').value = item.name;
  document.getElementById('param-w').value = item.width.toFixed(2);
  document.getElementById('param-d').value = item.depth.toFixed(2);
  document.getElementById('param-h').value = item.height.toFixed(2);
  document.getElementById('param-color').value = item.color || '#8B93A7';
  document.getElementById('param-color-hex').textContent = (item.color || '#8B93A7').toUpperCase();
  document.getElementById('param-tuya').value = item.tuya || '';

  document.getElementById('custom-modal').classList.add('open');
}

// ============================================================================
// TOAST NOTIFICACIÓN
// ============================================================================
let toastTimer = null;
function showToast(message) {
  const toast = document.getElementById('lumion-toast');
  toast.querySelector('.toast-message').textContent = message;
  toast.classList.add('show');

  if (toastTimer) clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    toast.classList.remove('show');
  }, 3200);
}
