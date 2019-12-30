$PBExportHeader$b5w_reg_reqpgmbase_v20.srw
$PBExportComments$[khpark] 청구주기별 청구절차메뉴정의
forward
global type b5w_reg_reqpgmbase_v20 from w_a_reg_m
end type
end forward

global type b5w_reg_reqpgmbase_v20 from w_a_reg_m
integer width = 2386
integer height = 2020
end type
global b5w_reg_reqpgmbase_v20 b5w_reg_reqpgmbase_v20

type variables
string is_chargedt
end variables

on b5w_reg_reqpgmbase_v20.create
call super::create
end on

on b5w_reg_reqpgmbase_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where
String ls_pgm_id

//입력 조건 처리 부분
is_chargedt = Trim(dw_cond.Object.chargedt[1])
ls_pgm_id = Trim(dw_cond.Object.pgm_id[1])

//Error 처리부분
If IsNull(is_chargedt) Then is_chargedt = ""
If is_chargedt = "" Then
	f_msg_info(200, Title, "청구주기")
	dw_cond.SetFocus()
	dw_cond.setColumn("chargedt")
	Return 
End If


If IsNull(ls_pgm_id) Then ls_pgm_id = ""

//Dynamic SQL 처리부분
ls_where = ""
If is_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "reqpgmbase.chargedt = '" + is_chargedt + "'"
End If

If ls_pgm_id <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += "reqpgmbase.pgm_id = '" + ls_pgm_id + "'"
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
String ls_pgm_id, ls_chargedt

//필수항목 Check
//기타 항목 Check
ll_rowcount = dw_detail.RowCount()
For ll_row = 1 To ll_rowcount
	ls_chargedt = Trim(dw_detail.Object.chargedt[ll_row])
	ls_pgm_id = Trim(dw_detail.Object.pgm_id[ll_row])

	If IsNull(ls_chargedt) Then ls_chargedt = ""
	If IsNull(ls_pgm_id) Then ls_pgm_id= ""

	If ls_chargedt = "" Then
		f_msg_usr_err(200, Title, "청구주기")
		dw_detail.SetColumn("chargedt")
		dw_detail.SetFocus()
		Return -2
	End If
	
	If ls_pgm_id = "" Then
		f_msg_usr_err(200, Title, "청구절차코드")
		dw_detail.SetColumn("pgm_id")
		dw_detail.SetFocus()
		Return -2
	End If

Next

Return 0

end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;////Log 정보
dw_detail.Object.crt_user[al_insert_row] 	= gs_user_id
dw_detail.Object.crtdt[al_insert_row] 		= fdt_get_dbserver_now()
dw_detail.Object.chargedt[al_insert_row] 	= is_chargedt


RETURN 0
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqpgmbase_v20
integer x = 64
integer y = 64
integer width = 1431
integer height = 204
string dataobject = "b5d_cnd_reg_reqpgmbase_v20"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqpgmbase_v20
integer x = 1614
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqpgmbase_v20
integer x = 1925
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqpgmbase_v20
integer x = 37
integer width = 1486
integer height = 284
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqpgmbase_v20
integer x = 334
integer y = 1744
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqpgmbase_v20
integer x = 37
integer y = 1744
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqpgmbase_v20
integer x = 635
integer y = 1744
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqpgmbase_v20
integer x = 37
integer y = 300
integer width = 2272
integer height = 1404
string dataobject = "b5dw_reg_reqpgmbase_v20"
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

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqpgmbase_v20
integer x = 1097
integer y = 1744
end type

