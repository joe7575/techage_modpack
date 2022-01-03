techage.add_to_manual('DE', {
  "1,TA4 Addons",
  "2,Touchscreen",
  "3,Unterstützte Elemente und ihre Eigenschaften",
  "2,Matrix Screen",
}, {
  "Aktuell sind folgende Erweiterungen für TA4 verfügbar:\n"..
  "\n"..
  "  - Touchscreen\n"..
  "\n",
  "\n"..
  "\n"..
  "Der Touchscreen kann wie ein normales TA 4 Display verwendet werden.\n"..
  "Zusätzlich werden folgende Befehle unterstützt\\, die es erlauben\\, ein Formular zu erstellen\\, das mittels Rechtsklick geöffnet werden kann:\n"..
  "\n"..
  "  - add_content: Versucht\\, dem Touchscreen-Formular ein Element hinzuzufügen. Akzeptiert eine Element-Definition als Payload. Gibt im Erfolgsfall die ID des neu erstellten Elements zurück.\n"..
  "  - update_content: Versucht\\, ein bereits bestehendes Element zu modifizieren. Akzeptiert eine Element-Definition mit einem zusätzlichem ID-Feld als Payload. Dieses ID-Feld wird verwendet\\, um das zu aktualisierende Element zu wählen. Gibt im Erfolgsfall true zurück.\n"..
  "  - remove_content: Versucht\\, ein existierendes Element vom Touchscreen-Formular zu entfernen. Akzeptiert eine Store-Datenstruktur mit einem Feld \"id\" als Payload. Gibt im Erfolgsfall \"true\" zurück.\n"..
  "  - private: Macht den Touchscreen privat. Nur Spieler mit Störschutz-Zugang können das Formular absenden.\n"..
  "  - public: Macht den Touchscreen öffentlich. Alle Spieler können das Formular absenden.\n"..
  "\n"..
  "Eine Element-Definition ist eine \"Store\"-Datenstruktur. Der Element-Typ kann im \"type\"-Feld dieser Datenstruktur gesetzt werden.\n"..
  "Die Eigenschaften des entsprechenden Elements können als weitere Felder in der Store-Datenstruktur gesetzt werden.\n"..
  "Mehr oder weniger sinnvolle Standardwerte sind grundsätzlich für alle Eigenschaften gesetzt\\,\n"..
  "es wird aber dringend empfohlen\\, immer selbst die gewünschten Werte explizit zu übergeben\\, da die Standardwerte undokumentiert sind und sich ändern können.\n"..
  "\n"..
  "Wenn das Formular abgesendet wird\\, wird eine Store-Struktur an den Controller als Nachricht zurückgesandt.\n"..
  "Diese Datenstruktur beinhaltet alle Felder\\, die im on_receive_fields callback von Minetest verfügbar sind.\n"..
  "Zusätzlich ist im Feld \"_sent_by\" der Name des Absenders hinterlegt.\n"..
  "Mittels der Lua-Controller-Funktion $get_msg(true) kann auf diese Store-Struktur zugegriffen werden.\n"..
  "Der Wert \"true\" für den ersten Parameter darf dabei nicht vergessen werden\\; ansonsten wird nur die String-Repräsentation der Nachricht zurückgegeben.\n"..
  "\n"..
  "Das Formular wird mit der Formspec Version 3 angezeigt (real coordinates aktiviert). Es wird also dringend empfohlen\\, eine aktuelle Minetest Client-Version zu verwenden.\n"..
  "\n"..
  "Wenn der Touchscreen geöffnet wird\\, wird eine Nachricht an den Controller gesendet.\n"..
  "Diese Nachricht enthält einen Store\\, in dem das Feld \"_touchscreen_opened_by\" auf den jeweiligen Spielername gesetzt ist.\n"..
  "\n",
  "\n"..
  "\n"..
  "Bitte beachte: Diese Liste ist Gegenstand fortwährender Veränderung.\n"..
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
  "Für weitere Informationen über die Bedeutung dieser Elemente sei die Datei lua_api.txt des Minetest-Projekts empfohlen.\n"..
  "\n",
  "\n"..
  "\n"..
  "Der Matrix Screen ist eine 16x16px-Anzeige.\n"..
  "Es stehen verschiedene Paletten mit je 64 Farben zur Verfügung.\n"..
  "\n"..
  "Zum Programmieren der Anzeige wird ein Base64-codierter String als Payload des Befehls \"pixels\" gesendet.\n"..
  "Dieser String muss 256 Zeichen umfassen\\, wobei jedes Zeichen einem Pixel entspricht (zeilenweise von links oben nach rechts unten).\n"..
  "\n"..
  "Zum einfachen Erstellen solcher Strings sei der TA4 Matrix Screen Programmer empfohlen.\n"..
  "\n"..
  "Die verwendete Farbpalette kann über den Befehl \"palette\" geändert werden.\n"..
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
