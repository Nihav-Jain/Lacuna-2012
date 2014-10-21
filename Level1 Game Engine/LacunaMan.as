package 
{
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import fl.transitions.Tween;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import com.greensock.easing.Linear;
	import flash.geom.Rectangle;
	import flash.display.Loader;
	import flash.net.URLRequest;
	
	/**
	 *	@author Nihav Jain
	 *	@class LacunaMan - controls the movement and logic for man
	 */
	public class LacunaMan extends MovieClip
	{
		var jumping:Boolean;
		var moveFactor:int;
		var isleft:Boolean;
		var isright:Boolean;
		var isup:Boolean;
		var canMove:Boolean;
		var fall:Boolean;
		var fll:Boolean;
		var isFaling:Boolean;
		var canMoveLeft:Boolean;
		var canMoveRight:Boolean;
		var blockPickedUp:Boolean;
		var pickedBlockIndex:int;
		var midAirCount:int;
		var dropBoxDir:String;
		public var restartfunc:Function;
		
		private var startFalling:uint = 0;
		public var lacunaWall:LacunaWall;

		/**
		 *	@constructor
		 */
		public function LacunaMan()
		{
			jumping = false;
			moveFactor = 4;
			isleft = false;
			isright = false;
			isup = false;
			fall = false;
			fll = false;
			blockPickedUp = false;
			pickedBlockIndex = -1;
			dropBoxDir = "";
			midAirCount = 0;
			this.stop();
		}
		
		/**
		 *	@method startListening
		 *	@desc adds the key event and enter frame event listeners
		 */
		public function startListening():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEvent, false, 0);
			stage.addEventListener(KeyboardEvent.KEY_UP, stop_walk, false, 1);
			this.addEventListener(Event.ENTER_FRAME, move_man, false, 2);
			var i:int;
			if(lacunaWall.crates != null)
			{
				for(i=0;i<lacunaWall.crates.length;i++)
				{
					lacunaWall.crates[i].lacunawall = lacunaWall;
					lacunaWall.crates[i].lacunaman = this;
				}
			}
		}
		
		/**
		 *	@method stopListening
		 *	@desc removes the key event and enter frame listeners
		 */
		public function stopListening():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
			stage.removeEventListener(KeyboardEvent.KEY_UP, stop_walk);
			this.removeEventListener(Event.ENTER_FRAME, move_man);
		}

		/**
		 *	@method keyEvent
		 *	@desc listener for KEY_DOWN Event for man movement
		 */
		function keyEvent(ev:KeyboardEvent):void
		{
			/***** MAN MOVEMENT *****/
			if (ev.keyCode == 37)	// left key
			{
				isleft = lacunaWall.checkMoveLeft(this.x,this.y);
				this.play();
			}
			if (ev.keyCode == 39)	// right key
			{
				isright = lacunaWall.checkMoveRight(this.x,this.y);
				this.play();
			}
			// cannot jump when man has picked up a block
			if(blockPickedUp == false)
			{
				// cannot jump when in air
				if (jumping == false && ev.keyCode == 38 && isFaling == false && startFalling != 1)	// up key
				{
					isup = true;
					jumping = true;
					moveFactor = 12;
					midAirCount = 0;
				}
			}
			
			/***** TO PICK UP BLOCK *****/
			if(ev.shiftKey)
			{
				if(blockPickedUp == false)
				{
					pickedBlockIndex = lacunaWall.pickBlock(this.x, this.y);	
					if(pickedBlockIndex >= 0)
					{
						blockPickedUp = true;
					}
				}
				else
				{
					blockPickedUp = !dropBlock();
					if(blockPickedUp == false)
						pickedBlockIndex = -1;
				}
			}
			if(ev.ctrlKey)	// for debugging purpose
			{
				trace(x, y);
			}
		}
		
		/**
		 *	@method isPaning
		 *	@desc scroll rect function for following the character around the level
		 */
		private function isPaning():void
		{
			lacunaWall.scrollRect = new Rectangle(lacunaWall.panx, lacunaWall.pany, 400, 400);
		}

		/**
		 *	@method returnFromClue
		 *	@desc removes clue from stage, adds event listeners to resume gameplay
		 *	@param {boolean} anscorrectly
		 */
		public function returnFromClue(anscorrectly:Boolean):void
		{
			if(anscorrectly == true)
			{
				lacunaWall.removeClue(curClueI);
				lacunaWall._nocorrans[curClueOn] = 1;
				if(curClueOn == 2)	// only for level 1
				{
					lacunaWall.invisiWall[0].removeWall();
				}
			}
			startListening();
		}
		
		private var curClueOn:int = -1;
		private var curClueI:int = -1;
		public var clueFunc:Function;
		public var showClueBut:Function;
		public var disposeBut:Function;
		
		/**
		 *	@method move_man
		 *	@desc called on every frame, main man logic, MOST IMPORTANT
		 */
		function move_man(ev:Event):void
		{
			var i:int;
			var dist:int;
			var blockIndex:int;
			var bAlien:burntAlien = new burntAlien();
			
			if(isup)
			{
				// midAirCount = man will go up for 2 seconds, then fall
				if((lacunaWall.checkMoveUp(this.x, this.y) >= 20) && (midAirCount < 2))
				{
					this.y -= 20;
					midAirCount++;
				}
				else
				{
					comeDown();
				}
			}
			
			for(i=0; i<lacunaWall.firearm.length;i++)
			{
				lacunaWall.firearm[i].fire.height = 120;
			}
			/***** Check grid properties *****/
			if(lacunaWall.gridProperties[int((x+38)/40)][int(y/40)] == "fire")
			{
				// block on head protects man from fire
				if(blockPickedUp == false)
				{
					for(i=0; i<lacunaWall.firearm.length;i++)
					{
						dist = lacunaWall.firearm[i].x - this.x;
						if(dist < 40)
						{
							if(lacunaWall.firearm[i].getStatus(this.y - lacunaWall.firearm[i].y) == true)
							{
								lacunaWall.addBurnt(this.x, this.y);
								this.visible = false;
								stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
								this.removeEventListener(Event.ENTER_FRAME, move_man);
								deathAnime();
								break;
							}		
						}
					}
				}
				else
				{
					for(i=0; i<lacunaWall.firearm.length;i++)
					{
						dist = lacunaWall.firearm[i].x - this.x;
						if(dist > -40 && dist < 40)
						{
							lacunaWall.firearm[i].fire.height = 40;
						}
					}
				}
			}
			else if(lacunaWall.gridProperties[int(x/40)][int(y/40)] == "fire")
			{
				if(blockPickedUp == false)
				{
					for(i=0; i<lacunaWall.firearm.length;i++)
					{
						dist = lacunaWall.firearm[i].x - this.x;
						if(dist > -40)
						{
							if(lacunaWall.firearm[i].getStatus(this.y - lacunaWall.firearm[i].y) == true)
							{
								lacunaWall.addBurnt(this.x, this.y);
								this.visible = false;
								stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
								this.removeEventListener(Event.ENTER_FRAME, move_man);
								deathAnime();
								return;
							}
						}
					}
				}
				else
				{
					for(i=0; i<lacunaWall.firearm.length;i++)
					{
						dist = lacunaWall.firearm[i].x - this.x;
						if((dist > -40) && (dist < 40))
						{
							lacunaWall.firearm[i].fire.height = 40;
						}
					}
				}
			}
			
			if(blockPickedUp == true && (lacunaWall.gridProperties[int((x+38)/40)][int(y/40)] == "fire" || lacunaWall.gridProperties[int(x/40)][int(y/40)] == "fire"))
			{
				for(i=0; i<lacunaWall.firearm[i].length;i++)
				{
					dist = lacunaWall.firearm[i].x - this.x;
						if(dist > -40)
						{
							if(lacunaWall.firearm[i].getStatus(this.y - lacunaWall.firearm[i].y) == true)
							{
								lacunaWall.firearm[i].fire.visible = false;
								break;
							}
						}
				}
			}
			if(lacunaWall.gridProperties[int((x+38)/40)][int(y/40)] == "button" || lacunaWall.gridProperties[int(x/40)][int(y/40)] == "button")
			{
				if(lacunaWall.invisiWall[0].hasBeenSet == false)
				{
					if(lacunaWall.invisiWall[0].isConcrete == false)
					{
						lacunaWall.invisiWall[0].makeWall();
					}
					else
					{
						if(lacunaWall._nocorrans[2] == 1)
						{
							lacunaWall.invisiWall[0].removeWall();
						}
					}
				}
			}
			if(lacunaWall.gridProperties[int((x+38)/40)][int(y/40)] != "button" && lacunaWall.gridProperties[int(x/40)][int(y/40)] != "button")
			{
				lacunaWall.invisiWall[0].hasBeenSet = false;
			}
			
			if((lacunaWall.gridProperties[int(x/40)][int(y/40)] == "clue") || (lacunaWall.gridProperties[int((x+38)/40)][int(y/40)] == "clue") || (lacunaWall.gridProperties[int(x/40)][int((y+38)/40)] == "clue") || (lacunaWall.gridProperties[int((x+38)/40)][int((y+38)/40)] == "clue"))
			{
				for(i=0; i<lacunaWall.clue.length; i++)
				{
					if(((lacunaWall.clue[i].xgrid == int(x/40)) || (lacunaWall.clue[i].xgrid == int((x+38)/40))) && ((lacunaWall.clue[i].ygrid == int(y/40)) || (lacunaWall.clue[i].ygrid == int((y+38)/40))))
					{
						curClueOn = lacunaWall.clue[i].clueno;
						curClueI = i;
						if(lacunaWall.clue[i].isFirst == true)
						{
							this.removeEventListener(Event.ENTER_FRAME, move_man);
							this.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
							this.removeEventListener(KeyboardEvent.KEY_UP, stop_walk);
							lacunaWall.clue[i].isFirst = false;
							clueFunc.call(this,curClueOn);
							return;
						}
						else
						{
							showClueBut.call(this, curClueOn);
							lacunaWall.clue[i].temp = 0;
							TweenLite.killTweensOf(lacunaWall.clue[i]);
							TweenLite.to(lacunaWall.clue[i], 2, {temp:10, onComplete:disposeBut});
						}
						break;
					}
				}
			}
			
			var l:int;
			if((!jumping) || (startFalling == 1))
			{
				fall = lacunaWall.isFalling(this.x, this.y);
				if(fall == true && lacunaWall.checkBlockUnder(this.x, this.y) == false)
				{
					this.y += 20;
					isFaling = true;
					if(blockPickedUp == true)
						lacunaWall.crates[pickedBlockIndex].y += 20;
				}
				else
				{
					isFaling = false;
				}
				startFalling = 0;
			}
			
			if (isleft == true)
			{
				canMoveLeft = lacunaWall.checkMoveLeft(this.x, this.y);
				if(canMoveLeft)
				{
					if(pickedBlockIndex >= 0)
					{
						if(lacunaWall.checkMoveLeftbx(this.x, this.y - 40))
						{
							this.x -= moveFactor;
							lacunaWall.crates[pickedBlockIndex].x -= moveFactor;
						}
					}
					else
						this.x -= moveFactor;
				}
			}  //isleft == true
			
			if (isright == true)
			{
				canMoveRight = lacunaWall.checkMoveRight(this.x, this.y);
				if(canMoveRight)
				{
					if(pickedBlockIndex >= 0) // && lacunaWall.checkMoveRight(lacunaWall.crates[pickedBlockIndex].x, lacunaWall.crates[pickedBlockIndex].y))
					{
						if(lacunaWall.checkMoveRightbx(this.x, this.y - 40))
						{
							lacunaWall.crates[pickedBlockIndex].x += moveFactor;
							this.x +=  moveFactor;
						}
					}
					else
						this.x += moveFactor;
				}
			}  //isright == true

		}  //func end

		/******* MOVEMENT RELATED FUNCTIONS *******/
		
		/**
		 *	@method comeDown
		 *	@desc calls method addKeyUp
		 */
		function comeDown():void
		{
			TweenLite.delayedCall(0.1, addKeyUp);
		}
		
		/**
		 *	@method addKeyUp
		 *	@desc resets falling/jumping state to normal walking
		 */
		function addKeyUp():void
		{
			moveFactor = 4;
			jumping = false;
			startFalling = 1;
			isup = false;
		}
		
		/**
		 *	@method stop_walk
		 *	@desc listener for KEY_UP event
		 */
		function stop_walk(evt:KeyboardEvent):void
		{
			if (evt.keyCode == 37)
			{
				isleft = false;
				dropBoxDir = "left";
				this.gotoAndStop(1);
			}
			if (evt.keyCode == 39)
			{
				isright = false;
				dropBoxDir = "right";
				this.gotoAndStop(1);
			}
		}
		
		/**
		 *	@method deathAnime
		 *	@desc removes event listeners, prepares for death
		 */
		function deathAnime():void
		{
			lacunaWall.addDeath();
			disposeBut.call(this);
			this.removeEventListener(KeyboardEvent.KEY_DOWN, keyEvent);
			this.removeEventListener(Event.ENTER_FRAME, move_man);
			this.removeEventListener(KeyboardEvent.KEY_UP, stop_walk);
			TweenLite.to(lacunaWall.death, 2, {alpha:1, onComplete: restartfunc});
		}
		
		/**
		 *	@method dropBlock
		 *	@desc drop the block being carried (if possible) in last direction of movement (left/right)
		 *	@return boolean - if block was successfully dropped or not
		 */
		function dropBlock():Boolean
		{
			if(isleft == false && isright == false)
			{
				if(dropBoxDir == "left")
				{
					var z:uint;
					for(z = 0; z<10; z++)
					{
						if(lacunaWall.checkMoveLeft(lacunaWall.crates[pickedBlockIndex].x - z*4, lacunaWall.crates[pickedBlockIndex].y) == false)
						{
							return false;
						}
					}
					lacunaWall.crates[pickedBlockIndex].dropB(-1,this.x);
					return true;
				}
				else if(dropBoxDir == "right")
				{
					for(z = 0; z<10; z++)
					{
						if(lacunaWall.checkMoveRight(lacunaWall.crates[pickedBlockIndex].x + z*4, lacunaWall.crates[pickedBlockIndex].y) == false)
						{
							return false;
						}
					}
					lacunaWall.crates[pickedBlockIndex].dropB(1, this.x);
					return true;
				}
			}
			return false;
		}
		
	}//class close

}//package clos
