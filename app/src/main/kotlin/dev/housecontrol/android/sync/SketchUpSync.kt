package dev.housecontrol.android.sync

import android.content.Context
import android.content.SharedPreferences
import dev.housecontrol.android.core.Http
import dev.housecontrol.android.core.HttpAnswer
import dev.housecontrol.android.core.PlanStore
import dev.housecontrol.android.core.fetch
import dev.housecontrol.android.core.readable
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStream
import java.net.Inet4Address
import java.net.NetworkInterface
import java.net.ServerSocket
import java.net.Socket

/**
 * Gestor de sincronización directa inalámbrica entre la app House Control (celular)
 * y Trimble SketchUp (PC) a través de Wi-Fi local sin depender de la nube.
 */
class SketchUpSync(
    private val context: Context,
    private val scope: CoroutineScope,
    private val onPlanReceived: (ByteArray) -> Unit
) {
    companion object {
        const val PC_DEFAULT_PORT = 8765
        const val PHONE_RECEIVER_PORT = 8766
        private const val PREFS_NAME = "sketchup_sync_prefs"
        private const val KEY_PC_IP = "last_pc_ip"
    }

    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private var receiverJob: Job? = null
    private var serverSocket: ServerSocket? = null

    var lastPcIp: String
        get() = prefs.getString(KEY_PC_IP, "192.168.1.68") ?: "192.168.1.68"
        set(value) {
            prefs.edit().putString(KEY_PC_IP, value.trim()).apply()
        }

    val isReceiverRunning: Boolean
        get() = serverSocket != null && !(serverSocket?.isClosed ?: true)

    /**
     * Inicia el receptor HTTP local en el celular (puerto 8766).
     * Permite que SketchUp envíe ("Push") el plano directamente al teléfono.
     */
    fun startReceiver() {
        if (receiverJob != null && isReceiverRunning) return

        receiverJob = scope.launch(Dispatchers.IO) {
            try {
                serverSocket = ServerSocket(PHONE_RECEIVER_PORT).apply {
                    reuseAddress = true
                }

                while (isActive && serverSocket != null && !serverSocket!!.isClosed) {
                    val clientSocket = try {
                        serverSocket?.accept() ?: break
                    } catch (_: Exception) {
                        break
                    }

                    launch(Dispatchers.IO) {
                        handleClient(clientSocket)
                    }
                }
            } catch (e: Exception) {
                // Puerto en uso o red cambiada
            } finally {
                stopReceiver()
            }
        }
    }

    fun stopReceiver() {
        try {
            serverSocket?.close()
        } catch (_: Exception) {}
        serverSocket = null
        receiverJob?.cancel()
        receiverJob = null
    }

    private fun handleClient(socket: Socket) {
        socket.use { s ->
            s.soTimeout = 8000
            val input = s.getInputStream()
            val reader = BufferedReader(InputStreamReader(input, Charsets.UTF_8))
            val output = s.getOutputStream()

            val requestLine = reader.readLine() ?: return
            var contentLength = 0

            var line: String?
            while (reader.readLine().also { line = it } != null) {
                if (line.isNullOrEmpty()) break
                val lower = line!!.lowercase()
                if (lower.startsWith("content-length:")) {
                    contentLength = lower.substringAfter("content-length:").trim().toIntOrNull() ?: 0
                }
            }

            if (requestLine.startsWith("GET /")) {
                sendResponse(output, 200, "application/json", jsonOf(
                    "app" to "HouseControl Android Receiver",
                    "port" to PHONE_RECEIVER_PORT,
                    "status" to "online"
                ).toString())
                return
            }

            if (requestLine.startsWith("POST /api/receive_plan") || requestLine.startsWith("POST /api/sync_plan") || requestLine.startsWith("POST /")) {
                if (contentLength > 0) {
                    val bodyBytes = ByteArray(contentLength)
                    var readTotal = 0
                    while (readTotal < contentLength) {
                        val count = input.read(bodyBytes, readTotal, contentLength - readTotal)
                        if (count < 0) break
                        readTotal += count
                    }

                    if (readTotal == contentLength) {
                        // Enviar a la app principal
                        scope.launch(Dispatchers.Main) {
                            try {
                                PlanStore.validate(bodyBytes)
                                onPlanReceived(bodyBytes)
                            } catch (_: Exception) {}
                        }

                        sendResponse(output, 200, "application/json", jsonOf(
                            "ok" to true,
                            "message" to "Plano recibido y actualizado en House Control"
                        ).toString())
                        return
                    }
                }
            }

            sendResponse(output, 400, "application/json", jsonOf("error" to "Bad Request").toString())
        }
    }

    private fun sendResponse(output: OutputStream, status: Int, contentType: String, body: String) {
        val bytes = body.toByteArray(Charsets.UTF_8)
        val header = "HTTP/1.1 $status OK\r\n" +
                "Content-Type: $contentType\r\n" +
                "Content-Length: ${bytes.size}\r\n" +
                "Access-Control-Allow-Origin: *\r\n" +
                "Connection: close\r\n\r\n"
        output.write(header.toByteArray(Charsets.UTF_8))
        output.write(bytes)
        output.flush()
    }

    /**
     * Prueba si el servidor de SketchUp está respondiendo en la IP indicada.
     */
    suspend fun testConnection(pcIp: String): Result<String> = withContext(Dispatchers.IO) {
        val cleanIp = pcIp.trim().removePrefix("http://").removePrefix("https://").substringBefore(":")
        val url = "http://$cleanIp:$PC_DEFAULT_PORT/"
        try {
            val req = Request.Builder().url(url).get().build()
            val answer = Http.client.fetch(req)
            if (answer.code == 200) {
                lastPcIp = cleanIp
                val json = runCatching { JSONObject(answer.text) }.getOrNull()
                val modelName = json?.optString("model_name") ?: "SketchUp"
                Result.success(modelName)
            } else {
                Result.failure(Exception("SketchUp respondió con error HTTP ${answer.code}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("No se pudo conectar a $cleanIp:$PC_DEFAULT_PORT (${e.readable})"))
        }
    }

    /**
     * Exporta el plano actual del celular y lo envía por HTTP POST hacia SketchUp.
     */
    suspend fun exportToPc(pcIp: String, planJson: JSONObject): Result<String> = withContext(Dispatchers.IO) {
        val cleanIp = pcIp.trim().removePrefix("http://").removePrefix("https://").substringBefore(":")
        val url = "http://$cleanIp:$PC_DEFAULT_PORT/api/sync_plan"
        try {
            val body = planJson.toString().toRequestBody("application/json".toMediaType())
            val req = Request.Builder().url(url).post(body).build()
            val answer = Http.client.fetch(req)

            if (answer.code == 200) {
                lastPcIp = cleanIp
                Result.success("Plano exportado exitosamente a SketchUp en $cleanIp")
            } else {
                Result.failure(Exception("Error en SketchUp (HTTP ${answer.code}): ${answer.text}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("Error de conexión con SketchUp en $cleanIp: ${e.readable}"))
        }
    }

    /**
     * Solicita y descarga el plano 3D actual directamente desde SketchUp en la PC.
     */
    suspend fun importFromPc(pcIp: String): Result<ByteArray> = withContext(Dispatchers.IO) {
        val cleanIp = pcIp.trim().removePrefix("http://").removePrefix("https://").substringBefore(":")
        val url = "http://$cleanIp:$PC_DEFAULT_PORT/api/plan.json"
        try {
            val req = Request.Builder().url(url).get().build()
            val answer = Http.client.fetch(req)

            if (answer.code == 200) {
                lastPcIp = cleanIp
                val bytes = answer.text.toByteArray(Charsets.UTF_8)
                PlanStore.validate(bytes)
                Result.success(bytes)
            } else {
                Result.failure(Exception("SketchUp respondió con error HTTP ${answer.code}"))
            }
        } catch (e: Exception) {
            Result.failure(Exception("No se pudo descargar el plano desde SketchUp: ${e.readable}"))
        }
    }

    /**
     * Obtiene la dirección IPv4 del celular en la red Wi-Fi local para mostrarla al usuario.
     */
    fun getLocalWifiIp(): String {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            while (interfaces.hasMoreElements()) {
                val iface = interfaces.nextElement()
                if (iface.isLoopback || !iface.isUp) continue
                val addrs = iface.inetAddresses
                while (addrs.hasMoreElements()) {
                    val addr = addrs.nextElement()
                    if (!addr.isLoopbackAddress && addr is Inet4Address) {
                        val host = addr.hostAddress ?: continue
                        if (host != "127.0.0.1") return host
                    }
                }
            }
        } catch (_: Exception) {}
        return "192.168.1.X"
    }

    private fun jsonOf(vararg pairs: Pair<String, Any?>): JSONObject =
        JSONObject().apply {
            for ((key, value) in pairs) {
                put(key, value ?: JSONObject.NULL)
            }
        }
}
