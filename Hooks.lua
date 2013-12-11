---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------


function OnWorldTick(World, TimeDelta)
	WORLD_SPAWNS[World:GetName()] = Vector2d(math.floor(World:GetSpawnX() / 16), math.floor(World:GetSpawnZ() / 16)) -- Get spawn chunks.
end

function OnSpawningEntity(World, Entity)
	if Entity:IsPlayer() then
		return false
	end
	local DistanceVector = (Vector2d(Entity:GetChunkX(), Entity:GetChunkZ()) - WORLD_SPAWNS[World:GetName()])
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
	local DistanceVector = (Vector2d(math.floor(BlockX / 16), math.floor(BlockZ / 16)) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then	
		return true
	end
end

function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	local World = Player:GetWorld()
	local DistanceVector = (Vector2d(math.floor(BlockX / 16), math.floor(BlockZ / 16)) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then	
		return true
	end
end

function OnChunkGenerating(World, ChunkX, ChunkZ, ChunkDesc)
	local DistanceVector = (Vector2d(ChunkX, ChunkZ) - WORLD_SPAWNS[World:GetName()])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE then
		GenerateChunkOutOfRange(ChunkDesc) -- Generate the chunk as the user says we should generate it.
	end	
end

function OnPlayerMoving(Player)
	local World = Player:GetWorld()
	local WorldName = World:GetName()
	local PlayerChunk = Vector2d(Player:GetChunkX(), Player:GetChunkZ())
	local PlayerCoords = Vector2d(Player:GetPosX(), Player:GetPosZ())
	local DistanceVector = (PlayerChunk - WORLD_SPAWNS[WorldName])
	local Distance = DistanceVector:Length()
	if Distance > MAX_RANGE * 3 then 
		-- It's not worth calculating where the player should spawn since he is far behind the border. 
		-- Just teleport him to spawn.
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
