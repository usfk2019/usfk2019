$PBExportHeader$b2w_prt_outbound_profit.srw
$PBExportComments$[ohj] OutBound사업자별 원가대비 수익율 현황
forward
global type b2w_prt_outbound_profit from w_a_print
end type
end forward

global type b2w_prt_outbound_profit from w_a_print
end type
global b2w_prt_outbound_profit b2w_prt_outbound_profit

on b2w_prt_outbound_profit.create
call super::create
end on

on b2w_prt_outbound_profit.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 0 //가로인쇄
ib_margin = True
end event

event ue_saveas();call super::ue_saveas;ib_saveas = True
idw_saveas = dw_list
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;//조회
String ls_from_date, ls_to_date
Long ll_row


ls_from_date = String(dw_cond.object.from_date[1], 'yyyymmdd')
ls_to_date = String(dw_cond.object.to_date[1], 'yyyymmdd')


If IsNull(ls_from_date) Then ls_from_date = ""
If IsNull(ls_to_date) Then ls_to_date = ""

IF ls_from_date = "" THEN
	f_msg_info(200, Title, "기간")
	dw_cond.SetFocus()
	dw_cond.setColumn("from_date")
	RETURN
END IF

IF ls_to_date = "" THEN
	f_msg_info(200, Title, "기간")
	dw_cond.SetFocus()
	dw_cond.setColumn("to_date")
	RETURN
END IF

dw_list.object.fr_to.Text = String(dw_cond.object.from_date[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.to_date[1], 'yyyy-mm-dd')

ll_row = dw_list.Retrieve(ls_from_date, ls_to_date)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

type dw_cond from w_a_print`dw_cond within b2w_prt_outbound_profit
integer y = 56
integer height = 136
string dataobject = "b2dw_cnd_prt_outbound_profit"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_outbound_profit
end type

type p_close from w_a_print`p_close within b2w_prt_outbound_profit
end type

type dw_list from w_a_print`dw_list within b2w_prt_outbound_profit
integer y = 252
integer height = 1368
string dataobject = "b2dw_prt_outbound_profit"
end type

type p_1 from w_a_print`p_1 within b2w_prt_outbound_profit
end type

type p_2 from w_a_print`p_2 within b2w_prt_outbound_profit
end type

type p_3 from w_a_print`p_3 within b2w_prt_outbound_profit
end type

type p_5 from w_a_print`p_5 within b2w_prt_outbound_profit
end type

type p_6 from w_a_print`p_6 within b2w_prt_outbound_profit
end type

type p_7 from w_a_print`p_7 within b2w_prt_outbound_profit
end type

type p_8 from w_a_print`p_8 within b2w_prt_outbound_profit
end type

type p_9 from w_a_print`p_9 within b2w_prt_outbound_profit
end type

type p_4 from w_a_print`p_4 within b2w_prt_outbound_profit
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_outbound_profit
end type

type p_port from w_a_print`p_port within b2w_prt_outbound_profit
end type

type p_land from w_a_print`p_land within b2w_prt_outbound_profit
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_outbound_profit
integer height = 220
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_outbound_profit
end type

