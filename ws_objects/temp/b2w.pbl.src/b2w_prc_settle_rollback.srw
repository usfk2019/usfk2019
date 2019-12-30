$PBExportHeader$b2w_prc_settle_rollback.srw
$PBExportComments$[jsmnoh] 사업자 정산 유치/매출수수료계산취소
forward
global type b2w_prc_settle_rollback from w_a_prc
end type
end forward

global type b2w_prc_settle_rollback from w_a_prc
integer width = 1874
integer height = 1216
end type
global b2w_prc_settle_rollback b2w_prc_settle_rollback

type variables
String  is_fromdt

end variables

on b2w_prc_settle_rollback.create
call super::create
end on

on b2w_prc_settle_rollback.destroy
call super::destroy
end on

event ue_input;call super::ue_input;//dw_input. 입력하는 Check 
String ls_paycomm, ls_desc, ls_yyyymm

If is_fromdt = "00000000" Then
	f_msg_info(9000, Title, "유치/매출수수료작업을 취소할수없습니다. 최종대상일을 확인하시기 바랍니다.")
	Return -1
End If

Return 0
end event

event ue_process;call super::ue_process;b2u_dbmgr 	lu_dbmgr
String ls_yyyymm
Integer li_rc

lu_dbmgr = Create b2u_dbmgr
ls_yyyymm = String(dw_input.Object.yyyymm[1])

lu_dbmgr.is_data[1] = ls_yyyymm
lu_dbmgr.is_title = "유치/매출수수료계산취소"
lu_dbmgr.is_caller = "b2w_prc_cancel_settle_commdet%ue_process"
lu_dbmgr.uf_prc_db()
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

ls_regcomm = fs_get_control('A1', 'C350', ls_desc)			// 유치수수료 최종 대상일From;대상일To;발생년월
ls_settlecomm = fs_get_control('A1', 'C351', ls_desc)		// 매출수수료 최종 대상일From;대상일To;발생년월

li_regcnt = fi_cut_string(ls_regcomm, ';', ls_regcommarr)
li_settlecnt = fi_cut_string(ls_settlecomm, ';', ls_settlecommarr)

If ls_regcommarr[3] = ls_settlecommarr[3] Then
	ls_yyyymm = ls_regcommarr[3]
ElseIf ls_regcommarr[3] > ls_settlecommarr[3] Then
	ls_yyyymm = ls_regcommarr[3]
ElseIf ls_regcommarr[3] < ls_settlecommarr[3] Then
	ls_yyyymm = ls_settlecommarr[3]
End If

dw_input.Object.yyyymm[1] = ls_yyyymm

If ls_regcommarr[1] = "00000000" And ls_regcommarr[3] = ls_yyyymm Then
	is_fromdt = "00000000"
End If

If ls_settlecommarr[1] = "00000000" And ls_settlecommarr[3] = ls_yyyymm Then
	is_fromdt = "00000000"
End If

end event

type p_ok from w_a_prc`p_ok within b2w_prc_settle_rollback
integer x = 1102
integer y = 48
boolean originalsize = false
end type

type dw_input from w_a_prc`dw_input within b2w_prc_settle_rollback
integer width = 914
integer height = 176
string dataobject = "b2dw_cnd_prc_cancel_commdet"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_settle_rollback
integer x = 27
integer y = 804
integer width = 1801
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_settle_rollback
integer x = 27
integer y = 328
integer width = 1801
end type

type ln_up from w_a_prc`ln_up within b2w_prc_settle_rollback
integer beginx = 18
integer beginy = 304
integer endx = 1769
integer endy = 304
end type

type ln_down from w_a_prc`ln_down within b2w_prc_settle_rollback
integer beginx = 27
integer beginy = 1092
integer endx = 1778
integer endy = 1092
end type

type p_close from w_a_prc`p_close within b2w_prc_settle_rollback
integer x = 1403
integer y = 48
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_settle_rollback
integer x = 27
integer width = 955
integer height = 260
end type

