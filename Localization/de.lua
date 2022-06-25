if (GetLocale() ~= 'deDE') then
    return
end

local l = DataTracker.i18n

-- General
l.LOADING_MSG = 'DataTracker wurde geladen, %u Gegenstände, %u Gegner'

l.GOLD   = 'Gold';
l.SILVER = 'Silber';
l.COPPER = 'Kupfer';

l.NEW_UNIT = 'Neuer Gegner';
l.NEW_ZONE = 'Neue Zone';
l.NEW_ITEM = 'Neuer Gegenstand';

-- OptionsPanel
l.OP_DEBUG_LOGS          = 'Diagnoselogs aktivieren'
l.OP_TT_HEADER           = 'Tooltip'
l.OP_TT_SHOW_KILLS       = 'Getötet'
l.OP_TT_SHOW_LOOTED      = 'Gelootet'
l.OP_TT_SHOW_MONEY       = 'Gold'
l.OP_TT_SHOW_ITEMS       = 'Gegenstände'
l.OP_TT_SHOW_TRASH_ITEMS = 'Graue Gegenstände'

-- DatabaseBrowser
l.UI_SEARCH = 'Suche'
l.UI_BACK   = 'Zurück'

-- Tooltip
l.TT_KILLS  = 'Getötet'
l.TT_LOOTED = 'Gelootet'

l.TT_MIN_COP = 'Min. Gold'
l.TT_MAX_COP = 'Max. Gold'
