package dev.housecontrol.android.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dev.housecontrol.android.AppModel
import dev.housecontrol.android.R

/**
 * Pantalla de sincronización y respaldo: Exportación para SketchUp,
 * almacenamiento local y conexión con Google Drive, OneDrive y Dropbox.
 */
@Composable
fun CloudSyncScreen(model: AppModel, back: () -> Unit) {
    val context = LocalContext.current

    Screen("Sincronización y Respaldo", onBack = back) {
        // Sección SketchUp Sync
        Section("Trimble SketchUp") {
            Card(padding = 16.dp) {
                Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(painterResource(R.drawable.lucide_pencil_ruler), null, Modifier.size(20.dp), tint = Palette.accent)
                        Text(
                            "SketchUp 3D Sync",
                            Modifier.padding(start = 10.dp),
                            style = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = Palette.text)
                        )
                    }
                    Text(
                        "Exporta el proyecto actual en formato JSON para abrirlo y editarlo con el plugin House Control 3D Sync en tu computadora sin perder la vinculación de dispositivos.",
                        style = TextStyle(fontSize = 14.sp, color = Palette.muted, lineHeight = 20.sp)
                    )
                    PrimaryButton("Exportar para SketchUp (.json)", icon = R.drawable.lucide_upload) {
                        model.requestExportForSketchUp()
                    }
                    SecondaryButton("Compartir Archivo (WhatsApp, Mail, Drive)", icon = R.drawable.lucide_share_2) {
                        model.shareCurrentPlan(context)
                    }
                }
            }
            Footnote("El archivo generado se importa directamente desde SketchUp en Extensiones → House Control 3D → Importar Plano.")
        }

        // Sección Almacenamiento Local en el celular
        Section("Almacenamiento Local") {
            Card(padding = 16.dp) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(painterResource(R.drawable.lucide_download), null, Modifier.size(20.dp), tint = Palette.green)
                        Text(
                            "Memoria del Teléfono",
                            Modifier.padding(start = 10.dp),
                            style = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = Palette.text)
                        )
                    }
                    Text(
                        "Tus cambios se guardan localmente en la app. Pulsa aquí para exportar una copia accesible en tu carpeta pública de Documentos (Documents/HouseControl).",
                        style = TextStyle(fontSize = 14.sp, color = Palette.muted, lineHeight = 20.sp)
                    )
                    SecondaryButton("Guardar Copia en Documentos", icon = R.drawable.lucide_download) {
                        model.saveLocalBackup()
                    }
                }
            }
        }

        // Sección Servicios en la Nube
        Section("Cuentas en la Nube") {
            Card {
                // Google Drive
                CloudServiceRow(
                    name = "Google Drive",
                    detail = "Guarda o restaura desde tu cuenta de Google Drive",
                    tint = Color(0xFF4285F4),
                    onUpload = { model.requestExport("${model.customPlanName ?: "Casa"}-GoogleDrive") },
                    onDownload = { model.requestImport() }
                )
                RowDivider()

                // Microsoft OneDrive
                CloudServiceRow(
                    name = "Microsoft OneDrive",
                    detail = "Sincroniza tus proyectos con OneDrive personal o empresarial",
                    tint = Color(0xFF0078D4),
                    onUpload = { model.requestExport("${model.customPlanName ?: "Casa"}-OneDrive") },
                    onDownload = { model.requestImport() }
                )
                RowDivider()

                // Dropbox
                CloudServiceRow(
                    name = "Dropbox",
                    detail = "Almacena tus planos en Dropbox para acceder en múltiples dispositivos",
                    tint = Color(0xFF0061FE),
                    onUpload = { model.requestExport("${model.customPlanName ?: "Casa"}-Dropbox") },
                    onDownload = { model.requestImport() }
                )
            }
            Footnote("Al pulsar 'Guardar', el selector de archivos de Android te permitirá elegir la carpeta de tu cuenta de Google Drive, OneDrive o Dropbox.")
        }
    }
}

@Composable
private fun CloudServiceRow(
    name: String,
    detail: String,
    tint: Color,
    onUpload: () -> Unit,
    onDownload: () -> Unit,
) {
    Column(Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(painterResource(R.drawable.lucide_cloud), null, Modifier.size(20.dp), tint = tint)
            Text(
                name,
                Modifier.padding(start = 10.dp),
                style = TextStyle(fontSize = 16.sp, fontWeight = FontWeight.SemiBold, color = Palette.text)
            )
        }
        Text(
            detail,
            style = TextStyle(fontSize = 13.5.sp, color = Palette.muted)
        )
        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            SecondaryButton(
                "Guardar",
                Modifier.weight(1f),
                icon = R.drawable.lucide_upload,
                tint = tint,
                onClick = onUpload
            )
            SecondaryButton(
                "Cargar",
                Modifier.weight(1f),
                icon = R.drawable.lucide_download,
                onClick = onDownload
            )
        }
    }
}
