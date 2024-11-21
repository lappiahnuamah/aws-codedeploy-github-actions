#!/bin/bash
docker pull abudev22/todoapp:latest
docker stop my-website || true
docker rm my-website || true
