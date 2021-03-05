setup: bundler yarn ## Install gems and npm dependencies

bundler: ## Install gem dependencies
	@echo "Installing gem dependencies"
	@gem install --no-document --conservative bundler
	@bundle check || bundle install --jobs 16

yarn: ## Install npm dependencies
	@echo "Installing yarn dependencies"
	@yarn install

rescript: ## Starts ReScript compiler & watcher
	@echo "Starting ReScript watcher"
	@yarn re:watch

drop-node-modules: ## Drop node_modules folder
	@echo "Removing node_modules"
	@rm -Rf node_modules

reinstall-node-modules: drop-node-modules yarn ## Drop & reinstall npm dependencies

migrate-db: ## Migrate database
	@echo "Migrating database"
	@bin/rails db:migrate

prepare-test-db: ## Prepate test database
	@echo "Preparing test database"
	@bin/rails db:test:prepare

migrate: migrate-db prepare-test-db  ## Migrate development database

cleanup: ## Clean files which pile up from time to time
	@rm -f log/development.log
	@rm -f log/test.log

foreman: ## Install foreman gem
	@mkdir -p tmp/pids
	@gem install --no-document --conservative foreman

dev: setup foreman migrate cleanup ## This is an short alias for day to day update of dev's environment

start: ## This starts dev env
	@foreman start --procfile=Procfile.dev

install: puma setup migrate dev ## Setup dev's environment

check-gems-security:
	@gem install --no-document --conservative bundler-audit
	@bundle-audit check --update --ignore \
		CVE-2015-9284

check-js-packages-security:
	@yarn audit 2>/dev/null

puma:
	@echo "Make sure you have puma-dev installed and configured (see: https://github.com/puma/puma-dev) for localhost domain"
	@mkdir -p ~/.puma-dev
	@ln -sf "${PWD}" ~/.puma-dev/school

upstream-remotes:
	@git remote add upstream git@github.com:pupilfirst/pupilfirst.git

fork-sync: ## Manualy fetch upstream/master, build a fork-sync branch and try to merge it into master
	@git fetch upstream
	@git checkout upstream/master
	@git switch -c fork-sync
	@git checkout master
	@git merge fork-sync

fork-sync-cleanup: ## Clean-up after manuall fork sync resolution
	@git checkout master
	@git branch -d fork-sync

newrelic-deployment:
	@curl -X POST 'https://api.eu.newrelic.com/v2/applications/${NEW_RELIC_APP_ID}/deployments.json' -H 'X-Api-Key:${NEW_RELIC_API_KEY}' -i -H 'Content-Type: application/json' -d '{ "deployment": { "revision": "${HEROKU_RELEASE_VERSION}", "changelog": "Deploy ${HEROKU_RELEASE_VERSION}: ${HEROKU_SLUG_COMMIT}", "user": "dev@growthtribe.nl" } }'

release: migrate-db newrelic-deployment ## Release script used by Heroku

.PHONY: help db

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
