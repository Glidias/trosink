function InkleSessionInstance(socket) {
	
	var edgeCodebase;
	var inklePackage;
	var process;
	
	var DESTROYED = false;
	
	var loadJSONString = function(stringData) {
		 edgeCodebase(stringData, function (error, result) {
			if (DESTROYED) return;
			
			if (error) throw error;
			else {
				inklePackage = result;
				onInklePackageCompiled();
			}
		});
	}
	this.loadJSONString = loadJSONString;
	
	
	function init() {
		setupEdge();
	}
	
	
	function setupEdge() {
		var edge = require('edge');

		edgeCodebase = edge.func({
			source: function() {/*
				using System;
				using System.Threading.Tasks;
				using Ink.Runtime;

				public class Startup
				{
					Story _story;
					
					public async Task<object> Invoke(string input)
					{
						// 1) Load story
						 _story = new Story(input);
						// 2) Game content, line by line
				
						 return new {
							helloWorld = (Func<object,Task<object>>)(
								async (i) => 
								{ 
									return "Hello world: "+i;
								}
							)
							,helloStory = (Func<object,Task<object>>)(
								async (i) => 
								{ 
									return _story;
								}
							)
						};
					}
				}
			*/},
			references: ['ink-engine.dll']
		});
		
	}
	
	function onInklePackageCompiled() {
		
		if (socket) {
			var testoutput = inklePackage.helloStory(null, true);
			socket.emit("chat message", testoutput);
		} 
	}

	function executeCompileProcess(filePath) {
		var fs = require('fs');
		if (filePath == null) filePath = "stories/tros.ink";
		 process = require('child_process');
		process.exec("inklecate.exe "+filePath,
			function (error, stdout, stderr) {
				
				process = null;
				if (DESTROYED) return;
				
				var result = stdout;
				
				if (error) {
					return console.log(err);
				}
				fs.readFile(filePath+".json", 'utf8', readJSONFileComplete);
						
				
			});
	}
	this._executeCompileProcess = executeCompileProcess;
	
	
	this.readDefaultTROS = function() {
		var fs = require("fs");
		fs.readFile("stories/tros.ink"+".json", 'utf8', readJSONFileComplete);
	}
	
	
	function readJSONFileComplete(err, data) {
		  if (err) {
			return console.log(err);
		  }
		loadJSONString(data.slice(1));
	}

		
	this.destroy = function() {
		
		DESTROYED = true;
		
		if (process) {
			// cancel process
			
			

		}
		if (inklePackage) {
			// need to dispose?
		}
	}
		
	
	init();
}

var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);


app.get('/', function(req, res){
  var path = require("path");
  res.sendFile(path.join(__dirname, '../views', 'inkleconsole.html'));
});

http.listen(3000, function(){
  console.log('listening on *:3000');
});


var sessionHash = {};

io.on('connection', function(socket){

 // when the client emits 'adduser', this listens and executes
	
	// add the client's username to the global list
	sessionHash[socket.username] = new InkleSessionInstance(socket);
	
	sessionHash[socket.username].readDefaultTROS();

   socket.on('disconnect', function(reason){
		if (sessionHash[socket.username]) {
			sessionHash[socket.username].destroy();
		}
		delete sessionHash[socket.username];
  });
  
  socket.on('chat message', function(msg){
    io.emit('chat message', msg);
  });
});



