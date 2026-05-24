-- Author: Fetty42
-- Date: 08.12.2024
-- Version: 1.0.0.0

local isDbPrintfOn = false

-- Function to print debug messages if debugging is enabled
-- Usage: dbPrintf("Message: %s", message)
local function dbPrintf(...)
    if isDbPrintfOn then
        print(string.format(...))
    end
end


dbPrintf("    FS25_PlaceableOverview: register global player action events")


--[[
    This function appends a custom action event registration to the global player action events.
    
    Parameters:
    - self: The PlayerInputComponent instance.
    - controlling: The current controlling state, expected to be "VEHICLE" or other states.
--]]
PlayerInputComponent.registerGlobalPlayerActionEvents = Utils.appendedFunction(
    PlayerInputComponent.registerGlobalPlayerActionEvents,
    function(self, controlling)
        if PlaceableOverview.actionEventRegistered then
            return
        end

        local triggerUp, triggerDown, triggerAlways, startActive, callbackState, disableConflictingBindings = false, true, false, true, nil, true

        local success, actionEventId, otherEvents = g_inputBinding:registerActionEvent(InputAction.SHOW_PLACEABLE_DLG, PlaceableOverview, PlaceableOverview.ShowPlaceableDlg, triggerUp, triggerDown, triggerAlways, startActive, callbackState, disableConflictingBindings)

        if success then
            PlaceableOverview.actionEventRegistered = true
            PlaceableOverview.actionEventId = actionEventId
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW) -- GS_PRIO_VERY_HIGH, GS_PRIO_HIGH, GS_PRIO_LOW, GS_PRIO_VERY_LOW
            g_inputBinding:setActionEventTextVisibility(actionEventId, true) -- INFO: change "false" to "true" to show keybinding in help window
            dbPrintf("FS25_PlaceableOverview - Register key (controlling=%s, action=%s, actionId=%s)", controlling, InputAction.SHOW_PLACEABLE_DLG, actionEventId)
        else
            dbPrintf("FS25_PlaceableOverview - Failed to register key (controlling=%s, action=%s, actionId=%s)", controlling, InputAction.SHOW_PLACEABLE_DLG, actionEventId)
        end
    end)
