



local g_DefaultConfig =
{
	General = 
	{
		MaxRange = 10,
		Shape = "circle",
	},
	
	Chunk =
	{
		ChunkComposition = "61x7;1x8",
	},
}




function LoadConfig()
	local FilePath = cPluginManager:Get():GetCurrentPlugin():GetLocalFolder() .. "/config.cfg"
	if (not cFile:Exists(FilePath)) then
		LOGWARNING("[LimitWorld] The config file doesn't exist. LimitWorld will write and use the default settings")
		WriteDefaultSettings(FilePath)
		LoadDefaultSettings()
		return
	end
	
	local FileContent = cFile:ReadWholeFile(FilePath)
	if (FileContent == "") then
		LOGWARNING("[LimitWorld] The config file is empty. LimitWorld will write and use the default settings")
		WriteDefaultSettings(FilePath)
		LoadDefaultSettings()
		return
	end
	
	local Loader, Error = loadstring("return {" .. FileContent .. "}")
	if (not Loader) then
		LOGWARNING("[LimitWorld] There is a problem in the config file. LimitWorld will use the default settings")
		LoadDefaultSettings()
		return
	end
		
	local Result, ConfigTable, Error = pcall(Loader)
	if (not Result) then
		LOGWARNING("[LimitWorld] There is a problem in the config file. LimitWorld will use the default settings")
		LoadDefaultSettings()
	end
	
	if (not ConfigTable.General) then
		LOGWARNING("[LimitWorld] General tab not found in config. Using defaults")
		LoadDefaultSettings()
	end
	
	if (type(ConfigTable.General.MaxRange) ~= 'number') then
		if (type(tonumber(ConfigTable.General.MaxRange)) ~= 'number') then
			LOGWARNING("[LimitWorld] MaxRange isn't a number. Changing to default (" .. g_DefaultConfig.General.MaxRange .. ")")
			ConfigTable.General.MaxRange = g_DefaultConfig.General.MaxRange
		end
		ConfigTable.General.MaxRange = tonumber(ConfigTable.General.MaxRange)
	end
	
	g_Config = ConfigTable
end





function LoadDefaultSettings()
	g_Config = g_DefaultConfig
end





function WriteDefaultSettings(a_Path)
	local NumTabs = 0
	local File = io.open(a_Path, "w")
	local function WriteTable(a_Table, a_Name)
		if (a_Name) then
			File:write(a_Name, " = \n", string.rep("\t", NumTabs))
			File:write("{\n")
		end
		
		for Key, Value in pairs(a_Table) do
			if (type(Value) == 'table') then
				WriteTable(Value, Key)
				NumTabs = NumTabs + 1
			else
				local StringToFormat = type(Value) == 'string' and "%s = '%s',\n" or "%s = %s,\n"
				File:write(string.rep("\t", NumTabs + 1), StringToFormat:format(Key, Value))
			end
		end
		
		if (a_Name) then
			File:write("},\n\n")
		end
		
		NumTabs = NumTabs - 1
	end
	WriteTable(g_DefaultConfig)
	
	File:close()
end




