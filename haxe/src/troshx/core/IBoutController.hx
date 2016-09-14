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
  
  function setBout(val:Bout):Void;
  
  function getMessages():Array<BoutMessage>;
  function getMessagesCount():Int;
}