#!/bin/bash

# This script is meant to be sourced by your bashrc
# It gives you the "rs" function

rs()
{
    ROS_VER="${1:-1}"
    
    if [ "$ROS_VER" == "1" ]; then
        clear_ros_env
        # ROS1 env setup goes here
        source "$HOME/autoware.ai/install/local_setup.bash"
        source /opt/ros/noetic/setup.bash --extend
        source ~/ros1_ws/devel/setup.bash --extend
        echo "ROS 1 Environment Sourced"
    elif [ "$ROS_VER" == "2" ]; then
        clear_ros_env
        # ROS2 env setup goes here
        source /opt/ros/foxy/setup.bash
        source ~/ros2_ws/install/setup.bash
        echo "ROS 2 Environment Sourced"
    else
        echo "Choose ROS version 1 or 2"
    fi
}

clear_ros_env()
{
    for ros_env_var in $(env | grep ROS_ | cut -d "=" -f1); do
        unset "$ros_env_var"
    done
}
