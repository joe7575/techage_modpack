return {
  titles = {
    "1,Heading 1",
    "2,Heading 2",
    "3,Heading 3",
    "2,Text Block",
    "2,Lists",
    "2,Code",
    "2,Construction plan",
  },
  texts = {
    "This is some demo text to demonstrate the generation of ingame manuals from\n"..
    "markdown files.\n"..
    "To open sub-chapters\\, click on the plus sign.\n"..
    "\n"..
    "\n"..
    "\n",
    "This is a second-level heading.\n"..
    "\n"..
    "\n"..
    "\n",
    "This is a third-level heading.\n"..
    "\n"..
    "\n"..
    "\n",
    "Lorem ipsum dolor sit amet\\, consetetur sadipscing elitr\\, sed diam nonumy\n"..
    "eirmod tempor invidunt ut labore et dolore magna aliquyam erat\\, sed diam\n"..
    "voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet\n"..
    "clita kasd gubergren\\, no sea takimata sanctus est Lorem ipsum dolor sit\n"..
    "amet. Lorem ipsum dolor sit amet\\, consetetur sadipscing elitr\\, sed diam\n"..
    "nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat\\,\n"..
    "sed diam voluptua.\n"..
    "\n"..
    "\n"..
    "\n",
    "This is a list:\n"..
    "\n"..
    "  - List\n"..
    "  - List\n"..
    "  - List\n"..
    "\n"..
    "\n"..
    "\n",
    "This is a code block:\n"..
    "\n"..
    "    doclib.create_manual(\"doclib\"\\, \"EN\"\\, settings)\n"..
    "    local content = dofile(MP..\"/manual_EN.lua\") \n"..
    "    doclib.add_to_manual(\"doclib\"\\, \"EN\"\\, content)\n"..
    "\n"..
    "\n"..
    "\n",
    "This is an example\\, how to make plans/block diagrams.\n"..
    "Click an the button on the right.\n"..
    "\n"..
    "\n"..
    "\n",
  },
  images = {
    "doclib_demo_img1.png",
    "doclib_demo_img2.png",
    "doclib_demo_img3.png",
    "doclib:manual",
    "default:dirt",
    "doclib_demo_img4.png",
    "",
  },
  plans = {
    "",
    "",
    "",
    "",
    "",
    "",
    "demo1",
  }
}