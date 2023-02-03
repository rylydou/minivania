extends Node

var climb := false
var swim := false
var double_jump := false
var dash := false
var explode := false

func store_state(ds: DataStore) -> void:
	ds.push_prefix('upgrades')
	
	ds.store('climb', climb)
	ds.store('swim', swim)
	ds.store('double_jump', double_jump)
	ds.store('dash', dash)
	ds.store('explode', explode)
	
	ds.pop_prefix()

func fetch_state(ds: DataStore) -> void:
	ds.push_prefix('upgrades')
	
	climb = ds.fetch('climb', false)
	swim = ds.fetch('swim', false)
	double_jump = ds.fetch('double_jump', false)
	dash = ds.fetch('dash', false)
	explode = ds.fetch('explode', false)
	
	ds.pop_prefix()

func set_upgrade(upgrade: String, state: bool) -> void:
	set(upgrade, state)
