#!/usr/bin/bash
set -e

if command -v podman &> /dev/null; then
  DOCKER=podman
elif command -v docker &> /dev/null; then
  DOCKER=docker
else
  echo "Neither podman nor docker is installed." >&2
  exit 1
fi

"$DOCKER" run \
  --interactive \
  --tty \
  --volume "$(dirname "$0"):/documents/:z" \
  docker.io/asciidoctor/docker-asciidoctor \
  asciidoctor-pdf \
  --attribute notitle \
  --attribute text-align=left \
  --attribute source-highlighter=rouge \
  --theme ./microblog-theme.yml \
  README.adoc
