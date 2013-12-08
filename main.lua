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
	MAX_RANGE = IniFile:GetValueSetI("General", "Range", 10)
	CHUNK_COMPISITION = IniFile:GetValueSet("Chunk", "Composition", "61x7;1x8")
	IniFile:WriteFile(Plugin:GetLocalFolder() .. "/Config.ini")
	
	CreateChunkData()
	
	LOG("Initialized LimitWorld")
	return true
end

function OnWorldTick(World, TimeDelta)
	WORLD_SPAWNS[World:GetName()] = Vector3d(math.floor(World:GetSpawnX() / 16), 0, math.floor(World:GetSpawnZ() / 16)) -- Get spawn chunks.
end

function OnSpawningEntity(World, Entity)
	if Entity:IsPlayer() then
		return false
	end
	local DistanceVector = (Vector3d(math.floor(Entity:GetPosX() / 16), 0, math.floor(Entity:GetPosZ() / 16)) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then
		return true -- Don't spawn any entities outside the range.
	end
end

function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if BlockX == -1 and BlockY == 255 and BlockZ == -1 then -- The client sends two packets. One with these coordinates. We don't want that one.
		return false
	end
	local World = Player:GetWorld()
	local DistanceVector = (Vector3d(math.floor(BlockX / 16), 0, math.floor(BlockZ / 16)) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then	
		return true
	end
end

function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	local World = Player:GetWorld()
	local DistanceVector = (Vector3d(math.floor(BlockX / 16), 0, math.floor(BlockZ / 16)) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then	
		return true
	end
end

function OnChunkGenerating(World, ChunkX, ChunkZ, ChunkDesc)
	local DistanceVector = (Vector3d(ChunkX, 0, ChunkZ) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then
		GenerateChunkOutOfRange(ChunkDesc) -- Generate the chunk as the user says we should generate it.
	end	
end

function OnPlayerMoving(Player)
	local World = Player:GetWorld()
	local WorldName = World:GetName()
	local PlayerChunk = Vector3d(Player:GetChunkX(), 0, Player:GetChunkZ())
	local PlayerCoords = Vector3d(Player:GetPosX(), 0, Player:GetPosZ())
	local DistanceVector = (PlayerChunk - WORLD_SPAWNS[WorldName])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE * 3 then 
		-- It's not worth calculating where the player should spawn since he is far behind the border. 
		--Just teleport him to spawn.
		Player:TeleportToCoords(World:GetSpawnX(), World:GetSpawnY(), World:GetSpawnZ())
	elseif Distance > MAX_RANGE then
		local NewCoords = PlayerCoords
		if DistanceVector.x > 0 then
			NewCoords.x = NewCoords.x - (Distance)
		else
			NewCoords.x = NewCoords.x + (Distance)
		end
		if DistanceVector.z > 0 then
			NewCoords.z = NewCoords.z - (Distance)
		else
			NewCoords.z = NewCoords.z + (Distance)
		end
		Player:TeleportToCoords(NewCoords.x, World:GetHeight(NewCoords.x, NewCoords.z) + 3, NewCoords.z)
	end
end

function CreateChunkData()
	local BlockArea = cBlockArea()
	local ChunkComposition = StringSplit(CHUNK_COMPISITION, ";")
	local Height = 0
	local Layers = {}
	for Index, Content in pairs(ChunkComposition) do -- Get the max height
		local Layer = StringSplit(Content, "x")
		if #Layer ~= 2 then -- It should be Hight|BlockTypeMeta. Now it is something else.
			LOGWARN("Something wrong in the composition. Skipping layer " .. Content)
		else
			Height = Height + Layer[1]
			table.insert(Layers, Layer)
		end
	end
	BlockArea:Create(16, Height, 16, 3) -- Create the BlockArea using the max height.
	local CurrentLayer = 0
	for Index, Content in pairs(Layers) do
		local BlockType, BlockMeta = GetBlockTypeMeta(Content[2])
		if not BlockType or not IsValidBlock(BlockType) then -- Skip this layer
			LOGWARN("There is something wrong in the composition. Skipping layer " .. Content[1] .. "x" .. Content[2])
		else
			BlockArea:FillRelCuboid(0, 15, CurrentLayer, CurrentLayer + Content[1] - 1, 0, 15, 3, BlockType, BlockMeta)
			CurrentLayer = CurrentLayer + Content[1]
		end
	end
	CHUNK_EMPTY_CHUNK_DATA:CopyFrom(BlockArea)
end

function GetBlockTypeMeta(Blocks)
	local Tonumber = tonumber(Blocks)
	if Tonumber == nil then	
		local Item = cItem()
		if StringToItem(Blocks, Item) == false then
			return false
		else
			return Item.m_ItemType, Item.m_ItemDamage
		end
		local Block = StringSplit(Blocks, ":")		
		if tonumber(Block[1]) == nil then
			return false
		else
			if Block[2] == nil then
				return Block[1], 0
			else
				return Block[1], Block[2]
			end
		end
	else
		return Tonumber, 0, true
	end
end

function GenerateChunkOutOfRange(ChunkDesc)
	ChunkDesc:SetUseDefaultBiomes(false)
	ChunkDesc:SetUseDefaultComposition(false)
	ChunkDesc:SetUseDefaultFinish(false)
	ChunkDesc:SetUseDefaultHeight(false)
	ChunkDesc:SetUseDefaultStructures(false)
	ChunkDesc:WriteBlockArea(CHUNK_EMPTY_CHUNK_DATA, 0, 0, 0)
end
			