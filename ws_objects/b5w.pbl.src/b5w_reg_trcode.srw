$PBExportHeader$b5w_reg_trcode.srw
$PBExportComments$[kwon-backgu] 거래유형
forward
global type b5w_reg_trcode from w_a_reg_m
end type
end forward

global type b5w_reg_trcode from w_a_reg_m
integer width = 2971
integer height = 2020
end type
global b5w_reg_trcode b5w_reg_trcode

on b5w_reg_trcode.create
call super::create
end on

on b5w_reg_trcode.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;Long ll_rows
String ls_where
String ls_trcod, ls_trcodnm, ls_dctype

//입력 조건 처리 부분
ls_trcod = Trim(dw_cond.Object.trcod[1])
ls_trcodnm = Trim(dw_cond.Object.trcodnm[1])
ls_dctype = Trim(dw_cond.Object.dctype[1])

//Error 처리부분
If IsNull(ls_trcod) Then ls_trcod = ""
If IsNull(ls_trcodnm) Then ls_trcodnm = ""
If IsNull(ls_dctype) Then ls_dctype = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_trcodnm <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "trcodnm like '%" + ls_trcodnm + "%'"
End If

If ls_dctype <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "dctype = '" + ls_dctype + "'"
End If

If ls_trcod <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "trcod like '" + ls_trcod + "%'"
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event type integer ue_extra_save();Long ll_row, ll_rowcount
String ls_trcod, ls_trcodnm

//필수항목 Check
//기타 항목 Check
ll_rowcount = dw_detail.RowCount()
For ll_row = 1 To ll_rowcount
	ls_trcod = Trim(dw_detail.Object.trcod[ll_row])
	ls_trcodnm = Trim(dw_detail.Object.trcodnm[ll_row])

	If IsNull(ls_trcod) Then ls_trcod= ""
	If IsNull(ls_trcodnm) Then ls_trcodnm = ""
	If ls_trcod = "" Then
		f_msg_usr_err(200, Title, "TR Code")
		dw_detail.SetColumn("trcod")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_trcodnm = "" Then
		f_msg_usr_err(200, Title, "Transaction")
		dw_detail.SetColumn("trcodnm")
		dw_detail.SetFocus()
		Return -2
	End If
	
Next

Return 0

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;////Log 정보
//dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
//dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
//dw_detail.Object.updt_user[al_insert_row] = gs_user_id
//dw_detail.Object.updtdt[al_insert_row]		= fdt_get_dbserver_now()
//dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]
//
RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_trcode
integer x = 64
integer y = 60
integer width = 1778
integer height = 204
string dataobject = "b5d_cnd_reg_code_trcode"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_trcode
integer x = 2121
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b5w_reg_trcode
integer x = 2432
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_trcode
integer x = 37
integer width = 1947
integer height = 284
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_trcode
integer x = 334
integer y = 1744
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_trcode
integer x = 37
integer y = 1744
end type

type p_save from w_a_reg_m`p_save within b5w_reg_trcode
integer x = 635
integer y = 1744
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_trcode
integer x = 37
integer y = 300
integer width = 2866
integer height = 1404
string dataobject = "b5dw_reg_trcode"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")

	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_trcode
integer x = 1097
integer y = 1744
end type

