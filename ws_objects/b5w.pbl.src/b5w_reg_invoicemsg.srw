$PBExportHeader$b5w_reg_invoicemsg.srw
$PBExportComments$[islim] 청구서 안내문
forward
global type b5w_reg_invoicemsg from w_a_reg_m
end type
end forward

global type b5w_reg_invoicemsg from w_a_reg_m
end type
global b5w_reg_invoicemsg b5w_reg_invoicemsg

on b5w_reg_invoicemsg.create
call super::create
end on

on b5w_reg_invoicemsg.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b5w_reg_invoicemsg_hk
	Desc.	: 	청구서 안내문 등록
	Date	:	2003.08.01
	Auth.	: 	C.BORA(ceusee)
------------------------------------------------------------------------*/
end event

event ue_ok();call super::ue_ok;String ls_pay_method, ls_langtype, ls_fromdt_fr, ls_fromdt_to, ls_where
Long ll_row
String ls_trdt, ls_chargedt

ls_trdt = String(dw_cond.Object.trdt[1],'yyyymmdd')
ls_chargedt = Trim(dw_cond.object.chargedt[1])
ls_pay_method = Trim(dw_cond.object.pay_method[1])
ls_langtype = Trim(dw_cond.object.langtype[1])

If IsNull(ls_trdt) Then ls_trdt = ""
If IsNull(ls_chargedt) Then ls_chargedt = ""
If Isnull(ls_pay_method) Then ls_pay_method = ""
If Isnull(ls_langtype) Then ls_langtype = ""


ls_where = ""
If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "chargedt ='"+ls_chargedt +"' "
End if

If ls_trdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(trdt,'yyyymmdd') ='" +ls_trdt +"' "
End If

If ls_pay_method <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "pay_method ='" + ls_pay_method + "' "
End If

If ls_langtype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "langtype ='" + ls_langtype + "' "
End If

If ls_fromdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(fromdt,'yyyymmdd') >='" + ls_fromdt_fr + "' "
End If

If ls_fromdt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(fromdt,'yyyymmdd')  <='" + ls_fromdt_to + "' "
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()


If ll_row = 0 Then
	f_msg_info(1000, title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return
End If


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;Long i
DateTime ldt_sysdate
ldt_sysdate = fdt_get_dbserver_now()

dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = ldt_sysdate
dw_detail.object.crtdt[al_insert_row] = ldt_sysdate
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]


//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("chargedt")

Return 0 
end event

event type integer ue_extra_save();call super::ue_extra_save;Long i
String ls_pay_method, ls_langtype, ls_fromdt
String ls_trdt, ls_chargedt
DateTime ldt_sysdate, ldt_trdt


ldt_sysdate= fdt_get_dbserver_now()

For i= 1 To dw_detail.RowCount()
	ls_chargedt = Trim(dw_detail.object.chargedt[i])
	If IsNull(ls_chargedt) Then ls_chargedt=""
	If ls_chargedt ="" Then
		f_msg_info(200, Title,"청구주기")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("chargedt")
		dw_detail.SetFocus()		
		Return -1
	End If
	
	ldt_trdt = dw_detail.object.trdt[i]
	ls_trdt = String(ldt_trdt, 'yyyymmdd')
	If IsNull(ls_trdt) Then ls_trdt =""
	If ls_trdt="" Then
		f_msg_Info(200, Title, "청구기준일")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("trdt")
		dw_detail.SetFocus()		
		Return -1
	End If
	
	ls_pay_method = Trim(dw_detail.object.pay_method[i])
	If Isnull(ls_pay_method) Then ls_pay_method = ""
	If ls_pay_method = "" Then
		f_msg_Info(200, Title,"결제방법")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("pay_method")
		dw_detail.SetFocus()		
		Return -1
	End If
	
	ls_langtype = Trim(dw_detail.object.langtype[i])
	If Isnull(ls_langtype) Then ls_langtype = ""
	If ls_langtype = "" Then
		f_msg_Info(200, Title, "사용언어")
		dw_detail.SetRow(i)
		dw_detail.SetColumn("langtype")
		dw_detail.SetFocus()		
		Return -1
	End If
	


 //Update Log
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[i] = gs_user_id
		dw_detail.object.updtdt[i] = ldt_sysdate
   End If
Next

Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_invoicemsg
integer height = 308
string dataobject = "b5dw_cnd_reg_invoicemsg"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b5w_reg_invoicemsg
end type

type p_close from w_a_reg_m`p_close within b5w_reg_invoicemsg
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_invoicemsg
integer height = 368
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_invoicemsg
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_invoicemsg
end type

type p_save from w_a_reg_m`p_save within b5w_reg_invoicemsg
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_invoicemsg
integer y = 388
integer height = 1176
string dataobject = "b5dw_reg_invoicemsg"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력했을시 버튼 활성화
If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_invoicemsg
end type

