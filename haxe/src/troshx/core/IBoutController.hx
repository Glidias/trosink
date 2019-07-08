package troshx.core;


/**
 * @author Glidias
 */
interface IBoutController 
{
  
  function step():Void;
  
  // Return >0 bitmask value if a combatant input response (number slot of combatant) is required before continuing with step()
  // Return 0 if nothing required
  // Return -1 (or lower than 0) value for requiring every combatant response 
  function handleCurrentStep():Int;
  

}