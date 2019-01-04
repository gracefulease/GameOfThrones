obj
	armyPiece
		layer = PIECE_LAYER
		var
			Strength			// Strength
			tempStrength		// Strength affected by House Cards and such
			onSea				// Land or Sea
			mob/Player/Owner 	// Player that owns src
			var/turf/turnStartLoc // Where the piece started the turn
			retreating = FALSE	//Are they retreating or not?
			icon/defaultIcon
			list/overlayList = new/list()
		Infantry
			icon_state = "Infantry"
			Strength = 1
			onSea = 0	// Land unit
		Cavalry
			icon_state = "Cavalry"
			Strength = 2
			onSea = 0	// Land unit
		SiegeTower
			name = "Siege Tower"
			icon_state = "SiegeTower"
			Strength = 4
			onSea = 0	// Land unit
		Ship
			icon_state = "Ship"
			Strength = 1
			onSea = 1	// Sea unit
			MouseEntered()
				for(var/atom/overlay in overlayList)
					overlay.alpha = 255
			MouseExited()
				for(var/atom/overlay in overlayList)
					overlay.alpha = 175
		New()
			..()
			spawn(1) src.defaultIcon = new(src.icon, src.icon_state)

		MouseDrop(var/over_object,var/turf/src_location,var/atom/over_location,var/src_control,var/over_control,var/params)
			if(over_control=="default.main")
				if(!over_location)
					return
				var/obj/armyPiece/piece = src
				var/area/Territories/targetTer
				if(over_location) targetTer = over_location.loc
				var/area/Territories/startTer
				if(turnStartLoc) startTer = turnStartLoc.loc
				var/obj/hudOrder/order
				if(PlayerTurn)
					order = PlayerTurn.curOrder
				if(PHASE == "March" && PlayerTurn == usr && piece.Owner == usr && order && istype(order, /obj/hudOrder/March))		// Moving as part of the March PHASE
					if(startTer != order.loc.loc)
						PlayerTurn << "This piece is not affected by the [order] order."
						return 0
					if(targetTer != startTer && !startTer.highlight.Find(targetTer)) 			// If a valid neighbour to move to
						PlayerTurn << "That is not a valid neighbour."
						return 0
					if(targetTer.isSea && !src.onSea)
						PlayerTurn << "That piece can only move on land."
						return 0
					if(!targetTer.isSea && src.onSea)
						PlayerTurn << "That piece can only move on sea."
						return 0
					if(armyCheck(usr, over_location) >= 1)
						if(battleCheck(order, targetTer))
							if(targetTer.isPort)
								piece.Owner << "Ports cannot be attacked."
								return 0
							if(order.hasAttacked && order.hasAttacked != targetTer && !isLeaving(piece,src_location.loc))
								piece.Owner << "You cannot instigate two battle with one March order."
								return 0
							else
								order.hasAttacked = targetTer

						src.loc = over_location							// Move the piece
						if(!piece.Owner.territories.Find(targetTer))	// And add the territory to the owner's list
							piece.Owner.territories += targetTer
					else
						world<<"Moving [src] to [targetTer] would exceed [usr]'s supply limit."


				else if(PHASE == "Muster" && PlayerTurn == usr && PlayerTurn.castle)	// Mustering
					var/area/Territories/castleArea = PlayerTurn.castle

					if(!PlayerTurn.castle) PlayerTurn<<"Select a castle first."

					var/list/area/Territories/musterPlaces = new/list()	// Make a list of places you can muster
					musterPlaces += castleArea							// Add the mustering land to it

					for(var/area/Territories/a in castleArea.neighbours)
						if(a.isSea || a.isSea)
							musterPlaces+=a								// Add all adjacent seas/ports to the list

					if(musterPlaces.Find(over_location.loc))			// If the piece is dropped on an area in the list then:
						if(castleArea.Castle >= (castleArea.mustered+src.Strength)) // If the castle has enough mustering points left...
							if(targetTer.isSea == src.onSea)
								if(armyCheck(PlayerTurn, over_location)>=1)
									var/obj/armyPiece/army = new piece.type(over_location)
									army.Owner = PlayerTurn
									army.icon = piece.icon
									castleArea.mustered+=piece.Strength
									PlayerTurn.armyPieces += army
									if(!piece.Owner.territories.Find(over_location.loc)) piece.Owner.territories += over_location.loc
									world << "[PlayerTurn] has mustered [piece] in [over_location.loc]."
								else
									PlayerTurn<<"Mustering a piece here would exceed your supply limit."
							else if (!src.onSea)
								PlayerTurn<<"[src] must be mustered on land."
							else if (src.onSea)
								PlayerTurn<<"[src] must be mustered on sea."
						else
							PlayerTurn<<"[src.Strength] points required for [src] exceeds [castleArea.Castle-castleArea.mustered] muster points remaining."

						if(castleArea.Castle==castleArea.mustered) 					// If no mustering points are left, move to the next player
							world<<"[PlayerTurn] has finished mustering at [castleArea]."
							PlayerTurn.castle = null
							castleArea.destroyHUDOverlays()
							d_rotatePlayer(TRUE)

				else if(PHASE == "BattleRout" && battle.retreatSelecter == usr)
					var/pieceCount = 0

					for(var/obj/armyPiece/pieces in battle.Loser.armyPieces)
						if(pieces.loc.loc == battle.territory)
							pieceCount++
					if(armyCheck(battle.Loser,targetTer)>=pieceCount)
						if(battle.retreatSelecter != battle.Loser) world<<"[battle.retreatSelecter] has selected [battle.Loser]'s army will retreat to [targetTer]."
						else world<<"[battle.Loser] is retreating to [targetTer]."
						src.loc = over_location
						var/icon/I
						for(var/obj/armyPiece/pieces in battle.Loser.armyPieces)
							if(pieces.loc.loc == battle.territory)
								bounce(pieces)
								pieces.loc = pick(targetTer)
								I = new(src.icon, src.icon_state)
								I.Turn(90)
								I.Blend(rgb(180,180,180),ICON_MULTIPLY,1,1)
								piece.icon = I
								piece.retreating = TRUE
						battle_seizeLand()
					else
						battle.retreatSelecter << "[battle.Loser]'s pieces can't retreat there as there are [pieceCount] pieces and only room there for [armyCheck(battle.Loser,src)]."

				else if(PHASE == "DEBUG")


				else if (PlayerTurn != usr) usr << "It is not your turn!"
				else if (piece.Owner != usr) usr << "That is not your piece!"

		MouseDown(location,control,params)
			var/obj/armyPiece/piece = src
			if(piece.Owner == usr && PlayerTurn == usr)
				if(PHASE == "March")
					if(!PlayerTurn.curOrder)	// If the Player doesn't have a current order yet, set it to the one relevant to this piece

						var/area/Territories/territory = src.loc.loc	// Check that there's a MARCH Order in the piece's territory
						var/obj/hudOrder/march = locate(/obj/hudOrder/March) in territory
						if(march)
							piece.mouse_drag_pointer = icon(piece.icon, piece.icon_state)
							PlayerTurn.curOrder = march
							territory.fillNeighbours(usr)
							territory.highlightNeighbours(/obj/orderOverlay/march)
							for(var/obj/armyPiece/pieces in territory)
								pieces.turnStartLoc = pieces.loc
					else if(PlayerTurn.curOrder.loc.loc == src.turnStartLoc.loc)
						piece.mouse_drag_pointer = icon(piece.icon, piece.icon_state)
					else
						piece.mouse_drag_pointer = 0

				else if((PHASE == "Muster" && location == "apMap") || (PHASE == "BattleRout" && battle.Loser == usr))
					piece.mouse_drag_pointer = icon(piece.icon, piece.icon_state)
				else
					piece.mouse_drag_pointer = 0
			else
				piece.mouse_drag_pointer = 0

		Click()
			clickDel(usr)
			upgradeCheck(usr)
			downgradeCheck(usr)
			..()
		proc
			clickDel(var/mob/Player/clicker)
				if(PlayerTurn == clicker && src.Owner == clicker)
					if(PHASE=="Reconcile Supply" || PHASE=="RR-Loss" )
						clicker.armyPieces-=src
						src.loc=null
						world<<armyCheck(clicker)
						if(armyCheck(clicker) >= 0)
							if(clicker.client)
								clicker.client.mouse_pointer_icon = null
							if(clicker == Lowest)
								c_endCardPhase()
								del src
							d_rotatePlayer(FALSE)
						else
							clicker << "You still exceed your supply."
						del src
					else if(findtext(PHASE,"MR-Loss"))
						clicker.armyPieces-=src
						src.loc=null
						if(PHASE=="MR-Loss")
							PHASE = "MR-Loss1"
						else if(PHASE=="MR-Loss1" && clicker==Lowest)
							PHASE = "MR-Loss2"
						else if(PHASE=="MR-Loss1" || PHASE=="MR-Loss2")
							if(clicker.client)
								clicker.client.mouse_pointer_icon = null
							if(clicker==Lowest)
								c_endCardPhase()
								del src
							else
								PHASE = "MR-Loss"
								d_rotatePlayer(FALSE)
						del src
					else if(findtext(PHASE,"PR-Loss"))
						clicker.armyPieces-=src
						src.loc=null
						if(PHASE=="PR-Loss2")
							if(clicker.client)
								clicker.client.mouse_pointer_icon = null
							c_endCardPhase()
							del src
						else if(findtext(PHASE,"1")) PHASE = replacetext(PHASE,"1","2")
						else PHASE += "1"
						del src

					else if(findtext(PHASE,"THD-Loss"))
						if(PHASE=="THD-Loss" && clicker!=Lowest)
							clicker.armyPieces-=src
							src.loc=null
							if(clicker.client)
								clicker.client.mouse_pointer_icon = null
							PHASE = "THD-Loss"
							d_rotatePlayer(FALSE)
						else
							var/area/Territories/ter = src.loc.loc
							var/area/Territories/otherTer
							var/hasGarrison = FALSE
							if(ter.Castle)
								clicker.armyPieces-=src
								src.loc=null
								if(findtext(PHASE,"2"))
									c_endCardPhase()
									if(clicker.client)
										clicker.client.mouse_pointer_icon = null
									del src
								if(findtext(PHASE,"1")) PHASE = replacetext(PHASE,"1","2")
								else PHASE += "1"
							else
								for(var/obj/piece in clicker.armyPieces)
									otherTer = piece.loc.loc
									if(otherTer.Castle)
										hasGarrison = TRUE
										break
								if(hasGarrison)
									clicker<<"You must delete a unit from a territory that contains a castle. [ter] does not. [otherTer] does, for example."
								else
									clicker.armyPieces-=src
									src.loc=null
									if(findtext(PHASE,"2"))
										c_endCardPhase()
										if(clicker.client)
											clicker.client.mouse_pointer_icon = null
										del src
									if(findtext(PHASE,"1")) PHASE = replacetext(PHASE,"1","2")
									else PHASE += "1"
						del src
					else if(PHASE=="BattleHC")
						var/obj/House_Cards/card = battle.houseCards[clicker]
						if(istype(card,/obj/House_Cards/Tyrell/Mace))
							if(!card.used)
								var/mob/Player/enemy
								for(enemy in battle.combatants)
									if(enemy != clicker)
										break
								if(enemy.armyPieces.Find(src))
									enemy.armyPieces -= src
									src.loc = null
									card.used = TRUE
									clicker.client.mouse_pointer_icon = null
									world<<"[clicker] destroyed [enemy]'s [src] in [src.loc.loc]."

									if(battle_HouseCardsCheck()) battle_Blade()
								del src
					else if(PHASE=="BattleCas")
						if(src.loc.loc == battle.territory)
							if(src.Owner == clicker)
								clicker.armyPieces -= src
								src.loc = null
								battle_casualtiesCheck()
						del src


			upgradeCheck(var/mob/Player/clicker)
				if(findtext(PHASE,"CK-Won") && Highest == clicker && src.Owner == clicker)
					if(!istype(src, /obj/armyPiece/Infantry))
						clicker << "You may only upgrade infantry pieces."
						return 0
					var/obj/armyPiece/Cavalry/piece = new(src.loc)
					var/icon/iconFile = houseIconLookup(clicker.House)
					piece.Owner	= clicker
					piece.icon	= iconFile
					clicker.armyPieces+=piece
					if(PHASE=="CK-Won")
						PHASE = "CK-Won1"
					else if(PHASE=="CK-Won1")
						if(clicker.client)
							clicker.client.mouse_pointer_icon = null
						c_endCardPhase()
					del src
				else if(PHASE == "BattleEnd" && battle.Winner == Owner)
					var/obj/House_Cards/card = battle.houseCards[clicker]
					if(istype(card,/obj/House_Cards/Baratheon/Renly))
						if(!card.used)

							if(!istype(src, /obj/armyPiece/Infantry))
								clicker << "You may only upgrade infantry pieces."
								return 0

							var/obj/armyPiece/Cavalry/piece = new(src.loc)
							var/icon/iconFile = houseIconLookup(clicker.House)
							piece.Owner	= clicker
							piece.icon	= iconFile
							clicker.armyPieces+=piece

							card.used = TRUE

							if(battle_HouseCardsCheck())
								battle_routing()


			downgradeCheck(var/mob/Player/clicker)
				if(findtext(PHASE,"CK-Loss") && PlayerTurn == clicker && src.Owner == clicker)
					if(!istype(src, /obj/armyPiece/Cavalry))
						clicker << "You may only downgrade cavalry pieces."
						return 0
					var/obj/armyPiece/Infantry/piece = new(src.loc)
					var/icon/iconFile = houseIconLookup(clicker.House)
					piece.Owner	= clicker
					piece.icon	= iconFile
					clicker.armyPieces+=piece
					if(PHASE=="CK-Loss")
						PHASE = "CK-Loss1"
					else if(PHASE=="CK-Loss1")
						if(clicker.client)
							clicker.client.mouse_pointer_icon = null
						PHASE = "CK-Loss"
						d_rotatePlayer(FALSE)
					del src

proc
	armyCheck(var/mob/Player/player, var/atom/over_location, var/area/Territories/currentTer)
		if(over_location)
			world<<"Sending [player] to moveArmyCheck"
			return moveArmyCheck(player, over_location, currentTer)
		else
			world<<"Sending [player] to stdArmyCheck"
			return stdArmyCheck(player)

	// Return the number of spaces free in the specified over_location, but doesn't fill an army slot with currentTer if included
	moveArmyCheck(var/mob/Player/player, var/atom/over_location, var/area/Territories/currentTer)
		var/army = 0
		var/foundSlot = 0
		var/amount = 0
		var/count = 0

		var/list/allowedArmies = new/list()						// The armies they're allowed
		var/list/currentArmies = new/list()						// The armies they currently have
		var/list/templist = SupplyAllowance[player.Supply+1]	// Get their specific supply allowance

		// Fill allowedArmies with the armies allowed by their supply
		allowedArmies = templist.Copy()

		// Make a list of the territories they own, plus the place they're trying to move to if it isn't one of them
		var/list/check = player.territories.Copy()
		if(over_location)
			if(!check.Find(over_location.loc)) check+= over_location.loc

		// Count the number of pieces in each territory
		for(var/area/Territories/territory in check)
			count = 0
			for(var/obj/armyPiece/piece in territory)
				if(player.armyPieces.Find(piece))
					count++

			if(territory == currentTer)		// On a success this piece will move so should not be counted towards limit
				count--
			if(count>=1)	currentArmies[territory] = count

		if(OrganizeNumbers(currentArmies) == -1)	// Sort their current armies by size
			return -1								// If the sort failed, return error code -1

		for(var/i = 1; i<= currentArmies.len; i++)	// Loops through the list of armies, subtracting allowance
			army = currentArmies[i]
			foundSlot = 0
			amount = 0

			if(allowedArmies.len>=1)				//Look for smallest supply to fit army - start amount at exact army size, and increase up to largest allowed
				for(amount = currentArmies[army]; amount <= allowedArmies[1]; amount++)
					foundSlot = 0
					if(amount == 1)
						foundSlot = 1
						break
					else if(allowedArmies.Remove(amount))
						foundSlot = 1
						break

				if(!foundSlot)						// None of the available slots were large enough
					return -1
			else									// Run out of available army slots
				return -1

		if(allowedArmies.len>=1)
			amount = 0
			if(currentArmies[over_location.loc])
				amount = currentArmies[over_location.loc]
			return (allowedArmies[1]-amount)
		else
			return 0

	// Return the number of spaces free in the specified over_location, but doesn't fill an army slot with currentTer if included
	stdArmyCheck(var/mob/Player/player)
		var/army = 0
		var/foundSlot = 0
		var/amount = 0
		var/count = 0

		var/list/allowedArmies = new/list()						// The armies they're allowed
		var/list/currentArmies = new/list()						// The armies they currently have
		var/list/templist = SupplyAllowance[player.Supply+1]	// Get their specific supply allowance

		// Fill allowedArmies with the armies allowed by their supply
		allowedArmies = templist.Copy()

		// Make a list of the territories they own
		var/list/check = player.territories.Copy()

		// Count the number of pieces in each territory
		for(var/area/Territories/territory in check)
			count = 0
			for(var/obj/armyPiece/piece in territory)
				if(player.armyPieces.Find(piece))
					count++

			if(count>=1)	currentArmies[territory] = count

		if(OrganizeNumbers(currentArmies) == -1)	// Sort their current armies by size
			return -1								// If the sort failed, return error code -1

		for(var/i = 1; i<= currentArmies.len; i++)	// Loops through the list of armies, subtracting allowance
			army = currentArmies[i]

			if(allowedArmies.len>=1)				//Look for smallest supply to fit army - start amount at exact army size, and increase up to largest allowed
				for(amount = currentArmies[army]; amount <= allowedArmies[1]; amount++)
					foundSlot = 0

					//Armies of one don't need a slot
					if(amount == 1)
						foundSlot = 1
						break

					// Remove a the smallest slot possible
					else if(allowedArmies.Remove(amount))
						foundSlot = 1
						break

				if(!foundSlot)						// None of the available slots were large enough
					return -1
			else									// Run out of available army slots
				return -1

		if(allowedArmies.len>=1)
			return 1
		else
			return 0

	p_resetRouters()
		var/mob/Player/player
		for(var/p in Players)
			player = Players[p]
			for(var/obj/armyPiece/piece in player.armyPieces)
				if(piece.retreating)
					piece.retreating = FALSE
					piece.icon = piece.defaultIcon

	OrganizeNumbers(list/AS) //Associated List to sort by Associated Values
		if(!AS)
			world << "ERROR: No list."
			return -1
		var
			list/TempCount[] = list()
			i = 1
			Comparer	//Value to be compared to the list with
			h		   //Holder. Holds the index of the Comparer for reference later
		while(TempCount.len > 0)
			if(i > AS.len)
				TempCount[AS[h]] = AS[AS[h]]
				AS.Remove(AS[h])
				i = 1
			if(AS.len)
				Comparer = AS[AS[i]]
				h = i
			for(i,i<=AS.len,i++)
				var/b = AS[AS[i]]
				if(Comparer < b)break
		var/b
		for(b=1,b<=TempCount.len,b++)
			AS[TempCount[b]] = TempCount[TempCount[b]]


	isLeaving(var/obj/armyPiece/piece, var/area/Territories/territory)
		var/obj/hudOrder/March/order = PlayerTurn.curOrder
		var/remaining = 1
		for(var/obj/armyPiece/pieces in (PlayerTurn.armyPieces - piece))
			if(pieces.loc.loc == order.hasAttacked)
				remaining = 0
				break
		return remaining