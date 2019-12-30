$PBExportHeader$b2w_prc_close_maintaincom.srw
$PBExportComments$[jsmnoh] 월별관리수수료마감
forward
global type b2w_prc_close_maintaincom from w_a_prc
end type
end forward

global type b2w_prc_close_maintaincom from w_a_prc
integer width = 1925
integer height = 1288
end type
global b2w_prc_close_maintaincom b2w_prc_close_maintaincom

type variables
String is_lastSettleDt //최종 대리점지급수수료정산 작업일
end variables

on b2w_prc_close_maintaincom.create
call super::create
end on

on b2w_prc_close_maintaincom.destroy
call super::destroy
end on

event type integer ue_process();call super::ue_process;String ls_errmsg,ls_pgm_id,ls_closedt
Double ldb_return,ldb_count

ldb_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_closedt = String(dw_input.Object.closedt[1],"YYYYMMDD")

//처리부분...
//subroutine B2CRT_SALECOMMISSION(string P_TODT,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"DFBIL~".~"B2CRT_SALECOMMISSION~""
SQLCA.B2CRT_MAINTAINCOMMISSION(ls_closedt,gs_user_id,ls_pgm_id, ldb_return, ls_errmsg, ldb_count)
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

event type integer ue_input();call super::ue_input;String ls_closedt, ls_last[], ls_days, ls_desc, ls_last_month, ls_today
Int  li_daycnt

ls_closedt = String(dw_input.Object.closedt[1],"YYYYMMDD")
ls_today = String(Today(), "YYYYMMDD")

ls_days = fs_get_control('A1', 'C313', ls_desc)				// 최종매출수수료대상기간
li_daycnt = fi_cut_string(ls_days, ';', ls_last)

ls_last_month = ls_last[3] //매출수수료 최종 계산한 달.

// 현재월의 수수료정산은 막는다.
If ls_today < ls_closedt Then
	f_msg_usr_err(201, This.TItle, '마김일은 오늘날짜보다 작아야 합니다.')
	dw_input.SetFocus()
	dw_input.SetColumn("closedt")
	Return -1
End If

//입력받은 매출수수료대상 마감일은 최종 마감일보다 커야한다.
If ls_closedt <= ls_last[2]  Then
	f_msg_usr_err(201, This.title, '이미 매출수수료마감된 일자입니다.')
	dw_input.SetFocus()
	dw_input.SetColumn("closedt")
	Return -1
End If 

ls_days = fs_get_control('A1', 'C320', ls_desc)
li_daycnt = fi_cut_string(ls_days, ';', ls_last)

If ls_last_month > ls_last[1] Then
	f_msg_usr_err(201, this.title, '수수료정산작업을 먼저 하십시오.')
	Return -1
End If

Return 0
end event

event open;call super::open;Date   ld_closedt
String ls_closedt, ls_temp, ls_ref_desc, ls_name[]
Integer li_year, li_month, li_day, li_last_day

/*
//현재월의 마지막일자를 Default값으로.
Select  last_day(sysdate)
Into    :ld_closedt
From    dual;

dw_input.object.closedt[1] = ld_closedt
*/

ls_temp = fs_get_control("A1", "C313", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])

ls_closedt = ls_name[2]
ls_closedt = LeftA(ls_closedt, 4) + "-" + MidA(ls_closedt, 5, 2) + "-" + RightA(ls_closedt, 2)

ld_closedt = Date(ls_closedt)
ld_closedt = fd_next_month(ld_closedt, 1)

li_year = Year(ld_closedt)
li_month = Month(ld_closedt)
li_day = Day(ld_closedt)
li_last_day = fl_date_count_in_month(li_year, li_month)

If li_day < li_last_day Then ld_closedt = Date(li_year, li_month, li_last_day)

dw_input.object.closedt[1] = ld_closedt


end event

type p_ok from w_a_prc`p_ok within b2w_prc_close_maintaincom
integer x = 1275
integer y = 48
end type

type dw_input from w_a_prc`dw_input within b2w_prc_close_maintaincom
integer width = 1125
integer height = 192
string dataobject = "b2dw_cnd_prc_close_maintaincom"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_close_maintaincom
integer y = 860
integer width = 1851
integer height = 300
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_close_maintaincom
integer y = 296
integer width = 1851
integer height = 548
end type

type ln_up from w_a_prc`ln_up within b2w_prc_close_maintaincom
integer beginy = 276
integer endy = 276
end type

type ln_down from w_a_prc`ln_down within b2w_prc_close_maintaincom
integer beginy = 1172
integer endy = 1172
end type

type p_close from w_a_prc`p_close within b2w_prc_close_maintaincom
integer x = 1586
integer y = 48
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_close_maintaincom
integer width = 1170
integer height = 248
end type

