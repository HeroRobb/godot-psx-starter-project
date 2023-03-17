class_name Glbl
extends Node

## This node, along with [SignalMngr], is intended to be used as an autoload
## singleton to facilitate communication between the rest of the nodes in HR
## PSX, it does this by containing enums.
##
## You should edit this script in your game to have the appropriate ACTORS,
## MUSIC, AMBIENCES, SFX, and LEVELS. Don't extend this into another script,
## because you cannot change the enums once they've been declared. I had to use
## a shortened class name because the class name cannot be the same as it's
## autoload name.


enum ACTORS {
	
}

enum  LEVELS {
	MAIN_MENU,
	INTRO,
	TEST,
}

enum SOUND_TYPES {
	MUSIC,
	AMBIENCE,
	SFX,
}

enum MUSIC {
	NONE,
	ITS_SAX,
	ITS_SAX_8_BIT,
	CARNELIA,
	SHIFTING_LOSS,
}

enum AMBIENCES {
	NONE,
	FOGHORN,
	LOST,
}

enum SFX {
	BLIP,
	NJB,
}

enum WINDOW_MODES {
	FULLSCREEN,
	BORDERLESS,
	WINDOWED_MED,
	WINDOWED_SMALL,
}

enum SHADERS {
	BLUR,
	BLACK_AND_WHITE,
	BETTERCC,
	COLOR_PRECISION,
	CRT,
	GLITCH,
	GLITCH_SIMPLE,
	GRAIN,
	GRAIN_SIMPLE,
	JPEG_COMPRESSION,
	LCD,
	LENS_DISTORTION,
	NTSC,
	NTSC_BASIC,
	PSX_DITHER,
	SHARPNESS,
	VHS,
	VHS_PAUSE,
}

const GAME_STATE_SAVER_GROUP = "game_state_saver"
