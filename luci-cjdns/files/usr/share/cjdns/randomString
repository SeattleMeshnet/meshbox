#!/usr/bin/env lua

--[[ Generate Pseudo Random Password ]]--
 
char = { 
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", 
	"p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4",
	"5","6", "7","8","9", "@", "#", "$", "%", "&", "?"
}

math.randomseed(os.time())

pass = {}

function generate(s, l)
	size = math.random(s,l)

	for z = 1,size do

		case = math.random(1,2)
		a    = math.random(1,#char)

		if case == 1 then
			x = string.upper(char[a])
		elseif case == 2 then
			x = string.lower(char[a])
		end
		
		table.insert(pass, x)
	end

	return(table.concat(pass))
end
