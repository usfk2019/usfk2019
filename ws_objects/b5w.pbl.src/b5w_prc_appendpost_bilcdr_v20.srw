$PBExportHeader$b5w_prc_appendpost_bilcdr_v20.srw
$PBExportComments$[ohj] 일자별CDRyyyymmdd=>post_bilcdr v20
forward
global type b5w_prc_appendpost_bilcdr_v20 from w_a_prc
end type
end forward

global type b5w_prc_appendpost_bilcdr_v20 from w_a_prc
integer height = 1132
end type
global b5w_prc_appendpost_bilcdr_v20 b5w_prc_appendpost_bilcdr_v20

type variables

end variables

on b5w_prc_appendpost_bilcdr_v20.create
call super::create
end on

on b5w_prc_appendpost_bilcdr_v20.destroy
call super::destroy
end on

event type integer ue_process();
String ls_errmsg,ls_yyyymmdd_to,ls_yyyymmdd_fr,ls_null
Long ll_return
double lb_count


ll_return = -1
ls_errmsg = space(800)
//ls_pgm_id = iu_cust_msg.is_pgm_id
//ls_chargedt = trim(dw_input.Object.chargedt[1])
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
setnull(ls_null )

//처리부분...
SQLCA.b5AppendPost_bilcdr_v2(ls_yyyymmdd_to, 1000, 100, ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

If ll_return <> 0 Then	//실패
	is_msg_process = "Fail"
	Return -1
Else				//성공
	is_msg_process = String(lb_count, "#,##0") + " Hit(s)"
	Return 0
End If
end event

event type integer ue_input();call super::ue_input;String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate
ls_sysdate = string(date(fdt_get_dbserver_now()), "yyyymmdd") 
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")

If ls_yyyymmdd_to = "" Then
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If

If ls_yyyymmdd_fr > ls_yyyymmdd_to or ls_yyyymmdd_to >= ls_sysdate Then
	f_msg_info(9000, This.Title, "일자(To)를 확인하세요")
	dw_input.SetFocus()
   dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If


Return 0


end event

event open;call super::open;//Date ld_sysdt, ld_stddt
//
//ld_sysdt = Date(fdt_get_dbserver_now())
//
////ld_stddt = fd_pre_month(ld_sysdt, 1)
//
//dw_input.Object.stddt[1] = ld_sysdt

String ls_module, ls_ref_no, ls_ref_desc, ls_date[], ls_temp
String ls_yyyymmdd

ls_temp = ""
ls_temp = fs_get_control('B5','A101', ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", ls_date[])

ls_yyyymmdd =  ls_date[1]

If IsNull(ls_yyyymmdd) Then Return
If ls_yyyymmdd <> "" Then
    dw_input.Object.yyyymmdd_fr[1] = fd_date_next(date(MidA(ls_yyyymmdd,1,4) + '-' + MidA(ls_yyyymmdd,5,2) + '-' + MidA(ls_yyyymmdd,7,2)),1)
	 dw_input.Object.yyyymmdd_to[1] = fd_date_next(date(MidA(ls_yyyymmdd,1,4) + '-' + MidA(ls_yyyymmdd,5,2) + '-' + MidA(ls_yyyymmdd,7,2)),1)
	
End If;

p_ok.SetFocus()

 
end event

type p_ok from w_a_prc`p_ok within b5w_prc_appendpost_bilcdr_v20
integer x = 1449
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b5w_prc_appendpost_bilcdr_v20
integer x = 64
integer y = 44
integer width = 1230
integer height = 148
string dataobject = "b5d_cnd_prc_appendpost_bilcdr_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b5w_prc_appendpost_bilcdr_v20
integer y = 744
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_prc_appendpost_bilcdr_v20
integer y = 280
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within b5w_prc_appendpost_bilcdr_v20
integer beginy = 264
integer endx = 1838
integer endy = 264
end type

type ln_down from w_a_prc`ln_down within b5w_prc_appendpost_bilcdr_v20
integer beginy = 1024
integer endx = 1838
integer endy = 1024
end type

type p_close from w_a_prc`p_close within b5w_prc_appendpost_bilcdr_v20
integer x = 1449
integer y = 148
end type

type gb_cond from w_a_prc`gb_cond within b5w_prc_appendpost_bilcdr_v20
integer width = 1307
integer height = 232
end type

