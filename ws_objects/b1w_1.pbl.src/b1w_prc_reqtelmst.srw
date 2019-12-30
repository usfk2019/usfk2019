$PBExportHeader$b1w_prc_reqtelmst.srw
$PBExportComments$[parkkh] 발신정보생성
forward
global type b1w_prc_reqtelmst from w_a_prc
end type
end forward

global type b1w_prc_reqtelmst from w_a_prc
integer width = 1947
integer height = 1196
end type
global b1w_prc_reqtelmst b1w_prc_reqtelmst

type variables

end variables

on b1w_prc_reqtelmst.create
call super::create
end on

on b1w_prc_reqtelmst.destroy
call super::destroy
end on

event type integer ue_process();String ls_errmsg,ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_null,ls_CalcType,ls_carrierid
Long ll_return
double lb_count

ll_return = 0

//처리부분...
//SQLCA.c1Carrier_Amount(ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_calctype,ls_Carrierid, ll_return, ls_errmsg, lb_count)
//If SQLCA.SQLCode < 0 Then		//For Programer
//	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
//	ll_return = -1
//ElseIf ll_return < 0 Then	//For User
//	MessageBox(This.Title, ls_errmsg)
//End If
//

If ll_return <> 0 Then	//실패
	is_msg_process = "Fail"
	Return -1
Else				//성공
	is_msg_process = "Count: " + String(lb_count, "#,##0") + " 건"
	Return 0
End If


end event

event type integer ue_input();call super::ue_input;String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate

ls_sysdate = string(date(fdt_get_dbserver_now())) 
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")

If ls_yyyymmdd_fr = "" Then
	f_msg_usr_err(200, This.Title, "발생일자 Fr")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_fr")
	Return -1
End If

If ls_yyyymmdd_to = "" Then
	f_msg_usr_err(200, This.Title, "발생일자 To")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If

If ls_yyyymmdd_fr > ls_yyyymmdd_to or ls_yyyymmdd_to >= ls_sysdate Then
	f_msg_info(9000, This.Title, "발생일자")
	dw_input.SetFocus()
    dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If


Return 0


end event

event open;call super::open;
Date ld_sysdt, ld_stddt

ld_sysdt = Date(fdt_get_dbserver_now())

dw_input.Object.yyyymmdd_fr[1] = ld_sysdt
dw_input.Object.yyyymmdd_to[1] = ld_sysdt

p_ok.SetFocus()
end event

type p_ok from w_a_prc`p_ok within b1w_prc_reqtelmst
integer x = 1568
integer y = 56
end type

type dw_input from w_a_prc`dw_input within b1w_prc_reqtelmst
integer y = 72
integer width = 1335
integer height = 192
string dataobject = "b1dw_cnd_prc_reqtelmst"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b1w_prc_reqtelmst
integer y = 804
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b1w_prc_reqtelmst
integer y = 340
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within b1w_prc_reqtelmst
integer beginx = 18
integer beginy = 328
integer endx = 1824
integer endy = 328
end type

type ln_down from w_a_prc`ln_down within b1w_prc_reqtelmst
integer beginy = 1084
integer endx = 1838
integer endy = 1084
end type

type p_close from w_a_prc`p_close within b1w_prc_reqtelmst
integer x = 1568
integer y = 176
end type

type gb_cond from w_a_prc`gb_cond within b1w_prc_reqtelmst
integer width = 1426
integer height = 304
end type

