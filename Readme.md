# WOW Addon DataTracker

DataTracker is a WOW Addon to track looted items and fighted units in an ingame database.
The data can be used later for a graphical UI to search for items or units.

The resulting database is saved to a lua file which could be also imported to a website to build a nice looking Website out of it.

To show or export the data, find the file DataTracker.lua in your interface directory:

~~~
/_retail_/WTF/Account/ACCOUNT_NAME/SavedVariables/DataTracker.lua
~~~

> The addon was developed in WOW Shadowlands. Compatibility with Classic is not guaranteed.

# Installation

The addon is available on CurseForge https://www.curseforge.com/wow/addons/datatracker

You can also install it manually, by downloading one of the release packages and copying it to your addon path.
Thats usually `/_retail_/Interface/AddOns`

# Database Structure

The structure of the resulting file will look like bellow.

~~~lua
DT_ItemDb = {
	[179315] = {
		["looted"] = 18,
		["name"] = "Schattenhafter Schenkel",
		["quality"] = 1,
	},
    ..
}
DT_UnitDb = {
	[158439] = {
		["zones"] = {
			[1005] = 8,
		},
		["kills"] = 8,
		["name"] = "Verhüllte Arkanistin",
		["looted"] = {
			[173202] = 5,
			[173204] = 1,
			[177753] = 1,
		},
	},
    ..
}
DT_ZoneDb = {
	[1001] = "Orgrimmar",
	[1003] = "Nördliches Brachland",
	[1005] = "Revendreth",
    ..
}

~~~
