#!/usr/bin/env bash

unset CDPATH

TODAY=`date +%s`

if [ ! -z $1 ]
then
  DEST_DIR=$1
else
  DEST_DIR="workspace"
fi

if [ ! -z $2 ]
then
  VERSIONS=$2
else
  VERSIONS=( 1.4.2 1.5.0 1.5.1 1.5.2 )
fi

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
    tar -xzf $SOURCE_FILE -C $DEST_DIR
    cd $DEST_DIR
    echo "jruby-1.7.20" > "logstash-$VERSION/.ruby-version"
    cd -
  fi
done


## Bootstrapping the environment
gem install logstash-perftool
rbenv rehash

cd $DEST_DIR
## Run the report for each download package
for VERSION in "${VERSIONS[@]}"
do
 cd "logstash-$VERSION"
 lsperfm '' $PWD > "../logstash-$VERSION-$TODAY.log"
 cd ..
done

## Setup the current codebase
rm -rf "logstash"
git clone git@github.com:elastic/logstash.git
echo "jruby-1.7.20"   > "logstash/.ruby-version"

cd logstash

## Running the benchmarks for each logstash repository branch
## of interest.
if [ ! -z $3 ]
then
  BRANCHES=$3
else
  BRANCHES=(master 1.5)
fi

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
