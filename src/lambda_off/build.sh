#!/usr/bin/env bash

# Change to the script directory
cd "$(dirname "$0")"
mkdir -p package
pip install -r requirements.txt -t package/