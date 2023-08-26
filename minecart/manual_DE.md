# Minecart

Die Mod Minecart verfügt zusätzlich zu den Standard-Wagen/Loren über eigene Wagen
(Minecart genannt).
Minecarts werden für den automatisierten Gütertransport auf privaten und öffentlichen
Schienennetzen eingesetzt.

Die Hauptmerkmale sind:

- Gütertransport von Station zu Station
- Wagen können durch unbeladene Bereiche (Mapblocks) fahren
  (es müssen nur beide Stationen geladen sein)
- Automatisiertes Be-/Entladen von Minecarts mittels Minecart Hopper
- Die Schienen können durch Landmarken geschützt werden

Wenn die Mod Techage verfügbar ist:

- Sind zwei zusätzliche Wagen für den Transport von Gegenständen und Flüssigkeiten verfügbar
- Können diese Wagen mit Hilfe von Techage Schiebern und Pumpen be- und entladen werden

Du kannst:

- den Wagen mit einem Rechtsklick besteigen
- den Wagen mit einem Sprung oder Rechtsklick wieder verlassen
- den Wagen mit einem Linksklick anschieben/starten

Aber Minecarts haben ihren Besitzer und du kannst fremde Minecarts nicht starten, stoppen oder entfernen.
Minecarts können nur am Puffer/Prellbock gestartet werden. Wenn ein Minecarts unterwegs stehen bleibt,
entferne es und platziere es wieder an einer Puffer-Position.

[minecart_manual_image.png|image]


## Kurzanleitung

1. Platziere die Schienen und baue eine Route mit zwei Endpunkten.
   Kreuzungen sind erlaubt, solange jede Route einen eigenen Start- und Endpunkt hat.
2. Platziere an beiden Endpunkten einen Prellbock/Puffer (Puffer werden immer benötigt,
   sie speichern die Routen- und Zeitinformationen).
3. Gebe beiden Prellböcken eindeutige Bahnhofsnamen, z. B. Stuttgart und München.
4. Stelle ein Minecart an einen Puffer und gebe ihm eine Wagennummer (1..999).
5. Fahre mit dem Minecart(!) von Puffer zu Puffer in beide Richtungen, um die
   Stecke aufzuzeichnen (verwende die Rechts/Links-Tasten, um das Minecart zu steuern).
6. Schlage auf die Puffer, um die Verbindungsdaten zu überprüfen
    (z. B. "Stuttgart: verbunden mit München").
7. Optional: Konfiguriere die Minecart-Wartezeit in beiden Puffern.
   Das Minecart startet dann automatisch nach der konfigurierten Zeit.
9. Stelle ein Minecart vor den Puffer und prüfe, ob es nach der konfigurierten Zeit
   startet.
10. Lege Gegenstände in das Minecart und schlage auf den Wagen, um ihn zu starten.
11. Entferne den Wagen mit Shift + Rechts-Click“.

[minecart_manual_image.png|image]


## Minecart-Blöcke

[minecart:cart|image]


### Wagen

Wird hauptsächlich zum Transport von Gegenständen verwendet. Du kannst Gegenstände
in das Minecart legen und auf den Wagen schlagen, um ihn zu starten.

[minecart:cart|image]


### Puffer

Wird als Prellbock an beiden Schienenenden verwendet. Wird benötigt, um die
Routen der Minecarts aufzeichnen und speichern zu können.

[minecart:buffer|image]


### Landmarken

Schütze deine Schienen mit den Landmarken (mindestens alle 16 Blöcke in
der Nähe der Schiene eine Landmarke).

[minecart:landmark|image]


### Trichter/Hopper

Wird zum Laden/Entladen von Minecarts verwendet. Der Hopper kann Gegenstände
zu/von Truhen schieben/ziehen und Gegenstände zu/von Minecarts abgeben/abholen.
Um ein Minecart zu entladen, platziere den Trichter unterhalb der Schiene.
Um das Minecart zu beladen, platziere den Trichter direkt neben dem Minecart.

[minecart:hopper|image]


### Wagenschieber (Cart Pusher)

Wenn mehrere Wagen auf einer Strecke fahren, kann es vorkommen, dass eine Pufferposition
bereits belegt ist und ein Wagen daher früher stoppt.
In diesem Fall dient der Wagenschieber dazu, den Wagen wieder in Richtung Puffer zu schieben.
Dieser Block muss im Abstand von 2 m vor dem Puffer unter der Schiene platziert werden.

[minecart:cart_pusher|image]


### Geschwindigkeitsbegrenzungsschilder

Begrenze  die Geschwindigkeit der Minecarts mit Geschwindigkeitsbegrenzungsschildern.

[minecart:speed2|image]


## Chat-Befehle

- Befehl „/mycart <num>“, um den Status und den Standort des Minecarts auszugeben
- Befehl „/stopcart <num>“, um verlorene Minecarts abzurufen


## Online-Handbuch

Ein umfassendes Handbuch ist online verfügbar.
Siehe: https://github.com/joe7575/minecart/wiki
