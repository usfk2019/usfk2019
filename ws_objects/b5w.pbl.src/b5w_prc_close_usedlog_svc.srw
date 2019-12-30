﻿$PBExportHeader$b5w_prc_close_usedlog_svc.srw
$PBExportComments$[backgu] Service사용료 월청구마감 Window
forward
global type b5w_prc_close_usedlog_svc from b5w_a_prc_reqpgm
end type
end forward

global type b5w_prc_close_usedlog_svc from b5w_a_prc_reqpgm
integer height = 1240
end type
global b5w_prc_close_usedlog_svc b5w_prc_close_usedlog_svc

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

on b5w_prc_close_usedlog_svc.create
call super::create
end on

on b5w_prc_close_usedlog_svc.destroy
call super::destroy
end on

event ue_input;call super::ue_input;String ls_sysdate
If ii_input_error = -1 Then 
	Return -1
End If	

//시스템 date check해서 작업일 가능한지 check.//
//ls_sysdate = string(date(fdt_get_dbserver_now()),'yyyymmdd')
//If ls_sysdate < is_next_fr  Then
//	f_msg_usr_err(1200, This.title, +&
//	'작업조건: ' + mid(is_next_fr,1,4) +'-'+  mid(is_next_fr,5,2) +'-' + mid(is_next_fr,7,2) +'일 이후 부터 작업이 가능 합니다')
//	dw_input.SetFocus()
//	dw_input.SetColumn("chargedt")
//	Return -1
//	
//End If 
//
Return 0

end event

event type integer ue_process();String ls_errmsg,ls_cur_fr,ls_next_fr,ls_pgm_id,ls_chargedt,ls_payid
String ls_reqnum_fr,ls_reqnum_to
Long ll_return, ll_max, ll_i
double lb_count


ls_reqnum_fr = space(256)
ls_reqnum_to = space(256)
ll_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_payid = trim(dw_input.Object.payid[1])
ls_chargedt = trim(dw_input.Object.chargedt[1])
If isnull(ls_payid)  Then
   ls_payid = '0000000'
End IF;

If ls_payid = '' Then 
	ls_payid = '0000000'
End If	
	

//처리부분...
SQLCA.b5ItemSaleClose(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ls_reqnum_fr, ls_reqnum_to, ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1

ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

is_msg_process = 'Invoice No:' + ls_reqnum_fr + '-' + ls_reqnum_to + string(lb_count)  + "Hit(s)"


If ll_return <> 0 Then	//실패
	Return -1
Else				//성공
	Return 0
End If

end event

event open;call super::open;If dw_input.object.chargedt.protect = '1' Then//청구작업절차에서 표시된경우 
	dw_input.object.payid[1] = wfs_reqconf_payid(dw_input.object.chargedt[1])
End If
end event

type p_ok from b5w_a_prc_reqpgm`p_ok within b5w_prc_close_usedlog_svc
end type

type dw_input from b5w_a_prc_reqpgm`dw_input within b5w_prc_close_usedlog_svc
integer y = 112
integer width = 1417
integer height = 196
string dataobject = "b5d_cnd_prc_close_cdr"
end type

event dw_input::itemchanged;call super::itemchanged;IF dwo.Name = "chargedt" THEN
      dw_input.object.payid[1] = wfs_reqconf_payid(dw_input.object.chargedt[1])
END IF
end event

type dw_msg_time from b5w_a_prc_reqpgm`dw_msg_time within b5w_prc_close_usedlog_svc
integer y = 840
end type

type dw_msg_processing from b5w_a_prc_reqpgm`dw_msg_processing within b5w_prc_close_usedlog_svc
integer y = 376
end type

type ln_up from b5w_a_prc_reqpgm`ln_up within b5w_prc_close_usedlog_svc
integer beginy = 356
integer endx = 1897
integer endy = 356
end type

type ln_down from b5w_a_prc_reqpgm`ln_down within b5w_prc_close_usedlog_svc
integer beginy = 1128
integer endx = 1897
integer endy = 1128
end type

type p_close from b5w_a_prc_reqpgm`p_close within b5w_prc_close_usedlog_svc
end type

type gb_cond from b5w_a_prc_reqpgm`gb_cond within b5w_prc_close_usedlog_svc
integer height = 348
end type

