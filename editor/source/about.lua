local Slab = require("lib.Slab")

local Data = require("data")

local About = {}

function About:draw()
	if Slab.BeginDialog("AboutDialog", {
		Title = "About",
	}) then
		Slab.BeginLayout("layout", {
			AlignX = "center"
		})
			Slab.Text(Data.title, {URL = Data.github_url})
			Slab.Text(Data.version)
			Slab.Text(Data.author, {URL = Data.author_url})
			Slab.Separator()
			if Slab.Button("close") then
				Slab.CloseDialog()
			end
		Slab.EndLayout()

		Slab.EndDialog()
	end
end

return About
