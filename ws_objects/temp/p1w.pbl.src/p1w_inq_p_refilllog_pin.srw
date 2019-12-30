$PBExportHeader$p1w_inq_p_refilllog_pin.srw
$PBExportComments$[jsha] pin충전history 조회
forward
global type p1w_inq_p_refilllog_pin from w_a_inq_m
end type
end forward

global type p1w_inq_p_refilllog_pin from w_a_inq_m
end type
global p1w_inq_p_refilllog_pin p1w_inq_p_refilllog_pin

on p1w_inq_p_refilllog_pin.create
call super::create
end on

on p1w_inq_p_refilllog_pin.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_pid, ls_validkey
Long ll_row

ls_pid = Trim(dw_cond.Object.pid[1])
ls_validkey = Trim(dw_cond.Object.validkey[1])

ls_where = ""

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "pid = '" + ls_pid + "' "
End If
If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "validkey = '" + ls_validkey + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
End If
end event

type dw_cond from w_a_inq_m`dw_cond within p1w_inq_p_refilllog_pin
integer x = 64
integer y = 84
integer width = 2007
integer height = 124
string dataobject = "p1dw_cnd_inq_p_refilllog_pin"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within p1w_inq_p_refilllog_pin
integer x = 2245
end type

type p_close from w_a_inq_m`p_close within p1w_inq_p_refilllog_pin
integer x = 2546
end type

type gb_cond from w_a_inq_m`gb_cond within p1w_inq_p_refilllog_pin
integer y = 12
integer width = 2112
integer height = 224
end type

type dw_detail from w_a_inq_m`dw_detail within p1w_inq_p_refilllog_pin
integer y = 264
string dataobject = "p1dw_p_refilllog_pin"
end type

event dw_detail::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.moddt_t
uf_init(ldwo_sort,'D', RGB(0,0,128))
end event

