package troshx.sos.bnb;
import troshx.sos.bnb.Banes.BadEars;
import troshx.sos.bnb.Banes.Blind;
import troshx.sos.bnb.Banes.Mute;
import troshx.sos.bnb.Banes.OneEyed;
import troshx.sos.bnb.LastingPain.LastingPainAssign;
import troshx.sos.bnb.OldWound.OldWoundAssign;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class BrainDamage extends Bane {
	public function new() {
		super("Brain Damage", [4,8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING;	
		this.clampRank = true;
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return  new BrainDamageAssign(charSheet);
	}
}

class BrainDamageAssign extends BaneAssign {
	var char:CharSheet;
	

	@:ui({label:"Trigger Brain Damage (4)", type:"ButtonCounter", callback:callbackUITrigger, preventDefault:true }) var count1:Int = 0;
	@:ui({label:"Trigger Brain Damage (8)", type:"ButtonCounter", callback:callbackUITrigger, preventDefault:true }) var count2:Int = 0;

	var oldWound:OldWoundAssign;
	var lastingPain:LastingPainAssign;
	var mute:BaneAssign;
	var badEyes:BaneAssign;
	var badEars:BaneAssign;
	var blind:BaneAssign;
	var oneEyed:BaneAssign;

	
	public function new(char:CharSheet) {
		super();
		this.char = char;
		
		oldWound = cast new OldWound().getAssign(1, char);
		mute = cast new Mute().getAssign(1, char);
		lastingPain = cast new LastingPain().getAssign(1, char);
		badEyes = new BadEyes().getAssign(1, char);
		badEars = new BadEars().getAssign(1, char);
		blind = new Blind().getAssign(1, char);
		oneEyed = new OneEyed().getAssign(1, char);
	}
	
	function callbackUITrigger(obj:Dynamic, prop:String):Dynamic {
		execute(prop == "count1" ? 0 : 1);
		return baneQueue;
	}
	
	function gainBane(baneAssign:BaneAssign, rank:Int):Void {
		/*
		if ( char.banes.contains(baneAssign) ) {
			baneAssign = char.banes.findById(baneAssign.uid);
		}
		else {
			//char.banes.add(baneAssign);
		}
		*/
		var rankSet:Int =  baneAssign.bane.clampRank ? 1 : rank;
		if (baneAssign.rank >= rankSet) {
			rankSet = baneAssign.rank;
		}
		baneAssign.rank = rankSet;
		baneAssign._minRequired = rankSet;
		baneAssign.discount = baneAssign._costCached = baneAssign.getCost(rankSet);
		//baneAssign._forcePermanent = true;
		
		baneQueue.push(baneAssign);
		
	}
	
	public var baneQueue(default, null):Array<BaneAssign>;
	
	public function execute(indexRank:Int):Void {
		_minRequired = 1;
		
		var add2:Int;
		if (indexRank == 0) {
			count1++;
			add2 = 0;
		}
		else {
			count2++;
			add2 = 2;
		}
		
		if (char.ingame) {
			char.intelligence -= Std.int(Math.random() * (indexRank == 0 ? 2 : 5) ) + 1;
		}
		
		baneQueue = [];
		var rIndex:Int = Std.int( Math.random() * 10 ) + add2 + 1;
		switch (rIndex) {
			case 1:
			case 2:
			case 3:
			case 4:
				gainBane(badEyes, 1);
			case 5:
				gainBane(badEars, 2);
			case 6:
				gainBane(oldWound.inflictRandom(), 1);
				gainBane(badEars, 1);
			case 7:
				gainBane(oldWound.inflictRandom(),1);
				gainBane(badEars, 2);
			case 8:
				gainBane(oldWound.inflictRandom(), 1);
				gainBane(oneEyed, 1);
			case 9:
				gainBane(oldWound.inflictRandom(), 1);
				gainBane(mute, 1);
			case 10:
				gainBane(oldWound.inflictRandom(), 1);
				gainBane(lastingPain.inflictRandomMinor(), 1);
			case 11:
				gainBane(oldWound.inflictRandom(), 1);
				gainBane(lastingPain.inflictRandomMinor(), 1);
				if (char.ingame) char.intelligence-= 2;
			case 12:
				gainBane(oldWound.inflictRandom(), 1);
				gainBane(lastingPain.inflictRandomMajor(), 2);
				gainBane(blind, 1);
			default:
				trace("Warning, unforeseen roll index number detected: " + rIndex);
		}
	}
	
	override function getCost(rank:Int):Int {
		return count1 * 4 + count2 * 8;
	}
	
	
	
}


