var/list
	npcGarrisons = list(list(KingsLanding = 5, TheEyrie = 6),list(TheBoneway = 3, Yronwood = 3, ThreeTowers = 3, Sunspear = 5, PrincesPass = 3, Starfall = 3, SaltShore = 3),list(StormsEnd = 4, DornishMarches = 3, Oldtown = 3))

proc
	populateNPCgarrisons()
		var/area/Territories/ter
		var/tername
		var/obj/garrisonPiece/Garrison/garrison
		var/obj/WorldObjs/Strategy/Castle/castle
		var/garrisonRange = 0
		var/turf/WorldTurfs/place

		for(var/listi = 1, 6-listi>=Players.len && listi<=npcGarrisons.len, listi++)
			for(tername in npcGarrisons[listi])
				ter = locate(text2path("/area/Territories/[tername]"))
				if(ter)
					garrisonRange = 0
					castle = locate(/obj/WorldObjs/Strategy/Castle) in ter
					if(!castle) castle = locate(/obj/WorldObjs/Strategy/Fort) in ter
					if(!castle)
						do
							castle = pick(ter.contents)
						while(!(istype(castle,/turf)&&!castle.contents.len))

					for(var/i = 1; i<=npcGarrisons[listi][tername]; i++)
						garrison = new()
						garrison.Owner = "NPC"
						place = null
						do
							garrisonRange+=1
							for(var/turf/picked in range(garrisonRange,castle))
								if(!picked.contents.len && picked.loc == ter)
									place = picked
									break
						while(!place)
						garrison.loc = place

	npcBattle(var/mob/Player/attacker, var/area/Territories/territory)
		battle = new()
		battle.territory = territory
		var/answer, defaultAnswer
		var/obj/hudOrder/Support/support
		var/list/options

		for(var/obj/garrisonPiece/Garrison/garrison in battle.territory)
			battle.combatants["NPC"] += garrison.Strength

		// There's no NPC's so this must be a normal battle
		if(battle.combatants["NPC"]<1)
			return 0

		// Add current March order strength to attacker strength
		if(istype(attacker.curOrder, /obj/hudOrder/March))
			battle.combatants[attacker] += attacker.curOrder.bonus
		else
			world<<"Error in npcBattle() - [attacker.curOrder] should be a March."

		// Add strength of army pieces
		for(var/obj/armyPiece/piece in battle.territory)
			battle.combatants[piece.Owner] += piece.Strength
			piece.tempStrength = piece.Strength

		// Add strength of supporters
		for(var/area/Territories/neighbour in battle.territory.neighbours)
			support = locate(/obj/hudOrder/Support) in neighbour
			if(support && !(neighbour.isPort && !battle.territory.isSea))	// Ports can't support battle on land
				options = list(attacker, "No-one")
				defaultAnswer = "No-one"
				if(support.Owner == attacker)
					defaultAnswer = attacker

				answer = input(support.Owner,"Who will your troops in [neighbour] support the battle?", "Support", defaultAnswer) in options
				if(answer == "No-one")
					continue

				battle.combatants[answer] += support.bonus

				for(var/obj/armyPiece/piece in neighbour)
					bounce(piece)
					if(support.Owner != piece.Owner)
						world<<"Error in npcBattle() - [support.Owner] should be the same as [piece.Owner]"
						return -1
					else
						battle.combatants[answer] += piece.Strength

		// Remove Garrison pieces
		if(battle.combatants[attacker] >= battle.combatants["NPC"])
			for(var/obj/garrisonPiece/Garrison/garrison in battle.territory)
				if(garrison.Owner == "NPC")
					del garrison

			attacker.territories += battle.territory
			return 1

		else
			for(var/obj/armyPiece/piece in battle.territory)
				piece.Move(piece.turnStartLoc)
			attacker << "You need [battle.combatants["NPC"] - battle.combatants[attacker]] more strength to seize [territory]."
			return -1








