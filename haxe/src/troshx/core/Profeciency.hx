package troshx.core;

/**
 * ...
 * @author Glidias
 */
class Profeciency {
	public var id:String;
	public var name:String;
	public var offensiveManuevers:Int;
	public var defensiveManuevers:Int;
	public var atkCosts:Dynamic;
	public var defCosts:Dynamic;
	public var defaults:Dynamic;
	
	public var index:Int;  // for internal use

	public function new(id:String, name:String, offensiveManuevers:Int, defensiveManuevers:Int, atkCosts:Dynamic=null, defCosts:Dynamic=null, defaults:Dynamic=null) {
		this.id = id;
		this.name = name;
		this.offensiveManuevers = offensiveManuevers;
		this.defensiveManuevers = defensiveManuevers;
		this.atkCosts = atkCosts!=null ? atkCosts : { };
		this.defCosts = defCosts!=null ? defCosts : { };
		this.defaults = defaults!=null ? defaults : { };
	}

}