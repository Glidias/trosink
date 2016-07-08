/**
 * ...
 * @author Glidias
 */

(function() {
	
	
	var myScroll = new IScroll('#contentwrapper', {
		HWCompositing: false,
		mouseWheel: true,
		bounce:false
	});


	$("#phoneframe").addClass("scaleddown");
	
	
	var STANCE_RESET = -1;
	var STANCE_NEUTRAL = 0;
	var STANCE_DEFENSIVE = 1;
	var STANCE_OFFENSIVE = 2;
	
	var ORIENTATION_NONE = 0
	var ORIENTATION_DEFENSIVE = 1
	var ORIENTATION_CAUTIOUS = 2
	var ORIENTATION_AGGRESSIVE = 3
	
	// Assumptions and TODOs
	// - After every exchange, for every character in charInfo.....  nullify orientation, nullify stance
	//  Check if still got target, or target lost after every exchange, and display current target enagements above any new engagements. 
	// Add service watcher for "target" variable per character to track any changes into charInfo
	// 
	
	var testVueModelData = {
		charInfo: [
			{}
			,{stance:STANCE_OFFENSIVE, orientation: ORIENTATION_CAUTIOUS, target:2}
			,{stance:STANCE_NEUTRAL, orientation: ORIENTATION_CAUTIOUS, target:1, initiative:false}
			,{stance:STANCE_DEFENSIVE, orientation: ORIENTATION_DEFENSIVE}
		]
		,lines: [
			{
				text:"Copy of person goes here adopting stance, if any"
				,charId:1
				,stance:true
			}
			,{
				text:"Copy of person goes here adopting orientation if any"
				,charId:1
				,orientation:true
			}
			,{
				text:"Copy of person targets so and so with orientation "
				,charId:1
				,target:true
			}
			,{
				text:"You"
				,charId:1
				,temp:true
				,tempCurrent:true
			}
			,{
				text:"Copy of person 2 goes here adopting stance, if any"
				,charId:2
				,stance:true
			}
			,{
				text:"Copy of person 2 goes here adopting orientation, if any"
				,charId:2
				,orientation:true
			}
			,{
				text:"Copy of person 2 goes  here targeting back, with orientation (if any), and with initiative state mentioned"
				,charId:2
				,target:true
				,initiative:true
			}	
			,{
				text:"CharPerson2.."
				,charId:2
				,temp:true
			}
			,{
				text:"What would you choose?"
	
			}
		]
		,choiceHeader:false
		,choices:[
			{
				text:"A choice"
			}
			,{
				text:"Another choice.."
			}
			,{
				text:"A choice"
			}
			,{
				text:"Another choice.."
			}
			,{
				text:"A choice"
			}
			,{
				text:"Another choice.."
			}
		
		]
	};
	
	
		
	var vm = new Vue({
		el: '#appwrapper',
		 data: testVueModelData,
		 methods: {
			isPortraitLeftAligned: function(a) {
				return a.target ? (a.initiative!=null ? !a.initiative : false )  : (a.orientation ? a.orientation === ORIENTATION_CAUTIOUS  : a.stance === STANCE_DEFENSIVE) 
			}
			,getCharInfo(packet, prop) {
				return packet.charId ? this.charInfo[packet.charId] : {};
			}
		 }
	});
	
	
	
	
	
	
	function onVueUpdate() {
		myScroll.refresh();
	}
	setTimeout(onVueUpdate, 0);
	
})();