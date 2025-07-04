extends Node2D

var screen = DisplayServer.screen_get_size()

var ARRAY_SIZE = 0
var BAR_WIDTH = 0
const DELAY = 0

var array = []
var colors : Array = []

const COLOR_NORMAL = Color(0.4, 0.6, 0.8)
const COLOR_PIVOT = Color(1, 0.2, 0.2)
const COLOR_COMPARING = Color(1, 0.8, 0.2)
const COLOR_SORTED = Color(0.2, 1, 0.3)

func _ready() -> void:
	ARRAY_SIZE = $"../HSlider".value
	BAR_WIDTH = screen.x/ARRAY_SIZE
	randomize()
	_init_array()
	quicksort(0, array.size() - 1)
	$"..".counter=0

func _init_array() -> void:
	var abc = $"../Button/OptionButton".selected
	array.clear()
	colors.clear()
	for i in range(ARRAY_SIZE):
		#array.append(randf_range(5,500))
		#array.append(randi_range(10,500))
		#array.append(randi() % 300 + 20)
		match abc:
			0:
				array.append((i+1)*(((screen.y/4)*3)/ARRAY_SIZE))
			1:
				array.append((i+1)*(((screen.y/4)*3)/ARRAY_SIZE))
			2:
				array.append((ARRAY_SIZE-(i))*(((screen.y/4)*3)/ARRAY_SIZE))
			3:
				array.append(randi_range(10,((screen.y/4)*3)))
			4:
				# Exponential mapping, scaled to the desired height
				var exp_value = ((screen.y/4)*3) * pow(100, i / ARRAY_SIZE)
				# Normalize so that the last value is precisely (screen.y / 4) * 3
				exp_value = exp_value / pow(100, 1)
				array.append(exp_value)
		colors.append(COLOR_NORMAL)
	if abc == 0 or abc == 4:
		for i in range(array.size()):
			var rand_index = randi() % array.size()
			var temp = array[i]
			array[i] = array[rand_index]
			array[rand_index] = temp

# Main quicksort function with async/await
func quicksort(low: int, high: int) -> void:
	# We can't mark this 'async' because Godot doesn't support async functions directly
	# So use a helper coroutine wrapper
	_quicksort_coroutine(low, high)

func _quicksort_coroutine(low: int, high: int) -> void:
	if low < high:
		var p = await partition(low, high)
		_quicksort_coroutine(low, p - 1)
		_quicksort_coroutine(p + 1, high)
	else:
		if low >= 0 and high < array.size() and low<=colors.size()-1:
			colors[low] = COLOR_SORTED
			await get_tree().create_timer(DELAY).timeout

# Partition function is async, returns pivot index
func partition(low: int, high: int) -> int:
	colors[high] = COLOR_PIVOT
	await get_tree().create_timer(DELAY).timeout

	var pivot = array[high]
	var i = low - 1
	for j in range(low, high):
		colors[j] = COLOR_COMPARING
		await get_tree().create_timer(DELAY).timeout

		if array[j] < pivot:
			i += 1
			_swap(i, j)
			await get_tree().create_timer(DELAY).timeout
		colors[j] = COLOR_NORMAL
	_swap(i + 1, high)

	colors[high] = COLOR_NORMAL
	colors[i + 1] = COLOR_SORTED
	await get_tree().create_timer(DELAY).timeout
	return i + 1

func _swap(i: int, j: int) -> void:
	$"..".counter+=1
	var temp = array[i]
	array[i] = array[j]
	array[j] = temp

func _draw() -> void:
	for i in range(array.size()):
		draw_rect(Rect2(i * BAR_WIDTH, screen.y - array[i], BAR_WIDTH, array[i]), colors[i])

func _process(delta: float) -> void:
	queue_redraw()
