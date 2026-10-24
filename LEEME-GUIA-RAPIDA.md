# Guía Rápida - House Control para Android & Web

Bienvenido a **House Control**, la aplicación para visualizar y controlar tu hogar mediante un **modelo 3D interactivo en tiempo real**.

---

## 🚀 Archivos y Accesos Directos Creados

En la carpeta principal del proyecto (`c:\PROYECTOS ANTIGRAVITY\house-control-android`):

1. **`HouseControl-debug.apk`** (18.6 MB):
   - El archivo instalador APK listo para instalar en cualquier teléfono o tablet Android (Android 8.0 en adelante).
2. **`instalar-en-celular-o-emulador.bat`**:
   - Conecta tu celular por USB (con *Depuración USB* activada) o abre un emulador, y haz doble clic en este archivo para instalar y abrir la app de inmediato.
3. **`iniciar-servidor-web.bat`**:
   - Ejecuta el modelo 3D y el panel interactivo directamente en el navegador de tu computadora (`http://localhost:5199/?platform=android`) para probar planos, luces, climas, simulación y el editor sin necesidad de un teléfono físico.
4. **`compilar-apk.bat`**:
   - Recompila el APK en caso de que hagas cambios en el código o diseño.

---

## 📱 ¿Cómo instalar el APK en tu celular Android?

### Opción A (Vía Cable USB / ADB - Automático):
1. Activa las **Opciones de desarrollador** y la **Depuración USB** en tu teléfono Android.
2. Conéctalo por cable USB a la computadora.
3. Haz doble clic en [`instalar-en-celular-o-emulador.bat`](file:///c:/PROYECTOS%20ANTIGRAVITY/house-control-android/instalar-en-celular-o-emulador.bat).

### Opción B (Manual):
1. Envía el archivo [`HouseControl-debug.apk`](file:///c:/PROYECTOS%20ANTIGRAVITY/house-control-android/HouseControl-debug.apk) a tu teléfono (por WhatsApp, Google Drive, Telegram o cable).
2. En tu teléfono, ábrelo y selecciona **Instalar** (Android te pedirá conceder permiso para instalar apps de fuentes desconocidas).

---

## 🌐 Funcionalidades Principales

- **Plano en 3D en Tiempo Real:** Paredes, puertas, ventanas, muebles y lámparas que iluminan la habitación con el color y brillo real.
- **Control de Iluminación:** Enciende/apaga con un toque, desliza para graduar brillo y mantén presionado para cambiar color o temperatura de luz blanca.
- **Aires Acondicionados:** Control de encendido, temperatura deseada, modo, velocidad de ventilador y oscilación (muestra viento animado en 3D).
- **Escenas Inteligentes:** Configura escenas completas como "Cine", "Noche", "Acogedor" con un solo clic.
- **Editor de Planos Integrado:** Diseña tu casa directamente, añade habitaciones y muebles, ajusta paredes y enlaza cada lámpara a un dispositivo real.
- **Integraciones Compatibles:**
  - **Smart Life / Tuya:** Vinculación mediante código QR desde la app Smart Life (sin necesidad de cuenta de desarrollador).
  - **Home Assistant:** Detección automática en la red local Wi-Fi con token de acceso de larga duración.
  - **Philips Hue:** Emparejamiento con el puente local pulsando el botón central.
