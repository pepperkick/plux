#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.0.1"

public Plugin:myinfo = {
	name = "Information",
	author = "PepperKick",
	description = "Stroe essential server information in a file",
	version = PLUGIN_VERSION,
	url = "http://pepperkick.com/"
};

new Handle:g_hCvarServerIp;
new Handle:g_hCvarServerPort;
new Handle:g_hCvarPassword;
new Handle:g_hCvarRconPassword;
new Handle:g_hCvarTvPassword;

public OnPluginStart() {
    g_hCvarServerIp = FindConVar("ip");
    g_hCvarServerPort = FindConVar("hostport");
    g_hCvarPassword = FindConVar("sv_password");
    g_hCvarRconPassword = FindConVar("rcon_password");
    g_hCvarTvPassword = FindConVar("tv_password");

    HookConVarChange(g_hCvarPassword, OnConvarChange);
    HookConVarChange(g_hCvarRconPassword, OnConvarChange);
    HookConVarChange(g_hCvarTvPassword, OnConvarChange);

    WriteToFile();
}

public void OnConvarChange(Handle cvar, const char[] oldvalue, const char[] newvalue) {
    WriteToFile();
}

public void OnClientPostAdminCheck(int client) {
    PrintToServer("[INFO] Player connected");
    WriteToFile();
}

public void OnClientDisconnect_Post(int client) {
    PrintToServer("[INFO] Player disconnected");
    WriteToFile();
}

WriteToFile() {
    PrintToServer("[INFO] Writing to file");
    new File:hFile = OpenFile("server.info", "w");

    // Read data from convars
    decl String:server_ip[64], String:server_port[64], String:password[64], String:rcon_password[64], String:tv_password[64];
    GetConVarString(g_hCvarServerIp, server_ip, sizeof(server_ip));
    GetConVarString(g_hCvarServerPort, server_port, sizeof(server_port));
    GetConVarString(g_hCvarPassword, password, sizeof(password));
    GetConVarString(g_hCvarTvPassword, tv_password, sizeof(tv_password));
    GetConVarString(g_hCvarRconPassword, rcon_password, sizeof(rcon_password));

    // Write convars data to file    
    hFile.WriteLine("server_ip: %s", server_ip);
    hFile.WriteLine("server_port: %s", server_port);
    hFile.WriteLine("password: %s", password);
    hFile.WriteLine("tv_password: %s", tv_password);
    hFile.WriteLine("rcon_password: %s", rcon_password);

    hFile.WriteLine("");

    // Get steamid and name of all players
    for (new i = 1; i <= MaxClients; i++) {
        if (IsClientInGame(i)) {
            decl String:steamid[64], String:name[64], String:ip[64];
            GetClientAuthId(i, AuthId_Steam3, steamid, sizeof(steamid));
            GetClientName(i, name, sizeof(name));
            GetClientIP(i, ip, sizeof(ip));
            hFile.WriteLine("connected_player: %d %s \"%s\" %s", GetClientUserId(i), steamid, name, ip);
        }
    }

    PrintToServer("[INFO] Done writing to file");
    hFile.Flush();
    hFile.Close();
}