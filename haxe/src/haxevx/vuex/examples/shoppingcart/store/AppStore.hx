package haxevx.vuex.examples.shoppingcart.store;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VxStore;
import haxevx.vuex.examples.shoppingcart.modules.Cart;
import haxevx.vuex.examples.shoppingcart.modules.ProductList;

/**
 * Implemented VxStores do not have constructors by default and will be automatically intiialized by root application component
 * depending on the store type supplied to the generic component.
 * @author Glidias
 */
@:rtti
class AppStore extends VxStore<NoneT>   // In this example, the main store does not hold any state data by itself (use NoneT)
{

	// Mark modules with "@module" metadata. In this example, the modules contain their own state data, but such data is kept private.
	@module public var cart:Cart;
	@module public var products:ProductList;

	
}