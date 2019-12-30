$PBExportHeader$b1w_prc_customerm.srw
$PBExportComments$[parkkh] 고객자료생성
forward
global type b1w_prc_customerm from w_a_prc
end type
end forward

global type b1w_prc_customerm from w_a_prc
integer height = 1132
end type
global b1w_prc_customerm b1w_prc_customerm

type variables
String is_stddt
end variables

on b1w_prc_customerm.create
call super::create
end on

on b1w_prc_customerm.destroy
call super::destroy
end on

event type integer ue_process();String ls_errmsg,ls_pgm_id,ls_chargedt, ls_usedmonth
Long ll_return
Double lb_count, lb_count_a, lb_count_r

ll_return = 0
ls_errmsg = space(256)


//처리부분...
//연체개월수계산
//subroutine E01_CALC_OVERDUEM(string P_STDDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"ANYUSERJ~".~"E01_CALC_OVERDUEM~""
//SQLCA.e01_calc_overduem(is_stddt, gs_pgm_id[gi_open_win_no], gs_user_id, ll_return, ls_errmsg, lb_count)
//If SQLCA.SQLCode < 0 Then		//For Programer
//	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
//	ll_return = -1
//ElseIf ll_return < 0 Then	//For User
//	MessageBox(This.Title, ls_errmsg)
//End If


If ll_return <> 0 Then	//실패
	is_msg_process = "처리실패"
	Return -1
Else				//성공
	is_msg_process = "처리건수: " + String(lb_count, "#,##0") + " 건"
	Return 0
End If

end event

event type integer ue_input();call super::ue_input;String ls_stddt, ls_sysdt

ls_stddt = String(dw_input.Object.stddt[1], "yyyymmdd")
ls_sysdt = String(fdt_get_dbserver_now(), "yyyymmdd")

If ls_stddt = "" Then
	f_msg_usr_err(200, This.Title, "연체기준년월")
	dw_input.SetFocus()
	dw_input.SetColumn("stddt")
	Return -1
End If

If ls_stddt > ls_sysdt Then
	f_msg_info(9000, This.Title, "연체기준일자은 당일보다 클 수 없습니다.")
	dw_input.SetFocus()
	dw_input.SetColumn("stddt")
	Return -1
End If

is_stddt = ls_stddt

Return 0


end event

event open;call super::open;Date ld_sysdt, ld_stddt

ld_sysdt = Date(fdt_get_dbserver_now())

//ld_stddt = fd_pre_month(ld_sysdt, 1)

dw_input.Object.stddt[1] = ld_sysdt

p_ok.SetFocus()

end event

type p_ok from w_a_prc`p_ok within b1w_prc_customerm
integer x = 1326
integer y = 48
end type

type dw_input from w_a_prc`dw_input within b1w_prc_customerm
integer x = 69
integer y = 48
integer width = 1079
integer height = 164
string dataobject = "b1dw_cnd_prc_customerm"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b1w_prc_customerm
integer y = 744
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b1w_prc_customerm
integer y = 280
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within b1w_prc_customerm
integer beginy = 264
integer endx = 1838
integer endy = 264
end type

type ln_down from w_a_prc`ln_down within b1w_prc_customerm
integer beginy = 1024
integer endx = 1838
integer endy = 1024
end type

type p_close from w_a_prc`p_close within b1w_prc_customerm
integer x = 1641
integer y = 48
end type

type gb_cond from w_a_prc`gb_cond within b1w_prc_customerm
integer width = 1266
integer height = 240
end type

