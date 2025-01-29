-- Author: Fetty42
-- Date: 2024-12-09
-- Version: 1.0.0.0


local isDbPrintfOn = false

local function dbPrintf(...)
	if isDbPrintfOn then
    	print(string.format(...))
	end
end


PlaceableDlgFrame = {}
local DlgFrame_mt = Class(PlaceableDlgFrame, MessageDialog)

PlaceableDlgFrame.mixDlg	= nil


function PlaceableDlgFrame.new(target, custom_mt)
	dbPrintf("PlaceableDlgFrame:new()")
	local self = MessageDialog.new(target, custom_mt or DlgFrame_mt)
	return self
end

function PlaceableDlgFrame:onGuiSetupFinished()
	dbPrintf("PlaceableDlgFrame:onGuiSetupFinished()")
	PlaceableDlgFrame:superClass().onGuiSetupFinished(self)
	self.overviewTable:setDataSource(self)
	self.overviewTable:setDelegate(self)
end

function PlaceableDlgFrame:onCreate()
	dbPrintf("PlaceableDlgFrame:onCreate()")
	PlaceableDlgFrame:superClass().onCreate(self)
end


function PlaceableDlgFrame:onOpen()
	dbPrintf("PlaceableDlgFrame:onOpen()")
	PlaceableDlgFrame:superClass().onOpen(self)

	-- Fill data structure
	self.dataTable = {}

	for _, placeable in pairs(g_currentMission.placeableSystem.placeables) do
        if not placeable.markedForDeletion
            and not placeable.isDeleted
            and not placeable.isDeleteing
            and placeable.typeName ~= "newFence"
            -- and placeable.ownerFarmId == g_currentMission:getFarmId()
            -- and placeable.ownerFarmId ~= FarmManager.SPECTATOR_FARM_ID
        then
		table.insert(self.dataTable, placeable)
        end
	end

    table.sort(self.dataTable, function (p1, p2)
        local p1OwnerOrder = (p1.ownerFarmId == AccessHandler.NOBODY and 100) or (p1.ownerFarmId == AccessHandler.EVERYONE and 101) or (p1.ownerFarmId == g_currentMission:getFarmId() and p1.ownerFarmId ~= FarmManager.SPECTATOR_FARM_ID and 0) or p1.ownerFarmId
        local p2OwnerOrder = (p2.ownerFarmId == AccessHandler.NOBODY and 100) or (p2.ownerFarmId == AccessHandler.EVERYONE and 101) or (p2.ownerFarmId == g_currentMission:getFarmId() and p2.ownerFarmId ~= FarmManager.SPECTATOR_FARM_ID and 0) or p2.ownerFarmId
        if p1OwnerOrder == p2OwnerOrder then
            local p1Name        = p1:getName()
            if p1.brand ~= nil and p1.brand.title ~= nil and p1.brand.title ~= "None" then
                p1Name = p1.brand.title .. " " .. p1Name
            end

            local p2Name        = p2:getName()
            if p2.brand ~= nil and p2.brand.title ~= nil and p2.brand.title ~= "None" then
                p2Name = p2.brand.title .. " " .. p2Name
            end

            return p1Name < p2Name
        end
        return p1OwnerOrder < p2OwnerOrder
    end )

    -- finalize dialog
	self.overviewTable:reloadData()

	self:setSoundSuppressed(true)
    FocusManager:setFocus(self.overviewTable)
    self:setSoundSuppressed(false)
end


-- function PlaceableDlgFrame:getNumberOfSections(list)
--     dbPrintf("PlaceableDlgFrame:getNumberOfSections()")
--     return 1
-- 	-- if list == self.overviewTable then
-- 	-- 	return #self.overviewTableData
-- 	-- else
-- 	-- 	return 1
-- 	-- end
-- end

function PlaceableDlgFrame:getNumberOfItemsInSection(list, section)
    if list == self.overviewTable then
        return #self.dataTable
    else
        return 0
    end
end

-- function PlaceableDlgFrame:getTitleForSectionHeader(list, section)
-- 	dbPrintf("PlaceableDlgFrame:getTitleForSectionHeader()")
--     return "Test"
-- 	-- if list == self.overviewTable then
-- 	-- 	return self.overviewTableData[section].sectionTitle
-- 	-- else
-- 	-- 	return nil
-- 	-- end
-- end



function PlaceableDlgFrame:populateCellForItemInSection(list, section, index, cell)
    if list == self.overviewTable then
        local thisPlaceable      = self.dataTable[index]

        -- Title
        local name        = thisPlaceable:getName()
        if thisPlaceable.brand ~= nil and thisPlaceable.brand.title ~= nil and thisPlaceable.brand.title ~= "None" then
            name = thisPlaceable.brand.title .. " " .. name
        end
        cell:getAttribute("title"):setText(name)

        -- Icon
        local imageFilename = thisPlaceable:getImageFilename()
        if imageFilename ~= nil then
            cell:getAttribute("ftIcon"):setImageFilename(imageFilename)
        end
        cell:getAttribute("ftIcon"):setVisible(imageFilename ~= nil)

        -- Owner
        local ownerFarmId       = thisPlaceable.ownerFarmId
        local farmColor         = { 1, 1, 1, 1 }
        local farmName
        if ownerFarmId == g_currentMission:getFarmId() and ownerFarmId ~= FarmManager.SPECTATOR_FARM_ID then
            farmName =g_i18n:getText("ownerYou")
            if g_currentMission.missionDynamicInfo.isMultiplayer then
                local farm = g_farmManager:getFarmById(ownerFarmId)
                if farm ~= nil then
                    farmName  = farm.name
                    farmColor = Farm.COLORS[farm.color]
                end
            end
        elseif ownerFarmId == AccessHandler.EVERYONE then
            farmColor = { 0.5, 0.5, 0.5, 1 }
            farmName = g_i18n:getText("ownerEveryone")
        elseif ownerFarmId == AccessHandler.NOBODY then
            farmColor = { 0.5, 0.5, 0.5, 1 }
            farmName = g_i18n:getText("ownerNobody")
        else
            local farm = g_farmManager:getFarmById(ownerFarmId)

            if farm ~= nil then
                farmName  = farm.name
                farmColor = Farm.COLORS[farm.color]
            else
                farmName = g_i18n:getText("ownerUnknown")
                farmColor = { 0.5, 0.5, 0.5, 1 }
            end
        end
        cell:getAttribute("placeableOwner"):setText(farmName)
        cell:getAttribute("placeableOwner").textColor = farmColor

        -- daily up keep
        local dailyUpkeep = math.floor(thisPlaceable:getDailyUpkeep())
        cell:getAttribute("dailyUpkeep"):setText(g_i18n:formatMoney(dailyUpkeep, 0, true, true))

        -- Store category name
        local storeCategorieName = g_storeManager:getCategoryByName(thisPlaceable.storeItem.categoryName).title
        -- local storeCategorieName = string.lower(thisPlaceable.storeItem.categoryName)
        -- storeCategorieName = string.upper(string.sub(storeCategorieName, 1, 1)) .. string.sub(storeCategorieName, 2)
        cell:getAttribute("storeCategoryName"):setText(storeCategorieName)

        -- Store functions description
        local storeFunctions =  thisPlaceable.storeItem.functions ~= nil and table.concat(thisPlaceable.storeItem.functions, "\n") or ""   --> description of the functions of the placeable
        cell:getAttribute("storeFunctions"):setText(storeFunctions)


        -- cell:getAttribute("typeName"):setText(thisPlaceable.typeName)
        -- local sellPrice   = math.floor(thisPlaceable:getSellPrice())
        -- local age = thisPlaceable.age
        -- local farmlandId = thisPlaceable:getFarmlandId()
        -- local isOnPublicGround = g_farmlandManager:getFarmlandOwner(thisPlaceable:getFarmlandId()) == FarmManager.SPECTATOR_FARM_ID
        -- local boughtWithFarmland = (thisPlaceable.boughtWithFarmlandSavegameOverwrite == nil and thisPlaceable.boughtWithFarmland) or thisPlaceable.boughtWithFarmlandSavegameOverwrite

        -- Specializations
        -- local specializationNames = ""   -- e.g.: lights, deletedNodes, ...
        -- for _, str in pairs(thisPlaceable.specializationNames) do
        --     if string.find("lights, deletedNodes, hotspots, dynamicallyLoadedParts, triggerMarkers, leveling, animatedObjects, ai, tipOcclusionAreas, foliageAreas, indoorAreas, clearAreas, placement, placeable, infoTrigger", str) == nil then
        --         specializationNames =  specializationNames .. str .. (specializationNames ~= "" and ", " or "")
        --     end
        -- end
        -- cell:getAttribute("specializationNames"):setText(specializationNames)
    end
end

function PlaceableDlgFrame:onButtonWarpToPlaceable()
    dbPrintf("PlaceableDlgFrame:onButtonWarpToPlaceable()")

    local warpX, warpY, warpZ = 0, 0, 0
    local dropHeight       = 1.2
    local thisPlaceable     = self.dataTable[self.overviewTable.selectedIndex]
    local foundHotSpot  = nil

    -- Find a valid hotspot or area for teleportation
    -- 1. Checks if the placeable object has map hotspots with teleport coordinates.
    if thisPlaceable.spec_hotspots ~= nil and thisPlaceable.spec_hotspots.mapHotspots ~= nil then
        for _, mapHotSpot in ipairs(thisPlaceable.spec_hotspots.mapHotspots) do
            if not foundHotSpot and mapHotSpot.teleportWorldX ~= nil and mapHotSpot.teleportWorldZ ~= nil then
                foundHotSpot = "warpHotSpot"
                warpX        = mapHotSpot.teleportWorldX
                warpZ        = mapHotSpot.teleportWorldZ
            end
        end
    end

    -- 2. Checks if the placeable object has clear areas with a starting point.
    if not foundHotSpot and thisPlaceable.spec_clearAreas ~= nil and thisPlaceable.spec_clearAreas.areas ~= nil then
        for _, thisArea in ipairs(thisPlaceable.spec_clearAreas.areas) do
            if not foundHotSpot and thisArea.start ~= nil then
                foundHotSpot    = "clearArea"
                warpX, _, warpZ = getWorldTranslation(thisArea.start)
            end
        end
    end

    -- 3. Checks if the placeable object has test areas with a starting node.
    if not foundHotSpot and thisPlaceable.spec_placement ~= nil and thisPlaceable.spec_placement.testAreas ~= nil then
        for _, thisArea in ipairs(thisPlaceable.spec_placement.testAreas) do
            if not foundHotSpot and thisArea.startNode ~= nil then
                foundHotSpot    = "testArea"
                warpX, _, warpZ = getWorldTranslation(thisArea.startNode)
            end
        end
    end

    -- 4. If no valid hotspot or area is found, it uses the root node's coordinates as a fallback.
    if not foundHotSpot then
        foundHotSpot    = "fallback"
        warpX, _, warpZ = getWorldTranslation(thisPlaceable.rootNode)
    end

    warpY =  getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode, warpX, 0, warpZ);
    dbPrintf("Warping to '%s': %f, %f, %f", foundHotSpot, warpX, warpY, warpZ)

    g_gui:showGui("")

    if g_localPlayer ~= nil and g_localPlayer:getCurrentVehicle() ~= nil then
        local curVehicle = g_localPlayer:getCurrentVehicle()
        curVehicle:doLeaveVehicle()
    end
    g_localPlayer:teleportTo(warpX, warpY + dropHeight, warpZ)
end


function PlaceableDlgFrame:onClose()
	dbPrintf("PlaceableDlgFrame:onClose()")
	self.dataTable = {}
	PlaceableDlgFrame:superClass().onClose(self)
end


function PlaceableDlgFrame:onClickBack(sender)
	dbPrintf("PlaceableDlgFrame:onClickBack()")
	self:close()
end

