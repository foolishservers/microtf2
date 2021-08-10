/**
 * MicroTF2 - Minigame C30
 * 
 * Say the Word! (Word or Color)
 */
 
char g_sMC30SayTextAnswers[][] =
{
	"빨강",
	"주황",
	"노랑",
	"초록",
	"파랑",
	"보라",
	"하양",
	"분홍"
};
char g_sMC30SayTextAnswersEng[][] =
{
	"레드",
	"오렌지",
	"옐로우",
	"그린",
	"블루",
	"퍼플",
	"화이트",
	"핑크"
};
int g_iMC30Answer = -1;
int g_iMC30Rng;
int g_MC30Color[4];
bool g_bMC30IsColor;
bool g_bMC30HasAnyPlayerWon = false;

Handle g_hHudSyncColor;

public void MC30_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, MC30_OnMinigameSelectedPre);
	g_pfOnPlayerChatMessage.AddFunction(INVALID_HANDLE, MC30_OnChatMessage);
	
	if(g_hHudSyncColor != null) delete g_hHudSyncColor;
	g_hHudSyncColor = CreateHudSynchronizer();
}

public void MC30_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 30)
	{
		g_iMC30Answer = GetRandomInt(0, sizeof(g_sMC30SayTextAnswers) - 1);
		g_bMC30IsColor = view_as<bool>(GetRandomInt(0, 1));
		
		while((g_iMC30Rng = GetRandomInt(0, sizeof(g_sMC30SayTextAnswers) - 1)) == g_iMC30Answer)
		{
			g_iMC30Rng = GetRandomInt(0, sizeof(g_sMC30SayTextAnswers) - 1);
		}
		
		if(g_bMC30IsColor)
		{
			MC30_GetColor(g_iMC30Answer);
		}
		else
		{
			MC30_GetColor(g_iMC30Rng);
		}
		
		g_bMC30HasAnyPlayerWon = false;
	}
}

public void MC30_GetDynamicCaption(int client)
{
	Player player = new Player(client);
	
	if (player.IsInGame)
	{
		char text[64];
		Format(text, sizeof(text), g_bMC30IsColor ? "아래의 색깔을 입력하세요!" : "아래의 단어를 입력하세요!");
		player.SetCaption(text);
		
		SetHudTextParamsEx(-1.0, 0.26, 4.07, g_MC30Color, {0, 0, 0, 0}, 2, 0.0, 0.0, 0.0);
		//for(int i = 0; i < 5; i++)
		ShowSyncHudText(player.ClientId, g_hHudSyncColor, g_bMC30IsColor ? g_sMC30SayTextAnswers[g_iMC30Rng] : g_sMC30SayTextAnswers[g_iMC30Answer]);
	}
}

public Action MC30_OnChatMessage(int client, const char[] messageText, bool isTeamMessage)
{
	if (!g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}

	if (g_iActiveMinigameId != 30)
	{
		return Plugin_Continue;
	}

	Player invoker = new Player(client);

	if (!invoker.IsParticipating)
	{
		return Plugin_Continue;
	}

	if (strcmp(messageText, g_sMC30SayTextAnswers[g_iMC30Answer]) == 0 ||
	strcmp(messageText, g_sMC30SayTextAnswersEng[g_iMC30Answer]) == 0)
	{
		invoker.TriggerSuccess();

		if (!g_bMC30HasAnyPlayerWon && Config_BonusPointsEnabled())
		{
			invoker.Score++;
			g_bMC30HasAnyPlayerWon = true;

			MC30_NotifyFirstPlayerComplete(invoker);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

void MC30_NotifyFirstPlayerComplete(Player invoker)
{
	char name[64];
	
	if (invoker.Team == TFTeam_Red)
	{
		Format(name, sizeof(name), "{red}%N{default}", invoker.ClientId);
	}
	else if (invoker.Team == TFTeam_Blue)
	{
		Format(name, sizeof(name), "{blue}%N{default}", invoker.ClientId);
	}
	else
	{
		Format(name, sizeof(name), "{white}%N{default}", invoker.ClientId);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			player.PrintChatText("%T", "Minigame6_SayTheWord_PlayerSaidWordFirst", i, name);
		}
	}
}

void MC30_GetColor(int id)
{
	switch(id)
	{
		case 0:
		{
			g_MC30Color[0] = 255;
			g_MC30Color[1] = 0;
			g_MC30Color[2] = 0;
			g_MC30Color[3] = 255;
		}
		case 1:
		{
			g_MC30Color[0] = 252;
			g_MC30Color[1] = 161;
			g_MC30Color[2] = 3;
			g_MC30Color[3] = 255;
		}
		case 2:
		{
			g_MC30Color[0] = 252;
			g_MC30Color[1] = 240;
			g_MC30Color[2] = 3;
			g_MC30Color[3] = 255;
		}
		case 3:
		{
			g_MC30Color[0] = 4;
			g_MC30Color[1] = 173;
			g_MC30Color[2] = 46;
			g_MC30Color[3] = 255;
		}
		case 4:
		{
			g_MC30Color[0] = 0;
			g_MC30Color[1] = 101;
			g_MC30Color[2] = 209;
			g_MC30Color[3] = 255;
		}
		case 5:
		{
			g_MC30Color[0] = 152;
			g_MC30Color[1] = 50;
			g_MC30Color[2] = 219;
			g_MC30Color[3] = 255;
		}
		case 6:
		{
			g_MC30Color[0] = 255;
			g_MC30Color[1] = 255;
			g_MC30Color[2] = 255;
			g_MC30Color[3] = 255;
		}
		case 7:
		{
			g_MC30Color[0] = 255;
			g_MC30Color[1] = 138;
			g_MC30Color[2] = 249;
			g_MC30Color[3] = 255;
		}
	}
}