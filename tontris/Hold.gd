extends RichTextLabel

var m_held: Tetromino.Kind = Tetromino.Kind.NONE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.set_text("EMPTY")

var label_lookup: Array[String] = [
	"EMPTY",
	"[color=#00CDCD]I[/color]",
	"[color=#9A00CD]T[/color]",
	"[color=#CDCD00]O[/color]",
	"[color=#CD0000]Z[/color]",
	"[color=#00CD00]S[/color]",
	"[color=#CD6600]J[/color]",
	"[color=#0000CD]L[/color]"
]

func swap(piece: Tetromino.Kind) -> Tetromino.Kind:
	var ret := m_held
	m_held = piece
	self.set_text("[center]"+label_lookup[m_held]+"[/center]")
	return ret

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
