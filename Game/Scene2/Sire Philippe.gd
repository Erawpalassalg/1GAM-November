extends "res://NPC.gd"

func init():
	set_name(tr("SIR PHILIPPE"))
	unique_name = "Sire Philippe"
	base_looking_direction = "down"

func enter():
	fade_in()