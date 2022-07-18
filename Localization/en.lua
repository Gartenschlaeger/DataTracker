---@class DataTracker_Core
local DataTracker = select(2, ...)

---@class DataTracker_Locale
local l = {}
DataTracker.i18n = l

-- General
l.LOADING_MSG = 'DataTracker loaded, %s items, %s units (use /dts for search)'

l.GOLD   = 'Gold'
l.SILVER = 'Silver'
l.COPPER = 'Copper'

l.NEW_UNIT = 'New unit'
l.NEW_MAP = 'New map'
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
l.UI_SEARCH     = 'Search'
l.UI_BACK       = 'Back'
l.UI_RESET      = 'Reset'
l.UI_UNIT_NAME  = 'Unit name'
l.UI_ZONE_NAME  = 'Zone'
l.UI_KILLS_PH   = 'Kills'
l.UI_GOLD_LEVEL = 'Gold level'

-- Tooltip
l.TT_KILLS   = 'Kills'
l.TT_LOOTED  = 'Looted'
l.TT_AVG_COP = 'Money'
l.TT_MIN_COP = 'Min. money'
l.TT_MAX_COP = 'Max. money'
