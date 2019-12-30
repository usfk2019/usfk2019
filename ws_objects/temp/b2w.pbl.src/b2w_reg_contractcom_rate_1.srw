$PBExportHeader$b2w_reg_contractcom_rate_1.srw
$PBExportComments$[islim] 유치/매출/관리커미션 요율 등록
forward
global type b2w_reg_contractcom_rate_1 from w_a_reg_m_tm2
end type
end forward

global type b2w_reg_contractcom_rate_1 from w_a_reg_m_tm2
integer height = 2092
end type
global b2w_reg_contractcom_rate_1 b2w_reg_contractcom_rate_1

on b2w_reg_contractcom_rate_1.create
int iCurrent
call super::create
end on

on b2w_reg_contractcom_rate_1.destroy
call super::destroy
end on

event open;call super::open;//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
end event

event ue_ok();call super::ue_ok;String ls_partner, ls_partnernm, ls_levelcod, ls_prefixno, ls_where
Long ll_row

//특판대리점만 선택(levelcod:100)	
//ls_levelcod = "100"

ls_partner = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_levelcod = Trim(dw_cond.object.levelcod[1])
ls_prefixno = Trim(dw_cond.object.prefixno[1])

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partnernm) Then ls_partnernm = ""
If IsNull(ls_levelcod) Then ls_levelcod = ""
If IsNull(ls_prefixno) Then ls_prefixno = ""

ls_where = ""
If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner like '" + ls_partner + "%'"
End If

If ls_partnernm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partnernm like '" + ls_partnernm + "%'"
End If
If ls_levelcod <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "levelcod = '" + ls_levelcod + "' "
End If
		
If ls_prefixno <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "prefixno like '" + ls_prefixno + "%' "
End If

////특판대리점만 선택
//If ls_where <> "" Then ls_where += " And "
//ls_where += "levelcod = '"  +  ls_levelcod + "'"

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
Else			
	//검색을 찾으면 Tab를 활성화 시킨다.
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
End If
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert
Integer li_tab
Long ll_master_row, ll_seq
String ls_partner, ls_levelcod

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 0 
ls_partner = Trim(dw_master.object.partner[ll_master_row])
ls_levelcod = Trim(dw_master.object.levelcod[ll_master_row])

li_tab = ai_selected_tab
Choose Case li_tab
	Case 1
		//Log 정보
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			
		//자동입력
		Select seq_regcommst.nextval
		Into :ll_seq
		From dual;
		
		tab_1.idw_tabpage[li_tab].object.regseq[al_insert_row] = ll_seq
		tab_1.idw_tabpage[li_tab].object.partner[al_insert_row] = ls_partner
		tab_1.idw_tabpage[li_tab].object.levelcod[al_insert_row] = ls_levelcod
		
		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = fdt_get_dbserver_now()

		tab_1.idw_tabpage[li_tab].SetRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].SetColumn("itemcod")
		
	Case 2
		//Log 정보
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			
		//자동입력
		Select seq_salecommst.nextval
		Into :ll_seq
		From dual;
		
		tab_1.idw_tabpage[li_tab].object.saleseq[al_insert_row] = ll_seq
		tab_1.idw_tabpage[li_tab].object.partner[al_insert_row] = ls_partner
		tab_1.idw_tabpage[li_tab].object.levelcod[al_insert_row] = ls_levelcod
		
		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = fdt_get_dbserver_now()

		tab_1.idw_tabpage[li_tab].SetRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].SetColumn("commplan")
		
	Case 3
		//Log 정보
		tab_1.idw_tabpage[li_tab].object.crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.updt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[li_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			
		//자동입력
		Select seq_maintaincommst.nextval
		Into :ll_seq
		From dual;
		
		tab_1.idw_tabpage[li_tab].object.maintainseq[al_insert_row] = ll_seq
		tab_1.idw_tabpage[li_tab].object.partner[al_insert_row] = ls_partner
		tab_1.idw_tabpage[li_tab].object.levelcod[al_insert_row] = ls_levelcod
		
		tab_1.idw_tabpage[li_tab].object.fromdt[al_insert_row] = fdt_get_dbserver_now()

		tab_1.idw_tabpage[li_tab].SetRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].ScrollToRow(al_insert_row)
		tab_1.idw_tabpage[li_tab].SetColumn("commplan")
End Choose

Return 0 

end event

event ue_extra_save;call super::ue_extra_save;//Save Check
Integer li_rc
Long ll_master_row
String ls_levelcod
b2u_check 		lu_check

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 0 
ls_levelcod = Trim(dw_master.object.levelcod[ll_master_row])

lu_check = Create b2u_check
lu_check.is_caller = "b2w_reg_contractcom_rate%save"
lu_check.is_title = Title
lu_check.ii_data[1] = ai_select_tab
lu_check.is_data[1] = ls_levelcod
lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
lu_check.uf_prc_check()
li_rc = lu_check.ii_rc

//필수 항목 오류
If li_rc < 0 Then
	Destroy lu_check
	Return li_rc
End If

Destroy lu_check
Return 0 
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b2w_reg_contractcom_rate_1
integer y = 44
integer width = 2299
integer height = 228
string dataobject = "b2dw_cnd_reg_contractcom_rate_1"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b2w_reg_contractcom_rate_1
integer x = 2455
integer y = 48
end type

type p_close from w_a_reg_m_tm2`p_close within b2w_reg_contractcom_rate_1
integer x = 2761
integer y = 48
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b2w_reg_contractcom_rate_1
integer width = 2336
integer height = 292
end type

type dw_master from w_a_reg_m_tm2`dw_master within b2w_reg_contractcom_rate_1
integer x = 27
integer y = 316
integer height = 612
string dataobject = "b2dw_inq_contractcom_rate_1"
end type

event dw_master::ue_init;call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.partner_t
uf_init(ldwo_sort)
end event

type p_insert from w_a_reg_m_tm2`p_insert within b2w_reg_contractcom_rate_1
integer y = 1848
end type

type p_delete from w_a_reg_m_tm2`p_delete within b2w_reg_contractcom_rate_1
integer y = 1848
end type

type p_save from w_a_reg_m_tm2`p_save within b2w_reg_contractcom_rate_1
integer y = 1848
end type

type p_reset from w_a_reg_m_tm2`p_reset within b2w_reg_contractcom_rate_1
integer y = 1848
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b2w_reg_contractcom_rate_1
integer x = 23
integer y = 964
integer height = 856
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3		//Tab 갯수
//Tab Title
is_tab_title[1] = "유치수수료"
is_tab_title[2] = "매출수수료"
is_tab_title[3] = "관리수수료"


//Tab에 해당하는 dw
is_dwObject[1] = "b2dw_reg_contractcom_rate_t1_1"
is_dwObject[2] = "b2dw_reg_contractcom_rate_t2_1"
is_dwObject[3] = "b2dw_reg_contractcom_rate_t3_1"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);//Tab Retrieve
String ls_partner, ls_levelcod
String ls_where, ls_filter
Long ll_row, i, ll_rowcount, ll_cnt
Integer li_tab
DataWindowChild ldc



li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_partner = Trim(dw_master.object.partner[al_master_row])
ls_levelcod = Trim(dw_master.object.levelcod[al_master_row])

Choose Case li_tab
	Case 1				//유치 수수료율
		ls_where = "partner = '" + ls_partner + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		ll_rowcount = idw_tabpage[li_tab].RowCount() 
		If ll_rowcount < 0 Then Return 0
		
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		

		//dw_master의 Level보다 작은 것만 가져오게 
		ll_cnt = idw_tabpage[li_tab].GetChild("levelcod", ldc)
		If ll_cnt = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "code >= '" + ls_levelcod + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_cnt =ldc.Retrieve() 
		
		
		//찾았을 경우 적용이 빨리 안되서
		idw_tabpage[li_tab].SetColumn("levelcod")

		
//		For i = 1 To ll_rowcount
//			//Servece/Item
//			ls_svcitem_flag = Trim(idw_tabpage[li_tab].object.svcitem_flag[i])
//			If ls_svcitem_flag = '0' Then
//				idw_tabpage[li_tab].Modify("svcitem.dddw.name=b0dc_dddw_svcmst")
//				idw_tabpage[li_tab].Modify("svcitem.dddw.DataColumn='svccod'")
//				idw_tabpage[li_tab].Modify("svcitem.dddw.DisplayColumn='svcdesc'")
//			Else
//				idw_tabpage[li_tab].Modify("svcitem.dddw.name=b0dc_dddw_item_by_svc")
//				idw_tabpage[li_tab].Modify("svcitem.dddw.DataColumn='itemcod'")
//				idw_tabpage[li_tab].Modify("svcitem.dddw.DisplayColumn='itemnm'")
//			End If
//		Next		

	Case 2				//정산 수수료율
		ls_where = "partner = '" + ls_partner + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		If idw_tabpage[li_tab].RowCount() < 0 Then Return 0
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
	  
	 	//dw_master의 Level보다 작은 것만 가져오게 
		ll_cnt = idw_tabpage[li_tab].GetChild("levelcod", ldc)
		If ll_cnt = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "code >= '" + ls_levelcod + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_cnt =ldc.Retrieve() 

	Case 3				//관리 수수료율
		ls_where = "partner = '" + ls_partner + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		If idw_tabpage[li_tab].RowCount() < 0 Then Return 0
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
	  
	 	//dw_master의 Level보다 작은 것만 가져오게 
		ll_cnt = idw_tabpage[li_tab].GetChild("levelcod", ldc)
		If ll_cnt = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "code >= '" + ls_levelcod + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_cnt =ldc.Retrieve() 
End Choose
Return 0



end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b2w_reg_contractcom_rate_1
integer y = 932
end type

