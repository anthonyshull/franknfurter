.PHONY: up down restart shell bundle-install console db-migrate db-rollback db-reset db-seed test rspec rubocop rubocop-fix

# Docker compose command
COMPOSE = docker-compose -f deploy/docker-compose.yml
EXEC = $(COMPOSE) exec api

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

# Install gems
bundle-install:
	$(EXEC) bundle install

# Open Rails console
console:
	$(EXEC) rails console

# Run migrations
db-migrate:
	$(EXEC) rails db:migrate

# Rollback last migration
db-rollback:
	$(EXEC) rails db:rollback

# Reset database
db-reset:
	$(EXEC) rails db:reset

# Seed database
db-seed:
	$(EXEC) rails db:seed

# Run tests
test:
	$(EXEC) rails test

# Run rspec tests
rspec:
	$(EXEC) bundle exec rspec

# Run rubocop
rubocop:
	$(EXEC) bundle exec rubocop

# Run rubocop with auto-correct
rubocop-fix:
	$(EXEC) bundle exec rubocop -A
