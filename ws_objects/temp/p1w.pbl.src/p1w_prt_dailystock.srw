$PBExportHeader$p1w_prt_dailystock.srw
$PBExportComments$[jykim] 대리점별 일자별 수불현황
forward
global type p1w_prt_dailystock from w_a_print
end type
end forward

global type p1w_prt_dailystock from w_a_print
integer width = 4105
end type
global p1w_prt_dailystock p1w_prt_dailystock

event ue_ok();call super::ue_ok;Integer li_return
Long ll_row
String ls_where, ls_partner_prefix, ls_inoutdt_from, ls_inoutdt_to

ls_partner_prefix = dw_cond.Object.partner_prefix[1]
If IsNull(ls_partner_prefix) Then ls_partner_prefix = ""


ls_inoutdt_from = String(dw_cond.Object.inoutdt_from[1],"yyyymmdd")
If IsNull(ls_inoutdt_from) Then ls_inoutdt_from = ""

ls_inoutdt_to = String(dw_cond.Object.inoutdt_to[1],"yyyymmdd")
If IsNull(ls_inoutdt_to) Then ls_inoutdt_to = ""

If ls_inoutdt_from <> ls_inoutdt_to Then
ll_row = fi_chk_frto_day(dw_cond.Object.inoutdt_from[1], dw_cond.Object.inoutdt_to[1])
	If ll_row < 0 Then
	 f_msg_usr_err(211, Title, "일자")             //입력 날짜 순서 잘못됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("inoutdt_from")
	 Return
   End if
End if	 
ls_where = ""

If ls_partner_prefix <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner_prefix = '"+ls_partner_prefix+"' "
End If

If ls_inoutdt_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(to_date(inoutdt, 'yyyymmdd'), 'yyyymmdd') >= '"+ls_inoutdt_from+"' "
End If

If ls_inoutdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(to_date(inoutdt, 'yyyymmdd'), 'yyyymmdd') <= '"+ls_inoutdt_to+"' "
End If

dw_list.SetTransObject(SQLCA)
dw_list.is_where = ls_where 
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
End If
end event

on p1w_prt_dailystock.create
call super::create
end on

on p1w_prt_dailystock.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = false
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_dailystock
event ue_saveas_int ( )
integer width = 1408
string dataobject = "p1dw_cnd_prt_dailystock"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_saveas_int();ib_saveas = True
idw_saveas = dw_list
end event

type p_ok from w_a_print`p_ok within p1w_prt_dailystock
integer x = 1573
integer y = 32
end type

type p_close from w_a_print`p_close within p1w_prt_dailystock
integer x = 1573
integer y = 144
end type

type dw_list from w_a_print`dw_list within p1w_prt_dailystock
integer width = 3936
integer height = 1300
string dataobject = "p1dw_prt_dailystock"
end type

type p_1 from w_a_print`p_1 within p1w_prt_dailystock
end type

type p_2 from w_a_print`p_2 within p1w_prt_dailystock
end type

type p_3 from w_a_print`p_3 within p1w_prt_dailystock
end type

type p_5 from w_a_print`p_5 within p1w_prt_dailystock
end type

type p_6 from w_a_print`p_6 within p1w_prt_dailystock
end type

type p_7 from w_a_print`p_7 within p1w_prt_dailystock
end type

type p_8 from w_a_print`p_8 within p1w_prt_dailystock
end type

type p_9 from w_a_print`p_9 within p1w_prt_dailystock
end type

type p_4 from w_a_print`p_4 within p1w_prt_dailystock
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_dailystock
end type

type p_port from w_a_print`p_port within p1w_prt_dailystock
end type

type p_land from w_a_print`p_land within p1w_prt_dailystock
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_dailystock
integer width = 1467
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_dailystock
end type

