:- dynamic([

  % Length of the lattice side N.
  % It means that we have the lattice of the size N x N
  % Lattice can be said to be a map in which an actor tries to find his home
  latticeSize/1,

  % Coordinates(p, [X, Y]) means that [X, Y] are the coordinates of p
  coordinates/2,
  homePath/1        % path to home found by searching algorithms
]).


% Generate random coordinates [X, Y]
createRandomCoords([X, Y]):-
    latticeSize(N),
    random(1, N, X),
    random(1, N, Y).


% If we have generated the needed amount of mask cells then stop
generateMaskCoords(NMasks, NumGenerated):-
    NumGenerated == NMasks,
    true.

% Generate NMasks mask cells
generateMaskCoords(NMasks, NumGenerated):-

    % Create the random coordinates of possible mask's location on the lattice
    createRandomCoords(Coords),

    % If the we have not generated the needed amount of masks then continue
    NumGenerated \= NMasks,
    (
        (
            % The mask should not be in covid infected cells
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                Coords == CovidSourceCoords
            ),
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                adjacent(Coords, CovidSourceCoords)
            ),

            % The mask should not be in the actor's starting location
            \+ (
                coordinates(actor, ActorCoords),
                Coords == ActorCoords
            ),

            % The mask should not be at home
            \+ (
                coordinates(home, HomeCoords),
                Coords == HomeCoords
            ),

            % The mask's coordinates should not coincide with doctors' ones
            \+ (
                coordinates(doctor, DoctorCoords),
                Coords == DoctorCoords
            ),

            % The mask's coordinates should not coincide with other masks' ones
            \+ (
                coordinates(mask, MaskCoords),
                Coords == MaskCoords
            )
        ) -> (
            % If all needed conditions are satisfied then we create the mask
            % with these coordinates
            assert(coordinates(mask, Coords)),

            % Increment the number of created masks and proceed with recursion
            NewNumGenerated is NumGenerated + 1,
            generateMaskCoords(NMasks, NewNumGenerated)
        ); (
            % If some conditions are violated then proceed with recursion
            % with previous value of the number of generated masks (try again)
            generateMaskCoords(NMasks, NumGenerated)
        )
    ).


% If we have generated the needed amount of doctor cells then stop
generateDoctorCoords(NDoctors, NumGenerated):-
    NumGenerated == NDoctors,
    true.

% Generate NDoctors mask cells
generateDoctorCoords(NDoctors, NumGenerated):-

    % Create the random coordinates of possible doctor's location on the lattice
    createRandomCoords(Coords),

    % If the we have not generated the needed amount of doctors then continue
    NumGenerated \= NDoctors,
    (
        (
            % The doctor should not be in covid infected cells
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                Coords == CovidSourceCoords
            ),
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                adjacent(Coords, CovidSourceCoords)
            ),

            % The doctor should not be in the actor's starting location
            \+ (
                coordinates(actor, ActorCoords),
                Coords == ActorCoords
            ),

            % The doctor should not be at home
            \+ (
                coordinates(home, HomeCoords),
                Coords == HomeCoords
            ),

            % The doctor's coordinates should not coincide with masks' ones
            \+ (
                coordinates(mask, MaskCoords),
                Coords == MaskCoords
            ),

        % The doctor's coordinates should not coincide with other doctors' ones
            \+ (
                coordinates(doctor, DoctorCoords),
                Coords == DoctorCoords
            )
        ) -> (
            % If all needed conditions are satisfied then we create the doctor
            % with these coordinates
            assert(coordinates(doctor, Coords)),

            % Increment the number of created doctors and proceed with recursion
            NewNumGenerated is NumGenerated + 1,
            generateDoctorCoords(NDoctors, NewNumGenerated)
        ); (
            % If some conditions are violated then proceed with recursion
            % with previous value of the number of generated doctors (try again)
            generateDoctorCoords(NDoctors, NumGenerated)
        )
    ).


% If we have generated the home then stop
generateHomeCoords(NumGenerated):-
    NumGenerated == 1,
    true.

% Generate the home
generateHomeCoords(NumGenerated):-

    % Create the random coordinates of possible home's location on the lattice
    createRandomCoords(Coords),

    % If the we have not generated the home yet then continue
    NumGenerated \= 1,
    (
        (
            % The home should not be in covid infected cells
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                Coords == CovidSourceCoords
            ),
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                adjacent(Coords, CovidSourceCoords)
            ),

            % The home should not be in the actor's starting location
            \+ (
                coordinates(actor, ActorCoords),
                Coords == ActorCoords
            )
        ) -> (
            % If all needed conditions are satisfied then we create the home
            % with these coordinates
            assert(coordinates(home, Coords)),

            % State that the home is created and proceed with recursion
            NewNumGenerated is NumGenerated + 1,
            generateHomeCoords(NewNumGenerated)
        ); (
            % If some conditions are violated then try to generate home again
            generateHomeCoords(NumGenerated)
        )
    ).


% If we have generated the needed amount of covid source cells then stop
generateCovidSourceCoords(NCovids, NumGenerated):-
    NumGenerated == NCovids,
    true.

% Generate the NCovids covid source cells
generateCovidSourceCoords(NCovids, NumGenerated):-

    % Create the random coordinates of possible home's location on the lattice
    createRandomCoords(Coords),

    % If the we have not generated the needed amount of covids then continue
    NumGenerated \= NCovids,
    (
        (
            % It should not coincide with other covid source
            \+ (
                coordinates(covidSource, CovidSourceCoords),
                Coords == CovidSourceCoords
            ),

            % It should not be in the actor's starting location and should not
            % be adjacent to it
            \+ (
                coordinates(actor, ActorCoords),
                (
                    Coords == ActorCoords;
                    adjacent(Coords, ActorCoords)
                )
            )
        ) -> (
            % If all needed conditions are satisfied then we create the covid
            % with these coordinates
            assert(coordinates(covidSource, Coords)),

            % Increment the number of created covids and proceed with recursion
            NewNumGenerated is NumGenerated + 1,
            generateCovidSourceCoords(NCovids, NewNumGenerated)
        ); (
            % If some conditions are violated then proceed with recursion with
            % previous value of the number of generated covids (try again)
            generateCovidSourceCoords(NCovids, NumGenerated)
        )
    ).


% Get coordinates of cell Z adjacent to [X, Y]
adjacent([X, Y], Z):-
    Left is X-1,
    cellIsWithinLattice([Left, Y]),
    Z = [Left, Y].

adjacent([X, Y], Z):-
    Right is X+1,
    cellIsWithinLattice([Right, Y]),
    Z = [Right, Y].

adjacent([X, Y], Z):-
    Down is Y-1,
    cellIsWithinLattice([X, Down]),
    Z = [X, Down].

adjacent([X, Y], Z):-
    Up is Y+1,
    cellIsWithinLattice([X, Up]),
    Z = [X, Up].

adjacent([X, Y], Z):-
    Left is X-1, Up is Y+1,
    cellIsWithinLattice([Left, Up]),
    Z = [Left, Up].

adjacent([X, Y], Z):-
    Right is X+1, Up is Y+1,
    cellIsWithinLattice([Right, Up]),
    Z = [Right, Up].

adjacent([X, Y], Z):-
    Right is X+1, Down is Y-1,
    cellIsWithinLattice([Right, Down]),
    Z = [Right, Down].

adjacent([X, Y], Z):-
    Left is X-1, Down is Y-1,
    cellIsWithinLattice([Left, Down]),
    Z = [Left, Down].


% Get the coordinates of the cells that are safe to go
safeAdjacent([X, Y], PathToCurNode, Z):-
    adjacent([X, Y], [Xadj, Yadj]),
    (
        (
            coordinates(mask, MaskCoords),
            member(MaskCoords, PathToCurNode)
        );
        (
            coordinates(doctor, DoctorCoords),
            member(DoctorCoords, PathToCurNode)
        );
        \+ cellIsInfected([Xadj, Yadj])
    ),
    Z = [Xadj, Yadj].


% If we have reached an end of lattice then stop printing
printLattice(_, Height):-
    Height == 0,
    true.

% Print the lattice
printLattice(N, Height):-

    % There should be something to print
    Height \= 0,

    % Get numbers 1...N for Width to iterate over X components of lattice
    between(1, N, Width),
    (
        % Print a path to home
        (
            \+ cellIsHome([Width, Height]),
            homePath(PathToHome),
            member([Width, Height], PathToHome)
        ) -> write("*");

        % Print an actor's position
        (
            coordinates(actor, ActorCoords),
            [Width, Height] == ActorCoords
        ) -> write("A");

        % Print covid infected cells
        (
            coordinates(covidSource, CovidSourceCoords),
            [Width, Height] == CovidSourceCoords
        ) -> write("C");

        cellIsInfected([Width, Height]) -> write("c");

        % Print doctor's cells
        (
            coordinates(doctor, DoctorCoords),
            [Width, Height] == DoctorCoords
        ) -> write("D");

        % Print mask's cells
        (
            coordinates(mask, MaskCoords),
            [Width, Height] == MaskCoords
        ) -> write("M");

        % Print home's cell
        (
            coordinates(home, HomeCoords),
            [Width, Height] == HomeCoords
        ) -> write("H");

        % Otherwise, the cell is empty
        write(".")
    ),

    % If we have reached the maximum X value of lattice, go to the new line
    Width == N -> nl,

    % Decrement the Y and proceed with recursion to print the other part of lattice
    % Note: we print from the highest Y value because an actor starts in the
    % left bottom corner, not in the left top corner
    NewHeight is Height - 1,
    printLattice(N, NewHeight).


% Check whether the cell [X, Y] is infected
cellIsInfected([X, Y]):-
    coordinates(covidSource, Z),
    adjacent([X, Y], Z),
    !.


% Check whether the cell [X, Y] is a home
cellIsHome([X, Y]):-
    coordinates(home, Z),
    Z == [X, Y].


% Check whether the cell [X, Y] coordinates is within the lattice
cellIsWithinLattice([X, Y]):-
    X > 0, Y > 0,
    latticeSize(N),
    X @=< N, Y @=< N.


% The code for 'minimal' and 'min' is adopted from:
% https://www.cpp.edu/~jrfisher/www/prolog_tutorial/2_15A.pl
% Finds the element with minimal second term
minLen([A | B], PathLen):-
    minim(B, A, PathLen).

minim([], PathLen, PathLen).

minim([[Path, Len] | B], [_, PathLen], MinLen):-
    Len < PathLen,
    !,
    minim(B, [Path, Len], MinLen).

minim([_ | B], PathLen, MinLen):-
    minim(B, PathLen, MinLen).


% Recusrively search for the path to home
backtracking([CellX, CellY], CurrentPath, CurrentLength, PathToHome, PathToHomeLength):-

    % If the actor picked up the mask or visited the doctor on the path to the
    % current node, then he can go directly to home with shortest path with no
    % fear of covid (since now the actor has immunity)
    \+ cellIsHome([CellX, CellY]),
    coordinates(mask, MaskCoords),
    coordinates(doctor, DoctorCoords),
    (
        member(MaskCoords, CurrentPath);
        member(DoctorCoords, CurrentPath)
    ),
    coordinates(home, [HomeX, HomeY]),

    % Estimate the length of the path to home by adding to the current path
    % length the Chebyshev's distance between the current cell and the home
    % This heuristics is needed to optimize the performance and drop not opimal
    % paths to home
    EstimatedLength is CurrentLength + max(abs(HomeX - CellX), abs(HomeY - CellY)),

    % Get the global value of minimal path length and check if the estimated
    % path length is less than it
    nb_getval(minLength, MinLength),
    EstimatedLength < MinLength,

    % Calculating the coordinates of the most optimal cell to go
    DiffX is HomeX - CellX,
    DiffY is HomeY - CellY,
    (
        DiffX == 0 -> CellAdjX is CellX;
        DiffX < 0 -> CellAdjX is CellX - 1;
        DiffX > 0 -> CellAdjX is CellX + 1
    ),
    (
        DiffY == 0 -> CellAdjY is CellY;
        DiffY < 0 -> CellAdjY is CellY - 1;
        DiffY > 0 -> CellAdjY is CellY + 1
    ),


    % Append the suitable adjacent cell to the current path
    append(CurrentPath, [[CellAdjX, CellAdjY]], NewCurrentPath),

    % Increment the length of the current path
    NewCurrentLength is CurrentLength + 1,

    % Proceed further with recursion starting the search from the adjacent cell
    % with updated path and its length
    backtracking([CellAdjX, CellAdjY], NewCurrentPath, NewCurrentLength, PathToHome, PathToHomeLength).


% If the cell is Home the current path's length is less than previous minimal
% length of the path to home then return the path to home and its length
backtracking([CellX, CellY], CurrentPath, CurrentLength, PathToHome, PathToHomeLength):-
    cellIsHome([CellX, CellY]),

    % Get the global value of the minimal length
    nb_getval(minLength, MinLength),
    CurrentLength < MinLength,

    % Update the global minimal length
    nb_setval(minLength, CurrentLength),
    PathToHome = CurrentPath,
    PathToHomeLength = CurrentLength.


% Recusrively search for the path to home
backtracking([CellX, CellY], CurrentPath, CurrentLength, PathToHome, PathToHomeLength):-
    coordinates(home, [HomeX, HomeY]),

    % Estimate the length of the path to home by adding to the current path
    % length the Chebyshev's distance between the current cell and the home
    % This heuristics is needed to optimize the performance and drop not opimal
    % paths to home
    EstimatedLength is CurrentLength + max(abs(HomeX - CellX), abs(HomeY - CellY)),

    % Get the global value of minimal path length and check if the estimated
    % path length is less than it
    nb_getval(minLength, MinLength),
    EstimatedLength < MinLength,

    % Get the adjacent cells that are safe for actor (the cells are safe if they
    % are not Covid infected or the actor has mask or he has visited the doctor)
    safeAdjacent([CellX, CellY], CurrentPath, [CellAdjX, CellAdjY]),

    % The adjacent cell should not be visited
    \+ member([CellAdjX, CellAdjY], CurrentPath),

    % Append the suitable adjacent cell to the current path
    append(CurrentPath, [[CellAdjX, CellAdjY]], NewCurrentPath),

    % Increment the length of the current path
    NewCurrentLength is CurrentLength + 1,

    % Proceed further with recursion starting the search from the adjacent cell
    % with updated path and its length
    backtracking([CellAdjX, CellAdjY], NewCurrentPath, NewCurrentLength, PathToHome, PathToHomeLength).


% Is used in A* search algorithm
% Get the node with the minimal F cost
lookForMinFCost(Open, MinFNodeTuple):-

    % Sort the list of nodes by F cost (2 - index of F cost starting from 0)
    sort(2, @=<, Open, OpenSorted),

    % Get the minimal F cost value
    nth0(0, OpenSorted, [_, _, Fmin, _, _]),

    % Get all nodes with this minimal F cost and sort them by G cost
    % (0 - index of G cost)
    setof(
        X,
        (
            member(X, OpenSorted),
            nth0(2, X, F),
            F == Fmin
        ),
        PossibleMinFNodeTuples
    ),
    sort(1, @<, PossibleMinFNodeTuples, MinFNodeTuples),

    % Get the best node
    nth0(0, MinFNodeTuples, MinFNodeTuple).


aStar([_, _, _, [CellX, CellY], PathToCurNode], _, _, Result):-

    % If the actor picked up the mask or visited the doctor on the path to the
    % current node, then he can go directly to home with shortest path with no
    % fear of covid (since now the actor has immunity)
    \+ cellIsHome([CellX, CellY]),
    coordinates(mask, MaskCoords),
    coordinates(doctor, DoctorCoords),
    (
        member(MaskCoords, PathToCurNode);
        member(DoctorCoords, PathToCurNode)
    ),
    coordinates(home, [HomeX, HomeY]),

    % Calculating the coordinates of the most optimal cell to go
    DiffX is HomeX - CellX,
    DiffY is HomeY - CellY,
    (
        DiffX == 0 -> CellAdjX is CellX;
        DiffX < 0 -> CellAdjX is CellX - 1;
        DiffX > 0 -> CellAdjX is CellX + 1
    ),
    (
        DiffY == 0 -> CellAdjY is CellY;
        DiffY < 0 -> CellAdjY is CellY - 1;
        DiffY > 0 -> CellAdjY is CellY + 1
    ),


    % Append the suitable adjacent cell to the current path
    append(PathToCurNode, [[CellAdjX, CellAdjY]], NewPathToCurNode),

    % Proceed further with recursion starting the search from the adjacent cell
    % with updated path and its length
    aStar([_, _, _, [CellAdjX, CellAdjY], NewPathToCurNode], _, _, Result).

% If we have reached the home then return the path to home
aStar([_, _, _, CurNodeCoords, PathToCurNode], _, _, Result):-
    cellIsHome(CurNodeCoords),
    Result = PathToCurNode,
    !.


% A* algorithm that searches for home
aStar([Gcur, Hcur, Fcur, CurNodeCoords, PathToCurNode], Open, Closed, Result):-

    % Add the current node to the Closed list
    append(Closed, [[Gcur, Hcur, Fcur, CurNodeCoords, PathToCurNode]], NewClosed),

    % Get the coordinates of home
    coordinates(home, [HomeX, HomeY]),

    % Get the valid nodes adjacent to the current node, calculate their G,
    % F costs and paths to them
    (
        setof(
            [Gadj, Hadj, Fadj, [Xadj, Yadj], PathToAdjNode],
            (
                % Get the adjacent nodes in which the actor can safely go
                safeAdjacent(CurNodeCoords, PathToCurNode, [Xadj, Yadj]),

                % These nodes should not be in closed list
                \+ member([_, _, _, [Xadj, Yadj], _], NewClosed),
                Gadj is Gcur + 1, % G cost of the adjacent node

                % H cost is the heuristics that is caculated as the Chebyshev's
                % distance between this node and home
                Hadj is max(abs(HomeX - Xadj), abs(HomeY - Yadj)),
                Fadj is Gadj + Hadj, % F cost of the adjacent node
                (
                    (
                        % If the node is already in open list then its G cost
                        % should be less than G cost of the current node
                        member([G, _, _, [Xadj, Yadj], _], Open),
                        Gadj =< G
                    );
                    (
                        \+ member([_, _, _, [Xadj, Yadj], _], Open)
                    )
                ),
                % Make the current node the parent of the adjacent node
                append(PathToCurNode, [[Xadj, Yadj]], PathToAdjNode)
            ),
            AdjNodes
        );
        % If no suitable adjacent nodes is found then we get an empty list
        AdjNodes = []
    ),

    % Append the obtained adjacent cells to the open list
    append(Open, AdjNodes, NewOpen),

    % If at this moment an open list should not be empty or there is no path to
    % home
    length(NewOpen, LenOpen),
    LenOpen \= 0,

    % Look for the node with lowest F cost on the open list, this will be the
    % current node. CurrentNodeTuple is [G, H, F, [NodeX, NodeY], PathToNode]
    lookForMinFCost(NewOpen, CurNodeTuple),

    % Remove the current node from the open list
    delete(NewOpen, CurNodeTuple, UpdatedOpen),

    % Proceed with recursion and search for path to home from the current node
    aStar(CurNodeTuple, UpdatedOpen, NewClosed, Result).


% Launch the search for home using backtracking
backtrackingSearch:-

    % measure the runtime
    statistics(runtime,[StartBacktracking|_]),

    % Set the initial global value of the minimal length of path to home to be
    % N * 2 - this value should be changed depending on the complexity of the
    % map (lattice)
    latticeSize(N),
    nb_setval(minLength, N * 2),

    % Get all paths to the home, select the shortest one, and print the actor's
    % path on the lattice. If there is no path to home, then print the message
    (
        setof(
            [Path, Length],
            backtracking([1, 1], [[1, 1]], 1, Path, Length),
            FoundPathsWithLengths
        );
        FoundPathsWithLengths = []
    ),
    length(FoundPathsWithLengths, Len),
    (
        Len \= 0 ->
        (
            minLen(FoundPathsWithLengths, [ShortestPath, ShortstLength]), !,
            assert(homePath(ShortestPath)),
            writeln("Win."),
            write("The number of steps: "),
            writeln(ShortstLength),
            writeln("Path to home found by Backtracking algorithm: "),
            writeln(ShortestPath),
            printLattice(N, N),
            nl
        ); (
            writeln("Lose (there is no path to home found by Backtracking algorithm).")
        )
    ),

    % stop the timer
    statistics(runtime,[StopBacktracking|_]),
    TimeBacktracking is StopBacktracking - StartBacktracking,
    write("Backtracking algorithm search time: "),
    write(TimeBacktracking),
    writeln("ms\n\n"),

    % clear the stored shortest path to home
    retractall(homePath(_)).


% Launch the search for home using A* algorithm
aStarSearch:-

    % measure the runtime
    statistics(runtime,[StartAstar|_]),

    % Get the shortest path to home and print the actor's path on the lattice.
    % If there is no path to home, then print the message
    (
        (
            aStar([0, 0, 0, [1, 1], [[1, 1]]], [], [], Result),
            length(Result, ShortestLength),
            writeln("Win."),
            write("The number of steps: "),
            writeln(ShortestLength),
            writeln("Path to home found by A* algorithm: "),
            writeln(Result),
            assert(homePath(Result)),
            latticeSize(N),
            printLattice(N, N),
            nl,
            !
        );
        (
            writeln("Lose (there is no path to home found by A* algorithm).")
        )
    ),

    % stop the timer
    statistics(runtime,[StopAstar|_]),
    TimeAstar is StopAstar - StartAstar,
    write("A* algorithm search time: "),
    write(TimeAstar),
    writeln("ms\n\n"),

    % clear the stored shortest path to home
    retractall(homePath(_)).


% Initialize Actor
initActor:-
    assert(coordinates(actor, [1, 1])).

% Initialize Covid(s)
initCovid:-
    format("Please, enter the number of Covids: "),
    read(NCovids),
    generateCovidSourceCoords(NCovids, 0).

% Initialize Home
initHome:-
    generateHomeCoords(0).

% Initialize Doctor(s)
initDoctor:-
    format("Please, enter the number of doctors: "),
    read(NDoctors),
    generateDoctorCoords(NDoctors, 0).

% Initialize Mask(s)
initMask:-
    format("Please, enter the number of masks: "),
    read(NMasks),
    generateMaskCoords(NMasks, 0).


% Random map generation
generateMap:-

    % Clear previous facts
    retractall(numCovids(_)),
    retractall(latticeSize(_)),
    retractall(coordinates(_,_)),
    retractall(homePath(_)),

    % Reading the size of the lattice (map)
    format("Please, enter the size of the NxN lattice: "),
    read(N),
    assert(latticeSize(N)),

    initActor,               % initialize Actor
    initCovid,               % initalize Covid
    initHome,                % initalize Home
    initDoctor,              % initalize Doctor
    initMask,                % initalize Mask

    nl, nl,
    writeln("Generated map (lattice):"),
    printLattice(N, N),
    nl, nl.


% Generate randomly the map and run the A* algorithm
runAstar:-
    generateMap,             % generate randomly the map
    aStarSearch.             % launch the A* search


% Generate randomly the map and run the Backtracking algorithm
runBacktracking:-
    generateMap,             % generate randomly the map
    backtrackingSearch.      % launch the backtracking search


% Generate randomly the map and run both algorithms
runBoth:-
    generateMap,             % generate randomly the map
    backtrackingSearch,      % launch the backtracking search
    aStarSearch.             % launch the A* search
