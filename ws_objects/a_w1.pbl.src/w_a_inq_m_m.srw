$PBExportHeader$w_a_inq_m_m.srw
$PBExportComments$multi master,multi row Inquiry ( from w_a_m_master)
forward
global type w_a_inq_m_m from w_a_m_master
end type
type dw_detail from u_d_base within w_a_inq_m_m
end type
type st_horizontal from statictext within w_a_inq_m_m
end type
end forward

global type w_a_inq_m_m from w_a_m_master
integer width = 3109
integer height = 1948
dw_detail dw_detail
st_horizontal st_horizontal
end type
global w_a_inq_m_m w_a_inq_m_m

type variables
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

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness)



end subroutine

on w_a_inq_m_m.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.st_horizontal=create st_horizontal
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.st_horizontal
end on

on w_a_inq_m_m.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.st_horizontal)
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < dw_detail.Y Then
	dw_detail.Height = 0
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event open;call super::open;// Set the Top, Bottom Controls
idrg_Top = dw_master
idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

type dw_cond from w_a_m_master`dw_cond within w_a_inq_m_m
end type

type p_ok from w_a_m_master`p_ok within w_a_inq_m_m
end type

type p_close from w_a_m_master`p_close within w_a_inq_m_m
integer y = 52
end type

type gb_cond from w_a_m_master`gb_cond within w_a_inq_m_m
end type

type dw_master from w_a_m_master`dw_master within w_a_inq_m_m
integer y = 312
integer width = 3003
integer height = 408
end type

event dw_master::clicked;call super::clicked;Long ll_selected_row
//Int li_return

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_selected_row > 0 Then
		
		If dw_detail.Trigger Event ue_retrieve(ll_selected_row) < 0 Then
			Return
		End If
	Else
		dw_detail.Reset()
	End if
End If

end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
End If

end event

event ue_after_sort;//PB 6.0 : Sort()후의 첫번째 열의 자동 선택에 따른 해결책(Sort()전에 선택된 열이 존재시)
//Long ll_select_row
//
//ll_select_row = GetSelectedRow(0)
//
//If ll_select_row > 0 Then
//	If dw_detail.Trigger Event ue_retrieve(ll_select_row) < 0 Then
//		Return -1
//	End If
//End If
//
//Return 0

//==> Tab관련 Ancestor의 문제점으로 인해 선택되지 않게 하는 것으로 처리..
Long ll_select_row

ll_select_row = GetSelectedRow(0)

If ll_select_row > 0 Then
	Trigger Event Clicked(0, 0, ll_select_row, Object.a_d)
End If

Return 0

end event

type dw_detail from u_d_base within w_a_inq_m_m
event type integer ue_retrieve ( long al_select_row )
integer x = 18
integer y = 764
integer width = 3003
integer height = 1048
integer taborder = 0
boolean hsplitscroll = true
end type

type st_horizontal from statictext within w_a_inq_m_m
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 27
integer y = 724
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

