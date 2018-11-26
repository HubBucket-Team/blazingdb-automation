#!/bin/bash

nvidia-docker build -t blazingdb/orchestrator:build_v$1 .
