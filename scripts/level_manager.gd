extends Node

# Tracks the current level
var current_level = 0

# Settings for every level
var levels = [
	{
		"name": "The Awakening",
		"time_limit": 60,
		"echo_charges": 3
	},
	{
		"name": "The Lost Passage",
		"time_limit": 50,
		"echo_charges": 2
	},
	{
		"name": "The Forgotten Depths",
		"time_limit": 40,
		"echo_charges": 1
	}
]


# Get the settings of the current level
func get_current_level_data():
	return levels[current_level]


# Move to the next level
func advance_level():
	if current_level < levels.size() - 1:
		current_level += 1
		return true

	return false


# Check whether another level exists
func has_next_level():
	return current_level < levels.size() - 1
