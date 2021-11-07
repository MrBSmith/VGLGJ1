extends EventsBase

# warnings-disable

signal collect_kunai()
signal nb_kunai_changed(nb_kunai)

signal spawn_projectile(projectile_type, pos, dir)

signal hp_changed(hp)

signal enemy_spawn_query(enemy, position)
signal enemy_killed(points)

signal score_changed(score)

signal wave_started(wave_id)

signal new_difficulty(difficulty)
signal difficulty_finished()

signal spawn_heart(pos)
