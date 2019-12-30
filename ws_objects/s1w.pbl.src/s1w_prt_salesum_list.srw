$PBExportHeader$s1w_prt_salesum_list.srw
$PBExportComments$[ceusee] 유형별 매출 통계 보고서
forward
global type s1w_prt_salesum_list from w_a_print
end type
end forward

global type s1w_prt_salesum_list from w_a_print
end type
global s1w_prt_salesum_list s1w_prt_salesum_list

type variables
String is_format
end variables

on s1w_prt_salesum_list.create
call super::create
end on

on s1w_prt_salesum_list.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s1w_prt_salesum_list
	Desc.	: 	유형별 매출통계 보고서
	Ver.	:	1.0
	Date	:	2003.08.20
	Programer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
String ls_format, ls_ref_desc
is_format = fs_get_control("B5", "H200", ls_ref_desc)


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_fromdt, ls_where, ls_currency_type, ls_work_type
String ls_ref_desc, ls_format
Dec{0} lc_rate
Long ll_row

ls_fromdt = String(dw_cond.object.fromdt[1], 'yyyy')
ls_currency_type = Trim(dw_cond.object.currency_type[1])
ls_work_type = Trim(dw_cond.object.work_type[1])


If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_currency_type) Then ls_currency_type = ""
If IsNull(ls_work_type) Then ls_work_type = ""

If ls_fromdt = "" Then
	f_msg_info(200, title, "년도")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_work_type = "" Then
	f_msg_info(200, title, "작업선택")
	dw_cond.SetFocus()
	dw_cond.SetColumn("work_type")
	Return
End If

If ls_currency_type = "" Then
	f_msg_info(200, title, "통화유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("currency_type")
	Return
End If

If ls_currency_type = 'KRW' Then
	lc_rate = 1000
ElseIf ls_currency_type = 'CAD' Then
	lc_rate = 1
ElseIf ls_currency_type = 'USD' Then
	lc_rate = 1
Else
	lc_rate = 1
End If

If ls_where <> "" Then ls_where += " And "
ls_where = "to_char(sum.sale_month, 'yyyy') = '" + ls_fromdt + "' "

If ls_currency_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "sum.currency_type = '" + ls_currency_type + "' "
End If

dw_list.SetRedraw(False)


//데이터 윈도우 바꾸기 
If ls_work_type = "1"  Then 
	dw_list.DataObject = "s1dw_prt_salesum_list_1"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_work_type = "2" Then
	dw_list.DataObject = "s1dw_prt_salesum_list_2"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_work_type = '3' Then
	dw_list.DataObject = "s1dw_prt_salesum_list_3"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_work_type = '4' Then
	dw_list.DataObject = "s1dw_prt_salesum_list_4"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_work_type = '5' Then
	dw_list.DataObject = "s1dw_prt_salesum_list_5"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
//ElseIf ls_work_type = '6' Then
//	dw_list.DataObject = "s1dw_prt_salesum_list_6"
//	dw_list.SetTransObject(SQLCA)
//	dw_list.is_where = ls_where
//ElseIf ls_work_type = '7' Then
//	dw_list.DataObject = "s1dw_prt_salesum_list_7"
//	dw_list.SetTransObject(SQLCA)
//	dw_list.is_where = ls_where
End If

If is_format = "1" Then
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
	dw_list.object.sale_total.Format = "#,##0.0"	
	dw_list.object.sale_sum01.Format = "#,##0.0"
	dw_list.object.sale_sum02.Format = "#,##0.0"
	dw_list.object.sale_sum03.Format = "#,##0.0"
	dw_list.object.sale_sum04.Format = "#,##0.0"
	dw_list.object.sale_sum05.Format = "#,##0.0"
	dw_list.object.sale_sum06.Format = "#,##0.0"
	dw_list.object.sale_sum07.Format = "#,##0.0"
	dw_list.object.sale_sum08.Format = "#,##0.0"
	dw_list.object.sale_sum09.Format = "#,##0.0"
	dw_list.object.sale_sum10.Format = "#,##0.0"
	dw_list.object.sale_sum11.Format = "#,##0.0"
	dw_list.object.sale_sum12.Format = "#,##0.0"
	dw_list.object.sale_sumall.Format = "#,##0.0"	
	
ElseIf is_format = "2" Then
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
	dw_list.object.sale_total.Format = "#,##0.00"	
	dw_list.object.sale_sum01.Format = "#,##0.00"
	dw_list.object.sale_sum02.Format = "#,##0.00"
	dw_list.object.sale_sum03.Format = "#,##0.00"
	dw_list.object.sale_sum04.Format = "#,##0.00"
	dw_list.object.sale_sum05.Format = "#,##0.00"
	dw_list.object.sale_sum06.Format = "#,##0.00"
	dw_list.object.sale_sum07.Format = "#,##0.00"
	dw_list.object.sale_sum08.Format = "#,##0.00"
	dw_list.object.sale_sum09.Format = "#,##0.00"
	dw_list.object.sale_sum10.Format = "#,##0.00"
	dw_list.object.sale_sum11.Format = "#,##0.00"
	dw_list.object.sale_sum12.Format = "#,##0.00"
	dw_list.object.sale_sumall.Format = "#,##0.00"
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
	dw_list.object.sale_total.Format = "#,##0"	
	dw_list.object.sale_sum01.Format = "#,##0"
	dw_list.object.sale_sum02.Format = "#,##0"
	dw_list.object.sale_sum03.Format = "#,##0"
	dw_list.object.sale_sum04.Format = "#,##0"
	dw_list.object.sale_sum05.Format = "#,##0"
	dw_list.object.sale_sum06.Format = "#,##0"
	dw_list.object.sale_sum07.Format = "#,##0"
	dw_list.object.sale_sum08.Format = "#,##0"
	dw_list.object.sale_sum09.Format = "#,##0"
	dw_list.object.sale_sum10.Format = "#,##0"
	dw_list.object.sale_sum11.Format = "#,##0"
	dw_list.object.sale_sum12.Format = "#,##0"
	dw_list.object.sale_sumall.Format = "#,##0"
End If


//조건 Setting
ll_row = dw_list.Retrieve(lc_rate)
dw_list.SetRedraw(True)
dw_list.object.t_date.Text = ls_fromdt
dw_list.object.t_unit.Text = "단위 : 1/" + String(lc_rate) 
If ll_row = 0  Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If





end event

event ue_reset();call super::ue_reset;String ls_ref_content, ls_currency_type
ls_currency_type = fs_get_control("B0", "P105", ls_ref_content)

dw_cond.object.currency_type[1] = ls_currency_type
dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within s1w_prt_salesum_list
integer x = 55
integer y = 76
integer width = 1413
integer height = 196
string dataobject = "s1dw_cnd_prt_salesum_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s1w_prt_salesum_list
integer x = 1609
integer y = 44
end type

type p_close from w_a_print`p_close within s1w_prt_salesum_list
integer x = 1911
integer y = 44
end type

type dw_list from w_a_print`dw_list within s1w_prt_salesum_list
integer y = 332
integer height = 1288
string dataobject = "s1dw_prt_salesum_list_1"
end type

event dw_list::retrieveend;call super::retrieveend;Long i
// 점유율 Setting
dw_list.AcceptText()
For i= 1 To This.RowCount()
	This.object.rate01[i] = This.object.rate_01[i]
	This.object.rate02[i] = This.object.rate_02[i]
	This.object.rate03[i] = This.object.rate_03[i]
	This.object.rate04[i] = This.object.rate_04[i]
	This.object.rate05[i] = This.object.rate_05[i]
	This.object.rate06[i] = This.object.rate_06[i]
	This.object.rate07[i] = This.object.rate_07[i]
	This.object.rate08[i] = This.object.rate_08[i]
	This.object.rate09[i] = This.object.rate_09[i]
	This.object.rate10[i] = This.object.rate_10[i]
	This.object.rate11[i] = This.object.rate_11[i]
	This.object.rate12[i] = This.object.rate_12[i]
Next 

//Format
If is_format = "1" Then
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
	dw_list.object.sale_sum01.Format = "#,##0.0"
	dw_list.object.sale_sum02.Format = "#,##0.0"
	dw_list.object.sale_sum03.Format = "#,##0.0"
	dw_list.object.sale_sum04.Format = "#,##0.0"
	dw_list.object.sale_sum05.Format = "#,##0.0"
	dw_list.object.sale_sum06.Format = "#,##0.0"
	dw_list.object.sale_sum07.Format = "#,##0.0"
	dw_list.object.sale_sum08.Format = "#,##0.0"
	dw_list.object.sale_sum09.Format = "#,##0.0"
	dw_list.object.sale_sum10.Format = "#,##0.0"
	dw_list.object.sale_sum11.Format = "#,##0.0"
	dw_list.object.sale_sum12.Format = "#,##0.0"
	dw_list.object.sale_sumall.Format = "#,##0.0"
	dw_list.object.sale_total.Format = "#,##0.0"
ElseIf is_format = "2" Then
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
	dw_list.object.sale_sum01.Format = "#,##0.00"
	dw_list.object.sale_sum02.Format = "#,##0.00"
	dw_list.object.sale_sum03.Format = "#,##0.00"
	dw_list.object.sale_sum04.Format = "#,##0.00"
	dw_list.object.sale_sum05.Format = "#,##0.00"
	dw_list.object.sale_sum06.Format = "#,##0.00"
	dw_list.object.sale_sum07.Format = "#,##0.00"
	dw_list.object.sale_sum08.Format = "#,##0.00"
	dw_list.object.sale_sum09.Format = "#,##0.00"
	dw_list.object.sale_sum10.Format = "#,##0.00"
	dw_list.object.sale_sum11.Format = "#,##0.00"
	dw_list.object.sale_sum12.Format = "#,##0.00"
	dw_list.object.sale_sumall.Format = "#,##0.00"
	dw_list.object.sale_total.Format = "#,##0.00"
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
	dw_list.object.sale_sum01.Format = "#,##0"
	dw_list.object.sale_sum02.Format = "#,##0"
	dw_list.object.sale_sum03.Format = "#,##0"
	dw_list.object.sale_sum04.Format = "#,##0"
	dw_list.object.sale_sum05.Format = "#,##0"
	dw_list.object.sale_sum06.Format = "#,##0"
	dw_list.object.sale_sum07.Format = "#,##0"
	dw_list.object.sale_sum08.Format = "#,##0"
	dw_list.object.sale_sum09.Format = "#,##0"
	dw_list.object.sale_sum10.Format = "#,##0"
	dw_list.object.sale_sum11.Format = "#,##0"
	dw_list.object.sale_sum12.Format = "#,##0"
	dw_list.object.sale_sumall.Format = "#,##0"
	dw_list.object.sale_total.Format = "#,##0"
	
End If
end event

type p_1 from w_a_print`p_1 within s1w_prt_salesum_list
end type

type p_2 from w_a_print`p_2 within s1w_prt_salesum_list
end type

type p_3 from w_a_print`p_3 within s1w_prt_salesum_list
end type

type p_5 from w_a_print`p_5 within s1w_prt_salesum_list
end type

type p_6 from w_a_print`p_6 within s1w_prt_salesum_list
end type

type p_7 from w_a_print`p_7 within s1w_prt_salesum_list
end type

type p_8 from w_a_print`p_8 within s1w_prt_salesum_list
end type

type p_9 from w_a_print`p_9 within s1w_prt_salesum_list
end type

type p_4 from w_a_print`p_4 within s1w_prt_salesum_list
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_salesum_list
end type

type p_port from w_a_print`p_port within s1w_prt_salesum_list
end type

type p_land from w_a_print`p_land within s1w_prt_salesum_list
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_salesum_list
integer width = 1467
integer height = 308
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_salesum_list
end type

