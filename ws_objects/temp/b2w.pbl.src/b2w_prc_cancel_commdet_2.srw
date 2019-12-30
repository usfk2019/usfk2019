$PBExportHeader$b2w_prc_cancel_commdet_2.srw
$PBExportComments$[islim] 유치/매출/관리수수료계산취소
forward
global type b2w_prc_cancel_commdet_2 from w_a_prc
end type
end forward

global type b2w_prc_cancel_commdet_2 from w_a_prc
integer width = 1870
integer height = 1180
end type
global b2w_prc_cancel_commdet_2 b2w_prc_cancel_commdet_2

type variables
String  is_fromdt

end variables

on b2w_prc_cancel_commdet_2.create
call super::create
end on

on b2w_prc_cancel_commdet_2.destroy
call super::destroy
end on

event type integer ue_input();call super::ue_input;//dw_input. 입력하는 Check 
String ls_paycomm, ls_desc, ls_yyyymm

ls_paycomm = fs_get_control('A1', 'C320', ls_desc)			// 대리점 지급수수료 정산 최종 작업년월
ls_yyyymm = dw_input.Object.yyyymm[1]

If Integer(ls_yyyymm) <= Integer(ls_paycomm) Then
	f_msg_info(9000, Title, "지급수수료정산 취소작업을 먼저 하신후 작업하시기 바랍니다.")
	Return - 1
End If

If is_fromdt = "00000000" Then
	f_msg_info(9000, Title, "유치/매출수수료작업을 취소할수없습니다. 최종대상일을 확인하시기 바랍니다.")
	Return -1
End If

Return 0
end event

event type integer ue_process();call super::ue_process;b2u_dbmgr 	lu_dbmgr
String ls_yyyymm
Integer li_rc

lu_dbmgr = Create b2u_dbmgr
ls_yyyymm = String(dw_input.Object.yyyymm[1])

lu_dbmgr.is_data[1] = ls_yyyymm
lu_dbmgr.is_title = "유치/매출/관리수수료계산취소"
lu_dbmgr.is_caller = "b2w_prc_cancel_commdet_maintain%ue_process"
lu_dbmgr.uf_prc_db_03()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	//Error
	is_msg_process = "수수료계산 취소 실패" 
	Return - 1
End If

is_msg_process = "수수료계산 취소 성공"
Return 0 
end event

event open;call super::open;String ls_regcomm, ls_settlecomm, ls_regcommarr[], ls_settlecommarr[], ls_desc, ls_yyyymm
int li_regcnt, li_settlecnt

//2005.01.27 add
String ls_maintaincomm, ls_maintaincommarr[]
int li_maintaincnt

ls_regcomm = fs_get_control('A1', 'C310', ls_desc)			// 유치수수료 최종 대상일From;대상일To;발생년월
ls_settlecomm = fs_get_control('A1', 'C311', ls_desc)		// 매출수수료 최종 대상일From;대상일To;발생년월
ls_maintaincomm = fs_get_control('A1', 'C313', ls_desc)  // 관리수수료 최종 대상일From;대상일To;발생년월

li_regcnt = fi_cut_string(ls_regcomm, ';', ls_regcommarr)
li_settlecnt = fi_cut_string(ls_settlecomm, ';', ls_settlecommarr)
li_maintaincnt = fi_cut_string(ls_maintaincomm, ';', ls_maintaincommarr)

If ls_regcommarr[3] = ls_settlecommarr[3] Then
	If ls_regcommarr[3] = ls_maintaincommarr[3]  Then
		ls_yyyymm = ls_regcommarr[3]
	ElseIf ls_regcommarr[3] > ls_maintaincommarr[3] Then
    	ls_yyyymm = ls_regcommarr[3]
	ElseIf ls_regcommarr[3] < ls_maintaincommarr[3] Then
		ls_yyyymm = ls_maintaincommarr[3]
	End If
ElseIf ls_regcommarr[3] > ls_settlecommarr[3] Then
	If ls_regcommarr[3] > ls_maintaincommarr[3] Then
		ls_yyyymm = ls_regcommarr[3]
	ElseIf ls_regcommarr[3] < ls_maintaincommarr[3] Then
		ls_yyyymm = ls_maintaincommarr[3]
	ElseIf ls_regcommarr[3] = ls_maintaincommarr[3] Then
		ls_yyyymm = ls_maintaincommarr[3]
	End If
ElseIf ls_regcommarr[3] < ls_settlecommarr[3] Then
	If ls_maintaincommarr[3] < ls_settlecommarr[3] Then
		ls_yyyymm = ls_settlecommarr[3]
	ElseIf ls_maintaincommarr[3] > ls_settlecommarr[3] Then
		ls_yyyymm = ls_maintaincommarr[3]
	ElseIf ls_settlecommarr[3] = ls_maintaincommarr[3] Then
		ls_yyyymm = ls_settlecommarr[3]
	End If
End If

dw_input.Object.yyyymm[1] = ls_yyyymm

If ls_regcommarr[1] = "00000000" And ls_regcommarr[3] = ls_yyyymm Then
	is_fromdt = "00000000"
End If

If ls_settlecommarr[1] = "00000000" And ls_settlecommarr[3] = ls_yyyymm Then
	is_fromdt = "00000000"
End If

If ls_maintaincommarr[1] = "00000000" And ls_maintaincommarr[3] = ls_yyyymm Then
	is_fromdt = "00000000"
End If

end event

type p_ok from w_a_prc`p_ok within b2w_prc_cancel_commdet_2
integer x = 1125
integer y = 44
boolean originalsize = false
end type

type dw_input from w_a_prc`dw_input within b2w_prc_cancel_commdet_2
integer x = 50
integer width = 942
integer height = 192
string dataobject = "b2dw_cnd_prc_cancel_commdet_maintain"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_cancel_commdet_2
integer x = 27
integer y = 768
integer width = 1797
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_cancel_commdet_2
integer x = 27
integer y = 292
integer width = 1797
end type

type ln_up from w_a_prc`ln_up within b2w_prc_cancel_commdet_2
integer beginy = 268
integer endy = 268
end type

type ln_down from w_a_prc`ln_down within b2w_prc_cancel_commdet_2
integer beginx = 27
integer beginy = 1056
integer endx = 1778
integer endy = 1056
end type

type p_close from w_a_prc`p_close within b2w_prc_cancel_commdet_2
integer x = 1426
integer y = 44
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_cancel_commdet_2
integer width = 987
integer height = 244
end type

