---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------


function Vector2d(BlockX, BlockZ)
	local Object = {}
	Object.x = BlockX
	Object.z = BlockZ
	function Object:Length()
	end
	local MetaTable = {
		__add = function (Vector1, Vector2)
			return {x = Vector1.x + Vector2.x,
			z = Vector1.z + Vector2.z, 
			Length = function()
				return math.sqrt(Object.x * Object.x + Object.z * Object.z)
			end,
			}
		end,
		__sub = function (Vector1, Vector2)
			return {x = Vector1.x - Vector2.x,
			z = Vector1.z - Vector2.z,
			Length = function()
				return math.sqrt(Object.x * Object.x + Object.z * Object.z)
			end,
			}
		end
	}
	setmetatable(Object, MetaTable)
	return Object
end