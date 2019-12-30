$PBExportHeader$b5w_prt_paylist_hotreqdtl.srw
$PBExportComments$[CEUSEE] 기간별 청구수납현황
forward
global type b5w_prt_paylist_hotreqdtl from w_a_print
end type
end forward

global type b5w_prt_paylist_hotreqdtl from w_a_print
end type
global b5w_prt_paylist_hotreqdtl b5w_prt_paylist_hotreqdtl

type variables
Int ii_pos
end variables

on b5w_prt_paylist_hotreqdtl.create
call super::create
end on

on b5w_prt_paylist_hotreqdtl.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_saveas();call super::ue_saveas;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;Long ll_rows

ll_rows = dw_list.Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
End If
end event

event ue_reset();call super::ue_reset;dw_cond.object.fromdt[1] = Date(fdt_get_dbserver_now())

end event

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b5w_prt_paylist_hotreqdtl
integer x = 73
integer y = 92
integer width = 1042
integer height = 148
string dataobject = "b5dw_cnd_prt_paylist_hotreqdtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_prt_paylist_hotreqdtl
integer x = 1321
integer y = 48
end type

type p_close from w_a_print`p_close within b5w_prt_paylist_hotreqdtl
integer x = 1623
integer y = 48
end type

type dw_list from w_a_print`dw_list within b5w_prt_paylist_hotreqdtl
integer y = 288
integer height = 1332
string dataobject = "b5dw_prt_paylist_hotreqdtl"
end type

type p_1 from w_a_print`p_1 within b5w_prt_paylist_hotreqdtl
end type

type p_2 from w_a_print`p_2 within b5w_prt_paylist_hotreqdtl
end type

type p_3 from w_a_print`p_3 within b5w_prt_paylist_hotreqdtl
end type

type p_5 from w_a_print`p_5 within b5w_prt_paylist_hotreqdtl
end type

type p_6 from w_a_print`p_6 within b5w_prt_paylist_hotreqdtl
end type

type p_7 from w_a_print`p_7 within b5w_prt_paylist_hotreqdtl
end type

type p_8 from w_a_print`p_8 within b5w_prt_paylist_hotreqdtl
end type

type p_9 from w_a_print`p_9 within b5w_prt_paylist_hotreqdtl
end type

type p_4 from w_a_print`p_4 within b5w_prt_paylist_hotreqdtl
end type

type gb_1 from w_a_print`gb_1 within b5w_prt_paylist_hotreqdtl
end type

type p_port from w_a_print`p_port within b5w_prt_paylist_hotreqdtl
end type

type p_land from w_a_print`p_land within b5w_prt_paylist_hotreqdtl
end type

type gb_cond from w_a_print`gb_cond within b5w_prt_paylist_hotreqdtl
integer width = 1157
integer height = 264
end type

type p_saveas from w_a_print`p_saveas within b5w_prt_paylist_hotreqdtl
end type

