﻿$PBExportHeader$b5w_prc_calcinvdiscount.srw
$PBExportComments$[hhm]청구할인계산
forward
global type b5w_prc_calcinvdiscount from b5w_a_prc_reqpgm
end type
end forward

global type b5w_prc_calcinvdiscount from b5w_a_prc_reqpgm
integer width = 1979
integer height = 1296
end type
global b5w_prc_calcinvdiscount b5w_prc_calcinvdiscount

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

on b5w_prc_calcinvdiscount.create
call super::create
end on

on b5w_prc_calcinvdiscount.destroy
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
SQLCA.b5CalcInvDiscount(ls_chargedt, ls_pgm_id, gs_user_id,  ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	is_msg_process = ls_errmsg + ",,," + SQLCA.SQLErrText
	Return -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	is_msg_process = ls_errmsg 
	Return -1
End If

is_msg_process =  String(lb_count, "#,##0")  + "Hit(s)"

//성공
Return 0

end event

type p_ok from b5w_a_prc_reqpgm`p_ok within b5w_prc_calcinvdiscount
integer x = 1618
integer y = 60
end type

type dw_input from b5w_a_prc_reqpgm`dw_input within b5w_prc_calcinvdiscount
integer x = 64
integer y = 92
integer width = 1371
integer height = 188
string dataobject = "b5d_cnd_prc_reqpgm2"
end type

type dw_msg_time from b5w_a_prc_reqpgm`dw_msg_time within b5w_prc_calcinvdiscount
integer y = 844
end type

type dw_msg_processing from b5w_a_prc_reqpgm`dw_msg_processing within b5w_prc_calcinvdiscount
integer y = 372
end type

type ln_up from b5w_a_prc_reqpgm`ln_up within b5w_prc_calcinvdiscount
integer beginx = 0
integer beginy = 336
integer endx = 1751
integer endy = 336
end type

type ln_down from b5w_a_prc_reqpgm`ln_down within b5w_prc_calcinvdiscount
integer beginy = 1140
integer endy = 1140
end type

type p_close from b5w_a_prc_reqpgm`p_close within b5w_prc_calcinvdiscount
integer x = 1618
integer y = 180
end type

type gb_cond from b5w_a_prc_reqpgm`gb_cond within b5w_prc_calcinvdiscount
integer y = 12
integer width = 1518
integer height = 280
end type
