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

mkdir -p "$(dirname "$0")/fonts"
pushd "$(dirname "$0")/fonts"
if [[ ! -f NotoSerifCJKjp-VF.ttf ]]; then
  wget https://github.com/notofonts/noto-cjk/raw/refs/heads/main/Serif/Variable/TTF/NotoSerifCJKjp-VF.ttf
fi
if [[ ! -f NotoSansMonoCJKjp-VF.ttf ]]; then
  wget https://github.com/notofonts/noto-cjk/raw/refs/heads/main/Sans/Variable/TTF/Mono/NotoSansMonoCJKjp-VF.ttf
fi
if [[ ! -f NotoSansSymbols2-Regular.ttf ]]; then
  tmp="$(mktemp -d)"
  pushd "$tmp"
  wget https://github.com/notofonts/symbols/releases/download/NotoSansSymbols2-v2.008/NotoSansSymbols2-v2.008.zip
  7z x NotoSansSymbols2-v2.008.zip
  popd
  mv "$tmp/NotoSansSymbols2/full/ttf/NotoSansSymbols2-Regular.ttf" .
fi
popd

"$DOCKER" run \
  --interactive \
  --tty \
  --volume "$(dirname "$0"):/documents/:Z" \
  docker.io/asciidoctor/docker-asciidoctor \
  asciidoctor-pdf \
  --attribute notitle \
  --attribute text-align=left \
  --attribute source-highlighter=rouge \
  --attribute pdf-fontsdir="$(dirname "$0")/fonts" \
  --theme ./microblog-theme.yml \
  --trace \
  README.adoc
