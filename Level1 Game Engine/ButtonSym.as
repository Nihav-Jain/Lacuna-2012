package  {
	import flash.display.Shape;
	
	/**
	 *	@author Nihav Jain
	 *	@class ButtonSym - draws a button shape
	 */
	public class ButtonSym extends Shape
	{
		/**
		 *	@constructor
		 */
		public function ButtonSym() {
			this.graphics.beginFill(0xff0000);
			this.graphics.moveTo(10, 40);
			this.graphics.curveTo(20, 30, 30, 40);
			this.graphics.lineTo(10, 40);
			this.graphics.endFill();
		}
	}
}