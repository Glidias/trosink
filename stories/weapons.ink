// Stateless stats and their retrieval methods for Weapons

CONST ATTR_BASE_NONE = -1
CONST ATTR_BASE_STRENGTH = 0

=== function getWeaponStatsForManueverFilter(weaponId, ref isShield, ref dtn, ref dtnT, ref atn, ref atn2, ref blunt) 
~temp x
{ getAllWeaponStats(weaponId,x,isShield,x,x,x,x,  dtn, dtnT, atn, atn2, blunt) }

=== function getAllWeaponStats(weaponId, ref name, ref isShield, ref damage, ref damage2, ref damage3, ref attrBaseIndex,  ref dtn, ref dtnT, ref atn, ref atn2, ref blunt   )
{
- weaponId == "gladius":
	~name = "Gladius"
	~isShield = 0
	~damage = 2
	~damage2 = 2
	~damage3 = 0
	~attrBaseIndex = ATTR_BASE_STRENGTH
	~dtn = 6
	~dtnT = 0
	~atn = 6
	~atn2 = 6
	~blunt =0
~return
- weaponId == "mace":
	~name = "Mace"
	~isShield = 0
	~damage = 2
	~damage2 = 2
	~damage3 = 4
	~attrBaseIndex = ATTR_BASE_STRENGTH
	~dtn = 4
	~dtnT = 0
	~atn = 6
	~atn2 = 6
	~blunt = 1
~return
- weaponId == "shield":
	~name = "Shield"
	~isShield = 1
	~damage = 0
	~damage2 = 0
	~damage3 = 0
	~attrBaseIndex = ATTR_BASE_STRENGTH
	~dtn = 4
	~dtnT = 0
	~atn = 0
	~atn2 = 0
	~blunt = 1
~return
}
// default empty NOTHING weapon below (remember to '~return' switch cases above to early-exit!!)
~name =""
~isShield = 0
~damage = 0
~damage2 = 0
~damage3 = 0
~attrBaseIndex = ATTR_BASE_NONE
~dtn = 0
~dtnT = 0
~atn = 0
~atn2 = 0
~blunt = 0