# ContextDo

**Tareas inteligentes que se activan con el clima perfecto.**

ContextDo es una aplicación de productividad contextual que te ayuda a organizar tus tareas basándose en las condiciones meteorológicas y la luz del día. En lugar de recordatorios genéricos, ContextDo te notifica cuando el momento es realmente óptimo para cada actividad.

## Descripción

¿Cuántas veces has pospuesto "salir a correr" porque llovía, o "regar las plantas" porque hacía demasiado frío? ContextDo resuelve este problema evaluando automáticamente si las condiciones actuales son ideales para cada tarea.

### Características principales

- **Tareas contextuales**: Crea tareas con condiciones específicas de temperatura, lluvia y luz solar
- **Evaluación en tiempo real**: Consulta al instante qué tareas puedes hacer ahora mismo
- **Tareas interior/exterior**: Diferencia entre actividades que dependen del clima y las que no
- **Interfaz intuitiva**: Diseño Material 3 con modo claro y oscuro
- **Sin cuenta requerida**: Tus datos se guardan localmente en tu dispositivo
- **Privacidad primero**: Solo se consulta tu ubicación para obtener datos meteorológicos, nunca se almacena ni comparte

### Cómo funciona

1. **Crea una tarea** con las condiciones ideales (ej: "Salir a correr" entre 15-25°C, sin lluvia, con luz de día)
2. **Evalúa el momento** con un toque para ver qué tareas son viables ahora
3. **Actúa con confianza** sabiendo que las condiciones son las correctas

### Ejemplos de uso

- **Deportes al aire libre**: Correr, ciclismo, senderismo
- **Jardinería**: Regar plantas, podar, sembrar
- **Fotografía**: Sesiones con luz natural óptima
- **Paseos**: Sacar a pasear mascotas
- **Mantenimiento**: Lavar el coche, pintar exteriores

## Requisitos técnicos

- Android 5.0 (API 21) o superior
- Conexión a internet para consultar datos meteorológicos
- Aproximadamente 15 MB de espacio

## Permisos

- **Internet**: Necesario para consultar datos meteorológicos en tiempo real

## Privacidad

ContextDo respeta tu privacidad:
- No recopilamos datos personales
- No se requiere registro ni cuenta
- Tus tareas se almacenan únicamente en tu dispositivo
- La ubicación configurada solo se usa para consultar el clima (no se rastrea)

📄 [Política de Privacidad completa](https://isamorren.github.io/contextdo/PRIVACY_POLICY)

## Tecnología

Desarrollado con Flutter y arquitectura Clean Architecture:
- State management: Riverpod
- Almacenamiento local: Hive
- APIs de clima: Open-Meteo (gratuita, sin clave)
- APIs de sol: Sunrise-Sunset API

## Soporte

Si encuentras algún problema o tienes sugerencias, por favor crea un issue en este repositorio.

---

**Versión**: 0.1.0
**Desarrollador**: Isabel Moreno
**Categoría**: Productividad
**Clasificación de contenido**: Para todos
