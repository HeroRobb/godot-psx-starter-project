extends Node

## This node is mostly used to contain enums used in conjunction with the rest
## of the autoload singletons from HR PSX.
##
## You should edit this script in your game to have the appropriate ACTORS,
## MUSIC, AMBIENCES, SFX, and LEVELS.


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
