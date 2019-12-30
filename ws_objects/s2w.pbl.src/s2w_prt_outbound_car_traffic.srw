$PBExportHeader$s2w_prt_outbound_car_traffic.srw
$PBExportComments$[kjm]outbound 사업자별 트래픽 현황
forward
global type s2w_prt_outbound_car_traffic from w_a_print
end type
end forward

global type s2w_prt_outbound_car_traffic from w_a_print
end type
global s2w_prt_outbound_car_traffic s2w_prt_outbound_car_traffic

on s2w_prt_outbound_car_traffic.create
call super::create
end on

on s2w_prt_outbound_car_traffic.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_ymd_fr, ls_ymd_to
String ls_where, ls_date, ls_dis_currency
Dec{0} lc_rate
Long   ll_row

ls_ymd_fr    = String(dw_cond.object.ymd_fr[1], 'yyyymmdd')
ls_ymd_to    = String(dw_cond.object.ymd_to[1], 'yyyymmdd')

If IsNull(ls_ymd_fr) Then ls_ymd_fr = ""
If IsNull(ls_ymd_to) Then ls_ymd_to = ""

If ls_ymd_fr = "" Then 
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("ymd_fr")
	Return
End If

If ls_ymd_to = "" Then 
	f_msg_info(200, title, "작업일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("ymd_to")
	Return
End If

If ls_ymd_fr <> "" And ls_ymd_to <> "" Then
	If ls_ymd_fr > ls_ymd_to Then
		f_msg_usr_err(210, title, "작업일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("ymd_fr")
		Return
	End If
End If
//messagebox('ls_ymd_fr', ls_ymd_fr)
//messagebox('ls_ymd_to', ls_ymd_to)
ll_row	= dw_list.Retrieve(ls_ymd_fr,ls_ymd_to)

If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

type dw_cond from w_a_print`dw_cond within s2w_prt_outbound_car_traffic
integer width = 1376
integer height = 124
string dataobject = "s2dw_cnd_reg_outbound_carrier_traffic"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_outbound_car_traffic
end type

type p_close from w_a_print`p_close within s2w_prt_outbound_car_traffic
end type

type dw_list from w_a_print`dw_list within s2w_prt_outbound_car_traffic
integer y = 196
string dataobject = "s2dw_prt_outbound_carrier_traffic"
end type

type p_1 from w_a_print`p_1 within s2w_prt_outbound_car_traffic
end type

type p_2 from w_a_print`p_2 within s2w_prt_outbound_car_traffic
end type

type p_3 from w_a_print`p_3 within s2w_prt_outbound_car_traffic
end type

type p_5 from w_a_print`p_5 within s2w_prt_outbound_car_traffic
end type

type p_6 from w_a_print`p_6 within s2w_prt_outbound_car_traffic
end type

type p_7 from w_a_print`p_7 within s2w_prt_outbound_car_traffic
end type

type p_8 from w_a_print`p_8 within s2w_prt_outbound_car_traffic
end type

type p_9 from w_a_print`p_9 within s2w_prt_outbound_car_traffic
end type

type p_4 from w_a_print`p_4 within s2w_prt_outbound_car_traffic
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_outbound_car_traffic
end type

type p_port from w_a_print`p_port within s2w_prt_outbound_car_traffic
end type

type p_land from w_a_print`p_land within s2w_prt_outbound_car_traffic
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_outbound_car_traffic
integer width = 1413
integer height = 180
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_outbound_car_traffic
end type

