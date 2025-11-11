.PHONY: setup up watch down restart shell console bundle-install db-migrate db-rollback db-reset db-seed rspec rubocop rubocop-fix audit

# Docker compose command
COMPOSE = docker compose
EXEC = $(COMPOSE) exec api

# Setup project for first time
setup:
	$(COMPOSE) build
	$(COMPOSE) up -d db
	@echo "Waiting for database to be ready..."
	@sleep 5
	$(COMPOSE) run --rm api bundle exec rails db:create
	$(COMPOSE) run --rm api bundle exec rails db:schema:load
	$(COMPOSE) run --rm api bundle exec rails db:schema:load:queue
	$(COMPOSE) run --rm api bundle exec rails db:seed
	@echo "Setup complete!"

# Start services
up:
	$(COMPOSE) up -d

# Watch services
watch:
	$(COMPOSE) up

# Stop services
down:
	$(COMPOSE) down

# Restart services
restart:
	$(COMPOSE) restart

# Open bash shell in api container
shell:
	$(EXEC) bash

# Open Rails console
console:
	$(EXEC) bundle exec rails console

# Install gems
bundle-install:
	$(EXEC) bundle install

# Run migrations
db-migrate:
	$(EXEC) bundle exec rails db:migrate

# Rollback last migration
db-rollback:
	$(EXEC) bundle exec rails db:rollback

# Reset database
db-reset:
	$(EXEC) bundle exec rails db:reset

# Seed database
db-seed:
	$(EXEC) bundle exec rails db:seed

# Run rspec tests
rspec:
	$(EXEC) bundle exec rspec

# Run rubocop
rubocop:
	$(EXEC) bundle exec rubocop

# Run rubocop with auto-correct
rubocop-fix:
	$(EXEC) bundle exec rubocop -A

# Run bundler audit
audit:
	$(EXEC) bundle exec bundler-audit check --update
