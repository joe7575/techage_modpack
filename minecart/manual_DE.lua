return {
  titles = {
    "1,Minecart",
    "2,Kurzanleitung",
    "2,Minecart-Blöcke",
    "3,Wagen",
    "3,Puffer",
    "3,Landmarken",
    "3,Trichter/Hopper",
    "3,Wagenschieber (Cart Pusher)",
    "3,Geschwindigkeitsbegrenzungsschilder",
    "2,Chat-Befehle",
    "2,Online-Handbuch",
  },
  texts = {
    "Die Mod Minecart verfügt zusätzlich zu den Standard-Wagen/Loren über eigene Wagen\n"..
    "(Minecart genannt).\n"..
    "Minecarts werden für den automatisierten Gütertransport auf privaten und öffentlichen\n"..
    "Schienennetzen eingesetzt.\n"..
    "\n"..
    "Die Hauptmerkmale sind:\n"..
    "\n"..
    "  - Gütertransport von Station zu Station\n"..
    "  - Wagen können durch unbeladene Bereiche (Mapblocks) fahren\n(es müssen nur beide Stationen geladen sein)\n"..
    "  - Automatisiertes Be-/Entladen von Minecarts mittels Minecart Hopper\n"..
    "  - Die Schienen können durch Landmarken geschützt werden\n"..
    "\n"..
    "Wenn die Mod Techage verfügbar ist:\n"..
    "\n"..
    "  - Sind zwei zusätzliche Wagen für den Transport von Gegenständen und Flüssigkeiten verfügbar\n"..
    "  - Können diese Wagen mit Hilfe von Techage Schiebern und Pumpen be- und entladen werden\n"..
    "\n"..
    "Du kannst:\n"..
    "\n"..
    "  - den Wagen mit einem Rechtsklick besteigen\n"..
    "  - den Wagen mit einem Sprung oder Rechtsklick wieder verlassen\n"..
    "  - den Wagen mit einem Linksklick anschieben/starten\n"..
    "\n"..
    "Aber Minecarts haben ihren Besitzer und du kannst fremde Minecarts nicht starten\\, stoppen oder entfernen.\n"..
    "Minecarts können nur am Puffer/Prellbock gestartet werden. Wenn ein Minecarts unterwegs stehen bleibt\\,\n"..
    "entferne es und platziere es wieder an einer Puffer-Position.\n"..
    "\n"..
    "\n"..
    "\n",
    "  - Platziere die Schienen und baue eine Route mit zwei Endpunkten.\nKreuzungen sind erlaubt\\, solange jede Route einen eigenen Start- und Endpunkt hat.\n"..
    "  - Platziere an beiden Endpunkten einen Prellbock/Puffer (Puffer werden immer benötigt\\,\nsie speichern die Routen- und Zeitinformationen).\n"..
    "  - Gebe beiden Prellböcken eindeutige Bahnhofsnamen\\, z. B. Stuttgart und München.\n"..
    "  - Stelle ein Minecart an einen Puffer und gebe ihm eine Wagennummer (1..999).\n"..
    "  - Fahre mit dem Minecart(!) von Puffer zu Puffer in beide Richtungen\\, um die\nStecke aufzuzeichnen (verwende die Rechts/Links-Tasten\\, um das Minecart zu steuern).\n"..
    "  - Schlage auf die Puffer\\, um die Verbindungsdaten zu überprüfen\n (z. B. \"Stuttgart: verbunden mit München\").\n"..
    "  - Optional: Konfiguriere die Minecart-Wartezeit in beiden Puffern.\nDas Minecart startet dann automatisch nach der konfigurierten Zeit.\n"..
    "  - Stelle ein Minecart vor den Puffer und prüfe\\, ob es nach der konfigurierten Zeit\nstartet.\n"..
    "  - Lege Gegenstände in das Minecart und schlage auf den Wagen\\, um ihn zu starten.\n"..
    "  - Entferne den Wagen mit Shift + Rechts-Click“.\n"..
    "\n"..
    "\n"..
    "\n",
    "\n"..
    "\n",
    "Wird hauptsächlich zum Transport von Gegenständen verwendet. Du kannst Gegenstände\n"..
    "in das Minecart legen und auf den Wagen schlagen\\, um ihn zu starten.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird als Prellbock an beiden Schienenenden verwendet. Wird benötigt\\, um die\n"..
    "Routen der Minecarts aufzeichnen und speichern zu können.\n"..
    "\n"..
    "\n"..
    "\n",
    "Schütze deine Schienen mit den Landmarken (mindestens alle 16 Blöcke in\n"..
    "der Nähe der Schiene eine Landmarke).\n"..
    "\n"..
    "\n"..
    "\n",
    "Wird zum Laden/Entladen von Minecarts verwendet. Der Hopper kann Gegenstände\n"..
    "zu/von Truhen schieben/ziehen und Gegenstände zu/von Minecarts abgeben/abholen.\n"..
    "Um ein Minecart zu entladen\\, platziere den Trichter unterhalb der Schiene.\n"..
    "Um das Minecart zu beladen\\, platziere den Trichter direkt neben dem Minecart.\n"..
    "\n"..
    "\n"..
    "\n",
    "Wenn mehrere Wagen auf einer Strecke fahren\\, kann es vorkommen\\, dass eine Pufferposition\n"..
    "bereits belegt ist und ein Wagen daher früher stoppt.\n"..
    "In diesem Fall dient der Wagenschieber dazu\\, den Wagen wieder in Richtung Puffer zu schieben.\n"..
    "Dieser Block muss im Abstand von 2 m vor dem Puffer unter der Schiene platziert werden.\n"..
    "\n"..
    "\n"..
    "\n",
    "Begrenze  die Geschwindigkeit der Minecarts mit Geschwindigkeitsbegrenzungsschildern.\n"..
    "\n"..
    "\n"..
    "\n",
    "  - Befehl „/mycart <num>“\\, um den Status und den Standort des Minecarts auszugeben\n"..
    "  - Befehl „/stopcart <num>“\\, um verlorene Minecarts abzurufen\n"..
    "\n",
    "Ein umfassendes Handbuch ist online verfügbar.\n"..
    "Siehe: https://github.com/joe7575/minecart/wiki\n"..
    "\n",
  },
  images = {
    "minecart_manual_image.png",
    "minecart_manual_image.png",
    "minecart:cart",
    "minecart:cart",
    "minecart:buffer",
    "minecart:landmark",
    "minecart:hopper",
    "minecart:cart_pusher",
    "minecart:speed2",
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
  }
}