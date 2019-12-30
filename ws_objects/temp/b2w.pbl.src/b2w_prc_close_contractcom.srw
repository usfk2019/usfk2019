$PBExportHeader$b2w_prc_close_contractcom.srw
$PBExportComments$[chooys] 월별유치수수료마감
forward
global type b2w_prc_close_contractcom from w_a_prc
end type
end forward

global type b2w_prc_close_contractcom from w_a_prc
integer width = 2066
integer height = 1288
end type
global b2w_prc_close_contractcom b2w_prc_close_contractcom

type variables
String is_lastSettleDt //최종 대리점지급수수료정산 작업일
end variables

on b2w_prc_close_contractcom.create
call super::create
end on

on b2w_prc_close_contractcom.destroy
call super::destroy
end on

event type integer ue_process();call super::ue_process;String ls_errmsg,ls_pgm_id,ls_closedt
Double ldb_return,ldb_count

ldb_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_closedt = String(dw_input.Object.closedt_to[1],"YYYYMMDD")

//처리부분...

SQLCA.B2CRT_REGCOMMISSION(ls_closedt,gs_user_id,ls_pgm_id, ldb_return, ls_errmsg, ldb_count)
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

event type integer ue_input();call super::ue_input;String ls_closedt, ls_last[], ls_days, ls_desc, ls_temp, ls_last2[], ls_today
String ls_closedt_to
Int  li_daycnt, li_temp

ls_closedt = String(dw_input.Object.closedt_fr[1],"YYYYMMDD")
ls_closedt_to = String(dw_input.Object.closedt_to[1],"YYYYMMDD")
ls_today = String(Today(), "YYYYMMDD")

ls_days = fs_get_control('A1', 'C310', ls_desc)
li_daycnt = fi_cut_string(ls_days, ';', ls_last)
ls_temp = fs_get_control('A1', 'C320', ls_desc)
li_temp = fi_cut_string(ls_temp, ';', ls_last2[])

// 현재월의 수수료는 정산하지 못한다.
If ls_today < ls_closedt_to Then
	f_msg_usr_err(201, This.title, '마감일은 오늘날짜보다 작아야 합니다.')
	Return -1
End If

//입력받은 유치수수료대상 마감일은 최종 마감일보다 커야한다.
If ls_closedt <= ls_last[2]  Then
	f_msg_usr_err(201, This.title, '이미 유치수수료마감된 일자입니다.')
	Return -1
End If 
If ls_last[3] > ls_last2[1] Then
	f_msg_usr_err(201, This.title, '수수료정산작업을 먼저 하십시오.')
	Return -1
End If

Return 0

end event

event open;call super::open;Date   ld_closedt_fr, ld_closedt_to
String ls_temp, ls_ref_desc, ls_name[], ls_closedt_fr, ls_closedt_to
Integer li_year, li_month, li_day, li_last_day

/*
//현재월의 마지막일자를 Default값으로.
Select  last_day(sysdate)
Into    :ld_closedt
From    dual;

dw_input.object.closedt[1] = ld_closedt
*/

ls_temp = fs_get_control("A1", "C310", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_name[])

ls_closedt_to = ls_name[2]
ls_closedt_to = LeftA(ls_closedt_to,4) + "-" + MidA(ls_closedt_to, 5, 2) + "-" + RightA(ls_closedt_to, 2)

ld_closedt_to = Date(ls_closedt_to)
ld_closedt_fr = relativedate(ld_closedt_to, 1)
ld_closedt_to = fd_next_month(ld_closedt_to, 1)

li_year = Year(ld_closedt_to)
li_month = Month(ld_closedt_to)
li_day = Day(ld_closedt_to)

li_last_day = fl_date_count_in_month(li_year, li_month)

If li_day < li_last_day Then ld_closedt_to = Date(li_year, li_month, li_last_day)

dw_input.object.closedt_fr[1] = ld_closedt_fr
dw_input.object.closedt_to[1] = ld_closedt_to

end event

type p_ok from w_a_prc`p_ok within b2w_prc_close_contractcom
integer x = 1755
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b2w_prc_close_contractcom
integer width = 1522
integer height = 180
string dataobject = "b2dw_cnd_prc_close_contractcom"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b2w_prc_close_contractcom
integer y = 860
integer width = 1975
integer height = 300
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b2w_prc_close_contractcom
integer y = 296
integer width = 1970
integer height = 548
end type

type ln_up from w_a_prc`ln_up within b2w_prc_close_contractcom
integer beginy = 276
integer endy = 276
end type

type ln_down from w_a_prc`ln_down within b2w_prc_close_contractcom
integer beginy = 1172
integer endx = 1902
integer endy = 1172
end type

type p_close from w_a_prc`p_close within b2w_prc_close_contractcom
integer x = 1755
integer y = 144
end type

type gb_cond from w_a_prc`gb_cond within b2w_prc_close_contractcom
integer width = 1582
integer height = 236
end type

