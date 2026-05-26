#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
    name = "tele command",
    author = "coah & GoogleAI",
    description = "Flexible teleport syntax supporting character names and IDs.",
    version = "1.3",
    url = ""
};

public void OnPluginStart()
{
    RegAdminCmd("sm_tele", Command_CustomTele, ADMFLAG_GENERIC, "Usage: !tele <target> <destination>");
}

public Action Command_CustomTele(int client, int args)
{
    if (client == 0 || !IsClientInGame(client))
    {
        return Plugin_Handled;
    }

    if (args < 2)
    {
        return Plugin_Handled;
    }

    char arg1[64], arg2[64];
    GetCmdArg(1, arg1, sizeof(arg1));
    GetCmdArg(2, arg2, sizeof(arg2));

    int target_client = -1;
    if (StrEqual(arg2, "me", false))
    {
        target_client = client;
    }
    else
    {
        target_client = FindTargetCustom(arg2);
    }

    if (target_client == -1 || !IsClientInGame(target_client) || !IsPlayerAlive(target_client))
    {
        return Plugin_Handled;
    }

    float pos[3], ang[3];
    GetClientAbsOrigin(target_client, pos);
    GetClientAbsAngles(target_client, ang);

    if (StrEqual(arg1, "all", false) || StrEqual(arg1, "survivor", false))
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && i != target_client)
            {
                TeleportEntity(i, pos, ang, NULL_VECTOR);
            }
        }
    }
    else if (StrEqual(arg1, "bot", false) || StrEqual(arg1, "bots", false))
    {
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientInGame(i) && IsPlayerAlive(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && i != target_client)
            {
                TeleportEntity(i, pos, ang, NULL_VECTOR);
            }
        }
    }
    else if (StrEqual(arg1, "me", false))
    {
        if (client != target_client)
        {
            TeleportEntity(client, pos, ang, NULL_VECTOR);
        }
    }
    else
    {
        int p_target = FindTargetCustom(arg1);
        if (p_target != -1 && IsClientInGame(p_target) && IsPlayerAlive(p_target) && p_target != target_client)
        {
            TeleportEntity(p_target, pos, ang, NULL_VECTOR);
        }
    }

    return Plugin_Handled;
}

int FindTargetCustom(const char[] input)
{
    int userid = StringToInt(input);
    if (userid > 0)
    {
        int client = GetClientOfUserId(userid);
        if (client > 0 && IsClientInGame(client))
        {
            return client;
        }
    }

    char model[128], name[MAX_NAME_LENGTH];
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i))
        {
            GetClientName(i, name, sizeof(name));
            if (StrContains(name, input, false) != -1)
            {
                return i;
            }

            if (GetClientTeam(i) == 2)
            {
                GetClientModel(i, model, sizeof(model));
                if (StrContains(model, input, false) != -1)
                {
                    return i;
                }
            }
        }
    }
    return -1;
}
