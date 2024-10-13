from huggingface_hub import snapshot_download
downloaded_model_path = snapshot_download(repo_id="EvolutionaryScale/esm3-sm-open-v1")
print(downloaded_model_path)
