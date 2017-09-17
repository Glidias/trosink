package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
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
		return current + 1;
	}
	
	function checkValidTextEntry(txt:String, checkSchema:Dynamic, checkProp:String):Bool {
		for (p in Reflect.fields(this.labelSchema)) {
			if (checkProp == p || LibUtil.field(this.labelSchema, p) !=checkSchema ) continue;
			if (  LibUtil.field(this.labelMap, p) == txt ) {
				return false;
			}
		}
		return true;
	}
	
	function setSpecialText(input:InputElement, prop:String):Void {
		
		if (input.value != "" && checkValidTextEntry(input.value, LibUtil.field(this.labelSchema, prop), prop )) {
			LibUtil.setField(labelMap, prop, input.value);	
		}
		else {
			input.value = LibUtil.field(this.labelMap, prop);
		}
	
	}
	
	@:computed inline function get_packet():SkillPacket {
		return obj;	// assume obj supplied is SkillPacket
	}
	
	inline function isLabelBinded(s:String):Bool {
		return s.charAt(0) == "~";
	}
	

	
	inline function isArray(dyn:Dynamic):Bool {
		return Std.is(dyn, Array);
	}
	
	override function Template():String {
		return '<div class="skillpacket" :class="{active:packet.qty>0}">
		<div class="heading"><input type="number" number :value="obj[prop]" v-on:input="inputHandler($$event.target)" :class="{invalid:!valid}" :min="min" :max="max"></input><label>{{ obj.name }}</label></div>
			<div class="skill-listing">
				<div v-for="(count,p) in packet.values">
					<div v-for="i in count">
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
	@:prop({required:true}) var labelSchema:Dynamic<String>;
	@:prop({required:true}) var index:Int;
	@:prop({required:true}) var skillValues:Dynamic<Int>;
	@:prop({required:true}) var totalSkillPointsLeft:Int;
	
}

