addEvent("onElementCustomDataChange")

local dataSystem = {
	data = {},
	timers = {},
	buffer = {
		synced = {},
		selected = {},	
	},
}

-- DO UŻYCIA Z SYTEMEM ZAPISU DANYCH MYSQL
local playerElement = createElement("playerElement","playerElement")
local otherElement = createElement("otherElement","otherElement")

function setCustomData(element,name,variable,selectedKey)
    -- WERYFIKACJA
    if not element or not name or not variable then 
        return
    end
    -- DODAWANIE DATY
    local elements = {}
    if type(element) == "table" then
        elements = element
    else
        elements = {element}
    end

    for i=1,#elements do 
        local elem = elements[i]
		if dataSystem.data[elem] then
            triggerEvent("onElementCustomDataChange",elem,name,dataSystem.data[elem][name],variable)           
	        dataSystem.data[elem][name] = variable		
		else
			dataSystem.data[elem] = {}
            triggerEvent("onElementCustomDataChange",elem,name,dataSystem.data[elem][name],variable)           			
			dataSystem.data[elem][name] = variable			
		end
    end
	
	if selectedKey == true or selectedKey == nil then 
		for i=1,#elements do 
			local bufferLocal = dataSystem.buffer["synced"]	
			local bufferSize = #bufferLocal+1
			bufferLocal[bufferSize] = {elements[i],name,variable}
		end		 
		if isTimer(dataSystem.timers["global"]) then
			killTimer(dataSystem.timers["global"])
			dataSystem.timers["global"] = nil
		end
		dataSystem.timers["global"]	= setTimer(synchronizeData,20,1)	
	elseif selectedKey == false then 
		for i=1,#elements do 
			if not dataSystem.buffer["selected"][elements[i]] then
				dataSystem.buffer["selected"][elements[i]] = {}
			end
			local userBuffer = dataSystem.buffer["selected"][elements[i]]			
			local bufferSize = #userBuffer+1			
			userBuffer[bufferSize] = {elements[i],name,variable}	
			if isTimer(dataSystem.timers[elements[i]]) then
				killTimer(dataSystem.timers[elements[i]])
				dataSystem.timers[elements[i]] = nil
			end
			dataSystem.timers[elements[i]] = setTimer(synchronizeData,20,1,elements[i])	
		end
	end
end

function getCustomData(element,name)
    if dataSystem.data[element] then 
        return dataSystem.data[element][name]
    end
end

function getAllCustomData(element,name)
    if dataSystem.data[element] then 
        return dataSystem.data[element]
    end
end

function getElementsByCustomData(name,key)
    local tableList = {}
    for element,variable in pairs(dataSystem.data) do
        if dataSystem.data[element][name] then 
            tableList[#tableList+1] = element 
        end
    end
    return #tableList == 0 and false or tableList
end

function hasCustomData(element,name,variable)
    local validateElement = isElement(element)
    if validateElement and not name and not variable then
        return dataSystem.data[element] or false
    elseif validateElement and name and not variable then
        return dataSystem.data[element] and dataSystem.data[element][name] ~= nil or false
    elseif validateElement and name and variable then
        return dataSystem.data[element] and dataSystem.data[element][name] == variable or false
    end
    return false
end

function removeCustomData(element,name)
    if dataSystem.data[element] then 
        dataSystem.data[element][name] = nil
    end
end

function synchronizeData(element)
	if not element then 
		local bufferLocal = dataSystem.buffer["synced"]	
		if bufferLocal ~= nil then
			triggerLatentClientEvent(getElementsByType("player"),"getSynchronizeFromServer",root,bufferLocal)	
			dataSystem.buffer["synced"] = {}	
			dataSystem.timers["global"] = nil
		end
	else 
		local bufferLocal = dataSystem.buffer["selected"][element]
		if bufferLocal ~= nil then
			triggerLatentClientEvent(element,"getSynchronizeFromServer",root,bufferLocal)                     			 	
			dataSystem.buffer["selected"][element] = nil
			dataSystem.timers[element] = nil			
		end
	end
end

local function onPlayerJoin()
	triggerLatentClientEvent(source,"synchronizeLocalPlayer",source,dataSystem.data)  
end
addEventHandler("onPlayerJoin",root,onPlayerJoin)

local function elementDestroy()
	dataSystem.data[source] = nil
end 
addEventHandler("onPlayerQuit",root,elementDestroy)
addEventHandler("onElementDestroy",root,elementDestroy) 

function loadDataSystem()
	local getSave = getElementData(root,"dataSystem")
	if getSave then 
		dataSystem = getSave
	end
end
addEventHandler("onResourceStart",resourceRoot,loadDataSystem)

function saveDataSystem()
	setElementData(root,"dataSystem",dataSystem,false)
end
addEventHandler("onResourceStop",resourceRoot,saveDataSystem)