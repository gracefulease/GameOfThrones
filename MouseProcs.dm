client
	var
		mouseDownLoc[2]
	MouseDown(var/obj/object,var/location,var/control,var/params)
		if(control=="default.main"&&isturf(object))
			var/list/plist = params2list(params)
			var/loc = plist["screen-loc"]
			mouseDownLoc = parseScreenLoc(loc)
		else
			mouseDownLoc[1] = -1

		..()
	MouseUp(var/obj/object,var/location,var/control,var/params)
		if(control=="default.main")
			if(mouseDownLoc[1]!=-1)
				var/list/plist = params2list(params)
				var/loc = plist["screen-loc"]
				var/list/parsedLoc = new/list()
				parsedLoc = parseScreenLoc(loc)
				var/mouseX = mouseDownLoc[1] - parsedLoc[1]
				var/mouseY = mouseDownLoc[2] - parsedLoc[2]
				var/turf/targetLoc = locate(src.mob.x + mouseX, src.mob.y + mouseY, src.mob.z)
				if(targetLoc)										// Ensure target location exists
					if(!targetLoc.density&&!targetLoc.opacity)		// Ensure it's not the surrounding border
						src.mob.Move(targetLoc)
