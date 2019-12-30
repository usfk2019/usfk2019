$PBExportHeader$b5w_prt_reqdtl_list.srw
$PBExportComments$[parkkh] 기간별 거래내역서 window
forward
global type b5w_prt_reqdtl_list from w_a_print
end type
end forward

global type b5w_prt_reqdtl_list from w_a_print
end type
global b5w_prt_reqdtl_list b5w_prt_reqdtl_list

type variables
String is_format
end variables

on b5w_prt_reqdtl_list.create
call super::create
end on

on b5w_prt_reqdtl_list.destroy
call super::destroy
end on

event ue_init;call super::ue_init;ii_orientation = 2
ib_margin = False
end event

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;Long ll_rc, ll_rows
String ls_where
String ls_trdtfr, ls_trdtto, ls_currency

//필수입력사항 check
ls_trdtfr = String(dw_cond.Object.trdtfr[1], "yyyymmdd")
ls_trdtto = String(dw_cond.Object.trdtto[1], "yyyymmdd")
ls_currency = Trim(dw_cond.object.currency_type[1])
If IsNull(ls_currency) Then ls_currency = ""
If Isnull(ls_trdtfr) Then ls_trdtfr = ""				
If Isnull(ls_trdtto) Then ls_trdtto = ""				

//***** 사용자 입력사항 검증 *****
If ls_trdtfr = "" Then
	f_msg_info(200, Title, "Transaction Date(From)")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdtfr")
	Return
End If

If ls_trdtto = "" Then
	f_msg_info(201, Title, "Transaction Date(To)")
	dw_cond.setfocus()
	dw_cond.SetColumn("trdtto")
	Return
End If

If ls_trdtto <> "" Then
	If ls_trdtfr <> "" Then
		If ls_trdtfr > ls_trdtto Then
			f_msg_info(200, Title, "일자(From) <= 일자(To)")
			Return
		End If
	End If
End If


dw_list.Object.paydt_text.Text ="거래기간 : " +String(ls_trdtfr, "@@@@-@@-@@") + " ~~ " + String(ls_trdtto, "@@@@-@@-@@")

If is_format = "1" Then
	dw_list.object.reqdtl_tramt.Format = "#,##0.0"
   dw_list.object.sum_tramt.Format = "#,##0.0"
	dw_list.object.sum_sale.Format = "#,##0.0"
	dw_list.object.sum_in.Format = "#,##0.0"
ElseIf is_format = "2" Then
	dw_list.object.reqdtl_tramt.Format = "#,##0.00"
	dw_list.object.sum_tramt.Format = "#,##0.00"
	dw_list.object.sum_sale.Format = "#,##0.00"
	dw_list.object.sum_in.Format = "#,##0.00"
Else
	dw_list.object.reqdtl_tramt.Format = "#,##0"
	dw_list.object.sum_tramt.Format = "#,##0"
	dw_list.object.sum_sale.Format = "#,##0"
	dw_list.object.sum_in.Format = "#,##0"
End If

ll_rows = dw_list.Retrieve(ls_trdtfr,ls_trdtto, ls_currency)
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If
end event

event open;call super::open;Date ld_sysdate
String ls_ref_desc

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.trdtfr[1] = f_mon_first_date(ld_sysdate)
dw_cond.object.trdtto[1] = f_mon_last_date(ld_sysdate)

is_format = fs_get_control("B5", "H200", ls_ref_desc)

return


end event

event ue_reset();call super::ue_reset;Date ld_sysdate

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.trdtfr[1] = f_mon_first_date(ld_sysdate)
dw_cond.object.trdtto[1] = f_mon_last_date(ld_sysdate)

Return


end event

type dw_cond from w_a_print`dw_cond within b5w_prt_reqdtl_list
integer y = 60
integer width = 1243
integer height = 224
string dataobject = "b5dw_cnd_prt_reqdtl_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::buttonclicked;//String ls_paydt
//Datetime ldt_tdtime
//
//
//
//dw_cond.SetColumn("paydt")
//
//ls_paydt = Trim(dw_cond.Object.paydt[row])
//If IsNull(ls_paydt) Then ls_paydt = ""
//
//If ls_paydt = "" Then 
//	ldt_tdtime = fdt_get_dbserver_now()
//	dw_cond.Object.paydt[row] = String(Date(ldt_tdtime),"yyyymm")
//End if
//
//Choose Case dwo.Name
//	Case "up"
//		If Mid(ls_paydt,5,2) < "12" Then
//			ls_paydt = String(Dec(ls_paydt) + 1)
//			dw_cond.Object.paydt[row] = ls_paydt
//		Else 
//			ls_paydt = String(Dec(Mid(ls_paydt,1,4)) + 1) + "01"
//			dw_cond.Object.paydt[row] = ls_paydt
//		End if
//		
//	Case "down"
//		If Mid(ls_paydt,5,2) > "01" And Mid(ls_paydt,5,2) <= "12" Then
//			ls_paydt = String(Dec(ls_paydt) - 1)
//			dw_cond.Object.paydt[row] = ls_paydt
//		Elseif Mid(ls_paydt,5,2) <= "01" Then
//			ls_paydt = String(Dec(Mid(ls_paydt,1,4)) - 1) + "12"
//			dw_cond.Object.paydt[row] = ls_paydt
//		Else
//			ls_paydt = String(Dec(Mid(ls_paydt,1,4))) + "12"
//			dw_cond.Object.paydt[row] = ls_paydt
//		End if
//
//End Choose
//
//
Return 0

end event

event dw_cond::ue_key;call super::ue_key;String ls_paydt
Datetime ldt_tdtime


Choose Case key
	Case KeyUpArrow!
		
		dw_cond.SetColumn("paydt")
		
		ls_paydt = Trim(dw_cond.Object.paydt[1])
		If IsNull(ls_paydt) Then ls_paydt = ""
		
		If ls_paydt = "" Then 
			ldt_tdtime = fdt_get_dbserver_now()
			dw_cond.Object.paydt[1] = String(Date(ldt_tdtime),"yyyymm")
		End if
		
		If MidA(ls_paydt,5,2) < "12" Then
			ls_paydt = String(Dec(ls_paydt) + 1)
			dw_cond.Object.paydt[1] = ls_paydt
		Else 
			ls_paydt = String(Dec(MidA(ls_paydt,1,4)) + 1) + "01"
			dw_cond.Object.paydt[1] = ls_paydt
		End if
		
	Case KeyDownArrow!
		
		dw_cond.SetColumn("paydt")
		
		ls_paydt = Trim(dw_cond.Object.paydt[1])
		If IsNull(ls_paydt) Then ls_paydt = ""
		
		If ls_paydt = "" Then 
			ldt_tdtime = fdt_get_dbserver_now()
			dw_cond.Object.paydt[1] = String(Date(ldt_tdtime),"yyyymm")
		End if

		If MidA(ls_paydt,5,2) > "01" And MidA(ls_paydt,5,2) <= "12" Then
			ls_paydt = String(Dec(ls_paydt) - 1)
			dw_cond.Object.paydt[1] = ls_paydt
		Elseif MidA(ls_paydt,5,2) <= "01" Then
			ls_paydt = String(Dec(MidA(ls_paydt,1,4)) - 1) + "12"
			dw_cond.Object.paydt[1] = ls_paydt
		Else
			ls_paydt = String(Dec(MidA(ls_paydt,1,4))) + "12"
			dw_cond.Object.paydt[1] = ls_paydt
		End if

End Choose


Return 0

end event

type p_ok from w_a_print`p_ok within b5w_prt_reqdtl_list
integer x = 1568
integer y = 56
end type

type p_close from w_a_print`p_close within b5w_prt_reqdtl_list
integer x = 1874
integer y = 56
end type

type dw_list from w_a_print`dw_list within b5w_prt_reqdtl_list
integer x = 27
integer y = 356
integer width = 3022
integer height = 1220
string dataobject = "b5dw_prt_reqdtl_list"
end type

type p_1 from w_a_print`p_1 within b5w_prt_reqdtl_list
integer x = 2688
end type

type p_2 from w_a_print`p_2 within b5w_prt_reqdtl_list
end type

type p_3 from w_a_print`p_3 within b5w_prt_reqdtl_list
end type

type p_5 from w_a_print`p_5 within b5w_prt_reqdtl_list
end type

type p_6 from w_a_print`p_6 within b5w_prt_reqdtl_list
end type

type p_7 from w_a_print`p_7 within b5w_prt_reqdtl_list
end type

type p_8 from w_a_print`p_8 within b5w_prt_reqdtl_list
end type

type p_9 from w_a_print`p_9 within b5w_prt_reqdtl_list
end type

type p_4 from w_a_print`p_4 within b5w_prt_reqdtl_list
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_reqdtl_list
end type

type p_port from w_a_print`p_port within b5w_prt_reqdtl_list
end type

type p_land from w_a_print`p_land within b5w_prt_reqdtl_list
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_reqdtl_list
integer width = 1422
integer height = 324
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_reqdtl_list
end type

