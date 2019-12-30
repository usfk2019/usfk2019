$PBExportHeader$b5w_inq_sendemail.srw
$PBExportComments$[jsha] email발송조회
forward
global type b5w_inq_sendemail from w_a_inq_m
end type
end forward

global type b5w_inq_sendemail from w_a_inq_m
integer width = 3232
end type
global b5w_inq_sendemail b5w_inq_sendemail

on b5w_inq_sendemail.create
call super::create
end on

on b5w_inq_sendemail.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_to_name, ls_chargedt, ls_sender, ls_senddt
Date ld_senddt
String ls_where
Long ll_row

ls_to_name = Trim(dw_cond.Object.to_name[1])
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
ls_sender = Trim(dw_cond.Object.sender[1])
ld_senddt = dw_cond.Object.senddt[1]
ls_senddt = Trim(String(ld_senddt,'yyyymmdd'))

If IsNull(ls_to_name) Then ls_to_name = ""
If IsNull(ls_chargedt) Then ls_chargedt = ""
If IsNull(ls_sender) Then ls_sender = ""
If IsNull(ls_senddt) Then ls_senddt = ""

ls_where = ""

If ls_to_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_name = '" + ls_to_name + "' "
End If
If ls_chargedt <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += "chargedt = '" + ls_chargedt + "' "
End If
If ls_sender <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "sender = '" + ls_sender + "' "
End If
If ls_senddt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(senddt,'yyyymmdd') = '" + ls_senddt + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If

end event

type dw_cond from w_a_inq_m`dw_cond within b5w_inq_sendemail
integer y = 64
integer width = 2240
integer height = 220
string dataobject = "b5dw_cnd_inq_sendemail"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within b5w_inq_sendemail
integer x = 2427
integer y = 56
end type

type p_close from w_a_inq_m`p_close within b5w_inq_sendemail
integer x = 2729
integer y = 56
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_inq_sendemail
integer width = 2277
integer height = 300
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_inq_sendemail
integer width = 3136
string dataobject = "b5dw_inq_sendemail"
boolean ib_sort_use = false
end type

