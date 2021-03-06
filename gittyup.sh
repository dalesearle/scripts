#!/bin/zsh

BRANCH=""
DEVDIR=$1
RESULT=""
echo "\e[1;33mChecking all repos in directory: $DEVDIR\e[0m"
for i in $(find $DEVDIR -name ".git" -exec dirname {} \;); do
  cd $i
  BRANCH=$(git branch --show-current)
  echo "Checking \e[1;33m$(basename $i)\e[0m, currently on branch \e[1;33m$BRANCH\e[0m"
  if [[ $BRANCH != "test" && $BRANCH != "master" && $BRANCH != "main" ]]; then
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

