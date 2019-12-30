$PBExportHeader$b1w_reg_bilcheck_x1.srw
$PBExportComments$[jsha] 요금계산 과금정보등록-제너only
forward
global type b1w_reg_bilcheck_x1 from w_a_reg_m
end type
end forward

global type b1w_reg_bilcheck_x1 from w_a_reg_m
end type
global b1w_reg_bilcheck_x1 b1w_reg_bilcheck_x1

on b1w_reg_bilcheck_x1.create
call super::create
end on

on b1w_reg_bilcheck_x1.destroy
call super::destroy
end on

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;// Insert시 Row 상단에 Focus
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("calltype1")

// Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_calltype1, ls_calltype2, ls_inid, ls_flag
Long ll_rows, ll_i

ll_rows = dw_detail.RowCount()

For ll_i = 1 To ll_rows
	ls_calltype1 = Trim(dw_detail.Object.calltype1[ll_i])
	ls_calltype2 = Trim(dw_detail.Object.calltype2[ll_i])
	ls_inid = Trim(dw_detail.Object.inid[ll_i])
	ls_flag = Trim(dw_detail.Object.flag[ll_i])

	If IsNull(ls_calltype1) Then ls_calltype1 = ""
	If IsNull(ls_calltype2) Then ls_calltype2 = ""
	If IsNull(ls_inid) Then ls_inid = ""
	If IsNull(ls_flag) Then ls_flag = ""

	// Mandatory Column Check
	If ls_calltype1 = "" Then
		f_msg_usr_err(200, This.Title, "CDR Type")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("calltype1")
		Return -1
	End If
	
	If ls_calltype2 = "" Then
		f_msg_usr_err(200, This.Title, "Charging Class")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("calltype2")
		Return -1
	End If
	
	If ls_inid = "" Then
		f_msg_usr_err(200, This.Title, "InID")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("inid")
		Return -1
	End If
	
	If ls_flag = "" Then
		f_msg_usr_err(200, This.Title, "과금 Flag")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("flag")
		Return -1
	End If
	
	//Update 한 Log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
   End If
Next

Return 0
end event

event ue_ok();call super::ue_ok;String ls_calltype1, ls_calltype2, ls_flag
Long ll_row
String ls_where

ls_calltype1 = Trim(dw_cond.Object.calltype1[1])
ls_calltype2 = Trim(dw_cond.Object.calltype2[1])
ls_flag = Trim(dw_cond.Object.flag[1])

If IsNull(ls_calltype1) Then ls_calltype1 = ""
If IsNull(ls_calltype2) Then ls_calltype2 = ""
If IsNull(ls_flag) Then ls_flag = ""

// Dynamic SQL
ls_where = ""

If ls_calltype1 <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "calltype1 = '" + ls_calltype1 + "' "
End If

If ls_calltype2 <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "calltype2 = '" + ls_calltype2 + "' "
End If
If ls_flag <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "flag = '" + ls_flag + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 THen
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_bilcheck_x1
integer width = 1989
string dataobject = "b1dw_cnd_reg_bilcheck_x1"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_bilcheck_x1
integer x = 2194
integer y = 76
end type

type p_close from w_a_reg_m`p_close within b1w_reg_bilcheck_x1
integer x = 2510
integer y = 76
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_bilcheck_x1
integer width = 2043
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_bilcheck_x1
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_bilcheck_x1
end type

type p_save from w_a_reg_m`p_save within b1w_reg_bilcheck_x1
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_bilcheck_x1
string dataobject = "b1dw_reg_bilcheck_x1_m"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(OFF!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_bilcheck_x1
end type

