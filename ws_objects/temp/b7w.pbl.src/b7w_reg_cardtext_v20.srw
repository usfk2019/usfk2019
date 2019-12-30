$PBExportHeader$b7w_reg_cardtext_v20.srw
$PBExportComments$[jsha] 카드결제요청
forward
global type b7w_reg_cardtext_v20 from w_a_reg_m
end type
type p_create from u_p_create within b7w_reg_cardtext_v20
end type
end forward

global type b7w_reg_cardtext_v20 from w_a_reg_m
integer height = 1776
event ue_retrieve ( )
p_create p_create
end type
global b7w_reg_cardtext_v20 b7w_reg_cardtext_v20

event ue_retrieve();Long ll_row

ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ElseIf ll_row = 0 Then
	//	자료없음.
End If
end event

on b7w_reg_cardtext_v20.create
int iCurrent
call super::create
this.p_create=create p_create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_create
end on

on b7w_reg_cardtext_v20.destroy
call super::destroy
destroy(this.p_create)
end on

event ue_ok();call super::ue_ok;String ls_errmsg, ls_pgm_id, ls_chargedt, ls_trdt
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ls_chargedt = fs_snvl(dw_cond.Object.chargedt[1], "")
ls_trdt = fs_snvl(String(dw_cond.Object.reqdt[1], 'yyyy-mm-dd'), "")

If ls_chargedt = "" Then
	f_msg_usr_err(200, This.Title, "청구주기")
	dw_cond.SetColumn("chargedt")
	dw_cond.SetFocus()
	Return
End If
If ls_trdt = "" Then
	f_msg_usr_err(200, This.Title, "청구기준일")
	dw_cond.SetColumn("reqdt")
	dw_cond.SetFocus()
	Return
End If

//처리부분...
SQLCA.B7CARDTEXT(ls_chargedt, ls_trdt, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	Return 
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	Return 
ElseIf ll_return >= 0 Then
	MessageBox(This.Title, "Process Completed.")
End If


// Retrieve
This.TriggerEvent('ue_reset')
This.TriggerEvent('ue_retrieve')
end event

event open;call super::open;dw_detail.SetRowFocusIndicator(off!)
This.TriggerEvent('ue_retrieve')
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Object.period_t.Text = ""

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b7w_reg_cardtext_v20
integer x = 59
integer y = 52
integer width = 1819
integer height = 316
string dataobject = "b7dw_cnd_reg_cardtext_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;Int li_return
DataWindowChild ldc_trdt
String ls_filter, ls_period, ls_chargedt

Choose Case dwo.name
	Case "chargedt"
		//dw_cond.Object.reqdt[1] = Date("0000-00-00")
		li_return = dw_cond.GetChild("reqdt", ldc_trdt)
		If li_return = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 청구기준일")
		
		ls_filter = "chargedt = '" + data  + "' "
		ldc_trdt.SetTransObject(SQLCA)
		li_return =ldc_trdt.Retrieve()
		ldc_trdt.SetFilter(ls_filter)			//Filter정함
		ldc_trdt.Filter()
	
		If li_return < 0 Then 				
	  		f_msg_usr_err(2100, Title, "Retrieve()")
		End If  
	Case "reqdt"	
		ls_chargedt = dw_cond.Object.chargedt[1]
		
		SELECT to_char(useddt_fr, 'yyyy-mm-dd') || ' ~ ' || to_char(useddt_to, 'yyyy-mm-dd')
		INTO	:ls_period
		FROM	(SELECT useddt_fr, useddt_to FROM reqconf
				 WHERE chargedt = :ls_chargedt
				 AND	 reqdt = :data
				 UNION
				 SELECT useddt_fr, useddt_to FROM reqconfh
				 WHERE chargedt = :ls_chargedt
				 AND	 reqdt = :data);
				 
		If SQLCA.SQLCode < 0 Then
			f_msg_usr_err(9000, Parent.Title, "Error")
		End If
		
		dw_cond.Object.period_t.Text = ls_period
		
End Choose
end event

type p_ok from w_a_reg_m`p_ok within b7w_reg_cardtext_v20
boolean visible = false
integer x = 1970
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b7w_reg_cardtext_v20
integer x = 2322
integer y = 56
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b7w_reg_cardtext_v20
integer width = 1851
integer height = 376
end type

type p_delete from w_a_reg_m`p_delete within b7w_reg_cardtext_v20
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b7w_reg_cardtext_v20
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b7w_reg_cardtext_v20
boolean visible = false
end type

type dw_detail from w_a_reg_m`dw_detail within b7w_reg_cardtext_v20
integer y = 392
string dataobject = "b7dw_reg_cardtext_v20"
end type

event dw_detail::retrieveend;//If rowcount > 0 Then
//	p_ok.TriggerEvent("ue_disable")
//	
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	
//	dw_cond.Enabled = False
//End If

end event

type p_reset from w_a_reg_m`p_reset within b7w_reg_cardtext_v20
boolean visible = false
end type

type p_create from u_p_create within b7w_reg_cardtext_v20
integer x = 2007
integer y = 56
boolean bringtotop = true
end type

event clicked;call super::clicked;Parent.TriggerEvent('ue_ok')
end event

