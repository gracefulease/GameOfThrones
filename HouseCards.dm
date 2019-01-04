proc
	showHouseCards(var/mob/Player/player,var/mob/Player/enemy)
		if(player.client)
			if(winget(player, "houseCards", "is-visible")=="true")
				winshow(player,"houseCards",0)
			else
				if(!enemy)
					winset(player, "houseCards", "size=640x260")
				else
					winset(player, "houseCards", "size=640x530")
					for(var/i = 1; i<=enemy.HouseCards.len; i++)
						var/obj/House_Cards/card = enemy.HouseCards[i]
						if(!card.SNSIcon) swordsNShields(card)
						usr << output(card, "enemyHouse:1,[i]")
						usr << output(card.Strength, "enemyHouse:2,[i]")
						usr << output("<BIG>\icon[card.SNSIcon]</BIG>", "enemyHouse:3,[i]")
						usr << output(card.desc, "enemyHouse:4,[i]")
				for(var/i = 1; i<=player.HouseCards.len; i++)
					var/obj/House_Cards/card = player.HouseCards[i]
					if(!card.SNSIcon) swordsNShields(card)
					usr << output(card, "myHouse:1,[i]")
					usr << output(card.Strength, "myHouse:2,[i]")
					usr << output("<BIG>\icon[card.SNSIcon]</BIG>", "myHouse:3,[i]")
					usr << output(card.desc, "myHouse:4,[i]")
				winshow(player,"houseCards",1)

	closeHouseCards(var/mob/Player/player)
		if(player.client)
			if(winget(player, "houseCards", "is-visible")=="true")
				winshow(player,"houseCards",0)

proc
	swordsNShields(var/obj/House_Cards/card)	// If ever stuck again: http://www.byond.com/forum/?post=2225068
		var/icon/I = icon('blank.dmi')  // Just a blank .dmi file with one blank icon in it.
		var/num_Swords = card.Swords
		var/num_Shields = card.Shields
		var/icon/Sword = icon('HUD.dmi',"Sword")
		var/icon/Shield = icon('HUD.dmi', "Shield")

		if(!num_Swords && !num_Shields)
			card.SNSIcon = I
			return 0

		var/width = 32 + (num_Swords + num_Shields -1)*SWORDWIDTH
		I.Scale(width,32)
		for(var/i in 1 to num_Swords)
			I.Blend(Sword, ICON_OVERLAY)
			if((i<num_Swords))
				I.Shift(EAST, SWORDWIDTH)
			else if(num_Shields)
				I.Shift(EAST, SHIELDWIDTH)
		for(var/i in 1 to num_Shields)
			I.Blend(Shield, ICON_UNDERLAY)
			if(i<num_Shields)
				I.Shift(EAST, SHIELDWIDTH)
		card.SNSIcon = I


obj
	House_Cards
		var
			House = ""
			Strength = 0
			Swords = 0
			Shields = 0
			mob/Player/Owner
			icon/SNSIcon
			used = FALSE
		Click()
			beenClicked(usr)
		proc
			effect()
				src.used = TRUE								// If no effect count the card as "used"
			winEffect()
				src.used = TRUE
			lossEffect()
				src.used = TRUE
			beenClicked(var/mob/Player/clicker)
				if(PHASE == "BattleHC" && Owner == clicker)
					battle.houseCards[clicker] = src
					Owner.HouseCards -= src
					Owner.DiscardPile += src
					for(var/enemy in battle.houseCards)		// If our enemy has picked as well, move onto the next stage
						if(enemy != clicker)
							closeHouseCards(clicker)
							battle_HouseCardsActivate()
		New()
			..()

		Stark
			House = "Stark"
			icon = 'Stark.dmi'
			New()
				..()
				icon_state = name
			Eddard
				name = "Eddard Stark"
				Strength = 4
				Swords = 2
			Robb
				name = "Robb Stark"
				Strength = 3
				desc = "On winning, decide where the routing units go."
				winEffect()
					//@TODO - pick where retreater goes
					var/list/ownerFlags = new/list()
					if(battle.flags[Owner])
						ownerFlags = battle.flags[Owner]
					ownerFlags.Add("pick_retreat")
					battle.flags[Owner]=ownerFlags
					.=..()
			Roose
				name = "Roose Bolton"
				Strength = 2
				desc = "On winning, return all House cards to your hand."
				winEffect()
					src.Owner.HouseCards += src.Owner.DiscardPile
					src.Owner.DiscardPile.len=0
			Greatjon
				name = "Greatjon Umber"
				Strength = 2
				Swords = 1
			Rodrick
				name = "Ser Rodrick Cassel"
				Strength = 1
				Shields = 2
			Blackfish
				name = "The Blackfish"
				Strength = 1
				desc = "Take no casulaties from House cards, combat icons, or Tides of Battle."
				effect()
					var/list/ownerFlags = new/list()
					if(battle.flags[Owner])
						ownerFlags = battle.flags[Owner]
					ownerFlags.Add("no_casualties")
					battle.flags[Owner]=ownerFlags
					.=..()

			Cat
				name = "Catelyn Stark"
				Strength = 0
				desc = "Double the defense order in this territory."
				effect()
					var/obj/hudOrder/defOrder = locate(/obj/hudOrder/) in battle.territory
					if(istype(defOrder, /obj/hudOrder/Defend) && defOrder.Owner == src.Owner)
						battle.combatants[defOrder.Owner] += defOrder.bonus
						updateBattleScores()
						bounce(defOrder)
					.=..()
		Baratheon
			House = "Baratheon"
			icon = 'Baratheon.dmi'
			New()
				..()
				icon_state = name
			Stannis
				name = "Stannis Baratheon"
				Strength = 4
				desc = "If your enemy is above you on the Iron Throne gain 1 Strength."
				effect()
					for(var/mob/player in battle.combatants)
						if(player != src.Owner)
							var/list/IronThrone = Tracks["IronThrone"]
							if(IronThrone.Find(player) < IronThrone.Find(src.Owner))
								battle.combatants[src.Owner]++
								updateBattleScores()
							break
					.=..()
			Renly
				name = "Renly Baratheon"
				Strength = 3
				desc = "If you win upgrade an infantry piece to cavalry."
				winEffect()
					Owner << "Click on an infantry piece to upgrade it to cavalry."
					if(src.Owner.client)
						src.Owner.client.mouse_pointer_icon = icon('mouseIcons.dmi',"upgrade")
					//@TODO - if win, upgrade a footman to knight
					used = FALSE
			Davos
				name = "Ser Davos Seaworth"
				Strength = 2
				desc = "If Stannis Baratheon is in the discard pile, gain 1 Strength and 1 Sword."
				effect()
					if(locate(/obj/House_Cards/Baratheon/Stannis) in Owner.DiscardPile)
						battle.combatants[Owner]++
						battle.swords[Owner]++
					.=..()
			Brienne
				name = "Brienne of Tarth"
				Strength = 2
				Swords = 1
				Shields = 1
			Sallador
				name = "Sallador Saan"
				Strength = 1
				desc = "If you are supported, all non-Baratheon ships have a strength of zero."
				effect()
					var/list/ownerFlags = battle.flags[Owner]
					if(ownerFlags.Find("supported"))
						for(var/obj/armyPiece/Ship/piece in battle.pieces)
							if(piece.Owner != src.Owner)
								bounce(piece)
								var/receiver = battle.pieces[piece]
								battle.combatants[receiver] -= piece.tempStrength
								piece.tempStrength = 0
					.=..()
			Melisandre
				name = "Melisandre"
				Strength = 1
				Swords = 1
			Patchface
				name = "Patchface"
				Strength = 0
				desc = "After combat you may discard one of your opponent's cards."
				winEffect()
					lossEffect()
				lossEffect()
					src.used = FALSE
					for(var/mob/Player/other in battle.houseCards - src.Owner)
						var/choice = pick(other.HouseCards)
						choice = input(src.Owner,"Select a card to discard from [other]'s hand.","[src.name]", choice) in list(other.HouseCards + "None")
						if(choice != "None")
							other.DiscardPile += choice
							other.HouseCards -= choice
							world<<"[src.Owner] has elected to discard [choice] from [other]'s hand."
						else
							world<<"[src.Owner] has elected not to discard a card from [other]'s hand."
					.=..()
		Greyjoy
			House = "Greyjoy"
			icon = 'Greyjoy.dmi'
			New()
				..()
				icon_state = name
			Euron
				name = "Euron Crow's Eye"
				Strength = 4
				Swords = 1
			Victarion
				name = "Victarion Greyjoy"
				Strength = 3
				desc = "If you are attacking all Greyjoy ships have double strength."
				effect()
					if(battle.attDef["attacker"]==src.Owner)
						for(var/obj/armyPiece/Ship/piece in battle.pieces)
							if(piece.Owner == src.Owner)
								bounce(piece)
								battle.combatants[piece.Owner] -= piece.tempStrength
								piece.tempStrength *= 2
								battle.combatants[piece.Owner] += piece.tempStrength
					.=..()

			Balon
				name = "Balon Greyjoy"
				Strength = 2
				desc = "The combat strength of the enemy house card is reduced to zero."
				effect()
					for(var/obj/House_Cards/card in battle.houseCards)
						if(card.Owner != src.Owner)
							battle.combatants[card.Owner]-=card.Strength
					.=..()
			Theon
				name = "Theon Greyjoy"
				Strength = 2
				desc = "If defending a castle gain 1 Strength and 1 Sword."
				effect()
					if(battle.territory.Castle && battle.attDef["defender"] == src.Owner)
						battle.combatants[src.Owner]++
						battle.swords[src.Owner]++
					.=..()

			Dagmar
				name = "Dagmar Cleftjaw"
				Strength = 1
				Swords = 1
				Shields = 1
			Asha
				name = "Asha Greyjoy"
				Strength = 1
				desc = "If not supported gain 2 Swords and 1 Shield."
				effect()
					var/list/ownerFlags = battle.flags[Owner]
					if(ownerFlags && ownerFlags.Find("supported"))
						return 0
					battle.swords[src.Owner]+=2
					battle.shields[src.Owner]+=1
					.=..()
			Aeron
				name = "Aeron Damphair"
				Strength = 0

		Lannister
			House = "Lannister"
			icon = 'Lannister.dmi'
			New()
				..()
				icon_state = name
			Tywin
				name = "Tywin Lannister"
				Strength = 4
				Swords = 0
				winEffect()
					src.Owner.Influence += 2
					h_influenceChange()
			Gregor
				name = "Ser Gregor Clegane"
				Strength = 3
				Swords = 3
			Jaime
				name = "Jaime Lannister"
				Strength = 2
				Swords = 1
			Hound
				name = "The Hound"
				Strength = 2
				Shields = 2
			Kevan
				name = "Ser Kevan Lannister"
				Strength = 1
				desc = "If attacking, all Lannister Infantry have 2 Strength."
				effect()
					if(battle.attDef["attacker"] == src.Owner)
						for(var/obj/armyPiece/Infantry/piece in battle.pieces)
							if(piece.Owner == src.Owner)
								bounce(piece)
								battle.combatants[piece.Owner] -= piece.tempStrength
								piece.tempStrength = 2
								battle.combatants[piece.Owner] += piece.tempStrength
					.=..()
			Tyrion
				name = "Tyrion Lannister"
				Strength = 1
				desc = "You may force your opponent to select a different house card. If your opponent has no other house cards in hand then they must fight without one."
				effect()
					if(!battle.bannedCard)	//As the bulk is done in battle_continued(), now put the banned card back in your opponents hand to clean up
						return 0
					for(var/mob/Player/enemy in battle.combatants)
						if(enemy != src.Owner &&  battle.bannedCard.Owner == enemy)
							enemy.DiscardPile -= battle.bannedCard
							enemy.HouseCards += battle.bannedCard
							battle.bannedCard = null
					.=..()

			Cersei
				name = "Cersei Lannister"
				Strength = 0
				desc = "If you win, remove one enemy order token from board."
				winEffect()
					used = FALSE
					world<<"[src.Owner] may remove any one enemy order token from the board."

		Martell
			House = "Martell"
			icon = 'Martell.dmi'
			New()
				..()
				icon_state = name
			Viper
				name = "The Red Viper"
				Strength = 4
				Swords = 2
				Shields = 1
			Areo
				name = "Areo Hotah"
				Strength = 3
				Shields = 1
			Darkstar
				name = "Darkstar"
				Strength = 2
				Swords = 1
			Obara
				name = "Obara Sand"
				Strength = 2
				Shields = 1
			Arianne
				name = "Arianne Martell"
				Strength = 1
				lossEffect()
					if(battle.attDef["defender"] == src.Owner)
						var/list/ownerFlags = new/list()
						if(battle.flags[battle.attDef["attacker"]])
							ownerFlags = battle.attDef["attacker"]
						ownerFlags.Add("cannot_seize")
						battle.flags[battle.attDef["attacker"]]=ownerFlags
					.=..()
					//@TODO - if defending and lose, opponent cannot take won land
			Nymeria
				name = "Nymeria Sand"
				Strength = 1
				effect()
					if(src.Owner.territories.Find(battle.territory))
						battle.shields[src.Owner]++
					else if(!src.Owner.territories.Find(battle.territory))
						battle.swords[src.Owner]++
					.=..()
			Doran
				name = "Doran Martell"
				Strength = 0
				effect()
					used = FALSE

		Tyrell
			House = "Tyrell"
			icon = 'Tyrell.dmi'
			New()
				..()
				icon_state = name
			Mace
				name = "Mace Tyrell"
				Strength = 4
				desc = "Immediately destroy one enemy Infantry."
				effect()
					used = FALSE
					if(src.Owner.client)
						src.Owner.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")
			Loras
				name = "Ser Loras Tyrell"
				Strength = 3
				winEffect()
					var/mob/Player/attacker = battle.attDef["attacker"]
					if(battle.attDef["attacker"] == src.Owner)
						bounce(attacker.curOrder)
						attacker.curOrder.loc = pick(battle.territory.contents)
						bounce(attacker.curOrder)
						attacker.curOrder = null
					.=..()
			Randyll
				name = "Randyll Tarly"
				Strength = 2
				Swords = 1
			Garlan
				name = "Ser Garlan Tyrell"
				Strength = 2
				Swords = 2
			Margaery
				name = "Margaery Tyrell"
				Strength = 1
				Shields = 1
			Alester
				name = "Alester Florent"
				Strength = 1
				Shields = 1
			Queen
				name = "Queen Of Thorns"
				Strength = 0
				effect()
					used = FALSE
					if(src.Owner.client)
						src.Owner.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")


proc
	SortByStrength(var/list/l)
		var i, j, num = l.len
		for(i=0,i < num, i++)
			for(j=1, j < (num - i), j++)
				var/obj/House_Cards/A = l[j]
				var/obj/House_Cards/B = l[j+1]
				if(A.Strength < B.Strength)
					l[j] = B
					l[j + 1] = A
