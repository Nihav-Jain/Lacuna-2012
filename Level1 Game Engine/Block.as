package  
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 *	@author Nihav Jain
	 *	@class Block - represents a movable, pushable, pickable crate
	 */	
	public class Block extends MovieClip
	{		
		public var lacunaman:LacunaMan;
		public var lacunawall:LacunaWall;
		public var isFalling:Boolean;
		public var isCarried:Boolean;
		var bl:crate;
		var movingwallIndex:int;
		
		/**
		 *	@constructor
		 */
		public function Block()
		{
			// blockpic is a png image of a wooden crate embedded in the FLA
			this.graphics.beginBitmapFill(new blockPic());
			this.graphics.drawRect(0, 0, 40, 40);
			this.graphics.endFill();
			bl = new crate;
		}
		
		/**
		 *	@method addEvent
		 *	@desc adds the ENTER_FRAME event listener to this movie clip
		 */
		function addEvent():void
		{
			this.addEventListener(Event.ENTER_FRAME, blockFall);
		}
		
		/********** BLOCK FUNCTIONS **********/
		
		/**
		 *	@method blockFall
		 *	@desc function called at every frame i.e. listener for ENTER_FRAME
		 */
		function blockFall(ev:Event):void
		{
			// if no wall or no ther bloack is under the block, and it is not being carried, make it fall 
			if(lacunawall.isFalling(ev.target.x, ev.target.y) && lacunawall.checkBlockUnder(ev.target.x, ev.target.y) == false && isCarried == false)
			{
				this.y += 20;
				// if block lands on man, do a George R.R. Martin on him!!! :P
				if(lacunaman.x - this.x > -40 && lacunaman.x - this.x < 40 && lacunaman.y - this.y >= 0 && lacunaman.y - this.y <= 20)
				{
					this.visible = false;					
					lacunawall.addChild(bl);
					bl.x = this.x;
					bl.y = this.y;
					this.removeEventListener(Event.ENTER_FRAME, blockFall);
					lacunaman.deathAnime();
				}
				isFalling = true;
			}
			else
				isFalling = false;
			// if this block is carries and another block lands on it, KILL THE MAN!!!
			if(isCarried == true && lacunawall.checkBlockUnder(this.x, this.y - 80) == true)
			{
				this.visible = false;
				lacunawall.addChild(bl);
				bl.x = this.x;
				bl.y = this.y+20;
				lacunaman.deathAnime();
				this.removeEventListener(Event.ENTER_FRAME, blockFall);
			}
		}

		/**
		 *	@method dropB
		 *	@desc drops the block being carried
		 *	@param {int} a 		- direction parameter -> -1 for left, +1 for right (x-axis from left to right)
		 *	@param {Number} b 	- x-offset for dropping the block (possibly the position for man)
		 */
		function dropB(a:int, b:Number)
		{
			this.x = b + (40*a);
			this.isCarried = false;
			this.addEventListener(Event.ENTER_FRAME, blockFall);
		}
	}
}