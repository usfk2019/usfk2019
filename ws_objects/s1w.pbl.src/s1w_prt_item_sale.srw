$PBExportHeader$s1w_prt_item_sale.srw
$PBExportComments$[ceusee] 품목 분류별 판매 통계 보고서
forward
global type s1w_prt_item_sale from w_a_print
end type
end forward

global type s1w_prt_item_sale from w_a_print
end type
global s1w_prt_item_sale s1w_prt_item_sale

on s1w_prt_item_sale.create
call super::create
end on

on s1w_prt_item_sale.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s1w_prt_item_sale
	Desc.	: 	품목별 판매  통계 리스트 
	Ver.	:	1.0
	Date	:	2003.01.16
	Programer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format
Date ld_sysdate

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.sale_month[1] = ld_sysdate
dw_cond.Object.currency[1]   = fs_get_control("B0", "P105", ls_ref_desc)

//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_list.object.sale01.Format = "#,##0.0"	
	dw_list.object.sale02.Format = "#,##0.0"	
	dw_list.object.sale03.Format = "#,##0.0"	
	dw_list.object.sale04.Format = "#,##0.0"	
	dw_list.object.sale05.Format = "#,##0.0"	
	dw_list.object.sale06.Format = "#,##0.0"	
	dw_list.object.sale07.Format = "#,##0.0"	
	dw_list.object.sale08.Format = "#,##0.0"	
	dw_list.object.sale09.Format = "#,##0.0"	
	dw_list.object.sale10.Format = "#,##0.0"	
	dw_list.object.sale11.Format = "#,##0.0"	
	dw_list.object.sale12.Format = "#,##0.0"	
	dw_list.object.compute_1.Format = "#,##0.0"
	dw_list.object.compute_2.Format = "#,##0.0"
	dw_list.object.compute_3.Format = "#,##0.0"
	dw_list.object.compute_4.Format = "#,##0.0"
	dw_list.object.compute_5.Format = "#,##0.0"
	dw_list.object.compute_6.Format = "#,##0.0"
	dw_list.object.compute_7.Format = "#,##0.0"
	dw_list.object.compute_8.Format = "#,##0.0"
	dw_list.object.compute_9.Format = "#,##0.0"
	dw_list.object.compute_10.Format = "#,##0.0"
	dw_list.object.compute_11.Format = "#,##0.0"
	dw_list.object.compute_12.Format = "#,##0.0"
	dw_list.object.compute_13.Format = "#,##0.0"
	dw_list.object.compute_14.Format = "#,##0.0"
	dw_list.object.compute_15.Format = "#,##0.0"
	dw_list.object.compute_16.Format = "#,##0.0"
	dw_list.object.compute_17.Format = "#,##0.0"
	dw_list.object.compute_18.Format = "#,##0.0"
	dw_list.object.compute_19.Format = "#,##0.0"
	dw_list.object.compute_20.Format = "#,##0.0"
	dw_list.object.compute_21.Format = "#,##0.0"
	dw_list.object.compute_22.Format = "#,##0.0"
	dw_list.object.compute_23.Format = "#,##0.0"
	dw_list.object.compute_24.Format = "#,##0.0"
	dw_list.object.compute_25.Format = "#,##0.0"
	dw_list.object.compute_26.Format = "#,##0.0"
	dw_list.object.compute_27.Format = "#,##0.0"
	dw_list.object.compute_28.Format = "#,##0.0"
	dw_list.object.compute_29.Format = "#,##0.0"
	dw_list.object.compute_30.Format = "#,##0.0"
	dw_list.object.compute_31.Format = "#,##0.0"
	dw_list.object.compute_32.Format = "#,##0.0"
	dw_list.object.compute_33.Format = "#,##0.0"
	dw_list.object.compute_34.Format = "#,##0.0"
	dw_list.object.compute_35.Format = "#,##0.0"
	dw_list.object.compute_36.Format = "#,##0.0"
	dw_list.object.compute_37.Format = "#,##0.0"
	dw_list.object.compute_38.Format = "#,##0.0"
	dw_list.object.compute_39.Format = "#,##0.0"
	dw_list.object.compute_40.Format = "#,##0.0"
	
ElseIf ls_format = "2" Then
	dw_list.object.sale01.Format = "#,##0.00"	
	dw_list.object.sale02.Format = "#,##0.00"	
	dw_list.object.sale03.Format = "#,##0.00"	
	dw_list.object.sale04.Format = "#,##0.00"	
	dw_list.object.sale05.Format = "#,##0.00"	
	dw_list.object.sale06.Format = "#,##0.00"	
	dw_list.object.sale07.Format = "#,##0.00"	
	dw_list.object.sale08.Format = "#,##0.00"	
	dw_list.object.sale09.Format = "#,##0.00"	
	dw_list.object.sale10.Format = "#,##0.00"	
	dw_list.object.sale11.Format = "#,##0.00"	
	dw_list.object.sale12.Format = "#,##0.00"	
	dw_list.object.compute_1.Format = "#,##0.00"
	dw_list.object.compute_2.Format = "#,##0.00"
	dw_list.object.compute_3.Format = "#,##0.00"
	dw_list.object.compute_4.Format = "#,##0.00"
	dw_list.object.compute_5.Format = "#,##0.00"
	dw_list.object.compute_6.Format = "#,##0.00"
	dw_list.object.compute_7.Format = "#,##0.00"
	dw_list.object.compute_8.Format = "#,##0.00"
	dw_list.object.compute_9.Format = "#,##0.00"
	dw_list.object.compute_10.Format = "#,##0.00"
	dw_list.object.compute_11.Format = "#,##0.00"
	dw_list.object.compute_12.Format = "#,##0.00"
	dw_list.object.compute_13.Format = "#,##0.00"
	dw_list.object.compute_14.Format = "#,##0.00"
	dw_list.object.compute_15.Format = "#,##0.00"
	dw_list.object.compute_16.Format = "#,##0.00"
	dw_list.object.compute_17.Format = "#,##0.00"
	dw_list.object.compute_18.Format = "#,##0.00"
	dw_list.object.compute_19.Format = "#,##0.00"
	dw_list.object.compute_20.Format = "#,##0.00"
	dw_list.object.compute_21.Format = "#,##0.00"
	dw_list.object.compute_22.Format = "#,##0.00"
	dw_list.object.compute_23.Format = "#,##0.00"
	dw_list.object.compute_24.Format = "#,##0.00"
	dw_list.object.compute_25.Format = "#,##0.00"
	dw_list.object.compute_26.Format = "#,##0.00"
	dw_list.object.compute_27.Format = "#,##0.00"
	dw_list.object.compute_28.Format = "#,##0.00"
	dw_list.object.compute_29.Format = "#,##0.00"
	dw_list.object.compute_30.Format = "#,##0.00"
	dw_list.object.compute_31.Format = "#,##0.00"
	dw_list.object.compute_32.Format = "#,##0.00"
	dw_list.object.compute_33.Format = "#,##0.00"
	dw_list.object.compute_34.Format = "#,##0.00"
	dw_list.object.compute_35.Format = "#,##0.00"
	dw_list.object.compute_36.Format = "#,##0.00"
	dw_list.object.compute_37.Format = "#,##0.00"
	dw_list.object.compute_38.Format = "#,##0.00"
	dw_list.object.compute_39.Format = "#,##0.00"
	dw_list.object.compute_40.Format = "#,##0.00"
Else
	dw_list.object.sale01.Format = "#,##0"	
	dw_list.object.sale02.Format = "#,##0"	
	dw_list.object.sale03.Format = "#,##0"	
	dw_list.object.sale04.Format = "#,##0"	
	dw_list.object.sale05.Format = "#,##0"	
	dw_list.object.sale06.Format = "#,##0"	
	dw_list.object.sale07.Format = "#,##0"	
	dw_list.object.sale08.Format = "#,##0"	
	dw_list.object.sale09.Format = "#,##0"	
	dw_list.object.sale10.Format = "#,##0"	
	dw_list.object.sale11.Format = "#,##0"	
	dw_list.object.sale12.Format = "#,##0"	
	dw_list.object.compute_1.Format = "#,##0"
	dw_list.object.compute_2.Format = "#,##0"
	dw_list.object.compute_3.Format = "#,##0"
	dw_list.object.compute_4.Format = "#,##0"
	dw_list.object.compute_5.Format = "#,##0"
	dw_list.object.compute_6.Format = "#,##0"
	dw_list.object.compute_7.Format = "#,##0"
	dw_list.object.compute_8.Format = "#,##0"
	dw_list.object.compute_9.Format = "#,##0"
	dw_list.object.compute_10.Format = "#,##0"
	dw_list.object.compute_11.Format = "#,##0"
	dw_list.object.compute_12.Format = "#,##0"
	dw_list.object.compute_13.Format = "#,##0"
	dw_list.object.compute_14.Format = "#,##0"
	dw_list.object.compute_15.Format = "#,##0"
	dw_list.object.compute_16.Format = "#,##0"
	dw_list.object.compute_17.Format = "#,##0"
	dw_list.object.compute_18.Format = "#,##0"
	dw_list.object.compute_19.Format = "#,##0"
	dw_list.object.compute_20.Format = "#,##0"
	dw_list.object.compute_21.Format = "#,##0"
	dw_list.object.compute_22.Format = "#,##0"
	dw_list.object.compute_23.Format = "#,##0"
	dw_list.object.compute_24.Format = "#,##0"
	dw_list.object.compute_25.Format = "#,##0"
	dw_list.object.compute_26.Format = "#,##0"
	dw_list.object.compute_27.Format = "#,##0"
	dw_list.object.compute_28.Format = "#,##0"
	dw_list.object.compute_29.Format = "#,##0"
	dw_list.object.compute_30.Format = "#,##0"
	dw_list.object.compute_31.Format = "#,##0"
	dw_list.object.compute_32.Format = "#,##0"
	dw_list.object.compute_33.Format = "#,##0"
	dw_list.object.compute_34.Format = "#,##0"
	dw_list.object.compute_35.Format = "#,##0"
	dw_list.object.compute_36.Format = "#,##0"
	dw_list.object.compute_37.Format = "#,##0"
	dw_list.object.compute_38.Format = "#,##0"
	dw_list.object.compute_39.Format = "#,##0"
	dw_list.object.compute_40.Format = "#,##0"
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_sale_month, ls_svccod, ls_priceplan, ls_currency, ls_where, ls_date
Dec{0} lc_rate
Long ll_row

dw_cond.AcceptText()

ls_sale_month = String(dw_cond.object.sale_month[1], 'yyyy')
ls_svccod     = Trim(dw_cond.object.svccod[1])
ls_currency   = Trim(dw_cond.object.currency[1])
ls_priceplan  = Trim(dw_cond.object.priceplan[1])

If IsNull(ls_sale_month) Then ls_sale_month = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_currency) Then ls_currency = ""

If ls_sale_month = "" Then
	f_msg_info(200, title, "년도")
	dw_cond.SetFocus()
	dw_cond.SetColumn("sale_month")
	Return
End If

If ls_currency = "" Then
	f_msg_info(200, title, "통화유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("currency")
	Return
End If

If ls_currency = 'KRW' Then
	lc_rate = 1000
ElseIf ls_currency = 'CAD' Then
	lc_rate = 1
ElseIf ls_currency = 'USD' Then
	lc_rate = 1
Else
	lc_rate = 1
End If

ls_where = "to_char(sale_month, 'yyyy') = '" + ls_sale_month + "' "

If ls_where <> "" Then ls_where += " And "
ls_where += "sum.currency_type = '" + ls_currency + "' "

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "sum.svccod = '" + ls_svccod + "' "
	ls_svccod = dw_cond.Describe("evaluate('lookupdisplay(svccod)',1 )")
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "sum.priceplan = '" + ls_priceplan + "' "
	ls_priceplan = dw_cond.Describe("evaluate('lookupdisplay(priceplan)',1 )")
End If

//조건 Setting
If ls_priceplan = "" Then ls_priceplan = "All"
If ls_svccod = "" Then ls_svccod = "All"

dw_list.object.t_date.Text = ls_sale_month
dw_list.object.t_svccod.Text = ls_svccod
dw_list.object.t_priceplan.Text = ls_priceplan
//dw_list.object.t_currency.Text = ls_currency

dw_list.object.t_unit.Text = "단위 : 1/" + String(lc_rate) 

dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve( lc_rate )
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

type dw_cond from w_a_print`dw_cond within s1w_prt_item_sale
integer width = 1381
integer height = 336
string dataobject = "s1dw_cnd_reg_item_sale"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s1w_prt_item_sale
integer x = 1582
integer y = 64
end type

type p_close from w_a_print`p_close within s1w_prt_item_sale
integer x = 1906
integer y = 64
end type

type dw_list from w_a_print`dw_list within s1w_prt_item_sale
integer y = 448
integer height = 1172
string dataobject = "s1dw_prt_item_sale"
end type

type p_1 from w_a_print`p_1 within s1w_prt_item_sale
end type

type p_2 from w_a_print`p_2 within s1w_prt_item_sale
end type

type p_3 from w_a_print`p_3 within s1w_prt_item_sale
end type

type p_5 from w_a_print`p_5 within s1w_prt_item_sale
end type

type p_6 from w_a_print`p_6 within s1w_prt_item_sale
end type

type p_7 from w_a_print`p_7 within s1w_prt_item_sale
end type

type p_8 from w_a_print`p_8 within s1w_prt_item_sale
end type

type p_9 from w_a_print`p_9 within s1w_prt_item_sale
end type

type p_4 from w_a_print`p_4 within s1w_prt_item_sale
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_item_sale
end type

type p_port from w_a_print`p_port within s1w_prt_item_sale
end type

type p_land from w_a_print`p_land within s1w_prt_item_sale
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_item_sale
integer width = 1445
integer height = 412
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_item_sale
end type

