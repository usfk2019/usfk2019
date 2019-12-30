$PBExportHeader$b5w_prc_itemsale_m_pre.srw
$PBExportComments$[khpark]선불기본료정액상품rateing
forward
global type b5w_prc_itemsale_m_pre from b5w_a_prc_reqpgm
end type
end forward

global type b5w_prc_itemsale_m_pre from b5w_a_prc_reqpgm
integer height = 1236
end type
global b5w_prc_itemsale_m_pre b5w_prc_itemsale_m_pre

type variables

end variables

forward prototypes
public function string wfs_reqconf_payid (string as_chargedt, string as_pgm_id)
end prototypes

public function string wfs_reqconf_payid (string as_chargedt, string as_pgm_id);string ls_chargedt,ls_prc_payid,ls_pgm_id
ls_chargedt = as_chargedt
ls_pgm_id = as_pgm_id

Select nvl(prcpayid,'')
Into   :ls_prc_payid
From   reqpgm
Where  chargedt = :ls_chargedt and pgm_id = :ls_pgm_id;

Return ls_prc_payid
end function

on b5w_prc_itemsale_m_pre.create
call super::create
end on

on b5w_prc_itemsale_m_pre.destroy
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
//subroutine B5ITEMSALE_M_PRE(string P_CHARGEDT,string P_PGM_ID,string P_USER_ID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"B5ITEMSALE_M_PRE~""
SQLCA.B5ITEMSALE_M_PRE(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	is_msg_process = ls_errmsg + ",,," + SQLCA.SQLErrText
	Return -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	is_msg_process = ls_errmsg 
	Return -1
End If

is_msg_process = + String(lb_count, "#,##0") + "Hit(s)"

//성공
Return 0

end event

type p_ok from b5w_a_prc_reqpgm`p_ok within b5w_prc_itemsale_m_pre
integer x = 1472
integer y = 60
end type

type dw_input from b5w_a_prc_reqpgm`dw_input within b5w_prc_itemsale_m_pre
integer x = 46
integer y = 68
integer width = 1198
integer height = 244
string dataobject = "b5d_cnd_prc_inv_payid"
end type

event dw_input::itemchanged;call super::itemchanged;IF dwo.Name = "chargedt" THEN
      dw_input.object.payid[1] = wfs_reqconf_payid(dw_input.object.chargedt[1],iu_cust_msg.is_pgm_id)
END IF
end event

type dw_msg_time from b5w_a_prc_reqpgm`dw_msg_time within b5w_prc_itemsale_m_pre
integer y = 844
end type

type dw_msg_processing from b5w_a_prc_reqpgm`dw_msg_processing within b5w_prc_itemsale_m_pre
integer y = 380
end type

type ln_up from b5w_a_prc_reqpgm`ln_up within b5w_prc_itemsale_m_pre
integer beginy = 364
integer endx = 1897
integer endy = 364
end type

type ln_down from b5w_a_prc_reqpgm`ln_down within b5w_prc_itemsale_m_pre
integer beginy = 1124
integer endx = 1897
integer endy = 1124
end type

type p_close from b5w_a_prc_reqpgm`p_close within b5w_prc_itemsale_m_pre
integer x = 1472
integer y = 168
end type

type gb_cond from b5w_a_prc_reqpgm`gb_cond within b5w_prc_itemsale_m_pre
integer y = 8
integer width = 1330
integer height = 336
end type

