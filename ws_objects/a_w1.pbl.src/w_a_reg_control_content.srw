$PBExportHeader$w_a_reg_control_content.srw
$PBExportComments$Parameter Setting Ancestor(from w_a_reg_m)
forward
global type w_a_reg_control_content from w_a_reg_m
end type
end forward

global type w_a_reg_control_content from w_a_reg_m
integer width = 3095
integer height = 1952
end type
global w_a_reg_control_content w_a_reg_control_content

type variables
//해당 Module 정보
String is_module
end variables

on w_a_reg_control_content.create
call super::create
end on

on w_a_reg_control_content.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_where, ls_where_tmp
String ls_ref_no, ls_ref_desc
Long ll_row

//입력 조건 처리 부분
ls_ref_no = Trim(String(dw_cond.Object.ref_no[1]))
ls_ref_desc = Trim(String(dw_cond.Object.ref_desc[1]))

//에레 처리부분

//Dynamic SQL 처리부분
ls_where = "module = '" + is_module + "'"

If ls_ref_no <> "" Then
	ls_where_tmp = "ref_no like '" + ls_ref_no + "%'"

	If ls_where <> "" Then
		ls_where = ls_where + " and " + ls_where_tmp
	Else
		ls_where = ls_where_tmp
	End If
End If

If ls_ref_desc <> "" Then
	ls_where_tmp = "ref_desc like '" + ls_ref_desc + "%'"

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

////윈도우 상태 전환부분
//p_insert.TriggerEvent("ue_enable")
//p_delete.TriggerEvent("ue_enable")
//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//dw_cond.Enabled = False
//dw_detail.SetFocus()
end event

event ue_extra_save;Return 0

//Date ld_now
//Long ll_mrow_cnt, ll_row_cnt
//
////***** Record when modified or created ****
////Read today & current time
//iu_cust_db_app.is_caller = "NOW"
//iu_cust_db_app.is_title = This.Title
//
//iu_cust_db_app.uf_prc_db()
//
//If iu_cust_db_app.ii_rc = -1 Then Return
//
//ld_now = Date(iu_cust_db_app.idt_data[1])
//
////Record
//ll_row_cnt = dw_detail.RowCount()
//
//Do While ll_mrow_cnt <= ll_row_cnt
//	ll_mrow_cnt = dw_detail.GetNextModified(ll_mrow_cnt, Primary!)
//	If ll_mrow_cnt > 0 Then
//		dw_detail.Object.reg_dt[ll_mrow_cnt] = ld_now
//	Else
//		ll_mrow_cnt = ll_row_cnt + 1
//	End If
//Loop
//

end event

event open;call super::open;p_insert.Visible = False
p_delete.Visible = False
end event

type dw_cond from w_a_reg_m`dw_cond within w_a_reg_control_content
integer x = 55
integer y = 60
integer width = 1938
integer height = 116
string dataobject = "d_cnd_control_content"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_a_reg_control_content
integer x = 2574
integer y = 24
end type

type p_close from w_a_reg_m`p_close within w_a_reg_control_content
integer x = 2574
integer y = 132
end type

type gb_cond from w_a_reg_m`gb_cond within w_a_reg_control_content
integer height = 220
end type

type p_delete from w_a_reg_m`p_delete within w_a_reg_control_content
integer x = 329
integer y = 1724
end type

type p_insert from w_a_reg_m`p_insert within w_a_reg_control_content
integer x = 37
integer y = 1724
end type

type p_save from w_a_reg_m`p_save within w_a_reg_control_content
integer y = 1724
end type

type dw_detail from w_a_reg_m`dw_detail within w_a_reg_control_content
integer y = 240
integer width = 2990
integer height = 1452
string dataobject = "d_reg_control_content"
end type

type p_reset from w_a_reg_m`p_reset within w_a_reg_control_content
integer y = 1724
end type

