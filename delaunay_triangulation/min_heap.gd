class_name MinHeap extends RefCounted

var children_limit := 2

# comparator function which returns > 0 (positive) if A is greater; < 0 otherwise; == 0 if same.
var comparator: Callable 

var object_to_children: Dictionary[Variant, Array] = {}
var object_to_load: Dictionary[Variant, int] = {}
var root: Variant

func _init(_comparator: Callable):
	comparator = _comparator

func insert(object: Variant) -> void:
	if object_to_children.has(object):
		return
	
	object_to_children[object] = []
	object_to_load[object] = 0
	
	if !root:
		root = object
		return
	
	if comparator.call(root, object) > 0:
		#object needs to be new root
		_add_child(object, root)
		root = object
	else:
		_add_child(root, object)

func is_empty() -> bool:
	return !root

func peek() -> Variant:
	return root

func pop() -> Variant:
	var result =  root
	
	var smallest_child: Variant
	for child in _get_children(root):
		if !smallest_child || comparator.call(smallest_child, child) > 0:
			smallest_child = child
			
	for child in _get_children(root):
		if child != smallest_child:
			_add_child(smallest_child, child)
	
	object_to_children.erase(root)
	object_to_load.erase(root)
	
	root = smallest_child
	return result

func _add_child(parent: Variant, candidate: Variant):
	if _get_children(parent).size() < children_limit:
		if !object_to_children.has(parent):
			object_to_children[parent] = []
			
		if !object_to_load.has(parent):
			object_to_load[parent] = 0
			
		object_to_children.get(parent).push_back(candidate)
		object_to_load[parent] += _get_load(candidate) + 1
		return
	
	var child_with_low_load: Variant
	var lowest_load: int
	for child in _get_children(parent):
		if !child_with_low_load || _get_load(child) < lowest_load:
			lowest_load = _get_load(child)
			child_with_low_load = child
			
	if comparator.call(candidate, child_with_low_load) <= 0:
		_add_child(candidate, child_with_low_load)
		_remove_child(parent, child_with_low_load)
		object_to_children.get(parent).push_back(candidate)
		object_to_load[parent] += _get_load(candidate) + 1
	else:
		_add_child(child_with_low_load, candidate)
		object_to_load[parent] += _get_load(candidate) + 1
	
func _get_load(node: Variant):
	if !object_to_load.has(node):
		object_to_load[node] = 0

	return object_to_load.get(node)
	
func _get_children(node: Variant) -> Array:
	if !object_to_children.has(node):
		return []
	return object_to_children.get(node)
	
func _remove_child(parent: Variant, child: Variant) -> void:
	if !object_to_children.has(parent):
		return
	
	var children_array := (object_to_children.get(parent) as Array)
	children_array.remove_at(children_array.find(child))
	
	object_to_load[parent] -= _get_load(child)
