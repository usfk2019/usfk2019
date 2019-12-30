$PBExportHeader$p2w_prt_call_areacod.srw
$PBExportComments$[jykim] 통화명세서 (국가별)
forward
global type p2w_prt_call_areacod from w_a_print
end type
end forward

global type p2w_prt_call_areacod from w_a_print
integer width = 3282
end type
global p2w_prt_call_areacod p2w_prt_call_areacod

on p2w_prt_call_areacod.create
call super::create
end on

on p2w_prt_call_areacod.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = false
end event

event ue_ok();call super::ue_ok;Integer li_return
Long ll_row
String ls_where, ls_stime_from, ls_stime_to
String ls_areacode, ls_pid, ls_validkey, ls_countrycod
Date ld_stime_from, ld_stime_to
String ls_svctype, ls_ref_desc

ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)

ld_stime_from = dw_cond.Object.fromdt[1]
ls_stime_from = String(ld_stime_from,"yyyymmdd")
If IsNull(ls_stime_from) Then ls_stime_from = ""

ld_stime_to = dw_cond.Object.todt[1]
ls_stime_to = String(ld_stime_to,"yyyymmdd")
If IsNull(ls_stime_to) Then ls_stime_to = ""

ls_areacode = dw_cond.Object.areacod[1]
If IsNull(ls_areacode) Then ls_areacode = ""

ls_countrycod = dw_cond.Object.country[1]
If IsNull(ls_countrycod) Then ls_countrycod = ""

ls_pid = dw_cond.Object.pid[1]
If IsNull(ls_pid) Then ls_pid = ""

ls_validkey = dw_cond.Object.anino[1]
If IsNull(ls_validkey) Then ls_validkey = ""

If ls_stime_from = "" and ls_stime_to = "" Then
	f_msg_info(200, is_title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fromdt")
	Return
End If

If ls_stime_from > ls_stime_to Then
	f_msg_usr_err(210, is_title, "통화일자")
	Return
End If

ls_where = ""
ls_where += "cdr.svctype = '" + ls_svctype + "' "

If ls_stime_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(cdr.stime, 'yyyymmdd') >= '" + ls_stime_from + "' "
End If

If ls_stime_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(cdr.stime, 'yyyymmdd') <= '" + ls_stime_to + "' "
End If

If ls_areacode <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.areacod = '" + ls_areacode + "'"
End If

If ls_countrycod <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.countrycod = '" + ls_countrycod + "'"
End If

If ls_pid <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.pid = '" + ls_pid + "'"
End If
If ls_validkey <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.validkey LIKE '" + ls_validkey + "%'"
End If

//조회조건 입력값을 보여준다.
dw_list.Modify ( "fromdt.text= '" + String(ld_stime_from, 'yyyy-mm-dd') + "' " )
dw_list.Modify ( "todt.text='" + String(ld_stime_to, 'yyyy-mm-dd') + "'" )

dw_list.is_where = ls_where 
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return

ElseIf ll_row = 0 Then
	f_msg_info(1000, Title, "")
End If
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within p2w_prt_call_areacod
integer x = 91
integer y = 64
integer width = 2286
integer height = 232
string dataobject = "p2dw_cnd_call_areacod"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within p2w_prt_call_areacod
integer x = 2569
end type

type p_close from w_a_print`p_close within p2w_prt_call_areacod
integer x = 2871
end type

type dw_list from w_a_print`dw_list within p2w_prt_call_areacod
integer x = 27
integer y = 332
integer width = 3200
integer height = 1296
string dataobject = "p2dw_prt_call_areacod"
end type

type p_1 from w_a_print`p_1 within p2w_prt_call_areacod
end type

type p_2 from w_a_print`p_2 within p2w_prt_call_areacod
end type

type p_3 from w_a_print`p_3 within p2w_prt_call_areacod
end type

type p_5 from w_a_print`p_5 within p2w_prt_call_areacod
end type

type p_6 from w_a_print`p_6 within p2w_prt_call_areacod
end type

type p_7 from w_a_print`p_7 within p2w_prt_call_areacod
end type

type p_8 from w_a_print`p_8 within p2w_prt_call_areacod
end type

type p_9 from w_a_print`p_9 within p2w_prt_call_areacod
end type

type p_4 from w_a_print`p_4 within p2w_prt_call_areacod
end type

type gb_1 from w_a_print`gb_1 within p2w_prt_call_areacod
end type

type p_port from w_a_print`p_port within p2w_prt_call_areacod
end type

type p_land from w_a_print`p_land within p2w_prt_call_areacod
end type

type gb_cond from w_a_print`gb_cond within p2w_prt_call_areacod
integer y = 20
integer width = 2414
integer height = 296
end type

type p_saveas from w_a_print`p_saveas within p2w_prt_call_areacod
end type

