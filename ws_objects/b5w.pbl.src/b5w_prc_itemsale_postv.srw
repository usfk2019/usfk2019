$PBExportHeader$b5w_prc_itemsale_postv.srw
$PBExportComments$[hhm]월통화판매액생성
forward
global type b5w_prc_itemsale_postv from b5w_a_prc_reqpgm
end type
end forward

global type b5w_prc_itemsale_postv from b5w_a_prc_reqpgm
integer width = 1984
integer height = 1248
end type
global b5w_prc_itemsale_postv b5w_prc_itemsale_postv

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

on b5w_prc_itemsale_postv.create
call super::create
end on

on b5w_prc_itemsale_postv.destroy
call super::destroy
end on

event ue_input;call super::ue_input;String ls_sysdate
If ii_input_error = -1 Then 
	Return -1
End If	

Return 0

end event

event type integer ue_process();String ls_errmsg,ls_pgm_id,ls_chargedt,ls_payid
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_chargedt = trim(dw_input.Object.chargedt[1])
ls_payid = trim(dw_input.Object.payid[1])
If isnull(ls_payid)  Then
   ls_payid = '00000000'
End IF;

If ls_payid = '' Then 
	ls_payid = '00000000'
End If	

//처리부분...
SQLCA.b5ItemSale_postV(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id,  ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	is_msg_process = ls_errmsg + ",,," + SQLCA.SQLErrText
	Return -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	is_msg_process = ls_errmsg 
	Return -1
End If

is_msg_process = "Count : " + String(lb_count, "#,##0") 

//성공
Return 0

end event

event open;call super::open;If dw_input.object.chargedt.protect = '1' Then//청구작업절차에서 표시된경우 
	dw_input.object.payid[1] = wfs_reqconf_payid(dw_input.object.chargedt[1],iu_cust_msg.is_pgm_id)
End If
end event

type p_ok from b5w_a_prc_reqpgm`p_ok within b5w_prc_itemsale_postv
integer x = 1536
integer y = 80
end type

type dw_input from b5w_a_prc_reqpgm`dw_input within b5w_prc_itemsale_postv
integer x = 78
integer y = 92
integer width = 1211
integer height = 264
string dataobject = "b5d_cnd_prc_inv_payid"
end type

event dw_input::itemchanged;call super::itemchanged;IF dwo.Name = "chargedt" THEN
      dw_input.object.payid[1] = wfs_reqconf_payid(dw_input.object.chargedt[1],iu_cust_msg.is_pgm_id)
END IF
end event

type dw_msg_time from b5w_a_prc_reqpgm`dw_msg_time within b5w_prc_itemsale_postv
integer y = 864
end type

type dw_msg_processing from b5w_a_prc_reqpgm`dw_msg_processing within b5w_prc_itemsale_postv
integer y = 400
end type

type ln_up from b5w_a_prc_reqpgm`ln_up within b5w_prc_itemsale_postv
integer beginy = 384
integer endx = 1897
integer endy = 384
end type

type ln_down from b5w_a_prc_reqpgm`ln_down within b5w_prc_itemsale_postv
integer beginy = 1144
integer endx = 1897
integer endy = 1144
end type

type p_close from b5w_a_prc_reqpgm`p_close within b5w_prc_itemsale_postv
integer x = 1536
integer y = 212
end type

type gb_cond from b5w_a_prc_reqpgm`gb_cond within b5w_prc_itemsale_postv
integer y = 28
integer width = 1376
integer height = 336
end type

