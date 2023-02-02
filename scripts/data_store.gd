class_name DataStore extends RefCounted

enum Format {
	TextFile,
	BytesFile,
}

var _data := {}
var _cache := {}

func _init(path: String, format: Format):
	setup(path, format)

var _path: String
var _format: Format
func setup(path: String, format: Format):
	_path = path
	_format = format

var prefixes: PackedStringArray = []
var prefix_str := ''

func push_prefix(prefix: String):
	prefixes.append(prefix + '.')
	_update_prefix_str()

func pop_prefix():
	prefixes.remove_at(prefixes.size() - 1)
	_update_prefix_str()

func _update_prefix_str():
	prefix_str = ''
	prefix_str = prefix_str.join(prefixes)

func store(key: String, value: Variant) -> void:
	_data[prefix_str + key] = value

func store_rng(key: String, value: RandomNumberGenerator) -> void:
	store(key, [value.seed, value.state])

func fetch(key: String, default: Variant = null) -> Variant:
	key = prefix_str + key
	if _data.has(key):
		return _data[key]
	_data[key] = default
	return default

func fetch_int(key: String) -> int:
	return fetch(key) as int

func fetch_float(key: String) -> float:
	return fetch(key) as float

func fetch_str(key: String) -> String:
	return fetch(key) as String

func fetch_vec2(key: String) -> Vector2:
	return fetch(key) as Vector2
	
func fetch_rng(key: String, rng: RandomNumberGenerator, default_seed := randi()):
	var arr = fetch(key, [default_seed, 0])
	rng.seed = arr[0]
	rng.state = arr[1]

func save_to_cache() -> void:
	_cache = _data.duplicate()

func save_cache_to_disk() -> int:
	var file := FileAccess.open(_path, FileAccess.WRITE)
	if not is_instance_valid(file):
		return FileAccess.get_open_error()
	
	match _format:
		Format.TextFile:
			var string := var_to_str(_cache)
			file.store_string(string)
			if file.get_error() != OK: return file.get_error()
		Format.BytesFile:
			var bytes := var_to_bytes(_cache)
			file.store_buffer(bytes)
			if file.get_error() != OK: return file.get_error()
	
	file.flush()
	
	return OK

func load_from_cache() -> void:
	_data = _cache.duplicate()

func load_from_disk_to_cache() -> int:
	var file := FileAccess.open(_path, FileAccess.READ)
	if not is_instance_valid(file):
		return FileAccess.get_open_error()
	
	match _format:
		Format.TextFile:
			var string: String = file.get_as_text()
			if file.get_error() != OK: return file.get_error()
			_cache = str_to_var(string)
		Format.BytesFile:
			var bytes: PackedByteArray = file.get_buffer(file.get_length())
			if file.get_error() != OK: return file.get_error()
			_cache  = bytes_to_var(bytes)
	
	return OK
