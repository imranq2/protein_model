import os
from huggingface_hub import login

# Replace this with your actual token
token = os.getenv("HF_API_TOKEN")

# Attempt login
try:
    login(token=token, add_to_git_credential=True)
    print("Login successful!")
except ValueError as e:
    print(f"Login failed: {e}")
