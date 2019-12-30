$PBExportHeader$w_a_reg_m_m3_sams.srw
$PBExportComments$multi master,multi 2 row Register ( from w_a_m_master)
forward
global type w_a_reg_m_m3_sams from w_a_m_master
end type
type dw_detail from u_d_indicator within w_a_reg_m_m3_sams
end type
type p_insert from u_p_insert within w_a_reg_m_m3_sams
end type
type p_delete from u_p_delete within w_a_reg_m_m3_sams
end type
type p_save from u_p_save within w_a_reg_m_m3_sams
end type
type p_reset from u_p_reset within w_a_reg_m_m3_sams
end type
type dw_detail2 from u_d_indicator within w_a_reg_m_m3_sams
end type
type st_horizontal2 from statictext within w_a_reg_m_m3_sams
end type
type st_horizontal from statictext within w_a_reg_m_m3_sams
end type
type dw_sale from u_d_indicator within w_a_reg_m_m3_sams
end type
end forward

global type w_a_reg_m_m3_sams from w_a_m_master
integer width = 3250
integer height = 1880
event ue_insert ( )
event ue_delete ( )
event type integer ue_save ( )
event ue_extra_insert ( long al_insert_row,  ref integer ai_return )
event ue_extra_delete ( ref integer ai_return )
event ue_extra_save ( ref integer ai_return )
event ue_reset ( )
event ue_ok_after ( )
event ue_save_after ( ref integer ai_return )
dw_detail dw_detail
p_insert p_insert
p_delete p_delete
p_save p_save
p_reset p_reset
dw_detail2 dw_detail2
st_horizontal2 st_horizontal2
st_horizontal st_horizontal
dw_sale dw_sale
end type
global w_a_reg_m_m3_sams w_a_reg_m_m3_sams

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app

Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop						//The virtual top of the window
Integer		ii_WindowMiddle					//The virtual middle of the window
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Middle							//Reference to the Top Middle control
Dragobject	idrg_Bottom							//Reference to the Top Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine of_resizebars ()
public subroutine of_refreshbars ()
end prototypes

event ue_insert();//Long ll_row
//Int li_return
//
//ii_error_chk = -1
//
//
//ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)
//
//dw_detail.ScrollToRow(ll_row)
//dw_detail.SetRow(ll_row)
//dw_detail.SetFocus()
//
//This.Trigger Event ue_extra_insert(ll_row,li_return)
//
//If li_return < 0 Then
//	Return
//End if
//
//ii_error_chk = 0
end event

event ue_delete();//Int li_return
//
//ii_error_chk = -1
//
//This.Trigger Event ue_extra_delete(li_return)
//
//If li_return < 0 Then
//	Return
//End if
//
//If dw_detail.RowCount() > 0 Then
//	dw_detail.DeleteRow(0)
//	dw_detail.SetFocus()
//End if
//
//ii_error_chk = 0
end event

event type integer ue_save();//Int li_return
//
//ii_error_chk = -1
//
//If dw_detail.AcceptText() < 0 Then
//	dw_detail.SetFocus()
//	Return -1
//End if
//
//This.Trigger Event ue_extra_save(li_return)
//
//If li_return < 0 Then
//	dw_detail.SetFocus()
//	Return -1
//End if
//
//If dw_detail.Update() < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return -1
//	End If
//	f_msg_info(3010,This.Title,"Save")
//	return -1
//end If
//
//If dw_detail2.Update() < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail2.SetFocus()
//		return -1
//	End If
//	f_msg_info(3010,This.Title,"Save")
//	return -1
//end If
//
//// 저장후 commit 전에 할일 
//li_return = 1
//Event ue_save_after( li_return )
//If li_return < 0 then
//	f_msg_info(3010,This.Title,"Save")
//	rollback ;
//	return -1
//End If
//
//
////COMMIT와 동일한 기능
//iu_cust_db_app.is_caller = "COMMIT"
//iu_cust_db_app.is_title = This.Title
//
//iu_cust_db_app.uf_prc_db()
//
//If iu_cust_db_app.ii_rc = -1 Then
//
//	dw_detail.SetFocus()
//	return -1
//End If
//f_msg_info(3000,This.Title,"Save")
//
//
ii_error_chk = 0
return 1
end event

event ue_reset();//Int li_rc, li_ret
//
//ii_error_chk = -1
//
//dw_detail.AcceptText()
//
//If dw_detail.ModifiedCount() > 0 or &
//	dw_detail.DeletedCount() > 0 or &
//	dw_detail2.ModifiedCount() > 0 or &
//	dw_detail2.DeletedCount() > 0 then
//	
//	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
//	CHOOSE CASE li_ret
//		CASE 1
//			li_ret = -1 
//			li_ret = Event ue_save()
//			If Isnull( li_ret ) or li_ret < 0 then return
//		CASE 2
//
//		CASE ELSE
//			Return 
//	END CHOOSE
//		
//end If
//
//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
//p_save.TriggerEvent("ue_disable")
//p_reset.TriggerEvent("ue_disable")
//p_ok.TriggerEvent("ue_enable")
//
//dw_detail.Reset()
//dw_detail2.Reset()
//dw_master.Reset()
//dw_cond.Enabled = True
//dw_cond.Reset()
//dw_cond.InsertRow(0)
//dw_cond.SetFocus()
//
//ii_error_chk = 0
//
end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

Long		ll_Width, ll_Height

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return

ll_Width = WorkSpaceWidth()
ll_Height = WorkspaceHeight()

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal2.Y - idrg_Top.Y)

// Middle processing
idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness)
idrg_Middle.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Middle.Y)

// Bottom Processing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, ll_Height - (st_horizontal.Y + cii_BarThickness) - iu_cust_w_resize.ii_button_space)

end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.
//If st_horizontal2.Y < ii_WindowTop + 150 Then
//	st_horizontal2.Y = ii_WindowTop + 150
//End If
//If st_horizontal2.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
//	st_horizontal2.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
//End If
st_horizontal2.Move(idrg_Top.X, st_horizontal2.Y)
st_horizontal2.Resize(idrg_Top.Width, cii_Barthickness)

//If st_horizontal.Y < ii_WindowTop + 150 Then
//	st_horizontal.Y = ii_WindowTop + 150
//End If
//If st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
//	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
//End If
st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

//If st_vertical.X < idrg_Top.Y + cii_Barthickness + 150 Then
//	st_vertical.X = idrg_Top.Y + cii_Barthickness + 150
//End If
//
//If st_vertical.X > WorkSpaceWidth() - 150 - cii_BarThickness - iu_cust_w_resize.ii_button_space Then
//	st_vertical.X = WorkSpaceWidth() - 150 - cii_BarThickness - iu_cust_w_resize.ii_button_space
//End If

//st_vertical.Move(st_vertical.X, st_horizontal.Y + cii_Barthickness)
//st_vertical.Resize(cii_Barthickness, WorkSpaceHeight() - st_vertical.Y - iu_cust_w_resize.ii_button_space)

of_RefreshBars()

end subroutine

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)
st_horizontal2.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness
st_horizontal2.Height = cii_BarThickness

end subroutine

on w_a_reg_m_m3_sams.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.dw_detail2=create dw_detail2
this.st_horizontal2=create st_horizontal2
this.st_horizontal=create st_horizontal
this.dw_sale=create dw_sale
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.p_insert
this.Control[iCurrent+3]=this.p_delete
this.Control[iCurrent+4]=this.p_save
this.Control[iCurrent+5]=this.p_reset
this.Control[iCurrent+6]=this.dw_detail2
this.Control[iCurrent+7]=this.st_horizontal2
this.Control[iCurrent+8]=this.st_horizontal
this.Control[iCurrent+9]=this.dw_sale
end on

on w_a_reg_m_m3_sams.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.dw_detail2)
destroy(this.st_horizontal2)
destroy(this.st_horizontal)
destroy(this.dw_sale)
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

//// Set the TopLeft, TopRight, and Bottom Controls
idrg_Top 	= dw_sale
idrg_Middle = dw_detail2
idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop				 	= idrg_Top.Y
ii_WindowMiddle 				= idrg_Middle.Y
st_horizontal.BackColor 	= BackColor
st_horizontal2.BackColor 	= BackColor
il_HiddenColor 				= BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

end event

event ue_ok();call super::ue_ok;Long li_ret

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = -1 
			li_ret = Event ue_save()
			If Isnull( li_ret ) or li_ret < 0 then return
		CASE 2

		CASE ELSE
			Return 
	END CHOOSE
		
end If

Event ue_ok_after()

//dw_master.event ue_select()
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

type dw_cond from w_a_m_master`dw_cond within w_a_reg_m_m3_sams
integer width = 2167
integer taborder = 20
end type

type p_ok from w_a_m_master`p_ok within w_a_reg_m_m3_sams
integer x = 2391
end type

type p_close from w_a_m_master`p_close within w_a_reg_m_m3_sams
integer x = 2693
end type

type gb_cond from w_a_m_master`gb_cond within w_a_reg_m_m3_sams
end type

type dw_master from w_a_m_master`dw_master within w_a_reg_m_m3_sams
event ue_select ( )
boolean visible = false
integer x = 41
integer y = 316
integer width = 3150
integer height = 372
integer taborder = 30
boolean ib_sort_use = false
end type

event dw_master::retrieveend;call super::retrieveend;//If rowcount > 0 Then
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	dw_detail.SetFocus()
//
//	dw_cond.Enabled = False
//	p_ok.TriggerEvent("ue_disable")
//End If
//
end event

event dw_master::getfocus;call super::getfocus;//// ue_init 에서 설정되는 아래의 값에 따라 데이타윈도우별 
//// 추가삭제 처리를 조정케 한다. 
//ib_insert =  True
//ib_delete = True
//If ib_insert Then
//	p_insert.Event ue_enable()
//else
//	p_insert.Event ue_disable()
//end If
//
//
//If ib_delete Then
//	p_delete.Event ue_enable()
//else
//	p_delete.Event ue_disable()
//end If
//
//
end event

type dw_detail from u_d_indicator within w_a_reg_m_m3_sams
event ue_retrieve ( long al_select_row,  ref integer ai_return )
integer x = 32
integer y = 1036
integer width = 3150
integer height = 572
integer taborder = 10
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event ue_init;call super::ue_init;// ib_delete ib_insert 값을 셋팅하여야 함 
// 
end event

event getfocus;call super::getfocus;// ue_init 에서 설정되는 아래의 값에 따라 데이타윈도우별 
// 추가삭제 처리를 조정케 한다. 
ib_insert =  True
ib_delete = True
If ib_insert Then
	p_insert.Event ue_enable()
else
	p_insert.Event ue_disable()
end If


If ib_delete Then
	p_delete.Event ue_enable()
else
	p_delete.Event ue_disable()
end If


end event

event losefocus;call super::losefocus;AcceptText()
end event

event constructor;call super::constructor;SetRowfocusIndicator( off! )
end event

type p_insert from u_p_insert within w_a_reg_m_m3_sams
integer x = 32
integer y = 1648
boolean enabled = false
boolean originalsize = false
end type

type p_delete from u_p_delete within w_a_reg_m_m3_sams
integer x = 325
integer y = 1648
boolean enabled = false
boolean originalsize = false
end type

type p_save from u_p_save within w_a_reg_m_m3_sams
integer x = 622
integer y = 1648
boolean enabled = false
boolean originalsize = false
end type

type p_reset from u_p_reset within w_a_reg_m_m3_sams
integer x = 1321
integer y = 1648
boolean enabled = false
boolean originalsize = false
end type

type dw_detail2 from u_d_indicator within w_a_reg_m_m3_sams
event ue_retrieve ( long al_select_row,  ref integer ai_return )
integer x = 32
integer y = 724
integer width = 3150
integer height = 272
integer taborder = 2
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event getfocus;call super::getfocus;// ue_init 에서 설정되는 아래의 값에 따라 데이타윈도우별 
// 추가삭제 처리를 조정케 한다. 
ib_insert = True
ib_delete = True
If ib_insert Then
	p_insert.Event ue_enable()
else
	p_insert.Event ue_disable()
end If


If ib_delete Then
	p_delete.Event ue_enable()
else
	p_delete.Event ue_disable()
end If


end event

event losefocus;call super::losefocus;AcceptText()
end event

event constructor;call super::constructor;SetRowfocusIndicator( off! )
end event

type st_horizontal2 from statictext within w_a_reg_m_m3_sams
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 32
integer y = 692
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
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= st_horizontal.Y - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If

	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Middle.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
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

type st_horizontal from statictext within w_a_reg_m_m3_sams
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 32
integer y = 1000
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
	If Not (Parent.PointerY() <= idrg_Middle.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Middle.Y + idrg_Middle.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Middle.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
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

type dw_sale from u_d_indicator within w_a_reg_m_m3_sams
integer x = 32
integer y = 312
integer width = 3150
integer taborder = 11
boolean bringtotop = true
end type

event getfocus;call super::getfocus;// ue_init 에서 설정되는 아래의 값에 따라 데이타윈도우별 
// 추가삭제 처리를 조정케 한다. 
ib_insert = True
ib_delete = True
If ib_insert Then
	p_insert.Event ue_enable()
else
	p_insert.Event ue_disable()
end If


If ib_delete Then
	p_delete.Event ue_enable()
else
	p_delete.Event ue_disable()
end If


end event

event losefocus;call super::losefocus;AcceptText()
end event

event constructor;call super::constructor;SetRowfocusIndicator( off! )
end event

