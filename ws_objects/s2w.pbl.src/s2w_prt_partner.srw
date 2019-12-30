$PBExportHeader$s2w_prt_partner.srw
$PBExportComments$[cusee] 상품별일일통계보고서
forward
global type s2w_prt_partner from w_a_print
end type
end forward

global type s2w_prt_partner from w_a_print
end type
global s2w_prt_partner s2w_prt_partner

on s2w_prt_partner.create
call super::create
end on

on s2w_prt_partner.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_use_dt, ls_type, ls_priceplan, ls_currency, ls_use_to, ls_date_to
String ls_where, ls_date, ls_dis_currency
Dec{0} lc_rate
s2c_dbmgr lu_dbmgr
Long ll_row

ls_use_dt    = String(dw_cond.object.use_dt[1], 'yyyymmdd')
ls_use_to    = String(dw_cond.object.use_to[1], 'yyyymmdd')
ls_type      = Trim(dw_cond.object.type[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_currency  = Trim(dw_cond.object.currency[1])

If IsNull(ls_use_dt)    Then ls_use_dt = ""
If IsNull(ls_use_to)    Then ls_use_to = ""
If IsNull(ls_type)      Then ls_type = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_currency)  Then ls_currency = ""

If ls_use_dt = "" Then 
	f_msg_info(200, title, "통화기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_dt")
	Return
End If
If ls_use_to = "" Then 
	f_msg_info(200, title, "통화기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_to")
	Return
End If

If ls_use_dt > ls_use_to Then
	f_msg_info(200, title, "통화기간(to)를 확인하세요.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_to")
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

If ls_use_dt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " workdt  >= '" + ls_use_dt + "' "	
End If

If ls_use_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " workdt  <= '" + ls_use_to + "' "	
End If

ls_date    = MidA(ls_use_dt,1,4) + "-" +  MidA(ls_use_dt, 5,2)+ "-" +  MidA(ls_use_dt, 7,2) 
ls_date_to = MidA(ls_use_to,1,4) + "-" +  MidA(ls_use_to, 5,2)+ "-" +  MidA(ls_use_to, 7,2)

If ls_currency <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "currency_type = '" + ls_currency + "' "
End If

If ls_type <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "type = '" + ls_type + "' "
	ls_type = dw_cond.Describe("evaluate('lookupdisplay(type)',1 )")
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "priceplan = '" + ls_priceplan + "' "
	ls_priceplan = dw_cond.Describe("evaluate('lookupdisplay(priceplan)',1 )")
End If

ls_dis_currency = dw_cond.Describe("evaluate('lookupdisplay(currency)',1 )")

//조건 Setting
If ls_date = "" Then ls_date = "All"
If ls_type = "" Then ls_type = "All"
dw_list.object.t_date.Text = ls_date
dw_list.object.t_date_to.Text = ls_date_to
dw_list.object.t_type.Text = ls_type
dw_list.object.t_currency.Text = ls_dis_currency
dw_list.object.t_unit.Text = "금액단위 : 1/" + String(lc_rate)
SetPointer(HourGlass!)
dw_list.SetRedraw(False)
dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve(lc_rate)
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	dw_list.SetRedraw(True)
	Return 
End If

//사용자수를 구한다.
//lu_dbmgr = Create s2c_dbmgr
//lu_dbmgr.is_caller = "s2w_prt_partner%ok"
//lu_dbmgr.idw_data[1] = dw_list
//lu_dbmgr.uf_prc_db()
//ll_row = lu_dbmgr.ii_rc
//
//Destroy lu_dbmgr
dw_list.SetRedraw(True)
SetPointer(Arrow!)




end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 0 //세로0, 가로1
ib_margin = False
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s2w_prt_origin_week
	Desc.	: 	대리점별요일통계 보고서 
	Ver.	:	1.0
	Date	:	2003.08.28
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)

//금액 format 맞춘다.
ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_list.object.sum_amt.Format = "#,##0.0"
	dw_list.object.tot_amt.Format = "#,##0.0"
	dw_list.object.sum_time.Format = "#,##0.0"

ElseIf ls_format = "2" Then
   dw_list.object.sum_amt.Format = "#,##0.00"
	dw_list.object.tot_amt.Format = "#,##0.00"
	dw_list.object.sum_time.Format = "#,##0.00"
Else
	dw_list.object.sum_amt.Format = "#,##0"
	dw_list.object.tot_amt.Format = "#,##0"
	dw_list.object.sum_time.Format = "#,##0"
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;String ls_ref_desc

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)

end event

type dw_cond from w_a_print`dw_cond within s2w_prt_partner
integer width = 1943
integer height = 288
string dataobject = "s2dw_cnd_reg_partner"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_partner
integer x = 2153
end type

type p_close from w_a_print`p_close within s2w_prt_partner
integer x = 2455
end type

type dw_list from w_a_print`dw_list within s2w_prt_partner
integer y = 372
integer height = 1248
string dataobject = "s2dw_prt_partner"
end type

type p_1 from w_a_print`p_1 within s2w_prt_partner
end type

type p_2 from w_a_print`p_2 within s2w_prt_partner
end type

type p_3 from w_a_print`p_3 within s2w_prt_partner
end type

type p_5 from w_a_print`p_5 within s2w_prt_partner
end type

type p_6 from w_a_print`p_6 within s2w_prt_partner
end type

type p_7 from w_a_print`p_7 within s2w_prt_partner
end type

type p_8 from w_a_print`p_8 within s2w_prt_partner
end type

type p_9 from w_a_print`p_9 within s2w_prt_partner
end type

type p_4 from w_a_print`p_4 within s2w_prt_partner
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_partner
end type

type p_port from w_a_print`p_port within s2w_prt_partner
end type

type p_land from w_a_print`p_land within s2w_prt_partner
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_partner
integer width = 1989
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_partner
end type

