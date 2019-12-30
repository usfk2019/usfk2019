$PBExportHeader$w_reg_code_group2.srw
$PBExportComments$Different Code Table(from w_a_reg_m)
forward
global type w_reg_code_group2 from w_a_reg_m
end type
end forward

global type w_reg_code_group2 from w_a_reg_m
integer width = 2999
integer height = 1900
end type
global w_reg_code_group2 w_reg_code_group2

on w_reg_code_group2.create
call super::create
end on

on w_reg_code_group2.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_where, ls_where_tmp
String ls_table, ls_table_name, ls_call_name
Long ll_row

//입력 조건 처리 부분
ls_table = Trim(String(dw_cond.Object.table[1]))
ls_table_name = Trim(String(dw_cond.Object.table_name[1]))
ls_call_name = Trim(String(dw_cond.Object.call_name[1]))

//에레 처리부분

//Dynamic SQL 처리부분
If ls_table <> "" Then
	ls_where = "tbl like '" + ls_table + "%'"
End If

If ls_table_name <> "" Then
	ls_where_tmp = "tbl_nm like '" + ls_table_name + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

If ls_call_name <> "" Then
	ls_where_tmp = "call_nm like '" + ls_call_name + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

//윈도우 상태 전환부분
p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
dw_cond.Enabled = False

end event

event ue_reset;call super::ue_reset;p_ok.TriggerEvent("ue_enable")

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_code_group2
integer x = 55
integer y = 52
integer width = 2185
integer height = 220
string dataobject = "d_cnd_code_group2"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_code_group2
integer x = 2350
integer y = 44
end type

type p_close from w_a_reg_m`p_close within w_reg_code_group2
integer x = 2647
integer y = 40
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_code_group2
integer x = 18
integer y = 12
integer width = 2254
end type

type p_delete from w_a_reg_m`p_delete within w_reg_code_group2
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within w_reg_code_group2
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within w_reg_code_group2
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_code_group2
integer x = 37
integer width = 2885
integer height = 1320
string dataobject = "d_reg_code_group2"
end type

type p_reset from w_a_reg_m`p_reset within w_reg_code_group2
integer y = 1664
end type

