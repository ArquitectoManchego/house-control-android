# encoding: UTF-8
require 'socket'
require 'webrick'
require 'net/http'
require 'uri'
require 'json'

module HouseControlSync
  module DirectSync
    PORT = 8765
    PHONE_PORT = 8766

    @server = nil
    @server_thread = nil
    @server_status = :stopped
    @last_phone_ip = nil
    @dialog = nil
    @activity_log = []

    def self.local_ip
      orig = Socket.do_not_reverse_lookup
      Socket.do_not_reverse_lookup = true
      UDPSocket.open do |s|
        s.connect('8.8.8.8', 1)
        s.addr.last
      end
    rescue
      '127.0.0.1'
    ensure
      Socket.do_not_reverse_lookup = orig
    end

    def self.log(message)
      entry = "[#{Time.now.strftime('%H:%M:%S')}] #{message}"
      @activity_log << entry
      @activity_log.shift if @activity_log.size > 50
      notify_ui_log(entry)
    end

    def self.add_cors_headers(res)
      res['Access-Control-Allow-Origin'] = '*'
      res['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
      res['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    end

    def self.start_server
      return if @server && @server_status == :running

      begin
        log("Iniciando servidor de sincronización en puerto #{PORT}...")
        @server = WEBrick::HTTPServer.new(
          Port: PORT,
          BindAddress: '0.0.0.0',
          Logger: WEBrick::Log.new(nil, WEBrick::BasicLog::WARN),
          AccessLog: []
        )

        # GET / o /status
        @server.mount_proc '/' do |_req, res|
          add_cors_headers(res)
          res['Content-Type'] = 'application/json'
          model = Sketchup.active_model
          model_name = (model && !model.title.empty?) ? model.title : 'Casa House Control'
          res.body = {
            status: 'online',
            app: 'HouseControl SketchUp Sync',
            version: '1.2.0',
            pc_ip: local_ip,
            model_name: model_name
          }.to_json
        end

        # GET /api/plan.json - El celular descarga el plano actual de SketchUp
        @server.mount_proc '/api/plan.json' do |req, res|
          add_cors_headers(res)
          client_ip = req.peeraddr[3]
          @last_phone_ip = client_ip
          Sketchup.write_default('HouseControl', 'last_phone_ip', client_ip)
          log("📱 Celular conectado desde #{client_ip} solicitando plano 3D...")

          model = Sketchup.active_model
          plan_json = Exporter.export_json_string(model)

          res['Content-Type'] = 'application/json'
          res.body = plan_json
          log("✓ Plano 3D enviado exitosamente al celular (#{client_ip})")
        end

        # POST /api/sync_plan o /api/upload_plan - El celular envía su plano a SketchUp
        @server.mount_proc '/api/sync_plan' do |req, res|
          add_cors_headers(res)
          if req.request_method == 'OPTIONS'
            res.status = 200
            next
          end

          client_ip = req.peeraddr[3]
          @last_phone_ip = client_ip
          Sketchup.write_default('HouseControl', 'last_phone_ip', client_ip)
          body = req.body.to_s
          log("📥 Recibiendo plano 3D enviado desde celular (#{client_ip})...")

          # Ejecutar en el hilo principal de SketchUp de forma 100% segura
          UI.start_timer(0, false) do
            model = Sketchup.active_model
            success = Importer.import_json_string(model, body, "Celular (#{client_ip})", true)
            log(success ? "✓ Plano importado y actualizado en SketchUp" : "❌ Error al interpretar plano recibido")
          end

          res['Content-Type'] = 'application/json'
          res.body = { ok: true, message: 'Plano recibido e importado en SketchUp con éxito' }.to_json
        end

        @server_thread = Thread.new { @server.start }
        @server_status = :running
        log("🟢 Servidor Wi-Fi activo en http://#{local_ip}:#{PORT}")
      rescue => e
        @server_status = :error
        log("❌ Error al iniciar servidor: #{e.message}")
      end
    end

    def self.stop_server
      if @server
        log("Deteniendo servidor de sincronización...")
        @server.shutdown rescue nil
        @server = nil
        @server_status = :stopped
      end
      if @server_thread
        @server_thread.kill rescue nil
        @server_thread = nil
      end
    end

    # Enviar plano directamente desde SketchUp al celular (Push a puerto 8766)
    def self.send_plan_to_phone(target_ip = nil)
      start_server unless @server_status == :running

      ip = target_ip || @last_phone_ip || Sketchup.read_default('HouseControl', 'last_phone_ip', '')

      if ip.nil? || ip.empty? || ip == '127.0.0.1'
        # Pedir IP o abrir ventana de sincronización
        show_sync_dialog
        return
      end

      model = Sketchup.active_model
      plan_json = Exporter.export_json_string(model)

      log("🚀 Enviando plano a app en celular (http://#{ip}:#{PHONE_PORT}/api/receive_plan)...")

      Thread.new do
        begin
          uri = URI.parse("http://#{ip}:#{PHONE_PORT}/api/receive_plan")
          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = 4
          http.read_timeout = 6

          request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
          request.body = plan_json

          response = http.request(request)

          UI.start_timer(0, false) do
            if response.code.to_i == 200
              log("✓ ¡Plano recibido y cargado en el celular (#{ip}) con éxito!")
              UI.messagebox("¡Plano 3D enviado con éxito a tu celular!\n\n" +
                            "Dispositivo: #{ip}\n" +
                            "La app House Control ya ha actualizado el plano 3D en pantalla.")
            else
              log("⚠ El celular respondió con código #{response.code}")
              UI.messagebox("El celular respondió con código #{response.code}.\nAsegúrate de tener la app House Control abierta.")
            end
          end
        rescue => err
          log("❌ No se pudo conectar con #{ip}:#{PHONE_PORT} (#{err.message})")
          UI.start_timer(0, false) do
            UI.messagebox("No se pudo conectar con el celular en #{ip}:#{PHONE_PORT}.\n\n" +
                          "Asegúrate de que la app House Control esté abierta en tu celular en la misma red Wi-Fi.\n\n" +
                          "Se abrirá la ventana de sincronización para verificar la IP o escanear el código QR.")
            show_sync_dialog
          end
        end
      end
    end

    def self.show_sync_dialog
      start_server unless @server_status == :running

      if @dialog && @dialog.visible?
        @dialog.bring_to_front
        return
      end

      dialog_options = {
        dialog_title: "Sincronización Directa Wi-Fi - House Control ⇄ SketchUp",
        preferences_key: "HouseControl_DirectSync",
        scrollable: false,
        resizable: true,
        width: 720,
        height: 600,
        left: 200,
        top: 120,
        min_width: 600,
        min_height: 500,
        style: UI::HtmlDialog::STYLE_DIALOG
      }

      @dialog = UI::HtmlDialog.new(dialog_options)
      html_path = File.join(File.dirname(__FILE__), 'web', 'sync.html')
      @dialog.set_file(html_path)

      # Callbacks
      @dialog.add_action_callback("get_status") do |_context|
        send_status_to_dialog
      end

      @dialog.add_action_callback("send_to_phone") do |_context, phone_ip|
        phone_ip = phone_ip.to_s.strip
        unless phone_ip.empty?
          @last_phone_ip = phone_ip
          Sketchup.write_default('HouseControl', 'last_phone_ip', phone_ip)
        end
        send_plan_to_phone(phone_ip)
      end

      @dialog.add_action_callback("refresh_server") do |_context|
        stop_server
        start_server
        send_status_to_dialog
      end

      @dialog.show
    end

    def self.send_status_to_dialog
      return unless @dialog
      data = {
        pc_ip: local_ip,
        port: PORT,
        server_url: "http://#{local_ip}:#{PORT}",
        status: @server_status.to_s,
        last_phone_ip: @last_phone_ip || Sketchup.read_default('HouseControl', 'last_phone_ip', ''),
        logs: @activity_log
      }
      @dialog.execute_script("if(window.updateStatus) { updateStatus(#{data.to_json}); }")
    end

    def self.notify_ui_log(msg)
      if @dialog
        @dialog.execute_script("if(window.appendLog) { appendLog(#{msg.to_json}); }")
      end
    end
  end
end
