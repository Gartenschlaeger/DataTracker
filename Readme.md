# WOW Addon DataTracker

DataTracker is a WOW Addon to track looted items and fighted units in an ingame database.
The data can be used later for a graphical UI to search for items or units.

The resulting database is saved to a lua file which could be also imported to a website to build a nice looking Website out of it.

To show or export the data, find the file DataTracker.lua in your interface directory:

```
/_retail_/WTF/Account/ACCOUNT_NAME/SavedVariables/DataTracker.lua
```

> The addon was developed in WOW Shadowlands. Compatibility with Classic is not guaranteed.

# Installation

The addon is available on CurseForge https://www.curseforge.com/wow/addons/datatracker

You can also install it manually, by downloading one of the release packages and copying it to your addon path.
Thats usually `/_retail_/Interface/AddOns`

# Database Structure

The structure of the resulting file will look like bellow.

```lua
DT_ItemDb = {
	[<Item ID>] = {
		["nam"] = <Item Name>,
		["qlt"] = <Item Quality>,
	},
    ..
}
```

```lua
DT_UnitDb = {
	[<Unit ID>] = {
		["mps"] = {
			[<Map ID>] = <Kills>,
		},
		["kls"] = <Kills>,
		["clf"] = <Classification>,
		["nam"] = <Unit Name>,
		["ltd"] = <Looting counter>,
		["its"] = {
			[<Item ID>] = <Looting counter>,
			..
		},
		["cpi"] = {
			["l:38"] = {
				["min"] = <min copper>,
				["max"] = <max copper>,
				["ltd"] = <copper looted>,
				["tot"] = <total looted copper>,
			},
			["l:39"] = {
				..
			},
			["_"] = {
				..
			},
		},
	},
    ..
}
```

```lua
DT_MapDb = {
	["<Map ID>"] = <Map Name>,
    ..
}
```
