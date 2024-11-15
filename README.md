## Intro
- Name: Jacob Lorenzo

- Date: 11/14/2024

- Instructor: Dr. Hutchinson

- Class: COS 470/570

- Assignment: Homework 4 

## Program Details
#### Requirements
- SWI Prolog

#### HOWTO: Load
- Open up swipl
- load the prolog file with `[main].`
#### HOWTO: Run
- Once you have swipl open and the prolog file loaded, you can type `play().`
    - What this will do is save the current state, then it will start discovering paths to the various objectives and using the created predicates to maneuver those paths. It will also call the `startGame().` predicate that will create said saved state.
- Once you have used the `play().` predicate, you are able to use the `win().` predicate. 
    - You use this predicate to check if the prior predicate was successful. Additionally, the `win().` predicate will automatically call the `resetGame().` predicate.