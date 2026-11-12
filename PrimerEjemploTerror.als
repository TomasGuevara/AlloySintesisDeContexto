// ============================================
// 1. CHARACTER
// ============================================

abstract sig Character {}

one sig Saul, Amanda, Bruce, Player extends Character {}


// ============================================
// 2. ITEMS
// ============================================

abstract sig Item {}

one sig Cigarettes, VacuumBottle, Mate,
        Guitar, Book extends Item {}


// ============================================
// 3. MONEY
// ============================================

abstract sig Money {}

one sig Money10, Money20, Money50, Money75 extends Money {}


// ============================================
// 4. PLACES
// ============================================

abstract sig Place {}

one sig Junin, PlazaSarmiento extends Place {}


// ============================================
// 5. TENSION LEVELS
// ============================================

abstract sig Tension {}

one sig T0, T10, T20, T30, T40, T50,
        T60, T70, T80, T90, T100 extends Tension {}


// ============================================
// 6. TENSION OPERATIONS
// ============================================

fun Plus20: Tension -> Tension {
    T0->T20 + T10->T30 + T20->T40 +
    T30->T50 + T40->T60 + T50->T70 +
    T60->T80 + T70->T90 + T80->T100
}

fun Plus10: Tension -> Tension {
    T0->T10 + T10->T20 + T20->T30 +
    T30->T40 + T40->T50 + T50->T60 +
    T60->T70 + T70->T80 + T80->T90 +
    T90->T100
}

fun Minus10: Tension -> Tension {
    T10->T0 + T20->T10 + T30->T20 +
    T40->T30 + T50->T40 + T60->T50 +
    T70->T60 + T80->T70 + T90->T80 +
    T100->T90
}

fun Minus30: Tension -> Tension {
    T30->T0 + T40->T10 + T50->T20 +
    T60->T30 + T70->T40 + T80->T50 +
    T90->T60 + T100->T70
}


// ============================================
// 7. ACTIONS
// ============================================

abstract sig Action {}

one sig KillSaul, KillBruce, CryFor,
        RunAwayAmanda, RaiseTension extends Action {}


// ============================================
// 8. NARRATIVE WORLD
// ============================================

one sig World {
    var alive: set Character,
    pockets: Character -> Item,
    money: Character -> one Money,
    var tension: one Tension,
    var location: one Place,
    var escaped: set Character,
    var performed: lone Action
}


// ============================================
// 9. INITIAL STATE
// ============================================

pred init {

    World.alive = Character

    World.pockets =
        (Saul -> Cigarettes) +
        (Amanda -> VacuumBottle) +
        (Amanda -> Mate) +
        (Bruce -> Guitar) +
        (Player -> Book)

    World.money =
        (Saul -> Money50) +
        (Amanda -> Money75) +
        (Bruce -> Money10) +
        (Player -> Money20)

    World.tension = T20
    World.location = Junin
    World.escaped = none

    no World.performed
}


// ============================================
// 10. ACTION: KILL SAUL
// ============================================

pred killSaul {

    Saul in World.alive

    World.alive' = World.alive - Saul
    World.tension -> World.tension' in Plus20

    World.location' = World.location
    World.escaped' = World.escaped
    World.performed' = KillSaul
}


// ============================================
// 11. ACTION: KILL BRUCE
// ============================================

pred killBruce {

    Bruce in World.alive

    World.alive' = World.alive - Bruce
    World.tension -> World.tension' in Plus20

    World.location' = World.location
    World.escaped' = World.escaped
    World.performed' = KillBruce
}


// ============================================
// 12. ACTION: CRY FOR
// ============================================

pred cryFor {

    World.tension in T50 + T60 + T70 +
                     T80 + T90 + T100

    World.tension -> World.tension' in Minus10

    World.alive' = World.alive
    World.location' = World.location
    World.escaped' = World.escaped
    World.performed' = CryFor
}


// ============================================
// 13. ACTION: RUN AWAY WITH AMANDA
// ============================================

pred runAwayAmanda {

    Saul not in World.alive
    Bruce not in World.alive
    Amanda not in World.escaped

    World.tension -> World.tension' in Minus30

    World.alive' = World.alive
    World.escaped' = World.escaped + Amanda
    World.location' = PlazaSarmiento
    World.performed' = RunAwayAmanda
}


// ============================================
// 14. ACTION: RAISE TENSION
// ============================================

pred raiseTension {

    Saul not in World.alive
    or Bruce not in World.alive

    World.tension -> World.tension' in Plus10

    World.alive' = World.alive
    World.location' = World.location
    World.escaped' = World.escaped
    World.performed' = RaiseTension
}


// ============================================
// 15. STUTTER
// ============================================

pred stutter {

    World.alive' = World.alive
    World.tension' = World.tension
    World.location' = World.location
    World.escaped' = World.escaped
    World.performed' = none
}


// ============================================
// 16. TRANSITION FUNCTION
// ============================================

pred step {

    killSaul
    or killBruce
    or cryFor
    or runAwayAmanda
    or raiseTension
    or stutter
}


// ============================================
// 17. TEMPORAL EXECUTION
// ============================================

pred trace {

    init
    always step
}


// ============================================
// 18. MODEL EXPLORATION
// ============================================

// Display the initial world.

run init for 5 but 1..1 steps


// Find a trace where Saul dies.

run {
    trace
    eventually (World.performed = KillSaul)
} for 5 but 5..8 steps


// Find a trace where Amanda escapes.

run {
    trace
    eventually (Amanda in World.escaped)
} for 5 but 5..8 steps


// Find a trace where all five actions are executed.

run {
    trace
    eventually (World.performed = KillSaul)
    and eventually (World.performed = KillBruce)
    and eventually (World.performed = CryFor)
    and eventually (World.performed = RunAwayAmanda)
    and eventually (World.performed = RaiseTension)
} for 5 but 8..10 steps
