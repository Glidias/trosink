package troshx.sos.chargen;

/**
 * ...
 * @author Glidias
 */
class CategoryPCP 
{
	public var pcp:Int = 0;
	public var name:String;
	public var magic:Bool;
	public var slug:String;
	public function new(name:String, magic:Bool=false) 
	{
		this.name = name;
		this.magic = magic;
	}
	

}