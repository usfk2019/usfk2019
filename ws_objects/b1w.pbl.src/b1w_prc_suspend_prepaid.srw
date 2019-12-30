$PBExportHeader$b1w_prc_suspend_prepaid.srw
$PBExportComments$[ohj]일시정지- 선불
forward
global type b1w_prc_suspend_prepaid from w_a_prc
end type
type st_1 from statictext within b1w_prc_suspend_prepaid
end type
end forward

global type b1w_prc_suspend_prepaid from w_a_prc
integer height = 1132
st_1 st_1
end type
global b1w_prc_suspend_prepaid b1w_prc_suspend_prepaid

type variables

end variables

on b1w_prc_suspend_prepaid.create
int iCurrent
call super::create
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
end on

on b1w_prc_suspend_prepaid.destroy
call super::destroy
destroy(this.st_1)
end on

event type integer ue_process();
String ls_errmsg
Long ll_return
double lb_count


ll_return = -1
ls_errmsg = space(800)
//ls_pgm_id = iu_cust_msg.is_pgm_id
//ls_chargedt = trim(dw_input.Object.chargedt[1])
//ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")
//ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
//setnull(ls_null )
//처리부분...
SQLCA.B1SUSPEND_PREPAYMENT(ll_return, ls_errmsg, lb_count)

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
	is_msg_process = String(lb_count, "#,##0") + " # of  Transactions"
	Return 0
End If


end event

event type integer ue_input();call super::ue_input;//String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate
//ls_sysdate = string(date(fdt_get_dbserver_now())) 
//ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
//ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")
//
//If ls_yyyymmdd_to = "" Then
//	f_msg_usr_err(200, This.Title, "")
//	dw_input.SetFocus()
//	dw_input.SetColumn("yyyymmdd_to")
//	Return -1
//End If
//
//If ls_yyyymmdd_fr > ls_yyyymmdd_to or ls_yyyymmdd_to >= ls_sysdate Then
//	f_msg_info(9000, This.Title, "")
//	dw_input.SetFocus()
//   dw_input.SetColumn("yyyymmdd_to")
//	Return -1
//End If
//
//
Return 0
//

end event

event open;call super::open;//Date ld_sysdt, ld_stddt
//
//ld_sysdt = Date(fdt_get_dbserver_now())
//
////ld_stddt = fd_pre_month(ld_sysdt, 1)
//
//dw_input.Object.stddt[1] = ld_sysdt


//String ls_module, ls_ref_no, ls_ref_desc
//String ls_yyyymmdd
//
//ls_module = "B1"
//ls_ref_no = "A101" 
//ls_ref_desc = ""
//ls_yyyymmdd = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
//
//If IsNull(ls_yyyymmdd) Then Return
//If ls_yyyymmdd <> "" Then
//    dw_input.Object.yyyymmdd_fr[1] = fd_date_next(date(mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)),1)
//	 dw_input.Object.yyyymmdd_to[1] = fd_date_next(date(mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)),1)
//	
//End If;

p_ok.SetFocus()

 
end event

type p_ok from w_a_prc`p_ok within b1w_prc_suspend_prepaid
integer x = 1449
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b1w_prc_suspend_prepaid
boolean visible = false
integer x = 64
integer y = 44
integer width = 1230
integer height = 148
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b1w_prc_suspend_prepaid
integer y = 744
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b1w_prc_suspend_prepaid
integer y = 280
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within b1w_prc_suspend_prepaid
integer beginy = 264
integer endx = 1838
integer endy = 264
end type

type ln_down from w_a_prc`ln_down within b1w_prc_suspend_prepaid
integer beginy = 1024
integer endx = 1838
integer endy = 1024
end type

type p_close from w_a_prc`p_close within b1w_prc_suspend_prepaid
integer x = 1449
integer y = 148
end type

type gb_cond from w_a_prc`gb_cond within b1w_prc_suspend_prepaid
integer width = 1307
integer height = 232
end type

type st_1 from statictext within b1w_prc_suspend_prepaid
integer x = 187
integer y = 104
integer width = 1038
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "Prepaid Suspention Process...."
boolean focusrectangle = false
end type

