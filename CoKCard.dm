proc
	CoKCard()
		var/obj/WA/Slot/s = new()
		var/obj/WA/Up/u = new()
		var/obj/WA/Down/d = new()

		for(var/mob/Player/player in Tracks["IronThrone"])

			player.bid = 0
			g_bidChange(player)
			if(player.client)
				var/count = 1
				var/list/tempList = Tracks["IronThrone"]
				for(var/i = 1; i <= tempList.len; i++)
					var/mob/Player/other = Tracks["IronThrone"][i]
					if(other&&other!=player)
						new /obj/HUD/Influence(null, player.client, list(icon = houseIconLookup(other.House), owner = other, anchor_x="CENTER", anchor_y="CENTER", screen_x=(-1*TILE_WIDTH), screen_y=count*TILE_WIDTH, layer=HUD_LAYER),1)
						new /obj/HUD(null, player.client, list(maptext = "[other.Influence]", anchor_x="CENTER", anchor_y="CENTER", screen_x=0, screen_y=count*TILE_WIDTH, layer=HUD_LAYER),1)
						count++
					var/obj/WA/Bidslot/bid = new()
					bid.screen_loc="scoreboard:[i+1],4"
					player.client.screen+=bid


				player.client.screen+=s
				player.client.screen+=u
				player.client.screen+=d
		CoKCardIT()

	CoKCardIT()
		PHASE="ClashOfKings-IT"
		var/obj/WA/Track/IronThrone/IT = new()
		var/obj/WA/Track/IronThrone/ITsb = new()
		ITsb.screen_loc="scoreboard:1,4"
		for(var/mob/Player/player in Tracks["IronThrone"])
			if(player.client)
				player.client.screen+=IT
				// Add "bids" track above the Tracks on 'scoreboard'
				player.client.screen+=ITsb
			else
				player.AI()

		world<<"Please bid on the Iron Throne track."


	CoKCardITEnd()
		PHASE="ClashOfKings-ITEnd"
		swapper = Tracks["IronThrone"][1]

		var/list/tempList = Tracks["IronThrone"]
		if(!tempList.len) return
		SortByBids(Tracks["IronThrone"])

		s_updateScoreboard()
		var/obj/Scoreboard/Track/IronThrone/throne 	= locate("IronThrone")
		for(var/obj/Scoreboard/PlayerToken/token in throne.Tokens)
			token.maptext="<b>[token.Owner.bid]</b>"
			token.maptext_y = 36

		var/equalBidders = FALSE
		for(var/mob/Player/p in Tracks["IronThrone"])
			for(var/mob/Player/q in Tracks["IronThrone"])
				if(p!=q && p.bid==q.bid)
					equalBidders = TRUE
					break
			if(equalBidders) break

		if(equalBidders)
			world<<"[swapper] has thirty seconds to reorder anyone with equal bids."
			if(swapper.client)
				spawn(300) if(PHASE=="ClashOfKings-ITEnd") CoKCardF()
			else
				swapper.AI()
		else
			world<<"Bids are shown."
			sleep(50)
			CoKCardF()

	CoKCardF()
		PHASE="ClashOfKings-F"
		var/obj/WA/Track/Fiefdoms/F = new()
		var/obj/WA/Track/Fiefdoms/Fsb = new()
		Fsb.screen_loc="scoreboard:1,4"
		for(var/mob/Player/player in Tracks["Fiefdoms"])
			player.bidlocked=FALSE
			player.bid=0
			if(player.client)
				g_bidChange(player)
				for(var/obj/WA/Track/IronThrone/IT in player.client.screen)
					del IT
				player.client.screen+=F
				// Add Fiefdom icon next to "bids" track on 'scoreboard'
				player.client.screen+=Fsb
			else
				player.AI()

		// Remove IronThrone bids from screen
		var/obj/Scoreboard/Track/IronThrone/throne 	= locate("IronThrone")
		for(var/obj/Scoreboard/PlayerToken/token in throne.Tokens)
			token.maptext=""
		world<<"Please bid on the Fiefdoms track."

	CoKCardFEnd()
		PHASE="ClashOfKings-FEnd"
		swapper = Tracks["IronThrone"][1]
		var/list/tempList = Tracks["Fiefdoms"]
		if(!tempList.len) return
		SortByBids(tempList)

		s_updateScoreboard()
		var/obj/Scoreboard/Track/Fiefdoms/fiefdoms 	= locate("Fiefdoms")
		for(var/obj/Scoreboard/PlayerToken/token in fiefdoms.Tokens)
			token.maptext="<b>[token.Owner.bid]</b>"
			token.maptext_y = 68

		var/equalBidders = FALSE
		for(var/mob/Player/p in Tracks["Fiefdoms"])
			for(var/mob/Player/q in Tracks["Fiefdoms"])
				if(p!=q && p.bid==q.bid)
					equalBidders = TRUE
					break
			if(equalBidders) break

		if(equalBidders)
			world<<"[swapper] has thirty seconds to reorder anyone with equal bids."
			if(swapper.client)
				spawn(300) if(PHASE=="ClashOfKings-FEnd") CoKCardR()
			else
				swapper.AI()
		else
			world<<"Bids are shown."
			sleep(50)
			CoKCardR()


	CoKCardR()
		PHASE="ClashOfKings-R"
		var/obj/WA/Track/Raven/R = new()
		var/obj/WA/Track/Raven/Rsb = new()
		Rsb.screen_loc="scoreboard:1,4"
		for(var/mob/Player/player in Tracks["Raven"])
			player.bidlocked=FALSE
			player.bid = 0
			if(player.client)
				g_bidChange(player)
				for(var/obj/WA/Track/Fiefdoms/F in player.client.screen)
					del F
				player.client.screen+=R
				// Add Raven icon next to "bids" track on 'scoreboard'
				player.client.screen+=Rsb
			else
				player.AI()
		var/obj/Scoreboard/Track/Fiefdoms/fiefdoms 	= locate("Fiefdoms")
		for(var/obj/Scoreboard/PlayerToken/token in fiefdoms.Tokens)
			token.maptext=""
		s_updateScoreboard()
		world<<"Please bid on the Raven track."


	CoKCardREnd()
		PHASE="ClashOfKings-REnd"
		swapper = Tracks["IronThrone"][1]

		var/list/Raven = Tracks["Raven"]
		if(!Raven.len) return
		SortByBids(Tracks["Raven"])

		s_updateScoreboard()
		var/obj/Scoreboard/Track/Raven/raven 	= locate("Raven")
		for(var/obj/Scoreboard/PlayerToken/token in raven.Tokens)
			token.maptext="<b>[token.Owner.bid]</b>"
			token.maptext_y = 100

		var/equalBidders = FALSE
		for(var/mob/Player/p in Tracks["Fiefdoms"])
			for(var/mob/Player/q in Tracks["Fiefdoms"])
				if(p!=q && p.bid==q.bid)
					equalBidders = TRUE
					break
			if(equalBidders) break

		if(equalBidders)
			world<<"[swapper] has thirty seconds to reorder anyone with equal bids."
			if(swapper.client)
				spawn(300) if(PHASE=="ClashOfKings-REnd") CoKCardEnd()
			else
				swapper.AI()
		else
			world<<"Bids are shown."
			sleep(50)
			CoKCardEnd()


	CoKCardEnd()
		for(var/mob/Player/player in Tracks["Raven"])
			player.bidlocked=FALSE
			player.bid = 0
			if(player.client)
				for(var/obj/WA/R in player.client.screen)
					del R
				for(var/obj/WA/Bid/B in player.client.screen)
					del B
		c_pickCards()

	g_bidChange(var/mob/Player/player)
		if(player && player.client)
			for(var/obj/WA/Bid/b in player.client.screen) del b
			var/obj/WA/Bid/bid = new()
			bid.maptext = "<b>[player.bid]</b>"
			bid.screen_loc = "15:11,1:23"
			player.client.screen += bid