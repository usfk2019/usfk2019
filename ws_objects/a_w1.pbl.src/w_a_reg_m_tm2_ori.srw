$PBExportHeader$w_a_reg_m_tm2_ori.srw
$PBExportComments$[kenn] multi master,tab,multi row Register - Update for tab selctionchanged ( from w_a_m_master)
forward
global type w_a_reg_m_tm2_ori from w_a_m_master
end type
type p_insert from u_p_insert within w_a_reg_m_tm2_ori
end type
type p_delete from u_p_delete within w_a_reg_m_tm2_ori
end type
type p_save from u_p_save within w_a_reg_m_tm2_ori
end type
type p_reset from u_p_reset within w_a_reg_m_tm2_ori
end type
type tab_1 from u_tab_reg within w_a_reg_m_tm2_ori
end type
type tab_1 from u_tab_reg within w_a_reg_m_tm2_ori
end type
end forward

global type w_a_reg_m_tm2_ori from w_a_m_master
integer width = 3090
integer height = 1892
boolean maxbox = false
boolean resizable = false
event type integer ue_insert ( )
event type integer ue_delete ( )
event type integer ue_save ( )
event type integer ue_extra_insert ( integer ai_selected_tab,  long al_insert_row )
event type integer ue_extra_delete ( )
event type integer ue_extra_save ( integer ai_select_tab )
event type integer ue_reset ( )
p_insert p_insert
p_delete p_delete
p_save p_save
p_reset p_reset
tab_1 tab_1
end type
global w_a_reg_m_tm2_ori w_a_reg_m_tm2_ori

type variables
//NVO For Common Processing
u_cust_db_app iu_cust_db_app

//tab 관련 기능 작동을 위한 Flag
Boolean ib_retrieve, ib_update = False, ib_no_retrieve = False

//AncestorReturnValue사용으로 필요없어짐
//Int ii_error_chk 

end variables

event ue_insert;Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return

//ii_error_chk = -1

li_curtab = tab_1.Selectedtab
ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0


end event

event ue_delete;Constant Int LI_ERROR = -1

//Int li_return

//ii_error_chk = -1

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End If

If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
	tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
	tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
End if

//ii_error_chk = 0
Return 0

end event

event ue_save;Constant Int LI_ERROR = -1
Int li_tab_index, li_return

//ii_error_chk = -1

li_tab_index = tab_1.SelectedTab
//For li_tab_index = 1 To tab_1.ii_enable_max_tab
	//If tab_1.ib_tabpage_check[li_tab_index] = True Then
		If tab_1.idw_tabpage[li_tab_index].AcceptText() < 0 Then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title

			iu_cust_db_app.uf_prc_db()
	
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If

			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			Return LI_ERROR
		End If

		li_return = Trigger Event ue_extra_save(li_tab_index)
		Choose Case li_return
			Case -2
				//필수항목 미입력
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return -2
			Case -1
				//ROLLBACK와 동일한 기능
				iu_cust_db_app.is_caller = "ROLLBACK"
				iu_cust_db_app.is_title = tab_1.is_parent_title
				iu_cust_db_app.uf_prc_db()
				If iu_cust_db_app.ii_rc = -1 Then
					ib_update = False
					Return -1
				End If
		
				f_msg_info(3010, tab_1.is_parent_title, "Save")
				ib_update = False
				Return -1
		End Choose
		
		If tab_1.idw_tabpage[li_tab_index].Update(True,False) < 0 then
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title
			iu_cust_db_app.uf_prc_db()
			If iu_cust_db_app.ii_rc = -1 Then
				tab_1.idw_tabpage[li_tab_index].SetFocus()
				Return LI_ERROR
			End If
		
			tab_1.SelectedTab = li_tab_index
			tab_1.idw_tabpage[li_tab_index].SetFocus()
			f_msg_info(3010,tab_1.is_parent_title,"Save")
			Return LI_ERROR
		End If
	//End If
//Next

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

//For li_tab_index = 1 To tab_1.ii_enable_max_tab
//	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
//	End If
//Next

f_msg_info(3000,tab_1.is_parent_title,"Save")

//ii_error_chk = 0
Return 0

end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

//ii_error_chk = -1

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
		If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
			(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
			tab_1.SelectedTab = li_tab_index
			li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
			If li_rc <> 1 Then
				Return LI_ERROR
			End If
		End If
	End If
Next

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")


For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False
Next

dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
tab_1.enabled = False

ib_retrieve = FALSE

//ii_error_chk = 0
Return 0


end event

on w_a_reg_m_tm2_ori.create
int iCurrent
call super::create
this.p_insert=create p_insert
this.p_delete=create p_delete
this.p_save=create p_save
this.p_reset=create p_reset
this.tab_1=create tab_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_insert
this.Control[iCurrent+2]=this.p_delete
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.tab_1
end on

on w_a_reg_m_tm2_ori.destroy
call super::destroy
destroy(this.p_insert)
destroy(this.p_delete)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.tab_1)
end on

event closequery;//Int li_tab_index, li_rc
Integer li_return
Integer li_curtab

li_curtab = tab_1.SelectedTab
tab_1.idw_tabpage[li_curtab].AcceptText() 
If (tab_1.idw_tabpage[li_curtab].ModifiedCount() > 0) or &
	(tab_1.idw_tabpage[li_curtab].DeletedCount() > 0)	Then
	li_return = MessageBox(Tab_1.is_parent_title, "Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
	If li_return <> 1 Then Return 1
End If

end event

event close;call super::close;Destroy iu_cust_db_app
end event

event open;call super::open;iu_cust_db_app = Create u_cust_db_app
TriggerEvent("ue_reset")
end event

event ue_ok;call super::ue_ok;Int li_tab_index

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False	
Next

ib_retrieve = False
end event

type dw_cond from w_a_m_master`dw_cond within w_a_reg_m_tm2_ori
integer width = 2158
end type

type p_ok from w_a_m_master`p_ok within w_a_reg_m_tm2_ori
integer y = 56
end type

type p_close from w_a_m_master`p_close within w_a_reg_m_tm2_ori
integer y = 56
end type

type gb_cond from w_a_m_master`gb_cond within w_a_reg_m_tm2_ori
end type

type dw_master from w_a_m_master`dw_master within w_a_reg_m_tm2_ori
integer width = 3013
integer height = 464
end type

event dw_master::clicked;Long ll_selected_row,ll_old_selected_row
Int li_tab_index,li_rc

ll_old_selected_row = This.GetSelectedRow(0)

Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_old_selected_row > 0 Then
		For li_tab_index = 1 To tab_1.ii_enable_max_tab
			If tab_1.ib_tabpage_check[li_tab_index] = True Then
				tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
				If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
					(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
					tab_1.SelectedTab = li_tab_index
					li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
						"Do you want to cancel?",Question!,YesNo!)
					If li_rc <> 1 Then
						If ll_selected_row > 0 Then
							SelectRow(ll_selected_row ,FALSE)
						End If
						SelectRow(ll_old_selected_row , TRUE )
						ScrollToRow(ll_old_selected_row)
						tab_1.idw_tabpage[li_tab_index].SetFocus()
						Return 
					End If
				End If
			End If	
		Next
	End If
		
	For li_tab_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_tab_index].Reset()
		tab_1.ib_tabpage_check[li_tab_index] = False
	Next
		
	If ll_selected_row > 0 Then
		tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)
		p_insert.TriggerEvent('ue_enable') 
		p_delete.TriggerEvent('ue_enable')
		p_save.TriggerEvent('ue_enable')
		p_reset.TriggerEvent('ue_enable')
		tab_1.enabled = true
		tab_1.idw_tabpage[Tab_1.SelectedTab].SetFocus()
	Else		
		p_insert.TriggerEvent('ue_disable')
		p_delete.TriggerEvent('ue_disable')
		p_save.TriggerEvent('ue_disable')
		p_reset.TriggerEvent('ue_disable')
		tab_1.enabled = false
	End If
End If
end event

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	ib_retrieve = True
	Tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

	Tab_1.SetFocus()
	p_save.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
	p_insert.TriggerEvent('ue_enable')
	p_delete.TriggerEvent('ue_enable')

	p_ok.TriggerEvent('ue_disable')
	dw_cond.Enabled =  False
End If

end event

event ue_after_sort;//PB 6.0 : Sort()후의 첫번째 열의 자동 선택에 따른 해결책(Sort()전에 선택된 열이 존재시)
Long ll_select_row

ll_select_row = GetSelectedRow(0)

If ll_select_row > 0 Then
	Trigger Event Clicked(0, 0, ll_select_row, Object.a_d)
End If

Return 0

end event

type p_insert from u_p_insert within w_a_reg_m_tm2_ori
integer x = 32
integer y = 1668
boolean enabled = false
end type

type p_delete from u_p_delete within w_a_reg_m_tm2_ori
integer x = 325
integer y = 1668
boolean enabled = false
end type

type p_save from u_p_save within w_a_reg_m_tm2_ori
integer x = 622
integer y = 1668
boolean enabled = false
end type

type p_reset from u_p_reset within w_a_reg_m_tm2_ori
integer x = 1157
integer y = 1668
boolean enabled = false
end type

type tab_1 from u_tab_reg within w_a_reg_m_tm2_ori
event type integer ue_tabpage_retrieve ( long al_master_row,  integer ai_select_tabpage )
event type integer ue_tabpage_update ( integer oldindex,  integer newindex )
integer x = 32
integer y = 804
integer width = 3013
integer height = 840
integer taborder = 30
long backcolor = 29478337
end type

event ue_tabpage_retrieve;Return 0 //이것이 존재하지 않을 경우 자손에서 이 부분에 코딩시 Window쪽으로 이벤트가 형성됨.


end event

event ue_tabpage_update;//****kenn : 1999-05-11 火 *****************************
// Return : -1 Save Error
//           0 Save
//           1 User Abort(Retrieve oldindex)
//           2 System Ignore
//******************************************************
Integer li_return

If oldindex <= 0 Then Return 2
If oldindex = 1 And newindex = 1 Then Return 2
ib_update = True
//If tab_1.ib_tabpage_check[oldindex] Then
	tab_1.idw_tabpage[oldindex].AcceptText()
	If (tab_1.idw_tabpage[oldindex].ModifiedCount() > 0) Or &
		(tab_1.idw_tabpage[oldindex].DeletedCount() > 0) Then
		tab_1.SelectedTab = oldindex
		li_return = MessageBox(Tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]" &
					, "Data is Modified.! Do you want to save?", Question!, YesNo!)
		If li_return <> 1 Then
			ib_update = False
			Return 1
		End If
	Else
		ib_update = False
		Return 2
	End If

	li_return = Trigger Event ue_extra_save(oldindex)
	Choose Case li_return
		Case -2
			//필수항목 미입력
			//tab_1.SelectedTab = oldindex
			//tab_1.idw_tabpage[oldindex].SetFocus()
			ib_update = False
			Return -2
		Case -1
			//ROLLBACK와 동일한 기능
			iu_cust_db_app.is_caller = "ROLLBACK"
			iu_cust_db_app.is_title = tab_1.is_parent_title
			iu_cust_db_app.uf_prc_db()
			If iu_cust_db_app.ii_rc = -1 Then
				ib_update = False
				Return -1
			End If
	
			f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
			ib_update = False
			Return -1
	End Choose

	If tab_1.idw_tabpage[oldindex].Update(True, False) < 0 Then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			ib_update = False
			Return -1
		End If

		f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
		ib_update = False
		Return -1
	End If

	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		ib_update = False
		Return -1
	End If

	tab_1.idw_tabpage[oldindex].ResetUpdate()
	f_msg_info(3000, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
	ib_update = False
	//tab_1.SelectedTab = newindex
//End If

Return 0

end event

event ue_init;call super::ue_init;iw_parent = Parent
end event

event selectionchanged;call super::selectionchanged;Integer li_return
Long ll_selected_row

If ib_update Or ib_no_retrieve Then Return 0
ll_selected_row = dw_master.GetSelectedRow(0)
li_return = Trigger Event ue_tabpage_update(oldindex, newindex)
Choose Case li_return
	Case -2
		tab_1.idw_tabpage[oldindex].SetFocus()
		Return
	Case 1
		//Trigger Event ue_tabpage_retrieve(ll_selected_row, oldindex)
		tab_1.idw_tabpage[oldindex].Reset()
		ib_no_retrieve = True
		tab_1.SelectedTab = newindex
		ib_no_retrieve = False
//	Case 2
//		Return
//	Case 0
End Choose

If ib_retrieve Then
	//If Not tab_1.ib_tabpage_check[newindex] Then
		ll_selected_row = dw_master.GetSelectedRow(0)
		If ll_selected_row > 0 Then
			If Trigger Event ue_tabpage_retrieve(ll_selected_row, newindex) < 0 Then
				Return
			End If
			tab_1.ib_tabpage_check[newindex] = True
		End If
	//End If
End If

end event

