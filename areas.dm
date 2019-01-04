obj
	terOverlay
		Muster
			icon = 'Territories.dmi'
			icon_state="musterOverlay"
			density = 0

area
	Territories
		icon = 'Territories.dmi'
		var
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   	   // path of Port
			obj/Order/order // ref. to order placed here
			list/neighbours = new/list() // list of neighbouring territories
			list/highlight = new/list()
			isSea = 0 // 1 if sea, else 0
			isPort = 0 // 1 if port, else 0
			mustered = 0 // Used for Muster card
			disabled = 0 // 1 means disabled
		proc
			PopulateNeighbours()

			showMusterNeighbours()
				var/obj/terOverlay/Muster/m = new()
				for(var/turf/t in src)
					t.overlays+=m
					t.hudoverlay = m
				for(var/area/Territories/a in src.neighbours)
					if(a.isSea)
						for(var/turf/t in a)
							t.overlays+=m
							t.hudoverlay = m

			destroyHUDOverlays()
				for(var/area/Territories/a in src.highlight)
					for(var/turf/t in a)
						t.overlays-=t.hudoverlay
						t.hudoverlay=null

			fillNeighbours(var/mob/Player/owner, var/mob/Player/enemy)
				// Add all neighbouring territories to neighbours
				var/area/list/Territories/possible = new/list()
				if(!enemy) possible += src				// If there is an enemy then we are routing and must leave the current territory, aka src
				for(var/area/Territories/neighbour in src.neighbours)
					possible += getMarchLocsRecursively(neighbour, owner, possible, enemy)
				for(var/area/Territories/a in possible)
					if(a.isSea != src.isSea) // Check that they're both either Sea or Not Sea
						possible -= a
					if(a.isPort)
						possible -= a
				src.highlight = possible.Copy()

			/* Get Neighbours Recursively */
			getMarchLocsRecursively(var/area/Territories/ter, var/mob/Player/player, var/area/list/Territories/possible, var/mob/Player/enemy)
				if(enemy && enemy.territories.Find(ter))
					return null
				var/obj/armyPiece/piece = locate(/obj/armyPiece/Ship) in ter
				var/list/temp = new/list()
				temp += ter
				if(piece && piece.Owner == player)
					possible += ter
					for(var/area/Territories/territory in ter.neighbours)
						// If that neighbour isn't already in the main list, AND is owned by the player
						if(!possible.Find(territory))
							temp += getMarchLocsRecursively(territory, player, possible)
				if(temp.len)
					return temp
				else
					return null

			highlightNeighbours(var/overlayType)
				overlayType = text2path("[overlayType]")
				var/obj/orderOverlay/m = new overlayType()
				m.layer = OVERLAY_LAYER
				for(var/area/Territories/a in src.highlight)
					for(var/turf/t in a)
						t.overlays+=m
						t.hudoverlay = m


		Sunspear
			name = "Sunspear"
			icon_state = "Sunspear"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = /area/Territories/Port/Sunspear // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SaltShore)
				neighbours += locate(/area/Territories/Yronwood)
				neighbours += locate(/area/Territories/SeaOfDorne)
				neighbours += locate(/area/Territories/EastSummerSea)
				neighbours += locate(src.Port)
		SaltShore
			name = "Salt Shore"
			icon_state = "SaltShore"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Sunspear)
				neighbours += locate(/area/Territories/Starfall)
				neighbours += locate(/area/Territories/Yronwood)
				neighbours += locate(/area/Territories/EastSummerSea)
		Starfall
			name = "Starfall"
			icon_state = "Starfall"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SaltShore)
				neighbours += locate(/area/Territories/Yronwood)
				neighbours += locate(/area/Territories/PrincesPass)
				neighbours += locate(/area/Territories/WestSummerSea)
				neighbours += locate(/area/Territories/EastSummerSea)
		Yronwood
			name = "Yronwood"
			icon_state = "Yronwood"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SaltShore)
				neighbours += locate(/area/Territories/Sunspear)
				neighbours += locate(/area/Territories/Starfall)
				neighbours += locate(/area/Territories/SeaOfDorne)
				neighbours += locate(/area/Territories/PrincesPass)
				neighbours += locate(/area/Territories/TheBoneway)
		TheBoneway
			name = "The Boneway"
			icon_state = "TheBoneway"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Yronwood)
				neighbours += locate(/area/Territories/PrincesPass)
				neighbours += locate(/area/Territories/Starfall)
				neighbours += locate(/area/Territories/SeaOfDorne)
				neighbours += locate(/area/Territories/DornishMarches)
		StormsEnd
			name = "Storms End"
			icon_state = "StormsEnd"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = /area/Territories/Port/StormsEnd // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Kingswood)
				neighbours += locate(/area/Territories/TheBoneway)
				neighbours += locate(/area/Territories/SeaOfDorne)
				neighbours += locate(/area/Territories/ShipbreakerBay)
				neighbours += locate(src.Port)
		PrincesPass
			name = "Prince's Pass"
			icon_state = "PrincesPass"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheBoneway)
				neighbours += locate(/area/Territories/Yronwood)
				neighbours += locate(/area/Territories/Starfall)
				neighbours += locate(/area/Territories/DornishMarches)
		DornishMarches
			name = "Dornish Marches"
			icon_state = "DornishMarches"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheBoneway)
				neighbours += locate(/area/Territories/PrincesPass)
				neighbours += locate(/area/Territories/ThreeTowers)
				neighbours += locate(/area/Territories/Oldtown)
				neighbours += locate(/area/Territories/Highgarden)
				neighbours += locate(/area/Territories/TheReach)
		ThreeTowers
			name = "Three Towers"
			icon_state = "ThreeTowers"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/DornishMarches)
				neighbours += locate(/area/Territories/RedwyneStraits)
				neighbours += locate(/area/Territories/Oldtown)
		TheArbor
			name = "The Arbor"
			icon_state = "TheArbor"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/RedwyneStraits)
				neighbours += locate(/area/Territories/WestSummerSea)
		Oldtown
			name = "Oldtown"
			icon_state = "Oldtown"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = /area/Territories/Port/Oldtown // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Highgarden)
				neighbours += locate(/area/Territories/DornishMarches)
				neighbours += locate(/area/Territories/ThreeTowers)
				neighbours += locate(/area/Territories/RedwyneStraits)
		Highgarden
			name = "Highgarden"
			icon_state = "Highgarden"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 2 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheReach)
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/DornishMarches)
				neighbours += locate(/area/Territories/Oldtown)
				neighbours += locate(/area/Territories/RedwyneStraits)
				neighbours += locate(/area/Territories/WestSummerSea)
		TheReach
			name = "The Reach"
			icon_state = "TheReach"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Highgarden)
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/DornishMarches)
				neighbours += locate(/area/Territories/Kingswood)
				neighbours += locate(/area/Territories/Blackwater)
				neighbours += locate(/area/Territories/KingsLanding)
				neighbours += locate(/area/Territories/TheBoneway)
				neighbours += locate(/area/Territories/SeaOfDorne)
				neighbours += locate(/area/Territories/EastSummerSea)
		Kingswood
			name = "Kingswood"
			icon_state = "Kingswood"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheBoneway)
				neighbours += locate(/area/Territories/TheReach)
				neighbours += locate(/area/Territories/KingsLanding)
				neighbours += locate(/area/Territories/StormsEnd)
				neighbours += locate(/area/Territories/BlackwaterBay)
				neighbours += locate(/area/Territories/ShipbreakerBay)
		KingsLanding
			name = "King's Landing"
			icon_state = "KingsLanding"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 2 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Kingswood)
				neighbours += locate(/area/Territories/CrackclawPoint)
				neighbours += locate(/area/Territories/Blackwater)
				neighbours += locate(/area/Territories/TheReach)
				neighbours += locate(/area/Territories/BlackwaterBay)
		Blackwater
			name = "Blackwater"
			icon_state = "Blackwater"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 2 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/KingsLanding)
				neighbours += locate(/area/Territories/Kingswood)
				neighbours += locate(/area/Territories/TheReach)
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/StoneySept)
				neighbours += locate(/area/Territories/Harrenhal)
				neighbours += locate(/area/Territories/CrackclawPoint)
		SearoadMarches
			name = "Searoad Marches"
			icon_state = "SearoadMarches"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Blackwater)
				neighbours += locate(/area/Territories/Highgarden)
				neighbours += locate(/area/Territories/Lannisport)
				neighbours += locate(/area/Territories/StoneySept)
				neighbours += locate(/area/Territories/TheReach)
				neighbours += locate(/area/Territories/SunsetSea)
				neighbours += locate(/area/Territories/TheGoldenSound)
		Lannisport
			name = "Lannisport"
			icon_state = "Lannisport"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 2 // Number of Supply Barrels
			Port   = /area/Territories/Port/Lannisport // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/StoneySept)
				neighbours += locate(/area/Territories/Riverrun)
				neighbours += locate(/area/Territories/TheGoldenSound)
				neighbours += locate(src.Port)
		StoneySept
			name = "Stoney Sept"
			icon_state = "StoneySept"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Lannisport)
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/Blackwater)
				neighbours += locate(/area/Territories/Harrenhal)
				neighbours += locate(/area/Territories/Riverrun)
		Harrenhal
			name = "Harrenhal"
			icon_state = "Harrenhal"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Riverrun)
				neighbours += locate(/area/Territories/CrackclawPoint)
				neighbours += locate(/area/Territories/BlackwaterBay)
				neighbours += locate(/area/Territories/StoneySept)
		CrackclawPoint
			name = "Crackclaw Point"
			icon_state = "CrackclawPoint"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/KingsLanding)
				neighbours += locate(/area/Territories/Harrenhal)
				neighbours += locate(/area/Territories/TheMountainsOfTheMoon)
				neighbours += locate(/area/Territories/BlackwaterBay)
				neighbours += locate(/area/Territories/ShipbreakerBay)
		Dragonstone
			name = "Dragonstone"
			icon_state = "Dragonstone"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = /area/Territories/Port/Dragonstone // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/ShipbreakerBay)
				neighbours += locate(src.Port)
		Riverrun
			name = "Riverrun"
			icon_state = "Riverrun"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Harrenhal)
				neighbours += locate(/area/Territories/Lannisport)
				neighbours += locate(/area/Territories/Seagard)
				neighbours += locate(/area/Territories/StoneySept)
				neighbours += locate(/area/Territories/TheGoldenSound)
				neighbours += locate(/area/Territories/IronmansBay)
		TheEyrie
			name = "The Eyrie"
			icon_state = "TheEyrie"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheMountainsOfTheMoon)
				neighbours += locate(/area/Territories/TheNarrowSea)
		TheMountainsOfTheMoon
			name = "The Mountains Of The Moon"
			icon_state = "TheMountainsOfTheMoon"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheEyrie)
				neighbours += locate(/area/Territories/CrackclawPoint)
				neighbours += locate(/area/Territories/TheFingers)
				neighbours += locate(/area/Territories/TheTwins)
				neighbours += locate(/area/Territories/TheNarrowSea)
		TheFingers
			name = "The Fingers"
			icon_state = "TheFingers"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheMountainsOfTheMoon)
				neighbours += locate(/area/Territories/TheTwins)
				neighbours += locate(/area/Territories/TheNarrowSea)
		TheTwins
			name = "The Twins"
			icon_state = "TheTwins"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheFingers)
				neighbours += locate(/area/Territories/TheMountainsOfTheMoon)
				neighbours += locate(/area/Territories/MoatCailin)
				neighbours += locate(/area/Territories/Seagard)
				neighbours += locate(/area/Territories/TheNarrowSea)
		Seagard
			name = "Seagard"
			icon_state = "Seagard"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/GreywaterWatch)
				neighbours += locate(/area/Territories/TheTwins)
				neighbours += locate(/area/Territories/MoatCailin)
				neighbours += locate(/area/Territories/Riverrun)
				neighbours += locate(/area/Territories/IronmansBay)
		Pyke
			name = "Pyke"
			icon_state = "Pyke"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = /area/Territories/Port/Pyke // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/IronmansBay)
				neighbours += locate(src.Port)
		MoatCailin
			name = "Moat Cailin"
			icon_state = "MoatCailin"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/GreywaterWatch)
				neighbours += locate(/area/Territories/TheTwins)
				neighbours += locate(/area/Territories/WhiteHarbour)
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/TheNarrowSea)
		GreywaterWatch
			name = "Greywater Watch"
			icon_state = "GreywaterWatch"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/MoatCailin)
				neighbours += locate(/area/Territories/FlintsFinger)
				neighbours += locate(/area/Territories/Seagard)
				neighbours += locate(/area/Territories/BayOfIce)
				neighbours += locate(/area/Territories/IronmansBay)
		FlintsFinger
			name = "Flint's Finger"
			icon_state = "FlintsFinger"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/GreywaterWatch)
				neighbours += locate(/area/Territories/BayOfIce)
				neighbours += locate(/area/Territories/IronmansBay)
				neighbours += locate(/area/Territories/SunsetSea)
		TheStoneyShore
			name = "The Stoney Shore"
			icon_state = "TheStoneyShore"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/BayOfIce)
		WhiteHarbour
			name = "White Harbour"
			icon_state = "WhiteHarbour"
			Castle = 1 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = /area/Territories/Port/WhiteHarbour // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/WidowsWatch)
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/MoatCailin)
				neighbours += locate(/area/Territories/TheNarrowSea)
				neighbours += locate(/area/Territories/TheShiveringSea)
		WidowsWatch
			name = "Widow's Watch"
			icon_state = "WidowsWatch"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/WhiteHarbour)
				neighbours += locate(/area/Territories/TheNarrowSea)
				neighbours += locate(/area/Territories/TheShiveringSea)
		Winterfell
			name = "Winterfell"
			icon_state = "Winterfell"
			Castle = 2 // 1 for small castle, 2 for large
			Power  = 1 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = /area/Territories/Port/Winterfell // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/WhiteHarbour)
				neighbours += locate(/area/Territories/MoatCailin)
				neighbours += locate(/area/Territories/TheStoneyShore)
				neighbours += locate(/area/Territories/CastleBlack)
				neighbours += locate(/area/Territories/Karhold)
				neighbours += locate(/area/Territories/TheShiveringSea)
				neighbours += locate(/area/Territories/BayOfIce)
				neighbours += locate(src.Port)
		Karhold
			name = "Karhold"
			icon_state = "Karhold"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/CastleBlack)
				neighbours += locate(/area/Territories/TheShiveringSea)
				neighbours += locate(/area/Territories/BayOfIce)
		CastleBlack
			name = "Castle Black"
			icon_state = "CastleBlack"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 1 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Karhold)
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/TheShiveringSea)
				neighbours += locate(/area/Territories/BayOfIce)
		TheShiveringSea
			name = "The Shivering Sea"
			icon_state = "TheShiveringSea"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Karhold)
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/CastleBlack)
				neighbours += locate(/area/Territories/WhiteHarbour)
				neighbours += locate(/area/Territories/WidowsWatch)
				neighbours += locate(/area/Territories/TheNarrowSea)
		TheNarrowSea
			name = "The Narrow Sea"
			icon_state = "TheNarrowSea"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/WidowsWatch)
				neighbours += locate(/area/Territories/WhiteHarbour)
				neighbours += locate(/area/Territories/MoatCailin)
				neighbours += locate(/area/Territories/TheTwins)
				neighbours += locate(/area/Territories/TheFingers)
				neighbours += locate(/area/Territories/TheMountainsOfTheMoon)
				neighbours += locate(/area/Territories/TheEyrie)
				neighbours += locate(/area/Territories/CrackclawPoint)
				neighbours += locate(/area/Territories/TheShiveringSea)
				neighbours += locate(/area/Territories/ShipbreakerBay)
		ShipbreakerBay
			name = "Shipbreaker Bay"
			icon_state = "ShipbreakerBay"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/CrackclawPoint)
				neighbours += locate(/area/Territories/Dragonstone)
				neighbours += locate(/area/Territories/Kingswood)
				neighbours += locate(/area/Territories/StormsEnd)
				neighbours += locate(/area/Territories/BlackwaterBay)
				neighbours += locate(/area/Territories/TheNarrowSea)
		BlackwaterBay
			name = "Blackwater Bay"
			icon_state = "BlackwaterBay"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/KingsLanding)
				neighbours += locate(/area/Territories/Kingswood)
				neighbours += locate(/area/Territories/CrackclawPoint)
				neighbours += locate(/area/Territories/ShipbreakerBay)
		EastSummerSea
			name = "East Summer Sea"
			icon_state = "EastSummerSea"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SaltShore)
				neighbours += locate(/area/Territories/Sunspear)
				neighbours += locate(/area/Territories/Starfall)
				neighbours += locate(/area/Territories/SeaOfDorne)
				neighbours += locate(/area/Territories/ShipbreakerBay)
				neighbours += locate(/area/Territories/WestSummerSea)
		SeaOfDorne
			name = "Sea Of Dorne"
			icon_state = "SeaOfDorne"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/StormsEnd)
				neighbours += locate(/area/Territories/Sunspear)
				neighbours += locate(/area/Territories/Yronwood)
				neighbours += locate(/area/Territories/TheBoneway)
				neighbours += locate(/area/Territories/ShipbreakerBay)
				neighbours += locate(/area/Territories/EastSummerSea)
		WestSummerSea
			name = "West Summer Sea"
			icon_state = "WestSummerSea"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Starfall)
				neighbours += locate(/area/Territories/ThreeTowers)
				neighbours += locate(/area/Territories/Highgarden)
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/SunsetSea)
				neighbours += locate(/area/Territories/RedwyneStraits)
				neighbours += locate(/area/Territories/EastSummerSea)
				neighbours += locate(/area/Territories/TheArbor)
		RedwyneStraits
			name = "Redwyne Straits"
			icon_state = "RedwyneStraits"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Highgarden)
				neighbours += locate(/area/Territories/Oldtown)
				neighbours += locate(/area/Territories/ThreeTowers)
				neighbours += locate(/area/Territories/WestSummerSea)
				neighbours += locate(/area/Territories/TheArbor)
		SunsetSea
			name = "Sunset Sea"
			icon_state = "SunsetSea"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/FlintsFinger)
				neighbours += locate(/area/Territories/WestSummerSea)
				neighbours += locate(/area/Territories/IronmansBay)
				neighbours += locate(/area/Territories/TheGoldenSound)
				neighbours += locate(/area/Territories/BayOfIce)
		TheGoldenSound
			name = "The Golden Sound"
			icon_state = "TheGoldenSound"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/SearoadMarches)
				neighbours += locate(/area/Territories/Lannisport)
				neighbours += locate(/area/Territories/Riverrun)
				neighbours += locate(/area/Territories/SunsetSea)
				neighbours += locate(/area/Territories/IronmansBay)
		IronmansBay
			name = "Ironman's Bay"
			icon_state = "IronmansBay"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/Pyke)
				neighbours += locate(/area/Territories/FlintsFinger)
				neighbours += locate(/area/Territories/GreywaterWatch)
				neighbours += locate(/area/Territories/Seagard)
				neighbours += locate(/area/Territories/Riverrun)
				neighbours += locate(/area/Territories/TheGoldenSound)
				neighbours += locate(/area/Territories/SunsetSea)
		BayOfIce
			name = "Bay Of Ice"
			icon_state = "BayOfIce"
			Castle = 0 // 1 for small castle, 2 for large
			Power  = 0 // Number of Consolidation Crowns
			Supply = 0 // Number of Supply Barrels
			Port   = 0 // 1 if has Port
			isSea  = 1  // It is a sea
			PopulateNeighbours()
				neighbours += locate(/area/Territories/TheStoneyShore)
				neighbours += locate(/area/Territories/GreywaterWatch)
				neighbours += locate(/area/Territories/FlintsFinger)
				neighbours += locate(/area/Territories/Winterfell)
				neighbours += locate(/area/Territories/CastleBlack)
				neighbours += locate(/area/Territories/SunsetSea)