#!/bin/bash -l

source ~/.virtualenvs/techdocs/bin/activate
cd /src
techdocs-cli build --verbose --no-docker
