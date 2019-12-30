$PBExportHeader$b3w_reg_discount_plan.srw
$PBExportComments$할인유형등록 By 변유신 2002.12.23
forward
global type b3w_reg_discount_plan from w_a_reg_m_tm2
end type
end forward

global type b3w_reg_discount_plan from w_a_reg_m_tm2
integer width = 3296
integer height = 2192
end type
global b3w_reg_discount_plan b3w_reg_discount_plan

type variables
Boolean ib_new			//신규 등록  True
String is_check, is_root
String is_save , is_fgdiscount

end variables

on b3w_reg_discount_plan.create
int iCurrent
call super::create
end on

on b3w_reg_discount_plan.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;
string ls_cdtype,ls_dtapply,ls_fg1,ls_fg2,ls_fgdiscount
string ls_new , ls_where
long ll_row,ll_curRow,ll_i

ll_curRow = dw_master.GetRow()

//MessageBox("ll_curRow",String(ll_curRow))

// 검색조건
ls_cdtype   = trim(dw_cond.Object.nmtype[1])
ls_dtapply  = trim(String(dw_cond.Object.dtapply[1],'yyyymmdd'))
ls_fg1      = trim(dw_cond.Object.fgdiscount[1] )
ls_fg2      = trim(dw_cond.Object.grtype[1])
ls_new      = trim(dw_cond.Object.new[1])

if(LenA(ls_dtapply) = 0) then ls_dtapply = "00000000" 

If ls_new = "Y" Then ib_new = True

If ib_new = True then
    	 
	tab_1.SelectedTab = 1		//Tab 1 Select
	
	p_ok.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
		
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   p_insert.TriggerEvent("Clicked")
	Return
Else
	
	ls_where = ""
	If ls_cdtype <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "discountplan = '" + ls_cdtype + "' "
	End If

	If ls_dtapply <> "" Then
		If ls_where <> "" Then ls_where += " And "
		   ls_where += "to_char(fromdt,'YYYYMMDD') >= '" + ls_dtapply + "' "
	End If
	
	If ls_fg1 <> "" Then
		If ls_where <> "" Then ls_where += " And "
		if ls_fg1 = "A" then
			ls_where += "discount_type in " + "('I','S')" + " "
		else
			ls_where += "discount_type = '" + ls_fg1 + "' "
		end if	
	End If
	
	If ls_fg2 <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += "discount_type2 = '" + ls_fg2 + "' "
	End If         
	
  
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	  
	
	If ll_row = 0 Then 
			f_msg_info(1000, Title, "등록된 할인유형이 없습니다.")

		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return
		Else
			//검색을 찾으면 Tab를 활성화 시킨다.
			tab_1.Trigger Event SelectionChanged(1, 1)
			tab_1.Enabled = True
		End If
   
	
	//Messagebox("rowcount",string(dw_master.Rowcount()) + " = " + string(ll_curRow))
	
	// 수정후 dw_master 재 Retrieve
	if ll_curRow > 0  and dw_master.Rowcount() >= ll_curRow then
		
		ls_cdtype = dw_master.object.discountplan[ll_curRow]		
		ls_where = "discountplan = '" + ls_cdtype + "' "
		tab_1.idw_tabpage[1].is_where = ls_where
		tab_1.idw_tabpage[1].Retrieve()	
		
		dw_master.SelectRow(0,false)
		dw_master.SetRow(ll_curRow)
		dw_master.SelectRow(ll_curRow,true)
		dw_master.ScrollToRow(ll_curRow)
		// <!-- DataWindow 수정 Start --> 
		tab_1.idw_tabpage[1].Modify("trcod.Background.Mode='0'")
		
		ls_fgdiscount = tab_1.idw_tabpage[1].Object.discount_type[1]
		
		if ls_fgdiscount = 'I' then  // 청구할인 일때			
		   
			// 필수항목
			tab_1.idw_tabpage[1].SetTabOrder('trcod',45)
			tab_1.idw_tabpage[1].Modify("trcod.Color='" + String(RGB(255,255,255)) + "'") 
  	      tab_1.idw_tabpage[1].Modify("trcod.Background.Color='" + String(RGB(108,147,137 )) + "'")
						
		else                         // 판매할인 일때
			// Disalble
			tab_1.idw_tabpage[1].SetTabOrder('trcod', 0)
			tab_1.idw_tabpage[1].Modify("trcod.Color='" + String(RGB(0,0,0)) + "'")
			tab_1.idw_tabpage[1].Modify("trcod.Background.Color='" + string(RGB(255, 251, 240)) + "'")
						
   	end if
      // <!-- DataWindow 수정 End --> 
				
	end if	
		  
End If
	
end event

event type integer ue_insert();call super::ue_insert;Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
String ls_fgdiscount
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1
           
		
	Case 2

	
	
End Choose

Return 0
end event

event type integer ue_reset();call super::ue_reset;dataWindowchild dw_chl 
dw_cond.Reset()

dw_cond.GetChild('nmtype',dw_chl)
dw_chl.SetTransObject(sqlca)

dw_chl.Retrieve()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("nmtype")
tab_1.SelectedTab = 1
ib_new = False
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")


Return 0 

end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_nmtype
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



if li_tab_index = 1 then 
   TriggerEvent('ue_ok')
end if



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
		 ls_nmtype = tab_1.idw_tabpage[1].Object.discountplan[1]	//조건을 넣고
		 TriggerEvent("ue_reset")
		 dw_cond.object.nmtype[1] = ls_nmtype
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

If is_check = "DEL" Then	//Delete 
   If  li_selectedTab = 1 Then
		 dw_cond.Reset()
		 dw_cond.InsertRow(0)
		 TriggerEvent("ue_ok")
		 is_check = ""
	End If
End If

Return 0
end event

event open;call super::open;tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)

ib_new = False

dw_cond.Object.fgdiscount[1] = 'A'
end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;//Save

String ls_hprefixno, ls_hprefixno_1, ls_prefixno, ls_sql, ls_credit_yn, ls_bondtype, ls_fromdt, ls_bondamt
Long ll_row, ll_len, ll_len_1, ll_cnt
Integer li_rc, ll_i, li_count, li_return

String ls_cdtype, ls_nmtype, ls_discountTy1, ls_discountTy2, ls_trcod, ls_plevel,ls_fgdiscount
String ls_dtfrom, ls_dtto, ls_dcamt, ls_dcrate
Date   ld_dtfrom, ld_dtto
Dec 	 lc_dcrate, lc_dcamt
long   ll_color

// Empty Row Check
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

Choose Case ai_select_tab
	Case 1 
		// 정보수정자 기록 
		tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()
		
		tab_1.idw_tabpage[ai_select_tab].AcceptText()
		//필수 Check
		ls_discountTy2 = Trim(tab_1.idw_tabpage[ai_select_tab].object.discount_type2[ll_row])
		ls_discountTy1 = Trim(tab_1.idw_tabpage[ai_select_tab].object.discount_type[ll_row])
		ls_trcod       = Trim(tab_1.idw_tabpage[ai_select_tab].object.trcod[ll_row])
		ls_plevel      = Trim(tab_1.idw_tabpage[ai_select_tab].object.plevel[ll_row])
					
		ls_dtfrom	   = Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.fromdt[ll_row],'yyyymmdd'))
		ls_dtto     	= Trim(String(tab_1.idw_tabpage[ai_select_tab].Object.todt[ll_row],'yyyymmdd'))
		lc_dcamt       = tab_1.idw_tabpage[ai_select_tab].Object.dcamt[ll_row]
		lc_dcrate      = tab_1.idw_tabpage[ai_select_tab].Object.dcrate[ll_row]
		ls_nmtype      = Trim(tab_1.idw_tabpage[ai_select_tab].object.discountplannm[ll_row])
		

		If IsNull(ls_discountTy2) Then ls_discountTy2 = ""
		If IsNull(ls_discountTy1) Then ls_discountTy1 = ""
		If IsNull(ls_trcod)       Then ls_trcod = ""
		If IsNull(ls_plevel)      Then ls_plevel = ""
		If IsNull(ls_dtfrom)      Then ls_dtfrom = ""
		If IsNull(ls_dtto)        Then ls_dtto = ""
		If IsNull(ls_nmtype)      Then ls_nmtype = "" 
		
		//실행의 확인 작업
		
		IF lc_dcamt <> 0 AND lc_dcrate <>0 THEN
			li_return = MessageBox(Title, "할인금액과 할인율을 모두 선택하셨습니다. 계속하시겠습니까?", Question!, YesNo!, 1)
		
			If li_return <> 1 Then
				Return -2
			End If
		END IF

		If ls_discountTy2 = "" Then
			f_msg_usr_err(200, title, "할인그룹")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("discount_type2")
			Return -2
		End If

		If ls_discountTy1 = "" Then
			f_msg_usr_err(200, title, "할인구분")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("discount_type")
			Return -2
		End If
		
		// 할인구분이 청구(I) 일 경우 할인발생거래유형 필수
		If ls_discountTy1 = "I" Then 
			
			//tab_1.idw_tabpage[ai_select_tab].Modify("trcod_t.Color='16711680'")
					
			If ls_trcod = "" Then
			f_msg_usr_err(200, title, "할인발생거래유형")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("trcod")
			Return -2
		   End If
		else 
			ll_color = RGB(0, 0, 0)
			tab_1.idw_tabpage[ai_select_tab].Modify("trcod_t.Color=" + string(ll_color) )

		End If	
		
		If ls_plevel = "" Then
			f_msg_usr_err(200, title, "적용우선순위")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("plevel")
			Return -2
		End If
		
		//적용시작일 체크
		IF ls_dtfrom = "" THEN
			f_msg_usr_err(200, Title, "적용시작일")
			tab_1.idw_tabpage[ai_select_tab].setColumn("fromdt")
			tab_1.idw_tabpage[ai_select_tab].setRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].setFocus()
			RETURN -2
		END IF

		//적용종료일 체크
				
		IF ls_dtto <> "" THEN
			If ls_dtfrom > ls_dtto THEN
				f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
				tab_1.idw_tabpage[ai_select_tab].setColumn("todt")
				tab_1.idw_tabpage[ai_select_tab].setRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_row)
				tab_1.idw_tabpage[ai_select_tab].setFocus()
				RETURN -2
			END IF
		END IF
		
		
		
		// 할인율 
		IF lc_dcrate = 0 and lc_dcamt = 0 THEN
			f_msg_usr_err(200, Title, "할인율,할인금액 두값이 0 일순 없습니다.")
			tab_1.idw_tabpage[ai_select_tab].setColumn("dcamt")
			tab_1.idw_tabpage[ai_select_tab].setRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].scrollToRow(ll_row)
			tab_1.idw_tabpage[ai_select_tab].setFocus()
			RETURN -2
		END IF
		
		// <!-- 신규일때 신규코드 생성 Start -->
		If ib_new = True Then	
			
			Select concat('DC',trim(to_char(max(to_number(substr(discountplan,3,3))) + 1,'009'))),count(discountplan)
		   	   into :ls_cdtype,:li_count
			from discount_plan;
		
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, "할인유형코드 생성오류")			
				Return -1
			End If
		 
		 IF li_count = 0 then ls_cdtype = 'DC001'
		 
		 tab_1.idw_tabpage[ai_select_tab].Object.discountplan[ll_row] = ls_cdtype
		 end if	
		// <!-- 신규일때 신규코드 생성 End -->
		

End Choose

Return 0
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;String ls_code 
int li_curRow   

Choose Case ai_selected_tab
	Case 1	
		
		tab_1.idw_tabpage[1].object.discount_type[al_insert_row] = 'S' // 할인구분 Default 판매 
		tab_1.idw_tabpage[1].object.auto_yn[al_insert_row] = 'Y'
		tab_1.idw_tabpage[1].object.edit_yn[al_insert_row] = 'Y'
		tab_1.idw_tabpage[1].Object.fromdt[al_insert_row] = today()
		tab_1.idw_tabpage[1].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[1].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
							  
		tab_1.idw_tabpage[1].SetTabOrder('trcod', 0)
	   tab_1.idw_tabpage[1].Modify("trcod.Color='" + String(RGB(0,0,0)) + "'") 
	   tab_1.idw_tabpage[1].Modify("trcod.Background.Color='" + String(RGB(255, 251, 240)) + "'")
		tab_1.idw_tabpage[1].Object.trcod[al_insert_row] = ''	
		tab_1.tabpage_2.text= "할인대상품목" 			  
	  
				 
	Case 2
				
		li_curRow = dw_master.GetRow()
		ls_code   = dw_master.object.discountplan[li_curRow]
		
   	tab_1.idw_tabpage[2].object.discountplan[al_insert_row] = ls_code
		tab_1.idw_tabpage[2].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[2].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
End Choose		

Return 0 
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b3w_reg_discount_plan
integer x = 41
integer width = 2368
integer height = 212
string dataobject = "b3dw_cnd_reg_discount_plan"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b3w_reg_discount_plan
integer x = 2528
integer y = 44
boolean originalsize = false
end type

type p_close from w_a_reg_m_tm2`p_close within b3w_reg_discount_plan
integer x = 2830
integer y = 44
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b3w_reg_discount_plan
integer x = 27
integer width = 2414
integer height = 284
end type

type dw_master from w_a_reg_m_tm2`dw_master within b3w_reg_discount_plan
integer x = 23
integer y = 296
integer width = 3200
integer height = 528
string dataobject = "b3dw_inq_discount_plan"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.discountplan_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;call super::clicked;Int li_rc, li_return, li_cnt, li_i
String ls_credit_yn, ls_partner, ls_fgdiscount

Choose Case tab_1.SelectedTab
	Case 1
		
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_tm2`p_insert within b3w_reg_discount_plan
integer x = 23
integer y = 1956
end type

type p_delete from w_a_reg_m_tm2`p_delete within b3w_reg_discount_plan
integer x = 315
integer y = 1956
end type

type p_save from w_a_reg_m_tm2`p_save within b3w_reg_discount_plan
integer x = 608
integer y = 1956
end type

type p_reset from w_a_reg_m_tm2`p_reset within b3w_reg_discount_plan
integer y = 1956
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b3w_reg_discount_plan
event ue_enter pbm_dwnprocessenter
integer x = 14
integer y = 868
integer width = 3200
integer height = 1032
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 2 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "유형마스터"
is_tab_title[2] = "할인대상품목"

is_dwobject[1] = "b3dw_reg_discount_plan"
is_dwobject[2] = "b3dw_reg_discount_item"  


end event

event tab_1::selectionchanged;call super::selectionchanged;
//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn, ls_credit_yn
ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

//MessageBox("Event","selectchanged")

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0 


end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;
//Retrieve
String ls_where, ls_cdtype, ls_prefixno, ls_credit_yn,ls_fgdiscount
Long ll_row, ll_curRow
Dec lc_troubleno

If al_master_row = 0 Then Return -1		//해당 Code 없음

Choose Case ai_select_tabpage
	Case 1						//Tab 1
		
		// dw_Master 에 따른 상세조회
		ls_cdtype = dw_master.object.discountplan[al_master_row]		
		ls_where = "discountplan = '" + ls_cdtype + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
     
	   // <!-- DataWindow 수정 Start --> 
		tab_1.idw_tabpage[1].Modify("trcod.Background.Mode='0'")
		
		ls_fgdiscount = this.idw_tabpage[1].Object.discount_type[1]
		
		if ls_fgdiscount = 'I' then  // 청구할인 일때			
		   
			// 필수항목
			tab_1.idw_tabpage[1].SetTabOrder('trcod',45)
			tab_1.idw_tabpage[1].object.trcod.Background.Color = RGB(108,147,137)
			tab_1.idw_tabpage[1].object.trcod.Color = RGB(255,255,255)
		   tab_1.tabpage_2.text= "할인대상거래유형" 
						
		else                         // 판매할인 일때
			// Disalble
			tab_1.idw_tabpage[1].SetTabOrder('trcod', 0)
			tab_1.idw_tabpage[1].object.trcod.Background.Color = RGB(255,251,240)
			tab_1.idw_tabpage[1].object.trcod.Color = RGB(0,0,0)
			tab_1.tabpage_2.text= "할인대상품목" 			
   	end if
      // <!-- DataWindow 수정 End --> 
		
		
	Case 2
				
		ls_cdtype = dw_master.object.discountplan[al_master_row]		
		ls_where = "discountplan = '" + ls_cdtype + "' "
		
		Select discount_type
		Into :ls_fgdiscount
		from discount_plan
		where discountplan = :ls_cdtype;
	
		// <!-- Dynamic Dw -->
		if ls_fgdiscount = 'I' then  // 청구할인 일때		
		   tab_1.idw_tabpage[2].DataObject = 'b3dw_reg_discount_item_i'
			tab_1.idw_tabpage[2].SetTransObject(sqlca)
		else                         // 판매할인 일때
		   tab_1.idw_tabpage[2].DataObject = 'b3dw_reg_discount_item_s'
			tab_1.idw_tabpage[2].SetTransObject(sqlca)
   	end if
		
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
End Choose
		
	


Return 0 

end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Change Event
String ls_codename, ls_closeyn, ls_code
integer li_rc, li_seltab
datetime ldt_date
Long li_exist
String ls_filter , ls_row
String ls_dtfrom, ls_dtto
DataWindowChild ldc_hpartner

li_seltab = tab_1.SelectedTab

Choose Case li_seltab
	Case 1														//Tab 1
		Choose Case dwo.name

			Case "discount_type"
               
					tab_1.idw_tabpage[li_seltab].Modify("trcod.Background.Mode='0'")
                If data = "S"  Then  //품목
					  
					  tab_1.idw_tabpage[li_seltab].SetTabOrder('trcod', 0)
					  tab_1.idw_tabpage[li_seltab].Modify("trcod.Color='" + String(RGB(0,0,0)) + "'") 
			  	     tab_1.idw_tabpage[li_seltab].Modify("trcod.Background.Color='" + String(RGB(255, 251, 240)) + "'")
					  tab_1.idw_tabpage[li_seltab].Object.trcod[row] = ''	
					  
  					  tab_1.tabpage_2.text= "할인대상품목" 
					  				  
					  
		        else 					//거래유형
					  tab_1.idw_tabpage[li_seltab].SetTabOrder('trcod', 45)
					  tab_1.idw_tabpage[li_seltab].Modify("trcod.Color='" + String(RGB(0,0,0)) + "'")
			        tab_1.idw_tabpage[li_seltab].Modify("trcod.Background.Color='" + string(RGB(108,147,137)) + "'")
   				  tab_1.idw_tabpage[li_seltab].title = "할인대상품목"
					  tab_1.tabpage_2.text= "할인대상거래유형"		 
				  End If	
				  
				 is_fgdiscount = data
				  
         Case "fromdt"
				     ls_dtfrom = Trim(String(data,'yyyymmdd'))
		   		     
			Case "todt"
				     ls_dtfrom = Trim(String(tab_1.idw_tabpage[li_seltab].Object.fromdt[row],'yyyymmdd'))
				     ls_dtto = Trim(String(data,'yyyymmdd'))	
	  				  
					  If ls_dtfrom > ls_dtto Then
					   f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
					   tab_1.idw_tabpage[li_seltab].setColumn("todt")
					   tab_1.idw_tabpage[li_seltab].setRow(row)
					   tab_1.idw_tabpage[li_seltab].scrollToRow(row)
					   tab_1.idw_tabpage[li_seltab].setFocus()
					  End if
		   
			End Choose
End Choose

Return 0 
end event

event tab_1::selectionchanging;call super::selectionchanging;//1  Prevent the selection from changing
Long ll_master_row
ll_master_row = dw_master.GetSelectedRow(0)
//신규 등록이면
If ib_new = TRUE Then Return 1
end event

event type integer tab_1::ue_itemerror(long row, dwobject dwo, string data);call super::ue_itemerror;Integer li_seltab

li_seltab = tab_1.SelectedTab
Choose Case li_seltab
	Case 1
		Choose Case dwo.name
			Case "dcamt"
					If IsNull(data) Or data = "" Then tab_1.idw_tabpage[li_seltab].object.dcamt[row] = 0
					Return 1 //Error 메세지 보여주지 않는다.
		  	Case "dcrate"
					If IsNull(data) Or data = "" Then tab_1.idw_tabpage[li_seltab].object.dcrate[row] = 0
					Return 1
		End Choose
End Choose

Return 0 
		
			         			     				
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b3w_reg_discount_plan
integer x = 14
integer y = 828
integer height = 36
end type

