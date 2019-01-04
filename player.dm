mob
	Login()
		client.onResize()
		return ..()
	Player
		var
			canMove = 1
			House = "" // Player's House
			Supply = 0
			Castles = 0
			Influence = 5
			Exempt = FALSE	// Whether they are exempt from the Wildling Attack or not
			obj/influenceObj
			bid = 0		// Amount of influence bid for current track
			bidlocked = FALSE
			list/armyPieces = new/list()
			list/hudOrders = new/list()
			area/list/Territories/territories = new/list()
			obj/hudOrder/curOrder
			area/Territories/castle
			list/HouseCards = new/list()
			list/DiscardPile = new/list()
			list/Orders = new/list()
			list/placedOrders = new/list()
			mob/Player/chatTarget

		Login()
			..()
			if(!inProgress) // If the game hasn't started yet
				src.loc = locate(34,37,2)
				canMove = 0
				//See if they are host and give them host position
				if(world.host==src.key)
					Players[src.name] = src
					PlayerKeys[src.name] = src.key
					LobbyPositions[1] = src
					LobbyNames()
					new /obj/HUD/Start(null, usr.client, list(anchor_x="CENTER", anchor_y="SOUTH", screen_x=6*32, screen_y=1*64, layer=HUD_LAYER),1)
				//if(src.key == "Ease"||src.key == "GokuSS4neo"||src.key == "Romkabant")
					winshow(usr,"debug",1)
		Move()
			if(canMove)
				..()

	proc
		returnPosition()
			for(var/pos in Players)
				if(PlayerKeys[pos] == usr.key)
					return pos
			return null


proc
	// Takes screen loc as text, and converts it into an x and y, with pixels at decimal points of full tiles
	parseScreenLoc(var/screenloc)
		var/locx, locy
		var/textPos = 1
		for(textPos, textPos<=lentext(screenloc), textPos++)
			var/tempC = copytext(screenloc,textPos,textPos+1)
			if(tempC == ":")
				break
			locx += "[tempC]"

		for(textPos=textPos+1, textPos<=lentext(screenloc), textPos++)
			var/tempC = copytext(screenloc,textPos,textPos+1)
			if(tempC == ",")
				break
		for(textPos=textPos+1, textPos<=lentext(screenloc), textPos++)
			var/tempC = copytext(screenloc,textPos,textPos+1)
			if(tempC == ":")
				break
			locy += "[tempC]"
		for(textPos=textPos+1, textPos<=lentext(screenloc), textPos++)
			var/tempC = copytext(screenloc,textPos,textPos+1)
			if(tempC == ",")
				break
		locx = text2num(locx)
		locy = text2num(locy)
		var/list/parsedLoc = list(locx,locy)
		return parsedLoc