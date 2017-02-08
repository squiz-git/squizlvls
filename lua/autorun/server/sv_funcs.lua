--[[

	SquizLvls
	Made by Squiz - Last Update: 8/2/17

	-- To:Do
	
	Add Items that you need to be > Lvl to use.
	Add Rest of Levels
	Add GUI 
	Find Firework Effect
	Add Perks for Every X Levels
	
	
]]--


function tables_exist()
	if sql.TableExists("squiz_db") then
	   	Msg("Squiz_DB Exists.")
	else
	    sql.Query("CREATE TABLE squiz_db ( unique_id varchar(255), lvl int, xp int )")
	end
end

function new_player( SteamID, ply )
 
	steamID = SteamID
	sql.Query( "INSERT INTO squiz_db (`unique_id`, `lvl`, `xp`)VALUES ('"..steamID.."', '1', '1')" )
	result = sql.Query( "SELECT unique_id, lvl, xp FROM squiz_db WHERE unique_id = '"..steamID.."'" )
	   	   
	if (result) then
	
	   	sql.Query( "INSERT INTO squiz_db (`unique_id`, `lvl`, `xp`)VALUES ('"..steamID.."', '1', '1', '1')" )
	   	result = sql.Query( "SELECT unique_id, lvl, xp FROM squiz_db WHERE unique_id = '"..steamID.."'" ) 
		
			if (result) then
				Msg("Player account created !\n")
				sql_value_stats( ply )
				sql_value_skills( ply )
			else
				Msg("Something went wrong with creating a players skills !\n")
			end 
    else
	   	Msg("Something went wrong with creating a players info !\n")
	end	   
end
 
function player_exists( ply )
	
	steamID = ply:GetNWString("SteamID")
	result = sql.Query("SELECT unique_id, lvl, xp FROM squiz_db WHERE unique_id = '"..steamID.."'")
    
    if (result) then
	   	sql_value_skills( ply ) // We will call this to retrieve the skills
	else
	   	new_player( steamID, ply ) // Create a new player :D
    end
end
 
function PlayerInitialSpawn( ply )
 
	   timer.Create("Steam_id_delay", 1, 1, function()
	   	   SteamID = ply:SteamID()
	   	   ply:SetNWString("SteamID", SteamID)
	   	   timer.Create("SaveStat", 10, 0, function() saveStat( ply ) end)
	   	   player_exists( ply ) 
	   end)
 
end

function sql_value_skills ( ply )
	unique_id = sql.QueryValue("SELECT unique_id FROM squiz_db WHERE unique_id = '"..steamID.."'")
	lvl = sql.QueryValue("SELECT lvl FROM squiz_db WHERE unique_id = '"..steamID.."'")
	xp = sql.QueryValue("SELECT xp FROM squiz_db WHERE unique_id = '"..steamID.."'")
	ply:SetNWString("unique_id", unique_id)
	ply:SetNWInt("lvl", lvl)
	ply:SetNWInt("xp", xp)
end
 
function saveStat ( ply )
	lvl = ply:GetNWInt("lvl")
	unique_id = ply:GetNWString ("SteamID")
	xp = ply:GetNWInt("xp")
	sql.Query("UPDATE squiz_db SET xp = "..xp.." WHERE unique_id = '"..unique_id.."'")
	sql.Query("UPDATE squiz_db SET lvl = "..lvl.." WHERE unique_id = '"..unique_id.."'")
end

hook.Add( "PlayerInitialSpawn", "PlayerInitialSpawn", PlayerInitialSpawn )
hook.Add( "Initialize", "Initialize", Initialize )
 
function Initialize()
    tables_exist()
end

local xpTable = {140}
local ExpMultiplier = 140

// Genlevels
for i=2,100 do
	ExpMultiplier = math.Round ( ExpMultiplier + math.Clamp( ExpMeme*0.4 , 0, 10000 ) )
	xpTable[i] = ExpMeme
end

function CheckLevel(ply)
	
	local xp = GetXP(ply)
	
	foreach level,lxp in pairs( xpTable ) do
		
		if xp >= lxp and xp < xpTable[level+1] then
			SetLvl(ply,level)
		end
	end
end

function LvlUp(ply)

	lvl = sql.QueryValue("SELECT lvl FROM squiz_db WHERE unique_id = '"..steamID.."'")
	lvl = lvl+1
	ply:PrintMessage(HUD_PRINTTALK,"You've leveled up your current level is now: "..lvl)
	ply:SetNWInt("lvl", lvl)
	saveStat(ply)
	
    -- Leveling Effect

    local vPoint = ply:GetPos()
    ParticleEffect( "party_fireworks", Vector(vPoint.x,vPoint.y,vPoint.z+40), Angle(0,0,0), ply )
    ply:EmitSound("ui/achievement_earned.wav")

end

function SetLvl(ply,lvlset)

	lvl = sql.QueryValue("SELECT lvl FROM squiz_db WHERE unique_id = '"..steamID.."'")
	lvl = lvlset
	ply:PrintMessage(HUD_PRINTTALK,"You've leveled up your current level is now: "..lvl)
	ply:SetNWInt("lvl", lvl)
	saveStat(ply)
	
    -- Leveling Effect

    local vPoint = ply:GetPos()
    ParticleEffect( "party_fireworks", Vector(vPoint.x,vPoint.y,vPoint.z+40), Angle(0,0,0), ply )
    ply:EmitSound("ui/achievement_earned.wav")

end

function GiveXP(ply,xpearned)

	xp = sql.QueryValue("SELECT xp FROM squiz_db WHERE unique_id = '"..steamID.."'")
	xp = xp+xpearned
	ply:SetNWInt("xp", xp)
	CheckLevel(ply)
	saveStat(ply)
	
end

function SetXP(ply,xpset)

	xp = sql.QueryValue("SELECT xp FROM squiz_db WHERE unique_id = '"..steamID.."'")
	xp = xpset
	ply:SetNWInt("xp", xp)
	ply:PrintMessage(HUD_PRINTTALK,xpset.. " XP Set for ".. ply:Nick() .. "." )
	--CheckLevel(ply)
	saveStat(ply)
	
end
