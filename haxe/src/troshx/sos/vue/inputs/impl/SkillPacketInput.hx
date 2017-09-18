package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.sos.chargen.CharGenSkillPackets;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class SkillPacketInput extends VComponent<NoneT, SkillPacketInputProps>
{

	public static inline var NAME:String = "SkillPacketInput";
	
	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	
	}
	
	@:watch function watch_current(newValue:Int, oldValue:Int):Void {
		_vEmit("change", this.index, newValue - oldValue);
	}
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	@:computed function get_min():Int {
		return 0;
	}
	
	
	@:computed function get_max():Int {
		var packet = this.packet;
		var r =  packet.qty + skillPacketsRemaining; // regular skillPackets remaining through points only...
		
		// TODO: maxQty until useless which also factors 
		var s = packet.history != null ?  dynamicMaxQtyUntilUseless() : staticMaxQtyUntilUseless();
		
		r = r < s ? r : s;
		
		// no point going above 5 in anyway,
		return r >= 5 ? 5 : r;
	}
	
	
	function staticMaxQtyUntilUseless():Int { // pennywise
		var packet = this.packet;
		var current:Int = packet.qty;
		var isChoosy:Bool = this.packetChoosy;
		
		var candidate = 9999;
		for (i in 0...packet.fields.length) {
			var f = packet.fields[i];
			var v = LibUtil.field( packet.values, f);
			var skill:Int = getBindedValue(f);
			
			var innerV = (5 - currentPacketClampedSkillLevel(skill) ) / v;
			v = current  +  ( isChoosy ? Math.floor(innerV) : Math.ceil( innerV ));
			if (v < candidate) {
				candidate = v;
			}
		}
		return candidate;
	}
	
	
	inline function currentPacketClampedSkillLevel(skill:Int):Int {
		return skill >= 5 ? 5 : skill;
	}
	
	function dynamicMaxQtyUntilUseless():Int {
		var packet = this.packet;
		var current:Int = packet.qty;
		var compare = packetChoosy ? 0 : 1;
		for (i in 0...packet.fields.length) {
			var f = packet.fields[i];
			var v = LibUtil.field( packet.values, f);
			var skill:Int = getBindedValue(f);
			
			if ( currentPacketClampedSkillLevel(skill) + v - 5 > compare) {
				return current;
			}
		}
		return current + 1;
	}
	
	
	// TO be depreciated
	function checkValidTextEntry(txt:String, checkSchema:Dynamic, checkProp:String):Bool {
		for (p in Reflect.fields(this.labelSchema)) {
			if (checkProp == p || LibUtil.field(this.labelSchema, p) !=checkSchema ) continue;
			if (  LibUtil.field(this.labelMap, p) == txt ) {
				return false;
			}
		}
		return true;
	}
	// TO be depreciated
	function setSpecialText(input:InputElement, prop:String):Void {

		if (input.value != "" && checkValidTextEntry(input.value, LibUtil.field(this.labelSchema, prop), prop )) {
			LibUtil.setField(labelMap, prop, input.value);	
		}
		else {
			input.value = LibUtil.field(this.labelMap, prop);
		}
	
	}
	
	function cloneCurrentState():Dynamic<Int> {
		var cl:Dynamic<Int> = {};
		var packet = this.packet;
		var fields = packet.fields;
		for (i in 0...fields.length) {
			var f = fields[i];
			// todo: proper history for backtracking
			LibUtil.setField(cl, f,  LibUtil.field(packet.values, f));
		}
		return cl;
	}
	
	function incrementBtnHit():Void {
		var val:Int = this.current;

		LibUtil.setArrayLength(packet.history, val);
		packet.history.push(cloneCurrentState());
		
		LibUtil.setField(obj, prop, val + 1);
	}
	
	function spliceBtnHit():Void {
		var val:Int = this.current;
		
		LibUtil.setArrayLength(packet.history, val);

	
	}
	
	@:computed inline function get_packet():SkillPacket {
		return obj;	// assume obj supplied is SkillPacket
	}
	

	
	inline function isLabelBinded(s:String):Bool {
		return  CharGenSkillPackets.isSkillLabelBinded(s);
	}
	function getLabel(s:String):String {
		return CharGenSkillPackets.getSkillLabel(s, labelSchema, labelMap);
	
		
	}
	/*
	@:computed function get_maxHistoryLength():Int {
		if (obj.history == null) return 0;
		
		return obj.history.length;  // handling of history is done outside this component
		
	}
	*/
	
	
	/*  // no longer needed, handle outside
	@:watch function watch_maxHistoryLength(newValue:Int):Void {
		if (this.obj.history != null && this.obj.history.length != newValue) {
			LibUtil.setArrayLength(obj.history, newValue);
		}
	}
	*/
	// need to: invalidate future history whenever any adding of new skill elsewhere is made

	
	inline function getBindedValue(p:String):Int  {
		// TODO: checkbinding for getLabelValue using schema and getLabel(..)
		return LibUtil.field(skillValues, p);
	}
	
	@:computed function get_showHistoryInterface():Bool {  // WARNING: only call this if you know this.obj.history isn't null!
		var a =  LibUtil.field(obj, prop) > 0;
		var b = this.obj.history.length > 0;
		return a || b;
	}

	
	inline function isArray(dyn:Dynamic):Bool {
		return Std.is(dyn, Array);
	}
	
	override function Template():String {
		return '<div class="skillpacket" :class="{active:obj[prop]>0}">
<div class="heading"><button v-if="obj.history!=null" v-on:click="incrementBtnHit" v-show="true || current==obj.history.length" :disabled="current>=max">+</button><input type="number" v-if="obj.history==null" number :value="obj[prop]" v-on:input="inputHandler($$event.target)" v-on:blur="blurHandler($$event.target)" :class="{invalid:!valid}" :min="min" :max="max"></input><label>{{ obj.name }}</label><button v-if="false && obj.history!=null" v-on:click="spliceBtnHit" v-show="current!=obj.history.length" class="revert" :disabled="obj[prop]>=max">&#9100;</button><span class="max-length" v-if="obj.history!=null" v-show="showHistoryInterface">/{{ obj.history.length }}</span><input type="number" number :value="current" :max="obj.history.length" :min="0" v-on:input="inputHandler($$event.target)" v-if="obj.history!=null" v-show="showHistoryInterface" class="max-length-input"></input><span class="max-predict" v-if="obj.history==null">{{max - current}}</span><span style="display:block;clear:both"></span></div>
			<div class="skill-listing">
				<div v-for="(count,p) in packet.values">
					<div v-for="i in count" :class="{disabled:getBindedValue(p)+i-1>=5}">
						<div v-if="!isLabelBinded(p)">{{ p }}</div>
						<div v-else>
							<select v-if="isArray(labelSchema[p])" v-model="labelMap[p]">
								<option value="" disabled selected hidden>Choose One...</option>
								<option v-for="val in labelSchema[p]" :value="val">{{ val }}</option>
							</select>
							<span v-else class="flex"><span>{{labelSchema[p]}}(</span><span class="middle"><input type="text" placeholder="provide unique.." v-on:blur="setSpecialText($$event.target, p)" :value="labelMap[p]"></input></span><span>)</span></span>
						</div>
					</div>
				</div>
			</div>
		</div>';
	}
}

typedef SkillPacketInputProps = {
	>NumericInputProps,
	@:prop({required:true}) var labelMap:Dynamic<String>;
	@:prop({required:true}) var labelSchema:Dynamic;
	@:prop({required:true}) var index:Int;
	
	@:prop({required:true}) var skillValues:Dynamic<Int>;
 	@:prop({required:true}) var skillPacketsRemaining:Int;
	@:prop({required:true}) var packetChoosy:Bool;
}

