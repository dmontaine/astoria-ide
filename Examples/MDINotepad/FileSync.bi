#pragma once
' FileAct - file handling
' Copyright (c) 2024 CM.Wang
' Freeware. Use at your own risk.

#include once "FileAct.bi"

'Folder and file action enumeration
Enum PathFileActEnum
	Act_FileCopy = 1
	Act_FileOverwrite
	Act_FileDelete
	Act_FileDeleteBNotInA
	Act_PathCreate
	Act_PathRemove
	Act_PathRemoveBNotInA
End Enum

'Count enumeration
Enum PathFileCountEnum
	Count_FileCopy = 1
	Count_FileOverwrite
	Count_FileSkip
	Count_FileDelete
	Count_PathCreate
	Count_PathRemove
	Count_FileDeleteBNotInA
	Count_PathRemoveBNotInA
	Count_File
	Count_Path
	Count_Error
End Enum

'FilesSync file-operation enumeration
Enum FilesSyncMode
	FSM_PathSync = 1
	FSM_PathRemove
	FSM_PathCreate
End Enum

Type FilesSync
Private:
	'Private variables

	Const mFileInc As Integer = &hfffff 'File increment

	mOwner As Any Ptr = 0

	mPathA As WString Ptr = NULL
	mPathB As WString Ptr = NULL

	mDone As Long                       'Main thread completed
	mCancel As Long                     'Main thread cancelled

	mThreadMode As FilesSyncMode        'Main mode: sync, create, remove

	mPercentThread As Any Ptr = NULL    'Thread ID for computing the progress percentage

	mTiMr As TimeMeter 'Timer
	mSyncTarget As WString Ptr = NULL   'Sync target
	mSyncSource As WString Ptr = NULL   'Sync source
	
	mListFile(Any) As WString Ptr
	mListFileCount As LongInt
	mListPath(Any) As WString Ptr
	mListPathCount As LongInt

	'Records
	mErrorMessage(Any) As WString Ptr
	mErrorMessageCount As LongInt
	mFileCopy(Any) As WString Ptr
	mFileCopyCount As LongInt
	mFileCopySize As LongInt
	mFileDelete(Any) As WString Ptr
	mFileDeleteBNotInA(Any) As WString Ptr
	mFileDeleteBNotInACount As LongInt
	mFileDeleteBNotInASize As LongInt
	mFileDeleteCount As LongInt
	mFileDeleteSize As LongInt
	mFileOverwrite(Any) As WString Ptr
	mFileOverwriteCount As LongInt
	mFileOverwriteSize As LongInt
	mFileSkip(Any) As WString Ptr
	mFileSkipCount As LongInt
	mFileSkipSize As LongInt
	mPathCreate(Any) As WString Ptr
	mPathCreateCount As LongInt
	mPathRemove(Any) As WString Ptr
	mPathRemoveBNotInA(Any) As WString Ptr
	mPathRemoveBNotInACount As LongInt
	mPathRemoveCount As LongInt
	
	'Completion progress
	mPercentReady As Long               'Ready
	mPercentCount As LongInt            'Total count to complete
	mPercentStep As LongInt             'Count completed so far
	mPercentPath As WString Ptr = NULL  'Progress directory

	'Completion steps
	mStepDoing As Long                  'Step in progress
	mStepCount As Long = -1             'Total steps
	mStepMessage(Any) As WString Ptr
	mStepTimeAdd As Double = -1
	mStepTime(Any) As Double
	
	mTotalCopySize As LongInt
	mTotalDeleteCount As LongInt
	mCopyTime As Double
	mDeleteTime As Double
	
Public:
	mSyncThread As Any Ptr = NULL       'Main thread ID

	'Settings
	mCompareData As Long                'Comparison data used to decide whether a duplicate file is overwritten
	mCompareMode As Long                'Comparison mode used to decide whether a duplicate file is overwritten
	mCopyEmptyPath As Long              'Copy empty directories
	mDuplicat As Long                   'Delete B files that don't exist in A
	mLogFile As WString Ptr             'Log file name
	mLogFileNum As Long                 'Log file number
	mLogMode As Long                    'Log mode: 0 = none, 1 = memory, 2 = file
	mSyncMode As Long                   'Directory mode: False = one-way copy, True = two-way sync

Private:

	'Private functions
	Declare Function ActPath(aType As PathFileActEnum, SourceStr As WString Ptr) As Long
	Declare Function LogStr(Index As Long) ByRef As WString
	Declare Static Function PercentThread(ByVal pParam As Any Ptr) As Any Ptr
	Declare Static Function SyncThread(ByVal pParam As Any Ptr) As Any Ptr
	Declare Sub ActFile(aType As PathFileActEnum, SourceStr As WString Ptr, TargetStr As WString Ptr, wfd As WIN32_FIND_DATA Ptr)
	Declare Sub CountInc(CntIdx As PathFileCountEnum, IncMsg As WString = "")
	Declare Sub DeleteBNotInA(PathStr As WString)
	Declare Sub ErrorInc(ErrorTitle As WString, ErrorMsg As WString Ptr)
	Declare Sub FileCopyAct(PathStr As WString Ptr, wfd As WIN32_FIND_DATA Ptr)
	Declare Sub ListFile()
	Declare Sub ListFileSub(PathStr As WString)
	Declare Sub LogFile(LogMsg As WString)
	Declare Sub LogFileClose()
	Declare Sub LogFileOpen()
	Declare Sub PathCreate(PathStr As WString Ptr)
	Declare Sub PathRemove(PathStr As WString Ptr)
	Declare Sub PathRemoveSub(PathStr As WString)
	Declare Sub PathSync()
	Declare Sub PathSyncSub(PathStr As WString)
	Declare Sub PercentDoing(PathStr As WString Ptr)
	Declare Sub PercentSub(PathStr As WString)
	Declare Sub StepInc(StepMsg As WString)
	Declare Sub StepInit(StepCount As LongInt, StepMsg As WString)
	Declare Sub SyncDoing()
	Declare Sub SyncInit()
	
Public:
	'Constructor and destructor
	Declare Constructor
	Declare Destructor

	'Public functions - class events
	OnDone As Sub(Owner As Any Ptr) 'Enumeration-completed event

	'Public functions - class methods
	Declare Function Create(Owner As Any Ptr, PathStr As WString) As Integer
	Declare Function Remove(Owner As Any Ptr, PathStr As WString) As Integer
	Declare Function ReportData(x As Long, y As Long) ByRef As WString
	Declare Function Sync(Owner As Any Ptr, SourceStr As WString, TargetStr As WString) As Integer

	'Public functions - class properties
	Declare Property Cancel() As Integer
	Declare Property Cancel(ByVal nVal As Integer)
	Declare Property DetialInfo() ByRef As WString
	Declare Property Done() As Integer
	Declare Property Done(ByVal nVal As Integer)
	Declare Property ErrorCount() As Integer
	Declare Property Information() ByRef As WString
	Declare Property PercentStep() As Double
	Declare Property PercentTotal() As Double
	Declare Property Report(Index As Integer) ByRef As WString
	Declare Property Setting() ByRef As WString
	Declare Property Speed() ByRef As WString
	Declare Property Summary() ByRef As WString
	Declare Property TimePass() As Double
End Type

#ifndef __USE_MAKE__
	#include once "FileSync.bas"
#endif
