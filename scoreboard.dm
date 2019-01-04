obj
	Scoreboard
		icon = 'Scoreboard.dmi'
		var
			track

		Supply
			icon_state="Supply"
			screen_loc="supMap:1,4"
		Castle
			icon_state="Castle"
			screen_loc="supMap:1,9"
		Track
			layer = 4
			IronThrone
				icon_state="IronThrone"
				screen_loc="scoreboard:1,3"
				track = "IronThrone"
				Click()
					beenClicked(usr)

			Fiefdoms
				icon_state="Fiefdoms"
				screen_loc="scoreboard:1,2"
				track = "Fiefdoms"
				Click()
					beenClicked(usr)

			Raven
				icon_state="Raven"
				screen_loc="scoreboard:1,1"
				track = "Raven"
				Click()
					beenClicked(usr)
			var
				list/Tokens = new/list()
			proc
				beenClicked(var/mob/Player/clicker)
					if(PHASE == "AKBTW-Win")
						if(clicker == Highest)
							var/list/tempList = Tracks[src.track]
							tempList.Remove(Highest)
							tempList.Insert(1,Highest)
							var/trackName = src.track
							if(trackName=="IronThrone") trackName = "Iron Throne"
							world<<"[Highest] has moved to the top of the [trackName] track."
							s_updateScoreboard()
							c_endCardPhase()
					else if(PHASE == "AKBTW-Loss"&&src.track!="IronThrone")
						if(PlayerTurn == clicker)
							movePlayer(PlayerTurn, src.track, 7) 			// Move PlayerTurn to bottom of selected list
							world<<"[PlayerTurn] has moved to the bottom of the [src.track] track."
							d_rotatePlayer(FALSE)
					else if(PHASE == "BattleHC")
						for(var/player in battle.houseCards)
							var/obj/House_Cards/card = battle.houseCards[player]
							if(istype(card,/obj/House_Cards/Martell/Doran))
								if(!card.used && card.Owner == clicker)
									var/mob/Player/enemy
									for(enemy in battle.combatants)
										if(enemy != clicker)
											break
									if(enemy)
										movePlayer(enemy, src.track, 7)
										world<<"[enemy] has moved to the bottom of the [src.track] track."
										card.used = TRUE
										if(battle_HouseCardsCheck()) battle_Blade()
									else
										world<<"ERROR: [src.track] - beenClicked() - no enemy?"
				movePlayer(var/mob/Player/player, var/list/track, var/pos)
					if(pos>track.len)
						pos = track.len
					var/oldPos = track.Find(player)
					track.Cut(oldPos, oldPos+1)
					track.Insert(pos,player)
					s_updateScoreboard()
		Slot
			icon_state="Slot"
			layer = 4
		Flags
			layer = 4
		PlayerToken
			icon_state="Order"
			maptext_x = 12
			var
				mob/Player/Owner

			MouseDrop(var/over_object,var/turf/src_location,var/atom/over_location,var/src_control,var/over_control,var/params)

				if(swapper == usr)
					if(over_control=="default.scoreboard")
						var/obj/Scoreboard/PlayerToken/droppedOn = over_object
						if(droppedOn == src)
							return 0
						if(PHASE == "ClashOfKings-ITEnd" && droppedOn.track == src.track)
							if(src.Owner.bid == droppedOn.Owner.bid)
								var/list/tempList = Tracks["[src.track]"]
								var/temp = tempList.Find(droppedOn.Owner)
								world<<"[usr] swapped [src.Owner] and [droppedOn.Owner]."
								tempList[tempList.Find(src.Owner)] = droppedOn.Owner
								tempList[temp] = src.Owner
					s_updateScoreboard()


			MouseDown(location,control,params)
				if(Tracks["IronThrone"][1] == usr)
					var/obj/Scoreboard/Track/throne 	= locate("IronThrone")
					var/obj/Scoreboard/Track/fiefdoms 	= locate("Fiefdoms")
					var/obj/Scoreboard/Track/raven 		= locate("Raven")
					if(PHASE == "ClashOfKings-ITEnd" && throne.Tokens.Find(src) \
						|| PHASE == "ClashOfKings-FEnd" && fiefdoms.Tokens.Find(src) \
						|| PHASE == "ClashOfKings-REnd" && raven.Tokens.Find(src))
						src.mouse_drag_pointer = icon(src.icon, src.icon_state)
					else
						src.mouse_drag_pointer = 0


				else
					src.mouse_drag_pointer = 0

proc
	s_fillSupplyAndVictoryTracks(var/mob/Player/viewer)
		if(viewer.client)
			//Add the single Supply and Castle hudchoices
			var/obj/Scoreboard/Supply/hud1 = new()
			var/obj/Scoreboard/Castle/hud2 = new()
			h_addToScreen(viewer.client, list(hud1,hud2))
			//Fill in the different SUPPLY Flags
			for(var/x = 0; x<=6; x++)
				var/obj/Scoreboard/blank = new()
				blank.icon_state="[x]"
				blank.screen_loc="supMap:[x+2],5"
				viewer.client.screen+=blank
			//Fill in Castle Counters
			for(var/x = 1; x<=7; x++)
				var/obj/Scoreboard/blank = new()
				blank.icon_state="castleCount"
				blank.screen_loc="supMap:[x+1],10"
				viewer.client.screen+=blank
			//Add blank overlays to Castle Counters to position mapText
			for(var/x = 1; x<=7; x++)
				var/obj/Scoreboard/blank = new()
				blank.maptext="[x]"
				blank.screen_loc="supMap:[x+1]:10,10:10"
				viewer.client.screen+=blank

	s_fillScoreboard()
		var/obj/Scoreboard/Track/IronThrone/scoreboard1 = new()
		var/obj/Scoreboard/Track/Fiefdoms/scoreboard2 = new()
		var/obj/Scoreboard/Track/Raven/scoreboard3 = new()
		scoreboard1.tag = "IronThrone"
		scoreboard2.tag = "Fiefdoms"
		scoreboard3.tag = "Raven"
		var/list/tempList = Tracks["IronThrone"]
		for(var/mob/Player/player in tempList)
			if(player.client)
				h_addToScreen(player.client, list(scoreboard1, scoreboard2, scoreboard3))
				//Fill in the slots for IRONTHRONE/FIEFDOMS/RAVEN
				for(var/y = 1; y<=3; y++)
					for(var/x = 1; x<=tempList.len; x++)
						var/obj/Scoreboard/Slot/slot = new()
						slot.screen_loc="scoreboard:[x+1],[y]"
						slot.maptext="[x]"
						player.client.screen+=slot
	s_popTrackways()
		for(var/players in Players)
			var/mob/Player/player = Players[players]
			if(player)
				if(player.House=="Stark") 			{Tracks["IronThrone"][3]=player; Tracks["Fiefdoms"][4]=player;	Tracks["Raven"][2]=player;}
				else if(player.House=="Lannister") 	{Tracks["IronThrone"][2]=player; Tracks["Fiefdoms"][6]=player;	Tracks["Raven"][1]=player;}
				else if(player.House=="Baratheon") 	{Tracks["IronThrone"][1]=player; Tracks["Fiefdoms"][5]=player;	Tracks["Raven"][4]=player;}
				else if(player.House=="Tyrell") 	{Tracks["IronThrone"][6]=player; Tracks["Fiefdoms"][2]=player;	Tracks["Raven"][5]=player;}
				else if(player.House=="Greyjoy") 	{Tracks["IronThrone"][5]=player; Tracks["Fiefdoms"][1]=player;	Tracks["Raven"][6]=player;}
				else if(player.House=="Martell") 	{Tracks["IronThrone"][4]=player; Tracks["Fiefdoms"][3]=player;	Tracks["Raven"][3]=player;}
		//Shuffle everyone up - reduce list length to number of Players

		for(var/lists in Tracks)
			for(var/i in Tracks[lists])
			var/list/tempList = Tracks[lists]
			while(tempList.Remove("")) {}

	s_updateScoreboard()
		var/obj/Scoreboard/Track/scoreboardTrack = locate("IronThrone")

		//If the throne has any Tokens on it already, rearrange them, else add Tokens
		//We can assume that if the throne has Tokens, so does the fiefdoms and the raven.
		var/list/templist
		if(scoreboardTrack.Tokens.len)
			// Clear out Dominance Tokens
			for(var/mob/Player/player in Tracks["IronThrone"])
				for(var/obj/HUD/Dominance/d in player.contents)
					del d

			for(var/track in Tracks)
				templist = Tracks[track]
				scoreboardTrack = locate(track)

				for(var/obj/Scoreboard/PlayerToken/token in scoreboardTrack.Tokens)
					var/pos = templist.Find(token.Owner)
					token.screen_loc = "scoreboard: [pos+1],[s_track2y(track)]"
					if(pos==1) s_reassignDominance(token.Owner, track)

	/*		templist = Tracks["Fiefdoms"]
			for(var/obj/Scoreboard/PlayerToken/token in fiefdoms.Tokens)
				var/pos = templist.Find(token.Owner)
				token.screen_loc = "scoreboard: [pos+1],2"
			templist = Tracks["Raven"]
			for(var/obj/Scoreboard/PlayerToken/token in raven.Tokens)
				var/pos = templist.Find(token.Owner)
				token.screen_loc = "scoreboard: [pos+1],1"	*/
		else
			// Make tokens for each player
			for(var/mob/Player/player in Tracks["IronThrone"])
				s_createToken(player, "IronThrone")
				s_createToken(player, "Fiefdoms")
				s_createToken(player, "Raven")

	s_createToken(var/mob/Player/player, var/track)
		var/y = s_track2y(track)
		var/obj/Scoreboard/PlayerToken/token1 = new()
		var/pos1
		token1.Owner = player
		var/list/l = Tracks[track]
		pos1= l.Find(token1.Owner)
		token1.screen_loc = "scoreboard: [pos1+1],[y]"
		token1.icon = houseIconLookup(player.House)
		token1.track = track
		var/obj/Scoreboard/Track/HUDtrack = locate("[track]")
		HUDtrack.Tokens+=token1

		// Add tokens to all player's screens
		for(var/mob/Player/others in Tracks["IronThrone"])
			if(others.client)
				for(var/obj/Scoreboard/PlayerToken/token in HUDtrack.Tokens)
					others.client.screen += token
		if(pos1==1)
			s_createDominance(player, track)


	s_createDominance(var/mob/Player/player, var/track)
		var/y = s_track2y(track)
		var/hudtype = text2path("/obj/HUD/Dominance/[track]")
		var/obj/HUD/Dominance/token = new hudtype(null, player.client, list(anchor_x="EAST", anchor_y="SOUTH", screen_x=-8*TILE_WIDTH, screen_y=(y-1)*(TILE_HEIGHT-1)+1), 1)
		player.contents += token
		token.tag="[track]token"
	s_reassignDominance(var/mob/Player/player, var/track)
		var/obj/HUD/Dominance/d = locate("[track]token")
		d.loc = player
	s_track2y(var/track)
		if(track=="Raven") return 1
		else if(track=="Fiefdoms") return 2
		else if(track=="IronThrone") return 3
		else return -1

