$PBExportHeader$b1w_prc_payid_movepartner.srw
$PBExportComments$[ohj] 일자별CDRyyyymmdd=>post_bilcdr v20
forward
global type b1w_prc_payid_movepartner from w_a_prc
end type
end forward

global type b1w_prc_payid_movepartner from w_a_prc
integer width = 2469
integer height = 1324
end type
global b1w_prc_payid_movepartner b1w_prc_payid_movepartner

type variables

end variables

on b1w_prc_payid_movepartner.create
call super::create
end on

on b1w_prc_payid_movepartner.destroy
call super::destroy
end on

event type integer ue_process();
String ls_errmsg,ls_customerid,ls_reg_partner,ls_sale_partner,ls_main_partner,ls_partner,ls_null
Long ll_return
double lb_count


ll_return = -1
ls_errmsg = space(800)
//ls_pgm_id = iu_cust_msg.is_pgm_id
//ls_chargedt = trim(dw_input.Object.chargedt[1])
ls_customerid   = Trim(dw_input.Object.customerid[1])
ls_reg_partner  = Trim(dw_input.Object.reg_partner[1])
ls_sale_partner = Trim(dw_input.Object.sale_partner[1])
ls_main_partner = Trim(dw_input.Object.main_partner[1])
ls_partner      = Trim(dw_input.Object.partner[1])
setnull(ls_null )

If IsNull(ls_reg_partner) Or ls_reg_partner = '' Then ls_reg_partner = ls_null
If IsNull(ls_sale_partner) Or ls_sale_partner = '' Then ls_sale_partner = ls_null
If IsNull(ls_main_partner) Or ls_main_partner = '' Then ls_main_partner = ls_null
If IsNull(ls_partner)  Or ls_partner = ''Then ls_partner = ls_null

//처리부분...
//SQLCA.b5AppendPost_bilcdr_v2(ls_yyyymmdd_to, 1000, 100, ll_return, ls_errmsg, lb_count)
SQLCA.B2PAYID_MOVEPARTNER(ls_customerid, ls_reg_partner, ls_sale_partner, ls_main_partner, ls_partner, ll_return, ls_errmsg, lb_count)
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

event type integer ue_input();call super::ue_input;String ls_customerid, ls_reg_partner, ls_sale_partner, ls_main_partner, ls_partner

ls_customerid   = Trim(dw_input.Object.customerid[1])
ls_reg_partner  = Trim(dw_input.Object.reg_partner[1])
ls_sale_partner = Trim(dw_input.Object.sale_partner[1])
ls_main_partner = Trim(dw_input.Object.main_partner[1])
ls_partner      = Trim(dw_input.Object.partner[1])


If ls_customerid = "" Then
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("고객번호")
	Return -1
End If

If IsNull(ls_reg_partner) AND IsNull(ls_sale_partner) AND + &
   IsNull(ls_main_partner) AND IsNull(ls_partner) Then
	f_msg_info(9000, This.Title, "하나 이상의 대리점 정보가 존재해야 합니다.")
	dw_input.SetFocus()
   dw_input.SetColumn("reg_partner")
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


p_ok.SetFocus()

 
end event

type p_ok from w_a_prc`p_ok within b1w_prc_payid_movepartner
integer x = 2130
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b1w_prc_payid_movepartner
integer x = 50
integer y = 52
integer width = 2030
integer height = 312
string dataobject = "b1d_cnd_prc_payid_movepartner"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_input::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_input::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If

End Choose
end event

type dw_msg_time from w_a_prc`dw_msg_time within b1w_prc_payid_movepartner
integer y = 888
integer width = 2098
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b1w_prc_payid_movepartner
integer y = 424
integer width = 2098
end type

type ln_up from w_a_prc`ln_up within b1w_prc_payid_movepartner
integer beginy = 408
integer endx = 2080
integer endy = 408
end type

type ln_down from w_a_prc`ln_down within b1w_prc_payid_movepartner
integer beginy = 1168
integer endx = 2080
integer endy = 1168
end type

type p_close from w_a_prc`p_close within b1w_prc_payid_movepartner
integer x = 2130
integer y = 148
end type

type gb_cond from w_a_prc`gb_cond within b1w_prc_payid_movepartner
integer width = 2075
integer height = 380
end type

