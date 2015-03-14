---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------


g_MaxRange         = 10 -- The default range
g_WorldSpawns      = {} -- Table were all the coordinates for every world's spawn go.
g_ChunkComposition = cBlockArea() -- This wil eventualy become the composition of a chunk that is not in range.
g_PosCheckIsInside = nil -- The function that checks if a position in a world is inside the world limit

function Initialize(Plugin)
	PLUGIN = Plugin
	Plugin:SetName("LimitWorld")
	Plugin:SetVersion(1)
	
	cPluginManager.AddHook(cPluginManager.HOOK_CHUNK_GENERATING, OnChunkGenerating)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, OnPlayerBreakingBlock)
	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
	cPluginManager.AddHook(cPluginManager.HOOK_SPAWNING_ENTITY, OnSpawningEntity)
	
	LoadConfig()
	
	InitShape()
	
	CreateChunkData(g_Config.Chunk.ChunkComposition)
	
	LOG("Initialized LimitWorld")
	return true
end