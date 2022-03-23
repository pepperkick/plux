#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <constants>  

#define PLUGIN_VERSION  "1.0.0"
#define DEBUG_TAG       "CYTOKINE"
#define MAX_PLAYERS     36
#define DEBUG

public Plugin:myinfo = {
	name = "Cytokine",
	author = "PepperKick",
	description = "Helper plugin for Qixalite's Cytokine",
	version = PLUGIN_VERSION,
	url = "http://pepperkick.com/"
};

ArrayList PlayerSteam;
StringMap PlayerName;
StringMap PlayerTeam;
StringMap PlayerClass;

Handle g_hcRestrictPlayers = INVALID_HANDLE;

public OnPluginStart() {	
    //Plugin Version ConVar
    CreateConVar(
        "cytokine_version",
        PLUGIN_VERSION,
        "Cytokine Plugin Version",
        FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY
    );


    // CVar to whether restrict players or not
    g_hcRestrictPlayers = CreateConVar(
		"qix_restrict_players",
		"0",
		"Should unknown players be restricted from joining the server?",
		FCVAR_NOTIFY | FCVAR_DONTRECORD
	);

    RegConsoleCmd("qix_add_player", Command_AddPlayer);
    RegConsoleCmd("qix_remove_player", Command_RemovePlayer);

    PlayerSteam = new ArrayList(MAX_PLAYERS);
    PlayerName = new StringMap();
    PlayerTeam = new StringMap();
    PlayerClass = new StringMap();
}

public void OnClientAuthorized(int client) {
    if (IsClientSourceTV(client)) {
        Log("Client is SourceTV, Ignoring...");
        return;
    }

    if (IsFakeClient(client)) {
        Log("Client is Bot, Ignoring...");
        return;
    }

    char steam[32];
    if (!GetClientAuthId(client, AuthId_SteamID64, steam, sizeof(steam))) {
        KickClient(client, "Unknown Steam ID");
        return;
    }

    if (PlayerSteam.FindString(steam) == -1 && GetConVarInt(g_hcRestrictPlayers) == 1) {
        KickClient(client, "You cannot join this server as you are not a part of this match.");
        return;
    }

    Log("Player Joined with id %s", steam);
}

public void OnClientPostAdminCheck(int client) {
    CreateTimer(1.0, CheckPlayer, client);
}

public Action Command_AddPlayer(int client, int args) {
    char steam[128], team[4], class[16], name[128];
    
    GetCmdArg(1, steam, sizeof(steam));
    GetCmdArg(2, team, sizeof(team));
    GetCmdArg(3, class, sizeof(class));
    GetCmdArg(4, name, sizeof(name));
    
    if (args > 4) {
        for (int i = 5; i <= args; i++) {
            char temp[128];
            GetCmdArg(i, temp, sizeof(temp));
            Format(name, sizeof(name), "%s %s", name, temp);
        }
    }

    if (PlayerSteam.FindString(steam) == -1) {
        PlayerSteam.PushString(steam);
    }

    if (StrEqual(team, "1", false)) {
        Format(team, sizeof(team), "%d", TEAM_RED);
    } else if (StrEqual(team, "2", false)){
        Format(team, sizeof(team), "%d", TEAM_BLU);
    }

    PlayerName.SetString(steam, name, true);
    PlayerTeam.SetString(steam, team, true);
    PlayerClass.SetString(steam, class, true);

    Log("Added Player %s with name '%s' for team %s and class %s", steam, name, team, class);

    return Plugin_Handled;
}

public Action Command_RemovePlayer(int client, int args) {
    char steam[128];    
    GetCmdArg(1, steam, sizeof(steam));

    for (int i = 0; i < PlayerSteam.Length; i++) {
        char p_steam[128];
        PlayerSteam.GetString(i, p_steam, sizeof(p_steam));

        if (StrEqual(steam, p_steam, false)) {
            PlayerSteam.Erase(i);
            PlayerName.SetString(steam, "", true);
            PlayerTeam.SetString(steam, "", true);
            PlayerClass.SetString(steam, "", true);
        }
    }

    Log("Removed Player %s", steam);

    return Plugin_Handled;
}

public Log(const char[] myString, any ...) {
    #if defined DEBUG
        int len = strlen(myString) + 255;
        char[] myFormattedString = new char[len];
        VFormat(myFormattedString, len, myString, 2);

        PrintToServer("[%s] %s", DEBUG_TAG, myFormattedString);
    #endif
}

public Action CheckPlayer(Handle timer, int client) {
    char steam[32], name[32], team[4], class[16];

    if (IsClientSourceTV(client)) {
        return;
    }

    if (IsFakeClient(client)) {
        return;
    }

    GetClientAuthId(client, AuthId_SteamID64, steam, sizeof(steam));

    if (PlayerSteam.FindString(steam) == -1) {
        return;
    }

    PlayerName.GetString(steam, name, sizeof(name));
    SetClientName(client, name);

    PlayerTeam.GetString(steam, team, sizeof(team));
    ChangeClientTeam(client, StringToInt(team));

    PlayerClass.GetString(steam, class, sizeof(class));
    TF2_SetPlayerClass(client, StringToInt(class));
}