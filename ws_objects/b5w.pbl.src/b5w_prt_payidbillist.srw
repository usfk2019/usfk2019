$PBExportHeader$b5w_prt_payidbillist.srw
$PBExportComments$[chooys] 고객별 청구내역상세 보고서
forward
global type b5w_prt_payidbillist from w_a_print
end type
end forward

global type b5w_prt_payidbillist from w_a_print
end type
global b5w_prt_payidbillist b5w_prt_payidbillist

type variables
String is_pos, is_currency_type
end variables

on b5w_prt_payidbillist.create
call super::create
end on

on b5w_prt_payidbillist.destroy
call super::destroy
end on

event open;call super::open;String ls_desc

is_currency_type = fs_get_control("B0","P105",ls_desc)
dw_cond.object.currency[1] = is_currency_type


//금액의 소숫점 자리수 가져오기(B5:H200)
is_pos = fs_get_control("B5","H200",ls_desc)
end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_reset();call super::ue_reset;dw_cond.object.currency[1] = is_currency_type

end event

event ue_ok();call super::ue_ok;String ls_trdt
String ls_currency, ls_location, ls_paymethod
Date ld_fromdt
String ls_where
Long ll_rows
Integer li_rc

ls_trdt = String(dw_cond.object.trdt[1], 'yyyymmdd')
ls_currency = Trim(dw_cond.object.currency[1])
ls_location = Trim(dw_cond.object.location[1])
ls_paymethod = Trim(dw_cond.object.pay_method[1])

If IsNull(ls_trdt) Then ls_trdt = ""
If IsNull(ls_currency) Then ls_currency = ""
If IsNull(ls_location) Then ls_location = ""
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

//모래시계표시
SetPointer (HourGlass! )

ls_where = ""
If ls_location <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " cus.location = '" + ls_location + "'"
End If

If ls_paymethod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " bil.pay_method = '" + ls_paymethod + "'"
End If

dw_list.setredraw(false)

dw_list.is_where  = ls_where
ll_rows = dw_list.retrieve(ls_trdt,ls_currency)

//If ls_location = "" Then
//	dw_list.DataObject = "b5dw_prt_payidbillist"
//	dw_list.SetTransObject(SQLCA)
//	ll_rows = dw_list.retrieve(ls_trdt,ls_currency)
//Else
//	dw_list.DataObject = "b5dw_prt_payidbillist_loc"
//	dw_list.SetTransObject(SQLCA)
//	ll_rows = dw_list.retrieve(ls_trdt,ls_currency,ls_location)
//End If

If is_pos = "1" Then
	dw_list.object.reqamtinfo_btramt01.Format = "#,##0.0"
	dw_list.object.reqamtinfo_btramt02.Format = "#,##0.0"
	dw_list.object.reqamtinfo_btramt03.Format = "#,##0.0"
	dw_list.object.reqamtinfo_btramt04.Format = "#,##0.0"
	dw_list.object.reqamtinfo_btramt05.Format = "#,##0.0"
	dw_list.object.reqamtinfo_btramt06.Format = "#,##0.0"
	dw_list.object.btramt30.Format = "#,##0.0"
   dw_list.object.sum1_loc.Format = "#,##0.0"
	dw_list.object.sum2_loc.Format = "#,##0.0"
	dw_list.object.sum3_loc.Format = "#,##0.0"
	dw_list.object.sum4_loc.Format = "#,##0.0"
	dw_list.object.sum5_loc.Format = "#,##0.0"
	dw_list.object.sum6_loc.Format = "#,##0.0"
	dw_list.object.sum7_loc.Format = "#,##0.0"
	dw_list.object.sum8_loc.Format = "#,##0.0"
	dw_list.object.sum9_loc.Format = "#,##0.0"
	dw_list.object.sum10.Format = "#,##0.0"
    dw_list.object.sum1.Format = "#,##0.0"
	dw_list.object.sum2.Format = "#,##0.0"
	dw_list.object.sum3.Format = "#,##0.0"
	dw_list.object.sum4.Format = "#,##0.0"
	dw_list.object.sum5.Format = "#,##0.0"
	dw_list.object.sum6.Format = "#,##0.0"
	dw_list.object.sum7.Format = "#,##0.0"
	dw_list.object.sum8.Format = "#,##0.0"
	dw_list.object.sum9.Format = "#,##0.0"
	dw_list.object.sum10.Format = "#,##0.0"
ElseIf is_pos = "2" Then
	dw_list.object.reqamtinfo_btramt01.Format = "#,##0.00"
	dw_list.object.reqamtinfo_btramt02.Format = "#,##0.00"
	dw_list.object.reqamtinfo_btramt03.Format = "#,##0.00"
	dw_list.object.reqamtinfo_btramt04.Format = "#,##0.00"
	dw_list.object.reqamtinfo_btramt05.Format = "#,##0.00"
	dw_list.object.reqamtinfo_btramt06.Format = "#,##0.00"
	dw_list.object.btramt30.Format = "#,##0.00"
   dw_list.object.sum1_loc.Format = "#,##0.00"
	dw_list.object.sum2_loc.Format = "#,##0.00"
	dw_list.object.sum3_loc.Format = "#,##0.00"
	dw_list.object.sum4_loc.Format = "#,##0.00"
	dw_list.object.sum5_loc.Format = "#,##0.00"
	dw_list.object.sum6_loc.Format = "#,##0.00"
	dw_list.object.sum7_loc.Format = "#,##0.00"
	dw_list.object.sum8_loc.Format = "#,##0.00"
	dw_list.object.sum9_loc.Format = "#,##0.00"
	dw_list.object.sum10.Format = "#,##0.00"
   dw_list.object.sum1.Format = "#,##0.00"
	dw_list.object.sum2.Format = "#,##0.00"
	dw_list.object.sum3.Format = "#,##0.00"
	dw_list.object.sum4.Format = "#,##0.00"
	dw_list.object.sum5.Format = "#,##0.00"
	dw_list.object.sum6.Format = "#,##0.00"
	dw_list.object.sum7.Format = "#,##0.00"
	dw_list.object.sum8.Format = "#,##0.00"
	dw_list.object.sum9.Format = "#,##0.00"
	dw_list.object.sum10.Format = "#,##0.00"
Else
	dw_list.object.reqamtinfo_btramt01.Format = "#,##0"
	dw_list.object.reqamtinfo_btramt02.Format = "#,##0"
	dw_list.object.reqamtinfo_btramt03.Format = "#,##0"
	dw_list.object.reqamtinfo_btramt04.Format = "#,##0"
	dw_list.object.reqamtinfo_btramt05.Format = "#,##0"
	dw_list.object.reqamtinfo_btramt06.Format = "#,##0"
	dw_list.object.btramt30.Format = "#,##0"
   dw_list.object.sum1_loc.Format = "#,##0"
	dw_list.object.sum2_loc.Format = "#,##0"
	dw_list.object.sum3_loc.Format = "#,##0"
	dw_list.object.sum4_loc.Format = "#,##0"
	dw_list.object.sum5_loc.Format = "#,##0"
	dw_list.object.sum6_loc.Format = "#,##0"
	dw_list.object.sum7_loc.Format = "#,##0"
	dw_list.object.sum8_loc.Format = "#,##0"
	dw_list.object.sum9_loc.Format = "#,##0"
	dw_list.object.sum10.Format = "#,##0"
   dw_list.object.sum1.Format = "#,##0"
	dw_list.object.sum2.Format = "#,##0"
	dw_list.object.sum3.Format = "#,##0"
	dw_list.object.sum4.Format = "#,##0"
	dw_list.object.sum5.Format = "#,##0"
	dw_list.object.sum6.Format = "#,##0"
	dw_list.object.sum7.Format = "#,##0"
	dw_list.object.sum8.Format = "#,##0"
	dw_list.object.sum9.Format = "#,##0"
	dw_list.object.sum10.Format = "#,##0"
End If


IF ll_rows > 0 THEN
	
ELSEIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	//모래시계표시 해제
	SetPointer (Arrow! )
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
END IF

//모래시계표시 해제
SetPointer (Arrow! )
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_payidbillist
integer width = 1678
integer height = 300
string dataobject = "b5dw_cnd_prt_payidbillist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_payidbillist
integer x = 1847
integer y = 44
end type

type p_close from w_a_print`p_close within b5w_prt_payidbillist
integer x = 2149
integer y = 44
end type

type dw_list from w_a_print`dw_list within b5w_prt_payidbillist
integer y = 388
integer height = 1240
string dataobject = "b5dw_prt_payidbillist"
end type

type p_1 from w_a_print`p_1 within b5w_prt_payidbillist
end type

type p_2 from w_a_print`p_2 within b5w_prt_payidbillist
end type

type p_3 from w_a_print`p_3 within b5w_prt_payidbillist
end type

type p_5 from w_a_print`p_5 within b5w_prt_payidbillist
end type

type p_6 from w_a_print`p_6 within b5w_prt_payidbillist
end type

type p_7 from w_a_print`p_7 within b5w_prt_payidbillist
end type

type p_8 from w_a_print`p_8 within b5w_prt_payidbillist
end type

type p_9 from w_a_print`p_9 within b5w_prt_payidbillist
end type

type p_4 from w_a_print`p_4 within b5w_prt_payidbillist
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_payidbillist
end type

type p_port from w_a_print`p_port within b5w_prt_payidbillist
end type

type p_land from w_a_print`p_land within b5w_prt_payidbillist
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_payidbillist
integer width = 1733
integer height = 360
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_payidbillist
end type

