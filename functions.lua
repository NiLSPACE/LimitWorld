---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------


function GetBlockTypeMeta(Blocks)
	local Tonumber = tonumber(Blocks)
	if Tonumber == nil then
		local Item = cItem()
		if StringToItem(Blocks, Item) then
			return Item.m_ItemType, Item.m_ItemDamage
		else
			return false
		end
	else
		return Tonumber, 0, true
	end
end