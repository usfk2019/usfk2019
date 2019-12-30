$PBExportHeader$s2w_prt_outbound_zon_traffic.srw
$PBExportComments$[kjm]outbound 대역별 트래픽 현황
forward
global type s2w_prt_outbound_zon_traffic from w_a_print
end type
end forward

global type s2w_prt_outbound_zon_traffic from w_a_print
integer width = 3566
end type
global s2w_prt_outbound_zon_traffic s2w_prt_outbound_zon_traffic

on s2w_prt_outbound_zon_traffic.create
call super::create
end on

on s2w_prt_outbound_zon_traffic.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_ymd_fr, ls_ymd_to,	ls_carrier,	ls_areagroup
String ls_where, ls_date, ls_dis_currency
Dec{0} lc_rate
Long   ll_row

ls_ymd_fr  = String(dw_cond.object.ymd_fr[1], 'yyyymmdd')
ls_ymd_to  = String(dw_cond.object.ymd_to[1], 'yyyymmdd')
ls_carrier  = Trim(dw_cond.object.carrier[1])
ls_areagroup  = Trim(dw_cond.object.areagroup[1])

If IsNull(ls_ymd_fr) Then ls_ymd_fr = ""
If IsNull(ls_ymd_to) Then ls_ymd_to = ""
If IsNull(ls_carrier) Then ls_carrier = ""
If IsNull(ls_areagroup) Then ls_areagroup = ""

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

If ls_carrier <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "carrier = '" + ls_carrier + "' "
END IF

If ls_areagroup <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "areagroup = '" + ls_areagroup + "' "
END IF

dw_list.is_where = ls_where

If ls_carrier = "" Then
	dw_list.object.carrier_11.Text = 'ALL'
Else
	dw_list.object.carrier_11.Text = dw_cond.object.t_carrier[1]
End If

If ls_areagroup = "" Then
	dw_list.object.areagroup_11.Text = 'ALL'
Else
	dw_list.object.areagroup_11.Text = dw_cond.object.t_areagroup[1]
End If

ll_row	= dw_list.Retrieve(ls_ymd_fr,ls_ymd_to)

If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

type dw_cond from w_a_print`dw_cond within s2w_prt_outbound_zon_traffic
integer width = 2555
integer height = 204
string dataobject = "s2dw_cnd_reg_outbound_zon_traffic"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_outbound_zon_traffic
integer x = 2734
end type

type p_close from w_a_print`p_close within s2w_prt_outbound_zon_traffic
integer x = 3035
end type

type dw_list from w_a_print`dw_list within s2w_prt_outbound_zon_traffic
integer y = 288
integer width = 3291
string dataobject = "s2dw_prt_outbound_zon_traffic"
end type

type p_1 from w_a_print`p_1 within s2w_prt_outbound_zon_traffic
end type

type p_2 from w_a_print`p_2 within s2w_prt_outbound_zon_traffic
end type

type p_3 from w_a_print`p_3 within s2w_prt_outbound_zon_traffic
end type

type p_5 from w_a_print`p_5 within s2w_prt_outbound_zon_traffic
end type

type p_6 from w_a_print`p_6 within s2w_prt_outbound_zon_traffic
end type

type p_7 from w_a_print`p_7 within s2w_prt_outbound_zon_traffic
end type

type p_8 from w_a_print`p_8 within s2w_prt_outbound_zon_traffic
end type

type p_9 from w_a_print`p_9 within s2w_prt_outbound_zon_traffic
end type

type p_4 from w_a_print`p_4 within s2w_prt_outbound_zon_traffic
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_outbound_zon_traffic
end type

type p_port from w_a_print`p_port within s2w_prt_outbound_zon_traffic
end type

type p_land from w_a_print`p_land within s2w_prt_outbound_zon_traffic
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_outbound_zon_traffic
integer width = 2610
integer height = 260
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_outbound_zon_traffic
end type

