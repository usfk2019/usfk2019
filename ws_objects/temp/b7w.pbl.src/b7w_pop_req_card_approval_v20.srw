$PBExportHeader$b7w_pop_req_card_approval_v20.srw
$PBExportComments$[jsha] 신용카드결제승인요청 popup window
forward
global type b7w_pop_req_card_approval_v20 from w_a_reg_m
end type
end forward

global type b7w_pop_req_card_approval_v20 from w_a_reg_m
integer width = 3502
integer height = 1036
boolean minbox = false
boolean maxbox = false
windowstate windowstate = normal!
end type
global b7w_pop_req_card_approval_v20 b7w_pop_req_card_approval_v20

type variables
Int ii_cnt
Long il_workno[]
end variables

on b7w_pop_req_card_approval_v20.create
call super::create
end on

on b7w_pop_req_card_approval_v20.destroy
call super::destroy
end on

event open;call super::open;Long ll_cnt

f_center_window(This)

iu_cust_msg = Message.PowerObjectParm
ii_cnt = iu_cust_msg.ii_data[1]

For ll_cnt = 1 To ii_cnt
	il_workno[ll_cnt] = iu_cust_msg.il_data[ll_cnt]
Next

This.TriggerEvent('ue_ok')
end event

event ue_ok();call super::ue_ok;String ls_where
Long ll_row
Int li_cnt

ls_where = ""
For li_cnt = 1 To ii_cnt
	If ls_where <> "" Then
		ls_where += " OR "
	End If
	
	ls_where += "workno = " + String(il_workno[li_cnt]) + " "
Next

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If
end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_close.Y	= newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b7w_pop_req_card_approval_v20
boolean visible = false
end type

type p_ok from w_a_reg_m`p_ok within b7w_pop_req_card_approval_v20
boolean visible = false
integer x = 114
integer y = 964
end type

type p_close from w_a_reg_m`p_close within b7w_pop_req_card_approval_v20
integer x = 23
integer y = 808
end type

type gb_cond from w_a_reg_m`gb_cond within b7w_pop_req_card_approval_v20
boolean visible = false
end type

type p_delete from w_a_reg_m`p_delete within b7w_pop_req_card_approval_v20
boolean visible = false
end type

type p_insert from w_a_reg_m`p_insert within b7w_pop_req_card_approval_v20
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b7w_pop_req_card_approval_v20
boolean visible = false
end type

type dw_detail from w_a_reg_m`dw_detail within b7w_pop_req_card_approval_v20
integer x = 14
integer y = 20
integer width = 3424
integer height = 764
string dataobject = "b7dw_prc_req_card_approval2_v20"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)

Return 0
end event

type p_reset from w_a_reg_m`p_reset within b7w_pop_req_card_approval_v20
boolean visible = false
end type

