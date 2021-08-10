/**
 * MicroTF2 - Minigame C31
 * 
 * Pick a door!
 */

int g_MC31Ans;

public void MC31_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, MC31_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, MC31_OnMinigameSelected);
	g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, MC31_OnMinigameFinish);
}

public void MC31_OnMinigameSelectedPre()
{
	if(g_iActiveMinigameId == 31)
	{
		char entityName[32];
		char expectedEntityName[32];
		int entity = -1;
		for(int i = 1; i <= 3; i++)
		{
			Format(expectedEntityName, sizeof(expectedEntityName), "plugin_PCBoss_Hurt%i", i);
		
			while ((entity = FindEntityByClassname(entity, "trigger_hurt")) != INVALID_ENT_REFERENCE)
			{
				GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));
		
				if (strcmp(entityName, expectedEntityName) == 0)
				{
					AcceptEntityInput(entity, "Enable", -1, -1, -1);
					HookSingleEntityOutput(entity, "OnStartTouch", MC31_OnHurtStartTouch);
				}
			}
		}
		
		g_MC31Ans = GetRandomInt(1, 3);
		
		MC31_SetDoorOpen(1, true);
		MC31_SetDoorOpen(2, true);
		MC31_SetDoorOpen(3, true);
	}
}

public void MC31_OnMinigameSelected(int client)
{
	if(g_iActiveMinigameId != 31)
	{
		return;
	}

	if(!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);

	if(player.IsValid)
	{
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);
		player.ResetHealth();
		player.ResetWeapon(false);
		
		float pos[3] = { -2239.0, 1855.0, -1082.0 };
		float vel[3] = { 0.0, 0.0, 0.0 };
		
		TeleportEntity(client, pos, vel, vel);
	}
}

public void MC31_OnMinigameFinish()
{
	if(g_iActiveMinigameId != 31)
	{
		return;
	}
	
	if(!g_bIsMinigameActive)
	{
		return;
	}
	
	char entityName[32];
	char expectedEntityName[32];
	int entity = -1;
	for(int i = 1; i <= 3; i++)
	{
		Format(expectedEntityName, sizeof(expectedEntityName), "plugin_PCBoss_Hurt%i", i);
	
		while ((entity = FindEntityByClassname(entity, "trigger_hurt")) != INVALID_ENT_REFERENCE)
		{
			GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));
	
			if (strcmp(entityName, expectedEntityName) == 0)
			{
				UnhookSingleEntityOutput(entity, "OnStartTouch", MC31_OnHurtStartTouch);
				AcceptEntityInput(entity, "Disable", -1, -1, -1);
			}
		}
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating)
		{
			player.Respawn();
			SDKUnhook(i, SDKHook_OnTakeDamage, Minigame18_OnTakeDamage);
		}
	}
	
	MC31_SetDoorOpen(1, false);
	MC31_SetDoorOpen(2, false);
	MC31_SetDoorOpen(3, false);
}

public Action MC31_OnHurtStartTouch(const char[] output, int caller, int activator, float delay)
{
	char name[32];
	GetEntPropString(caller, Prop_Data, "m_iName", name, sizeof(name));
	
	if(!StrContains(name, "plugin_PCBoss_Hurt"))
	{
		ReplaceString(name, sizeof(name), "plugin_PCBoss_Hurt", "", false);
		int num = StringToInt(name);
		
		Player player = new Player(activator);
		
		if(player.IsValid && player.IsAlive && player.IsParticipating && player.Status == PlayerStatus_NotWon)
		{
			float pos[3];
			float ang[3];
			float vel[3] = { 0.0, 0.0, 0.0 };
			
			if(g_MC31Ans == num)
			{
				player.TriggerSuccess();
				
				pos[0] = 11369.0;
				pos[1] = 7059.0;
				pos[2] = -214.0;
				
				ang[0] = 0.0;
				ang[1] = 90.0;
				ang[2] = 0.0;
			}
			else
			{
				player.Status = PlayerStatus_Failed;
				player.Health = 1;
				
				pos[0] = 11369.0;
				pos[1] = 7843.0;
				pos[2] = -118.0;
				
				ang[0] = 0.0;
				ang[1] = 270.0;
				ang[2] = 0.0;
			}
			
			TeleportEntity(activator, pos, ang, vel);
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

void MC31_SetDoorOpen(int roomNumber, bool open)
{
	int entity = -1;
	char entityName[32];

	char expectedEntityName[32];
	Format(expectedEntityName, sizeof(expectedEntityName), "plugin_PCBoss_Door%i", roomNumber);

	while ((entity = FindEntityByClassname(entity, "func_door")) != INVALID_ENT_REFERENCE)
	{
		GetEntPropString(entity, Prop_Data, "m_iName", entityName, sizeof(entityName));

		if (strcmp(entityName, expectedEntityName) == 0)
		{
			AcceptEntityInput(entity, open ? "Open" : "Close", -1, -1, -1);
		}
	}
}