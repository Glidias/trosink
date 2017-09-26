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
import troshx.sos.sheets.CharSheet.WealthAssetAssign;
import troshx.sos.vue.inputs.impl.AttributeInput;
import troshx.sos.vue.inputs.impl.BoonBaneInput;
import troshx.sos.vue.inputs.impl.CategoryPCPInput;
import troshx.sos.vue.inputs.impl.SkillLibInput;
import troshx.sos.vue.inputs.impl.SkillPacketInput;
import troshx.sos.vue.uifields.ArrayOf;
import troshx.sos.vue.uifields.ArrayOfBits;
import troshx.sos.vue.widgets.BoonBaneApplyDetails;
import troshx.sos.vue.widgets.SkillSubjectCreator;

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
		untyped CharGenData.dynSetField = Vue.set;
		untyped CharGenData.dynDeleteField = Vue.delete;
		untyped CharGenData.dynSetArray = Vue.set;
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
	
	@:watch function watch_socialEitherMaxIndex(newValue:Int):Void {
		this.constraintSocialWealth();
	}
	
	@:watch function watch_wealthEitherMaxIndex(newValue:Int):Void {
		this.constraintSocialWealth();
	}
	@:watch function watch_syncSocialWealth(newValue:Bool):Void {
		this.constraintSocialWealth();
	}
	
	@:watch function watch_socialClassIndex(newValue:Int, lastValue:Int):Void {
		this.updateSocialToCharsheet();
	}
	@:watch function watch_wealthIndex(newValue:Int):Void {
		this.updateMoneyToCharsheet();
	}
	
	@:watch function watch_socialBenefit1(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		this.updateSocialBenefitsToBoon(newValue, oldValue);
		
	}
	@:watch function watch_socialBenefit2(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		this.updateSocialBenefitsToBoon(newValue, oldValue);
	}
	@:watch function watch_socialBenefit3(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		this.updateSocialBenefitsToBoon(newValue, oldValue);
	}
	
	
	function getBnBSlug(name:String):String {
		return BoonBaneApplyDetails.getSlug(name);
	}
	
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			CategoryPCPInput.NAME => new CategoryPCPInput(),
			AttributeInput.NAME => new AttributeInput(),
			
			BoonBaneInput.NAME => new BoonBaneInput(),
			BoonBaneApplyDetails.NAME => new BoonBaneApplyDetails(),
			
			SkillPacketInput.NAME => new SkillPacketInput(),
			SkillLibInput.NAME => new SkillLibInput(),
			SkillSubjectCreator.NAME => new SkillSubjectCreator(),
			
			ArrayOf.NAME => new ArrayOf(),
			ArrayOfBits.NAME => new ArrayOfBits()
		];
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	@:computed function get_placeholder():String {
		return "[placeholder]";
	}
}

