# Ruby on AWS Lambda

## Why?

Because:

- AWS Lambda has immense potential and interesting implications
- AWS Lambda doesn't officially support Ruby, as yet
- Ruby has immense potential and interesting implications as well!

## How?

By:

- packaging a Ruby binary _with our app_
  - thank you, [Traveling Ruby!](http://phusion.github.io/traveling-ruby/)
- Lambda executes a simple NodeJS program that shells out to our code
  - see `index.js`
- Ruby executes your code
  - yes, Bundler works! *(within reason)*
- Hello World is about 8MB, leaving you 42MB of room to get crazy
  - (no native gems)

## Usage

1. Sign up for Amazon AWS
2. Get access to Amazon S3
3. Get access to Amazon Lambda
4. Create an IAM account with access to S3 and Lambda
5. Install the aws cli tools
6. Set up an AWS profile in `~/.aws/credentials` for the account created above
7. Change the variables in `deploy.sh` to match your app and AWS settings
8. Ensure you're using ruby 2.1.x in this directory
9. Add any gems you need to app/Gemfile
10. `cd app` and run `bundle install` from there (you need a Gemfile.lock)
11. edit `app/app.rb` with your application code
12. run `./deploy.sh linux-x86_64`
13. test your Lambda Function!
  - i've been using the web console for testing
