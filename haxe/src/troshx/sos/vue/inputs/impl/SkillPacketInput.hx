package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
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
	
	@:computed inline function get_packet():SkillPacket {
		return obj;	// assume obj supplied is SkillPacket
	}
	
	inline function isLabelBinded(s:String):Bool {
		return s.charAt(0) == "~";
	}
	
	inline function getLabel(s:String):String {
		return isLabelBinded(s) ? LibUtil.field(labelMap, s) : s;
	}
	
	inline function isArray(dyn:Dynamic):Bool {
		return Std.is(dyn, Array);
	}
	
	override function Template():String {
		return '<div class="skillpacket" style="position:relative">
			<input type="number" number :value="obj[prop]" v-on:input="inputHandler($$event.target)" :class="{invalid:!valid}" :min="min" :max="max"></input><label>{{ obj.name }}</label>
			<div class="skill-listing">
				<div v-for="(count,p) in packet.values">
					<div v-for="i in count">
						<div v-if="!isLabelBinded(p)">{{ p }}</div>
						<div v-else>
							<select v-if="isArray(labelSchema[p])" v-model="labelMap[p]">
								<option v-for="val in labelSchema[p]" :value="val">{{ val }}</option>
							</select>
							<span v-else>{{labelSchema[p]}}(<input type="text" v-model="labelMap[p]"></input>)</span>
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
}

