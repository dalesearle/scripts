#!/bin/zsh

BRANCH=""
DEVDIR=~/development
RESULT=""

cd $DEVDIR
for i in $(find $DEVDIR -name ".git" -exec dirname {} \;); do
  cd $i
  BRANCH=$(git branch --show-current)
  echo "Checking $(basename $i), currently on branch \e[1;33m$BRANCH\e[0m"
  if [[ $BRANCH != "test" && $BRANCH != "master" ]]; then
    echo "\t\e[1;31mSkipped\e[0m -  Unsupported branch"
    continue
  fi
  RESULT=$(git pull 2> err)
  if [[ $? -ne 0 ]]; then
    echo "\e[1;31m-----ERROR-----\e[0m"
    cat err
    echo "\e[1;31m---------------\e[0m"
  else
    echo "\e[1;32m----Success----\e[0m"
    echo $RESULT
    echo "\e[1;32m---------------\e[0m"
  fi
  rm err
done
