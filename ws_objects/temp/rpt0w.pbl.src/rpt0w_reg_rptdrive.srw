$PBExportHeader$rpt0w_reg_rptdrive.srw
$PBExportComments$[parkkh] rptcontrol insert popup window
forward
global type rpt0w_reg_rptdrive from w_a_m_master
end type
type dw_detail from u_d_indicator within rpt0w_reg_rptdrive
end type
type p_insert from u_p_insert within rpt0w_reg_rptdrive
end type
type p_delete from u_p_delete within rpt0w_reg_rptdrive
end type
type p_save from u_p_save within rpt0w_reg_rptdrive
end type
type p_reset from u_p_reset within rpt0w_reg_rptdrive
end type
type st_horizontal from statictext within rpt0w_reg_rptdrive
end type
type st_vertical from statictext within rpt0w_reg_rptdrive
end type
type dw_detail2 from u_d_base within rpt0w_reg_rptdrive
end type
type tv_item from treeview within rpt0w_reg_rptdrive
end type
end forward

global type rpt0w_reg_rptdrive from w_a_m_master
integer width = 3227
integer height = 2024
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
st_vertical st_vertical
dw_detail2 dw_detail2
tv_item tv_item
end type
global rpt0w_reg_rptdrive rpt0w_reg_rptdrive

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

//DataStore	ids_log
String		is_where_cnd
Dragobject	idrg_Left							//Reference to the Top Left control
Dragobject	idrg_Right							//Reference to the Top Right control

String is_cur_levelno, is_cur_leveldes  //현재 levelno, des
String is_insert_flag   //insert 버튼인지 event 인지... Or 
end variables

forward prototypes
public function integer wfi_screen_init ()
public function integer wfi_tv_dts_close ()
public function long wfl_tv_dts_init ()
public subroutine of_resizepanels ()
public subroutine of_resizebars ()
public function long wfl_tv_dts_filter (string as_filter)
public function long wfl_tv_add (integer ai_level, long al_node, string as_label, string as_data)
public function integer wfi_tv_refresh (long al_rows)
public subroutine of_refreshbars ()
end prototypes

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row, ll_rowcount, ll_i
//Int li_return

//ii_error_chk = -1

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

ll_rowcount = dw_detail.rowcount()

For ll_i = 1 To ll_rowcount
	dw_detail.object.seq[ll_i] = ll_i
Next

Return 0
//ii_error_chk = 0
end event

event type integer ue_delete();Constant Int LI_ERROR = -1
Long ll_i, ll_rowcount
//Int li_return

//ii_error_chk = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
End if

ll_rowcount = dw_detail.rowcount()

For ll_i = 1 To ll_rowcount
	dw_detail.object.seq[ll_i] = ll_i
Next

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

event type integer ue_extra_insert(long al_insert_row);long ll_master_row

ll_master_row = dw_master.GetRow()

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.pageno[al_insert_row] = dw_master.object.pageno[ll_master_row]
//dw_detail.object.seq[al_insert_row] = al_insert_row

IF is_insert_flag = "T" Then
	dw_detail.object.loadlevel[al_insert_row] = long(is_cur_levelno)
	dw_detail.object.wkcod[al_insert_row] = "L"
	dw_detail.object.desc_p[al_insert_row] = is_cur_leveldes
End If

Return 0
end event

event type integer ue_extra_save();Long ll_rowcount, ll_i
String ls_wkcod
dec{0} lc_loadlevel

ll_rowcount = dw_detail.rowcount()

For ll_i = 1 To ll_rowcount
	
//	dw_detail.object.seq[ll_i] = ll_i

	ls_wkcod = Trim(dw_detail.Object.wkcod[ll_i])
	If IsNull(ls_wkcod) Then ls_wkcod = ""
	
	If ls_wkcod = "" Then
		f_msg_usr_err(200, Title, "구  분")
		dw_detail.SetFocus()
		dw_detail.SetRow(ll_i)
		dw_detail.SetColumn("wkcod")
		Return -1
	End if
	
	// workcod = "L" Level
	If ls_wkcod = "L" Then
		lc_loadlevel = dw_detail.Object.loadlevel[ll_i]
		If IsNull(lc_loadlevel) Then
			f_msg_usr_err(200, Title, "loadlevel")
			dw_detail.SetFocus()
			dw_detail.SetRow(ll_i)
			dw_detail.SetColumn("loadlevel")
			Return -1
		End If
	End If
	
Next

return 0
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR      //Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_master.Reset()
tv_item.deleteitem(0)
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//ii_error_chk = 0
Return 0
end event

public function integer wfi_screen_init ();Return 0

end function

public function integer wfi_tv_dts_close ();//Destroy ids_log

Return 0

end function

public function long wfl_tv_dts_init ();//Long ll_rows
//
//SetPointer(HourGlass!)
//
//ids_log = Create DataStore
//ids_log.DataObject = "d_dts_log"
//ids_log.SetTransObject(sqlca)
//ll_rows = ids_log.Retrieve()
//
//SetPointer(Arrow!)
//
//Return ll_rows
Return 0
end function

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.
Long		ll_Width, ll_Height

ll_Width = WorkSpaceWidth()
ll_Height = WorkspaceHeight()

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
// Validate the controls.
If Not IsValid(idrg_Right) Or Not IsValid(idrg_Left) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Left processing
idrg_Left.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Left.Resize(st_vertical.X - idrg_Left.X, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

// Bottom Procesing
idrg_Bottom.Move(st_vertical.X + cii_BarThickness, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width - idrg_left.Width - cii_Barthickness, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)
end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
End If

//st_vertical.Y = st_horizontal.Y + st_horizontal.Height

If st_vertical.X < cii_WindowBorder + 150 Then
	st_vertical.X = cii_WindowBorder + 150
End If

If st_vertical.X > WorkSpaceWidth() - 150 - cii_BarThickness Then
	st_vertical.X = WorkSpaceWidth() - 150 - cii_BarThickness
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

st_vertical.Move(st_vertical.X, st_horizontal.Y + cii_BarThickness)
st_vertical.Resize(cii_Barthickness, idrg_bottom.Height)

of_RefreshBars()
end subroutine

public function long wfl_tv_dts_filter (string as_filter);//Long		ll_rows
//String	ls_filter
//
//ls_filter = as_filter
//ids_log.SetFilter(ls_filter)
//ids_log.Filter()
//ll_rows = ids_log.RowCount()

Long		ll_rows
String	ls_where

//ls_where = as_filter
//dw_detail2.is_where = ls_where
ll_rows = dw_detail2.Retrieve()

Return ll_rows

end function

public function long wfl_tv_add (integer ai_level, long al_node, string as_label, string as_data);Long ll_node
TreeViewItem ltvi_new

ltvi_new.Label = as_label
ltvi_new.Data = as_data
ltvi_new.PictureIndex = ai_level + 1

Choose Case ai_level
	Case 0
		ltvi_new.SelectedPictureIndex = ai_level + 1
	Case 1
		ltvi_new.SelectedPictureIndex = ai_level + 2
End Choose

ll_node = tv_item.InsertItemLast(al_node, ltvi_new)

Return ll_node
end function

public function integer wfi_tv_refresh (long al_rows);Boolean lb_skip
Integer li_level
Long ll_row, ll_rows
Long ll_node1, ll_node2, ll_node3
String ls_label, ls_data, ls_levelno, ls_description
String ls_pgm_item

//기존의 Item을 전부 삭제
tv_item.DeleteItem(0)

//Root
li_level = 0
ls_label = "LEVEL NO"
ls_data = "|"
ll_node1 = wfl_tv_add(li_level, 0, ls_label, ls_data)

For ll_row = 1 To al_rows

	ls_levelno = String(dw_detail2.Object.levelno[ll_row])
	ls_description = Trim(dw_detail2.Object.description[ll_row])
	If IsNull(ls_description) Then ls_description = ""
	
	li_level = 1
	ls_label = "[" + ls_levelno + "]" + ls_description 
	ls_data = ls_levelno + "`" + ls_description
	ll_node2 = wfl_tv_add(li_level, ll_node1, ls_label, ls_data)

Next

tv_item.ExpandItem(1)

Return 0
end function

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

//// Force appropriate order
st_vertical.SetPosition(ToTop!)

// Make sure the Width is not lost
st_vertical.Width = cii_BarThickness
end subroutine

on rpt0w_reg_rptdrive.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.st_horizontal=create st_horizontal
this.st_vertical=create st_vertical
this.dw_detail2=create dw_detail2
this.tv_item=create tv_item
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.p_insert
this.Control[iCurrent+3]=this.p_delete
this.Control[iCurrent+4]=this.p_save
this.Control[iCurrent+5]=this.p_reset
this.Control[iCurrent+6]=this.st_horizontal
this.Control[iCurrent+7]=this.st_vertical
this.Control[iCurrent+8]=this.dw_detail2
this.Control[iCurrent+9]=this.tv_item
end on

on rpt0w_reg_rptdrive.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.st_horizontal)
destroy(this.st_vertical)
destroy(this.dw_detail2)
destroy(this.tv_item)
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

// Set the TopLeft, TopRight, and Bottom Controls
idrg_Left = tv_item
idrg_Right = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

//Change the back color so they cannot be seen.
st_vertical.BackColor = BackColor

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

event ue_ok();call super::ue_ok;String ls_pageno_fr, ls_pageno_to, ls_pageno, ls_description, ls_reccod, ls_selection
String ls_where
Long ll_row

ls_pageno_fr = Trim(dw_cond.Object.pageno_fr[1])
ls_pageno_to = Trim(dw_cond.Object.pageno_to[1])
ls_description = Trim(dw_cond.Object.description[1])
ls_selection = Trim(dw_cond.Object.selection[1])

If IsNull(ls_pageno_fr) Then ls_pageno_fr = ""
If IsNull(ls_pageno_to) Then ls_pageno_to = ""
If IsNull(ls_description) Then ls_description = ""
If IsNull(ls_selection) Then ls_selection = ""

//Record NO Valid Check
If ls_pageno_fr <> "" And ls_pageno_to <> "" Then
	If Long(ls_pageno_fr) > Long(ls_pageno_to) Then
		f_msg_usr_err(202,Title,"Page No From")
		dw_cond.SetFocus()
		dw_cond.SetColumn("pageno_fr")
		Return
	End If
End If

//SQL Where절 생성
ls_where = ""
If ls_pageno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " page.pageno >= '" + ls_pageno_fr + "' "
End If

If ls_pageno_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " page.pageno <= '" + ls_pageno_to + "' "
End If

If ls_description <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " page.description like '%" + ls_description + "%' "
End If


//selection...
If ls_selection <> "" Then
	
	Choose Case ls_selection
		Case "A"   //All
			//.....
		Case "U"   //Use
			If ls_where <> "" Then ls_where += " And "
			ls_where += "( page.mark is null or page.mark <> 'D')"
		Case "D"   //Delete
			If ls_where <> "" Then ls_where += " And "
			ls_where += " page.mark = 'D' "
	End Choose
End If
	
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

//TreeView Refresh
ls_where = ""
ll_row = wfl_tv_dts_filter(ls_where)
wfi_tv_refresh(ll_row)
end event

type dw_cond from w_a_m_master`dw_cond within rpt0w_reg_rptdrive
integer width = 2382
integer height = 232
string dataobject = "rpt0dw_cnd_reg_rptdrive"
end type

type p_ok from w_a_m_master`p_ok within rpt0w_reg_rptdrive
integer x = 2565
integer y = 56
end type

type p_close from w_a_m_master`p_close within rpt0w_reg_rptdrive
integer x = 2871
integer y = 56
end type

type gb_cond from w_a_m_master`gb_cond within rpt0w_reg_rptdrive
integer width = 2418
end type

type dw_master from w_a_m_master`dw_master within rpt0w_reg_rptdrive
integer width = 3104
integer height = 408
string dataobject = "rpt0dw_master_reg_rptdrive"
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

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.pageno_t
uf_init(ldwo_SORT)
end event

type dw_detail from u_d_indicator within rpt0w_reg_rptdrive
event type integer ue_retrieve ( long al_select_row )
integer x = 823
integer y = 764
integer width = 2318
integer height = 928
integer taborder = 30
string dataobject = "rpt0dw_detail_reg_rptdrive"
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//dw_master cleck시 Retrieve
String ls_where, ls_pageno
Long ll_row

ls_pageno = dw_master.object.pageno[al_select_row]
If IsNull(ls_pageno) Then ls_pageno = ""

ls_where = ""
If ls_pageno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "pageno = '" + ls_pageno + "'"
End If

//dw_detail 조회
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
//	f_msg_usr_err(2100, Title, "Retrieve()")
//	Return -2
End If

dw_detail.SetRedraw(True)

Return 0
end event

event ue_key;call super::ue_key;If keyflags = 0 Then
	If key = KeyEscape! Then
		Parent.TriggerEvent(is_close)
	End If
End If

end event

event constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event doubleclicked;call super::doubleclicked;//Item Change Event
Long ll_tvi, li_return
String ls_levelno, ls_leveldes, ls_temp, ls_result[]
TreeViewItem ltvi_cur

Choose Case dwo.name
		
	Case "loadlevel"
		
		ll_tvi = tv_item.FindItem(CurrentTreeItem!, 0)
		If ll_tvi = -1 then return 0
		tv_item.GetItem(ll_tvi, ltvi_cur)

		ls_temp = String(ltvi_cur.Data)
		li_return = fi_cut_string(ls_temp, "`", ls_result[])
		
		ls_levelno = ls_result[1]
		ls_leveldes = ls_result[2]		
		
		This.object.loadlevel[row] = long(ls_levelno)
		This.object.desc_p[row] = ls_leveldes
			
	Case "divlevel"
		
		ll_tvi = tv_item.FindItem(CurrentTreeItem!, 0)
		If ll_tvi = -1 then return 0
		tv_item.GetItem(ll_tvi, ltvi_cur)
		
		ls_temp = String(ltvi_cur.Data)
		li_return = fi_cut_string(ls_temp, "`", ls_result[])
		
		ls_levelno = ls_result[1]
		ls_leveldes = ls_result[2]		
		
		This.object.divlevel[row] = long(ls_levelno)

End Choose

Return 0 
end event

event itemchanged;call super::itemchanged;//Item Change Event
Long ll_temp
String ls_temp
Dec lc_temp, lc_levelno
setnull(lc_temp)
setnull(ls_temp)

Choose Case dwo.name
		
	Case "wkcod"
		
		If data = "T" Then
			
			Object.loadlevel[row] = lc_temp
			Object.divlevel[row] = lc_temp
			Object.reverseck[row] = ls_temp
			Object.format[row] = ls_temp
			
 		End IF
		 
	Case "loadlevel"
		
		lc_levelno = Object.loadlevel[row]
		
		If lc_levelno = 0 Then //화면상에선 지워지나 내부적으로 0의 값을 가져서....
		
			SetNull(lc_levelno)                          
			Object.loadlevel[row] = lc_levelno  
			Return 1   /////////////////
			
		ElseIf lc_levelno > 0 Then
	
			If rpt0fb_levelno_check(lc_levelno) Then //levelno가 있다면 Description을 보여준다.
			Else  //levelno가 없다면 다시 입력하게한다.
//				f_msg_usr_err(1100,Title,"LoadLevel에 입력한 Level No(" + String(lc_levelno) + ")가 존재하지 않습니다.")
				SetNull(lc_levelno)
				dw_detail.SetFocus()
				dw_detail.SetColumn("loadlevel")
				dw_detail.ScrollToRow(row)
				dw_detail.Object.loadlevel[row] = lc_levelno
				Return 1
			End If
			
		End If

	Case "divlevel"
		
		lc_levelno = Object.divlevel[row]
		
		If lc_levelno = 0 Then //화면상에선 지워지나 내부적으로 0의 값을 가져서....
		
			SetNull(lc_levelno)                          
			Object.loadlevel[row] = lc_levelno  
			Return 0   /////////////////
			
		ElseIf lc_levelno > 0 Then
	
			If rpt0fb_levelno_check(lc_levelno) Then //levelno가 있다면 Description을 보여준다.
			Else  //levelno가 없다면 다시 입력하게한다.
//				f_msg_usr_err(1100,Title,"LoadLevel에 입력한 Level No(" + String(lc_levelno) + ")가 존재하지 않습니다.")
				SetNull(lc_levelno)
				dw_detail.SetFocus()
				dw_detail.SetColumn("divlevel")
				dw_detail.ScrollToRow(row)
				dw_detail.Object.divlevel[row] = lc_levelno
				Return 1
			End If
			
		End If
		
End Choose

Return 0 
end event

type p_insert from u_p_insert within rpt0w_reg_rptdrive
integer x = 32
integer y = 1712
boolean enabled = false
boolean originalsize = false
end type

event clicked;If fb_enable_button("INSERT", gi_group_auth) Then
	is_insert_flag = 'I'	
	Parent.TriggerEvent('ue_insert')
Else
	Return 0 
End If 
end event

type p_delete from u_p_delete within rpt0w_reg_rptdrive
integer x = 325
integer y = 1716
boolean enabled = false
boolean originalsize = false
end type

type p_save from u_p_save within rpt0w_reg_rptdrive
integer x = 622
integer y = 1716
boolean enabled = false
boolean originalsize = false
end type

type p_reset from u_p_reset within rpt0w_reg_rptdrive
integer x = 1349
integer y = 1716
boolean enabled = false
boolean originalsize = false
end type

type st_horizontal from statictext within rpt0w_reg_rptdrive
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

of_ResizeBars()
of_ResizePanels()
end event

event mouseup;// Hide the bar
BackColor = il_HiddenColor


end event

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.


end event

type st_vertical from statictext within rpt0w_reg_rptdrive
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
event mousedown pbm_lbuttondown
integer x = 791
integer y = 760
integer width = 27
integer height = 540
string dragicon = "Exclamation!"
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string pointer = "SizeWE!"
long textcolor = 255
long backcolor = 255
long bordercolor = 276856960
boolean focusrectangle = false
end type

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = X

	// Refresh the Bar attributes.
	If Not (Parent.PointerX() <= idrg_Left.X + li_MoveLimit Or Parent.PointerX() >= idrg_Right.X + idrg_Right.Width - li_MoveLimit) Then
		X = Parent.PointerX()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Left) Or Not IsValid(idrg_Right) Then Return
	If li_prevposition > idrg_Right.X Then idrg_Right.SetRedraw(True)
	If li_prevposition < idrg_Left.X + idrg_Left.Width Then idrg_Left.SetRedraw(True)
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

type dw_detail2 from u_d_base within rpt0w_reg_rptdrive
boolean visible = false
integer x = 3186
integer y = 36
integer width = 507
integer height = 432
integer taborder = 11
boolean bringtotop = true
string dataobject = "rpt0dw_detail2_reg_rptdrive"
boolean resizable = true
boolean hsplitscroll = true
boolean righttoleft = true
end type

type tv_item from treeview within rpt0w_reg_rptdrive
integer x = 27
integer y = 764
integer width = 759
integer height = 928
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 15793151
borderstyle borderstyle = stylelowered!
string picturename[] = {"Custom051!","Custom066!","SingletonReturn!","tv_menu.gif","CreateIndex!"}
long picturemaskcolor = 12632256
long statepicturemaskcolor = 15793151
end type

event constructor;//***********************************
//Pictures
//***********************************
//1:Step!
//2:Window!
//3:CreateIndex!
//4:EditStops!
//5:SingletonReturn!

end event

event selectionchanged;Integer li_return
String ls_result[]
String ls_where
String ls_temp
TreeViewItem ltvi_cur

GetItem(newhandle, ltvi_cur)
ls_temp = String(ltvi_cur.Data)
If ltvi_cur.Data = "|" Then
	is_cur_levelno = ls_temp	
Else
	li_return = fi_cut_string(ls_temp, "`", ls_result[])
	
	is_cur_levelno = ls_result[1]
	is_cur_leveldes = ls_result[2]
End If


end event

event doubleclicked;If is_cur_levelno <> "|" Then
	
	is_insert_flag = "T"
	
	Trigger Event ue_insert()
		
End IF
end event

