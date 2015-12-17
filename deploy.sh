#!/bin/sh
echo "Cleaning..."
rm -rf build
mkdir build

echo "Creating Build..."
# The wrapped Ruby app
cp -R hello-1.0.0-linux-x86_64 build
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