#! /bin/bash

if [ -z "$1" ]; then
	exit 1
else
	rm "$1"