package haxevx.vuex.examples;


import haxevx.vuex.core.IVxStore;
import haxevx.vuex.core.IVxStoreContext;
import js.Promise;

/**
 * ...
 * @author Glidias
 */
@:rtti
class AppDispatcher
{


	// dispatch helper methods
	public static function moveToAsync<T>(position:{ x : Int,  y : Int }, ?context:IVxStoreContext<T>):Promise<Bool>  {
		return moveToAsync_handler(context, position);
	}
	
	public static function temporaryATM<T>(position:{ x : Int,  y : Int }, ?context:IVxStoreContext<T>):Promise<Bool>  {
		return EMPTY_HANDLER_PROMISE(context, position);
	}
	
	
	//-------------------------
	
	// Consider, factor out specific app handlers to seperate class fuile, put as reference in metadata
	
	// action handlers
	static function moveToAsync_handler<T>(context:IVxStoreContext<T>, position:{ x : Int,  y : Int }):Promise<Bool>  {
		
		return new Promise( function(resolve, reject):Void {
			AppMutator.moveTo(position, context);
			resolve(true);
		}
		);  // promise
	}
	
	// ---------------------
	
	// testing/ mock handlers
	
	//
	static function EMPTY_HANDLER<T>(context:IVxStoreContext<T>, payload:Dynamic=null):Void  {}
	static function EMPTY_HANDLER_PROMISE<T, R>(context:IVxStoreContext<T>, payload:Dynamic=null):Promise<Bool>  {
		return new Promise( function(resolve, reject):Void {	
			resolve(false);
		}
		);
	}

	
	
}