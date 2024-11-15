/*
Designate has/1 and location/1
as dynamic. Which means they can
be changed using assertz and retract.
*/
:- dynamic(has/1).
:- dynamic(location/1).
:- dynamic(contains/2).
:- dynamic(contains_storage/2).

/****************************************
These facts are not really needed.
I've given them here, just so you have
a list of the room and things.

room(dungeon).
room(crypt).
room(basement).
room(graveyard).
room(garden).
room(church).
room(hall).
room(kitchen).
room(shed).
room(gate).
room(lab).
room(tower).
room(diningroom).

room(nowhere). A fake room where things go when
taken.

thing(message).
thing(code).
thing(key).
********************************************/


/* Note: These edges are UNDIRECTED.
Meaning the player can move from one
location to another in either direction.
You code will need to account for that.
*/
edge(dungeon, crypt).
edge(crypt, basement).
edge(graveyard, crypt).
edge(garden, graveyard).
edge(church, garden).
edge(garden, shed).
edge(basement, hall).
edge(garden, hall).
edge(gate, hall).
edge(kitchen, hall).
edge(kitchen, diningroom).
edge(tower, diningroom).
edge(hall, tower).
edge(lab, tower).
edge(shed, basement).

/* The starting location of the things.
*/
contains(lab, message).
contains(dungeon, code).
contains(church, key).

/* Initial state:
- Player has nothing
- Player's location is the kitchen.
*/
has(false/0).
location(kitchen).

/* The win condition. After running
your game using play/0, I should be able to type:
win(), and prolog responds: true.
*/
win() :-
    (
	has(message),
	has(code),
	has(key),
	location(gate)
    )
    -> format('You are free of the spooky mansion.~n'), resetGame().

/* Created canmove predicate that checks the current location and if there is an edge to or from x to the current location. 
*/

canmove(X):-
	location(Current),
	(edge(Current,X); edge(X,Current)).

/* You may only use this predicate
to move the player between locations.
This only moves the player from one
location to another if the room the
player's current location are directly
connected (one edge away).
*/

move(X) :-
    canmove(X)
    -> (
		format("Moving to: ~w ~n",X),
	    retract(location(_)),
	    assertz(location(X))
	);
    false.

/* You may only use this predicate
to take things from the environment.
The take/1 predicate will take the
thing X if the player is currently
in the location where it is located.
Once taken, a thing is moved into a
nowhere location that is not reachable
to simulate the player has it. This
prevents the player from taking it
multiple times.
*/
take(X) :-
    (
	location(Y),
	contains(Y, X)
    )
    -> (
		format("Found ~w ~n",X),
	    assertz(has(X)),
	    retract(contains(Y,X)),
	    assertz(contains(nowhere,X))
	);
    false.

/* Base condition for undirected graph to verify that it's either or
*/
path(X,Y):-
	edge(X,Y);edge(Y,X).

/* Initialize with findPath
*/
path(X,Y,Traversed):- path(X,Y,Traversed,[X]).

/* Base case
*/
path(X,Y,[X,Y],Traversed):-
	\+member(Y,Traversed),path(X,Y).

/* Recursion
*/
path(X,Y,[X|Path],Traversed):-
	path(X,Z),\+ member(Z,Traversed), path(Z,Y,Path,[Z|Traversed]).

/* Predicate to start pathfinding
   Exclaimation point will cut it off after a success; we don't necessarily need the optimal path, just a path.
*/
findPath(X,Y,Path):-
	Y\=X,
	path(X,Y,Path),!.

/* Base Case
*/
followPath([]).

/* Recursively go through a given path and move to each tile
*/
followPath([Next|Tail]):-
	move(Next),
	followPath(Tail).

/* Predicate to start travering the path
*/
startTraversal([_,Next|Tail]):-followPath([Next|Tail]).

/* Called by the play predicate to save the initial state
*/
startGame():-
	contains(MsgLoc,message),
	contains(CodeLoc,code),
	contains(KeyLoc,key),
	assertz(contains_storage(MsgLoc,message)),
	assertz(contains_storage(CodeLoc,code)),
	assertz(contains_storage(KeyLoc,key)).

/* Called by the win predicate to reset the game to the initial state saved in the startGame predicate.
*/
resetGame():-
	retractall(has(_)),
	retractall(location(_)),
	retractall(contains(_,_)),
	assertz(location(kitchen)),
	assertz(has(false/0)),
	contains_storage(MsgLoc,message),
	contains_storage(CodeLoc,code),
	contains_storage(KeyLoc,key),
	assertz(contains(MsgLoc,message)),
	assertz(contains(CodeLoc,code)),
	assertz(contains(KeyLoc,key)),!.


/****************************************

Write your code below. Think of the
play/0 predicate as the main() function.
It should start the simulation. When
play/0 is called, the simlation should
do the following:

- Move to one of the things and take it.
- Move to the next and take it.
- Move to the third and take it.
- Move to the gate.

Hints:
- Don't hard-code the solution. When I test
your code, I will rearrange a
few connections and a thing or two. If you
hard-code your solution, it will not work
when I test it.
- I will NOT change the names of the rooms
or things. Your code can assume fact names
stay the same.
- The gate will always be the exit.
- The player will always start in the kitchen.
- Your code must programmatically
find the correct Path to each thing and
then to the gate.
- I suggest you create a cleanup/0 predicate
that uses retract or retractall, to reset
the simulation back to its initial state;
otherwise, facts created during previous
runs will persist.

All of the above should happen automatically
when the play/0 predicate is called.

Once the player has all three things and is
in the gate location, the win condition will
be true.
****************************************/

/* You will need to fill in play/0.
You can write as many additional predicates
as necessary. You may alter the predicates
I have provided for testing alternate maps
but note that I will use my own. For
grading */

play():-
	% Maneuver to the message
	startGame(),
	location(Start),
	format("starting in ~w ~n",Start),
	contains(MessageLocation, message),
	findPath(Start,MessageLocation,MessagePath),
	startTraversal(MessagePath),
	take(message),

	% Maneuver to the code
	contains(CodeLocation,code),
	location(StartTwo),
	findPath(StartTwo,CodeLocation,CodePath),
	startTraversal(CodePath),
	take(code),

	% Maneuver to the key
	contains(KeyLocation,key),
	location(StartThree),
	findPath(StartThree,KeyLocation,KeyPath),
	startTraversal(KeyPath),
	take(key),

	% Maneuver to the gate
	location(StartFour),
	findPath(StartFour,gate,GatePath),
	startTraversal(GatePath),!.
