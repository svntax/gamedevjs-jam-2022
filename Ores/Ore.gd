extends Area2D

export (Globals.ORE_TYPE) var ore_type = Globals.ORE_TYPE.Gold

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body.has_method("collect"):
		body.collect(self)
		queue_free()
