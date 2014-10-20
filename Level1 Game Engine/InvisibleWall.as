package  {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.BitmapData;
	
	public class InvisibleWall extends Sprite
	{
		var xa:int;
		var yb:int;
		
		public var lacunawall:LacunaWall;
		var mwall:int = 0;
		public var isConcrete:Boolean;
		public var hasBeenSet:Boolean;
		
		
		public function InvisibleWall(a:int,b:int) 
		{
			
			hasBeenSet = true;
			xa=a;
			yb=b;
			isConcrete = false;
		}
		
		
		
		public function makeWall():void
		{
			
			for(mwall=(yb/40);mwall>=(yb/40)-2;mwall--)
			{
				
				lacunawall.leftwall[(xa/40)][mwall] = true;
				
			}
			this.graphics.lineStyle(1);
			this.graphics.moveTo(xa,yb);
			this.graphics.lineTo(xa,yb-80);
			this.graphics.endFill();
			isConcrete = true;
			hasBeenSet = true;
		}
		public function removeWall():void
		{
			hasBeenSet = true;
			for(mwall=(yb/40);mwall>=(yb/40)-2;mwall--)
			{
				lacunawall.leftwall[(xa/40)][mwall]=false;
			}
			this.graphics.clear();
			isConcrete = false;
		}
		
	}
	
}
