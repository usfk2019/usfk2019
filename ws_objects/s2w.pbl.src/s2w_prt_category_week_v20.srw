$PBExportHeader$s2w_prt_category_week_v20.srw
$PBExportComments$[ohj] 품목 중분류, 소분류별 요일 통계 보고서 v20
forward
global type s2w_prt_category_week_v20 from w_a_print
end type
end forward

global type s2w_prt_category_week_v20 from w_a_print
end type
global s2w_prt_category_week_v20 s2w_prt_category_week_v20

on s2w_prt_category_week_v20.create
call super::create
end on

on s2w_prt_category_week_v20.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_use_fr, ls_use_to, ls_type, ls_currency
String ls_where, ls_date, ls_dis_currency
Dec{0} lc_rate
Long ll_row

ls_use_fr = String(dw_cond.object.use_fr[1], 'yyyymmdd')
ls_use_to = String(dw_cond.object.use_to[1], 'yyyymmdd')
ls_type = Trim(dw_cond.object.type[1])
ls_currency = Trim(dw_cond.object.currency[1])

If IsNull(ls_use_fr) Then ls_use_fr = ""
If IsNull(ls_use_to) Then ls_use_to = ""
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_currency) Then ls_currency = ""

If ls_use_fr = "" Then 
	f_msg_info(200, title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_fr")
	Return
End If

If ls_use_to = "" Then 
	f_msg_info(200, title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_to")
	Return
End If

If ls_use_fr <> "" And ls_use_to <> "" Then
	If ls_use_fr > ls_use_to Then
		f_msg_usr_err(210, title, "통화일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("use_fr")
		Return
	End If
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

If ls_use_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "workdt  >= '" + ls_use_fr + "' "
	ls_date = MidA(ls_use_fr,1,4) + "-" +  MidA(ls_use_fr, 5,2)+ "-" +  MidA(ls_use_fr, 7,2) + " ~~ "
End If

If ls_use_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "workdt <= '" + ls_use_to + "' "
	ls_date += MidA(ls_use_to,1,4) + "-" +  MidA(ls_use_to, 5,2)+ "-" +  MidA(ls_use_to, 7,2)
End If

If ls_currency <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "currency_type = '" + ls_currency + "' "
End If

If ls_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "type = '" + ls_type + "' "
	ls_type = dw_cond.Describe("evaluate('lookupdisplay(type)',1 )")
End If

ls_dis_currency = dw_cond.Describe("evaluate('lookupdisplay(currency)',1 )")

//조건 Setting
If ls_date = "" Then ls_date = "All"
If ls_type = "" Then ls_type = "All"
dw_list.object.t_date.Text = ls_date
dw_list.object.t_type.Text = ls_type
dw_list.object.t_currency.Text = ls_dis_currency
dw_list.object.t_unit.Text = "금액단위 : 1/" + String(lc_rate)

dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve(lc_rate)
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s1w_prt_item_week
	Desc.	: 	상품별 요일별 통계 리스트 
	Ver.	:	1.0
	Date	:	2003.01.16
	Programer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)

//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_list.object.bilcost0.Format = "#,##0.0"
	dw_list.object.bilcost1.Format = "#,##0.0"	
	dw_list.object.bilcost2.Format = "#,##0.0"
	dw_list.object.bilcost3.Format = "#,##0.0"
	dw_list.object.bilcost4.Format = "#,##0.0"
	dw_list.object.bilcost5.Format = "#,##0.0"
	dw_list.object.bilcost6.Format = "#,##0.0"
	dw_list.object.bilcost_tot.Format = "#,##0.0"
	dw_list.object.sum_bilcost0.Format = "#,##0.0"
	dw_list.object.sum_bilcost1.Format = "#,##0.0"
	dw_list.object.sum_bilcost2.Format = "#,##0.0"
	dw_list.object.sum_bilcost3.Format = "#,##0.0"
	dw_list.object.sum_bilcost4.Format = "#,##0.0"
	dw_list.object.sum_bilcost5.Format = "#,##0.0"
	dw_list.object.sum_bilcost6.Format = "#,##0.0"
	dw_list.object.sum_tot.Format = "#,##0.0"
	dw_list.object.tot_bilcost0.Format = "#,##0.0"
	dw_list.object.tot_bilcost1.Format = "#,##0.0"
	dw_list.object.tot_bilcost2.Format = "#,##0.0"
	dw_list.object.tot_bilcost3.Format = "#,##0.0"
	dw_list.object.tot_bilcost4.Format = "#,##0.0"
	dw_list.object.tot_bilcost5.Format = "#,##0.0"
	dw_list.object.tot_bilcost6.Format = "#,##0.0"
	dw_list.object.total.Format = "#,##0.0"
	
ElseIf ls_format = "2" Then
	dw_list.object.bilcost0.Format = "#,##0.00"
	dw_list.object.bilcost1.Format = "#,##0.00"	
	dw_list.object.bilcost2.Format = "#,##0.00"
	dw_list.object.bilcost3.Format = "#,##0.00"
	dw_list.object.bilcost4.Format = "#,##0.00"
	dw_list.object.bilcost5.Format = "#,##0.00"
	dw_list.object.bilcost6.Format = "#,##0.00"
	dw_list.object.bilcost_tot.Format = "#,##0.00"
	dw_list.object.sum_bilcost0.Format = "#,##0.00"
	dw_list.object.sum_bilcost1.Format = "#,##0.00"
	dw_list.object.sum_bilcost2.Format = "#,##0.00"
	dw_list.object.sum_bilcost3.Format = "#,##0.00"
	dw_list.object.sum_bilcost4.Format = "#,##0.00"
	dw_list.object.sum_bilcost5.Format = "#,##0.00"
	dw_list.object.sum_bilcost6.Format = "#,##0.00"
	dw_list.object.sum_tot.Format = "#,##0.00"
	dw_list.object.tot_bilcost0.Format = "#,##0.00"
	dw_list.object.tot_bilcost1.Format = "#,##0.00"
	dw_list.object.tot_bilcost2.Format = "#,##0.00"
	dw_list.object.tot_bilcost3.Format = "#,##0.00"
	dw_list.object.tot_bilcost4.Format = "#,##0.00"
	dw_list.object.tot_bilcost5.Format = "#,##0.00"
	dw_list.object.tot_bilcost6.Format = "#,##0.00"
	dw_list.object.total.Format = "#,##0.00"	
Else
	dw_list.object.bilcost0.Format = "#,##0"
	dw_list.object.bilcost1.Format = "#,##0"	
	dw_list.object.bilcost2.Format = "#,##0"
	dw_list.object.bilcost3.Format = "#,##0"
	dw_list.object.bilcost4.Format = "#,##0"
	dw_list.object.bilcost5.Format = "#,##0"
	dw_list.object.bilcost6.Format = "#,##0"
	dw_list.object.bilcost_tot.Format = "#,##0"
	dw_list.object.sum_bilcost0.Format = "#,##0"
	dw_list.object.sum_bilcost1.Format = "#,##0"
	dw_list.object.sum_bilcost2.Format = "#,##0"
	dw_list.object.sum_bilcost3.Format = "#,##0"
	dw_list.object.sum_bilcost4.Format = "#,##0"
	dw_list.object.sum_bilcost5.Format = "#,##0"
	dw_list.object.sum_bilcost6.Format = "#,##0"
	dw_list.object.sum_tot.Format = "#,##0"
	dw_list.object.tot_bilcost0.Format = "#,##0"
	dw_list.object.tot_bilcost1.Format = "#,##0"
	dw_list.object.tot_bilcost2.Format = "#,##0"
	dw_list.object.tot_bilcost3.Format = "#,##0"
	dw_list.object.tot_bilcost4.Format = "#,##0"
	dw_list.object.tot_bilcost5.Format = "#,##0"
	dw_list.object.tot_bilcost6.Format = "#,##0"
	dw_list.object.total.Format = "#,##0"	
End If
end event

type dw_cond from w_a_print`dw_cond within s2w_prt_category_week_v20
integer width = 1710
integer height = 252
string dataobject = "s2dw_cnd_reg_category_week_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_category_week_v20
integer x = 2089
integer y = 56
end type

type p_close from w_a_print`p_close within s2w_prt_category_week_v20
integer x = 2405
integer y = 56
end type

type dw_list from w_a_print`dw_list within s2w_prt_category_week_v20
integer y = 356
integer height = 1264
string dataobject = "s2dw_prt_category_week_v20"
end type

type p_1 from w_a_print`p_1 within s2w_prt_category_week_v20
end type

type p_2 from w_a_print`p_2 within s2w_prt_category_week_v20
end type

type p_3 from w_a_print`p_3 within s2w_prt_category_week_v20
end type

type p_5 from w_a_print`p_5 within s2w_prt_category_week_v20
end type

type p_6 from w_a_print`p_6 within s2w_prt_category_week_v20
end type

type p_7 from w_a_print`p_7 within s2w_prt_category_week_v20
end type

type p_8 from w_a_print`p_8 within s2w_prt_category_week_v20
end type

type p_9 from w_a_print`p_9 within s2w_prt_category_week_v20
end type

type p_4 from w_a_print`p_4 within s2w_prt_category_week_v20
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_category_week_v20
end type

type p_port from w_a_print`p_port within s2w_prt_category_week_v20
end type

type p_land from w_a_print`p_land within s2w_prt_category_week_v20
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_category_week_v20
integer width = 1778
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_category_week_v20
end type

