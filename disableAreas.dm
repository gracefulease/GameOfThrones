var/list/disableList = list("Pyke", "Highgarden", "TheBoneway", "Yronwood", "ThreeTowers", "Sunspear", "PrincesPass", "Starfall", "SaltShore", "StormsEnd", "DornishMarches", "Oldtown")

proc/disableAreas()
	if(Players.len==3)

		var/area/Territories/ter
		// Remove all disabled areas from the npcGarrison list as we don't need to garrison areas that are disabled
		for(var/i = 1, i<=3, i++)
			var/list/tempList = npcGarrisons[i]
			for(var/entry in tempList)
				if(disableList.Find(entry))
					tempList.Remove(entry)

		for(var/tername in disableList)
			ter = locate(text2path("/area/Territories/[tername]"))
			if(ter)
				var/obj/greyedout = new()
				greyedout.icon = 'Territories.dmi'
				greyedout.icon_state = "disabled"
				greyedout.layer = OVERLAY_LAYER
				ter.overlays+= greyedout
				ter.disabled = TRUE
		for(var/area/Territories/all in world)
			for(var/tername in disableList)
				ter = locate(text2path("/area/Territories/[tername]"))
				all.neighbours.Remove(ter)

