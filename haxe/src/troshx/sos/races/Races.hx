package troshx.sos.races;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.core.Race;
import troshx.sos.macro.MacroUtil;
import troshx.sos.races.Races.Orredin;
import troshx.sos.races.Races.Zell;

/**
 * // TOOD:skill modifiers for fairness, and named tags for those modifiers, and all other modifiers for Races
 * @author Glidias
 */
class Races
{
	/* // yagni atm. might think of another way
	public static var RACE_HUMAN:Int = 0;
	public static var RACE_GOBLIN:Int = 0;
	public static var RACE_HUMAN:Int = 0;
	public static var RACE_HUMAN:Int = 0;
	public static var RACE_HUMAN:Int = 0;
	public static var RACE_HUMAN:Int = 0;
	public static var RACE_HUMAN:Int = 0;
	public static var LIST:Array<Race>;
	*/
	
	public static var PCP_FOR_TIERS:Array<Int> =  [1, 2, 4, 6, 8];
	
	static var TIERS:Array<Array<Race>>;
	public static function getTiers():Array<Array<Race>> {
		return TIERS != null ? TIERS : (TIERS = getNewTiers());
	}
	public static function getNewTiers():Array<Array<Race>> {
		return [
			[new Human(), new Goblin()],
			[new Dwarf(), new Zell()],
			[new Burdinadin(), new Ohanedin()],
			[new Orredin()],
			[new StarVampire(),new SaturiChosen(), new GenosianPaladin(), new DessianSilverGuard()]
		];
	}
}


class Human extends Race {
	public function new() {
		super("Human");
	}
}
class Goblin extends Race {
	public function new() {
		super("Goblin");
		MacroUtil.linkedListFromArray(staticModifiers,  [
			StaticModifier.create(Modifier.ATTR_STR, -1),
			StaticModifier.create(Modifier.ATTR_AGI, 1),
			StaticModifier.create(Modifier.ATTR_PER, 1),
			// stuff for goblins
			StaticModifier.create(Modifier.CMP_MOB, -2),	
			StaticModifier.create(Modifier.REACH, -2)	
		]);
	}
}
class Dwarf extends Race {
	public function new() {
		super("Dwarf");
		MacroUtil.linkedListFromArray(staticModifiers,  [
			StaticModifier.create(Modifier.ATTR_END, 2),
			StaticModifier.create(Modifier.ATTR_HLT, 1),
			// stuff for dwarfs
			StaticModifier.create(Modifier.CMP_TOU, 1)
		]);
	}
}

class Zell extends Race {
	public function new() {
		super("Zell");
		MacroUtil.linkedListFromArray(staticModifiers,  [
			StaticModifier.create(Modifier.ATTR_AGI, 1),
			StaticModifier.create(Modifier.ATTR_PER, 2)
		]);
	}
}

class Burdinadin extends Race {
	public function new() {
		super("Burdinadin");
		MacroUtil.linkedListFromArray(staticModifiers,  [
			StaticModifier.create(Modifier.ATTR_INT, 1),
			StaticModifier.create(Modifier.ATTR_AGI, 1)
		]);
	}
}

class Ohanedin extends Race {
	public function new() {
		super("Ohanedin");
		MacroUtil.linkedListFromArray(staticModifiers,  [
			StaticModifier.create(Modifier.ATTR_STR, 1),
			StaticModifier.create(Modifier.ATTR_AGI, 1),
			StaticModifier.create(Modifier.ATTR_PER, 1)
		]);
	}
}

class Orredin extends Race {
	public function new() {
		super("Orredin");
		magic = true;
	}
}

class StarVampire extends Race {
	public function new() {
		super("Star Vampire");
		magic = true;
	}
}

class SaturiChosen extends Race {
	public function new() {
		super("Saturi Chosen");
	}
}

class GenosianPaladin extends Race {
	public function new() {
		super("Genosian Paladin");
	}
}

class DessianSilverGuard extends Race {
	public function new() {
		super("Dessian Silver Guard");
	}
}

