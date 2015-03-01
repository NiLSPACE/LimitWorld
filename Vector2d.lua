---------------------------------------------------------
---------------[[Created by STR_Warrior]]----------------
---------------------------------------------------------





Vector2d = {}





function Vector2d:__call(a_X, a_Z)
	local Obj = {}
	
	setmetatable(Obj, Vector2d)
	Obj.__index = Obj
	
	Obj.x = a_X
	Obj.z = a_Z
	
	return Obj
end





function Vector2d:__add(a_Vector2)
	return Vector2d(
		self.x + a_Vector2.x,
		self.z + a_Vector2.z
	)
end





function Vector2d:__sub(a_Vector2)
	return Vector2d(
		self.x - a_Vector2.x,
		self.z - a_Vector2.z
	)
end





function Vector2d:Length()
	return math.sqrt(self.x * self.x + self.z * self.z)
end





setmetatable(Vector2d, Vector2d)
Vector2d.__index = Vector2d




