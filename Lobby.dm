turf
	Lobby
		icon = 'Lobby.dmi'
		background
			icon_state = "background"
		topLeft
			icon_state = "topLeft"
		topRight
			icon_state = "topRight"
		bottomLeft
			icon_state = "bottomLeft"
		bottomRight
			icon_state = "bottomRight"
		top
			icon_state = "top"
		bottom
			icon_state = "bottom"

obj
	HUD
		Start
			icon = 'LobbyStart.dmi'
			icon_state = "Start"
			Click()
			//	t_prettify()
				var/mob/Player/player

	//			if(Players.len<=2)
	//				world<<"This game requires at least three players."
	//				return
				if(Players.len<6)
					var/list/playersWithWrongHouses = new/list()
					for(var/players in Players)
						player = Players[players]
						if(!(playeroption.Find(player.House,1,Players.len+1) || player.House == "Random" || player.House == "" ))
							playersWithWrongHouses +=player
					if(playersWithWrongHouses.len)

						var/string = "If you are playing with only [Players.len] players the only eligible houses are "
						for(var/i = 1, (i<=Players.len && i<=playeroption.len), i++)
							if(i!=1)
								string+=", "
							else if(i==playeroption.len)
								string+=" and "
							string+="[playeroption[i]]"
						world<<string + "."

						string = ""
						for(var/i = 1, i<=playersWithWrongHouses.len, i++)
							if(i!=1)
								string+=" and "
							string+="[playersWithWrongHouses[i]]"
						string+=" must reselect their house."
						world<<string
						return

				// If anyone has failed to pick a House, pick for them
				var/list/tempHouses = playeroption.Copy(1, Players.len+1)
				for(var/players in Players)
					player = Players[players]
					if(player)
						tempHouses.Remove(player.House)
				for(var/players in Players)
					player = Players[players]
					if(player.client)
						for(var/obj/HUD/hud in player.client.hud)
							if(!istype(hud,/obj/HUD/Start))
								del hud
					if(player.House == "Random" || player.House == "")
						player.House = pick(tempHouses)
						tempHouses.Remove(player.House)
				for(var/obj/HUD/Start/s in usr.client.hud)
					usr.client.screen-=s
					usr.client.hud-=s

				spawn() gameStart()

				for(var/obj/Lobby/House/h)
					if(h.attachedImages.len>=1)
						for(var/I in h.attachedImages)
							h.attachedImages.Remove(I)
							del I
				for(var/obj/HUD/Start/s in usr.client.screen)
					del s
	Lobby
		icon = 'Lobby.dmi'
		var
			Position

		// Player positions
		Host
			icon_state = "host"
		Join
			icon_state = "Join"
	//		pixel_y = 18
			Click()
				if(LobbyPositions[1] != usr)
					// If the position is already taken, report that.
					if(LobbyPositions[Position])
						usr<<"Position is already occupied by [LobbyPositions[Position]]"
						return
					// If not, take the player out of their current slot
					for(var/p in LobbyPositions)
						if(p == usr)
							LobbyPositions.Remove(p)
					// And add them to the chosen spot
					LobbyPositions[Position] = usr
					LobbyNames()
				else
					d_addAI()

		Leave
			icon_state = "Leave"
		//	pixel_y = 18
			Click()
				if(LobbyPositions[src.Position] == usr)
					LobbyPositions[src.Position]=null
					PlayerKeys.Remove(usr.name)
					Players.Remove(usr.name)
					for(var/p in Players)
						world<<"b [p] = [Players[p]]"
					LobbyNames()
		ChangeName
			icon_state = "changeName"
			pixel_y = 18
			Click()
				if(LobbyPositions[src.Position] == usr)
					PlayerKeys.Remove(usr.name)
					Players.Remove(usr.name)
					usr.name = input("Choose your name.","Your Name",usr.name)
					PlayerKeys[usr.name] = usr.key
					Players[usr.name] = usr
					LobbyNames()
		House
			icon = 'Houses.dmi'
			icon_state = "House"
			pixel_y = 18
			var
				House
				list/attachedImages = new/list()
			Click()
			//	if(Players[src.Position] == usr || (PlayerKeys[src.Position] == "AIKEY" && Players["Player Host"] == usr))
				if(src.attachedImages.len>=1)
					for(var/I in src.attachedImages)
						src.attachedImages.Remove(I)
						del I
				else
					var/overlayHeight = 18
					var/houses = availableHouses()
					var/hud_x = (src.x - usr.x + 2.5)*TILE_WIDTH
					var/hud_y = (src.y - usr.y + 2.5)*TILE_WIDTH
					for(var/house in houses)
						var/obj/HUD/Houses/houseHUD = new /obj/HUD/Houses(null, usr.client, list(icon_state=house,anchor_x="CENTER", anchor_y="CENTER", screen_x=hud_x, screen_y=hud_y+overlayHeight), 1)
						overlayHeight -= 29
						houseHUD.masterPosition = src
						houseHUD.House = house
						houseHUD.Position = src.Position

						src.attachedImages += houseHUD
	HUD
		Houses
			icon = 'Houses.dmi'
			var
				House
				obj/Lobby/House/masterPosition
				startPosition[3]		// Where the player eye starts the game
				Position
			Click()
				var/houseTaken = FALSE
				var/mob/Player/player
				for(var/p in Players) // Ensure House hasn't been taken yet
					player = Players[p]
					if(player.House==src.House)
						houseTaken = TRUE
						break

				if(!houseTaken)
					player=LobbyPositions[Position]
					player.House = src.House
					masterPosition.House = src.House
					masterPosition.icon_state = src.icon_state
					for(var/obj/HUD/I in masterPosition.attachedImages)
						masterPosition.attachedImages.Remove(I)
						I.hide()

					for(var/p in Players) // Ensure House hasn't been taken yet
						player = Players[p]
						if(player.client)
							for(var/obj/HUD/Houses/h in player.client.hud)
								h.hide()
					del src

proc
	LobbyNames()
		var/obj/HUD/hud
		for(var/p in Players)
			var/mob/Player/player = Players[p]
			if(player.client)
				for(hud in player.client.hud)
					if(!istype(hud,/obj/HUD/Start))
						del hud
				for(var/i = 1, i<=LobbyPositions.len, i++)
					var/mob/name = LobbyPositions[i]
					if(name)
						var/y = 10.5 - (3 * i)//Height of name
						hud = new(null, player.client, list(anchor_x="CENTER", anchor_y="CENTER", screen_x=-180, screen_y=32*y, layer=HUD_LAYER+1),1)
						hud.pixel_y = 24
						hud.maptext_width = 128
						hud.maptext_height = 64
						hud.maptext = "<b>[name.name]</b>"

	availableHouses()
		var/houseTaken = FALSE
		var/mob/Player/player
		var/list/avHouses = new()
		var/house
		var/list/tempHouses = playeroption.Copy(1,max(Players.len,3)+1)
		for(house in tempHouses) // Ensure House hasn't been taken yet
			houseTaken = FALSE
			for(var/p in Players)
				player = Players[p]
				if(player.House==house)
					houseTaken = TRUE
					break
			if(!houseTaken)
				avHouses += house
		if(avHouses.len)
			return avHouses
		return 0

	getHouseLoc(var/mob/Player/player)
		if(player.House == "Stark") 	return locate(29,72,1)
		if(player.House == "Lannister")	return locate(16,36,1)
		if(player.House == "Greyjoy")	return locate(15,52,1)
		if(player.House == "Baratheon")	return locate(57,43,1)
		if(player.House == "Tyrell")	return locate(18,18,1)
		if(player.House == "Martell")	return locate(54,13,1)

	drawLobby()
		for(var/i = 1, i<=6, i++)
			var/obj/Lobby/Join/j = new(locate(34,48-(3*i),2))
			j.Position = i
			var/obj/Lobby/House/h = new(locate(37,47-(3*i),2))
			h.Position = i
			var/obj/Lobby/ChangeName/c = new(locate(26,47-(3*i),2))
			c.Position = i
			if(i==1) continue
			var/obj/Lobby/Leave/l = new(locate(34,47-(3*i),2))
			l.Position = i

var/global/list/LobbyPos = list(1 = 7.5, "Player Two" = 4.5, "Player Three" = 1.5, "Player Four" = -1.5, "Player Five" = -4.5, "Player Six" = -7.5)
var/list/playeroption = list("Stark","Baratheon","Lannister","Greyjoy","Tyrell","Sunspear")