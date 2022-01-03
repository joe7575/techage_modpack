techage.add_to_manual('EN', {
  "1,TA4 Addons",
  "2,Touchscreen",
  "3,Supported Elements and their properties",
  "2,Matrix Screen",
}, {
  "Currently\\, the following extensions for TA4 are available:\n"..
  "\n"..
  "  - Touchscreen\n"..
  "\n",
  "\n"..
  "\n"..
  "The touchscreen can be used like the normal TA 4 display.\n"..
  "Additionally\\, it supports the following commands\\, which allow to create a form that can be opened by right-clicking the touchscreen:\n"..
  "\n"..
  "  - add_content: Tries to add an element to the touchscreen formspec. Takes an element definition as payload. Returns the ID of the newly created element on success.\n"..
  "  - update_content: Tries to modify an already existing touchscreen formspec element. Takes an element definition with an additional id field\\, which can be used to choose the element to be updated. Returns true on success.\n"..
  "  - remove_content: Tries to remove an existing element from the touchscreen formspec. Takes a Store as payload. The only field on this Store should be the id field. Returns true on success.\n"..
  "  - private: Makes the touchscreen private. Only players with protection access can submit the form.\n"..
  "  - public: Makes the touchscreen public. All players can submit the form.\n"..
  "\n"..
  "An element definition is a Store data structure. You can set the element type in the \"type\" field of this Store.\n"..
  "You can set properties for the element as further fields in this Store.\n"..
  "More or less reasonable default values are always provided for these additional properties\\,\n"..
  "but it is strongly suggested to always provide the values by yourself as the defaults are undocumented and subject to change.\n"..
  "\n"..
  "On formspec submit\\, a Store is sent back to the controller as message.\n"..
  "The fields as available in the Minetest on_receive_fields callbacks are set in this store.\n"..
  "The field \"_sent_by\" contains the sender's name.\n"..
  "You can access this store by using the $get_msg(true) function of the Lua Controller.\n"..
  "Please do not forget the \"true\" value as first parameter\\; otherwise you'll only get access to the string representation of the message.\n"..
  "\n"..
  "The form is rendered by using formspec version 3 (real coordinates enabled)\\, so please use a recent Minetest client version.\n"..
  "\n"..
  "When someone opens the touchscreen\\, a message will be sent to the controller.\n"..
  "This message contains a Store\\, in which the field \"_touchscreen_opened_by\" is set to the respective player name.\n"..
  "\n",
  "\n"..
  "\n"..
  "Please note: This list is subject to change.\n"..
  "\n"..
  "button: x\\, y\\, w\\, h\\, name\\, label\n"..
  "label: x\\, y\\, label\n"..
  "image: x\\, y\\, w\\, h\\, texture_name\n"..
  "animated_image: x\\, y\\, w\\, h\\, name\\, texture_name\\, frame_count\\, frame_duration\\, frame_start\n"..
  "item_image: x\\, y\\, w\\, h\\, item_name\n"..
  "pwdfield: x\\, y\\, w\\, h\\, name\\, label\n"..
  "field: x\\, y\\, w\\, h\\, name\\, label\\, default\n"..
  "field_close_on_enter: name\\, close_on_enter\n"..
  "textarea: x\\, y\\, w\\, h\\, name\\, label\\, default\n"..
  "image_button: x\\, y\\, w\\, h\\, texture_name\\, name\\, label\n"..
  "item_image_button: x\\, y\\, w\\, h\\, item_name\\, name\\, label\n"..
  "button_exit: x\\, y\\, w\\, h\\, name\\, label\n"..
  "image_button_exit: x\\, y\\, w\\, h\\, texture_name\\, name\\, label\n"..
  "box: x\\, y\\, w\\, h\\, color\n"..
  "checkbox: x\\, y\\, name\\, label\\, selected\n"..
  "\n"..
  "For further information of the meaning of these elements\\, please consult Minetest's lua_api.txt.\n"..
  "\n",
  "\n"..
  "\n"..
  "The matrix screen is a 16x16px display.\n"..
  "Different palettes with 64 colors each are available.\n"..
  "\n"..
  "To program the display\\, you can send a base64 encoded string as a payload for the \"pixels\" command.\n"..
  "This string has to be 256 characters long. Each character corresponds to a pixel\\, line by line from the upper left-hand corner to the lower right-hand corner. \n"..
  "\n"..
  "It is recommended to use the TA4 Matrix Screen Programmer in order to create such strings easily.\n"..
  "\n"..
  "The color palette can be changed with the \"palette\" command.\n"..
  "\n",
}, {
  "",
  "ta4_addons_touchscreen",
  "ta4_addons_touchscreen",
  "ta4_addons_matrix_screen",
}, {
  "",
  "",
  "",
  "",
})
