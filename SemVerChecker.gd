extends Node

var semver_regex = RegEx.new()

# From https://regex101.com/r/Ly7O1x/3/ modified to be a bit more laxing in the patch part
var pattern = "^(?P<major>0|[1-9]\\d*)\\.(?P<minor>0|[1-9]\\d*)(?:\\.(?P<patch>0|[1-9]\\d*))?(?:-(?P<prerelease>(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$"
func _init():
	semver_regex.compile(pattern)

func check(value):
	return semver_regex.search(value) != null

func compare(to_compare, correct):
	var to_compare_match = semver_regex.search(to_compare)
	if to_compare_match == null:
		return false

	var correct_match = semver_regex.search(correct)

	if correct_match == null:
		printerr("Correct SemVer is wrong!")
		return false

	var correct_dict = _get_dict(correct_match)
	var to_compare_dict = _get_dict(to_compare_match)

	print("Checking semver\n\t%s\n\t%s" % [correct_dict, to_compare_dict])

	if correct_dict.hash() == to_compare_dict.hash():
		return true

	return false

func _get_dict(r_match):
	var result = {
		"major": "0",
		"minor": "0",
		"patch": "0",
		"prerelease": "",
		"buildmetadata": ""
	}
	if r_match.names.has("major"):
		result["major"] = r_match.strings[r_match.names["major"]]

	if r_match.names.has("minor"):
		result["minor"] = r_match.strings[r_match.names["minor"]]

	if r_match.names.has("patch"):
		result["patch"] = r_match.strings[r_match.names["patch"]]

	if r_match.names.has("prerelease"):
		result["prerelease"] = r_match.strings[r_match.names["prerelease"]]

	if r_match.names.has("buildmetadata"):
		result["buildmetadata"] = r_match.strings[r_match.names["buildmetadata"]]

	return result
