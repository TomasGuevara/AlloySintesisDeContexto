// ============================================
// 1. CHARACTER
// ============================================

abstract sig Character {
    var condition: one Attributes,
    inventory: set Item,
    var location: one Location
}

one sig Saul, Amanda, Bruce, Player extends Character {}


// ============================================
// 2. ITEMS
// ============================================

abstract sig Item {}

one sig Cigarettes, VacuumBottle, Mate,
        Guitar, Book extends Item {}


// ============================================
// 3. ATTRIBUTES
// ============================================

abstract sig Attributes {}

one sig Alive, Dead extends Attributes {}


// ============================================
// 4. LOCATION
// ============================================

abstract sig Location {}

one sig Junin, PlazaSarmiento extends Location {}

// ============================================
// 5. MOOD
// ============================================

abstract sig Mood {
    var affected: set Character
}

one sig TensionMinimum, TensionMedium,
        MaxTension extends Mood {}

// ============================================
// 6. MOOD TRANSITIONS
// ============================================

// Set the active mood
pred setMood[m: Mood] {

    m.affected' = { c: Character | c.condition' = Alive }

    all x: Mood - m |
        no x.affected'
}


// Increase tension
pred raiseMood {

    // Minimum -> Medium
    (TensionMinimum.affected = { c: Character | c.condition = Alive }
        and setMood[TensionMedium])

    or

    // Medium -> Maximum
    (TensionMedium.affected = { c: Character | c.condition = Alive }
        and setMood[MaxTension])

    or

    // Maximum remains Maximum
    (MaxTension.affected = { c: Character | c.condition = Alive }
        and setMood[MaxTension])
}


// Decrease tension
pred lowerMood {

    // Maximum -> Medium
    (MaxTension.affected = { c: Character | c.condition = Alive }
        and setMood[TensionMedium])

    or

    // Medium -> Minimum
    (TensionMedium.affected = { c: Character | c.condition = Alive }
        and setMood[TensionMinimum])

    or

    // Minimum remains Minimum
    (TensionMinimum.affected = { c: Character | c.condition = Alive }
        and setMood[TensionMinimum])
}


// ============================================
// 7. ACTIONS
// ============================================

abstract sig Action {
    var participants: set Character
}

one sig KillSaul, KillBruce,
        RunAwayAmanda extends Action {}


// ============================================
// 8. INITIAL STATE
// ============================================

pred init {

    Saul.condition = Alive
    Saul.inventory = Cigarettes
    Saul.location = Junin

    Amanda.condition = Alive
    Amanda.inventory = VacuumBottle + Mate
    Amanda.location = Junin

    Bruce.condition = Alive
    Bruce.inventory = Guitar
    Bruce.location = Junin

    Player.condition = Alive
    Player.inventory = Book
    Player.location = Junin

     // Initial mood
    TensionMinimum.affected = { c: Character | c.condition = Alive }
    no TensionMedium.affected
    no MaxTension.affected

    no Action.participants
}


// ============================================
// 9. ACTION: KILL SAUL
// ============================================

pred killSaul {

    Saul.condition = Alive

    Saul.condition' = Dead

    all c: Character - Saul |
        c.condition' = c.condition

    all c: Character |
        c.location' = c.location

    KillSaul.participants' = Saul

    all a: Action - KillSaul |
        no a.participants'

    raiseMood
}


// ============================================
// 10. ACTION: KILL BRUCE
// ============================================

pred killBruce {

    Bruce.condition = Alive

    Bruce.condition' = Dead

    all c: Character - Bruce |
        c.condition' = c.condition

    all c: Character |
        c.location' = c.location

    KillBruce.participants' = Bruce

    all a: Action - KillBruce |
        no a.participants'

    raiseMood
}


// ============================================
// 11. ACTION: RUN AWAY WITH AMANDA
// ============================================

pred runAwayAmanda {

    Saul.condition = Dead
    Bruce.condition = Dead

    Amanda.location' = PlazaSarmiento
    Player.location' = PlazaSarmiento

    all c: Character - Amanda - Player |
        c.location' = c.location

    all c: Character |
        c.condition' = c.condition

    RunAwayAmanda.participants' = Amanda + Player

    all a: Action - RunAwayAmanda |
        no a.participants'

    lowerMood
}


// ============================================
// 10. STUTTER
// ============================================

pred stutter {

    all c: Character |
        c.condition' = c.condition

    all c: Character |
        c.location' = c.location

    all m: Mood |
        m.affected' = m.affected

    all a: Action |
        a.participants' = a.participants
}


// ============================================
// 12. TRANSITION FUNCTION
// ============================================

pred step {

    killSaul
    or killBruce
    or runAwayAmanda
    or stutter
}


// ============================================
// 13. TEMPORAL EXECUTION
// ============================================

pred trace {

    init

    always step
}


// ============================================
// 14. MODEL EXPLORATION
// ============================================

// Initial world

run init for 5 but 1..1 steps


// Saul dies

run {
    trace
    eventually (Saul.condition = Dead)
} for 5 but 5..8 steps


// Amanda escapes

run {
    trace
    eventually (Amanda.location = PlazaSarmiento)
} for 5 but 5..8 steps


// Both characters die and Amanda escapes

run {
    trace
    eventually (Saul.condition = Dead)
    and eventually (Bruce.condition = Dead)
    and eventually (Amanda.location = PlazaSarmiento)
} for 5 but 8..10 steps
