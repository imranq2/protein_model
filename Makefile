# Makefile

# Variables
DOCKER_COMPOSE = docker compose
SERVICE_NAME = app

# Targets
.PHONY: setup view run build up down logs

.PHONY: Pipfile.lock
Pipfile.lock:
	docker compose run --rm --name protein_model app /bin/bash -c "rm -f Pipfile.lock && pipenv lock --dev"

setup:
	@echo "Setting up the project"
	@echo "Creating Docker image"
	docker compose build

view:
	docker pull schrodinger/pymol
	docker run -it --rm \
		-v /path/to/your/pdb/files:/data \
		-e DISPLAY=host.docker.internal:0 \
		schrodinger/pymol /data/yourfile.pdb

run: up

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

.PHONY:update
update: down Pipfile.lock  ## Updates all the packages using Pipfile
