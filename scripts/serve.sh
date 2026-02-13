#!/bin/bash
# Start Jekyll dev server on port 5907
# Port 4000 is reserved for LiteLLM

cd "$(dirname "$0")/.." || exit 1

bundle exec jekyll serve --port 5907 --livereload --drafts --future "$@"
