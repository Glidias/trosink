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
				using System.Collections.Generic;
				using troshx.tros.ai;

				public class Startup
				{
					Story _story;
					
					public static void setupBindingsForBot(Story _story, string prefixChar, TROSAiBot bot) {
						System.Console.WriteLine("Tracing bind variables...");
							object d = new global::haxe.lang.DynamicObject(new int[]{}, new object[]{}, new int[]{}, new double[]{});
							global::troshx.util.ReflectUtil.setItemFieldsTo<object>(typeof(global::troshx.tros.ai.TROSAiBot), d, new global::haxe.lang.Null<bool>(false, true), "bind", null);
							int _g = 0;
							global::haxe.root.Array<object> _g1 = global::haxe.root.Reflect.fields(d);
						
							while (( _g < _g1.length )) {
								string p = global::haxe.lang.Runtime.toString(_g1[_g]);
								 ++ _g;
								
								 //(metaName:String, t:Dynamic, fieldName:Dynamic, isStatic:Bool=false
									global::haxe.root.Array<object> metaData = (global::haxe.root.Array<object>)(global::troshx.util.ReflectUtil.getMetaDataOfField("bind", typeof(TROSAiBot), bot, p, new global::haxe.lang.Null<bool>(false, true)));
									
									// System.Console.WriteLine(prefixChar+metaData[0]);
									string fullFieldName =  prefixChar+metaData[0];
									global::haxe.root.Reflect.setField(d, fullFieldName, p);
				
									global::haxe.root.Reflect.setField(bot, p, _story.variablesState[fullFieldName]);
									System.Console.WriteLine(p + " SETTING : "+_story.variablesState[fullFieldName]);
									
									_story.ObserveVariable(prefixChar+metaData[0],  (string varName, object newValue) => {
										string propToSet = (string)global::haxe.root.Reflect.field(d, varName);
										System.Console.WriteLine(prefixChar+ ":"+(bot.id) + ": "+propToSet +  "="+newValue);
										global::haxe.root.Reflect.setField(bot,propToSet , newValue);
									});
								
							}
					}


					public async Task<object> Invoke(string input)
					{
						 _story = new Story(input);
						
						 //TROSAiBotInkle.bindWatchesForInk<TROSAiBot>(typeof(TROSAiBot), _story, null);
						
						{
							System.Console.WriteLine("Tracing watch variables...");
							object d = new global::haxe.lang.DynamicObject(new int[]{}, new object[]{}, new int[]{}, new double[]{});
						global::troshx.util.ReflectUtil.setItemFieldsTo<object>(typeof(global::troshx.tros.ai.TROSAiBot), d, new global::haxe.lang.Null<bool>(true, true), "watch", null);
							int _g = 0;
							global::haxe.root.Array<object> _g1 = global::haxe.root.Reflect.fields(d);
						
							while (( _g < _g1.length )) {
								string p = global::haxe.lang.Runtime.toString(_g1[_g]);
								 ++ _g;
								 _story.ObserveVariable(p,  TROSAiBotInkle.staticVarSetter);
								 System.Console.WriteLine(p);
							}
						}
						TROSAiBot bot = new TROSAiBot();
						TROSAiBot bot2 = new TROSAiBot();
						setupBindingsForBot(_story, "charPersonName", bot);
						setupBindingsForBot(_story, "charPersonName2", bot2);
						
						 return new {
							helloWorld = (Func<object,Task<object>>)(
								async (i) => 
								{ 
									return "Hello world: "+i;
								}
							)
							,helloTest = (Func<object,Task<object>>)(
								async (i) => 
								{ 
									
									return "Hello test: "+i;
								}
							)
							,helloStory = (Func<object,Task<object>>)(
								async (i) => 
								{ 
									return _story;
								}
							)
							,getOutputMessages = (Func<object,Task< object  >>)(
								async (obj) => 
								{ 
									return StoryUtil.getOutputMessages(_story);
								}
							) 
							,setChoiceIndex = (Func<object,Task<object>>)(
								async (obj) => 
								{ 
									await Task.Run(() => _story.ChooseChoiceIndex((int)obj));
									return StoryUtil.getOutputMessages(_story);

								}
							) 
						};
					}


					public class StoryUtil {
	
						public static object getOutputMessages(Story story) {
							List<string> lineList = new List<string>();
							List<string> choiceList = new List<string>();
							while (story.canContinue) {
								lineList.Add(story.Continue());
							}
							//int count = ;
							for (int i = 0; i < story.currentChoices.Count; ++i) {
						        Choice choice = story.currentChoices[i];
						  		choiceList.Add(choice.text);
						    }
							
							
							return new {
								lines = lineList,
								choices = choiceList
							};
						}
					}

					
				}


			*/},
			references: ['ink-engine.dll', 'trosink.dll']
		});
		
	}

	/*
						
							*/
	


	var CHOICES_AVAILABLE = 0;
	var _LOCKED = true;

	function onInklePackageCompiled() {
		
		if (socket) {
			//var testoutput = inklePackage.helloStory(null, true);
			//socket.emit("chat message", testoutput);

			///*
			socket.emit("data", inklePackage.getOutputMessages(0,true));

			var data = inklePackage.getOutputMessages(0, true);
			CHOICES_AVAILABLE = data.choices.length;
			if (CHOICES_AVAILABLE <= 0) {
				if (socket) {
					socket.emit("serverchat", "== End detected ==");
					socket.emit("end");

				}
				_LOCKED = true;
			}
			_LOCKED = false;
			//*/

		} 
		else {
			console.log("Successfully compiled.");
			//var testoutput = inklePackage.helloStory(null, true);
			//inklePackage.helloTest(null, true);

		}
	}

	function setChoiceIndex(index) {
		if (_LOCKED) return;

		index = parseInt(index);
		if (isNaN (index)) return;
		if (index <0 || index >= CHOICES_AVAILABLE) {
			if (socket) socket.emit("serverchat", "Choice selection ("+(index+1)+") out of range..")
			return;
		}

		if (inklePackage == null) return
		_LOCKED = true;

		inklePackage.setChoiceIndex(index, function(error, data) {
			if (error) {
				console.error(error);
				if (socket) socket.emit("error", "ERROR: sorry something went wrong...")
				return;
			}


			CHOICES_AVAILABLE = data.choices.length;
			if (socket) {
				socket.emit("data", data);
			}
			else {
				console.log(data);
			}
			_LOCKED = false;

		});
	}
	this.setChoiceIndex = setChoiceIndex;




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

function setupServer() {

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
		sessionHash[socket.id] = new InkleSessionInstance(socket);
		
		sessionHash[socket.id].readDefaultTROS();

	   socket.on('disconnect', function(reason){
			if (sessionHash[socket.id]) {
				sessionHash[socket.id].destroy();
			}
			delete sessionHash[socket.id];
	  });
	  
	  socket.on('serverchat', function(msg){
	    socket.emit('serverchat', msg);
	  });

/*
	   socket.on('chat message', function(msg){
	    //io.emit('serverchat', msg);
	  });
*/

	  socket.on('sendChoice', function(index) {
	  	if (isNaN(index)) return;
	  	//	console.log(setChoiceIndex);
	  	if (!sessionHash[socket.id]) return;
	  	 sessionHash[socket.id].setChoiceIndex(index);
	  });
	});

}

function testCode() {
	var comp = new InkleSessionInstance(null);
	comp.readDefaultTROS();

}

function compileTROS() {
	var comp = new InkleSessionInstance(null);
	comp._executeCompileProcess();

}

//testCode();
//compileTROS();
setupServer();