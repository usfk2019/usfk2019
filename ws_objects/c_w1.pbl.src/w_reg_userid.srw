﻿$PBExportHeader$w_reg_userid.srw
$PBExportComments$Reg : User ID(from w_a_reg_m)
forward
global type w_reg_userid from w_a_reg_m
end type
end forward

global type w_reg_userid from w_a_reg_m
integer width = 3497
integer height = 1920
end type
global w_reg_userid w_reg_userid

on w_reg_userid.create
call super::create
end on

on w_reg_userid.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String ls_where
String ls_userid, ls_empnm
Long ll_row

ls_userid = Trim(String(dw_cond.Object.sle_userid[1]))
ls_empnm = Trim(String(dw_cond.Object.empnm[1]))

If ls_userid <> "" Or Not ISNull(ls_userid) Then
	ls_where = "emp_id like '" + ls_userid + "%'"
End IF
If ls_empnm <> "" Or Not ISNull(ls_empnm) Then
	ls_where = "empnm like '" + ls_empnm + "%'"
End IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

end event

event ue_extra_save;Date ld_now
Long ll_mrow_cnt, ll_row_cnt, i
String ls_emp_auth

ll_row_cnt = dw_detail.RowCount()
If ll_row_cnt = 0 Then Return 0 
For i = 1 To ll_row_cnt
	ls_emp_auth = String(dw_detail.object.emp_auth[i])
	If IsNull(ls_emp_auth) Then ls_emp_auth = ""
	If ls_emp_auth = "" Then
		f_msg_usr_err(200, Title, "Authority")
		dw_detail.SetFocus()
		dw_detail.scrolltorow(i)
		dw_detail.SetColumn("emp_auth")
		Return -2
	End If
Next
//***** Record when modified or created ****
//Read today & current time
iu_cust_db_app.is_caller = "NOW"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then Return -1

ld_now = Date(iu_cust_db_app.idt_data[1])

//Record
ll_row_cnt = dw_detail.RowCount()

Do While ll_mrow_cnt <= ll_row_cnt
	ll_mrow_cnt = dw_detail.GetNextModified(ll_mrow_cnt, Primary!)
	If ll_mrow_cnt > 0 Then
		dw_detail.Object.upd_dt[ll_mrow_cnt] = ld_now
	Else
		ll_mrow_cnt = ll_row_cnt + 1
	End If
Loop

Return 0

end event

type dw_cond from w_a_reg_m`dw_cond within w_reg_userid
integer y = 64
integer width = 1330
integer height = 212
string dataobject = "d_cnd_userid"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m`p_ok within w_reg_userid
integer x = 1563
integer y = 44
end type

type p_close from w_a_reg_m`p_close within w_reg_userid
integer x = 1870
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within w_reg_userid
integer width = 1422
end type

type p_delete from w_a_reg_m`p_delete within w_reg_userid
integer y = 1692
end type

type p_insert from w_a_reg_m`p_insert within w_reg_userid
integer y = 1692
end type

type p_save from w_a_reg_m`p_save within w_reg_userid
integer y = 1692
end type

type dw_detail from w_a_reg_m`dw_detail within w_reg_userid
integer y = 304
integer width = 3401
integer height = 1364
string dataobject = "d_reg_userid"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within w_reg_userid
integer y = 1692
end type
