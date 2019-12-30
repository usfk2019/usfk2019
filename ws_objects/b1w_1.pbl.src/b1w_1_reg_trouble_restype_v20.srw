$PBExportHeader$b1w_1_reg_trouble_restype_v20.srw
$PBExportComments$[jsha] 민원조치유형등록
forward
global type b1w_1_reg_trouble_restype_v20 from w_a_reg_m
end type
end forward

global type b1w_1_reg_trouble_restype_v20 from w_a_reg_m
integer width = 2981
integer height = 1424
windowstate windowstate = normal!
end type
global b1w_1_reg_trouble_restype_v20 b1w_1_reg_trouble_restype_v20

on b1w_1_reg_trouble_restype_v20.create
call super::create
end on

on b1w_1_reg_trouble_restype_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_restype, ls_restypenm
String ls_where
Long ll_row

ls_restype = fs_snvl(dw_cond.Object.restype[1], "")
ls_restypenm = fs_snvl(dw_cond.Object.restypenm[1], "")

ls_where = ""

If ls_restype <> "" Then
	ls_where += " restype = '" + ls_restype + "' "
End If
If ls_restypenm <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " restypenm = '" + ls_restypenm + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.TItle, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.TItle, "")
End IF

end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_rownum, ll_cnt
String ls_restype, ls_restypenm

ll_rownum = dw_detail.RowCount()
If ll_rownum <= 0 Then Return 0

For ll_cnt = 1 To ll_rownum
	ls_restype = fs_snvl(dw_detail.Object.restype[ll_cnt], "")
	ls_restypenm = fs_snvl(dw_detail.Object.restypenm[ll_cnt], "")
	
	If ls_restype = "" Then
		f_msg_usr_Err(200, This.Title, "조치유형코드")
		dw_detail.SetRow(ll_cnt)
		dw_detail.SetColumn("restype")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_restypenm = "" Then
		f_msg_usr_Err(200, This.Title, "조치유형명")
		dw_detail.SetRow(ll_cnt)
		dw_detail.SetColumn("restypenm")
		dw_detail.SetFocus()
		Return -2
	End If
	
	// Log
	If dw_detail.GetItemStatus(ll_cnt, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_cnt] = gs_user_id
		dw_detail.object.updtdt[ll_cnt] = fdt_get_dbserver_now()
		dw_detail.Object.pgm_id[ll_cnt] = gs_pgm_id[gi_open_win_no]
	End If
Next

Return 0
end event

event open;call super::open;p_insert.TriggerEvent("ue_enable")
dw_detail.SetRowFocusIndicator(off!)
end event

event type integer ue_reset();call super::ue_reset;p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;dw_detail.Object.crt_user[al_insert_row] = gs_user_id
dw_detail.Object.crtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0
end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_1_reg_trouble_restype_v20
integer width = 2075
integer height = 200
string dataobject = "b1dw_1_cnd_reg_trouble_restype_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_1_reg_trouble_restype_v20
integer x = 2290
end type

type p_close from w_a_reg_m`p_close within b1w_1_reg_trouble_restype_v20
integer x = 2597
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_1_reg_trouble_restype_v20
integer width = 2135
integer height = 256
end type

type p_delete from w_a_reg_m`p_delete within b1w_1_reg_trouble_restype_v20
integer y = 1196
end type

type p_insert from w_a_reg_m`p_insert within b1w_1_reg_trouble_restype_v20
integer y = 1196
end type

type p_save from w_a_reg_m`p_save within b1w_1_reg_trouble_restype_v20
integer y = 1196
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_1_reg_trouble_restype_v20
integer y = 268
integer width = 2176
integer height = 896
string dataobject = "b1dw_1_reg_trouble_restype_v20"
end type

type p_reset from w_a_reg_m`p_reset within b1w_1_reg_trouble_restype_v20
integer y = 1196
end type

