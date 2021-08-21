/**
 * MicroTF2 - Minigame C4
 *
 * Airblast the rockets!
 */

#define MC4_NUM 33
#define MC4_SFXSHOOT "weapons/rocket_shoot.wav"

public void MC4_EntryPoint()
{
	AddToForward(g_pfOnMinigameSelectedPre, INVALID_HANDLE, MC4_OnMinigameSelectedPre);
	AddToForward(g_pfOnMinigameSelected, INVALID_HANDLE, MC4_OnMinigameSelected);
	//AddToForward(g_pfOnMinigameFinish, INVALID_HANDLE, MC4_OnMinigameFinish);
	AddToForward(g_pfOnSoundEmit, INVALID_HANDLE, MC4_OnSoundEmit);
	
	PrecacheSound(MC4_SFXSHOOT);
}

public void MC4_OnMinigameSelectedPre()
{
	if(g_iActiveMinigameId == MC4_NUM)
	{
		int skip; int count;
		bool subtract = false;
		float pos[3];
		//pos[0] = -544.0;
		pos[0] = -672.0;
		pos[1] = -7152.0;
		pos[2] = 896.0;
		
		for(int i = 5; i >= 5;)
		{
			if(i >= 9) subtract = true;
			
			count = i;
			skip = RoundToFloor(float(9 - i) / 2.0) + view_as<int>(i % 2 == 0);
			for(int j = 1; j <= 18; j++)
			{
				pos[0] += 64.0;
				
				if((i % 2 == 0) == (j % 2 == 0))
				{
					continue;
				}
				
				if(skip > 0)
				{
					skip--;
					continue;
				}
				
				if(count <= 0)
				{
					break;
				}
				
				MC4_SpawnRocket(pos);
				count--;
			}
			
			pos[0] = -672.0;
			pos[1] -= 128.0;
			
			if(subtract)
			{
				i--;
			}
			else
			{
				i++;
			}
		}
		
		pos[0] = -32.0;
		pos[1] = -7664.0;
		
		EmitSoundToAll("weapons/rocket_shoot.wav", _, _, _, _, 0.78, _, _, pos);
	}
}

public void MC4_OnMinigameSelected(int client)
{
	if(g_iActiveMinigameId != MC4_NUM)
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
		player.Class = TFClass_Pyro;
		player.SetGodMode(true);
		player.ResetHealth();
		player.RemoveAllWeapons();
		player.GiveWeapon(21);
		player.SetWeaponPrimaryAmmoCount(800);
		player.SetCollisionsEnabled(false);
	}
}

/*public void MC4_OnMinigameFinish(int client)
{
	if(g_iActiveMinigameId != MC4_NUM)
	{
		return;
	}

	if(!g_bIsMinigameActive)
	{
		return;
	}
}*/

public Action MC4_OnSoundEmit(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH],
int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if(g_iActiveMinigameId != MC4_NUM)
	{
		return Plugin_Continue;
	}

	if(!g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}
	
	if(StrContains(sample, "flame_thrower_airblast_rocket_redirect", false) != -1)
    {
		Player player = new Player(GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity"));
		if(player.IsValid && player.IsParticipating)
		{
			player.TriggerSuccess();
		}
	}
	
	return Plugin_Continue;
}

int MC4_SpawnRocket(const float[3] pos)
{
	int rocket = CreateEntityByName("tf_projectile_rocket");
	if(IsValidEntity(rocket))
	{
		float ang[3] = { 90.0, 0.0, 0.0 };
		float vel[3] = { 0.0, 0.0, -730.0 };
		
		SetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity", 0);
		SetEntProp(rocket, Prop_Data, "m_nSkin", 0);
		SetEntProp(rocket, Prop_Send, "m_bCritical", 1);
		SetEntProp(rocket, Prop_Send, "m_iDeflected", 1);
		SetEntDataFloat(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, 1.0, true);
		
		SetVariantInt(1);
		AcceptEntityInput(rocket, "TeamNum", -1, -1, 0);
	
		SetVariantInt(1);
		AcceptEntityInput(rocket, "SetTeam", -1, -1, 0);
		
		DispatchSpawn(rocket);
		TeleportEntity(rocket, pos, ang, vel);
	}
	
	return rocket;
}