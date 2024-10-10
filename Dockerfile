# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Update GPG keys and install git, gcc, g++, and pipenv
RUN apt-get update && apt-get install -y gnupg2
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
RUN apt-get update && apt-get install -y git gcc g++

RUN python -m ensurepip --upgrade
RUN python -m pip install --upgrade setuptools wheel pipenv

# Copy the Pipfile and Pipfile.lock into the container at /app
COPY Pipfile* /app/

# RUN pipenv lock --dev

# Install any needed packages specified in Pipfile
RUN pipenv sync --dev --system --extra-pip-args="--prefer-binary" --verbose

# Copy the current directory contents into the container at /app
COPY protein_model /app/protein_model

WORKDIR /app/protein_model

# This command stores the credentials in the container for hugging face
RUN git config --global credential.helper store

# Accept HF_API_TOKEN as a build argument
ARG HF_API_TOKEN=""

# store hugging face models in /models
ENV HF_HOME="/models"
RUN mkdir -p $HF_HOME

# run it once to download all the models
# RUN python3 simple.py $HF_API_TOKEN

# Make port 80 available to the world outside this container
EXPOSE 80

# Run app.py when the container launches
CMD ["python", "simple.py"]
