package haxevx.vuex.examples;

 typedef AppState =  {
	value:Int,
	matrixAB: {
		a:Int,
		b:Int,
		nested: {
			c:Int,
			d:Int
		}
		
	},
	coordinates:Array<Float>,
	position: {
		x:Int,
		y:Int,
		z:Int
	}
}
