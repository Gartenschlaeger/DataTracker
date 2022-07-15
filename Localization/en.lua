---@class DTCore
local _, core = ...

---@class DTLocale
local l = {}
core.i18n = l

-- General
l.LOADING_MSG = 'DataTracker loaded, %s items, %s units'

l.GOLD   = 'Gold'
l.SILVER = 'Silver'
l.COPPER = 'Copper'

l.NEW_UNIT = 'New unit'
l.NEW_ZONE = 'New zone'
l.NEW_ITEM = 'New item'

-- OptionsPanel
l.OP_DEBUG_LOGS        = "Enable debug logs"
l.OP_TT_HEADER         = 'Tooltip'
l.OP_TT_SHOW_KILLS     = 'Show kills'
l.OP_TT_SHOW_LOOTED    = 'Show times looted'
l.OP_TT_SHOW_MONEY     = 'Show money'
l.OP_TT_SHOW_MONEY_AVG = 'Avarage'
l.OP_TT_SHOW_MONEY_MM  = 'Min/max'
l.OP_TT_SHOW_ITEMS     = 'Show items'
l.OP_TT_SHOW_ICONS     = 'Show icons'
l.OP_TT_MIN_ITEM_QLT   = 'Min. item quality'

-- DatabaseBrowser
l.UI_SEARCH = 'Search'
l.UI_BACK   = 'Back'

-- Tooltip
l.TT_KILLS   = 'Kills'
l.TT_LOOTED  = 'Looted'
l.TT_AVG_COP = 'Money'
l.TT_MIN_COP = 'Min. money'
l.TT_MAX_COP = 'Max. money'
