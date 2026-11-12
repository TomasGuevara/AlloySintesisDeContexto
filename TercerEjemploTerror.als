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
// 3. ACTIONS
// ============================================

abstract sig Action {}

one sig KillSaul, KillBruce, CryFor,
        RunAwayAmanda, RaiseTension extends Action {}

// ============================================
// 3. ACTIONS
// ============================================

abstract sig Attributes {}

one sig Alive, Dead extends Attributes {}

// ============================================
// 3. LOCATION
// ============================================

abstract sig Location {}

one sig Junin, PlazaSarmiento extends Location {}


// ============================================
// 4. INITIAL STATE
// ============================================

pred init {

    Character.Saul -> Item.Cigarettes
    Saul -> Alive
    Saul -> Junin
    Amanda -> VacuumBottle
    Amanda -> Mateí
    Amanda -> Alive
    Amanda -> Junin
    Bruce -> Guitar
    Bruce -> Alive
    Bruce -> Junin
    Player -> Book
    Player -> Alive
    Player -> Junin
}


// ============================================
// 5. ACTION: KILL SAUL
// ============================================

pred killSaul {

    Saul - Alive
    Saul -> Dead
}


// ============================================
// 6. ACTION: KILL BRUCE
// ============================================

pred killBruce {

    Bruce - Alive
    Bruce -> Dead
}


// ============================================
// 8. ACTION: RUN AWAY WITH AMANDA
// ============================================

pred runAwayAmanda {

    Saul not in Alive
    Bruce not in Alive
    Amanda - Junin
    Amanda -> PlazaSarmiento
    Player - Junin
    Player -> PlazaSarmiento
}


// ============================================
// 16. TRANSITION FUNCTION
// ============================================

pred step {

    killSaul
    or killBruce
    or runAwayAmanda
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
    eventually (Saul = Dead)
} for 5 but 5..8 steps


// Find a trace where Amanda escapes.

run {
    trace
    eventually (Amanda = PlazaSarmiento)
} for 5 but 5..8 steps


// Find a trace where all five actions are executed.

run {
    trace
    eventually (Saul = Dead)
    and eventually (Bruce = Dead)
    and eventually (Amanda = PlazaSarmiento)
} for 5 but 8..10 steps
