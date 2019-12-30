$PBExportHeader$b5w_prt_payamt_vtel.srw
$PBExportComments$[juede] 입금내역보고서
forward
global type b5w_prt_payamt_vtel from w_a_print
end type
end forward

global type b5w_prt_payamt_vtel from w_a_print
end type
global b5w_prt_payamt_vtel b5w_prt_payamt_vtel

type variables
String is_pos, is_currency_type
end variables

on b5w_prt_payamt_vtel.create
call super::create
end on

on b5w_prt_payamt_vtel.destroy
call super::destroy
end on

event open;call super::open;String ls_currency, ls_desc

is_currency_type = fs_get_control("B0","P105",ls_desc)
//dw_cond.object.currency[1] = is_currency_type

//금액의 소숫점 자리수 가져오기(B5:H200)
is_pos = fs_get_control("B5","H200",ls_desc)
end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_reset();call super::ue_reset;//dw_cond.object.currency[1] = is_currency_type

end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where  , ls_payid  , ls_paynm  , ls_paydtfrom, ls_paydtto
String	ls_trcodnm, ls_paytype, ls_transdtfr, ls_transdtto
String   ls_ctype2, ls_trcod

ls_payid		 = Trim(dw_cond.Object.payid[1])
ls_paydtfrom = Trim(String(dw_cond.object.paydtfrom[1],'yyyymmdd'))
ls_paydtto	 = Trim(String(dw_cond.object.paydtto[1],'yyyymmdd'))
ls_transdtfr	 = Trim(String(dw_cond.object.transdtfr[1],'yyyymmdd'))
ls_transdtto	 = Trim(String(dw_cond.object.transdtto[1],'yyyymmdd'))
ls_ctype2      =Trim(String(dw_cond.object.ctype2[1]))
ls_paytype	 = Trim(dw_cond.Object.paytype[1])
ls_trcodnm	 = Trim(dw_cond.Object.trcodnm[1])
ls_trcod     = Trim(dw_cond.Object.trcod[1])

If IsNull(ls_payid)		Then ls_payid = ""
If IsNull(ls_paydtfrom) Then ls_paydtfrom = ""
If IsNull(ls_paydtto)   Then ls_paydtfrom = ""
If IsNull(ls_transdtfr) Then ls_transdtfr = ""
If IsNull(ls_transdtto) Then ls_transdtto = ""
If IsNull(ls_paytype)   Then ls_paytype = ""
If IsNull(ls_trcodnm)   Then ls_trcodnm = ""
If IsNull(ls_ctype2)    Then ls_ctype2 = ""
If IsNull(ls_trcod)     Then ls_trcod = ""

//Dynamic SQL
ls_where = ""

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where	+= "reqpay.payid = '"+ ls_payid +"' "
End If

If( ls_paydtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(reqpay.paydt, 'YYYYMMDD') >= '"+ ls_paydtfrom +"' "
End If

If( ls_paydtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(reqpay.paydt, 'YYYYMMDD') <= '"+ ls_paydtto +"' "
End If

If (ls_ctype2 <> "") Then
	If( ls_where <> "") Then ls_where += " AND "
	ls_where += "cus.ctype2  = '"+ ls_ctype2 +"' "
End If

If( ls_transdtfr <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(reqpay.transdt, 'YYYYMMDD') >= '"+ ls_transdtfr +"' "
End If

If( ls_transdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(reqpay.transdt, 'YYYYMMDD') <= '"+ ls_transdtto +"' "
End If

If( ls_paytype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "reqpay.paytype = '"+ ls_paytype +"' "
End If

If( ls_trcod <> "") Then
   If( ls_where <> "") Then ls_where +=" AND "
	ls_where += "reqpay.trcod = '"+ ls_trcod + "' "
End If

//모래시계표시
SetPointer (HourGlass! )
dw_list.setredraw(false)

dw_list.is_where  = ls_where
ll_rows = dw_list.retrieve()

If is_pos = "1" Then

	dw_list.object.reqpay_payamt.Format = "#,##0.0"
	dw_list.object.payamt_sum.Format = "#,##0.0"

ElseIf is_pos = "2" Then

	dw_list.object.reqpay_payamt.Format = "#,##0.00"
	dw_list.object.payamt_sum.Format = "#,##0.00"
	
Else
	
	dw_list.object.reqpay_payamt.Format = "#,##0"
	dw_list.object.payamt_sum.Format = "#,##0"

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

type dw_cond from w_a_print`dw_cond within b5w_prt_payamt_vtel
integer width = 2290
integer height = 352
string dataobject = "b5d_cnd_prt_payamt_vtel"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_payamt_vtel
integer x = 2418
integer y = 44
end type

type p_close from w_a_print`p_close within b5w_prt_payamt_vtel
integer x = 2720
integer y = 44
end type

type dw_list from w_a_print`dw_list within b5w_prt_payamt_vtel
integer y = 452
integer height = 1164
string dataobject = "b5dw_prt_payamt_list"
end type

type p_1 from w_a_print`p_1 within b5w_prt_payamt_vtel
end type

type p_2 from w_a_print`p_2 within b5w_prt_payamt_vtel
end type

type p_3 from w_a_print`p_3 within b5w_prt_payamt_vtel
end type

type p_5 from w_a_print`p_5 within b5w_prt_payamt_vtel
end type

type p_6 from w_a_print`p_6 within b5w_prt_payamt_vtel
end type

type p_7 from w_a_print`p_7 within b5w_prt_payamt_vtel
end type

type p_8 from w_a_print`p_8 within b5w_prt_payamt_vtel
end type

type p_9 from w_a_print`p_9 within b5w_prt_payamt_vtel
end type

type p_4 from w_a_print`p_4 within b5w_prt_payamt_vtel
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_payamt_vtel
end type

type p_port from w_a_print`p_port within b5w_prt_payamt_vtel
end type

type p_land from w_a_print`p_land within b5w_prt_payamt_vtel
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_payamt_vtel
integer width = 2350
integer height = 420
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_payamt_vtel
end type

