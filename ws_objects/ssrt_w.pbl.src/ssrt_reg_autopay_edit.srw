$PBExportHeader$ssrt_reg_autopay_edit.srw
$PBExportComments$[1hera] AutoPayment Update
forward
global type ssrt_reg_autopay_edit from w_a_reg_m
end type
end forward

global type ssrt_reg_autopay_edit from w_a_reg_m
integer width = 3950
integer height = 2016
end type
global ssrt_reg_autopay_edit ssrt_reg_autopay_edit

type variables
String is_cus_status
end variables

on ssrt_reg_autopay_edit.create
call super::create
end on

on ssrt_reg_autopay_edit.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String 	ls_customerid, ls_reqdt, ls_where
Long 		ll_row, 			ll_result

dw_cond.AcceptText()

ls_reqdt       = String(dw_cond.object.reqdt[1],'yyyymmdd')
ls_customerid  = Trim(dw_cond.object.customerid[1])
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_reqdt) 			Then ls_reqdt 			= ""

If ls_reqdt = "" Then
	f_msg_info(200, Title, "Request Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reqdt")
	Return
End If
ls_where = ""
If ls_reqdt <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "a.requestdt = '" + ls_reqdt + "' "
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += "b.customerid = '" + ls_customerid + "'"
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If
SetRedraw(False)

If ll_row > 0 Then
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_disable")

	dw_cond.Enabled 		= False
else
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_Enable")
	dw_cond.Enabled 		= True
	dw_cond.SetFocus()
End If

SetRedraw(True)
end event

type dw_cond from w_a_reg_m`dw_cond within ssrt_reg_autopay_edit
integer x = 37
integer y = 52
integer width = 2217
integer height = 292
string dataobject = "ssrt_cnd_reg_autopay_edit"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm, ls_memberid, &
		 ls_operator
Integer	li_cnt

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select customernm
		  INTO :ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		IF ls_customernm = '' THEN
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			return 1
		ELSE
			This.Object.customernm[1] 	=  ls_customernm
		END IF
End Choose

end event

event dw_cond::ue_init();call super::ue_init;String ls_emp_grp,		ls_basecod
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

dw_cond.reset()


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

type p_ok from w_a_reg_m`p_ok within ssrt_reg_autopay_edit
integer x = 2482
integer y = 28
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within ssrt_reg_autopay_edit
integer x = 2784
integer y = 28
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ssrt_reg_autopay_edit
integer x = 18
integer width = 2290
integer height = 348
end type

type p_delete from w_a_reg_m`p_delete within ssrt_reg_autopay_edit
integer x = 315
integer y = 1768
end type

type p_insert from w_a_reg_m`p_insert within ssrt_reg_autopay_edit
boolean visible = false
integer x = 23
integer y = 1768
end type

type p_save from w_a_reg_m`p_save within ssrt_reg_autopay_edit
integer x = 608
integer y = 1768
end type

type dw_detail from w_a_reg_m`dw_detail within ssrt_reg_autopay_edit
integer x = 18
integer y = 376
integer width = 3849
integer height = 1340
string dataobject = "ssrt_reg_autopay_edit"
boolean hscrollbar = false
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within ssrt_reg_autopay_edit
integer x = 1179
integer y = 1768
end type

