#!/bin/zsh

cd $1
git fetch
git tag --sort=committerdate | tail -1