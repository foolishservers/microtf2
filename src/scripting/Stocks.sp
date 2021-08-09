/**
 * MicroTF2 - Stocks.inc
 * 
 * Contains alot of Stocks for use in Minigames / Other stuff
 */

stock void DisplayOverlayToAll(const char[] path)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			player.DisplayOverlay(path);
		}
	}
}

stock void PlaySoundToPlayer(int client, const char[] sound)
{
	Player player = new Player(client);

	if (player.IsInGame && !player.IsBot && !g_bIsMapEnding)
	{
		EmitSoundToClient(client, sound, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, GetSoundMultiplier());
	}
}

stock void PlaySoundToAll(const char[] sound)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		PlaySoundToPlayer(i, sound);
	}
}

public Action Timer_Respawn(Handle timer, int client)
{
	Player player = new Player(client);

	if (player.IsValid && player.IsParticipating)
	{
		player.Respawn();
	}

	return Plugin_Handled;
}

stock void ShowAnnotation(int client, int attachToEntity, float lifetime, char text[32])
{
	int bitfield = BuildBitStringExcludingClient(attachToEntity);

	ShowAnnotationWithBitfield(client, attachToEntity, lifetime, text, bitfield);
}

stock void ShowAnnotationWithBitfield(int client, int attachToEntity, float lifetime, char text[32], int bitfield)
{
	Event event = CreateEvent("show_annotation");

	if (event == INVALID_HANDLE)
	{
		return;
	}

	if (g_iAnnotationEventId > 9999)
	{
		g_iAnnotationEventId = 0;
	}

	if (g_iSpecialRoundId == 19)
	{
		char rewritten[32];
		ReverseString(text, sizeof(text), rewritten);
		strcopy(text, sizeof(text), rewritten);
	}

	//https://forums.alliedmods.net/showpost.php?p=1996379&postcount=14
	event.SetInt("id", g_iAnnotationEventId);
	event.SetInt("follow_entindex", attachToEntity);
	event.SetFloat("lifetime", lifetime);
	event.SetString("text", text);
	event.SetString("play_sound", "misc/null.wav");
	event.SetBool("show_effect", false);
	event.SetInt("visibilityBitfield", bitfield);
	event.FireToClient(client);
	event.Cancel();	//Free the handle memory
	
	g_iAnnotationEventId++;
}

public int BuildBitStringExcludingClient(int client)
{
	int bitfield = 0;

	// Iterating through all clients to build a visibility bitfield of all alive players
	for (int i = 1; i <= MaxClients; i++)
	{
		if (client == i) 
		{
			continue;
		}

		if (IsClientInGame(i) && i != client)
		{
			// 1-based
			bitfield |= (1 << i);
		}
	}

	return bitfield;
}

public void AddClientToBitString(int bitfield, int client)
{
	bitfield |= (1 << client);
}

stock void RemoveAllStunballEntities()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_stun_ball")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

stock void RemoveAllJarateEntities()
{
	int entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_projectile_jar")) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(entity, "Kill");
	}
}

// Credit to authors of SMLIB. Moved here due to the include file not building on newer spcomp, also converted to new syntax
stock void ToUpperString(const char[] input, char[] output, int size)
{
	size--;

	int x = 0;

	while (input[x] != '\0' && x < size) 
	{
		output[x] = CharToUpper(input[x]);
		x++;
	}

	output[x] = '\0';
}

stock void ReverseString(const char[] input, int inputSize, char[] output)
{
	int rc = 0;
	int len = inputSize;

	for (int c = len - 1; c >= 0; c--)
	{
		if (input[c] == '\0')
		{
		 	continue;
		}

		// Thanks to whysodrooled for these Unicode reversal fixes (#199)

		if (c >= 1 && (input[c-1] & 0xC0 == 0xC0)) // 2 bytes
		{
			for (int j = 0; j < 2; j++)
			{
				output[rc] = input[c-1+j];
				rc++;
			}
			c--;
		}
		else if (c >= 2 && (input[c-2] & 0xE0 == 0xE0)) // 3 bytes
		{
			for (int j = 0; j < 3; j++)
			{
				output[rc] = input[c-2+j];
				rc++;
			}
			c -= 2;
		}
		else
		{
			output[rc] = input[c];
			rc++;
		}
	}
}

stock bool IsStringInt(const char[] arg)
{
	return StringToInt(arg) != 0 || StrEqual(arg, "0");
}

public int GetClientAimEntity3(int client, float &distancetoentity, float endpos[3])	//Snippet by Javalia
{
	float cleyepos[3];
	float cleyeangle[3];

	GetClientEyePosition(client, cleyepos);
	GetClientEyeAngles(client, cleyeangle);

	Handle traceresulthandle = INVALID_HANDLE;
	traceresulthandle = TR_TraceRayFilterEx(cleyepos, cleyeangle, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfOrPlayers, client);

	if (TR_DidHit(traceresulthandle) == true)
	{
		TR_GetEndPosition(endpos, traceresulthandle);
		distancetoentity = GetVectorDistance(cleyepos, endpos);
		int entindextoreturn = TR_GetEntityIndex(traceresulthandle);
		CloseHandle(traceresulthandle);
		return entindextoreturn;
	}

	CloseHandle(traceresulthandle);
	return -1;
}

public bool TraceRayDontHitSelfOrPlayers(int entity, int mask, int data)
{
	Player player = new Player(entity);

	return (entity != data && !player.IsValid);
}

stock void GetEntityPosition(int entity, float position[3])
{
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
}

stock float NormalizeAngle(float angle)
{
	angle -= RoundToFloor(angle / 360.0) * 360.0;
	
	if (angle > 180)
	{
		angle -= 360;
	}
    
	if (angle < -180)
	{
		angle += 360;
	}

	return angle;
}

stock int GetRandomParticipatingPlayerId()
{
	int loop = 0;

	while (loop < 32)
	{
		loop++;

		Player player = new Player(GetRandomInt(1, MaxClients));

		if (player.IsValid && player.IsParticipating) 
		{
			return player.ClientId;
		}
	}

	return -1;
}

stock int GetEntityByName(const char[] name, const char[] classname)
{
	int ret = -1;
	while((ret = FindEntityByClassname(ret, classname)) != -1)
	{
		char entityName[64];
		GetEntPropString(ret, Prop_Data, "m_iName", entityName, sizeof(entityName));
		
		if(StrEqual(entityName, name)) break;
	}
	
	return ret;
}