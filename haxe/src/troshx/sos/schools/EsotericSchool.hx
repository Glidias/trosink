package troshx.sos.schools;

import troshx.sos.core.Item;
import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class EsotericSchool extends School
{

	public function new() 
	{
		super("Esoteric School", 3, 5);
		costMoney = Money.create(15, 0, 0);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new EsotericSchoolBonuses();
	}
	
}

class EsotericSchoolBonuses extends SchoolBonuses {
	
	@:flag public static inline var SIMPLICITY:Int = (1<<0);
	@:flag public static inline var FLOWING_WATER:Int = (1<<1);
	@:flag public static inline var RAGING_FLAME:Int = (1<<2);
	@:flag public static inline var BITING_WIND:Int = (1 << 3);
	@:flag public static inline var STOIC_EARTH:Int = (1 << 4);
	
	@:ui({type:"SingleSelection", label:"Choose Benefit(s)", labels:["Simplicity, Flowing Water", "Raging Flame", "Biting Wind", "Stoic Earth"], values:[SIMPLICITY|FLOWING_WATER, RAGING_FLAME, BITING_WIND, STOIC_EARTH] }) public var flags:Int = SIMPLICITY|FLOWING_WATER;
	
	public function new() {
		super();
	}
	
	override public function getTags():Array<String> {
		var arr:Array<String> = [];
		var flags:Int = this.flags;
		Item.pushFlagLabelsToArr(true, "troshx.sos.schools.EsotericSchool:EsotericSchoolBonuses", false, ":flag");
		return arr;
	}
}