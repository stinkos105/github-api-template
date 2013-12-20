//------------------------------------------------------------------------------
//  Copyright (c) 2009-2013 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.eventDispatcher
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.instanceOf;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.LifecycleEvent;
	import robotlegs.bender.framework.impl.Context;

	public class EventDispatcherExtensionTest
	{

		/*============================================================================*/
		/* Private Static Properties                                                  */
		/*============================================================================*/

		// NOTE: We can't catch POST_DESTROY as the Relay is destroyed at that point
		private static const LIFECYCLE_TYPES:Array = [
			LifecycleEvent.PRE_INITIALIZE, LifecycleEvent.INITIALIZE, LifecycleEvent.POST_INITIALIZE,
			LifecycleEvent.PRE_SUSPEND, LifecycleEvent.SUSPEND, LifecycleEvent.POST_SUSPEND,
			LifecycleEvent.PRE_RESUME, LifecycleEvent.RESUME, LifecycleEvent.POST_RESUME,
			LifecycleEvent.PRE_DESTROY, LifecycleEvent.DESTROY];

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var context:IContext;

		/*============================================================================*/
		/* Test Setup and Teardown                                                    */
		/*============================================================================*/

		[Before]
		public function before():void
		{
			context = new Context();
		}

		/*============================================================================*/
		/* Tests                                                                      */
		/*============================================================================*/

		[Test]
		public function an_EventDispatcher_is_mapped_into_injector():void
		{
			var actual:Object = null;
			context.install(EventDispatcherExtension);
			context.whenInitializing(function():void {
				actual = context.injector.getInstance(IEventDispatcher);
			});
			context.initialize();
			assertThat(actual, instanceOf(IEventDispatcher));
		}

		[Test]
		public function provided_EventDispatcher_is_mapped_into_injector():void
		{
			const expected:IEventDispatcher = new EventDispatcher();
			var actual:Object = null;
			context.install(new EventDispatcherExtension(expected));
			context.whenInitializing(function():void {
				actual = context.injector.getInstance(IEventDispatcher);
			});
			context.initialize();
			assertThat(actual, equalTo(expected));
		}

		[Test]
		public function lifecycleEvents_are_relayed_to_dispatcher():void
		{
			const dispatcher:IEventDispatcher = new EventDispatcher();
			const reportedTypes:Array = [];
			for each (var type:String in LIFECYCLE_TYPES)
			{
				dispatcher.addEventListener(type, function(event:Event):void {
					reportedTypes.push(event.type);
				});
			}
			context.install(new EventDispatcherExtension(dispatcher));
			context.initialize();
			context.suspend();
			context.resume();
			context.destroy();
			assertThat(reportedTypes, array(LIFECYCLE_TYPES));
		}
	}
}
