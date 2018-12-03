--[[
	Golem need a decent options menu.
	So lets get rocky to rumble.
]]

local BASE = {};

AccessorFunc( BASE, "m_sName", 			"Name", 		FORCE_STRING );
AccessorFunc( BASE, "m_sCommand", 		"Command", 		FORCE_STRING );
AccessorFunc( BASE, "m_sCookie", 		"Cookie", 		FORCE_STRING );

AccessorFunc( BASE, "m_cBGColor", 		"BackGroundColor" );
AccessorFunc( BASE, "m_cFontColor", 	"FontColor" );
AccessorFunc( BASE, "m_sFont", 			"Font", 		FORCE_STRING );

function BASE:Init()
	self:SetName("option");
	self:SetFont("ChatFont");
	self:SetFontColor(Color(0, 0, 0));
	self:SetBackGroundColor(Color(255, 100, 100));

	self:SetTall(50);

	self.m_pCanvas = self:Add("DPanel");
end

function BASE:GetCanvas()
	return self.m_pCanvas;
end

function BASE:AllParentsVisible()
	local pnl = self;
	local world = vgui.GetWorldPanel();

	while IsValid(pnl) do
		if pnl == world then break; end
		if not pnl:IsVisible() then return false; end
		pnl = pnl:GetParent();
	end

	return true;
end

function BASE:PerformLayout( w, h )
	local canvas = self:GetCanvas();

	if canvas then
		canvas:SetPos(8, h - 28);
		canvas:SetSize(w - 16, 22);
		canvas:InvalidateLayout();
	end
end

function BASE:Paint(w, h)
	draw.RoundedBox( 8, 5, 5, w - 10, h - 10, self:GetBackGroundColor() );

	draw.DrawText( self:GetName(), self:GetFont(), 6, 6, self:GetFontColor(), TEXT_ALIGN_LEFT );
end

function BASE:GetValue(value)
	return self.m_oValue;
end

function BASE:SetValue(value, changed)
	local oldValue = self:GetValue();

	self.m_oValue = value;

	if changed == null then
		changed = (value ~= oldValue);
	end

	if changed then
		local cookie = self:GetCookie();
		local command = self:GetCommand();

		if cookie then
			cookie.Set(cookie, self:ToString(value));
		end

		if command then
			RunConsoleCommand(command, self:ToString());
		end

		if self.ValueChanged then
			self:ValueChanged(value, oldValue);
		end
	end
end

function BASE:ToStirng()
	return tostring(self:GetValue());
end

function BASE:SetUpFromTable(tbl)
	self:SetUp(tbl.Name or "");

	for k, v in pairs(tbl) do
		k = "Set" .. k;
		if self[k] then self[k](self, v); end
	end
end

vgui.Register( "GOLEM_Setting", BASE, "EditablePanel" );

--[[
	On and Off.
]]

local ONOFF = { };

AccessorFunc( ONOFF, "m_mIconOn", 	"IconOn" );
AccessorFunc( ONOFF, "m_mIconOff", 	"IconOff" );

AccessorFunc( ONOFF, "m_sDescription", 	"Description" );

AccessorFunc( ONOFF, "m_sMessageOn", 	"MessageOn" );
AccessorFunc( ONOFF, "m_sMessageOff", 	"MessageOff" );

local mOn = Material("materials/fugue/status.png");
local mOff = Material("materials/fugue/status-offline.png");

function ONOFF:Init()
	local canvas = self:GetCanvas();

	self.btnIcon = canvas:Add("GOLEM_ImageButton");
	self.btnIcon:Dock(LEFT);

	self.btnIcon.DoClick = function()
		self:SetValue( not self:GetValue() );
	end;

	canvas.Paint = function(_, w, h)
		draw.DrawText( self:GetDescription(), self:GetFont(), 16, 2, self:GetFontColor(), TEXT_ALIGN_LEFT );
	end;
end

function ONOFF:SetUp(name, onIcon, offIcon, onDesc, offDesc)
	self:SetName(name);
	self:SetIconOn(onIcon or mOn);
	self:SetIconOff(offIcon or mOff);
	self:SetMessageOn(onDesc or "");
	self:SetMessageOff(offDesc or onDesc or "");

	self:SetValue(false, true);
end

function ONOFF:ValueChanged(value, old)
	self.btnIcon:SetMaterial( value and self:GetIconOn() or self:GetIconOff() );

	self:SetDescription( value and self:GetMessageOn() or self:GetMessageOff() );

	if self.OnValueChanged then self:OnValueChanged(value, old); end
end

vgui.Register( "GOLEM_Setting_OnOff", ONOFF, "GOLEM_Setting" );

--[[
	Text
]]

local TEXT = { };

AccessorFunc( TEXT, "m_mIcon",		 	"Icon" );
AccessorFunc( TEXT, "m_mSaveIcon", 	"SaveIcon" );

local mText = Material("materials/fugue/quill.png");
local mDisk = Material("materials/fugue/disk.png");

function TEXT:Init()
	local canvas = self:GetCanvas();

	self.btnIcon = canvas:Add("GOLEM_ImageButton");
	self.btnIcon:Dock(LEFT);

	self.text = canvas:Add("DTextEntry");
	self.text:SetUpdateOnType(true);
	self.text:SetDrawBackground(false);
	self.text:Dock(FILL);

	self.text.OnEnter = function()
		self:SetValue( self:GetValue() );
	end;

	self.text.OnValueChange = function(_, value)
		self:UpdateSaveIcion();
	end;

	self.btnIcon.DoClick = function()
		self:SetValue( self.text:GetValue() );
	end;

	canvas.Paint = function(_, w, h)
	end;
end

function TEXT:UpdateSaveIcion()
	self.btnIcon:SetMaterial( self.text:GetValue() == self:GetValue() and self:GetIcon() or self:GetSaveIcon());
end

function TEXT:SetUp(name, icon, saveicon)
	self:SetName(name);
	self:SetIcon(icon or mText);
	self:SetSaveIcon(saveicon or mDisk);
	self.text:OnValueChange(self.text:GetValue());

	self.text:SetFont( self:GetFont() );
	self.text:SetTextColor( self:GetFontColor() );

	self:SetValue("", true);
end

function TEXT:ValueChanged(value, old)
	self.text:SetValue(value);

	self:UpdateSaveIcion();

	if self.OnValueChanged then self:OnValueChanged(value, old); end
end

vgui.Register( "GOLEM_Setting_Text", TEXT, "GOLEM_Setting" );

--[[
	Expanding
]]

local EXPAND = { };

AccessorFunc( EXPAND, "m_mOpenIcon",		 	"OpenIcon" );
AccessorFunc( EXPAND, "m_mCloseIcon",		 	"CloseIcon" );

local mOpen = Material("materials/fugue/toggle-small-expand.png");
local mClose = Material("materials/fugue/toggle-small.png");

function EXPAND:Init()
	local canvas = self:GetCanvas();

	self.btnIcon = canvas:Add("GOLEM_ImageButton");
	self.btnIcon:Dock(LEFT);

	self.btnIcon.DoClick = function()
		self:ToogleMenu();
	end;
end

function EXPAND:CreateMenu(height, openIcon, closeIcon)
	local canvas = self:GetCanvas();

	self.pnlMenu = vgui.Create("DScrollPanel")
	self.pnlMenu:SetTall(height);

	self:SetOpenIcon(openIcon or mOpen);
	self:SetCloseIcon(closeIcon or mClose);
	self:HideMenu();

	self.pnlMenu.Think = function()
		if self:IsOpen() then
			if not self:AllParentsVisible() then
				self:HideMenu();
			else
				self:RepositionMenu();
			end
		end
	end;

	return self.pnlMenu;
end

function EXPAND:GetMenu()
	return self.pnlMenu;
end

function EXPAND:AddItem(item)
	if self.pnlMenu then
		self.pnlMenu:AddItem(item);
	end
end

function EXPAND:RepositionMenu()
	local canvas = self:GetCanvas();
	local menu = self:GetMenu();

	local x, y = self:LocalToScreen(canvas:GetPos());
	local w, h = canvas:GetSize();
	local t = menu:GetTall();

	if y + h + t < ScrH() then
		y = y + h;
	else
		y = y - t;
	end

	menu:SetPos(x, y);

	menu:MakePopup();
end

function EXPAND:ShowMenu()
	self.btnIcon:SetMaterial(self:GetCloseIcon());

	local canvas = self:GetCanvas();
	local menu = self:GetMenu();

	if not menu then return; end

	local w, h = canvas:GetSize();

	menu:SetVisible(true);

	menu:SetWide(w);

	self:RepositionMenu();

	self.m_bOpen = true;

	self:OnShowMenu();
end

function EXPAND:HideMenu()
	local menu = self:GetMenu();

	if not menu then return; end

	self.btnIcon:SetMaterial(self:GetOpenIcon());

	menu:SetVisible(false);

	self.m_bOpen = false;

	self:OnHideMenu();
end

function EXPAND:OnShowMenu()
end

function EXPAND:OnHideMenu()
end

function EXPAND:IsOpen()
	return self.m_bOpen;
end

function EXPAND:ToogleMenu()
	if self:IsOpen() then
		self:HideMenu();
	else
		self:ShowMenu();
	end
end

vgui.Register( "GOLEM_Setting_Expandable", EXPAND, "GOLEM_Setting" );

--[[
	Color Wheel
]]

local WHEEL = {};

local bNoSave = false;
local mColor = Material("materials/fugue/spectrum-absorption.png");

function WHEEL:Init()
	local canvas = self:GetCanvas();

	canvas.Paint = function(_, w, h)
		local open = self:IsOpen();
		local color = self:GetValue();
		
		local wide = w - 24;

		draw.RoundedBox( 8, 20, 2, wide, h - 4, color);

		if open and self.colorPicker then
			color = self.colorPicker:GetColor();

			draw.RoundedBox( 8, 24, 4, h - 8, h - 8, color);
		end

		draw.DrawText( string.format("%s, %s, %s", color.r, color.g, color.b), self:GetFont(), 20 + (wide * 0.5), 3, self:GetFontColor(), TEXT_ALIGN_CENTER );

	end;
end

function WHEEL:OnShowMenu()
	if self.colorPicker then
		self.colorPicker:SetColor(self:GetValue());
	end
end

function WHEEL:OnHideMenu()
	if self.colorPicker and not bNoSave then
		self:SetValue(self.colorPicker:GetColor());
	end
end

function WHEEL:SetUp(name, height, openIcon, closeIcon, saveIcon)
	self:SetName(name);

	local menu = self:CreateMenu(height or 300, openIcon or mColor, closeIcon or mDisk);

	self.colorPicker = menu:Add("DColorCombo");
	self.colorPicker:Dock(FILL);

	self:SetValue(Color(255, 255, 255), true);
end

function WHEEL:ValueChanged(value, old)
	self.colorPicker:SetColor(value);

	if self.OnValueChanged then self:OnValueChanged(value, old); end
end

vgui.Register( "GOLEM_Setting_Color", WHEEL, "GOLEM_Setting_Expandable" );

--[[
	Golem Settings Menu v2.0
]]

local PANEL = {};

function PANEL:Init()	
	self.testBool = self:Add("GOLEM_Setting_OnOff");
	self.testBool:SetUp("Boolean", nil, nil, "This setting is on.", "This setting is off.");
	self.testBool:Dock(TOP);

	self.testText = self:Add("GOLEM_Setting_Text");
	self.testText:SetUp("Text");
	self.testText:SetValue("Example of a text seting.");
	self.testText:Dock(TOP);

	self.testColor = self:Add("GOLEM_Setting_Color");
	self.testColor:SetUp("Color");
	self.testColor:SetValue(Color(0, 255, 0));
	self.testColor:Dock(TOP);
end

vgui.Register("GOLEM_Options2", PANEL, "EditablePanel")