--=============================--
--==         E3 Wiki         ==--
--=============================--

if SERVER then
	AddCSLuaFile()
	
	AddCSLuaFile("wiki/html_compiler.lua")
	AddCSLuaFile("wiki/inits/autogen.lua")
else
	include("wiki/html_compiler.lua")
	include("wiki/inits/autogen.lua")
	
	hook.Add("Expression3.AddGolemTabTypes", "Expression3.AddGolemTabTypes.wiki", function(self)
		self:AddCustomTab(true, "html", function(self, html, name, w, h)
			local HTML = vgui.Create("GOLEM_DHTML")
			HTML:Setup(html, ScrW(), ScrH())
			
			local Sheet = self.pnlTabHolder:AddSheet(name or "E3 Wiki", HTML, "fugue/question.png", function(pnl) self:CloseTab(pnl:GetParent(), true) end)
			self.pnlTabHolder:SetActiveTab(Sheet.Tab)
			Sheet.Panel:RequestFocus()
			
			Sheet.Tab.DoRightClick = function(pnl)
				local Menu = DermaMenu()
				
				Menu:AddOption("Close", function() self:CloseTab(pnl, false) end)
				Menu:AddOption("Close others", function() self:CloseAllBut(pnl) end)
				Menu:AddOption("Close all tabs", function() self:CloseAll()  end)
				
				Menu:Open()
			end
			
			return Sheet 
		end, function(self)
			
		end)
	end)
end

--[[----------------------
Example to add something to wiki (This example is for a function, it is very simular for other things)

NOTE: You dont have to add it manualy!
It will automaticly add any function that is added,
this is only if you want the page more detailed
--------------------------

local lib = "exampleLib"			-- This is the lib it will be added to
local func = "anExampleFunc(t,s)"	-- This is the name that will appear in the wiki browser
local exampleFunc = {				-- This is the data to give information to the page
	func = {
		side = "shared",
		func = "anExampleFunc"
	}, desc = [[
		This is the best description ever made.
		I swear it is!
		This is a example description.
	]]
	--[[		-- This line only exists because the line above stopped the command
	, args = {
		data = {
			type = "table",
			name = "data",
			desc = "A table with data"
		}, index = {
			type = "string",
			name = "index",
			desc = "The index of the table"
		}
	}, rtns = {
		thing = {
			type = "any value",
			desc = "The variable from the given index of the given table"
		}, table = {
			type = "table",
			desc = "The table itself"
		}
	}
}

EXPR_WIKI.RegisterFunction(lib, func, EXPR_WIKI.COMPILER.Function(exampleFunc))

--]]----------------------