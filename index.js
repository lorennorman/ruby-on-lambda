var spawn = require('child_process').spawn;

var rubyAppRoot    = "hello-1.0.0-linux-x86_64"
  , rubyExectuable = rubyAppRoot + "/lib/ruby/bin/ruby"
  , rubyApp        = rubyAppRoot + "/lib/app/hello.rb";

exports.handler = function(event, context) {
  var child = spawn(rubyExectuable, [ rubyApp ]);

  child.stdout.on('data', function (data) { console.log("stdout:\n"+data); });
  child.stderr.on('data', function (data) { console.log("stderr:\n"+data); });

  child.on('close', function (code) { context.done(); });
}
