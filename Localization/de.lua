---@class DTCore
local _, core = ...

if (GetLocale() ~= 'deDE') then
    return
end

local l                = core.i18n

-- General
l.LOADING_MSG          = 'DataTracker geladen, %s Gegenstände, %s Gegner (verwende /dts um zu suchen)'

l.GOLD                 = 'Gold';
l.SILVER               = 'Silber';
l.COPPER               = 'Kupfer';

l.NEW_UNIT             = 'Neuer Gegner';
l.NEW_ZONE             = 'Neue Zone';
l.NEW_ITEM             = 'Neuer Gegenstand';

-- OptionsPanel
l.OP_DEBUG_LOGS        = 'Diagnoselogs aktivieren'
l.OP_TT_HEADER         = 'Tooltip'
l.OP_TT_SHOW_KILLS     = 'Getötet'
l.OP_TT_SHOW_LOOTED    = 'Gelootet'
l.OP_TT_SHOW_MONEY     = 'Gold'
l.OP_TT_SHOW_MONEY_AVG = 'Durschnitt'
l.OP_TT_SHOW_MONEY_MM  = 'Min/max'
l.OP_TT_SHOW_ITEMS     = 'Gegenstände'
l.OP_TT_SHOW_ICONS     = 'Symbole anzeigen'
l.OP_TT_MIN_ITEM_QLT   = 'Min. Qualität'
l.OP_TT_LIMIT_ITEMS    = "Maximale Anzahl Items anzeigen"
l.OP_TT_MORE_ITEMS     = "+ %s weitere Gegenstände..."
l.OP_TT_SHOW_EQUIP     = "Ausrüstungsgegenstände anzeigen"
l.OP_TT_SHOW_JOBS      = "Berufsgegenstände anzeigen"

-- DatabaseBrowser
l.UI_SEARCH            = 'Suche'
l.UI_BACK              = 'Zurück'
l.UI_RESET             = 'Reset'
l.UI_UNIT_NAME         = 'Gegner name'
l.UI_ZONE_NAME         = 'Zone'
l.UI_KILLS_PH          = 'Getötet'
l.UI_GOLD_LEVEL        = 'Gold level'

-- Tooltip
l.TT_KILLS             = 'Getötet'
l.TT_LOOTED            = 'Gelootet'

l.TT_AVG_COP           = 'Gold'
l.TT_MIN_COP           = 'Min. Gold'
l.TT_MAX_COP           = 'Max. Gold'
l.TT_SKINNING          = 'Kürschnerei'
l.TT_MINING            = 'Bergbau'
l.TT_HERBALISM         = 'Kräuterkunde'
