turf
	var
		obj/hudoverlay
	WorldTurfs

		Click()
			clicked(usr)
			..()
		proc
			clicked(var/mob/Player/player)
				if(istype(player, /mob/Player/))
					var/area/Territories/clickedArea = src.loc
					var/space = 0
					if(PHASE == "BattleRout" && battle && battle.retreatSelecter == player)
						var/pieceCount = 0

						space = armyCheck(battle.Loser, src, battle.territory)
						for(var/obj/armyPiece/piece in battle.Loser.armyPieces)
							if(piece.loc.loc == battle.territory)
								pieceCount++
						if(space>=pieceCount)
							if(battle.retreatSelecter != battle.Loser) world<<"[battle.retreatSelecter] has selected [battle.Loser]'s army will retreat to [src.loc]."
							else world<<"[battle.Loser] is retreating to [src.loc]."
							var/icon/I
							for(var/obj/armyPiece/piece in battle.Loser.armyPieces)
								if(piece.loc.loc == battle.territory)
									bounce(piece)
									piece.loc = pick(src.loc.contents)
									I = new(src.icon, src.icon_state)
									I.Turn(90)
									I.Blend(rgb(180,180,180),ICON_MULTIPLY,1,1)
									piece.icon = I
									piece.retreating = TRUE
							battle_seizeLand()
						else
							battle.retreatSelecter << "[battle.Loser]'s pieces can't retreat there as there are [pieceCount] pieces and only room there for [space]."
					else if(player.territories.Find(clickedArea) && clickedArea.Castle)	// If it belongs to the clicker
						// If we're in Muster phase, and it's player's turn, and they haven't mustered here
						if(PHASE == "Muster" && PlayerTurn == player && player.castle != clickedArea && clickedArea.mustered!=clickedArea.Castle)
							if(player.castle)
								player.castle.destroyHUDOverlays()				// Remove the mustering overlay
							player.castle = clickedArea
							world<<"[player] will muster in [player.castle] for [player.castle.Castle] points."
							clickedArea.showMusterNeighbours()

		icon = 'turfs.dmi'
		Land
			icon_state = "land"
			New()
				..()
				spawn(2) turfs[src.y][src.x] = src
		Sea
			icon_state = "sea"
		Barrier
			icon_state = "barrier"
			density = 1
			opacity = 1
			Enter()
				return 0
obj
	WorldObjs
		Click()
			..()
			if(istype(usr, /mob/Player/))
				var/mob/Player/player = usr
				var/area/Territories/clickedArea = src.loc.loc
				if(player.territories.Find(clickedArea) && clickedArea.Castle)	// If it belongs to the clicker
					if(PHASE == "Muster" && PlayerTurn == player && player.castle != clickedArea && clickedArea.mustered!=clickedArea.Castle)
						if(player.castle)
							player.castle.destroyHUDOverlays()				// Remove the mustering overlay
						player.castle = clickedArea
						world<<"[player] will muster in [player.castle] for [player.castle.Castle] points."
						clickedArea.showMusterNeighbours()
		River
			icon = 'River.dmi'
			N
				icon_state = "N"
			E
				icon_state = "E"
			S
				icon_state = "S"
			W
				icon_state = "W"
			NE
				icon_state = "NE"
			NW
				icon_state = "NW"
			SE
				icon_state = "SE"
			SW
				icon_state = "SW"
			BridgeNS
				icon_state = "NS"
				pixel_y = -12
				layer = OBJ_LAYER + 1
			BridgeEW
				icon_state = "EW"
				pixel_x = 16
				layer = OBJ_LAYER + 1
		Strategy
			icon = 'turfs.dmi'
			Castle
				icon_state = "Castle"
			Fort
				icon_state = "Fort"
			Supply
				icon_state = "Supply"
			Consolidate
				icon_state = "Consolidate"


proc
	t_GenerateBorders()
		for(var/turf/WorldTurfs/self in world)
			var/border = 0
			for(var/turf/WorldTurfs/neighbours in oview(1,self)) // To save computational effort, discern which turfs have bordering neighbours
				if(neighbours.loc!=self.loc)
					border=1
					break
			if(border)
				var/turf/WorldTurfs/north = locate(self.x,self.y+1,self.z)
				var/turf/WorldTurfs/east = locate(self.x+1,self.y,self.z)
				var/turf/WorldTurfs/south = locate(self.x,self.y-1,self.z)
				var/turf/WorldTurfs/west = locate(self.x-1,self.y,self.z)
				if(north)
					if(north.loc!=self.loc)
						var/obj/o = new/obj()
						o.icon = 'Borders.dmi'
						o.icon_state="N"
						self.overlays+=o
				if(east)
					if(east.loc!=self.loc)
						var/obj/o = new/obj()
						o.icon = 'Borders.dmi'
						o.icon_state="E"
						self.overlays+=o
				if(south)
					if(south.loc!=self.loc)
						var/obj/o = new/obj()
						o.icon = 'Borders.dmi'
						o.icon_state="S"
						self.overlays+=o
				if(west)
					if(west.loc!=self.loc)
						var/obj/o = new/obj()
						o.icon = 'Borders.dmi'
						o.icon_state="W"
						self.overlays+=o

	t_addNames()
		for(var/area/Territories/self in world)
			if(istype(self,/area/Territories/Port))
				continue
			var/turf/WorldTurfs/place
			var/turf/turfForList
			var/turf/righthand
			var/list/potentials = list()
			var/central = 1

			for(turfForList in self)
				if(!turfForList.contents.len) // Ensure the turf is empty
					righthand = locate(turfForList.x+1,turfForList.y,turfForList.z) // Ensure righthand turf is empty too
					if(righthand)
						if(!righthand.contents.len && righthand.loc == self)
							if(!self.isSea)
								if(istype(turfForList,/turf/WorldTurfs/Land)&&istype(righthand,/turf/WorldTurfs/Land))
									potentials+=turfForList
							else
								if(istype(turfForList,/turf/WorldTurfs/Sea)&&istype(righthand,/turf/WorldTurfs/Sea))
									potentials+=turfForList
			do
				central = 1
				var/turf/temp = pick(potentials)
				var/list/NESWturfs = t_getNESWturfs(temp)
				for(var/turf/surrounding in NESWturfs) // Check if chosen square is central to the area
					if(surrounding.loc != self)
						central = 0
						break
				if(central)
					place = temp
			while(!place)
			place.maptext_height = 32
			place.maptext_width = 96
			place.layer = NAME_LAYER
			place.maptext = "<b>[self.name]</b>"

	t_getNESWturfs(var/turf/origin)
		var/list/NESWturfs = list()
		if(origin.y<world.maxy)
			NESWturfs += locate(origin.x,origin.y+1,origin.z)
		if(origin.y>1)
			NESWturfs += locate(origin.x,origin.y-1,origin.z)
		if(origin.x+1<world.maxx)
			NESWturfs += locate(origin.x+1,origin.y,origin.z)
			NESWturfs += locate(origin.x+2,origin.y,origin.z)
		if(origin.x>1)
			NESWturfs += locate(origin.x-1,origin.y,origin.z)
		return NESWturfs


	t_prettify()
		var/turf/WorldTurfs/Land/T
		var/matrix/cmatrix = list(0.5,0.5,0.5, 0.5,0.5,0.5, 0.5,0.5,0.5)
		var/rany = 0, ranx = 0, gran = 0, grey = 0
		var/list/temp = new/list()
		for(var/y = 53, y<=turfs.len, y++)
			temp = turfs[y]
			rany += rand()/50
			ranx = rany
			for(T in temp)
				ranx += (rand()-0.5)/40
				gran = 1-ranx
				grey = (ranx)/1.2
				cmatrix = list(gran,grey,grey, grey,gran,grey, grey,grey,gran)
				T.color = cmatrix
				//var/random = 255-round(rand(1,5)*(T.y-52))
