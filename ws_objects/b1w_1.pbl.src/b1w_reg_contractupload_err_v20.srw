$PBExportHeader$b1w_reg_contractupload_err_v20.srw
$PBExportComments$[jsha] 계약요청재처리
forward
global type b1w_reg_contractupload_err_v20 from w_a_reg_m_tm2
end type
type p_find from u_p_find within b1w_reg_contractupload_err_v20
end type
type cb_1 from commandbutton within b1w_reg_contractupload_err_v20
end type
type dw_cond2 from u_d_help within b1w_reg_contractupload_err_v20
end type
end forward

global type b1w_reg_contractupload_err_v20 from w_a_reg_m_tm2
integer width = 3511
integer height = 2112
event ue_find ( )
event ue_request ( )
p_find p_find
cb_1 cb_1
dw_cond2 dw_cond2
end type
global b1w_reg_contractupload_err_v20 b1w_reg_contractupload_err_v20

event ue_find();String ls_file_code, ls_filename, ls_cond, ls_value
Long ll_row, ll_selected_row
String ls_where
Int li_curtab

dw_cond2.AcceptText()

li_curtab = tab_1.selectedTab
ll_selected_row = dw_master.GetSelectedRow(0)

If ll_selected_row <= 0 Then Return

ls_file_code = fs_snvl(dw_master.Object.fileupload_worklog_file_code[ll_selected_row], "")
ls_filename = fs_snvl(dw_master.Object.fileupload_worklog_filename[ll_selected_row], "")
ls_cond = fs_snvl(dw_cond2.Object.cond[1], "")
ls_value = fs_snvl(dw_cond2.Object.value[1], "")

Choose Case li_curtab
	Case 2
		ls_where = " file_code = '" + ls_file_code + "' "
		ls_where += " AND filename = '" + ls_filename + "' "
		If ls_value <> "" Then
			ls_where += " AND " + ls_cond + " = '" + ls_value + "' "
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_row = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_row = 0 Then
			f_msg_info(1000, This.Title, "")
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, This.Title, "Retrieve()")
		Else
			p_save.TriggerEvent('ue_enable')
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)
	
	Case 3
		ls_where = " file_code = '" + ls_file_code + "' "
		ls_where += " AND filename = '" + ls_filename + "' "
		If ls_value <> "" Then
			ls_where += " AND " + ls_cond + " = '" + ls_value + "' "
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(False)
		tab_1.idw_tabpage[li_curtab].is_where = ls_where
		ll_row = tab_1.idw_tabpage[li_curtab].Retrieve()
		
		If ll_row = 0 Then
			f_msg_info(1000, This.Title, "")
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, This.Title, "Retrieve()")
		End If
		
		tab_1.idw_tabpage[li_curtab].SetRedraw(True)		
		

End Choose
		
end event

event ue_request();Long ll_selected_row, ll_seqno
Int li_curtab, li_rc
String ls_file_code, ls_filename, ls_temp, ls_ref_desc, ls_result[]
b1u_1_dbmgr16_v20 lu_dbmgr

li_curtab = tab_1.selectedTab
//ll_selected_row = tab_1.idw_tabpage[li_curtab].GetSelectedRow(0)
ll_selected_row = dw_master.GetSelectedRow(0)
If ll_selected_row <= 0 Then Return

ll_seqno = dw_master.Object.fileupload_worklog_seqno[ll_selected_row]
ls_file_code = dw_master.Object.fileupload_worklog_file_code[ll_selected_row]
ls_filename = dw_master.Object.fileupload_worklog_filename[ll_selected_row]

ls_temp = fs_get_control("B1", "P331", ls_ref_desc)
li_rc = fi_cut_string(ls_temp, ";", ls_result[])

//**********************************************************//
lu_dbmgr = Create b1u_1_dbmgr16_v20

lu_dbmgr.is_title = This.Title
lu_dbmgr.is_caller = "b1w_reg_contractupload_err_v20%ue_request"
lu_dbmgr.il_data[1] = ll_seqno
lu_dbmgr.is_data[1] = ls_file_Code
lu_dbmgr.is_data[2] = ls_filename
lu_dbmgr.is_data[3] = ls_result[5]

lu_dbmgr.uf_prc_db()
li_rc = lu_dbmgr.ii_rc

Destroy lu_dbmgr
If li_rc < 0 Then
	f_msg_usr_err(9000, This.Title, "미처리Data 재요청 Error")
	Return
Else
	f_msg_info(3000, This.Title, "")
	This.TriggerEvent('ue_ok')
End If

Return
end event

on b1w_reg_contractupload_err_v20.create
int iCurrent
call super::create
this.p_find=create p_find
this.cb_1=create cb_1
this.dw_cond2=create dw_cond2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_find
this.Control[iCurrent+2]=this.cb_1
this.Control[iCurrent+3]=this.dw_cond2
end on

on b1w_reg_contractupload_err_v20.destroy
call super::destroy
destroy(this.p_find)
destroy(this.cb_1)
destroy(this.dw_cond2)
end on

event ue_ok();call super::ue_ok;Long ll_row
Int li_return
String ls_file_code, ls_file_status, ls_status
String ls_where, ls_temp, ls_ref_desc, ls_result[]

ls_temp = fs_get_control("B1", "P320", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result[])

ls_file_code = dw_cond.Object.file_code[1]
ls_file_status = dw_cond.Object.file_status[1]
ls_status = dw_cond.Object.status[1]

If IsNull(ls_file_code) Then ls_file_code = ""
If IsNull(ls_file_status) Then ls_file_status = ""
If IsNull(ls_status) Then ls_status = ""

ls_where = ""
If ls_file_code <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.file_code='" + ls_file_code + "' "
End If
If ls_file_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.file_status='" + ls_file_status + "' "
End If
If ls_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.status='" + ls_status + "' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve(ls_result[1])

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End If

Return
end event

event resize;call super::resize;Int li_index

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	dw_cond2.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space 
	p_find.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	cb_1.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height -125
	Next

	dw_cond2.Y	= newheight - iu_cust_w_resize.ii_button_space 
	p_find.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	cb_1.Y	= newheight - iu_cust_w_resize.ii_button_space_1
End If

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
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
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")
p_find.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")


For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False
Next

dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
tab_1.enabled = True

ib_retrieve = FALSE

Return 0
end event

event open;call super::open;tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_contractupload_err_v20
integer width = 2130
integer height = 244
string dataobject = "b1dw_cnd_reg_contractupload_err_v20"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_contractupload_err_v20
integer x = 2382
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_contractupload_err_v20
integer x = 2683
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_contractupload_err_v20
integer width = 2217
integer height = 300
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_contractupload_err_v20
integer y = 320
integer height = 556
string dataobject = "b1dw_m_reg_contractupload_err_v20"
boolean ib_sort_use = false
end type

event dw_master::ue_init();call super::ue_init;//dwObject ldwo_SORT
//
//ib_sort_use = True
//ldwo_SORT = Object.fileupload_worklog_seqno_t
//uf_init(ldwo_SORT)
//
end event

event dw_master::retrieveend;If rowcount > 0 Then
	SelectRow( 1, True )
	
	ib_retrieve = True
	Tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

	Tab_1.SetFocus()
	//p_save.TriggerEvent('ue_enable')
	p_reset.TriggerEvent('ue_enable')
	//p_insert.TriggerEvent('ue_enable')
	//p_delete.TriggerEvent('ue_enable')

	p_ok.TriggerEvent('ue_disable')
	//p_find.TriggerEvent('ue_enable')
	dw_cond.Enabled =  False
End If

end event

event dw_master::clicked;//Override
Integer li_SelectedTab
Long ll_selected_row
Long ll_old_selected_row
Int li_tab_index,li_rc

String ls_customerid
Boolean lb_check1, lb_check2


ll_old_selected_row = This.GetSelectedRow(0)

Call w_a_m_master`dw_master::clicked

li_SelectedTab = tab_1.SelectedTab
ll_selected_row = This.GetSelectedRow(0)

//Override - w_a_reg_m_tm2

If (tab_1.idw_tabpage[li_SelectedTab].ModifiedCount() > 0) or &
	(tab_1.idw_tabpage[li_SelectedTab].DeletedCount() > 0)	Then

// 확인 메세지 두번 나오는 문제 해결(tab_1)
//	tab_1.SelectedTab = li_tab_index
	li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
		"Do you want to cancel?",Question!,YesNo!)
	If li_rc <> 1 Then
		If ll_selected_row > 0 Then
			SelectRow(ll_selected_row ,FALSE)
		End If
		SelectRow(ll_old_selected_row , TRUE )
		ScrollToRow(ll_old_selected_row)
		tab_1.idw_tabpage[li_SelectedTab].SetFocus()
		Return 
	End If
End If
		
tab_1.idw_tabpage[li_SelectedTab].Reset()
tab_1.ib_tabpage_check[li_SelectedTab] = False

// Button Enable Or Disable
tab_1.Trigger Event SelectionChanged(li_SelectedTab, li_SelectedTab)	

Return 0




end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_contractupload_err_v20
boolean visible = false
integer y = 2020
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_contractupload_err_v20
boolean visible = false
integer y = 2020
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_contractupload_err_v20
integer x = 2007
integer y = 1840
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_contractupload_err_v20
integer x = 2395
integer y = 1840
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_contractupload_err_v20
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3		//Tab 갯수

//Tab Title
is_tab_title[1] = "미처리Error Data"
is_tab_title[2] = "미처리 Data"
is_tab_title[3] = "처리완료 Data"
//is_tab_title[4] = "작업로그"

//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_contractupload_err_t1_v20"
is_dwObject[2] = "b1dw_reg_contractupload_err_t2_v20"
is_dwObject[3] = "b1dw_reg_contractupload_err_t3_v20"
//is_dwObject[4] = "b1dw_reg_contractupload_err_t4_v20"
end event

event tab_1::selectionchanged;call super::selectionchanged;Choose Case newindex
	Case 1
		p_find.TriggerEvent("ue_disable")
		dw_cond2.Visible = False

	Case 2,3
		p_find.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_disable")
		dw_cond2.dataobject = "b1dw_cnd2_reg_contractupload_err_v20"
		dw_cond2.reset()
		dw_cond2.insertRow(0)
		dw_cond2.SetFocus()
		dw_cond2.Visible = True
//	Case 4
//		p_find.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		dw_cond2.Visible = False
End Choose

idw_tabpage[newindex].Visible	 = True		

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;String ls_where, ls_file_code, ls_filename
Long ll_row

If al_master_row = -1 Then Return -1

Choose Case ai_select_tabpage
	Case 1
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
		
		ls_file_code = dw_master.Object.fileupload_worklog_file_code[al_master_row]
		ls_filename = dw_master.Object.fileupload_worklog_filename[al_master_row]
		
		ls_where = " file_code = '" + ls_file_code + "' "
		ls_where += " AND filename = '" + ls_filename + "' "
		
		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
		
		If ll_row = 0 Then
			f_msg_info(1000, Parent.Title, "")
			cb_1.Enabled = False
			//Return 0
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		Else
			p_save.TriggerEvent('ue_enable')
			cb_1.Enabled = True
		End If
		
		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(True)
		
	Case 2
		cb_1.Enabled = False
		
	Case 3
		cb_1.Enabled = False
		
//	Case 4
//		cb_1.Enabled = False
//		
//		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(False)
//		
//		ls_file_code = dw_master.Object.fileupload_worklog_file_code[al_master_row]
//		ls_filename = dw_master.Object.fileupload_worklog_filename[al_master_row]
//		
//		ls_where = " file_code = '" + ls_file_code + "' "
//		ls_where += " AND filename = '" + ls_filename + "' "
//		
//		tab_1.idw_tabpage[ai_select_tabpage].is_where = ls_where
//		ll_row = tab_1.idw_tabpage[ai_select_tabpage].Retrieve()
//		
//		If ll_row = 0 Then
//			f_msg_info(1000, Parent.Title, "")
//			//Return 0
//		ElseIf ll_row < 0 Then
//			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//			Return -1
//		End If
//		
//		tab_1.idw_tabpage[ai_select_tabpage].SetRedraw(True)
		
End Choose

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_contractupload_err_v20
end type

type p_find from u_p_find within b1w_reg_contractupload_err_v20
integer x = 1710
integer y = 1840
boolean bringtotop = true
end type

type cb_1 from commandbutton within b1w_reg_contractupload_err_v20
integer x = 2757
integer y = 1836
integer width = 590
integer height = 112
integer taborder = 50
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
boolean enabled = false
string text = "미처리Data재요청"
end type

event clicked;Parent.TriggerEvent('ue_request')
end event

type dw_cond2 from u_d_help within b1w_reg_contractupload_err_v20
integer x = 27
integer y = 1828
integer width = 1623
integer height = 140
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_cnd2_reg_contractupload_err_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

