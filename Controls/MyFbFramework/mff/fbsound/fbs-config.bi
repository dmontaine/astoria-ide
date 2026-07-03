	#define __FBS_CONFIG_BI__
	
	'' NOTE: If these options are changed, then
	'' the libraries must be built again from sources.
	'' These options disable features of both the
	'' static libraries and shared libraries.
	''
	'' Otherwise, any options defined here can be used
	'' in the user program to detect if certain features
	'' will be unavilable at either compile time or
	'' run time depending on the method of library use
	'' (either static or shared respectively).
		#define FBSOUND_USE_STATIC
		'#include once "plug-static.bi"
		'#include once "plug-static.bas"
		'#ifdef __FB_OUT_DLL__
		'	#undef __FB_OUT_DLL__
		'	#define __FB_OUT_DLL__ 0
		'#endif
	
	' disable some features and rebuild the lib
	'#define NO_ASM
	'#define NO_MP3        ' no MP3 sound and stream
	#define NO_OGG        ' no Vorbis sound
	'#define NO_MOD        ' no tracker modules
	#define NO_SID        ' no SID stream
	'#define NO_CALLBACK   ' no load or buffer callbacks
	'#define NO_DSP        ' no EQS Filter
	'#define NO_PITCHSHIFT ' no realtime pitch shifter
	'#define NO_3D
	
	'#define DEBUG
	
		' windows
		'#define NO_PLUG_MM
		'#define NO_PLUG_DS
	' linux
	
	
		#define dprint(msg) :
	

