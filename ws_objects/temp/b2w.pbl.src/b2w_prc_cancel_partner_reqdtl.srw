$PBExportHeader$b2w_prc_cancel_partner_reqdtl.srw
$PBExportComments$[y.k.min] 지급수수료정산작업취소
forward
global type b2w_prc_cancel_partner_reqdtl from w_a_prc
end type
end forward

global type b2w_prc_cancel_partner_reqdtl from w_a_prc
integer width = 1883
integer height = 1160
end type
global b2w_prc_cancel_partner_reqdtl b2w_prc_cancel_partner_reqdtl

on b2w_prc_cancel_partner_reqdtl.create
call super::create
end on

on b2w_prc_cancel_partner_reqdtl.destroy
call super::destroy
end on

event type integer ue_input();call super::ue_input;//dw_input. 입력하는 Check 
/*
String ls_yyyymm, ls_temp, ls_last_month, ls_desc, ls_last[]
Long li_temp

ls_temp = fs_get_control('A1', 'C311', ls_desc)
li_temp = fi_cut_string(ls_temp, ';', ls_last)

ls_yyyymm = fs_get_control('A1', 'C320', ls_desc) //마지막 정산월

If ls_yyyymm <> ls_last[3] Then
	f_msg_info(9000, Title, '수수료계산취소작업을 먼저 하십시오.')
	Return -1
End If
*/

Return 0
end event

event type integer ue_process();call super::ue_process;b2u_dbmgr 	lu_dbmgr
String ls_yyyymm
Integer li_rc

lu_dbmgr = Create b2u_dbmgr
ls_yyyymm = String(dw_input.Object.yyyymm[1])

lu_dbmgr.is_data[1] = ls_yyyymm
lu_dbmgr.is_title = "지급수수료정산작업취소"
lu_dbmgr.is_caller = "b2w_prc_cancel_partner_reqdtl%ue_process"
lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	//Error
	is_msg_process = "지급수수료정산작업 취소 실패" 
	Return - 1
End If

is_msg_process = "지급수수료정산작업 취소 성공"
Return 0 
end event

event open;call super::open;String ls_paycomm, ls_paycommarr[], ls_desc
int li_paycnt


ls_paycomm = fs_get_control('A1', 'C320', ls_desc)			// 대리점지급수수료정산 최종작업년월
li_paycnt = fi_cut_string(ls_paycomm, ';', ls_paycommarr)

dw_input.Object.yyyymm[1] = ls_paycommarr[1]

end event

type p_ok from w_a_prc`p_ok within b2w_prc_cancel_partner_reqdtl
integer x = 1102
integer y = 44
boolean originalsize = false
end type

type dw_input from w_a_prc`dw_input within b2w_prc_cancel_partner_reqdtl
integer width = 841
integer height = 176
string dataobject = "b2dw_cnd_prc_cancel_partner_reqdtl"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_cancel_partner_reqdtl
integer x = 27
integer y = 752
integer width = 1810
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_cancel_partner_reqdtl
integer x = 27
integer y = 276
integer width = 1810
end type

type ln_up from w_a_prc`ln_up within b2w_prc_cancel_partner_reqdtl
integer beginx = 18
integer beginy = 252
integer endx = 1769
integer endy = 252
end type

type ln_down from w_a_prc`ln_down within b2w_prc_cancel_partner_reqdtl
integer beginx = 27
integer beginy = 1040
integer endx = 1778
integer endy = 1040
end type

type p_close from w_a_prc`p_close within b2w_prc_cancel_partner_reqdtl
integer x = 1408
integer y = 44
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_cancel_partner_reqdtl
integer width = 974
integer height = 224
end type

