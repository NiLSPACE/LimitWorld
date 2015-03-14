---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------


function GenerateChunkOutOfRange(ChunkDesc)
	ChunkDesc:SetUseDefaultBiomes(false)
	ChunkDesc:SetUseDefaultComposition(false)
	ChunkDesc:SetUseDefaultFinish(false)
	ChunkDesc:SetUseDefaultHeight(false)
	ChunkDesc:WriteBlockArea(g_ChunkComposition, 0, 0, 0)
end


function CreateChunkData(a_CompositionString)
	local BlockArea = cBlockArea()
	local ChunkComposition = StringSplit(a_CompositionString, ";")
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
		if not BlockType or not IsValidBlock(BlockType) then -- Skip this layer because the block isn't valid
			LOGWARN('"' .. Content[2] .. '" isn\'t a valid block. Skipping layer ' .. Content[1] .. "x" .. Content[2])
		else
			BlockArea:FillRelCuboid(0, 15, CurrentLayer, CurrentLayer + Content[1] - 1, 0, 15, 3, BlockType, BlockMeta)
			CurrentLayer = CurrentLayer + Content[1]
		end
	end
	g_ChunkComposition:CopyFrom(BlockArea)
end