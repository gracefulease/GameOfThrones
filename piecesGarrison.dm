obj
	garrisonPiece
		var
			Strength			// Strength
			tempStrength		// Strength affected by House Cards and such
			onSea				// Land or Sea
			mob/Player/Owner 	// Player that owns src
		Garrison
			icon_state = "Garrison"
			icon = 'NPC.dmi'
			Strength = 1
			onSea = 0	// Land unit
		Click()
			usr << "This piece cannot be moved."