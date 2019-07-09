package troshx.sos.vue.pregen;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.core.CharSave;

/**
 * 
 * @author Glidias
 */
class PregenSelectView extends VComponent<PregenSelectData, PregenSelectProps>
{

	public function new() 
	{
		super();
	}
	
	override function Data():PregenSelectData {
		return {
			selectedChars: [],
			selectedChar:-1
		}
	}
	
	function onConfirm():Void {
		if (this.multiSelect) {
			multiCharSelected();
		} else {
			singleCharSelected();
		}
	}
	
	function singleCharSelected():Void {
		var i = this.selectedChar;
		var char = characters[i];
		if (splice) {
			characters.splice(i, 1);
		}
		_vEmit("singleCharSelected", char); 
	}
	
	function multiCharSelected():Void {
		if (selectedChars.length == 0) return;
		var chars = [];
		for (i in 0...selectedChars.length) {
			chars.push(characters[selectedChars[i]]);
		}
		if (splice) {
			for (i in 0...chars.length) {
				characters.splice(characters.indexOf(chars[i]), 1);
			}
		}
		_vEmit("multiCharSelected", chars ); 
	}
	
	function onClose():Void {
		_vEmit("close" ); 
	}
	
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("");
	}
	
}

typedef PregenSelectData = {
	var selectedChars:Array<Int>;
	var selectedChar:Int;
}

typedef PregenSelectProps = {
	@:optional var header:String;
	@:optional var characters:Array<CharSave>;
	@:optional @:prop({'default':false}) var multiSelect:Bool;
	@:optional@:prop({'default':false}) var splice:Bool;
}