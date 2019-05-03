package troshx.core;
import troshx.components.Bout;
import troshx.core.BoutMessage;

/**
 * @author Glidias
 */
interface IBoutModel<C>
{
  function setBout(val:Bout<C>):Void;
  function getMessages():Array<BoutMessage>;
  function getMessagesCount():Int;
  function clearMessages():Void;
}