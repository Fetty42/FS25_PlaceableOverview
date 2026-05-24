-- Author: Fetty42
-- Date: 2024-12-09
-- Version: 1.0.0.0

local dbPrintfOn = false
local dbInfoPrintfOn = false

local function dbInfoPrintf(...)
	if dbInfoPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrint(...)
	if dbPrintfOn then
    	print(...)
	end
end

local function dbPrintHeader(funcName)
	if dbPrintfOn then
		if g_currentMission ~=nil and g_currentMission.missionDynamicInfo ~=nil then
			print(string.format("Call %s: isDedicatedServer=%s | isServer()=%s | isMasterUser=%s | isMultiplayer=%s | isClient()=%s | farmId=%s", 
							funcName, tostring(g_dedicatedServer~=nil), tostring(g_currentMission:getIsServer()), tostring(g_currentMission.isMasterUser), tostring(g_currentMission.missionDynamicInfo.isMultiplayer), tostring(g_currentMission:getIsClient()), tostring(g_currentMission:getFarmId())))
		else
			print(string.format("Call %s: isDedicatedServer=%s | g_currentMission=%s",
							funcName, tostring(g_dedicatedServer~=nil), tostring(g_currentMission)))
		end
	end
end


PlaceableOverview = {}; -- Class

-- global variables
PlaceableOverview.dir = g_currentModDirectory
PlaceableOverview.modName = g_currentModName

PlaceableOverview.dlg = nil
PlaceableOverview.guiLoaded = false
PlaceableOverview.placeableDlgFrame = nil

source(PlaceableOverview.dir .. "gui/PlaceableDlgFrame.lua")

function PlaceableOverview:ensureGuiLoaded()
	if PlaceableOverview.guiLoaded then
		return true
	end

	g_gui:loadProfiles(PlaceableOverview.dir .. "gui/guiProfiles.xml")
	PlaceableOverview.placeableDlgFrame = PlaceableDlgFrame.new(g_i18n)
	g_gui:loadGui(PlaceableOverview.dir .. "gui/PlaceableDlgFrame.xml", "PlaceableDlgFrame", PlaceableOverview.placeableDlgFrame)
	PlaceableOverview.guiLoaded = true

	return true
end

function PlaceableOverview:loadMap(name)
    dbPrintHeader("PlaceableOverview:loadMap()")
	self:ensureGuiLoaded()
end

function PlaceableOverview:ShowPlaceableDlg(actionName, keyStatus, arg3, arg4, arg5)
	dbPrintHeader("PlaceableOverview:ShowPlaceableDlg()")

	if not self:ensureGuiLoaded() then
		return
	end

	PlaceableOverview.dlg = g_gui:showDialog("PlaceableDlgFrame")
end

function PlaceableOverview:onLoad(savegame)end;
function PlaceableOverview:onUpdate(dt)end;

function PlaceableOverview:deleteMap()
	PlaceableOverview.guiLoaded = false
	PlaceableOverview.placeableDlgFrame = nil
	PlaceableOverview.dlg = nil
	PlaceableOverview.actionEventRegistered = false
	PlaceableOverview.actionEventId = nil
end

function PlaceableOverview:keyEvent(unicode, sym, modifier, isDown)end;
function PlaceableOverview:mouseEvent(posX, posY, isDown, isUp, button)end;

addModEventListener(PlaceableOverview);
