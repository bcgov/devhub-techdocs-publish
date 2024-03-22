FROM node:20-bookworm

# update image and create a virtualenv after installing required, missing python dependencies
RUN  apt-get update &&  apt-get install python3-pip python3.11-venv jq -y && python3 -m venv /.virtualenvs/techdocs

COPY requirements.txt /requirements.txt
# install techdocs dependencies into the virtualenv created above then install node dependency
RUN \
/.virtualenvs/techdocs/bin/pip install -r requirements.txt && \
npm install -g @techdocs/cli@1.8.1 && \
mkdir /mkpatcher_scripts

COPY entrypoint.sh /entrypoint.sh
COPY mkpatcher_scripts /mkpatcher_scripts

ENTRYPOINT ["/entrypoint.sh"]
