$PBExportHeader$p1w_prt_validkey_list.srw
$PBExportComments$[kem] 인증Key List
forward
global type p1w_prt_validkey_list from w_a_print
end type
end forward

global type p1w_prt_validkey_list from w_a_print
integer width = 3150
end type
global p1w_prt_validkey_list p1w_prt_validkey_list

type variables
String is_svctype
end variables

event ue_ok();call super::ue_ok;Integer li_return
Long ll_row
String ls_where, ls_fromdt_from, ls_fromdt_to, ls_pid, ls_anino, ls_order

ls_fromdt_from = String(dw_cond.Object.fromdt_from[1], 'yyyymmdd')
ls_fromdt_to   = String(dw_cond.Object.fromdt_to[1], 'yyyymmdd')
ls_pid         = Trim(dw_cond.Object.pid[1])
ls_anino       = Trim(dw_cond.Object.anino[1])
ls_order       = Trim(dw_cond.Object.order[1])

If IsNull(ls_fromdt_from) Then ls_fromdt_from = ""
If IsNull(ls_fromdt_to) Then ls_fromdt_to = ""
If IsNull(ls_pid) Then ls_pid = ""
If IsNull(ls_anino) Then ls_anino = ""
If IsNull(ls_order) Then ls_order = ""

ls_where = ""

If is_svctype <> "" Then
	ls_where += " svctype = '" + is_svctype + "' "
End If

If ls_fromdt_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(fromdt, 'yyyymmdd') >= '" + ls_fromdt_from + "' "
End If

If ls_fromdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(fromdt, 'yyyymmdd') <= '" + ls_fromdt_to + "' "
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " pid = '" + ls_pid + "' "
End If

If ls_anino <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " validkey Like '" + ls_anino + "%' "
End If

If ls_order = "1" Then
	ls_where += " order by validkey "
ElseIf ls_order = "2" Then
	ls_where += " order by pid "
ElseIf ls_order = "3" Then
	ls_where += " order by fromdt "
End If

dw_list.is_where = ls_where 
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
End If
end event

on p1w_prt_validkey_list.create
call super::create
end on

on p1w_prt_validkey_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = false
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;
dw_cond.Object.order[1] = '1'
end event

event open;call super::open;String ls_ref_desc

//선불카드 서비스타입
is_svctype = fs_get_control('P0', 'P100', ls_ref_desc)
end event

type dw_cond from w_a_print`dw_cond within p1w_prt_validkey_list
event ue_saveas_int ( )
integer x = 69
integer width = 1829
integer height = 336
string dataobject = "p1dw_cnd_prt_validkey_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_pid

If dwo.name = "contno" Then
	If data <> "" Then
		
		SELECT PID
		  INTO :ls_pid
		  FROM P_CARDMST
		 WHERE CONTNO = :data ;
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_usr_err(9000, is_title, "P_CARDMST SELECT Error")
			Return -1
		ElseIf SQLCA.SQLCode = 100 Then
			f_msg_info(9000, is_title, "해당 관리번호가 존재하지 않습니다.")
			dw_cond.Object.pid[row] = ""
			dw_cond.Object.contno[row] = ""
			dw_cond.SetColumn("contno")
			dw_cond.SetFocus()
			Return 2
		End If
		
		dw_cond.Object.pid[row] = ls_pid
	
	Else
		dw_cond.Object.pid[row] = ""
	
	End If
End If

Return 0
			
end event

type p_ok from w_a_print`p_ok within p1w_prt_validkey_list
integer x = 2034
integer y = 96
end type

type p_close from w_a_print`p_close within p1w_prt_validkey_list
integer x = 2341
integer y = 96
end type

type dw_list from w_a_print`dw_list within p1w_prt_validkey_list
integer y = 412
integer width = 3035
integer height = 1228
string dataobject = "p1dw_prt_validkey_list"
end type

type p_1 from w_a_print`p_1 within p1w_prt_validkey_list
end type

type p_2 from w_a_print`p_2 within p1w_prt_validkey_list
end type

type p_3 from w_a_print`p_3 within p1w_prt_validkey_list
end type

type p_5 from w_a_print`p_5 within p1w_prt_validkey_list
end type

type p_6 from w_a_print`p_6 within p1w_prt_validkey_list
end type

type p_7 from w_a_print`p_7 within p1w_prt_validkey_list
end type

type p_8 from w_a_print`p_8 within p1w_prt_validkey_list
end type

type p_9 from w_a_print`p_9 within p1w_prt_validkey_list
end type

type p_4 from w_a_print`p_4 within p1w_prt_validkey_list
end type

type gb_1 from w_a_print`gb_1 within p1w_prt_validkey_list
end type

type p_port from w_a_print`p_port within p1w_prt_validkey_list
end type

type p_land from w_a_print`p_land within p1w_prt_validkey_list
end type

type gb_cond from w_a_print`gb_cond within p1w_prt_validkey_list
integer width = 1888
integer height = 400
end type

type p_saveas from w_a_print`p_saveas within p1w_prt_validkey_list
end type

