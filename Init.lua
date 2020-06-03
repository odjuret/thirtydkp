local addonName, ThirtyDKP = ...

-- Initializing the three main layers of this addon
-- View handles the GUI
-- DAL (Data Access Layer) handles all data
-- Core handles logic and events. Main entry point of everything in this addon.
ThirtyDKP.View = {}
ThirtyDKP.DAL = {}  
ThirtyDKP.Core = {}