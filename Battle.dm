proc
	// Checks if a battle will be incurred by player moving to territory
	battleCheck(var/obj/hudOrder/March/march, var/area/Territories/territory)
		if(march.hasAttacked == territory)	// You're already attacking this territory, so continue
			return 1
		var/mob/Player/defender = null

		for(var/obj/armyPiece/piece in territory)
			if(piece.Owner!=march.Owner)
				defender = piece.Owner
				break

		if(!defender)
			for(var/obj/garrisonPiece/piece in territory)
				if(piece.Owner!=march.Owner)
					defender = piece.Owner
					break
		if(defender)
			return 1
		return 0

	battle(var/mob/Player/attacker, var/area/Territories/territory)
		PHASE = "Battle"
		battle = new()
		battle.territory = territory
		battle.attDef["attacker"] = attacker
		var/answer, defaultAnswer
		var/obj/hudOrder/Support/support
		var/list/options

		var/mob/Player/defender
		for(var/obj/armyPiece/piece in territory)
			if(piece.Owner!=attacker)
				defender = piece.Owner
				battle.attDef["defender"] = defender
				break
		if(!defender)
			world<<"Error: there should be a defender."
			return 0

		world<<"[attacker] has attacked [defender]'s army in [territory]!"
		battle.combatants[attacker]=0
		battle.combatants[defender]=0

		var/list/attackerScores = addScoresToAllScreens(attacker, -2)
		var/list/defenderScores = addScoresToAllScreens(defender, 2)

		battle.hud[attacker] = attackerScores
		battle.hud[defender] = defenderScores

		sleep(10)

		// Add current March order strength to attacker strength
		if(istype(attacker.curOrder, /obj/hudOrder/March))
			battle.combatants[attacker] += attacker.curOrder.bonus
			updateBattleScores()
			bounce(attacker.curOrder)

		// Add Defend strength to attacker strength
		var/obj/hudOrder/defOrder = locate(/obj/hudOrder/) in battle.territory
		defender.curOrder = defOrder
		if(istype(defOrder, /obj/hudOrder/Defend) && defOrder.Owner == defender)
			battle.combatants[defender] += defOrder.bonus
			updateBattleScores()
			bounce(defOrder)

		sleep(10)

		// Add strength of army pieces
		for(var/obj/armyPiece/piece in battle.territory)
			bounce(piece)
			piece.tempStrength = piece.Strength

			//Set piece strength to 0 if a siege tower that isn't attacking a castle, OR if piece is retreating
			if(istype(piece,/obj/armyPiece/SiegeTower) && (!battle.territory.Castle || piece.Owner != attacker)\
				||piece.retreating)
				battle.pieces[piece] = piece.Owner
				piece.tempStrength = 0
				continue

			battle.combatants[piece.Owner] += piece.tempStrength
			battle.pieces[piece] = piece.Owner
			updateBattleScores()

		// Add strength of garrison pieces
		for(var/obj/garrisonPiece/garrison in battle.territory)
			bounce(garrison)
			battle.combatants[garrison.Owner] += garrison.Strength
			garrison.tempStrength = garrison.Strength
			updateBattleScores()

		sleep(10)

		// Add strength of supporters
		for(var/area/Territories/neighbour in battle.territory.neighbours)
			support = locate(/obj/hudOrder/Support) in neighbour
			if(support && !(neighbour.isPort && !battle.territory.isSea))	// Ports can't support battle on land
				options = list(attacker, defender, "No-one")
				defaultAnswer = "No-one"
				if(support.Owner == attacker)
					options -= defender
					defaultAnswer = attacker
				else if(support.Owner == defender)
					options -= attacker
					defaultAnswer = defender

				answer = input(support.Owner,"Who will your troops in [neighbour] support the battle?", "Support", defaultAnswer) in options
				if(answer == "No-one")
					continue

				battle.combatants[answer] += support.bonus
				updateBattleScores()

				var/list/ownerFlags = new/list()			// Add flag to mark them as supported (for Salladhor et al)
				if(battle.flags[answer])
					ownerFlags = battle.flags[answer]
				if(!ownerFlags.Find("supported")) ownerFlags.Add("supported")
				battle.flags[answer]=ownerFlags

				for(var/obj/armyPiece/piece in neighbour)
					bounce(piece)
					if(support.Owner != piece.Owner)
						world<<"Error in battleChecks() - [support.Owner] should be the same as [piece.Owner]"
						return 0
					else
						//Set piece strength to 0 if a siege tower that isn't attacking a castle
						if(istype(piece,/obj/armyPiece/SiegeTower) && (!battle.territory.Castle || answer != attacker))
							battle.pieces[piece] = answer
							piece.tempStrength = 0
							continue
						battle.combatants[answer] += piece.Strength
						battle.pieces[piece] = answer
						piece.tempStrength = piece.Strength
						updateBattleScores()

		PHASE = "BattleHC"
		for(var/mob/Player/player in battle.combatants)
			player << "Select a House card to lead your forces."
			if(!player.client)
				player.AI()

		showHouseCards(attacker,defender)
		showHouseCards(defender,attacker)

	battle_HouseCardsActivate()
		var/obj/House_Cards/card

		for(var/mob/Player/player in battle.houseCards)		// Check for Tyrion
			card = battle.houseCards[player]
			if(!battle.bannedCard && istype(card,/obj/House_Cards/Lannister/Tyrion))
				for(var/mob/Player/other in battle.houseCards - player)
					var/choice = input(player,"[other] has selected [battle.houseCards[other]] - will you force them to reselect their House Card?","[card.name]","Yes") in list("Yes","No")
					if(choice == "Yes")
						battle.bannedCard = battle.houseCards[other]
						battle.houseCards[other] = null
						world<<"[player] played [card] so [other] cannot use [battle.bannedCard] and must pick another House Card."
						showHouseCards(other,player)
						other.AI()
						return 0

			if(istype(card,/obj/House_Cards/Greyjoy/Aeron))	// Check for Aeron
				if(player.Influence >= 2)
					for(var/mob/Player/other in battle.houseCards - player)
						var/choice = input(player,"[other] has selected [battle.houseCards[other]] - do you want to spend 2 of your [player.Influence] to reselect your House Card?","[card.name]","No") in list("Yes","No")
						if(choice == "Yes")
							battle.houseCards[player] = null
							player.HouseCards -= card
							player.DiscardPile += card
							player.Influence -= 2
							world<<"[player] discarded [card] to pick another House Card."
							showHouseCards(player,other)
							player.AI()
							return 0

		for(var/player in battle.houseCards)
			card = battle.houseCards[player]
			world<<"[player] picked [card]." //@TODO - show card to everyone
			if(card.desc) world<<"[card]'s ability: [card.desc]."
			battle.combatants[player] += card.Strength
			battle.swords[player] += card.Swords
			battle.shields[player] += card.Shields

		updateBattleScores()

		for(var/player in battle.houseCards)
			card = battle.houseCards[player]
			card.effect()

		updateBattleScores()

		if(battle_HouseCardsCheck()) battle_Blade()

	battle_Blade()
		var/obj/HUD/Dominance/Fiefdoms/sword = locate("Fiefdomstoken")
		var/mob/Player/bladeBearer = sword.loc
		if(sword.used || !bladeBearer || !battle.combatants[bladeBearer])
			battle_determineWinner()
		else
			bladeBearer << "Click on the Valyrian Steel Blade to use it, or click Done to continue the battle without it."
			PHASE = "BattleBlade"


	battle_determineWinner()
		updateBattleScores()

		/* Determine winner/loser: compare scores. If equal, compare positions on Fiefdoms */
		for(var/player in battle.combatants)
			if(!battle.Winner)
				battle.Winner = player
				battle.Loser = player
				continue
			else if(battle.combatants[battle.Winner]<battle.combatants[player])
				battle.Loser = battle.Winner
				battle.Winner = player
				break
			else if(battle.combatants[battle.Winner]==battle.combatants[player])
				var/list/Fiefdoms = Tracks["Fiefdoms"]
				if(Fiefdoms.Find(battle.Winner)>Fiefdoms.Find(player))
					battle.Loser = battle.Winner
					battle.Winner = player
					break
				else
					battle.Loser = player
			else
				battle.Loser = player

		world << "[battle.Winner] has defeated [battle.Loser] in battle!"
		sleep(5)
		battle_casualties()

	battle_casualties()
		//Remove all retreating units first
		for(var/obj/armyPiece/piece in battle.Loser.armyPieces)
			if(piece.retreating)
				del piece

		// Then calculate the number of casualties incurred
		battle.casualties = max(battle.swords[battle.Winner] - battle.shields[battle.Loser],0)

		// Check flags for no_casualties effect from House Card
		var/list/ownerFlags = new/list()
		var/numberOfPieces = 0
		if(battle.flags[battle.Loser])
			ownerFlags = battle.flags[battle.Loser]
			if(ownerFlags.Find("no_casualties"))
				battle.casualties = 0

		if(!battle.casualties)
			battle_endEffects()
		else
			for(var/obj/armyPiece/piece in battle.territory)
				if(piece.Owner == battle.Loser)
					numberOfPieces ++
			if(battle.casualties<numberOfPieces)
				world << "[battle.Loser] must destroy [battle.casualties] pieces."
				PHASE = "BattleCas"
				if(battle.Loser.client)
					battle.Loser.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")
				else
					battle.Loser.AI()
				return 0
			else
				world << "More than [battle.casualties] casualties were incurred than [battle.Loser] has pieces, so all are destroyed."
				for(var/obj/armyPiece/piece in battle.territory)
					if(piece.Owner == battle.Loser)
						piece.Owner.armyPieces -= piece
						del piece
				PHASE = "BattleEnd"
				battle_endEffects()
			return 0

	battle_casualtiesCheck()
		if(!battle.casualties)
			world<<"ERROR - battle_casualtiesCheck()"
		else
			battle.casualties--
			if(battle.casualties<=0)
				if(battle.Loser.client)
					battle.Loser.client.mouse_pointer_icon = null
				battle_endEffects()
			else
				battle.Loser << "[battle.casualties] pieces left to destroy."

	battle_endEffects()
		PHASE = "BattleEnd"
		var/obj/House_Cards/card
		card = battle.houseCards[battle.Winner]
		card.winEffect()
		card = battle.houseCards[battle.Loser]
		card.lossEffect()
		if(battle_HouseCardsCheck())
			battle_routing()

	battle_routing()
		PHASE = "BattleRout"
		var/list/ownerFlags = new/list()

		if(battle.Loser.territories.Find(battle.territory)) battle.Loser.territories -= battle.territory
		// Loser loses battle.territory, so all npcGarrisons die //
		for(var/obj/garrisonPiece/garrison in battle.territory)
			if(garrison.Owner == battle.Loser)
				bounce(garrison)
				del garrison

		battle.retreatSelecter = battle.Loser
		if(battle.flags[battle.Winner])
			ownerFlags = battle.flags[battle.Winner]
			if(ownerFlags.Find("pick_retreat"))
				battle.retreatSelecter = battle.Winner
			if(ownerFlags.Find("cannot_seize") && battle.attDef["attacker"] == battle.Winner)
				world<<"[battle.Winner] must return to the area from which they marched. [battle.Loser] must still retreat."
				sleep(5)
				var/area/Territories/returnTer = battle.Winner.curOrder.loc.loc
				for(var/obj/armyPiece/piece in battle.Winner.armyPieces)
					if(piece.loc.loc == battle.territory)
						bounce(piece)
						piece.loc = pick(returnTer.contents)
		var/list/remainingPieces = list(battle.Loser = 0, battle.Winner = 0)	//Determine if either combatant has pieces left in the area
		for(var/obj/armyPiece/piece in battle.territory)
			remainingPieces[piece.Owner]++

		if(remainingPieces[battle.Loser]>=1)
			if(battle.retreatSelecter != battle.Loser) world<<"[battle.retreatSelecter] now selects where [battle.Loser] retreats to."
			else world<<"[battle.Loser] now chooses where to retreat to."

			battle.territory.fillNeighbours(battle.Loser, battle.Winner)
			battle.territory.highlightNeighbours(/obj/orderOverlay/rout)
			if(battle.retreatSelecter.client)
				sleep(5)
				battle.retreatSelecter<<"Select either an empty or friendly adjacent area - ships may be used for transport."
				sleep(5)
				battle.retreatSelecter<<"All units must go to the same territory. If doing so would breach the supply limit then it may only be chosen if it is the only option. [battle.Loser] must then destroy enough routing units to comply."
			else
				battle.retreatSelecter.AI()

		else
			battle_seizeLand()

	battle_seizeLand()
		PHASE = "BattleSeize"
		var/list/remainingPieces = list(battle.Loser = 0, battle.Winner = 0)	//Determine if either combatant has pieces left in the area
		for(var/obj/armyPiece/piece in battle.territory)
			remainingPieces[piece.Owner]++

		if(remainingPieces[battle.Winner]>=1)
			if(!battle.Winner.territories.Find(battle.territory)) battle.Winner.territories += battle.territory

			if(battle.territory.Port)
				var/area/Territories/port = locate(battle.territory.Port)
				for(var/obj/armyPiece/Ship/piece in port)

					if(armyCheck(battle.Winner, port) >= 1)
						piece.overlays += new /obj/ShipOverlay/Destroy()
						piece.overlays += new /obj/ShipOverlay/Seize()
					else
						piece.Owner.armyPieces -= src
						piece.loc = null


	battle_complete()
		PHASE = "BattleComplete"
		for(var/hudchoices in battle.hud)
			del battle.hud[hudchoices]
		battle.territory.destroyHUDOverlays()
		var/mob/Player/attacker = battle.attDef["attacker"]
		del attacker.curOrder

		for(var/obj/hudOrder/order in battle.territory)
			if(order.Owner!=battle.Loser)
				del order

		PHASE = "March"
		d_rotatePlayer(TRUE)



	battle_HouseCardsCheck()	// Check if everyone's done their House Cards
		var/alldone = TRUE
		var/obj/House_Cards/card
		for(var/player in battle.houseCards)
			card = battle.houseCards[player]
			if(!card.used)
				alldone = FALSE
				world<<"[player] [card]"
				break
		return alldone


	addScoresToAllScreens(var/mob/Player/player, var/screen_loc)
		var/list/battleScore = new/list()
		var/obj/HUD/Influence/playerInfl
		var/icon/houseIcon = houseIconLookup(player.House)
		for(var/mob/Player/other in Tracks["IronThrone"])
			if(other.client)
				playerInfl = new(null, other.client, list(icon = houseIcon, anchor_x="CENTER", anchor_y="NORTH", screen_x=screen_loc*TILE_WIDTH, screen_y=-3*TILE_HEIGHT, layer=HUD_LAYER-1),1)
				playerInfl.transform *= 2
				playerInfl.maptext="0"
				playerInfl.maptext_x=13
				playerInfl.maptext_y=-16
				battleScore+=playerInfl
		return battleScore

	updateBattleScores()
		var/obj/HUD/score
		for(var/player in battle.combatants)
			var/list/scores = battle.hud[player]
			for(score in scores)
				score.maptext = "[battle.combatants[player]]"

datum
	Battle
		var
			list/attDef = new/list()
			mob/Player/Winner
			mob/Player/Loser
			mob/Player/retreatSelecter
			list/combatants = new/list()
			list/hud = new/list()
			list/houseCards = new/list()
			list/swords = new/list()
			list/shields = new/list()
			area/Territories/territory
			list/flags = new/list()
			list/pieces = new/list()
			obj/House_Cards/bannedCard
			casualties = 0