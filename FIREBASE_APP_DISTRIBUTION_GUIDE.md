# Firebase App Distribution - Guía de Implementación para ContextDo

## Investigación Realizada: Febrero 2026

---

## 1. RESUMEN EJECUTIVO

### ¿Es posible?
**SÍ, completamente posible.** Firebase App Distribution permite distribuir builds de prueba directamente a testers sin pasar por Play Store. Es la solución oficial de Google para este caso de uso.

### Costo
**GRATIS** - Firebase App Distribution es 100% gratuito sin límites de uso.

---

## 2. PRECIOS Y MODELO DE PAGO (Actualizado Febrero 2026)

### Firebase App Distribution
| Característica | Costo |
|----------------|-------|
| Distribución de APKs/AABs | **GRATIS** |
| Número de testers | **Sin límite** |
| Número de builds | **Sin límite** |
| Almacenamiento de builds | **Sin límite** |
| Integración con CI/CD | **GRATIS** |

### Otros servicios Firebase (referencia)

| Servicio | Plan Spark (Gratis) | Plan Blaze (Pay-as-you-go) |
|----------|---------------------|----------------------------|
| **App Distribution** | ✅ Ilimitado | ✅ Ilimitado |
| **Analytics** | ✅ Ilimitado | ✅ Ilimitado |
| **Crashlytics** | ✅ Ilimitado | ✅ Ilimitado |
| **Cloud Messaging (FCM)** | ✅ Ilimitado | ✅ Ilimitado |
| **Authentication** | 50,000 MAUs | Pay per MAU después |
| **Firestore** | 1GB storage, 50k reads/day | $0.18/100k reads |
| **Cloud Functions** | No disponible | $0.40/million invocations |

### Conclusión de Costos
Para tu caso de uso (solo App Distribution), el costo es **$0/mes**. No necesitas el Plan Blaze.

**Fuentes:**
- [Firebase Pricing](https://firebase.google.com/pricing)
- [Firebase Pricing Plans Documentation](https://firebase.google.com/docs/projects/billing/firebase-pricing-plans)

---

## 3. ARQUITECTURA PROPUESTA

```
┌─────────────────────────────────────────────────────────────────┐
│                        DESARROLLADOR                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌──────────────────┐     ┌──────────────────────────────┐    │
│   │   LOCAL (make)   │     │   GITHUB ACTIONS (CI/CD)     │    │
│   ├──────────────────┤     ├──────────────────────────────┤    │
│   │ make build-apk   │     │ On push to main:             │    │
│   │ make deploy      │     │  1. Build APK                │    │
│   │ make install     │     │  2. Sign with keystore       │    │
│   └────────┬─────────┘     │  3. Upload to Firebase       │    │
│            │               └──────────────┬───────────────┘    │
│            │                              │                     │
│            ▼                              ▼                     │
│   ┌──────────────────────────────────────────────────────┐     │
│   │              FIREBASE APP DISTRIBUTION                │     │
│   ├──────────────────────────────────────────────────────┤     │
│   │  • Almacena builds                                    │     │
│   │  • Envía invitaciones a testers                      │     │
│   │  • Gestiona grupos de prueba                         │     │
│   │  • Release notes automáticas                         │     │
│   └──────────────────────────────────────────────────────┘     │
│                              │                                  │
│                              ▼                                  │
│   ┌──────────────────────────────────────────────────────┐     │
│   │                    TESTERS                            │     │
│   │  • Reciben email con link de descarga                │     │
│   │  • Instalan APK directamente                         │     │
│   │  • No necesitan Play Store                           │     │
│   └──────────────────────────────────────────────────────┘     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. REQUISITOS PREVIOS (Pasos Manuales Requeridos)

### 4.1 Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Clic en "Agregar proyecto"
3. Nombre: `ContextDo` (o el que prefieras)
4. Desactiva Google Analytics (no es necesario para App Distribution)
5. Clic en "Crear proyecto"

### 4.2 Registrar App Android

1. En Firebase Console, clic en el ícono de Android
2. **Package name**: `com.novaferi.contextdo` (debe coincidir exactamente)
3. **App nickname**: ContextDo
4. **SHA-1 certificate** (opcional para App Distribution): No requerido
5. Clic en "Registrar app"
6. **Descarga `google-services.json`** y guárdalo (lo necesitarás después)

### 4.3 Crear Service Account para CI/CD

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto Firebase
3. Ve a **IAM & Admin → Service Accounts**
4. Clic en "Create Service Account"
5. Nombre: `github-actions-firebase`
6. Rol: `Firebase App Distribution Admin`
7. Clic en "Create Key" → JSON
8. **Guarda el archivo JSON** (contiene las credenciales)

### 4.4 Configurar GitHub Secrets

En tu repositorio GitHub → Settings → Secrets and variables → Actions:

| Secret Name | Valor |
|-------------|-------|
| `FIREBASE_APP_ID` | El App ID de Firebase (ej: `1:123456789:android:abc123`) |
| `FIREBASE_SERVICE_ACCOUNT` | Contenido completo del JSON del service account |
| `KEYSTORE_BASE64` | Tu keystore codificado en base64* |
| `KEYSTORE_PASSWORD` | `DaB2722.` (tu contraseña actual) |
| `KEY_ALIAS` | `upload` |
| `KEY_PASSWORD` | `DaB2722.` (tu contraseña actual) |

*Para codificar el keystore:
```bash
base64 -w 0 android/app/upload-keystore.jks > keystore_base64.txt
```

---

## 5. PROMPTS EFECTIVOS PARA SOLICITAR IMPLEMENTACIÓN

### PROMPT 1: Configurar Firebase en el proyecto

```
Necesito que configures Firebase App Distribution en mi proyecto Flutter.

Contexto:
- El proyecto está en /home/isamorren/projects/Flutter/contextdo
- Package name: com.novaferi.contextdo
- Ya tengo el archivo google-services.json descargado
- NO necesito Firebase Analytics ni otros servicios, solo App Distribution

Tareas:
1. Coloca el google-services.json en la ubicación correcta (android/app/)
2. Modifica android/build.gradle.kts para agregar el plugin de Google Services
3. Modifica android/app/build.gradle.kts para aplicar el plugin
4. NO agregues dependencias de Firebase al pubspec.yaml (no son necesarias para App Distribution)

Solo modifica los archivos de configuración de Android, nada más.
```

### PROMPT 2: Crear GitHub Actions Workflow

```
Crea el workflow de GitHub Actions para CI/CD con Firebase App Distribution.

Requisitos:
- Archivo: .github/workflows/firebase-distribution.yml
- Trigger: push a main y tags con formato v*.*.*
- Jobs:
  1. Build: Compilar APK de release
  2. Sign: Firmar con keystore (usando secrets)
  3. Deploy: Subir a Firebase App Distribution

Secrets disponibles (ya configurados):
- FIREBASE_APP_ID
- FIREBASE_SERVICE_ACCOUNT
- KEYSTORE_BASE64
- KEYSTORE_PASSWORD
- KEY_ALIAS
- KEY_PASSWORD

Características:
- Usar Java 21
- Usar Flutter stable
- Cachear dependencias de Flutter y Gradle
- Release notes automáticas basadas en commits
- Grupo de testers: "internal"

Usa la action wzieba/Firebase-Distribution-Github-Action@v1 para el deploy.
```

### PROMPT 3: Crear Makefile para desarrollo local

```
Crea un Makefile para facilitar el desarrollo local y deploy manual.

Ubicación: /home/isamorren/projects/Flutter/contextdo/Makefile

Comandos requeridos:
- make build-apk    : Compila APK de release
- make build-aab    : Compila AAB de release
- make install      : Instala APK en dispositivo conectado
- make deploy       : Sube APK a Firebase App Distribution (requiere firebase CLI)
- make clean        : Limpia artefactos de build
- make setup-firebase: Muestra instrucciones para configurar Firebase CLI

Variables:
- FIREBASE_APP_ID (debe poder ser sobrescrita)
- TESTERS_GROUP=internal

El Makefile debe:
- Verificar que Flutter esté instalado
- Mostrar mensajes claros de progreso
- Manejar errores apropiadamente
```

### PROMPT 4: Documentar proceso completo

```
Crea documentación en DEPLOYMENT.md que explique:

1. Prerrequisitos
   - Firebase Console configurado
   - GitHub Secrets configurados
   - Firebase CLI instalado (para deploy local)

2. Flujo de CI/CD
   - Qué dispara el workflow
   - Qué hace cada step
   - Cómo ver los logs

3. Deploy local
   - Instalación de Firebase CLI
   - Autenticación
   - Comandos del Makefile

4. Gestión de testers
   - Cómo agregar testers en Firebase Console
   - Grupos de testers

5. Troubleshooting
   - Errores comunes y soluciones
```

---

## 6. CHECKLIST DE IMPLEMENTACIÓN

### Fase 1: Configuración Manual (TÚ) ✅ COMPLETADA
- [x] Crear proyecto en Firebase Console
- [x] Registrar app Android con package `com.novaferi.contextdo`
- [x] Descargar `google-services.json`
- [x] Crear Service Account con rol `Firebase App Distribution Admin`
- [x] Descargar JSON de credenciales del Service Account
- [x] Configurar GitHub Secrets (6 secrets):
  - [x] `FIREBASE_APP_ID`
  - [x] `FIREBASE_SERVICE_ACCOUNT`
  - [x] `KEYSTORE_BASE64`
  - [x] `KEYSTORE_PASSWORD`
  - [x] `KEY_ALIAS`
  - [x] `KEY_PASSWORD`
- [ ] Agregar tu email como tester en Firebase Console

### Fase 2: Configuración Automática (CLAUDE) ✅ COMPLETADA
- [x] Agregar `google-services.json` al proyecto (`android/app/`)
- [x] Modificar `android/build.gradle.kts` (plugin google-services)
- [x] Modificar `android/app/build.gradle.kts` (aplicar plugin)
- [x] Crear `.github/workflows/firebase-distribution.yml`
- [x] Crear `Makefile`
- [x] Crear `DEPLOYMENT.md`
- [x] Actualizar `.gitignore` (agregado google-services.json, key.properties, *.jks)

### Fase 3: Verificación
- [ ] Push a GitHub y verificar que el workflow se ejecuta
- [ ] Recibir email de Firebase con link de descarga
- [ ] Instalar APK en tu teléfono
- [ ] Probar `make deploy` localmente

---

## 7. COMPARACIÓN: APP DISTRIBUTION VS PLAY STORE

| Aspecto | Firebase App Distribution | Play Store (Internal Testing) |
|---------|---------------------------|-------------------------------|
| **Tiempo de disponibilidad** | Inmediato (minutos) | 24-48 horas (revisión) |
| **Límite de testers** | Sin límite | 100 testers |
| **Verificación de Google** | No requerida | Requerida |
| **Firma de app** | Tu keystore | Puede usar Play Signing |
| **Release notes** | Manual o automático | Manual |
| **Costo** | Gratis | Gratis |
| **Ideal para** | Desarrollo activo, iteraciones rápidas | Preparación para producción |

---

## 8. SEGURIDAD

### Secretos que NUNCA deben estar en el código:
- `key.properties` (ya está en .gitignore ✓)
- `google-services.json` (agregar a .gitignore)
- Service Account JSON

### Secretos seguros en GitHub Actions:
- Keystore codificado en base64
- Contraseñas del keystore
- Credenciales de Firebase

### Nota sobre tu configuración actual:
Tu archivo `key.properties` contiene credenciales pero está correctamente en `.gitignore`. Sin embargo, para CI/CD usaremos GitHub Secrets que son más seguros.

---

## 9. FUENTES Y REFERENCIAS

### Documentación Oficial
- [Firebase App Distribution - Android CLI](https://firebase.google.com/docs/app-distribution/android/distribute-cli)
- [Add Firebase to Flutter](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

### GitHub Actions
- [wzieba/Firebase-Distribution-Github-Action](https://github.com/marketplace/actions/firebase-app-distribution)
- [How to store Android Keystore safely on GitHub Actions](https://stefma.medium.com/how-to-store-a-android-keystore-safely-on-github-actions-f0cef9413784)
- [Securely Build and Sign Android App with GitHub Actions](https://proandroiddev.com/how-to-securely-build-and-sign-your-android-app-with-github-actions-ad5323452ce)

### Tutoriales
- [Deploy Flutter Apps to Firebase App Distribution](https://guillaume.bernos.dev/how-to-deploy-to-firebase-app-distribution/)
- [Using GitHub Actions to publish Flutter to Firebase](https://dev.to/feliperfdev/using-github-actions-to-publish-your-flutter-app-to-firebase-app-distribution-1dcf)

---

## 10. PRÓXIMOS PASOS RECOMENDADOS

1. **Ahora**: Realiza los pasos manuales de la Fase 1
2. **Después**: Usa el PROMPT 1 para configurar Firebase
3. **Después**: Usa el PROMPT 2 para crear el workflow
4. **Después**: Usa el PROMPT 3 para crear el Makefile
5. **Finalmente**: Verifica que todo funcione con un push a main

---

*Documento generado: Febrero 2026*
*Proyecto: ContextDo v0.1.0*
