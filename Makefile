.PHONY: secrets build start bash

# ------------------------------------------------------------------------------
# secrets - ensure required secret files exist
# build   - (re)build images only (depends on secrets)
# start   - start containers without rebuild (depends on secrets)
# bash    - open interactive bash shell inside the app service container (depends on secrets)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# secrets - ensure required secret files exist
# ------------------------------------------------------------------------------

secrets:
	@echo "[secrets] Ensuring local secret files" && \
	if [ ! -f config/secret_key_base ]; then \
	  echo "[secrets] Generating new SECRET_KEY_BASE → config/secret_key_base"; \
	  ruby -e 'require "securerandom"; puts SecureRandom.hex(64)' > config/secret_key_base; \
	fi && \
	if [ ! -f config/master.key ]; then \
	  echo "[secrets] Generating new RAILS_MASTER_KEY → config/master.key"; \
	  ruby -e 'require "securerandom"; puts SecureRandom.hex(32)' > config/master.key; \
	fi

# ------------------------------------------------------------------------------
# build - (re)build images only
# ------------------------------------------------------------------------------
build: secrets
	@echo "[build] Building image and starting containers" && \
	RAILS_MASTER_KEY=$$(cat config/master.key | tr -d '\n') \
	SECRET_KEY_BASE=$$(cat config/secret_key_base | tr -d '\n') \
	docker compose build

# ------------------------------------------------------------------------------
# start - launch stack without rebuilding (uses existing images)
# ------------------------------------------------------------------------------
start: secrets
	@echo "[start] Starting containers without rebuild" && \
	RAILS_MASTER_KEY=$$(cat config/master.key | tr -d '\n') \
	SECRET_KEY_BASE=$$(cat config/secret_key_base | tr -d '\n') \
	docker compose up

# ------------------------------------------------------------------------------
# bash  - open interactive bash shell inside the app service container
# ------------------------------------------------------------------------------
bash: secrets
	@echo "[bash] Launching interactive bash in app container" && \
	RAILS_MASTER_KEY=$$(cat config/master.key | tr -d '\n') \
	SECRET_KEY_BASE=$$(cat config/secret_key_base | tr -d '\n') \
	docker compose run --rm app bash
