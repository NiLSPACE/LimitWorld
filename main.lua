---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------


MAX_RANGE = 10 -- The default range
WORLD_SPAWNS = {} -- Table were all the coordinates for every world's spawn go.
CHUNK_EMPTY_CHUNK_DATA = cBlockArea() -- This wil eventualy become the composition of a chunk that is not in range.
CHUNK_COMPISITION = "" -- This string is where the user input for the composition will come.

function Initialize(Plugin)
	PLUGIN = Plugin
	Plugin:SetName("LimitWorld")
	Plugin:SetVersion(1)
	
	cPluginManager.AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
	cPluginManager.AddHook(cPluginManager.HOOK_SPAWNING_ENTITY, OnSpawningEntity)
	
	cPluginManager.AddHook(cPluginManager.HOOK_WORLD_TICK, OnWorldTick) -- Needed to check the spawn of each world.
	local IniFile = cIniFile()
	if not (IniFile:ReadFile(Plugin:GetLocalFolder() .. "/Config.ini")) then
		LOGWARN("[LIMITWORLD] Could not read the config file. Using default!")
	end
	MAX_RANGE = IniFile:GetValueSetF("General", "Range", 10)
	CHUNK_COMPISITION = IniFile:GetValueSet("Chunk", "Composition", "61x7;1x8")
	IniFile:WriteFile(Plugin:GetLocalFolder() .. "/Config.ini")
	
	CreateChunkData()
	
	LOG("Initialized LimitWorld")
	return true
end