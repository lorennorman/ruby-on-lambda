var spawn = require('child_process').spawn;

var invokeRubyApp = "./app";

exports.handler = function(event, context) {
  var child = spawn(invokeRubyApp);

  child.stdout.on('data', function (data) { console.log("stdout:\n"+data); });
  child.stderr.on('data', function (data) { console.log("stderr:\n"+data); });

  child.on('close', function (code) { context.done(); });
}
