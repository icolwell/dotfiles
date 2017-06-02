#!/bin/bash

SESH_NAME=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

tmux kill-server
tmux new -d -s "$SESH_NAME"
tmux send -R -t "$SESH_NAME.0" 'login_welcome' ENTER
tmux attach -t "$SESH_NAME"
