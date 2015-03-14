




function InitShape()
	local Shape = g_Config.General.Shape
	if (not Shape) then
		LOGWARNING("[LimitWorld] No shape defined. Using circle")
		Shape = 'circle'
	end
	
	local ShapeFunction = nil
	
	if (Shape == 'circle') then
		ShapeFunction = ShapeCircle
	elseif (Shape == "square") then
		ShapeFunction = ShapeSquare
	else
		LOGWARNING("Unknown shape. Using circle")
		ShapeFunction = ShapeCircle
	end
	
	g_PosCheckIsInside = ShapeFunction
end





function ShapeCircle(a_World, a_X, a_Z)
	local WorldSpawn = Vector2d(math.floor(a_World:GetSpawnX() / 16), math.floor(a_World:GetSpawnZ() / 16))
	local Pos = Vector2d(a_X, a_Z)
	local DistanceVec = Pos - WorldSpawn
	local Distance = DistanceVec:Length()
	
	if (Distance < g_Config.General.MaxRange) then
		-- Coordinates are still inside the world limit
		return true
	end
	
	return false
end





function ShapeSquare(a_World, a_X, a_Z)
	local WorldSpawn = Vector3d(math.floor(a_World:GetSpawnX() / 16), 0, math.floor(a_World:GetSpawnZ() / 16))
	local Cuboid = cCuboid(
		-g_Config.General.MaxRange, 0, -g_Config.General.MaxRange,
		 g_Config.General.MaxRange, 0,  g_Config.General.MaxRange
	)
	
	return Cuboid:IsInside(a_X, 0, a_Z)
end

	


