# Guía de Deployment - ContextDo

Esta guía explica cómo desplegar ContextDo a Firebase App Distribution para pruebas.

---

## 1. Prerrequisitos

### Firebase Console
- [x] Proyecto creado en Firebase Console
- [x] App Android registrada con package `com.novaferi.contextdo`
- [x] `google-services.json` descargado y en `android/app/`

### GitHub Secrets (ya configurados)
| Secret | Descripción |
|--------|-------------|
| `FIREBASE_APP_ID` | ID de la app en Firebase |
| `FIREBASE_SERVICE_ACCOUNT` | JSON del Service Account |
| `KEYSTORE_BASE64` | Keystore codificado en base64 |
| `KEYSTORE_PASSWORD` | Contraseña del keystore |
| `KEY_ALIAS` | Alias de la clave (`upload`) |
| `KEY_PASSWORD` | Contraseña de la clave |

### Para Deploy Local
- Firebase CLI instalado (`npm install -g firebase-tools`)
- Sesión iniciada (`firebase login`)
- Variable `FIREBASE_APP_ID` configurada

---

## 2. Flujo de CI/CD (Automático)

### ¿Qué dispara el workflow?

| Evento | Descripción |
|--------|-------------|
| Push a `main` | Cualquier commit a la rama principal |
| Tag `v*.*.*` | Crear un tag de versión (ej: `v0.1.1`) |
| Manual | Desde GitHub Actions → "Run workflow" |

### ¿Qué hace cada step?

```
1. Checkout          → Descarga el código
2. Setup Java 17     → Instala Java (requerido por Gradle)
3. Setup Flutter     → Instala Flutter 3.32.0 stable
4. Get dependencies  → flutter pub get
5. Decode Keystore   → Decodifica el keystore desde secrets
6. Create key.props  → Crea key.properties desde secrets
7. Build APK         → flutter build apk --release
8. Release Notes     → Genera notas con últimos commits
9. Upload Firebase   → Sube a App Distribution
10. Save Artifact    → Guarda APK en GitHub (30 días)
```

### ¿Cómo ver los logs?

1. Ve a tu repositorio en GitHub
2. Pestaña **Actions**
3. Clic en el workflow en ejecución
4. Clic en el job para ver logs detallados

---

## 3. Deploy Local

### Instalación de Firebase CLI

```bash
# Instalar con npm
npm install -g firebase-tools

# Verificar instalación
firebase --version
```

### Autenticación

```bash
# Iniciar sesión (abre navegador)
firebase login

# Verificar proyectos disponibles
firebase projects:list
```

### Configurar FIREBASE_APP_ID

Encuentra tu App ID en Firebase Console → Configuración → Tus apps

```bash
# Temporal (solo esta sesión)
export FIREBASE_APP_ID='1:123456789:android:abc123def456'

# Permanente (agregar a ~/.bashrc o ~/.zshrc)
echo 'export FIREBASE_APP_ID="1:123456789:android:abc123def456"' >> ~/.bashrc
source ~/.bashrc
```

### Comandos del Makefile

```bash
# Ver todos los comandos disponibles
make help

# Compilar APK de release
make build-apk

# Compilar AAB para Play Store
make build-aab

# Instalar en dispositivo conectado
make install

# Subir a Firebase App Distribution
make deploy

# Limpiar artefactos
make clean

# Ver versiones instaladas
make version
```

### Ejemplo de deploy completo

```bash
# 1. Configurar App ID (solo la primera vez)
export FIREBASE_APP_ID='tu-app-id-aqui'

# 2. Deploy
make deploy

# Esto ejecuta:
# - Verifica Flutter y Firebase CLI
# - Compila APK de release
# - Sube a Firebase App Distribution
# - Los testers reciben email
```

---

## 4. Gestión de Testers

### Agregar testers en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Tu proyecto → **App Distribution** (menú lateral)
3. Pestaña **Testers y grupos**
4. Clic en **Agregar testers**
5. Ingresa emails separados por comas

### Grupos de testers

Por defecto usamos el grupo `internal`. Puedes crear más grupos:

1. En App Distribution → Testers y grupos
2. Clic en **Crear grupo**
3. Nombre: `beta`, `qa`, etc.
4. Agrega testers al grupo

Para usar un grupo diferente en deploy local:

```bash
TESTERS_GROUP=beta make deploy
```

### Invitaciones

- Los testers reciben email con link de descarga
- Deben aceptar la invitación la primera vez
- Después reciben notificaciones de nuevos builds

---

## 5. Troubleshooting

### Error: "Firebase CLI not found"

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# O con curl
curl -sL https://firebase.tools | bash
```

### Error: "FIREBASE_APP_ID not set"

```bash
# Configurar la variable
export FIREBASE_APP_ID='1:123456789:android:abc123'

# Verificar
echo $FIREBASE_APP_ID
```

### Error: "Authentication failed"

```bash
# Re-autenticar
firebase logout
firebase login
```

### Error: "Service account permissions"

El Service Account necesita el rol `Firebase App Distribution Admin`:

1. Ve a Google Cloud Console
2. IAM y administración → Cuentas de servicio
3. Edita la cuenta `github-actions-firebase`
4. Agrega rol: `Firebase App Distribution Admin`

### Error: "APK not found"

```bash
# Limpiar y recompilar
make clean
make build-apk
```

### Error: "Keystore not found" (en CI/CD)

Verifica que el secret `KEYSTORE_BASE64` esté correctamente configurado:

```bash
# Regenerar base64 del keystore
base64 -w 0 android/app/upload-keystore.jks
```

### El workflow falla en GitHub Actions

1. Ve a Actions → workflow fallido
2. Revisa los logs del step que falló
3. Errores comunes:
   - Secrets mal configurados
   - Versión de Flutter incompatible
   - Dependencias faltantes

### Los testers no reciben email

1. Verifica que estén en el grupo correcto
2. Revisa que hayan aceptado la invitación inicial
3. Revisa carpeta de spam

---

## 6. Referencia Rápida

### URLs Importantes

| Recurso | URL |
|---------|-----|
| Firebase Console | https://console.firebase.google.com/ |
| Google Cloud Console | https://console.cloud.google.com/ |
| GitHub Actions | https://github.com/TU_USUARIO/contextdo/actions |

### Archivos de Configuración

| Archivo | Propósito |
|---------|-----------|
| `.github/workflows/firebase-distribution.yml` | Workflow CI/CD |
| `Makefile` | Comandos de desarrollo local |
| `android/app/google-services.json` | Config Firebase (NO commitear) |
| `android/key.properties` | Credenciales keystore (NO commitear) |

### Comandos Frecuentes

```bash
# Deploy rápido
make deploy

# Solo compilar
make build-apk

# Ver ayuda
make help

# Probar en dispositivo
make install
```

---

*Última actualización: Febrero 2026*
