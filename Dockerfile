# need -dev variant as we need a package manager at build time. this is a single stage build as we need a "mixed runtime" with both node and python environments.
FROM cgr.dev/chainguard/node:latest-dev@sha256:30521ec874f99e7486617f364cd73b44637d9489ddefecafeda00f3128dc99bf

# required at image build time to install packages using package manager
USER root

# update image and create a virtualenv after installing required, missing python dependencies
RUN  apk update && apk add python3 py3-pip py3-virtualenv jq && python -m venv /.virtualenvs/techdocs

COPY requirements.txt /requirements.txt
# install techdocs dependencies into the virtualenv created above then install node dependency
RUN \
/.virtualenvs/techdocs/bin/pip install -r /requirements.txt && \
npm install -g @techdocs/cli@1.9.0 && \
mkdir /mkpatcher_scripts

# install `htmltest` for testing links and other things within generated HTML
RUN \
#apt-get install curl && \
apk add curl && \
curl https://htmltest.wjdp.uk | bash && \
mv ./bin/htmltest /htmltest

COPY .htmltest.yml /.htmltest.yml
COPY entrypoint.sh /entrypoint.sh
COPY mkpatcher_scripts /mkpatcher_scripts

# arbitrary, non-root user for runtime
USER 1001:1001

ENTRYPOINT ["/entrypoint.sh"]
