# encoding: UTF-8
# ==============================================================================
# House Control 3D Sync for Trimble SketchUp
# Compatible with SketchUp 2018 - 2026 (Ruby 2.2+ - Ruby 3.2+)
# ==============================================================================

require 'sketchup.rb'
require 'extensions.rb'

module HouseControlSync
  loader_path = File.join(File.dirname(__FILE__), 'house_control_sync', 'main.rb')
  extension = SketchupExtension.new('House Control 3D Sync', loader_path)
  extension.description = 'Importa y exporta planos 3D compatibles con la app House Control manteniendo todos los datos e integraciones de luces, climas y muebles.'
  extension.version     = '1.2.0'
  extension.copyright   = '2026 ArquitectoManchego & Antigravity'
  extension.creator     = 'Alex (ArquitectoManchego)'

  Sketchup.register_extension(extension, true)

  # Carga directa garantizada para levantar servidor Wi-Fi y barra de herramientas
  begin
    load loader_path
  rescue => err
    puts "HouseControlSync: Error al cargar extension: #{err.message}\n#{err.backtrace.join("\n") rescue ''}"
  end
end
