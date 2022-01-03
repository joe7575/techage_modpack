# TA4 Addons

Currently, the following extensions for TA4 are available:
 - Touchscreen

## Touchscreen

[ta4_addons_touchscreen|image]

The touchscreen can be used like the normal TA 4 display.
Additionally, it supports the following commands, which allow to create a form that can be opened by right-clicking the touchscreen:

- add_content: Tries to add an element to the touchscreen formspec. Takes an element definition as payload. Returns the ID of the newly created element on success.
- update_content: Tries to modify an already existing touchscreen formspec element. Takes an element definition with an additional id field, which can be used to choose the element to be updated. Returns true on success.
- remove_content: Tries to remove an existing element from the touchscreen formspec. Takes a Store as payload. The only field on this Store should be the id field. Returns true on success.
- private: Makes the touchscreen private. Only players with protection access can submit the form.
- public: Makes the touchscreen public. All players can submit the form.

An element definition is a Store data structure. You can set the element type in the "type" field of this Store.
You can set properties for the element as further fields in this Store.
More or less reasonable default values are always provided for these additional properties,
but it is strongly suggested to always provide the values by yourself as the defaults are undocumented and subject to change.

On formspec submit, a Store is sent back to the controller as message.
The fields as available in the Minetest on_receive_fields callbacks are set in this store.
The field "_sent_by" contains the sender's name.
You can access this store by using the $get_msg(true) function of the Lua Controller.
Please do not forget the "true" value as first parameter; otherwise you'll only get access to the string representation of the message.

The form is rendered by using formspec version 3 (real coordinates enabled), so please use a recent Minetest client version.

When someone opens the touchscreen, a message will be sent to the controller.
This message contains a Store, in which the field "_touchscreen_opened_by" is set to the respective player name.

### Supported Elements and their properties

[ta4_addons_touchscreen|image]

Please note: This list is subject to change.

button: x, y, w, h, name, label
label: x, y, label
image: x, y, w, h, texture_name
animated_image: x, y, w, h, name, texture_name, frame_count, frame_duration, frame_start
item_image: x, y, w, h, item_name
pwdfield: x, y, w, h, name, label
field: x, y, w, h, name, label, default
field_close_on_enter: name, close_on_enter
textarea: x, y, w, h, name, label, default
image_button: x, y, w, h, texture_name, name, label
item_image_button: x, y, w, h, item_name, name, label
button_exit: x, y, w, h, name, label
image_button_exit: x, y, w, h, texture_name, name, label
box: x, y, w, h, color
checkbox: x, y, name, label, selected

For further information of the meaning of these elements, please consult Minetest's lua_api.txt.

## Matrix Screen

[ta4_addons_matrix_screen|image]

The matrix screen is a 16x16px display.
Different palettes with 64 colors each are available.

To program the display, you can send a base64 encoded string as a payload for the "pixels" command.
This string has to be 256 characters long. Each character corresponds to a pixel, line by line from the upper left-hand corner to the lower right-hand corner. 

It is recommended to use the TA4 Matrix Screen Programmer in order to create such strings easily.

The color palette can be changed with the "palette" command.
