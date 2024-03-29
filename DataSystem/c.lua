local dataSystem = {}

addEvent("synchronizeLocalPlayer",true)
addEventHandler("synchronizeLocalPlayer",root,function(data)
	dataSystem = data	
end)
 
addEvent("getSynchronizeFromServer",true)
addEventHandler("getSynchronizeFromServer",root,function(buffer)
	if not buffer or type(buffer) ~= "table" then return end
	for i=1,#buffer do 
		local getBufferRow = buffer[i]
		if getBufferRow then
			local element = getBufferRow[1]
			local name = getBufferRow[2]
			local value =  getBufferRow[3]
		    if dataSystem[element] then 
				dataSystem[element][name] = value
			else 
				dataSystem[element] = {}
				dataSystem[element][name] = value
			end
		end
	end
end)

function getCustomData(element,name) 
	if element and isElement(element) and name then
		if dataSystem[element] then
			return dataSystem[element][name]
		end
	elseif type(element) == "string" then
		return dataSystem[element]
	end
end

function setCustomData(name,variable) 
   if dataSystem[localPlayer] then 
		dataSystem[localPlayer][name] = value
	else 
		dataSystem[localPlayer] = {}
		dataSystem[localPlayer][name] = value
	end
end

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

function setTableProtected (tbl)
  return setmetatable ({}, 
    {
    __index = tbl,  -- read access gets original table item
    __newindex = function (t, n, v)
       error ("attempting to change constant " .. 
             tostring (n) .. " to " .. tostring (v), 2)
      end -- __newindex, error protects from editing
    })
end

function loadDataSystem()
	local getSave = getElementData(localPlayer,"dataSystem")
	if getSave then 
		dataSystem = getSave
	end
end
addEventHandler("onClientResourceStart",resourceRoot,loadDataSystem)

function saveDataSystem()
	setElementData(localPlayer,"dataSystem",setTableProtected(dataSystem), false)
end
addEventHandler("onClientResourceStop",resourceRoot,saveDataSystem)