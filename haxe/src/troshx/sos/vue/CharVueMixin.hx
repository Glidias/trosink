package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.sheets.CharSheet;

/**
 * Common charsheet related derived attributes cached by vue proxy, boilerplate.
 * @author Glidias
 */
class CharVueMixin extends VComponent<CharVueMixinData,NoneT>
{

	public function new() 
	{
		super();
	}
	override function Data():CharVueMixinData {
		return {
			char: null //new CharSheet()
		}
	}
	
	static var INSTANCE:CharVueMixin;
	public static function getSampleInstance():CharVueMixin {
		return (INSTANCE != null  ? INSTANCE : INSTANCE = new CharVueMixin());
	}
	
	
	// inventory
	
	@:computed  function get_encumbered():Bool   { return this.totalWeight >= this.CAR;  }
	
	@:computed  function get_totalWeight():Float   { return this.char.totalWeight;  }
	@:computed  function get_encumberanceLvl():Int   { return this.char.encumbranceLvl;  }

	// derived 
	@:computed function get_adr():Int { return this.char.adr;  }
	@:computed  function get_mob():Int   { return this.char.mob;  }
	@:computed  function get_car():Int  { return this.char.car;  }
	@:computed  function get_cha():Int  { return this.char.cha;  }
	@:computed  function get_tou():Int   { return this.char.tou;  }

	// derived with mods
	@:computed  function get_ADR():Int {
		return this.char.ADR;
	}
	
	@:computed  function get_MOB():Int 
	{
		return this.char.MOB;
	}
	
	@:computed  function get_CAR():Int 
	{
		return this.char.CAR;
	}
	
	@:computed  function get_CHA():Int 
	{
		return this.char.CHA;
	}
	
	@:computed  function get_startingGrit():Int 
	{
		return this.char.startingGrit;
	}
	
	@:computed  function get_TOU():Int 
	{
		return this.char.TOU;
	}
	
	@:computed  function get_GRIT():Int 
	{
		return this.char.GRIT;
	}

	@:computed  function get_baseGrit():Int 
	{
		return this.char.baseGrit;
	}
	
	// base with modifiers
	@:computed function get_STR():Int { return this.char.STR;  } 
	@:computed function get_AGI():Int { return this.char.AGI;  } 
	@:computed function get_END():Int { return this.char.END;  } 
	@:computed function get_HLT():Int {return this.char.HLT;  } 
	@:computed function get_WIP():Int { return this.char.WIP;  } 
	@:computed function get_WIT():Int { return this.char.WIT;  } 
	@:computed function get_INT():Int { return this.char.INT;  } 
	@:computed function get_PER():Int { return this.char.PER;  } 
	
	// raw without modifiers
	@:computed function get_strength():Int { return this.char.strength;  } 
	@:computed function get_agility():Int { return this.char.agility;  } 
	@:computed function get_endurance():Int { return this.char.endurance;  } 
	@:computed function get_health():Int {return this.char.health;  } 
	@:computed function get_willpower():Int { return this.char.willpower;  } 
	@:computed function get_wit():Int { return this.char.wit;  } 
	@:computed function get_intelligence():Int { return this.char.intelligence;  } 
	@:computed function get_perception():Int { return this.char.perception;  } 
	
	
	// everything else bleh.. (violates DRY but ah well..)
	
	@:computed inline function get_SDB():Int 
	{
		return this.char.SDB;
	}
	
	@:computed inline function get_labelRace():String 
	{
		return this.char.labelRace;
	}

	
	@:computed inline function get_labelSchool():String 
	{
		return this.char.labelSchool;
	}
	
	
	@:computed inline function get_baseCP():Int {
		return this.char.baseCP;
	}
	
	@:computed inline function get_CP():Int {
		return this.char.CP;
	}
	
	@:computed inline function get_meleeCP():Int 
	{
		return this.char.meleeCP;
	}
		
	@:computed inline function get_totalPain():Int 
	{
		return this.char.totalPain;
	}
	@:computed inline function get_totalBloodlost():Int 
	{
		return this.char.totalBloodLost;
	}
	
	@:computed inline function get_schoolCP():Int 
	{
		return this.char.schoolCP;
	}
	
	@:computed function get_arcPointsAvailable():Int 
	{
		return this.char.arcPointsAvailable;
	}
	

	@:computed function get_skillPenalty():Int 
	{
		return this.char.skillPenalty;
	}
	
	@:computed function get_recoveryRate():Int 
	{
		return this.char.recoveryRate;
	}
	
	@:computed function get_exhaustionRate():Int 
	{
		return this.char.exhaustionRate;
	}
	
}

typedef CharVueMixinData = {
	var char:CharSheet;
}