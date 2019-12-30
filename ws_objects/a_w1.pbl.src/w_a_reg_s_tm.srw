$PBExportHeader$w_a_reg_s_tm.srw
$PBExportComments$single master,tab,multi row Register ( from w_a_s_master)
forward
global type w_a_reg_s_tm from w_a_s_master
end type
type p_insert from u_p_insert within w_a_reg_s_tm
end type
type p_delete from u_p_delete within w_a_reg_s_tm
end type
type p_save from u_p_save within w_a_reg_s_tm
end type
type p_reset from u_p_reset within w_a_reg_s_tm
end type
type tab_1 from u_tab_reg within w_a_reg_s_tm
end type
type tab_1 from u_tab_reg within w_a_reg_s_tm
end type
type st_horizontal from statictext within w_a_reg_s_tm
end type
end forward

global type w_a_reg_s_tm from w_a_s_master
integer height = 1928
event type integer ue_insert ( )
event type integer ue_delete ( )
event type integer ue_save ( )
event type integer ue_extra_insert ( long al_insert_row )
event type integer ue_extra_delete ( )
event type integer ue_extra_save ( integer ai_select_tab )
event type integer ue_reset ( )
p_insert p_insert
p_delete p_delete
p_save p_save
p_reset p_reset
tab_1 tab_1
st_horizontal st_horizontal
end type
global w_a_reg_s_tm w_a_reg_s_tm

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app

Boolean ib_retrieve

//AncestorReturnValue사용으로 의미가 없어짐.
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
public subroutine of_resizebars ()
public subroutine of_refreshbars ()
public subroutine of_resizepanels ()
end prototypes

event ue_insert;Constant Int LI_ERROR = -1
Long ll_row
//Int li_return

//ii_error_chk = -1

ll_row = tab_1.idw_tabpage[tab_1.Selectedtab].InsertRow &
			(tab_1.idw_tabpage[tab_1.Selectedtab].GetRow()+1)

tab_1.idw_tabpage[tab_1.Selectedtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[tab_1.Selectedtab].SetRow(ll_row)
tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End If

//ii_error_chk = 0
Return 0

end event

event ue_delete;Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
	tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
	tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
End if

//ii_error_chk = 0
Return 0
end event

event ue_save;Constant Int LI_ERROR = -1
Int li_tab_index//,li_return

//ii_error_chk = -1

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		If tab_1.idw_tabpage[li_tab_index].AcceptText() < 0 Then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title

			iu_cust_db_app.uf_prc_db()
	
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If

			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			Return LI_ERROR
		End If

		If This.Trigger Event ue_extra_save(li_tab_index) < 0 then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title

			iu_cust_db_app.uf_prc_db()
	
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If

			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			f_msg_info(3010,tab_1.is_parent_title,"Save")
			Return LI_ERROR
		End if
		
		If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title

			iu_cust_db_app.uf_prc_db()
	
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If

			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			f_msg_info(3010,tab_1.is_parent_title,"Save")
			Return LI_ERROR
		End If
	End If
Next

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If
	
For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
	End If
Next

f_msg_info(3000,tab_1.is_parent_title,"Save")

//ii_error_chk = 0
Return 0


end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

//ii_error_chk = -1

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
		If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
			(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
			tab_1.SelectedTab = li_tab_index
			li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
			If li_rc <> 1 Then
				Return LI_ERROR
			End if
		End if
	End if	
Next

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False	
Next

dw_master.Reset()
dw_master.InsertRow(0)
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

ib_retrieve = FALSE

//ii_error_chk = 0
Return 0
end event

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
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

For li_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
Next

end subroutine

on w_a_reg_s_tm.create
int iCurrent
call super::create
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.tab_1=create tab_1
this.st_horizontal=create st_horizontal
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_insert
this.Control[iCurrent+2]=this.p_delete
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.tab_1
this.Control[iCurrent+6]=this.st_horizontal
end on

on w_a_reg_s_tm.destroy
call super::destroy
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.tab_1)
destroy(this.st_horizontal)
end on

event closequery;call super::closequery;Int li_tab_index,li_rc

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If Tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
		If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
			(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
			tab_1.SelectedTab = li_tab_index
			li_rc = MessageBox(tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
							,Question!,YesNo!)
			If li_rc <> 1 Then
				Return 1
			End if
		End if
	End if
Next
end event

event close;call super::close;Destroy iu_cust_db_app
end event

event open;call super::open;iu_cust_db_app = Create u_cust_db_app
TriggerEvent("ue_reset")

// Set the Top, Bottom Controls
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

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.tabpage_1.Height - tab_1.idw_tabpage[li_index].Y * 2
	Next

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
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

type dw_cond from w_a_s_master`dw_cond within w_a_reg_s_tm
integer width = 2217
integer taborder = 10
end type

type p_ok from w_a_s_master`p_ok within w_a_reg_s_tm
integer x = 2464
integer y = 52
end type

type p_close from w_a_s_master`p_close within w_a_reg_s_tm
integer x = 2766
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_s_master`gb_cond within w_a_reg_s_tm
end type

type dw_master from w_a_s_master`dw_master within w_a_reg_s_tm
integer y = 320
integer width = 3013
integer height = 412
integer taborder = 0
end type

event retrieveend;If rowcount > 0 Then
	ib_retrieve = True
	Tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

	Tab_1.SetFocus()
	p_save.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
	p_insert.TriggerEvent('ue_enable')
	p_delete.TriggerEvent('ue_enable')

	p_ok.TriggerEvent('ue_disable')
	dw_cond.Enabled =  False
End If

end event

type p_insert from u_p_insert within w_a_reg_s_tm
integer x = 41
integer y = 1700
boolean enabled = false
boolean originalsize = false
end type

type p_delete from u_p_delete within w_a_reg_s_tm
integer x = 334
integer y = 1700
boolean enabled = false
boolean originalsize = false
end type

type p_save from u_p_save within w_a_reg_s_tm
integer x = 631
integer y = 1700
boolean enabled = false
boolean originalsize = false
end type

type p_reset from u_p_reset within w_a_reg_s_tm
integer x = 1152
integer y = 1704
boolean enabled = false
boolean originalsize = false
end type

type tab_1 from u_tab_reg within w_a_reg_s_tm
event type integer ue_tabpage_retrieve ( integer ai_select_tabpage )
integer x = 18
integer y = 768
integer width = 3013
integer height = 892
integer taborder = 20
fontcharset fontcharset = ansi!
long backcolor = 29478337
end type

event ue_tabpage_retrieve;Return 0 //이것이 없으면 자손에서 코딩시 윈도우의 이벤트로 전환된다.
end event

event ue_init;call super::ue_init;iw_parent = Parent
end event

event selectionchanged;call super::selectionchanged;Int li_return

If ib_retrieve = True Then
	If tab_1.ib_tabpage_check[newindex] = False Then
		
		If Trigger Event ue_tabpage_retrieve(newindex) < 0 Then
			Return
		End If
		tab_1.ib_tabpage_check[newindex] = True
	End if
End If
end event

type st_horizontal from statictext within w_a_reg_s_tm
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 18
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

