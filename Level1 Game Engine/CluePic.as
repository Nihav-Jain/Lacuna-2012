package  {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.events.Event;
	import com.adobe.images.JPGEncoder;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;
	
	/**
	 *	@author Nihav Jain
	 *	@class CluePic - container for the clue image
	 */
	public class CluePic extends Sprite
	{
		private var _bmpd:BitmapData;
		private var saveImage:ContextMenuItem;
		
		/**
		 *	@constructor
		 *	@param {BitmapData} bmpd - bitmap data for the image to be shown
		 */
		public function CluePic(bmpd:BitmapData) {
			_bmpd = bmpd;
			var hit:uint = bmpd.height;
			var wid:uint = bmpd.width;
			var mat:Matrix = new Matrix();
			if(hit < wid)
			{
				mat.scale(400/wid, 400/wid);
				mat.ty = 200*(wid-hit)/wid;
			}
			else
			{
				mat.scale(400/hit, 400/hit);
				mat.tx = 200*(hit-wid)/hit;
			}
			this.graphics.beginBitmapFill(bmpd, mat, false, true);
			this.graphics.drawRect(mat.tx, mat.ty, 400 - 2*mat.tx, 400 - 2*mat.ty);
			this.graphics.endFill();
			this.x = 262.5;
			this.y = 140;
			
			var cm:ContextMenu = new ContextMenu();
			saveImage = new ContextMenuItem("Save Image");
			
			saveImage.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, saveTheImage);
			cm.customItems.push(saveImage);
			this.contextMenu = cm;
		}
		
		/**
		 *	@method saveTheImage
		 *	@desc saves the displayed image as jpeg
		 */
		private function saveTheImage(ev:Event):void
		{
			var enc:JPGEncoder = new JPGEncoder(100);
			var file:FileReference = new FileReference();
			var ba:ByteArray = enc.encode(_bmpd);
			file.save(ba, "image.jpg");
		}
		
		/**
		 *	@method dispose
		 *	@desc adds the event listener for the right click context menu
		 */
		public function dispose():void
		{
			saveImage.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, saveTheImage);
		}
	}
}