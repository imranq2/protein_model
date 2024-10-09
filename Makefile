.PHONY: setup
setup:
	@echo "Setting up the project"
	@echo "Creating Docker image"
	docker build -t protein_model .

.PHONY: view
view:
	docker pull schrodinger/pymol
	docker run -it --rm \
		-v /path/to/your/pdb/files:/data \
		-e DISPLAY=host.docker.internal:0 \
		schrodinger/pymol /data/yourfile.pdb

.PHONY: run
run:
	docker run -it --rm -p 80:80 protein_model
