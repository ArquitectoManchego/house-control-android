# encoding: UTF-8
require 'socket'
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
      puts "HouseControlSync: #{entry}" rescue nil
    end

    def self.send_http_response(client, status_code, status_text, content_type, body_str)
      headers = [
        "HTTP/1.1 #{status_code} #{status_text}",
        "Content-Type: #{content_type}; charset=utf-8",
        "Content-Length: #{body_str.bytesize}",
        "Access-Control-Allow-Origin: *",
        "Access-Control-Allow-Methods: GET, POST, OPTIONS",
        "Access-Control-Allow-Headers: Content-Type, Authorization",
        "Connection: close",
        "\r\n"
      ].join("\r\n")

      client.write(headers)
      client.write(body_str)
      client.flush
    rescue => e
      # Ignorar si el cliente cerró el socket
    end

    def self.handle_client(client)
      client.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, [5, 0].pack('l_2')) rescue nil

      request_line = client.gets
      return unless request_line

      parts = request_line.strip.split(/\s+/)
      return unless parts.size >= 2
      method = parts[0].upcase
      path = parts[1]

      headers = {}
      while (line = client.gets)
        line = line.strip
        break if line.empty?
        k, v = line.split(/:\s*/, 2)
        headers[k.downcase] = v if k && v
      end

      # Handle CORS Preflight
      if method == 'OPTIONS'
        send_http_response(client, 200, 'OK', 'application/json', '{"ok":true}')
        return
      end

      clean_path = path.split('?').first

      case clean_path
      when '/', '/status'
        model = Sketchup.active_model
        model_name = (model && !model.title.empty?) ? model.title : 'Casa House Control'
        res_json = {
          status: 'online',
          app: 'HouseControl SketchUp Sync',
          version: '1.2.0',
          pc_ip: local_ip,
          model_name: model_name
        }.to_json
        send_http_response(client, 200, 'OK', 'application/json', res_json)

      when '/api/plan.json'
        client_ip = client.peeraddr[3] rescue 'unknown'
        @last_phone_ip = client_ip
        Sketchup.write_default('HouseControl', 'last_phone_ip', client_ip) rescue nil
        log("📱 Celular conectado desde #{client_ip} solicitando plano 3D...")

        model = Sketchup.active_model
        plan_json = Exporter.export_json_string(model)
        send_http_response(client, 200, 'OK', 'application/json', plan_json)
        log("✓ Plano 3D enviado exitosamente al celular (#{client_ip})")

      when '/api/sync_plan', '/api/receive_plan'
        content_length = headers['content-length'].to_i
        body = ''
        if content_length > 0
          body = client.read(content_length) || ''
        end

        client_ip = client.peeraddr[3] rescue 'unknown'
        @last_phone_ip = client_ip
        Sketchup.write_default('HouseControl', 'last_phone_ip', client_ip) rescue nil
        log("📥 Recibiendo plano 3D enviado desde celular (#{client_ip})...")

        # Programar importación segura en el hilo principal de SketchUp
        UI.start_timer(0, false) do
          model = Sketchup.active_model
          success = Importer.import_json_string(model, body, "Celular (#{client_ip})", true)
          log(success ? "✓ Plano importado y actualizado en SketchUp" : "❌ Error al interpretar plano recibido")
        end

        send_http_response(client, 200, 'OK', 'application/json', '{"ok":true,"message":"Plano recibido e importado en SketchUp con éxito"}')

      else
        send_http_response(client, 404, 'Not Found', 'text/plain', 'Not Found')
      end
    rescue => e
      log("Error en conexión: #{e.message}")
    ensure
      client.close rescue nil
    end

    def self.start_server
      return if @server && @server_status == :running

      stop_server if @server

      begin
        log("Iniciando servidor de sincronización en puerto #{PORT}...")
        @server = TCPServer.new('0.0.0.0', PORT)
        @server_status = :running
        log("🟢 Servidor Wi-Fi activo en http://#{local_ip}:#{PORT}")

        @server_thread = Thread.new do
          while @server_status == :running && @server && !@server.closed?
            begin
              client = @server.accept
              Thread.new(client) do |c|
                handle_client(c)
              end
            rescue => e
              break if @server.nil? || @server.closed?
            end
          end
        end
      rescue => e
        @server_status = :error
        log("❌ Error al iniciar servidor: #{e.message}")
      end
    end

    def self.stop_server
      log("Deteniendo servidor de sincronización...")
      @server_status = :stopped
      if @server
        @server.close rescue nil
        @server = nil
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
