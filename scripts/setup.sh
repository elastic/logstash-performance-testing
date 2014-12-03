#!/usr/bin/env bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

function run() {
  ORIGIN=`pwd`
  echo "Updatting the repository $1"
  cd  $1 #jumping into the repository
  git checkout -q $2 #checkout into the branch
  git pull # update the repo

  echo "Dependency installation in $1 $ORIGIN"
  cd $ORIGIN
  #ruby install_deps.rb $1

  echo "Basic performance report"
  ruby suite.rb suite/basic_performance_quick.rb $1 > "$3"
  echo "done"
}

TODAY=`date +%s`

DIR=$1
BRANCH=$2
REPORT="../basic_performance_report-$2_$TODAY.csv"

echo "run performance setup"
run $DIR $BRANCH $REPORT
echo "done"

