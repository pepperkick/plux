#pragma semicolon 1
#include <sourcemod>
#include <tf2>

public Plugin:myinfo =
{
	name = "Config Alias",
	author = "PepperKick",
	description = "Override exec command to support alias",
	version = "0.1.0",
	url = "https://pepperkick.com"
};

new String:alias[512][256];
new String:config[512][256];
int index = 0;

public OnPluginStart() {
	RegServerCmd("exec", HandleExecAction);

	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, PLATFORM_MAX_PATH, "configs/configalias.txt");
	new Handle:configFileHandle = OpenFile(path, "r");

	while (!IsEndOfFile(configFileHandle)) {
		new String:line[512];
		new String:parts[2][256];
		ReadFileLine(configFileHandle, line, sizeof(line));

		if (StrEqual(line, "", false)) {
			continue;
		}

		if (StrContains(line, "#", false) != -1) {
			continue;
		}

		ExplodeString(line, "=", parts, 2, 256);
		TrimString(parts[0]);
		if (StrEqual(parts[0], "", false)) {
			continue;
		}

		TrimString(parts[1]);
		if (StrEqual(parts[1], "", false)) {
			continue;
		}

		PrintToServer("%s -> %s", parts[0], parts[1]);
		alias[index] = parts[0];
		config[index] = parts[1];
		index = index + 1;
	}
}

public Action:HandleExecAction(args) {
	new String:arg[128];
	GetCmdArg(1, arg, sizeof(arg));

	for (int i = 0; i < index; i++) {
		if (StrEqual(arg, alias[i], false)) {
			PrintToServer("Overriding %s with %s...", alias[i], config[i]);
			ServerCommand("exec %s", config[i]);
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}
