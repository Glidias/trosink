package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.input.MixinInput;
import troshx.util.LibUtil;

/**
 * Displays a list of modifiers for charsheet and optional to add custom homebrew modifiers
 * @author Glidias
 */
class ModifierList extends VComponent<ModifierData, ModifierListProps>
{
	public static inline var NAME:String = "ModifierList";

	public function new() 
	{
		super();
		untyped this.mixins = [
			MixinInput.getInstance()
		];
	}
	
	override function Data():ModifierData {
		var dyn:Dynamic = Modifier;
		var index:Int = LibUtil.field(dyn, rowId);
		return {
			staticMod: StaticModifier.create(index, "", 0)
		}
	}
	
	function resetData():Void {
		var dyn:Dynamic = Modifier;
		var index:Int = LibUtil.field(dyn, rowId);
		this.staticMod = StaticModifier.create(index, "", 0);
	}
	
	
	
	
	@:computed function get_rowStatic():Array<StaticModifier> {
		var dyn:Dynamic = Modifier;
		return this.char.staticModifierTable[LibUtil.field(dyn, rowId)];
	}
	@:computed function get_rowSituational():Array<SituationalCharModifier> {
		var dyn:Dynamic = Modifier;
		return this.char.situationalModifierTable[LibUtil.field(dyn, rowId)];
	}
	
	@:computed function get_list():Array<ModifierEntry> {
		var arr:Array<ModifierEntry> = [];
		var statics:Array<StaticModifier> = rowStatic;
		var situational:Array<SituationalCharModifier> = rowSituational;
		for (i in 0...statics.length) {
			var s = statics[i];
			if (!s.custom) {
				arr.push({
					staticMod: s,
					name:s.name,
					custom:s.custom
				});
			}
		}
		
		for (i in 0...situational.length) {
			arr.push({
				name:situational[i].name,
				custom:false
			});
		}
		
		for (i in 0...statics.length) {  // always show customs last
			var s = statics[i];
			if (s.custom) {
				arr.push({
					staticMod: s,
					name:s.name,
					custom:s.custom
				});
			}
		}
		
		
		return arr;
	}
	
	@:computed function get_enabledAddBtn():Bool {
		return StringTools.trim(staticMod.name) != "";
	}
	
	function addStaticEntry():Void {
		this.char.addStaticModifier(this.staticMod);
		resetData();
	}
	
	function getStaticModStat(mod:StaticModifier):String {
		return (mod.multiply != 0 ? "x" + mod.multiply : "") + (mod.add !=0 ?  ( (mod.add>=0 ? "+":"") + mod.add) : "" );
	}
	
	function deleteEntry(mod:ModifierEntry):Void {
		this.char.removeStaticModifier(mod.staticMod);
	}
	
	
	override function Template():String {
		return '<div>
			<ul class="modifiers">
				<li v-for="(li, i) in list" :class="{custom:li.custom}">{{li.name}}<span v-if="li.staticMod!=null"> ({{ getStaticModStat(li.staticMod) }})</span> <span v-if="li.custom"><a href="javascript:;" v-on:click="deleteEntry(li)">[x]</a></span></li>
			</ul>
			<div v-if="editable">
				<div v-if="staticMod != null">
					<div><label>Name:<InputString :obj="staticMod" prop="name" /></label> <label>Add(+):<InputNumber :obj="staticMod" prop="add" /></label> <label>Multiply(x):<InputNumber :obj="staticMod" prop="multiply" :step="0.5" /></label></div>
					<button :enabled="enabledAddBtn" v-on:click="addStaticEntry">Add Custom Modifier</button>
				<div>
			</div>
		</div>';
	}

}

typedef ModifierListProps = {
	@:prop({required:true}) var rowId:String;
	@:prop({required:true}) var char:CharSheet;
	@:prop({required:false, 'default':false}) var editable:Bool;
	@:prop({required:false}) var baseCalc:Float;
}

typedef ModifierEntry = {
	@:optional var staticMod:StaticModifier;
	var name:String;
	var custom:Bool;
}

typedef ModifierData = {
	var staticMod:StaticModifier;
}