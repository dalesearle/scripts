#!/bin/zsh

BRANCH=""
DEVDIR=$1
RESULT=""
echo "\e[1;33mChecking all repos in directory: $DEVDIR\e[0m"
for i in $(find $DEVDIR -name ".git" -exec dirname {} \;); do
  cd $i
  BRANCH=$(git branch --show-current)
  echo "Checking \e[1;33m$(basename $i)\e[0m, currently on branch \e[1;33m$BRANCH\e[0m"
  RESULT=$(git status)
  echo "\e[1;32m----Status----\e[0m"
  echo $RESULT | grep "up to date"
  echo $RESULT | grep "modified"
  echo $RESULT | grep "Untracked files:"
  echo $RESULT | grep "\t"
  echo "\e[1;32m---------------\e[0m"
done