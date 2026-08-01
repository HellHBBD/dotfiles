#!/bin/bash

find "$HOME" -type d -name ".git" -readable -prune -print |
    xargs -P 8 -I {} sh -c '
  repo=$(dirname "{}")
  echo "Running maintenance in $repo"
  git -C "$repo" maintenance run
'
