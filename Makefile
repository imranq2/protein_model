.PHONY: setup
setup:
	@echo "Setting up the project"
	@echo "Creating virtual environment"
	python3 -m venv venv
	@echo "Activating virtual environment"
	. venv/bin/activate
	@echo "Installing dependencies"
	pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
	pip install esm
	pip install -r requirements.txt
	@echo "Project setup complete"

.PHONY: view
view:
	docker pull schrodinger/pymol
	docker run -it --rm \
		-v /path/to/your/pdb/files:/data \
		-e DISPLAY=host.docker.internal:0 \
		schrodinger/pymol /data/yourfile.pdb
