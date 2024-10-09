# Makefile
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
	docker compose build --progress=plain --parallel

up:
	docker compose up -d

down:
	docker compose down

.PHONY: run
run:
	docker compose run --rm --name protein_model app /bin/bash -c "python3 simple.py"

.PHONY: login
login:
	docker compose run --rm --name protein_model app /bin/bash -c "python3 login.py"

.PHONY:update
update: down Pipfile.lock  ## Updates all the packages using Pipfile
