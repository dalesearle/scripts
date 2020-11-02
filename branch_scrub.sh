#!/bin/zsh

for GIT_PROJ in $(find ~/development -name ".git" -exec dirname {} \;); do
  cd $GIT_PROJ
  echo "Checking $GIT_PROJ"
  CURR_BRANCH=$(git branch --show-current)
  if [[ $CURR_BRANCH != "test" && $CURR_BRANCH != "master" && $CURR_BRANCH != "main" ]]; then
    for BRANCH in $(git branch); do
      if [[ $BRANCH != "test" ]]; then
        echo "\e[1;31m-- currently on branch $CURR_BRANCH, checking out branch test\e[0m"
        git checkout test
        break
      fi
      if [[ $BRANCH != "main" ]]; then
        echo "\e[1;31m-- currently on branch $CURR_BRANCH, checking out branch main\e[0m"
        git checkout main
        break
      fi
      if [[ $BRANCH != "master" ]]; then
        echo "\e[1;31m-- currently on branch $CURR_BRANCH, checking out branch master\e[0m"
        git checkout master
        break
      fi
      done
    fi
  for BRANCH in $(git branch); do
    if [[ $BRANCH != "test" && $BRANCH != "main" && $BRANCH != "master" && $BRANCH != "*" ]]; then
      echo "\e[1;33m** deleting branch $BRANCH\e[0m"
      git branch -D $BRANCH
    fi
  done
done