addEvent("onElementCustomDataChange")

local dataSystem = {}
dataSystem.server = {}
dataSystem.synced = {}
dataSystem.client = {}
dataSystem.group = {}
dataSystem.buffer = {}

-- TO USE WITH MYSQL SAVE SYSTEM (WITH THIS YOU CAN EASLY LOAD PLAYER DATA ON RESOUCE START)
local playerElement = createElement("playerElement","playerElement")
local otherElement = createElement("otherElement","otherElement")

-- SET CUSTOM DATA
function setCustomData(element,name,variable,key)
    if not element or not name or not variable then return end

    local selectedKey = key or "synced"
    local elements = {}
    if type(element) == "table" then
        elements = element
    else
        elements = {element}
    end

    for i=1,#elements do 
        local elem = elements[i]
		if dataSystem[selectedKey][elem] then
            triggerEvent("onElementCustomDataChange",elem,name,dataSystem[selectedKey][elem][name],variable)           
	        dataSystem[selectedKey][elem][name] = variable		
		else
			dataSystem[selectedKey][elem] = {}
            triggerEvent("onElementCustomDataChange",elem,name,dataSystem[selectedKey][elem][name],variable)           			
			dataSystem[selectedKey][elem][name] = variable			
		end
    end

    if key ~= "server" then
        dataSystem.buffer[element] = {name,variable}
        if key == "client" then
            setTimer(synchronizeData,10,1,elements[1],selectedKey,name,variable)
        elseif key == "group" then
            setTimer(synchronizeData,10,1,elements,selectedKey,name,variable)
        elseif key == "synced" or key == nil then
            setTimer(synchronizeData,10,1,getElementsByType("player"),selectedKey,name,variable)
		end
    end 
end

-- GET CUSTOM DATA (RETURN VALUE IF EXISTS)
function getCustomData(element,name,key)
    local selectedKey = key or "synced"
    if dataSystem[selectedKey][element] then 
        return dataSystem[selectedKey][element][name]
    end
end

-- GET ALL CUSTOM DATA FROM ELEMENT (RETURN DATA IF EXISTS)
function getAllCustomData(element,key)
    local selectedKey = key or "synced"
    if dataSystem[selectedKey][element] then 
        return dataSystem[selectedKey][element]
    end
end

-- GET ELEMENTS WHICH HAVE SELECTED DATA (RETURN TABLE OF ELEMENTS)
function getElementsByCustomData(name,key)
    local selectedKey = key or "synced"
    local tableList = {}
    for element,variable in pairs(dataSystem[selectedKey]) do
        if dataSystem[selectedKey][element][name] then 
            tableList[#tableList+1] = element 
        end
    end
    return #tableList == 0 and false or tableList
end

-- CHECK ELEMENT HAVE CUSTOM DATA (RETURN DATA IF HAVE)
function hasCustomData(element, selectedKey, name, variable)
    local selectedKey = key or "synced"
    local validateElement = isElement(element)
    if validateElement and not name and not variable then
        return dataSystem[selectedKey][elements] or false
    elseif validateElement and name and not variable then
        return dataSystem[selectedKey][elements] and dataSystem[selectedKey][elements][name] ~= nil or false
    elseif validateElement and name and variable then
        return dataSystem[selectedKey][elements] and dataSystem[selectedKey][elements][name] == variable or false
    end
    return false
end

-- REMOVE CUSTOM DATA
function removeCustomData(element,name,key)
    local selectedKey = key or "server"
    if dataSystem[selectedKey][element] then 
        dataSystem[selectedKey][element][name] = nil
    end
end

-- SYNCHRONIZE UPDATED DATA WITH ELEMENTS
local function synchronizeData(element,type,name,variable)
    for i=1,#element do 
        if type == "synced" then 
            triggerLatentClientEvent(getElementsByType("player"),"getSynchronizeFromServer",root,element[i],name,variable)
        elseif type == "group" then
            triggerLatentClientEvent(element[i],"getSynchronizeFromServer",root,element[i],name,variable,true)                     
        else     
            triggerLatentClientEvent(element[i],"getSynchronizeFromServer",root,element[i],name,variable)           
        end
    end
end

-- ON PLAYER JOIN SEND HIM ALL SERVER SYNCED PLAYER DATA
local function onPlayerJoin()
	triggerLatentClientEvent(source,"synchronizeLocalPlayer",source,dataSystem["synced"])  
end
addEventHandler("onPlayerJoin",root,onPlayerJoin)

-- ON ELEMENT DESTROY/PLAYER QUIET DESTROY HIS DATA FROM TABLES
local function elementDestroy()
	dataSystem["synced"][source] = nil
	dataSystem["server"][source] = nil
	dataSystem["client"][source] = nil
end
addEventHandler("onPlayerQuit",root,elementDestroy)
addEventHandler("onElementDestroy",root,elementDestroy) 

-- SECURE SYSTEM DATA ON RESOURCE RESTART
local function loadDataSystem()
	local getSave = getElementData(root,"dataSystem")
	if getSave then 
		dataSystem = getSave
	end
end
addEventHandler("onResourceStart",resourceRoot,loadDataSystem)

local function saveDataSystem()
	setElementData(root,"dataSystem",dataSystem)
end
addEventHandler("onResourceStop",resourceRoot,saveDataSystem)
