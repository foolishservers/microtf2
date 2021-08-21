/**
 * MicroTF2 - Bossgame C3
 * 
 * Goal 7 Bombs
 */

#define BC3_NUM 11
#define BC3_SFX_GOAL "ui/hitsound_retro1.wav"

int g_iBC3Points[MAXPLAYERS + 1];

public void BC3_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, BC3_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, BC3_OnMinigameSelected);
	//g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, BC3_OnMinigameFinish);
	g_pfOnEntityCreated.AddFunction(INVALID_HANDLE, BC3_OnEntityCreated);
	
	PrecacheSound(BC3_SFX_GOAL);
}

public void BC3_OnMinigameSelectedPre()
{
	if(g_iActiveBossgameId == BC3_NUM)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			g_iBC3Points[i] = 0;
		}
	}
}

public void BC3_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != BC3_NUM)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);
	
	if (!player.IsValid)
	{
		return;
	}
	
	player.Class = TFClass_DemoMan;
	player.SetGodMode(true);
	player.ResetHealth();
	player.RemoveAllWeapons();
	player.GiveWeapon(19);
	player.SetWeaponPrimaryAmmoCount(100);
	player.SetWeaponClipAmmoCount(4);
	player.SetCollisionsEnabled(false);
	
	// teleport
	float pos[3];
	float ang[3] = {0.0, 90.0, 0.0};
	float vel[3] = {0.0, 0.0, 0.0};
	int measure = client;
	
	pos[2] = -3690.0;
	if(measure > 16)
	{
		pos[1] = 5055.0;
		measure -= 16;
	}
	else
	{
		pos[1] = 5151.0;
	}
	pos[0] = 5217.0 + ((measure-1) * 64);
	
	TeleportEntity(client, pos, ang, vel);
}

public void BC3_OnEntityCreated(int entity, const char[] cls)
{
	if (g_iActiveBossgameId != BC3_NUM)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	if(StrEqual(cls, "tf_projectile_pipe"))
	{
		SDKHook(entity, SDKHook_StartTouchPost, BC3_PipeStartTouchPost);
	}
}

/*public void BC3_OnMinigameFinish(int client)
{
	
}*/

public void BC3_PipeStartTouchPost(int entity, int other)
{
	char cls[16]; GetEntityClassname(other, cls, sizeof(cls));
	if(StrEqual(cls, "func_button"))
	{
		Player player = new Player(GetEntPropEnt(entity, Prop_Send, "m_hThrower"));
		if(!player.IsInGame) return;
		
		if(player.Status == PlayerStatus_NotWon)
		{
			g_iBC3Points[player.ClientId]++;
			EmitSoundToClient(player.ClientId, BC3_SFX_GOAL);
			if(g_iBC3Points[player.ClientId] >= 5)
			{
				player.TriggerSuccess();
			}
		}
		
		RemoveEntity(entity);
	}
}