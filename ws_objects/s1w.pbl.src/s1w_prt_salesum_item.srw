$PBExportHeader$s1w_prt_salesum_item.srw
$PBExportComments$[ceusee] 품목별 매출 실적 보고서
forward
global type s1w_prt_salesum_item from w_a_print
end type
end forward

global type s1w_prt_salesum_item from w_a_print
end type
global s1w_prt_salesum_item s1w_prt_salesum_item

on s1w_prt_salesum_item.create
call super::create
end on

on s1w_prt_salesum_item.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : s1w_prt_salesum_item
	Desc : 품목별 매출 실적 보고서
	Date : 2003.08.20
	Auth : C.BORA
--------------------------------------------------------------------------*/

String ls_ref_desc, ls_format

dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.todt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.currency_type[1] = fs_get_control("B0", "P105", ls_ref_desc)

//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_list.object.sale_amt.Format = "#,##0.0"	
	dw_list.object.sale_a.Format = "#,##0.0"	
	dw_list.object.sale_b.Format = "#,##0.0"	
	dw_list.object.sale_c.Format = "#,##0.0"	
	
ElseIf ls_format = "2" Then
	dw_list.object.sale_amt.Format = "#,##0.00"	
	dw_list.object.sale_a.Format = "#,##0.00"	
	dw_list.object.sale_b.Format = "#,##0.00"	
	dw_list.object.sale_c.Format = "#,##0.00"	
Else
	dw_list.object.sale_amt.Format = "#,##0"	
	dw_list.object.sale_a.Format = "#,##0"	
	dw_list.object.sale_b.Format = "#,##0"	
	dw_list.object.sale_c.Format = "#,##0"	
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;String ls_fromdt, ls_todt, ls_svccod, ls_currency_type, ls_where
Long ll_row

ls_fromdt = String(dw_cond.object.fromdt[1], 'yyyymm')
ls_todt = String(dw_cond.object.todt[1], 'yyyymm')
ls_currency_type = Trim(dw_cond.object.currency_type[1])
ls_svccod = Trim(dw_cond.object.svccod[1])

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_currency_type) Then ls_currency_type = ""
If IsNull(ls_svccod) Then ls_svccod = ""

If ls_fromdt = "" Then
	f_msg_info(200, title, "매출실적기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_todt = "" Then
	f_msg_info(200, title, "매출실적기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("todt")
	Return
End If

If ls_fromdt > ls_todt Then 
	f_msg_usr_err(211, title, "매출실적기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_svccod = "" Then
	f_msg_info(200, title, "서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

If ls_currency_type = "" Then
	f_msg_info(200, title, "통화유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("currency_type")
	Return
End If

ls_where = ""
ls_where += "to_char(sum.sale_month, 'yyyymm') >= '" + ls_fromdt + "' " + &
            "and to_char(sum.sale_month, 'yyyymm') <= '" + ls_todt + "' " + &
				"and sum.svccod = '" + ls_svccod + "' "
If ls_currency_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "sum.currency_type = '" + ls_currency_type + "' "
End If

//조건 Setting
dw_list.object.t_fromdt.Text = MidA(ls_fromdt, 1,4) + "-" + MidA(ls_fromdt, 5,2)
dw_list.object.t_todt.Text = MidA(ls_todt, 1,4) + "-" + MidA(ls_todt, 5,2)
dw_list.object.t_svccod.Text = dw_cond.Describe("evaluate('lookupdisplay(svccod)',1 )")

dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve()
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


				


end event

event ue_reset();call super::ue_reset;String ls_ref_content, ls_currency_type

dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.todt[1] = Date(fdt_get_dbserver_now())
ls_currency_type = fs_get_control("B0", "P105", ls_ref_content)
dw_cond.object.currency_type[1] = ls_currency_type
end event

type dw_cond from w_a_print`dw_cond within s1w_prt_salesum_item
integer y = 72
integer height = 192
string dataobject = "s1dw_prt_cnd_salesum_item"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s1w_prt_salesum_item
end type

type p_close from w_a_print`p_close within s1w_prt_salesum_item
end type

type dw_list from w_a_print`dw_list within s1w_prt_salesum_item
string dataobject = "s1dw_prt_salesum_item"
end type

type p_1 from w_a_print`p_1 within s1w_prt_salesum_item
end type

type p_2 from w_a_print`p_2 within s1w_prt_salesum_item
end type

type p_3 from w_a_print`p_3 within s1w_prt_salesum_item
end type

type p_5 from w_a_print`p_5 within s1w_prt_salesum_item
end type

type p_6 from w_a_print`p_6 within s1w_prt_salesum_item
end type

type p_7 from w_a_print`p_7 within s1w_prt_salesum_item
end type

type p_8 from w_a_print`p_8 within s1w_prt_salesum_item
end type

type p_9 from w_a_print`p_9 within s1w_prt_salesum_item
end type

type p_4 from w_a_print`p_4 within s1w_prt_salesum_item
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_salesum_item
end type

type p_port from w_a_print`p_port within s1w_prt_salesum_item
end type

type p_land from w_a_print`p_land within s1w_prt_salesum_item
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_salesum_item
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_salesum_item
end type

