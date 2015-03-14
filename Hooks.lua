---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------





function OnSpawningEntity(World, Entity)
	if (Entity:IsPlayer()) then
		return false
	end
	
	local IsInside = g_PosCheckIsInside(World, Entity:GetChunkX(), Entity:GetChunkZ())
	if (not IsInside) then
		return true
	end
end





function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	if (BlockFace == BLOCK_FACE_NONE) then -- The client sends two packets. One with these coordinates. We don't want that one.
		return false
	end
	
	local IsInside = g_PosCheckIsInside(Player:GetWorld(), math.floor(BlockX / 16), math.floor(BlockZ / 16))
	if (not IsInside) then
		return true
	end
end





function OnPlayerBreakingBlock(Player, BlockX, BlockY, BlockZ, BlockFace, BlockType, BlockMeta)
	local IsInside = g_PosCheckIsInside(Player:GetWorld(), math.floor(BlockX / 16), math.floor(BlockZ / 16))
	if (not IsInside) then
		return true
	end
end





function OnChunkGenerating(World, ChunkX, ChunkZ, ChunkDesc)
	local IsInside = g_PosCheckIsInside(World, ChunkX, ChunkZ)
	if (not IsInside) then
		GenerateChunkOutOfRange(ChunkDesc) -- Generate the chunk as the user says we should generate it.
	end
end





function OnPlayerMoving(Player)
	local World = Player:GetWorld()
	
	local IsInside, NewPos = g_PosCheckIsInside(World, Player:GetChunkX(), Player:GetChunkZ())
	if (IsInside) then
		return false
	end
	return true
end




