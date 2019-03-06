
--[[
	Quick Cash

	Originally By Juna
	Maintained By Arnvid Karstad - ievil - Asys @ Turalyon_EU

	Adds a little strip of a window which is a functioning cash display.

	Thanks to sarf for the Rogue Helper code which was very informative and useful.	
	Some utility type code is directly from RogueHelper (hope thats ok).
	Also thanks to Trentin for MonkeyQuest which I had a gander at.

	- V1.1 
	
	Revised by Outshynd
	Added character+realm specific settings
	
	- V1.7.00 (ACUI)
	
	Revised and fixed for 1700 compability

	- V2.0 (ACUI)
	
	Fixed the loading of variables and data. Hopefully will work better now.
	Thanx to Norganna for fixing this in Gatherer so I could learn this from him

	- V2.1 (ACUI-0.5.0)
	
	Fixed the loading of variables and data. Hopefully will work better now.
	Thanx to Norganna for fixing this in Gatherer so I could learn this from him

	- V2.2 (ACUI-0.6.0)
	
	Bumped config and toc for 11100 - tested and works

	- V3.0.2.0 (ACUI-N/A)
	
	Bumped config and toc for 30000 
	Updated code for WOTLK compability.

	
   ]]

-- VARIABLES

local playerName = nil;
local QuickCash_Loaded = nil;

function QuickCash_initialize()
	SlashCmdList["QUICKCASH"] = QuickCash_command;
	SLASH_QUICKCASH1 = "/quickcash";
	SLASH_QUICKCASH2 = "/qc";
end

function QuickCash_Extract_NextParameter(msg)
	local params = msg;
	local command = params;
	local index = strfind(command, " ");
	if ( index ) then
		command = strsub(command, 1, index-1);
		params = strsub(params, index+1);
	else
		params = "";
	end
	return command, params;
end

function QuickCash_command(msg)
-- this function handles our chat command

	if ( ( not msg) or ( strlen(msg) <= 0 ) ) then
		DEFAULT_CHAT_FRAME:AddMessage( "QuickCash commands: /quickcash or /qc" );
		DEFAULT_CHAT_FRAME:AddMessage( "/quickcash show, /quickcash hide, /qc alpha <number>, /qc borderalpha <number>" );
		DEFAULT_CHAT_FRAME:AddMessage( "/qc lock, /qc unlock, /qc stick (stick to mouse)" );
		return;
	end

	local command, params = QuickCash_Extract_NextParameter(msg);

	if (command == "hide") then
		QuickCashFrame:Hide();
		QuickCash_State[playerName].Visible = 0;
		DEFAULT_CHAT_FRAME:AddMessage( "QuickCash is now hidden." );
		return;
	end 

	if (command == "show") then
		QuickCashFrame:Show();
		QuickCash_State[playerName].Visible = 1;
		DEFAULT_CHAT_FRAME:AddMessage( "QuickCash is now visible." );
		return;	
	end

	if (command == "refresh") then
		QuickCashFrame:Hide();
		QuickCashFrame:Show();
		return;	
	end

	if (command == "stick") then
		QuickCashFrame:StartMoving();
		DEFAULT_CHAT_FRAME:AddMessage( "QuickCash will now move with the mouse. use /qc unstick or if you started with the mouse over QC you can click to stop." );
		return;	
	end

	if (command == "unstick") then
		QuickCashFrame:StopMovingOrSizing();
		DEFAULT_CHAT_FRAME:AddMessage( "QuickCash unstuck." );
		return;	
	end

	if (command == "lock") then
		QuickCash_State[playerName].Locked = 1;
		DEFAULT_CHAT_FRAME:AddMessage( "Quick Cash is now locked in place." );
		return;	
	end

	if (command == "unlock") then
		QuickCash_State[playerName].Locked = 0;
		DEFAULT_CHAT_FRAME:AddMessage( "Quick Cash is now draggable." );
		return;	
	end

	if (command == "alpha") then
		if ( params ) then
			QuickCash_SetAlpha(params);
			QuickCash_State[playerName].Alpha = params;
			DEFAULT_CHAT_FRAME:AddMessage( "Quick Cash alpha is now "..params.."." );
			return;
		end
	end

	if (command == "borderalpha") then
		if ( params ) then
			QuickCash_SetBorderAlpha(params);
			QuickCash_State[playerName].BorderAlpha = params;
			DEFAULT_CHAT_FRAME:AddMessage( "Quick Cash borderalpha is now "..params.."." );
			return;
		end
	end

	DEFAULT_CHAT_FRAME:AddMessage( "QuickCash commands: /quickcash or /qc" );
	DEFAULT_CHAT_FRAME:AddMessage( "/quickcash show, /quickcash hide, /qc alpha <number>, /qc borderalpha <number>" );
	DEFAULT_CHAT_FRAME:AddMessage( "/qc lock, /qc unlock, /qc stick (stick to mouse)" );
			

end 


function QuickCash_Window_GetDragFrame()
	return QuickCashFrame;
end

function QuickCash_Window_OnMouseDown(arg1)
	
	if ( arg1 == "LeftButton" and QuickCash_State[playerName].Locked == 0 ) then
		QuickCashFrame:StartMoving();
	end
end

function QuickCash_Window_OnMouseUp(arg1)

	if (arg1 == "LeftButton") then
		QuickCashFrame:StopMovingOrSizing();
	end

end

function QuickCash_Window_OnLoad()
	this:RegisterForDrag("LeftButton");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UNIT_NAME_UPDATE");
	QuickCashFrame:Show();
end

function QuickCash_WindowMoney_OnLoad()


end

function QuickCash_WindowMoney_initialize()
	MoneyFrame_SetType(QuickCashFrameMoneyFrame, "PLAYER");
	MoneyFrame_UpdateMoney(QuickCashFrameMoneyFrame);		
end

function QuickCash_Window_OnEvent(event)
	if (event == "VARIABLES_LOADED") then
		QuickCash_Loaded = 1;
		if( not QuickCash_State ) then
			QuickCash_State = {};
		end
	end
	if (not QuickCash_Loaded) then
		return;
	end
	
	if ( event == "UNIT_NAME_UPDATE" and arg1 == "player" and UnitName("player") ~= UNKNOWNOBJECT) then
		playerName = UnitName("player").." of "..GetCVar("realmName");
	elseif ( event == "PLAYER_ENTERING_WORLD") then
		if ( not playerName) then
			playerName = UnitName("player").." of "..GetCVar("realmName");
		end
		if ( not QuickCash_State[playerName] ) then
			QuickCash_State[playerName] = {}; 
			QuickCash_State[playerName].Visible = 1; 
			QuickCash_State[playerName].Alpha = "0"; 
			QuickCash_State[playerName].BorderAlpha = "0"; 
			QuickCash_State[playerName].Locked = 0; 
			QuickCashFrame:Show(); 
			QuickCash_SetAlpha(QuickCash_State[playerName].Alpha); 
			QuickCash_SetBorderAlpha(QuickCash_State[playerName].BorderAlpha); 
			DEFAULT_CHAT_FRAME:AddMessage( "QuickCash Loaded with default settings!" ); 
		else 
			if ( QuickCash_State[playerName].Visible == 1 ) then 
				QuickCashFrame:Hide();
				QuickCashFrame:Show();
				QuickCash_SetAlpha(QuickCash_State[playerName].Alpha); 
				QuickCash_SetBorderAlpha(QuickCash_State[playerName].BorderAlpha);
			end
		end
		DEFAULT_CHAT_FRAME:AddMessage( "QuickCash Loaded with "..playerName.." profile." );
	end
end

-- Set the opacity of the background
function QuickCash_SetAlpha(alpha)
	QuickCashFrame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b, alpha);
end

-- Set the opacity of the border
function QuickCash_SetBorderAlpha(alpha)
	QuickCashFrame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, alpha);
end
