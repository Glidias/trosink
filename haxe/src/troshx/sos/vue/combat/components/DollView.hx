package troshx.sos.vue.combat.components;
import haxe.Unserializer;
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
import troshx.sos.core.Manuever;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;
import troshx.sos.vue.combat.components.ZoneItemView.ShapeStyleProps;
import troshx.sos.vue.combat.components.ZoneItemView.ZoneItemViewProps;
import troshx.sos.core.Armor;
import troshx.sos.core.Armor.AV3;
import troshx.sos.core.BodyChar;
import troshx.sos.core.HitLocation;
import troshx.sos.core.Inventory.ArmorAssign;
import troshx.util.AbsStringMap;
import troshx.util.LibUtil;

import troshx.sos.combat.BoutController;
import troshx.sos.combat.BoutModel;
import troshx.sos.pregens.FightCharacters;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.combat.CombatViewModel;
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
	
	function quickStartDebug() {
		
		var boutModel = this.boutModel;
		if (boutModel.bout == null) {
			boutModel.bout = new Bout();
		}
		
		var valData:CharSave;
		var node;
		valData = FightCharacters.get()[7];
		
		node = new FightNode<CharSheet>(valData.label, deserializeSheet(valData.savedData), viewModel.getDefaultPlayerSideIndex());
		var theIndex = boutModel.bout.combatants.length;
		boutModel.bout.pushNewFightNode(node);
		viewModel.currentPlayerIndex = theIndex;
		node.fight.cp = node.charSheet.CP;
		
		node.charSheet.inventory.refreshHalfArmorLabels();
		node.charSheet.inventory.cleanupShieldLabels();
		node.charSheet.inventory.weildMeleeEquip(node.charSheet.profsMelee);
		viewModel.activatePlayerItem();
		

		valData = FightCharacters.get()[7];
		node = new FightNode<CharSheet>(valData.label, deserializeSheet(valData.savedData), viewModel.getDefaultEnemySideIndex());
		boutModel.bout.pushNewFightNode(node);
		viewModel.focusOpponentIndex = theIndex;
		
		node.charSheet.inventory.refreshHalfArmorLabels();
		node.charSheet.inventory.cleanupShieldLabels();
		node.charSheet.inventory.weildMeleeEquip(node.charSheet.profsMelee);
		
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
			boutModel.bout.pushNewFightNode(node);
			viewModel.currentPlayerIndex = theIndex;
			node.fight.cp = node.charSheet.CP;
			
			
		} else if (showPregens == PREGEN_SELECT_OPPONENT) {
			var valData:CharSave = val;
			var theIndex = boutModel.bout.combatants.length;
			node = new FightNode<CharSheet>(valData.label, deserializeSheet(valData.savedData), viewModel.getDefaultEnemySideIndex());
			boutModel.bout.pushNewFightNode(node);
			viewModel.focusOpponentIndex = theIndex;
		}
		if (node != null) {
			node.charSheet.inventory.refreshHalfArmorLabels();
			node.charSheet.inventory.cleanupShieldLabels();
			node.charSheet.inventory.weildMeleeEquip(node.charSheet.profsMelee);
			if (showPregens == PREGEN_SELECT_SELF) viewModel.activatePlayerItem();
			
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
		return pl.charSheet.fullCP;
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
	@:computed function get_rightItemAssign():ReadyAssign {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.inventory.findMasterHandAssign();
	}
	@:computed function get_leftItemAssign():ReadyAssign {
		var pl = viewModel.getCurrentPlayer();
		return pl.charSheet.inventory.findOffHandAssign();
	}
	@:computed function get_rightItemHighlighted():Bool {
		var usingLeftLimb = viewModel.playerManueverSpec.usingLeftLimb;
		var activeItem = viewModel.playerManueverSpec.activeItem;
		var rightItem = this.rightItem;
		return usingLeftLimb ? false : rightItem ==  activeItem;
	}
	@:computed function get_leftItemHighlighted():Bool {
		var usingLeftLimb = viewModel.playerManueverSpec.usingLeftLimb;
		var activeItem = viewModel.playerManueverSpec.activeItem;
		var leftItem = this.leftItem;
		var rightItemAssign = this.rightItemAssign;
		// TODO: test both handed highlghting
		return usingLeftLimb ? leftItem == activeItem : rightItemAssign != null && rightItemAssign.held == Inventory.HELD_BOTH;
	}
	
	function getTypeTagForItem(item:Item):String {
		var weapon:Weapon = LibUtil.as(item, Weapon);
		var shield:Shield = LibUtil.as(item, Shield);
		return shield != null ? '<span class="fa">${ICON_SHIELD}</span>' : weapon != null ? weapon.profLabelStdFirst().split(" ").join("").substr(0,3) : "";
	}
	
	@:computed function get_leftTypeTag():String {
		return getTypeTagForItem(this.leftItem);
	}
	
	@:computed function get_rightTypeTag():String {
		return getTypeTagForItem(this.rightItem);
	}
	
	// ENEMY
	
	// warning: assumption made for masterhand item handedness
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
	
	@:computed function get_styleObservePartProps():ShapeStyleProps {
		var d = mapData;
		return {
			fillColor: "transparent",
			strokeColor: "rgba(0,0,0,1)",
			strokeWidth: 4*(d.scaleX < d.scaleY ? d.scaleX : d.scaleY)
		}
	}
	
	@:computed function get_focusManueverAtkType():Int {
		return viewModel.getFocusManueverAtkType();
	}
	
	@:computed function get_advStyleProps():ShapeStyleProps {
		return this.focusManueverAtkType != Manuever.ATTACK_TYPE_SWING ? stylePartProps : styleSwingProps;
	}
	
	
	@:computed function get_stylePartProps():ShapeStyleProps {
		var d = mapData;
		return {
			fillColor: "rgba(0,200,255,0.3)",
			strokeColor: "rgba(0,200,255,0.3)",
			strokeWidth: 4*(d.scaleX < d.scaleY ? d.scaleX : d.scaleY),
		}
	}
	
	function getArmorPartPropsOf(name:String, index:Int):ZoneItemViewProps {
		var aColors = armorDollColors;
		var defColors = armorColorScale;
		var gotColor = aColors[index] != null;
		
		var d = mapData;
		var p:ZoneItemViewProps = {
			index:d.idIndices.get(name),
			mapData:d
		}
		
		p.fillColor = "transparent";
		p.strokeColor = gotColor ? aColors[index] : defColors[0];
		p.strokeWidth = 3*(mapData.scaleX < mapData.scaleY ? mapData.scaleX : mapData.scaleY);
		p.showShape = gotColor;
		return p;
	}
	
	@:computed function get_armorPartProps():Array<ZoneItemViewProps> {
		var arr:Array<ZoneItemViewProps> = [];
		var slugs = viewModel.DOLL_PART_Slugs;
		for (i in 0...slugs.length) {
			arr[i] = getArmorPartPropsOf(slugs[i], i);
		}
		return arr;
	}
	


	
	@:computed function get_styleSwingProps():ShapeStyleProps {
		var d = mapData;
		return {
			fillColor: "rgba(0,255,255,0.3)",
			strokeColor: "rgba(0,255,255,0.3)",
			strokeWidth: 8*(d.scaleX < d.scaleY ? d.scaleX : d.scaleY)
		}
	}
	
	@:computed function get_styleDefBtnProps():ShapeStyleProps {
		var d = mapData;
		return {
			fillColor: "rgba(0,255,255,0.3)",
			strokeColor: "rgba(0,255,255,0.3)",
			strokeWidth: 4,
		}
	}
	

	@:computed function get_stylePlHandBtnProps():ShapeStyleProps {
		return {
			fillColor: "rgba(161,244,210,1)",
			// strokeColor: "rgba(0,255,255,0.3)",
			strokeWidth: 0
		}
	}
	
	@:computed function get_focusedTextLbl():String 
	{
		var viewModel = this.viewModel;
		//var d1 = this.viewModel.focusInvalidateCount; // this.cachedEnemyLeft
		var lbl = !viewModel.observeOpponent ? viewModel.getFocusedLabel(this.enemyLeftItem, this.enemyRightItem) : this.partObserveLbl;
		//if (lbl == null) lbl = viewModel.getBodyPartLabel(viewModel.focusedIndex);
		return lbl;
	}
	
	@:computed function get_observePrompt():String {
		return !this.viewModel.observeOpponent ? '<span class="fa">${ICON_ARROW_LEFT}${ICON_FINGER_UP}</span> to observe <span class="fa">${ICON_EYE}</span>' : "observing...";
	}
	
	static inline var ICON_EYE:String = "&#xf06e;";
	static inline var ICON_CHEV_LEFT:String = "&#xf053;";
	static inline var ICON_ARROW_LEFT:String = "&#xf060;";
	static inline var ICON_FINGER_UP:String = "&#xf0a6;";
	static inline var ICON_SHIELD:String = "&#xf132;";
	
	@:computed function get_partObserveLbl():String 
	{
		var oi = viewModel.observeIndex;
		var di = viewModel.getDollIndexAtFocusIndex(oi);
		if (di >= 0) {
			var armor:Armor = getVisibleArmorAtDollPartIndex(di);
			var shield:Shield = this.carriedDollShield;
			if (shield != null && !shieldCoveredAtDollHitLocation(di) ) {
				shield = null;
			}
			return viewModel.getBodyPartLabel(oi) + (shield!= null || armor!=null ? ": "+(shield!=null? '<span class="fa">${ICON_SHIELD}</span> ' : "")+(armor != null ? "<b>"+armor.name+"</b>" : "") : "");	
		} else  {
			var hi = viewModel.focusIndexEnemyHandSide(oi);
			if (hi != 0) {
				var item:Item = hi != Inventory.WEAR_LEFT ? this.enemyRightItem : this.enemyLeftItem;
				if (item != null) {
					return item.name;
				}
			}
		}
		return "";
	}
	
	@:computed function get_player():FightNode<CharSheet>
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
	
	@:computed function get_currentOpponent():FightNode<CharSheet> 
	{
		var allOpponents = this.opponents; // fallback temp show from all opponents list if no currentPlayer yet
		
		var currentPlayer:FightNode<CharSheet> = this.player;
		//if (currentPlayer != null) {
			//var r = currentPlayer.targetLinkUpdateCount;
			//trace(currentPlayer.targetLink); // target FightLink<CharSheet> linked-list item should be non-reactive
		//}
		return currentPlayer != null ? currentPlayer.getTargetOpponent() : 
			allOpponents != null ? allOpponents[this.clampedOpponentIndex] : null;
	}
	
	@:computed inline function get_gotCurrentOpponent():Bool
	{
		return this.currentOpponent != null;
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			zone: new ZoneItemView(),
			pregens: new PregenSelectView()
		}
	}
	
	@:computed function get_advManuevers():Array<Manuever> {
		var gotPlayer:Bool = this.player != null;
		var gotEnemy:Bool = this.currentOpponent != null;
		return this.viewModel.getAdvancedManuevers(this.player, gotPlayer ? this.leftItem : null, gotPlayer ? this.rightItem : null, this.currentOpponent, gotEnemy ? this.enemyLeftItem : null, gotEnemy ? this.enemyRightItem : null);
	}
	

	@:computed function get_advTNArr():Array<Int> {
		var gotPlayer:Bool = this.player != null; 
		return gotPlayer ? this.advTNs : this.advSimpTNs;
	}
	
	@:computed function get_advCostArr():Array<Int> {
		var gotPlayer:Bool = this.player != null; 
		return gotPlayer ? this.advCosts : this.advSimpCosts;
	}
	
	@:computed function get_browseAttackModeLabel():String {
		return this.viewModel.getBrowseAttackModeLabel(false);
	}
	
	@:computed function get_browseAttackModeLabel2():String {
		return this.viewModel.getBrowseAttackModeLabel(true);
	}
	
	@:computed function get_isBrowseHighlightLeft():Bool {
		return this.viewModel.isBrowseHighlightLeft();
	}
	@:computed function get_isBrowseHighlightRight():Bool {
		return this.viewModel.isBrowseHighlightRight();
	}
	
	@:computed function get_advTNs():Array<Int> {
		var arr = this.advManuevers;
		var val = [];
		var pSpec = this.viewModel.playerManueverSpec;
		for (i in 0...arr.length) {
			val[i] = arr[i].getTN(pSpec);
		}
		return val;
	}
	
	@:computed function get_advSimpTNs():Array<Int> {
		var arr = this.advManuevers;
		var val = [];
		for (i in 0...arr.length) {
			val[i] = arr[i].tn;
		}
		return val;
	}
	
	@:computed function get_advCosts():Array<Int> {
		var arr = this.advManuevers;
		var val = [];
		for (i in 0...arr.length) {
			val[i] = arr[i].getCost(this.boutModel.bout, this.player, null);
		}
		return val;
	}
	
	@:computed function get_advSimpCosts():Array<Int> {
		var arr = this.advManuevers;
		var val = [];
		for (i in 0...arr.length) {
			val[i] = arr[i].cost;
		}
		return val;
	}
	
	function advHiddenAt(i:Int):Bool {
		return (this.advNotAvailMask & (1 << i)) != 0;
	}
	
	function advDisabledAt(i:Int):Bool {
		return (this.advNotAvailMask & (1 << (i+4))) != 0;
	}
	@:computed function get_advNotAvailMask():Int {
		var arr = this.advManuevers;
		var arrTNs = this.advTNs;
		var gotPlayer = this.player != null;
		var val = 0;
		if (gotPlayer) {
			for (i in 0...arr.length) {
				val |= arrTNs[i] < 0 || !arr[i].getAvailability(this.boutModel.bout, this.player, this.viewModel.playerManueverSpec) ? (1 << i) : 0;
			}
		}
		return val;
	}
	
	@:watch("advNotAvailMask") function onNotAvailAdvMaskChange(newValue:Int, oldValue:Int):Void {
		this.viewModel.onAdvAvailabilityChange(newValue);
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
		
		if (Browser.window.location.href.substr(0,7) == "file://" || Browser.window.location.host == "localhost") {
			Browser.window.setTimeout(function() {
				//quickStartDebug();
			}, 100);
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
	
	@:computed function get_carriedDollShield():Shield {
		var assign = this.carriedDollShieldAssign;
		return assign != null ? assign.shield : null;
	}
	
	@:computed function get_shieldIconStyle():Dynamic {
		var shield = carriedDollShield;
		var avI:Int = -1;
		var armorColorScale = this.armorColorScale;
		if (shield != null) {
			avI = shield.AV - 1;
			if (avI >= armorColorScale.length) {
				avI = armorColorScale.length - 1;
			}
		}
		return shield != null && avI >= 0 ? {color:armorColorScale[avI]} : {};
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
	
	@:computed function get_dollShieldCoverageBools():Array<Bool> {
		var slugs =  viewModel.DOLL_PART_Slugs;
		var arr:Array<Bool> = [];
		for (i in 0...slugs.length) {
			arr[i] = shieldCoveredAtDollHitLocation(i);
		}
		return arr;
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
		return this.currentDollSheet.body.getNewEmptyAvsWithVis();
	}
	
	// for standard non-dominant (enemy's left) side  (ie. right side of doll)
	@:computed function get_hitLocationZeroAVValues2():Dynamic<AV3> {
		return this.currentDollSheet.body.getNewEmptyAvsWithVis();
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
			var aggre:Float = av.avc*Armor.VISIBLE_WEIGHT_AVC + av.avp*Armor.VISIBLE_WEIGHT_AVP + av.avb*Armor.VISIBLE_WEIGHT_AVB;
			var gotAV:Bool = aggre > 0;
			aggre /= 3;
			
			var aggI:Int = Math.floor(aggre) - 1;
			var colors = this.armorColorScale;
			if (aggI >= colors.length) {
				aggI = colors.length - 1;
				if (aggI < 0) aggI = 0;
			}
			arr[i] = gotAV ? colors[aggI] : null;
		}
		return arr;
	}
	
	function getVisibleArmorAtDollPartIndex(i:Int):Armor {
		var avs:Dynamic<AV3> = this.viewModel.isLeftPartAtDollIndex(i) ? this.hitLocationArmorValues2 : this.hitLocationArmorValues;
		var hitLocIndex:Int = this.viewModel.DOLL_PART_HitIndices[i];
		var hitLoc = this.coverageHitLocations[hitLocIndex];
		var av:AV3 = LibUtil.field(avs, hitLoc.id);
		return av.visArmor;
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
	
	@:computed function get_cpTrayCSSTransform():String {
		var scaleX = this.viewModel.trayPosFlip ? -1 : 1;
		var scaleY = this.viewModel.trayPosFlipY ? -1 : 1;
		return 'translate(${viewModel.trayPosX + viewModel.trayGridShelfX*scaleX}px, ${viewModel.trayPosY + viewModel.trayGridShelfSize*scaleY}px)' + ' scale(${scaleX},${scaleY})';
	}
	
	@:computed function get_cpMeterAmount():Int {
		return player.charSheet.CP;
	}
	
	static inline var HTML_CHAR_DRAGGED = "◘";
	static inline var HTML_CHAR_DICE = "◊";
	
	@:computed function get_dragCPHtml():String {
		var player = this.player;
		var draggedCP = viewModel.draggedCP;
		
		var totalShowCP = player.charSheet.fullCP;
		
		//var allotedCP = player.charSheet.CP; // alloted CP for fighting excluding pain
		//var availableCP = player.fight.cp; // avilalbe usable CP for fighting across 2 exchanges
		//meleeCP (-pain)
		
		// Show all indicators?
		// pain x
		// shock *
		// used |
		// fatique/prone/other .
		
		var totalRowsDn = Math.floor(totalShowCP / CombatViewModel.TRAY_TOTAL_COLS);
		
		// warning: assumed TRAY_TOTAL_COLS == 5
		if (draggedCP > 0) {
			var draggedRowsDn = Math.floor(draggedCP / CombatViewModel.TRAY_TOTAL_COLS);
			return '<span>'+repeatTxt('${HTML_CHAR_DRAGGED}${HTML_CHAR_DRAGGED}${HTML_CHAR_DRAGGED}${HTML_CHAR_DRAGGED}${HTML_CHAR_DRAGGED}', draggedRowsDn, '<br>')+'</span>' + repeatTxt(HTML_CHAR_DRAGGED,  draggedCP - draggedRowsDn* CombatViewModel.TRAY_TOTAL_COLS) + getRemainingMid(draggedCP, HTML_CHAR_DICE, totalShowCP);
		} else {
			return repeatTxt('${HTML_CHAR_DICE}${HTML_CHAR_DICE}${HTML_CHAR_DICE}${HTML_CHAR_DICE}${HTML_CHAR_DICE}', totalRowsDn, '<br>') + repeatTxt(HTML_CHAR_DICE,  totalShowCP - totalRowsDn * CombatViewModel.TRAY_TOTAL_COLS);
		}
		/*
		<span><del>&#9632;&#9632;&#9632;&#9632;&#9632;</del><br/>
				&#9632;&#9632;&#9632;</span>&#9642;&#9642;<br/>
				&#9642;&#9642;&#9642;&#9642;&#9642;<br/>
				&#9642;&#9642;&#9642;&#9642;&#9642;<br/>
		*/
	}
	
	function getRemainingMid(fromAmount:Int, str:String, amount:Int):String {
		var ab = amount - (Math.floor(amount / CombatViewModel.TRAY_TOTAL_COLS) * CombatViewModel.TRAY_TOTAL_COLS);
		ab = amount - ab;
		var residue = (ab - fromAmount) % CombatViewModel.TRAY_TOTAL_COLS;
		if (residue < 0) residue = 0;
		var s = repeatTxt(str, residue);
		
		
		
		var totalShowCP = amount - fromAmount - residue;
		if (totalShowCP > 0 && residue > 0) s += "<br>";
		var totalRowsDn= Math.floor(totalShowCP / CombatViewModel.TRAY_TOTAL_COLS);
		return s + repeatTxt('${str}${str}${str}${str}${str}', totalRowsDn, '<br>') + repeatTxt(HTML_CHAR_DICE,  totalShowCP - totalRowsDn * CombatViewModel.TRAY_TOTAL_COLS);
	}
	
	function repeatTxt(str:String, times:Int, lineBreak:String=''):String {
		var s = '';
		var lastIndex = times - 1;
		for (i in 0...times) {
			s += str +  lineBreak;  //(i != lastIndex ? lineBreak : lineBreak); trailing linebreak seems to be no issue
		}
		return s;
	}
	
	@:computed function get_cpTrayStyle():Dynamic {
		return {transform: this.cpTrayCSSTransform, 'font-size':'${viewModel.trayGridSizeY}px' };
	}
	
	// UI Interaction and states
	
	// -- the setup
	function setupUIInteraction():Void {
		hammerUI = new HammerJSCombat(cast _vRefs.container, this.mapData, null, _vRefs.cursor);
		hammerUI.viewModel = this.viewModel;
		
		this.viewModel.setupDollInteraction(hammerUI.interactionList, this.mapData);
		
		//hammerUI.setNewInteractionList([]);
		this.viewModel.setActingState(CombatViewModel.ACTING_NONE);
	}
	
	@:computed function get_actingState():Int {
		return this.viewModel.actingState;
	}

	@:computed function get_isDefBtnBlockAllowed():Bool {
		return this.viewModel.isDefBtnBlockAllowed();
	}
	
	@:computed function get_isDefBtnParryAllowed():Bool {
		return this.viewModel.isDefBtnParryAllowed();
	}
	
	@:computed function get_isDraggingCP():Bool {
		return this.viewModel.actingState == CombatViewModel.ACTING_DOLL_DRAG_CP;
	}
	
	@:watch("actingState") function onActingStateChanged(newValue:Int, oldValue:Int):Void {
		var arr = this.viewModel.getInteractionListByState(newValue);
		this.hammerUI.setNewInteractionList(arr!=null ? arr : this.viewModel.getInteractionListByState(CombatViewModel.ACTING_NONE));
	}
	
	// -- temp pregen initialization handler atm
	
	@:watch("gotCurrentOpponent") function onOpponentsStateChange(newValue:Bool, oldValue:Bool):Void {
		
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
		
		
		var idIndices:AbsStringMap<Int> = new AbsStringMap<Int>();
		
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