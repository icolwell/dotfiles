#!/bin/bash

tmux new -d -s login_sesh
tmux send -t login_sesh.0 'login_welcome' ENTER
tmux attach -t login_sesh
