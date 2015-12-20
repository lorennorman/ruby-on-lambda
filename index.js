var spawn = require('child_process').spawn;

var rubyAppRoot    = "lib"
  , rubyExectuable = rubyAppRoot + "/ruby/bin/ruby"
  , rubyApp        = rubyAppRoot + "/app/hello.rb";

exports.handler = function(event, context) {
  var child = spawn(rubyExectuable, [ rubyApp ]);

  child.stdout.on('data', function (data) { console.log("stdout:\n"+data); });
  child.stderr.on('data', function (data) { console.log("stderr:\n"+data); });

  child.on('close', function (code) { context.done(); });
}
