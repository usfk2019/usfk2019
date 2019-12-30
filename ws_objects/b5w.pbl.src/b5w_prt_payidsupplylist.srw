$PBExportHeader$b5w_prt_payidsupplylist.srw
$PBExportComments$[juede] 고객별 청구 공급가액 보고서 - Vtelecom
forward
global type b5w_prt_payidsupplylist from w_a_print
end type
end forward

global type b5w_prt_payidsupplylist from w_a_print
end type
global b5w_prt_payidsupplylist b5w_prt_payidsupplylist

type variables
String is_pos, is_currency_type
end variables

on b5w_prt_payidsupplylist.create
call super::create
end on

on b5w_prt_payidsupplylist.destroy
call super::destroy
end on

event open;call super::open;String ls_currency, ls_desc

is_currency_type = fs_get_control("B0","P105",ls_desc)
dw_cond.object.currency[1] = is_currency_type

//금액의 소숫점 자리수 가져오기(B5:H200)
is_pos = fs_get_control("B5","H200",ls_desc)
end event

event ue_init();call super::ue_init;ii_orientation = 2 //가로 기준
ib_margin = True
end event

event ue_reset();call super::ue_reset;dw_cond.object.currency[1] =is_currency_type

end event

event ue_ok();call super::ue_ok;String ls_trdt, ls_currency
Date ld_fromdt
String ls_where, ls_paymethod, ls_ctype2
Long ll_rows, ll_i
Integer li_rc

ls_trdt = String(dw_cond.object.trdt[1], 'yyyymmdd')
ls_currency = Trim(dw_cond.object.currency[1])
ls_ctype2 = Trim(dw_cond.object.ctype2[1])
ls_paymethod = Trim(dw_cond.object.pay_method[1])

If IsNull(ls_trdt) Then ls_trdt = ""
If IsNull(ls_currency) Then ls_currency = ""
If IsNull(ls_ctype2) Then ls_ctype2 = ""
If IsNull(ls_paymethod) Then ls_paymethod = ""

If ls_trdt = "" Then
	f_msg_info(200, title, "Billing Cycle Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return
End If

If ls_currency = "" Then
	f_msg_info(200, title, "Currency")
	dw_cond.SetFocus()
	dw_cond.SetColumn("currency")
	Return
End If

ls_where = ""
If ls_ctype2 <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "bil.ctype2  = '" + ls_ctype2 + "'"
End If

If ls_paymethod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " bil.pay_method = '" + ls_paymethod + "'"
End If

//모래시계표시
SetPointer (HourGlass! )
dw_list.setredraw(false)

dw_list.is_where  = ls_where
ll_rows = dw_list.retrieve(ls_trdt,ls_currency)

If is_pos = "1" Then

	dw_list.object.reqamtinfo_surtax.Format = "#,##0.0"
	dw_list.object.reqamtinfo_supplyamt.Format = "#,##0.0"

ElseIf is_pos = "2" Then

	dw_list.object.reqamtinfo_surtax.Format = "#,##0.00"
	dw_list.object.reqamtinfo_supplyamt.Format = "#,##0.00"
	
Else
	
	dw_list.object.reqamtinfo_surtax.Format = "#,##0"
	dw_list.object.reqamtinfo_supplyamt.Format = "#,##0"

End If

IF ll_rows > 0 THEN
	
ELSEIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	SetPointer (Arrow! )
	dw_list.setredraw(true)	
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
END IF

dw_list.setredraw(true)
//모래시계표시 해제
SetPointer (Arrow! )
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_payidsupplylist
integer width = 1678
integer height = 296
string dataobject = "b5dw_cnd_prt_payidsupplylist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_payidsupplylist
integer x = 1847
integer y = 44
end type

type p_close from w_a_print`p_close within b5w_prt_payidsupplylist
integer x = 2149
integer y = 44
end type

type dw_list from w_a_print`dw_list within b5w_prt_payidsupplylist
integer y = 376
integer height = 1240
string dataobject = "b5dw_prt_payidsupplylist"
end type

type p_1 from w_a_print`p_1 within b5w_prt_payidsupplylist
end type

type p_2 from w_a_print`p_2 within b5w_prt_payidsupplylist
end type

type p_3 from w_a_print`p_3 within b5w_prt_payidsupplylist
end type

type p_5 from w_a_print`p_5 within b5w_prt_payidsupplylist
end type

type p_6 from w_a_print`p_6 within b5w_prt_payidsupplylist
end type

type p_7 from w_a_print`p_7 within b5w_prt_payidsupplylist
end type

type p_8 from w_a_print`p_8 within b5w_prt_payidsupplylist
end type

type p_9 from w_a_print`p_9 within b5w_prt_payidsupplylist
end type

type p_4 from w_a_print`p_4 within b5w_prt_payidsupplylist
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_payidsupplylist
end type

type p_port from w_a_print`p_port within b5w_prt_payidsupplylist
end type

type p_land from w_a_print`p_land within b5w_prt_payidsupplylist
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_payidsupplylist
integer width = 1733
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_payidsupplylist
end type

