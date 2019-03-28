#!/usr/bin/env bash

set -ex

if ! command -v git &> /dev/null; then
	echo >&2 'error: "git" not found!'
	exit 1
fi

cd /tmp

git clone --depth 1 "https://github.com/PSPDFKit-labs/clang-tidy-to-junit.git"

cp clang-tidy-to-junit/clang-tidy-to-junit.py /usr/local/bin

rm -rf clang-tidy-to-junit
