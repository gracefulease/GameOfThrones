mob/Player/proc/AI()
	if(!src.client)
		if(PHASE=="Place Orders")
			var/obj/armyPiece/piece
			var/obj/hudOrder/order
			var/turf/WorldTurfs/place
			var/list/pickableOrders = src.Orders.Copy()

			if(!Restraints["canRaid"])
				for(var/obj/hudOrder/Raid/raid in pickableOrders)
					pickableOrders.Remove(raid)
					del raid
			if(!Restraints["canDefend"])
				for(var/obj/hudOrder/Defend/def in pickableOrders)
					pickableOrders.Remove(def)
					del def
			if(!Restraints["canConsolidate"])
				for(var/obj/hudOrder/Consolidate/consolidate in pickableOrders)
					pickableOrders.Remove(consolidate)
					del consolidate

			for(var/area/Territories/ter in src.territories)
				piece = locate(/obj/armyPiece) in ter
				if(piece)
					order = pick(pickableOrders)
					if(order)
						order.Owner = src
					else

						world<<"Error: [src] hasn't got an order. [pickableOrders.len] pO.len"
						for(var/a in pickableOrders)
							world<<"a [a]"
						return

					for(var/turf/picked in ter.contents)
						if(!picked.contents.len)
							place = picked
							break


					src.hudOrders += new order.type(place,owner=src)
					bounce(order)
					pickableOrders.Remove(order)
				//	world<<"[src.House] picks [order] [pickableOrders.len] - [order.x],[order.y],[order.z]"
		else if(PHASE=="Raven")
			PHASE = "Raid"
			d_startPhase()
		else if(PHASE=="Raid")		// @TODO
			for(var/obj/hudOrder/Raid/raid in src.hudOrders)
				if(raid.z == 1 && raid.Owner == src)
					del raid
			d_rotatePlayer(TRUE)
		else if(PHASE=="March")		// @TODO
			for(var/obj/hudOrder/March/march in src.hudOrders)
				if(march.z == 1 && march.Owner == src)
					del march
			d_rotatePlayer(TRUE)
		else if(PHASE=="Muster")
			var/list/musterplaces = new/list()
			for(var/area/Territories/territory in src.territories)
				if(territory.Castle && !territory.mustered)
					musterplaces += territory
			var/area/Territories/musterTerritory = pick(musterplaces)
			if(musterTerritory)
				musterTerritory.mustered = 	musterTerritory.Castle			//@TODO: Actually muster

			d_rotatePlayer(TRUE)

		else if(PHASE=="ClashOfKings-IT")
			src.bid = rand(0,src.Influence-2)
			src.Influence -= src.bid
			src.bidlocked = TRUE
		else if(PHASE=="ClashOfKings-F")
			src.bid = rand(0,src.Influence-1)
			src.Influence -= src.bid
			src.bidlocked = TRUE
		else if(PHASE=="ClashOfKings-R")
			src.bid = rand(0,src.Influence)
			src.Influence -= src.bid
			src.bidlocked = TRUE
		else if(PHASE=="ClashOfKings-ITEnd")
			spawn(50) CoKCardF()
		else if(PHASE=="ClashOfKings-FEnd")
			spawn(50) CoKCardR()
		else if(PHASE=="ClashOfKings-REnd")
			spawn(50) CoKCardEnd()
		else if(PHASE=="WildlingAttack")
		//	src.bid = 2
			var/list/IronThrone = Tracks["IronThrone"]
			// Aim bid for wildling threat/number of players, but ensure not higher than Influence or WildlingThreat, and not below zero
			src.bid = max(0,min(round((WildlingThreat/IronThrone.len) + rand(-2,2),1), WildlingThreat, src.Influence))
			src.Influence -= src.bid
			src.bidlocked = TRUE

			for(var/mob/Player/others in Tracks["IronThrone"])
				if(!others.bidlocked)
					return 0
			wa_End()
		else if(PHASE=="WildlingAttackWin")
			sleep(10)
			WACARD.highestEffect()
		else if(PHASE=="WildlingAttackLoss")
			sleep(10)
			WACARD.lossEffect()
		else if(PHASE=="AKBTW-Win")
			var/obj/Scoreboard/Track/picked = pick(locate("IronThrone"), locate("Fiefdoms"), locate("Raven"))
			sleep(10)
			picked.beenClicked(src)
		else if(PHASE=="AKBTW-Loss")
			var/obj/Scoreboard/Track/picked = pick(locate("Fiefdoms"), locate("Raven"))
			sleep(10)
			picked.beenClicked(src)
		else if(PHASE=="PR-Won")
			if(Highest!=src)
				var/list/IronThrone = Tracks["IronThrone"]
				// Aim bid for wildling threat/number of players, but ensure not higher than Influence or WildlingThreat, and not below zero
				src.bid = max(0,min(round((WildlingThreat/IronThrone.len) + rand(-2,2),1), WildlingThreat, src.Influence))
				src.Influence -= src.bid
				src.bidlocked = TRUE

			for(var/mob/Player/others in Tracks["IronThrone"])
				if(!others.bidlocked && !others.Exempt)
					return 0
			sleep(10)
			wa_End()
		else if(PHASE=="BattleHC")
			var/obj/House_Cards/card = pick(src.HouseCards)
			card.beenClicked(src)
		else if(PHASE == "BattleRout")
			if(battle && battle.retreatSelecter == src)
				var/area/ter = pick(battle.territory.highlight)
				var/turf/WorldTurfs/picked = pick(ter.contents)
				picked.clicked(src)
		else if(PHASE == "Cards")
			if(CARD.hudchoices.len)
				var/obj/HUD/Choice/choice = pick(CARD.hudchoices)
				choice.beenClicked(src)

