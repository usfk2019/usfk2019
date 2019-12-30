$PBExportHeader$w_a_reg_m.srw
$PBExportComments$Multi master Register ( from w_a_condition)
forward
global type w_a_reg_m from w_a_condition
end type
type p_delete from u_p_delete within w_a_reg_m
end type
type p_insert from u_p_insert within w_a_reg_m
end type
type p_save from u_p_save within w_a_reg_m
end type
type dw_detail from u_d_indicator within w_a_reg_m
end type
type p_reset from u_p_reset within w_a_reg_m
end type
end forward

global type w_a_reg_m from w_a_condition
integer height = 1848
event type integer ue_insert ( )
event type integer ue_delete ( )
event type integer ue_save ( )
event type integer ue_extra_insert ( long al_insert_row )
event type integer ue_extra_delete ( )
event type integer ue_extra_save ( )
event type integer ue_reset ( )
p_delete p_delete
p_insert p_insert
p_save p_save
dw_detail dw_detail
p_reset p_reset
end type
global w_a_reg_m w_a_reg_m

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app

//AncestorReturnValue사용으로 의미가 없어짐.
//Int ii_error_chk

end variables

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0
end event

event ue_delete;Constant Int LI_ERROR = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End if

If dw_detail.RowCount() > 0 Then
	dw_detail.DeleteRow(0)
	dw_detail.SetFocus()
End if

Return 0
end event

event ue_save;Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End If

Return 0
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

//ii_error_chk = -1

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//ii_error_chk = 0
Return 0
end event

on w_a_reg_m.create
int iCurrent
call super::create
this.p_delete=create p_delete
this.p_insert=create p_insert
this.p_save=create p_save
this.dw_detail=create dw_detail
this.p_reset=create p_reset
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_delete
this.Control[iCurrent+2]=this.p_insert
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.p_reset
end on

on w_a_reg_m.destroy
call super::destroy
destroy(this.p_delete)
destroy(this.p_insert)
destroy(this.p_save)
destroy(this.dw_detail)
destroy(this.p_reset)
end on

event closequery;call super::closequery;Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

event open;call super::open;iu_cust_db_app = Create u_cust_db_app

TriggerEvent("ue_reset")


end event

event close;call super::close;Destroy iu_cust_db_app


end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_condition`dw_cond within w_a_reg_m
end type

type p_ok from w_a_condition`p_ok within w_a_reg_m
integer x = 2455
integer y = 48
end type

type p_close from w_a_condition`p_close within w_a_reg_m
integer y = 48
end type

type gb_cond from w_a_condition`gb_cond within w_a_reg_m
end type

type p_delete from u_p_delete within w_a_reg_m
integer x = 325
integer y = 1596
boolean enabled = false
boolean originalsize = false
end type

type p_insert from u_p_insert within w_a_reg_m
integer x = 32
integer y = 1596
boolean enabled = false
boolean originalsize = false
end type

type p_save from u_p_save within w_a_reg_m
integer x = 622
integer y = 1596
boolean enabled = false
boolean originalsize = false
end type

type dw_detail from u_d_indicator within w_a_reg_m
integer x = 32
integer y = 320
integer width = 3003
integer height = 1244
integer taborder = 2
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event ue_key;call super::ue_key;If keyflags = 0 Then
	If key = KeyEscape! Then
		Parent.TriggerEvent(is_close)
	End If
End If



end event

event retrieveend;call super::retrieveend;If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If

end event

type p_reset from u_p_reset within w_a_reg_m
integer x = 1138
integer y = 1596
boolean enabled = false
boolean originalsize = false
end type

