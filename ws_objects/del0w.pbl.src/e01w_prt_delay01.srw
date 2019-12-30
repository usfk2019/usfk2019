$PBExportHeader$e01w_prt_delay01.srw
$PBExportComments$[parkkh] 연체대상자 출력 - 상세
forward
global type e01w_prt_delay01 from w_a_print
end type
end forward

global type e01w_prt_delay01 from w_a_print
integer width = 3314
end type
global e01w_prt_delay01 e01w_prt_delay01

event ue_init;call super::ue_init;ii_orientation = 1
end event

event ue_ok();call super::ue_ok;Long ll_row
String ls_where , ls_workdt
String ls_status_cd, ls_last_reqdtfr, ls_last_reqdtto, ls_dlyamt, ls_chargeby

ls_status_cd = Trim(dw_cond.object.status_current[1])
ls_workdt = String(dw_cond.Object.work_date[1], "yyyymmdd")
ls_last_reqdtfr = String(dw_cond.Object.last_reqdtfr[1], "yyyymm")
ls_last_reqdtto = String(dw_cond.Object.last_reqdtto[1], "yyyymm")
ls_dlyamt = String(dw_cond.Object.dlyamt[1])
ls_chargeby = Trim(dw_cond.Object.chargeby[1])
If IsNull(ls_workdt) Then ls_workdt = ""
If IsNull(ls_status_cd) Then ls_status_cd = ""
If IsNull(ls_dlyamt) Then ls_dlyamt = ""
If IsNull(ls_chargeby) Then ls_chargeby = ""

If ls_status_cd = "" Then
	f_msg_usr_err(200, This.Title, "현연체상태")	
	dw_cond.Setcolumn(1)
	dw_cond.Setfocus()
	Return
End If

ls_where = ""

If ls_chargeby <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " bil.pay_method = '" + ls_chargeby + "' "
End If
If ls_dlyamt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " dlymst.amount >= " + ls_dlyamt + " "
End If
If ls_status_cd <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " DLYMST.STATUS = '" + ls_status_cd + "' "
End If
If ls_workdt <> '' Then
	If ls_where <> '' then ls_where += " and "
	ls_where += " to_char(DLYMST.FIRST_DATE,'yyyymmdd') = '" + ls_workdt + "'"
End If
If ls_last_reqdtfr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(dlymst.lastreqdt,'yyyymm') >= '" + ls_last_reqdtfr + "' "
End If
If ls_last_reqdtto <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(dlymst.lastreqdt,'yyyymm') <= '" + ls_last_reqdtto + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

event ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

on e01w_prt_delay01.create
call super::create
end on

on e01w_prt_delay01.destroy
call super::destroy
end on

type dw_cond from w_a_print`dw_cond within e01w_prt_delay01
integer x = 46
integer y = 36
integer width = 2482
integer height = 204
string dataobject = "e01d_cnd_prt_delay01"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within e01w_prt_delay01
integer x = 2619
integer y = 44
end type

type p_close from w_a_print`p_close within e01w_prt_delay01
integer x = 2935
integer y = 44
end type

type dw_list from w_a_print`dw_list within e01w_prt_delay01
integer x = 27
integer y = 276
integer width = 3223
integer height = 1340
string dataobject = "e01d_prt_delay01"
end type

type p_1 from w_a_print`p_1 within e01w_prt_delay01
end type

type p_2 from w_a_print`p_2 within e01w_prt_delay01
end type

type p_3 from w_a_print`p_3 within e01w_prt_delay01
end type

type p_5 from w_a_print`p_5 within e01w_prt_delay01
end type

type p_6 from w_a_print`p_6 within e01w_prt_delay01
end type

type p_7 from w_a_print`p_7 within e01w_prt_delay01
end type

type p_8 from w_a_print`p_8 within e01w_prt_delay01
end type

type p_9 from w_a_print`p_9 within e01w_prt_delay01
end type

type p_4 from w_a_print`p_4 within e01w_prt_delay01
end type

type gb_1 from w_a_print`gb_1 within e01w_prt_delay01
end type

type p_port from w_a_print`p_port within e01w_prt_delay01
end type

type p_land from w_a_print`p_land within e01w_prt_delay01
end type

type gb_cond from w_a_print`gb_cond within e01w_prt_delay01
integer width = 2537
integer height = 256
end type

type p_saveas from w_a_print`p_saveas within e01w_prt_delay01
end type

