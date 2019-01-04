mob
	verb
		debug_dropdown()
			var/text = {"<select name="number" onchange="set(this);">
				<option value="one"> One</option>
				<option value="two"> Two</option>
				<option value="three"> Three</option>
				</select>"}
			usr<<browse(text)
		debug_portSeize()
			var/list/turfs = new/list()
			var/area/Territories/port = locate(/area/Territories/Port/Lannisport)
			for(var/turf/t in port.contents)
				if(!locate(/obj/armyPiece/Ship) in t.contents)
					turfs += t
			for(var/i = 1, i<=3, i++)
				var/turf/T = pick(turfs)
				turfs -= T
				var/obj/armyPiece/Ship/ship = new (T)
				var/mob/Player/m = new()
				ship.Owner = m
				ship.icon = 'Lannister.dmi'
			sleep(10)
			for(var/obj/armyPiece/Ship/piece in port)
				var/obj/ShipOverlay/destroy = new /obj/ShipOverlay/Destroy(piece.loc)
				var/obj/ShipOverlay/seize = new /obj/ShipOverlay/Seize(piece.loc)
				destroy.master = piece
				seize.master = piece
				piece.overlayList += destroy
				piece.overlayList += seize
		debug_neighbours()
			world<<"Debug - Neighbours"
			for(var/area/Territories/t in world)
				world<<t
				world<<t.neighbours.len
				for(var/atom/a in t.neighbours)
					world<<"[a.name]"
				world<<"\n"
		debug_battleHouses()
			var/list/temp = Tracks["IronThrone"]
			var/mob/Player/enemy = input("Pick enemy.","debug_battleHouses") in temp
			showHouseCards(usr, enemy)
		debug_players()
			for(var/p in Players)
				var/mob/Player/p1 = Players[p]
				if(p1)
					world<<"[p] is [Players[p]] of House [p1.House]"

		debus_popTrackways()
			s_popTrackways()
			var/list/tempList = Tracks["IronThrone"]
			for(var/i = 1; i<=tempList.len; i++)
				world<<"Iron Throne [i] : [Tracks["IronThrone"][i]] \n\
				Fiefdoms [i] : [Tracks["Fiefdoms"][i]] \n\
				Raven [i] : [Tracks["Raven"][i]]"

		debug_setWildlingThreat()
			WildlingThreat = 5
		debug_addNames()
			t_addNames()
		debug_muster()
			PHASE = "DEBUG"
			PlayerTurn = usr
			winshow(PlayerTurn,"armyPieces",1)
/*		debug_crows()
			var/obj/Cards/WildlingAttack/CK/card = new()
			card.highestEffect(usr)
		debug_phasePlaceOrders()
			d_addOrdersToScreen()
		debug_resolveOrders()
			d_resolveOrders()
		debug_fillScoreboard()
			s_fillScoreboard()
		debug_fillHUD()
			h_fillHUD(usr)
		debug_supplyCheck()
			h_updateSupply()
		debug_cards()
			c_fillCards()
			c_pickCards()
		debug_rout()
			PHASE = "DEBUG"*/
		debug_addAI()
			d_addAI()
		debug_cards()
			c_fillCards()
			c_pickCards()
		debug_houseCardsTest()
			var/mob/Player/player = usr
			var/obj/House_Cards/card = new /obj/House_Cards/Tyrell/Loras
			card.Owner = player
			player.HouseCards += card
			world<<"added [card] to [player] house cards."
		debug_waUpdate()
			if(WildlingThreat<12)
				WildlingThreat += 2
			bounceslide(locate("waToken"))
		debug_darkwings()
			var/obj/HUD/Cards/PutToTheSword/d = new()
			d.effect()


	Player
		verb
			debug_territories()
				for(var/area in src.territories)
					world<<":: [area]"

proc
	d_addAI()
		var/list/forenames = list("Steve", "Garret", "Duncan", "Roger", "Paolo", "Mikey", "Crabs", "Tone", "Deckstar", "Captain")
		var/list/surnames = list("of_Cheam", "Shnitzel", "von_Vaderham", "Steveson", "Ping", "Blacks", "Jamesson", "Ulricksted")
		var/mob/Player/player1 = new()
		do
			player1.name = "[pick(forenames)]_[pick(surnames)]"
		while (Players[player1.name])
	//	player1.name = "[pick(forenames)]"
		var/position
		var/list/possiblePositions = list(2,3,4,5,6)
		for(position in possiblePositions )
			if(!LobbyPositions[position])
				LobbyPositions[position] = player1
				Players[player1.name] = player1
				PlayerKeys[player1.name] = "AIKEY"
				LobbyNames()
				break
		//Could not find a position for AI!
		if(LobbyPositions[position] != player1)
			return
		//Find the AI a house to take
/*		var/list/availableHouses = availableHouses()

		player1.House = pick(availableHouses)
		for(var/obj/Lobby/House/lobbyhouse in world)
			if(lobbyhouse.Position == position)
				lobbyhouse.icon_state = "[player1.House]"
				*/