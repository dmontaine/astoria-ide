'###############################################################################
'#  AgentPipe.bi                                                               #
'#  Agent MCP pipe -- Layer C of MCP_SERVER_PLAN.md: a named-pipe server      #
'#  inside astoria.exe that lets the astoria-mcp sidecar drive the IDE.       #
'#                                                                             #
'#  Threading contract (plan section 5): the pipe worker thread NEVER touches #
'#  windows or controls. It parses one request, publishes it in the single    #
'#  in-flight command slot, posts WM_APP_AGENTCMD to the main window, and     #
'#  waits for the UI thread to complete the slot. frmMain_Message routes the  #
'#  message to AgentPipe_ExecutePendingOnUi, which runs the command on the    #
'#  UI thread and signals completion.                                          #
'#                                                                             #
'#  Off by default (plan section 8): nothing listens unless StartAgentPipe    #
'#  is called (gated on the EnableAgentPipe INI setting until the Tools >     #
'#  Options toggle ships in MCP Task 6).                                       #
'###############################################################################
#pragma once

#include once "JsonLite.bi"

'' Posted by the pipe worker to marshal a command onto the UI thread.
Const WM_APP_AGENTCMD = WM_APP + 71

'' Start listening (creates the worker thread). hMainWnd is the window that
'' receives WM_APP_AGENTCMD -- pass frmMain.Handle after the form exists.
Declare Sub StartAgentPipe(hMainWnd As HWND)

'' Stop listening and join the worker thread. Safe to call when not started.
Declare Sub StopAgentPipe()

'' Whether the listener is currently up.
Declare Function AgentPipeActive() As Boolean

'' UI-thread half: executes the pending command slot. Call ONLY from the main
'' window's message handler on WM_APP_AGENTCMD.
Declare Sub AgentPipe_ExecutePendingOnUi()

#include once "AgentPipe.bas"
