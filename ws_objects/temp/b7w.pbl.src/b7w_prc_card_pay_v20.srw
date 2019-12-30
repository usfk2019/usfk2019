$PBExportHeader$b7w_prc_card_pay_v20.srw
$PBExportComments$[jsha] 신용카드 입금처리
forward
global type b7w_prc_card_pay_v20 from w_a_reg_m_m
end type
type p_payment from u_p_payment within b7w_prc_card_pay_v20
end type
end forward

global type b7w_prc_card_pay_v20 from w_a_reg_m_m
integer height = 1620
event ue_payment ( )
p_payment p_payment
end type
global b7w_prc_card_pay_v20 b7w_prc_card_pay_v20

event ue_payment();String ls_errmsg, ls_pgm_id
String ls_temp, ls_ref_desc, ls_pay_type[], ls_paytype
Double lb_count
Long  ll_return, ll_workno, ll_row
Int    li_cnt

ll_row = dw_master.GetRow()
If ll_row <= 0 Then Return

ll_workno = dw_master.Object.workno[ll_row]
ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ll_return = -1

//입금유형(REQDTL:PAYTYPE)
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_pay_type[])
ls_paytype = ls_pay_type[4]

//입금유형- Card type
If IsNull(ls_paytype) Or ls_paytype = "" Then Return 

// Procedure Call
SQLCA.B7CARDREQPAY(ll_workno, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return 
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

//지로 입금 처리
SQLCA.B5REQPAY2DTL_NOSEQ(ls_paytype, gs_user_id, ls_pgm_id, ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	Return 

ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

If ll_return <> 0 Then	//실패
	f_msg_info(3000, Title, "입금TR생성이 되지 않았습니다.")
	Return 
Else							//성공
	f_msg_info(3000, Title, "신용카드 입금 처리 반영(건수 : " + String(lb_count)+ ")")
	Return
End If

This.TriggerEvent('ue_ok')
end event

event ue_ok();call super::ue_ok;String ls_where, ls_status, ls_ref_desc, ls_temp, ls_result[]
Long ll_row
Int li_return

//ls_temp = fs_get_control("B7", "C100", ls_ref_desc)
ls_temp = fs_get_control("B7", "C110", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result[])
//ls_status = ls_result[4]
ls_status = ls_result[7]

//ls_where = "a.status = '" + ls_status + "' "
//dw_master.is_where = ls_where

ll_row = dw_master.Retrieve(ls_status)

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ELseIf ll_row > 0 Then
	p_payment.TriggerEvent('ue_enable')
End If
end event

on b7w_prc_card_pay_v20.create
int iCurrent
call super::create
this.p_payment=create p_payment
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_payment
end on

on b7w_prc_card_pay_v20.destroy
call super::destroy
destroy(this.p_payment)
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_payment.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_payment.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event open;call super::open;p_payment.TriggerEvent('ue_disable')
This.TriggerEvent('ue_ok')

end event

type dw_cond from w_a_reg_m_m`dw_cond within b7w_prc_card_pay_v20
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_reg_m_m`p_ok within b7w_prc_card_pay_v20
boolean visible = false
integer x = 64
integer y = 1664
end type

type p_close from w_a_reg_m_m`p_close within b7w_prc_card_pay_v20
integer x = 347
integer y = 1392
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b7w_prc_card_pay_v20
boolean visible = false
end type

type dw_master from w_a_reg_m_m`dw_master within b7w_prc_card_pay_v20
integer y = 40
integer height = 604
string dataobject = "b7dw_m_prc_cardtext_pay_v20"
boolean ib_sort_use = false
end type

event dw_master::clicked;Long ll_selected_row,ll_old_selected_row
Int li_rc

ll_old_selected_row = This.GetSelectedRow(0)

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_old_selected_row > 0 Then
		dw_detail.AcceptText()

		If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
			li_rc = MessageBox(Parent.Title, "Data is Modified.! Do you want to cancel?" &
						,Question!, YesNo!)
   		If li_rc <> 1 Then
				If ll_selected_row > 0 Then
					SelectRow(ll_selected_row ,FALSE)
				End If
				SelectRow(ll_old_selected_row , TRUE )
				ScrollToRow(ll_old_selected_row)
				dw_detail.SetFocus()
				Return //Process Cancel
			End If
		End If
	End If
		
	If ll_selected_row > 0 Then
		If dw_detail.Trigger Event ue_retrieve(ll_selected_row) < 0 Then
			Return
		End If
		p_payment.TriggerEvent('ue_enable')
		p_insert.TriggerEvent('ue_enable') 
		p_delete.TriggerEvent('ue_enable') 
		p_save.TriggerEvent('ue_enable') 
		p_reset.TriggerEvent('ue_enable') 
		dw_detail.SetFocus()
	Else
		dw_detail.Reset()
		p_payment.TriggerEvent('ue_disable')		
		p_insert.TriggerEvent('ue_disable') 
		p_delete.TriggerEvent('ue_disable') 
		p_save.TriggerEvent('ue_disable') 
		p_reset.TriggerEvent('ue_disable') 
	End If
End If
end event

type dw_detail from w_a_reg_m_m`dw_detail within b7w_prc_card_pay_v20
integer y = 688
integer height = 664
string dataobject = "b7dw_d_prc_cardtext_pay_v20"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_where
Long ll_row, ll_workno

ll_workno = dw_master.Object.workno[al_select_row]

ls_where = "workno = " + String(ll_workno) + " "
dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b7w_prc_card_pay_v20
boolean visible = false
end type

type p_delete from w_a_reg_m_m`p_delete within b7w_prc_card_pay_v20
boolean visible = false
end type

type p_save from w_a_reg_m_m`p_save within b7w_prc_card_pay_v20
boolean visible = false
end type

type p_reset from w_a_reg_m_m`p_reset within b7w_prc_card_pay_v20
boolean visible = false
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b7w_prc_card_pay_v20
integer y = 652
end type

type p_payment from u_p_payment within b7w_prc_card_pay_v20
integer x = 41
integer y = 1392
boolean bringtotop = true
end type

