package haxevx.vuex.examples.shoppingcart.store;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VxStore;
import haxevx.vuex.examples.shoppingcart.modules.Cart;
import haxevx.vuex.examples.shoppingcart.modules.ProductList;

/**
 * ...
 * @author Glidias
 */
@:rtti
class AppStore extends VxStore<NoneT>
{

	@module public var cart:Cart;
	@module public var products:ProductList;
	
	public function new() 
	{
		
	}
	
}