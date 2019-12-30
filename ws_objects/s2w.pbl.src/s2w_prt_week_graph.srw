$PBExportHeader$s2w_prt_week_graph.srw
$PBExportComments$[kem] 요일별 통계 그래프
forward
global type s2w_prt_week_graph from w_a_print
end type
end forward

global type s2w_prt_week_graph from w_a_print
end type
global s2w_prt_week_graph s2w_prt_week_graph

on s2w_prt_week_graph.create
call super::create
end on

on s2w_prt_week_graph.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s2w_prt_graph_hour
	Desc.	: 	통화량 상품별 실적 그래프 
	Ver.	:	1.0
	Date	:	2003.08.29
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
String ls_ref_desc, ls_format

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)
dw_cond.Object.type[1] = "1"

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_use_fr, ls_use_to, ls_currency, ls_type
String ls_where, ls_date, ls_dis_currency
Dec{0} lc_rate
Long   ll_row

ls_use_fr    = String(dw_cond.object.use_fr[1], 'yyyymmdd')
ls_use_to    = String(dw_cond.object.use_to[1], 'yyyymmdd')
ls_currency  = Trim(dw_cond.object.currency[1])
ls_type      = Trim(dw_cond.object.type[1])

If IsNull(ls_use_fr) Then ls_use_fr = ""
If IsNull(ls_use_to) Then ls_use_to = ""
If IsNull(ls_currency) Then ls_currency = ""
If IsNull(ls_type) Then ls_type = ""

If ls_use_fr = "" Then 
	f_msg_info(200, title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_fr")
	Return
End If

ls_date = MidA(ls_use_fr,1,4) + "-" +  MidA(ls_use_fr, 5,2)+ "-" + MidA(ls_use_fr, 7,2) + " ~~ "

If ls_use_to = "" Then 
	f_msg_info(200, title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("use_to")
	Return
End If

ls_date += MidA(ls_use_to,1,4) + "-" +  MidA(ls_use_to, 5,2)+ "-" +  MidA(ls_use_to, 7,2)

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

If ls_type = "" Then 
	f_msg_info(200, title, "그래프종류")
	dw_cond.SetFocus()
	dw_cond.SetColumn("type")
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

//데이터 윈도우 바꾸기 
If ls_type = "1"  Then 
	dw_list.DataObject = "s2dw_prt_week_graph"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
ElseIf ls_type = "2" Then
	dw_list.DataObject = "s2dw_prt_week_graphpie"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
End If

ls_dis_currency = dw_cond.Describe("evaluate('lookupdisplay(currency)',1 )")

//조건 Setting
If ls_date = "" Then ls_date = "All"
dw_list.object.t_date.Text = ls_date
dw_list.object.t_currency.Text = ls_dis_currency
dw_list.object.t_unit.Text = "시간단위:1/60 금액단위:1/" + String(lc_rate)

//dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve(lc_rate, ls_use_fr, ls_use_to, ls_currency)
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event ue_reset();call super::ue_reset;String ls_ref_desc, ls_format

dw_cond.Object.currency[1] = fs_get_control("B0", "P105", ls_ref_desc)
dw_cond.Object.type[1] = "1"
end event

type dw_cond from w_a_print`dw_cond within s2w_prt_week_graph
integer y = 40
integer width = 1330
integer height = 284
string dataobject = "s2dw_cnd_reg_week_graph"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_week_graph
integer x = 1550
end type

type p_close from w_a_print`p_close within s2w_prt_week_graph
integer x = 1851
end type

type dw_list from w_a_print`dw_list within s2w_prt_week_graph
integer y = 348
integer height = 1272
string dataobject = "s2dw_prt_week_graph"
end type

type p_1 from w_a_print`p_1 within s2w_prt_week_graph
end type

type p_2 from w_a_print`p_2 within s2w_prt_week_graph
end type

type p_3 from w_a_print`p_3 within s2w_prt_week_graph
end type

type p_5 from w_a_print`p_5 within s2w_prt_week_graph
end type

type p_6 from w_a_print`p_6 within s2w_prt_week_graph
end type

type p_7 from w_a_print`p_7 within s2w_prt_week_graph
end type

type p_8 from w_a_print`p_8 within s2w_prt_week_graph
end type

type p_9 from w_a_print`p_9 within s2w_prt_week_graph
end type

type p_4 from w_a_print`p_4 within s2w_prt_week_graph
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_week_graph
end type

type p_port from w_a_print`p_port within s2w_prt_week_graph
end type

type p_land from w_a_print`p_land within s2w_prt_week_graph
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_week_graph
integer width = 1413
integer height = 340
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_week_graph
end type

