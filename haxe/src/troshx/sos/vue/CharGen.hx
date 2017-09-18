package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.chargen.CampaignPowerLevel;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.chargen.CharGenData;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.Skill;
import troshx.sos.vue.inputs.impl.AttributeInput;
import troshx.sos.vue.inputs.impl.BoonBaneInput;
import troshx.sos.vue.inputs.impl.CategoryPCPInput;
import troshx.sos.vue.inputs.impl.SkillLibInput;
import troshx.sos.vue.inputs.impl.SkillPacketInput;
import troshx.sos.vue.widgets.BoonBaneApplyDetails;

/**
 * ...
 * @author Glidias
 */
@:vueIncludeDataMethods
class CharGen extends VComponent<CharGenData,NoneT>
{

	public function new() 
	{
		super();
	}
	
	
	
	override function Data():CharGenData {
		return new CharGenData();
	}
	
	override function Created():Void {
		_vData.privateInit();
	}
	
	@:watch function watch_maxBoonsSpendableLeft(newValue:Int):Void {
		var arr = this.boonsArray;
		var i = arr.length;
		while (--i > -1) {
			var v = arr[i];
			v.updateRemainingCache(newValue);
		}
		
	}
	@:watch function watch_raceTier(newValue:Int):Void {
		
		if (this.selectedTierIndex >= newValue) {
			this.resetToHuman();
		}
	}
	
	function getBnBSlug(name:String):String {
		return BoonBaneApplyDetails.getSlug(name);
	}
	
	function resetBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("REMOVING:" + bba + " , " + isBane);
		if (isBane) {
			//char.removeBane(cast bba);
			var bane:Bane = cast bba.getBoonOrBane();
			var ba;
			var i = baneAssignList.indexOf(cast bba);
			ba = bane.getAssign(0, char);
			ba._costCached = bane.costs[0];
			Vue.set(this.baneAssignList, i, ba );
			
		}
		else {
		
			var boon:Boon = cast bba.getBoonOrBane();
			var ba;
			var i = boonAssignList.indexOf(cast bba);
			ba = boon.getAssign(0, char);
			ba._costCached = boon.costs[0];
			ba._remainingCached = maxBoonsSpendableLeft;
			Vue.set(this.boonAssignList, i, ba );
		}
	}

	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			CategoryPCPInput.NAME => new CategoryPCPInput(),
			AttributeInput.NAME => new AttributeInput(),
			
			BoonBaneInput.NAME => new BoonBaneInput(),
			BoonBaneApplyDetails.NAME => new BoonBaneApplyDetails(),
			
			SkillPacketInput.NAME => new SkillPacketInput(),
			SkillLibInput.NAME => new SkillLibInput()
		];
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	@:computed function get_placeholder():String {
		return "[placeholder]";
	}
}

