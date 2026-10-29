# encoding: UTF-8
require 'sketchup.rb'

module HouseControlSync
  require_relative 'materials'
  require_relative 'builder'
  require_relative 'importer'
  require_relative 'exporter'

  def self.inspect_selection
    model = Sketchup.active_model
    sel = model.selection
    if sel.empty?
      UI.messagebox('Por favor selecciona un elemento del modelo de House Control primero.')
      return
    end

    ent = sel.first
    cat = ent.get_attribute('HouseControl', 'category')
    unless cat
      UI.messagebox("El elemento seleccionado (#{ent.name.empty? ? ent.class.to_s : ent.name}) no tiene datos de House Control.")
      return
    end

    id = ent.get_attribute('HouseControl', 'id') || '-'
    name = ent.get_attribute('HouseControl', 'name') || ent.name
    room = ent.get_attribute('HouseControl', 'room') || '-'
    type = ent.get_attribute('HouseControl', 'type') || '-'
    link = ent.get_attribute('HouseControl', 'link')
    tuya = ent.get_attribute('HouseControl', 'tuya')
    sensor = ent.get_attribute('HouseControl', 'sensor')

    pos = ent.transformation.origin
    px = pos.x.to_m.round(2)
    pz = (-pos.y).to_m.round(2)
    py = pos.z.to_m.round(2)

    device_info = if tuya && !tuya.empty?
                    "Smart Life / Tuya: #{tuya}"
                  elsif link && !link.empty?
                    "Enlace: #{link}"
                  else
                    "Sin dispositivo físico vinculado (Simulado)"
                  end

    msg = "Información del Elemento House Control:\n\n" +
          "• Categoría: #{cat.capitalize}\n" +
          "• Nombre: #{name}\n" +
          "• ID: #{id}\n" +
          "• Habitación: #{room}\n" +
          "• Tipo: #{type}\n" +
          "• Posición 3D (X, Z, Y): [#{px}m, #{pz}m, #{py}m]\n" +
          "• Dispositivo: #{device_info}\n\n" +
          "Puedes moverlo, rotarlo o escalarlo con las herramientas estándar de SketchUp."

    UI.messagebox(msg)
  end

  def self.open_samples_folder
    folder = File.expand_path('../../sample_plans', __FILE__)
    if File.directory?(folder)
      UI.openURL("file:///#{folder.tr('\\', '/')}")
    else
      UI.messagebox("Carpeta de ejemplos no encontrada en: #{folder}")
    end
  end

  # Crear Menús y Barra de Herramientas
  unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins') || UI.menu('Extensions')
    hc_menu = menu.add_submenu('House Control 3D')

    cmd_import = UI::Command.new('Importar Plano House Control (*.json)...') {
      Importer.prompt_and_import(Sketchup.active_model)
    }
    cmd_import.tooltip = 'Importar plano JSON de House Control con muebles, luces y climas'
    cmd_import.status_bar_text = 'Importa un archivo plan.json a SketchUp preservando toda la información'

    cmd_export = UI::Command.new('Exportar a House Control (*.json)...') {
      Exporter.prompt_and_export(Sketchup.active_model)
    }
    cmd_export.tooltip = 'Exportar modelo 3D actual a formato plan.json de House Control'
    cmd_export.status_bar_text = 'Exporta el modelo actual manteniendo las vinculaciones de luces y climas'

    cmd_inspect = UI::Command.new('Inspeccionar Datos del Elemento...') {
      inspect_selection
    }
    cmd_inspect.tooltip = 'Ver metadatos e integración del elemento seleccionado'

    cmd_samples = UI::Command.new('Abrir Carpeta de Planos de Ejemplo...') {
      open_samples_folder
    }

    hc_menu.add_item(cmd_import)
    hc_menu.add_item(cmd_export)
    hc_menu.add_separator
    hc_menu.add_item(cmd_inspect)
    hc_menu.add_separator
    hc_menu.add_item(cmd_samples)

    # Barra de herramientas (Toolbar)
    tb = UI::Toolbar.new('House Control 3D')
    tb.add_item(cmd_import)
    tb.add_item(cmd_export)
    tb.add_item(cmd_inspect)
    tb.restore

    file_loaded?(__FILE__)
  end
end
