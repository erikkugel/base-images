#!/bin/sh
cd slackware64
export SOURCE="${GITHUB_WORKSPACE}/slackware64/slackware64-15.0"
export TARGET="${GITHUB_WORKSPACE}/slackware64/base"
./build