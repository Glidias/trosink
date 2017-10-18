package troshx.sos.vue;
import haxe.Unserializer;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.chargen.CharGenData;
import troshx.sos.chargen.CharGenSkillPackets;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.Skill;
import troshx.sos.core.Skill.SkillObj;
import troshx.sos.core.Skill.SkillTable;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.input.MixinInput;
import troshx.sos.vue.inputs.impl.BoonBaneInput;
import troshx.sos.vue.inputs.impl.InputNameLabel;
import troshx.sos.vue.inputs.impl.SkillLibInput;
import troshx.sos.vue.uifields.ArrayOf;
import troshx.sos.vue.uifields.ArrayOfBits;
import troshx.sos.vue.widgets.BoonBaneApplyDetails;
import troshx.sos.vue.widgets.SchoolSheetDetails;
import troshx.sos.vue.widgets.SkillSubjectCreator;
import troshx.util.LibUtil;



/**
 * ...
 * @author Glidias
 */
class CharSheetVue extends VComponent<CharSheetVueData,CharSheetVueProps>
{

	public function new() 
	{
		super();
		untyped this.mixins = [
			CharVueMixin.getSampleInstance(),
			MixinInput.getInstance()
		];
	}
	

	override function Data():CharSheetVueData {
		return new CharSheetVueData();
	}
	
	override function Created():Void {
		//_vData.privateInit();
		//untyped CharGenData.dynSetField = Vue.set;
		//untyped CharGenData.dynDeleteField = Vue.delete;
		//untyped CharGenData.dynSetArray = Vue.set;
	}

	
	function exitInventory():Void {
		
		insideInventory = false;
		/*
		Vue.nextTick( function() {
			var htmlElement:HtmlElement = _vRefs.checkoutHeader;
			Browser.window.scroll({top:htmlElement.offsetTop});
		});
		*/
	}
	
	
	function proceedToInventory():Void {
		

		insideInventory = true;
		/*
		Vue.nextTick( function() {
			var htmlElement:HtmlElement = _vRefs.inventoryHolder;
			Browser.window.scroll({top:htmlElement.offsetTop});
		});
		*/
	}
	public function saveFinaliseSkills():Void {
	
		for ( i in 0...skillObjs.length) {
			var s = skillObjs[i];
			var total = LibUtil.field(skillValues, s.name);
			if (total > 0 ) {
				//trace("Setting skill:" + s.name + " = " + total);
				char.skills.setSkill(s.name, total);
			}
		}
	}
	
	var maxAvailableProfSlots(get, never):Int;
	inline function get_maxAvailableProfSlots():Int {
		return char.school!=null ? char.school.profLimit : 0;
	}
	
	var maxMeleeProfSlots(get, never):Int;
	function get_maxMeleeProfSlots():Int {
		var r =  maxAvailableProfSlots - profCoreListRanged.length;
		return char.school!=null ? r < 0 ? 0 : r 
		: 0;
	}
	
	var maxRangedProfSlots(get, never):Int;
	function get_maxRangedProfSlots():Int {
		var r =  maxAvailableProfSlots - profCoreListMelee.length;
		return char.school!=null ? r < 0 ? 0 : r 
		: 0;
	}
	

	@:computed function get_talentsAvailable():Array<Int> {
		return CharGenData.getTalentsAvailable();
	}
	
	@:computed function get_superiorsAvailable():Array<Int> {
		return CharGenData.getSuperiorsAvailable();
	}
	var maxTalentSlots(get, never):Int;
	function get_maxTalentSlots():Int {
		var r = char.schoolLevel > 0 ? talentsAvailable[char.schoolLevel-1] : 0;
		return char.school !=null ? r : 0;
	}
	
	var maxSuperiorSlots(get, never):Int;
	function get_maxSuperiorSlots():Int {
		var r = char.schoolLevel > 0 ? superiorsAvailable[char.schoolLevel-1] : 0;
		return char.school !=null ? r : 0;
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			
			BoonBaneInput.NAME => new BoonBaneInput(),
			BoonBaneApplyDetails.NAME => new BoonBaneApplyDetails(),
			
			SkillLibInput.NAME => new SkillLibInput(),
			SkillSubjectCreator.NAME => new SkillSubjectCreator(),
			
			InputNameLabel.NAME => new InputNameLabel(),
			
			ArrayOf.NAME => new ArrayOf(),
			ArrayOfBits.NAME => new ArrayOfBits(),
			
			"inventory" => new InventoryVue()
		];
	}
	
	// duplicate from chargendata, but without the packet line at the end...
	public function deleteSkillInput(index:Int):Void {
		var obj = skillObjs[index];
		var spl = Skill.getSplitFromSpecialisation(obj.name);
		var skill = spl[0];
		var special = spl[1];
		
		
		var skillToSpecial:Array<String> = LibUtil.field(skillSubjectHash, skill);
		var specialToSkill:Array<String>  = LibUtil.field(skillSubjectHash, special);
		skillToSpecial.splice( skillToSpecial.indexOf(special), 1 );
		specialToSkill.splice( skillToSpecial.indexOf(skill), 1 );
		CharGenData.dynDeleteField(skillValues, obj.name);
		
		skillObjs.splice(index, 1);
	}
	
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	@:computed function get_placeholder():String {
		return "[placeholder]";
	}
}

typedef CharSheetVueProps = {
	@:prop({required:false}) @:optional var exitBtnCallback:Void->Void;
	@:prop({required:false}) @:optional var finaliseSaveCallback:String->Void;
}


class CharSheetVueData {
	var showBnBs:Bool = true;
	var insideInventory:Bool = false;
	var char:CharSheet;
	var boonAssignList:Array<BoonAssign>;
	var baneAssignList:Array<BaneAssign>;
	
	var skillValues:Dynamic<Int>;
	var skillsTable:SkillTable;
	var skillObjs:Array<SkillObj>;
	var startingSkillObjsCount:Int;
	var specialisedSkills:Array<String>;
	var skillSubjectHash:Dynamic<Array<String>>;
	
	// todo
	//var skillSubjects:Array<String>;
	//var skillSubjectsInitial:Dynamic<Bool>;
	
	var profCoreListMelee:Array<Int> = [];
	var profCoreListRanged:Array<Int> = [];
	
	
	public function new(char:CharSheet = null) {
		this.char = char == null ? getSampleChar() : char;
		
		initBoons();
		initSkills();
		initProfs();
	}
	
	
	
	function getSampleChar():CharSheet {
		var s:Unserializer = new Unserializer( VHTMacros.getHTMLStringFromFile("src/troshx/sos/vue/samplechar", "txt") );
		return s.unserialize();
	}
	
	function initProfs():Void {
		// todo: link with char's existing melee/ranged profs
		
	}
	
	function initBoons():Void {
		// todo: link with char
		
		var boonList:Array<Boon> = Boons.getList();
		this.boonAssignList = [];
		this.baneAssignList = [];
		var bb:BoonBane;
		
		for (i in 0...boonList.length) {
			bb =  boonList[i];
			
			if (bb.costs != null) {
				var ba;
				this.boonAssignList.push(  ba = boonList[i].getAssign(0, this.char) );
				//ba._costCached = bb.costs[0];
				ba._remainingCached = 999;
			}
		}
		var baneList:Array<Bane> = Banes.getList();
		for (i in 0...baneList.length) {
			bb = baneList[i];
			if (bb.costs != null) {
				var ba;
				this.baneAssignList.push(ba = baneList[i].getAssign(0, this.char) );
				//ba._costCached = bb.costs[0];
			}
		}
	}
	
	
	function initSkills():Void {  // somewhat similar to CharGenData, but without packets
		// todo: link with char
		
		skillsTable = SkillTable.getNewDefaultSkillTable();
		skillObjs = skillsTable.getSkillObjectsAsArray(true);
		specialisedSkills = skillsTable.getSpecialisationList();
		setupEmptyMappings();
		
		skillSubjectHash = {};
		
		for (f in Reflect.fields(skillValues)) {
			var arr = Skill.getSplitFromSpecialisation(f);
			if (arr != null) {
				var skill = arr[0];
				var special = arr[1];
				var skillToSpecial:Array<String>;
				var specialToSkill:Array<String>;
				if ( (skillToSpecial=LibUtil.field(skillSubjectHash, skill)) == null ) {
					LibUtil.setField(skillSubjectHash, skill, skillToSpecial=[]);
				}
				if ( (specialToSkill=LibUtil.field(skillSubjectHash, special)) == null ) {
					LibUtil.setField(skillSubjectHash, special, specialToSkill=[]);
				}
				skillToSpecial.push(special);
				specialToSkill.push(skill);
			}
		}
		
		startingSkillObjsCount = skillObjs.length;
	}
	

	function setupEmptyMappings():Void
	{
	
		
		var arrAdded:Array<SkillObj> = [];
		
		this.skillValues = {};
		
		for (f in Reflect.fields(skillsTable.skillHash)) {
			if ( !skillsTable.requiresSpecification(f) ) {
				LibUtil.setField(this.skillValues, f, 0);
			}
		}
		arrAdded.sort(SkillTable.sortArrayMethod);
		skillObjs = skillObjs.concat(arrAdded);
		
		/*
		skillSubjects = CharGenSkillPackets.getExistingSubjects();
		var reflectedExisting:Dynamic<Bool> = {};
		for ( i in 0...skillSubjects.length) {
			LibUtil.setField(reflectedExisting, skillSubjects[i], true);
		}
		skillSubjectsInitial = reflectedExisting;
		*/
		
	}

}
