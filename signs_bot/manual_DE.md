# Signs Bot

Ein durch Zeichen/Schilder gesteuerter Roboter.

Web Doku: https://github.com/joe7575/signs_bot/blob/master/manual_DE.md

[signs_bot_bot_inv.png|image]

## Erste Schritte

Nachdem du die Signs Bot Box platziert hast, kannst du den Bot über die
Schaltfläche „An“ im Boxmenü starten. Wenn der Bot sofort in seine Box zurückkehrt,
muss der Bot zuerst mit elektrischer Energie (Techage) aufgeladen werden.
Anschließend läuft der Bot geradeaus, bis er auf ein Hindernis trifft
(eine Stufe mit zwei oder mehr Blöcken nach oben oder unten, oder ein Schild.)

Der Bot kann nur durch Schilder gesteuert werden, die ihm in den Weg gestellt werden.

Falls der Bot ein Schild erreicht, führt er die Befehle auf dem Schild aus.
Falls der erste Befehl auf dem Schild z.B. lautet: „turn_around“, dreht sich der Bot 
um und geht zurück. In diesem Fall erreicht der Bot seine Box erneut und
schaltet sich ab.

Falls der Bot ein Hindernis erreicht, stoppt er, oder führt, falls verfügbar,
den nächsten Befehle vom letzten Schild aus.

Die Signs Bot Box verfügt über ein Inventar mit 6 Slots (Speicherplätze) für Schilder
und 8 Slots für andere Gegenstände (die vom Bot platziert/abgebaut werden).
Dieses Inventar simuliert das interne Inventar des Bots. Das bedeutet, dass du
nur dann Zugriff auf das Inventar hast, wenn der Bot ausgeschaltet ist
(in seiner Box „sitzt“).

Außerdem gibt es folgende Blöcke:
- Sensoren: Diese können ein Signal an einen Aktor senden, wenn sie mit dem
  Aktor verbunden sind.
- Aktoren: Diese führen eine Aktion aus, wenn sie ein Signal von einem Sensor empfangen.

[signs_bot_bot_inv.png|image]

## Schilder

Du steuerst die Richtung des Bots über die „links drehen“ und
„rechts drehen“-Schilder (Schilder mit dem Pfeil). Der Bot kann Stufen
überwinden (einen Block hoch/runter).
Es gibt aber auch Befehle, um den Bot nach oben und unten zu bewegen.

Es ist nicht notwendig, einen Weg zurück zur Box zu markieren. Mit dem
Befehl „turn_off“ schaltet sich der Bot ab und ist von jeder Position aus wieder
in seiner Box. Das Gleiche gilt, wenn du den Bot über das Box-Menü ausschaltest.
Wenn der Bot ein Schild aus der falschen Richtung (von hinten oder von der Seite)
erreicht, wird das Schild ignoriert.
Der Bot wird einfach über das Schild steigen.

Alle vordefinierten Schilder verfügen über ein Menü mit einer Liste der Bot-Befehle.
Diese Schilder können nicht geändert werden, aber du kannst deine eigenen Schilder
erstellen und programmieren. Hierzu musst du das „command“-Schild verwenden.
Dieses Schild verfügt über ein Bearbeitungsfeld für Befehle und eine Hilfeseite mit
allen verfügbaren Befehlen. Die Hilfeseite verfügt über eine Kopierschaltfläche,
um die Programmierung zu vereinfachen.

Auch für die eigenen Schilder ist es wichtig zu wissen: Nach der Ausführung des
letzten Befehls des Schildes verfällt der Bot wieder in sein Standardverhalten
und läuft in die eingeschlagene Richtung.

Eine Standardaufgabe des Bots besteht darin, Gegenstände von einer Truhe zu
einer anderen Truhe (oder einem Block mit einem truhenähnlichen Inventar) zu
verschieben. Dies kann über die beiden Zeichen „Nehme Gegenstand“ und
„Lege Gegenstand“ erfolgen.
Diese Schilder müssen auf dem Truhenblock platziert werden.

[signs_bot_sign_left.png|image]

## Sensors and Actuators

Zusätzlich zu den Schildern kann der Bot mittels Sensoren gesteuert werden. Sensoren wie der Bot-Sensor haben zwei Zustände: ein und aus. Wenn der Bot-Sensor einen Bot erkennt, wechselt er in den Zustand „Ein“ und sendet ein Signal an einen angeschlossenen Block, einen sogenannten Aktor.

Sensoren sind:

- Bot-Sensor: Sendet ein Signal, wenn ein Roboter am Sensor vorbeikommt
- Block Sensor: Sendet ein Signal, wenn der Sensor einen (neuen) Block erkennt
- Ernte Sensor: Sendet ein Signal, wenn beispielsweise Weizen ausgewachsen ist
- Signs Bot Kiste: Sendet je nach Truhenzustand (leer, voll) ein Signal

Aktuatoren sind:

- Roboter Box: Kann den Bot ein- und ausschalten
- Roboter Steuerungseinheit: Kann verwendet werden, um ein Schild auszutauschen,
  um dadurch den Bot zu lenken

Sensoren müssen mit Aktoren verbunden (gepaart) werden. Dafür kann das
„Sensor Verbindungswerkzeug“ genutzt werden.

[signs_bot_sensor_crop_inv.png|image]


## Sensor Verbindungswerkzeug

Um ein Signal von einem Sensor an einen Aktor zu senden, muss der Sensor mit dem
Aktor verbunden (gepaart) werden. Zur Verbindung von Sensor und Aktor muss das
Sensor Connection Tool verwendet werden. Klicke einfach mit dem Werkzeug
auf beide Blöcke und der Sensor wird mit dem Aktor verbunden. Eine erfolgreiche
Verbindung wird durch ein Ping/Pong-Geräusch angezeigt.

Bevor du den Sensor mit dem Aktor verbindest, stelle sicher, dass sich der Aktor im
gewünschten Zustand befindet.
Beispiel: Wenn du den Bot mit einem Sensor starten möchtest, verbinde den Sensor
mit der Bot Box, wenn sich der Bot im Status „An“ befindet. Andernfalls stoppt das
Sensorsignal den Bot, anstatt ihn zu starten.

[signs_bot_tool.png|image]


## Inventar

Das Folgende gilt für alle Befehle, die Gegenstände/Artikel in das Bot-Inventar
legen, wie:

- `take_item <num> <slot>`
- `pickup_items <slot>`
- `trash_sign <slot>`
- `harvest <slot>`
- `dig_front <slot> <lvl>`

Wenn beim Befehl kein Slot oder aber Slot 0 angegeben wurde (Fall A), werden
nacheinander alle 8 Slots des Bot-Inventars überprüft. 
Wenn ein Slot angegeben wurde (Fall B), wird nur dieser Slot überprüft.
In beiden Fällen gilt: 

Wenn der Slot vorkonfiguriert ist und zum Artikel passt, oder wenn der Slot
nicht konfiguriert und leer ist, oder nur teilweise mit dem Artikeltyp gefüllt ist,
der hinzugefügt werden soll, dann werden die oder der Artikel hinzugefügt.

Können nicht alle Artikel hinzugefügt werden, werden im Fall A die verbleibenden
Slots durchprobiert. Alles, was nicht zum eigenen Inventar hinzugefügt werden
konnte, geht zurück oder wird fallen gelassen.

Das Folgende gilt für alle Befehle, die verwendet werden, um Gegenstände aus dem
Bot-Inventar zu entnehmen, wie zum Beispiel:

- `add_item <num> <slot>`

Hier spielt es keine Rolle, ob ein Slot vorkonfiguriert ist oder nicht. Der Bot nimmt
den ersten Stapel, den er aus seinem eigenen Inventar finden kann, und versucht,
ihn zu verwenden. Wenn ein Slot angegeben ist, nimmt er Artikel nur aus diesem
Slot. Ist kein Slot angegeben, prüft der Bot nacheinander alle Positiionen,
beginnend bei Slot 1, bis es etwas findet. Ist die gefundene Anzahl kleiner als
gefordert, versucht er, den Rest aus einem beliebigen anderen Slot zu entnehmen.

[signs_bot:box|image]

## Blöcke

### Signs Bot Box

Die Box ist das Gehäuse des Bots. Platzieren Sie die Box und starten Sie den Bot über
die Schaltfläche „An“. Wenn die Mod Techage installiert ist, benötigt der Bot auch Strom.
Der Bot verlässt die Box auf der rechten Seite. Es startet nicht, wenn diese Position
blockiert ist.

Um den Bot anzuhalten und zu entfernen, drücken Sie die „Aus“-Taste.
Das Box-Inventar simuliert das Inventar des Bots.
Sie können nicht auf das Inventar zugreifen, wenn der Bot aktiv ist..
Der Bot kann bis zu 8 Stapel mit Gengeständen und 6 Schilder mit sich führen.

[signs_bot:box|image]

### Bot Klappe

Die Klappe ist ein einfacher Block, der als Tür für den Bot dient. Platziere die
Klappe in einer beliebigen Wand und der Bot öffnet und schließt die Klappe 
automatisch, wenn er an dieser Stelle durch die Wand geht.

[signs_bot:bot_flap|image]

### Zeichen Kopierer

Mit dem Kopierer können Schilderkopien erstellt werden:

1. Fügen Sie ein „cmnd“-Schild, das als Vorlage verwendet werden soll, 
    in das Inventar „Vorlage“ ein
2. Fügen Sie ein oder mehrere „Leerzeichen“ zum Inventar „Eingabe“ hinzu.
3. Nehmen Sie die Kopien aus dem Inventar „Ausgabe“.

Alternativ können auch geschriebene Bücher [default:book_written] als
Vorlage verwendet werden.
Auch bereits geschriebene Schilder können als Input verwendet werden.

[signs_bot:duplicator|image]

### Bot Sensor

Der Bot-Sensor erkennt jeden Bot und sendet ein Signal, wenn sich ein Bot
in der Nähe befindet.
Der Sensorbereich beträgt einen Block/Meter. 
Die Sensorrichtung spielt keine Rolle.

[signs_bot:bot_sensor|image]

### Block Sensor

Der Block Sensor sendet zyklisch Signale, wenn er das Auftauchen oder
Verschwinden von Blöcken erkennt, muss aber entsprechend konfiguriert
werden. Die Sensorreichweite beträgt 3 Blöcke/Meter in eine Richtung.
Der Sensor hat eine aktive Seite (rot), die auf den beobachteten Bereich
zeigen muss.

[signs_bot:node_sensor|image]

### Ernte Sensor

Der Ernte Sensor sendet zyklische Signale, wenn beispielsweise Weizen
ausgewachsen ist. Der Sensorbereich beträgt einen Block/Meter.#
Der Sensor hat eine aktive Seite (rot), die auf die Ernte/das Feld
zeigen muss.

[signs_bot:crop_sensor|image]

### Signs Bot Kiste

Die Signs Bot Kiste ist eine spezielle Truhe mit Sensorfunktion. Sie sendet
je nach Zustand ein Signal.
Mögliche Zustände sind „empty“, „not empty“, „almost full“.

Ein typischer Anwendungsfall ist das Ausschalten des Bots, wenn die Truhe
fast voll oder aber leer ist.

[signs_bot:chest|image]

### Bot Timer

Dies ist eine besondere Typ von Sensor. Er ist programmierbar mit einer Zeit
in Sekunden, z.B. um den Bot zyklisch zu starten.

[signs_bot:timer|image]

### Roboter Steuerungseinheit

Die Roboter Steuerungseinheit dient der Steuerung des Bots mittels Zeichen.
Das Gerät kann mit bis zu 4 verschiedenen Schildern bestückt und mittels
Sensoren programmiert werden.

Um die Steuerungseinheit zu laden, platzieren Sie ein Schild auf der roten Seite
der Steuerungseinheit und klicken Sie auf die Steuerungseinheit.
Das Schild verschwindet / wird in das Inventar der Steuerungseinheit verschoben.
Dies kann dreimal wiederholt werden.

Verwenden Sie das Verbindungstool, um bis zu 4 Sensoren mit der
Steuerungseinheit zu verbinden.

[signs_bot:changer1|image]

### Sensor Erweiterung

Mit der  Sensor Erweiterung können Sensorsignale an mehr als einen Aktor
gesendet werden.
Platzieren Sie eine oder mehrere Sensor Erweiterungen in der Nähe des
Sensors und verbinden Sie jede  Sensor Erweiterung mithilfe des
Verbindungswerkzeug mit einem weiteren Aktor.

[signs_bot:sensor_extender|image]

### Signal AND

Signal wird gesendet, wenn alle Eingangssignale empfangen wurden.

[signs_bot:and1|image]

### Signal Verzögerer

Signale werden verzögert weitergeleitet. Nachfolgende Signale werden
in die Warteschlange gestellt.
Die Verzögerungszeit ist konfigurierbar.

[signs_bot:delayer|image]

### Zeichen 'Farming'

Wird zum Ernten und Säen eines 3x3-Feldes verwendet. Platziere das Schild
vor dem Feld.
Der verwendete Samen muss sich im ersten Slot des Bot Inventars
befinden. Wenn der Bot fertig ist, dreht sich der Bot und läuft zurück.

[signs_bot:farming|image]

### Zeichen 'Vorlage'

Wird verwendet, um eine Kopie eines 3x3x3-Würfels zu erstellen. Platziere das
Schild vor die zu kopierenden Blöcke. Verwende das Kopierzeichen, um die Kopie
dieser Blöcke an einem anderen Ort anzufertigen. 
Der Bot muss zuerst das "Vorlage" Zeichen abarbeiten, erst dann kann der Bot zum
Kopierzeichen geleitet werden.

[signs_bot:pattern|image]

### Zeichen 'kopiere 3x3x3'

Wird verwendet, um eine Kopie eines 3x3x3-Würfels zu erstellen. Platziere das Schild
vor der Stelle, an der die Kopie angefertigt werden soll. Siehe auch "Vorlage" Zeichen.

[signs_bot:copy3x3x3|image]

### Zeichen 'Blumen'

Wird zum Schneiden von Blumen auf einem 3x3-Feld verwendet. Platziere das SWenn der Bot fertig ist, dreht sich der Bot und geht zurück.child
vor dem Feld.
Wenn der Bot fertig ist, dreht er sich um.

[signs_bot:flowers|image]

### Zeichen 'Espe'

Wird zum Ernten eines Espen- oder Kiefernstamms verwendet:

- Platziere das Schild vor dem Baum.
- Platziere eine Truhe rechts neben dem Schild.
- Legen Sie einen Erdstapel (mindestens 10 Blöcke) in die Truhe.
- Slot 1 des Bot-Inventars für Erde vorkonfigurieren
- Slot 2 des Bot-Inventars für Setzlingen vorkonfigurieren

[signs_bot:aspen|image]

### Zeichen 'Kommando'

Das „Kommando“-Zeichen kann vom Spieler programmiert werden. Platziere
das Schild und verwende das Blockmenü, um die Abfolge von Bot-Befehlen zu
programmieren.
Das Menü verfügt über ein Bearbeitungsfeld für Ihre Befehle und eine Hilfeseite
mit allen verfügbaren Befehle. Die Hilfeseite verfügt über eine Kopierschaltfläche,
um die Programmierung zu vereinfachen.

[signs_bot:sign_cmnd|image]

### Zeichen "Rechts drehen"

Der Bot dreht sich nach rechts, wenn er dieses Schild vor sich erkennt.

[signs_bot:sign_right|image]

### Zeichen "Links drehen"

Der Bot dreht sich nach links, wenn er dieses Schild vor sich erkennt.

[signs_bot:sign_left|image]

### Zeichen "Nehme Gegenstand"

Der Bot nimmt Gegenstände aus einer Truhe/Kiste vor sich und dreht sich dann um.
Dieses Schild muss oben auf der Truhe angebracht werden.


[signs_bot:sign_take|image]

### Zeichen "Lege Gegenstand"

Der Bot legt Gegenstände in eine Truhe /Kistevor sich und dreht sich dann um.
Dieses Schild muss oben auf der Truhe angebracht werden.

[signs_bot:sign_add|image]

### Zeichen "Stopp"

Der Bot bleibt vor diesem Schild stehen, bis das Schild entfernt oder der
Bot ausgeschaltet wird.

[signs_bot:sign_stop|image]

### Zeichen "Lege in den Wagen" (minecart)

Der Bot legt Gegenstände in einen Grubenwagen (minecart) vor sich,
schiebt den Wagen an und dreht sich dann um. Dieses Schild muss an
der Endposition des Wagens über der Schiene angebracht werden.

[signs_bot:sign_add_cart|image]

### Zeichen "Nehme aus dem Wagen" (minecart)

Der Bot nimmt Gegenstände aus einem Grubenwagen (minecart) vor sich,
schiebt den Wagen an und dreht sich dann um. Dieses Schild muss an der
Endposition des Wagens über der Schiene angebracht werden.

[signs_bot:sign_take_cart|image]

### Zeichen 'Schöpfe Wasser' (xdecor)

Wird verwendet, um Wasser in einen Eimer zu füllen. Platzieren Sie das Schild
am Ufer vor dem stillen Wasserbecken.

Gegenstände in den Slots:

   1 - leerer Eimer

Das Ergebnis ist ein Eimer mit Wasser im ausgewählten Inventarplatz.
Wenn der Bot fertig ist, dreht er sich um.

[signs_bot:water|image]

### Zeichen 'Koche Suppe' (xdecor)

Wird zum Kochen einer Gemüsesuppe im Kessel verwendet. 
Der Kessel sollte leer und über brennbarem Material platziert sein. 
Im zu verhindern, dass das Holzschild Feuer fängt, stelle das Schild
ein Feld vor den Kessel.

Gegenstände in den Slots:

   1 - Wassereimer"
   2 – Gemüse Nr. 1 (z. B. Tomate)
   3 – Gemüse Nr. 2 (z. B. Karotte)
   4 – leere Schüssel (von Farming- oder Xdecor-Mods)

Das Ergebnis ist eine Schüssel mit Gemüsesuppe im ausgewählten Inventarplatz.
Wenn der Bot fertig ist, dreht er sich um.


[signs_bot:soup|image]


## Bot Kommandos

Die Befehle sind auch alle als Hilfeseite im Zeichen „Kommandos“ beschrieben.
Alle gesetzten Blöcke oder Schilder werden aus dem Bot-Inventar übernommen.
Alle entfernten Blöcke oder Schilder werden wieder dem Bot-Inventar hinzugefügt.
„<slot>“ ist immer der interne Inventarstapel des Bots (1..8).

    move <steps>              - gehe einen oder mehrere Schritte vorwärts
    cond_move                 - gehe bis zum nächsten Hindernis oder Schild
    turn_left                 - drehe links
    turn_right                - drehe rechts
    turn_around               - drehe um
    backward                  - gehe ein Schitt zurück
    turn_off                  - schalte den Bot aus / zurück in die Box
    pause <sec>               - warte eine oder mehrere Sekunden
    move_up                   - nach oben bewegen (maximal 2 Mal)
    move_down                 - nach unten bewegen
    fall_down                 - in ein Loch/Abgrund fallen lassen (bis zu 10 Blöcke)
    take_item <num> <slot>    - nehme einen oder mehrere Gegenstände aus einer Kiste
    add_item <num> <slot>     - lege einen oder mehrere Gegenstände in eine Kiste
    add_fuel <num> <slot>     - fülle Brennstoff in einen Ofen
    place_front <slot> <lvl>  - setze den Block vor den Roboter
    place_left <slot> <lvl>   - setze den Block links vom Roboter
    place_right <slot> <lvl>  - setze den Block rechts vom Roboter
    place_below <slot>        - hebe den Roboter an und setze den Block unter den Roboter
    place_above <slot>        - setze den Block über den Roboter
    dig_front <slot> <lvl>    - entferne den Block vor dem Roboter
    dig_left <slot> <lvl>     - entferne den Block links vom Roboter
    dig_right <slot> <lvl>    - entferne den Block rechts vom Roboter
    dig_below <slot>          - entferne den Block unter dem Roboter
    dig_above <slot>          - entferne den Block über dem Roboter
    rotate_item <lvl> <steps> - drehe einen Block vor dem Roboter
    set_param2 <lvl> <param2> - setze param2 des Blocks vor dem Roboter
    place_sign <slot>         - setze das Schild vor den Roboter
    place_sign_behind <slot>  - setze das Schild hinter den Roboter
    dig_sign <slot>           - entferne das Schild vor den Roboter
    trash_sign <slot>         - Entferne das Schild, lösche die Daten und fügen es dem Inventar hinzu
    stop                      - stoppe den Bot, bis das Schild entfernt wird
    pickup_items <slot>       - hebe Gegenstände auf (in einem 3x3 Feld)
    drop_items <num> <slot>   - lasse Gegenstände fallen
    harvest                   - ernte ein 3x3 Feld ab (farming)
    cutting                   - schneide Blumen in einem 3x3 Feld ab
    sow_seed <slot>           - sähe/pflanze ein 3x3 Feld an
    plant_sapling <slot>      - pflanze einen Setzling vor dem Roboter
    pattern                   - speichere die Blockeigenschaften hinter dem Schild (3x3x3 Würfel) als Vorlage
    copy <size>               - erstelle eine 3x3x3-Kopie der gespeicherten Vorlage
    punch_cart                - stoße einen Grubenwagen an
    add_compost <slot>        - gebe 2 Blätter in das Kompostfass
    take_compost <slot>       - nehme Kompost aus dem Kompostfass
    print <text>              - gebe eine Chat-Nachricht für Debug-Zwecke aus
    take_water <slot>         - schöpfe Wasser mit einem leeren Eimer
    fill_cauldron <slot>      - fülle den xdecor Kessel für eine Suppe
    take_soup <slot>          - fülle die kochende Suppe aus dem Kessel in eine leere Schüssel
    flame_on                  - mache Feuer an
    flame_off                 - lösche das Feuer

[signs_bot_bot_inv.png|image]

### Techage spezifische Kommandos

    ignite                            - Zünde den Techage-Kohleanzünder an
    low_batt <percent>                - Schalte den Bot aus, wenn die Batterieleistung
                                        unter dem angegebenen Wert in Prozent (1..99) liegt.
    jump_low_batt <percent> <label>   - Springe zu <label>, wenn die Batterieleistung
                                        unter dem angegebenen Wert in Prozent (1..99) liegt.
                                        (siehe "Flow Control Kommandos")
    send_cmnd <receiver> <command>    - Sende ein Techage-Befehl an einen bestimmten Knoten.
                                        Der Empfänger wird über die Techage-Knotennummer angesprochen.
                                        Für Befehle mit zwei oder mehr Wörtern:
                                        Verwenden Sie das Zeichen „*“ statt Leerzeichen, z.B.:
                                        send_cmnd 3465 pull*default:dirt*2

[signs_bot_bot_inv.png|image]

### Flow Control Kommandos

    -- Sprungbefehl, <label> ist ein Wort aus den Zeichen a-z oder A-Z
    jump <label>
    
    -- Sprungmarke / Beginn einer Funktion
    <label>:
    
    -- Rückkehr von einer Funktion
    return
    
    -- Beginn eines Schleifenblocks, <num> ist eine Zahl von 1..999
    repeat <num>
    
    -- Ende eines Schleifenblocks
    end
    
    -- Aufruf einer Funktion (mit Rückkehr über den Befehl 'return')
    call <label>


[signs_bot_bot_inv.png|image]

### Weitere Sprungkommands

    -- Überprüfe, ob sich <num> Gegenstände im 
    -- truhenähnlichen Knoten befinden.
    -- Wenn nicht, springe zu <label>.
    -- <slot> ist der Bot-Inventar-Slot (1..8) um den Artikel anzugeben, 
    -- oder 0 für jeden Artikel.
    jump_check_item <num> <slot> <label>
    
    -- Siehe "Techage spezifische Kommandos"
    jump_low_batt <percent> <label>


[signs_bot_bot_inv.png|image]

### Flow Control Beispiele

#### Beispiel mit einer Funktion am Anfang:

    -- jump to the label 'main'
    jump main
    
    -- starting point of the function with the name 'foo'
    foo:
      cmnd ...
      cmnd ...
    -- end of 'foo'. Jump back
    return
    
    -- main program
    main:
      cmnd ...
      -- repeat all commands up to 'end' 10 times
      repeat 10
        cmnd ...
        -- call the subfunction 'foo'
        call foo
        cmnd ...
      -- end of the 'repeat' loop
      end
    -- end of the program
    exit


#### Beispiel mit einer Funktion am Ende:

    cmnd ...
    -- repeat all commands up to 'end' 10 times
    repeat 10
      cmnd ...
      -- call the subfunction 'foo'
      call foo
      cmnd ...
    -- end of the 'repeat' loop
    end
    -- end of the program
    exit
    
    -- starting point of the function with the name 'foo'
    foo:
      cmnd ...
      cmnd ...
    -- end of 'foo'. Jump back
    return
