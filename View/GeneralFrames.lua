local addonName, ThirtyDKP = ...
local View = ThirtyDKP.View;
local Const = ThirtyDKP.View.Constants;

function View:CreateInputFrame(parent, text, value, valueChangedCallback)
    local wrapper = CreateFrame("Frame", nil, parent, nil);
    wrapper:SetSize(parent:GetWidth(), 30);

    wrapper.label = wrapper:CreateFontString(nil, Const.OVERLAY_LAYER);
    wrapper.label:SetFontObject("GameFontNormal");
    wrapper.label:ClearAllPoints();
    wrapper.label:SetText(text);
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