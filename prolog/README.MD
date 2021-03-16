Introduction to Artificial Intelligence, Innopolis University, Spring 2021
==
## Assignment 1

### 1. Requirements
This assignment was done using `swi-prolog 8.2.3-1`

### 2. Installation guides
* https://www.swi-prolog.org/build/
* Install on Arch-based Linux distros:
```console
$ sudo pacman -S swi-prolog
```

### 3. Test the program
* The user should enter the size of the map and the numbers of covids, doctors, and masks.
* Then the map is randomly generated. 
* The generated map, the outcome (Win / Lose), and in case of winning, the number of steps, the path to home, and the 
  map with the corresponding path for each algorithm are also printed in the console.

* Note that sometimes it might take quite a long time to find a path in case of difficult maps.


* If you want the program to generate randomly the map and run both algorithms on this map, execute the following 
  command:
```console
$ swipl -s solution.pl -g "runBoth, halt."
```

* If you want the program to generate randomly the map and run only Backtracking algorithm on this map, execute the 
  following command:
```console
$ swipl -s solution.pl -g "runBacktracking, halt."
```

* If you want the program to generate randomly the map and run only A* algorithm on this map, execute the following 
  command:
```console
$ swipl -s solution.pl -g "runAstar, halt."
```

