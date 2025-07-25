return {
  titles = {
    "1,Signs Bot",
    "2,Erste Schritte",
    "2,Schilder",
    "2,Sensors and Actuators",
    "2,Sensor Verbindungswerkzeug",
    "2,Inventar",
    "2,Blöcke",
    "3,Signs Bot Box",
    "3,Bot Klappe",
    "3,Zeichen Kopierer",
    "3,Bot Sensor",
    "3,Block Sensor",
    "3,Ernte Sensor",
    "3,Signs Bot Kiste",
    "3,Bot Timer",
    "3,Roboter Steuerungseinheit",
    "3,Sensor Erweiterung",
    "3,Signal AND",
    "3,Signal Verzögerer",
    "3,Zeichen 'Farming'",
    "3,Zeichen 'Vorlage'",
    "3,Zeichen 'kopiere 3x3x3'",
    "3,Zeichen 'Blumen'",
    "3,Zeichen 'Espe'",
    "3,Zeichen 'Kommando'",
    "3,Zeichen \"Rechts drehen\"",
    "3,Zeichen \"Links drehen\"",
    "3,Zeichen \"Nehme Gegenstand\"",
    "3,Zeichen \"Lege Gegenstand\"",
    "3,Zeichen \"Stopp\"",
    "3,Zeichen \"Lege in den Wagen\" (minecart)",
    "3,Zeichen \"Nehme aus dem Wagen\" (minecart)",
    "3,Zeichen 'Schöpfe Wasser' (xdecor)",
    "3,Zeichen 'Koche Suppe' (xdecor)",
    "2,Bot Kommandos",
    "3,Techage spezifische Kommandos",
    "3,Flow Control Kommandos",
    "3,Weitere Sprungkommands",
    "3,Flow Control Beispiele",
    "4,Beispiel mit einer Funktion am Anfang:",
    "4,Beispiel mit einer Funktion am Ende:",
  },
  texts = {
    "Ein durch Zeichen/Schilder gesteuerter Roboter.\n"..
    "\n"..
    "Web Doku: https://github.com/joe7575/signs_bot/blob/master/manual_DE.md\n"..
    "\n"..
    "\n"..
    "\n",
    "Nachdem du die Signs Bot Box platziert hast\\, kannst du den Bot über die\n"..
    "Schaltfläche „An“ im Boxmenü starten. Wenn der Bot sofort in seine Box zurückkehrt\\,\n"..
    "muss der Bot zuerst mit elektrischer Energie (Techage) aufgeladen werden.\n"..
    "Anschließend läuft der Bot geradeaus\\, bis er auf ein Hindernis trifft\n"..
    "(eine Stufe mit zwei oder mehr Blöcken nach oben oder unten\\, oder ein Schild.)\n"..
    "\n"..
    "Der Bot kann nur durch Schilder gesteuert werden\\, die ihm in den Weg gestellt werden.\n"..
    "\n"..
    "Falls der Bot ein Schild erreicht\\, führt er die Befehle auf dem Schild aus.\n"..
    "Falls der erste Befehl auf dem Schild z.B. lautet: „turn_around“\\, dreht sich der Bot \n"..
    "um und geht zurück. In diesem Fall erreicht der Bot seine Box erneut und\n"..
    "schaltet sich ab.\n"..
    "\n"..
    "Falls der Bot ein Hindernis erreicht\\, stoppt er\\, oder führt\\, falls verfügbar\\,\n"..
    "den nächsten Befehle vom letzten Schild aus.\n"..
    "\n"..
    "Die Signs Bot Box verfügt über ein Inventar mit 6 Slots (Speicherplätze) für Schilder\n"..
    "und 8 Slots für andere Gegenstände (die vom Bot platziert/abgebaut werden).\n"..
    "Dieses Inventar simuliert das interne Inventar des Bots. Das bedeutet\\, dass du\n"..
    "nur dann Zugriff auf das Inventar hast\\, wenn der Bot ausgeschaltet ist\n"..
    "(in seiner Box „sitzt“).\n"..
    "\n"..
    "Außerdem gibt es folgende Blöcke:\n"..
    "\n"..
    "  - Sensoren: Diese können ein Signal an einen Aktor senden\\, wenn sie mit dem\nAktor verbunden sind.\n"..
    "  - Aktoren: Diese führen eine Aktion aus\\, wenn sie ein Signal von einem Sensor empfangen.\n"..
    "\n"..
    "\n"..
    "\n",
    "Du steuerst die Richtung des Bots über die „links drehen“ und\n"..
    "„rechts drehen“-Schilder (Schilder mit dem Pfeil). Der Bot kann Stufen\n"..
    "überwinden (einen Block hoch/runter).\n"..
    "Es gibt aber auch Befehle\\, um den Bot nach oben und unten zu bewegen.\n"..
    "\n"..
    "Es ist nicht notwendig\\, einen Weg zurück zur Box zu markieren. Mit dem\n"..
    "Befehl „turn_off“ schaltet sich der Bot ab und ist von jeder Position aus wieder\n"..
    "in seiner Box. Das Gleiche gilt\\, wenn du den Bot über das Box-Menü ausschaltest.\n"..
    "Wenn der Bot ein Schild aus der falschen Richtung (von hinten oder von der Seite)\n"..
    "erreicht\\, wird das Schild ignoriert.\n"..
    "Der Bot wird einfach über das Schild steigen.\n"..
    "\n"..
    "Alle vordefinierten Schilder verfügen über ein Menü mit einer Liste der Bot-Befehle.\n"..
    "Diese Schilder können nicht geändert werden\\, aber du kannst deine eigenen Schilder\n"..
    "erstellen und programmieren. Hierzu musst du das „command“-Schild verwenden.\n"..
    "Dieses Schild verfügt über ein Bearbeitungsfeld für Befehle und eine Hilfeseite mit\n"..
    "allen verfügbaren Befehlen. Die Hilfeseite verfügt über eine Kopierschaltfläche\\,\n"..
    "um die Programmierung zu vereinfachen.\n"..
    "\n"..
    "Auch für die eigenen Schilder ist es wichtig zu wissen: Nach der Ausführung des\n"..
    "letzten Befehls des Schildes verfällt der Bot wieder in sein Standardverhalten\n"..
    "und läuft in die eingeschlagene Richtung.\n"..
    "\n"..
    "Eine Standardaufgabe des Bots besteht darin\\, Gegenstände von einer Truhe zu\n"..
    "einer anderen Truhe (oder einem Block mit einem truhenähnlichen Inventar) zu\n"..
    "verschieben. Dies kann über die beiden Zeichen „Nehme Gegenstand“ und\n"..
    "„Lege Gegenstand“ erfolgen.\n"..
    "Diese Schilder müssen auf dem Truhenblock platziert werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Zusätzlich zu den Schildern kann der Bot mittels Sensoren gesteuert werden. Sensoren wie der Bot-Sensor haben zwei Zustände: ein und aus. Wenn der Bot-Sensor einen Bot erkennt\\, wechselt er in den Zustand „Ein“ und sendet ein Signal an einen angeschlossenen Block\\, einen sogenannten Aktor.\n"..
    "\n"..
    "Sensoren sind:\n"..
    "\n"..
    "  - Bot-Sensor: Sendet ein Signal\\, wenn ein Roboter am Sensor vorbeikommt\n"..
    "  - Block Sensor: Sendet ein Signal\\, wenn der Sensor einen (neuen) Block erkennt\n"..
    "  - Ernte Sensor: Sendet ein Signal\\, wenn beispielsweise Weizen ausgewachsen ist\n"..
    "  - Signs Bot Kiste: Sendet je nach Truhenzustand (leer\\, voll) ein Signal\n"..
    "\n"..
    "Aktuatoren sind:\n"..
    "\n"..
    "  - Roboter Box: Kann den Bot ein- und ausschalten\n"..
    "  - Roboter Steuerungseinheit: Kann verwendet werden\\, um ein Schild auszutauschen\\,\num dadurch den Bot zu lenken\n"..
    "\n"..
    "Sensoren müssen mit Aktoren verbunden (gepaart) werden. Dafür kann das\n"..
    "„Sensor Verbindungswerkzeug“ genutzt werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Um ein Signal von einem Sensor an einen Aktor zu senden\\, muss der Sensor mit dem\n"..
    "Aktor verbunden (gepaart) werden. Zur Verbindung von Sensor und Aktor muss das\n"..
    "Sensor Connection Tool verwendet werden. Klicke einfach mit dem Werkzeug\n"..
    "auf beide Blöcke und der Sensor wird mit dem Aktor verbunden. Eine erfolgreiche\n"..
    "Verbindung wird durch ein Ping/Pong-Geräusch angezeigt.\n"..
    "\n"..
    "Bevor du den Sensor mit dem Aktor verbindest\\, stelle sicher\\, dass sich der Aktor im\n"..
    "gewünschten Zustand befindet.\n"..
    "Beispiel: Wenn du den Bot mit einem Sensor starten möchtest\\, verbinde den Sensor\n"..
    "mit der Bot Box\\, wenn sich der Bot im Status „An“ befindet. Andernfalls stoppt das\n"..
    "Sensorsignal den Bot\\, anstatt ihn zu starten.\n"..
    "\n"..
    "\n"..
    "\n",
    "Das Folgende gilt für alle Befehle\\, die Gegenstände/Artikel in das Bot-Inventar\n"..
    "legen\\, wie:\n"..
    "\n"..
    "  - 'take_item <num> <slot>'\n"..
    "  - 'pickup_items <slot>'\n"..
    "  - 'trash_sign <slot>'\n"..
    "  - 'harvest <slot>'\n"..
    "  - 'dig_front <slot> <lvl>'\n"..
    "\n"..
    "Wenn beim Befehl kein Slot oder aber Slot 0 angegeben wurde (Fall A)\\, werden\n"..
    "nacheinander alle 8 Slots des Bot-Inventars überprüft. \n"..
    "Wenn ein Slot angegeben wurde (Fall B)\\, wird nur dieser Slot überprüft.\n"..
    "In beiden Fällen gilt: \n"..
    "\n"..
    "Wenn der Slot vorkonfiguriert ist und zum Artikel passt\\, oder wenn der Slot\n"..
    "nicht konfiguriert und leer ist\\, oder nur teilweise mit dem Artikeltyp gefüllt ist\\,\n"..
    "der hinzugefügt werden soll\\, dann werden die oder der Artikel hinzugefügt.\n"..
    "Dabei werden vorkonfigurierte Slots zuerst gefüllt\\, bevor leere Slots verwendet werden.\n"..
    "\n"..
    "Können nicht alle Artikel hinzugefügt werden\\, werden im Fall A die verbleibenden\n"..
    "Slots durchprobiert. Alles\\, was nicht zum eigenen Inventar hinzugefügt werden\n"..
    "konnte\\, geht zurück oder wird fallen gelassen.\n"..
    "\n"..
    "Das Folgende gilt für alle Befehle\\, die verwendet werden\\, um Gegenstände aus dem\n"..
    "Bot-Inventar zu entnehmen\\, wie zum Beispiel:\n"..
    "\n"..
    "  - 'add_item <num> <slot>'\n"..
    "\n"..
    "Hier spielt es keine Rolle\\, ob ein Slot vorkonfiguriert ist oder nicht. Der Bot nimmt\n"..
    "den ersten Stapel\\, den er aus seinem eigenen Inventar finden kann\\, und versucht\\,\n"..
    "ihn zu verwenden. Wenn ein Slot angegeben ist\\, nimmt er Artikel nur aus diesem\n"..
    "Slot. Ist kein Slot angegeben\\, prüft der Bot nacheinander alle Positiionen\\,\n"..
    "beginnend bei Slot 1\\, bis es etwas findet. Ist die gefundene Anzahl kleiner als\n"..
    "gefordert\\, versucht er\\, den Rest aus einem beliebigen anderen Slot zu entnehmen.\n"..
    "\n"..
    "\n"..
    "\n",
    "",
    "Die Box ist das Gehäuse des Bots. Platzieren Sie die Box und starten Sie den Bot über\n"..
    "die Schaltfläche „An“. Wenn die Mod Techage installiert ist\\, benötigt der Bot auch Strom.\n"..
    "Der Bot verlässt die Box auf der rechten Seite. Es startet nicht\\, wenn diese Position\n"..
    "blockiert ist.\n"..
    "\n"..
    "Um den Bot anzuhalten und zu entfernen\\, drücken Sie die „Aus“-Taste.\n"..
    "Das Box-Inventar simuliert das Inventar des Bots.\n"..
    "Sie können nicht auf das Inventar zugreifen\\, wenn der Bot aktiv ist..\n"..
    "Der Bot kann bis zu 8 Stapel mit Gengeständen und 6 Schilder mit sich führen.\n"..
    "\n"..
    "\n"..
    "\n",
    "Die Klappe ist ein einfacher Block\\, der als Tür für den Bot dient. Platziere die\n"..
    "Klappe in einer beliebigen Wand und der Bot öffnet und schließt die Klappe \n"..
    "automatisch\\, wenn er an dieser Stelle durch die Wand geht.\n"..
    "\n"..
    "\n"..
    "\n",
    "Mit dem Kopierer können Schilderkopien erstellt werden:\n"..
    "\n"..
    "  - Fügen Sie ein „cmnd“-Schild\\, das als Vorlage verwendet werden soll\\, \n in das Inventar „Vorlage“ ein\n"..
    "  - Fügen Sie ein oder mehrere „Leerzeichen“ zum Inventar „Eingabe“ hinzu.\n"..
    "  - Nehmen Sie die Kopien aus dem Inventar „Ausgabe“.\n"..
    "\n"..
    "Alternativ können auch geschriebene Bücher \\[default:book_written\\] als\n"..
    "Vorlage verwendet werden.\n"..
    "Auch bereits geschriebene Schilder können als Input verwendet werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot-Sensor erkennt jeden Bot und sendet ein Signal\\, wenn sich ein Bot\n"..
    "in der Nähe befindet.\n"..
    "Der Sensorbereich beträgt einen Block/Meter. \n"..
    "Die Sensorrichtung spielt keine Rolle.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Block Sensor sendet zyklisch Signale\\, wenn er das Auftauchen oder\n"..
    "Verschwinden von Blöcken erkennt\\, muss aber entsprechend konfiguriert\n"..
    "werden. Die Sensorreichweite beträgt 3 Blöcke/Meter in eine Richtung.\n"..
    "Der Sensor hat eine aktive Seite (rot)\\, die auf den beobachteten Bereich\n"..
    "zeigen muss.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Ernte Sensor sendet zyklische Signale\\, wenn beispielsweise Weizen\n"..
    "ausgewachsen ist. Der Sensorbereich beträgt einen Block/Meter.#\n"..
    "Der Sensor hat eine aktive Seite (rot)\\, die auf die Ernte/das Feld\n"..
    "zeigen muss.\n"..
    "\n"..
    "\n"..
    "\n",
    "Die Signs Bot Kiste ist eine spezielle Truhe mit Sensorfunktion. Sie sendet\n"..
    "je nach Zustand ein Signal.\n"..
    "Mögliche Zustände sind „empty“\\, „not empty“\\, „almost full“.\n"..
    "\n"..
    "Ein typischer Anwendungsfall ist das Ausschalten des Bots\\, wenn die Truhe\n"..
    "fast voll oder aber leer ist.\n"..
    "\n"..
    "\n"..
    "\n",
    "Dies ist eine besondere Typ von Sensor. Er ist programmierbar mit einer Zeit\n"..
    "in Sekunden\\, z.B. um den Bot zyklisch zu starten.\n"..
    "\n"..
    "\n"..
    "\n",
    "Die Roboter Steuerungseinheit dient der Steuerung des Bots mittels Zeichen.\n"..
    "Das Gerät kann mit bis zu 4 verschiedenen Schildern bestückt und mittels\n"..
    "Sensoren programmiert werden.\n"..
    "\n"..
    "Um die Steuerungseinheit zu laden\\, platzieren Sie ein Schild auf der roten Seite\n"..
    "der Steuerungseinheit und klicken Sie auf die Steuerungseinheit.\n"..
    "Das Schild verschwindet / wird in das Inventar der Steuerungseinheit verschoben.\n"..
    "Dies kann dreimal wiederholt werden.\n"..
    "\n"..
    "Verwenden Sie das Verbindungstool\\, um bis zu 4 Sensoren mit der\n"..
    "Steuerungseinheit zu verbinden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Mit der  Sensor Erweiterung können Sensorsignale an mehr als einen Aktor\n"..
    "gesendet werden.\n"..
    "Platzieren Sie eine oder mehrere Sensor Erweiterungen in der Nähe des\n"..
    "Sensors und verbinden Sie jede  Sensor Erweiterung mithilfe des\n"..
    "Verbindungswerkzeug mit einem weiteren Aktor.\n"..
    "\n"..
    "\n"..
    "\n",
    "Um mehrere Signale zu kombinieren\\, verwende den Signal AND Block.\n"..
    "Dieser sendet erst ein Signal\\, wenn alle Eingangssignale empfangen wurden.\n"..
    "(logisches UND). Der Block hat beliebig viele Eingänge und 1 Ausgang.\n"..
    "Der Block hat drei Zustände\\, die er farblich anzeigt:\n"..
    "\n"..
    "  - Schwarzes &-Symbol: Es liegt kein Eingangssignal an\n"..
    "  - Blaues &-Symbol: Es liegt mindestens ein Eingangssignal an\\, aber noch nicht alle\n"..
    "  - Rotes &-Symbol: Alle Eingangssignale liegen an\\, der Block sendet ein Signal\nund löscht die Eingangssignale\\, so dass er wieder ein schwarzes Symbol anzeigt.\n"..
    "\n"..
    "Der Block arbeitet nur\\, wenn der Ausgangsaktor nicht in dem Zustand ist\\,\n"..
    "in den er durch das Signal gesetzt werden soll.\n"..
    "Ist also bspw. ein Bot bereits unterwegs und der AND-Block ist so progammiert\\,\n"..
    "dass der Bot starten soll\\, werden Eingangsssignale nicht angenommen.\n"..
    "\n"..
    "Durch einen Schlag auf den Block werden ggf. anliegende Eingangssignale\n"..
    "gelöscht\\, so dass der Block wieder auf den Ausgangszustand zurückfällt.\n"..
    "\n"..
    "\n"..
    "\n",
    "Signale werden verzögert weitergeleitet. Nachfolgende Signale werden\n"..
    "in die Warteschlange gestellt.\n"..
    "Die Verzögerungszeit ist konfigurierbar.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird zum Ernten und Säen eines 3x3-Feldes verwendet. Platziere das Schild\n"..
    "vor dem Feld.\n"..
    "Der verwendete Samen muss sich im ersten Slot des Bot Inventars\n"..
    "befinden. Wenn der Bot fertig ist\\, dreht sich der Bot und läuft zurück.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird verwendet\\, um eine Kopie eines 3x3x3-Würfels zu erstellen. Platziere das\n"..
    "Schild vor die zu kopierenden Blöcke. Verwende das Kopierzeichen\\, um die Kopie\n"..
    "dieser Blöcke an einem anderen Ort anzufertigen. \n"..
    "Der Bot muss zuerst das \"Vorlage\" Zeichen abarbeiten\\, erst dann kann der Bot zum\n"..
    "Kopierzeichen geleitet werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird verwendet\\, um eine Kopie eines 3x3x3-Würfels zu erstellen. Platziere das Schild\n"..
    "vor der Stelle\\, an der die Kopie angefertigt werden soll. Siehe auch \"Vorlage\" Zeichen.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird zum Schneiden von Blumen auf einem 3x3-Feld verwendet. Platziere das SWenn der Bot fertig ist\\, dreht sich der Bot und geht zurück.child\n"..
    "vor dem Feld.\n"..
    "Wenn der Bot fertig ist\\, dreht er sich um.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird zum Ernten eines Espen- oder Kiefernstamms verwendet:\n"..
    "\n"..
    "  - Platziere das Schild vor dem Baum.\n"..
    "  - Platziere eine Truhe rechts neben dem Schild.\n"..
    "  - Legen Sie einen Erdstapel (mindestens 10 Blöcke) in die Truhe.\n"..
    "  - Slot 1 des Bot-Inventars für Erde vorkonfigurieren\n"..
    "  - Slot 2 des Bot-Inventars für Setzlingen vorkonfigurieren\n"..
    "\n"..
    "\n"..
    "\n",
    "Das „Kommando“-Zeichen kann vom Spieler programmiert werden. Platziere\n"..
    "das Schild und verwende das Blockmenü\\, um die Abfolge von Bot-Befehlen zu\n"..
    "programmieren.\n"..
    "Das Menü verfügt über ein Bearbeitungsfeld für Ihre Befehle und eine Hilfeseite\n"..
    "mit allen verfügbaren Befehle. Die Hilfeseite verfügt über eine Kopierschaltfläche\\,\n"..
    "um die Programmierung zu vereinfachen.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot dreht sich nach rechts\\, wenn er dieses Schild vor sich erkennt.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot dreht sich nach links\\, wenn er dieses Schild vor sich erkennt.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot nimmt Gegenstände aus einer Truhe/Kiste vor sich und dreht sich dann um.\n"..
    "Dieses Schild muss oben auf der Truhe angebracht werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot legt Gegenstände in eine Truhe /Kistevor sich und dreht sich dann um.\n"..
    "Dieses Schild muss oben auf der Truhe angebracht werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot bleibt vor diesem Schild stehen\\, bis das Schild entfernt oder der\n"..
    "Bot ausgeschaltet wird.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot legt Gegenstände in einen Grubenwagen (minecart) vor sich\\,\n"..
    "schiebt den Wagen an und dreht sich dann um. Dieses Schild muss an\n"..
    "der Endposition des Wagens über der Schiene angebracht werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Der Bot nimmt Gegenstände aus einem Grubenwagen (minecart) vor sich\\,\n"..
    "schiebt den Wagen an und dreht sich dann um. Dieses Schild muss an der\n"..
    "Endposition des Wagens über der Schiene angebracht werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird verwendet\\, um Wasser in einen Eimer zu füllen. Platzieren Sie das Schild\n"..
    "am Ufer vor dem stillen Wasserbecken.\n"..
    "\n"..
    "Gegenstände in den Slots:\n"..
    "\n"..
    "   1 - leerer Eimer\n"..
    "\n"..
    "Das Ergebnis ist ein Eimer mit Wasser im ausgewählten Inventarplatz.\n"..
    "Wenn der Bot fertig ist\\, dreht er sich um.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird zum Kochen einer Gemüsesuppe im Kessel verwendet. \n"..
    "Der Kessel sollte leer und über brennbarem Material platziert sein. \n"..
    "Im zu verhindern\\, dass das Holzschild Feuer fängt\\, stelle das Schild\n"..
    "ein Feld vor den Kessel.\n"..
    "\n"..
    "Gegenstände in den Slots:\n"..
    "\n"..
    "   1 - Wassereimer\"\n"..
    "   2 – Gemüse Nr. 1 (z. B. Tomate)\n"..
    "   3 – Gemüse Nr. 2 (z. B. Karotte)\n"..
    "   4 – leere Schüssel (von Farming- oder Xdecor-Mods)\n"..
    "\n"..
    "Das Ergebnis ist eine Schüssel mit Gemüsesuppe im ausgewählten Inventarplatz.\n"..
    "Wenn der Bot fertig ist\\, dreht er sich um.\n"..
    "\n"..
    "\n"..
    "\n",
    "Die Befehle sind auch alle als Hilfeseite im Zeichen „Kommandos“ beschrieben.\n"..
    "Alle gesetzten Blöcke oder Schilder werden aus dem Bot-Inventar übernommen.\n"..
    "Alle entfernten Blöcke oder Schilder werden wieder dem Bot-Inventar hinzugefügt.\n"..
    "„<slot>“ ist immer der interne Inventarstapel des Bots (1..8).\n"..
    "\n"..
    "    move <steps>              - gehe einen oder mehrere Schritte vorwärts\n"..
    "    cond_move                 - gehe bis zum nächsten Hindernis oder Schild\n"..
    "    turn_left                 - drehe links\n"..
    "    turn_right                - drehe rechts\n"..
    "    turn_around               - drehe um\n"..
    "    backward                  - gehe ein Schitt zurück\n"..
    "    turn_off                  - schalte den Bot aus / zurück in die Box\n"..
    "    pause <sec>               - warte eine oder mehrere Sekunden\n"..
    "    move_up                   - nach oben bewegen (maximal 2 Mal)\n"..
    "    move_down                 - nach unten bewegen\n"..
    "    fall_down                 - in ein Loch/Abgrund fallen lassen (bis zu 10 Blöcke)\n"..
    "    take_item <num> <slot>    - nehme einen oder mehrere Gegenstände aus einer Kiste\n"..
    "    add_item <num> <slot>     - lege einen oder mehrere Gegenstände in eine Kiste\n"..
    "    add_fuel <num> <slot>     - fülle Brennstoff in einen Ofen\n"..
    "    place_front <slot> <lvl>  - setze den Block vor den Roboter\n"..
    "    place_left <slot> <lvl>   - setze den Block links vom Roboter\n"..
    "    place_right <slot> <lvl>  - setze den Block rechts vom Roboter\n"..
    "    place_below <slot>        - hebe den Roboter an und setze den Block unter den Roboter\n"..
    "    place_above <slot>        - setze den Block über den Roboter\n"..
    "    dig_front <slot> <lvl>    - entferne den Block vor dem Roboter\n"..
    "    dig_left <slot> <lvl>     - entferne den Block links vom Roboter\n"..
    "    dig_right <slot> <lvl>    - entferne den Block rechts vom Roboter\n"..
    "    dig_below <slot>          - entferne den Block unter dem Roboter\n"..
    "    dig_above <slot>          - entferne den Block über dem Roboter\n"..
    "    rotate_item <lvl> <steps> - drehe einen Block vor dem Roboter\n"..
    "    set_param2 <lvl> <param2> - setze param2 des Blocks vor dem Roboter\n"..
    "    place_sign <slot>         - setze das Schild vor den Roboter\n"..
    "    place_sign_behind <slot>  - setze das Schild hinter den Roboter\n"..
    "    dig_sign <slot>           - entferne das Schild vor den Roboter\n"..
    "    trash_sign <slot>         - Entferne das Schild\\, lösche die Daten und fügen es dem Inventar hinzu\n"..
    "    stop                      - stoppe den Bot\\, bis das Schild entfernt wird\n"..
    "    pickup_items <slot>       - hebe Gegenstände auf (in einem 3x3 Feld)\n"..
    "    drop_items <num> <slot>   - lasse Gegenstände fallen\n"..
    "    harvest                   - ernte ein 3x3 Feld ab (farming)\n"..
    "    cutting                   - schneide Blumen in einem 3x3 Feld ab\n"..
    "    sow_seed <slot>           - sähe/pflanze ein 3x3 Feld an\n"..
    "    plant_sapling <slot>      - pflanze einen Setzling vor dem Roboter\n"..
    "    pattern                   - speichere die Blockeigenschaften hinter dem Schild (3x3x3 Würfel) als Vorlage\n"..
    "    copy <size>               - erstelle eine 3x3x3-Kopie der gespeicherten Vorlage\n"..
    "    punch_cart                - stoße einen Grubenwagen an\n"..
    "    add_compost <slot>        - gebe 2 Blätter in das Kompostfass\n"..
    "    take_compost <slot>       - nehme Kompost aus dem Kompostfass\n"..
    "    print <text>              - gebe eine Chat-Nachricht für Debug-Zwecke aus\n"..
    "    take_water <slot>         - schöpfe Wasser mit einem leeren Eimer\n"..
    "    fill_cauldron <slot>      - fülle den xdecor Kessel für eine Suppe\n"..
    "    take_soup <slot>          - fülle die kochende Suppe aus dem Kessel in eine leere Schüssel\n"..
    "    flame_on                  - mache Feuer an\n"..
    "    flame_off                 - lösche das Feuer\n"..
    "\n"..
    "\n"..
    "\n",
    "    ignite                            - Zünde den Techage-Kohleanzünder an\n"..
    "    low_batt <percent>                - Schalte den Bot aus\\, wenn die Batterieleistung\n"..
    "                                        unter dem angegebenen Wert in Prozent (1..99) liegt.\n"..
    "    jump_low_batt <percent> <label>   - Springe zu <label>\\, wenn die Batterieleistung\n"..
    "                                        unter dem angegebenen Wert in Prozent (1..99) liegt.\n"..
    "                                        (siehe \"Flow Control Kommandos\")\n"..
    "    send_cmnd <receiver> <command>    - Sende ein Techage-Befehl an einen bestimmten Knoten.\n"..
    "                                        Der Empfänger wird über die Techage-Knotennummer angesprochen.\n"..
    "                                        Für Befehle mit zwei oder mehr Wörtern:\n"..
    "                                        Verwenden Sie das Zeichen „*“ statt Leerzeichen\\, z.B.:\n"..
    "                                        send_cmnd 3465 pull*default:dirt*2\n"..
    "\n"..
    "\n"..
    "\n",
    "    -- Sprungbefehl\\, <label> ist ein Wort aus den Zeichen a-z oder A-Z\n"..
    "    jump <label>\n"..
    "    \n"..
    "    -- Sprungmarke / Beginn einer Funktion\n"..
    "    <label>:\n"..
    "    \n"..
    "    -- Rückkehr von einer Funktion\n"..
    "    return\n"..
    "    \n"..
    "    -- Beginn eines Schleifenblocks\\, <num> ist eine Zahl von 1..999\n"..
    "    repeat <num>\n"..
    "    \n"..
    "    -- Ende eines Schleifenblocks\n"..
    "    end\n"..
    "    \n"..
    "    -- Aufruf einer Funktion (mit Rückkehr über den Befehl 'return')\n"..
    "    call <label>\n"..
    "\n"..
    "\n"..
    "\n",
    "    -- Überprüfe\\, ob sich <num> Gegenstände im \n"..
    "    -- truhenähnlichen Knoten befinden.\n"..
    "    -- Wenn nicht\\, springe zu <label>.\n"..
    "    -- <slot> ist der Bot-Inventar-Slot (1..8) um den Artikel anzugeben\\, \n"..
    "    -- oder 0 für jeden Artikel.\n"..
    "    jump_check_item <num> <slot> <label>\n"..
    "    \n"..
    "    -- Siehe \"Techage spezifische Kommandos\"\n"..
    "    jump_low_batt <percent> <label>\n"..
    "\n"..
    "\n"..
    "\n",
    "",
    "    -- jump to the label 'main'\n"..
    "    jump main\n"..
    "    \n"..
    "    -- starting point of the function with the name 'foo'\n"..
    "    foo:\n"..
    "      cmnd ...\n"..
    "      cmnd ...\n"..
    "    -- end of 'foo'. Jump back\n"..
    "    return\n"..
    "    \n"..
    "    -- main program\n"..
    "    main:\n"..
    "      cmnd ...\n"..
    "      -- repeat all commands up to 'end' 10 times\n"..
    "      repeat 10\n"..
    "        cmnd ...\n"..
    "        -- call the subfunction 'foo'\n"..
    "        call foo\n"..
    "        cmnd ...\n"..
    "      -- end of the 'repeat' loop\n"..
    "      end\n"..
    "    -- end of the program\n"..
    "    exit\n"..
    "\n",
    "    cmnd ...\n"..
    "    -- repeat all commands up to 'end' 10 times\n"..
    "    repeat 10\n"..
    "      cmnd ...\n"..
    "      -- call the subfunction 'foo'\n"..
    "      call foo\n"..
    "      cmnd ...\n"..
    "    -- end of the 'repeat' loop\n"..
    "    end\n"..
    "    -- end of the program\n"..
    "    exit\n"..
    "    \n"..
    "    -- starting point of the function with the name 'foo'\n"..
    "    foo:\n"..
    "      cmnd ...\n"..
    "      cmnd ...\n"..
    "    -- end of 'foo'. Jump back\n"..
    "    return\n"..
    "\n",
  },
  images = {
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "signs_bot_sign_left.png",
    "signs_bot_sensor_crop_inv.png",
    "signs_bot_tool.png",
    "signs_bot:box",
    "",
    "signs_bot:box",
    "signs_bot:bot_flap",
    "signs_bot:duplicator",
    "signs_bot:bot_sensor",
    "signs_bot:node_sensor",
    "signs_bot:crop_sensor",
    "signs_bot:chest",
    "signs_bot:timer",
    "signs_bot:changer1",
    "signs_bot:sensor_extender",
    "signs_bot:and1",
    "signs_bot:delayer",
    "signs_bot:farming",
    "signs_bot:pattern",
    "signs_bot:copy3x3x3",
    "signs_bot:flowers",
    "signs_bot:aspen",
    "signs_bot:sign_cmnd",
    "signs_bot:sign_right",
    "signs_bot:sign_left",
    "signs_bot:sign_take",
    "signs_bot:sign_add",
    "signs_bot:sign_stop",
    "signs_bot:sign_add_cart",
    "signs_bot:sign_take_cart",
    "signs_bot:water",
    "signs_bot:soup",
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "signs_bot_bot_inv.png",
    "",
    "",
    "",
  },
  plans = {
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    "",
  }
}