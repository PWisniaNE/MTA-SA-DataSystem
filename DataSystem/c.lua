local dataSystem = {}

-- LOAD ALL DATA ON PLAYER JOIN OR RESOURCE START
addEvent("synchronizeLocalPlayer",true)
addEventHandler("synchronizeLocalPlayer",root,function(data)
	dataSystem = data	
end)

-- GET SYNCHRONIZATION FROM SERVER
addEvent("getSynchronizeFromServer",true)
addEventHandler("getSynchronizeFromServer",root,function(element,name,variable,group)
    if group == true then 
        if dataSystem["group"][element] then 
            dataSystem["group"][element][name] = variable
        else 
            dataSystem["group"][element] = {}
            dataSystem["group"][element][name] = variable
        end
    else 
       if dataSystem[element] then 
            dataSystem[element][name] = variable
        else 
            dataSystem[element] = {}
            dataSystem[element][name] = variable
        end
    end
end)

-- GET CUSTOM DATA (RETURN VALUE IF EXISTS)
function getCustomData(element,name) 
	if element and isElement(element) and name then
		if dataSystem[element] then
			return dataSystem[element][name]
		end
	elseif type(element) == "string" then
		return dataSystem[element]
	end
end

-- SET CUSTOM DATA
function setCustomData(element,name,variable) 
   if dataSystem[element] then 
		dataSystem[element][name] = variable
	else 
		dataSystem[element] = {}
		dataSystem[element][name] = variable
	end
end

-- CHECK ELEMENT HAVE CUSTOM DATA (RETURN DATA IF HAVE)
function hasCustomData(element,name,variable)
    local validateElement = isElement(element)
    if validateElement and not name and not variable then
        return dataSystem[element] or false
    elseif validateElement and name and not variable then
        return dataSystem[element] and dataSystem[element][name] ~= nil or false
    elseif validateElement and name and variable then
        return dataSystem[element] and dataSystem[element][name] == variable or false
    end
	return false
end