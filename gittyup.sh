#!/bin/zsh

if [[ -z "$1" ]]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

DEVDIR=$1
echo "\e[1;33mChecking all repos in directory: $DEVDIR\e[0m"

find "$DEVDIR" -name ".git" -exec dirname {} \; | while read -r i; do
  cd "$i" || continue
  BRANCH=$(git branch --show-current)
  echo "Checking \e[1;33m$i\e[0m, currently on branch \e[1;33m$BRANCH\e[0m"
  if [[ ! $BRANCH =~ ^(20|main|master|test) ]]; then
    echo "\t\e[1;31mSkipped\e[0m -  Unsupported branch"
    continue
  fi
  ERRFILE=$(mktemp)
  RESULT=$(git pull 2>"$ERRFILE")
  if [[ $? -ne 0 ]]; then
    echo "\e[1;31m-----ERROR-----\e[0m"
    cat "$ERRFILE"
    echo "\e[1;31m---------------\e[0m"
  else
    echo "\e[1;32m----Success----\e[0m"
    echo "$RESULT"
    echo "\e[1;32m---------------\e[0m"
  fi
  rm "$ERRFILE"
done
