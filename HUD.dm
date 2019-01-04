obj
	HUD
		icon='HUD.dmi'
		layer = HUD_LAYER
		var
			click_state
			std_state
			client/client
			anchor_x = "WEST"
			anchor_y = "SOUTH"
			screen_x = 0
			screen_y = 0
			width = TILE_WIDTH
			height = TILE_HEIGHT
			clickProcPath

		proc
			setSize(W,H)
				width = W
				height = H
				if(anchor_x!="WEST"||anchor_y!="SOUTH")
					updatePos()

			setPos(X,Y,AnchorX="WEST",AnchorY="SOUTH")
				screen_x = X
				anchor_x = AnchorX
				screen_y = Y
				anchor_y = AnchorY
				updatePos()

			updatePos()
				var/ax
				var/ay
				var/ox
				var/oy
				if(!client)
		//			world<<"no client [src]"
					return 0
				switch(anchor_x)
					if("WEST")
						ax = "WEST+0"
						ox = screen_x + client.buffer_x
					if("EAST")
						if(width>TILE_WIDTH)
							var/tx = ceil(width/TILE_WIDTH)
							ax = "EAST-[tx-1]"
							ox = tx*TILE_WIDTH - width - client.buffer_x + screen_x
						else
							ax = "EAST+0"
							ox = TILE_WIDTH - width - client.buffer_x + screen_x
					if("CENTER")
						ax = "CENTER+0"
						ox = floor((TILE_WIDTH - width)/2) + screen_x
				switch(anchor_y)
					if("SOUTH")
						ay = "SOUTH+0"
						oy = screen_y + client.buffer_y
					if("NORTH")
						if(height>TILE_HEIGHT)
							var/ty = ceil(height/TILE_HEIGHT)
							ay = "NORTH-[ty-1]"
							oy = ty*TILE_HEIGHT - height - client.buffer_y + screen_y
						else
							ay = "NORTH+0"
							oy = TILE_HEIGHT - height - client.buffer_y + screen_y
					if("CENTER")
						ay = "CENTER+0"
						oy = floor((TILE_HEIGHT - height)/2) + screen_y
				screen_loc = "[ax]:[ox],[ay]:[oy]"

			show()
				updatePos()
				if(client)
					client.screen += src
					client.hud += src

			hide()
				if(client)
					client.screen -= src
					client.hud -= src


		New(loc=null, client/Client, list/Params,show=1)
			client = Client
			for(var/v in Params)
				vars[v] = Params[v]
			if(show) show()
			if(!std_state) std_state = icon_state
			if(!click_state) click_state = icon_state

		supplyCastle
			icon_state="supplyCastle"
			Click()
				if(winget(usr, "supplyAndVictory", "is-visible")=="true")
					winshow(usr,"supplyAndVictory",0)
				else
					h_updateVictory()
					h_updateSupplyAndVictoryTracks(usr)
					winshow(usr,"supplyAndVictory",1)

		HouseCards
			icon_state="HouseCards"
			Click()
				showHouseCards(usr)

		PlayerToken
			icon_state="Order"
			maptext_x = 12
			var
				mob/Player/Owner
				old_y = 0
			MouseEntered()
				src.layer = HUD_LAYER+1
				bounce(src)
				src.layer = HUD_LAYER

		Influence
			icon_state="Influence"
			var/mob/Player/owner

			MouseDown(location,control,params)
				if(PlayerTurn == usr && PHASE == "March")
					if(PlayerTurn.curOrder)	// If the Player has a current order
						src.mouse_drag_pointer = icon(src.icon, src.icon_state)
					else
						src.mouse_drag_pointer = 0
						PlayerTurn << "You must be activating a March Order to leave Influence."
				else if(PlayerTurn != usr)
					src.mouse_drag_pointer = 0
					usr << "It is not your turn."

			MouseDrop(var/over_object,var/turf/src_location,var/atom/over_location,var/src_control,var/over_control,var/params)
				if(!over_location)
					return
				if(PlayerTurn == usr && PHASE == "March")
					if(PlayerTurn.curOrder)	// If the Player has a current order
						if(over_control=="default.main")
							var/count = 0
							var/area/Territories/territory = PlayerTurn.curOrder.loc.loc
							if(over_location.loc != territory)
								PlayerTurn << "Use influence to hold [territory] once your troops have left."
								return 0
							for(var/obj/armyPiece/pieces in territory) count++
							if(!count)
								for(var/obj/playPiece/Influence/existing in territory) // If there's already an Influence there, just move it around
									existing.loc = over_location
									return 0
								if(PlayerTurn.Influence>=1)
									var/obj/playPiece/Influence/influence = new(over_location)
									influence.icon = houseIconLookup(PlayerTurn.House)
									influence.owner = PlayerTurn
									PlayerTurn.Influence--
									h_influenceChange()
								else
									PlayerTurn<<"You do not have enough influence to hold [territory]."
							else
								PlayerTurn<<"[territory] can only by held by influence when not held by troops."

					else
						src.mouse_drag_pointer = 0
						PlayerTurn << "You must be activating a March Order to leave Influence."
				else if(PlayerTurn != usr)
					PlayerTurn << "It is not your turn."





proc
	/*Fills the HUD with everything that should only be placed once and never updated */
	h_fillHUD(var/mob/Player/player)
		if(player.client)
			h_fillMainMapHud(player)
			s_fillSupplyAndVictoryTracks(player)
			h_popArmyPiecesMap(player)

	h_fillMainMapHud(var/mob/Player/player)
		if(player.client)
			//Fill out the  HUD
			for(var/x = 0; x<=9; x++)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="WEST", anchor_y="SOUTH", screen_x=x*TILE_WIDTH, screen_y=0, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="WEST", anchor_y="SOUTH", screen_x=x*TILE_WIDTH, screen_y=TILE_WIDTH, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotTop", anchor_x="WEST", anchor_y="SOUTH", screen_x=x*TILE_WIDTH, screen_y=TILE_WIDTH*2, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="WEST", anchor_y="NORTH", screen_x=x*TILE_WIDTH, screen_y=-0, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="WEST", anchor_y="NORTH", screen_x=x*TILE_WIDTH, screen_y=-TILE_WIDTH, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="Top", anchor_x="WEST", anchor_y="NORTH", screen_x=x*TILE_WIDTH, screen_y=-TILE_WIDTH*2, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="EAST", anchor_y="SOUTH", screen_x=-x*TILE_WIDTH, screen_y=0, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="EAST", anchor_y="SOUTH", screen_x=-x*TILE_WIDTH, screen_y=TILE_WIDTH, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotTop", anchor_x="EAST", anchor_y="SOUTH", screen_x=-x*TILE_WIDTH, screen_y=TILE_WIDTH*2, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="EAST", anchor_y="NORTH", screen_x=-x*TILE_WIDTH, screen_y=-0, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="BotMid", anchor_x="EAST", anchor_y="NORTH", screen_x=-x*TILE_WIDTH, screen_y=-TILE_WIDTH, layer=HUD_LAYER-1),1)
				new /obj/HUD(null, player.client, list(icon_state="Top", anchor_x="EAST", anchor_y="NORTH", screen_x=-x*TILE_WIDTH, screen_y=-TILE_WIDTH*2, layer=HUD_LAYER-1),1)
			//Add Influence
			var/icon/influenceIcon = houseIconLookup(player.House)
			new /obj/HUD/Influence(null, player.client, list(icon=influenceIcon, anchor_x="EAST", anchor_y="SOUTH", screen_x=INFLUENCE_X*TILE_WIDTH, screen_y=16), 1)
			var/obj/HUD/slot = new /obj/HUD(null, player.client, list(icon='Scoreboard.dmi',icon_state="Slot",anchor_x="EAST", anchor_y="SOUTH", screen_x=SLOT_X*TILE_WIDTH, screen_y=16), 1)
			player.influenceObj = slot
			player.influenceObj.maptext_x=10
			player.influenceObj.maptext_y=8
			new /obj/HUD/EndPhase(null, player.client, list(anchor_x="EAST", anchor_y="SOUTH", screen_x=END_X*TILE_WIDTH, screen_y=16), 1)
			new /obj/HUD/HouseCards(null, player.client, list(anchor_x="EAST", anchor_y="SOUTH", screen_x=HOUSECARDS_X*TILE_WIDTH, screen_y=16), 1)
			new /obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="Spear",anchor_x="EAST", anchor_y="NORTH", screen_x=WILDLING_X*TILE_WIDTH, screen_y=-TILE_HEIGHT), 1)
			new /obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="waToken",tag="waToken",anchor_x="EAST", anchor_y="NORTH", screen_x=WATOKEN_X*TILE_WIDTH, screen_y=-TILE_HEIGHT), 1)

			//Add supply track

			new/obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="Supply", anchor_x="WEST", anchor_y="SOUTH", screen_x=0.5*TILE_WIDTH, screen_y=TILE_HEIGHT), 1)
			for(var/x = 0; x<=6; x++)
				new /obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="[x]", anchor_x="WEST", anchor_y="SOUTH", screen_x=(1.5+x)*TILE_WIDTH, screen_y=62), 1)

			//Add victory track
			new/obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="Castle", anchor_x="WEST", anchor_y="NORTH", screen_x=0.5*TILE_WIDTH, screen_y=-TILE_HEIGHT), 1)
			for(var/x = 0; x<=7; x++)
				new /obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="castleCount", anchor_x="WEST", anchor_y="NORTH", screen_x=(1.5+x)*TILE_WIDTH, screen_y=0,\
					maptext="<b>[x]</b>",maptext_x=12,maptext_y=10), 1)

			//Add Wildling Track
			for(var/x = 0; x<=6; x++)
				new /obj/HUD(null, player.client, list(icon='HUD.dmi',icon_state="spearCount", anchor_x="EAST", anchor_y="NORTH", screen_x=(-6.5+x)*TILE_WIDTH, screen_y=0,\
					maptext="<b>[x*2]</b>",maptext_x=12,maptext_y=10), 1)




	h_updateSupply()
		for(var/mob/Player/player in Tracks["IronThrone"])
			player.Supply = 0
			for(var/area/Territories/territory in player.territories)
				player.Supply += territory.Supply
		h_updateSupplyAndVictoryTracks()

	h_updateVictory()
		for(var/mob/Player/player in Tracks["IronThrone"])
			player.Castles = 0
			for(var/area/Territories/territory in player.territories)
				if(territory.Castle)
					player.Castles++
		h_updateSupplyAndVictoryTracks()

	h_updateSupplyAndVictoryTracks()
		for(var/mob/Player/viewer in Tracks["IronThrone"])
			//Clear their screen of all tokens first
			if(viewer.client)
				for(var/obj/HUD/PlayerToken/pt in viewer.client.hud)
					pt.hide()
			//Then populate
			//Add Player Tokens to Victory and Supply Tracks
				var/list/supplies = new/list()
				var/list/castles = new/list()
				var/icon/influenceIcon
				var/count, tokenY
				for(var/mob/Player/player in Tracks["IronThrone"])
					//Add Player Tokens to Supply Track
					influenceIcon = houseIconLookup(player.House)
					count = listCount(player.Supply,supplies)
					supplies.Add(player.Supply)
					tokenY = 32-(count*7)
					new/obj/HUD/PlayerToken(null, viewer.client, list(icon=influenceIcon, anchor_x="WEST", anchor_y="SOUTH", screen_x=(1.5+player.Supply)*TILE_WIDTH, screen_y=tokenY), 1)

					//Add Player Tokens to Victory Track
					count = listCount(player.Castles,castles)
					castles.Add(player.Castles)
					tokenY = 30+(count*7)
					new/obj/HUD/PlayerToken(null, viewer.client, list(icon=influenceIcon, anchor_x="WEST", anchor_y="NORTH", screen_x=(player.Castles+2.5)*TILE_WIDTH, screen_y=-tokenY), 1)

	h_influenceChange()
		for(var/mob/Player/player in Tracks["IronThrone"])
			if(player.client)
				player.influenceObj.maptext = "<b>[player.Influence]</b>"


	/* Count items in list */
	listCount(var/needle, var/list/haystack)
		var/count = 0
		var/pos = 1
		while(pos <= haystack.len)
			var/find = haystack.Find(needle,pos)
			if(find)
				pos = find + 1
				++count
			else
				break
		return count

	/* Convert decimal ints to a screen loc */
	intToScreenLoc(var/int)
		var/screenloc = "[round(int)]:[round((int-round(int))*32)]"
		return screenloc

	/* Add a list of objs to a client's screen */
	h_addToScreen(var/client/client, var/list/items)
		if(client && items.len>=1)
			for(var/item in items)
				client.screen += item
		else
			return 0
		return 1


	h_popArmyPiecesMap(var/mob/Player/player)
		if(player.client)
			if(!locate(/obj/armyPiece/Infantry/) in player.client.screen)
				var/icon/iconFile = houseIconLookup(player.House)
				var/obj/armyPiece/Infantry/infantry = new()
				var/obj/armyPiece/Cavalry/cavalry = new()
				var/obj/armyPiece/Ship/ship = new()
				infantry.screen_loc	="apMap:1,1"
				cavalry.screen_loc	="apMap:2,1"
				ship.screen_loc		="apMap:3,1"
				var/list/toScreen = list(infantry, cavalry, ship)
				for(var/obj/armyPiece/piece in toScreen)
					piece.Owner	= player
					piece.icon	= iconFile
				h_addToScreen(player.client, toScreen)

	returnHighestTracks(var/mob/Player/player)
		var/list/tempList
		var/list/highestTracks
		var/pos, highestPos = 0
		for(var/track in Tracks)
			tempList = Tracks[track]
			pos = tempList.Find(player)
			if(pos > highestPos)
				highestTracks.len = 0
				highestPos = pos
			if(pos >= highestPos)
				highestTracks += track
		return highestTracks


	bounce(var/atom/subject)
		animate(subject, transform = matrix()*2, time = 5, easing = SINE_EASING)
		sleep(5)
		animate(subject, transform = null, time = 5, easing = ELASTIC_EASING)

	explode(var/atom/subject)
		var/matrix/orderM = matrix()
		orderM.Translate(2,0)
		subject.transform = orderM
		sleep(2)
		orderM.Translate(-4,0)
		subject.transform = orderM
		sleep(2)
		orderM.Translate(2,0)
		subject.transform = orderM
		subject.layer = 10
		for(var/i = 1; i<=4; i++)
			orderM.Scale(1.5,1.5)
			subject.transform = orderM
			var/icon/I = icon(subject.icon, subject.icon_state)
			I.SetIntensity(2)
			subject.icon = I
			subject.alpha /= 2
			sleep(1)

	slowexplode(var/atom/subject)
		animate(subject, transform = matrix()*20, time = 20, easing = SINE_EASING)
		for(var/i = 1; i<=20; i++)
			sleep(1)
			var/icon/I = icon(subject.icon, subject.icon_state)
			I.SetIntensity(1.2)
			subject.icon = I
			subject.alpha -= 13
		del subject
	bounceslide(var/obj/HUD/subject)
		animate(subject, transform = matrix()*2, time = 5, easing = SINE_EASING)
		for(var/i = 1; i<=8; i++)
			subject.screen_x+=4
			subject.updatePos()
			sleep(0.5)
		animate(subject, transform = null, time = 5, easing = ELASTIC_EASING)
		subject.screen_x = (WATOKEN_X*TILE_WIDTH) + (16*WildlingThreat)
		subject.updatePos()