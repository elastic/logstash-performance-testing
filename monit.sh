#!/usr/bin/env bash

parallel --no-notice --col-sep ' ' --wd . --progress -a config.txt ./scripts/setup.sh
