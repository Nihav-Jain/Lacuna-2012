package  
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	
	
	public class Block extends MovieClip
	{
		
		 public var lacunaman:LacunaMan;
		 public var lacunawall:LacunaWall;
		public var isFalling:Boolean;
		public var isCarried:Boolean;
		var bl:crate;
		var movingwallIndex:int;
		
		public function Block()
		{
			//trace("Hi");
			this.graphics.beginBitmapFill(new blockPic());
			this.graphics.drawRect(0, 0, 40, 40);
			this.graphics.endFill();
			bl = new crate;
		}
		
		function addEvent():void
		{
			this.addEventListener(Event.ENTER_FRAME, blockFall);
		}
		
		//BLOCK FUNCTIONS:
		function blockFall(ev:Event):void
		{
			//trace(ev.target.x);
			if(lacunawall.isFalling(ev.target.x, ev.target.y) && lacunawall.checkBlockUnder(ev.target.x, ev.target.y) == false && isCarried == false)
			{
				this.y += 20;
				/*if((lacunaman.y - this.y  == 20 && lacunaman.x - this.x > -40 && lacunaman.x - this.x < 40))
				{
					lacunaman.deathAnime();
					this.removeEventListener(Event.ENTER_FRAME, blockFall);
				}
				*/
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
			if(isCarried == true && lacunawall.checkBlockUnder(this.x, this.y - 80) == true)
			{
				this.visible = false;
					
					lacunawall.addChild(bl);
					bl.x = this.x;
					bl.y = this.y+20;
				lacunaman.deathAnime();
				
				this.removeEventListener(Event.ENTER_FRAME, blockFall);
			}
				//ev.target.removeEventListener(Event.ENTER_FRAME, blockFall);
		}

		
		function dropB(a:int, b:Number)
		{
			//trace(lacunaman.x);
			this.x = b + (40*a);
			this.isCarried = false;
			//trace("ok for dropB");
			this.addEventListener(Event.ENTER_FRAME, blockFall);
		}
		
		/*function canMoveRight():Boolean
		{
			
		}*/
	}
}