#!/bin/bash

cat /etc/os-release | grep 'PRETTY_NAME.*' -o | awk -F\" '{print $2}'
