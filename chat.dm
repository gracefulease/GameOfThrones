mob
	Player
		verb
			say(var/text as text)
				var/msg
				var/regex/search = new("@(\\w+)\\b (.+)","i")
				var/found = search.Find(text)
				var/hit=0
				if(found)
					var/receiver = search.group[1]
					if(receiver!="all")
						for(var/name in Players)
							hit = findtext(name, search.group[1])
							if(hit)
								chatTarget = Players[name]
					else
						chatTarget = null

					msg = search.group[2]
					if(chatTarget)
						winset(usr, "output1", "text-color=[textColour[chatTarget.House]]")
						chatTarget<<"[usr]->[chatTarget]: [msg]"
						usr<<"[usr]->[chatTarget]: [msg]"
					else
						winset(usr, "output1", "text-color=#000000")
						world<<"[usr]: [msg]"
				else
					search = new("(.+)","i")
					found = search.Find(text)
					if(found)
						msg = search.group[1]
						world<<"[usr]: [msg]"

			autocomplete()
				var/text = winget(usr, "chat", "text")
				var/regex/search = new("(?:@)(\\w+)","i")
				var/found = search.Find(text)
				var/hit = 0
				if(found)
					for(var/name in Players)
						hit = findtext(name, search.group[1])
						if(hit)
							var/mob/Player/receiver = Players[name]
							winset(usr, "chat", "text=\"@[name] \";text-color=[textColour[receiver.House]]")
							winset(usr, "output1", "text-color=[textColour[receiver.House]]")
							break


var
	global
		list/textColour = list("Baratheon" = "#999909", "Greyjoy" = "#555580", "Lannister" = "#bb0000", "Martell" = "#CC7722", "Stark" = "#776655", "Tyrell" = "#008800")
