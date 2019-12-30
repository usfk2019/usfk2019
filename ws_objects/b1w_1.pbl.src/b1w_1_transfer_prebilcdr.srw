$PBExportHeader$b1w_1_transfer_prebilcdr.srw
$PBExportComments$[ceusee] 선불 정산 CDR 이관
forward
global type b1w_1_transfer_prebilcdr from w_a_prc
end type
end forward

global type b1w_1_transfer_prebilcdr from w_a_prc
integer width = 1920
integer height = 1232
end type
global b1w_1_transfer_prebilcdr b1w_1_transfer_prebilcdr

on b1w_1_transfer_prebilcdr.create
call super::create
end on

on b1w_1_transfer_prebilcdr.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name : b1w_1_transfer_prebilcdr
	Desc : 보관일수 만큼 CDR 자료를 남기고 이관한다.
	Date : 2004.02.01
	Auth.: C.BORA
-------------------------------------------------------------------------*/
String ls_days, ls_ref_desc, ls_tmp, ls_name[]
Date ld_sysdt, ld_enddt
Integer li_days
//정보가져오기
ls_tmp = fs_get_control("B1", "A102", ls_ref_desc)
fi_cut_string(ls_tmp, ";", ls_name[])
li_days = Integer(ls_name[1])
dw_input.object.days[1] = li_days


ld_sysdt = Date(fdt_get_dbserver_now())
ld_enddt = Date(String(ls_name[2], "@@@@-@@-@@"))

//해당 날짜 구하기
dw_input.Object.fromdt[1] = fd_date_next(ld_enddt, 1)
dw_input.Object.todt[1] = fd_date_pre(ld_sysdt, li_days)

end event

event type integer ue_process();call super::ue_process;String ls_errmsg
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)


//처리부분...
//subroutine TRANSFER_PREBILCDRH(ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"HKTEL~".~"TRANSFER_PREBILCDRH~""
SQLCA.TRANSFER_PREBILCDRH(ll_return,ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1

ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	
End If

If ll_return <> 0 Then	Return -1

If IsNull(lb_count) Then lb_count = 0
	
is_msg_process = String(lb_count, "#,##0") + " 건"

Return 0

end event

type p_ok from w_a_prc`p_ok within b1w_1_transfer_prebilcdr
integer x = 1463
integer y = 48
end type

type dw_input from w_a_prc`dw_input within b1w_1_transfer_prebilcdr
integer x = 73
integer y = 56
integer width = 1275
integer height = 224
string dataobject = "b1dw_1_transfer_prebilcdr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b1w_1_transfer_prebilcdr
integer y = 816
integer width = 1833
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b1w_1_transfer_prebilcdr
integer y = 352
integer width = 1838
end type

type ln_up from w_a_prc`ln_up within b1w_1_transfer_prebilcdr
integer beginy = 332
integer endy = 332
end type

type ln_down from w_a_prc`ln_down within b1w_1_transfer_prebilcdr
integer beginy = 1104
integer endy = 1104
end type

type p_close from w_a_prc`p_close within b1w_1_transfer_prebilcdr
integer x = 1463
integer y = 156
end type

type gb_cond from w_a_prc`gb_cond within b1w_1_transfer_prebilcdr
integer width = 1335
integer height = 308
end type

