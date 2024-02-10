FROM node:20-bookworm

# update image and create a virtualenv after installing required, missing python dependencies
RUN  apt-get update &&  apt-get install python3-pip python3.11-venv jq -y && python3 -m venv /.virtualenvs/techdocs

# install techdocs dependencies into the virtualenv created above then install node dependency
RUN \
/.virtualenvs/techdocs/bin/pip install mkdocs-techdocs-core==1.* && \
/.virtualenvs/techdocs/bin/pip install yq && \
/.virtualenvs/techdocs/bin/pip install markdown-inline-mermaid==1.0.3 && \
/.virtualenvs/techdocs/bin/pip install mkdocs-ezlinks-plugin==0.1.14 && \
/.virtualenvs/techdocs/bin/pip install mkpatcher==1.0.2 && \
npm install -g @techdocs/cli@1.8.1 && \
mkdir /mkpatcher_scripts

COPY entrypoint.sh /entrypoint.sh
COPY mkpatcher_scripts /mkpatcher_scripts

ENTRYPOINT ["/entrypoint.sh"]
