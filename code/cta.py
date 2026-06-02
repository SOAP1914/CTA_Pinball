"""Coming to America — shared game constants and data tables.

Following the MPF philosophy of keeping custom Python minimal, this module
holds only data (lists, dicts, scoring tables) that multiple modes or configs
reference. Gameplay logic stays in YAML.
"""

# --- Story path sub-mode ordering ---
# These lists define the canonical chapter order for each story path.
# Used as the single source of truth for progression.

QUEENS_SUBMODES = [
    "arriving_in_queens",
    "searching_for_a_queen",
    "the_barbershop",
    "miss_black_awareness",
    "working_at_mcdowells",
    "basketball_date",
    "thwarting_a_robbery",
    "would_you_like_to_dance",
    "pleading_your_case",
    "king_collects_son",
]

ZAMUNDA_SUBMODES = [
    "the_prince_awakens",
    "bubble_bath",
    "sparring_with_semmi",
    "the_royal_wedding",
    "a_royal_celebration",
]

# --- Scoring tables ---
# Base score values for common shots (referenced by modes for consistency).

SHOT_SCORES = {
    "inlane": 5_000,
    "orbit": 15_000,
    "ramp": 25_000,
    "spinner": 1_000,
    "pop": 3_000,
    "sling": 500,
    "vuk": 10_000,
    "drop_single": 5_000,
    "drop_mcdowell": 7_500,
}

# --- Working at McDowell's mode ---
# Sequential drop sequence: hit drops 1->2->3 in order. Each correct hit
# escalates. Completing the sequence awards the bonus.
MCDOWELLS_SEQUENCE_SCORES = [25_000, 50_000, 100_000]  # drop 1, 2, 3
MCDOWELLS_COMPLETE_BONUS = 250_000
