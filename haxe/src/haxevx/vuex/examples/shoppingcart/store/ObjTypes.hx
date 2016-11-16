package haxevx.vuex.examples.shoppingcart.store;

/**
 * Generic object/payload data types
 * @author Glidias
 */

 // Objects
 
typedef ProductInCart = {
	id:String,
	quantity:Int
}

typedef ProductInStore = {
	id:String,
	inventory:Int
}


// Payload

typedef ProductIdentifier = {
	id:String
}

