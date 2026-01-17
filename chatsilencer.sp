#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

UserMsg g_msgSayText2;
UserMsg g_msgSayText;
UserMsg g_msgTextMsg;

public Plugin myinfo = {
    name = "Chat Silencer",
    author = "gloom",
    description = "Silences chat messages from plugins using the [BotManager] prefix",
    version = "2.3",
    url = ""
};

public void OnPluginStart()
{
    // Look up the IDs once and save them
    g_msgSayText2 = GetUserMessageId("SayText2");
    g_msgSayText = GetUserMessageId("SayText");
    g_msgTextMsg = GetUserMessageId("TextMsg");

    // Hook all chat-related usermessages
    HookUserMessage(g_msgSayText2, UserMessageHook, true);
    HookUserMessage(g_msgSayText, UserMessageHook, true);
    HookUserMessage(g_msgTextMsg, UserMessageHook, true);
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (StrContains(sArgs, "[BotManager]") != -1)
    {
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action UserMessageHook(UserMsg msg_id, Handle bf, const int[] players, int playersNum, bool reliable, bool init)
{
    char sBuffer[256];
    bool bFound = false;

    // Use if/else if instead of switch to compare runtime variables
    if (msg_id == g_msgSayText2)
    {
        // TF2 SayText2: Byte (Index), Byte (Type), String (Name), String (Message)
        BfReadByte(bf); // Index
        BfReadByte(bf); // Type
        
        // Check Name
        BfReadString(bf, sBuffer, sizeof(sBuffer));
        if (StrContains(sBuffer, "[BotManager]", false) != -1) bFound = true;
        
        // Check Message
        if (!bFound)
        {
            BfReadString(bf, sBuffer, sizeof(sBuffer));
            if (StrContains(sBuffer, "[BotManager]", false) != -1) bFound = true;
        }
    }
    else if (msg_id == g_msgSayText)
    {
        // SayText: Byte (Index), String (Message)
        BfReadByte(bf); // Index
        
        BfReadString(bf, sBuffer, sizeof(sBuffer));
        if (StrContains(sBuffer, "[BotManager]", false) != -1) bFound = true;
    }
    else if (msg_id == g_msgTextMsg)
    {
        // TextMsg: Byte (Dest), String (Param1), String (Param2), String (Param3)...
        BfReadByte(bf); // Dest
        
        // Read up to 3 parameters
        for (int i = 0; i < 3; i++)
        {
            if (BfReadString(bf, sBuffer, sizeof(sBuffer)) > 0)
            {
                if (StrContains(sBuffer, "[BotManager]", false) != -1)
                {
                    bFound = true;
                    break;
                }
            }
        }
    }

    if (bFound)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
}