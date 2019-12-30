$PBExportHeader$w_a_reg_m_m.srw
$PBExportComments$multi master,multi row Register ( from w_a_m_master)
forward
global type w_a_reg_m_m from w_a_m_master
end type
type dw_detail from u_d_indicator within w_a_reg_m_m
end type
type p_insert from u_p_insert within w_a_reg_m_m
end type
type p_delete from u_p_delete within w_a_reg_m_m
end type
type p_save from u_p_save within w_a_reg_m_m
end type
type p_reset from u_p_reset within w_a_reg_m_m
end type
type st_horizontal from statictext within w_a_reg_m_m
end type
end forward

global type w_a_reg_m_m from w_a_m_master
integer width = 3145
integer height = 1888
event type integer ue_insert ( )
event type integer ue_delete ( )
event type integer ue_save ( )
event type integer ue_extra_insert ( long al_insert_row )
event type integer ue_extra_delete ( )
event type integer ue_extra_save ( )
event type integer ue_reset ( )
dw_detail dw_detail
p_insert p_insert
p_delete p_delete
p_save p_save
p_reset p_reset
st_horizontal st_horizontal
end type
global w_a_reg_m_m w_a_reg_m_m

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app

//AncestorReturnValue사용으로 필요가 없어짐.
//Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Bottom							//Reference to the Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine of_resizebars ()
public subroutine of_refreshbars ()
end prototypes

event ue_insert;Constant Int LI_ERROR = -1
Long ll_row
//Int li_return

//ii_error_chk = -1

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

Return 0
//ii_error_chk = 0
end event

event ue_delete;Constant Int LI_ERROR = -1

//Int li_return

//ii_error_chk = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
End if

Return 0
//ii_error_chk = 0
end event

event ue_save;Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
End if

//ii_error_chk = 0
Return 0

end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//ii_error_chk = 0
Return 0

end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
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

on w_a_reg_m_m.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.st_horizontal=create st_horizontal
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.p_insert
this.Control[iCurrent+3]=this.p_delete
this.Control[iCurrent+4]=this.p_save
this.Control[iCurrent+5]=this.p_reset
this.Control[iCurrent+6]=this.st_horizontal
end on

on w_a_reg_m_m.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.st_horizontal)
end on

event closequery;call super::closequery;Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

event close;call super::close;Destroy iu_cust_db_app
end event

event open;call super::open;iu_cust_db_app = Create u_cust_db_app

TriggerEvent("ue_reset")

// Set the Top, Bottom Controls
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

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
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

type dw_cond from w_a_m_master`dw_cond within w_a_reg_m_m
integer width = 2286
end type

type p_ok from w_a_m_master`p_ok within w_a_reg_m_m
integer x = 2473
integer y = 56
end type

type p_close from w_a_m_master`p_close within w_a_reg_m_m
integer x = 2779
integer y = 56
end type

type gb_cond from w_a_m_master`gb_cond within w_a_reg_m_m
integer width = 2368
end type

type dw_master from w_a_m_master`dw_master within w_a_reg_m_m
integer x = 37
integer width = 3008
integer height = 408
end type

event dw_master::clicked;Long ll_selected_row,ll_old_selected_row
Int li_rc

ll_old_selected_row = This.GetSelectedRow(0)

Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_old_selected_row > 0 Then
		dw_detail.AcceptText()

		If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
			li_rc = MessageBox(Parent.Title, "Data is Modified.! Do you want to cancel?" &
						,Question!, YesNo!)
   		If li_rc <> 1 Then
				If ll_selected_row > 0 Then
					SelectRow(ll_selected_row ,FALSE)
				End If
				SelectRow(ll_old_selected_row , TRUE )
				ScrollToRow(ll_old_selected_row)
				dw_detail.SetFocus()
				Return //Process Cancel
			End If
		End If
	End If
		
	If ll_selected_row > 0 Then
		If dw_detail.Trigger Event ue_retrieve(ll_selected_row) < 0 Then
			Return
		End If
		p_insert.TriggerEvent('ue_enable') 
		p_delete.TriggerEvent('ue_enable') 
		p_save.TriggerEvent('ue_enable') 
		p_reset.TriggerEvent('ue_enable') 
		dw_detail.SetFocus()
	Else
		dw_detail.Reset()
		p_insert.TriggerEvent('ue_disable') 
		p_delete.TriggerEvent('ue_disable') 
		p_save.TriggerEvent('ue_disable') 
		p_reset.TriggerEvent('ue_disable') 
	End If
End If
end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
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

type dw_detail from u_d_indicator within w_a_reg_m_m
event type integer ue_retrieve ( long al_select_row )
integer x = 27
integer y = 772
integer width = 3008
integer height = 860
integer taborder = 30
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event ue_key;call super::ue_key;If keyflags = 0 Then
	If key = KeyEscape! Then
		Parent.TriggerEvent(is_close)
	End If
End If

end event

type p_insert from u_p_insert within w_a_reg_m_m
integer x = 32
integer y = 1656
boolean enabled = false
boolean originalsize = false
end type

type p_delete from u_p_delete within w_a_reg_m_m
integer x = 325
integer y = 1660
boolean enabled = false
boolean originalsize = false
end type

type p_save from u_p_save within w_a_reg_m_m
integer x = 622
integer y = 1660
boolean enabled = false
boolean originalsize = false
end type

type p_reset from u_p_reset within w_a_reg_m_m
integer x = 1349
integer y = 1660
boolean enabled = false
boolean originalsize = false
end type

type st_horizontal from statictext within w_a_reg_m_m
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 27
integer y = 732
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

