$PBExportHeader$b2w_reg_partner_trcode.srw
$PBExportComments$[chooys] Partner 거래유형 Window
forward
global type b2w_reg_partner_trcode from w_a_reg_m
end type
end forward

global type b2w_reg_partner_trcode from w_a_reg_m
integer width = 3086
integer height = 1940
end type
global b2w_reg_partner_trcode b2w_reg_partner_trcode

on b2w_reg_partner_trcode.create
call super::create
end on

on b2w_reg_partner_trcode.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_rows
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
	p_insert.TriggerEvent("ue_enable")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_extra_save;Long ll_row, ll_rowcount
String ls_trcod, ls_trcodnm, ls_commtype

//필수항목 Check
//기타 항목 Check
ll_rowcount = dw_detail.RowCount()
For ll_row = 1 To ll_rowcount
	ls_trcod = Trim(dw_detail.Object.trcod[ll_row])
	ls_trcodnm = Trim(dw_detail.Object.trcodnm[ll_row])
	ls_commtype = Trim(dw_detail.Object.comm_type[ll_row])

	If IsNull(ls_trcod) Then ls_trcod= ""
	If IsNull(ls_trcodnm) Then ls_trcodnm = ""
	If IsNull(ls_commtype) Then ls_commtype = ""
	If ls_trcod = "" Then
		f_msg_usr_err(200, Title, "거래코드")
		dw_detail.SetColumn("trcod")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_trcodnm = "" Then
		f_msg_usr_err(200, Title, "거래명")
		dw_detail.SetColumn("trcodnm")
		dw_detail.SetFocus()
		Return -2
	End If
	If ls_commtype = "" Then
		f_msg_usr_err(200, Title, "거래유형구분")
		dw_detail.SetColumn("comm_type")
		dw_detail.SetFocus()
		Return -2
	End If
Next

Return 0

end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b2w_reg_partner_trcode
integer x = 82
integer y = 40
integer width = 1833
integer height = 168
string dataobject = "b2dw_cnd_partner_trcode"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within b2w_reg_partner_trcode
integer x = 2048
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b2w_reg_partner_trcode
integer x = 2373
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b2w_reg_partner_trcode
integer width = 1920
integer height = 236
end type

type p_delete from w_a_reg_m`p_delete within b2w_reg_partner_trcode
integer x = 329
integer y = 1696
end type

type p_insert from w_a_reg_m`p_insert within b2w_reg_partner_trcode
integer x = 27
integer y = 1696
end type

type p_save from w_a_reg_m`p_save within b2w_reg_partner_trcode
integer x = 631
integer y = 1696
end type

type dw_detail from w_a_reg_m`dw_detail within b2w_reg_partner_trcode
integer x = 27
integer y = 252
integer width = 2981
integer height = 1404
string dataobject = "b2dw_reg_partner_trcode"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b2w_reg_partner_trcode
integer x = 1385
integer y = 1696
end type

