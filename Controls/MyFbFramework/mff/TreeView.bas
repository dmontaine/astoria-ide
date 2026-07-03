'################################################################################
'#  TreeView.bi                                                                 #
'#  This file is part of MyFBFramework                                          #
'#  Authors: Xusinboy Bekchanov(2018-2019)  Liu XiaLin                          #
'################################################################################

#include once "TreeView.bi"
	#include once "win\commctrl.bi"
	#include once "win\tmschema.bi"

Namespace My.Sys.Forms
	Private Sub TreeNode.SelectItem
			If Parent AndAlso Parent->Handle Then TreeView_Select(Parent->Handle, Handle, TVGN_CARET)
	End Sub
	
	Private Sub TreeNode.Collapse
			If Parent AndAlso Parent->Handle Then TreeView_Expand(Parent->Handle, Handle, TVE_COLLAPSE)
	End Sub
	
	Private Sub TreeNode.Expand
			If Parent AndAlso Parent->Handle Then TreeView_Expand(Parent->Handle, Handle, TVE_EXPAND)
	End Sub
	
	Private Function TreeNode.IsExpanded As Boolean
			If Parent AndAlso Parent->Handle Then Return TreeView_GetItemState(Parent->Handle, Handle, TVIS_EXPANDED)
		Return False
	End Function
	
	Private Property TreeNode.Bold As Boolean
			If Parent AndAlso Parent->Handle Then
				FBold = TreeView_GetItemState(Parent->Handle, Handle, TVIS_BOLD)
				Return FBold
			End If
		Return FBold
	End Property
	
	Private Property TreeNode.Bold(Value As Boolean)
		FBold = Value
			If Parent AndAlso Parent->Handle Then
				TreeView_SetItemState(Parent->Handle, Handle, IIf(Value, TVIS_BOLD, 0), TVIS_BOLD)
			End If
	End Property
	
	Private Function TreeNode.Index As Integer
		If FParentNode <> 0 Then
			Return FParentNode->Nodes.IndexOf(@This)
		ElseIf Parent <> 0 Then
			Return Cast(TreeView Ptr, Parent)->Nodes.IndexOf(@This)
		Else
			Return -1
		End If
	End Function
	
	Private Function TreeNode.ToString ByRef As WString
		Return This.Name
	End Function
	
	Private Property TreeNode.Text ByRef As WString
		If FText > 0 Then Return *FText Else Return WStr("")
	End Property
	
	Private Property TreeNode.Text(ByRef Value As WString)
		WLet(FText, Value)
			If Parent AndAlso Parent->Handle Then
				Dim tvi As TVITEM
				'tvi.mask = TVIF_HANDLE
				'TreeView_GetItem(Parent->Handle, @tvi)
				tvi.mask = TVIF_TEXT
				tvi.hItem = Handle
				tvi.pszText = FText
				tvi.cchTextMax = Len(*FText) + 1
				TreeView_SetItem(Parent->Handle, @tvi)
			End If
	End Property
	
	Private Property TreeNode.IsUpdated As Boolean
		Return FIsUpdated
	End Property
	
	Private Property TreeNode.IsUpdated(Value As Boolean)
		FIsUpdated = Value
	End Property
	
	Private Property TreeNode.Checked As Boolean
		Return FChecked
	End Property
	
	Private Property TreeNode.Checked(Value As Boolean)
		FChecked = Value
	End Property
	
	Private Property TreeNode.Hint ByRef As WString
		If FHint > 0 Then Return *FHint Else Return WStr("")
	End Property
	
	Private Property TreeNode.Hint(ByRef Value As WString)
		WLet(FHint, Value)
	End Property
	
	Private Property TreeNode.Name ByRef As WString
		If FName > 0 Then Return *FName Else Return WStr("")
	End Property
	
	Private Property TreeNode.Name(ByRef Value As WString)
		WLet(FName, Value)
	End Property
	
	Private Property TreeNode.ImageIndex As Integer
		Return FImageIndex
	End Property
	
	Private Property TreeNode.ImageIndex(Value As Integer)
		FImageIndex = Value
			If Value <> FImageIndex Then
				If Parent AndAlso Parent->Handle Then
					Dim tvi As TVITEM
					tvi.mask = TVIF_IMAGE
					tvi.hItem = Handle
					tvi.iImage             = FImageIndex
					TreeView_SetItem(Parent->Handle, @tvi)
				End If
			End If
	End Property
	
	Private Property TreeNode.ImageKey ByRef As WString
		If FImageKey > 0 Then Return *FImageKey Else Return WStr("")
	End Property
	
	Private Property TreeNode.ImageKey(ByRef Value As WString)
		If FImageKey = 0 OrElse Value <> *FImageKey Then
			WLet(FImageKey, Value)
			If Parent AndAlso Parent->Handle AndAlso Cast(TreeView Ptr, Parent)->Images Then
				FImageIndex = Cast(TreeView Ptr, Parent)->Images->IndexOf(*FImageKey)
					Dim tvi As TVITEM
					tvi.mask = TVIF_IMAGE
					tvi.hItem = Handle
					tvi.iImage             = FImageIndex
					TreeView_SetItem(Parent->Handle, @tvi)
			End If
		End If
	End Property
	
	Private Property TreeNode.SelectedImageIndex As Integer
		Return FSelectedImageIndex
	End Property
	
	Private Property TreeNode.SelectedImageIndex(Value As Integer)
		FSelectedImageIndex = Value
		If Parent AndAlso Parent->Handle Then
				Dim tvi As TVITEM
				tvi.mask = TVIF_SELECTEDIMAGE
				tvi.hItem = Handle
				tvi.iSelectedImage   = FSelectedImageIndex
				TreeView_SetItem(Parent->Handle, @tvi)
		End If
	End Property
	
	Private Property TreeNode.ParentNode As TreeNode Ptr
		Return FParentNode
	End Property
	
	Private Property TreeNode.ParentNode(Value As TreeNode Ptr)
		FParentNode = Value
	End Property
	
	Private Property TreeNode.SelectedImageKey ByRef As WString
		If FSelectedImageKey > 0 Then Return *FSelectedImageKey Else Return WStr("")
	End Property
	
	Private Property TreeNode.SelectedImageKey(ByRef Value As WString)
		WLet(FSelectedImageKey, Value)
		If Parent AndAlso Parent->Handle AndAlso Cast(TreeView Ptr, Parent)->SelectedImages Then
			FSelectedImageIndex = Cast(TreeView Ptr, Parent)->SelectedImages->IndexOf(*FSelectedImageKey)
				Dim tvi As TVITEM
				tvi.mask = TVIF_SELECTEDIMAGE
				tvi.hItem = Handle
				tvi.iSelectedImage = FSelectedImageIndex
				TreeView_SetItem(Parent->Handle, @tvi)
		End If
	End Property
	
	Private Property TreeNode.Visible As Boolean
		Return FVisible
	End Property
	
	Private Sub TreeNode.AddItems(Node As TreeNode Ptr)
		Dim As Integer iIndex
		Dim As TreeNodeCollection Ptr pNodes
		If Node->ParentNode <> 0 Then
			pNodes = @(Node->ParentNode->Nodes)
		Else
			pNodes = @(QTreeView(Node->Parent).Nodes)
		End If
			For i As Integer = 0 To Node->Index - 1
				If pNodes->Item(i)->Visible Then
					iIndex = i + 1
				End If
			Next
			Dim As TVINSERTSTRUCT tvis
			If Node->Parent AndAlso Node->Parent->Handle AndAlso (Node->ParentNode = 0 OrElse Node->ParentNode->Handle <> 0) Then
				tvis.item.mask = TVIF_TEXT Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
				tvis.item.pszText              = Node->FText
				tvis.item.cchTextMax           = Len(WGet(Node->FText)) + 1
				tvis.item.iImage             = Node->FImageIndex
				tvis.item.iSelectedImage     = Node->FSelectedImageIndex
				tvis.hInsertAfter            = IIf(iIndex = 0, TVI_FIRST, IIf(iIndex < 0, TVI_LAST, pNodes->Item(iIndex - 1)->Handle))
				If Node->ParentNode Then tvis.hParent               = Node->ParentNode->Handle
				Node->Handle        = TreeView_InsertItem(Node->Parent->Handle, @tvis)
				For j As Integer = 0 To Node->Nodes.Count - 1
					If Node->Nodes.Item(j)->Visible Then AddItems Node->Nodes.Item(j)
				Next
			End If
	End Sub
	
	Private Property TreeNode.Visible(Value As Boolean)
		If Value <> FVisible Then
			FVisible = Value
			If Parent Then
				With This
					If Value Then
						AddItems @This
					Else
							If Parent AndAlso Parent->Handle Then
								TreeView_DeleteItem(Parent->Handle, This.Handle)
								This.Handle = 0
							End If
					End If
				End With
			End If
		End If
	End Property
	
	Private Operator TreeNode.Cast As Any Ptr
		Return @This
	End Operator
	
	Private Constructor TreeNode
		Nodes.Clear
		Nodes.Parent = Parent
		Nodes.ParentNode = @This
		Text = ""
		FVisible    = 1
		FImageIndex = -1
		FSelectedImageIndex = -1
	End Constructor
	
	Private Function TreeNode.IsDisposed As Boolean
		Return FIsDisposed
	End Function
	
	Private Destructor TreeNode
		Nodes.Clear
		FIsDisposed = True
			If Parent AndAlso Parent->Handle Then
				TreeView_DeleteItem(Parent->Handle, This.Handle)
				This.Handle = 0
			End If
		If FHint Then _Deallocate(FHint)
		If FName Then _Deallocate(FName)
		If FText Then _Deallocate(FText)
		If FSelectedImageKey Then _Deallocate(FSelectedImageKey)
		If FImageKey Then _Deallocate(FImageKey)
	End Destructor
	
	Private Constructor TreeNodeCollection
		This.Clear
	End Constructor
	
	Private Destructor TreeNodeCollection
		This.Clear
	End Destructor
	
		Private Function TreeNodeCollection.FindByHandle(hti As HTREEITEM) As TreeNode Ptr
			If ParentNode AndAlso ParentNode->Handle = hti Then Return ParentNode
			For i As Integer = 0 To Count - 1
				PNode = Item(i)->Nodes.FindByHandle(hti)
				If PNode <> 0 Then Return PNode
			Next i
			Return 0
		End Function
	
	Private Property TreeNodeCollection.Count As Integer
		Return FNodes.Count
	End Property
	
	Private Property TreeNodeCollection.Count(Value As Integer)
	End Property
	
	Private Property TreeNodeCollection.Item(Index As Integer) As TreeNode Ptr
		If Index >= 0 AndAlso Index < FNodes.Count Then
			Return FNodes.Items[Index]
		End If
	End Property
	
	Private Property TreeNodeCollection.Item(Index As Integer, Value As TreeNode Ptr)
		If Index >= 0 AndAlso Index < FNodes.Count Then
			FNodes.Items[Index] = Value 'David Change
		End If
	End Property
	
	Private Function TreeNodeCollection.Add(ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", iImageIndex As Integer = -1, iSelectedImageIndex As Integer = -1, bSorted As Boolean = False) As PTreeNode
		Dim PNode As PTreeNode
		PNode = _New( TreeNode)
		PNode->FDynamic = True
		Dim iIndex As Integer = -1
		If Cast(TreeView Ptr, Parent)->Sorted Or bSorted Then
			For i As Integer = 0 To FNodes.Count - 1
				If LCase(Item(i)->Text) > LCase(iText) Then
					iIndex = i
					Exit For
				End If
			Next
		End If
		If iIndex = -1 Then FNodes.Add PNode Else FNodes.Insert iIndex, PNode
		With *PNode
			.Text         = iText
			.Name         = iKey
			.ImageIndex     = iImageIndex
			.SelectedImageIndex     = iSelectedImageIndex
			.Hint           = iHint
			.Parent         = Parent
			.Nodes.Parent         = Parent
			.ParentNode        = Cast(TreeNode Ptr, ParentNode)
				Dim As TVINSERTSTRUCT tvis
				If Parent AndAlso Parent->Handle AndAlso (FParentNode = 0 OrElse FParentNode->Handle <> 0) Then
					tvis.item.mask = TVIF_TEXT Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
					tvis.item.pszText              = @iText
					tvis.item.cchTextMax           = Len(iText)+1
					tvis.item.iImage             = iImageIndex
					tvis.item.iSelectedImage     = iSelectedImageIndex
					tvis.hInsertAfter            = IIf(Cast(TreeView Ptr, Parent)->Sorted Or bSorted, TVI_SORT, 0)
					'tvis.hInsertAfter            = 0
					If .ParentNode Then tvis.hParent               = .ParentNode->Handle
					.Handle        = TreeView_InsertItem(Parent->Handle, @tvis)
				End If
		End With
		Return PNode
	End Function
	
	Private Function TreeNodeCollection.Add(ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", ByRef iImageKey As WString, ByRef iSelectedImageKey As WString, bSorted As Boolean = False) As PTreeNode
		Dim As TreeNode Ptr PNode
		If Parent AndAlso Cast(TreeView Ptr, Parent)->Images AndAlso Cast(TreeView Ptr, Parent)->SelectedImages Then
			PNode = This.Add(iText, iKey, iHint, Cast(TreeView Ptr, Parent)->Images->IndexOf(iImageKey), Cast(TreeView Ptr, Parent)->SelectedImages->IndexOf(iSelectedImageKey), bSorted)
		Else
			PNode = This.Add(iText, iKey, iHint, -1, -1, bSorted)
		End If
		If PNode Then PNode->ImageKey = iImageKey: PNode->SelectedImageKey = iSelectedImageKey
		Return PNode
	End Function
	
	Private Function TreeNodeCollection.Insert(Index As Integer, ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", iImageIndex As Integer = -1, iSelectedImageIndex As Integer = -1) As PTreeNode
		Dim PNode As PTreeNode
		PNode = _New( TreeNode)
		PNode->FDynamic = True
		FNodes.Insert Index, PNode
		With *PNode
			.Text         = iText
			.Name         = iKey
			.ImageIndex     = iImageIndex
			.SelectedImageIndex     = iSelectedImageIndex
			.Hint           = iHint
			.Parent         = Parent
			.Nodes.Parent         = Parent
			.ParentNode        = ParentNode
				Dim As TVINSERTSTRUCT tvis
				If Parent->Handle Then
					tvis.item.mask = TVIF_TEXT Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
					tvis.item.pszText              = @iText
					tvis.item.cchTextMax           = Len(iText) + 1
					tvis.item.iImage             = iImageIndex
					tvis.item.iSelectedImage     = iSelectedImageIndex
					tvis.hInsertAfter            = IIf(Index = 0, TVI_FIRST, IIf(Index < 0, TVI_LAST, Item(Index - 1)->Handle))
					If ParentNode Then
						tvis.hParent               = ParentNode->Handle
					Else
						tvis.hParent            = TVI_ROOT
					End If
					.Handle        = TreeView_InsertItem(Parent->Handle, @tvis)
				End If
		End With
		Return PNode
	End Function
	
	Private Function TreeNodeCollection.Insert(Index As Integer, ByRef iText As WString = "", ByRef iKey As WString = "", ByRef iHint As WString = "", ByRef iImageKey As WString, ByRef iSelectedImageKey As WString) As PTreeNode
		Dim PNode As PTreeNode
		If Parent AndAlso Cast(TreeView Ptr, Parent)->Images AndAlso Cast(TreeView Ptr, Parent)->SelectedImages Then
			PNode = This.Insert(Index, iText, iKey, iHint, Cast(TreeView Ptr, Parent)->Images->IndexOf(iImageKey), Cast(TreeView Ptr, Parent)->SelectedImages->IndexOf(iSelectedImageKey))
		Else
			PNode = This.Insert(Index, iText, iKey, iHint, -1, -1)
		End If
		If PNode Then PNode->ImageKey         = iImageKey: PNode->SelectedImageKey         = iSelectedImageKey
		Return PNode
	End Function
	
	Private Sub TreeNodeCollection.Remove(Index As Integer)
		'		#ifdef __USE_GTK__
		'			If Parent AndAlso Parent->widget Then
		'				gtk_tree_store_remove(Cast(TreeView Ptr, Parent)->TreeStore, @This.Item(Index)->TreeIter)
		'			End If
		'		#else
		'			If Parent AndAlso Parent->Handle Then
		'				TreeView_DeleteItem(Parent->Handle, Item(Index)->Handle)
		'			End If
		'		#endif
		_Delete(Item(Index))
		FNodes.Remove Index
	End Sub
	Private Sub TreeNode.EditLabel
			If Parent AndAlso Parent->Handle AndAlso Handle Then
				TreeView_EditLabel(Parent->Handle, Handle)
			End If
	End Sub
	
	Private Function TreeNodeCollection.IndexOf(ByRef FNode As TreeNode Ptr) As Integer
		Return FNodes.IndexOf(FNode)
	End Function
	
	Private Function TreeNodeCollection.IndexOf(ByRef Text As WString) As Integer
		For i As Integer = 0 To Count - 1
			If Item(i)->Text = Text Then Return i
		Next i
		Return -1
	End Function
	
	Private Function TreeNodeCollection.IndexOfKey(ByRef Key As WString) As Integer
		For i As Integer = 0 To Count - 1
			If Item(i)->Name = Key Then Return i
		Next i
		Return -1
	End Function
	
	Private Function TreeNodeCollection.Contains(ByRef FNode As TreeNode Ptr) As Boolean
		Return IndexOf(FNode) <> -1
	End Function
	
	Private Function TreeNodeCollection.Contains(ByRef Text As WString) As Boolean
		Return IndexOf(Text) <> -1
	End Function
	
	Private Function TreeNodeCollection.ContainsKey(ByRef Key As WString) As Boolean
		Return IndexOfKey(Key) <> -1
	End Function
	
	Private Property TreeNodeCollection.ParentNode As PTreeNode
		Return FParentNode
	End Property
	
	Private Property TreeNodeCollection.ParentNode(Value As PTreeNode)
		FParentNode = Value
	End Property
	
	Private Sub TreeNodeCollection.Clear
		'		If ParentNode = 0 Then
		'			#ifdef __USE_GTK__
		'				If Parent AndAlso Cast(TreeView Ptr, Parent)->TreeStore Then gtk_tree_store_clear(Cast(TreeView Ptr, Parent)->TreeStore)
		'			#else
		'				If Parent AndAlso Parent->Handle Then SendMessage(Parent->Handle, TVM_DELETEITEM, 0, Cast(LPARAM, TVI_ROOT))
		'			#endif
		For i As Integer = FNodes.Count - 1 To 0 Step -1
			If Cast(TreeNode Ptr, FNodes.Items[i])->FDynamic Then _Delete( Cast(TreeNode Ptr, FNodes.Items[i]))
		Next i
		'		Else
		'			For i As Integer = Count - 1 To 0 Step -1
		'				Remove i
		'			Next i
		'		End If
		FNodes.Clear
	End Sub
	
		Private Function TreeView.ReadProperty(ByRef PropertyName As String) As Any Ptr
			Select Case LCase(PropertyName)
			Case "editlabels": Return @FEditLabels
			Case "hideselection": Return @FHideSelection
			Case "images": Return Images
			Case "sorted": Return @FSorted
			Case "showhint": Return @FShowHint
			Case "selectedimages": Return SelectedImages
			Case "selectednode": Return SelectedNode
			Case "tabindex": Return @FTabIndex
			Case Else: Return Base.ReadProperty(PropertyName)
			End Select
			Return 0
		End Function
	
		Private Function TreeView.WriteProperty(ByRef PropertyName As String, Value As Any Ptr) As Boolean
			If Value = 0 Then
				Select Case LCase(PropertyName)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			Else
				Select Case LCase(PropertyName)
				Case "editlabels": EditLabels = QBoolean(Value)
				Case "hideselection": HideSelection = QBoolean(Value)
				Case "images": Images = Value
				Case "sorted": Sorted = QBoolean(Value)
				Case "showhint": ShowHint = QBoolean(Value)
				Case "selectedimages": SelectedImages = Value
				Case "selectednode": SelectedNode = Value
				Case "tabindex": TabIndex = QInteger(Value)
				Case Else: Return Base.WriteProperty(PropertyName, Value)
				End Select
			End If
			Return True
		End Function
	
	Private Property TreeView.TabIndex As Integer
		Return FTabIndex
	End Property
	
	Private Property TreeView.TabIndex(Value As Integer)
		ChangeTabIndex Value
	End Property
	
	Private Property TreeView.TabStop As Boolean
		Return FTabStop
	End Property
	
	Private Property TreeView.TabStop(Value As Boolean)
		ChangeTabStop Value
	End Property
	
		Private Sub TreeView.SendToAllChildItems(ByVal hNode As HTREEITEM, tvMessage As Long)
			Dim hChildNode As HTREEITEM
			Do While hNode
				TreeView_Expand(FHandle, hNode, tvMessage)
				hChildNode = TreeView_GetChild(FHandle, hNode)
				If hChildNode Then SendToAllChildItems(hChildNode, tvMessage)
				hNode = TreeView_GetNextSibling(FHandle, hNode)
			Loop
		End Sub
	
	Private Sub TreeView.CollapseAll
			SendToAllChildItems(TreeView_GetRoot(Handle), TVE_COLLAPSE)
	End Sub
	
	Private Sub TreeView.ExpandAll
			SendToAllChildItems(TreeView_GetRoot(Handle), TVM_EXPAND)
	End Sub
	
	Private Property TreeView.HideSelection As Boolean
		Return FHideSelection
	End Property
	
	Private Property TreeView.HideSelection(Value As Boolean)
		FHideSelection = Value
			ChangeStyle TVS_SHOWSELALWAYS, Not Value
	End Property
	
	Private Property TreeView.EditLabels As Boolean
		Return FEditLabels
	End Property
	
	Private Property TreeView.EditLabels(Value As Boolean)
		FEditLabels = Value
			ChangeStyle TVS_EDITLABELS, Value
	End Property
	
	Private Property TreeView.SelectedNode As TreeNode Ptr
			If Handle Then
				Dim As HTREEITEM hti = TreeView_GetNextItem(Handle, NULL, TVGN_CARET)
				Return Nodes.FindByHandle(hti)
			End If
		Return 0
	End Property
	
	Private Property TreeView.SelectedNode(Value As TreeNode Ptr)
			If Handle Then TreeView_Select(Handle, Value->Handle, TVGN_CARET)
	End Property
	
	Private Function TreeView.DraggedNode As TreeNode Ptr
			If Handle Then
				Dim As HTREEITEM hti = TreeView_GetNextItem(Handle, NULL, TVGN_DROPHILITE)
				Return Nodes.FindByHandle(hti)
			End If
		Return 0
	End Function
	
	Private Property TreeView.ShowHint As Boolean
		Return FShowHint
	End Property
	
	Private Property TreeView.ShowHint(Value As Boolean)
		FShowHint = Value
	End Property
	
	Private Property TreeView.Sorted As Boolean
		Return FSorted
	End Property
	
	Private Property TreeView.Sorted(Value As Boolean)
		FSorted = Value
	End Property
	
		Private Sub TreeView.WndProc(ByRef Message As Message)
		End Sub
	
	
	Private Sub TreeView.ProcessMessage(ByRef Message As Message)
			Select Case Message.Msg
			Case WM_PAINT
				Message.Result = 0
			Case WM_DPICHANGED
				Base.ProcessMessage(Message)
				If Images Then Images->SetImageSize Images->ImageWidth, Images->ImageHeight, xdpi, ydpi
				If SelectedImages Then SelectedImages->SetImageSize SelectedImages->ImageWidth, SelectedImages->ImageHeight, xdpi, ydpi
				If Images AndAlso Images->Handle Then TreeView_SetImageList(FHandle, CInt(Images->Handle), TVSIL_NORMAL)
				If SelectedImages AndAlso SelectedImages->Handle Then TreeView_SetImageList(FHandle, CInt(SelectedImages->Handle), TVSIL_STATE)
				SendMessage(FHandle, TVM_SETINDENT, 0, 0)
				RedrawWindow(Message.hWnd, nullptr, nullptr, RDW_FRAME Or RDW_INVALIDATE)
				Return
			Case WM_DESTROY
				If Images Then TreeView_SetImageList(FHandle, 0, TVSIL_NORMAL)
				If SelectedImages Then TreeView_SetImageList(FHandle, 0, TVSIL_STATE)
			Case WM_SIZE
			Case WM_NOTIFY
				If (Cast(LPNMHDR, Message.lParam)->code = NM_CUSTOMDRAW) Then
					Dim As LPNMCUSTOMDRAW nmcd = Cast(LPNMCUSTOMDRAW, Message.lParam)
					Select Case nmcd->dwDrawStage
					Case CDDS_PREPAINT
						Message.Result = CDRF_NOTIFYITEMDRAW
						Return
					Case CDDS_ITEMPREPAINT
						'Var info = Cast(SubclassInfo Ptr, dwRefData)
						'SetTextColor(nmcd->hdc, headerTextColor)
						Message.Result = CDRF_DODEFAULT
						Return
					End Select
				End If
			Case WM_THEMECHANGED
				If (g_darkModeSupported) Then
					
					AllowDarkModeForWindow(Message.hWnd, g_darkModeEnabled)
					
					'Dim As HTHEME hTheme = OpenThemeData(nullptr, "ItemsView")
					'If (hTheme) Then
					'Dim As COLORREF Color1
					'If (SUCCEEDED(GetThemeColor(hTheme, 0, 0, TMT_TEXTCOLOR, @Color1))) Then
					If g_darkModeEnabled Then
						TreeView_SetTextColor(Message.hWnd, darkTextColor) 'Color1)
					Else
						TreeView_SetTextColor(Message.hWnd, Font.Color) 'Color1)
					End If
					'End If
					'If (SUCCEEDED(GetThemeColor(hTheme, 0, 0, TMT_FILLCOLOR, @Color1))) Then
					'TreeView_SetTextBkColor(Message.hWnd, Color1)
					If g_darkModeEnabled Then
						TreeView_SetBkColor(Message.hWnd, darkBkColor) 'Color1)
					Else
						TreeView_SetBkColor(Message.hWnd, FBackColor) 'Color1)
					End If
					'End If
					'	CloseThemeData(hTheme)
					'End If
					
					RedrawWindow(Message.hWnd, nullptr, nullptr, RDW_FRAME Or RDW_INVALIDATE)
				End If
			Case CM_NOTIFY
				Dim tvp As NMTREEVIEW Ptr = Cast(NMTREEVIEW Ptr, Message.lParam)
				'If tvp->itemNew.hItem <> 0 Then
					Dim sn As TreeNode Ptr
					Select Case tvp->hdr.code
					Case NM_CLICK
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						If OnNodeClick AndAlso sn Then OnNodeClick(*Designer, This, *sn)
					Case NM_DBLCLK:
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						If OnNodeDblClick AndAlso sn Then OnNodeDblClick(*Designer, This, *sn)
						If OnNodeActivate Then OnNodeActivate(*Designer, This, *sn)
					Case NM_KILLFOCUS
					Case NM_RCLICK
						If OnMouseUp Then OnMouseUp(*Designer, This, 1, Message.lParamLo, Message.lParamHi, Message.wParam And &HFFFF)
						If ContextMenu Then
							If ContextMenu->Handle Then
								Dim As ..Point P
								GetCursorPos(@P)
								ContextMenu->Popup(P.X, P.Y)
							End If
						End If
					Case NM_RDBLCLK
					Case NM_RETURN
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						If OnNodeActivate AndAlso sn Then OnNodeActivate(*Designer, This, *sn)
					Case NM_SETCURSOR
					Case NM_SETFOCUS
					Case TVN_KEYDOWN
					Case TVN_GETINFOTIP
					Case TVN_SINGLEEXPAND
					Case TVN_SELCHANGING
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						Dim bCancel As Boolean
						If OnSelChanging AndAlso sn <> 0 Then OnSelChanging(*Designer, This, *sn, bCancel)
						If bCancel Then Message.Result = -1: Exit Sub
					Case TVN_SELCHANGED
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						If OnSelChanged AndAlso sn <> 0 Then OnSelChanged(*Designer, This, *sn)
					Case TVN_GETDISPINFO
					Case TVN_GETINFOTIP
					Case TVN_SETDISPINFO
					Case TVN_ITEMCHANGED
					Case TVN_ITEMCHANGING
					Case TVN_ITEMEXPANDING
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						Dim bCancel As Boolean
						Select Case tvp->action
						Case TVE_COLLAPSE: If OnNodeCollapsing AndAlso sn <> 0 Then OnNodeCollapsing(*Designer, This, *sn, bCancel)
						Case TVE_EXPAND: If OnNodeExpanding AndAlso sn <> 0 Then OnNodeExpanding(*Designer, This, *sn, bCancel)
						End Select
						If bCancel Then Message.Result = -1: Exit Sub
					Case TVN_ITEMEXPANDED
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						Select Case tvp->action
						Case TVE_COLLAPSE: If OnNodeCollapsed AndAlso sn <> 0 Then OnNodeCollapsed(*Designer, This, *sn)
						Case TVE_EXPAND: If OnNodeExpanded AndAlso sn <> 0 Then OnNodeExpanded(*Designer, This, *sn)
						End Select
					Case TVN_BEGINDRAG
					Case TVN_BEGINRDRAG
					Case TVN_DELETEITEM
					Case TVN_BEGINLABELEDIT
						Dim tvpA As NMTVDISPINFOA Ptr = Cast(NMTVDISPINFOA Ptr, Message.lParam)
						Dim As WString Ptr tmpStr = Cast(WString Ptr, tvpA->item.pszText)
						If tmpStr = 0 Then Return
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						Dim bCancel As Boolean
						If OnBeforeLabelEdit Then OnBeforeLabelEdit(*Designer, This, *sn, *tmpStr, bCancel)
						If bCancel Then Message.Result = -1: Exit Sub
					Case TVN_ENDLABELEDIT
						Dim tvpA As NMTVDISPINFOA Ptr = Cast(NMTVDISPINFOA Ptr, Message.lParam)
						Dim As WString Ptr tmpStr = Cast(WString Ptr, tvpA->item.pszText)
						If tmpStr = 0 Then Return
						sn = Nodes.FindByHandle(tvp->itemNew.hItem): If sn = 0 Then sn = SelectedNode
						Dim bCancel As Boolean
						If OnAfterLabelEdit Then OnAfterLabelEdit(*Designer, This, *sn, *tmpStr, bCancel)
						If Not bCancel Then Message.Result = -1: Exit Sub
					Case TVN_ASYNCDRAW
						'Case NM_KEYDOWN: If OnItemDblClick Then OnItemDblClick(This, *ListItems.Item(lvp->iItem))
					End Select
				'End If
				
			Case CM_COMMAND
				
			Case CM_NEEDTEXT
				'            Dim As LPTOOLTIPTEXT TTX
				'            TTX = Cast(LPTOOLTIPTEXT,Message.lParam)
				'            TTX->hInst = GetModuleHandle(NULL)
				'            If TTX->hdr.idFrom Then
				'                Dim As TBButton TB
				'                Dim As Integer Index
				'                Index = Perform(TB_COMMANDTOINDEX,TTX->hdr.idFrom,0)
				'                If Perform(TB_GETBUTTON,Index,CInt(@TB)) Then
				'                   If Buttons.Button(Index)->ShowHint Then
				'                      If Buttons.Button(Index)->Hint <> "" Then
				'                          'Dim As UString s
				'                          's = Buttons.Button(Index).Hint
				'                          TTX->lpszText = @(Buttons.Button(Index)->Hint)
				'                      End If
				'                   End If
				'                End If
				'            End If
			End Select
		Base.ProcessMessage(Message)
	End Sub
	
		Private Sub TreeView.HandleIsDestroyed(ByRef Sender As Control)
		End Sub
		
		Private Sub TreeView.CreateNodes(PNode As TreeNode Ptr)
			With PNode->Nodes
				For i As Integer = 0 To .Count - 1
					Dim tvis As TVINSERTSTRUCT
					tvis.item.mask = TVIF_TEXT Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
					tvis.item.pszText              = @.Item(i)->Text
					tvis.item.cchTextMax           = Len(.Item(i)->Text)
					tvis.item.iImage             = .Item(i)->ImageIndex
					tvis.item.iSelectedImage     = .Item(i)->SelectedImageIndex
					tvis.hInsertAfter            = 0
					If .Item(i)->ParentNode Then
						tvis.hParent               = .Item(i)->ParentNode->Handle
					Else
						tvis.hParent            = TVI_ROOT
					End If
					.Item(i)->Handle        = TreeView_InsertItem(FHandle, @tvis )
					CreateNodes .Item(i)
				Next i
			End With
		End Sub
		
		Private Sub TreeView.HandleIsAllocated(ByRef Sender As Control)
			If Sender.Child Then
				With QTreeView(Sender.Child)
					If .Images Then .Images->ParentWindow = @Sender
					If .SelectedImages Then .SelectedImages->ParentWindow = @Sender
					'.Perform(TB_BUTTONSTRUCTSIZE,SizeOF(TBBUTTON),0)
					'.Perform(TB_SETEXTENDEDSTYLE, 0, .Perform(TB_GETEXTENDEDSTYLE, 0, 0) OR TBSTYLE_EX_DRAWDDARROWS)
					'.Perform(TB_SETBUTTONSIZE,0,MakeLong(.ButtonWidth,.ButtonHeight))
					'.Perform(TB_SETBITMAPSIZE,0,MakeLong(.ButtonWidth,.ButtonHeight))
					Dim lvStyle As Integer = TreeView_GetExtendedStyle(.FHandle) 'David Change
					lvStyle = lvStyle Or TVS_EX_DOUBLEBUFFER' Or TVS_EX_FADEINOUTEXPANDOS 'the ICO not showing at the beginning
					TreeView_SetExtendedStyle(.FHandle, lvStyle, 0)
					
					If .Images AndAlso .Images->Handle Then TreeView_SetImageList(.FHandle, CInt(.Images->Handle), TVSIL_NORMAL)
					If .SelectedImages AndAlso .SelectedImages->Handle Then TreeView_SetImageList(.FHandle, CInt(.SelectedImages->Handle), TVSIL_STATE)
					For i As Integer = 0 To .Nodes.Count -1
						Dim tvis As TVINSERTSTRUCT
						tvis.item.mask = TVIF_TEXT Or TVIF_IMAGE Or TVIF_SELECTEDIMAGE
						tvis.item.pszText              = @.Nodes.Item(i)->Text
						tvis.item.cchTextMax           = Len(.Nodes.Item(i)->Text)
						tvis.item.iImage             = .Nodes.Item(i)->ImageIndex
						tvis.item.iSelectedImage     = .Nodes.Item(i)->SelectedImageIndex
						tvis.hInsertAfter            = 0
						tvis.hParent            = TVI_ROOT
						.Nodes.Item(i)->Handle        = TreeView_InsertItem(.FHandle, @tvis)
						.CreateNodes .Nodes.Item(i)
					Next i
				End With
			End If
		End Sub
	
	Private Operator TreeView.Cast As Control Ptr
		Return @This
	End Operator
	
	
	Private Constructor TreeView
		Nodes.Clear
		Nodes.Parent = @This
		FEnabled = True
		FVisible = True
		With This
			.Child             = @This
				.OnHandleIsAllocated = @HandleIsAllocated
				.OnHandleIsDestroyed = @HandleIsDestroyed
				.RegisterClass "TreeView", WC_TREEVIEW
				.ChildProc         = @WndProc
				WLet(FClassAncestor, WC_TREEVIEW)
				.ExStyle           = WS_EX_CLIENTEDGE
				.Style             = WS_CHILD Or WS_VISIBLE Or TVS_HASLINES Or TVS_LINESATROOT Or TVS_HASBUTTONS
				.BackColor       = GetSysColor(COLOR_WINDOW) 'David Change
				FDefaultBackColor = .BackColor
				.DoubleBuffered = True
			BorderStyle = BorderStyles.bsClient
			WLet(FClassName, "TreeView")
			FTabIndex          = -1
			FTabStop = True
			.Width             = 121
			.Height            = 121
		End With
	End Constructor
	
	Private Destructor TreeView
		Nodes.Clear
			UnregisterClass "TreeView", GetModuleHandle(NULL)
	End Destructor
End Namespace

