﻿$PBExportHeader$b5w_prc_reqamtinfo.srw
$PBExportComments$[hhm] 월청구서금액생성
forward
global type b5w_prc_reqamtinfo from b5w_a_prc_reqpgm
end type
end forward

global type b5w_prc_reqamtinfo from b5w_a_prc_reqpgm
integer width = 2057
integer height = 1168
end type
global b5w_prc_reqamtinfo b5w_prc_reqamtinfo

type variables

end variables

forward prototypes
public function string wfs_reqconf_payid (string as_chargedt)
end prototypes

public function string wfs_reqconf_payid (string as_chargedt);string ls_chargedt,ls_prc_payid
ls_chargedt = as_chargedt

Select nvl(prc_payid,'')
Into   :ls_prc_payid
From   reqconf
Where  chargedt = :ls_chargedt;

Return ls_prc_payid
end function

on b5w_prc_reqamtinfo.create
call super::create
end on

on b5w_prc_reqamtinfo.destroy
call super::destroy
end on

event ue_input;call super::ue_input;String ls_sysdate
If ii_input_error = -1 Then 
	Return -1
End If	

Return 0

end event

event type integer ue_process();String ls_errmsg,ls_pgm_id,ls_chargedt
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_chargedt = trim(dw_input.Object.chargedt[1])

//처리부분...
SQLCA.b5ReqAmtInfo(ls_chargedt, ls_pgm_id,gs_user_id,  ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	is_msg_process = ls_errmsg + ",,," + SQLCA.SQLErrText
	Return -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	is_msg_process = ls_errmsg 
	Return -1
End If

is_msg_process = String(lb_count, "#,##0") + "Hit(s)"

//성공
Return 0

end event

type p_ok from b5w_a_prc_reqpgm`p_ok within b5w_prc_reqamtinfo
integer x = 1710
integer y = 52
end type

type dw_input from b5w_a_prc_reqpgm`dw_input within b5w_prc_reqamtinfo
integer x = 64
integer y = 76
integer width = 1454
integer height = 168
string dataobject = "b5d_cnd_prc_reqpgm2"
end type

type dw_msg_time from b5w_a_prc_reqpgm`dw_msg_time within b5w_prc_reqamtinfo
integer x = 37
integer y = 784
end type

type dw_msg_processing from b5w_a_prc_reqpgm`dw_msg_processing within b5w_prc_reqamtinfo
integer y = 324
end type

type ln_up from b5w_a_prc_reqpgm`ln_up within b5w_prc_reqamtinfo
integer beginy = 304
integer endy = 304
end type

type ln_down from b5w_a_prc_reqpgm`ln_down within b5w_prc_reqamtinfo
integer beginy = 1068
integer endy = 1068
end type

type p_close from b5w_a_prc_reqpgm`p_close within b5w_prc_reqamtinfo
integer x = 1714
integer y = 176
end type

type gb_cond from b5w_a_prc_reqpgm`gb_cond within b5w_prc_reqamtinfo
integer width = 1559
integer height = 280
end type
