
#define PLUGIN_VERSION "1.0.0"
public Plugin:myinfo =
{
	name = "Rainbow Dash Likes Girls",
	author = "Chamamyungsu",
	description = "Unknown",
	version = PLUGIN_VERSION,
	url = "http://cafe.naver.com/sourcemulti"
};

#pragma semicolon 1
#include <sourcemod>
#include "Renard"

#define MaxLength 12

public OnPluginStart()
{
	CreateConVar("sm_Rainbow_Dash_Likes_Girls", PLUGIN_VERSION, "Made By Chamamyungsu", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegConsoleCmd("sm_encrypt", Command_encrypt, "");
	RegConsoleCmd("sm_decrypt", Command_decrypt, "");
}

//0000000
public Action:Command_encrypt(client, Arguments)
{
	if(Arguments < 1)
	{
		PrintToChat(client, "\x04Usage : !encrypt words(MaxLength : %d)", MaxLength);
		return Plugin_Handled;
	}
	
	new String:ScanChar[256], String:MainChar[256], String:OriginalChar[256], String:DoNotDecompile[256];
	GetCmdArg(1, ScanChar, sizeof(ScanChar));
	
	Format(DoNotDecompile, sizeof(DoNotDecompile), "Do..not..decompile..sigh.. - Made by Chamamyungsu");
	if(StrContains(ScanChar[0], MyLittlePony[0][0]) == 0)
		TrimString(DoNotDecompile);

	//암호화를 하기전, 조건에 적합한지 체크합니다.
	for(new i=0; i<strlen(ScanChar); i++)
	{
		if(!IsCharAlpha(ScanChar[i]) && !IsCharNumeric(ScanChar[i]))
		{
			PrintToChat(client, "Alphabet and number use only.");
			return Plugin_Handled;
		}
	}
	if(strlen(ScanChar) > MaxLength)
	{
		PrintToChat(client, "input words are shorter than %d-character.", MaxLength);
		return Plugin_Handled;
	}
	strcopy(OriginalChar, sizeof(OriginalChar), ScanChar);

	//암호화를 시작합니다.
	for(new i=0; i<MaxLength; i++)
	{
		new Chartemp, String:TempChar[48], bool:charisnotprime = false, temp, numtemp, firstrandomint = GetRandomInt(1, 46), secondrandomint = GetRandomInt(1, 46), thirdrandomint = GetRandomInt(1, 46);
		if(!(i<strlen(OriginalChar)))
		{
			new RandomChar = GetRandomInt(1, 2);
			if(RandomChar == 1)
				Format(ScanChar, sizeof(ScanChar), "%s%s", ScanChar, Renard[GetRandomInt(0, sizeof(Renard)-1)][0]);
			else
				Format(ScanChar, sizeof(ScanChar), "%s%s", ScanChar, MyLittlePony[GetRandomInt(0, sizeof(MyLittlePony)-1)][0]);
		}
		if(IsCharAlpha(ScanChar[i]))
		{
			for(new j=0; j<sizeof(MyLittlePony); j++)
			{
				if(StrContains(ScanChar[i], MyLittlePony[j][0]) == 0)
				{
					Chartemp = StringToInt(MyLittlePony[j][1]);
					break;
				}
			}
		}
		else
		{
			for(new j=0; j<sizeof(Renard); j++)
			{
				if(StrContains(ScanChar[i], Renard[j][0]) == 0)
				{
					Chartemp = StringToInt(Renard[j][1]);
					break;
				}
			}
		}
		if(i > 0)
		{
			for(new j=2; j<i+1; j++)
			{
				if((i+1)%j == 0)
				{
					charisnotprime = true;
					break;
				}
			}
		}
		else
			charisnotprime = true;

		numtemp = (RoundToNearest(Pow(2.0, float(strlen(OriginalChar))))*Chartemp)+(charisnotprime == false ? -2 : 1)+firstrandomint+secondrandomint+thirdrandomint;
		new whiletemp = numtemp;
		while(whiletemp > 0)
		{
			whiletemp /= 16;
			temp++;
		}

		if(i<strlen(OriginalChar))
			Format(TempChar, sizeof(TempChar), "%s", MyLittlePony[firstrandomint+5][0]);
		else
			Format(TempChar, sizeof(TempChar), "%x", GetRandomInt(0,15));
		Format(TempChar, sizeof(TempChar), "%s%s", TempChar, MyLittlePony[secondrandomint+5][0]);
		if(temp < 5)
		{
			Format(TempChar, sizeof(TempChar), "%s%s", TempChar, MyLittlePony[thirdrandomint+5][0]);
			for(new j=4-temp; j>0; j--)
				Format(TempChar, sizeof(TempChar), "%s%s", TempChar, MyLittlePony[GetRandomInt(1, 46)+5][0]);
		}
		else
			numtemp -= thirdrandomint;
		Format(TempChar, sizeof(TempChar), "%s%x", TempChar, numtemp);
		Format(MainChar, sizeof(MainChar), "%s%s", MainChar, TempChar);
	}
	PrintToChat(client, "\x04 Encrypt complete! Input : \x01%s", OriginalChar);
	PrintToChat(client, "\x04 Results : \x01%s", MainChar);
	return Plugin_Continue;
}

public Action:Command_decrypt(client, Arguments)
{
	if(Arguments < 1)
	{
		PrintToChat(client, "\x04Usage : !decrypt Encryptwords");
		return Plugin_Handled;
	}
	
	new String:ScanChar[256], String:MainChar[256], Length = 0, String:DoNotDecompile[256];
	GetCmdArg(1, ScanChar, sizeof(ScanChar));
	
	Format(DoNotDecompile, sizeof(DoNotDecompile), "Do..not..decompile..sigh.. - Made by Chamamyungsu");
	if(StrContains(ScanChar[0], MyLittlePony[0][0]) == 0)
		TrimString(DoNotDecompile);

	//해독을 하기전, 조건에 적합한지 체크합니다.
	if(!(strlen(ScanChar)%7 == 0))
	{
		PrintToChat(client, "Is not in the correct format. (Error code : 05:%d)", strlen(ScanChar));
		return Plugin_Handled;
	}

	if(strlen(ScanChar)/7 != MaxLength)
	{
		PrintToChat(client, "Is not in the correct format. (Error code : 25:%d)", strlen(ScanChar)/7);
		return Plugin_Handled;
	}
	
	for(new h=0; h<strlen(ScanChar)/7; h++)
	{
		if(IsCharAlpha(ScanChar[h*7]))
		{
			for(new i=6; i<sizeof(MyLittlePony); i++)
			{
				if(StrContains(ScanChar[h*7], MyLittlePony[i][0]) == 0)
				{
					Length += 1;
					break;
				}
			}
		}
	}

	//암호화된 문자를 해독합니다.
	for(new h=1; h<=strlen(ScanChar)/7; h++)
	{
		new String:CharTemp[12], IntTemp, bool:charisnotprime = false, firstrandomint, secondrandomint, thirdrandomint, xtemp, fakenumtemp;
		xtemp = (h-1)*7;
		for(new i=xtemp; i<=6+xtemp; i++)
		{
			new bool:AlphaCheck = false;
			if(IsCharAlpha(ScanChar[i]))
			{
				for(new j=6; j<sizeof(MyLittlePony); j++)
				{
					if(StrContains(ScanChar[i], MyLittlePony[j][0]) == 0)
					{
						AlphaCheck = true;
						if(firstrandomint == 0)
							firstrandomint = j;
						else if(secondrandomint == 0)
							secondrandomint = j;
						else if(thirdrandomint == 0)
							thirdrandomint = j;
						break;
					}
				}
				if(firstrandomint == 0 && AlphaCheck == false)
				{
					fakenumtemp = 1;
					break;
				}
			}
			else if(firstrandomint == 0)
			{
				fakenumtemp = 1;
				break;
			}
			if(AlphaCheck == false && fakenumtemp == 0)
			{
				new hexnumtemp;
				if(IsCharAlpha(ScanChar[i]))
				{
					for(new k=0; k<=5; k++)
					{
						new String:Hextemp[2];
						Format(Hextemp, sizeof(Hextemp), "%x", k+10);
						if(StrContains(ScanChar[i], Hextemp) == 0)
							hexnumtemp = k+10;
					}
				}
				else
				{
					new String:Hextemp[2];
					Format(Hextemp, sizeof(Hextemp), "%c", ScanChar[i]);
					hexnumtemp = StringToInt(Hextemp);
				}
				if(i < 6+xtemp)
					hexnumtemp = hexnumtemp*(RoundToNearest(Pow(16.0, float(6+xtemp-i))));
				IntTemp += hexnumtemp;
			}
		}

		if(fakenumtemp == 0)
		{
			if(h > 1)
			{
				for(new j=2; j<h; j++)
				{
					if(h%j == 0)
					{
						charisnotprime = true;
						break;
					}
				}
			}
			else
				charisnotprime = true;
			IntTemp -= firstrandomint-5+(secondrandomint > 0 ? secondrandomint-5 : 0)+(thirdrandomint > 0 ? thirdrandomint-5 : 0)+(charisnotprime == false ? -2 : 1);
			IntTemp = IntTemp/RoundToNearest(Pow(2.0, float(Length)));
			
			if(IntTemp == 0)
			{
				PrintToChat(client, "Is not in the correct format. (Error code : 20:%d)", h);
				return Plugin_Handled;
			}
			
			if(IntTemp > sizeof(Renard)+sizeof(MyLittlePony) || IntTemp < 1)
			{
				PrintToChat(client, "Is not in the correct format. (Error code : 15:%d)", IntTemp);
				return Plugin_Handled;
			}
			
			if(firstrandomint == 0)
			{
				PrintToChat(client, "Is not in the correct format. (Error code : 10:%d)", firstrandomint);
				return Plugin_Handled;
			}

			new RenardCheck;
			for(new j=0; j<sizeof(MyLittlePony); j++)
			{
				if(IntTemp == StringToInt(MyLittlePony[j][1]))
				{
					RenardCheck = 1;
					Format(CharTemp, sizeof(CharTemp), "%s", MyLittlePony[j][0]);
					break;
				}
			}
			if(RenardCheck == 0)
			{
				for(new j=0; j<=9; j++)
				{
					if(IntTemp == StringToInt(Renard[j][1]))
					{
						Format(CharTemp, sizeof(CharTemp), "%s", Renard[j][0]);
						break;
					}
				}
			}
			Format(MainChar, sizeof(MainChar), "%s%c", MainChar, CharTemp);
		}
	}

	PrintToChat(client, "\x04 Decrypt Complete! Input : \x01%s", ScanChar);
	PrintToChat(client, "\x04 Results : \x01%s", MainChar);
	return Plugin_Continue;
}