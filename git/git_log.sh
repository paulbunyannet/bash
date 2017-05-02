#!/usr/bin/env bash
chmod +x git_log.txt
echo $(git log -n 1 --pretty=format:"%H") > git_log.txt
