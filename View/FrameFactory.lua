local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Const = ThirtyDKP.View.Constants;

local menuFrame = CreateFrame("Frame", "ThirtyDKPRightClickMenuFrame", UIParent, "UIDropDownMenuTemplate")

function View:CreateNumericInputFrame(parent, label, value, valueChangedCallback)
    local wrapper = CreateFrame("Frame", nil, parent, nil);
    wrapper:SetSize(parent:GetWidth(), 30);

    wrapper.label = wrapper:CreateFontString(nil, Const.OVERLAY_LAYER);
    wrapper.label:SetFontObject("GameFontNormal");
    wrapper.label:ClearAllPoints();
    wrapper.label:SetText(label);
    wrapper.label:SetPoint(Const.TOP_LEFT_POINT, wrapper, Const.TOP_LEFT_POINT, 0, -5)

    wrapper.input = CreateFrame("EditBox", nil, wrapper, nil);
    wrapper.input:SetFontObject("GameFontNormal");
    wrapper.input:SetSize(30, 20);
    wrapper.input:SetAutoFocus(false);
    wrapper.input:SetNumeric(true);
    wrapper.input:SetNumber(value);
    wrapper.input:SetJustifyH("CENTER");
    wrapper.input:SetPoint(Const.TOP_RIGHT_POINT, wrapper, Const.TOP_RIGHT_POINT, 0, 0);
    wrapper.input:SetScript("OnTextChanged", function(self)
        valueChangedCallback(self);
    end);
    wrapper.input:SetScript("OnEnterPressed", function(self)
        self:ClearFocus();
    end);
    wrapper.input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus();
    end);
    wrapper.input:SetScript("OnSpacePressed", function(self)
        self:ClearFocus();
    end);

    local tex = wrapper.input:CreateTexture(nil, "BACKGROUND");
    tex:SetAllPoints();
    tex:SetColorTexture(0.2, 0.2, 0.2);

    return wrapper;
end

function View:CreateTextInputFrame(parent, label, value, valueChangedCallback)
    local wrapper = CreateFrame("Frame", nil, parent, nil);
    wrapper:SetSize(parent:GetWidth(), 30);

    wrapper.label = wrapper:CreateFontString(nil, Const.OVERLAY_LAYER);
    wrapper.label:SetFontObject("GameFontNormal");
    wrapper.label:ClearAllPoints();
    wrapper.label:SetText(label);
    wrapper.label:SetPoint(Const.TOP_LEFT_POINT, wrapper, Const.TOP_LEFT_POINT, 0, -5)

    wrapper.input = CreateFrame("EditBox", nil, wrapper, nil);
    wrapper.input:SetFontObject("GameFontNormal");
    wrapper.input:SetSize(wrapper:GetWidth() - wrapper.label:GetStringWidth(), 20);
    wrapper.input:SetAutoFocus(false);
    wrapper.input:SetPoint(Const.TOP_LEFT_POINT, wrapper.label, Const.TOP_RIGHT_POINT, 10, 5);
    wrapper.input:SetScript("OnTextChanged", function(self)
        valueChangedCallback(self);
    end);
    wrapper.input:SetScript("OnEnterPressed", function(self)
        self:ClearFocus();
    end);
    wrapper.input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus();
    end);

    local tex = wrapper.input:CreateTexture(nil, "BACKGROUND");
    tex:SetAllPoints();
    tex:SetColorTexture(0.2, 0.2, 0.2);

    return wrapper;
end

function View:CreateContainerFrame(parentFrame, title, width, height)
    local f = CreateFrame("Frame", "ThirtyDKP_HistoryFrame", parentFrame, "TooltipBorderedFrameTemplate");
	f:SetShown(false);
	f:SetSize(width, height);
	f:SetFrameStrata("HIGH");
	f:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
    f:EnableMouse(true);

    -- title
    f.title = f:CreateFontString(nil, Const.OVERLAY_LAYER);
    f.title:SetFontObject("GameFontNormal");
    f.title:SetPoint(Const.TOP_LEFT_POINT, f, Const.TOP_LEFT_POINT, 15, -10);
    f.title:SetText(title);

    f.closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeBtn:SetPoint(Const.TOP_RIGHT_POINT, f, Const.TOP_RIGHT_POINT)

    return f
end

function View:CreateRightClickMenu(self, title, actionHeader, actionFunction)
    local menu = {
    { text = title, isTitle = true},
    { text = actionHeader, func = actionFunction },
    }
    EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU", 2);
end