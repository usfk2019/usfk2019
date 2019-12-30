﻿$PBExportHeader$b2w_prc_settle_regcom.srw
$PBExportComments$[jsmnoh]월 사업자 정산 유치수수료계산
forward
global type b2w_prc_settle_regcom from w_a_prc
end type
end forward

global type b2w_prc_settle_regcom from w_a_prc
integer width = 1984
integer height = 1288
end type
global b2w_prc_settle_regcom b2w_prc_settle_regcom

type variables
String is_lastSettleDt //최종 대리점지급수수료정산 작업일
end variables

on b2w_prc_settle_regcom.create
call super::create
end on

on b2w_prc_settle_regcom.destroy
call super::destroy
end on

event type integer ue_process();call super::ue_process;String ls_errmsg,ls_pgm_id,ls_closedt
Double ldb_return,ldb_count

ldb_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_closedt = String(dw_input.Object.closedt[1],"YYYYMMDD")

//처리부분...
//subroutine B2CRT_SETTLEREGCOMMISSION(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"DFBIL~".~"B2CRT_SETTLEREGCOMMISSION~""
//SQLCA.B2CRT_SETTLEREGCOMMISSION(ls_closedt,gs_user_id,ls_pgm_id, ldb_return, ls_errmsg, ldb_count)
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

event ue_input;call super::ue_input;String ls_closedt, ls_last[], ls_days, ls_desc
Int  li_daycnt

ls_closedt = String(dw_input.Object.closedt[1],"YYYYMMDD")

ls_days = fs_get_control('A1', 'C350', ls_desc)
li_daycnt = fi_cut_string(ls_days, ';', ls_last)


//입력받은 유치수수료대상 마감일은 최종 마감일보다 커야한다.
If ls_closedt <= ls_last[2]  Then
	f_msg_usr_err(201, This.title, '이미 사업자 유치수수료마감된 일자입니다.')
	dw_input.SetFocus()
	dw_input.SetColumn("closedt")
	Return -1
End If 

Return 0
end event

event open;call super::open;Date   ld_closedt

//현재월의 마지막일자를 Default값으로.
Select  last_day(sysdate)
Into    :ld_closedt
From    dual;

dw_input.object.closedt[1] = ld_closedt


end event

type p_ok from w_a_prc`p_ok within b2w_prc_settle_regcom
integer x = 1367
integer y = 48
end type

type dw_input from w_a_prc`dw_input within b2w_prc_settle_regcom
integer width = 1115
integer height = 200
string dataobject = "b2dw_cnd_prc_close_contractcom"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_settle_regcom
integer y = 860
integer height = 300
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_settle_regcom
integer y = 296
integer height = 548
end type

type ln_up from w_a_prc`ln_up within b2w_prc_settle_regcom
integer beginy = 276
integer endy = 276
end type

type ln_down from w_a_prc`ln_down within b2w_prc_settle_regcom
integer beginy = 1172
integer endy = 1172
end type

type p_close from w_a_prc`p_close within b2w_prc_settle_regcom
integer x = 1664
integer y = 48
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_settle_regcom
integer width = 1234
integer height = 248
end type
