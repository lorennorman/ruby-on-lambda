var spawn = require('child_process').spawn;

var invokeRubyApp = "./app";

exports.handler = function(event, context) {
  console.log("Starting process: " + invokeRubyApp);
  var child = spawn(invokeRubyApp, [JSON.stringify(event, null, 2), JSON.stringify(context, null, 2)]);

  child.stdout.on('data', function (data) { console.log("stdout:\n"+data); });
  child.stderr.on('data', function (data) { console.log("stderr:\n"+data); });

  child.on('close', function (code) {
    if(code === 0) {
      context.succeed("Process completed: " + invokeRubyApp);
    } else {
      context.fail("Process \"" + invokeRubyApp + "\" exited with code: " + code);
    }
  });
}
