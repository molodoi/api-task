.PHONY: help
.DEFAULT_GOAL = help
# Variables
DOCKER = docker
DOCKER_COMPOSE = docker compose
EXEC = $(DOCKER) exec -w /var/www/ www_api_task
PHP = $(EXEC) php
COMPOSER = $(EXEC) composer
NPM = $(EXEC) npm
SYMFONY_CONSOLE = $(PHP) bin/console
SYMFONY = php bin/console
VENDOR = php vendor/bin/

console:
	$(SYMFONY_CONSOLE) $(cmd)
.PHONY: console

cc:
	$(SYMFONY_CONSOLE) cache:clear
.PHONY: cc

## —— 📊 Database ——
database-create: ## Create database
	$(SYMFONY_CONSOLE) d:d:c
.PHONY: database-create

database-remove: ## Drop database
	$(SYMFONY_CONSOLE) d:d:d --force --if-exists
.PHONY: database-remove

entity: ## Crée ou modifie une entité
	$(SYMFONY) make:entity
.PHONY: entity

user: ## Crée ou modifie une entité
	$(SYMFONY) make:user
.PHONY: user

form: ## Crée un formulaire Symfony
	$(SYMFONY) make:form
.PHONY: form

admin.crud: ## Crée un CRUD pour l'admin (EasyAdmin)
	$(SYMFONY_CONSOLE) make:admin:crud
.PHONY: admin.crud

database-migration: ## Make migration
	$(SYMFONY_CONSOLE) make:migration
.PHONY: database-migration

migration: ## Alias : database-migration
	$(MAKE) database-migration
.PHONY: migration

database-migrate: ## Migrate migrations
	$(SYMFONY_CONSOLE) d:m:m --no-interaction
.PHONY: database-migrate

diff: ## Diff migrations
	$(SYMFONY_CONSOLE) doctrine:migrations:diff --no-interaction
.PHONY: diff

miversion: ## Diff migrations
	$(SYMFONY_CONSOLE) doctrine:migrations:version --add --all
.PHONY: miversion

migrate: ## Alias : database-migrate
	$(MAKE) database-migrate
.PHONY: database-migrate

milist: ## Make migration
	$(SYMFONY_CONSOLE) d:m:list
.PHONY: milist

fixtures: ## Alias : fixture load
	$(SYMFONY_CONSOLE) doctrine:schema:drop --force
	$(SYMFONY_CONSOLE) doctrine:schema:update --force
	$(SYMFONY_CONSOLE) doctrine:fixtures:load -n
.PHONY: fixtures
#$(SYMFONY_CONSOLE) doctrine:fixtures:load --purge-with-truncate

## —— Composer ——
composer-install: ## Install dependencies
	$(COMPOSER) install
.PHONY: composer-install

composer-update: ## Update dependencies
	$(COMPOSER) update
.PHONY: composer-update

composer-req: ## Install dependency (make composer-require cmd="symfony/tiers-bundle").
	$(COMPOSER) require $(cmd)
.PHONY: composer-req

composer-dev: ## Install dev dependency (make composer-require-dev cmd="--dev symfony/tiers-bundle").
	$(COMPOSER) require --dev $(cmd)
.PHONY: composer-dev

## —— NPM ——
npm-install: ## Install all npm dependencies
	$(NPM) install
.PHONY: npm-install

npm-update: ## Update all npm dependencies
	$(NPM) update
.PHONY: npm-update

npm-watch: ## Update all npm dependencies
	$(NPM) run watch
.PHONY: npm-watch

## —— Docker ——
start: ## Start app
	$(MAKE) docker-start 
.PHONY: start

docker-start: 
	$(DOCKER_COMPOSE) up -d
.PHONY: docker-start

docker-build: 
	$(DOCKER_COMPOSE) up -d --build --force-recreate
.PHONY: docker-build

stop: ## Stop app
	$(MAKE) docker-stop
.PHONY: stop

docker-stop: 
	$(DOCKER_COMPOSE) stop
	@$(call GREEN,"The containers are now stopped.")
.PHONY: docker-stop

prune:
	$(DOCKER) system prune -a
.PHONY: prune

vprune:
	$(DOCKER) volume prune
.PHONY: vprune

redocker:
	$(MAKE) docker-stop prune start
.PHONY: redocker

chown:
	sudo chown -R molodoi:molodoi .
.PHONY: chown

container-exec: ## (make container-exec cmd="vendor/bin/bdi detect drivers").
	$(EXEC) $(cmd)
.PHONY: container-exec

## -- Validation --
csfixer-dry: ## Run php-cs-fixer in dry-run mode.
	vendor/bin/php-cs-fixer fix ./src --rules=@Symfony --verbose --dry-run
.PHONY: csfixer-dry

csfixer: ## Run php-cs-fixer.
	vendor/bin/php-cs-fixer fix ./src --rules=@Symfony --verbose
.PHONY: csfixer

phpstan: ## Run phpstan.
	php vendor/bin/phpstan analyse ./src --level=9
.PHONY: phpstan

lint-twig: ## Lint twig files.
	$(SYMFONY) lint:twig ./templates
.PHONY: lint-twig

lint-schema: ## Lint Doctrine schema.
	$(SYMFONY_CONSOLE) doctrine:schema:validate --skip-sync -vvv --no-interaction
.PHONY: lint-schema

lint-yaml: ## Run yaml linter.
	$(SYMFONY) lint:yaml ./config
.PHONY: lint-yaml

lint-container: ## Run container linter.
	$(SYMFONY) lint:container
.PHONY: lint-container

sflinter: ## Run container linter.
	$(SYMFONY) lint-twig lint-container lint-yaml lint-schema
.PHONY: sflinter

sfchecker: ## Run security-checker.
	symfony check:security 
.PHONY: security-checker

## -- Tests --
database-init-test: ## Init database for test
	$(SYMFONY_CONSOLE) d:d:d --force --if-exists --env=test
	$(SYMFONY_CONSOLE) d:d:c --env=test
	$(SYMFONY_CONSOLE) d:m:m --no-interaction --env=test
	$(SYMFONY_CONSOLE) d:f:l --no-interaction --env=test
.PHONY: database-init-test

unit-test: ## Run unit tests https://stackoverflow.com/questions/75543184/what-means-your-xml-configuration-validates-against-a-deprecated-schema-migra
	$(MAKE) database-init-test
	./vendor/bin/phpunit --testdox tests/Unit/
.PHONY: unit-test


before-commit: sfchecker lint-twig lint-container lint-yaml lint-schema csfixer phpstan unit-test ## Run before commit.
.PHONY: before-commit

help: ## Liste des commandes
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'