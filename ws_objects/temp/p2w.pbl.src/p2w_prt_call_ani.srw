$PBExportHeader$p2w_prt_call_ani.srw
$PBExportComments$[ceusee] 통화명세서(Ani #)
forward
global type p2w_prt_call_ani from w_a_print
end type
end forward

global type p2w_prt_call_ani from w_a_print
boolean ib_saveas = true
end type
global p2w_prt_call_ani p2w_prt_call_ani

on p2w_prt_call_ani.create
call super::create
end on

on p2w_prt_call_ani.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;Integer li_return
Long ll_row
String ls_where, ls_stime_from, ls_stime_to
String ls_priceplan, ls_pid, ls_validkey
Date ld_stime_from, ld_stime_to
String ls_svctype, ls_ref_desc

ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)

ld_stime_from = dw_cond.Object.stime_from[1]
ls_stime_from = String(ld_stime_from,"yyyymmdd")
If IsNull(ls_stime_from) Then ls_stime_from = ""

ld_stime_to = dw_cond.Object.stime_to[1]
ls_stime_to = String(ld_stime_to,"yyyymmdd")
If IsNull(ls_stime_to) Then ls_stime_to = ""

ls_priceplan = dw_cond.Object.priceplan[1]
If IsNull(ls_priceplan) Then ls_priceplan = ""

ls_pid = dw_cond.Object.pid[1]
If IsNull(ls_pid) Then ls_pid = ""

ls_validkey = dw_cond.Object.validkey[1]
If IsNull(ls_validkey) Then ls_validkey = ""

If ls_stime_from = "" and ls_stime_to = "" Then
	f_msg_info(200, is_title, "통화일자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("stime_from")
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

If ls_priceplan <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.priceplan = '" + ls_priceplan + "'"
End If

If ls_pid <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.pid = '" + ls_pid + "'"
End If
If ls_validkey <> ""  Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "cdr.validkey like '" + ls_validkey + "%'"
End If

//조회조건 입력값을 보여준다.
dw_list.Modify ( "stime_from.text= '" + String(ld_stime_from, 'yyyy-mm-dd') + "' " )
dw_list.Modify ( "stime_to.text='" + String(ld_stime_to, 'yyyy-mm-dd') + "'" )

dw_list.is_where = ls_where 
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return

ElseIf ll_row = 0 Then
	f_msg_info(1000, Title, "")
End If
end event

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = false
end event

type dw_cond from w_a_print`dw_cond within p2w_prt_call_ani
integer y = 56
integer width = 2199
integer height = 272
string dataobject = "p2dw_cnd_call_pin"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_pid
Integer li_cnt
If dwo.name = "contno" Then
	If data <> "" Then
		Select pid, count(*)
		Into :ls_pid, :li_cnt
		From p_cardmst
		where CONTNO = :data
		 group by pid;
		
		If li_cnt = 0 Then
			f_msg_info(9000, is_title, "해당 관리번호가 존재하지 않습니다.")
			This.object.pid[1] = ""
			This.object.contno[1] = ""
			Return 2
		Else
		
		This.object.pid[1] = ls_pid
	End If
End If
End If
	
end event

type p_ok from w_a_print`p_ok within p2w_prt_call_ani
integer x = 2377
end type

type p_close from w_a_print`p_close within p2w_prt_call_ani
integer x = 2679
end type

type dw_list from w_a_print`dw_list within p2w_prt_call_ani
integer x = 27
integer y = 364
integer height = 1260
string dataobject = "p2dw_prt_call_ani"
end type

type p_1 from w_a_print`p_1 within p2w_prt_call_ani
end type

type p_2 from w_a_print`p_2 within p2w_prt_call_ani
end type

type p_3 from w_a_print`p_3 within p2w_prt_call_ani
end type

type p_5 from w_a_print`p_5 within p2w_prt_call_ani
end type

type p_6 from w_a_print`p_6 within p2w_prt_call_ani
end type

type p_7 from w_a_print`p_7 within p2w_prt_call_ani
end type

type p_8 from w_a_print`p_8 within p2w_prt_call_ani
end type

type p_9 from w_a_print`p_9 within p2w_prt_call_ani
end type

type p_4 from w_a_print`p_4 within p2w_prt_call_ani
end type

type gb_1 from w_a_print`gb_1 within p2w_prt_call_ani
end type

type p_port from w_a_print`p_port within p2w_prt_call_ani
end type

type p_land from w_a_print`p_land within p2w_prt_call_ani
end type

type gb_cond from w_a_print`gb_cond within p2w_prt_call_ani
integer width = 2245
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within p2w_prt_call_ani
end type

