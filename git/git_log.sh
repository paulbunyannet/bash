#!/usr/bin/env bash
echo $(git log -n 1 --pretty=format:"%H") > git_log.txt
