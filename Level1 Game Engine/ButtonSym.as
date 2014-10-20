package  {
	import flash.display.Shape;
	
	public class ButtonSym extends Shape{

		public function ButtonSym() {
			// constructor code
			this.graphics.beginFill(0xff0000);
			this.graphics.moveTo(10, 40);
			this.graphics.curveTo(20, 30, 30, 40);
			this.graphics.lineTo(10, 40);
			this.graphics.endFill();
		}
	}
}