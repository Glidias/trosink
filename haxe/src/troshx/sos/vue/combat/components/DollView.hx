package troshx.sos.vue.combat.components;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import hxGeomAlgo.HxPoint;
import js.Browser;
import js.html.Element;
import js.html.HtmlElement;
import js.html.Image;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.CharSave;
import troshx.sos.core.Inventory;
import troshx.sos.core.Item;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;

import troshx.sos.core.Armor;
import troshx.sos.core.Armor.AV3;
import troshx.sos.core.BodyChar;
import troshx.sos.core.HitLocation;
import troshx.sos.core.Inventory.ArmorAssign;
import troshx.util.LibUtil;

import troshx.sos.combat.BoutController;
import troshx.sos.combat.BoutModel;
import troshx.sos.pregens.FightCharacters;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.combat.CombatViewModel;
import troshx.sos.vue.combat.components.LayoutItemView;
import troshx.util.layout.LayoutItem;

import troshx.sos.vue.pregen.PregenSelectView;

// NOTE: This import is required for serialization, DO NOT delete!
import troshx.sos.chargen.CharGenData;

/**
 * Main doll view component
 * @author Glidias
 */
class DollView extends VComponent<DollViewData, NoneT>
{

	public function new() 
	{
		super();
	}
	
	// PREGENS
	
	static inline var PREGEN_SELECT_OPPONENT:Int = 4;
	static inline var PREGEN_SELECT_SELF:Int = 1;
	@:computed function get_pregenHeader():String 
	{
		return showPregens == PREGEN_SELECT_SELF ? "Select your character" : "Select your opponent"; 
	}
	function closePregens():Void {
		this.showPregens = 0;
	}
	
	function confirmPregens(val:Dynamic):Void {
		var boutModel = this.boutModel;
		if (boutModel.bout == null) {
			boutModel.bout = new Bout();
		}
		var viewModel:CombatViewModel = this.viewModel;
		var showPregens = this.showPregens;
		var node:FightNode<CharSheet> = null;
		if (showPregens == PREGEN_SELECT_SELF) {
			var valData:CharSave = val;
			node = new FightNode<CharSheet>(valData.label, deserializeSheet(valData.savedData), viewModel.getDefaultPlayerSideIndex());
			var theIndex = boutModel.bout.combatants.length;
			boutModel.bout.combatants.push(node);
			viewModel.currentPlayerIndex = theIndex;
			node.fight.cp = node.charSheet.CP;
			
		} else if (showPregens == PREGEN_SELECT_OPPONENT) {
			var valData:CharSave = val;
			node = new FightNode<CharSheet>(valData.label, deserializeSheet(valData.savedData), viewModel.getDefaultEnemySideIndex());
			boutModel.bout.combatants.push(node);
		}
		if (node != null) {
			node.charSheet.inventory.refreshHalfArmorLabels();
			node.charSheet.inventory.weildMeleeEquip(node.charSheet.profsMelee);
		}
		
		this.showPregens = 0;
	}
	
	function deserializeSheet(dataStr:String):CharSheet {
		 var unserializer = new Unserializer(dataStr);
		var data:CharSheet = unserializer.unserialize();
		//trace(data);
		return data;
	}
	
	function showSelfPregens():Void {
		this.showPregens = PREGEN_SELECT_SELF;
	}
	
	function showOpponentPregens():Void {
		this.showPregens = PREGEN_SELECT_OPPONENT;
	}
	
	// BOUT
	
	@:computed inline function get_boutModel():BoutModel 
	{
		return this.viewModel.boutModel;
	}
	
	// SELF 
	
	// cp
	@:computed function get_remainingDisplayCP():Int {
		return this.viewModel.getRemainingDisplayCP();
	}
	
	// vitals
	@:computed function get_fatique():Int {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.fatique;
	}
	@:computed function get_CP():Int {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.CP;
	}
	@:computed function get_remCP():Int {
		return viewModel.getRemainingDisplayCP();
	}
	@:computed function get_BL():Int {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.totalBloodLost;
	}
	@:computed function get_pain():Int {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.totalBloodLost;
	}
	
	// todo : might be different depending on handedness
	@:computed function get_rightItem():Item {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.inventory.findMasterHandItem();
	}
	@:computed function get_leftItem():Item {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.inventory.findOffHandItem();
	}
	
	function getTypeTagForItem(item:Item):String {
		var weapon:Weapon = LibUtil.as(item, Weapon);
		var shield:Shield = LibUtil.as(item, Shield);
		return shield != null ? "S" : weapon != null ? weapon.profLabelStdFirst().split(" ").join("").substr(0,3) : "";
	}
	
	@:computed function get_leftTypeTag():String {
		return getTypeTagForItem(this.leftItem);
	}
	
	@:computed function get_rightTypeTag():String {
		return getTypeTagForItem(this.rightItem);
	}
	
	// ENEMY
	
	@:computed function get_enemyRightItem():Item {
		var pl = this.currentOpponent;
		return pl.charSheet.inventory.findMasterHandItem();
	}
	@:computed function get_enemyLeftItem():Item {
		var pl = this.currentOpponent;
		return pl.charSheet.inventory.findOffHandItem();
	}
	
	@:computed function get_enemyLeftTypeTag():String {
		return getTypeTagForItem(this.enemyLeftItem);
	}
	
	@:computed function get_enemyRightTypeTag():String {
		return getTypeTagForItem(this.enemyRightItem);
	}
	
	
	
	// ----
	
	override function Data():DollViewData {
		return {
			mapData: getRenderTrackedImageData(),
			viewModel: new CombatViewModel(),
			
			fightChars: new FightCharacters(),
			showPregens: 0
		}
	}
	
	function getPartPropsOf(name:String):LayoutItemViewProps {
		var p = layoutViewPropsOf(name);
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		p.fillColor = "rgba(0,200,255,0.3)";
		p.strokeColor = "rgba(0,200,255,0.3)";
		p.strokeWidth = 4*(mapData.scaleX < mapData.scaleY ? mapData.scaleX : mapData.scaleY);
		p.showShape = i == viewModel.focusedIndex;
		return p;
	}
	
	function getArmorPartPropsOf(name:String, index:Int):LayoutItemViewProps {
		var aColors = armorDollColors;
		var defColors = armorColorScale;
		var gotColor = aColors[index] != null;
		
		var p = layoutViewPropsOf(name);
		var d = mapData;
		p.fillColor = "transparent";
		p.strokeColor = gotColor ? aColors[index] : defColors[0];
		p.strokeWidth = 3*(mapData.scaleX < mapData.scaleY ? mapData.scaleX : mapData.scaleY);
		p.showShape = gotColor;
		return p;
	}
	
	function getSwingPropsOf(name:String):LayoutItemViewProps {
		var p = layoutViewPropsOf(name);
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		p.fillColor = "rgba(0,255,255,0.3)";
		p.strokeColor = "rgba(0,255,255,0.3)";
		p.strokeWidth = 8*(mapData.scaleX < mapData.scaleY ? mapData.scaleX : mapData.scaleY);
		p.showShape = i == viewModel.focusedIndex;
		return p;
	}
	
	function layoutViewPropsOf(name:String):LayoutItemViewProps {
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		return {
			title: d.titleList[i],
			x: d.positionList[i].x*d.refWidth*d.scaleX,
			y: d.positionList[i].y*d.refHeight*d.scaleY,
			width: d.scaleList[i].x*d.refWidth*d.scaleX,
			height: d.scaleList[i].y * d.refHeight * d.scaleY,
			item: d.layoutItemList[i]
		}
	}
	
	@:computed inline function get_focusedTextLbl():String 
	{
		var lbl = viewModel.getFocusedLabel();
		if (lbl == null) lbl = viewModel.getBodyPartLabel(viewModel.focusedIndex);
		return lbl;
	}
	
	@:computed inline function get_player():FightNode<CharSheet>
	{
		return viewModel.getCurrentPlayer();
	}
	
	@:computed function get_opponents():Array<FightNode<CharSheet>> 
	{
		return viewModel.getCurrentOpponents();
	}
	
	@:computed inline function get_dollScale():Float
	{
		var x = mapData.scaleX;
		var y = mapData.scaleY;
		var R = mapData.renderCount;
		return y < x ? y : x;
	}
	
	@:computed inline function get_gotPregens():Bool
	{
		return fightChars != null && showPregens !=0;
	}
	
	@:computed inline function get_thrustPointStyle():Dynamic
	{
		var scale = this.dollScale;
		var d = (scale * 9);
		return {
			//backgroundColor:
			width:  d + "px",
			height: d + "px"
		};
	}
	
	@:computed function get_clampedOpponentIndex():Int
	{
		var opponents = this.opponents;
		var focusIndex = viewModel.focusOpponentIndex;
		if (opponents == null || opponents.length == 0) return 0;
		return focusIndex < opponents.length ? focusIndex : opponents.length -1;
	}
	
	@:computed inline function get_currentOpponent():FightNode<CharSheet> 
	{
		return this.opponents[this.clampedOpponentIndex];
	}
	
	@:computed inline function get_gotOpponents():Bool
	{
		return this.opponents != null && this.opponents.length >= 1;
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			zone: new LayoutItemView(),
			pregens: new PregenSelectView()
		}
	}
	
		
	override public function Mounted():Void {
		var img:Image = _vRefs.image;
		if (img.width > 0) {
			handleImageMap(img);
			
		} else {
			img.onload= function() {
				handleImageMap(img);
			};
		}
	}
	
	function startGame():Void {
		
	}
	
	
	// Doll Armor display calculation
	
	@:computed inline function get_currentDollSheet():CharSheet {
		return this.currentOpponent.charSheet;
	}
	
	@:computed function get_armorColorScale():Array<String> {
		return ["#ff0000", "#c00000", "#e26b0a", "#f79646",
		"#f1e70d", "#9bbb59", "#92d050", "#00b050",	//f1e70d   //ffff00
		"#0070c0", "#00b0f0"
		];
	}
	
	@:computed function get_carriedDollShieldAssign():ShieldAssign {
		return this.currentDollSheet.inventory.findHeldShieldAssign();
	}
	
	@:computed inline function get_carriedDollShield():Shield {
		var assign = this.carriedDollShieldAssign;
		return assign != null ? assign.shield : null;
	}
	
	@:computed function get_shieldLowProfiles():Array<Dynamic<Bool>> {
		return Shield.getLowCoverage();
	}
	
	@:computed function get_shieldHighProfiles():Array<Dynamic<Bool>> {
		return Shield.getHighCoverage();
	}
	
	@:computed function get_dollShieldCoverage():Dynamic<Bool> {
		var shield = this.carriedDollShield;
		var index:Int = shield != null ? shield.size : 0; 
		return this.currentDollSheet.inventory.shieldPosition == Shield.POSITION_HIGH ? this.shieldHighProfiles[index] : this.shieldLowProfiles[index];
	}
	
	function shieldCoveredAtDollHitLocation(i:Int):Bool {
		var viewModel = this.viewModel;
		var hitLocation = viewModel.getDollPartHitLocationAt(i);
		
		// note todo: might not be left part isLeftPartAtDollIndex, depends on where the shield is actually carried..
		return this.carriedDollShield != null && LibUtil.field(this.dollShieldCoverage, hitLocation.id) != null && (LibUtil.field(this.dollShieldCoverage, hitLocation.id) || viewModel.isLeftPartAtDollIndex(i) );
	}
	
	@:computed inline function get_coverageHitLocations():Array<HitLocation> {
		return this.currentDollSheet.body.hitLocations; // getNewHitLocationsFrontSlice();
	}
	
	// for standard dominant (enemy's right) side (ie. left side of doll)
	@:computed function get_hitLocationZeroAVValues():Dynamic<AV3> {
		return this.currentDollSheet.body.getNewEmptyAvs();
	}
	
	// for standard non-dominant (enemy's left) side  (ie. right side of doll)
	@:computed function get_hitLocationZeroAVValues2():Dynamic<AV3> {
		return this.currentDollSheet.body.getNewEmptyAvs();
	}
	
	/*
	 * @:computed inline function get_targetingZoneMask():Int {
		var i:Int = this.calcMeleeTargetingZoneIndex;
		return shouldCalcMeleeAiming ? (1<<i) : 0;
	}
	*/
	
	@:computed function get_armorDollColors():Array<String> {
		var arr:Array<String> = [];
		var hitIndices =  this.viewModel.DOLL_PART_HitIndices;
		var locations = this.coverageHitLocations;
		var avs = this.hitLocationArmorValues;
		var avsLeft = this.hitLocationArmorValues2;
		var isLefts = this.viewModel.DOLL_PART_IsLefts;
		for (i in 0...hitIndices.length) {
			var hitLocIndex:Int = hitIndices[i];
			var hitLoc = locations[hitLocIndex];
			var chosenAVs = hitLoc.twoSided && (isLefts & (1 << i)) != 0 ? avsLeft : avs;
			//trace( (hitLoc.twoSided && (isLefts & (1 << i)) != 0) + " : " + this.viewModel.DOLL_PART_Slugs[i]);
			var av:AV3 = LibUtil.field(chosenAVs, hitLoc.id);
			var aggre:Float = av.avc + av.avp + av.avb;
			var gotAV:Bool = aggre > 0;
			aggre /= 3;
			
			var aggI:Int = Math.floor(aggre);
			var colors = this.armorColorScale;
			if (aggI >= colors.length) {
				aggI = colors.length - 1;
			}
			arr[i] = gotAV ? colors[aggI] : null;
		}
		return arr;
	}
	
	function getHitLocationArmorValues(values:Dynamic<AV3>, sideMask:Int = 7):Dynamic<AV3> {
		var inventory = this.currentDollSheet.inventory;
		var armors:Array<ArmorAssign> = inventory.wornArmor;
		var ch = coverageHitLocations;
		var body:BodyChar =  this.currentDollSheet.body;

		var targMask:Int = 0;// targetingZoneMask;
	
		var nonFirearmMissile:Bool = false; // this.calcArmorMissile && !this.calcArmorFirearm;
		
		for (i in 0...ch.length) {
			var ider = ch[i].id;
			var cur = LibUtil.field(values, ider);
			cur.avc = 0;
			cur.avp = 0;
			cur.avb = 0;
		}
		
		for (i in 0...armors.length) {
			var assign:ArmorAssign = armors[i];
			if (assign.half != null && (assign.half & sideMask)==0) {
				continue;
			}
			var a:Armor = assign.armor;
			var layerMask:Int = 0;
			if (a.special != null && a.special.wornWith != null && a.special.wornWith.name != "" ) {
				layerMask = inventory.layeredWearingMaskWith(a, a.special.wornWith.name, body);	
			}
			a.writeAVVAluesTo(values, body, layerMask, nonFirearmMissile, targMask);
		}
		
		return values;
	}
	
	@:computed function get_hitLocationArmorValues():Dynamic<AV3> {
		return getHitLocationArmorValues(this.hitLocationZeroAVValues, Inventory.WEAR_WHOLE|Inventory.WEAR_RIGHT );
	}
	@:computed function get_hitLocationArmorValues2():Dynamic<AV3> {
		return getHitLocationArmorValues(this.hitLocationZeroAVValues2, Inventory.WEAR_WHOLE|Inventory.WEAR_LEFT);
	}
	
	// UI Interaction and states
	
	// -- the setup
	function setupUIInteraction():Void {
		hammerUI = new HammerJSCombat(cast _vRefs.container, this.mapData);
		hammerUI.viewModel = this.viewModel;
		
		this.viewModel.setupDollInteraction(hammerUI.interactionList, this.mapData);
		
		//hammerUI.setNewInteractionList([]);
		this.viewModel.setActingState(CombatViewModel.ACTING_NONE);
	}
	
	@:computed function get_actingState():Int {
		return this.viewModel.actingState;
	}

	@:watch("actingState") function onActingStateChanged(newValue:Int, oldValue:Int):Void {
		var arr = this.viewModel.getInteractionListByState(newValue);
		this.hammerUI.setNewInteractionList(arr!=null ? arr : this.viewModel.getInteractionListByState(CombatViewModel.ACTING_NONE));
	}
	
	// -- temp pregen initialization handler atm
	
	@:watch("gotOpponents") function onOpponentsStateChange(newValue:Bool, oldValue:Bool):Void {
		
		if (newValue) this.viewModel.setActingState(CombatViewModel.ACTING_DOLL_DECLARE);
		else {
			this.viewModel.setActingState(CombatViewModel.ACTING_NONE);
		}
		//this.hammerUI.setNewInteractionList(arr!=null ? arr : this.viewModel.getInteractionListByState(CombatViewModel.ACTING_DOLL_DECLARE));
	}
	
	// Image map layout setup
	
	public static function getRenderTrackedImageData():ImageMapData {
		return {
			renderCount:0,
		};
	}
	
	public static function getBlankImageMapData():ImageMapData {
		return {
			layoutItemList: null,
			positionList: [],
			scaleList: [],
			titleList: [],
			classList: [],
			refWidth:0,
			refHeight:0,
			scaleX:1,
			scaleY:1
		};
	}
	
	function handleImageMap(img:Image) 
	{
		var map:Element = _vRefs.map;
		var c = map.firstChild;
		
		var d = this.mapData;
		d.refWidth = img.width;
		d.refHeight = img.height;
		
		d.layoutItemList = [];
		d.positionList = [];
		d.scaleList = [];
		d.titleList = [];
		d.classList = [];
		
		
		var idIndices = new StringMap<Int>();
		
		var count:Int = 0;
		var arr:Array<LayoutItem> = [];
		while (c != null) {
			if (c.nodeName.toLowerCase() == "area") {
				//c.attributes.shape;
				//c.attributes.coord;
				var elem:HtmlElement = cast c;
				d.positionList.push( new HxPoint());
				d.scaleList.push( new HxPoint());
				d.classList.push(elem.getAttribute("alt"));
				var title = elem.getAttribute("title");
				d.titleList.push(title);
				idIndices.set(title, count++);
				
				arr.push(LayoutItem.fromHTMLImageMapArea(img.width, img.height, elem.getAttribute("shape"), elem.getAttribute("coords")));
			}
			c = c.nextSibling;
		}
		d.layoutItemList = arr;
		
		d.idIndices = idIndices;
		
		
		LayoutConstraints.applyDollView(arr, d.titleList, d.classList, d.refWidth, d.refHeight);
		
		Browser.window.addEventListener("resize", onResize);
		onResize();
		
		setupUIInteraction();

	}
	
	private function onResize():Void 
	{
		var container = _vRefs.container;
		var screenWidth = Std.parseFloat(container.clientWidth);
		var screenHeight = Std.parseFloat(container.clientHeight);
		var d = this.mapData;
		d.scaleX = screenWidth / d.refWidth;
		d.scaleY  = screenHeight / d.refHeight;
		
		refreshLayout();
	}
	
	function refreshLayout():Void
	{
		var d = mapData;
		for (i in 0...d.layoutItemList.length) {
			d.layoutItemList[i].solve(d.positionList[i], d.scaleList[i], d.scaleX, d.scaleY);
		}
		d.renderCount++;
	}
	
	
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}

typedef DollViewData = {
	var mapData: ImageMapData;
	var viewModel:CombatViewModel;
	
	// post initialize  below to prevent reactivity
	@:optional var hammerUI:HammerJSCombat;
	@:optional var boutController:BoutController;
	
	// pregens
	@:optional var fightChars:FightCharacters;
	@:optional var showPregens:Int;
	
}