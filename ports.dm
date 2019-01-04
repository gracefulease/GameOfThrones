
area
	Territories
		Port
			isSea  = 1
			isPort = 1
			Lannisport
				PopulateNeighbours()
					neighbours += locate(/area/Territories/TheGoldenSound)
			Oldtown
				PopulateNeighbours()
					neighbours += locate(/area/Territories/RedwyneStraits)
			Winterfell
				PopulateNeighbours()
					neighbours += locate(/area/Territories/BayOfIce)
			WhiteHarbour
				PopulateNeighbours()
					neighbours += locate(/area/Territories/TheNarrowSea)
			Dragonstone
				PopulateNeighbours()
					neighbours += locate(/area/Territories/ShipbreakerBay)
			StormsEnd
				PopulateNeighbours()
					neighbours += locate(/area/Territories/ShipbreakerBay)
			Sunspear
				PopulateNeighbours()
					neighbours += locate(/area/Territories/EastSummerSea)
			Pyke
				PopulateNeighbours()
					neighbours += locate(/area/Territories/IronmansBay)

obj
	Port
		icon = 'Ports.dmi'
		North
			icon_state="N"
		South
			icon_state="S"
		East
			icon_state="E"
		West
			icon_state="W"



obj
	ShipOverlay
		icon = 'HUD.dmi'
		layer = HUD_LAYER
		alpha = 175
		var/obj/armyPiece/Ship/master
		MouseEntered()
			var/matrix/enlargeM = matrix()
			enlargeM.Scale(2.0,2.0)
			src.transform = enlargeM
			src.alpha = 255
			layer = HUD_LAYER + 1
			pixel_y += 8
		MouseExited()
			var/matrix/enlargeM = matrix()
			enlargeM.Scale(1,1)
			src.transform = enlargeM
			src.alpha = 175
			layer = HUD_LAYER
			pixel_y -= 8
		Destroy
			icon_state = "Destroy"
			pixel_y = 0
			Click()
				master.Owner.armyPieces -= master
				for(var/item in master.overlayList)
					if(item!=src)
						del item
				del master
				del src
		Seize
			icon_state = "Seize"
			pixel_y= 22
			Click()
				master.Owner.armyPieces -= master
				master.Owner = usr
				master.Owner.armyPieces += master
				master.icon = houseIconLookup(master.Owner.House)
				for(var/item in master.overlayList)
					if(item!=src)
						del item
				del src