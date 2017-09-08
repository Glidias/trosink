package troshx.sos.events;
import msignal.Signal;

/**
 * An SOSEventBus provides a basic instance to dispatch notifications
 * which are specific to Song of Swords game, and may encapsulat
 * certain specific-case processing with regards these notifications.
 * 
 * @author Glidias
 */
class SOSEventBus 
{
	var notificationList:Array<SOSNotification> = [];
	//var notifier:Signal<
	
	var notifier:Signal<SOSNotification>;

	public function new() 
	{
		
	}
	
	function submitNotification(notify:SOSNotification):Void {
		// pre-process specific cases for SOS.
		/*
		switch( notify) {
			//case SOSNotification.BOON_TRIGGERED(boonAssign):
				
			//case SOSNotification.BANE_TRIGGERED(baneAssign):

			default:
		}
		*/
		notificationList.push(notify);
	}
	
}