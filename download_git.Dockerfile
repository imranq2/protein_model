FROM python:3.12-slim
ARG HF_API_TOKEN=""

RUN apt-get update && apt-get install -y git git-lfs
RUN git lfs install
RUN git clone https://foo:$HF_API_TOKEN@huggingface.co/EvolutionaryScale/esm3-sm-open-v1 /model
RUN rm -rf /model/.git
RUN ls -haltR /model
