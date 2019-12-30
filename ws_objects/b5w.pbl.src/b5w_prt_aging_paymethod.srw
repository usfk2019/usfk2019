$PBExportHeader$b5w_prt_aging_paymethod.srw
$PBExportComments$[kem] 납부방법별미납액보고서(AGING)
forward
global type b5w_prt_aging_paymethod from w_a_print
end type
end forward

global type b5w_prt_aging_paymethod from w_a_print
integer width = 3470
integer height = 2328
end type
global b5w_prt_aging_paymethod b5w_prt_aging_paymethod

type variables
String is_format
end variables

on b5w_prt_aging_paymethod.create
call super::create
end on

on b5w_prt_aging_paymethod.destroy
call super::destroy
end on

event open;call super::open;Date ld_sysdate
String ls_ref_desc

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.date[1] = ld_sysdate

is_format = fs_get_control("B5", "H200", ls_ref_desc)

Return
end event

event ue_init();call super::ue_init;ii_orientation = 2

end event

event ue_ok();call super::ue_ok;String ls_bilcycle, ls_inv_method, ls_date, ls_where, ls_filter
String ls_currency
Date ld_date
Long ll_row
Dec{2} lc_amt

dw_cond.AcceptText()
ls_bilcycle = Trim(dw_cond.object.bilcycle[1])
ls_currency = Trim(dw_cond.object.currency_type[1])
lc_amt = dw_cond.object.tramt[1]
ld_date= dw_cond.object.date[1]
ls_date = String(ld_date, 'YYYY-MM')

If IsNull(ls_date) Then ls_date = ""
If IsNull(ls_currency) Then ls_currency = ""
If IsNull(ls_bilcycle) Then ls_bilcycle = ""

If ls_date = "" Then
	f_msg_info(200, Title, "As Of")
	dw_cond.SetFocus()
	dw_cond.SetColumn("date")
	Return
End If

ls_where = ""
If ls_bilcycle <> "" Then
	If ls_where <> "" Then ls_where += " And "
    ls_where += " b.bilcycle = '" + ls_bilcycle + "' "
End If

If ls_date <> "" Then
	If ls_where <> "" then ls_where += " And "
	ls_where += " to_char(a.trdt, 'yyyy-mm') <= '" + ls_date + "' "
End If

If ls_currency <> "" Then
	If ls_where <> "" then ls_where += " And "
	ls_where += " b.currency_type = '" + ls_currency + "' "
End If

//0이면 0보다 더 큰것으로 보여주기 위해
If lc_amt = 0 Then lc_amt = 1

//ls_date += "-01" 	//청구 시작일을  정한다.

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve(ld_date, lc_amt)

//조건 표시
dw_list.object.t_bilcycle.Text = dw_cond.object.compute_bilcycle[1]
dw_list.object.t_date.Text = String(dw_cond.object.date[1], 'YYYY-MM-DD')

//Number format 정의
If is_format = "1" Then
	dw_list.object.amt3.Format = "#,##0.0"
	dw_list.object.amt2.Format = "#,##0.0"
	dw_list.object.amt1.Format = "#,##0.0"
	dw_list.object.amt0.Format = "#,##0.0"	
	dw_list.object.totalsum.Format = "#,##0.0"
	dw_list.object.sum_amt3.Format = "#,##0.0"
	dw_list.object.sum_amt2.Format = "#,##0.0"
	dw_list.object.sum_amt1.Format = "#,##0.0"
	dw_list.object.sum_amt0.Format = "#,##0.0"	
	dw_list.object.sum_tot.Format = "#,##0.0"
ElseIf is_format = "2" Then
	dw_list.object.amt3.Format = "#,##0.00"
	dw_list.object.amt2.Format = "#,##0.00"
	dw_list.object.amt1.Format = "#,##0.00"
	dw_list.object.amt0.Format = "#,##0.00"	
	dw_list.object.totalsum.Format = "#,##0.00"
	dw_list.object.sum_amt3.Format = "#,##0.00"
	dw_list.object.sum_amt2.Format = "#,##0.00"
	dw_list.object.sum_amt1.Format = "#,##0.00"
	dw_list.object.sum_amt0.Format = "#,##0.00"	
	dw_list.object.sum_tot.Format = "#,##0.00"
Else
	dw_list.object.amt3.Format = "#,##0"
	dw_list.object.amt2.Format = "#,##0"
	dw_list.object.amt1.Format = "#,##0"
	dw_list.object.amt0.Format = "#,##0"	
	dw_list.object.totalsum.Format = "#,##0"
	dw_list.object.sum_amt3.Format = "#,##0"
	dw_list.object.sum_amt2.Format = "#,##0"
	dw_list.object.sum_amt1.Format = "#,##0"
	dw_list.object.sum_amt0.Format = "#,##0"	
	dw_list.object.sum_tot.Format = "#,##0"
End If

If ll_row = 0 Then
	f_msg_info(1000, Title,"")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_aging_paymethod
integer y = 56
integer width = 2395
integer height = 232
string dataobject = "b5d_cnd_prt_aging_paymethod"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_aging_paymethod
integer x = 2592
integer y = 60
end type

type p_close from w_a_print`p_close within b5w_prt_aging_paymethod
integer x = 2894
integer y = 60
end type

type dw_list from w_a_print`dw_list within b5w_prt_aging_paymethod
integer y = 312
integer width = 3378
integer height = 1644
string dataobject = "b5dw_prt_aging_paymethod"
end type

type p_1 from w_a_print`p_1 within b5w_prt_aging_paymethod
integer x = 2898
integer y = 1996
end type

type p_2 from w_a_print`p_2 within b5w_prt_aging_paymethod
integer x = 695
integer y = 1996
end type

type p_3 from w_a_print`p_3 within b5w_prt_aging_paymethod
integer x = 2574
integer y = 1996
end type

type p_5 from w_a_print`p_5 within b5w_prt_aging_paymethod
integer x = 1385
integer y = 1996
end type

type p_6 from w_a_print`p_6 within b5w_prt_aging_paymethod
integer x = 1961
integer y = 1996
end type

type p_7 from w_a_print`p_7 within b5w_prt_aging_paymethod
integer x = 1769
integer y = 1996
end type

type p_8 from w_a_print`p_8 within b5w_prt_aging_paymethod
integer x = 1577
integer y = 1996
end type

type p_9 from w_a_print`p_9 within b5w_prt_aging_paymethod
integer x = 1010
integer y = 1996
end type

type p_4 from w_a_print`p_4 within b5w_prt_aging_paymethod
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_aging_paymethod
integer x = 55
integer y = 1968
end type

type p_port from w_a_print`p_port within b5w_prt_aging_paymethod
integer x = 105
integer y = 2024
end type

type p_land from w_a_print`p_land within b5w_prt_aging_paymethod
integer x = 265
integer y = 2036
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_aging_paymethod
integer y = 8
integer width = 2437
integer height = 296
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_aging_paymethod
integer x = 2249
integer y = 1996
end type

