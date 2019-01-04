obj
	playPiece
		Army
			var
				Strength	// Strength
				Type		// Land or Sea
				mob/Owner 	// Player that owns src
			Infantry
				icon_state = "Infantry"
				Strength = 1
			Cavalry
				icon_state = "Cavalry"
				Strength = 2
			Ship
				icon_state = "Ship"
				Strength = 2

	hudOrder
		icon = 'Orders.dmi'
		var
			House 	// Player that owns src
			image/Back
			icon/defaultMousePointer
		MarchPlus1
			icon_state = "March+1"
			screen_loc = "utility:0,1"
		MarchPlus0
			icon_state = "March+0"
			screen_loc = "utility:0,2"
		MarchMinus1
			icon_state = "March-1"
			screen_loc = "utility:0,3"
		DefendPlus2
			icon_state = "Defend+2"
			screen_loc = "utility:1,1"
		DefendPlus1A
			icon_state = "Defend+1"
			screen_loc = "utility:1,2"
		DefendPlus1B
			icon_state = "Defend+1"
			screen_loc = "utility:1,3"
		SupportPlus1
			icon_state = "Support+1"
			screen_loc = "utility:2,1"
		SupportA
			icon_state = "Support+0"
			screen_loc = "utility:2,2"
		SupportB
			icon_state = "Support+0"
			screen_loc = "utility:2,3"
		RaidPlus
			icon_state = "Raid+1"
			screen_loc = "utility:3,1"
		RaidA
			icon_state = "Raid"
			screen_loc = "utility:3,2"
		RaidB
			icon_state = "Raid"
			screen_loc = "utility:3,3"
		ConsolidatePlus
			icon_state = "Consolidate+1"
			screen_loc = "utility:4,1"
		ConsolidateA
			icon_state = "Consolidate"
			screen_loc = "utility:4,2"
		ConsolidateB
			icon_state = "Consolidate"
			screen_loc = "utility:4,3"
		New(house)
			..()
			defaultMousePointer = icon(src.icon, src.icon_state)
			src.House = house
			var/icon/mousePointer = new(src.icon,src.icon_state)
			mouse_drag_pointer=mousePointer
			//Show the house order icon to other players
			if(src.House=="Stark")
				src.Back = image('Stark.dmi',src,"Order")
			if(src.House=="Baratheon")
				src.Back = image('Baratheon.dmi',src,"Order")
			if(src.House=="Greyjoy")
				src.Back = image('Greyjoy.dmi',src,"Order")
			if(src.House=="Martell")
				src.Back = image('Martell.dmi',src,"Order")
			if(src.House=="Tyrell")
				src.Back = image('Tyrell.dmi',src,"Order")
			if(src.House=="Lannister")
				src.Back = image('Lannister.dmi',src,"Order")
			for(var/players in Players)
				var/mob/Player/player = Players[players]
				if(player)
					if(player.House!=src.House)
						player<< src.Back

		MouseDrop(var/over_object,var/src_location,var/atom/over_location,var/src_control,var/over_control,var/params)
			if(over_control=="default.main")

				var/obj/playPiece/Army/armyPiece = locate(/obj/playPiece/Army) in over_location.loc
				if(armyPiece)
					if(armyPiece.Owner == usr)
						//Delete all OTHER hudOrders in this Territory
						var/obj/hudOrder/h = new src.type(over_location, house=src.House)//IF the location contains your pieces
						for(var/turf/WorldTurfs/tempTurf in over_location.loc)
							for(var/obj/hudOrder/tempPiece in tempTurf)
								if(tempPiece!=h)
									del tempPiece

			if(over_control=="default.utility")
				del src
		MouseDown(location,control,params)
			var/obj/hudOrder/orderpiece = src
			var/mob/Player/clicker=usr
			if(orderpiece.House!=clicker.House)
				orderpiece.mouse_drag_pointer = orderpiece.Back
			else
				orderpiece.mouse_drag_pointer = defaultMousePointer

