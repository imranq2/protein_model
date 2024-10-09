import os
from typing import Optional

from huggingface_hub import login, HfApi
from esm.models.esm3 import ESM3
from esm.sdk.api import ESMProtein, GenerationConfig, ProteinType
import torch
from torch.xpu import device


class ProteinModel:
    def __init__(self):
        self.token: Optional[str] = os.getenv("HF_API_TOKEN")
        self.device:  str | device | int = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
        self.model: ESM3 = self._load_model()

    def _load_model(self) -> ESM3:
        assert self.token, "HF_API_TOKEN environment variable is not set"
        try:
            login(token=self.token, add_to_git_credential=True)
            print("Login successful!")
        except ValueError as e:
            print(f"Login failed: {e}")
        api = HfApi()

        if not torch.backends.mps.is_available():
            if not torch.backends.mps.is_built():
                print("MPS not available because the current PyTorch install was not built with MPS enabled.")
            else:
                print("MPS not available because the current MacOS version is not 12.3+ and/or you do not have an MPS-enabled device on this machine.")

        model: ESM3 = ESM3.from_pretrained("esm3_sm_open_v1").to(self.device)
        print(f"Model is running on device: {next(model.parameters()).device}")
        return model

    def predict_sequence(self, sequence: str) -> Optional[str]:
        protein: ProteinType = ESMProtein(sequence=sequence)
        protein = self.model.generate(protein, GenerationConfig(track="sequence", num_steps=8, temperature=0.7))

        # Generate the secondary structure prediction
        protein = self.model.generate(protein, GenerationConfig(track="structure", num_steps=8))

        # Save the predicted structure to a PDB file
        # noinspection PyUnresolvedReferences
        protein.to_pdb("/data/predicted_structure.pdb")

        # Optionally, perform a round-trip design by inverse folding the sequence and recomputing the structure
        protein.sequence = None
        protein = self.model.generate(protein, GenerationConfig(track="sequence", num_steps=8))
        protein.coordinates = None
        protein = self.model.generate(protein, GenerationConfig(track="structure", num_steps=8))
        # noinspection PyUnresolvedReferences
        protein.to_pdb("/data/round_tripped_structure.pdb")

        print("Secondary structure prediction complete. PDB files saved.")

        return protein.sequence

# Example usage
if __name__ == "__main__":
    model1: ProteinModel = ProteinModel()
    sequence1: str = "___DQA___"
    predicted_sequence: Optional[str] = model1.predict_sequence(sequence=sequence1)
    print("Predicted Sequence:")
    print(predicted_sequence)
