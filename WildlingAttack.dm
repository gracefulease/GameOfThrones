obj
	WA
		layer = 4
		icon = 'HUD.dmi'
		var
			click_state
			std_state
		WA
			icon_state = "WildlingAttack"
			screen_loc = "13:30,1:16"
		Bid
			icon_state = ""
		Bidslot
			icon_state = "Bid"
		Track
			icon = 'Scoreboard.dmi'
			screen_loc = "13:30,1:16"
			IronThrone
				icon_state="IronThrone"
			Fiefdoms
				icon_state="Fiefdoms"
			Raven
				icon_state="Raven"

		Slot
			icon_state = "Slot"
			screen_loc = "15,1:16"
		Up
			icon_state = "Up"
			click_state="UpClick"
			screen_loc = "15,1:29"
			Click()
				src.icon_state = src.click_state
				spawn(1) src.icon_state = src.std_state

				if(( findtext(PHASE,"ClashOfKings")||findtext(PHASE,"WildlingAttack") )&&!findtext(PHASE,"End"))
					var/mob/Player/player = usr
					if(player.bidlocked)
						player << "You have already locked in your bid."
						return 0
					if(player.Influence<1)
						player << "You do not have enough influence to bid more."
						return 0
					player.Influence--
					player.bid++
					g_bidChange(player)
					h_influenceChange()


		Down
			icon_state = "Down"
			click_state="DownClick"
			screen_loc = "15,1:4"
			Click()
				src.icon_state = src.click_state
				spawn(1) src.icon_state = src.std_state

				if(( findtext(PHASE,"ClashOfKings")||findtext(PHASE,"WildlingAttack") )&&!findtext(PHASE,"End"))
					var/mob/Player/player = usr
					if(player.bidlocked)
						player << "You have already locked in your bid."
						return 0
					if(player.bid<1)
						player << "You can't reduce a bid below zero."
						return 0
					player.Influence++
					player.bid--
					g_bidChange(player)
					h_influenceChange()

		Influence
			icon_state = "Influence"
			var/mob/Player/owner
			Click()
				if(PHASE=="WildlingAttackWin")
					Highest = owner
					wa_EndChoice(usr)
					PHASE="WildlingCard"
					WACARD.highestEffect()
				else if(PHASE=="WildlingAttackLoss")
					Lowest = owner
					wa_EndChoice(usr)
					PHASE="WildlingCard"
					WACARD.lossEffect()
		New()
			..()
			if(!std_state) std_state = icon_state
			if(!click_state) click_state = icon_state
proc
	wa_Start()
		var/obj/WA/Slot/s = new()
		var/obj/WA/Up/u = new()
		var/obj/WA/Down/d = new()
		var/obj/WA/WA/wa = new()
		var/list/IronThrone = Tracks["IronThrone"]
		for(var/mob/Player/player in IronThrone)
			player.bid = 0
			g_bidChange(player)
			if(player.client)
				var/count = 1
				for(var/i = 1; i<=IronThrone.len; i++)
					var/mob/Player/other = IronThrone[i]
					if(other&&other!=player)
						var/obj/WA/Influence/infl = new()
						infl.owner = other
						infl.icon = houseIconLookup(other.House)
						infl.screen_loc = "13:[-count*20],1:16"
						player.client.screen+=infl
						count++
					var/obj/WA/Bidslot/bid = new()
					bid.screen_loc="scoreboard:[i+1],4"
					player.client.screen+=bid

				player.client.screen+=s
				player.client.screen+=u
				player.client.screen+=d
				player.client.screen+=wa
			else
				player.AI()

	wa_repeat()
		for(var/mob/Player/player in Tracks["IronThrone"])
			if(!player.Exempt)
				player.bid = 0
				player.bidlocked = FALSE
				g_bidChange(player)
				if(!player.client)
					player.AI()
		wa_cardPick()

	wa_End()
		var/totalBid = 0, compareBid = 0
		var/procName
		swapper = Tracks["IronThrone"][1]
		var/list/Bidders, list/tempList = Tracks["IronThrone"]
		Bidders = tempList.Copy()

		if(PHASE == "PR-Won")	// If we're doing a repeat wildling attack, the former Highest doesn't have to contend
			if(!Bidders.Remove(Highest))
				world<<"Error: wa_End() - unable to remove Highest from Bidders list."
		SortByBids(Bidders)

		for(var/mob/Player/player in Bidders)
			totalBid += player.bid

			if(player.client)
				for(var/obj/WA/hudItem in player.client.screen)
					if(!findtext(hudItem.screen_loc,"scoreboard"))
						player.client.screen-=hudItem
		Highest = Bidders[1]
		Lowest = Bidders[Bidders.len]

		var/obj/Scoreboard/Track/IronThrone/throne 	= locate("IronThrone")
		for(var/obj/Scoreboard/PlayerToken/token in throne.Tokens)
			if(!token.Owner.Exempt)
				token.maptext="<b>[token.Owner.bid]</b>"
			else
				token.maptext="<b>n/a</b>"
			token.maptext_y = 36

		var/list/equalBidders = new/list()
		var/highOrLow
		world<<"[WACARD]"

		if(totalBid>=WildlingThreat)
			PHASE = "WildlingAttackWin"
			highOrLow = "high"
			procName = "highestEffect"
			compareBid = Highest.bid
		else
			PHASE = "WildlingAttackLoss"
			highOrLow = "low"
			procName = "lossEffect"
			compareBid = Lowest.bid

		for(var/mob/Player/p in Bidders)
			if(p.bid==compareBid)
				equalBidders += p
			p.bidlocked=FALSE
			p.bid = 0

		if(equalBidders.len>1)
			world<<"[swapper] has thirty seconds to pick the [highOrLow]est bidder out of:"
			for(var/mob/Player/p in equalBidders)
				world<<p

			if(swapper.client)
				wa_Choice(equalBidders)
				spawn(300)
					wa_EndChoice(swapper)
					if(PHASE=="WildlingAttackWin" || PHASE=="WildlingAttackLoss")
						call(WACARD,procName)()
			else
				swapper.AI()
				return
		else
			call(WACARD,procName)()

	wa_Choice(var/list/equalBidders)
		if(swapper.client)
			winshow(swapper,"wildlingAttack",1)

			for(var/i = 1; i <= equalBidders.len; i++)
				var/mob/Player/other = equalBidders[i]
				var/obj/WA/Influence/infl = new()
				infl.owner = other
				infl.icon = houseIconLookup(other.House)
				infl.screen_loc = "wildlingChoice: [i],0"
				swapper.client.screen+=infl

	wa_EndChoice(var/mob/Player/clicker)
		if(clicker.client)
			for(var/obj/WA/Influence/infl in clicker.client.screen)
				if(findtext(infl.screen_loc,"wildlingChoice"))
					clicker.client.screen-=infl
			if(winget(clicker, "wildlingAttack", "is-visible"))
				winshow(clicker,"wildlingAttack",0)

	wa_cardPick()
		var/list/wildlingCards = typesof(/obj/HUD/Cards/WildlingAttack) - /obj/HUD/Cards/WildlingAttack
		if(PHASE == "PR-Won")
			wildlingCards = typesof(/obj/HUD/Cards/WildlingAttack) - /obj/HUD/Cards/WildlingAttack
			wildlingCards.Remove(/obj/HUD/Cards/WildlingAttack/PR)

		var/WACARDtype = pick(wildlingCards)
		WACARD = new WACARDtype



obj/HUD/Cards/WildlingAttack
	var
		highestEffect = ""
		lossEffect = ""
		lowestEffect = ""
	New()
		..()
		spawn(1) desc = "Victory: [highestEffect]\n Loss: [lossEffect]\n Lowest bidder: [lowestEffect]"
	MOTM
		name = "Massing on the Milkwater"
		highestEffect = "The highest bidder gets back all their House Cards from their discard pile."
		lossEffect = "Everyone discards a House Card."
		lowestEffect = "The lowest bidder loses their strongest House Card(s)."
		highestEffect()
			world<<"As the highest bidder, [Highest] gets back all their House Cards from their discard pile."
			Highest.HouseCards+=Highest.DiscardPile
			Highest.DiscardPile.len=0
			c_endCardPhase()
		lossEffect()
			world<<"Everyone except [Lowest] must discard a House Card."
			for(var/mob/Player/player in Tracks["IronThrone"])
				var/obj/House_Cards/pickedCard
				if(player.client)
					pickedCard = input(player,"Select a House Card to discard.",src.name) in player.HouseCards
				else
					pickedCard = pick(player.HouseCards) 		// @TODO - make smarter for AI
				player.HouseCards-=pickedCard
				player.DiscardPile+=pickedCard
		lowestEffect()
			world<<"As the lowest bidder, [Lowest] loses their strongest House Card(s)."
			var/list/tempHand = Lowest.HouseCards.Copy()
			SortByStrength(tempHand)							// Sort card, strongest first
			var/obj/House_Cards/strongestCard = tempHand[1]
			for(var/obj/House_Cards/card in tempHand)			// Move all cards as strong as the strongest to discard pile
				if(card.Strength==strongestCard.Strength)
					Lowest.HouseCards-=card
					Lowest.DiscardPile+=card
				else
					break
			c_endCardPhase()

	AKBTW
		name = "A King Beyond the Wall"
		highestEffect 	= "The highest bidder is moved to the top of the Influence Track of their choice."
		lossEffect 		= "Everyone except the lowest bidder is moved to the bottom of either the Fiefdoms or Raven Track."
		lowestEffect 	= "The lowest bidder is moved to the bottom of every Influence Track."
		highestEffect()
			world<<"As the highest bidder, [Highest] must click on Track of their choice and is moved to the top."
			PHASE = "AKBTW-Win"
			if(!Highest.client)
				Highest.AI()
		lossEffect()
			world<<"Everyone except [Lowest] must click on either the Fiefdoms or Raven Track to be moved to the lowest position."
			PHASE = "AKBTW-Loss"
			d_assignPlayerTurn(Tracks["IronThrone"])
		lowestEffect()
			PHASE="AKBTW-Lowest"
			world<<"As the lowest bidder, [Lowest] is moved to the bottom of every Influence track."
			for(var/lists in Tracks)
				var/list/tempTrack = Tracks[lists]
				tempTrack.Remove(Lowest)
				tempTrack.Add(Lowest)
			s_updateScoreboard()
			c_endCardPhase()
	MR
		name = "Mammoth Riders"
		highestEffect 	= "The highest bidder retrieves a card of their choice from the discard pile."
		lossEffect 		= "Everyone except the lowest bidder must destroy two units."
		lowestEffect 	= "The lowest bidder must destroy three units."
		highestEffect()
			if(!Highest.DiscardPile.len)
				world<<"[Highest] had the highest bid, but had no House Cards in the discard pile to retrieve."
			else
				var/obj/House_Cards/pick = input(Highest,"Pick a House Card to return to your hand.","Mammoth Riders") in list(Highest.DiscardPile)
				if(pick)
					world<<"With the highest bid, [Highest] chose to retrieve [pick] from the discard pile."
					Highest.HouseCards+=pick
			c_endCardPhase()
		lossEffect()
			world<<"Everyone except [Lowest] must destroy two units."
			PHASE = "MR-Loss"
			d_assignPlayerTurn(Tracks["IronThrone"])
		lowestEffect()
			world<<"[Lowest] must destroy three units."
			PHASE = "MR-Loss"
			PlayerTurn = Lowest
			if(PlayerTurn.client)
				PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")
	CK
		name = "Crow Killers"
		highestEffect 	= "The highest bidder can upgrade two infantry to cavalry."
		lossEffect 		= "Everyone except the lowest bidder must replace two cavalry with infantry."
		lowestEffect 	= "All of the lowest bidder's cavalry are replaced with infantry."
		highestEffect()
			PHASE = "CK-Won"
			world<<"With the highest bid, [Highest] can upgrade two infantry to cavalry."
			if(PlayerTurn.client)
				PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"upgrade")
		lossEffect()
			PHASE = "CK-Loss"
			world<<"Everyone except [Lowest] must replace two cavalry with infantry."
			d_assignPlayerTurn(Tracks["IronThrone"])
		lowestEffect()
			world<<"All of [Lowest]'s cavalry are downgraded to infantry."
			for(var/obj/armyPiece/Cavalry/oldPiece in Lowest.armyPieces)
				var/obj/armyPiece/Infantry/newPiece = new(oldPiece.loc)
				var/icon/iconFile = houseIconLookup(Lowest.House)
				newPiece.Owner	= Lowest
				newPiece.icon	= iconFile
				Lowest.armyPieces+=newPiece
				del oldPiece
			c_endCardPhase()
	THD
		name = "The Horde Descends"
		highestEffect 	= "The highest bidder may muster in any one territory."
		lossEffect 		= "Everyone except the lowest bidder must destroy a unit."
		lowestEffect 	= "The lowest bidder must destroy two units in territories with castles, or elsewhere if not possible."
		highestEffect()
			//TODO - may muster in any one territory
			c_endCardPhase()
		lossEffect()
			world<<"Everyone except [Lowest] must destroy a unit."
			PHASE = "THD-Loss"
			d_assignPlayerTurn(Tracks["IronThrone"])
		lowestEffect()
			world<<"[Lowest] must destroy two units in territories with castles, or elsewhere if not possible."
			PHASE = "THD-Loss"
			PlayerTurn = Lowest
			if(PlayerTurn.client)
				PlayerTurn.client.mouse_pointer_icon = icon('mouseIcons.dmi',"destroy")
	SS
		name = "Skinchanger Scout"
		highestEffect 	= "The highest bidder gets their bid returned to them."
		lossEffect 		= "Everyone except the lowest bidder loses two Influence."
		lowestEffect 	= "The lowest bidder loses all Influence."
		highestEffect()
			world<<"With the highest bid, [Highest] gets their [Highest.bid] Influence returned."
			Highest.Influence += Highest.bid
			h_influenceChange()
			c_endCardPhase()
		lossEffect()
			world<<"All players, other than [Lowest] lose two Influence."
			for(var/mob/Player/other in Tracks["IronThrone"])
				if(other!=Lowest)
					other.Influence-=2
					if(other.Influence<=0) other.Influence = 0

			h_influenceChange()
			sleep(10)
			lowestEffect()
		lowestEffect()
			world<<"[Lowest], the lowest bidder, loses all Influence."
			Lowest.Influence = 0
			h_influenceChange()
			c_endCardPhase()
	RR
		name = "Rattleshirt's Raiders"
		highestEffect 	= "The highest bidder gains one Supply."
		lossEffect 		= "Everyone except the lowest bidder lose one Supply."
		lowestEffect 	= "The lowest bidder loses two Supply."
		highestEffect()
			world<<"[Highest] the highest bidder, gains one Supply."
			Highest.Supply = min(Highest.Supply+1,6)
			c_endCardPhase()
		lossEffect()
			world<<"All players, other than [Lowest] lose one Supply."
			for(var/mob/Player/other in Tracks["IronThrone"])
				if(other!=Lowest)
					other.Supply=max(other.Supply-1,0)
			PHASE="RR-Loss"
			d_assignPlayerTurn(Tracks["IronThrone"])
		lowestEffect()
			world<<"[Lowest], the lowest bidder, loses two Supply."
			Lowest.Supply=max(Lowest.Supply-2,0)
			PHASE="RR-Loss"
			PlayerTurn = Lowest
			c_endCardPhase()
	SATW
		name = "Silence at the Wall"
		highestEffect 	= "Nothing happens."
		lossEffect 		= "Nothing happens."
		lowestEffect 	= "Nothing happens."
		highestEffect()
			world<<"Nothing happens."
			c_endCardPhase()
		lossEffect()
			world<<"Nothing happens."
			c_endCardPhase()
		lowestEffect()
	PR
		name = "Preemptive Raid"
		highestEffect 	= "The wildlings attack again at their current strength, but the highest bidder does not participate"
		lossEffect 		= "Nothing happens for anyone but the lowest bidder"
		lowestEffect 	= "The lowest bidder must destroy two units, or move down two places on the influence track that they hold the highest position."
		highestEffect()
			world<<"The wildlings attack again at strength [WildlingThreat], but [Highest] does not participate."
			PHASE = "PR-Won"
			Highest.Exempt = TRUE
			if(Highest.client)
				for(var/obj/WA/hudItem in Highest.client.screen)
					if(!findtext(hudItem.screen_loc,"scoreboard"))
						Highest.client.screen-=hudItem
			wa_repeat()

		lossEffect()
			world<<"Nothing happens for anyone but [Lowest]."
			sleep(5)
			WACARD.lowestEffect()
		lowestEffect()
			world<<"[Lowest] must destroy two units, or move down two places on the influence track that they hold the highest position."
			Lowest<<"Click on units to destroy them, or click \"Done\" to move down on an influence track."
			PHASE = "PR-Loss"
			PlayerTurn = Lowest
			//choose two units to destroy, or reduce two positions on highest influence track

	proc
		highestEffect()
		lossEffect()
		lowestEffect()