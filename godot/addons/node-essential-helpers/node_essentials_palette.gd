class_name NodeEssentialsPalette

const COLOR_INTERACT := Color(0.301961, 0.65098, 1)
const COLOR_COLLECTIBLE := Color(1, 0.894118, 0.470588)
const COLOR_HITBOX := Color(0.560784, 0.870588, 0.364706)
const COLOR_HURTBOX := Color(0.690196, 0.188235, 0.360784)
const COLOR_WALL_COLLISION := Color(0.690196, 0.188235, 0.360784)
const COLOR_AI_VISION := Color(0.690196, 0.188235, 0.360784)
const COLOR_DISABLED := Color(0.376471, 0.376471, 0.439216)

const DEBUG_DRAWING_GROUPS := [
	"Interactive",
	"Collectible",
	"HitBox",
	"HurtBox",
	"Collision",
	"AIVision",
]

const COLORS_MAP := {
	"Interactive": COLOR_INTERACT,
	"Collectible": COLOR_COLLECTIBLE,
	"HitBox": COLOR_HITBOX,
	"HurtBox": COLOR_HURTBOX,
	"Collision": COLOR_WALL_COLLISION,
	"AIVision": COLOR_AI_VISION,
}
