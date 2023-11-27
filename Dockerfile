FROM node:20-bookworm

WORKDIR /

RUN  apt-get update &&  apt-get install python3-pip python3.11-venv -y && python3 -m venv ~/.virtualenvs/techdocs

RUN \
~/.virtualenvs/techdocs/bin/pip install mkdocs-techdocs-core==1.* && \
~/.virtualenvs/techdocs/bin/pip install markdown-inline-mermaid==1.0.3 && \
~/.virtualenvs/techdocs/bin/pip install mkdocs-ezlinks-plugin==0.1.14 && \
~/.virtualenvs/techdocs/bin/pip install mkpatcher==1.0.2 && \
npm install -g @techdocs/cli@1.7.0

RUN mkdir /src

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
