obj
	orderOverlay
		icon = 'Orders.dmi'
		density = 0
		march
			icon_state="marchOverlay"
		rout
			icon_state="routOverlay"
	hudOrder
		layer = PIECE_LAYER
		icon = 'Orders.dmi'
		var
			mob/Player/Owner 	// Player that owns src
			image/Back
			icon/defaultMousePointer
			Star = 0
			bonus = 0
			area/hasAttacked = null
			area/list/Territories/neighbours = new/list()
		Click()
			clickDel(usr)
			..()
		proc
			clickDel(var/mob/Player/clicker)
				if(PHASE=="BattleHC")
					var/obj/House_Cards/card = battle.houseCards[clicker]
					if(istype(card,/obj/House_Cards/Tyrell/Queen))
						if(!card.used)
							var/mob/Player/enemy
							for(enemy in battle.combatants)
								if(enemy != clicker)
									break
							if(src.Owner == enemy)
								card.used = TRUE
								clicker.client.mouse_pointer_icon = null
								world<<"[clicker] destroyed [enemy]'s [src] in [src.loc.loc]."

								if(battle_HouseCardsCheck()) battle_Blade()
								del src
		March
			MarchPlus1
				name = "March +1"
				icon_state = "March+1"
				screen_loc = "utility:0,1"
				Star = 1
				bonus = 1
			MarchPlus0
				name = "March +0"
				icon_state = "March+0"
				screen_loc = "utility:0,2"
			MarchMinus1
				name = "March -1"
				icon_state = "March-1"
				screen_loc = "utility:0,3"
				bonus = -1
			Click()
				if(PHASE == "March" && PlayerTurn == usr && src.Owner == usr)
					var/mob/Player/player = usr
					if(!player.curOrder)
						player.curOrder = src
						var/area/Territories/ter = src.loc.loc
						ter.fillNeighbours(usr)
						ter.highlightNeighbours(/obj/orderOverlay/march)
						for(var/obj/armyPiece/piece in ter)
							piece.turnStartLoc = piece.loc
				..()

		Defend
			DefendPlus2
				icon_state = "Defend+2"
				screen_loc = "utility:1,1"
				Star = 1
				bonus = 2
			DefendPlus1A
				icon_state = "Defend+1"
				screen_loc = "utility:1,2"
				bonus = 1
			DefendPlus1B
				icon_state = "Defend+1"
				screen_loc = "utility:1,3"
				bonus = 1
		Support

			SupportPlus1
				icon_state = "Support+1"
				screen_loc = "utility:2,1"
				Star = 1
				bonus = 1
			SupportA
				icon_state = "Support+0"
				screen_loc = "utility:2,2"
			SupportB
				icon_state = "Support+0"
				screen_loc = "utility:2,3"
			Click()
				// This order is being raided
				if(PHASE == "Raid" && PlayerTurn == usr)
					var/mob/Player/player = usr
					if(src.Owner != player)
						if(player.curOrder && istype(player.curOrder.type, /obj/hudOrder/Raid))
							var/area/Territories/raidTerritory = player.curOrder.loc.loc
							var/area/Territories/srcTerritory = src.loc.loc
							if(locate(srcTerritory) in raidTerritory.neighbours)
								if(!raidTerritory.isSea && srcTerritory.isSea)
									world<<"Land raids cannot raid sea territories."
									return 0
								if(raidTerritory.isPort && !srcTerritory.isSea)
									world<<"Port raids cannot raid sea territories."
									return 0
								else
									world<<"[player] raided [src.Owner]'s [src] in [src.loc.loc]"
									if(!player.curOrder.Star)
										del player.curOrder
									else
										player.curOrder.Star = 0
									del src
				..()
		Raid
			RaidPlus
				icon_state = "Raid+1"
				screen_loc = "utility:3,1"
				Star = 1
			RaidA
				icon_state = "Raid"
				screen_loc = "utility:3,2"
			RaidB
				icon_state = "Raid"
				screen_loc = "utility:3,3"
			Click()
				// This order is either being selected, or raided.
				if(PHASE == "Raid" && PlayerTurn == usr)
					var/mob/Player/player = usr
					if(src.Owner == player)
						player.curOrder = src
					else
						if(player.curOrder && istype(player.curOrder.type, /obj/hudOrder/Raid) )
							var/area/Territories/raidTerritory = player.curOrder.loc.loc
							var/area/Territories/srcTerritory = src.loc.loc
							if(locate(srcTerritory) in raidTerritory.neighbours)
								if(!raidTerritory.isSea && srcTerritory.isSea)
									world<<"Land raids cannot raid sea territories."
									return 0
								if(raidTerritory.isPort && !srcTerritory.isSea)
									world<<"Port raids cannot raid sea territories."
									return 0
								else
									world<<"[player] raided [src.Owner]'s [src] in [src.loc.loc]"
									if(!player.curOrder.Star)
										del player.curOrder
									else
										player.curOrder.Star = 0
									del src
				..()

		Consolidate
			ConsolidatePlus
				icon_state = "Consolidate+1"
				screen_loc = "utility:4,1"
				Star = 1
			ConsolidateA
				icon_state = "Consolidate"
				screen_loc = "utility:4,2"
			ConsolidateB
				icon_state = "Consolidate"
				screen_loc = "utility:4,3"
			Click()
				// This order is being raided
				if(PHASE == "Raid" && PlayerTurn == usr)
					var/mob/Player/player = usr
					if(src.Owner != player)
						if(player.curOrder && istype(player.curOrder.type, /obj/hudOrder/Raid))
							var/area/Territories/raidTerritory = player.curOrder.loc.loc
							var/area/Territories/srcTerritory = src.loc.loc
							if(locate(srcTerritory) in raidTerritory.neighbours)
								if(!raidTerritory.isSea && srcTerritory.isSea)
									world<<"Land raids cannot raid sea territories."
									return 0
								if(raidTerritory.isPort && !srcTerritory.isSea)
									world<<"Port raids cannot raid sea territories."
									return 0
								else
									world<<"[player] raided [src.Owner]'s [src] in [src.loc.loc]"
									player.Influence += 2
									src.Owner.Influence -= 1
									h_influenceChange()
									if(!player.curOrder.Star)
										del player.curOrder
									else
										player.curOrder.Star = 0
									del src
				..()

		New(owner)
			..()
			defaultMousePointer = icon(src.icon, src.icon_state)
			src.Owner = owner
			var/icon/mousePointer = new(src.icon,src.icon_state)
			mouse_drag_pointer=mousePointer
			//Show the house order icon to other players
			if(src.Owner.House=="Stark")
				src.Back = image('Stark.dmi',src,"Order")
			if(src.Owner.House=="Baratheon")
				src.Back = image('Baratheon.dmi',src,"Order")
			if(src.Owner.House=="Greyjoy")
				src.Back = image('Greyjoy.dmi',src,"Order")
			if(src.Owner.House=="Martell")
				src.Back = image('Martell.dmi',src,"Order")
			if(src.Owner.House=="Tyrell")
				src.Back = image('Tyrell.dmi',src,"Order")
			if(src.Owner.House=="Lannister")
				src.Back = image('Lannister.dmi',src,"Order")
			for(var/players in Players)
				var/mob/Player/player = Players[players]
				if(player)
					if(player!=src.Owner)
						player<< src.Back

		MouseDrop(var/over_object,var/src_location,var/atom/over_location,var/src_control,var/over_control,var/params)
			if(over_control=="default.main" && PHASE == "Place Orders")

				if(!over_location)
					return 0
				if(istype(src,/obj/hudOrder/Raid) && !Restraints["canRaid"])
					return 0
				if(istype(src,/obj/hudOrder/Defend) && !Restraints["canDefend"])
					return 0
				if(istype(src,/obj/hudOrder/Consolidate) && !Restraints["canConsolidate"])
					return 0

				var/usedStars = 0
				var/obj/armyPiece/armyPiece = locate(/obj/armyPiece) in over_location.loc
				if(armyPiece)
					//IF the location contains your pieces
					if(armyPiece.Owner == usr)
						var/mob/Player/player = usr
						//Delete all OTHER hudOrders in this Territory
						for(var/obj/hudOrder/tempPiece in over_location.loc)
							if(tempPiece != src)
								del tempPiece
						for(var/obj/hudOrder/h in player.hudOrders)
							if(h.z == 1)
								//Delete all IDENTICAL hudOrders in the world
								if(h.type == src.type && h.Owner == src.Owner && h != src)
									player.hudOrders -= h
									del h
								else if(h.Star && h != src)
									// Count up stars used so far
									usedStars+=h.Star
						if(src.Star)
							var/starAllowance = 0
							var/list/raven = Tracks["Raven"]
							var/pos = raven.Find(usr)
							if(pos == 1 || pos == 2)
								starAllowance = 3
							else if (pos == 3)
								starAllowance = 2
							else if (pos == 4)
								starAllowance = 1
							if(usedStars>=starAllowance)
								usr<<"Sorry, you have already used [usedStars] Stars, and can only use [starAllowance]. Remove a Star Order before placing another."
								return 0
						if(isturf(src_location))
							src.loc = over_location
						else
							var/newOrder = new src.type(over_location, owner=src.Owner)
							player.hudOrders+= newOrder

		MouseDown(location,control,params)
			var/obj/hudOrder/orderpiece = src
			orderpiece.mouse_drag_pointer = 0
			if(PHASE == "Place Orders")
				if(istype(src,/obj/hudOrder/Raid) && !Restraints["canRaid"])
					usr << "Raids cannot be played this turn."
					orderpiece.mouse_drag_pointer = 0
					return 0
				if(istype(src,/obj/hudOrder/Defend) && !Restraints["canDefend"])
					usr << "Defends cannot be played this turn."
					orderpiece.mouse_drag_pointer = 0
					return 0
				if(istype(src,/obj/hudOrder/Consolidate) && !Restraints["canConsolidate"])
					usr << "Consolidates cannot be played this turn."
					orderpiece.mouse_drag_pointer = 0
					return 0


				else if(orderpiece.Owner == usr)
					orderpiece.mouse_drag_pointer = defaultMousePointer
				else
					orderpiece.mouse_drag_pointer = orderpiece.Back
			else
				orderpiece.mouse_drag_pointer = 0

