package dev.housecontrol.android.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.housecontrol.android.AppModel
import dev.housecontrol.android.Banner
import dev.housecontrol.android.R
import dev.housecontrol.android.sync.SketchUpSync
import kotlinx.coroutines.launch

/**
 * Pantalla de sincronización bidireccional inalámbrica directa con Trimble SketchUp (PC).
 */
@Composable
fun SketchUpSyncScreen(model: AppModel, onBack: () -> Unit) {
    val scope = rememberCoroutineScope()
    var pcIp by remember { mutableStateOf(model.sketchupSync.lastPcIp) }
    var connectionStatus by remember { mutableStateOf<ConnectionTestStatus>(ConnectionTestStatus.Idle) }
    var isExporting by remember { mutableStateOf(false) }
    var isImporting by remember { mutableStateOf(false) }

    val phoneIp = remember { model.sketchupSync.getLocalWifiIp() }

    LaunchedEffect(Unit) {
        // Probar conexión inicial silenciosa
        connectionStatus = ConnectionTestStatus.Testing
        val res = model.sketchupSync.testConnection(pcIp)
        connectionStatus = if (res.isSuccess) {
            ConnectionTestStatus.Connected(res.getOrNull() ?: "SketchUp")
        } else {
            ConnectionTestStatus.Failed
        }
    }

    Screen("Sincronización SketchUp", onBack = onBack) {
        Section("Conexión Wi-Fi con tu PC") {
            Card(padding = 16.dp) {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Dirección IP de tu PC con SketchUp", style = Type.title)
                    Text("Ingresa la IP local de tu computadora en la red Wi-Fi (la misma que muestra SketchUp):",
                        style = TextStyle(fontSize = 13.5.sp, color = Palette.muted, lineHeight = 18.sp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        val shape = RoundedCornerShape(12.dp)
                        TextField(
                            value = pcIp,
                            onValueChange = {
                                pcIp = it.trim()
                                model.sketchupSync.lastPcIp = pcIp
                                connectionStatus = ConnectionTestStatus.Idle
                            },
                            modifier = Modifier.weight(1f).clip(shape).border(BorderStroke(1.dp, Palette.line), shape),
                            singleLine = true,
                            textStyle = TextStyle(fontFamily = FontFamily.Monospace, fontSize = 14.sp, color = Palette.text),
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = Color.Black.copy(alpha = 0.3f),
                                unfocusedContainerColor = Color.Black.copy(alpha = 0.3f),
                                focusedIndicatorColor = Palette.accent,
                                unfocusedIndicatorColor = Color.Transparent,
                                cursorColor = Palette.accent
                            )
                        )

                        SecondaryButton(
                            text = "Probar",
                            modifier = Modifier.width(95.dp),
                            icon = R.drawable.lucide_refresh_cw
                        ) {
                            scope.launch {
                                connectionStatus = ConnectionTestStatus.Testing
                                val res = model.sketchupSync.testConnection(pcIp)
                                connectionStatus = if (res.isSuccess) {
                                    ConnectionTestStatus.Connected(res.getOrNull() ?: "SketchUp")
                                } else {
                                    ConnectionTestStatus.Failed
                                }
                            }
                        }
                    }

                    // Indicador visual de estado
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.padding(top = 4.dp)
                    ) {
                        when (val s = connectionStatus) {
                            is ConnectionTestStatus.Testing -> {
                                CircularProgressIndicator(Modifier.size(14.dp), strokeWidth = 2.dp, color = Palette.accent)
                                Text("Comprobando conexión con SketchUp...", style = TextStyle(fontSize = 12.5.sp, color = Palette.muted))
                            }
                            is ConnectionTestStatus.Connected -> {
                                Box(Modifier.size(8.dp).background(Palette.green, CircleShape))
                                Text("Conectado con SketchUp (${s.modelName})", style = TextStyle(fontSize = 12.5.sp, color = Palette.green, fontWeight = FontWeight.SemiBold))
                            }
                            is ConnectionTestStatus.Failed -> {
                                Box(Modifier.size(8.dp).background(Palette.red, CircleShape))
                                Text("SketchUp no responde en puerto 8765", style = TextStyle(fontSize = 12.5.sp, color = Palette.red))
                            }
                            ConnectionTestStatus.Idle -> {
                                Box(Modifier.size(8.dp).background(Palette.muted, CircleShape))
                                Text("Listo para sincronizar", style = TextStyle(fontSize = 12.5.sp, color = Palette.muted))
                            }
                        }
                    }
                }
            }
        }

        Section("Acciones de Sincronización") {
            // BOTÓN DE EXPORTAR DESDE LA APP HACIA LA PC
            PrimaryButton(
                text = if (isExporting) "Exportando a PC..." else "Exportar a mi PC (SketchUp)",
                icon = R.drawable.lucide_upload,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (!isExporting) {
                    isExporting = true
                    model.exportToSketchUp(pcIp) { success, _ ->
                        isExporting = false
                    }
                }
            }

            Spacer(Modifier.height(8.dp))

            // BOTÓN DE IMPORTAR DIRECTAMENTE DESDE LA PC
            SecondaryButton(
                text = if (isImporting) "Descargando desde PC..." else "Importar directo desde PC (SketchUp)",
                icon = R.drawable.lucide_download,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (!isImporting) {
                    isImporting = true
                    model.importFromSketchUp(pcIp) { success, _ ->
                        isImporting = false
                    }
                }
            }

            Footnote("Ambos dispositivos deben estar en la misma red Wi-Fi. Al exportar, tu modelo se actualiza de inmediato en SketchUp sin necesidad de cables ni correos.")
        }

        Section("Receptor Móvil en Vivo") {
            Card(padding = 16.dp) {
                Row(verticalAlignment = Alignment.Top) {
                    IconBadge(R.drawable.lucide_smartphone, Palette.green)
                    Spacer(Modifier.width(14.dp))
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            Box(Modifier.size(8.dp).background(Palette.green, CircleShape))
                            Text("Receptor Móvil Activo", style = Type.title)
                        }
                        Text("IP de este celular: http://$phoneIp:${SketchUpSync.PHONE_RECEIVER_PORT}",
                            style = TextStyle(fontFamily = FontFamily.Monospace, fontSize = 12.5.sp, color = Palette.accent))
                        Text("Cuando pulses 'Enviar a Celular' en SketchUp, tu teléfono actualizará el plano automáticamente en vivo.",
                            style = TextStyle(fontSize = 13.sp, color = Palette.muted, lineHeight = 17.sp))
                    }
                }
            }
        }
    }
}

private sealed class ConnectionTestStatus {
    data object Idle : ConnectionTestStatus()
    data object Testing : ConnectionTestStatus()
    data class Connected(val modelName: String) : ConnectionTestStatus()
    data object Failed : ConnectionTestStatus()
}
