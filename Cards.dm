obj/HUD
	Cards
		icon = 'Cards.dmi'
		layer = CARDS_LAYER
		var
			deck = 0 // = 1 or 2 or 3
			wildlingThreat = FALSE
			list/hudchoices
			list/hudtext
		TitleText
			icon = null
			icon_state = "null"
			maptext_height= 128
			maptext_width = 128
		BlankCards
			I
				icon_state = "I"
				screen_loc = "cmap:1,1"
			II
				icon_state = "II"
				screen_loc = "cmap:5,1"
			III
				icon_state = "III"
				screen_loc = "cmap:9,1"
		Supply
			name = "Supply"
			desc = "In Order of Play, all players resupply and reconcile their armies to meet their supply limit."
			deck = 1
			effect()
				h_updateSupply()
				for(var/mob/Player/player in Tracks["IronThrone"])
					h_updateSupplyAndVictoryTracks(player)
					world<<"[player] now has [player.Supply] supply."
				PHASE="Reconcile Supply"
				d_assignPlayerTurn(Tracks["IronThrone"])

		Muster
			name = "Muster"
			desc = "In Order of Play, players muster new units from their cities and strongholds. New units must conform to a player’s Supply limits."
			deck = 1
			effect()
				world<<"Click on one of your castles to select a place to muster."
				PHASE="Muster"
				PlayerTurn= null
				d_startPhase()
				if(PlayerTurn.client)
					winshow(PlayerTurn,"armyPieces",1)

		LastDaysOfSummer1
			name = "Last Days Of Summer"
			desc = "Nothing happens."
			deck = 1
			wildlingThreat = TRUE
			effect()
				sleep(10)
				c_pickCards()

		LastDaysOfSummer2
			name = "Last Days Of Summer"
			desc = "Nothing happens."
			deck = 2
			wildlingThreat = TRUE
			effect()
				c_pickCards()

		ClashOfKings
			name = "Clash Of Kings"
			desc = "Bid on the Areas of Influence."
			deck = 2
			effect()
				PHASE="ClashOfKings"
				CoKCard()
		GameOfThrones
			name = "Game Of Thrones"
			desc = "In Order of Play, each player collects one influence for every port and every influence icon in areas they control."
			deck = 2
			effect()
				for(var/mob/Player/player in Tracks["IronThrone"])
					var/total = 0
					var/area/Territories/portNeighbour
					for(var/area/Territories/t in player.territories)
						total += t.Power
						if(t.isPort)
							// If t is a port check its neighbour (ports only have one) to ensure it isn't owned by another player
							portNeighbour = t.neighbours[1]
							if(!portNeighbour)
								world<<"Error, [t] is a port and has no neighbour."
								return

							for(var/mob/Player/others in Tracks["IronThrone"])
								if(others==player)
									continue
								for(var/area/Territories/a in others.territories)
									if(a == portNeighbour)
										portNeighbour = null
										break
								if(!portNeighbour)
									break

							if(portNeighbour)	// No player's owned the port neighbour so give the man some power
								total++
					player.Influence += total
					world<<"[player] gained [total] influence."
				sleep(10)
				c_pickCards()
		DarkWings
			name = "Dark Wings, Dark Words"
			desc = "The holder of the Raven token must choose one of the following:\n\
				1) All players must bid for position on the Influence Tracks\n\
				2) All players collect Power tokens for each power icon on the game board\n\
				3) Nothing happens."
			deck = 2
			wildlingThreat = TRUE
			effect()
				hudchoices = new/list()
				var/obj/HUD/Dominance/Raven/raven = locate("Raventoken")
				var/mob/Player/choser = raven.loc

				var/obj/HUD/Choice/choice1 = new(null, choser.client, list(icon_state="ravenChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=3.5*TILE_HEIGHT), 1)
				choice1.maptext = "<span style=font-size:xx-small>All players must bid for position on the Influence Tracks.</span>"
				choice1.targetCard = /obj/HUD/Cards/ClashOfKings
				var/obj/HUD/Choice/choice2 = new(null, choser.client, list(icon_state="ravenChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=1*TILE_HEIGHT), 1)
				choice2.maptext = "<span style=font-size:xx-small>All players collect Power tokens for each power icon on the game board and unblocked port.</span>"
				choice2.targetCard = /obj/HUD/Cards/GameOfThrones
				var/obj/HUD/Choice/choice3 = new(null, choser.client, list(icon_state="ravenChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=-1.5*TILE_HEIGHT), 1)
				choice3.maptext = "<span style=font-size:xx-small>Nothing happens.</span>"
				choice3.targetCard = /obj/HUD/Cards/LastDaysOfSummer1
				hudchoices += list(choice1, choice2, choice3)
				for(var/obj/HUD/Choice/c in hudchoices)
					c.choser = choser
					c.parentCard = src
				if(!choser.client)
					choser.AI()

		SeaOfStorms
			name = "Sea Of Storms"
			desc = "Players may not place Raids this turn."
			deck = 3
			wildlingThreat = TRUE
			effect()
				Restraints["canRaid"] = FALSE
				sleep(10)
				c_pickCards()

		FeastForCrows
			name = "Feast For Crows"
			desc = "Players may not place Consolidates this turn."
			deck = 3
			wildlingThreat = TRUE
			effect()
				Restraints["canConsolidate"] = FALSE
				sleep(10)
				c_pickCards()
		StormOfSwords
			name = "Storm Of Swords"
			desc = "Players may not place Defends this turn."
			deck = 3
			wildlingThreat = TRUE
			effect()
				Restraints["canDefend"] = FALSE
				sleep(10)
				c_pickCards()
		RainsOfAutumn
			name = "Rains of Autumn"
			desc = "Players may not place March +1 tokens this turn."
			deck = 3
			wildlingThreat = TRUE
			effect()
				Restraints["canMarch+1"] = FALSE
				sleep(10)
				c_pickCards()
		WebOfLies
			name = "Web Of Lies"
			desc = "Players may no place Supports this turn."
			deck = 3
			wildlingThreat = TRUE
			effect()
				Restraints["canSupport"] = FALSE
				sleep(10)
				c_pickCards()

		AThroneOfBlades
			name = "A Throne of Blades"
			desc = "The holder of the Iron Throne token must choose one of the following:\n\
				1) All players muster\n\
				2) All players update their supply\n\
				3) Nothing happens."
			deck = 1
			wildlingThreat = TRUE
			effect()
				hudchoices = new/list()
				var/obj/HUD/Dominance/IronThrone/throne = locate("IronThronetoken")
				var/mob/Player/choser = throne.loc
				var/obj/HUD/Choice/choice1 = new(null, choser.client, list(icon_state="throneChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=3.5*TILE_HEIGHT), 1)
				choice1.maptext = "<span style=font-size:xx-small>All players muster.</span>"
				choice1.targetCard = /obj/HUD/Cards/Muster
				var/obj/HUD/Choice/choice2 = new(null, choser.client, list(icon_state="throneChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=1*TILE_HEIGHT), 1)
				choice2.maptext = "<span style=font-size:xx-small>All players update and reconcile their supply.</span>"
				choice2.targetCard = /obj/HUD/Cards/Supply
				var/obj/HUD/Choice/choice3 = new(null, choser.client, list(icon_state="throneChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=-1.5*TILE_HEIGHT), 1)
				choice3.maptext = "<span style=font-size:xx-small>Nothing happens.</span>"
				choice3.targetCard = /obj/HUD/Cards/LastDaysOfSummer1
				hudchoices+= list(choice1, choice2, choice3)
				for(var/obj/HUD/Choice/c in hudchoices)
					c.choser = choser
					c.parentCard = src
				if(!choser.client)
					choser.AI()
		PutToTheSword
			name = "Put To The Sword"
			desc = "The holder of the Fiefdoms token must choose one of the following:\n\
				1) Players cannot use their March +1 order this coming turn\n\
				2) Players cannot use Defense orders this coming turn\n\
				3) Nothing happens."
			deck = 3
			wildlingThreat = TRUE
			effect()
				hudchoices = new/list()
				var/obj/HUD/Dominance/Fiefdoms/fief = locate("Fiefdomstoken")
				var/mob/Player/choser = fief.loc
				var/obj/HUD/Choice/choice1 = new(null, choser.client, list(icon_state="swordChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=3.5*TILE_HEIGHT), 1)
				choice1.maptext = "<span style=font-size:xx-small>Players cannot use their March +1 order this coming turn.</span>"
				choice1.targetCard = /obj/HUD/Cards/RainsOfAutumn
				var/obj/HUD/Choice/choice2 = new(null, choser.client, list(icon_state="swordChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=1*TILE_HEIGHT), 1)
				choice2.maptext = "<span style=font-size:xx-small>Players cannot use Defense orders this coming turn.</span>"
				choice2.targetCard = /obj/HUD/Cards/StormOfSwords
				var/obj/HUD/Choice/choice3 = new(null, choser.client, list(icon_state="swordChoice",anchor_x="CENTER", anchor_y="CENTER", screen_y=-1.5*TILE_HEIGHT), 1)
				choice3.maptext = "<span style=font-size:xx-small>Nothing happens.</span>"
				choice3.targetCard = /obj/HUD/Cards/LastDaysOfSummer1
				hudchoices+= list(choice1, choice2, choice3)
				for(var/obj/HUD/Choice/c in hudchoices)
					c.choser = choser
					c.parentCard = src
				if(!choser.client)
					choser.AI()


		WildlingAttack
			name = "Wildling Attack"
			desc = "The Wildings attack Westeros with their current strength."
			deck = 3

			effect()
				PHASE="WildlingAttack"
				wa_Start()
		Close
			icon_state = "Close"
			layer = CARDS_LAYER+1
			var/list/attached = new/list()
			Click()
				for(var/obj/HUD/o in attached)
					o.hide()
				src.hide()

		New()
			..()
			if(!icon_state)
				icon_state = "[name]"
			name = "<span style=font-size:5px>[name]</span>"
		proc
			effect()
		MouseEntered()
			hudtext = new/list()
			c_cardText(src)

		MouseExited()
			for(var/obj/HUD/hud in hudtext)
				spawn() animate(hud, alpha = 0, time = 5)
			sleep(5)
			for(var/obj/HUD/hud in hudtext)
				hud.hide()
				hudtext-=hud

	Choice
		icon='Cards.dmi'
		anchor_x="CENTER"
		anchor_y="CENTER"
		maptext_height = 64
		maptext_width = 128
		maptext_x = 2
		maptext_y = 2
		var
			obj/HUD/Cards/targetCard
			mob/Player/choser
			obj/HUD/Cards/parentCard
		Click()
			beenClicked(usr)
		proc
			beenClicked(var/mob/Player/player)
				if(player!=choser)
					world<<"Error: [player] is not choser [choser]"
					return 0
				if(!targetCard)
					world<<"Error: [src] has no targetCard."
					return 0
				if(parentCard)
					for(var/obj/HUD/Choice/choices in parentCard.hudchoices)
						choices.hide()
				var/obj/HUD/Cards/card = new targetCard
				world<<"[player] picked [card]"
				card.effect()
	CardTitle
		icon='Cards.dmi'
		icon_state="Title"
		anchor_x="CENTER"
		anchor_y="CENTER"
		maptext_height = 16
		maptext_width = 128
		maptext_x = 6
		maptext_y = 0
	CardText
		anchor_x="CENTER"
		anchor_y="CENTER"
		maptext_height = 60
		maptext_width = 120
		maptext_x = 5
		maptext_y = 2



proc
	c_fillCards()
		for(var/mob/Player/player in Tracks["IronThrone"])
			if(player.client)
				var/obj/HUD/Cards/TitleText/t1 = new()
				var/obj/HUD/Cards/TitleText/t2 = new()
				var/obj/HUD/Cards/TitleText/t3 = new()
				var/obj/HUD/Cards/BlankCards/I/I = new()
				var/obj/HUD/Cards/BlankCards/II/II = new()
				var/obj/HUD/Cards/BlankCards/III/III = new()
				var/list/screen_items = list(t1,t2,t3,I,II,III)
				t1.screen_loc = "cmap:1,3"
				t2.screen_loc = "cmap:5,3"
				t3.screen_loc = "cmap:9,3"
				h_addToScreen(player.client, screen_items)

	c_pickCards()
		PHASE = "Cards"
		var/list/cardList
		var/cardtype
		if(!CARD)			// If no card has been picked, pick from Deck 1
			cardList = list(/obj/HUD/Cards/Supply,\
				/obj/HUD/Cards/Muster,\
				/obj/HUD/Cards/LastDaysOfSummer1,\
				/obj/HUD/Cards/AThroneOfBlades)
		else if (CARD.deck==1)
			cardList = list(/obj/HUD/Cards/ClashOfKings,\
				/obj/HUD/Cards/GameOfThrones,\
				/obj/HUD/Cards/LastDaysOfSummer2,\
				/obj/HUD/Cards/DarkWings)
			cardList = list(/obj/HUD/Cards/ClashOfKings)
		else if (CARD.deck==2)
			cardList = list(/obj/HUD/Cards/WildlingAttack,\
			/obj/HUD/Cards/RainsOfAutumn,\
			/obj/HUD/Cards/StormOfSwords,\
			/obj/HUD/Cards/SeaOfStorms,\
			/obj/HUD/Cards/FeastForCrows,\
			/obj/HUD/Cards/WebOfLies,\
			/obj/HUD/Cards/PutToTheSword)
		else if (CARD.deck==3)	// Cards are finished
			CARD = null
			d_startTurn()
			for(var/obj/HUD/hud in cardsHUD)
				hud.hide()
				cardsHUD -= hud
			return 0

		cardtype = pick(cardList)
		var/obj/HUD/Cards/picked = new cardtype()
		var/obj/HUD/Cards/hud
		for(var/mob/Player/player in Tracks["IronThrone"])
			if(!player.client)
				continue
			hud = new cardtype(null, player.client, list(anchor_x="CENTER", anchor_y="CENTER", screen_x = (CARDS_X + ((picked.deck-1)*CARD_WIDTH))*TILE_HEIGHT, screen_y=CARDS_Y*TILE_HEIGHT), 1)
			hud.alpha = 200
			cardsHUD += hud
			hud = new /obj/HUD/CardTitle(null, player.client, list(maptext = picked.name, screen_x = (CARDS_X + ((picked.deck-1)*CARD_WIDTH))*TILE_HEIGHT, screen_y=((CARDS_Y+2)*TILE_HEIGHT)-1), 1)
			cardsHUD += hud
		if(picked.wildlingThreat)
			if(WildlingThreat<12)
				WildlingThreat += 2
				bounce(locate("waToken"))
				bounceslide(locate("waToken"))
			else
				PHASE="WildlingAttack"
				wa_Start()


		CARD = picked
		CARD.effect()


	c_endCardPhase()
		sleep(10)
		CARD = null
		WACARD = null
		for(var/mob/Player/player in Tracks["IronThrone"])
			player.Exempt = FALSE
			if(player.client)
				for(var/obj/WA/hudItem in player.client.screen)
					player.client.screen-=hudItem
		var/obj/Scoreboard/Track/IronThrone/throne 	= locate("IronThrone")
		for(var/obj/Scoreboard/PlayerToken/token in throne.Tokens)
			token.maptext=""
		d_startTurn()

	c_cardText(var/obj/HUD/Cards/source)
		var/tmp/pixel_x_offset = TEXT_OFFSET_X, pixel_y_offset = 0
		var/obj/HUD/Cards/hud
		var/text = source.desc
		var/height = max(64,round(c_calcHeight(text),2))
		var/halfHeight = height/2
		hud = new /obj/HUD/CardText(null, usr.client, list(icon='Cards.dmi', icon_state="TextMain", layer = HUD_LAYER, screen_x = source.screen_x, screen_y= (source.screen_y+2)-halfHeight-TILE_HEIGHT), 1)
		var/matrix/textM = matrix()
		textM.Scale(1,height/64)
		hud.transform = textM
		hud.alpha = 0
		source.hudtext+=hud

		hud = new /obj/HUD/CardText(null, usr.client, list(layer = HUD_LAYER, screen_x = source.screen_x, screen_y= (source.screen_y+2)-halfHeight-TILE_HEIGHT), 1)
		hud.alpha = 0
		source.hudtext+=hud
		var/char_pos = 1
		var/char_len = length(text)
		var/T
		var/list/word = new/list()
		var/image/I
		while(char_pos < char_len+1)
			T = copytext(text,char_pos,char_pos+1)
			if(T == "\n")
				pixel_x_offset=TEXT_OFFSET_X
				pixel_y_offset+=TEXT_OFFSET_Y
				char_pos ++
				continue
			pixel_x_offset += font.metrics[(text2ascii(T)-29)][1]
			I = image('Font1.dmi',hud,"[T]",22)
			I.pixel_x += pixel_x_offset
			I.pixel_y = halfHeight-pixel_y_offset
			I.mouse_opacity = 0
			if(T == " ")
				word=new/list()
			else
				word += I
			world<<I
			pixel_x_offset += font.metrics[(text2ascii(T)-29)][2] + font.metrics[(text2ascii(T)-29)][3]

			if(pixel_x_offset >= 122)
				pixel_x_offset = TEXT_OFFSET_X
				pixel_y_offset += TEXT_OFFSET_Y

				if(word)
					for(var/image/temp in word)
						temp.pixel_y = halfHeight-pixel_y_offset
						pixel_x_offset += font.metrics[(text2ascii(temp.icon_state)-29)][1]
						temp.pixel_x = pixel_x_offset
						pixel_x_offset += font.metrics[(text2ascii(temp.icon_state)-29)][2] + font.metrics[(text2ascii(temp.icon_state)-29)][3]
			char_pos += 1

		hud = new /obj/HUD/CardText(null, usr.client, list(icon='Cards.dmi', icon_state="TextBottom", layer = HUD_LAYER, screen_x = source.screen_x, screen_y= (source.screen_y)-height), 1)
		hud.alpha = 0
		source.hudtext+=hud

		for(var/obj/appear in source.hudtext)
			animate(appear, alpha = 255, time = 5)


	c_calcHeight(var/text)
		var/char_pos = 1
		var/char_len = length(text)
		var/height = TEXT_OFFSET_Y
		var/x = TEXT_OFFSET_X
		var/list/word = new/list()
		while(char_pos < char_len+1)
			var/T = copytext(text,char_pos,char_pos+1)
			if(T == "\n")
				x=TEXT_OFFSET_X
				height+=13
				char_pos ++
				continue
			x += font.metrics[(text2ascii(T)-29)][1] + font.metrics[(text2ascii(T)-29)][2] + font.metrics[(text2ascii(T)-29)][3]
			if(T == " ")
				word=new/list()
			else
				word += T
			if(x >= 122)
				x = TEXT_OFFSET_X
				height += TEXT_OFFSET_Y
				if(word)
					for(var/temp in word)
						x += font.metrics[(text2ascii(temp)-29)][1] + font.metrics[(text2ascii(temp)-29)][2] + font.metrics[(text2ascii(temp)-29)][3]
			char_pos++
		return height

	SortByBids(var/list/l)
		var i, j, num = l.len
		for(i=0,i < num, i++)
			for(j=1, j < (num - i), j++)
				var/mob/Player/A = l[j]
				var/mob/Player/B = l[j+1]
				if(A.bid < B.bid)
					l[j] = B
					l[j + 1] = A