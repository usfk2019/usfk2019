$PBExportHeader$s1w_prt_customer_traffic.srw
$PBExportComments$[ceusee] 유형별 매출 통계 보고서
forward
global type s1w_prt_customer_traffic from w_a_print
end type
end forward

global type s1w_prt_customer_traffic from w_a_print
end type
global s1w_prt_customer_traffic s1w_prt_customer_traffic

type variables
String is_format, is_areagroup[], is_areagroupnm[]
end variables

on s1w_prt_customer_traffic.create
call super::create
end on

on s1w_prt_customer_traffic.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s1w_prt_salesum_list
	Desc.	: 	유형별 매출통계 보고서
	Ver.	:	1.0
	Date	:	2003.08.20
	Programer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
String ls_format, ls_ref_desc, ls_temp

is_format = fs_get_control("B5", "H200", ls_ref_desc)

//시외, 시내, 국제, 모바일 I;1;L;M
ls_temp = fs_get_control("S1", "S200", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_areagroup[])

//시외, 시내, 국제, 모바일
ls_temp = fs_get_control("S1", "S201", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_areagroupnm[])

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 0 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_yyyymmdd_fr, ls_yyyymmdd_to, ls_where, ls_ctype, ls_svccod, ls_priceplan, ls_gubun
String ls_ref_desc, ls_format
Dec{0} lc_rate
Long ll_row

ls_yyyymmdd_fr = String(dw_cond.object.yyyymmdd_fr[1], 'yyyymmdd')
ls_yyyymmdd_to = String(dw_cond.object.yyyymmdd_to[1], 'yyyymmdd')
ls_ctype       = Trim(dw_cond.object.ctype[1])
ls_svccod      = Trim(dw_cond.object.svccod[1])
ls_priceplan   = Trim(dw_cond.object.priceplan[1])
ls_gubun       = Trim(dw_cond.object.gubun[1])

If IsNull(ls_ctype)     Then ls_ctype     = ""
If IsNull(ls_svccod)    Then ls_svccod    = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_gubun)     Then ls_gubun     = ""

If ls_yyyymmdd_fr = "" Then
	f_msg_info(200, title, "일자(from)")
	dw_cond.SetFocus()
	dw_cond.SetColumn("yyyymmdd_fr")
	Return
End If

If ls_yyyymmdd_to = "" Then
	f_msg_info(200, title, "일자(to)")
	dw_cond.SetFocus()
	dw_cond.SetColumn("yyyymmdd_to")
	Return
End If

If ls_yyyymmdd_fr > ls_yyyymmdd_to Then 
	f_msg_usr_err(211, title, '일자')
	dw_cond.SetFocus()
	dw_cond.SetColumn("yyyymmdd_fr")
	Return
End If
ls_where = ''
If ls_where <> "" Then ls_where += " And "
ls_where += "to_char(a.workdt, 'yyyymmdd') >= '" + ls_yyyymmdd_fr + "' "

If ls_where <> "" Then ls_where += " And "
ls_where += "to_char(a.workdt, 'yyyymmdd') <= '" + ls_yyyymmdd_to + "' "

If ls_ctype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "b.ctype1 = '" + ls_ctype + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.svccod = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.priceplan = '" + ls_priceplan + "' "
End If

dw_list.SetRedraw(False)

//데이터 윈도우 바꾸기 
If ls_gubun = "1"  Then 
	dw_list.DataObject = "s1dw_prt_customer_traffic_list"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_gubun = "2" Then
	dw_list.DataObject = "s1dw_prt_customer_traffic_list_1"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
End If

If is_format = "1" Then
	dw_list.object.internal1_amt.Format = "#,##0.0"
	dw_list.object.internal2_amt.Format = "#,##0.0"
	dw_list.object.international_amt.Format = "#,##0.0"
	dw_list.object.mobile_amt.Format = "#,##0.0"
	dw_list.object.etc_amt.Format = "#,##0.0" 
	dw_list.object.tot_amt.Format = "#,##0.0"
	
	dw_list.object.internal1_t_amt.Format = "#,##0.0"
	dw_list.object.internal2_t_amt.Format = "#,##0.0"
	dw_list.object.international_t_amt.Format = "#,##0.0"
	dw_list.object.mobile_t_amt.Format = "#,##0.0"
	dw_list.object.etc_t_amt.Format = "#,##0.0" 
	dw_list.object.tot_t_amt.Format = "#,##0.0"
	
ElseIf is_format = "2" Then
	dw_list.object.internal1_amt.Format = "#,##0.00"
	dw_list.object.internal2_amt.Format = "#,##0.00"
	dw_list.object.international_amt.Format = "#,##0.00"
	dw_list.object.mobile_amt.Format = "#,##0.00"
	dw_list.object.etc_amt.Format = "#,##0.00" 
	dw_list.object.tot_amt.Format = "#,##0.00"
	
	dw_list.object.internal1_t_amt.Format = "#,##0.00"
	dw_list.object.internal2_t_amt.Format = "#,##0.00"
	dw_list.object.international_t_amt.Format = "#,##0.00"
	dw_list.object.mobile_t_amt.Format = "#,##0.00"
	dw_list.object.etc_t_amt.Format = "#,##0.00" 
	dw_list.object.tot_t_amt.Format = "#,##0.00"
Else
	dw_list.object.internal1_amt.Format = "#,##0"
	dw_list.object.internal2_amt.Format = "#,##0"
	dw_list.object.international_amt.Format = "#,##0"
	dw_list.object.mobile_amt.Format = "#,##0"
	dw_list.object.etc_amt.Format = "#,##0" 
	dw_list.object.tot_amt.Format = "#,##0"
	
	dw_list.object.internal1_t_amt.Format = "#,##0"
	dw_list.object.internal2_t_amt.Format = "#,##0"
	dw_list.object.international_t_amt.Format = "#,##0"
	dw_list.object.mobile_t_amt.Format = "#,##0"
	dw_list.object.etc_t_amt.Format = "#,##0" 
	dw_list.object.tot_t_amt.Format = "#,##0"
End If

dw_list.is_where = ls_where
//조건 Setting
ll_row = dw_list.Retrieve(is_areagroup[1],is_areagroup[2],is_areagroup[3],is_areagroup[4])

dw_list.object.internal1_nm.Text   = is_areagroupnm[1]
dw_list.object.internal2_nm.Text   = is_areagroupnm[2]
dw_list.object.nation_nm.Text      = is_areagroupnm[3]
dw_list.object.mobile_nm.Text      = is_areagroupnm[4]
dw_list.object.internal1_t_nm.Text = is_areagroupnm[1]
dw_list.object.internal2_t_nm.Text = is_areagroupnm[2]
dw_list.object.nation_t_nm.Text    = is_areagroupnm[3]
dw_list.object.mobile_t_nm.Text    = is_areagroupnm[4]
dw_list.object.yyyymmddfr.Text    = String(dw_cond.object.yyyymmdd_fr[1], 'yyyy-mm-dd')
dw_list.object.yyyymmddto.Text    = String(dw_cond.object.yyyymmdd_to[1], 'yyyy-mm-dd')

dw_list.SetRedraw(True)

If ll_row = 0  Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_reset();call super::ue_reset;String ls_ref_content

dw_cond.object.yyyymmdd_fr[1] = Date(fdt_get_dbserver_now())
dw_cond.object.yyyymmdd_to[1] = Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within s1w_prt_customer_traffic
integer x = 55
integer y = 52
integer width = 2181
integer height = 236
string dataobject = "s1dw_cnd_customer_traffic_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan
String  ls_filter
Integer li_exist

This.AcceptText()

Choose Case dwo.name	
	Case "svccod"				
		This.object.priceplan[1] = ''
		ls_filter = ''
		li_exist = This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		If data <> '' Then
			ls_filter = "svccod = '" + data  + "'" 
		End If
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  	
	
End Choose	
end event

type p_ok from w_a_print`p_ok within s1w_prt_customer_traffic
integer x = 2368
integer y = 60
end type

type p_close from w_a_print`p_close within s1w_prt_customer_traffic
integer x = 2670
integer y = 60
end type

type dw_list from w_a_print`dw_list within s1w_prt_customer_traffic
integer y = 332
integer height = 1272
string dataobject = "s1dw_prt_customer_traffic_list"
end type

event dw_list::retrieveend;call super::retrieveend;//Long i
//// 점유율 Setting
//dw_list.AcceptText()
//For i= 1 To This.RowCount()
//	This.object.rate01[i] = This.object.rate_01[i]
//	This.object.rate02[i] = This.object.rate_02[i]
//	This.object.rate03[i] = This.object.rate_03[i]
//	This.object.rate04[i] = This.object.rate_04[i]
//	This.object.rate05[i] = This.object.rate_05[i]
//	This.object.rate06[i] = This.object.rate_06[i]
//	This.object.rate07[i] = This.object.rate_07[i]
//	This.object.rate08[i] = This.object.rate_08[i]
//	This.object.rate09[i] = This.object.rate_09[i]
//	This.object.rate10[i] = This.object.rate_10[i]
//	This.object.rate11[i] = This.object.rate_11[i]
//	This.object.rate12[i] = This.object.rate_12[i]
//Next 
//
////Format
//If is_format = "1" Then
//	dw_list.object.sale01.Format = "#,##0.0"
//	dw_list.object.sale02.Format = "#,##0.0"
//	dw_list.object.sale03.Format = "#,##0.0"
//	dw_list.object.sale04.Format = "#,##0.0"
//	dw_list.object.sale05.Format = "#,##0.0"
//	dw_list.object.sale06.Format = "#,##0.0"
//	dw_list.object.sale07.Format = "#,##0.0"
//	dw_list.object.sale08.Format = "#,##0.0"
//	dw_list.object.sale09.Format = "#,##0.0"
//	dw_list.object.sale10.Format = "#,##0.0"
//	dw_list.object.sale11.Format = "#,##0.0"
//	dw_list.object.sale12.Format = "#,##0.0"
//	dw_list.object.sale_sum01.Format = "#,##0.0"
//	dw_list.object.sale_sum02.Format = "#,##0.0"
//	dw_list.object.sale_sum03.Format = "#,##0.0"
//	dw_list.object.sale_sum04.Format = "#,##0.0"
//	dw_list.object.sale_sum05.Format = "#,##0.0"
//	dw_list.object.sale_sum06.Format = "#,##0.0"
//	dw_list.object.sale_sum07.Format = "#,##0.0"
//	dw_list.object.sale_sum08.Format = "#,##0.0"
//	dw_list.object.sale_sum09.Format = "#,##0.0"
//	dw_list.object.sale_sum10.Format = "#,##0.0"
//	dw_list.object.sale_sum11.Format = "#,##0.0"
//	dw_list.object.sale_sum12.Format = "#,##0.0"
//	dw_list.object.sale_sumall.Format = "#,##0.0"
//	dw_list.object.sale_total.Format = "#,##0.0"
//ElseIf is_format = "2" Then
//	dw_list.object.sale01.Format = "#,##0.00"
//	dw_list.object.sale02.Format = "#,##0.00"
//	dw_list.object.sale03.Format = "#,##0.00"
//	dw_list.object.sale04.Format = "#,##0.00"
//	dw_list.object.sale05.Format = "#,##0.00"
//	dw_list.object.sale06.Format = "#,##0.00"
//	dw_list.object.sale07.Format = "#,##0.00"
//	dw_list.object.sale08.Format = "#,##0.00"
//	dw_list.object.sale09.Format = "#,##0.00"
//	dw_list.object.sale10.Format = "#,##0.00"
//	dw_list.object.sale11.Format = "#,##0.00"
//	dw_list.object.sale12.Format = "#,##0.00"
//	dw_list.object.sale_sum01.Format = "#,##0.00"
//	dw_list.object.sale_sum02.Format = "#,##0.00"
//	dw_list.object.sale_sum03.Format = "#,##0.00"
//	dw_list.object.sale_sum04.Format = "#,##0.00"
//	dw_list.object.sale_sum05.Format = "#,##0.00"
//	dw_list.object.sale_sum06.Format = "#,##0.00"
//	dw_list.object.sale_sum07.Format = "#,##0.00"
//	dw_list.object.sale_sum08.Format = "#,##0.00"
//	dw_list.object.sale_sum09.Format = "#,##0.00"
//	dw_list.object.sale_sum10.Format = "#,##0.00"
//	dw_list.object.sale_sum11.Format = "#,##0.00"
//	dw_list.object.sale_sum12.Format = "#,##0.00"
//	dw_list.object.sale_sumall.Format = "#,##0.00"
//	dw_list.object.sale_total.Format = "#,##0.00"
//Else
//	dw_list.object.sale01.Format = "#,##0"
//	dw_list.object.sale02.Format = "#,##0"
//	dw_list.object.sale03.Format = "#,##0"
//	dw_list.object.sale04.Format = "#,##0"
//	dw_list.object.sale05.Format = "#,##0"
//	dw_list.object.sale06.Format = "#,##0"
//	dw_list.object.sale07.Format = "#,##0"
//	dw_list.object.sale08.Format = "#,##0"
//	dw_list.object.sale09.Format = "#,##0"
//	dw_list.object.sale10.Format = "#,##0"
//	dw_list.object.sale11.Format = "#,##0"
//	dw_list.object.sale12.Format = "#,##0"
//	dw_list.object.sale_sum01.Format = "#,##0"
//	dw_list.object.sale_sum02.Format = "#,##0"
//	dw_list.object.sale_sum03.Format = "#,##0"
//	dw_list.object.sale_sum04.Format = "#,##0"
//	dw_list.object.sale_sum05.Format = "#,##0"
//	dw_list.object.sale_sum06.Format = "#,##0"
//	dw_list.object.sale_sum07.Format = "#,##0"
//	dw_list.object.sale_sum08.Format = "#,##0"
//	dw_list.object.sale_sum09.Format = "#,##0"
//	dw_list.object.sale_sum10.Format = "#,##0"
//	dw_list.object.sale_sum11.Format = "#,##0"
//	dw_list.object.sale_sum12.Format = "#,##0"
//	dw_list.object.sale_sumall.Format = "#,##0"
//	dw_list.object.sale_total.Format = "#,##0"
//	
//End If
end event

type p_1 from w_a_print`p_1 within s1w_prt_customer_traffic
end type

type p_2 from w_a_print`p_2 within s1w_prt_customer_traffic
end type

type p_3 from w_a_print`p_3 within s1w_prt_customer_traffic
end type

type p_5 from w_a_print`p_5 within s1w_prt_customer_traffic
end type

type p_6 from w_a_print`p_6 within s1w_prt_customer_traffic
end type

type p_7 from w_a_print`p_7 within s1w_prt_customer_traffic
end type

type p_8 from w_a_print`p_8 within s1w_prt_customer_traffic
end type

type p_9 from w_a_print`p_9 within s1w_prt_customer_traffic
end type

type p_4 from w_a_print`p_4 within s1w_prt_customer_traffic
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_customer_traffic
end type

type p_port from w_a_print`p_port within s1w_prt_customer_traffic
end type

type p_land from w_a_print`p_land within s1w_prt_customer_traffic
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_customer_traffic
integer width = 2226
integer height = 320
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_customer_traffic
end type

