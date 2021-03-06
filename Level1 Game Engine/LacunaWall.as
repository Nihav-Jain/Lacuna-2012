﻿package 
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import flash.display.BitmapData;
	
	/**
	 *	@author Nihav Jain
	 *	@class LacunaWall - contains level map data and movement logic functions
	 */
	public class LacunaWall extends Sprite
	{
		/**
		 *	level mep is stored as a matrix of upwall and left wall
		 * 	level is divided into grids of 40x40px,
		 * 	each grid having a top horizontal wall (upwall) and a left vertical wall (leftwall)
		 * 	thus covering the entire level
		 */
		private var upwall:Vector.<Vector.<Boolean >  > ;
		public var leftwall:Vector.<Vector.<Boolean >  > ;
		
		private var wid:uint;
		private var hit:uint;
		
		public var picbmpds:Vector.<BitmapData>;
		
		public const gridwid:uint = 40;
		public const gridhit:uint = 40;
		private var blockx:uint = 6;
		
		public var lacunaMan:LacunaMan;
		public var xml2:XML;
		
		public var gridProperties:Vector.<Vector.<String>>;
		public var firearm:Vector.<MovieClip > ;
		public var crates:Vector.<Block>;
		public var clue:Vector.<Cluegif>;
		public var invisiWall:Vector.<InvisibleWall>;
		public var buttonW:ButtonSym;
		
		public var death:death_rect = new death_rect();
		public var brAlien:burntAlien = new burntAlien();
		
		public var panx:uint;
		public var pany:uint;
		
		private var leftLimit:int;
		private var rightLimit:int;		

		public var _nocorrans:Array;

		/**
		 *	@constructor invoked by FLA
		 *	@param {XML} _xml - xml containing level design
		 *	@param {Array} nocorrans - array containing the data for clues (answered/unanswered)
		 */
		public function LacunaWall(_xml:XML, nocorrans:Array)
		{
			xml2 = _xml;
			_nocorrans = nocorrans;
			
			wid = parseInt(_xml.maininfo. @ wid);
			hit = parseInt(_xml.maininfo. @ hit);
			
			upwall = new Vector.<Vector.<Boolean>>(wid+1, true);  
			leftwall = new Vector.<Vector.<Boolean>>(wid+1, true);
			
			var i:uint;
			var j:uint;
			
			for (i = 0; i<=wid; i++)
			{
				upwall[i] = new Vector.<Boolean>(hit+1, true);
				leftwall[i] = new Vector.<Boolean>(hit+1, true);

				for (j=0; j<=hit; j++)
				{
					upwall[i][j] = false;
					leftwall[i][j] = false;
				}
			}
			// top and bottom boundary of the level			
			for (i=0; i<wid; i++)
			{
				upwall[i][0] = true;
				upwall[i][hit] = true;
			}
			// left and right boundary of the level
			for(i=0; i<hit; i++)
			{
				leftwall[0][i] = true;
				leftwall[wid][i] = true;
			}
			// constructing walls and floors of level based on xml
			for each (var gridblock in _xml.wall.grid)
			{
				if (gridblock. @ upwall == "true")
				{
					upwall[parseInt(gridblock.@x)][parseInt(gridblock.@y)] = true;
					this.graphics.lineStyle(1);
					this.graphics.moveTo(parseInt(gridblock.@x)*gridwid,parseInt(gridblock.@y)*gridhit);
					this.graphics.lineTo((parseInt(gridblock.@x)+1)*gridwid, parseInt(gridblock.@y)*gridhit);
					this.graphics.endFill();

				}
				if (gridblock. @ leftwall == "true")
				{
					leftwall[parseInt(gridblock.@x)][parseInt(gridblock.@y)] = true;
					this.graphics.lineStyle(1);
					this.graphics.moveTo(parseInt(gridblock.@x)*gridwid,parseInt(gridblock.@y)*gridhit);
					this.graphics.lineTo(parseInt(gridblock.@x)*gridwid,(parseInt(gridblock.@y)+1)*gridhit);
					this.graphics.endFill();
				}
			}

			this.graphics.lineStyle(2);
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(wid*gridwid,0);

			this.graphics.lineTo(wid*gridwid,hit*gridhit);

			this.graphics.lineTo(0,hit*gridhit);
			this.graphics.lineTo(0,0);
			this.graphics.endFill();

			
			
			gridProperties=new Vector.<Vector.<String>>(wid,true);
			
			for (i = 0; i<wid; i++)
			{
				gridProperties[i] = new Vector.<String>(hit, true);
				for (j=0; j<hit; j++)
				{
					gridProperties[i][j] = "null";
				}
			}
			
			var fc:uint = 0;
			var cc:uint = 0;
			var clc:uint = 0;
			var iw:int = 0;
			
			// special objects in the level
			firearm = new Vector.<MovieClip > (_xml.specialsymbol.specobj.(@type == "fire").length(),true);
			crates = new Vector.<Block>(_xml.specialsymbol.specobj.(@type == "block").length(), true);
			clue = new Vector.<Cluegif>(_xml.specialsymbol.specobj.(@type == "cluebutton").length(), true);
			invisiWall = new Vector.<InvisibleWall>(_xml.specialsymbol.specobj.(@type == "invisiblewall").length(), true);
			
			for each (var specobj:XML in _xml.specialsymbol.specobj)
			{
				if(specobj.@type == "fire")
				{
					firearm[fc]=new fireblock();
					addChild(firearm[fc]);
					firearm[fc].x = parseInt(specobj. @ x) * gridwid;
					firearm[fc].y = parseInt(specobj. @ y) * gridhit;
					fc++;
					i=parseInt(specobj. @ x);
					j=parseInt(specobj. @ y)+1;
					for(;j<=parseInt(specobj. @ y)+parseInt(specobj. @ hit);j++)
					{
						gridProperties[i][j]="fire";
					}
				}
				else if(specobj.@type == "cluebutton")
				{
					if(nocorrans[parseInt(specobj.@clueno)] == 0)
					{
						clue[clc] = new Cluegif();
						clue[clc].clueno = parseInt(specobj.@clueno);
						clue[clc].x = parseInt(specobj.@x)*gridwid;
						clue[clc].y = parseInt(specobj.@y)*gridhit;
						clue[clc].xgrid = parseInt(specobj.@x);
						clue[clc].ygrid = parseInt(specobj.@y);
						addChild(clue[clc]);
						gridProperties[parseInt(specobj.@x)][parseInt(specobj.@y)] = "clue";
						clc++;
					}
				}
				else if(specobj.@type == "block")
				{
					crates[cc] = new Block();
					crates[cc].lacunaman = lacunaMan;
					crates[cc].x = parseInt(specobj.@x)*gridwid;
					crates[cc].y = parseInt(specobj.@y)*gridhit;
					addChild(crates[cc]);
					cc++;
				}
				else if(specobj.@type == "invisiblewall")
				{
					invisiWall[iw] = new InvisibleWall(parseInt(specobj.@x)*gridwid, parseInt(specobj.@y)*gridhit);
					addChild(invisiWall[iw]);
					invisiWall[iw].lacunawall = this;
					iw++;
				}
				else if(specobj.@type == "button")
				{
					buttonW = new ButtonSym();
					buttonW.x = parseInt(specobj.@x)*gridwid;
					buttonW.y = parseInt(specobj.@y)*gridhit;
					this.addChild(buttonW);
					gridProperties[parseInt(specobj.@x)][parseInt(specobj.@y)] = "button";
					
				}
			}  //for each loop ends
			
			for(cc = 0; cc<crates.length; cc++)
			{
				this.addChild(crates[cc]);
			}
		}  //constructor ends
		
		/**
		 *	@method chaluKaro
		 *	@desc sets the coordinates of the man
		 */
		public function chaluKaro():void
		{
			lacunaMan.x = parseInt(xml2.maininfo.@x)*gridwid;
			lacunaMan.y = parseInt(xml2.maininfo.@y)*gridhit;
		}
		
		var mwall:int = 0;
		
		/**
		 *	@method removeClue
		 *	@desc removes given clue from level
		 *	@param {uint} curclu - index of clu to remove
		 */
		public function removeClue(curclu:uint):void
		{
			this.removeChild(clue[curclu]);
			gridProperties[clue[curclu].xgrid][clue[curclu].ygrid] = "null";
			clue[curclu] = null;
			var temp:Vector.<Cluegif> = new Vector.<Cluegif>(clue.length-1, true);
			var i:uint = 0;
			var j:uint = 0;
			for(i=0; i<clue.length; i++)
			{
				if(i != curclu)
				{
					temp[j] = clue[i];
					j++;
				}
			}
			clue = temp;
			temp = null;
		}
		
		/****** MOVEMENT FUNCTIONS ******/
		
		/**
		 *	@method checkMoveLeft
		 *	@desc checks if object at given coordinates can move left
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		function checkMoveLeft(a:int,b:int):Boolean
		{
			if(Math.floor((a-lacunaMan.moveFactor)/40) != int(a/40))
			{
				if((leftwall[(int)((a)/40)][(int)(b/40)] == true) || (leftwall[(int)((a)/40)][(int)((b+38)/40)] == true))
				{
					return false;
				}
			}
			if((b%40) == 0)
			{
				if(blockOnLeft(a, b) >= 0)
				{
					var ileft:uint = blockOnLeft(a, b);
					if((blockOnLeft(crates[ileft].x, b) == -1) && ( (Math.floor((crates[ileft].x-lacunaMan.moveFactor)/40) == int(crates[ileft].x/40)) || (leftwall[(int)(crates[ileft].x/40)][b/40] == false) ) && (checkBlockUnder(crates[ileft].x, b-80) == false))
					{
						crates[ileft].x -= lacunaMan.moveFactor;
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					return true;
				}
			}
			else
			{
				if((upwall[(int)((a-lacunaMan.moveFactor)/40)][(int)((b+38)/40)] == false) && (blockOnLeft(a, gridhit*int(b/40)) == -1) && (blockOnLeft(a, gridhit*(int(b/40)+1)) == -1))
				{
					return true;
				}
			}
			return false;
		}

		/**
		 *	@method checkMoveRight
		 *	@desc checks if object at given coordinates can move right
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		function checkMoveRight(a:int, b:int):Boolean
		{
			if((leftwall[(int)((a+lacunaMan.moveFactor-1)/40)+1][(int)(b/40)] == false) && (leftwall[(int)((a+lacunaMan.moveFactor-1)/40)+1][(int)((b+38)/40)] == false))
			{
				if((b%40) == 0)
				{
					if(blockOnRight(a, b) >= 0)
					{
						var irit:uint = blockOnRight(a, b);
						if((blockOnRight(crates[irit].x, b) == -1) && (leftwall[(int)((crates[irit].x+lacunaMan.moveFactor-1)/40)+1][(b/40)] == false) && (checkBlockUnder(crates[irit].x, b-80) == false))
						{
							crates[irit].x += lacunaMan.moveFactor;
							return true;
						}
						else
						{
							return false;
						}
					}
					else
					{
						return true;
					}
				}
				else
				{
					if((upwall[(int)((a+lacunaMan.moveFactor-1)/40)+1][(int)((b+38)/40)] == false) && (blockOnRight(a, gridhit*int(b/40)) == -1) && (blockOnRight(a, gridhit*(int(b/40)+1)) == -1))
					{
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 *	@method checkMoveLeftbx
		 *	@desc checks if block at given coordinates can move left
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		function checkMoveLeftbx(a:int,b:int):Boolean
		{
			if(Math.floor((a-lacunaMan.moveFactor)/40) != int(a/40))
			{
				if((leftwall[(int)((a)/40)][(int)(b/40)] == true) || (leftwall[(int)((a)/40)][(int)((b+38)/40)] == true))
				{
					return false;
				}
			}
			if((b%40) == 0)
			{
				if(blockOnLeft(a, b) >= 0)
				{
					var ileft:uint = blockOnLeft(a, b);
					if((blockOnLeft(crates[ileft].x, b) == -1) && ( (Math.floor((crates[ileft].x-lacunaMan.moveFactor)/40) == int(crates[ileft].x/40)) || (leftwall[(int)(crates[ileft].x/40)][b/40] == false) ) && (checkBlockUnder(crates[ileft].x, b-80) == false))
					{
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					return true;
				}
			}
			else
			{
				if((upwall[(int)((a-lacunaMan.moveFactor)/40)][(int)((b+38)/40)] == false) && (blockOnLeft(a, gridhit*int(b/40)) == -1) && (blockOnLeft(a, gridhit*(int(b/40)+1)) == -1))
				{
					return true;
				}
			}
			return false;
		}

		/**
		 *	@method checkMoveRightbx
		 *	@desc checks if block at given coordinates can move right
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		function checkMoveRightbx(a:int, b:int):Boolean
		{
			if((leftwall[(int)((a+lacunaMan.moveFactor-1)/40)+1][(int)(b/40)] == false) && (leftwall[(int)((a+lacunaMan.moveFactor-1)/40)+1][(int)((b+38)/40)] == false))
			{
				if((b%40) == 0)
				{
					if(blockOnRight(a, b) >= 0)
					{
						var irit:uint = blockOnRight(a, b);
						if((blockOnRight(crates[irit].x, b) == -1) && (leftwall[(int)((crates[irit].x+lacunaMan.moveFactor-1)/40)+1][(b/40)] == false) && (checkBlockUnder(crates[irit].x, b-80) == false))
						{
							return true;
						}
						else
						{
							return false;
						}
					}
					else
					{
						return true;
					}
				}
				else
				{
					if((upwall[(int)((a+lacunaMan.moveFactor-1)/40)+1][(int)((b+38)/40)] == false) && (blockOnRight(a, gridhit*int(b/40)) == -1) && (blockOnRight(a, gridhit*(int(b/40)+1)) == -1))
					{
						return true;
					}
				}
			}
			return false;
		}
		
		/**
		 *	@method checkMoveUp
		 *	@desc checks if object at given coordinates can move up
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		function checkMoveUp(a:int,b:int):int
		{
			var xc:int=(int)(a/40);
			var yc:int=(int)(b/40);
			if(a%40 == 0)
			{
				if ((upwall[xc][yc] == true && b%40 < 20)|| checkBlockUnder(a, b-80) == true)
				{
					return 0;
				}
				else if ((yc > 0 && upwall[xc][yc-1] == true) || checkBlockUnder(a,b-120) == true)
				{
					return 40;
				}
				return 80;
			}
			else
			{
				if((upwall[xc][yc] == true && b%40 <20) || (upwall[xc+1][yc] == true &&  b%40 < 20) || checkBlockUnder(a, b-80) == true)
				{
					return 0;
				}
				else if((yc > 0 && upwall[xc][yc-1]==true) || (yc > 0 && upwall[xc+1][yc-1]==true) || checkBlockUnder(a,b-120) == true)
				{
					return 40;
				}
			}
			return 80;
		}
		
		/**
		 *	@method isFalling
		 *	@desc determines if element at given coordinates is falling or not (have floor below them or not)
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		public function isFalling(a:int, b:int):Boolean
		{
			// if given x coordinate lies inside 1 grid only
			if(a%40 == 0)
			{
				// then if there is a horizontal just below, return false
				if(upwall[int(a/40)][int(b/40) + 1] == true)
				{
					return false;
				}
				else
				{
					return true;
				}
			}
			else
			{
				// if object does not lies in more than 1 grid
				// check horizontal wall in both grids, and vertical wall in the intersection
				if((upwall[int(a/40)][int(b/40) + 1] == false) && (upwall[int((a+40)/40)][int(b/40) + 1] == false) && (leftwall[int((a+40)/40)][int(b/40) + 1] == false))
				{
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		
		/******** BLOCK FUNCTIONS ********/
		
		/**
		 *	@method blockOnLeft
		 *	@desc checks if there is a block to left of given coordinates
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return int - index of block on left, -1 if no block on left
		 */
		function blockOnLeft(a:int, b:int):int
		{
			var i:int;
			var diff:Number;
			for(i=0; i<crates.length;i++)
			{
				if((crates[i].isFalling == false) && (crates[i].y == b) && (b%40 == 0))
				{
					diff = a - crates[i].x;
					if(diff < (40 + lacunaMan.moveFactor) && diff >= 40)
						return i;	
				}
			}
			return -1;
		}
		/**
		 *	@method blockOnRight
		 *	@desc checks if there is a block to right of given coordinates
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return int - index of block on right, -1 if no block on right
		 */		
		function blockOnRight(a:int, b:int):int
		{
			var i:int;
			var diff:Number;
			for(i=0;i<crates.length;i++)
			{
				if(/*(crates[i].isFalling == false) &&*/  (crates[i].y == b)  && (b%40 == 0))
				{
					diff = crates[i].x - a;
					if(diff < (40 + lacunaMan.moveFactor) && diff >= 40)
						return i;
				}
			}
			return -1;
		}
		
		/**
		 *	@method checkBlockUnder
		 *	@desc checks if there is a block under the given object
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return boolean
		 */
		public function checkBlockUnder(a:int, b:int):Boolean
		{
			var i:int;
			var diffX:Number;
			
			for(i=0;i<crates.length;i++)
			{
				diffX = a - crates[i].x;
				if(diffX > -40 && diffX < 40 && crates[i].y == b + 40)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 *	@method blockOnLeftPick
		 *	@desc checks if there is a block to left of given coordinates can be picked
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return int - index of pickable block, -1 if no block on left
		 */
		function blockOnLeftPick(a:int, b:int):int
		{
			var i:int;
			var diff:Number;
			for(i=0; i<crates.length;i++)
			{
				if((crates[i].isFalling == false) && (crates[i].y == b) && (b%40 == 0) && checkBlockUnder(crates[i].x, crates[i].y - 80) == false)
				{
					diff = a - crates[i].x;
					if(diff <= 40 && diff > 0)
						return i;	
				}
			}
			return -1;
		}
		
		/**
		 *	@method blockOnRightPick
		 *	@desc checks if there is a block to right of given coordinates can be picked
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return int - index of pickable block, -1 if no block on right
		 */
		function blockOnRightPick(a:int, b:int):int
		{
			var i:int;
			var diff:Number;
			for(i=0;i<crates.length;i++)
			{
				if((crates[i].isFalling == false) && (crates[i].y == b) && (b%40 == 0) && checkBlockUnder(crates[i].x, crates[i].y - 80) == false)
				{
					diff = crates[i].x - a;
					if(diff <= 40 && diff > 0)
						return i;
				}
			}
			return -1;
		}
		
		/**
		 *	@method pickBlock
		 *	@desc picks the block, if possible, for given location of man
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 *	@return int - index of picked block, -1 if no block is picked
		 */
		function pickBlock(a:int, b:int):int
		{
			var blockIndexL:int;
			var blockIndexR:int;
			var blockIndexUL:int;	// UL: Upper Left
			var blockIndexUR:int;	// UR: Upper Right
			
			blockIndexL = blockOnLeftPick(a, b);
			blockIndexR = blockOnRightPick(a, b);
			blockIndexUL = blockOnLeftPick(a,b-40);
			blockIndexUR = blockOnRightPick(a,b-40);
			
			if(blockIndexUL >= 0 && blockIndexUR >= 0)
			{
				if(lacunaMan.dropBoxDir == "right")
					blockIndexUL = -1;					
			}
			
			if(blockIndexUL >= 0)
			{
				crates[blockIndexUL].x = a;
				crates[blockIndexUL].y = b - 40;
				crates[blockIndexUL].isCarried = true;
				return blockIndexUL;			
			}
			
			else if(blockIndexUR >= 0)
			{
				crates[blockIndexUR].x = a;
				crates[blockIndexUR].y = b - 40;
				crates[blockIndexUR].isCarried = true;
				return blockIndexUR;
			}
			
			if(blockIndexL >= 0 && blockIndexR >= 0)
			{
				if(lacunaMan.dropBoxDir == "right")
					blockIndexL = -1;					
			}

			if(blockIndexL >= 0)
			{
				if(checkMoveUp(crates[blockIndexL].x, crates[blockIndexL].y) == 0)
					return -1;
				crates[blockIndexL].x = a;
				crates[blockIndexL].y = b - 40;
				crates[blockIndexL].isCarried = true;
				return blockIndexL;
			}
			else if(blockIndexR >= 0)
			{
			
				if(checkMoveUp(crates[blockIndexR].x, crates[blockIndexR].y) == 0)
					return -1;
				crates[blockIndexR].x = a;
				crates[blockIndexR].y = b - 40;
				crates[blockIndexR].isCarried = true;
				return blockIndexR;
			}
			return -1;
		}
		
		/******** DEATH ANIMATION FUNCTIONS ********/
		
		/**
		 *	@method addDeath
		 *	@desc adds black rectangle for fading to black
		 */
		function addDeath():void
		{			
			death.width = wid * gridwid;
			death.height = hit * gridwid;
			
			addChild(death);
			
			death.alpha = 0;
			death.x = 0;
			death.y = 0;
		}
		
		/**
		 *	@method addBurnt
		 *	@desc adds burnt man image in position of man
		 *	@param {int} a - x coordinate
		 *	@param {int} b - y coordinate
		 */
		function addBurnt(a:int, b:int):void
		{
			brAlien.x = a;
			brAlien.y = b;
			addChild(brAlien);
		}
	}
}