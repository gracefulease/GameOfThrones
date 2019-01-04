obj
	HUD
		Dominance
			icon = 'Dominance.dmi'
			var
				used = FALSE
				icon/defaultIcon
			IronThrone
				icon_state="IronThrone"
				Click()
					usr<<"You decide any draws."
			Fiefdoms
				icon_state="Fiefdoms"
				Click()
					if(PHASE=="BattleBlade")
						if(src.loc == usr && battle.combatants && battle.combatants.Find(usr) && !src.used)
							src.used = TRUE
							battle.combatants[usr] += 1
							var/list/tempSwords = new/list()
							var/obj/HUD/tempSword
							for(var/mob/Player/other in Tracks["IronThrone"])
								if(other.client)
									tempSword = new(null, other.client, list(icon = 'Dominance.dmi', icon_state="Fiefdoms", anchor_x="CENTER", anchor_y="CENTER", screen_x=0, screen_y=0, layer=HUD_LAYER-1),1)
									spawn() slowexplode(tempSword)
									tempSwords += tempSword

							src.defaultIcon = src.icon
							var/icon/I = new(src.icon)
							I.Blend(rgb(100,100,100),ICON_MULTIPLY,1,1)
							src.icon = I
							battle_determineWinner()

			Raven
				icon_state="Raven"
				Click()
					if(!used)
						used = TRUE
						var/obj/HUD/Cards/hud
						var/obj/HUD/Cards/Close/close  = new /obj/HUD/Cards/Close(null, usr.client, list(anchor_x="CENTER", anchor_y="CENTER",screen_x=-TILE_WIDTH, screen_y=((CARDS_Y+2)*TILE_HEIGHT)-1), 1)

						hud = new WACARD.type(null, usr.client, list(icon_state="Wildling Attack",anchor_x="CENTER", anchor_y="CENTER", screen_x=-TILE_WIDTH, screen_y=CARDS_Y*TILE_HEIGHT), 1)
						close.attached += hud
						cardsHUD += hud
						hud = new /obj/HUD/CardTitle(null, usr.client, list(maptext = WACARD.name, screen_x=-TILE_WIDTH, screen_y=((CARDS_Y+2)*TILE_HEIGHT)-1), 1)
						cardsHUD += hud
						close.attached += hud
						src.defaultIcon = src.icon
						var/icon/I = new(src.icon)
						I.Blend(rgb(100,100,100),ICON_MULTIPLY,1,1)
						src.icon = I
