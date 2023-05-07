% --------------------------------------------------------------------------- %
% MINI ADVENTURE PROTOTYP
% --------------------------------------------------------------------------- %
%
% Kommentierter Quellcode 
% Carsten Heisterkamp
% Stand 13.01.2022 
%
% PROGRAMMSTART: oblivion.
%
% Basierend auf Spiel Nani Search aus dem Buch Adventure in Prolog.
%
% Das Spiel funktioniert leider nicht in SWISH, sondern nur in SWIPL. 
% Getestet wurde es bisher nur auf MacOS. tty_clear/0 muss ggf., auf Windows
% angepasst werden, da Terminal spezifisch.
%
% Mehr zu dem Konzept befindet sich im beigefügten Begleittext.
% 
% --------------------------------------------------------------------------- %
% REGELN ZUR DYNAMISCHEN PROGRAMMAUSFÜHRUNG
% --------------------------------------------------------------------------- %
% Diese kopflosen Regeln sind ein Sicherheitsmechanismus und teilen Prolog 
% mit, dass die folgenden Prädikate dynamisch sind und während des Programm-
% ablaufes dynamisch hinzukommen, verändert werden, oder sogar komplett entfernt 
% werden können.
% --------------------------------------------------------------------------- %

:- dynamic meine_position/1.
:- dynamic lokation/2.
:- dynamic besitz/1.
:- dynamic parole/1.
:- dynamic chiffre/1.
:- dynamic beschreibung/2.
:- dynamic gesagt/0.
:- dynamic eingeschaltet/1.

% Unterdrückt die Singleton Warnung im Reader Teil
:- style_check((-singleton)).

% Löscht die alte Datenbasis und verhindert doppelte Daten, falls das
% Programm mehrals hintereinander gestartet wird. 

:- retractall(meine_position(_)).
:- retractall(lokation(_,_)).
:- retractall(besitz(_)).
:- retractall(parole(_)).
:- retractall(chiffre(_)).
:- retractall(gesagt).
:- retractall(eingeschaltet(_)).

% --------------------------------------------------------------------------- %
% LOGISCHE DATENBASIS
% --------------------------------------------------------------------------- %
% Die logische Datenbasis enthält nur rein logische Prädikate, die für 
% die Spielmechanik benötigt werden. Keine Prädikate zur Ein- und Ausgabe.
%
% FAKTEN
% Fakten, wie ort/1 beschreiben, was in der Welt existiert.
% Relationen, wie lokation/2 beschreiben einfache Zusammenhänge.
% --------------------------------------------------------------------------- %

ort(blockhaus).
ort(lichtung).
ort(keller).
ort(wald).
ort(hoehle).
ort(tuer).
ort(wiese).
ort(schlucht).
ort(sumpf).

richtung(norden).
richtung(osten).
richtung(sueden).
richtung(unten).
richtung(oben).
richtung(westen).

lokation(astloch, baum).
lokation(ausgang, tuer).
lokation(baum, sumpf).
lokation(baer, wald).
lokation(bank, lichtung).
lokation(briefkasten, astloch).
lokation(lampe, blockhaus).
lokation(nachricht, briefkasten).
lokation(notiz, truhe).
lokation(schild, schlucht).
lokation(spatzen, vogelscheuche).
lokation(vogelscheuche, wiese).
lokation(schluessel, wasser).
lokation(truhe, keller).
lokation(wasser, hoehle).

besitz(tasche).
besitz(buch).

tragbar(buch).
tragbar(lampe).
tragbar(nachricht).
tragbar(notiz).
tragbar(schluessel).
tragbar(tasche).

aktivierbar(lampe).

% mit dem Schlüssel lässt sich die Truhe aktivieren
aktivierbar_mit(schluessel, truhe).

% Im Osten vom Blockaus liegt der Wald
pfad(osten, blockhaus, wald).
pfad(unten, blockhaus, keller).
pfad(westen, hoehle, sumpf).
pfad(oben, keller, blockhaus).
pfad(norden, lichtung, wiese).
pfad(sueden, lichtung, schlucht).
pfad(osten, lichtung, sumpf).
pfad(westen, lichtung, wald).
pfad(norden, schlucht, lichtung).
pfad(osten, sumpf, hoehle).
pfad(westen, sumpf, lichtung).
pfad(sueden, tuer, wiese).
pfad(westen, wald, blockhaus).
pfad(osten, wald, lichtung).
pfad(norden, wiese, tuer).
pfad(sueden, wiese, lichtung).

parolen([logik, semesterende, party ]).

% --------------------------------------------------------------------------- %
% REGELN 
% Regeln beschreiben die Struktur zwischen den Fakten. Hier beschreibt es die
% Struktur der 'Verbundenheit'. Was bedeutet, dass zwei Orte (oder Dinge) mit-
% einander verbunden sind? Wenn es eine Verbindung von dem einen, hier X, zu 
% dem anderen Y existiert und umgekehrt eine Verbindung von Y nach X. Damit 
% diese in Prolog existieren, müssen also beide Richtungen der Verbindung in der
% Datenbasis definiert sein. In der Datenbasis ist dies mit pfad/3 realisiert.
% Da uns hier nur die Verbindungen, nicht die Himmelsrichtung, in der sie ver-
% bunden sind interessiert, wird für den Parameter der Richtung, die anonyme 
% Variable _ verwendet. Prolog betrachtet diese erst gar nicht.
% --------------------------------------------------------------------------- %

verbunden(X,Y):-
    pfad(_,X,Y),
    pfad(_,Y,X).

% --------------------------------------------------------------------------- %
% PROGRAMMABLAUF UND BENUTZERINNENSCHNITTSTELLE
% --------------------------------------------------------------------------- %
% Dieser Programmabschnitt enthält die Hauptprogrammschleife und -interaktion. 
% Die Regel oblivion. startet das Spiel und ruft der Reihe nach die Regeln
% zur Initialisierung initialisierng/0, das Intro intro/0 auf, gibt einmal 
% die Umgebung mit umsehen/0 aus und geht dann in die Hauptprogrammschleife.
% --------------------------------------------------------------------------- %

oblivion :-
    initialisierung,
    intro,
    umsehen,
    hauptprogrammschleife.
 
initialisierung :-
    assertz(meine_position(lichtung)),
    chiffrierte_parole.

intro :-
    tty_clear,
	text_aus_datei('introtitel.txt'),
    get0(_),
    tty_clear,
    text_aus_datei('intrografik.txt'),
    sleep(4),
    tty_clear,nl,
    text_aus_datei('introtext.txt'),
    get0(_).
 
 % --------------------------------------------------------------------------- %
 % HAUPTPROGRAMMSCHLEIFE
 % Sofern ein Programm nicht nur einmal durchlaufen soll, benötigt jedes
 % Programm, auch in anderen Programmiersprachen, eine Hauptprogrammschleife.
 % Diese wird hier mit Hilfe des Prolog-eigenen Prädikats repeat/0 und der dazu
 % gehörigen Klammer am Ende von hauptprogrammschleife/0 realiert. Es werden die 
 % zwischen repeat/0 und dem Ausdruck in der Klammer befindlichen Prädikate, 
 % so lange in Schleife ausgeführt, bis der Ausdruck in der Klammer wahr wird. 
 % Also wenn die Regel spielende/0 als wahr abgeleitet werden kann, oder bis 
 % beenden eingegeben wird. So lange werden get_command/1 aus dem DCG Teil und 
 % aktion/1 aus dem DCG-Befehlslogik Interface hintereinander aufgerufen. 
 % Dabei liest get_command/1 den eingegebenen Text ein und überprüft diesen 
 % im DCG Teil. Wird der Satz als, nach der DCG Grammatik, gültiger Satz 
 % akzeptiert, wird die entsprechende Aktion aufgerufen. 
 % Danach beginnt der Loop von vorne.
 % --------------------------------------------------------------------------- %
 
hauptprogrammschleife :-
    repeat,
    get_command(Eingabe),   
    aktion(Eingabe),
    (spielende; Eingabe == beenden).

hilfe :- 
    tty_clear,
    text_aus_datei('hilfetext.txt'),
    get0(_),
    umsehen.

hinweis :-
    tty_clear,
    text_aus_datei('hinweistext.txt'),
    get0(_),
    umsehen.

spielende :-
    ort(tuer),
    gesagt,
    outro,
    beendenmenu.

outro :-
    tty_clear,
	text_aus_datei('outrotext.txt'),
    get0(_). 
     
beenden :-
    writeln("Gibst du schon auf? So sei es."), nl, 
    sleep(2),
    beendenmenu.

beendenmenu :-
	menu('Spiel beenden?',
		[ ende : 'ja, beenden',
          oblivion : 'nein - neues Spiel'
		], Choice),
        Choice,!.
 
ende :- 
    nl,nl, 
    writeln("Auf Wiedersehen, bis zum nächsten Abenteuer!"),
    nl,
    sleep(3),
    halt.

% --------------------------------------------------------------------------- %
% TECHNISCHE HILFSPRÄDIKATE
% --------------------------------------------------------------------------- %
% Prädikate zum Einlesen der Texte und Erzeugung der chiffrierten Parole. 
%
% text_aus_datei/1 liest eine .txt Datei, die im gleichen Ordner, wie das
% Hauptprogramm liegen muss zeilenweise ein und gibt es sofort aus.
% --------------------------------------------------------------------------- %

 text_aus_datei(Datei):-
    open(Datei, read, Datenstrom),
    repeat,
    read_line_to_codes(Datenstrom, Inhalt),
	writef(" "),
    writef(Inhalt),nl,
	at_end_of_stream(Datenstrom),!,
    nl,
    close(Datenstrom).

% --------------------------------------------------------------------------- %
% chiffriere_parole/0 wählt ein Wort aus der Liste der möglichen Worte und 
% 'chiffriert' es. Es ist keine echte Chiffrierung, sondern lediglich eine 
% Übersetzung des Wortes in dessen Unicode, der Zahlendarstellung des Wortes. 
% Die unchiffrierte und die chiffrierte Version werden in der 
% Datenbasis gespeichert. Die chiffrierte Variante wird für die Anzeige in 
% der Notiz im Keller, die unchiffrierte für die Lösung des Spiels verwendet. 
% parolen/1 enthält eine Liste mit Wörtern, aus der zufällig eins mit 
% random_member/2 ausgewählt wird. Das zurückgegebene Wort wird mit Hilfe 
% chiffriert/2 und dem Prolog eigenen atom_codes/2 in Unicode übersetzt. 
% atom_codes/2 gibt eine Liste mit Zahlen zurück, die dann für die spätere
% Ausgabe mit atomics_to_string/3 in einen String umgewandelt wird. 
% Anschließend wird der String der nun die Chiffre enthält mit assertz/1 
% in die Datenbasis geschrieben. Zuguterletzt wird daraus die Beschreibung 
% mit den SWI Prolog Prädikat string_concat/3 zusammengesetzt und in die 
% Datenbasis geschrieben.
% --------------------------------------------------------------------------- %

chiffrierte_parole :- 
    parolen(Parolen),
    random_member(Parole, Parolen),
    asserta(parole(Parole):-!),
    chiffriert(Parole, Chiffre),
    asserta(chiffre(Chiffre)),
    string_concat("Eine Notiz mit den Zahlen: ", Chiffre, Beschreibung),
    assert(beschreibung(notiz, Beschreibung)).

chiffriert(Wort, Chiffriert) :-
    atom_codes(Wort, Codes),
    atomics_to_string(Codes, ' ', Chiffriert).

% --------------------------------------------------------------------------- %
% HILFSPRÄDIKATE FÜR DIE TEXTAUSGABE
% --------------------------------------------------------------------------- %
% Die natürlich sprachliche Beschreibung wird den entsprechenden Atoms 
% zugeordnet. So lassen sich Logik und Ausgabe besser trennen und erlaubt so
% ein interessanteres Storytelling. Die Beschreibung der Notiz wird dynamisch
% erstellt, da sie Zahlen enthält, die bei jedem Programmdurchlauf anders sind.
% \n wird verwendet, um Zeilenumbrüche innerhalb eines Strings herzustellen. 
% --------------------------------------------------------------------------- %

beschreibung(astloch, "Ein Astloch, darin ließe sich gut etwas verstecken.").
beschreibung(ausgang, "Ein hölzerne Tür mitten in der Landschaft.\nAls du sie öffnen willst schreit die Brille:\n'Wie lautet die Parole!?'").
beschreibung(baum, "Ein knorriger Baum mit einem seltsamen Astloch.").
beschreibung(bank, "Eine alte und ziemlich harte Holzbank.").
beschreibung(baer, "Ein Baer, aber er bewegt sich nicht. Was ist wohl mit ihm los?").
beschreibung(buch, "Ein Buch. Du kannst den Titel kaum lesen. 'The Unicorn'? Du brauchst eine Brille...").
beschreibung(blockhaus, "Ein Blockhaus, die Tür steht offen.").
beschreibung(briefkasten, "Ein toter Briefkasten. Er enthält eine Nachricht.").
beschreibung(hoehle, "Ein Hoehle, die zum Teil unter Wasser steht.").
beschreibung(keller, "Ein sehr dunkler Keller.").
beschreibung(lampe, "Eine Petroliumlampe. Wie praktisch, sie ist gefüllt und es liegen Zündhölzer dabei.").
beschreibung(lichtung, "Eine Lichtung mit einer Bank an einer Weggabelung.").
beschreibung(nachricht, "Sie enthält eine Botschaft: 'Wer das liest, ist gar nicht so doof!'").
beschreibung(norden, "Norden").
beschreibung(osten, "Osten").
beschreibung(oben, "Oben").
beschreibung(quest, "Nenne mir die Parole, dann lasse ich dich passieren!").
beschreibung(schild, "Ein Schild: Kein Durchgang! Gehe gen Norden und meide die Wälder und Sümpfe!").
beschreibung(schlucht, "Eine steile Schlucht.").
beschreibung(schluessel, "Ein silberner Schluessel. Was lässt sich damit wohl öffnen?").
beschreibung(spatzen, "Ein Spatzenpaar, es schaut dich verwundert an.").
beschreibung(sumpf, "Ein nebliger Sumpf. Durch ihn führt ein Holzsteg.").
beschreibung(sueden, "Sueden").
beschreibung(tasche, "Eine abgewetzte Tasche aus dunkelbraunem Leder.").
beschreibung(truhe, "Eine schwere Truhe aus Holz. Sie lässt sich mit einem Schluessel öffnen.").
beschreibung(tuer, "Eine Tuer, die von einer in der Luft schwebenden Brille\nbewacht wird!").
beschreibung(unten, "Unten").
beschreibung(vogelscheuche, "Eine alte Vogelscheuche, in die sich ein Spatzenpaar eingenistet hat.\nSie winkt dir freundlich zu.").
beschreibung(wald, "Ein düsterer Wald mit einem Weg.").
beschreibung(wasser, "Silbern schimmerndes, flaches Wasser, das die Hälfte der Hoehle bedeckt.").
beschreibung(westen, "Westen").
beschreibung(wiese, "Eine dichte Wiese mit einem Trampelpfad.").

% --------------------------------------------------------------------------- %
% SCHNITTSTELLE DCG - SPIELMECHANIK, HILFSREGELN FÜR DIE INTERAKTION 
% --------------------------------------------------------------------------- %
% Die Aktionen werden von dem DCG aufgerufen und führen die entsprechenden 
% Prädikate aus. Sie sind Schnittstelle zwischen DCG und Spielmechanik
% --------------------------------------------------------------------------- %

aktion(ausschalten(X)) :- ausschalten(X),!.
aktion(betrachte(X)) :- betrachte(X),!.
aktion(beenden) :- beenden,!.
aktion(einschalten(X)) :- einschalten(X),!.
aktion(gehe(X)) :- gehe(X),!.
aktion(hineinschauen(X)) :- dinge_in(X),!.
aktion(hilfe) :- hilfe,!.
aktion(hinweis) :- hinweis,!.
aktion(inventar) :- inventar,!.
aktion(lege_ab(X)) :- lege_ab(X).
aktion(nimm(X)) :- nimm(X),!.
aktion(sage(X)) :- sage(X),!.
aktion(umsehen) :- umsehen,!.
aktion(verwende(X,Y)) :- verwende(X,Y).

% --------------------------------------------------------------------------- %
% SPIELMECHANIK
% --------------------------------------------------------------------------- %
% Die Spielmechanik ist eine Mischung aus Logik und Ausgabe. Dies könnte noch 
% mehr getrennt werden, ist aber für unseren Kurs ausreichend. Die Befehle wie 
% nimm/1 werden von der Schnittstelle DCG - Spielmechanik aufgerufen und dann 
% in weitere Regeln aufgeteilt, die dann bestimmte Teilaufgaben übernehmen. 
% --------------------------------------------------------------------------- %

% --------------------------------------------------------------------------- %
% BEFEHL: UMSEHEN
% Der Befehl sieht sich von der aktuellen Position aus um. Dafür wird zunächst
% die eigene Position ermittelt und die Beschreibung davon geholt und ausge-
% geben. Dann wird über dinge_an/1 aufgelistet, was es von der eigenen Position
% aus zu sehen gibt. dinge_an/1 geht dafür die logische Datenbasis durch, 
% findet die Definition der Orte in lokation/2 und gibt diese dann aus. 
% fail sorgt für ein absichtliches fehlschlagen der Regel, so dass durch 
% Backtracking nach  neuen Einsetzungen gesucht wird. Das führt dazu, dass 
% alle Einträge von lokation/2, die matchen, ausgegeben werden. Ein einfacher 
% Mechanismus, um sämtliche Lösungen aufzulisten. dinge_an(_). sorgt dafür, 
% dass am Ende kein false steht, wenn keine weiteren Lösungen mehr gefunden 
% werden, da es immer wahr wird.
% 
% BEFEHL: DINGE_IN
% Mit hineinschauen lässt sich in Objekte hineinschauen. Dafür wird geschaut, ob 
% sich das Objekt, in das hineingeschaut werden soll am Ort befindet und dann 
% selbst als Ort mit dinge_an/2 verwendet.
% --------------------------------------------------------------------------- %

umsehen :-
    meine_position(Position),
    beschreibung(Position, Beschreibung),
    tty_clear,
    writeln("---------------------------------------------------------------------------"),
    format("Du bist hier: ~w ~n ~n", [Beschreibung]),
    writeln("Du schaust dich um und siehst: "),
    writeln("---------------------------------------------------------------------------"),
    dinge_an(Position),nl,
    writeln("Mögliche Ausgänge:"),nl,
    begehbare_pfade(Position),
    writeln("---------------------------------------------------------------------------"),!.

dinge_an(Position):-
    lokation(Gegenstand, Position),
    beschreibung(Gegenstand, Beschreibung),
    writeln(Beschreibung),
    fail,!.
dinge_an(_).

dinge_in(truhe) :- 
  puzzle2,!.
dinge_in(Objekt):- 
    lokation(_, Objekt),  
    format("Im ~w befindet sich etwas: ~n ~n", [Objekt]),            
    dinge_an(Objekt),!.
dinge_in(_):-
    writeln("Darin befindet sich nichts.").

puzzle2 :- 
    eingeschaltet(truhe),
    writeln("Du öffnest die Truhe und darin findest du eine Notiz.").
puzzle2 :-
    writeln("Die Truhe ist verschlossen. Du musst wohl nach dem Schlüssel suchen."),!.

% --------------------------------------------------------------------------- %
% BEFEHL: NIMM
% Dieser Befehl dient dem Aufnehmen eines Gegenstands. Dieser muss dafür in 
% dem Ort sein, an dem auch die Spielfigur ist und tragbar sein. Um das zu
% überprüfen gibt es die beiden Hilfsprädikate, ist_hier/1 und ist_aufnehmbar/1.
% ist_hier/1 überprüft dabei, ob ein Gegenstand entweder bereits im Besitz der
% Spielfigur ist, oder an dem Ort, an dem die Spielfigur ist. Wenn der Gegen-
% stand bereits in Besitz ist, muss nichts weiter getan, ausser der entsprechen- 
% dne Hinweis auszugeben werden. Ist der Gegenstand nicht in Besitz, aber
% am gleichen Ort, wird entsprechend 'true' zurückgegeben. Falls der Gegen-
% stand sich weder im Besitz befindet, noch for Ort ist, wird ein entsprechender
% Text ausgegeben und mit fail absichtlich 'false' zurückgegeben, so dass auch
% nimm/1 scheitert und nichts aufgenommen wird. 
% --------------------------------------------------------------------------- %

nimm(Gegenstand):-
    ist_hier(Gegenstand),
    ist_aufnehmbar(Gegenstand),
    nimm_auf(Gegenstand, besitz),
    format("Du hast den folgenden Gegenstand aufgenommen: ~w ~n ~n", [Gegenstand] ),!.

ist_hier(Gegenstand):-
    besitz(Gegenstand),
    format("Diesen Gegenstand hast du schon: ~w ~n", [Gegenstand]),!.
ist_hier(Gegenstand):-
    meine_position(Position),
    ist_an(Gegenstand, Position),!. 
ist_hier(Gegenstand) :-
    format("Hier sehe hier kein/e ~w ~n", [Gegenstand]),
    fail.

ist_an(Gegenstand,Ort):-          
    lokation(Gegenstand,Ort).               
ist_an(Gegenstand,Ort):-            
    lokation(Gegenstand,In),
    ist_an(In,Ort).

ist_aufnehmbar(Gegenstand):-
    tragbar(Gegenstand),!.
ist_aufnehmbar(Gegenstand):-
    lokation(Gegenstand,_), 
    format("Den Gegenstand ~w kannst du nicht aufnehmen. ~n", [Gegenstand]).

nimm_auf(Gegenstand, besitz) :-
    retract(lokation(Gegenstand, _)),
    asserta(besitz(Gegenstand)).

lege_ab(Gegenstand):- 
    besitz(Gegenstand),
    meine_position(Position),
    retract(besitz(Gegenstand)),
    assert(lokation(Gegenstand, Position)),
    format("Du hast ~w hier abgelegt: ~w  ~n", [Gegenstand, Position]),!.
lege_ab(Gegenstand):- 
    format("Den Gegenstand ~w hast du nicht. ~n", [Gegenstand]),!.

% --------------------------------------------------------------------------- %
% BEFEHL: INVENTAR
% Damit das Inventar aufgelistet werden kann, nutzt inventar/0  das Hilfsprä-
% dikat in_besitz/0. Diese wurden getrennt, damit der Satz nur einmal und nicht 
% vor jedem Gegenstand ausgegeben wird. fail sorgt wieder dafür, dass alle
% Gegenstände durch Backtracking ausgegeben werden. in_besitz/0. sorgt dafür, 
% dass am Ende der Auflistung kein false ausgeben wird.
% --------------------------------------------------------------------------- %

inventar :-
    writeln("Die folgenden Gegensände trägst du bei dir:"),
    writeln("---------------------------------------------------------------------------"),
    in_besitz,
    writeln("---------------------------------------------------------------------------").

in_besitz :- 
    besitz(Gegenstand),
    beschreibung(Gegenstand, Beschreibung),
    writeln(Beschreibung),
    fail.
in_besitz.

% --------------------------------------------------------------------------- %
% BEFEHL: BETRACHTE
% Untersucht einen Gegenstand. Dafür muss der Gegenstand entweder in Besitz 
% sein (Fall 1), oder sich an der Position befinden (Fall 2). Dann wird die 
% entsprechende Beschreibung zu dem Gegenstand ausgegeben. Ansonsten (Fall 3)
% wird nur der Text ausgegeben, dass der Gegenstand nicht untersucht werden 
% kann.
% --------------------------------------------------------------------------- %

betrachte(Gegenstand):- 
    besitz(Gegenstand),
    beschreibung(Gegenstand, Beschreibung),
    writeln(Beschreibung),!.
betrachte(Gegenstand):- 
    meine_position(Position),
    ist_an(Gegenstand, Position),
    beschreibung(Gegenstand, Beschreibung),
    writeln(Beschreibung),!.
betrachte(Gegenstand) :- 
    format("Diesen Gegenstand sehe ich hier nicht: ~w", [Gegenstand]).

% --------------------------------------------------------------------------- %
% PFADE AUFLISTEN
% Das Prädikat dient der Ausgabe der, von einer Position aus, begehbaren Pfade. 
% Die Position wird beim Aufruf des Prädikats als Parameter übergeben. So kann 
% sie unabhängig von der Position der Spielfigur verwendet werden und ist so 
% flexibler. Dazu wird erst geprüft, welche Pfade es von der aktuellen Position 
% aus, in welche Richtung gibt, gibt. Dann wird die entsprechende Beschreibung 
% von Richtung und Ziel geholt. Beide werden dann zur Ausgabe in format/1 
% eingesetzt. Das fail/0 am Ende dient dazu da Backtracking zu erzwingen, das 
% heisst nach weiteren Lösungen zu suchen und so alle Pfade auszugeben. Die 
% zweite Klausel des Prädikats begehbare_pfade(_) dient als Platzhalter, um
% ein 'false' am Ende der Auflistung zu unterdrücken. Da es eine anonyme 
% Variable _ enthält, wird es immer wahr. 
% --------------------------------------------------------------------------- %

begehbare_pfade(Position):-
    pfad(Richtung, Position, Ziel),        
    beschreibung(Richtung, Beschreibung0),
    beschreibung(Ziel, Beschreibung1),
    format("In Richtung ~w: ~w ~n", [Beschreibung0,Beschreibung1]),
    fail.
begehbare_pfade(_). 

% --------------------------------------------------------------------------- %
% BEFEHL: GEHE
% Die folgenden Prädikate dienen dazu, den Befehl gehe/1 zu realisieren, der 
% von der DCG-Prolog Schnittstelle aufgerufen wird, wenn eine der 'gehe' DCG
% Varianten aufgerufen wird. Zuerst werden die Spezialfälle getestet, die 
% Himmelsrichtungen und der Keller, da dieser eines der Rätsel ist. Dann wird 
% zunächst mit Hilfe des Prädikats begehbar/1 (wenn gehe/1 mit einem Ort 
% verwendet wird), oder begehbar/2 (wenn gehe/1 mit einer Himmelsrichtung 
% verwendet wird) geschaut, ob es einen Pfad von der aktuellen Position zu 
% dem eingegebenen Ziel gibt. Falls ein Pfad existiert, wird 'true' zurück-
% gegeben und gehe/1 kann weitermachen. neue_position/1 löscht dann mit 
% retract/1 die aktuell gespeicherte Position und schreibt dann die neue 
% Position mit asserta/1 in die Datenbasis. 
%
% Falls die Spielfigur schon an dem Ort ist, der als Ziel eingegeben wurde,  
% was genau dann als wahr abgeleitet wird, wenn meine_position/1 und das Ziel 
% gleich sind, wird der entsprechende Hinweis ausgegeben.
%
% Falls kein Pfad existiert, wird 'false' zurückgegeben und der entsprechende
% Hinweis ausgegeben.
%
% puzzle/1 dient dazu, bei dem Versuch den Keller zu betreten, zu testen, 
% ob die Spielfigur die Lampe dabei hat und diese auch an ist. Falls beides
% zutrifft, wir true zurückgegeben sie kann den Keller bereten. 
% Hier wartet dann das nächste Rätsel.
% --------------------------------------------------------------------------- %

gehe(norden) :- 
    begehbar2(norden,Ziel),
    neue_position(Ziel),
    umsehen,!.
gehe(sueden) :- 
    begehbar2(sueden,Ziel),
    neue_position(Ziel),
    umsehen,!.
gehe(osten) :- 
    begehbar2(osten,Ziel),
    neue_position(Ziel),
    umsehen,!.
gehe(westen) :- 
    begehbar2(westen,Ziel),
    neue_position(Ziel),
    umsehen,!.
gehe(unten) :- gehe(keller).
gehe(oben) :- 
    begehbar2(oben,Ziel),
    neue_position(Ziel),
    umsehen,!.

gehe(keller):-
    puzzle1,!.

gehe(Ziel):- 
    begehbar(Ziel),
    neue_position(Ziel),
    umsehen,!.
gehe(Ziel) :-
    meine_position(Position),
    Position = Ziel,
    format("Da bist du doch schon: ~w ~n", [Ziel]).
gehe(Ziel) :-
   format("Von hier aus kommst du da nicht hin: ~w ~n", [Ziel]).

begehbar(Ziel) :-
    meine_position(Position),
    pfad(_, Position, Ziel),!.

begehbar2(Richtung, Ziel) :-
    meine_position(Position),
    pfad(Richtung, Position, Ziel),!.

neue_position(Ziel):-
    retract(meine_position(_)),      
    asserta(meine_position(Ziel)).  

puzzle1 :-
    begehbar(keller), 
    besitz(lampe),
    eingeschaltet(lampe),
    writeln("Die Lampe brennt, jetzt kann ich in den Keller."),
    neue_position(keller),
    umsehen,!. 
puzzle1 :-
    writeln("Das ist mir zu dunkel da unten, etwas Licht wäre nicht schlecht..."),
    nl,!. 

% --------------------------------------------------------------------------- %
% BEFEHLE: EINSCHALTEN / AUSCHALTEN
% Dieser Abschnitt enthält die Prädikate und Hilfsprädikate, die für das ein-
% und ausschalten von Gegenständen zuständig sind.
% Um etwas einschalten zu können, muss es im Besitz sein, das heißt der 
% Gegenstand muss erst aufgenommen werden, wenn er sich noch nicht im Besitz
% befindet. Dazu wird besitz/1 abgefragt. Als nächstes wir aktivierbar/1 
% abgefragt. In der Datenbasis wurden die aktivierbaren Gegenstände damit
% hinterlegt. Falls beide Goals wahr werden, wird mit schalte_ein/1 der 
% entsprechende Gegenstand eingeschaltet. Dazu wird dieser mit asserta/1
% in die Datenbasis geschrieben. Damit wird das Faktum geschaffen, dass die 
% Lampe eingeschaltet ist. Möchte die Lampe wieder ausgeschaltet werden, 
% wird das Faktum einfach entfernt. Das übernimmt auschalten/1.
% --------------------------------------------------------------------------- %

einschalten(Gegenstand) :- 
    besitz(Gegenstand),
    aktivierbar(Gegenstand),
    schalte_ein(Gegenstand),!.
einschalten(Gegenstand) :- 
    besitz(Gegenstand),
    writeln("Diesen Gegenstand kannst du nicht einschalten"),!.
einschalten(Gegenstand) :-
    format("Diesen Gegenstand hast du nicht: ~w.", [Gegenstand]),!.

schalte_ein(Gegenstand):-
    eingeschaltet(Gegenstand),
    format("Ist bereits eingeschaltet: ~w ~n", [Gegenstand]),!.
schalte_ein(Gegenstand) :-
    asserta(eingeschaltet(lampe)),
    format("Du hast den folgenden Gegenstand eingeschaltet: ~w ~n", [Gegenstand]),!.

ausschalten(Gegenstand) :- 
    besitz(Gegenstand),
    aktivierbar(Gegenstand),
    eingeschaltet(Gegenstand),
    schalte_aus(Gegenstand).
ausschalten(Gegenstand) :- 
    besitz(Gegenstand),
    aktivierbar(Gegenstand),
    format("Dieser Gegenstand ist nicht eingeschaltet: ~w ~n", [Gegenstand]).
ausschalten(Gegenstand) :- 
    besitz(Gegenstand),
    format("Diesen Gegenstand kannst du nicht ausschalten: ~w ~n", [Gegenstand]).
ausschalten(Gegenstand) :- 
    format("Diesen Gegenstand hast du nicht: ~w ~n", [Gegenstand]).

schalte_aus(Gegenstand) :-
    retract(eingeschaltet(Gegenstand)),
    format("Du hast den folgendne Gegenstand ausgeschaltet: ~w ~n", [Gegenstand]),!.

% --------------------------------------------------------------------------- %
% BEFEHL: VERWENDEN
% Verwende/2 wird verwendet, um einen Gegenstand mit einem anderen zu verwenden...
% Im Gegensatz zu einschalten/1 wird hier also mit zwei Gegenständen gearbeitet.
% Damit diese sich auch miteinander verwenden lassen, muss sich davon 
% mindestens einer im Besitz, also dem Inventar der Spielfigur befinden. 
% Die Fallunterscheidung muss also schauen, ob beide Gegenstände im Inventar 
% sind, oder einer im Inventar und einer vor Ort. Ist beides nicht der Fall 
% tritt Fall 3 ein. Die 3. Klausel könnte noch weiter verbessert werden.
% eingeschaltet/1 wird hier auch für die Truhe verwendet, aktiviert/1 wäre 
% ein besserer, generischerer Name für das Prädikat -> für die nächste Version. 
% --------------------------------------------------------------------------- %

verwende(Gegenstand0,Gegenstand1):-  
    besitz(Gegenstand0),
    besitz(Gegenstand1),
    aktivierbar_mit(Gegenstand0, Gegenstand1),
    asserta(eingeschaltet(Gegenstand1)),
    format("Du verwendest den Gegenstand ~w mit dem Gegenstand ~w. ~n", [Gegenstand0, Gegenstand1]),!.
verwende(Gegenstand0,Gegenstand1) :-
    meine_position(Position),
    besitz(Gegenstand0),
    lokation(Gegenstand1, Position),
    aktivierbar_mit(Gegenstand0, Gegenstand1),
    asserta(eingeschaltet(Gegenstand1)),
    format("Du verwendest den Gegenstand ~w mit dem Gegenstand ~w. ~n", [Gegenstand0, Gegenstand1]),!.
verwende(_,_) :- 
    writeln("Das kannst du nicht miteinander verwenden."),!.

% --------------------------------------------------------------------------- %
% BEFEHL: SAGEN
% Da es zum Haupträtsel gehört, die Parole zu entschlüsseln und dem Wächter zu 
% sagen, müssen die möglichen Fälle, die eintreten können unterschieden werden. 
% 1. Die Spielfigur ist beim Wächter, und sagt die richtige Parole, 
% dann sagt der Wächter seinen letzten Satz und das Spiel wird beendet.
% 2. Die Spielfigur ist beim Wächter, sagt jedoch die falsche Parole, dann muss 
% der Wächter entsprechend reagieren und sagen, dass die Parole falsch ist.
% 3. Die Spielfigur ist nicht beim Wächter, dann kann sie die Parole, oder 
% irgendein Wort sagen, ohne dass es Auswirkungen auf das Spiel hat. 
%
% Wird die richtige Parole gesagt, wird das Prädikat gesagt/0 in die Daten-
% basis geschrieben, so dass die Regel spielende/0 nun wahr und abgearbeitet 
% werden kann.
% --------------------------------------------------------------------------- %

sage(Parole):- 
    meine_position(tuer),
    parole(Parole),
    asserta(gesagt),
    format("Du rufts: ~w! ~n", [Parole]).
sage(Parole):- 
    meine_position(tuer),
    \+ parole(Parole),
    format("Du rufts: ~w!~n Doch der Wächter lacht:~n Haha! Falsche Parole! Versuche es nochmal!" , [Parole]),!.
sage(Wort):- 
    format("Du rufst: ~w! ~n Doch deine Worte verhallen im Nichts... ~n", [Wort]),!.

% --------------------------------------------------------------------------- %
% DER DCG TEIl
% --------------------------------------------------------------------------- %
% Dieser Abschnitt übernimmt das Einlesen und analysieren der Grammatik der 
% eingegebenen Texte. Die Grammatik erlaubt einfache Satzkonstruktionen und  
% Synonyme. War bisher alles auf Deutsch notiert, enthält dieser Bereich auch
% englische Prädikate, die aus dem ursprünglchen Nani Search stammen. Nur die 
% Erweiterungen und Änderungen wurden auf Deutsch hinzugefügt.
% --------------------------------------------------------------------------- %

get_command(C):-
    readlist(L),        % liest einen Satz und dessen Worte in Listenform ein
    command(X,L,[]),    % ruft due Grammatik für den Befehl auf
    C =.. X,!.          % macht aus der Befehlsliste eine Struktur
get_command(_):-
    format("Das verstehe ich nicht. Versuche es noch mal, oder gib 'hilfe' ein. ~n ~n" ),fail.

% --------------------------------------------------------------------------- %
% Es gibt zwei Type von Befehlen, einmal mit und einmal ohne ein Argument.
% Ein weiterer Spezialfall ist die Eingabe eines Ortes, der als Befehl 
% interpretiert wird, an diesen Ort zu gehen. Ein vierter Befehl 'verwende' 
% wurde hinzugefügt für 'verwende Gegenstand mit Gegenstand'. 
% --------------------------------------------------------------------------- %

command([Pred,Arg]) --> verb(Type,Pred), nounphrase(Type,Arg).
command([Pred]) --> verb(intran, Pred).
command([gehe, Arg]) --> noun(go_place, Arg).

command([verwende, Arg0, Arg1]) --> verb(Type,Pred), nounphrase(Type,Arg0), targetnounphrase(Type,Arg1).

% --------------------------------------------------------------------------- %
% Vier Typen von Verben. Jedes Verb korrespondiert mit einem Befehl.
% Auch Synonyme sind erlaubt.
% Für das Endrätsel wurde der Verbtyp 'wort' hinzugefügt, so dass diese 
% gesondert behandelt werden kann.
% --------------------------------------------------------------------------- %

verb(go_place, gehe) --> go_verb.
verb(gegenstand,V) --> tran_verb(V).
verb(intran,V) --> intran_verb(V).

verb(wort,V) --> tell_verb(V).

% --------------------------------------------------------------------------- %

go_verb --> [g].
go_verb --> [gehe].
go_verb --> [gehe, gen].
go_verb --> [gehe, in, richtung].
go_verb --> [gehe, richtung].
go_verb --> [gehe,nach].
go_verb --> [gehe,zu].

% --------------------------------------------------------------------------- %

tran_verb(ausschalten) --> [ausschalten].
tran_verb(ausschalten) --> [mache,aus].
tran_verb(ausschalten) --> [schalte,aus].
tran_verb(betrachte) --> [ansehen].
tran_verb(betrachte) --> [betrachte].
tran_verb(betrachte) --> [sieh, an].
tran_verb(betrachte) --> [schau, an].
tran_verb(einschalten) --> [einschalten].
tran_verb(einschalten) --> [entzuende].
tran_verb(einschalten) --> [schalte,ein].
tran_verb(einschalten) --> [schalte,an].
tran_verb(lege_ab) --> [ablegen].
tran_verb(lege_ab) --> [entferne].        
tran_verb(lege_ab) --> [lege,ab].
tran_verb(hineinschauen) --> [schaue,in].
tran_verb(hineinschauen) --> [schau,in].
tran_verb(hineinschauen) --> [sieh,in].
tran_verb(hineinschauen) --> [oeffne].
tran_verb(hineinschauen) --> [untersuche].
tran_verb(nimm) --> [nimm].
tran_verb(nimm) --> [nimm,auf].
tran_verb(nimm) --> [aufheben].
tran_verb(nimm) --> [aufnehmen].
tran_verb(nimm) --> [neb,auf].

% --------------------------------------------------------------------------- %
% Neue Verben für 'verwende'

tran_verb(verwende) --> [benutze].
tran_verb(verwende) --> [gebrauche].
tran_verb(verwende) --> [verwende].
tran_verb(verwende) --> [nutze].

% --------------------------------------------------------------------------- %
% Neue Kategorie für das letzte Rätsel hinzugefügt, um Worte sagen zu können.

tell_verb(sage) --> [sage].
tell_verb(sage) --> [rufe].
tell_verb(sage) --> [schreie].

% --------------------------------------------------------------------------- %

intran_verb(inventar) --> [inventar].
intran_verb(inventar) --> [i].
intran_verb(umsehen) --> [umsehen].
intran_verb(umsehen) --> [umschauen].
intran_verb(umsehen) --> [sieh, dich, um].
intran_verb(umsehen) --> [schau, dich, um].
intran_verb(umsehen) --> [wo, bin, ich].
intran_verb(umsehen) --> [u].
intran_verb(beenden) --> [beenden].
intran_verb(beenden) --> [ende].
intran_verb(beenden) --> [verlassen].
intran_verb(beenden) --> [bye].
intran_verb(hilfe) --> [hilfe].
intran_verb(hinweis) --> [hinweis].
intran_verb(hinweis) --> [tipp].

% --------------------------------------------------------------------------- %
% noundphrase/2
% definiert ein Nomen/Hauptwort/Substantiv (noun) mit einem optionalen 
% Determinativ (determiner)
% --------------------------------------------------------------------------- %

nounphrase(Type,Noun) --> det,noun(Type,Noun).
nounphrase(Type,Noun) --> noun(Type,Noun).

det --> [das].
det --> [die].
det --> [den].
det --> [ein].
det --> [eine].
det --> [einen].

% --------------------------------------------------------------------------- %
% Neue Kategorie, um Substantive, die das Ziel von 'anwenden' sind mit und ohne  
% Präposition nutzen zu können.

targetnounphrase(Type,Noun) --> prep,noun(Type,Noun).
targetnounphrase(Type,Noun) --> noun(Type,Noun).

prep --> [mit].

% --------------------------------------------------------------------------- %
% noun/2
% Die Definitionen mit Variablen dienen dazu Substantive eines bestimmten 
% Typs zu definieren. 'go_place' Substantive definieren Orte, vom Typ 
% 'gegenstand', Gegenstände. Diese werden dann über die Variablen und den ent-
% sprechenden Aufruf in den geschweiften Klammern {} aus der Datenbasis geholt. 
% ort(R) schaut beispielsweise, ob es den übergebenen Ort gibt, lokation(T, _),
% ob es diesen Gegenstand an der Lokation gibt und besitz(T) ob es den über-
% gebenen Gegenstand im Inventar gibt. 
% Mit Hilfe der geschweiften Klammern lässt sich die DCG Syntax mit der 
% normalen Prolog Syntax kombininiern. 
% --------------------------------------------------------------------------- %

noun(go_place,R) --> [R], { ort(R) }.
noun(go_place,R) --> [R], { richtung(R)}.
noun(gegenstand,T) --> [T], { lokation(T,_) }.
noun(gegenstand,T) --> [T], { besitz(T) }.

% --------------------------------------------------------------------------- %
% NOUN DEFINITIONEN FÜR DIE RÄTSEL
% Für das Rätsel wurde ein noun Typ 'wort' hinzugefügt, der jedes übergebene
% Wort als noun annmmt. So lässt sich jedes Wort an jeder Stelle im Spiel 
% sagen. 
% --------------------------------------------------------------------------- %

noun(wort,W) --> [W].      

% --------------------------------------------------------------------------- %
% DER READER 
% --------------------------------------------------------------------------- %
% Der Reader liest den im Terminal eingegebenen Text ein und konvertiert diesen
% mit Hilfe von readList/1 in eine Liste, die dann die Worte enthält.
% Dieser Abschnitt basiert auf dem Beispiel aus dem Buch von Clocksin & Mellish
% Programming in Prolog und kann dort nachgelesen werden.
% https://link.springer.com/book/10.1007/978-3-642-55481-0
% --------------------------------------------------------------------------- %

readlist(L):-
    nl,
    write('>> '),
    read_word_list(L).

read_word_list([W|Ws]) :-
    get0(C),
    readword(C, W, C1),             
    restsent(C1, Ws), !.            

restsent(C,[]) :- 
    lastword(C), !.                
restsent(C,[W1|Ws]) :-
    readword(C,W1,C1),             
    restsent(C1,Ws).

readword(C,W,C1) :-         
    single_char(C),                 
    !,                              
    name(W, [C]),                   
    get0(C1).
    readword(C, W, C1) :-
    is_num(C),                      
    !,                              
    number_word(C, W, C1, _).       
    readword(C,W,C2) :-             
    in_word(C, NewC),               
    get0(C1),                       
    restword(C1,Cs,C2),                
    name(W, [NewC|Cs]).            
    readword(C,W,C2) :-             
    get0(C1),       
    readword(C1,W,C2).              

restword(C, [NewC|Cs], C2) :-
    in_word(C, NewC),
    get0(C1),
    restword(C1, Cs, C2).
restword(C, [], C).

single_char(0',).
single_char(0';).
single_char(0':).
single_char(0'?).
single_char(0'!).
single_char(0'.).

in_word(C, C) :- C >= 0'a, C =< 0'z.
in_word(C, L) :- C >= 0'A, C =< 0'Z, L is C + 32.
in_word(0'',0'').
in_word(0'-,0'-).

number_word(C, W, C1, Pow10) :- 
    is_num(C),
    !,
    get0(C2),
    number_word(C2, W1, C1, P10),
    Pow10 is P10 * 10,
    W is integer(((C - 0'0) * Pow10) + W1).
number_word(C, 0, C, 0.1).

is_num(C) :-
    C =< 0'9,
    C >= 0'0.

lastword(10).   
lastword(0'.).
lastword(0'!).
lastword(0'?).
