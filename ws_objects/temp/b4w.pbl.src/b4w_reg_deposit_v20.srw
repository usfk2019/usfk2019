$PBExportHeader$b4w_reg_deposit_v20.srw
$PBExportComments$[ohj]납입고객별 서비스별 보증금 관리 v20
forward
global type b4w_reg_deposit_v20 from w_a_reg_m_tm2
end type
end forward

global type b4w_reg_deposit_v20 from w_a_reg_m_tm2
integer width = 3305
integer height = 2116
end type
global b4w_reg_deposit_v20 b4w_reg_deposit_v20

type variables
String  is_check
Boolean ib_new
end variables

forward prototypes
public function integer wfi_get_payid (string as_payid)
end prototypes

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "납입번호(wfi_get_payid)")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

on b4w_reg_deposit_v20.create
int iCurrent
call super::create
end on

on b4w_reg_deposit_v20.destroy
call super::destroy
end on

event open;call super::open;/*-------------------------------------------------------------------------
	Name	:	b4w_reg_deposit_v20
	Desc.	:	납입고객별 서비스별 보증금 관리
	Ver	: 	1.0
	Date	: 	2004.08.24
	Prgromer : Song Eun Mi (ssong)
---------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp, ls_name[]
ib_new = False

tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[5].SetRowFocusIndicator(Off!)

end event

event resize;call super::resize;

CALL w_a_m_master::resize

Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
	Next


	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.Width - 50
	Next
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert
Integer li_rc, li_tab
Long ll_master_row, ll_seq
String ls_svccod, ls_payid
Boolean lb_check1
li_tab = ai_selected_tab


ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row <> 0 Then
	If ll_master_row < 0 Then Return -1
	ls_svccod = Trim(dw_master.object.svccod[ll_master_row])
	ls_payid = Trim(dw_master.object.payid[ll_master_row])
End If

Choose Case li_tab
	Case 1		//Tab 1 고객정보
		
		If ib_new = True Then
		  	
			
				
				//editing
				tab_1.idw_tabpage[li_tab].object.svccod.Protect = 0
				tab_1.idw_tabpage[li_tab].object.svccod.Background.Color = RGB(108,147,137)
				tab_1.idw_tabpage[li_tab].object.svccod.Color = RGB(255,255,255)
				tab_1.idw_tabpage[li_tab].object.payid.protect = 0
				tab_1.idw_tabpage[li_tab].object.payid.Background.Color = RGB(108,147,137)
				tab_1.idw_tabpage[li_tab].object.payid.Color = RGB(255,255,255)
				
				tab_1.idw_tabpage[li_tab].object.payid.Pointer    = "Help!"
				tab_1.idw_tabpage[li_tab].idwo_help_col[1] = tab_1.idw_tabpage[li_tab].Object.payid
				
				//Setting
				tab_1.idw_tabpage[li_tab].object.crt_user[li_tab] = gs_user_id
				tab_1.idw_tabpage[li_tab].object.crtdt[li_tab] = fdt_get_dbserver_now()
				//가입일
		End  If
		
			
			//Log
			tab_1.idw_tabpage[li_tab].object.pgm_id[1] = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[li_tab].object.updt_user[1] = gs_user_id
			tab_1.idw_tabpage[li_tab].object.updtdt[1] = fdt_get_dbserver_now()
			
	Case 2		//Tab 2 
		//Setting
		tab_1.idw_tabpage[li_tab].object.svccod[al_insert_row] = ls_svccod
		tab_1.idw_tabpage[li_tab].object.payid[al_insert_row] = ls_payid
		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = fdt_get_dbserver_now()
		
		Select nvl(max(seq),0) + 1
		Into   :ll_seq
		From   customer_deposit_det
		Where  payid = :ls_payid
		And    svccod = :ls_svccod;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "")
			return -1
			
		ElseIf SQLCA.SQLCode = 100 Then
			ll_seq = 1
			
		End If
		
		tab_1.idw_tabpage[li_tab].object.seq[al_insert_row] = ll_seq
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		
		p_insert.TriggerEvent("ue_enable")		
		
   //2005.09.26 JUEDE 담당자 정보등록 =======================START
	Case 3		//Tab 3
		//Setting
		tab_1.idw_tabpage[li_tab].object.svccod[al_insert_row] = ls_svccod
		tab_1.idw_tabpage[li_tab].object.payid[al_insert_row] = ls_payid
		
		Select nvl(max(seq),0) + 1
		Into   :ll_seq
		From   customer_deposit_contact
		Where  payid = :ls_payid
		And    svccod = :ls_svccod;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, "")
			return -1
			
		ElseIf SQLCA.SQLCode = 100 Then
			ll_seq = 1
			
		End If
		
		tab_1.idw_tabpage[li_tab].object.seq[al_insert_row] = ll_seq
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		
		p_insert.TriggerEvent("ue_enable")		
      //2005.09.26 JUEDE 담당자 정보등록 =======================END
End Choose

Return 0

end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;
b4u_check_v20 lu_check
Integer li_tab, li_rc
Long i, ll_row, ll_rows, ll_master_row, j
String ls_svccod, ls_payid, ls_use_yn, ls_deposit_type, ls_fromdt
Dec ldc_deposit_amt, ldc_deposit_tot

lu_check = Create b4u_check_v20


If tab_1.idw_tabpage[ai_select_tab].RowCount() < 1 Then
	Return 0
End If

tab_1.idw_tabpage[ai_select_tab].AcceptText()


SetPointer(HourGlass!)

Choose Case ai_select_tab
	Case 1		
		ls_svccod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.svccod[1])
		ls_payid  = tab_1.idw_tabpage[ai_select_tab].Object.payid[1]
		ls_use_yn = tab_1.idw_tabpage[ai_select_tab].Object.use_yn[1]
				
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_use_yn) Then ls_use_yn = ""			
			
		If ls_svccod = "" Then
			f_msg_usr_err(200, Title, "서비스")
			tab_1.idw_tabpage[ai_select_tab].SetColumn("svccod")
			tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			Return -2
		End If
		
		If ls_payid = "" Then
			f_msg_usr_err(200, Title, "납입고객")
			tab_1.idw_tabpage[ai_select_tab].SetColumn("payid")
			tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			Return -2
		End If
						
//				If left(ls_auth_method,1) = 'S' Then
//					
//					If ls_validitem2 = "" Then
//						f_msg_info(200, Title, "IP ADDRESS")
//						tab_1.idw_tabpage[ai_select_tab].SetFocus()
//						tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//						tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//						tab_1.idw_tabpage[ai_select_tab].SetColumn("validitem2")
//						Return -2
//					End If		
//					
//				End if
//			
//				If mid(ls_auth_method,7,1) <> 'E' Then
//					
//					If ls_validitem3 = "" Then
//						f_msg_info(200, Title, "H323ID")
//						tab_1.idw_tabpage[ai_select_tab].SetFocus()
//						tab_1.idw_tabpage[ai_select_tab].SetRow(ll_row)
//						tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_row)
//						tab_1.idw_tabpage[ai_select_tab].SetColumn("validitem3")
//						Return -2
//					End If		
//				End if
//				
//				
		If ib_new = True Then
			tab_1.idw_tabpage[ai_select_tab].Object.limit_amt[1] = 0
		End If
		
		If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_row, 0, Primary!) = DataModified! Then
			tab_1.idw_tabpage[ai_select_tab].Object.updt_user[ll_row] = gs_user_id
			tab_1.idw_tabpage[ai_select_tab].Object.updtdt[ll_row] = fdt_get_dbserver_now()
		End If

	Case 2
		lu_check.is_caller = "b4w_reg_deposit_v20%save_tab2"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
		lu_check.uf_prc_check_2()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
		
		//Update Log
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For i = 1 To ll_row
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] = gs_user_id
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[i] = fdt_get_dbserver_now()
			End If
	   Next
		
		ls_payid = tab_1.idw_tabpage[ai_select_tab].Object.payid[ll_row]
		ls_svccod = Trim(tab_1.idw_tabpage[ai_select_tab].Object.svccod[1])
		
		For j = 1 To ll_row
			ldc_deposit_amt = tab_1.idw_tabpage[ai_select_tab].Object.deposit_amt[j]			
			ldc_deposit_tot = ldc_deposit_tot + ldc_deposit_amt
		Next
		
		//Update 추가 보증금총액, 한도잔액
		UPDATE customer_deposit
		   SET deposit_amt = :ldc_deposit_tot
		     , limit_amt   = :ldc_deposit_tot + ADJ_AMT - USE_AMT
		 WHERE payid       = :ls_payid
		   AND SVCCOD      = :ls_svccod   ;
			
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err('보증금관리 상세', '보증금관리 Update CUSTOMER_DEPOSIT')
			RollBack;
			Return -1
		End If

   // 2005.09.26 JUEDE 담당자 정보등록=========START
	Case 3
		lu_check.is_caller = "b4w_reg_deposit_v20%save_tab3"
		lu_check.is_title = Title
		lu_check.ii_data[1] = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
		lu_check.uf_prc_check_2()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
		
		//Update Log
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For i = 1 To ll_row
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.updt_user[i] = gs_user_id
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[i] = fdt_get_dbserver_now()
			End If
	   Next
		
		ls_payid        = tab_1.idw_tabpage[ai_select_tab].Object.payid[ll_row]

		
     // 2005.09.26 JUEDE 담당자 정보등록=========END		
	  
End Choose


Return 0



end event

event ue_ok();call super::ue_ok;String ls_svccod, ls_payid, ls_where, ls_new
Long   ll_row

ls_new = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then 
	ib_new = True
Else
	ib_new = False
End If

//신규 등록
If ib_new Then
	tab_1.SelectedTab = 1		//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.
	Return
	
Else

	ls_svccod = dw_cond.Object.svccod[1]
	ls_payid  = dw_cond.Object.payid[1]
	
	If IsNull(ls_svccod) Then ls_svccod = ""
	If IsNull(ls_payid)  Then ls_payid  = ""
	
	ls_where = ""
	If ls_svccod <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " a.svccod = '" + ls_svccod + "' "
	End If
	
	If ls_payid <> "" Then
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " a.payid = '" + ls_payid + "' "
	End If

	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")	
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")		
		Return
	Else			
		//검색을 찾으면 Tab를 활성화 시킨다.
		tab_1.Trigger Event SelectionChanged(1, 1)
		tab_1.Enabled = True
	End If

End If
end event

event type integer ue_reset();call super::ue_reset;//초기화
Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

li_tab_index = tab_1.SelectedTab

//Reset 문제
If tab_1.ib_tabpage_check[li_tab_index] = True Then
	tab_1.idw_tabpage[li_tab_index].AcceptText() 

	If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
		(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
		
		li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
					,Question!,YesNo!)
		If li_rc <> 1 Then
			Return LI_ERROR
		End If
	End If
End If
	
p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_cond.ReSet()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.InsertRow(0)
dw_cond.SetColumn("svccod")
ib_new = False

Return 0 
end event

event type integer ue_save();//Override
Constant Int LI_ERROR = -1
Int li_tab_index, li_return

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
	Case -3
		//ib_billing = True 	
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

//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

//cuesee
//저장 되어있으므로
String ls_svccod, ls_payid
Int li_rc, li_selectedTab
Long ll_row, ll_tab_rowcount, ll_master_row
Boolean lb_check2

li_selectedTab = tab_1.SelectedTab
If li_selectedTab = 1 Then						//Tab 1
	
	//신규등록
	If ib_new Then
		ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
		If ll_tab_rowcount < 1 Then Return 0
		dw_cond.Reset()
		dw_cond.InsertRow(0)
		ls_svccod = tab_1.idw_tabpage[li_selectedTab].object.svccod[1]
		ls_payid = tab_1.idw_tabpage[li_selectedTab].object.payid[1]
		dw_cond.object.svccod[1] = ls_svccod
		dw_cond.object.payid[1] = ls_payid
		TriggerEvent("ue_ok")
		tab_1.SelectedTab = 2
		ib_new = False
	End If
	
	//청구 정보를 입력하게 한다.	
//	If ib_billing Then						
//		ll_master_row = dw_master.GetSelectedRow(0)
//		If ll_master_row <> 0 Then
//			ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
//			
//			//wfi_get_ctype3(ls_customerid, lb_check1)
//			wfi_get_payid(ls_customerid, lb_check2)
//
//			If Not (lb_check2) Then
//				tab_1.SelectedTab = 2
//				TriggerEvent("ue_insert")
//				p_insert.TriggerEvent("ue_disable") 		
//			End If
//		End If
//	End If
  
ElseIf li_selectedTab = 2 Then	
	
	tab_1.idw_tabpage[2].Reset()
	tab_1.ib_tabpage_check[2] = False
	
	tab_1.Trigger Event SelectionChanged(2, 2)
 
End If

If is_check = "DEL" Then	//Delete 
	If  li_selectedTab = 1 Then
		 TriggerEvent("ue_reset")
		 is_check = ""
	End If
End If

Return 0
end event

event type integer ue_delete();//override
Constant Int LI_ERROR = -1
Long ll_row, ll_exist
Integer li_tab
String ls_rectype


li_tab = tab_1.SelectedTab

If li_tab =1  Then Return 0

If This.Trigger Event ue_extra_delete() < 0 Then
	Return LI_ERROR
End If

If tab_1.idw_tabpage[li_tab].RowCount() > 0 Then
	ll_row = tab_1.idw_tabpage[li_tab].GetRow()
	
   If ll_row <= 0 Then Return 0
		
	tab_1.idw_tabpage[li_tab].DeleteRow(ll_row)
	tab_1.idw_tabpage[li_tab].SetFocus()
		
End if

Return 0

end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b4w_reg_deposit_v20
integer width = 2446
integer height = 164
string dataobject = "b4dw_reg_cnd_deposit_V20"
end type

event dw_cond::doubleclicked;call super::doubleclicked;//Choose Case dwo.Name
//	Case "payid"
//		If iu_cust_help.ib_data[1] Then
//			Object.payid[row] = iu_cust_help.is_data[1]
//			Object.paynm[row] = iu_cust_help.is_data[2]
//		End If

Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.paynm[1] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If
//	Case "customerid"
//		If iu_cust_help.ib_data[1] Then
//			This.Object.customerid[1] = iu_cust_help.is_data2[1]
//			This.Object.customernm[1] = iu_cust_help.is_data2[2]			
//		End If	
End Choose

AcceptText()

Return 0 
		
		
		
		
//	Case "partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.partner[row] = iu_cust_help.is_data[1]
//			Object.partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "settle_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.settle_partner[row] = iu_cust_help.is_data[1]
//			Object.settle_partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "maintain_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.maintain_partner[row] = iu_cust_help.is_data[1]
//			Object.maintain_partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "reg_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.reg_partner[row] = iu_cust_help.is_data[1]
//			Object.reg_partnernm[row] = iu_cust_help.is_data[2]
//		End If
//		
//	Case "sale_partner"
//		If iu_cust_help.ib_data[1] Then
//			Object.sale_partner[row] = iu_cust_help.is_data[1]
//			Object.sale_partnernm[row] = iu_cust_help.is_data[2]
//		End If
		
//End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_payid
int    li_rc

Choose Case Dwo.Name
	Case "payid"
		ls_payid = dw_cond.object.payid[1]
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid)

		If li_rc < 0 Then
			dw_cond.Object.payid[1] = ""
			dw_cond.Object.paynm[1] = ""
			dw_cond.SetColumn("payid")
			return 2
		End IF
End Choose

end event

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.payid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"

end event

type p_ok from w_a_reg_m_tm2`p_ok within b4w_reg_deposit_v20
integer x = 2601
end type

type p_close from w_a_reg_m_tm2`p_close within b4w_reg_deposit_v20
integer x = 2903
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b4w_reg_deposit_v20
integer width = 2478
integer height = 256
end type

type dw_master from w_a_reg_m_tm2`dw_master within b4w_reg_deposit_v20
integer y = 284
integer width = 3154
integer height = 592
string dataobject = "b4dw_reg_master_deposit_V20"
end type

event dw_master::clicked;call super::clicked;Integer li_CurrTab

If row > 0 Then
	tab_1.idw_tabpage[1].Reset()
	li_CurrTab = tab_1.SelectedTab
	tab_1.SelectedTab = 1
Else
	tab_1.idw_tabpage[1].Reset()
End If

Return 0
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.svccod_t
uf_init(ldwo_SORT)

end event

type p_insert from w_a_reg_m_tm2`p_insert within b4w_reg_deposit_v20
end type

type p_delete from w_a_reg_m_tm2`p_delete within b4w_reg_deposit_v20
end type

type p_save from w_a_reg_m_tm2`p_save within b4w_reg_deposit_v20
end type

type p_reset from w_a_reg_m_tm2`p_reset within b4w_reg_deposit_v20
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b4w_reg_deposit_v20
integer width = 3159
end type

event tab_1::constructor;call super::constructor;idw_tabpage[1].is_help_win[1] = "b1w_hlp_payid"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.payid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

end event

event tab_1::selectionchanged;call super::selectionchanged;Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		p_insert.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")

	Case 3
		p_insert.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")	
		
	Case 4
		p_insert.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_disable")	
		
	Case 5
		p_insert.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_disable")			
End Choose


Return 
end event

event tab_1::ue_init();call super::ue_init;ii_enable_max_tab = 5 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "기본정보"  //Tab Page에 들어갈 title
is_tab_title[2] = "보증금상세"
is_tab_title[3] = "담당자정보"
is_tab_title[4] = "사용한도증감처리"
is_tab_title[5] = "한도초과조치이력"



is_dwobject[1] = "b4dw_reg_deposit_t1_v20"  //Tab Page에 해당되는  DataWindow 할당 
is_dwobject[2] = "b4dw_reg_deposit_t2_v20"
is_dwobject[3] = "b4dw_reg_deposit_t3_v20"
is_dwobject[4] = "b4dw_reg_deposit_t4_v20"
is_dwobject[5] = "b4dw_reg_deposit_t5_v20"
end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;Integer li_SelectedTab
Long  ll_master_row
String ls_sysdt, ls_bil_todt, ls_term_status, ls_ref_desc, ls_todt
String ls_payid, ls_payid_1


li_SelectedTab = SelectedTab
ll_master_row = dw_master.GetRow()


Choose Case li_SelectedTab
	Case 1	//기본정보
		If dwo.name = 'payid' Then
						
			SELECT CUSTOMERNM
			INTO   :ls_payid
			FROM   CUSTOMERM
			WHERE  PAYID = :data;
			
			
			idw_tabpage[li_SelectedTab].Object.payid_1[row] = ls_payid
			
		End If
				
		
End Choose

Return 0
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;String ls_where, ls_payid, ls_svccod
Long   ll_row

Choose Case ai_select_tabpage
	Case 1,2,3,4,5	//기본정보, 보증금 상세, 담당자 정보
		ls_payid= String(dw_master.Object.payid[al_master_row])
		ls_svccod = String(dw_master.Object.svccod[al_master_row])
		
		If IsNull(ls_payid) Then ls_payid = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		
		ls_where = ""
		If ls_payid <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += " a.payid = '" + ls_payid + "' "
		End If
		
		If ls_svccod <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += " a.svccod = '" + ls_svccod + "' "
		End If
		
		
		idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve() : " + is_tab_title[ai_select_tabpage])
			Return -1
		ElseIf ll_row = 0 Then
			f_msg_info(1000, Parent.Title, is_tab_title[ai_select_tabpage])
			Return -1
		End If
		
		If ai_select_tabpage = 1 Then
			tab_1.idw_tabpage[ai_select_tabpage].object.svccod.Protect = 1
			tab_1.idw_tabpage[ai_select_tabpage].object.svccod.Background.Color = RGB(255,251,240)
			tab_1.idw_tabpage[ai_select_tabpage].object.svccod.Color = RGB(0,0,0)
			tab_1.idw_tabpage[ai_select_tabpage].object.payid.protect = 1
			tab_1.idw_tabpage[ai_select_tabpage].object.payid.Background.Color = RGB(255,251,240)
			tab_1.idw_tabpage[ai_select_tabpage].object.payid.Color = RGB(0,0,0)
			
			tab_1.idw_tabpage[ai_select_tabpage].object.payid.Pointer    = "Arrow!"
			idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.crt_user
			
		End If
		
		
End Choose
Return 0
		
			
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;String ls_payid
If adwo_dwo.name = 'payid' Then
	If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
		idw_tabpage[ai_tabpage].Object.payid[1] = idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
		idw_tabpage[ai_tabpage].Object.payid_1[1] = idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
	End If
End If

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b4w_reg_deposit_v20
end type

