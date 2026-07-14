# Examples Build Audit

Date: 2026-07-13

The `Examples` directory was flattened so that every immediate child directory contains exactly one AstoriaIDE `.vfp` project. Former category directories containing multiple projects were split into individual project directories. Shared supporting files were copied into each affected project directory where necessary.

All 51 example projects were compiled with the bundled 64-bit FreeBASIC compiler using the repository's GCC, multithreading, exception-checking, WinAPI, framework include, and framework library settings. Temporary compile-check binaries were removed after each successful build. Projects that did not compile were removed as requested.

## Retained projects

The following 30 projects compiled successfully:

- Add-In
- amcap
- Calculator
- CamGrab
- Com_VBA
- DeviceExplorer
- DynamicControl
- FileBrowser
- FiveInARow
- Graphics
- Hash
- IFileDialog
- Maze
- MDIForm
- MediaPlayer
- MultipleDisplay
- NTPClient
- PipeProcess
- playcap
- PlayerGrab
- Radar
- SapiRecognizer
- SapiTTS
- Sudoku
- sysenum
- TCamGrab
- Test_WellCOM
- TPlayerGrab
- USBView
- WLan

## Removed projects

The following 21 projects failed compilation and were removed:

- AiAgentRich
- AiAgentText
- bassaudio
- capturesound
- Download
- enumdevices
- FileSearch
- FileSync
- fullduplexfilter
- livefx
- MDINotepad
- MDIScintilla
- MDIScintillaControl
- MediaFoundation
- netradio
- SerialPort
- soundfx
- wavegenerator
- Web Page
- WellCOM
- WMI

Final verification found 30 immediate child directories under `Examples`, exactly one `.vfp` project in every directory, no nested `.vfp` projects, and no temporary `__compile_check__` artifacts.
