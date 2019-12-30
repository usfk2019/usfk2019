$PBExportHeader$b1w_reg_validkeymst_ws.srw
$PBExportComments$[jsha] route key관리
forward
global type b1w_reg_validkeymst_ws from w_a_reg_m_m
end type
end forward

global type b1w_reg_validkeymst_ws from w_a_reg_m_m
integer width = 3593
integer height = 1932
end type
global b1w_reg_validkeymst_ws b1w_reg_validkeymst_ws

type variables
String is_validkey_type
boolean ib_new
end variables

on b1w_reg_validkeymst_ws.create
call super::create
end on

on b1w_reg_validkeymst_ws.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_customerid, ls_sale_flag, ls_rte_type, ls_in_out_type, ls_new, ls_validkey
String ls_where
Long ll_row

ls_customerid = Trim(dw_cond.Object.customerid[1])
ls_sale_flag = Trim(dw_cond.Object.sale_flag[1])
ls_rte_type = Trim(dw_cond.Object.rte_type[1])
ls_in_out_type = Trim(dw_cond.Object.in_out_type[1])
ls_validkey = Trim(dw_cond.Object.validkey[1])

ls_new = dw_cond.Object.new[1]

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_sale_flag) Then ls_sale_flag = ""
If IsNull(ls_rte_type) Then ls_rte_type = ""
If IsNull(ls_in_out_type) Then ls_in_out_type = ""
If IsNull(ls_validkey) Then ls_validkey = ""

If ls_new = 'Y' Then
	ib_new = true
Else
	ib_new = false
End If

If ib_new Then	//	신규등록
	p_delete.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	This.TriggerEvent("ue_insert")

Else	// 조회
	ls_where = ""
	If ls_customerid <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "validkeymst.customerid = '" + ls_Customerid + "' "
	End If
	If ls_sale_flag <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "validkeymst.sale_flag = '" + ls_sale_flag + "' "
	End If
	If ls_rte_type <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "validkeymst.rte_type = '" + ls_rte_type + "' "
	End If
	If ls_in_out_type <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "validkeymst.in_out_type = '" + ls_in_out_type + "' "
	End If
	If ls_validkey <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += "validkeymst.validkey = '" + ls_validkey + "' "
	End If
	
			
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve(is_validkey_type)
	
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")
		Return
	End If
	
End If
end event

event open;call super::open;String ls_ref_desc

// Route key Type
is_validkey_type = fs_get_control("B1", "P502", ls_ref_desc)
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
//Int li_return

dw_detail.Reset()
dw_master.Reset()
//ii_error_chk = -1

ll_row = dw_detail.InsertRow(0)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return 0
End if

p_save.TriggerEvent("ue_enable")

dw_detail.object.validkey.protect = 0
dw_detail.object.validkey.background.color = RGB(108,147,137)
dw_detail.object.validkey.color = RGB(255,255,255)

dw_detail.Object.systemid.Protect = 0
dw_detail.Object.systemid.Background.Color = RGB(255, 255, 255)
dw_detail.Object.systemid.Color = RGB(0, 0, 0)
dw_detail.Object.systemid.border = '2'
dw_detail.Object.rte_type.Protect = 0
dw_detail.Object.rte_type.Background.Color = RGB(255, 255, 255)
dw_detail.Object.rte_type.Color = RGB(0, 0, 0)
dw_detail.Object.rte_type.border = '2'
dw_detail.Object.in_out_type.Protect = 0
dw_detail.Object.in_out_type.Background.Color = RGB(255, 255, 255)
dw_detail.Object.in_out_type.Color = RGB(0, 0, 0)
dw_detail.Object.in_out_type.border = '2'
dw_detail.Object.sale_flag.Protect = 0
dw_detail.Object.sale_flag.Background.Color = RGB(255, 255, 255)
dw_detail.Object.sale_flag.Color = RGB(0, 0, 0)
dw_detail.Object.sale_flag.border = '2'
dw_detail.Object.remark.Protect = 0
dw_detail.Object.remark.Background.Color = RGB(255, 255, 255)
dw_detail.Object.remark.Color = RGB(0, 0, 0)
dw_detail.Object.remark.border = '2'

Return 0
//ii_error_chk = 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// validkey_type --> route key type
dw_detail.Object.validkey_type[al_insert_row] = is_validkey_type

// log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
				
return 0
end event

event type integer ue_save();String ls_validkey
Int li_curRow
Long ll_master_row

Constant Int LI_ERROR = -1
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

If ib_new Then		// 신규등록 후 Retrieve
	li_curRow = dw_detail.GetRow()
	ls_validkey = Trim(dw_detail.Object.validkey[li_curRow])
	If IsNull(ls_validkey) Then ls_validkey = ""
	
	This.TriggerEvent("ue_reset")
	dw_cond.Object.validkey[1] = ls_validkey
	This.TriggerEvent("ue_ok")
Else		// Edit 후
	//ll_master_row = dw_master.GetSelectedRow(0)
	//dw_detail.Trigger Event ue_retrieve(ll_master_row)
	This.TriggerEvent("ue_reset")
	This.TriggerEvent("ue_ok")
End If

//ii_error_chk = 0
Return 0

end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_validkey, ls_status[], ls_temp, ls_ref_desc
Int li_rowcount, li_curRow, li_return

li_rowcount = dw_detail.RowCount()
If li_rowcount = 0 then return 0

li_curRow = dw_detail.GetRow()

ls_validkey = Trim(dw_detail.Object.validkey[li_curRow])
If IsNull(ls_validkey) Then ls_validkey = ""

// 필수항목 Check
If ls_validkey = "" Then
	f_msg_usr_err(200, This.Title, "Route No.")
	dw_detail.SetRow(li_curRow)
	dw_detail.SetColumn("validkey")
	dw_detail.SetFocus()
	Return -2
End If

ls_temp = fs_get_control("B1", "P400", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_status)

dw_detail.object.status[li_curRow] = ls_status[1]
dw_detail.object.updt_user[li_curRow] = gs_user_id
dw_detail.object.updtdt[li_curRow] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[li_curRow] = gs_pgm_id[gi_max_win_no]

Return 0

end event

event type integer ue_reset();call super::ue_reset;ib_new = False

Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_validkeymst_ws
integer y = 40
integer width = 2738
string dataobject = "b1dw_cnd_reg_validkeymst_ws"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_1_hlp_customerm_carrier"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customernm

Choose Case dwo.name
	Case "customerid"
		If data = "" Then This.Object.customernm[1] = ""
		
		SELECT customernm
		INTO :ls_customernm
		FROM customerm
		WHERE customerid = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_info(9000, title, 'select error')
			Return -1
		End If
		
		If IsNull(ls_customernm) Then
			This.Object.customernm[1] = ""
			Return 0
		End If
		
		This.Object.customernm[1] = ls_customernm
		
End Choose

Return 0
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_validkeymst_ws
integer x = 2921
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_validkeymst_ws
integer x = 3227
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_validkeymst_ws
integer width = 2766
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_validkeymst_ws
integer width = 3013
integer height = 416
string dataobject = "b1dw_m_reg_validkeymst_ws"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.validkey_t
uf_init(ldwo_sort)
end event

event dw_master::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
End If

If rowcount > 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
End If

end event

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
//		p_insert.TriggerEvent('ue_enable') 
//		p_delete.TriggerEvent('ue_enable') 
//		p_save.TriggerEvent('ue_enable') 
		p_reset.TriggerEvent('ue_enable') 
		dw_detail.SetFocus()
	Else
		dw_detail.Reset()
//		p_insert.TriggerEvent('ue_disable') 
//		p_delete.TriggerEvent('ue_disable') 
//		p_save.TriggerEvent('ue_disable') 
		p_reset.TriggerEvent('ue_disable') 
	End If
End If
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_validkeymst_ws
integer x = 37
string dataobject = "b1dw_det_reg_validkeymst_ws"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_validkey, ls_sale_flag
String ls_where
Long ll_row

ls_validkey = dw_master.Object.validkey[al_select_row]
ls_sale_flag = dw_master.Object.sale_flag[al_select_row]

ls_where = " validkey = '" + ls_validkey + "' "
ls_where += " AND validkey_type = '" + is_validkey_type + "' "

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

This.Object.validkey.Protect = 1
This.Object.validkey.Background.Color = RGB(255, 251, 240)
This.Object.validkey.Color = RGB(0, 0, 0)
This.Object.validkey.border = '0'

If ls_sale_flag = '1' Then	//출고상태 --> Edit/Delete 불가능
	This.Object.systemid.Protect = 1
	This.Object.systemid.Background.Color = RGB(255, 251, 240)
	This.Object.systemid.Color = RGB(0, 0, 0)
	This.Object.systemid.border = '0'
	This.Object.rte_type.Protect = 1
	This.Object.rte_type.Background.Color = RGB(255, 251, 240)
	This.Object.rte_type.Color = RGB(0, 0, 0)
	This.Object.rte_type.border = '0'
	This.Object.in_out_type.Protect = 1
	This.Object.in_out_type.Background.Color = RGB(255, 251, 240)
	This.Object.in_out_type.Color = RGB(0, 0, 0)
	This.Object.in_out_type.border = '0'
	This.Object.sale_flag.Protect = 1
	This.Object.sale_flag.Background.Color = RGB(255, 251, 240)
	This.Object.sale_flag.Color = RGB(0, 0, 0)
	This.Object.sale_flag.border = '0'
	This.Object.remark.Protect = 1
	This.Object.remark.Background.Color = RGB(255, 251, 240)
	This.Object.remark.Color = RGB(0, 0, 0)
	This.Object.remark.border = '0'
	
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
Else	// 재고상태 --> Edit/Delete 가능
	This.Object.systemid.Protect = 0
	This.Object.systemid.Background.Color = RGB(255, 255, 255)
	This.Object.systemid.Color = RGB(0, 0, 0)
	This.Object.systemid.border = '2'
	This.Object.rte_type.Protect = 0
	This.Object.rte_type.Background.Color = RGB(255, 255, 255)
	This.Object.rte_type.Color = RGB(0, 0, 0)
	This.Object.rte_type.border = '2'
	This.Object.in_out_type.Protect = 0
	This.Object.in_out_type.Background.Color = RGB(255, 255, 255)
	This.Object.in_out_type.Color = RGB(0, 0, 0)
	This.Object.in_out_type.border = '2'
	This.Object.sale_flag.Protect = 0
	This.Object.sale_flag.Background.Color = RGB(255, 255, 255)
	This.Object.sale_flag.Color = RGB(0, 0, 0)
	This.Object.sale_flag.border = '2'
	This.Object.remark.Protect = 0
	This.Object.remark.Background.Color = RGB(255, 255, 255)
	This.Object.remark.Color = RGB(0, 0, 0)
	This.Object.remark.border = '2'
	
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
End If

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return -1
End If

Return 0
end event

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_validkeymst_ws
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_validkeymst_ws
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_validkeymst_ws
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_validkeymst_ws
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_validkeymst_ws
integer y = 736
end type

