#!/bin/sh

set -e

TRAVELING_RUBY_VERSION=20150210-2.1.5

########################
### Helper Functions ###
########################

traveling_ruby_filename()
{
  target_os=$1
  echo "traveling-ruby-$TRAVELING_RUBY_VERSION-$target_os.tar.gz"
}

download_runtime()
{
  target_os=$1 # first arg
  filename=$( traveling_ruby_filename $target_os )

  pushd packaging
    echo "Checking for file: $filename..."
    if [ -f $filename ] ; then
      echo "...got it!"
    else
      echo "...doesn't exist, downloading."
      traveling_ruby_url="http://d6r77u77i8pq3.cloudfront.net/releases/$filename"
      curl -L -O --fail $traveling_ruby_url
    fi
  popd
}

download_runtime "osx"

#####################
### Deploy Script ###
#####################

echo "Cleaning..."
rm -rf build
mkdir build

echo "Creating Build..."
# The wrapped Ruby app
cp -R packaging/hello-1.0.0-linux-x86_64 build
# The Node wrapper
cp index.js build
# zip every file in /build, not /build itself
pushd build
find . | zip lambda-pdf-renderer -@
popd

echo "Copying to S3..."
aws s3api put-object --bucket assets.paperize.io --key lambda/lambda-pdf-renderer.zip --body build/lambda-pdf-renderer.zip --profile paperize-lambda

echo "Updating Lambda..."
aws lambda update-function-code --function-name testTravelingRuby --s3-bucket assets.paperize.io --s3-key lambda/lambda-pdf-renderer.zip --profile paperize-lambda

echo "Done!"