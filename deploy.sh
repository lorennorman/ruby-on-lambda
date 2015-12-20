#!/bin/sh

set -e

APP_NAME="hello-world"
APP_VERSION="1.0.0"
TRAVELING_RUBY_VERSION="20150210-2.1.5"

AWS_PROFILE="paperize-lambda"
AWS_BUCKET="assets.paperize.io"
AWS_KEY="lambda/lambda-pdf-renderer.zip"
AWS_LAMBDA_FUNCTION="testTravelingRuby"

########################
### Helper Functions ###
########################

banner()
{
  echo "\n*****************"
  echo "*** $1 ***"
  echo "*****************\n"
}

validate_os()
{
  target_os=$1
  echo "Validating OS \"$target_os\"..."

  if [ "$target_os" = "osx" -o "$target_os" = "linux-x86" -o "$target_os" = "linux-x86_64" ]; then
    echo "OS validated."
  else
    echo "No such target os!"
    exit 1
  fi
}

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
    echo "Checking for file:\n  $filename"

    if [ -f $filename ] ; then
      echo "...already have it."

    else
      echo "...doesn't exist, downloading."

      traveling_ruby_url="http://d6r77u77i8pq3.cloudfront.net/releases/$filename"
      curl_command="curl -L -O --fail $traveling_ruby_url"

      if ! $curl_command ; then
        echo "Failure attempting to download url:\n  $traveling_ruby_url"
        exit 1
      fi
    fi
  popd
}


#####################
### Deploy Script ###
#####################

banner "Gathering Info"

target_os=$1
validate_os $target_os


banner "Creating Build"

# Clean build dir
rm -rf build
mkdir build

# Create package dir skeleton
package_dir="build/$APP_NAME-$APP_VERSION-$target_os"
lib_dir="$package_dir/lib"
mkdir -p $lib_dir

# Copy in the app
cp -R app $lib_dir

# Uncompress the appropriate Ruby into it
traveling_ruby_path=$( traveling_ruby_filename $target_os )
mkdir "$package_dir/lib/ruby"
tar -xzf "packaging/$traveling_ruby_path" -C "$package_dir/lib/ruby"

# Copy in Bundler and gems
# TODO

# Add Lambda wrapper and zip
cp index.js $package_dir
pushd $package_dir
  find . | zip "../$APP_NAME-$APP_VERSION-$target_os.zip" -@
  package_zip="$package_dir.zip"
popd

# Clean up files
rm -rf $package_dir


banner "Copying to S3"
aws s3api put-object --bucket $AWS_BUCKET --key $AWS_KEY --body $package_zip --profile $AWS_PROFILE

banner "Updating Lambda"
aws lambda update-function-code --function-name $AWS_LAMBDA_FUNCTION --s3-bucket $AWS_BUCKET --s3-key $AWS_KEY --profile $AWS_PROFILE

banner "Done!"
