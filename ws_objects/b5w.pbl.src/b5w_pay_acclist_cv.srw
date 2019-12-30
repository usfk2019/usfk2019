$PBExportHeader$b5w_pay_acclist_cv.srw
$PBExportComments$[chooys] 입금정산보고서 Window
forward
global type b5w_pay_acclist_cv from w_a_print
end type
end forward

global type b5w_pay_acclist_cv from w_a_print
end type
global b5w_pay_acclist_cv b5w_pay_acclist_cv

type variables
String is_format
String is_chk
String is_currency
end variables

on b5w_pay_acclist_cv.create
call super::create
end on

on b5w_pay_acclist_cv.destroy
call super::destroy
end on

event open;call super::open;String ls_desc

dw_cond.object.trdt[1] = Date(fdt_get_dbserver_now())

//금액의 소숫점 자리수 가져오기(B5:H200)
is_format = fs_get_control("B5","H200",ls_desc)

end event

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long ll_rc, ll_rows
String ls_where
String ls_trdt, ls_trdtfr, ls_trdtto
Date ld_trdate


//필수입력사항 check
ls_trdt = String(dw_cond.Object.trdt[1], "yyyymm")
If Isnull(ls_trdt) Then ls_trdt = ""				
	

//***** 사용자 입력사항 검증 *****
If ls_trdt = "" Then
	f_msg_info(200, Title, "입금거래년월")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdt")
	Return
End If


If is_format = "1" Then
	dw_list.object.paytot.Format = "#,##0.0"
	dw_list.object.paycur.Format = "#,##0.0"
	dw_list.object.paypre.Format = "#,##0.0"
	dw_list.object.sum_tot.Format = "#,##0.0"
	dw_list.object.sum_cur.Format = "#,##0.0"
	dw_list.object.sum_pre.Format = "#,##0.0"
ElseIf is_format = "2" Then
	dw_list.object.paytot.Format = "#,##0.00"
	dw_list.object.paycur.Format = "#,##0.00"
	dw_list.object.paypre.Format = "#,##0.00"
	dw_list.object.sum_tot.Format = "#,##0.00"
	dw_list.object.sum_cur.Format = "#,##0.00"
	dw_list.object.sum_pre.Format = "#,##0.00"
Else
	dw_list.object.paytot.Format = "#,##0"
	dw_list.object.paycur.Format = "#,##0"
	dw_list.object.paypre.Format = "#,##0"
	dw_list.object.sum_tot.Format = "#,##0"
	dw_list.object.sum_cur.Format = "#,##0"
	dw_list.object.sum_pre.Format = "#,##0"
End If


ll_rows = dw_list.Retrieve(ls_trdt)
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_cond.object.trdt[1] = Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within b5w_pay_acclist_cv
integer width = 878
integer height = 164
string dataobject = "b5dw_cnd_pay_acclist_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_pay_acclist_cv
integer x = 997
integer y = 48
end type

type p_close from w_a_print`p_close within b5w_pay_acclist_cv
integer x = 1298
integer y = 48
end type

type dw_list from w_a_print`dw_list within b5w_pay_acclist_cv
integer y = 248
integer height = 1372
string dataobject = "b5dw_prt_pay_acclist_cv"
end type

type p_1 from w_a_print`p_1 within b5w_pay_acclist_cv
end type

type p_2 from w_a_print`p_2 within b5w_pay_acclist_cv
end type

type p_3 from w_a_print`p_3 within b5w_pay_acclist_cv
end type

type p_5 from w_a_print`p_5 within b5w_pay_acclist_cv
end type

type p_6 from w_a_print`p_6 within b5w_pay_acclist_cv
end type

type p_7 from w_a_print`p_7 within b5w_pay_acclist_cv
end type

type p_8 from w_a_print`p_8 within b5w_pay_acclist_cv
end type

type p_9 from w_a_print`p_9 within b5w_pay_acclist_cv
end type

type p_4 from w_a_print`p_4 within b5w_pay_acclist_cv
end type

type gb_1 from w_a_print`gb_1 within b5w_pay_acclist_cv
end type

type p_port from w_a_print`p_port within b5w_pay_acclist_cv
end type

type p_land from w_a_print`p_land within b5w_pay_acclist_cv
end type

type gb_cond from w_a_print`gb_cond within b5w_pay_acclist_cv
integer width = 910
integer height = 220
end type

type p_saveas from w_a_print`p_saveas within b5w_pay_acclist_cv
end type

