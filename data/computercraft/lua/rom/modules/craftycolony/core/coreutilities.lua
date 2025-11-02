-- Core Utils for CraftyColony
--
-- collection of utility functions for CraftyColony
-- helps handling display and user interactions

local CoreUtilities = {
  -- Public API Overview:
  -- CoreUtilities.Direction - Access to Direction module
  -- CoreUtilities.Generate - Access to Generate module
  -- CoreUtilities.Location - Access to Location module
  -- CoreUtilities.Logger - Access to Logger module
  -- CoreUtilities.Timer - Access to Timer module
}

-- import right into the CoreUtilities table
CoreUtilities.Direction	= require("craftycolony.utilities.direction")
CoreUtilities.Generate	= require("craftycolony.utilities.generate")
CoreUtilities.Location	= require("craftycolony.utilities.location")
CoreUtilities.Logger	= require("craftycolony.utilities.logger")
CoreUtilities.Timer		= require("craftycolony.utilities.timer")

--[[
      _                     _       _   _
     | |                   (_)     | | (_)
   __| | ___  ___  ___ _ __ _ _ __ | |_ _  ___  _ __
  / _` |/ _ \/ __|/ __| '__| | '_ \| __| |/ _ \| '_ \
 | (_| |  __/\__ \ (__| |  | | |_) | |_| | (_) | | | |
  \__,_|\___||___/\___|_|  |_| .__/ \__|_|\___/|_| |_|
                             | |
                             |_|


    This modules offers access to various utility functions used in CraftyColony.

--]]

--[[
      _       _
     | |     | |
   __| | __ _| |_ __ _
  / _` |/ _` | __/ _` |
 | (_| | (_| | || (_| |
  \__,_|\__,_|\__\__,_|

--]]

--[[
  _                 _
 | |               | |
 | | ___   ___ __ _| |
 | |/ _ \ / __/ _` | |
 | | (_) | (_| (_| | |
 |_|\___/ \___\__,_|_|

--]]

--[[
              _     _ _
             | |   | (_)
  _ __  _   _| |__ | |_  ___
 | '_ \| | | | '_ \| | |/ __|
 | |_) | |_| | |_) | | | (__
 | .__/ \__,_|_.__/|_|_|\___|
 | |
 |_|

--]]



--[[
           _
          | |
  _ __ ___| |_ _   _ _ __ _ __
 | '__/ _ \ __| | | | '__| '_ \
 | | |  __/ |_| |_| | |  | | | |
 |_|  \___|\__|\__,_|_|  |_| |_|


--]]

-- done
return CoreUtilities