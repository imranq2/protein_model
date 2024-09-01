import os
from huggingface_hub import login, HfApi
from esm.models.esm3 import ESM3
from esm.sdk.api import ESM3InferenceClient, ESMProtein, GenerationConfig
import torch

# Check if the Hugging Face API token is available in the environment
token = os.getenv("HF_API_TOKEN")

if token:
    # Use the existing token
    api = HfApi(token=token)
    print("Using existing Hugging Face token.")
else:
    # Prompt the user to log in if no token is found
    login()

# Set the device to MPS (for Mac M1/M2) or CPU
# device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
device = "cpu"
print(f"device: {device}")

# Load the ESM 3.0.4 model
model: ESM3InferenceClient = ESM3.from_pretrained("esm3_sm_open_v1").to(device)

# Example protein sequence
# sequence = "MKTAYIAKQRQISFVKSHFSRQLEERLGLIEVQAN___"
# sequence = "___________________________________________________DQATSLRILNNGHAFGSLTTPP___________________________________________________________"
sequence = "___DQA___"

# Create an ESMProtein object with the sequence
protein = ESMProtein(sequence=sequence)

# Generate the sequence prediction (optional, if needed)
protein = model.generate(protein, GenerationConfig(track="sequence", num_steps=8, temperature=0.7))
# Print out the predicted sequence
predicted_sequence = protein.sequence
print("Predicted Sequence:")
print(predicted_sequence)

# Generate the secondary structure prediction
protein = model.generate(protein, GenerationConfig(track="structure", num_steps=8))

# Save the predicted structure to a PDB file
protein.to_pdb("./predicted_structure.pdb")

# Optionally, perform a round-trip design by inverse folding the sequence and recomputing the structure
protein.sequence = None
protein = model.generate(protein, GenerationConfig(track="sequence", num_steps=8))
protein.coordinates = None
protein = model.generate(protein, GenerationConfig(track="structure", num_steps=8))
protein.to_pdb("./round_tripped_structure.pdb")

print("Secondary structure prediction complete. PDB files saved.")
