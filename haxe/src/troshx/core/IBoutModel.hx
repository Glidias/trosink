package troshx.core;
import troshx.components.Bout;

/**
 * @author Glidias
 */
interface IBoutModel 
{
  function setBout(val:Bout):Void;
  function getMessages():Array<BoutMessage>;
  function getMessagesCount():Int;
  function clearMessages():Void;
}