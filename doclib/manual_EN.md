# Heading 1

This is some demo text to demonstrate the generation of ingame manuals from
markdown files.
To open sub-chapters, click on the plus sign.

[doclib_demo_img1.png|image]

## Heading 2

This is a second-level heading.

[doclib_demo_img2.png|image]

### Heading 3

This is a third-level heading.

[doclib_demo_img3.png|image]

## Text Block

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy
eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam
voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet
clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit
amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam
nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat,
sed diam voluptua.

[doclib:manual|image]

## Lists

This is a list:

- List
- List
- List

[default:dirt|image]

## Code

This is a code block:

```
doclib.create_manual("doclib", "EN", settings)
local content = dofile(MP.."/manual_EN.lua") 
doclib.add_to_manual("doclib", "EN", content)
```

[doclib_demo_img4.png|image]


## Construction plan

This is an example, how to make plans/block diagrams.
Click an the button on the right.

[demo1|plan]

