package haxevx.vuex.core;

/**
 * @author Glidias
 */
interface IVxStoreContext<T> extends IVxStore
{
  var state:T;
  function dispatch(type:String, payload:Dynamic=null):Void;
  function commit(type:String, payload:Dynamic = null):Void;
}