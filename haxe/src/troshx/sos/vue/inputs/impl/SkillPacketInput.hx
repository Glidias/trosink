package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import js.html.InputElement;
import js.html.SelectElement;
import troshx.sos.chargen.CharGenSkillPackets;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class SkillPacketInput extends VComponent<SkillPacketInputData, SkillPacketInputProps>
{

	public static inline var NAME:String = "SkillPacketInput";
	
	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	
	}
	
	override function Data():SkillPacketInputData {
		return {
			errorsDetected: {}
		}
	}
	
	override function Created():Void {
		this.clickedOnPlus = false;
	}
	

	
	@:watch function watch_current(newValue:Int, oldValue:Int):Void {
		_vEmit("change", this.index, newValue - oldValue, clickedOnPlus);
		clickedOnPlus = false;
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
	
	function cloneCurrentState():Dynamic<String> {
		var cl:Dynamic<String> = {};
		var packet = this.packet;
		var fields = packet.fields;
		for (i in 0...fields.length) {
			var f = fields[i];
			var p = getLabel(f);
			LibUtil.setField(cl, f,  p);
		}
		return cl;
	}
	
	function validation():Bool {
		var invalid:Bool = false;
		for (i in 0...packet.fields.length) {
			var f = packet.fields[i];
			if (!CharGenSkillPackets.isSkillLabelBinded(f) || isArray(LibUtil.field(labelSchema, f) ) ) continue;
			
			var chk = LibUtil.field(this.labelMap, f);
			//var elem:SelectElement = LibUtil.field(_vRefs, f);
			//trace(elem.checkValidity());
			if (chk == "") {
				invalid = true;
				//LibUtil.field(_vRefs, f);
				Vue.set(errorsDetected, f, true);
				
			}
			else {
				Vue.set(errorsDetected, f, false);
			}
		}
		return !invalid;
	}
	
	
	function incrementBtnHit():Void {
		
		if (!validation()) return;
		
		var val:Int = this.current;
		
		clickedOnPlus = true;
		
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
	inline function getLabel(s:String):String {
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
		p = getLabel(p);
		return LibUtil.field(skillValues, p);
	}
	
	@:computed function get_showHistoryInterface():Bool {  // WARNING: only call this if you know this.obj.history isn't null!
		var a =  LibUtil.field(obj, prop) > 0;
		var b = this.obj.history.length > 0;
		return a || b;
	}
	
	@:computed function get_packetValueList():Array<PacketProp> {  // homogenised display of data in array format
		var arr = [];
		for (p in Reflect.fields(packet.values)) {
			var lbb = isLabelBinded(p);
			var count  = LibUtil.field(packet.values, p);
			var iaa = lbb && isArray(LibUtil.field(labelSchema, p));
			while ( --count > -1) {
				arr.push({p:p, isLabelBinded:lbb, isArray:iaa  });
			}
		}
		return arr;
	}
	
	
	@:watch({deep:true}) function watch_skillSubjectHash(newValue:Dynamic<Array<String>>, oldValue:Dynamic<Array<String>>):Void {
		if (obj.history == null) return;
		
		for (i in 0...packet.fields.length) {
			var f = packet.fields[i];
			if (!CharGenSkillPackets.isSkillLabelBinded(f) || isArray(LibUtil.field(labelSchema, f) ) ) continue;
			
			var chk = LibUtil.field(this.labelMap, f);
			if (chk == "") continue;
			var skill = LibUtil.field( this.labelSchema, f);
			var arr = LibUtil.field(this.skillSubjectHash, skill);
			if (arr == null) continue;
			if (arr.indexOf(chk) < 0) {
				LibUtil.setField(this.labelMap, f, "");
			}
		}
		
	}
	
	
	function onOptionClickUnder(prop:String):Void {
		//LibUtil.setField(
		Vue.set(errorsDetected, prop, false);
	}

	function disabledFrom(arr:Array<PacketProp>, p:String, i:Int):Bool {
		p = getLabel(p);
		var cur = LibUtil.field(skillValues, p);
		while (--i > -1) {
			cur += getLabel(arr[i].p) == p ? 1 :  0;
		}
		return cur >= 5;
	}


	
	inline function isArray(dyn:Dynamic):Bool {
		return Std.is(dyn, Array);
	}
	
	override function Template():String {
		return '<div class="skillpacket" :class="{active:obj[prop]>0}">
<div class="heading"><button v-if="obj.history!=null" v-on:click="incrementBtnHit" v-show="true || current==obj.history.length" :disabled="current>=max">+</button><input type="number" v-if="obj.history==null" number :value="obj[prop]" v-on:input="inputHandler($$event.target)" v-on:blur="blurHandler($$event.target)" :class="{invalid:!valid}" :min="min" :max="max"></input><label>{{ obj.name }}</label><button v-if="false && obj.history!=null" v-on:click="spliceBtnHit" v-show="current!=obj.history.length" class="revert" :disabled="obj[prop]>=max">&#9100;</button><span class="max-length" v-if="obj.history!=null" v-show="showHistoryInterface">/{{ obj.history.length }}</span><input type="number" number :value="current" :max="obj.history.length" :min="0" v-on:input="inputHandler($$event.target)" v-if="obj.history!=null" v-show="showHistoryInterface" class="max-length-input"></input><span class="max-predict" v-if="obj.history==null">{{max - current}}</span><span style="display:block;clear:both"></span></div>
			<div class="skill-listing">
				<div v-for="(entry,i) in packetValueList" :class="{disabled:disabledFrom(packetValueList, entry.p, i)}">
					<div v-if="!entry.isLabelBinded">{{ entry.p }}</div>
					<div v-else>
						<select v-if="entry.isArray" v-model="labelMap[entry.p]">
							<option value="" disabled selected hidden>Choose One...</option>
							<option v-for="val in labelSchema[entry.p]" :value="val">{{ val }}</option>
						</select>
						<span v-else class="flex"><span>{{labelSchema[entry.p]}}(</span><span class="middle">
							<select v-if="skillSubjectHash[labelSchema[entry.p]]" v-model="labelMap[entry.p]"  v-on:change="onOptionClickUnder(entry.p)" :class="{invalid:errorsDetected[entry.p]}">
								<option value="" disabled selected hidden>Choose One...</option>
								<option v-for="special in skillSubjectHash[labelSchema[entry.p]]" :value="special" >{{ special }}</option>
							</select>
						</span><span>)</span></span>
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
	
	@:prop({required:true}) var skillSubjectHash:Dynamic<Array<String>>;
}

typedef SkillPacketInputData = {
	@:optional var clickedOnPlus:Bool;
	var errorsDetected:Dynamic<Bool>;
}

typedef PacketProp = {
	var p:String;
	var isLabelBinded:Bool;
	var isArray:Bool;
}