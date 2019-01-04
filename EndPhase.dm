obj
	HUD
		EndPhase
			icon_state="EndPhase"
			click_state="EndPhaseClick"
			Click()

				src.icon_state = src.click_state		// Blink a clicked state
				spawn(1) src.icon_state = src.std_state

				var/mob/Player/player = usr
				if(player)
					if(PHASE == "Place Orders")

						d_resolveOrders()
					else if(PHASE == "Raven")
						var/obj/HUD/Dominance/Raven/raven = locate("Raventoken")
						if(player == raven.loc)
							PHASE = "Raid"
							d_startPhase()
					else if(PHASE == "Raid" && PlayerTurn == player && player.curOrder)
						del player.curOrder
						d_rotatePlayer(TRUE)
					else if(PHASE == "March" && PlayerTurn == player && player.curOrder)
						var/area/Territories/territory = player.curOrder.loc.loc
						if(player.curOrder.hasAttacked)
							var/npcBattleResult = npcBattle(player, player.curOrder.hasAttacked)
							if(!npcBattleResult)
								territory.destroyHUDOverlays()
								battle(player, player.curOrder.hasAttacked)
							else if(npcBattleResult==-1)
								return 0

						if(!locate(/obj/armyPiece) in territory)
							if(!locate(/obj/playPiece/Influence) in territory)
								player.territories -= territory
						territory.destroyHUDOverlays()
						del player.curOrder
						d_rotatePlayer(TRUE)
					else if(PHASE == "Muster" && PlayerTurn == player)
						if(player.castle)
							player.castle.destroyHUDOverlays()				// Remove the mustering overlay
							player.castle.mustered=player.castle.Castle		// Mark the area as finished mustering
							player.castle = null							// Remove the selection
							d_rotatePlayer(TRUE)
						else
							PlayerTurn << "Select a castle to skip mustering on."
					else if(PHASE=="ClashOfKings-IT")
						player.bidlocked = TRUE
						for(var/mob/Player/others in Tracks["IronThrone"])
							if(!others.bidlocked)
								player<<"[others] has not yet locked in their bid."
								return 0
						CoKCardITEnd()
					else if(PHASE=="ClashOfKings-ITEnd")
						if(swapper == player)
							CoKCardF()
					else if(PHASE=="ClashOfKings-F")
						player.bidlocked = TRUE
						for(var/mob/Player/others in Tracks["Fiefdoms"])
							if(!others.bidlocked)
								player<<"[others] has not yet locked in their bid."
								return 0
						CoKCardFEnd()
					else if(PHASE=="ClashOfKings-FEnd")
						if(swapper == player)
							CoKCardR()
					else if(PHASE=="ClashOfKings-R")
						player.bidlocked = TRUE
						for(var/mob/Player/others in Tracks["Raven"])
							if(!others.bidlocked)
								player<<"[others] has not yet locked in their bid."
								return 0
					else if(PHASE=="WildlingAttack")
						player.bidlocked = TRUE
						for(var/mob/Player/others in Tracks["IronThrone"])
							if(!others.bidlocked)
								player<<"[others] has not yet locked in their bid."
								return 0
						wa_End()
					else if(PHASE=="PR-Won")		// A wildling attack that the previous highest bidder does not have to participate in
						player.bidlocked = TRUE
						for(var/mob/Player/others in Tracks["IronThrone"])
							if(!others.bidlocked && Highest!=others)
								player<<"[others] has not yet locked in their bid."
								return 0
						wa_End()
					else if(findtext(PHASE,"CK-Won") && PlayerTurn==player)
						if(player.client)
							player.client.mouse_pointer_icon = null
						c_endCardPhase()
					else if(findtext(PHASE,"CK-Loss") && PlayerTurn==player)
						var/obj/armyPiece/Cavalry/remainingPiece = locate(/obj/armyPiece/Cavalry) in player.armyPieces
						if(remainingPiece)
							player<<"You still have a cavalry unit in [remainingPiece.loc.loc]"
						else
							c_endCardPhase()
					else if(PHASE=="PR-Loss" && PlayerTurn==player)
						var/list/highestTracks = returnHighestTracks(player)
						var/list/tempList
						var/pickedTrack, pos
						if(highestTracks.len>1)
							pickedTrack = input(player,"Select a track to drop two places in.", "Preemptive Raid - Lowest Bidder")\
								in highestTracks
						else
							pickedTrack = highestTracks[1]
						tempList = Tracks[pickedTrack]
						pos = tempList.Find(player)
						pos+=2
						if(pos>tempList.len)
							pos=tempList.len
						tempList.Remove(player)
						tempList.Insert(pos,player)
						c_endCardPhase()	//@TODO CHECK - maybe finished?
					else if(PHASE=="BattleBlade")
						var/obj/sword = locate("Fiefdomstoken")
						if(sword.loc == player)
							battle_determineWinner()