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
DT_UnitDb = {
	[<Unit ID>] = {
		["zns"] = {
			[<Zone ID>] = <Kills>,
		},
		["kls"] = <Kills>,
		["clf"] = <Classification>,
		["mnc"] = <Min Copper>,
		["mxc"] = <Max Copper>,
		["nam"] = <Unit Name>,
		["cop"] = <Copper>,
		["ltd"] = <Looting counter>,
		["its"] = {
			[<Item ID>] = <Looting counter>,
			..
		},
	},
    ..
}
DT_ZoneDb = {
	[<Zone ID>] = <Zone Name>,
    ..
}

```
