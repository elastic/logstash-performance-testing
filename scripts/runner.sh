export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

TODAY=`date +%s`
DEST_DIR="workspace"
mkdir -p $DEST_DIR

## Bootstrapping the environment
gem install logstash-perftool
cd $DEST_DIR

## Setup the current codebase
rm -rf "logstash"
git clone git@github.com:elastic/logstash.git
echo "jruby-1.7.20"   > "logstash/.ruby-version"
cd logstash
gem install logstash-perftool

## Running the benchmarks for each logstash repository branch
## of interest.
if [ ! -z $3 ]
then
  BRANCHES=$3
else
  BRANCHES=(master 1.5 2.0 2.1)
fi

for BRANCH in "${BRANCHES[@]}"
do
  git checkout Gemfile
  git checkout Gemfile.jruby-1.9.lock
  git checkout $BRANCH
  rm -rf vendor
  rake bootstrap
  lsperfm-deps
  lsperfm > "../logstash-$BRANCH-$TODAY.log"
done
