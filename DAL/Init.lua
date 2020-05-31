local addonName, ThirtyDKP = ... 

-- Initializing the core global variables
ThirtyDKP.DAL = {}  

local DAL = ThirtyDKP.DAL

function DAL:Initialize()
    ------------------------------------
    --	Import SavedVariables
    ------------------------------------
    -- saved variables starts as nil. we want a empty table
    if not ThirtyDKP_Database_DKPTable then ThirtyDKP_Database_DKPTable = {} end;
    DAL.DKPTableCopy 		= ThirtyDKP_Database_DKPTable;	
    DAL.DKPTableNumRows     = 0;
    if #ThirtyDKP_Database_DKPTable > 0 then DAL.DKPTableNumRows = #ThirtyDKP_Database_DKPTable end;

    table.sort(ThirtyDKP_Database_DKPTable, function(a, b)
        return a["player"] < b["player"]
    end)
    
end
