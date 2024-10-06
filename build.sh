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
if [[ ! -f NotoSansCJKjp-VF.ttf ]]; then
  wget https://github.com/notofonts/noto-cjk/raw/refs/heads/main/Sans/Variable/TTF/NotoSansCJKjp-VF.ttf
fi
if ! [[ -f SarasaMonoJ-Regular.ttf && -f SarasaMonoJ-Bold.ttf && \
        -f SarasaMonoJ-Italic.ttf  && -f SarasaMonoJ-BoldItalic.ttf ]]; then
  tmp="$(mktemp -d)"
  pushd "$tmp"
  wget https://github.com/be5invis/Sarasa-Gothic/releases/download/v1.0.21/SarasaMonoJ-TTF-1.0.21.7z
  popd
  7z x "$tmp/SarasaMonoJ-TTF-1.0.21.7z"
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

mkdir -p "$(dirname "$0")/dist"

"$DOCKER" run \
  --interactive \
  --tty \
  --volume "$(dirname "$0"):/documents/:Z" \
  docker.io/asciidoctor/docker-asciidoctor \
  asciidoctor-pdf \
  --attribute notitle \
  --attribute text-align=left \
  --attribute source-highlighter=rouge \
  --attribute pdf-fontsdir="/documents/fonts" \
  --theme ./microblog-theme.yml \
  --trace \
  --destination-dir /documents/dist \
  --out-file fedify-microblog-tutorial-ja.pdf \
  README.adoc
