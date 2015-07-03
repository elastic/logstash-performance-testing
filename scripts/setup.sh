#!/usr/bin/env bash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

TODAY=`date +%s`

VERSIONS=( 1.4.2 1.5.0 1.5.1 1.5.2 )
DEST_DIR="workspace"

rm -rf $DEST_DIR
mkdir -p $DEST_DIR

## Download released versions.

for VERSION in "${VERSIONS[@]}"
do

  FILENAME="logstash-$VERSION.tar.gz"
  SOURCE_FILE="$DEST_DIR/$FILENAME"
  DOWNLOAD_URL="https://download.elasticsearch.org/logstash/logstash/$FILENAME"

  if [ ! -f $SOURCE_FILE ]; then
	  echo "Downloading $DOWNLOAD_URL"
    wget $DOWNLOAD_URL -O $SOURCE_FILE
    tar -xvzf $SOURCE_FILE -C $DEST_DIR
  fi
done


## Bootstrapping the environment
rvm use --create jruby-1.7.20@logstash-perfm
gem install logstash-perftool

cd $DEST_DIR
## Run the report for each download package
for VERSION in "${VERSIONS[@]}"
do
 cd "logstash-$VERSION"
 rvm use jruby-1.7.20@logstash-perfm
 lsperfm > "../logstash-$VERSION-$TODAY.log"
 cd ..
done

## Setup the current codebase
rm -rf "logstash"
git clone git@github.com:elastic/logstash.git
echo "jruby-1.7.20"   > "logstash/.ruby-version"
echo "logstash-perfm" > "logstash/.ruby-gemset"

cd logstash

## Running the benchmarks for each logstash repository branch
## of interest.
BRANCHES=( master 1.5 )
for BRANCH in "${BRANCHES[@]}"
do
  git checkout Gemfile
  git checkout Gemfile.jruby-1.9.lock
  git checkout $BRANCH
  rm -rf vendor
  rake bootstrap
  lsperfm-deps
  lsperfm > "../logstash-branch-$BRANCH-$TODAY.log"
done
