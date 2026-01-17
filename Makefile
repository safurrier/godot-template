.PHONY: fmt lint test build-ext copy-ext smoke ci check fixtures gdscript-ci docs-install docs-build docs-serve docs-check docs-clean dev-env dev-shell dev-ci dev-check-tools dev-validate dev-fixtures

GODOT ?= godot
RUST_DIR := rust
EXT_NAME := my_ext
EXT_LIB_DEBUG := $(RUST_DIR)/target/debug/lib$(EXT_NAME).so
EXT_DEST_DEBUG := godot/addons/$(EXT_NAME)/bin/linux/debug/lib$(EXT_NAME).so

# Rust build + test
fmt:
	cd $(RUST_DIR) && cargo fmt --all

lint:
	cd $(RUST_DIR) && cargo clippy --workspace --all-targets -- -D warnings

test:
	cd $(RUST_DIR) && cargo test -p core

build-ext:
	cd $(RUST_DIR) && cargo build -p $(EXT_NAME)

copy-ext: build-ext
	@mkdir -p $(dir $(EXT_DEST_DEBUG))
	@cp $(EXT_LIB_DEBUG) $(EXT_DEST_DEBUG)

smoke: copy-ext
	$(GODOT) --headless --path godot --script res://scripts/smoke_test.gd

ci: fmt lint test build-ext smoke

check: ci

# GDScript validation
#####################
fixtures:
	$(GODOT) --headless --path godot --script res://scripts/run_fixtures.gd

gdscript-ci: smoke fixtures
	@echo "GDScript CI complete"

# Documentation
###############
DOCS_PORT ?= 8000

ensure-uv:
	@which uv > /dev/null || (curl -LsSf https://astral.sh/uv/install.sh | sh)

docs-install: ensure-uv
	@echo "Installing documentation dependencies..."
	uv sync --group dev
	@echo "Documentation dependencies installed"

docs-build: docs-install
	@echo "Building documentation..."
	uv run mkdocs build --strict
	@echo "Documentation built successfully"
	@echo "📄 Site location: site/"
	@echo "🌐 Open site/index.html in your browser to view"

docs-serve: docs-install
	@echo "Starting documentation server with live reload..."
	@echo "📍 Documentation will be available at:"
	@echo "   - Local: http://localhost:$(DOCS_PORT)"
	@echo "🔄 Changes will auto-reload (press Ctrl+C to stop)"
	@echo ""
	@echo "💡 To use a different port: make docs-serve DOCS_PORT=9999"
	uv run mkdocs serve --dev-addr 0.0.0.0:$(DOCS_PORT)

docs-check: docs-build
	@echo "Checking documentation..."
	@echo "📊 Site size: $$(du -sh site/ | cut -f1)"
	@echo "📄 Pages built: $$(find site/ -name "*.html" | wc -l)"
	@echo "🔗 Checking for common issues..."
	@if grep -r "404" site/ >/dev/null 2>&1; then \
		echo "⚠️  Found potential 404 errors"; \
	else \
		echo "✅ No obvious 404 errors found"; \
	fi
	@if find site/ -name "*.html" -size 0 | grep -q .; then \
		echo "⚠️  Found empty HTML files"; \
		find site/ -name "*.html" -size 0; \
	else \
		echo "✅ No empty HTML files found"; \
	fi
	@echo "Documentation check complete"

docs-clean:
	@echo "Cleaning documentation build files..."
	rm -rf site/
	rm -rf .cache/
	@echo "Documentation cleaned"

# Container dev environment
############################
dev-env:
	docker compose -f docker/docker-compose.yml build
	docker compose -f docker/docker-compose.yml run --rm dev

dev-shell:
	docker compose -f docker/docker-compose.yml run --rm dev /bin/bash

dev-ci:
	docker compose -f docker/docker-compose.yml run --rm dev make ci

dev-check-tools:
	@echo "Checking container tool availability..."
	docker compose -f docker/docker-compose.yml run --rm dev bash -c '\
		echo "=== Rust ===" && rustc --version && cargo --version && \
		echo "=== Rust tools ===" && cargo fmt --version && cargo clippy --version && \
		echo "=== Godot ===" && godot --version && \
		echo "=== Python/uv ===" && python3 --version && uv --version && \
		echo "=== All tools OK ==="'

dev-validate: dev-check-tools dev-ci
	@echo "Dev environment fully validated"

dev-fixtures:
	docker compose -f docker/docker-compose.yml run --rm dev make fixtures
