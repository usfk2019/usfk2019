$PBExportHeader$b1w_reg_customertrouble_1.srw
$PBExportComments$[chooys] 고객 민원접수 및 처리_1
forward
global type b1w_reg_customertrouble_1 from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_customertrouble_1 from w_a_reg_m_tm2
integer width = 3346
integer height = 2176
end type
global b1w_reg_customertrouble_1 b1w_reg_customertrouble_1

type variables
Boolean ib_new			//신규 등록  True
String is_check, is_customerid, is_customernm, is_troubletype, is_troublenote, is_troubletype_nm
String is_trouble_note[], is_trouble_sum, is_closeyn
decimal ic_troubleno
DataWindowChild idcA, idcB , idwc_troubletype

end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename)
end prototypes

public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[]);//문자열을 특정구분자(as_cut)로 자른다.
Long ll_rc = 1
Int li_index = 0

as_source = Trim(as_source)
If as_source <> '' Then
	Do While(ll_rc <> 0 )
		li_index ++
		ll_rc = PosA(as_source, as_cut)
		If ll_rc <> 0 Then
			as_result[li_index] = Trim(LeftA(as_source, ll_rc - 1))
		Else
			as_result[li_index] = Trim(as_source)
		End If

		as_source = MidA(as_source, ll_rc + 2)
	Loop
End If

Return li_index
end function

public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename);// 코드별 명붙이기... or select column

CHOOSE CASE as_gu
	CASE "C"
		SELECT customernm
		INTO :as_codename
		FROM customerm
		WHERE customerid = :as_code ;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title,"고객명(wfi_set_codename)")
			Return -2
		End If
		
	CASE "T"
		
//		SELECT codenm
//		INTO :as_codename
//		FROM syscod2t
//		WHERE grcode = 'B330' 
//		  and use_yn = 'Y'
//		  and code = :as_code ;

		SELECT troubletypenm
		INTO :as_codename
		FROM troubletypemst
		WHERE troubletype = :as_code; 
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title,"민원요청(wfi_set_codename)")
			Return -2
		End If
		
	CASE "P"
		SELECT partnernm
		INTO :as_codename
		FROM partnermst
		WHERE partner = :as_code
		  AND act_yn = 'Y';
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title,"수행처(wfi_set_codename)")
			Return -2
		End If

	CASE ELSE
		
END CHOOSE

Return 0
end function

on b1w_reg_customertrouble_1.create
int iCurrent
call super::create
end on

on b1w_reg_customertrouble_1.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_reg_customertrouble
	Desc.	: 고객 민원접수 및 처리
	Ver.	: 1.0
	Date	: 2002.10.01
	Programer : Park Kyung Hae (parkkh)
------------------------------------------------------------------------*/
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
ib_new = False
is_check = ""
end event

event ue_ok();call super::ue_ok;//dw_master 조회
String ls_customerid, ls_partner, ls_temp, ls_result[]
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close
String ls_category, ls_selectcod
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

dw_cond.AcceptText()
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_partner = Trim(dw_cond.object.partner[1])
ls_type = Trim(dw_cond.object.troubletype[1])
ls_category = Trim(dw_cond.object.category[1])
ls_selectcod = Trim(dw_cond.object.selectcod[1])
ls_close = Trim(dw_cond.object.close_yn[1])
ld_todt = dw_cond.object.todt[1]
ld_fromdt = dw_cond.object.fromdt[1]
ls_todt = String(ld_todt, 'yyyymmdd')
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_new  = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then ib_new = True

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
		
		//Retrieve
		ls_where = ""
		IF ls_customerid <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.customerid = '" + ls_customerid + "' "
		End If
		
		IF ls_partner <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.partner = '" + ls_partner + "' "
		End If
		
		IF ls_type <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.troubletype = '" + ls_type + "' "
		End If
		
		IF ls_selectcod <> "" Then 
			IF ls_category <> "" Then 
				If ls_where <> "" Then ls_where += " And "
				CHOOSE CASE ls_selectcod
					CASE "categoryC"
						ls_where += "troubletypeb.troubletypec = '" + ls_category + "' "
					CASE "categoryB"
						ls_where += "troubletypea.troubletypeb = '" + ls_category + "' "
					CASE "categoryA"
						ls_where += "troubletypemst.troubletypea = '" + ls_category + "' "
				END CHOOSE
				
			End If
		End If

		
		//ranger가 확정이 되면
		If ls_fromdt <> ""  and ls_todt <> "" Then
		   ll_row = fi_chk_frto_day(ld_fromdt, ld_todt)
		   If ll_row < 0 Then
			 f_msg_usr_err(211, Title, "접수일자")             //입력 날짜 순저 잘 못 됨
			 dw_cond.SetFocus()
			 dw_cond.SetColumn("fromdt")
			 Return 
		   End If 	
		  If ls_where <> "" Then ls_where += " And "  
		  ls_where += "to_char(customer_trouble.receiptdt, 'YYYYMMDD') >='" + ls_fromdt + "' " + &
						"and to_char(customer_trouble.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' "
					  
		ElseIf ls_fromdt <> "" and ls_todt = "" Then			//시작 날짜만 있을때 
		   If ls_where <> "" Then ls_where += "And "
		   ls_where += "to_char(customer_trouble.receiptdt,'YYYYMMDD') > = '" + ls_fromdt + "' "
		ElseIf ls_fromdt = "" and ls_todt <> "" Then			//끝나는 날짜만 있을때   
			If ls_where <> "" Then ls_where += "And "
		   ls_where += "to_char(customer_trouble.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' " 
		End If
		
		If ls_close <> "" Then
			If ls_where <> "" Then ls_where += "And "
			ls_where += " customer_trouble.closeyn = '" + ls_close + "' "
		End If
		
		dw_master.is_where = ls_where
		ll_row = dw_master.Retrieve()
		
		If ll_row > 0 Then
			ic_troubleno = dw_master.object.customer_trouble_troubleno[1]
			is_customerid = dw_master.object.customer_trouble_customerid[1] 
			is_customernm = dw_master.object.customerm_customernm[1]
			is_troubletype = dw_master.object.customer_trouble_troubletype[1]
			is_troublenote = dw_master.object.customer_trouble_trouble_note[1]
			
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

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert시 조건
Dec lc_troubleno
Dec lc_num
Long ll_master_row, ll_seq , i, ll_row

ll_master_row = dw_master.GetRow()

Choose Case ai_selected_tab
	Case 1								//Tab 1
		Select seq_troubleno.nextval 
		Into :lc_num
		From dual;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select seq_troubleno.nextval")
			RollBack;
			Return -1
		End If				
	   
		tab_1.idw_tabpage[1].object.customer_trouble_troubleno[al_insert_row] = lc_num	//Trouble Num Setting
		tab_1.idw_tabpage[1].object.customer_trouble_receipt_user[al_insert_row] = gs_user_id //접수자
		tab_1.idw_tabpage[1].object.customer_trouble_receiptdt[al_insert_row] = Date(fdt_get_dbserver_now()) //date
		//Log
		tab_1.idw_tabpage[1].object.customer_trouble_crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[1].object.customer_trouble_crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[1].object.customer_trouble_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[1].object.customer_trouble_updt_user[1] = gs_user_id
		tab_1.idw_tabpage[1].object.customer_trouble_updtdt[1] = fdt_get_dbserver_now()
		
	Case 2							   //Tab 2
		
		If ll_master_row = 0 Then Return -1
		lc_troubleno = dw_master.object.customer_trouble_troubleno[ll_master_row]
		
		//Seq Number
		Select nvl(max(seq) + 1, 1) 
		Into :ll_seq
		From troubl_response
		Where troubleno = :lc_troubleno ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Seq")
			RollBack;
			Return -1
		End If				
		
		//Seq 비교 확인
		ll_row = tab_1.idw_tabpage[2].RowCount()
		If ll_row <> 0 Then
			For i = 1 To ll_row
				//seq number 이 같으면
				If ll_seq = tab_1.idw_tabpage[2].object.troubl_response_seq[i] Then
					ll_seq += 1
				End If	
			Next
		End If	
		
		//모든 row 를 삭제하고 다시 insert할때.
//		If al_insert_row = 1 Then
//			tab_1.idw_tabpage[2].object.customer_trouble_troubleno[al_insert_row] = &
//				lc_troubleno
//			tab_1.idw_tabpage[2].object.customer_trouble_troubletype[al_insert_row] = &
//				dw_master.object.customer_trouble_troubletype[ll_master_row]
//			tab_1.idw_tabpage[2].object.customer_trouble_customerid[al_insert_row] = &
//				dw_master.object.customer_trouble_customerid[ll_master_row]
//			tab_1.idw_tabpage[2].object.customer_trouble_note[al_insert_row] = &
//			 	dw_master.object.customer_trouble_note[ll_master_row]
//		End If
			
		tab_1.idw_tabpage[2].object.troubl_response_seq[al_insert_row] = ll_seq  //seq
		tab_1.idw_tabpage[2].object.troubl_response_response_user[al_insert_row] = gs_user_id //처리자
		tab_1.idw_tabpage[2].object.troubl_response_responsedt[al_insert_row] = Date(fdt_get_dbserver_now()) //date
		tab_1.idw_tabpage[2].object.troubl_response_troubleno[al_insert_row] = lc_troubleno
		//Log
		tab_1.idw_tabpage[2].object.troubl_response_crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[2].object.troubl_response_crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[2].object.troubl_response_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[2].object.troubl_response_updt_user[al_insert_row] = gs_user_id	
		tab_1.idw_tabpage[2].object.troubl_response_updtdt[al_insert_row] = fdt_get_dbserver_now()
	
End Choose

Return 0 
end event

event close;call super::close;ib_new = False		//초기화
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("customerid")
tab_1.SelectedTab = 1
ib_new = False
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
Return 0 
end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Dec lc_troubleno
Long ll_master_row, ll_cnt
String ls_receipt_user

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

Choose Case tab_1.SelectedTab
	Case 1						//Tab
		lc_troubleno = dw_master.object.customer_trouble_troubleno[ll_master_row]
		ls_receipt_user = dw_master.object.customer_trouble_receipt_user[ll_master_row]		
		
		If ls_receipt_user <> gs_user_id Then
			f_msg_usr_err(9000, Title, "삭제불가! 접수자만 삭제가능합니다.")  //삭제 안됨 
			Return -1
		End if			
		
		//trouble_shoothing table에 해당 사항이 있으면 삭제 불가능
		Select count(*)
		Into :ll_cnt
		From troubl_response
		Where troubleno = :lc_troubleno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Error")
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, Title, "삭제불가! 민원처리건이 존재합니다.")  //삭제 안됨 
			Return -1
		Else 							
			is_check = "DEL"							   //삭제 가능
		End If
		
End Choose

Return 0 
end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;//Save
Long ll_row
Integer li_rc, ll_i
b1u_check_1  lu_check
lu_check = Create b1u_check_1

//Row 수가 없으면
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

lu_check.is_caller = "b1w_reg_customermtrouble_1%extra_save"
lu_check.is_title    = This.Title
lu_check.ib_data[1]  = ib_new
lu_check.ii_data[1]  = ai_select_tab 								//SelectedTab 
lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]		//Data Window	
lu_check.uf_prc_check()

li_rc = lu_check.ii_rc

If li_rc < 0 Then 
	Destroy lu_check
	Return li_rc
End If

Destroy lu_check

Choose Case ai_select_tab
	Case 1
		//Update Log
		tab_1.idw_tabpage[ai_select_tab].object.customer_trouble_updt_user[1] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.customer_trouble_updtdt[1] = fdt_get_dbserver_now()
		
   Case 2
		//Update Log
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For ll_i = 1 To ll_row
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.troubl_response_updt_user[ll_row] = gs_user_id	
				tab_1.idw_tabpage[ai_select_tab].object.troubl_response_updtdt[ll_row] = fdt_get_dbserver_now()
			End If
	   Next
End Choose

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_payid, ls_shopid, ls_customerid
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
Long ll_row, ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab

If ib_new = True Then					//신규 등록이면		
	ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
	If ll_tab_rowcount < 1 Then Return 0
 	
	 If  li_selectedtab = 1 Then			//Tab 1
	 ls_customerid = tab_1.idw_tabpage[1].Object.customer_trouble_customerid[1]	//조건을 넣고
	 TriggerEvent("ue_reset")
	 dw_cond.object.customerid[1] = ls_customerid
	 dw_cond.object.troubletype[1] = ls_troubletype
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

event type integer ue_insert();//tab2는 맨 마지막에만 insert 되어야 하므로... 조상 스크립트 수정!!

Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)		
		
	Case 2  //tab2는 항상 맨 마지막줄에 insert 시킨다... 
		
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].RowCount() + 1)		
End Choose

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0


end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_customertrouble_1
integer x = 41
integer y = 44
integer width = 2523
integer height = 284
string dataobject = "b1dw_cnd_reg_customeridtrouble_1"
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_codename, ls_closeyn
integer li_rc, li_seltab
datetime ldt_date
li_seltab = tab_1.SelectedTab
Long ll_row
String ls_filter, ls_itemcod
DataWindowChild ldc


Choose Case dwo.name
	Case "customerid"
		
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 li_rc = wfi_set_codename("C", data, ls_codename)
		 If li_rc < 0 then return -2
		 
		 If ls_codename = "" or isnull(ls_codename ) then
//				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_codename
		 
//	Case "partner"
//		
//		 If data = "" then 
//			   This.Object.partnernm[row] = ""
//				This.SetFocus()
//				This.SetColumn("partner")
//				Return -1
// 		 End If		 
//
//		 li_rc = wfi_set_codename("P", data, ls_codename)
//		 If li_rc < 0 then return -2
//		 
//		 If ls_codename = "" or isnull(ls_codename ) then
////				This.Object.partner[row] = ""
//			   This.Object.partnernm[row] = ""
//				This.SetFocus()
//				This.SetColumn("partner")
//				Return 1
//		 End if
//		 
//		 This.Object.partnernm[row] = ls_codename
//		 
	Case "selectcod"
		Choose Case data
			Case "categoryA"         //소분류
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b1dc_dddw_troubletypea")
				Modify("category.dddw.DataColumn='troubletypea_troubletypea'")
				Modify("category.dddw.DisplayColumn='troubletypea_troubletypeanm'")
//				
			Case "categoryB"			//중분류
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b1dc_dddw_troubletypeb")
				Modify("category.dddw.DataColumn='troubletypeb_troubletypeb'")
				Modify("category.dddw.DisplayColumn='troubletypeb_troubletypebnm'")
				 
			Case "categoryC"			//대분류
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b1dc_dddw_troubletypec")
				Modify("category.dddw.DataColumn='troubletypec'")
				Modify("category.dddw.DisplayColumn='troubletypecnm'")
				
			Case else					//분류선택 안했을 경우...
				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''
		End Choose
		
	Case "category"	
		This.object.troubletype[1] = ""
		//해당 priceplan에 대한 itemcod
		ll_row = This.GetChild("troubletype", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = " troubletypea = '" + data + "' OR" + &
		" troubletypea_troubletypeb = '" + data + "' OR" + &
		" troubletypeb_troubletypec = '" + data + "' "
		
	
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve() 
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_customertrouble_1
integer x = 2693
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_customertrouble_1
integer x = 2994
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_customertrouble_1
integer width = 2551
integer height = 344
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_customertrouble_1
integer y = 360
integer width = 3209
integer height = 592
string dataobject = "b1dw_reg_customeridtrouble_m_1"
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.customer_trouble_customerid_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;call super::clicked;Int li_rc, li_return, li_cnt, li_i
String ls_result[], ls_closeyn

//THIS.b_1.Enabled = TRUE

If row > 0 Then
	ic_troubleno = dec(This.object.customer_trouble_troubleno[row])
	is_customerid = This.object.customer_trouble_customerid[row]
	is_customernm = This.object.customerm_customernm[row]
	//tab2에 붙일때... 줄바꾸기해서 붙이기 위해서....
	is_troublenote = This.object.customer_trouble_trouble_note[row]

	is_trouble_note[]	= ls_result[]
	If is_troublenote <> '' Then li_return = wfi_cut_string(is_troublenote,"~r", is_trouble_note[])
	is_trouble_sum = ""			
	If UpperBound(is_trouble_note) >= 5 Then
		For li_cnt = 5 To UpperBound(is_trouble_note)
			 is_trouble_sum += is_trouble_note[li_cnt]				
		Next
	End if
		
	is_troubletype = This.object.customer_trouble_troubletype[row]	
	//troubletype에 맞는 이름 가져오기!!!
	li_rc = wfi_set_codename("T", is_troubletype, is_troubletype_nm)
	If li_rc < 0 then return -2
	 
	//현재 tab2에 focus가 맞춰져 있을때는 text를 붙여준다... 
	If tab_1.Selectedtab = 2 then
		tab_1.idw_tabpage[2].modify("troubleno_t.text = '"+ string(ic_troubleno)+ "'")  //접수번호
		tab_1.idw_tabpage[2].modify("customerid_t.text = '["+ is_customerid + "]'")  //고객번호
		tab_1.idw_tabpage[2].modify("customernm_t.text = '"+ is_customernm + "'")  //고객명
		tab_1.idw_tabpage[2].modify("troubletype_t.text = '"+ is_troubletype_nm + "'")  //고객명
		
		For li_i = 1 To 5
			tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = ''")  //접수내역
		Next

		Choose Case UpperBound(is_trouble_note)
			Case 1 to 4
				
				For li_i = 1 To UpperBound(is_trouble_note)
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = '" + is_trouble_note[li_i] + "'")  //접수내역
				Next
			
			Case Is >= 5
				For li_i = 1 To 4
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) +".text = '"+ is_trouble_note[li_i] + "'")  //접수내역
				Next
				tab_1.idw_tabpage[2].modify("trouble_note_t_5.text = '"+ is_trouble_sum + "'")  //접수내역
				
		End Choose

	End if
End if

Choose Case tab_1.SelectedTab
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		
		If is_closeyn = 'Y' then
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		Else
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		End If
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_customertrouble_1
integer y = 1940
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_customertrouble_1
integer y = 1940
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_customertrouble_1
integer y = 1940
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_customertrouble_1
integer y = 1940
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_customertrouble_1
integer y = 984
integer width = 3209
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 2 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "민원접수"
is_tab_title[2] = "민원처리"

is_dwobject[1] = "b1dw_reg_customertrouble_t1_1"
is_dwobject[2] = "b1dw_reg_customertrouble_t2"

end event

event tab_1::constructor;call super::constructor;//Help Window
idw_tabpage[1].is_help_win[1] = "b1w_hlp_customerm"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.customer_trouble_customerid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

Long ll_row
//중분류
ll_row = tab_1.idw_tabpage[1].GetChild("troubletypea_troubletypeb", idcB)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 1")
//소분류
ll_row = tab_1.idw_tabpage[1].GetChild("troubletypemst_troubletypea", idcA)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 2")

//민원유형
ll_row = tab_1.idw_tabpage[1].GetChild("customer_trouble_troubletype", idwc_troubletype)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 3")

end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;Choose Case adwo_dwo.name
	Case "customer_trouble_customerid"
		If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
			 idw_tabpage[ai_tabpage].Object.customer_trouble_customerid[al_row] = &
			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
			 
			 idw_tabpage[ai_tabpage].Object.customerm_customernm[al_row] = &
			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
			 
		End If
		
//	Case "customer_trouble_partner"
//		If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//			 idw_tabpage[ai_tabpage].Object.customer_trouble_partner[al_row] = &
//			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//			 
//			 idw_tabpage[ai_tabpage].Object.partnermst_partnernm[al_row] = &
//			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//			 
//		End If
		
End Choose
Return 0 
end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Change Event
String ls_codename, ls_closeyn
integer li_rc, li_seltab
datetime ldt_date
li_seltab = tab_1.SelectedTab
Long ll_row
String ls_filter, ls_itemcod



Choose Case li_seltab
	Case 1														//Tab 1
		Choose Case dwo.name
			Case "customer_trouble_customerid"
				
				 li_rc = wfi_set_codename("C", data, ls_codename)
				 If li_rc < 0 then return -2
				 
				 If ls_codename = "" or isnull(ls_codename ) then
						tab_1.idw_tabpage[li_seltab].Object.customer_trouble_customerid[row] = ""
	 				   tab_1.idw_tabpage[li_seltab].Object.customerm_customernm[row] = ""
						tab_1.idw_tabpage[li_seltab].SetFocus()
						tab_1.idw_tabpage[li_seltab].SetColumn("customer_trouble_customerid")
						Return 1
				 End if
				 
				 tab_1.idw_tabpage[li_seltab].Object.customerm_customernm[row] = ls_codename


			Case "customer_trouble_closeyn"

				 If data = "Y" then
						tab_1.idw_tabpage[1].object.customer_trouble_close_user[row] = gs_user_id
						tab_1.idw_tabpage[1].object.customer_trouble_closedt[row] = fdt_get_dbserver_now()
				 ElseIf data = "N" then
						setnull(ldt_date)				 					
						tab_1.idw_tabpage[1].object.customer_trouble_close_user[row] = ""
						tab_1.idw_tabpage[1].object.customer_trouble_closedt[row] = ldt_date
				 End if
				 
			//민원유형 중분류 Filtering
			Case "troubletypeb_troubletypec"
				tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1] = ""
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1] = ""
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				
				ls_filter = "troubletypeb_troubletypec = '" + data + "' "
			   idcB.SetFilter(ls_filter)			//Filter정함
				idcB.Filter()
				idcB.SetTransObject(SQLCA)
				ll_row =idcB.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
			//민원유형 소분류 Filtering
			Case "troubletypea_troubletypeb"
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1] = ""
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				
				ls_filter = "troubletypea_troubletypeb = '" + data + "' "
			
				idcA.SetFilter(ls_filter)			//Filter정함
				idcA.Filter()
				idcA.SetTransObject(SQLCA)
				ll_row =idcA.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
			//민원유형
			Case "troubletypemst_troubletypea"
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				ls_filter = "troubletypea = '" + data + "' "
			   idwc_troubletype.SetFilter(ls_filter)			//Filter정함
				idwc_troubletype.Filter()
				idwc_troubletype.SetTransObject(SQLCA)
				ll_row =idwc_troubletype.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
			
								
	End Choose
End Choose

Return 0 
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Retrieve
String ls_where, ls_troubletypec, ls_troubletypeb, ls_troubletypea,ls_troubletype
String ls_filter
Long ll_row
Dec lc_troubleno
Int li_rc

If al_master_row = 0 Then Return -1		//해당 고객 없음

//trouble number
lc_troubleno = dw_master.object.customer_trouble_troubleno[al_master_row]

Choose Case ai_select_tabpage
	Case 1								//Tab 1
		ls_where = "to_char(customer_trouble.troubleno) = '" + String(lc_troubleno) + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		ls_troubletypec =  tab_1.idw_tabpage[ai_select_tabpage].object.troubletypeb_troubletypec[1]
		ls_troubletypeb =  tab_1.idw_tabpage[ai_select_tabpage].object.troubletypea_troubletypeb[1]
		ls_troubletypea = tab_1.idw_tabpage[ai_select_tabpage].object.troubletypemst_troubletypea[1]
		ls_troubletype = tab_1.idw_tabpage[ai_select_tabpage].object.customer_trouble_troubletype[1]
		
		//Filter
		ls_filter = "troubletypeb_troubletypec = '" + ls_troubletypec + "' "
		idcB.SetFilter(ls_filter)			
		idcB.Filter()
		idcB.SetTransObject(SQLCA)
		ll_row =idcB.Retrieve() 
	
	   ls_filter = "troubletypea_troubletypeb = '" + ls_troubletypeb + "' "
		idcA.SetFilter(ls_filter)			
		idcA.Filter()
		idcA.SetTransObject(SQLCA)
		ll_row =idcA.Retrieve() 
		
		
	   ls_filter = "troubletypea = '" + ls_troubletypea + "' "
		idwc_troubletype.SetFilter(ls_filter)			//Filter정함
		idwc_troubletype.Filter()
		idwc_troubletype.SetTransObject(SQLCA)
		ll_row =idwc_troubletype.Retrieve() 
		
		
	Case 2								//Tab 2
		ls_where = "to_char(troubl_response.troubleno) = '" + String(lc_troubleno) + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		li_rc = wfi_set_codename("T", is_troubletype, is_troubletype_nm)
			If li_rc < 0 then return -2
		
		
		SELECT closeyn
		 INTO :is_closeyn
		FROM customer_trouble
		WHERE troubleno = :lc_troubleno ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.Title,"Select Error(CUSTOMER_TROUBLE)")
			Return -2
		End If
		
		//처리 완료 되었으면 수정 불가능
		If is_closeyn = 'Y' Then
			idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.Protect = 1
			idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.Protect = 1
			idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.BackGround.Color = RGB(255,251,240)
		Else
			idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.Protect = 0
			idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.Protect = 0
			idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.troubl_response_responsedt.BackGround.Color = RGB(108,147,137)
			idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.troubl_response_response_note.BackGround.Color = RGB(108,147,137)
		End If
		
		

End Choose

Return 0 
		
end event

event tab_1::selectionchanging;call super::selectionchanging;//신규 등록이면
If ib_new = TRUE Then Return 1
end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn
ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
	   tab_1.idw_tabpage[newindex].modify("troubleno_t.text = '"+ string(ic_troubleno)+ "'")  //접수번호
	   tab_1.idw_tabpage[newindex].modify("customerid_t.text = '["+ is_customerid + "]'")  //고객번호
	   tab_1.idw_tabpage[newindex].modify("customernm_t.text = '"+ is_customernm + "'")  //고객명
		tab_1.idw_tabpage[newindex].modify("troubletype_t.text = '"+ is_troubletype_nm + "'")  //민원유형
		
		For li_i = 1 To 5
			tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = ''")  //접수내역 전부 "" setting
		Next
		
		Choose Case UpperBound(is_trouble_note)
			Case 1 to 4
				
				For li_i = 1 To UpperBound(is_trouble_note)
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = '" + is_trouble_note[li_i] + "'")  //접수내역
				Next
			
			Case Is >= 5
				For li_i = 1 To 4
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) +".text = '"+ is_trouble_note[li_i] + "'")  //접수내역
				Next
				tab_1.idw_tabpage[2].modify("trouble_note_t_5.text = '"+ is_trouble_sum + "'")  //접수내역
				
		End Choose

		lc_troubleno = dw_master.object.customer_trouble_troubleno[ll_master_row]  //처리완료이면 버튼 disable
		
		SELECT closeyn
		 INTO :is_closeyn
		FROM customer_trouble
		WHERE troubleno = :lc_troubleno ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.Title,"Select Error(CUSTOMER_TROUBLE)")
			Return -2
		End If
		
		If is_closeyn = 'Y' then
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		Else
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		End If
End Choose

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_customertrouble_1
integer y = 952
end type

