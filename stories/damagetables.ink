
=== function applyWound(applyPain,  applyBL,  applyShock,  ref charPartShock, ref charPartPain, ref charPartBL )
{
	- applyShock  == -1:	
		~charPartShock = 999
}
{
	- applyPain  == -1:	
		~charPartPain = 999
}
{
	- applyShock > 0 && applyShock > charPartShock:
		~charPartShock = applyShock
}
{
	- applyPain > 0 && applyPain > charPartPain:
		~charPartPain = applyPain
}
{
	- applyBL > charPartBL:
		~charPartBL = applyBL
}


=== function getPartWoundDamages(targetPart, woundLevel, damageType, ref applyPain, ref applyBL, ref applyShock)
{
	///* bodyparts var
	- targetPart == "bodyPartName": 
	{
		 
		-damageType== DAMAGE_TYPE_CUTTING:
			{
			- woundLevel == 1:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 2:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 3:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 4:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 5:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- else:
				~applyPain = 0
				~applyBL = 0
				~applyShock = 0
			}
		-damageType== DAMAGE_TYPE_PUNCTURING:
			{
			- woundLevel == 1:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 2:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 3:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 4:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 5:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- else:
				~applyPain = 0
				~applyBL = 0
				~applyShock = 0
			}
		-damageType== DAMAGE_TYPE_BLUDGEONING:
			{
			- woundLevel == 1:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 2:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 3:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 4:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- woundLevel == 5:
				~applyPain = 1
				~applyBL = 1
				~applyShock = 1
			- else:
				~applyPain = 0
				~applyBL = 0
				~applyShock = 0
			}
		else:
			~elseResulted = 1
	}
	~return targetPart
	//*/
	-else:
		~elseResulted = 1
}


=== function inflictWoundOn(charId, targetPart, woundLevel, damageType, ref shockToApply, ref painCollector, ref bloodCollector)
~temp applyPain
~temp applyBL
~temp applyShock
{ 
///* utest player bodyparts
- charId == charPersonName_id: 
 	{
		-targetPart:
			 ~getPartWoundDamages(targetPart, woundLevel, damageType, applyPain, applyBL, applyShock)
			///* bodyparts
			{ 
				-targetPart == charPersonName_wound_bodyPartName:
					~applyWound(applyPain, applyBL, applyShock, charPersonName_wound_bodyPartName_shock,  charPersonName_wound_bodyPartName_pain, charPersonName_wound_bodyPartName_BL)
					~shockToApply = charPersonName_wound_bodyPartName_shock
					//charPersonName_wound_bodyPartName_cutLevelFreshMask
			}
			//*/
			~return
		- else:
			///* bodyparts
			~painCollector = painCollector + charPersonName_wound_bodyPartName_pain
			~bloodCollector = bloodCollector + charPersonName_wound_bodyPartName_BL
			//*/
	}
//*/
///* utest bodyparts
- charId == charPersonName2_id: 
	{
		-targetPart:
			 ~getPartWoundDamages(targetPart, woundLevel, damageType, applyPain, applyBL, applyShock)
			///* bodyparts
			{ 
				-targetPart == charPersonName2_wound_bodyPartName:
					~applyWound(applyPain, applyBL, applyShock, charPersonName2_wound_bodyPartName_shock,  charPersonName2_wound_bodyPartName_pain, charPersonName2_wound_bodyPartName_BL)
					~shockToApply = charPersonName2_wound_bodyPartName_shock
			}
			//*/
			~return
		- else:
			///* bodyparts
			~painCollector = painCollector + charPersonName2_wound_bodyPartName_pain
			~bloodCollector = bloodCollector + charPersonName2_wound_bodyPartName_BL
			//*/
	}
//*/
-else:
	~elseResulted = 1
}