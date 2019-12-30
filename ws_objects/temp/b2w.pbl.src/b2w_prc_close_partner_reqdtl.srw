$PBExportHeader$b2w_prc_close_partner_reqdtl.srw
$PBExportComments$[chooys] 월별지급수수료정산 Window
forward
global type b2w_prc_close_partner_reqdtl from w_a_prc
end type
end forward

global type b2w_prc_close_partner_reqdtl from w_a_prc
integer height = 1140
end type
global b2w_prc_close_partner_reqdtl b2w_prc_close_partner_reqdtl

type variables
String is_lastSettleDt //최종 대리점지급수수료정산 작업일
end variables

on b2w_prc_close_partner_reqdtl.create
call super::create
end on

on b2w_prc_close_partner_reqdtl.destroy
call super::destroy
end on

event type integer ue_process();call super::ue_process;String ls_errmsg,ls_pgm_id,ls_settledt
Double ldb_return,ldb_count

ldb_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_settledt = String(dw_input.Object.settledt[1],"YYYYMM")

//처리부분...
SQLCA.B2CRTPARTNERREQDTL(ls_settledt,gs_user_id,ls_pgm_id, ldb_return, ls_errmsg, ldb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ldb_return = -1

ElseIf ldb_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

is_msg_process = '처리건수:' + string(ldb_count) 


If ldb_return <> 0 Then	//실패
	Return -1
Else				//성공
	Return 0
End If

end event

event type integer ue_input();call super::ue_input;String ls_settledt

ls_settledt = String(dw_input.Object.settledt[1],"YYYYMM")

//입력받은 작업년월은 최종 대리점지급수수료정산일(ls_lastSettleDt)보다 커야한다.
If ls_settledt <= is_lastSettleDt  Then
	f_msg_usr_err(1200, This.title, +&
	'작업조건: 작업년월이 ' + is_lastSettleDt +' 이후여야 합니다')
	dw_input.SetFocus()
	dw_input.SetColumn("settledt")
	Return -1
End If 

Return 0

end event

event open;call super::open;String ls_desc

//최종 대리점지급수수료정산일
is_lastSettleDt = fs_get_control('A1','C320',ls_desc)

IF LenA(is_lastSettleDt) = 6 THEN
	dw_input.object.settledt[1] = fd_next_month(Date(MidA(is_lastSettleDt,1,4)+"-"+MidA(is_lastSettleDt,5,2)+"-01"),0)
END IF


end event

type p_ok from w_a_prc`p_ok within b2w_prc_close_partner_reqdtl
integer x = 1243
integer y = 48
end type

type dw_input from w_a_prc`dw_input within b2w_prc_close_partner_reqdtl
integer width = 997
integer height = 160
string dataobject = "b2dw_cnd_prc_close_partner_reqdtl"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_close_partner_reqdtl
integer y = 716
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_close_partner_reqdtl
integer y = 256
end type

type ln_up from w_a_prc`ln_up within b2w_prc_close_partner_reqdtl
integer beginy = 236
integer endy = 236
end type

type ln_down from w_a_prc`ln_down within b2w_prc_close_partner_reqdtl
integer beginy = 996
integer endy = 996
end type

type p_close from w_a_prc`p_close within b2w_prc_close_partner_reqdtl
integer x = 1550
integer y = 48
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_close_partner_reqdtl
integer width = 1111
integer height = 212
end type

