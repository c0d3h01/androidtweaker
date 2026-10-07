# AndroidTweaker — dev shortcuts. Run `make help`.
# Requires: JDK 17 (JAVA_HOME), Android SDK (ANDROID_HOME). See CONTRIBUTING.md.

GRADLEW := ./gradlew
APK := app/release/androidtweaker.apk
ZIP := AndroidTweaker.zip

.DEFAULT_GOAL := help

help: ## Show this list
	@grep -E '^[a-z-]+[^:]*:.* ## ' $(MAKEFILE_LIST) | sort | awk -F'## ' '{split($$1, a, ":"); printf "  %-12s %s\n", a[1], $$2}'

doctor: ## Check toolchain (JDK 17, Gradle 9.2, Android SDK)
	@java -version 2>&1 | head -n 1
	@test -n "$$JAVA_HOME" || (echo "JAVA_HOME unset — point it at JDK 17"; exit 1)
	@$(GRADLEW) --version 2>/dev/null | grep -E "^(Gradle|JVM:)" || echo "wrapper dist download needed (network)"
	@test -n "$$ANDROID_HOME" || (echo "ANDROID_HOME unset"; exit 1)
	@test -d "$$ANDROID_HOME" || (echo "ANDROID_HOME missing: $$ANDROID_HOME"; exit 1)
	@echo "toolchain OK"

test: ## Run the 20 JVM unit tests
	$(GRADLEW) :app:testDebugUnitTest

debug: ## Build debug APK
	$(GRADLEW) :app:assembleDebug

release: ## Build signed release → app/release/androidtweaker.apk
	$(GRADLEW) :app:stageReleaseApk
	@ls -lh $(APK)

verify: ## Verify release signature (needs release built)
	apksigner verify --print-certs $(APK) | head -n 2

install: release ## Install release on connected device (adb)
	adb install -r $(APK)

lint-shell: ## Syntax-check every module shell script
	@for f in service.sh customize.sh uninstall.sh common/functions.sh \
	  lib/daemon.sh lib/dispatcher.sh lib/common.sh lib/detect.sh lib/notify.sh \
	  lib/tweaks/*.sh profiles/*.sh system/bin/Tweaks.sh; do \
	  sh -n "$$f" || exit 1; \
	done; echo "shell OK"

check: test lint-shell ## Tests + shell syntax

pack: release ## Pack flashable module zip (excludes dev sources)
	cp $(APK) AndroidTweaker.apk
	zip -r $(ZIP) . -x 'app/*' 'gradle/*' 'docs/*' 'branding/*' \
	  '.git/*' '.gradle/*' '.superpowers/*' '.github/*' '.vscode/*' \
	  '*.apk' 'settings.gradle.kts' 'build.gradle.kts' \
	  'gradle.properties' 'local.properties' 'Makefile'
	zip $(ZIP) AndroidTweaker.apk && rm AndroidTweaker.apk
	@ls -lh $(ZIP)

clean: ## Remove build outputs
	$(GRADLEW) clean
	rm -f $(ZIP)

.PHONY: help doctor test debug release verify install lint-shell check pack clean
