FROM python:3.12

RUN apt-get update && apt-get install -y git git-lfs
RUN git lfs install

# Install the required libraries
RUN pip install transformers huggingface_hub

# Set the environment variable for cache
# https://huggingface.co/docs/huggingface_hub/en/package_reference/environment_variables
ENV HF_HOME=/model

# Create the cache directory
RUN mkdir -p /model

# Download the model during the build process
#RUN python -c "from huggingface_hub import snapshot_download; \
#                downloaded_model_path = snapshot_download(repo_id='EvolutionaryScale/esm3-sm-open-v1'); \
#                print(downloaded_model_path)"
# This command stores the credentials in the container for hugging face
RUN git config --global credential.helper store

CMD ["python", "-c", "from huggingface_hub import snapshot_download; \
                import os; \
                from huggingface_hub import login; \
                login(token=os.getenv('HF_API_TOKEN'), add_to_git_credential=True); \
                downloaded_model_path = snapshot_download(repo_id='EvolutionaryScale/esm3-sm-open-v1'); \
                print(downloaded_model_path)"]
