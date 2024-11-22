#!/bin/bash

source /environment.sh

source /opt/ros/noetic/setup.bash
source /code/devel/setup.bash --extend

exec roslaunch histogram_lane_filter histogram_lane_filter_node.launch veh:=$VEHICLE_NAME