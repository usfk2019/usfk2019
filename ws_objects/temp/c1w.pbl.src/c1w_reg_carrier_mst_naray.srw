$PBExportHeader$c1w_reg_carrier_mst_naray.srw
$PBExportComments$[ssong] 회선 사업자 등록 naray old
forward
global type c1w_reg_carrier_mst_naray from w_a_reg_m_tm2
end type
end forward

global type c1w_reg_carrier_mst_naray from w_a_reg_m_tm2
integer width = 3191
integer height = 1964
end type
global c1w_reg_carrier_mst_naray c1w_reg_carrier_mst_naray

type variables
Boolean ib_new
String is_check


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

on c1w_reg_carrier_mst_naray.create
int iCurrent
call super::create
end on

on c1w_reg_carrier_mst_naray.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: c1w_reg_carrier_mst_naray
	Desc.	: 회선사업자 정산 - naray old virsion
	Ver.	: 1.0
	Date	: 2005.11.03
	Programer : Song Eun Mi
------------------------------------------------------------------------*/
// 손가락 모양 없애기.
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)

ib_new = False
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

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;String ls_carrierid, ls_carriernm, ls_carriertype, ls_ratetype, ls_pbxno, ls_carrierkey, ls_fromdt
String ls_gmtyn
Long ll_row, ll_rowcount, ll_i
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()

If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getRow()

Choose Case ai_select_tab
	Case 1
		//Update Log
		tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()
		
		tab_1.idw_tabpage[ai_select_tab].AcceptText()
		
		ls_carrierid = Trim(tab_1.idw_tabpage[ai_select_tab].object.carrierid[ll_row])
		ls_carriernm = Trim(tab_1.idw_tabpage[ai_select_tab].object.carriernm[ll_row])
		ls_carriertype = Trim(tab_1.idw_tabpage[ai_select_tab].object.carriertype[ll_row])
		ls_ratetype = Trim(tab_1.idw_tabpage[ai_select_tab].object.ratetype[ll_row])
		ls_gmtyn    = Trim(tab_1.idw_tabpage[ai_select_tab].object.gmt_yn[ll_row])
		
		If IsNull(ls_carrierid) Then ls_carrierid = ""
		If IsNull(ls_carriernm) Then ls_carriernm = ""
		If IsNull(ls_carriertype) Then ls_carriertype = ""
		If IsNull(ls_ratetype) Then ls_ratetype = ""
		If IsNull(ls_gmtyn) Then ls_gmtyn = ""
		
		If ls_carrierid = "" Then
			f_msg_usr_err(200, title, "사업자ID")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("carrierid")
			Return -2
		End If
		If ls_carriernm = "" Then
			f_msg_usr_err(200, title, "사업자명")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("carriernm")
			Return -2
		End If
		If ls_carriertype = "" Then
			f_msg_usr_err(200, title, "사업자유형")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("carriertype")
			Return -2
		End If
      If ls_ratetype = "" Then
			f_msg_usr_err(200, title, "정산유형")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("ratetype")
			Return -2
		End If
		If ls_gmtyn = "" Then
			f_msg_usr_err(200, title, "기준시간")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("gmt_yn")
			Return -2
		End If
		
		If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.upd_user[ll_i] = gs_user_id	
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_i] = fdt_get_dbserver_now()
		End If
		
	Case 2
		ll_rowcount = tab_1.idw_tabpage[ai_select_tab].RowCount()
		
		For ll_i = 1 To ll_rowcount
			tab_1.idw_tabpage[ai_select_tab].AcceptText()
		
			ls_pbxno = Trim(tab_1.idw_tabpage[ai_select_tab].object.pbxno[ll_i])
			ls_carrierkey = Trim(tab_1.idw_tabpage[ai_select_tab].object.carrierkey[ll_i])
			ls_fromdt = Trim(String(tab_1.idw_tabpage[ai_select_tab].object.fromdt[ll_i], "yyyymmdd"))
		
			If IsNull(ls_pbxno) Then ls_pbxno = ""
			If IsNull(ls_carrierkey) Then ls_carrierkey = ""
			If IsNull(ls_fromdt) Then ls_fromdt = ""
		
			//필수항목 Check
			If ls_pbxno = "" Then
				f_msg_usr_err(200, Title, "교환기")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("pbxno")
				Return -2
			End If
			If ls_carrierkey = "" Then
				f_msg_usr_err(200, Title, "Route Key")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("carrierkey")
				Return -2
			End If
			If ls_fromdt = "" Then
				f_msg_usr_err(200, Title, "적용개시일")
				tab_1.idw_tabpage[ai_select_tab].SetFocus()
				tab_1.idw_tabpage[ai_select_tab].SetColumn("fromdt")
				Return -2
			End If
		Next
End Choose

Return 0
end event

event ue_ok();call super::ue_ok;String ls_where, ls_carrierid, ls_carriernm, ls_new
Long ll_row

ls_carrierid = Trim(dw_cond.object.carrierid[1])
ls_carriernm = Trim(dw_cond.object.carriernm[1])
ls_new = Trim(dw_cond.object.new[1])

If IsNull(ls_carrierid) Then ls_carrierid = ""
IF IsNull(ls_carriernm) Then ls_carriernm = ""

If ls_new = "Y" Then 
	ib_new = True
Else 
	ib_new = False
End If

// 신규사업자 등록
IF ib_new Then
	tab_1.selectedTab = 1	//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.
	Return
// 조회
Else
	ls_where = ""

	If ls_carrierid <> "" Then
		If ls_where <> "" Then ls_where += " AND " 
		ls_where += " carrierid = '" + ls_carrierid + "' "
	End If

	IF ls_carriernm <> "" Then
		IF ls_where <> "" Then ls_where += " AND "
		ls_where += " carriernm LIKE '%" + ls_carriernm + "%' "
	End If

	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
	Elseif ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")
	Else 
		tab_1.Trigger Event SelectionChanged(1, 1)
		tab_1.Enabled = True
	End If
	
	p_insert.TriggerEvent('ue_disable')
End If

end event

event type integer ue_reset();call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("carrierid")
tab_1.SelectedTab = 1
ib_new = False
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
Return 0 
end event

event type integer ue_save();call super::ue_save;Constant Int LI_ERROR = -1
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

String ls_troubletype
Long ll_row, ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab

If ib_new = True Then					//신규 등록이면		
	ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
	If ll_tab_rowcount < 1 Then Return 0
 	
	 If  li_selectedtab = 1 Then			//Tab 1
	 ls_carrierid = tab_1.idw_tabpage[1].Object.carrierid[1]	//조건을 넣고
	 TriggerEvent("ue_reset")
	 dw_cond.object.carrierid[1] = ls_carrierid
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

type dw_cond from w_a_reg_m_tm2`dw_cond within c1w_reg_carrier_mst_naray
integer y = 44
integer width = 2354
integer height = 180
string dataobject = "c1dw_cnd_reg_carrier_mst_naray"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within c1w_reg_carrier_mst_naray
integer x = 2519
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_tm2`p_close within c1w_reg_carrier_mst_naray
integer x = 2821
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within c1w_reg_carrier_mst_naray
integer width = 2391
integer height = 244
end type

type dw_master from w_a_reg_m_tm2`dw_master within c1w_reg_carrier_mst_naray
integer x = 9
integer y = 276
integer width = 3118
integer height = 492
string dataobject = "c1dw_reg_carrier_mst_m"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.carrierid_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;Long ll_selected_row,ll_old_selected_row
Int li_tab_index,li_rc

ll_old_selected_row = This.GetSelectedRow(0)

CALL u_d_sort::Clicked

/* u_d_sgl_sel::Clicked script
//if clicked outside of row return 
//if clicked selected row that must be not selected 
//if clicked not selected row that must be selected */

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

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
		p_insert.TriggerEvent('ue_enable') 
		p_delete.TriggerEvent('ue_enable')
		p_save.TriggerEvent('ue_enable')
		p_reset.TriggerEvent('ue_enable')
		tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)		
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

type p_insert from w_a_reg_m_tm2`p_insert within c1w_reg_carrier_mst_naray
integer y = 1724
end type

type p_delete from w_a_reg_m_tm2`p_delete within c1w_reg_carrier_mst_naray
integer y = 1724
end type

type p_save from w_a_reg_m_tm2`p_save within c1w_reg_carrier_mst_naray
integer y = 1724
end type

type p_reset from w_a_reg_m_tm2`p_reset within c1w_reg_carrier_mst_naray
integer y = 1724
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within c1w_reg_carrier_mst_naray
integer x = 9
integer y = 804
integer width = 3109
integer height = 888
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;ii_enable_max_tab = 2

//Tab Title
is_tab_title[1] = "사업자등록"
is_tab_title[2] = "사업자Key"

is_dwObject[1] = "c1dw_reg_carrier_mst_t1"
is_dwObject[2] = "c1dw_reg_carrier_mst_t2"

end event

event tab_1::constructor;call super::constructor;idw_tabpage[1].is_help_win[1] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.zipcod
idw_tabpage[1].is_data[1] = "CloseWithReturn"
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;Choose Case ai_tabpage
	Case 1
		Choose Case adwo_dwo.name
			Case "zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose
End Choose

Return 0
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;String ls_where, ls_carrierid
Long ll_row

If al_master_row = 0 Then Return -1		//회선사업자 없음.

Choose Case ai_select_tabpage
	Case 1
		ls_carrierid = dw_master.object.carrierid[al_master_row]
		ls_where = "carrierid = '" + ls_carrierid + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		// 사업자 ID 수정불가
		tab_1.idw_tabpage[ai_select_tabpage].object.carrierid.Protect = 1
		tab_1.idw_tabpage[ai_select_tabpage].object.carrierid.Background.Color = RGB(255, 251, 240)
		tab_1.idw_tabpage[ai_select_tabpage].object.carrierid.Color = RGB(0, 0, 0)
		
	Case 2
		
		ls_carrierid = dw_master.object.carrierid[al_master_row]
		ls_where = " carrierid = '" + ls_carrierid + "' "
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
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")		
End Choose

Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within c1w_reg_carrier_mst_naray
integer y = 768
end type

