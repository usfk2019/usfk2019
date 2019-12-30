$PBExportHeader$b8w_reg_admodel_sams.srw
$PBExportComments$[kem] 장비모델 관리 Window
forward
global type b8w_reg_admodel_sams from w_a_reg_m_tm2
end type
end forward

global type b8w_reg_admodel_sams from w_a_reg_m_tm2
integer width = 2994
end type
global b8w_reg_admodel_sams b8w_reg_admodel_sams

type variables
Boolean 	ib_new		= FALSE	//신규등록 여부
String	is_modelno	= ""	, is_check 
end variables

on b8w_reg_admodel_sams.create
int iCurrent
call super::create
end on

on b8w_reg_admodel_sams.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String 	ls_new

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
	
	//모델번호 생성
	String ls_modelno
	
	SELECT to_char(seq_modelno.nextval)
	INTO :ls_modelno
	FROM dual;
	
	tab_1.idw_tabpage[1].Object.modelno[1] = ls_modelno
	
	//등록일자 입력
	tab_1.idw_tabpage[1].Object.regdt[1] = fdt_get_dbserver_now()
	
	
	Return
//조회
Else
	
	Long		ll_rows
	String	ls_where
	String	ls_item, ls_value
	
	//Condition
	ls_item	= Trim(dw_cond.Object.item[1])
	ls_value	= UPPER(Trim(dw_cond.Object.value[1]))
	
	IF IsNull(ls_item) THEN ls_item = ""
	IF IsNull(ls_value) THEN ls_value = ""
	
	
	//Dynamic SQL
	ls_where = ""
	
	IF ls_item = "modelno" AND ls_value <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "UPPER(modelno) LIKE '%" + ls_value + "%'"
	END IF
	
	IF ls_item = "modelnm" AND ls_value <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "UPPER(modelnm) LIKE '%" + ls_value + "%'"
	END IF
	
	IF ls_item = "makernm" AND ls_value <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "UPPER(makernm) LIKE '%" + ls_value + "%'"
	END IF
	
	//Retrieve
	
	dw_master.is_where = ls_where
	ll_rows = dw_master.Retrieve()
	If ll_rows = 0 Then
		f_msg_info(1000, Title, "")
	ElseIf ll_rows < 0 Then
		f_msg_usr_err(2100, Title, "")
		Return
	Else			
		//검색결과가 있으면 Tab을 활성화 시킨다.
		tab_1.Trigger Event SelectionChanged(1, tab_1.SelectedTab)
		tab_1.Enabled = True
	End If
END IF
end event

event ue_reset;call super::ue_reset;dw_cond.reset()
dw_cond.insertRow(0)

tab_1.SelectedTab = 1

RETURN 0
end event

event open;call super::open;tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(off!)
end event

event ue_save;Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_modelnm
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
	 ls_modelnm = tab_1.idw_tabpage[1].Object.modelnm[1]	//조건을 넣고
	 TriggerEvent("ue_reset")
	 dw_cond.Object.item[1] = 'modelnm'
	 dw_cond.object.value[1] = ls_modelnm
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

//If is_check = "DEL" Then	//Delete 
//	If  li_selectedTab = 1 Then
//		 dw_cond.Reset()
//		 dw_cond.InsertRow(0)
//		 TriggerEvent("ue_ok")
//		 is_check = ""
//	End If
//End If

Return 0
end event

event type integer ue_delete();Long 		ll_cnt
String	ls_modelno

ls_modelno = is_modelno

IF is_modelno = "" THEN
	RETURN -1
END IF

If tab_1.Selectedtab = 1 Then
	//삭제할 모델이 장비마스터(admst)에 등록되어 있으면 삭제할 수 없다.
	SELECT count(*)
	INTO :ll_cnt
	FROM admst
	WHERE modelno = :ls_modelno;
	
	IF ll_cnt > 0 THEN
		MessageBox("삭제불가","장비마스터에 저장된 모델이므로 삭제불가")
		f_msg_info(3010,tab_1.is_parent_title,"Delete")
		RETURN -2
	END IF
	
	// 모델삭제
	DELETE admodel
	WHERE modelno = :ls_modelno;
	
	DELETE admodel_item
	WHERE modelno = :ls_modelno;
	
	
	If  SQLCA.sqlcode < 0 then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			tab_1.idw_tabpage[1].SetFocus()
			f_msg_info(3010,tab_1.is_parent_title,"Delete")
			RETURN -1
		End If
	
		f_msg_info(3010,tab_1.is_parent_title,"Delete")
		RETURN -1
	End If
	
		
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then	//삭제실패
		f_msg_info(3010,tab_1.is_parent_title,"Delete")
		RETURN -1
	End If

	//삭제성공
	f_msg_info(3000,tab_1.is_parent_title,"Delete")

	TriggerEvent("ue_reset")
ElseIf tab_1.Selectedtab = 2 Then
	If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
		tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
		tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
	End if
ElseIf tab_1.Selectedtab = 4 Then
	If tab_1.idw_tabpage[tab_1.Selectedtab].RowCount() > 0 Then
		tab_1.idw_tabpage[tab_1.Selectedtab].DeleteRow(0)
		tab_1.idw_tabpage[tab_1.Selectedtab].SetFocus()
	End if	
End If


RETURN 0
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;String ls_modelno
Long   ll_row

If ai_selected_tab = 1 Then
	tab_1.idw_tabpage[ai_selected_tab].object.sale_amt[al_insert_row] = 0
	
	//Log 정보
	tab_1.idw_tabpage[ai_selected_tab].Object.crt_user[al_insert_row] = gs_user_id
	tab_1.idw_tabpage[ai_selected_tab].Object.crtdt[al_insert_row] 	 = fdt_get_dbserver_now()
	tab_1.idw_tabpage[ai_selected_tab].Object.updt_user[al_insert_row] = gs_user_id
	tab_1.idw_tabpage[ai_selected_tab].Object.updtdt[al_insert_row]	 = fdt_get_dbserver_now()
	tab_1.idw_tabpage[ai_selected_tab].Object.pgm_id[al_insert_row]	 = gs_pgm_id[gi_open_win_no]
	
ElseIf ai_selected_tab = 2 Then
	ll_row = dw_master.GetSelectedRow(0)
	ls_modelno = Trim(dw_master.object.modelno[ll_row])
	
	tab_1.idw_tabpage[ai_selected_tab].object.modelno[al_insert_row] = ls_modelno	
	
	
	//Log 정보
	tab_1.idw_tabpage[ai_selected_tab].Object.crt_user[al_insert_row] = gs_user_id
	tab_1.idw_tabpage[ai_selected_tab].Object.crtdt[al_insert_row] 	 = fdt_get_dbserver_now()
	tab_1.idw_tabpage[ai_selected_tab].Object.updt_user[al_insert_row] = gs_user_id
	tab_1.idw_tabpage[ai_selected_tab].Object.updtdt[al_insert_row]	 = fdt_get_dbserver_now()
	tab_1.idw_tabpage[ai_selected_tab].Object.pgm_id[al_insert_row]	 = gs_pgm_id[gi_open_win_no]
	
ElseIf ai_selected_tab = 4 Then
	ll_row = dw_master.GetSelectedRow(0)
	ls_modelno = Trim(dw_master.object.modelno[ll_row])
	
	tab_1.idw_tabpage[ai_selected_tab].object.modelno[al_insert_row] = ls_modelno	
	tab_1.idw_tabpage[ai_selected_tab].object.fromdt[al_insert_row] = fdt_get_dbserver_now()
	
	
	//Log 정보
	tab_1.idw_tabpage[ai_selected_tab].Object.crt_user[al_insert_row] = gs_user_id
	tab_1.idw_tabpage[ai_selected_tab].Object.crtdt[al_insert_row] 	 = fdt_get_dbserver_now()
	tab_1.idw_tabpage[ai_selected_tab].Object.updt_user[al_insert_row] = gs_user_id
	tab_1.idw_tabpage[ai_selected_tab].Object.updtdt[al_insert_row]	 = fdt_get_dbserver_now()
	tab_1.idw_tabpage[ai_selected_tab].Object.pgm_id[al_insert_row]	 = gs_pgm_id[gi_open_win_no]
	
End If

Return 0
end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;////Save
String ls_sale_amt, ls_itemcod, ls_modelnm, ls_adtype, ls_makercd
Int li_tab_index, li_return, li_row

String ls_sale_item


li_tab_index = tab_1.SelectedTab

tab_1.idw_tabpage[ai_select_tab].AcceptText()

Choose Case ai_select_tab
	Case 1

		//필수 Check
		ls_modelnm  = Trim(tab_1.idw_tabpage[li_tab_index].Object.modelnm[1])	//모델명
		ls_adtype   = Trim(tab_1.idw_tabpage[li_tab_index].Object.adtype[1])	//장비구분
		ls_makercd  = Trim(tab_1.idw_tabpage[li_tab_index].Object.makercd[1])	//제조사
		ls_sale_amt = String(tab_1.idw_tabpage[li_tab_index].Object.sale_amt[1])  //이동기준가
	
		IF IsNull(ls_modelnm) or ls_modelnm = "" THEN
				f_msg_usr_err(200, Title, "모델명")
				tab_1.idw_tabpage[li_tab_index].setColumn("modelnm")
				tab_1.idw_tabpage[li_tab_index].setFocus()
				Return -2
		END IF
		
		IF IsNull(ls_adtype) or ls_adtype = "" THEN
				f_msg_usr_err(200, Title, "장비구분")
				tab_1.idw_tabpage[li_tab_index].setColumn("adtype")
				tab_1.idw_tabpage[li_tab_index].setFocus()
				Return -2
		END IF
		
		IF IsNull(ls_makercd) or ls_makercd = "" THEN
				f_msg_usr_err(200, Title, "제조사")
				tab_1.idw_tabpage[li_tab_index].setColumn("makercd")
				tab_1.idw_tabpage[li_tab_index].setFocus()
				Return -2
		END IF
		
		If IsNull(ls_sale_amt) or ls_sale_amt = "" Then
			f_msg_usr_err(9000, Title, "이동기준가는 0 이상이어야 합니다.")
			tab_1.idw_tabpage[li_tab_index].setColumn("sale_amt")
			tab_1.idw_tabpage[li_tab_index].setFocus()
			Return -2
		End If
	Case 2
		For li_row = 1 To tab_1.idw_tabpage[li_tab_index].RowCount()
			ls_itemcod = Trim(tab_1.idw_tabpage[li_tab_index].Object.itemcod[li_row])
			
			IF IsNull(ls_itemcod) or ls_itemcod = "" THEN
				f_msg_usr_err(200, Title, "품목")
				tab_1.idw_tabpage[li_tab_index].setColumn("itemcod")
				tab_1.idw_tabpage[li_tab_index].setFocus()
				Return -2
			END IF
		Next
		
	Case 4
		For li_row = 1 To tab_1.idw_tabpage[li_tab_index].RowCount()
			ls_sale_item = Trim(tab_1.idw_tabpage[li_tab_index].Object.sale_item[li_row])		
			
			IF IsNull(ls_sale_item) or ls_sale_item = "" THEN
				f_msg_usr_err(200, Title, "판매품목")
				tab_1.idw_tabpage[li_tab_index].setColumn("sale_item")
				tab_1.idw_tabpage[li_tab_index].setFocus()
				Return -2
			END IF

		Next		
End Choose
//
Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b8w_reg_admodel_sams
integer x = 73
integer y = 40
integer width = 2048
integer height = 112
string dataobject = "b8dw_cnd_regadmodel_sams"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b8w_reg_admodel_sams
integer x = 2341
integer y = 44
end type

type p_close from w_a_reg_m_tm2`p_close within b8w_reg_admodel_sams
integer x = 2647
integer y = 44
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b8w_reg_admodel_sams
integer x = 37
integer width = 2149
integer height = 188
end type

type dw_master from w_a_reg_m_tm2`dw_master within b8w_reg_admodel_sams
integer x = 23
integer y = 224
integer width = 2903
integer height = 428
string dataobject = "b8dw_inq_reqadmodel_sams"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.modelnm_t
uf_init( ldwo_sort )

end event

event dw_master::clicked;call super::clicked;//마지막에 선택된 Row로 간다.
tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

end event

type p_insert from w_a_reg_m_tm2`p_insert within b8w_reg_admodel_sams
end type

type p_delete from w_a_reg_m_tm2`p_delete within b8w_reg_admodel_sams
end type

type p_save from w_a_reg_m_tm2`p_save within b8w_reg_admodel_sams
end type

type p_reset from w_a_reg_m_tm2`p_reset within b8w_reg_admodel_sams
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b8w_reg_admodel_sams
integer x = 23
integer y = 700
integer width = 2903
integer height = 956
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 4		//Tab 갯수
//Tab Title
is_tab_title[1] = "Master Info"
is_tab_title[2] = "Item Info"
is_tab_title[3] = "Present Stock "
is_tab_title[4] = "Model Price Info"


//Tab에 해당하는 dw
is_dwObject[1] = "b8dw_reg_admodel_t1_sams"
is_dwObject[2] = "b8dw_reg_admodel_t3_sams"
is_dwObject[3] = "b8dw_reg_admodel_t2_sams"
is_dwObject[4] = "b8dw_reg_admodel_t4_sams"





end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row		
String ls_customerid, ls_payid
Boolean lb_check1, lb_check2

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
   Return 0
End If


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
		
	Case 3	
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")

	Case 4
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
End Choose
Return 0
	
end event

event tab_1::selectionchanging;call super::selectionchanging;//신규 등록이면
IF ib_new = TRUE THEN RETURN 1

end event

event tab_1::ue_tabpage_retrieve;call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_modelno, ls_type, ls_resc
String ls_where
Long ll_row
Int li_tab

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_modelno = Trim(dw_master.object.modelno[al_master_row])

Choose Case li_tab
	Case 1								//Tab 1
		ls_where = "modelno = '" + ls_modelno + "' "
		is_modelno = ls_modelno
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		ls_type = fs_get_control("B5", "H200", ls_resc)
		
		If ls_type = '0' Then
			tab_1.idw_tabpage[li_tab].object.sale_amt.Format = "#,##0"
		ElseIf ls_type = '1' Then
			tab_1.idw_tabpage[li_tab].object.sale_amt.Format = "#,##0.0"
		ElseIf ls_type = '2' Then
			tab_1.idw_tabpage[li_tab].object.sale_amt.Format = "#,##0.00"
		Else
			tab_1.idw_tabpage[li_tab].object.sale_amt.Format = "#,##0.0000"
		End If
		
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		
	Case 2
		ls_where = "modelno = '" + ls_modelno + "' "
		is_modelno = ls_modelno
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		
	Case 3								//Tab 3
		ls_where = "a.mv_partner= b.partner"
		ls_where += " AND a.modelno = '" + ls_modelno + "' "
		is_modelno = ls_modelno
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		//현재시간
		idw_tabpage[li_tab].Object.t_now.Text = String(fdt_get_dbserver_now())
		
		
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		
	Case 4
		ls_where = "modelno = '" + ls_modelno + "' "
		is_modelno = ls_modelno
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		ls_type = fs_get_control("B5", "H200", ls_resc)
		
		If ls_type = '0' Then
			tab_1.idw_tabpage[li_tab].object.in_unitamt.Format = "#,##0"
			tab_1.idw_tabpage[li_tab].object.sale_unitamt.Format = "#,##0"			
		ElseIf ls_type = '1' Then
			tab_1.idw_tabpage[li_tab].object.in_unitamt.Format = "#,##0.0"			
			tab_1.idw_tabpage[li_tab].object.sale_unitamt.Format = "#,##0.0"
		ElseIf ls_type = '2' Then
			tab_1.idw_tabpage[li_tab].object.in_unitamt.Format = "#,##0.00"
			tab_1.idw_tabpage[li_tab].object.sale_unitamt.Format = "#,##0.00"			
		Else
			tab_1.idw_tabpage[li_tab].object.in_unitamt.Format = "#,##0.0000"
			tab_1.idw_tabpage[li_tab].object.sale_unitamt.Format = "#,##0.0000"			
		End If
		
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")		

End Choose


Return 0

end event

event tab_1::ue_dw_buttonclicked;call super::ue_dw_buttonclicked;


Int li_tab

li_tab = ai_tabpage
If al_row = 0 Then Return -1

Choose Case li_tab
	Case 3
		If adwo_dwo.name = 'b_print' then
			tab_1.idw_tabpage[li_tab].print()
		End IF	


End Choose

return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b8w_reg_admodel_sams
integer y = 660
end type

