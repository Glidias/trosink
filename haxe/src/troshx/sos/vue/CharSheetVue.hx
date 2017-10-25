package troshx.sos.vue;
import haxe.Serializer;
import haxe.Timer;
import haxe.Unserializer;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.core.VxMacros;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.html.HtmlElement;
import js.html.TextAreaElement;
import troshx.sos.core.DamageType;
import troshx.sos.core.HitLocation;
import troshx.sos.core.Wound;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.chargen.CharGenData;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.Inventory;
import troshx.sos.core.Profeciency;
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
import troshx.sos.vue.uifields.Bitmask;
import troshx.sos.vue.uifields.MoneyField;
import troshx.sos.vue.widgets.BoonBaneApplyDetails;
import troshx.sos.vue.widgets.GingkoTreeBrowser;
import troshx.sos.vue.widgets.ModifierList;
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
			MixinInput.getInstance(),
			new InventoryStandalone(null)
		];
	}
	
	function setInventory(chk:Inventory):Void {
		this.char.inventory = chk;
	}
	
	@:computed function get_domainId():String {
		return Globals.DOMAIN_CHARACTER;
	}
	
	override function Mounted():Void {
		if (this.autoLoadChar != null) {
			openTreeBrowser();
		}
	}

	function recoverFatique(amt:Int):Void {
		this.char.fatique -= amt;
		if (this.char.fatique < 0) this.char.fatique = 0;
	}
	override function Data():CharSheetVueData {
		return new CharSheetVueData(this.injectChar);
	}
	
	/*  // yagni atm
	function openAwardArc():Void {
		
	}
	function openSpendArc():Void {
		
	}
	
	@:computed function get_maxArcSpendable():Int {
		return this.char.arcPointsAvailable;
		
	}
	@:computed function get_minArcSpendable():Int {
		return this.maxArcSpendable > 0 ? 1 : 0;
	}
	
	function awardArc(amt:Int):Void {
		this.char.arcPointsAccum += amt;
		this.sessionArcAwarded += amt;
	}
	
	function revokeArcAwarded():Void {
		this.char.arcPointsAccum  -= this.sessionArcAwarded;
		this.sessionArcAwarded = 0;
	}
	function revokeArcSpent():Void {
		this.char.arcSpent -= this.sessionArcSpent;
		this.sessionArcSpent = 0;
	}
	*/
	
	override function Created():Void {
		//_vData.privateInit();
		untyped CharSheet.dynSetField = Vue.set;
		untyped CharSheet.dynDeleteField = Vue.delete;
		//untyped CharGenData.dynDeleteField = Vue.delete;
		//untyped CharGenData.dynSetArray = Vue.set;
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
			Bitmask.NAME => new Bitmask(),
			
			MoneyField.NAME => new MoneyField(),
			
			ModifierList.NAME => new ModifierList(),
			
			"inventory" => new InventoryVue(),
			"inventory-manager" => new InventoryManager(),
			"tree-browser" => new GingkoTreeBrowser()
		];
	}
	
	function openTreeBrowser():Void {
		if (!treeBrowserInited) {
			treeBrowserInited = true;
		}
		Vue.nextTick( function() {
			_vRefs.treeBrowser.open();
		});
	}
	
	function openClipboardWindow():Void {
		clipboardLoadContents = "";
		_vRefs.clipboardWindow.open();
	}
	
	function openFromTreeBrowser(contents:String, filename:String, disableCallback:Void->Void):Void {

		if ( loadCharContents(contents) ) {
			_vRefs.treeBrowser.close();
		}
		this.autoLoadChar = null;
		
	}
	function openModifiersWindow():Void {
		_vRefs.modifiersWindow.open();
	}
	
		
	@:computed function get_availableTypes():Dynamic<Bool> {
		return {
			"troshx.sos.sheets.CharSheet": true
		};
	}
	
	@:computed function get_hasSampleWound():Bool {
		return this.char.hasWound(this.sampleWound);
	}
	
	@:computed function get_sampleWoundGotSide():Bool {
		return char.body.gotSideWithId( sampleWound.locationId );
	}
	
	function deleteWound(w:Wound):Void {
		this.char.removeWound(w);
	}
	
	function checkConfirmDeleteWound(w:Wound):Void {
		woundMayDelete = w;
		_vRefs.confirmDeleteWoundWindow.open();
	}
	
	function confirmDeleteWound():Void {
		deleteWound(woundMayDelete);
		_vRefs.confirmDeleteWoundWindow.close();
	}

	function confirmAddWound():Void {
		var lastWound:Wound = sampleWound;
		//sampleWound = Wound.getNewEmptyAssign();
		if (forceNewSampleWound) {
			lastWound.makeUnique();
		}
		sampleWound = null;
		this.char.applyWound(lastWound);
		_vRefs.addWoundWindow.close();
	}
	
	@:computed function get_woundFlagLabels():Array<String> {
		return Wound.getFlagLabels();
	}
	@:computed function get_damageTypeLabels():Array<String> {
		return DamageType.getFlagLabels();
	}

	function matchExistingSampleWound():Void {
		var sample:Wound = sampleWound;
		var wound:Wound = this.char.getWound(sample);
		sample.pain = wound.pain;
		sample.BL = wound.BL;
		sample.stun = wound.stun;
		
	}
	
	function openAddNewWound():Void {
		//if (sampleWound == null)
		sampleWound = Wound.getNewEmptyAssign();
		forceNewSampleWound = false;
		_vRefs.addWoundWindow.open();
	}
	
	function exitInventory():Void {
		
		insideInventory = false;
		///*
		Vue.nextTick( function() {
			var htmlElement:HtmlElement = _vRefs.inventoryHolder;
			Browser.window.scroll({top:htmlElement.offsetTop});
		});
		//*/
	}
	
	
	function proceedToInventory():Void {
		

		insideInventory = true;
		///*
		Vue.nextTick( function() {
			var htmlElement:HtmlElement = _vRefs.inventoryHolder;
			Browser.window.scroll({top:htmlElement.offsetTop});
		});
		//*/
	}

	function saveFinaliseSkills():Void {
		

		char.skills.clearAllSkills(true);
		for ( i in 0...skillObjs.length) {
			var ss = skillObjs[i];
			
			var total = LibUtil.field(skillValues, ss.name);
			if (total > 0 ) {
				//trace("Setting skill:" + s.name + " = " + total);
				char.skills.setSkill(ss.name, total);
			}
			
		}
	
	}
	
	function loadCharacter():Void {
		loadCharContents(this.savedCharContents);
		
	}
	
	function loadCharacterClipboardWindow():Void {
		if (loadCharContents(this.clipboardLoadContents)) {
			_vRefs.clipboardWindow.close();
		}
	}
	function loadCharContents(contents:String):Bool 
	{
		var newItem:Dynamic;
		
		try {
			newItem = new Unserializer(contents).unserialize();
		}
		catch (e:Dynamic) {
			trace(e);
			Browser.alert("Sorry, failed to unserialize save-content string!");
			return false;
		}
		if (!Std.is(newItem, CharSheet) ) {
		
			trace(newItem);
			Browser.alert("Sorry, unserialized type isn't CharSeet!");
			return false;
		}
		var me:CharSheet =  LibUtil.as(newItem, CharSheet);
		me.postSerialization();
		this.char = me;
		
		return true;
	}
	
	function saveCharacter():Void {
		saveFinaliseSkills();
		saveFinaliseCleanupChar();
		
		saveCharToBox();
	}
	
	function saveFinaliseCleanupChar():Void {
	
		char.boons.filter(function(bb) { return !bb._canceled;  } );
		char.banes.filter(function(bb) { return !bb._canceled;  } );
		
		char.inventory.cleanupBeforeSerialize();
	}
	
	
	function executeCopyContents():Void {
		var textarea:TextAreaElement = _vRefs.savedCharTextArea;
		
		textarea.select();
		var result:Bool = Browser.document.execCommand("copy");
		if (result != null) {
			//Browser.alert("Copied to clipboard.");
			var htmlElem:HtmlElement = _vRefs.copyNotify;
			htmlElem.style.display = "inline-block";
			Timer.delay( function() {
				htmlElem.style.display = "none";
			}, 3000);
		}
		else {
			Browser.alert("Sorry, failed to copy to clipboard!");
		}
	}
	
	function saveCharToBox():String
	{
		var s = new Serializer();
		s.useCache = true;
		s.serialize(this.char);
		var str = s.toString();
		this.savedCharContents = str;
		return str;
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
	
		
	function addSkill(skill:String, special:String):Void {
		
		var skillToSpecial:Array<String>;
		var specialToSkill:Array<String>;
		if ( (skillToSpecial=LibUtil.field(skillSubjectHash, skill)) == null ) {
			Vue.set(skillSubjectHash, skill, skillToSpecial=[]);
		}
		if ( (specialToSkill=LibUtil.field(skillSubjectHash, special)) == null ) {
			Vue.set(skillSubjectHash, special, specialToSkill=[]);
		}
		
		skillToSpecial.push(special);
		specialToSkill.push(skill);
		
		var name = Skill.specialisationName(skill, special);
		Vue.set(skillValues, name, 0);
		
		skillObjs.push({
			name: name,
			attribs:0	// for this case (or for now), this isn't needed
		});
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
	
	@:watch function watch_injectChar(newVal:CharSheet, oldVal:CharSheet):Void {
		this.char = newVal;
	}
	
	@:watch function watch_char(newVal:CharSheet):Void {
		_vData.initNewChar();
	}
}

typedef CharSheetVueProps = {
	@:prop({required:false}) @:optional var exitBtnCallback:Void->Void;
	@:prop({required:false}) @:optional var finaliseSaveCallback:String->Void;
	@:prop({required:false}) @:optional var injectChar:CharSheet;
}


class CharSheetVueData {
	//safety locks
	var lockAttributes:Bool = true;
	var lockBoons:Bool = true;
	var lockBanes:Bool = true;
	var lockProfs:Bool = true;
	var lockWealth:Bool = true;
	var lockArc:Bool = true;
	var lockWounds:Bool = true;
	
	var treeBrowserInited:Bool = false;
	
	//  view hide/show
	var showBnBs:Bool = false;
	var showEditSkills:Bool = false;
	
	// load
	var clipboardLoadContents:String = "";
	
	// save
	var savedCharContents:String = "";
	
	// blah
	var insideInventory:Bool;
	var char:CharSheet;
	var boonAssignList:Array<BoonAssign>;
	var baneAssignList:Array<BaneAssign>;
	
	var skillValues:Dynamic<Int>;
	var skillsTable:SkillTable;
	var skillObjs:Array<SkillObj>;
	var startingSkillObjsCount:Int;
	var specialisedSkills:Array<String>;
	var skillSubjectHash:Dynamic<Array<String>>;
	
	var skillSubjects:Array<String>;
	var skillSubjectsInitial:Dynamic<Bool>;
	
	var profCoreListMelee:Array<Int>;
	var profCoreListRanged:Array<Int>;
	
	// sampleWound
	var sampleWound:Wound;
	var woundMayDelete:Wound;
	var forceNewSampleWound:Bool = false;
	
	// arc session
	var sessionArcSpent:Int;
	var sessionArcAwarded:Int;
	var loadedArcAccum:Int;
	var loadedArcSpent:Int;
	var arcAwardQty:Int = 0;
	var arcSpendQty:Int = 0;
	
	var autoLoadChar:String;
	
	public function new(char:CharSheet = null) {
		this.char = char == null ? new CharSheet() : char;
		// getSampleChar()
		
		this.autoLoadChar = Globals.AUTO_LOAD;
		
		initNewChar();
	}
	
	public function initNewChar():Void {
		sampleWound = null;// Wound.getNewEmptyAssign();
		woundMayDelete = null;
		profCoreListMelee = [];
		profCoreListRanged = [];
		sessionArcSpent = 0;
		sessionArcAwarded = 0;
		insideInventory = false;
		loadedArcAccum = char.arcPointsAccum;
		loadedArcSpent = char.arcSpent;
		
		initBoons();
		initSkills();
		initProfs();
	}
	

	
	/*
	function getSampleChar():CharSheet {
		var s:Unserializer = new Unserializer( VHTMacros.getHTMLStringFromFile("src/troshx/sos/vue/samplechar", "txt") );
		
		var c:CharSheet =  s.unserialize();
		c.postSerialization();
		//c.addBoon( new Ambidextrous().getAssign(1, c) );  // for testing
		return c;
	}
	*/
	
	function initProfs():Void {
		for (i in 0...31) {
			if ( (char.profsMelee & (1<<i)) != 0) {
				profCoreListMelee.push( (1 << i));
			}
		}
		for ( i in 0...31) {
			if ( (char.profsRanged & (1<<i)) != 0) {
				profCoreListRanged.push( (1 << i));
			}
		}
		
	}
	
	function initBoons():Void {
	
		
		var boonList:Array<Boon> = Boons.getList();
		this.boonAssignList = [];
		this.baneAssignList = [];
		var bb:BoonBane;
		
		for (i in 0...boonList.length) {
			bb =  boonList[i];
			
			//if (bb.costs != null) {
				var ba =  char.boons.findById( bb.uid);
				if (ba != null) {
					this.boonAssignList.push(ba);
				}
				else if ( (bb.flags & BoonBane.CHARACTER_CREATION_ONLY)!=0 ) {
					continue;
					
				}
				else {
					this.boonAssignList.push(  ba = boonList[i].getAssign(0, this.char) );
				}
				
				//ba._costCached = bb.costs[0];
				ba._remainingCached = 999;
			//}
		}
		var baneList:Array<Bane> = Banes.getList();
		for (i in 0...baneList.length) {
			bb = baneList[i];
			//if (bb.costs != null) {
				var ba = char.banes.findById(bb.uid);
				
				if (ba != null) {
					this.baneAssignList.push(ba);
				}
				else if ( (bb.flags & BoonBane.CHARACTER_CREATION_ONLY)!=0 ) {
					continue;
					
				}
				else {
					this.baneAssignList.push(  ba = baneList[i].getAssign(0, this.char) );
				}
				//ba._costCached = bb.costs[0];
			//}
		}
		
	}
	
	
	function initSkills():Void {  // somewhat similar to CharGenData, but without packets

		
		skillsTable = SkillTable.getNewDefaultSkillTable();
		skillsTable.matchValuesWith(char.skills);
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
				var existingVal = char.skills.getSkillValue(f);
				LibUtil.setField(this.skillValues, f,  existingVal != null ? existingVal : 0);
			}
		}
		
		arrAdded.sort(SkillTable.sortArrayMethod);
		skillObjs = skillObjs.concat(arrAdded);
		
	
		skillSubjects = char.skills.getSubjects();
		var reflectedExisting:Dynamic<Bool> = {};
		for ( i in 0...skillSubjects.length) {
			LibUtil.setField(reflectedExisting, skillSubjects[i], true);
		}
		skillSubjectsInitial = reflectedExisting;
	
		
	}

}
