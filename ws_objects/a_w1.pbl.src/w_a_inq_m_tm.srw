$PBExportHeader$w_a_inq_m_tm.srw
$PBExportComments$multi master, tab, multi row Inquiry ( from w_a_m_master)
forward
global type w_a_inq_m_tm from w_a_m_master
end type
type tab_1 from u_tab_inq within w_a_inq_m_tm
end type
type tab_1 from u_tab_inq within w_a_inq_m_tm
end type
type st_horizontal from statictext within w_a_inq_m_tm
end type
end forward

global type w_a_inq_m_tm from w_a_m_master
integer width = 3104
tab_1 tab_1
st_horizontal st_horizontal
end type
global w_a_inq_m_tm w_a_inq_m_tm

type variables
Boolean ib_retrieve

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Bottom							//Reference to the Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine of_refreshbars ()
public subroutine of_resizepanels ()
end prototypes

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

end subroutine

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.
Integer	li_index

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness)

For li_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
Next

end subroutine

on w_a_inq_m_tm.create
int iCurrent
call super::create
this.tab_1=create tab_1
this.st_horizontal=create st_horizontal
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
this.Control[iCurrent+2]=this.st_horizontal
end on

on w_a_inq_m_tm.destroy
call super::destroy
destroy(this.tab_1)
destroy(this.st_horizontal)
end on

event ue_ok;call super::ue_ok;Int li_tab_index

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False	
Next

ib_retrieve = False
end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < tab_1.Y Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.tabpage_1.Height - tab_1.idw_tabpage[li_index].Y * 2
	Next
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.tabpage_1.Width - tab_1.idw_tabpage[li_index].X * 2
	Next
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event open;call super::open;// Set the Top, Bottom Controls
idrg_Top = dw_master
idrg_Bottom = tab_1

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

type dw_cond from w_a_m_master`dw_cond within w_a_inq_m_tm
end type

type p_ok from w_a_m_master`p_ok within w_a_inq_m_tm
end type

type p_close from w_a_m_master`p_close within w_a_inq_m_tm
integer x = 2766
integer y = 52
end type

type gb_cond from w_a_m_master`gb_cond within w_a_inq_m_tm
end type

type dw_master from w_a_m_master`dw_master within w_a_inq_m_tm
integer width = 3008
integer height = 396
end type

event dw_master::clicked;call super::clicked;Long ll_selected_row
Int li_tab_index

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	For li_tab_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_tab_index].Reset()
		tab_1.ib_tabpage_check[li_tab_index] = False
	Next
	
	If ll_selected_row > 0 Then
		tab_1.Trigger Event SelectionChanged(1, Tab_1.SelectedTab)
	End If
End If
end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	ib_retrieve = True
	tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)
End If

end event

event ue_after_sort;//PB 6.0 : Sort()후의 첫번째 열의 자동 선택에 따른 해결책(Sort()전에 선택된 열이 존재시)
Long ll_select_row

ll_select_row = GetSelectedRow(0)

If ll_select_row > 0 Then
	Trigger Event Clicked(0, 0, ll_select_row, Object.a_d)
End If

Return 0

end event

type tab_1 from u_tab_inq within w_a_inq_m_tm
event type integer ue_tabpage_retrieve ( long al_master_row,  integer ai_select_tabpage )
integer x = 23
integer y = 760
integer width = 3008
integer height = 1080
integer taborder = 0
long backcolor = 29478337
end type

event ue_tabpage_retrieve;Return 0 //이 코드가 존재하지 않을 시 자손에서 이 부분 코딩시 윈도우의 이벤트로 변환됨
end event

event ue_init;call super::ue_init;iw_parent = Parent
end event

event selectionchanged;call super::selectionchanged;//Int li_return
Long ll_selected_row

If ib_retrieve = True Then
	If tab_1.ib_tabpage_check[newindex] = False Then
		ll_selected_row = dw_master.GetSelectedRow(0)
		If ll_selected_row > 0 Then
			If Trigger Event ue_tabpage_retrieve(ll_selected_row, newindex) < 0 Then
				Return
			End If
			tab_1.ib_tabpage_check[newindex] = True
		End If
	End If
End If
end event

type st_horizontal from statictext within w_a_inq_m_tm
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 23
integer y = 728
integer width = 745
integer height = 32
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string pointer = "SizeNS!"
long textcolor = 33554432
long backcolor = 16776960
boolean focusrectangle = false
end type

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = Y

	// Refresh the Bar attributes.
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
	If Not IsValid(idrg_Bottom) Then Return
	If li_prevposition > idrg_Bottom.Y Then idrg_Bottom.SetRedraw(True)
End If

end event

event mouseup;// Hide the bar
BackColor = il_HiddenColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.

end event

