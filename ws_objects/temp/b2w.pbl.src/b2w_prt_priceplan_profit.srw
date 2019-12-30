$PBExportHeader$b2w_prt_priceplan_profit.srw
$PBExportComments$[ohj] 가격정책별 수익율 증감현황
forward
global type b2w_prt_priceplan_profit from w_a_print
end type
end forward

global type b2w_prt_priceplan_profit from w_a_print
integer width = 3259
end type
global b2w_prt_priceplan_profit b2w_prt_priceplan_profit

on b2w_prt_priceplan_profit.create
call super::create
end on

on b2w_prt_priceplan_profit.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_pre_from, ls_pre_to, ls_now_from, ls_now_to
Long ll_row

ls_pre_from = String(dw_cond.object.pre_from[1], 'yyyymmdd')
ls_pre_to   = String(dw_cond.object.pre_to[1]  , 'yyyymmdd')
ls_now_from = String(dw_cond.object.now_from[1], 'yyyymmdd')
ls_now_to   = String(dw_cond.object.now_to[1]  , 'yyyymmdd')

If IsNull(ls_pre_from) Then ls_pre_from = ""
If IsNull(ls_pre_to)   Then ls_pre_to   = ""
If IsNull(ls_now_from) Then ls_now_from = ""
If IsNull(ls_now_to)   Then ls_now_to   = ""

If ls_pre_from = "" Then
	f_msg_info(200, title, "전기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pre_from")
	Return
End If

If ls_pre_to = "" Then
	f_msg_info(200, title, "전기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pre_to")
	Return
End If

If ls_now_from = "" Then
	f_msg_info(200, title, "당기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("now_from")
	Return
End If

If ls_now_to = "" Then
	f_msg_info(200, title, "당기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("now_to")
	Return
End If

If ls_pre_from > ls_pre_to Then
	f_msg_usr_err(210, Title, "전기기간시작일 <= 전기기간종료일")
	dw_cond.SetFocus()
	dw_cond.setColumn("pre_from")
	Return 
End If

If ls_now_from > ls_now_to Then
	f_msg_usr_err(210, Title, "당기기간시작일 <= 당기기간종료일")
	dw_cond.SetFocus()
	dw_cond.setColumn("now_from")
	Return 
End If

//전기기간, 당기기간 표시
dw_list.object.pre_txt.Text = "전기(" + String(dw_cond.object.pre_from[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.pre_to[1], 'yyyy-mm-dd') +")"
dw_list.object.new_txt.Text = "당기(" + String(dw_cond.object.now_from[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.now_to[1], 'yyyy-mm-dd') +")"
dw_list.object.cha_txt.Text = "차                         이"

ll_row = dw_list.Retrieve(ls_pre_from, ls_pre_to, ls_now_from, ls_now_to)

If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_priceplan_profit
integer x = 64
integer y = 60
integer width = 2203
integer height = 172
string dataobject = "b2dw_cnd_prt_priceplan_profit"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_priceplan_profit
integer x = 2560
end type

type p_close from w_a_print`p_close within b2w_prt_priceplan_profit
integer x = 2862
end type

type dw_list from w_a_print`dw_list within b2w_prt_priceplan_profit
integer y = 300
integer width = 3118
integer height = 1320
string dataobject = "b2dw_prt_priceplan_profit"
end type

type p_1 from w_a_print`p_1 within b2w_prt_priceplan_profit
end type

type p_2 from w_a_print`p_2 within b2w_prt_priceplan_profit
end type

type p_3 from w_a_print`p_3 within b2w_prt_priceplan_profit
end type

type p_5 from w_a_print`p_5 within b2w_prt_priceplan_profit
end type

type p_6 from w_a_print`p_6 within b2w_prt_priceplan_profit
end type

type p_7 from w_a_print`p_7 within b2w_prt_priceplan_profit
end type

type p_8 from w_a_print`p_8 within b2w_prt_priceplan_profit
end type

type p_9 from w_a_print`p_9 within b2w_prt_priceplan_profit
end type

type p_4 from w_a_print`p_4 within b2w_prt_priceplan_profit
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_priceplan_profit
end type

type p_port from w_a_print`p_port within b2w_prt_priceplan_profit
end type

type p_land from w_a_print`p_land within b2w_prt_priceplan_profit
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_priceplan_profit
integer width = 2405
integer height = 260
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_priceplan_profit
end type

