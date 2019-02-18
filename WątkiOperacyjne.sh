#!/bin/bash

jps | grep Main | xargs -n 1 ps -T 

