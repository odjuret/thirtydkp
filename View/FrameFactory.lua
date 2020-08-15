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

function View:CreateContainerFrame(frameName, parentFrame, title, width, height)
    local f 
    if parentFrame == nil then
        f = CreateFrame("Frame", frameName, UIParent, "TooltipBorderedFrameTemplate");
        f:SetPoint(Const.CENTER_POINT, UIParent, Const.CENTER_POINT, 0, 60); -- point, relative frame, relative point on relative frame
    else
        f = CreateFrame("Frame", frameName, parentFrame, "TooltipBorderedFrameTemplate");
        f:SetPoint(Const.TOP_LEFT_POINT, parentFrame, Const.TOP_RIGHT_POINT, 0, 0); -- point, relative frame, relative point on relative frame
    end
	f:SetShown(false);
	f:SetSize(width, height);
    f:SetFrameStrata("HIGH");
    f:SetFrameLevel(8);

    f:EnableMouse(true);

    tinsert(UISpecialFrames, f:GetName());

    -- title
    f.title = f:CreateFontString(nil, Const.OVERLAY_LAYER);
    f.title:SetFontObject("ThirtyDKPHeader");
    f.title:SetPoint(Const.TOP_LEFT_POINT, f, Const.TOP_LEFT_POINT, Const.Margin, -10);
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

function View:AttachHoverOverTooltip(frame, titleText, textContent)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetText(titleText, 0.25, 0.75, 0.90, 1, true);
        if textContent ~= nil and textContent ~= "" then
            GameTooltip:AddLine(textContent, 1.0, 1.0, 1.0, true);
        end
        GameTooltip:Show();
    end);

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end);
end

function View:AttachHoverOverTooltipAndOnclick(frame, tooltipHeader, tooltipContent, onClickFunction)
    View:AttachHoverOverTooltip(frame, tooltipHeader, tooltipContent)

    frame:RegisterForClicks("AnyUp");
    frame:SetScript("OnClick", onClickFunction);
end

function View:SanitizeTextForBlizzFunctions(textToSanitize)
    local sanitizedText = ""
	if strfind(textToSanitize, "%%") then
		sanitizedText = gsub(textToSanitize, "%%", "%%%%")
    end
    return sanitizedText
end
