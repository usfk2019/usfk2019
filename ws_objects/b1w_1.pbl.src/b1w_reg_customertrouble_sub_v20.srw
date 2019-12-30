$PBExportHeader$b1w_reg_customertrouble_sub_v20.srw
$PBExportComments$[jsha] 민원접수 V20
forward
global type b1w_reg_customertrouble_sub_v20 from b1w_reg_customertrouble_v20
end type
end forward

global type b1w_reg_customertrouble_sub_v20 from b1w_reg_customertrouble_v20
integer width = 4311
integer height = 2200
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
end type
global b1w_reg_customertrouble_sub_v20 b1w_reg_customertrouble_sub_v20

type variables
String is_troubleno, is_pgm_id, is_type, is_svccod, is_troubletypec, is_troubletypeb, &
		 is_troubletypea, is_trouble_partner
end variables

on b1w_reg_customertrouble_sub_v20.create
int iCurrent
call super::create
end on

on b1w_reg_customertrouble_sub_v20.destroy
call super::destroy
end on

event open;call super::open;String ls_temp, ls_ref_desc, ls_result[]
Int li_return

p_delete.visible = false
p_save.visible = false

f_center_window(This)

ls_temp = fs_get_control("B5", "U200", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_result[])

iu_cust_msg = Message.PowerObjectParm
//	Type : Query, Insert
is_type = iu_cust_msg.is_data[1]

//	조회인 경우
If is_type = "Query" Then
	is_troubleno = iu_cust_msg.is_data[2]
	is_pgm_id = iu_cust_msg.is_data[3]
Else	//	Insert
	ib_new = True
	is_customerid = iu_cust_msg.is_data[2]
	is_customernm = iu_cust_msg.is_data[3]
	is_svccod = ls_result[1]
	is_troubletypec = ls_result[2]
	is_troubletypeb = ls_result[3]
	is_troubletypea = ls_result[4]
	is_trouble_partner = ls_result[5]
End If

This.TriggerEvent('ue_ok')
end event

event ue_ok();//If dw_cond.AcceptText() < 1 Then
//	//자료에 이상이 있다는 메세지 처리 요망
//	dw_cond.SetFocus()
//	Return
//End If

Int li_tab_index

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False	
Next

ib_retrieve = False

//dw_master 조회
String ls_customerid, ls_partner, ls_temp, ls_result[],ls_modelno, ls_trouble_status
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close, ls_pid, ls_validkey
String ls_category, ls_selectcod
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

//dw_cond.AcceptText()
//ls_customerid = Trim(dw_cond.object.customerid[1])
//ls_partner = Trim(dw_cond.object.partner[1])
//ls_type = Trim(dw_cond.object.troubletype[1])
//ls_category = Trim(dw_cond.object.category[1])
//ls_selectcod = Trim(dw_cond.object.selectcod[1])
//ls_close = Trim(dw_cond.object.close_yn[1])
//ld_todt = dw_cond.object.todt[1]
//ld_fromdt = dw_cond.object.fromdt[1]
//ls_todt = String(ld_todt, 'yyyymmdd')
//ls_fromdt = String(ld_fromdt, 'yyyymmdd')
//ls_new  = Trim(dw_cond.object.new[1])
//If ls_new = "Y" Then ib_new = True
//ls_modelno = Trim(dw_cond.object.model[1])
//ls_trouble_status = Trim(dw_cond.object.trouble_status[1])
//ls_validkey = fs_snvl(Trim(dw_cond.Object.validkey[1]), "")
//ls_pid = fs_snvl(Trim(dw_cond.Object.pid[1]), "")
//
//신규 등록 
If ib_new = True Then
	
	tab_1.SelectedTab = 1		//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   p_insert.TriggerEvent("Clicked")
	
	//	Customerid, Customernm Display
	tab_1.idw_tabpage[1].object.customer_trouble_customerid[1] = is_customerid
	tab_1.idw_tabpage[1].object.customer_trouble_customernm[1] = is_customernm
	tab_1.idw_tabpage[1].object.customer_trouble_svccod[1] = is_svccod
	tab_1.idw_tabpage[1].object.troubletypeb_troubletypec[1] = is_troubletypec
	tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1] = is_troubletypeb
	tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1] = is_troubletypea
	tab_1.idw_tabpage[1].object.customer_trouble_partner[1] = is_trouble_partner
	
	Return
Else
		//Null Check
		If IsNull(ls_customerid) Then ls_customerid = ""
		If IsNull(ls_partner) Then ls_partner = ""
		If IsNull(ls_type) Then ls_type = ""
		If IsNull(ls_category) Then ls_category = ""
		If IsNull(ls_selectcod) Then ls_selectcod = ""
		If IsNull(ls_todt) Then ls_todt = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""
		If IsNull(ls_close) Then ls_close = ""
		If IsNull(ls_modelno) Then ls_modelno = ""
      If IsnUll(ls_trouble_status) Then ls_trouble_status = ""

		
		//Retrieve
		ls_where = ""
		
		If is_troubleno <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.troubleno = '" + is_troubleno + "' "
		End if
	
//		IF ls_customerid <> "" Then 
//			If ls_where <> "" Then ls_where += " And "
//			ls_where += "customer_trouble.customerid = '" + ls_customerid + "' "
//		End If
//		
//		IF ls_partner <> "" Then 
//			If ls_where <> "" Then ls_where += " And "
//			ls_where += "customer_trouble.partner = '" + ls_partner + "' "
//		End If
//		
//		IF ls_type <> "" Then 
//			If ls_where <> "" Then ls_where += " And "
//			ls_where += "customer_trouble.troubletype = '" + ls_type + "' "
//		End If

//		
//		IF ls_selectcod <> "" Then 
//			IF ls_category <> "" Then 
//				If ls_where <> "" Then ls_where += " And "
//				CHOOSE CASE ls_selectcod
//					CASE "categoryC"
//						ls_where += "troubletypeb.troubletypec = '" + ls_category + "' "
//					CASE "categoryB"
//						ls_where += "troubletypea.troubletypeb = '" + ls_category + "' "
//					CASE "categoryA"
//						ls_where += "troubletypemst.troubletypea = '" + ls_category + "' "
//				END CHOOSE
//				
//			End If
//		End If
//      
//			IF ls_modelno <> "" Then 
//			If ls_where <> "" Then ls_where += " And "
//			ls_where += "customer_trouble.modelno = '" + ls_modelno + "' "
//		End If
//		
//		IF ls_trouble_status <> "" Then 
//			If ls_where <> "" Then ls_where += " And "
//			ls_where += "customer_trouble.trouble_status = '" + ls_trouble_status + "' "
//		End If
//		
//		If ls_validkey <> "" Then
//			If ls_where <> "" Then ls_where += " AND "
//			ls_where += "customer_trouble.validkey = '" + ls_validkey + "' "
//		End If
//		
//		If ls_pid <> "" Then
//			If ls_where <> "" Then ls_where += " AND "
//			ls_where += "customer_trouble.pid = '" + ls_pid + "' "
//		End If
//		
//		//ranger가 확정이 되면
//		If ls_fromdt <> ""  and ls_todt <> "" Then
//		   ll_row = fi_chk_frto_day(ld_fromdt, ld_todt)
//		   If ll_row < 0 Then
//			 f_msg_usr_err(211, Title, "접수일자")             //입력 날짜 순저 잘 못 됨
//			 dw_cond.SetFocus()
//			 dw_cond.SetColumn("fromdt")
//			 Return 
//		   End If 	
//		  If ls_where <> "" Then ls_where += " And "  
//		  ls_where += "to_char(customer_trouble.receiptdt, 'YYYYMMDD') >='" + ls_fromdt + "' " + &
//						"and to_char(customer_trouble.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' "
//					  
//		ElseIf ls_fromdt <> "" and ls_todt = "" Then			//시작 날짜만 있을때 
//		   If ls_where <> "" Then ls_where += "And "
//		   ls_where += "to_char(customer_trouble.receiptdt,'YYYYMMDD') > = '" + ls_fromdt + "' "
//		ElseIf ls_fromdt = "" and ls_todt <> "" Then			//끝나는 날짜만 있을때   
//			If ls_where <> "" Then ls_where += "And "
//		   ls_where += "to_char(customer_trouble.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' " 
//		End If
//		
//		If ls_close <> "" Then
//			If ls_where <> "" Then ls_where += "And "
//			ls_where += " customer_trouble.closeyn = '" + ls_close + "' "
//		End If
		
		dw_master.is_where = ls_where
		ll_row = dw_master.Retrieve()
		
		If ll_row > 0 Then
			ic_troubleno = dw_master.object.troubleno[1]
			is_customerid = dw_master.object.customerid[1] 
			is_customernm = dw_master.object.customernm[1]
			is_troubletype = dw_master.object.troubletype[1]
			is_troublenote = dw_master.object.trouble_note[1]
			
			is_trouble_note[] = ls_result[]
			If is_troublenote <> '' Then li_return = wfi_cut_string(is_troublenote,"~r", is_trouble_note[])

			is_trouble_sum = ""			
			If UpperBound(is_trouble_note) >= 5 Then
				For li_cnt = 5 To UpperBound(is_trouble_note)
					 is_trouble_sum += is_trouble_note[li_cnt]				
				Next
			End if
			
			li_rc = wfi_set_codename("T", is_troubletype, is_troubletype_nm)
			If li_rc < 0 then return 
			
		End if
		
		If ll_row = 0 Then 
			f_msg_info(1000, Title, "")
//			//Insert Row
//			ib_new = True
//			tab_1.SelectedTab = 1				//Tab 1 Select
//			p_ok.TriggerEvent("ue_disable")
//			dw_cond.Enabled = False
//			p_delete.TriggerEvent("ue_disable")
//			p_save.TriggerEvent("ue_enable")
//			p_reset.TriggerEvent("ue_enable")
//			tab_1.Enabled = True
//			tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
//			TriggerEvent("ue_insert")			//첫 페이지에 Insert row 한다.
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return
		Else
			//검색을 찾으면 Tab를 활성화 시킨다.
			tab_1.Trigger Event SelectionChanged(1, 1)
			tab_1.Enabled = True
	
		End If
End If

end event

event type integer ue_reset();call super::ue_reset;is_troubleno = ""

Return 0
end event

event resize;call super::resize;If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	
	p_close.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
Else
	

	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1

End If

SetRedraw(False)
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_payid, ls_shopid, ls_customerid, ls_close_yn, ls_trouble_status, ls_partner
Dec lc_troubleno

li_tab_index = tab_1.SelectedTab

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

Long ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab
ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()

//	2번째 Tab이면 처리완료 Customer_Trouble Update
If li_tab_index = 2 Then
	If ll_tab_rowcount > 0 Then
		ls_close_yn = tab_1.idw_tabpage[li_tab_index].object.close_yn[1]
		ls_trouble_status = tab_1.idw_tabpage[li_tab_index].object.status[1]
		ls_partner = tab_1.idw_tabpage[li_tab_index].object.partner[1]
		
		// Update Customer_trouble
		update customer_trouble set closeyn = :ls_close_yn,
				 partner = :ls_partner, trouble_status = :ls_trouble_status
		where troubleno = :ic_troubleno;
		
	  If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Update Error (customer_trouble)")
			Return LI_ERROR
		End If
	End If
	
End If

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

String ls_troubletype
Long ll_row

If ib_new = True Then					//신규 등록이면		
	
	If ll_tab_rowcount < 1 Then Return 0
 	
	 If  li_selectedtab = 1 Then			//Tab 1
	 ls_customerid = tab_1.idw_tabpage[1].Object.customer_trouble_customerid[1]	//조건을 넣고
	 ls_partner = tab_1.idw_tabpage[1].Object.customer_trouble_partner[1]
    is_troubleno = string(tab_1.idw_tabpage[1].Object.customer_trouble_troubleno[1])
//	 TriggerEvent("ue_reset")	 
	 dw_cond.object.customerid[1] = ls_customerid
	 dw_cond.object.troubletype[1] = ls_troubletype
	 dw_cond.Object.partner[1] = ls_partner
	 dw_cond.object.new[1] = "N"
	 ib_new = False	 					//초기화 
	 dw_cond.Enabled = True
	 ll_row = TriggerEvent("ue_ok")		//조회
	 
	 If ll_row < 0 Then 
		f_msg_usr_err(2100,Title, "Retrieve()")
		Return LI_ERROR
	 End If			
	End If
End If

If is_check = "DEL" Then 				//삭제 후
	TriggerEvent("ue_reset")
	is_check = ""
End If

Return 0
end event

type dw_cond from b1w_reg_customertrouble_v20`dw_cond within b1w_reg_customertrouble_sub_v20
boolean visible = false
integer x = 9
integer y = 12
integer height = 36
end type

type p_ok from b1w_reg_customertrouble_v20`p_ok within b1w_reg_customertrouble_sub_v20
boolean visible = false
end type

type p_close from b1w_reg_customertrouble_v20`p_close within b1w_reg_customertrouble_sub_v20
integer x = 741
integer y = 1972
end type

type gb_cond from b1w_reg_customertrouble_v20`gb_cond within b1w_reg_customertrouble_sub_v20
boolean visible = false
end type

type dw_master from b1w_reg_customertrouble_v20`dw_master within b1w_reg_customertrouble_sub_v20
boolean visible = false
integer x = 18
integer y = 16
integer width = 3813
integer height = 36
end type

event dw_master::clicked;call super::clicked;Choose Case tab_1.SelectedTab
	Case 2
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
End Choose
end event

type p_insert from b1w_reg_customertrouble_v20`p_insert within b1w_reg_customertrouble_sub_v20
boolean visible = false
integer y = 1988
end type

type p_delete from b1w_reg_customertrouble_v20`p_delete within b1w_reg_customertrouble_sub_v20
integer x = 23
integer y = 1972
end type

type p_save from b1w_reg_customertrouble_v20`p_save within b1w_reg_customertrouble_sub_v20
integer x = 320
integer y = 1972
end type

type p_reset from b1w_reg_customertrouble_v20`p_reset within b1w_reg_customertrouble_sub_v20
boolean visible = false
integer y = 1988
end type

type tab_1 from b1w_reg_customertrouble_v20`tab_1 within b1w_reg_customertrouble_sub_v20
integer x = 9
integer y = 48
integer width = 4265
integer height = 1888
integer selectedtab = 2
end type

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;

Choose Case ai_select_tabpage
	Case 1
		tab_1.idw_tabpage[1].object.customer_trouble_country.Protect = 1
		tab_1.idw_tabpage[1].object.customer_trouble_country.border = 0
		tab_1.idw_tabpage[1].object.customer_trouble_country.Background.Color = RGB(255,251,240)
		tab_1.idw_tabpage[1].object.customer_trouble_country.Color = RGB(0, 0, 0)
		
		tab_1.idw_tabpage[1].object.customer_trouble_sacnum.Protect = 1
		tab_1.idw_tabpage[1].object.customer_trouble_sacnum.border = 0
		tab_1.idw_tabpage[1].object.customer_trouble_sacnum.Background.Color = RGB(255,251,240)
		tab_1.idw_tabpage[1].object.customer_trouble_sacnum.Color = RGB(0, 0, 0)
		
		tab_1.idw_tabpage[1].object.customer_trouble_callforwardno.Protect = 1
		tab_1.idw_tabpage[1].object.customer_trouble_callforwardno.border = 0
		tab_1.idw_tabpage[1].object.customer_trouble_callforwardno.Background.Color = RGB(255,251,240)
		tab_1.idw_tabpage[1].object.customer_trouble_callforwardno.Color = RGB(0, 0, 0)
		
		tab_1.idw_tabpage[1].object.customer_trouble_pid.Protect = 1
		tab_1.idw_tabpage[1].object.customer_trouble_pid.border = 0
		tab_1.idw_tabpage[1].object.customer_trouble_pid.Background.Color = RGB(255,251,240)
		tab_1.idw_tabpage[1].object.customer_trouble_pid.Color = RGB(0, 0, 0)
		
		tab_1.idw_tabpage[1].object.customer_trouble_validkey.Protect = 1
		tab_1.idw_tabpage[1].object.customer_trouble_validkey.border = 0
		tab_1.idw_tabpage[1].object.customer_trouble_validkey.Background.Color = RGB(255,251,240)
		tab_1.idw_tabpage[1].object.customer_trouble_validkey.Color = RGB(0, 0, 0)
		
		tab_1.idw_tabpage[1].object.customer_trouble_sendno.Protect = 1
		tab_1.idw_tabpage[1].object.customer_trouble_sendno.border = 0
		tab_1.idw_tabpage[1].object.customer_trouble_sendno.Background.Color = RGB(255,251,240)
		tab_1.idw_tabpage[1].object.customer_trouble_sendno.Color = RGB(0, 0, 0)
		//start-2006.01.13 민원접수 텝수정으로 인한 주석처리 
//		tab_1.idw_tabpage[1].object.customer_trouble_phone.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_phone.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_phone.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_phone.Color = RGB(0, 0, 0)
		
//		tab_1.idw_tabpage[1].object.customer_trouble_closeyn.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_closeyn.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_closeyn.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_closeyn.Color = RGB(0, 0, 0)

//		tab_1.idw_tabpage[1].object.customer_trouble_restype.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_restype.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_restype.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_restype.Color = RGB(0, 0, 0)
		
//		tab_1.idw_tabpage[1].object.customer_trouble_inid.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_inid.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_inid.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_inid.Color = RGB(0, 0, 0)
//		
//		tab_1.idw_tabpage[1].object.customer_trouble_inid_after.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_inid_after.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_inid_after.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_inid_after.Color = RGB(0, 0, 0)
//		
//		tab_1.idw_tabpage[1].object.customer_trouble_outid.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_outid.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_outid.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_outid.Color = RGB(0, 0, 0)
//		
//		tab_1.idw_tabpage[1].object.customer_trouble_outid_after.Protect = 1
//		tab_1.idw_tabpage[1].object.customer_trouble_outid_after.border = 0
//		tab_1.idw_tabpage[1].object.customer_trouble_outid_after.Background.Color = RGB(255,251,240)
//		tab_1.idw_tabpage[1].object.customer_trouble_outid_after.Color = RGB(0, 0, 0)
		//end
		
	Case 2
		idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.Protect = 1
		idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.Protect = 1
		idw_tabpage[ai_select_tabpage].object.troubl_response_response_note2.Protect = 1
		idw_tabpage[ai_select_tabpage].object.troubl_response_trouble_status.Protect = 1
		idw_tabpage[ai_select_tabpage].object.partner.Protect = 1
		idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.Color = RGB(0,0,0)
		idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.BackGround.Color = RGB(255,251,240)
		idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.Color = RGB(0,0,0)
		idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.BackGround.Color = RGB(255,251,240)
		idw_tabpage[ai_select_tabpage].object.troubl_response_response_note2.Color = RGB(0,0,0)
		idw_tabpage[ai_select_tabpage].object.troubl_response_response_note2.BackGround.Color = RGB(255,251,240)
		idw_tabpage[ai_select_tabpage].object.troubl_response_trouble_status.Color = RGB(0,0,0)
		idw_tabpage[ai_select_tabpage].object.troubl_response_trouble_status.BackGround.Color = RGB(255,251,240)
   	idw_tabpage[ai_select_tabpage].object.partner.Color = RGB(0,0,0)
		idw_tabpage[ai_select_tabpage].object.partner.BackGround.Color = RGB(255,251,240)
		
		tab_1.idw_tabpage[ai_select_tabpage].modify("trouble_note_t_1.text = '" + is_troublenote + "'")
		
End Choose

Return 0
end event

event tab_1::selectionchanged;call super::selectionchanged;
Choose Case newindex
	Case 2

		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
End Choose

Return 0
end event

type st_horizontal from b1w_reg_customertrouble_v20`st_horizontal within b1w_reg_customertrouble_sub_v20
integer x = 14
integer y = 12
end type

type uo_1 from b1w_reg_customertrouble_v20`uo_1 within b1w_reg_customertrouble_sub_v20
end type

