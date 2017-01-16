# Vegarium
Solution to challenge https://zestedesavoir.com/forums/sujet/447/javaquarium/

This program simulates the evolution of a population of animals and vegetals interacting with each other for a given period of time.

## How to run the program

ruby vegarium.rb \<all species file\> \<living beings file\> \<seed\> \<turns count\>

\<all species file\> is the input file containing all the species with their respective attributes (sample file all_species.txt is provided in solution).

\<living beings file\> is the input file containing the initial population of animals and vegetals with their respective attributes (sample file living_beings.txt is provided in solution).

\<seed\> is a number used to initialize the pseudo-random generator.

\<turns count\> is the period of time for which the simulation will run (the turn is the unit of time).

## Program output

The program will output the significant events that occurred at each turn, and the state of the population at the end of each turn.

The output of each turn can be reused as the living beings input for another simulation.
