$PBExportHeader$b2w_prt_priceplan_profit_cost.srw
$PBExportComments$[ohj] 가격정책별 원가대비 수익율현황
forward
global type b2w_prt_priceplan_profit_cost from w_a_print
end type
end forward

global type b2w_prt_priceplan_profit_cost from w_a_print
integer width = 3173
end type
global b2w_prt_priceplan_profit_cost b2w_prt_priceplan_profit_cost

on b2w_prt_priceplan_profit_cost.create
call super::create
end on

on b2w_prt_priceplan_profit_cost.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로인쇄
ib_margin = True
end event

event ue_saveas();call super::ue_saveas;ib_saveas = True
idw_saveas = dw_list
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;//조회
String ls_pre_from, ls_pre_to, ls_svccod, ls_priceplan, ls_where
Long ll_row

ls_pre_from  = String(dw_cond.object.pre_from[1], 'yyyymmdd')
ls_pre_to    = String(dw_cond.object.pre_to[1]  , 'yyyymmdd')
ls_svccod    = dw_cond.object.svccod[1]
ls_priceplan = dw_cond.object.priceplan[1]


If IsNull(ls_pre_from) Then ls_pre_from = ""
If IsNull(ls_pre_to)   Then ls_pre_to   = ""

If ls_pre_from = "" Then
	f_msg_info(200, title, "기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pre_from")
	Return
End If

If ls_pre_to = "" Then
	f_msg_info(200, title, "기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pre_to")
	Return
End If

If ls_pre_from > ls_pre_to Then
	f_msg_usr_err(210, Title, "기간시작일 <= 기간종료일")
	dw_cond.SetFocus()
	dw_cond.setColumn("pre_from")
	Return 
End If

ls_where = ""
ls_where = "TO_CHAR(A.COSTDT, 'yyyymmdd') >='" + ls_pre_from + "' AND TO_CHAR(A.COSTDT, 'yyyymmdd') <= '" + ls_pre_to + "'"

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.svccod = '" + ls_svccod + "'"
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.priceplan = '" + ls_priceplan + "'"
End If

dw_list.is_where = ls_where

dw_list.object.fr_to.Text = String(dw_cond.object.pre_from[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.pre_to[1], 'yyyy-mm-dd')

ll_row = dw_list.Retrieve()

If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

type dw_cond from w_a_print`dw_cond within b2w_prt_priceplan_profit_cost
integer y = 48
integer width = 2345
integer height = 172
string dataobject = "b2dw_cnd_prt_priceplan_profit_cost"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_priceplan_profit_cost
integer x = 2510
end type

type p_close from w_a_print`p_close within b2w_prt_priceplan_profit_cost
integer x = 2811
end type

type dw_list from w_a_print`dw_list within b2w_prt_priceplan_profit_cost
integer y = 272
integer width = 3058
integer height = 1348
string dataobject = "b2dw_prt_priceplan_profit_cost"
end type

type p_1 from w_a_print`p_1 within b2w_prt_priceplan_profit_cost
end type

type p_2 from w_a_print`p_2 within b2w_prt_priceplan_profit_cost
end type

type p_3 from w_a_print`p_3 within b2w_prt_priceplan_profit_cost
end type

type p_5 from w_a_print`p_5 within b2w_prt_priceplan_profit_cost
end type

type p_6 from w_a_print`p_6 within b2w_prt_priceplan_profit_cost
end type

type p_7 from w_a_print`p_7 within b2w_prt_priceplan_profit_cost
end type

type p_8 from w_a_print`p_8 within b2w_prt_priceplan_profit_cost
end type

type p_9 from w_a_print`p_9 within b2w_prt_priceplan_profit_cost
end type

type p_4 from w_a_print`p_4 within b2w_prt_priceplan_profit_cost
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_priceplan_profit_cost
end type

type p_port from w_a_print`p_port within b2w_prt_priceplan_profit_cost
end type

type p_land from w_a_print`p_land within b2w_prt_priceplan_profit_cost
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_priceplan_profit_cost
integer width = 2395
integer height = 240
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_priceplan_profit_cost
end type

