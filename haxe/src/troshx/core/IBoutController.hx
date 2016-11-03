package troshx.core;
import troshx.components.Bout;
import troshx.core.BoutMessage;

/**
 * @author Glidias
 */
interface IBoutController 
{
  
  function step():Void;
  
  function handleCurrentStep():Bool;
  

}