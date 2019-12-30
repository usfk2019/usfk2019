$PBExportHeader$e01w_prt_delaydemand.srw
$PBExportComments$[parkkh] 연체자 요금납입독촉장
forward
global type e01w_prt_delaydemand from w_a_print
end type
end forward

global type e01w_prt_delaydemand from w_a_print
integer width = 3273
end type
global e01w_prt_delaydemand e01w_prt_delaydemand

type variables

end variables

event ue_ok();call super::ue_ok;String ls_where, ls_status_current, ls_txtuser, ls_txtuser_to, ls_amount, ls_work_date, ls_pay_deadlinedt
String ls_module, ls_ref_no, ls_ref_desc, ls_temp, ls_result[], ls_addr_s, ls_sysdt, ls_choice
Date ld_work_date, ld_pay_deadlinedt
Dec{0} lc0_txtuser, lc0_txtuser_to, lc0_amount
Long ll_row
DateTime ldt_sysdt
String ls_last_reqdtfr, ls_last_reqdtto, ls_chargeby
String ls_sender

//1.SYSCTL1T의 사업자 주소
ls_module = "B0"
ls_ref_no = "A102"
ls_ref_desc = ""
ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
If ls_temp = "" Then Return 
fi_cut_string(ls_temp, ";" , ls_result[])
ls_addr_s = ls_result[1]

//2.SYSCTL1T의 보내는 사람
ls_module = "B0"
ls_ref_no = "A103"
ls_ref_desc = ""
ls_sender = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)



ldt_sysdt = fdt_get_dbserver_now()
ls_sysdt = String(ldt_sysdt,"yyyymmdd")

ls_status_current = Trim(dw_cond.Object.status_current[1])
If IsNull(ls_status_current) Then ls_status_current =""
If ls_status_current = "" Then
	f_msg_usr_err(200, Title, "연체상태")
	dw_cond.Setfocus()
	dw_cond.Setcolumn( "status_current" )	
	return
End If

lc0_txtuser = dw_cond.Object.txtuser[1]
ls_txtuser = String(lc0_txtuser)
If IsNull(lc0_txtuser) Then ls_txtuser =""
If ls_txtuser = "" Then
	f_msg_usr_err(200, Title, "연체개월수(from)")
	dw_cond.Setfocus()
	dw_cond.Setcolumn( "txtuser" )	
	return
End If
lc0_txtuser_to = dw_cond.Object.txtuser_to[1]
ls_txtuser_to = String(lc0_txtuser_to)
If IsNull(lc0_txtuser_to) Then ls_txtuser_to =""
//If ls_txtuser_to = "" Then
//	f_msg_usr_err(200, Title, "연체개월수(to)")
//	dw_cond.Setfocus()
//	dw_cond.Setcolumn( "txtuser_to" )	
//	return
//End If

lc0_amount = dw_cond.Object.amount[1]
ls_amount = String(lc0_amount)
If IsNull(lc0_amount) Then lc0_amount = 0

ld_work_date =dw_cond.Object.work_date[1]
ls_work_date = String(ld_work_date,"yyyymmdd")
If IsNull(ld_work_date) Then ls_work_date =""
If ls_work_date = ""  Then
	f_msg_usr_err(200, This.Title, "기준일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("work_date")
	Return
End If

ld_pay_deadlinedt =dw_cond.Object.pay_deadlinedt[1]
ls_pay_deadlinedt = String(ld_pay_deadlinedt,"yyyymmdd")
If IsNull(ld_pay_deadlinedt) Then ls_pay_deadlinedt =""
If ls_pay_deadlinedt = "" Then
	f_msg_usr_err(200, This.Title, "납부마감일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pay_deadlinedt")
	Return
End If

ls_choice = Trim(dw_cond.Object.choice[1])
If IsNull(ls_choice) Then ls_choice= ""
If ls_choice = "" Then
	f_msg_usr_err(200, This.Title, "구분")
	dw_cond.SetFocus()
	dw_cond.SetColumn("choice")
	Return
End If

ls_last_reqdtfr = String(dw_cond.Object.last_reqdtfr[1], "yyyymm")
ls_last_reqdtto = String(dw_cond.Object.last_reqdtto[1], "yyyymm")
ls_chargeby = Trim(dw_cond.Object.chargeby[1])
If IsNull(ls_chargeby) Then ls_chargeby = ""

ls_where = ""

Choose Case ls_choice	
	Case "1" 		
		dw_list.DataObject = "e01dw_prt_delaydemand_1"
	Case "2"
		dw_list.DataObject = "e01dw_prt_delaydemand_2"
End Choose

If ls_status_current <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " Dlymst.status = '" + ls_status_current + "' "
End If

If ls_txtuser <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " dlymst.delay_months >= " + ls_txtuser + " "
End If
If ls_txtuser_to <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " dlymst.delay_months <= " + ls_txtuser_to + " "
End If
If ls_amount <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " Dlymst.amount >= " + ls_amount + " "
End If
If ls_chargeby <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " bil.pay_method = '" + ls_chargeby + "' "
End If
If ls_last_reqdtfr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(dlymst.lastreqdt,'yyyymm') >= '" + ls_last_reqdtfr + "' "
End If
If ls_last_reqdtto <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(dlymst.lastreqdt,'yyyymm') <= '" + ls_last_reqdtto + "' "
End If

dw_list.Object.work_date.Text = MidA(ls_work_date,1,4) + "년 " + MidA(ls_work_date,5,2) +"월 " + MidA(ls_work_date,7,2) +"일" 
dw_list.Object.pay_deadlinedt.Text = MidA(ls_pay_deadlinedt,1,4) + "년 " + MidA(ls_pay_deadlinedt,5,2) +"월 " + MidA(ls_pay_deadlinedt,7,2) +"일" 
dw_list.Object.b1_t.Text = ls_addr_s
dw_list.Object.sysdt.Text = MidA(ls_sysdt,1,4) + "년 " + MidA(ls_sysdt,5,2) +"월 " + MidA(ls_sysdt,7,2) +"일 "
dw_list.Object.sender_t.Text = ls_sender

dw_list.SetTransObject(SQLCA)
dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on e01w_prt_delaydemand.create
call super::create
end on

on e01w_prt_delaydemand.destroy
call super::destroy
end on

event ue_init;call super::ue_init;ii_orientation = 2
ib_header_set = False
end event

event ue_reset;call super::ue_reset;dw_list.Object.work_date.Text = ""
dw_list.Object.pay_deadlinedt.Text = ""
dw_list.Object.b1_t.Text = ""
dw_list.Object.sysdt.Text = ""
end event

type dw_cond from w_a_print`dw_cond within e01w_prt_delaydemand
integer x = 41
integer y = 36
integer width = 2459
integer height = 284
string dataobject = "e01dw_cnd_prt_delaydemand"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within e01w_prt_delaydemand
integer x = 2633
integer y = 44
end type

type p_close from w_a_print`p_close within e01w_prt_delaydemand
integer x = 2939
integer y = 44
end type

type dw_list from w_a_print`dw_list within e01w_prt_delaydemand
integer x = 23
integer y = 364
integer width = 3177
integer height = 1260
string dataobject = "e01dw_prt_delaydemand_1"
boolean controlmenu = true
boolean maxbox = true
end type

type p_1 from w_a_print`p_1 within e01w_prt_delaydemand
integer y = 1676
end type

type p_2 from w_a_print`p_2 within e01w_prt_delaydemand
integer y = 1668
end type

type p_3 from w_a_print`p_3 within e01w_prt_delaydemand
integer y = 1676
end type

type p_5 from w_a_print`p_5 within e01w_prt_delaydemand
integer y = 1676
end type

type p_6 from w_a_print`p_6 within e01w_prt_delaydemand
integer y = 1676
end type

type p_7 from w_a_print`p_7 within e01w_prt_delaydemand
integer y = 1676
end type

type p_8 from w_a_print`p_8 within e01w_prt_delaydemand
integer y = 1676
end type

type p_9 from w_a_print`p_9 within e01w_prt_delaydemand
integer y = 1668
end type

type p_4 from w_a_print`p_4 within e01w_prt_delaydemand
end type

type gb_1 from w_a_print`gb_1 within e01w_prt_delaydemand
integer y = 1632
end type

type p_port from w_a_print`p_port within e01w_prt_delaydemand
end type

type p_land from w_a_print`p_land within e01w_prt_delaydemand
end type

type gb_cond from w_a_print`gb_cond within e01w_prt_delaydemand
integer width = 2510
end type

type p_saveas from w_a_print`p_saveas within e01w_prt_delaydemand
integer y = 1680
end type

