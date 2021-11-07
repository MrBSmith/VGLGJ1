extends EventsBase

# warnings-disable

signal collect_kunai()
signal spawn_kunai(pos, dir)
signal nb_kunai_changed(nb_kunai)

signal hp_changed(hp)

signal enemy_spawn_query(enemy, position)
signal enemy_killed()

signal score_changed(score)

signal wave_started(wave_id)

signal new_difficulty(difficulty)
signal difficulty_finished()

signal spawn_heart(pos)
