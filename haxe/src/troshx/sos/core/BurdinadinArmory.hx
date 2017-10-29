package troshx.sos.core;

/**
 * Empty filler classes for now. todo specs
 * @author Glidias
 */

 class BurdinadinArmory
{

	
}

class BurdinadinArmor 
{
	public var insulation:Int = 0;
	public var augmentations:Int = 0;

	public function new() 
	{
		
	}
	
	public function addTagsToStrArr(arr:Array<String>):Void
	{
		if (insulation != 0) {
			arr.push("Insulation "+insulation);
		}
		if (augmentations != 0) {
			arr.push("Augmentations ("+ augmentations+")");
		}
	}
	
}


/*
class BurdinadinWeapon 
{

	public function new() 
	{
		
	}
	
}
*/