--[[

	DocLib
	======

	Copyright (C) 2023 Joachim Stolberg

	AGPL v3
	See LICENSE.txt for more information

	A library to generate ingame manuals based on markdown files.

]]--

function doclib.create_manual(mod, language, settings)
	doclib.manual = doclib.manual or {}
	doclib.manual[mod] = doclib.manual[mod] or {}
	doclib.manual[mod][language] = doclib.manual[mod][language] or {settings = settings, 
		content = {
			aTitles = {},
			aTexts = {},
			aImages = {},
			aPlans = {},
			kvImages = {},
			kvPlans =  {},
		}
	}
end

function doclib.add_to_manual(mod, language, content)
	local manual = doclib.manual[mod][language]

	for _, item in ipairs(content.titles) do
		table.insert(manual.content.aTitles, item)
	end
	for _, item in ipairs(content.texts) do
		table.insert(manual.content.aTexts, item)
	end
	for _, item in ipairs(content.images) do
		table.insert(manual.content.aImages, item)
	end
	for _, item in ipairs(content.plans) do
		table.insert(manual.content.aPlans, item)
	end
end

-- Replace image tag from the markdown file with real PNG file name or node name
function doclib.add_manual_image(mod, language, name, image)
	local manual = doclib.manual[mod][language]
	manual.content.kvImages[name] = image
end

-- Replace plan tag from the markdown file with real Lua plan table
function doclib.add_manual_plan(mod, language, name, plan)
	local manual = doclib.manual[mod][language]
	manual.content.kvPlans[name] = plan
end
