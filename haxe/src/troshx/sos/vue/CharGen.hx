package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.chargen.CampaignPowerLevel;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.chargen.CharGenData;
import troshx.sos.vue.inputs.impl.AttributeInput;
import troshx.sos.vue.inputs.impl.BoonBaneInput;
import troshx.sos.vue.inputs.impl.CategoryPCPInput;

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
	
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			CategoryPCPInput.NAME => new CategoryPCPInput(),
			AttributeInput.NAME => new AttributeInput(),
			
			BoonBaneInput.NAME => new BoonBaneInput()
		];
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	@:computed function get_placeholder():String {
		return "[placeholder]";
	}
}

