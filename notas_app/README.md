# Fichero — notas y tareas

App de notas multiplataforma (web + Android desde una sola base de código en Flutter),
con estilo minimalista tipo "fichero de biblioteca": papel cálido, tinta verde,
acento azul-acero. Sincroniza en tiempo real entre dispositivos vía Firebase.

## Qué incluye

- **Notas organizadas en libros**, con colores fijos por libro, etiquetas, campos
  personalizados (clave/valor) y recordatorio por fecha.
- **Editor de texto enriquecido** (flutter_quill): negrita, cursiva, subrayado,
  tachado, tamaños de letra, encabezados, alineación de párrafo, listas con
  casillas de "realizado", enlaces.
- **Generar tarea desde una nota**: selecciona cualquier texto (por ejemplo, un
  ítem de una lista) y el botón de la barra superior lo convierte en una tarea
  real que aparece de inmediato en el tablero Kanban, enlazada a la nota de
  origen. El tablero Kanban es, en esta app, el lugar único que reúne todas las
  tareas generadas desde cualquier nota (equivalente al "Tasks" de Evernote).
- **Kanban**: columnas Por hacer / En curso / Hecho, arrastrar y soltar entre
  columnas y reordenar dentro de cada una (mantener presionada la tarjeta),
  asignar a una persona (texto libre) y fecha límite.
- **Autenticación** con correo/contraseña o Google, para usar la misma cuenta
  en web y Android con los datos sincronizados en tiempo real por Firestore.

## Decisiones de stack (uso personal)

- **Flutter** para compartir una sola base de código entre web y Android.
- **Firebase** (Auth + Firestore) como backend: plan gratuito (Spark) más que
  suficiente para uso personal, sin servidor propio que mantener.
- Los datos de cada cuenta viven bajo `users/{uid}/books|notes|tasks` en
  Firestore, así que si más adelante quieras compartir un tablero con otra
  persona, ya hay una base de la que partir (habría que añadir una capa de
  tableros compartidos).

## Requisitos previos

- Flutter SDK (canal stable). Este proyecto se generó y verificó con Flutter 3.47.
- Una cuenta de Firebase (gratuita): https://console.firebase.google.com
- Node.js (para instalar Firebase CLI) y `dart pub global activate flutterfire_cli`.

## 1. Configurar Firebase

1. Crea un proyecto en https://console.firebase.google.com (por ejemplo, "fichero-notas").
2. En **Authentication → Sign-in method**, habilita:
   - **Correo/contraseña**
   - **Google**
3. En **Firestore Database**, crea la base de datos (modo producción) y pega las
   reglas de seguridad de la sección siguiente.
4. Instala las herramientas de línea de comandos (una sola vez):
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   firebase login
   ```
5. Desde la carpeta `notas_app/` de este proyecto, ejecuta:
   ```bash
   flutterfire configure
   ```
   Elige el proyecto de Firebase que creaste y selecciona las plataformas
   **web** y **android**. Esto reemplaza automáticamente el archivo
   `lib/firebase_options.dart` (hoy es un placeholder) con tus claves reales,
   y genera `android/app/google-services.json` además de registrar el plugin
   de Google Services en los `build.gradle.kts` de Android.

### Reglas de seguridad de Firestore

Cada usuario solo puede leer/escribir sus propios datos:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 2. Instalar dependencias

```bash
cd notas_app
flutter pub get
```

## 3. Ejecutar

Web:
```bash
flutter run -d chrome
```

Android (con un emulador o dispositivo conectado):
```bash
flutter run -d <id-del-dispositivo>
```

Compilar un APK para instalar directamente en tu teléfono:
```bash
flutter build apk --release
# resultado en build/app/outputs/flutter-apk/app-release.apk
```

## Verificado en este entorno

- `flutter analyze`: sin errores ni advertencias.
- `flutter test`: pasa (pruebas de tema y paleta de colores; las pantallas que
  dependen de Firebase necesitan `flutterfire configure` con un proyecto real
  para poder probarse end-to-end).
- `flutter build web`: compila correctamente.
- No se pudo compilar el APK de Android en este entorno porque no tiene el
  Android SDK instalado, pero todo el código Dart es compartido entre
  plataformas y ya pasó `flutter analyze` sin problemas; solo falta que
  `flutterfire configure` genere `google-services.json` con tu proyecto real.

## Próximos pasos posibles (no incluidos todavía)

- Notificaciones push para los recordatorios de notas y fechas límite de
  tareas (requeriría Cloud Functions + FCM).
- Compartir un libro o tablero Kanban con otra persona (hoy todo es privado
  por cuenta).
- Exportar notas a Markdown/PDF.
