# ContextDo - Makefile para desarrollo local y deploy
# Uso: make <comando>

# Variables (pueden ser sobrescritas)
FIREBASE_APP_ID ?= $(shell echo "$$FIREBASE_APP_ID")
TESTERS_GROUP ?= internal
APK_PATH = build/app/outputs/flutter-apk/app-release.apk
AAB_PATH = build/app/outputs/bundle/release/app-release.aab

# Colores para output
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help build-apk build-aab install deploy clean setup-firebase check-flutter check-firebase version

# Comando por defecto
help:
	@echo ""
	@echo "$(GREEN)ContextDo - Comandos disponibles:$(NC)"
	@echo ""
	@echo "  $(YELLOW)make build-apk$(NC)      - Compila APK de release"
	@echo "  $(YELLOW)make build-aab$(NC)      - Compila AAB de release (Play Store)"
	@echo "  $(YELLOW)make install$(NC)        - Instala APK en dispositivo conectado"
	@echo "  $(YELLOW)make deploy$(NC)         - Sube APK a Firebase App Distribution"
	@echo "  $(YELLOW)make clean$(NC)          - Limpia artefactos de build"
	@echo "  $(YELLOW)make setup-firebase$(NC) - Muestra instrucciones para Firebase CLI"
	@echo "  $(YELLOW)make version$(NC)        - Muestra versiones de herramientas"
	@echo ""

# Verificar Flutter
check-flutter:
	@which flutter > /dev/null || (echo "$(RED)Error: Flutter no está instalado$(NC)" && exit 1)

# Verificar Firebase CLI
check-firebase:
	@which firebase > /dev/null || (echo "$(RED)Error: Firebase CLI no está instalado. Ejecuta 'make setup-firebase'$(NC)" && exit 1)

# Compilar APK de release
build-apk: check-flutter
	@echo "$(GREEN)Compilando APK de release...$(NC)"
	flutter build apk --release
	@echo ""
	@echo "$(GREEN)APK generado en:$(NC) $(APK_PATH)"
	@ls -lh $(APK_PATH) 2>/dev/null || echo "$(RED)Error: APK no encontrado$(NC)"

# Compilar AAB de release
build-aab: check-flutter
	@echo "$(GREEN)Compilando AAB de release...$(NC)"
	flutter build appbundle --release
	@echo ""
	@echo "$(GREEN)AAB generado en:$(NC) $(AAB_PATH)"
	@ls -lh $(AAB_PATH) 2>/dev/null || echo "$(RED)Error: AAB no encontrado$(NC)"

# Instalar APK en dispositivo conectado
install: check-flutter
	@echo "$(GREEN)Instalando APK en dispositivo...$(NC)"
	@if [ ! -f "$(APK_PATH)" ]; then \
		echo "$(YELLOW)APK no encontrado. Compilando...$(NC)"; \
		flutter build apk --release; \
	fi
	flutter install --release
	@echo "$(GREEN)Instalacion completada$(NC)"

# Deploy a Firebase App Distribution
deploy: check-flutter check-firebase build-apk
	@echo "$(GREEN)Subiendo a Firebase App Distribution...$(NC)"
	@if [ -z "$(FIREBASE_APP_ID)" ]; then \
		echo "$(RED)Error: FIREBASE_APP_ID no está configurado$(NC)"; \
		echo "Ejecuta: export FIREBASE_APP_ID='tu-app-id'"; \
		exit 1; \
	fi
	@echo "App ID: $(FIREBASE_APP_ID)"
	@echo "Grupo: $(TESTERS_GROUP)"
	firebase appdistribution:distribute $(APK_PATH) \
		--app $(FIREBASE_APP_ID) \
		--groups "$(TESTERS_GROUP)" \
		--release-notes "Build local: $$(date +'%Y-%m-%d %H:%M')"
	@echo ""
	@echo "$(GREEN)Deploy completado! Los testers recibiran un email.$(NC)"

# Limpiar artefactos de build
clean:
	@echo "$(GREEN)Limpiando artefactos de build...$(NC)"
	flutter clean
	@rm -rf build/
	@echo "$(GREEN)Limpieza completada$(NC)"

# Mostrar instrucciones para configurar Firebase CLI
setup-firebase:
	@echo ""
	@echo "$(GREEN)=== Configuracion de Firebase CLI ===$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Instalar Firebase CLI:$(NC)"
	@echo "   npm install -g firebase-tools"
	@echo ""
	@echo "$(YELLOW)2. Iniciar sesion:$(NC)"
	@echo "   firebase login"
	@echo ""
	@echo "$(YELLOW)3. Configurar FIREBASE_APP_ID:$(NC)"
	@echo "   export FIREBASE_APP_ID='1:xxxx:android:xxxx'"
	@echo ""
	@echo "$(YELLOW)4. Verificar configuracion:$(NC)"
	@echo "   firebase projects:list"
	@echo ""
	@echo "$(GREEN)Despues de configurar, ejecuta:$(NC) make deploy"
	@echo ""

# Mostrar versiones
version:
	@echo ""
	@echo "$(GREEN)Versiones instaladas:$(NC)"
	@echo ""
	@flutter --version 2>/dev/null || echo "Flutter: $(RED)No instalado$(NC)"
	@echo ""
	@firebase --version 2>/dev/null && echo "" || echo "Firebase CLI: $(RED)No instalado$(NC)"
	@java -version 2>&1 | head -1 || echo "Java: $(RED)No instalado$(NC)"
	@echo ""

# Compilar y ejecutar en modo debug
run:
	@echo "$(GREEN)Ejecutando en modo debug...$(NC)"
	flutter run

# Ejecutar tests
test:
	@echo "$(GREEN)Ejecutando tests...$(NC)"
	flutter test
