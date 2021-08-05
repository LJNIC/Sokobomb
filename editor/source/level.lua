local Level = class()

function Level:new(data)
	tablex.copy(data, self)
	print("new level created:")
	pretty.print(self)
end

return Level
