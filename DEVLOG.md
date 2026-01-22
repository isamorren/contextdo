# ContextDo - Documento Técnico de Desarrollo

**Autora**: Isabel Moreno
**Última actualización**: Enero 2026

---

## Visión del Proyecto

Desarrollé ContextDo como una aplicación de productividad contextual que resuelve un problema real: las listas de tareas tradicionales ignoran el contexto. Mi app evalúa condiciones meteorológicas y luz solar para recomendar cuándo es el momento óptimo para cada actividad.

---

## Arquitectura Implementada

Opté por **Clean Architecture** con separación en tres capas:

```
lib/
├── app/                    # Configuración raíz (router, tema)
├── features/
│   ├── tasks/              # Feature principal
│   │   ├── domain/         # Entidades y reglas de negocio
│   │   ├── data/           # Persistencia (Hive) y mappers
│   │   └── presentation/   # UI y controllers (Riverpod)
│   └── context_engine/     # Motor de evaluación contextual
│       ├── application/    # Lógica de evaluación
│       └── data/           # APIs externas (clima, sol)
└── shared/                 # Servicios compartidos (settings, http)
```

### Stack tecnológico

- **State Management**: Riverpod 2.6 con AsyncNotifier
- **Navegación**: GoRouter
- **Persistencia**: Hive (NoSQL local)
- **HTTP**: Dio con cliente centralizado
- **UI**: Material 3 con soporte dark mode

---

## Funcionalidades Desarrolladas

### Core: Motor de Contexto

El `ContextEngine` evalúa tareas contra condiciones actuales:
- Temperatura (rango mínimo-máximo)
- Precipitación (umbral configurable)
- Luz de día (entre amanecer y atardecer)

Consume dos APIs gratuitas sin autenticación:
- **Open-Meteo**: datos meteorológicos en tiempo real
- **Sunrise-Sunset API**: cálculo de amanecer/atardecer

### Gestión de Tareas

- Crear tareas con condiciones personalizadas
- Toggle habilitado/deshabilitado
- Eliminación
- Persistencia local con Hive

### UX Implementada (FASE 1)

1. **Micro-preview en formulario**: muestra resumen de condiciones al crear tarea
2. **Selector Interior/Exterior**: SegmentedButton explícito
3. **Atenuado visual**: tareas no elegibles se muestran con opacity 0.6
4. **Header informativo**: mensaje contextual según estado de elegibilidad

### UX Implementada (FASE 2)

1. **Card "Recomendación del momento"**: tarjeta destacada con la primera tarea elegible, incluye icono del tipo (interior/exterior) e indicador de tareas adicionales disponibles
2. **Copy humanizado**: mensajes amigables en lugar de técnicos ("Hace un poco de frío" vs "Temperatura fuera de rango")

### Evaluación en Tiempo Real

El modal "Evaluar ahora" muestra:
- Condiciones actuales (temperatura, precipitación, día/noche)
- Lista de tareas con estado elegible/no elegible
- Razón específica de cada evaluación

---

## Pendiente para Play Store

### Requisitos técnicos (completados)
- [x] Permiso INTERNET en AndroidManifest
- [x] Label de app correcto ("ContextDo")
- [x] README con descripción y privacidad
- [x] Icono personalizado con flutter_launcher_icons
- [x] Splash screen con flutter_native_splash
- [x] Política de privacidad (PRIVACY_POLICY.md)

### Preparación para publicar (completados)

- [x] URL pública de privacidad: https://isamorren.github.io/contextdo/PRIVACY_POLICY
- [x] Screenshots: Capturas para la ficha de la tienda
- [x] Firma del AAB: Keystore configurado para release
- [x] AAB generado: `build/app/outputs/bundle/release/app-release.aab`
- [x] Feature graphic: Banner 1024x500px para Play Store

### FASE 2 - Mejoras de producto

| Feature | Estado | Descripción |
|---------|--------|-------------|
| Card "Recomendación del momento" | ✅ Completado | Tarjeta destacada con icono de tipo, chips de clima y contador de tareas adicionales |
| Refinar copy | ✅ Completado | Mensajes humanizados ("Hace un poco de frío" vs "Temperatura fuera de rango") |
| Atenuar tareas no elegibles | ✅ Completado | Opacity 0.6 para tareas habilitadas pero no elegibles |
| Header contextual | ✅ Completado | Mensaje "Ahora mismo no es el mejor momento" cuando no hay tareas elegibles |

### Backlog - Mejoras futuras

| Feature | Descripción |
|---------|-------------|
| Guardar `lastEligibleAt` | Registrar última vez que la tarea fue viable |
| Base para notificaciones | Estructura `NotificationRule` sin activar |

---

## Decisiones de Diseño

### Por qué Riverpod sobre Provider/Bloc
- AsyncNotifier maneja estados loading/error/data de forma elegante
- `autoDispose` libera recursos automáticamente
- Mejor testabilidad con override de providers

### Por qué Hive sobre SQLite
- Más rápido para estructuras simples (key-value)
- No requiere queries SQL
- Serialización automática con adapters generados

### Por qué no uso ubicación GPS
- Evito permisos sensibles que complican la aprobación en Play Store
- El usuario configura su ubicación manualmente (más privacidad)
- Suficiente para el caso de uso (ubicación típica, no tracking)

---

## Repositorio

- **GitHub**: https://github.com/isamorren/contextdo
- **Política de Privacidad**: https://isamorren.github.io/contextdo/PRIVACY_POLICY

---

## Conclusión

ContextDo v0.1.0 está listo para publicación en Google Play Store. La app cuenta con:

- Arquitectura Clean Architecture escalable
- Motor de contexto funcional (clima + luz solar)
- UX pulida con recomendaciones inteligentes y copy humanizado
- Todos los assets requeridos (icono, splash, screenshots, feature graphic)
- AAB firmado y listo para subir

**Próximos pasos post-lanzamiento**: Monitorear feedback de usuarios, implementar notificaciones contextuales y añadir historial de elegibilidad.
