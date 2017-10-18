package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.sos.core.Skill.SkillTable;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * This input is two-fold, it displays the total accumulated skill levels from BOTH bought skill packets and individual skill assignments.
 * Additionally, it allows assigning individual skill levels by raising it's  current value to a higher amount above the skill level assigned through packets.
 * 
 * @author Glidias
 */
class SkillLibInput extends VComponent<SkillLibInputData, SkillLibInputProps>
{
	
	public static inline var NAME:String = "SkillLibInput";

	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	}
	
	override function Data():SkillLibInputData {
		return {};
	}
	
	override function Created():Void {
		this.interactedInput = false;
	}
	
	@:computed function get_min():Int {  // cannot be reduced to  < points of current skill level from packets
		return skillLevelsPacket != null ? clamp5( LibUtil.field(this.skillLevelsPacket, this.prop) ) : 0;
	}
	
	function checkConstraints():Void
	{
		var theCurrent:Float = this.current;
		var currentVal:Float = theCurrent;
		var min:Float = this.min;
		var max:Float = this.max;
		if (min != null && currentVal < min) currentVal = min;
		if (max != null && currentVal > max) currentVal = max;
		
		// UNFORTUANTELY, duplicate of checkConstraints boilerplate above (oops, too bad..)
		
		if (currentVal != theCurrent)  LibUtil.setField(obj, prop, currentVal - min);   // last line of duplicate adjusted to set obj value based on how display value above min
	}
	
	@:watch function watch_current(newValue:Int, oldValue:Int):Void {
		if (interactedInput) _vEmit("change",  newValue - oldValue);
		interactedInput = false;
	}
	
	function inputHandler(input:InputElement):Void {
		
		if (input.value == "") return;
		
		var max = this.max;
		var min = this.min;
			var result:Float =  floating ? input.valueAsNumber : Std.int(input.valueAsNumber); // Std.parseInt( (~/[^0-9]/g).replace( input.value, '') );
		
		if (result == null || Math.isNaN(result) ) {
			input.valueAsNumber =  LibUtil.field(obj, prop);
			return;
		}
		if (result != input.valueAsNumber) input.valueAsNumber = result;
		
		if (result > max) {
			input.valueAsNumber = result = max;
		}
		if (result < min) {
			input.valueAsNumber = result = min;
		}
		//  UNFORTUANTELY, duplicate of inputHandler boilerplate above (oops, too bad..)
		
		
		interactedInput = true;
		
		LibUtil.setField(obj, prop, result - min);  // last line of duplicate adjusted to set obj value based on display value above min
	}
	
	
	@:computed function get_max():Int {
		var r = current + remaining;
		var min = this.min;
		r =  r < min ? min : r;
		return r >= 10 ? 10 : r;
	}
	
	
	inline function clamp5(val:Int) {
		return val >= 5 ? 5 : val;
	}
	

	@:computed inline function get_current():Int {
		// the current display value to show
		return (skillLevelsPacket!=null?  clamp5(LibUtil.field(skillLevelsPacket, prop)) : 0) + LibUtil.field(obj, prop); 
	}
	
	@:computed function get_deleteBtnStyle():Dynamic {
		return {'visibility':current == 0 ? 'visible' : 'hidden' };
	}
	
	function onDeleteClick():Void {
		_vEmit("delete", index);
	}
	
	override function Template():String {
		return '<span :class="{active:obj[prop]>0, activepack:min>0}">
				<label><input type="number" number :value="current" v-on:blur="blurHandler($$event.target)" v-on:input="inputHandler($$event.target)" :class="{invalid:!valid}" :min="min" :max="max"></input>{{prop}}<span v-show="skillsTable.requiresSpecialisation[prop]">()</span><sup v-show="skillsTable.requiresTrained[prop]">1</sup><span v-if="canDelete" :style="deleteBtnStyle">[<a href="#" v-on:click.prevent="onDeleteClick">x</a>]</span></label>
			</span>';
	}
	
}

typedef SkillLibInputProps = {
	>NumericInputProps,  // obj assumed to be skillLevelsIndividual:Dynamic<Int>
	
	@:prop({required:false, 'default':10})  @:optional var remaining:Int; // individualSkillsRemaining
	@:prop({required:true}) var skillsTable:SkillTable;
	@:prop({required:true}) var index:Int;
	@:prop({required:false}) @:optional var skillLevelsPacket:Dynamic<Int>;
	@:prop({required:false, 'default':false}) var canDelete:Bool;

}

typedef SkillLibInputData = {
	@:optional var interactedInput:Bool;
}