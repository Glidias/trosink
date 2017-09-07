package troshx.sos.chargen;

/**
 * ...
 * @author Glidias
 */
class CampaignPowerLevel 
{

	public var name:String;
	public var pcp:Int;
	public var maxCategoryPCP:Int;
	
	public function new(name:String, pcp:Int, maxCategoryPCP:Int) 
	{
		this.name = name;
		this.pcp  = pcp;
		this.maxCategoryPCP = maxCategoryPCP;
	}
	
}