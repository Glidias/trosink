package haxevx.vuex.examples.shoppingcart;
import haxevx.vuex.examples.shoppingcart.components.App;
import haxevx.vuex.examples.shoppingcart.store.AppStore;

/**
 * Port of https://github.com/vuejs/vuex/tree/dev/examples/shopping-cart to HaxeVX
 * @author Glidias
 */
class ShoppingCartMain
{

	public function new() 
	{
		
		var store = new AppStore();
		var rootComponent = new App();
		
	}
	
}