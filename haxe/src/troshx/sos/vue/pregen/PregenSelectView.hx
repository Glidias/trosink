package troshx.sos.vue.pregen;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.core.CharSheet;
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
			selectedChars: []
		}
	}
	
	function singleCharSelected(i:Int):Void {
		var char = characters[i];
		if (splice) {
			characters.splice(i, 1);
		}
		_vEmit("singleCharSelected", char); 
	}
	
	function multiCharSelected(i:Int):Void {
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
		return '
			<div style="position:fixed;top:0;left:0;width:100%;height:100%;overflow:auto" class="pregen-select-view">
				<h1 v-if="header">{{header}}</h1>
				<ul v-if="characters">
					<li v-for="(li, i) in characters" :key="i">
						<div class="checkbox-holder" v-if="multiSelect">
							<input type="checkbox" v-model.number="selectedChars" :value="i">
								<label>{{li.label}}</label>
							</input>
						</div>
						<div class="btn-holder" v-else><button @click="singleCharSelected(i)">{{li.label}}</button></div>
					</li>
				</ul>
				<button v-if="multiSelect" :disabled="selectedChars.length == 0">Confirm</button>
				<div class="close-btn-zone">
					<a class="close-btn" v-on:click="onClose"><span>[x]</span> Close</a>
				</div>
			</div>
		
		';
	}
	
}

typedef PregenSelectData = {
	var selectedChars:Array<Int>;
}

typedef PregenSelectProps = {
	@:optional var header:String;
	@:optional var characters:Array<CharSave>;
	@:optional @:prop({'default':false}) var multiSelect:Bool;
	@:optional@:prop({'default':false}) var splice:Bool;
}