DocLib [doclib]
===============

**A library to generate ingame manuals based on markdown files.**

Browse on: [GitHub](https://github.com/joe7575/doclib)

Download: [GitHub](https://github.com/joe7575/doclib/archive/main.zip)

![DocLib](https://github.com/joe7575/doclib/blob/main/screenshot.png)


### Introduction

DocLib is used to generate a manual as ingame documentation.
The manual content is generated based on markdown files.

An advantage of this solution is the dual use of the documentation:

- A markdown file as web solution e. g. on GitHub
- A book as ingame manual

To generate a manual for your mod:

- Create your documentation as markdown file
- Copy the python script `markdown_to_lua.py` to your mod folder
- Add your markdown file to the python script (the last few lines)
- Install mistune with `pip install mistune==0.8.4`
- Run the script with `python markdown_to_lua.py`
- Implement the book node according to `node.lua`


### Supported Markdown Markups

- Heading
- List
- Code block

In addition DocLib supports image links for the ingame manual:

- for node images: `[doclib:manual|image]`
- for PNG images: `[doclib_book_inv.png|image]`

See examples in `manual_EN.md`.


### Construction Plans

This is a feature, mainly used by the mod techage to show construction plans of
multi-block machines. But it can be used for any other mod, too.

![Plan](https://github.com/joe7575/doclib/blob/main/construction_plan.png)

A construction plan is a map with up to 12 * 10 fields. 
Each field can contain a node/item, text, or an image.

The arrangement is defined via a Lua table.

- Unused field elements are set to `false` 
- For a text field (red mark) a table like `{"text", "Pointless Demo"}` is used
- For an item field (yellow mark) a table like `{"item", "doclib_demo_img2.png", "Tooltip 1"}` is used.
  The third value is a tooltip. It can be a string, a node name, or `nil` for no tooltip.
- For an image field (blue mark) a table like `{"img", "doclib_book_inv.png", "2,2"}` is used.
  The third value is the image size in fields (width x height).

This is an example of a map with 12 * 10 fields from the demo code in `node.lua`:

```lua

local ITEM1 = {"item", "doclib_demo_img1.png"}
local ITEM2 = {"item", "doclib_demo_img2.png", "Tooltip 1"}
local ITEM3 = {"item", "doclib_demo_img3.png", "Tooltip 2"}
local ITEM4 = {"item", "doclib_demo_img4.png", "Tooltip 3"}
local ITEM5 = {"item", "doclib_book_inv.png",  "doclib:manual"}
local ITEM6 = {"item", "doclib:manual",  "doclib:manual"}
local IMG_1 = {"img", "doclib_book_inv.png", "2,2"}
local TEXT1 = {"text", "Top view"}
local TEXT2 = {"text", "Pointless Demo"}
local TEXT3 = {"text", "End"}

local plan1 = {
	{TEXT2, false, false, false, false, false, false, false, false, false, false, ITEM4},
	{false, false, false, TEXT1, false, false, false, false, IMG_1, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, false, ITEM1, false, false, false, false, false, false, false},
	{false, false, false, ITEM4, ITEM5, ITEM2, false, false, false, false, false, false},
	{false, false, false, false, ITEM3, false, false, false, false, false, false, false},
	{false, false, false, false, ITEM6, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{false, false, false, false, false, false, false, false, false, false, false, false},
	{TEXT3, false, false, false, false, false, false, false, false, false, false, ITEM4},
}

doclib.add_manual_plan("doclib", "EN", "demo1", plan1)
```

With `doclib.add_manual_plan` the plan is stored under the name "demo1".


### License

Copyright (C) 2023 Joachim Stolberg

Code: Licensed under the GNU AGPL version 3. See LICENSE.txt    
Textures: CC BY-SA 3.0 


### Dependencies 

none


### History

- 2023-07-30  V1.00  * First commit



