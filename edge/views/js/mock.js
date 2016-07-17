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
	
	// Various meta types
	// "choiceHeader", "initiative", "stance", "exchangeEnd", "orientation", "target", "manueverDeclare", "redRedInitiativeContest", "cautiousInitiativeContest", "manuueverResolve"
	// "target": initiative, orientation, targetIsCautious 
	// "cautiousInitiativeContest": winnerCharId, loserCharId
	
	
	// .NET Text merged with accomapnying metadata
	// {type:"", charId:"", typeSlug:"", anyOtherDataForType:"", text:"", charId_isYOU:0, charId_isAI:0 }

	//  Js frontend include: "temp" + charId insertion
	
	var testMockData = [
		
	];
	
	var testMockDataHash = {
		"stance": {
			lines: [
				{ text:"CharPersonName2 adopted an offensive martial stance", type:"stance", charId:2, stance:STANCE_OFFENSIVE }
				,{ text:"What martial stance do you wish to take to your enemies?", type:"choiceHeader", charId:1 }
			],
			choices: [	
				{ text:"Neutral", type:"stance",  stance:STANCE_NEUTRAL }
				,{ text:"Offensive", type:"stance",  stance:STANCE_OFFENSIVE }
				,{ text:"Defensive", type:"stance",  stance:STANCE_DEFENSIVE }
			]
		},
		"orientation": {
			lines: [
				{ text:"CharPersonName3 adopted a defensive martial stance", type:"stance", charId:3, stance:STANCE_DEFENSIVE }
				,{ text:"What is your orientation intent you wish to secretly adopt?", type:"choiceHeader", choiceHeader:"stance", charId:1 }
			],
			choices: [	
				{ text:"Cautious",  stance:ORIENTATION_CAUTIOUS }
				,{ text:"Aggressive", stance:ORIENTATION_AGGRESSIVE }
				,{ text:"Defensive", stance:ORIENTATION_DEFENSIVE }
			]
		},
		"target": {
			lines: [
				,{ text:"You intend to be Aggressive", type:"choiceFeedback", charId:1}
				,{ text:"You revealed an orientation of: Aggressive", type:"orientation", charId:1, orientation:ORIENTATION_AGGRESSIVE }
				,{ text:"CharPersonName2 revealed an orientation of: Aggressive", type:"orientation", charId:2, orientation:ORIENTATION_AGGRESSIVE }
				,{ text:"CharPersonName3 revealed an orientation of: Defensive", type:"orientation", charId:3, orientation:ORIENTATION_DEFENSIVE }
				,{ text:"CharPersonName2 targeted you, aggressively.", type:"target", charId:2, target:1, targetIsCautious:1 }
				,{ text:"Choosing target for player character: You", type:"choiceHeader", choiceHeader:"target", charId:1 }
			],
			choices: [	
				{ text:"CharPersonName2",  target:2 }
				,{ text:"CharPersonName3", target:3 }
			]
		},
		"engaged": {
			lines: [
				{ text:"You intend to be Cautious", type:"choiceFeedback", charId:1}
				,{ text:"You revealed an orientation of: Cautious", type:"orientation", charId:1, orientation:ORIENTATION_CAUTIOUS }
				,{ text:"CharPersonName2 revealed an orientation of: Aggressive", type:"orientation", charId:2, orientation:ORIENTATION_AGGRESSIVE }
				,{ text:"CharPersonName3 revealed an orientation of: Cautious", type:"orientation", charId:3, orientation:ORIENTATION_CAUTIOUS }
				,{ text:"CharPersonName2 engaged you, aggressively.", type:"target", charId:2, target:1, targetIsCautious:1, initiative:1 }
				,{ text:"CharPersonName3 targets you, cautiously.", type:"target", charId:2, target:1 }
				,{ text:"CharPersonName2 attacks you with Bash (swing) (for Overhand Swing) with 8 CP", type:"target", charId:2, target:1 }
				,{ text:"Defend", type:"choiceHeader", charId:1, choiceHeader:"manueverDeclare", choiceSubHeader:"manuever" }
				
			],
			choices: [	
				{ text: "Block....(0)tn:4", tn:4, cost:0, manuever:"block" }
				,{ text: "Parry....(0)tn:6", tn:6, cost:0, manuever:"parry" }
				,{ text: "Partial Evasion....(0)tn:7", tn:7, cost:0, manuever:"partialevasion" }
				,{ text: "Full Evasion....(0)tn:5", tn:5, cost:0, manuever:"fullevasion" }
			]
		},
		"manueverDeclare": {
			lines: [
				{ text:"You targeted CharPersonName2, aggressively.", type:"target", charId:1, target:2, initiative:2  }
				,{ text:"Attack", type:"choiceHeader", charId:1, choiceHeader:"manueverDeclare", choiceSubHeader:"manuever" }
			],
			choices: [
				{ text: "Cut....(0)tn:6", tn:6, cost:0, manuever:"cut" }
				,{ text: "Thrust....(0)tn:6", tn:6, cost:0, manuever:"thrust" }	
			]
		},
		"manueverDeclareChooseOpponent": {
			lines: [
				{ text:"You targeted CharPersonName2, aggressively.", type:"target", charId:1, target:2, initiative:2  }
				,{ text:"Pick an opponent to deal against:", type:"choiceHeader", charId:1, choiceHeader:"manueverDeclare", choiceSubHeader:"chooseOpponent"}
			],
			choices: [
			
			]
		},
		
		"manueverChooseManueverType": {
			lines: [
				{ text:"You targeted CharPersonName2, aggressively.", type:"target", charId:1, target:2, initiative:2  }
				,{ text:"Choose the nature of your action:", type:"choiceHeader", charId:1, choiceHeader:"manueverDeclare", choiceSubHeader:"manueverType"}
			],
			choices: [
		
			]
		}
		
	}
	
	
	
	
	var testVueModelData = {
		charInfo: [
			{}
			,{stance:STANCE_RESET, orientation: ORIENTATION_NONE, target:2, isYou:true, isAI:false}
			,{stance:STANCE_RESET, orientation: ORIENTATION_NONE, target:1, initiative:false, isYou:false, isAI:true}
			,{stance:STANCE_RESET, orientation: ORIENTATION_NONE, isYou:false, isAI:true}
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