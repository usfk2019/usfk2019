$PBExportHeader$s2w_prt_partner_hour.srw
$PBExportComments$[kem] 대리점별 시간대 통계 보고서
forward
global type s2w_prt_partner_hour from w_a_print
end type
end forward

global type s2w_prt_partner_hour from w_a_print
end type
global s2w_prt_partner_hour s2w_prt_partner_hour

on s2w_prt_partner_hour.create
call super::create
end on

on s2w_prt_partner_hour.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_use_fr, ls_use_to, ls_type, ls_priceplan, ls_currency
String ls_where, ls_date, ls_dis_currency
Dec{0} lc_rate
Long ll_row

ls_use_fr    = String(dw_cond.object.use_fr[1], 'yyyymmdd')
ls_use_to    = String(dw_cond.object.use_to[1], 'yyyymmdd')
ls_type      = Trim(dw_cond.object.type[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_currency  = Trim(dw_cond.object.currency[1])

If IsNull(ls_use_fr) Then ls_use_fr = ""
If IsNull(ls_use_to) Then ls_use_to = ""
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
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
	ls_where += "a.workdt  >= '" + ls_use_fr + "' "
	ls_date = MidA(ls_use_fr,1,4) + "-" +  MidA(ls_use_fr, 5,2)+ "-" +  MidA(ls_use_fr, 7,2) + " ~~ "
End If

If ls_use_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.workdt <= '" + ls_use_to + "' "
	ls_date += MidA(ls_use_to,1,4) + "-" +  MidA(ls_use_to, 5,2)+ "-" +  MidA(ls_use_to, 7,2)
End If

If ls_currency <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.currency_type = '" + ls_currency + "' "
End If

If ls_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.type = '" + ls_type + "' "
	ls_type = dw_cond.Describe("evaluate('lookupdisplay(type)',1 )")
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.priceplan = '" + ls_priceplan + "' "
	ls_priceplan = dw_cond.Describe("evaluate('lookupdisplay(priceplan)',1 )")
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
	Name	:	s2w_prt_partner_hour
	Desc.	: 	대리점별 시간대통계 보고서 
	Ver.	:	1.0
	Date	:	2003.08.27
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format, ls_ref_content, ls_return[]
String ls_time1, ls_time2, ls_time3, ls_time4
Integer li_return

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)
ls_ref_content = fs_get_control("S1", "S101", ls_ref_desc)

If IsNull(ls_ref_content) Then Return
li_return = fi_cut_string(ls_ref_content, ';', ls_return[])

ls_time1 = ls_return[1] + '-' + ls_return[2]
ls_time2 = ls_return[3] + '-' + ls_return[4]
ls_time3 = ls_return[5] + '-' + ls_return[6]
ls_time4 = ls_return[7] + '-' + ls_return[8]

dw_list.object.t_time1.text = "1시간대(" + ls_time1 + ")"
dw_list.object.t_time2.text = "2시간대(" + ls_time2 + ")"
dw_list.object.t_time3.text = "3시간대(" + ls_time3 + ")"
dw_list.object.t_time4.text = "4시간대(" + ls_time4 + ")"

//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_list.object.bilcost1.Format = "#,##0.0"	
	dw_list.object.bilcost2.Format = "#,##0.0"
	dw_list.object.bilcost3.Format = "#,##0.0"
	dw_list.object.bilcost4.Format = "#,##0.0"
	dw_list.object.bilcost_tot.Format = "#,##0.0"
	dw_list.object.sum_bilcost1.Format = "#,##0.0"
	dw_list.object.sum_bilcost2.Format = "#,##0.0"
	dw_list.object.sum_bilcost3.Format = "#,##0.0"
	dw_list.object.sum_bilcost4.Format = "#,##0.0"
	dw_list.object.sum_tot.Format = "#,##0.0"
	dw_list.object.tot_bilcost1.Format = "#,##0.0"
	dw_list.object.tot_bilcost2.Format = "#,##0.0"
	dw_list.object.tot_bilcost3.Format = "#,##0.0"
	dw_list.object.tot_bilcost4.Format = "#,##0.0"
	dw_list.object.total.Format = "#,##0.0"
	
ElseIf ls_format = "2" Then
	dw_list.object.bilcost1.Format = "#,##0.00"	
	dw_list.object.bilcost2.Format = "#,##0.00"
	dw_list.object.bilcost3.Format = "#,##0.00"
	dw_list.object.bilcost4.Format = "#,##0.00"
	dw_list.object.bilcost_tot.Format = "#,##0.00"
	dw_list.object.sum_bilcost1.Format = "#,##0.00"
	dw_list.object.sum_bilcost2.Format = "#,##0.00"
	dw_list.object.sum_bilcost3.Format = "#,##0.00"
	dw_list.object.sum_bilcost4.Format = "#,##0.00"
	dw_list.object.sum_tot.Format = "#,##0.00"
	dw_list.object.tot_bilcost1.Format = "#,##0.00"
	dw_list.object.tot_bilcost2.Format = "#,##0.00"
	dw_list.object.tot_bilcost3.Format = "#,##0.00"
	dw_list.object.tot_bilcost4.Format = "#,##0.00"
	dw_list.object.total.Format = "#,##0.00"	
Else
	dw_list.object.bilcost1.Format = "#,##0"	
	dw_list.object.bilcost2.Format = "#,##0"
	dw_list.object.bilcost3.Format = "#,##0"
	dw_list.object.bilcost4.Format = "#,##0"
	dw_list.object.bilcost_tot.Format = "#,##0"
	dw_list.object.sum_bilcost1.Format = "#,##0"
	dw_list.object.sum_bilcost2.Format = "#,##0"
	dw_list.object.sum_bilcost3.Format = "#,##0"
	dw_list.object.sum_bilcost4.Format = "#,##0"
	dw_list.object.sum_tot.Format = "#,##0"
	dw_list.object.tot_bilcost1.Format = "#,##0"
	dw_list.object.tot_bilcost2.Format = "#,##0"
	dw_list.object.tot_bilcost3.Format = "#,##0"
	dw_list.object.tot_bilcost4.Format = "#,##0"
	dw_list.object.total.Format = "#,##0"	
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;String ls_ref_desc, ls_format, ls_ref_content, ls_return[]
String ls_time1, ls_time2, ls_time3, ls_time4
Integer li_return

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)
ls_ref_content = fs_get_control("S1", "S101", ls_ref_desc)

If IsNull(ls_ref_content) Then Return
li_return = fi_cut_string(ls_ref_content, ';', ls_return[])

ls_time1 = ls_return[1] + '-' + ls_return[2]
ls_time2 = ls_return[3] + '-' + ls_return[4]
ls_time3 = ls_return[5] + '-' + ls_return[6]
ls_time4 = ls_return[7] + '-' + ls_return[8]

dw_list.object.t_time1.text = "1시간대(" + ls_time1 + ")"
dw_list.object.t_time2.text = "2시간대(" + ls_time2 + ")"
dw_list.object.t_time3.text = "3시간대(" + ls_time3 + ")"
dw_list.object.t_time4.text = "4시간대(" + ls_time4 + ")"
end event

type dw_cond from w_a_print`dw_cond within s2w_prt_partner_hour
integer width = 1723
integer height = 292
string dataobject = "s2dw_cnd_reg_partner_hour"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_partner_hour
integer x = 1911
end type

type p_close from w_a_print`p_close within s2w_prt_partner_hour
integer x = 2213
end type

type dw_list from w_a_print`dw_list within s2w_prt_partner_hour
integer y = 364
integer height = 1256
string dataobject = "s2dw_prt_partner_hour"
end type

type p_1 from w_a_print`p_1 within s2w_prt_partner_hour
end type

type p_2 from w_a_print`p_2 within s2w_prt_partner_hour
end type

type p_3 from w_a_print`p_3 within s2w_prt_partner_hour
end type

type p_5 from w_a_print`p_5 within s2w_prt_partner_hour
end type

type p_6 from w_a_print`p_6 within s2w_prt_partner_hour
end type

type p_7 from w_a_print`p_7 within s2w_prt_partner_hour
end type

type p_8 from w_a_print`p_8 within s2w_prt_partner_hour
end type

type p_9 from w_a_print`p_9 within s2w_prt_partner_hour
end type

type p_4 from w_a_print`p_4 within s2w_prt_partner_hour
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_partner_hour
end type

type p_port from w_a_print`p_port within s2w_prt_partner_hour
end type

type p_land from w_a_print`p_land within s2w_prt_partner_hour
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_partner_hour
integer width = 1774
integer height = 356
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_partner_hour
end type

