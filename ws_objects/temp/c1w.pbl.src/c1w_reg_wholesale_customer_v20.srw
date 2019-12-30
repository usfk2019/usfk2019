$PBExportHeader$c1w_reg_wholesale_customer_v20.srw
$PBExportComments$[ohj] 홀세일사업자 등록 v20
forward
global type c1w_reg_wholesale_customer_v20 from w_a_reg_m_tm2
end type
end forward

global type c1w_reg_wholesale_customer_v20 from w_a_reg_m_tm2
integer width = 3191
integer height = 1964
end type
global c1w_reg_wholesale_customer_v20 c1w_reg_wholesale_customer_v20

type variables
Boolean ib_new
String is_check, is_term, is_svctype_in, is_svctype_out, is_method[]
end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename)
public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[])
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
		
		SELECT codenm
		INTO :as_codename
		FROM syscod2t
		WHERE grcode = 'B330' 
		  and use_yn = 'Y'
		  and code = :as_code ;
		
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

public function integer wfl_get_arezoncod (string as_zoncod, ref string as_arezoncod[]);Long ll_rows
String ls_zoncod

If as_zoncod = "" Then as_zoncod = "%"
ll_rows = 0

DECLARE cur_get_arezoncod CURSOR FOR
SELECT distinct zoncod
FROM arezoncod2
WHERE zoncod like :as_zoncod;

If SQLCA.sqlcode < 0 Then
	f_msg_sql_err(Title, ":CURSOR cur_get_arezoncod")
	Return -1
End If

OPEN cur_get_arezoncod;
Do While(True)
	FETCH cur_get_arezoncod
	INTO :ls_zoncod;
			
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(Title, ":cur_get_arezoncod")
		CLOSE cur_get_arezoncod;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	ll_rows += 1
	as_arezoncod[ll_rows] = ls_zoncod
	
Loop
CLOSE cur_get_arezoncod;

Return ll_rows
end function

on c1w_reg_wholesale_customer_v20.create
int iCurrent
call super::create
end on

on c1w_reg_wholesale_customer_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: c1w_reg_carrier_mst_naray
	Desc.	: 회선사업자 정산 - naray old virsion
	Ver.	: 1.0
	Date	: 2005.11.03
	Programer : Song Eun Mi
------------------------------------------------------------------------*/
String ls_ref_desc, ls_temp
// 손가락 모양 없애기.
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)

is_term        = fs_get_control("B0", "P201", ls_ref_desc)//해지상태 '99'
is_svctype_in  = fs_get_control("B0", "P108", ls_ref_desc)//입중계서비스	3
is_svctype_out = fs_get_control("B0", "P109", ls_ref_desc)//출중계서비스	4
//마감주기방식 d;m  daily; monthly
ls_temp = ""
ls_temp = fs_get_control("C1", "C230", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_method[])

   
end event

event type integer ue_delete();call super::ue_delete;is_check = "DEL"

Return 0
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;Long ll_row
ll_row = dw_master.GetRow()

Choose Case ai_selected_tab
	Case 1
		If ib_new Then
			tab_1.idw_tabpage[ai_selected_tab].object.carrierid.Protect = 0
			tab_1.idw_tabpage[ai_selected_tab].object.carrierid.Background.color = RGB(0, 128, 128)
			tab_1.idw_tabpage[ai_selected_tab].object.carrierid.color = RGB(255, 255, 255)
			
			//Setting
			tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()			//등록일자
			tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
			tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[ai_selected_tab].object.updt_user[al_insert_row] = gs_user_id	
			tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
		End If
	Case 2
		tab_1.idw_tabpage[ai_selected_tab].object.carrierid[al_insert_row] = dw_master.object.carrierid[ll_row]
      tab_1.idw_tabpage[ai_selected_tab].object.carriertype[al_insert_row] = dw_master.object.carriertype[ll_row]		
		tab_1.idw_tabpage[ai_selected_tab].object.fromdt[al_insert_row] = Date(fdt_get_dbserver_now())
End Choose

Return 0
end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;String ls_customerid, ls_customernm, ls_customertype, ls_settle_method, ls_cycle_method, ls_sacnum
Long ll_row, ll_rowcount, ll_i, ll_cycle_qty, ll_adj_hour 

ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()

If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getRow()

Choose Case ai_select_tab
	Case 1
		//Update Log
		
		tab_1.idw_tabpage[ai_select_tab].AcceptText()
		
		ls_customerid    = Trim(tab_1.idw_tabpage[ai_select_tab].object.customerid[ll_row])
		ls_customernm    = Trim(tab_1.idw_tabpage[ai_select_tab].object.customernm[ll_row])
		ls_customertype  = Trim(tab_1.idw_tabpage[ai_select_tab].object.customer_type[ll_row])
		ls_settle_method = Trim(tab_1.idw_tabpage[ai_select_tab].object.settle_method[ll_row])
		ll_adj_hour      = tab_1.idw_tabpage[ai_select_tab].object.adj_hour[ll_row]
		ls_cycle_method  = Trim(tab_1.idw_tabpage[ai_select_tab].object.cycle_method[ll_row])
		ll_cycle_qty     = tab_1.idw_tabpage[ai_select_tab].object.cycle_qty[ll_row]
		ls_sacnum        = Trim(tab_1.idw_tabpage[ai_select_tab].object.sacnum[ll_row])
		
		If IsNull(ls_customerid)    Then ls_customerid = ""
		If IsNull(ls_customernm)    Then ls_customernm = ""
		If IsNull(ls_customertype)  Then ls_customertype = ""
		If IsNull(ls_settle_method) Then ls_settle_method = ""
	//	If IsNull(ll_adj_hour)      Then ll_adj_hour = 0
		If IsNull(ls_cycle_method)  Then ls_cycle_method = ""
		If IsNull(ll_cycle_qty)     Then ll_cycle_qty = 0
		If IsNull(ls_sacnum)        Then ls_sacnum = ""
		
		If ls_customerid = "" Then
			f_msg_usr_err(200, title, "사업자ID")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("customerid")
			Return -2
		End If
		
		If ls_customernm = "" Then
			f_msg_usr_err(200, title, "사업자명")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("customernm")
			Return -2
		End If
		
		If ls_customertype = "" Then
			f_msg_usr_err(200, title, "사업자유형")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("customer_type")
			Return -2
		End If
		
		If ls_sacnum = "" Then
			f_msg_usr_err(200, title, "SAC")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("sacnum")
			Return -2
		End If
		
      If ls_settle_method = "" Then
			f_msg_usr_err(200, title, "정산방법")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("settle_method")
			Return -2
		End If
		
		If isnull(ll_adj_hour) Or LenA(string(ll_adj_hour)) = 0  Then
			f_msg_usr_err(200, title, "정산조정시간")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("adj_hour")
			Return -2
		End If
		
		If ls_cycle_method = "" Then
			f_msg_usr_err(200, title, "마감주기방식")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("cycle_method")
			Return -2
		End If
		
		If ll_cycle_qty = 0 Then
			f_msg_usr_err(200, title, "마감주기")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("cycle_qty")
			Return -2
		End If		
		
	Case else
		return 0
End Choose

Return 0
end event

event ue_ok();call super::ue_ok;String ls_where, ls_new, ls_customerid, ls_customernm
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_customernm = Trim(dw_cond.object.customernm[1])

If IsNull(ls_customerid) Then ls_customerid = ""
IF IsNull(ls_customernm) Then ls_customernm = ""

ls_where = ""

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND " 
	ls_where += " a.customerid = '" + ls_customerid + "' "
End If

IF ls_customernm <> "" Then
	IF ls_where <> "" Then ls_where += " AND "
	ls_where += " customernm LIKE '%" + ls_customernm + "%' "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve(is_term, is_svctype_in, is_svctype_out)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
Elseif ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
Else 
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
End If

p_insert.TriggerEvent('ue_disable')
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("customerid")

tab_1.SelectedTab = 1

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")

Return 0 
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_carrierid
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

//String ls_troubletype
//Long ll_row, ll_tab_rowcount
//Integer li_selectedTab
//li_selectedtab = tab_1.SelectedTab

//
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

type dw_cond from w_a_reg_m_tm2`dw_cond within c1w_reg_wholesale_customer_v20
integer x = 96
integer y = 76
integer width = 2190
integer height = 140
string dataobject = "c1dw_cnd_reg_wholesale_customer_v20"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within c1w_reg_wholesale_customer_v20
integer x = 2519
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_tm2`p_close within c1w_reg_wholesale_customer_v20
integer x = 2821
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within c1w_reg_wholesale_customer_v20
integer width = 2391
integer height = 244
end type

type dw_master from w_a_reg_m_tm2`dw_master within c1w_reg_wholesale_customer_v20
integer x = 0
integer y = 316
integer width = 3118
integer height = 492
string dataobject = "c1dw_reg_wholesale_customer"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.customerid_t
uf_init(ldwo_SORT)
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


//Long ll_selected_row,ll_old_selected_row
//Int li_tab_index,li_rc
//
//ll_old_selected_row = This.GetSelectedRow(0)
//
//CALL u_d_sort::Clicked
//
///* u_d_sgl_sel::Clicked script
////if clicked outside of row return 
////if clicked selected row that must be not selected 
////if clicked not selected row that must be selected */
//
//If row = 0 then Return
//
//If IsSelected( row ) then
//	SelectRow( row ,FALSE)
//Else
//   SelectRow(0, FALSE )
//	SelectRow( row , TRUE )
//End If
//
//If row > 0 Then
//	ll_selected_row = This.GetSelectedRow(0)
//
//	If ll_old_selected_row > 0 Then
//		For li_tab_index = 1 To tab_1.ii_enable_max_tab
//			If tab_1.ib_tabpage_check[li_tab_index] = True Then
//				tab_1.idw_tabpage[li_tab_index].AcceptText() 
//	
//				If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
//					(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
//					tab_1.SelectedTab = li_tab_index
//					li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.!" + &
//						"Do you want to cancel?",Question!,YesNo!)
//					If li_rc <> 1 Then
//						If ll_selected_row > 0 Then
//							SelectRow(ll_selected_row ,FALSE)
//						End If
//						SelectRow(ll_old_selected_row , TRUE )
//						ScrollToRow(ll_old_selected_row)
//						tab_1.idw_tabpage[li_tab_index].SetFocus()
//						Return 
//					End If
//				End If
//			End If	
//		Next
//	End If
//		
//	For li_tab_index = 1 To tab_1.ii_enable_max_tab
//		tab_1.idw_tabpage[li_tab_index].Reset()
//		tab_1.ib_tabpage_check[li_tab_index] = False
//	Next
//		
//	If ll_selected_row > 0 Then
//		p_insert.TriggerEvent('ue_enable') 
//		p_delete.TriggerEvent('ue_enable')
//		p_save.TriggerEvent('ue_enable')
//		p_reset.TriggerEvent('ue_enable')
//		tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)		
//		tab_1.enabled = true
//		tab_1.idw_tabpage[Tab_1.SelectedTab].SetFocus()
//	Else		
//		p_insert.TriggerEvent('ue_disable')
//		p_delete.TriggerEvent('ue_disable')
//		p_save.TriggerEvent('ue_disable')
//		p_reset.TriggerEvent('ue_disable')
//		tab_1.enabled = false
//	End If
//End If
end event

type p_insert from w_a_reg_m_tm2`p_insert within c1w_reg_wholesale_customer_v20
integer y = 1724
end type

type p_delete from w_a_reg_m_tm2`p_delete within c1w_reg_wholesale_customer_v20
integer y = 1724
end type

type p_save from w_a_reg_m_tm2`p_save within c1w_reg_wholesale_customer_v20
integer y = 1724
end type

type p_reset from w_a_reg_m_tm2`p_reset within c1w_reg_wholesale_customer_v20
integer y = 1724
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within c1w_reg_wholesale_customer_v20
integer x = 9
integer y = 804
integer width = 3109
integer height = 888
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;ii_enable_max_tab = 3

//Tab Title
is_tab_title[1] = "홀세일사업자정보"
is_tab_title[2] = "인증Key정보"
is_tab_title[3] = "매출마감Log"

is_dwObject[1] = "c1dw_reg_wholesale_customer_t1_v20"
is_dwObject[2] = "c1dw_reg_wholesale_customer_t2_v20"
is_dwObject[3] = "c1dw_reg_wholesale_customer_t3_v20"
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;//Choose Case ai_tabpage
//	Case 1
//		Choose Case adwo_dwo.name
//			Case "zipcod"
//				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//				End If
//		End Choose
//End Choose
//
Return 0
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;String ls_where, ls_carrierid, ls_customerid, ls_customernm, ls_svccod, ls_filter
Long ll_row, li_rc

DataWindowChild ldwc_sacnum

If al_master_row = 0 Then Return -1	

Choose Case ai_select_tabpage
	Case 1
		ls_customerid = dw_master.object.customerid[al_master_row]
		ls_customernm = dw_master.object.customernm[al_master_row]
		ls_where = "a.customerid = '" + ls_customerid + "' "
		
		idw_tabpage[ai_select_tabpage].is_where = ls_where
		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then
			idw_tabpage[ai_select_tabpage].reset()
			idw_tabpage[ai_select_tabpage].insertrow(0)
			idw_tabpage[ai_select_tabpage].Object.customerid[1] = ls_customerid
			idw_tabpage[ai_select_tabpage].Object.customernm[1] =	ls_customernm 	
			idw_tabpage[ai_select_tabpage].SetItemStatus(1, 0, Primary!, NotModified!)
		End If
		
		ls_svccod = dw_master.object.svccod[al_master_row] 
		
		li_rc = idw_tabpage[ai_select_tabpage].GetChild("sacnum", ldwc_sacnum)
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "GetChild : sacnum")
			Return -1
		End If
		
		ls_filter = "svccod = '" + ls_svccod + "' "
		ldwc_sacnum.SetFilter(ls_filter)
		ldwc_sacnum.Filter()
		
		ldwc_sacnum.SetTransObject(SQLCA)
		
		li_rc = ldwc_sacnum.Retrieve()
		If li_rc < 0 Then
			f_msg_usr_err(9000, Parent.Title, "sacnum Retrieve()")
			Return -1
		End If	

//		// 사업자 ID 수정불가
//		tab_1.idw_tabpage[ai_select_tabpage].object.carrierid.Protect = 1
//		tab_1.idw_tabpage[ai_select_tabpage].object.carrierid.Background.Color = RGB(255, 251, 240)
//		tab_1.idw_tabpage[ai_select_tabpage].object.carrierid.Color = RGB(0, 0, 0)
		
	Case 2
		ls_customerid = dw_master.object.customerid[al_master_row]
		
		ls_where = " a.customerid = '" + ls_customerid + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()		
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
	Case 3
		ls_customerid = dw_master.object.customerid[al_master_row]
		
		ls_where = " customerid = '" + ls_customerid + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()		
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
End Choose
	
Return 0
		
		
end event

event tab_1::selectionchanged;call super::selectionchanged;//TabPage를 선택하였을때 버튼의 활성화.
Long ll_master_row
ll_master_row = dw_master.GetSelectedRow(0)

If ll_master_row < 0 Then Return

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
	Case 2
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")	
	Case 3
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
End Choose

Return 0
end event

event tab_1::constructor;call super::constructor;//idw_tabpage[1].is_help_win[1] = "w_hlp_post"
//idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.zipcod
//idw_tabpage[1].is_data[1] = "CloseWithReturn"
end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;////Item Changed
//Boolean lb_check1, lb_check2
//String ls_data , ls_ctype2, ls_filter, ls_svctype, ls_opendt, ls_prefixno
//String  ls_payid, ls_customerid, ls_munitsec, ls_card_type, ls_card_group
//Integer li_exist, li_exist1, li_rc
//
//DataWindowChild ldc_priceplan
//b1u_check	lu_check
//lu_check = Create b1u_check
//
//Choose Case tab_1.SelectedTab
//	Case 1		//Tab 1
		
//	 Choose Case dwo.name
//		Case "cycle_qty"
//			If data <> 0 Then
//				
//			End If
//			 //납입자 정보 바꿀 시
//		   Case "payid"
//			  ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
//			  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
//			  If li_exist > 0 Then 
//				 f_msg_usr_err(404, title, "")
//				 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
//				 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
//				 Return 2
//			 End If
//			 
//			Case "partner"				
//				select prefixno
//				  into :ls_prefixno
//				  from partnermst
//				 where partner = :data
//				   and partner_type = '0';
//					
//				tab_1.idw_tabpage[1].Object.partner_prefix[1] =	ls_prefixno	 
//		   //sms 수신여부
//		   Case "sms_yn"
//			  If data = 'Y' Then 
//				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(255,255,255)		
//				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(108, 147, 137)
//   			  Else
//				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(0,0,0)				
//				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(255,255,255)
//			  End If
//
//		   //email 수신여부
//		   Case "email_yn"
//			  If data = 'Y' Then 
//				  tab_1.idw_tabpage[1].Object.email1.Color = RGB(255,255,255)		
//				  tab_1.idw_tabpage[1].Object.email1.Background.Color = RGB(108, 147, 137)
//   			  Else
//				  tab_1.idw_tabpage[1].Object.email1.Color = RGB(0,0,0)				
//				  tab_1.idw_tabpage[1].Object.email1.Background.Color = RGB(255,255,255)
//			  End If
//			 
//			 
//			Case "ctype2"
//				If lb_check1 Then		//개인이면 주민등록 번호 필수
//					tab_1.idw_tabpage[1].Object.ssno.Color = RGB(255,255,255)		
//					tab_1.idw_tabpage[1].Object.ssno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@@@@-@@@@@@@"
//					tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.customernm[row]
//					tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.ssno[row]
//				Else
//					tab_1.idw_tabpage[1].Object.ssno.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.ssno.Background.Color = RGB(255, 255, 255)
//				End If	
//				
//				If lb_check2 Then		//법인이면 사업장 정보 필수
//					tab_1.idw_tabpage[1].Object.corpnm.Color = RGB(255, 255, 255)			
//					tab_1.idw_tabpage[1].Object.corpnm.Background.Color = RGB(108, 147, 137)
//					
//					//법인등록번호 필수아님 20050725 ohj
//					tab_1.idw_tabpage[1].Object.corpno.Color = RGB(0, 0, 0)			
//					tab_1.idw_tabpage[1].Object.corpno.Background.Color = RGB(255, 255, 255)
//					
//					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(255, 255, 255)	
//					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[1].Object.representative.Color = RGB(255, 255, 255)		
//					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(255, 255, 255)	
//					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[1].Object.businessitem.Color = RGB(255, 255, 255)
//					tab_1.idw_tabpage[1].Object.businessitem.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.cregno[row]
//					tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@-@@-@@@@@"
//				   Choose Case dwo.name
//						Case "corpnm"
//					   	tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.cprpnm[row]
//						Case "cregno"
//							tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.cregno[row]
//							tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@-@@-@@@@@"
//						Case "businesstype"
//							tab_1.idw_tabpage[1].object.holder_type[row] = tab_1.idw_tabpage[1].object.businesstype[row]
//						Case "businessitem"
//							tab_1.idw_tabpage[1].object.holder_item[row] = tab_1.idw_tabpage[1].object.businessitem[row]
//					End Choose
//				Else
//					tab_1.idw_tabpage[1].Object.corpnm.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.corpnm.Background.Color = RGB(255, 255, 255)
//					tab_1.idw_tabpage[1].Object.corpno.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.corpno.Background.Color = RGB(255, 255, 255)
//					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(255, 255, 255)
//
//					tab_1.idw_tabpage[1].Object.representative.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(255, 255, 255)
//					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(255, 255, 255)
//					tab_1.idw_tabpage[1].Object.businessitem.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.businessitem.Background.Color = RGB(255, 255, 255)
//
//				End If
//			Case "addrtype"
//					tab_1.idw_tabpage[1].object.holder_addrtype[row] = data
//			Case "zipcod"
//					tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
//			Case "addr1"
//					tab_1.idw_tabpage[1].object.holder_addr1[row] = data
//			Case "addr2"
//					tab_1.idw_tabpage[1].object.holder_addr2[row] = data
//		  End Choose
//		  
//		  //개인이면
//		  If lb_check1 Then
//				Choose Case dwo.name
//					Case "customernm"
//						tab_1.idw_tabpage[1].object.holder[row] = data
//					Case "zipcode" 
//						tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
//					Case "ssno"
//						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
//				End Choose
//			ElseIf lb_check2 Then		//법인이면
//				Choose Case dwo.name
//					Case "corpnm"
//					   tab_1.idw_tabpage[1].object.holder[row] = data
//					Case "cregno"
//						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
//						tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@-@@-@@@@@"
//					Case "businesstype"
//						tab_1.idw_tabpage[1].object.holder_type[row] = data
//					Case "businessitem"
//						tab_1.idw_tabpage[1].object.holder_item[row] = data
//				End Choose
//			End If
//		
//	Case 2		//Tab
//		Choose Case dwo.name
//			Case "inv_method"
//				If is_inv_method = Trim(data) Then
//					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(255, 255, 255)		
//					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(108, 147, 137)
//				Else
//					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(255, 255, 255)
//				End If
//			
//			Case "card_no"
//				If is_card_prefix_yn = 'Y' Then
//					SELECT CARD_TYPE
//					  INTO :ls_card_type
//					  FROM CARDPREFIX  
//					 WHERE CARDPREFIX = (SELECT MAX(CARDPREFIX)
//												  FROM CARDPREFIX  
//												 WHERE :data LIKE CARDPREFIX ||'%' );
//												 
//					If sqlca.sqlcode < 0 Then
//						f_msg_sql_err(Title, "SELECT ERROR CARDPREFIX")
//						Return -1
//					ElseIf sqlca.sqlcode = 100 Then
//						f_msg_info(9000, title, "신용카드번호[" + data +"]의 prefix가 존재하지 않습니다.")	
//						tab_1.idw_tabpage[2].setcolumn("card_no")
//						Return -1
//					Else
//						tab_1.idw_tabpage[2].object.card_type[1] = ls_card_type
//					End If							
//				End If
//			Case "card_remark1"
//				If is_card_prefix_yn = 'Y' Then
//					SELECT card_group 
//					  INTO :ls_card_group
//					  FROM CARDREMARK
//					 WHERE CARD_REMARK = :data ;
//					 
//					If sqlca.sqlcode < 0 Then
//						f_msg_sql_err(Title, "SELECT ERROR CARDREMARK")
//						Return -1
//					ElseIf sqlca.sqlcode = 100 Then
//						f_msg_info(9000, title, "신용카드유형[" + data +"]가 존재하지 않습니다.")	
//						tab_1.idw_tabpage[2].setcolumn("card_remark1")
//						Return -1
//					Else
//						tab_1.idw_tabpage[2].object.card_group1[1] = ls_card_group
//					End If
//					 
//				End If
//			 Case "billinginfo_currency_type"
//				 
//				 ls_payid = tab_1.idw_tabpage[2].object.customerid[1]		//Pay ID
//				 
//				 Select count(customerid) into :li_exist from customerm where customerid <> payid and payid = :ls_payid;
//				 Select count(customerid) into :li_exist1 From svcorder where customerid = :ls_payid;
//				 If li_exist > 0  Or li_exist1 > 0 Then 
//					f_msg_usr_err(404, title, "") 
//					//다시 원복 한다.
//					tab_1.idw_tabpage[2].object.billinginfo_currency_type[1] = is_currency_old
//					tab_1.idw_tabpage[2].SetitemStatus(1, "billinginfo_currency_type", Primary!, NotModified!)   //수정 안되었다고 인식.
//					Return 2
//				 End If
//			
//			Case "pay_method"
//				Choose case is_pay_method_ori     //변경전데이타
//					case is_method    			  //자동이체
//						If Trim(data) <> is_pay_method_ori Then   //변경된데이타: 자동이체가 아닌경우
//							If is_drawingresult_ori = is_drawingresult[4] Then   //변경전 신청결과가 처리성공인경우
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			   //신청일자:sysdate
//								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[4]         //신청유형:해지
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]     //신청결과:미처리
//								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod              //신청접수처:이용이관
//							Else
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			   //신청일자:sysdate
//								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[1]		   //신청유형:없음
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[1]	   //신청결과:없음
//								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			   //신청접수처:이용기관
//							End If
//						Elseif Trim(data) = is_pay_method_ori Then      //자동이체 -> 지로, 기타 -> 자동이체 일경우가 존재 할 수 있기 때문에...원래대로 setting
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori
//								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
//								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori
//								tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori
//								tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori	
//								tab_1.idw_tabpage[2].Object.bank[1] = is_bank_ori
//								tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_ori
//								tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_ori
//								tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_ori
//    					End IF
//					case else    //변경전데이타가 자동이체가 아닌경우
//						If Trim(data) = is_method Then      //변경한 데이타가 자동이체인 경우
//						    //지로/카드->자동이체로 변경시 해지 미처리일때 는  자동이체의 신규 처리성공으로 셋팅...
//							If is_drawingtype_ori = is_drawingtype[4] and is_drawingresult_ori = is_drawingresult[2] Then
//								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[2]		//신청유형:신규
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[4]	//신청결과:처리성공
//							Else
//								ls_ctype2 = Trim(tab_1.idw_tabpage[2].Object.customerm_ctype2[1])
//								b1fb_check_control("B0", "P111", "", ls_ctype2,lb_check1)
//								b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			//신청일자:sysdate
//								tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[2]		//신청유형:신규
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
//								tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			//접수처:이용기관
//								If lb_check1 Then //개인이면 주민등록 번호 필수
//									tab_1.idw_tabpage[2].object.acct_ssno[1] = tab_1.idw_tabpage[2].Object.customerm_ssno[1]
//								End If	
//								If lb_check2 Then //법인이면 사업장 정보 필수					
//									tab_1.idw_tabpage[2].object.acct_ssno[1] = tab_1.idw_tabpage[2].Object.customerm_cregno[1]
//								End If
//							End If
//					    Else
//							tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori
//							tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori
//							tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
//							tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori
//							tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori
//							tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori								
//    					End IF
//				End Choose
//				
//				lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
//				lu_check.is_title    = Title
//				lu_check.ii_data[1]  = tab_1.SelectedTab
//				lu_check.is_data[1] = is_method
//				lu_check.is_data[2] = is_credit
//				lu_check.is_data[3] = is_inv_method
//				lu_check.is_data[4] = is_chg_flag
//				lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
//				lu_check.uf_prc_check_11()
//				li_rc = lu_check.ii_rc
//				If li_rc < 0 Then 
//					Destroy lu_check
//					Return li_rc
//				End If				
//
//			Case "bank_chg"			
//				If data = 'Y' Then
//					tab_1.idw_tabpage[2].Object.bank.Color = RGB(255, 255, 255)		
//					tab_1.idw_tabpage[2].Object.bank.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.acctno.Color = RGB(255, 255, 255)	
//					tab_1.idw_tabpage[2].Object.acctno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.acct_owner.Color = RGB(255, 255, 255)			
//					tab_1.idw_tabpage[2].Object.acct_owner.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.acct_ssno.Color = RGB(255, 255, 255)			
//					tab_1.idw_tabpage[2].Object.acct_ssno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[2].Object.bank.Protect =0
//					tab_1.idw_tabpage[2].Object.acctno.Protect = 0
//					tab_1.idw_tabpage[2].Object.acct_owner.Protect =0
//					tab_1.idw_tabpage[2].Object.acct_ssno.Protect =0
//					tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			//신청일자:sysdate
//					tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[3]		//신청유형:변경
//					tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
//					tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			//접수처:이용기관
//				Else
//					If is_bank_chg_ori = 'Y' Then
//						tab_1.idw_tabpage[2].Object.bank[1] = is_bank_bef				        //은행:before
//						tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_bef					//계좌번호:before
//						tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_bef 			//계좌명:before
//						tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_bef				//계좌주민번호:before
//						tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_bef		//신청일자:before
//						tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_bef 		//신청유형:before
//						tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_bef 	//신청결과:before
//						tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_bef			//접수처:before
//						tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_bef 	        //신청접수일자:before
//						tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_bef			    //신청결과코드:before
//					Else
//						tab_1.idw_tabpage[2].Object.bank[1] = is_bank_ori					    //은행:origin
//						tab_1.idw_tabpage[2].Object.acctno[1] = is_acctno_ori 					//계좌번호:origin
//						tab_1.idw_tabpage[2].Object.acct_owner[1] = is_acct_owner_ori 			//계좌명:origin
//						tab_1.idw_tabpage[2].Object.acct_ssno[1] = is_acct_ssno_ori				//계좌주민번호:origin
//						tab_1.idw_tabpage[2].Object.drawingreqdt[1] = id_drawingreqdt_ori		//신청일자:origin
//						
//						tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype_ori 		//신청유형:origin
//						tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori 	//신청결과:origin
//						tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod_ori			//접수처:origin
//						tab_1.idw_tabpage[2].Object.receiptdt[1] = id_receiptdt_ori 	        //신청접수일자:origin
//						tab_1.idw_tabpage[2].Object.resultcod[1] = is_resultcod_ori			    //신청결과코드:origin
//					End If
//					lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
//					lu_check.is_title    = Title
//					lu_check.ii_data[1]  = tab_1.SelectedTab
//					lu_check.is_data[1] = is_method
//					lu_check.is_data[2] = is_credit
//					lu_check.is_data[3] = is_inv_method
//					lu_check.is_data[4] = is_chg_flag
//					lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
//					lu_check.uf_prc_check_11()
//					li_rc = lu_check.ii_rc
//					If li_rc < 0 Then 
//						Destroy lu_check
//						Return li_rc
//					End If				
//			  End If		
//		End Choose
//		
//	Case 3
//		Choose Case dwo.name
//			Case "svccod"
//				li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//			
//				ldc_priceplan.SetTransObject(SQLCA)
//				ldc_priceplan.Retrieve(data)
//				
//		End Choose
//	
//	Case 10
//		If (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!) = New!) Or (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!)) = NewModified!	Then
//			ls_munitsec = "0"
//		Else
//			ls_munitsec = String(tab_1.idw_tabpage[10].object.munitsec[row])
//			If IsNull(ls_munitsec) Then ls_munitsec = ""
//		End If
//		
//		Choose Case dwo.name
//			Case "zoncod"
//				If data <> "ALL" Then
//					tab_1.idw_tabpage[10].Object.areanum[row] = "ALL"
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 1
//				Else
//					tab_1.idw_tabpage[10].Object.areanum[row] = ""
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 0
//				End If
//				
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[10].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[10].setColumn("enddt")
//						tab_1.idw_tabpage[10].setRow(row)
//						tab_1.idw_tabpage[10].scrollToRow(row)
//						tab_1.idw_tabpage[10].setFocus()
//						Return -1
//					End If
//				End If
//				
//			Case "unitsec"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange1[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange1[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].object.munitsec1[row] > 0) Then
//					tab_1.idw_tabpage[10].object.munitsec1[row] = Long(data)
//				End If
//			End If
//		
//		Case "unitfee1"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].object.munitfee[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee1[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange2[row] = Long(data)
//				End If
//			End If
//		
//			
//		Case "unitsec2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec2[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee2"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee2[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee2[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange3[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec3[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee3"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee3[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee3[row] = Long(data)
//				End If
//			End If
//
//			
//		Case "tmrange4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange4[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec4[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee4"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee4[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee4[row] = Long(data)
//				End If
//			End If
//			
//		Case "tmrange5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.mtmrange5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.mtmrange5[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitsec5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec5[row] = Long(data)
//				End If
//			End If
//			
//		Case "unitfee5"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitfee5[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitfee5[row] = Long(data)
//				End If
//			End If
//		End Choose
//	
//	Case 11
//		Choose Case dwo.name
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[11].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[11].setColumn("enddt")
//						tab_1.idw_tabpage[11].setRow(row)
//						tab_1.idw_tabpage[11].scrollToRow(row)
//						tab_1.idw_tabpage[11].setFocus()
//						Return -1
//					End If
//				End If
//		End Choose
//End Choose
Return 0

end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;String ls_rectype, ls_status

//신청 상태일때만 delete

Choose Case ai_tabpage
	Case 2
		If al_row = 0 then Return -1
		
		If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
			 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
		Else
			tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
			tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
		End If

End Choose

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within c1w_reg_wholesale_customer_v20
integer y = 768
end type

