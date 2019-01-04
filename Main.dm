


/*
	These are simple defaults for your project.
 */

world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default
	turf = /turf/WorldTurfs/Sea
	mob = /mob/Player
	view = "24x24"		// show up to 10 tiles outward from center (21x21 view)
	New()
		..()
		drawLobby()
		for(var/area/Territories/a in world)
			a.PopulateNeighbours()

// Make objects move 8 pixels per tick when walking

mob
	step_size = 32

obj
	step_size = 8
client
//	perspective = EDGE_PERSPECTIVE
var
	global
		TURN = 1
		PHASE = "Lobby" 					/* Can equal; "Lobby", "Place Orders" */
		mob/Player/PlayerTurn 				/* Player whose turn it is */
		obj/HUD/Cards/CARD					/* Current Card */
		obj/HUD/Cards/WildlingAttack/WACARD	/* Wildling Card */
		mob/Player/swapper 					// Player who can swap equal bidders
		mob/Player/Lowest 					// Lowest bidder on card
		mob/Player/Highest 					// Highest bidder on card
		WildlingThreat = 0					// Wildling Threat
		datum/Battle/battle					// Battle datum
		VICTORYTYPE = "sevenCastles"
		inProgress = 0 						// 1 if in progress, else 0
		list/LobbyPositions[6]
		list/Players 	= new/list()		// Player name = player mob
		list/PlayerKeys = new/list()		// Player name = player key
		list/Tracks = list("IronThrone" = list("","","","","",""),
			"Fiefdoms" = list("","","","","",""),
			"Raven" = list("","","","","",""))
		//List of Houses
		list/Houses = list("Stark", "Lannister", "Greyjoy", "Baratheon", "Tyrell", "Martell")

		//List of types of Orders
		list/TypesOfOrders = list( \
			/obj/hudOrder/March/MarchMinus1,\
			/obj/hudOrder/March/MarchPlus0,\
			/obj/hudOrder/March/MarchPlus1,\
			/obj/hudOrder/Defend/DefendPlus1A,\
			/obj/hudOrder/Defend/DefendPlus1B,\
			/obj/hudOrder/Defend/DefendPlus2,\
			/obj/hudOrder/Support/SupportA,\
			/obj/hudOrder/Support/SupportB,\
			/obj/hudOrder/Support/SupportPlus1,\
			/obj/hudOrder/Raid/RaidA,\
			/obj/hudOrder/Raid/RaidB,\
			/obj/hudOrder/Raid/RaidPlus,\
			/obj/hudOrder/Consolidate/ConsolidateA,\
			/obj/hudOrder/Consolidate/ConsolidateB,\
			/obj/hudOrder/Consolidate/ConsolidatePlus)
		list/SupplyAllowance = list(\
			list(2,2),\
			list(3,2),\
			list(3,2,2),\
			list(3,2,2,2),\
			list(3,3,2,2),\
			list(4,3,2,2),\
			list(4,3,2,2,2))

		//List of HUD Overlays
		list/obj/battleHUD = new/list()
		list/obj/cardsHUD  = new/list()

		//Restraint flags
		list/Restraints = list("canRaid" = TRUE,\
			"canConsolidate" = TRUE,\
			"canDefend" = TRUE,\
			"canSupport" = TRUE,\
			"canMarch+1" = TRUE)

		list/turfs[world.maxy][world.maxx] //list of all LAND turfs for speeding up stuff

client
	var
		view_width
		view_height
		buffer_x
		buffer_y
		map_zoom = 1
		list/hud = new/list()
	verb
		onResize()
			set hidden = 1
			set waitfor = 0
			var/sz = winget(src,"main","size")
			var/map_width = text2num(sz)
			var/map_height = text2num(copytext(sz,findtext(sz,"x")+1,0))
			view_width = ceil(map_width/TILE_WIDTH)
			if(!(view_width%2)) ++view_width
			view_height = ceil(map_height/TILE_HEIGHT)
			if(!(view_height%2)) ++view_height

			while(view_width*view_height>MAX_VIEW_TILES)
				view_width = ceil(map_width/TILE_WIDTH/++map_zoom)
				if(!(view_width%2)) ++view_width
				view_height = ceil(map_height/TILE_HEIGHT/map_zoom)
				if(!(view_height%2)) ++view_height

			buffer_x = floor((view_width*TILE_WIDTH - map_width/map_zoom)/2)
			buffer_y = floor((view_height*TILE_HEIGHT - map_height/map_zoom)/2)

			src.view = "[view_width]x[view_height]"
			winset(src,"main","zoom=[map_zoom];")

			for(var/obj/HUD/Hud in hud)
				Hud.updatePos()
