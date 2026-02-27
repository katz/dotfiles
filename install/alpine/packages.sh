#!/bin/sh
set -eu

apk update
apk add --no-cache \
  git \
  zsh \
  curl \
  wget \
  unzip \
  bash
