/* GAME START */
/* Place Orders Phase */
/* Flip and Resolve Order Phase */


/* Game Start */
proc
	gameStart()
		t_GenerateBorders()
		t_addNames()
		var/turf/WorldTurfs/place
		var/area/Territories/territory
		var/obj/armyPiece/piece
		var/pieceType
		var/obj/WorldObjs/Strategy/Castle/castle
		var/garrisonRange = 0
		var/obj/garrisonPiece/Garrison/garrison

		//disable areas if we're in a three player game
		disableAreas()
		//NPC Garrisons
		populateNPCgarrisons()
		// List of the four army pieces everyone starts with
		for(var/players in Players)
			var/mob/Player/player = Players[players]

			if(player)
				var/list/startPieces = playPieceLookup(player.House)
				var/icon/iconFile = houseIconLookup(player.House)
				//Move player to map and allow them to move
				player.loc = getHouseLoc(player)
				player.canMove = 1

				//Place their garrison pieces
				territory = garrisonLookup(player.House)
				garrisonRange = 0
				castle = locate(/obj/WorldObjs/Strategy/Castle) in territory

				for(var/i = 1; i<=2; i++)
					garrison = new()
					garrison.Owner = player
					garrison.icon = iconFile
					place = null
					do
						garrisonRange+=1
						for(var/turf/picked in range(garrisonRange,castle))
							if(!picked.contents.len && picked.loc == territory)
								place = picked
								break
					while(!place)
					garrison.loc = place

				// Place their starting army pieces
				var/list/turfs
				for(var/i=1; i<=4; i++)
					turfs = new()
					pieceType = startPieces[i][1]
					piece = new pieceType()
					territory = locate(startPieces[i][2])

					for(var/turf/t in territory.contents)
						if(!t.contents.len)
							turfs += t

					piece.icon= iconFile
					piece.Owner = player
					player.armyPieces += piece
					place = pick(turfs)
					turfs -= place
					// If the territory isn't the the list of owned territories, add it.
					if(!player.territories.Find(territory))
						player.territories += territory
					piece.loc = place

				// Put Order Tokens in utility map
				//Draw in HUD
				h_fillHUD(player)

				var/tp = text2path("/obj/House_Cards/[player.House]")
				var/list/tempHouseCards = typesof(tp) - tp
				var/obj/House_Cards/temp
				for(var/card in tempHouseCards)
					temp = new card
					temp.Owner = player
					player.HouseCards += temp

		// Populate IronThrone/Fiefdoms/Raven trackways
		s_popTrackways()
		PlayerTurn = Tracks["IronThrone"][1]	// Set first player to top of the Iron Throne
		d_addOrdersToScreen()
		// Draw IronThrone/Fiefdoms/Raven trackways on screen
		s_fillScoreboard()
		//Add Player tokens to IronThrone/Fiefdoms/Raven trackways
		s_updateScoreboard()
		//Update supplies
		h_updateSupply()
		//Update influence
		h_influenceChange()
		d_startTurn()

	/* Creates associated list of piece types and their locations for each house */
	playPieceLookup(var/House)
		var/pieces[4][2]
		pieces[1][1] = /obj/armyPiece/Cavalry/
		pieces[2][1] = /obj/armyPiece/Infantry/
		pieces[3][1] = /obj/armyPiece/Infantry/
		pieces[4][1] = /obj/armyPiece/Ship/
		for(var/i = 1; i <=pieces.len, i++)
			if(House == "Stark")
				if(i==1||i==2)	pieces[i][2] = /area/Territories/Winterfell
				else if(i==3)	pieces[i][2] = /area/Territories/WhiteHarbour
				else if(i==4)	pieces[i][2] = /area/Territories/TheShiveringSea
			else if(House == "Lannister")
				if(i==1||i==2)	pieces[i][2] = /area/Territories/Lannisport
				else if(i==3)	pieces[i][2] = /area/Territories/StoneySept
				else if(i==4)	pieces[i][2] = /area/Territories/TheGoldenSound
			else if(House == "Greyjoy")
				if(i==1||i==2)	pieces[i][2] = /area/Territories/SearoadMarches
				else if(i==3)	pieces[i][2] = /area/Territories/Riverrun
		//		if(i==1||i==2)	pieces[i][2] = /area/Territories/Pyke
		//		else if(i==3)	pieces[i][2] = /area/Territories/GreywaterWatch
				else if(i==4)	pieces[i][2] = /area/Territories/IronmansBay
			else if(House == "Baratheon")
				if(i==1||i==2)	pieces[i][2] = /area/Territories/Dragonstone
				else if(i==3)	pieces[i][2] = /area/Territories/Kingswood
				else if(i==4)	pieces[i][2] = /area/Territories/ShipbreakerBay
			else if(House == "Tyrell")
				if(i==1||i==2)	pieces[i][2] = /area/Territories/Highgarden
				else if(i==3)	pieces[i][2] = /area/Territories/DornishMarches
				else if(i==4)	pieces[i][2] = /area/Territories/RedwyneStraits
			else if(House == "Martell")
				if(i==1||i==2)	pieces[i][2] = /area/Territories/Sunspear
				else if(i==3)	pieces[i][2] = /area/Territories/SaltShore
				else if(i==4)	pieces[i][2] = /area/Territories/SeaOfDorne
		return pieces

	garrisonLookup(var/House)
		var/area/Territories/ter = new()
		switch(House)
			if("Stark")
				ter = locate(/area/Territories/Winterfell)
			if("Lannister")
				ter = locate(/area/Territories/Lannisport)
			if("Greyjoy")
				ter = locate(/area/Territories/Pyke)
			if("Baratheon")
				ter = locate(/area/Territories/Dragonstone)
			if("Tyrell")
				ter = locate(/area/Territories/Highgarden)
			if("Martell")
				ter = locate(/area/Territories/Sunspear)
			else
				world<<"ERROR: garrisonLookup([House])"
				return -1
		return ter

	houseIconLookup(var/House)
		if(House == "Stark")
			var/icon/tempIcon = 'Stark.dmi'
			return tempIcon
		else if(House == "Lannister")
			var/icon/tempIcon = 'Lannister.dmi'
			return tempIcon
		if(House == "Baratheon")
			var/icon/tempIcon = 'Baratheon.dmi'
			return tempIcon
		if(House == "Tyrell")
			var/icon/tempIcon = 'Tyrell.dmi'
			return tempIcon
		if(House == "Greyjoy")
			var/icon/tempIcon = 'Greyjoy.dmi'
			return tempIcon
		if(House == "Martell")
			var/icon/tempIcon = 'Martell.dmi'
			return tempIcon

/* Place Orders Phase */

proc
	d_startTurn()
		PHASE = "Place Orders"
		world<<"Place your orders!"
		wa_cardPick()
		p_resetRouters()
		for(var/mob/Player/player in Tracks["IronThrone"])
			if(!player.client)
				player.AI()

	d_addOrdersToScreen()
		// Give each player their Order tokens
		for(var/mob/Player/player in Tracks["IronThrone"])
			for(var/Order in TypesOfOrders)
				var/obj/hudOrder/tempOrder = new Order(owner=player)
				player.Orders += tempOrder
				if(player.client)
					player.client.screen+=tempOrder



/* Flip and Resolve Order Phase */
	d_resolveOrders()
		var/list/allOrders = new/list()	//List of all orders in world, to be processed during resolution
		// Loop through all the territories
		// If they have a playPiece, they MUST also have an order. If no order present, NAME AND SHAME AND RETURN 0
		for(var/mob/Player/player in Tracks["IronThrone"])
			for(var/area/Territories/self in player.territories)
				var/obj/armyPiece/piece = locate(/obj/armyPiece/) in self
				if(piece)
					var/obj/hudOrder/order = locate(/obj/hudOrder/) in self
					if(order)
						allOrders+=order
					else
						world<<"[piece.Owner] has a [piece] in [self] and has not placed an Order Token!"
						return 0
		// Flip all the tokens
		PHASE = "Raven"
		g_flipOrders(allOrders)
		//d_startPhase()
		d_Raven()

	d_Raven()
		var/obj/HUD/Dominance/Raven/raven = locate("Raventoken")
		var/mob/Player/seer = raven.loc
		seer<<"Drag an unused order onto a territory to replace the order there or click Done."
		seer<<"<span style=font-size:xx-small>If you haven't used the Raven token this turn you may instead use it to see the next Wildling Card at any time.</span>"
		PHASE = "Raven"
		if(!seer.client)
			seer.AI()

	d_startPhase()
		world<<"Start phase [PHASE]."
		d_assignPlayerTurn(Tracks["IronThrone"])

	/* Used for cycling through players in turn order */
	d_rotatePlayer(var/cycle)
		var/list/turnOrder, list/tempList = Tracks["IronThrone"]
		var/pos = tempList.Find(PlayerTurn)
		turnOrder = tempList.Copy()
		if(cycle)
			//Move all players up to and including previous player (PlayerTurn) to the back of the queue
			turnOrder.Add(turnOrder.Copy(1,pos+1))
		turnOrder.Cut(1,pos+1)
		d_assignPlayerTurn(turnOrder)

	d_assignPlayerTurn(var/list/turnOrder)
		PlayerTurn = null
		for(var/i = 1; i<= turnOrder.len; i++)
			var/mob/Player/player = turnOrder[i]
		//	if(player.client)
			if(PHASE == "Raid")
				for(var/obj/hudOrder/Raid/raid in player.hudOrders)
					if(raid.z == 1 && raid.Owner == player)
						PlayerTurn = player
						world<<"[PlayerTurn]'s turn to play a [PHASE]."
						if(!player.client)
							player.AI()
						return
			else if(PHASE == "March")
				for(var/obj/hudOrder/March/march in player.hudOrders)
					if(march.z == 1 && march.Owner == player)
						PlayerTurn = player
						world<<"[PlayerTurn]'s turn to play a [PHASE]."
						if(!PlayerTurn.client)
							PlayerTurn.AI()
						return
			else if(PHASE == "Muster")
				for(var/area/Territories/territory in player.territories)
					if(territory.Castle && !territory.mustered)
						PlayerTurn = player
						world<<"[PlayerTurn]'s turn to muster."
						if(!PlayerTurn.client)
							PlayerTurn.AI()
						return
			else if(PHASE == "Reconcile Supply" || PHASE == "RR-Loss")
				world<<"here. [PlayerTurn]"
				if(PHASE == "RR-Loss" && player == Lowest)
					continue
				world<<"army check: [armyCheck(player)]"
				if(armyCheck(player) < 0)
					world <<"[player] now exceeds their supply limit, and needs to remove units before play can resume."
					player<<"Click on units to remove them. Game will resume once you have met your supply limit."
					PlayerTurn = player
					if(PlayerTurn.client)
						PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")
					return
			else if(PHASE == "RR-Loss")
				if(player==Lowest)
					continue
				if(armyCheck(player) < 0)
					world <<"[player] now exceeds their supply limit, and needs to remove units before play can resume."
					player<<"Click on units to remove them. Game will resume once you have met your supply limit."
					PlayerTurn = player
					if(PlayerTurn.client)
						PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")

			else if(PHASE == "AKBTW-Loss" || PHASE == "MR-Loss" || PHASE == "CK-Loss" || PHASE == "THD-Loss")
				if(player==Lowest || player.Exempt)
					continue
				PlayerTurn = player
				world<<"[PlayerTurn]'s turn."
				if(!player.client)
					player.AI()
				else
					if( PHASE == "MR-Loss" )
						PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"downgrade")
					if( PHASE == "CK-Loss" || PHASE == "THD-Loss" )
						PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")
				break

		if(!PlayerTurn)
			if(PHASE == "Raid")
				PHASE = "March"
				d_startPhase()
			else if(PHASE == "March")
				PHASE = "Clean Up"
				d_cleanUp()
				c_fillCards()
				c_pickCards()
			else if(PHASE=="Muster" || PHASE=="Reconcile Supply")
				c_pickCards()
			else if(PHASE == "AKBTW-Loss" || PHASE == "MR-Loss" || PHASE == "CK-Loss" || PHASE == "THD-Loss" || PHASE == "RR-Loss")
				WACARD.lowestEffect()

	d_cleanUp()
		for(var/mob/Player/player in Tracks["IronThrone"])
			for(var/obj/hudOrder/Consolidate/cons in player.hudOrders)
				if(cons.z == 1)
					explode(cons)
					var/count = 1
					for(var/obj/WorldObjs/Strategy/Consolidate/c in cons.loc.loc)
						count++
					cons.Owner.Influence += count
					world<<"[cons.Owner] received [count] influence from [cons.loc.loc]."
					h_influenceChange()
					del cons
		for(var/obj/hudOrder/Support/sup in world)
			if(sup.z == 1)
				explode(sup)
				del sup
		for(var/obj/hudOrder/Defend/def in world)
			if(def.z == 1)
				explode(def)
				del def

	g_flipOrders(var/list/allOrders)
		var/matrix/orderM = matrix()
		if(!SLOWFLIP)
			del orderM
		for(var/obj/hudOrder/order in allOrders)
			if(SLOWFLIP)
				world<<order.Back
				sleep(2)
				orderM.Translate(2,0)
				order.transform = orderM
				sleep(1)
				orderM.Translate(-4,0)
				order.transform = orderM
				sleep(1)
				orderM.Translate(2,0)
				order.transform = orderM
				for(var/i = 1; i<=5; i++)
					orderM.Scale(0.5,1)
					order.transform = orderM
					sleep(1)
			del order.Back
			if(SLOWFLIP)
				for(var/i = 1; i<=5; i++)
					orderM.Scale(2,1)
					sleep(1)
					order.transform = orderM
			g_addOutline(order)
	g_addOutline(var/obj/hudOrder/order)
		var/obj/outline = new()
		outline.icon = houseIconLookup(order.Owner.House)
		outline.icon_state = "outline"
		order.overlays += outline
