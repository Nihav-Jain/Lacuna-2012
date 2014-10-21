package  {
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	
	public class ClueSym extends MovieClip
	{
		public var isFirst:Boolean;
		public var xgrid:uint;
		public var ygrid:uint;
		public var clueno:uint;
		
		public var temp:uint;

		public function ClueSym() {
			isFirst = true;
		}
	}
}