﻿$PBExportHeader$p2w_prc_appendpre_bilcdr.srw
$PBExportComments$[ceusee] 선불 일자별 CDR Append
forward
global type p2w_prc_appendpre_bilcdr from w_a_prc
end type
end forward

global type p2w_prc_appendpre_bilcdr from w_a_prc
integer height = 1132
end type
global p2w_prc_appendpre_bilcdr p2w_prc_appendpre_bilcdr

type variables

end variables

on p2w_prc_appendpre_bilcdr.create
call super::create
end on

on p2w_prc_appendpre_bilcdr.destroy
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
SQLCA.p2AppendPre_bilcdr(ls_yyyymmdd_to,'0',ls_null, ll_return, ls_errmsg, lb_count)
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
	is_msg_process = String(lb_count, "#,##0") + " 건"
	Return 0
End If


end event

event type integer ue_input();call super::ue_input;String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate
ls_sysdate = string(date(fdt_get_dbserver_now())) 
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")

If ls_yyyymmdd_to = "" Then
	f_msg_usr_err(200, This.Title, "생성일자")
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


String ls_module, ls_ref_no, ls_ref_desc
String ls_yyyymmdd

ls_module = "P0"
ls_ref_no = "P114" 
ls_ref_desc = ""
ls_yyyymmdd = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)

If IsNull(ls_yyyymmdd) Then Return
If ls_yyyymmdd <> "" Then
    dw_input.Object.yyyymmdd_fr[1] = fd_date_next(date(MidA(ls_yyyymmdd,1,4) + '-' + MidA(ls_yyyymmdd,5,2) + '-' + MidA(ls_yyyymmdd,7,2)),1)
	 dw_input.Object.yyyymmdd_to[1] = fd_date_next(date(MidA(ls_yyyymmdd,1,4) + '-' + MidA(ls_yyyymmdd,5,2) + '-' + MidA(ls_yyyymmdd,7,2)),1)
	
End If;

p_ok.SetFocus()

 
end event

type p_ok from w_a_prc`p_ok within p2w_prc_appendpre_bilcdr
integer x = 1449
integer y = 36
end type

type dw_input from w_a_prc`dw_input within p2w_prc_appendpre_bilcdr
integer x = 64
integer y = 44
integer width = 1230
integer height = 148
string dataobject = "p2dw_cnd_prc_appendpost_bilcdr"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within p2w_prc_appendpre_bilcdr
integer y = 744
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within p2w_prc_appendpre_bilcdr
integer y = 280
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within p2w_prc_appendpre_bilcdr
integer beginy = 264
integer endx = 1838
integer endy = 264
end type

type ln_down from w_a_prc`ln_down within p2w_prc_appendpre_bilcdr
integer beginy = 1024
integer endx = 1838
integer endy = 1024
end type

type p_close from w_a_prc`p_close within p2w_prc_appendpre_bilcdr
integer x = 1449
integer y = 148
end type

type gb_cond from w_a_prc`gb_cond within p2w_prc_appendpre_bilcdr
integer width = 1307
integer height = 232
end type

