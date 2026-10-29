# encoding: UTF-8
require 'sketchup.rb'

module HouseControlSync
  require_relative 'materials'
  require_relative 'builder'
  require_relative 'importer'
  require_relative 'exporter'
  require_relative 'catalog'
  require_relative 'direct_sync'

  # Iniciar servidor Wi-Fi local en segundo plano (puerto 8765)
  DirectSync.start_server

  # Herramienta para suavizar / redondear aristas (Phong / Gouraud shading)
  def self.smooth_selection(smooth = true)
    model = Sketchup.active_model
    sel = model.selection
    if sel.empty?
      UI.messagebox('Selecciona un objeto o aristas en SketchUp para suavizar.')
      return
    end

    model.start_operation(smooth ? 'Suavizar Aristas' : 'Endurecer Aristas', true)
    count = 0

    apply_smooth = lambda do |entity|
      if entity.is_a?(Sketchup::Edge)
        entity.soft = smooth
        entity.smooth = smooth
        count += 1
      elsif entity.is_a?(Sketchup::Group)
        entity.entities.grep(Sketchup::Edge).each do |edge|
          edge.soft = smooth
          edge.smooth = smooth
          count += 1
        end
      elsif entity.is_a?(Sketchup::ComponentInstance)
        entity.definition.entities.grep(Sketchup::Edge).each do |edge|
          edge.soft = smooth
          edge.smooth = smooth
          count += 1
        end
      end
    end

    sel.each { |e| apply_smooth.call(e) }
    model.commit_operation

    status = smooth ? 'suavizadas (redondeadas visualmente)' : 'endurecidas (aristas vivas)'
    UI.messagebox("Se han #{status} #{count} aristas.")
  end

  # Herramienta para convertir cualquier modelo o geometría nativa de SketchUp a House Control
  def self.convert_selection_dialog
    model = Sketchup.active_model
    sel = model.selection
    if sel.empty?
      UI.messagebox('Selecciona un grupo o componente en SketchUp para convertirlo.')
      return
    end

    ent = sel.first
    unless ent.is_a?(Sketchup::Group) || ent.is_a?(Sketchup::ComponentInstance)
      UI.messagebox('El elemento debe ser un Grupo o Componente.')
      return
    end

    current_cat = ent.get_attribute('HouseControl', 'category') || 'furniture'
    current_type = ent.get_attribute('HouseControl', 'type') || 'sofa'
    current_room = ent.get_attribute('HouseControl', 'room') || 'living'
    current_name = ent.get_attribute('HouseControl', 'name') || ent.name
    current_name = 'Nuevo Elemento' if current_name.nil? || current_name.empty?

    prompts = ['Categoría:', 'Tipo:', 'Nombre:', 'Habitación (ID):']
    defaults = [current_cat, current_type, current_name, current_room]
    list_cat = 'furniture|light|ac|room'
    list_type = 'sofa|sofa_l|armchair|coffeeTable|side_table|tv|diningSet|dining_round|desk|office_chair|kitchen|island|fridge|bar_stool|bed|bed_queen|bed_single|nightstand|dresser|plant|ficus|vanity|bathtub|shower|toilet|wardrobe|bookshelf|rug|car_sedan|car_suv|ceiling|pendant|spots|floor|table|strip|wall_sconce|custom'

    input = UI.inputbox(prompts, defaults, [list_cat, list_type, '', ''], 'Convertir a Elemento House Control')
    return unless input

    cat, type, name, room = input

    model.start_operation('Asignar a House Control', true)
    ent.name = name
    ent.set_attribute('HouseControl', 'category', cat)
    ent.set_attribute('HouseControl', 'type', type)
    ent.set_attribute('HouseControl', 'name', name)
    ent.set_attribute('HouseControl', 'room', room)
    ent.set_attribute('HouseControl', 'id', "#{room}.#{type}_#{rand(1000..9999)}")

    layer_name = case cat
                 when 'furniture' then 'HC_Muebles'
                 when 'light' then 'HC_Luces'
                 when 'ac' then 'HC_Climas'
                 when 'room' then 'HC_Pisos'
                 else 'HC_Muebles'
                 end
    layer = model.layers[layer_name] || model.layers.add(layer_name)
    ent.layer = layer

    model.commit_operation
    UI.messagebox("¡Elemento asignado con éxito como '#{name}' (#{cat}: #{type}) en la habitación '#{room}'!")
  end

  def self.inspect_selection
    model = Sketchup.active_model
    sel = model.selection
    if sel.empty?
      UI.messagebox('Por favor selecciona un elemento de House Control primero.')
      return
    end

    ent = sel.first
    cat = Exporter.get_hc_attr(ent, 'category') || Exporter.infer_category_from_layer(ent)
    unless cat
      UI.messagebox("El elemento seleccionado no tiene datos de House Control ni está en una capa HC.")
      return
    end

    id = Exporter.get_hc_attr(ent, 'id') || '-'
    name = Exporter.get_hc_attr(ent, 'name') || ent.name
    room = Exporter.get_hc_attr(ent, 'room') || '-'
    type = Exporter.get_hc_attr(ent, 'type') || '-'
    link = Exporter.get_hc_attr(ent, 'link')
    tuya = Exporter.get_hc_attr(ent, 'tuya')

    pos = ent.transformation.origin
    px = pos.x.to_m.round(2)
    pz = (-pos.y).to_m.round(2)
    py = pos.z.to_m.round(2)

    device_info = if tuya && !tuya.to_s.empty?
                    "Smart Life / Tuya: #{tuya}"
                  elsif link && !link.to_s.empty?
                    "Enlace: #{link}"
                  else
                    "Sin dispositivo físico (Simulado)"
                  end

    custom_mat = ent.material ? ent.material.name : 'Material por defecto'

    msg = "Información del Elemento House Control:\n\n" +
          "• Categoría: #{cat.capitalize}\n" +
          "• Nombre: #{name}\n" +
          "• ID: #{id}\n" +
          "• Habitación: #{room}\n" +
          "• Tipo de objeto: #{type}\n" +
          "• Coordenadas (X, Z, Y): [#{px}m, #{pz}m, #{py}m]\n" +
          "• Material aplicado: #{custom_mat}\n" +
          "• Dispositivo domótico: #{device_info}\n\n" +
          "Puedes moverlo, rotarlo o pintarlo libremente con las herramientas de SketchUp."

    UI.messagebox(msg)
  end

  def self.open_samples_folder
    folder = File.expand_path('../../sample_plans', __FILE__)
    if File.directory?(folder)
      UI.openURL("file:///#{folder.tr('\\', '/')}")
    else
      UI.messagebox("Carpeta de planos no encontrada en: #{folder}")
    end
  end

  # Registrar Menús y Barra de Herramientas en SketchUp
  unless file_loaded?(__FILE__)
    icons_dir = File.join(File.dirname(__FILE__), 'icons')

    menu = UI.menu('Plugins') || UI.menu('Extensions')
    hc_menu = menu.add_submenu('House Control 3D')

    # 1. Catálogo Lumion (Comando Principal)
    cmd_catalog = UI::Command.new('Catálogo de Objetos y Materiales (Estilo Lumion)...') {
      Catalog.show_dialog
    }
    cmd_catalog.tooltip = 'Catálogo 3D Lumion: Insertar mobiliario, iluminación, climas y materiales con 1 clic'
    cmd_catalog.status_bar_text = 'Abre la biblioteca interactiva 3D estilo Lumion para colocar objetos y aplicar materiales'
    icon_cat_16 = File.join(icons_dir, 'catalog_16.png')
    icon_cat_24 = File.join(icons_dir, 'catalog_24.png')
    cmd_catalog.small_icon = icon_cat_16 if File.exist?(icon_cat_16)
    cmd_catalog.large_icon = icon_cat_24 if File.exist?(icon_cat_24)

    # 2. Enviar directamente a Celular por Wi-Fi
    cmd_send_to_phone = UI::Command.new('📲 Enviar Directo a Celular...') {
      DirectSync.send_plan_to_phone
    }
    cmd_send_to_phone.tooltip = 'Exportar y enviar modelo 3D directamente a la app de tu celular por Wi-Fi'
    cmd_send_to_phone.status_bar_text = 'Envía el plano 3D directamente a la app House Control en tu teléfono'
    icon_sync_16 = File.join(icons_dir, 'sync_16.png')
    icon_sync_24 = File.join(icons_dir, 'sync_24.png')
    cmd_send_to_phone.small_icon = icon_sync_16 if File.exist?(icon_sync_16)
    cmd_send_to_phone.large_icon = icon_sync_24 if File.exist?(icon_sync_24)

    # 3. Ventana de Configuración de Sincronización Wi-Fi (QR y Servidor)
    cmd_sync_dialog = UI::Command.new('⚙️ Sincronización Wi-Fi (QR y Servidor)...') {
      DirectSync.show_sync_dialog
    }
    cmd_sync_dialog.tooltip = 'Ver estado del servidor Wi-Fi, IP de la PC y código QR para conectar con el celular'
    cmd_sync_dialog.status_bar_text = 'Muestra la IP y QR de la PC para conectar con el celular'

    # 4. Importar Plano desde Archivo
    cmd_import = UI::Command.new('Importar Plano House Control (*.json)...') {
      Importer.prompt_and_import(Sketchup.active_model)
    }
    cmd_import.tooltip = 'Importar plano JSON (Z corregido hacia arriba y muebles suavizados)'
    cmd_import.status_bar_text = 'Importa un archivo plan.json a SketchUp en coordenadas positivas'

    # 5. Exportar Plano a Archivo
    cmd_export = UI::Command.new('Exportar a House Control (*.json)...') {
      Exporter.prompt_and_export(Sketchup.active_model)
    }
    cmd_export.tooltip = 'Exportar modelo 3D actual a formato plan.json de House Control'
    cmd_export.status_bar_text = 'Exporta el modelo actual manteniendo vinculaciones y materiales'

    # 6. Herramientas de Aristas
    cmd_smooth = UI::Command.new('Suavizar / Redondear Aristas...') {
      smooth_selection(true)
    }
    cmd_smooth.tooltip = 'Suavizar esquinas y aristas del objeto seleccionado (efecto redondeado)'

    cmd_sharp = UI::Command.new('Endurecer Aristas...') {
      smooth_selection(false)
    }
    cmd_sharp.tooltip = 'Restaurar aristas rectas y vivas en el objeto seleccionado'

    # 7. Convertidor e Inspector
    cmd_convert = UI::Command.new('Convertir Selección a Objeto House Control...') {
      convert_selection_dialog
    }
    cmd_convert.tooltip = 'Asignar un modelo 3D propio de SketchUp como mueble, luz o clima'

    cmd_inspect = UI::Command.new('Inspeccionar Datos del Elemento...') {
      inspect_selection
    }
    cmd_inspect.tooltip = 'Ver metadatos, elevación y vinculación del elemento'

    cmd_samples = UI::Command.new('Abrir Carpeta de Planos de Ejemplo...') {
      open_samples_folder
    }

    # Menú desplegable
    hc_menu.add_item(cmd_catalog)
    hc_menu.add_separator
    hc_menu.add_item(cmd_send_to_phone)
    hc_menu.add_item(cmd_sync_dialog)
    hc_menu.add_separator
    hc_menu.add_item(cmd_import)
    hc_menu.add_item(cmd_export)
    hc_menu.add_separator
    hc_menu.add_item(cmd_smooth)
    hc_menu.add_item(cmd_sharp)
    hc_menu.add_separator
    hc_menu.add_item(cmd_convert)
    hc_menu.add_item(cmd_inspect)
    hc_menu.add_separator
    hc_menu.add_item(cmd_samples)

    # Barra de herramientas (Toolbar)
    tb = UI::Toolbar.new('House Control 3D')
    tb.add_item(cmd_catalog)
    tb.add_item(cmd_send_to_phone)
    tb.add_separator
    tb.add_item(cmd_import)
    tb.add_item(cmd_export)
    tb.add_separator
    tb.add_item(cmd_smooth)
    tb.add_item(cmd_convert)
    tb.add_item(cmd_inspect)
    tb.restore

    file_loaded?(__FILE__)
  end
end
