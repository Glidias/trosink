package troshx.core;


class CharSave { 
	public var savedData:String;
	public var label:String;
	public var description:String;
	public function new(label:String, data:String, description:String="") {
		this.label = label;
		this.savedData = data;
		this.description = description;
	}
}