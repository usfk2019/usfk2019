$PBExportHeader$s2w_prt_country_hour_v20.srw
$PBExportComments$[ohj] 국가별 시간대 통계 보고서 v20
forward
global type s2w_prt_country_hour_v20 from w_a_print
end type
end forward

global type s2w_prt_country_hour_v20 from w_a_print
integer width = 3168
end type
global s2w_prt_country_hour_v20 s2w_prt_country_hour_v20

on s2w_prt_country_hour_v20.create
call super::create
end on

on s2w_prt_country_hour_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_workdt_fr, ls_workdt_to, ls_svccod, ls_priceplan, ls_areagroup, ls_nodeno, ls_gubun 
String ls_where, ls_date, ls_dis_currency, ls_name
Dec{0} lc_rate
Long ll_row

ls_workdt_fr = String(dw_cond.object.workdt_fr[1], 'yyyymmdd')
ls_workdt_to = String(dw_cond.object.workdt_to[1], 'yyyymmdd')
ls_svccod    = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_areagroup = Trim(dw_cond.object.areagroup[1])
ls_nodeno    = Trim(dw_cond.object.nodeno[1])
ls_gubun     = Trim(dw_cond.object.gubun[1])

If IsNull(ls_svccod   ) Then ls_svccod		= ""
If IsNull(ls_priceplan) Then ls_priceplan	= ""
If IsNull(ls_areagroup) Then ls_areagroup	= ""
If IsNull(ls_nodeno   ) Then ls_nodeno		= ""
If IsNull(ls_gubun    ) Then ls_gubun     = ""

If ls_workdt_fr = "" Then 
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt_fr")
	Return
End If

If ls_workdt_to = "" Then 
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt_to")
	Return
End If

If ls_workdt_fr > ls_workdt_to Then
	f_msg_usr_err(210, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt_fr")
	Return
End If

//If ls_currency = 'KRW' Then
//	lc_rate = 1000
//ElseIf ls_currency = 'CAD' Then
//	lc_rate = 1
//ElseIf ls_currency = 'USD' Then
//	lc_rate = 1
//Else
//	lc_rate = 1
//End If

If ls_gubun = '1' Then		//통화수
	dw_list.dataObject = "s2dw_prt_country_hour_cnt_v20"
	dw_list.SetTransObject(SQLCA)
	ls_name = '통화수'
ElseIf ls_gubun = '2' Then	//통화시간
	dw_list.dataObject = "s2dw_prt_country_hour_time_v20"
	dw_list.SetTransObject(SQLCA)
	ls_name = '통화시간'
Else 								//통화금액
	dw_list.dataObject = "s2dw_prt_country_hour_amt_v20"
	dw_list.SetTransObject(SQLCA)
	ls_name = '통화금액'
End If

ls_where = ''
If ls_workdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.workdt  >= '" + ls_workdt_fr + "' "	
End If

If ls_workdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.workdt <= '" + ls_workdt_to + "' "	
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.svccod = '" + ls_svccod + "' "	
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.priceplan = '" + ls_priceplan + "' "
	//ls_priceplan = dw_cond.Describe("evaluate('lookupdisplay(priceplan)',1 )")
End If

If ls_areagroup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.areagroup = '" + ls_areagroup + "' "	
End If

If ls_nodeno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "a.nodeno = '" + ls_nodeno + "' "	
End If

//ls_dis_currency = dw_cond.Describe("evaluate('lookupdisplay(currency)',1 )")

dw_list.object.t_workdt_fr.Text = MidA(ls_workdt_fr,1,4) + "-" +  MidA(ls_workdt_fr, 5,2)+ "-" +  MidA(ls_workdt_fr, 7,2) 
dw_list.object.t_workdt_to.Text = MidA(ls_workdt_to,1,4) + "-" +  MidA(ls_workdt_to, 5,2)+ "-" +  MidA(ls_workdt_to, 7,2)
dw_list.object.t_gubun.Text = ls_name

//dw_list.object.t_unit.Text = "금액단위 : 1/" + String(lc_rate)
dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve()
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s2w_prt_country_hour_v20
	Desc.	: 	대리점별요일통계 보고서 
	Ver.	:	1.0
	Date	:	2005.12.08
	Programer : oh hye jin
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format

dw_cond.Object.workdt_fr[1] = fdt_get_dbserver_now()
dw_cond.Object.workdt_to[1] = fdt_get_dbserver_now()
//dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)

//금액 format 맞춘다.
//ls_format = fs_get_control("B5", "H200", ls_ref_desc)
//If ls_format = "1" Then
//	dw_list.object.bilcost1.Format = "#,##0.0"	
//	dw_list.object.bilcost2.Format = "#,##0.0"
//	dw_list.object.bilcost3.Format = "#,##0.0"
//	dw_list.object.bilcost4.Format = "#,##0.0"
//	dw_list.object.bilcost5.Format = "#,##0.0"
//	dw_list.object.bilcost6.Format = "#,##0.0"
//	dw_list.object.bilcost7.Format = "#,##0.0"
//	dw_list.object.bilcost_tot.Format = "#,##0.0"
//	dw_list.object.sum_bilcost1.Format = "#,##0.0"
//	dw_list.object.sum_bilcost2.Format = "#,##0.0"
//	dw_list.object.sum_bilcost3.Format = "#,##0.0"
//	dw_list.object.sum_bilcost4.Format = "#,##0.0"
//	dw_list.object.sum_bilcost5.Format = "#,##0.0"
//	dw_list.object.sum_bilcost6.Format = "#,##0.0"
//	dw_list.object.sum_bilcost7.Format = "#,##0.0"
//	dw_list.object.sum_tot.Format = "#,##0.0"
//	dw_list.object.tot_bilcost1.Format = "#,##0.0"
//	dw_list.object.tot_bilcost2.Format = "#,##0.0"
//	dw_list.object.tot_bilcost3.Format = "#,##0.0"
//	dw_list.object.tot_bilcost4.Format = "#,##0.0"
//	dw_list.object.tot_bilcost5.Format = "#,##0.0"
//	dw_list.object.tot_bilcost6.Format = "#,##0.0"
//	dw_list.object.tot_bilcost7.Format = "#,##0.0"
//	dw_list.object.total.Format = "#,##0.0"
//	
//ElseIf ls_format = "2" Then
//	dw_list.object.bilcost1.Format = "#,##0.00"	
//	dw_list.object.bilcost2.Format = "#,##0.00"
//	dw_list.object.bilcost3.Format = "#,##0.00"
//	dw_list.object.bilcost4.Format = "#,##0.00"
//	dw_list.object.bilcost5.Format = "#,##0.00"
//	dw_list.object.bilcost6.Format = "#,##0.00"
//	dw_list.object.bilcost7.Format = "#,##0.00"
//	dw_list.object.bilcost_tot.Format = "#,##0.00"
//	dw_list.object.sum_bilcost1.Format = "#,##0.00"
//	dw_list.object.sum_bilcost2.Format = "#,##0.00"
//	dw_list.object.sum_bilcost3.Format = "#,##0.00"
//	dw_list.object.sum_bilcost4.Format = "#,##0.00"
//	dw_list.object.sum_bilcost5.Format = "#,##0.00"
//	dw_list.object.sum_bilcost6.Format = "#,##0.00"
//	dw_list.object.sum_bilcost7.Format = "#,##0.00"
//	dw_list.object.sum_tot.Format = "#,##0.00"
//	dw_list.object.tot_bilcost1.Format = "#,##0.00"
//	dw_list.object.tot_bilcost2.Format = "#,##0.00"
//	dw_list.object.tot_bilcost3.Format = "#,##0.00"
//	dw_list.object.tot_bilcost4.Format = "#,##0.00"
//	dw_list.object.tot_bilcost5.Format = "#,##0.00"
//	dw_list.object.tot_bilcost6.Format = "#,##0.00"
//	dw_list.object.tot_bilcost7.Format = "#,##0.00"
//	dw_list.object.total.Format = "#,##0.00"	
//Else
//	dw_list.object.bilcost1.Format = "#,##0"	
//	dw_list.object.bilcost2.Format = "#,##0"
//	dw_list.object.bilcost3.Format = "#,##0"
//	dw_list.object.bilcost4.Format = "#,##0"
//	dw_list.object.bilcost5.Format = "#,##0"
//	dw_list.object.bilcost6.Format = "#,##0"
//	dw_list.object.bilcost7.Format = "#,##0"
//	dw_list.object.bilcost_tot.Format = "#,##0"
//	dw_list.object.sum_bilcost1.Format = "#,##0"
//	dw_list.object.sum_bilcost2.Format = "#,##0"
//	dw_list.object.sum_bilcost3.Format = "#,##0"
//	dw_list.object.sum_bilcost4.Format = "#,##0"
//	dw_list.object.sum_bilcost5.Format = "#,##0"
//	dw_list.object.sum_bilcost6.Format = "#,##0"
//	dw_list.object.sum_bilcost7.Format = "#,##0"
//	dw_list.object.sum_tot.Format = "#,##0"
//	dw_list.object.tot_bilcost1.Format = "#,##0"
//	dw_list.object.tot_bilcost2.Format = "#,##0"
//	dw_list.object.tot_bilcost3.Format = "#,##0"
//	dw_list.object.tot_bilcost4.Format = "#,##0"
//	dw_list.object.tot_bilcost5.Format = "#,##0"
//	dw_list.object.tot_bilcost6.Format = "#,##0"
//	dw_list.object.tot_bilcost7.Format = "#,##0"
//	dw_list.object.total.Format = "#,##0"	
//End If

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;String ls_ref_desc

//dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)

end event

type dw_cond from w_a_print`dw_cond within s2w_prt_country_hour_v20
integer width = 2290
integer height = 348
string dataobject = "s2dw_cnd_reg_country_hour_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_filter, ls_svccod, ls_priceplan
Int li_rc

DataWindowChild ldwc_nodeno, ldwc_priceplan
dw_cond.Accepttext()
Choose Case dwo.Name	
	Case "svccod"
		dw_cond.object.priceplan[1] = ''
		ls_svccod = dw_cond.object.svccod[1] 
		
		li_rc = This.GetChild("priceplan", ldwc_priceplan)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : priceplan")
			Return
		End If
		
		ls_filter = "svccod = '" + ls_svccod + "' "
		ldwc_priceplan.SetFilter(ls_filter)
		ldwc_priceplan.Filter()
		
		ldwc_priceplan.SetTransObject(SQLCA)
		
		li_rc = ldwc_priceplan.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "priceplan Retrieve()")
			Return
		End If		
		
		dw_cond.object.nodeno[1] = ''
		
		li_rc = This.GetChild("nodeno", ldwc_nodeno)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : nodeno")
			Return
		End If
		
		ls_filter = "b.svccod = '" + ls_svccod + "' "
		ldwc_nodeno.SetFilter(ls_filter)
		ldwc_nodeno.Filter()
		
		ldwc_nodeno.SetTransObject(SQLCA)
		
		li_rc = ldwc_nodeno.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Nodeno Retrieve()")
			Return
		End If
		
End Choose

end event

type p_ok from w_a_print`p_ok within s2w_prt_country_hour_v20
integer x = 2487
integer y = 56
end type

type p_close from w_a_print`p_close within s2w_prt_country_hour_v20
integer x = 2789
integer y = 56
end type

type dw_list from w_a_print`dw_list within s2w_prt_country_hour_v20
integer y = 440
integer height = 1180
string dataobject = "s2dw_prt_country_hour_time_v20"
end type

event dw_list::retrieveend;call super::retrieveend;string ls_format, ls_ref_desc, ls_gubun
//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)

ls_gubun = dw_cond.object.gubun[1]
If ls_gubun = '1' or ls_gubun = '2' Then //통화수, 통화시간
	ls_format = '3'
End If

If ls_format = "1" Then
	dw_list.object.h00.Format = "#,##0.0"
	dw_list.object.h01.Format = "#,##0.0"
	dw_list.object.h02.Format = "#,##0.0"
	dw_list.object.h03.Format = "#,##0.0"
	dw_list.object.h04.Format = "#,##0.0"
	dw_list.object.h05.Format = "#,##0.0"
	dw_list.object.h06.Format = "#,##0.0"
	dw_list.object.h07.Format = "#,##0.0"
	dw_list.object.h08.Format = "#,##0.0"
	dw_list.object.h09.Format = "#,##0.0"
	dw_list.object.h10.Format = "#,##0.0"
	dw_list.object.h11.Format = "#,##0.0"
	dw_list.object.h12.Format = "#,##0.0"
	dw_list.object.h13.Format = "#,##0.0"
	dw_list.object.h14.Format = "#,##0.0"
	dw_list.object.h15.Format = "#,##0.0"
	dw_list.object.h16.Format = "#,##0.0"
	dw_list.object.h17.Format = "#,##0.0"
	dw_list.object.h18.Format = "#,##0.0"
	dw_list.object.h19.Format = "#,##0.0"
	dw_list.object.h20.Format = "#,##0.0"
	dw_list.object.h21.Format = "#,##0.0"
	dw_list.object.h22.Format = "#,##0.0"
	dw_list.object.h23.Format = "#,##0.0"
	dw_list.object.h_tot.Format = "#,##0.0"
	dw_list.object.h00_t.Format = "#,##0.0"
	dw_list.object.h01_t.Format = "#,##0.0"
	dw_list.object.h02_t.Format = "#,##0.0"
	dw_list.object.h03_t.Format = "#,##0.0"
	dw_list.object.h04_t.Format = "#,##0.0"
	dw_list.object.h05_t.Format = "#,##0.0"
	dw_list.object.h06_t.Format = "#,##0.0"
	dw_list.object.h07_t.Format = "#,##0.0"
	dw_list.object.h08_t.Format = "#,##0.0"
	dw_list.object.h09_t.Format = "#,##0.0"
	dw_list.object.h10_t.Format = "#,##0.0"
	dw_list.object.h11_t.Format = "#,##0.0"
	dw_list.object.h12_t.Format = "#,##0.0"
	dw_list.object.h13_t.Format = "#,##0.0"
	dw_list.object.h14_t.Format = "#,##0.0"
	dw_list.object.h15_t.Format = "#,##0.0"
	dw_list.object.h16_t.Format = "#,##0.0"
	dw_list.object.h17_t.Format = "#,##0.0"
	dw_list.object.h18_t.Format = "#,##0.0"
	dw_list.object.h19_t.Format = "#,##0.0"
	dw_list.object.h20_t.Format = "#,##0.0"
	dw_list.object.h21_t.Format = "#,##0.0"
	dw_list.object.h22_t.Format = "#,##0.0"
	dw_list.object.h23_t.Format = "#,##0.0"
	dw_list.object.h_tot_t.Format = "#,##0.0"
	
ElseIf ls_format = "2" Then
	dw_list.object.h00.Format = "#,##0.00"
	dw_list.object.h01.Format = "#,##0.00"
	dw_list.object.h02.Format = "#,##0.00"
	dw_list.object.h03.Format = "#,##0.00"
	dw_list.object.h04.Format = "#,##0.00"
	dw_list.object.h05.Format = "#,##0.00"
	dw_list.object.h06.Format = "#,##0.00"
	dw_list.object.h07.Format = "#,##0.00"
	dw_list.object.h08.Format = "#,##0.00"
	dw_list.object.h09.Format = "#,##0.00"
	dw_list.object.h10.Format = "#,##0.00"
	dw_list.object.h11.Format = "#,##0.00"
	dw_list.object.h12.Format = "#,##0.00"
	dw_list.object.h13.Format = "#,##0.00"
	dw_list.object.h14.Format = "#,##0.00"
	dw_list.object.h15.Format = "#,##0.00"
	dw_list.object.h16.Format = "#,##0.00"
	dw_list.object.h17.Format = "#,##0.00"
	dw_list.object.h18.Format = "#,##0.00"
	dw_list.object.h19.Format = "#,##0.00"
	dw_list.object.h20.Format = "#,##0.00"
	dw_list.object.h21.Format = "#,##0.00"
	dw_list.object.h22.Format = "#,##0.00"
	dw_list.object.h23.Format = "#,##0.00"
	dw_list.object.h_tot.Format = "#,##0.00"
	dw_list.object.h00_t.Format = "#,##0.00"
	dw_list.object.h01_t.Format = "#,##0.00"
	dw_list.object.h02_t.Format = "#,##0.00"
	dw_list.object.h03_t.Format = "#,##0.00"
	dw_list.object.h04_t.Format = "#,##0.00"
	dw_list.object.h05_t.Format = "#,##0.00"
	dw_list.object.h06_t.Format = "#,##0.00"
	dw_list.object.h07_t.Format = "#,##0.00"
	dw_list.object.h08_t.Format = "#,##0.00"
	dw_list.object.h09_t.Format = "#,##0.00"
	dw_list.object.h10_t.Format = "#,##0.00"
	dw_list.object.h11_t.Format = "#,##0.00"
	dw_list.object.h12_t.Format = "#,##0.00"
	dw_list.object.h13_t.Format = "#,##0.00"
	dw_list.object.h14_t.Format = "#,##0.00"
	dw_list.object.h15_t.Format = "#,##0.00"
	dw_list.object.h16_t.Format = "#,##0.00"
	dw_list.object.h17_t.Format = "#,##0.00"
	dw_list.object.h18_t.Format = "#,##0.00"
	dw_list.object.h19_t.Format = "#,##0.00"
	dw_list.object.h20_t.Format = "#,##0.00"
	dw_list.object.h21_t.Format = "#,##0.00"
	dw_list.object.h22_t.Format = "#,##0.00"
	dw_list.object.h23_t.Format = "#,##0.00"
	dw_list.object.h_tot_t.Format = "#,##0.00"	
Else
	dw_list.object.h00.Format = "#,##0"
	dw_list.object.h01.Format = "#,##0"
	dw_list.object.h02.Format = "#,##0"
	dw_list.object.h03.Format = "#,##0"
	dw_list.object.h04.Format = "#,##0"
	dw_list.object.h05.Format = "#,##0"
	dw_list.object.h06.Format = "#,##0"
	dw_list.object.h07.Format = "#,##0"
	dw_list.object.h08.Format = "#,##0"
	dw_list.object.h09.Format = "#,##0"
	dw_list.object.h10.Format = "#,##0"
	dw_list.object.h11.Format = "#,##0"
	dw_list.object.h12.Format = "#,##0"
	dw_list.object.h13.Format = "#,##0"
	dw_list.object.h14.Format = "#,##0"
	dw_list.object.h15.Format = "#,##0"
	dw_list.object.h16.Format = "#,##0"
	dw_list.object.h17.Format = "#,##0"
	dw_list.object.h18.Format = "#,##0"
	dw_list.object.h19.Format = "#,##0"
	dw_list.object.h20.Format = "#,##0"
	dw_list.object.h21.Format = "#,##0"
	dw_list.object.h22.Format = "#,##0"
	dw_list.object.h23.Format = "#,##0"
	dw_list.object.h_tot.Format = "#,##0"
	dw_list.object.h00_t.Format = "#,##0"
	dw_list.object.h01_t.Format = "#,##0"
	dw_list.object.h02_t.Format = "#,##0"
	dw_list.object.h03_t.Format = "#,##0"
	dw_list.object.h04_t.Format = "#,##0"
	dw_list.object.h05_t.Format = "#,##0"
	dw_list.object.h06_t.Format = "#,##0"
	dw_list.object.h07_t.Format = "#,##0"
	dw_list.object.h08_t.Format = "#,##0"
	dw_list.object.h09_t.Format = "#,##0"
	dw_list.object.h10_t.Format = "#,##0"
	dw_list.object.h11_t.Format = "#,##0"
	dw_list.object.h12_t.Format = "#,##0"
	dw_list.object.h13_t.Format = "#,##0"
	dw_list.object.h14_t.Format = "#,##0"
	dw_list.object.h15_t.Format = "#,##0"
	dw_list.object.h16_t.Format = "#,##0"
	dw_list.object.h17_t.Format = "#,##0"
	dw_list.object.h18_t.Format = "#,##0"
	dw_list.object.h19_t.Format = "#,##0"
	dw_list.object.h20_t.Format = "#,##0"
	dw_list.object.h21_t.Format = "#,##0"
	dw_list.object.h22_t.Format = "#,##0"
	dw_list.object.h23_t.Format = "#,##0"
	dw_list.object.h_tot_t.Format = "#,##0"	
End If
end event

type p_1 from w_a_print`p_1 within s2w_prt_country_hour_v20
end type

type p_2 from w_a_print`p_2 within s2w_prt_country_hour_v20
end type

type p_3 from w_a_print`p_3 within s2w_prt_country_hour_v20
end type

type p_5 from w_a_print`p_5 within s2w_prt_country_hour_v20
end type

type p_6 from w_a_print`p_6 within s2w_prt_country_hour_v20
end type

type p_7 from w_a_print`p_7 within s2w_prt_country_hour_v20
end type

type p_8 from w_a_print`p_8 within s2w_prt_country_hour_v20
end type

type p_9 from w_a_print`p_9 within s2w_prt_country_hour_v20
end type

type p_4 from w_a_print`p_4 within s2w_prt_country_hour_v20
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_country_hour_v20
end type

type p_port from w_a_print`p_port within s2w_prt_country_hour_v20
end type

type p_land from w_a_print`p_land within s2w_prt_country_hour_v20
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_country_hour_v20
integer width = 2336
integer height = 412
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_country_hour_v20
end type

