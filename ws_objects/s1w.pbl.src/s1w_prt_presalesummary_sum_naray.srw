$PBExportHeader$s1w_prt_presalesummary_sum_naray.srw
$PBExportComments$[lwlee] 매출액산정 보고서-sum
forward
global type s1w_prt_presalesummary_sum_naray from w_a_print
end type
end forward

global type s1w_prt_presalesummary_sum_naray from w_a_print
end type
global s1w_prt_presalesummary_sum_naray s1w_prt_presalesummary_sum_naray

on s1w_prt_presalesummary_sum_naray.create
call super::create
end on

on s1w_prt_presalesummary_sum_naray.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s1w_prt_presalesummary
	Desc.	: 	매출액산정 보고서
	Ver.	:	1.0
	Date	:	2005.12.01
	Programer : Jin-Won,Lee(jwlee)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format
Date ld_sysdate

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.s_date[1] = ld_sysdate

end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_sdate, ls_edate, ls_priceplan, ls_partner, ls_where
Date   ld_date
Long   ll_row

ld_date      = dw_cond.object.s_date[1]
ls_sdate     = String(ld_date, 'yyyymm')//+'01'
//ls_edate     = String(ld_date, 'yyyymmdd')
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_partner   = Trim(dw_cond.object.partner[1])

If fs_snvl(ls_sdate,"") = "" Then
	f_msg_info(200, title, "기준일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("s_date")
	Return
End If

//If fs_snvl(ls_priceplan,"") = "" Then
//	f_msg_info(200, title, "가격정책")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("priceplan")
//	Return
//End If

//조건 Setting
dw_list.object.t_date.Text   = LeftA(ls_sdate,4)+'-'+RightA(ls_sdate,2)

If ls_where <> "" Then ls_where += " And "
ls_where = "YYYYMM = '" + ls_sdate  + "' "
//ls_where = "YYYY_MM between '" + ls_sdate + "'  and  '" + ls_edate + "'"

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "priceplan = '" + ls_priceplan + "' "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner_prefix = '" + ls_partner + "' "
End If

dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve()
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;String ls_ref_desc
Date ld_sysdate

ld_sysdate = date(fdt_get_dbserver_now())

dw_cond.Object.s_date[1] = ld_sysdate

end event

event ue_saveas();
f_excel_ascii1(dw_list,'s1w_prt_presalesummary_sum_naray')
end event

type dw_cond from w_a_print`dw_cond within s1w_prt_presalesummary_sum_naray
integer y = 36
integer width = 1833
integer height = 280
string dataobject = "s1dw_cnd_prt_presalesummary_sum_naray"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s1w_prt_presalesummary_sum_naray
end type

type p_close from w_a_print`p_close within s1w_prt_presalesummary_sum_naray
end type

type dw_list from w_a_print`dw_list within s1w_prt_presalesummary_sum_naray
string dataobject = "s1dw_prt_presalesummary_sum_naray"
end type

event dw_list::retrieveend;call super::retrieveend;//Long  ll_row
//
//dw_list.AcceptText()
//
//If dw_list.RowCount() > 0 Then
//	For ll_row = 1 To dw_list.RowCount()
//		dw_list.object.cnt_rate[ll_row] = dw_list.object.compute_6[ll_row]
//		dw_list.object.amt_rate[ll_row] = dw_list.object.compute_7[ll_row]
//	Next
//End If
end event

type p_1 from w_a_print`p_1 within s1w_prt_presalesummary_sum_naray
end type

type p_2 from w_a_print`p_2 within s1w_prt_presalesummary_sum_naray
end type

type p_3 from w_a_print`p_3 within s1w_prt_presalesummary_sum_naray
end type

type p_5 from w_a_print`p_5 within s1w_prt_presalesummary_sum_naray
end type

type p_6 from w_a_print`p_6 within s1w_prt_presalesummary_sum_naray
end type

type p_7 from w_a_print`p_7 within s1w_prt_presalesummary_sum_naray
end type

type p_8 from w_a_print`p_8 within s1w_prt_presalesummary_sum_naray
end type

type p_9 from w_a_print`p_9 within s1w_prt_presalesummary_sum_naray
end type

type p_4 from w_a_print`p_4 within s1w_prt_presalesummary_sum_naray
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_presalesummary_sum_naray
end type

type p_port from w_a_print`p_port within s1w_prt_presalesummary_sum_naray
end type

type p_land from w_a_print`p_land within s1w_prt_presalesummary_sum_naray
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_presalesummary_sum_naray
integer width = 1874
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_presalesummary_sum_naray
end type

