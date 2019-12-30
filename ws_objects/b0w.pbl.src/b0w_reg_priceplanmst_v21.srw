$PBExportHeader$b0w_reg_priceplanmst_v21.srw
$PBExportComments$[parkkh] 가격정책등록 v21버전
forward
global type b0w_reg_priceplanmst_v21 from w_a_reg_m_tm2
end type
end forward

global type b0w_reg_priceplanmst_v21 from w_a_reg_m_tm2
integer width = 3584
integer height = 2208
end type
global b0w_reg_priceplanmst_v21 b0w_reg_priceplanmst_v21

type variables
Boolean ib_new			//신규 등록  True
String is_root
String is_check ,is_currency_type, is_zoncst


end variables

forward prototypes
public function integer wfi_set_codename (string as_gu, string as_code, ref string as_codename)
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
end prototypes

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

on b0w_reg_priceplanmst_v21.create
int iCurrent
call super::create
end on

on b0w_reg_priceplanmst_v21.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b0w_reg_priceplanmst_v20
	Desc.	: 가격정책등록 
	Ver.	: 2.0
	Date	: 2005.04.12
	Programer : Park Kyung Hae (parkkh)
------------------------------------------------------------------------*/
String ls_desc

tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)

ib_new = False
is_check = ""

is_zoncst = fs_get_control("B0", "P100", ls_desc)
is_currency_type = fs_get_control("B0", "P105", ls_desc)
end event

event ue_ok();call super::ue_ok;//조회
String ls_svccod, ls_priceplan_desc, ls_new, ls_where
Long ll_row

dw_cond.AcceptText()
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan_desc = Trim(dw_cond.object.priceplan_desc[1])
ls_new = Trim(dw_cond.object.new[1])
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan_desc) Then ls_priceplan_desc = ""
If IsNull(ls_new) Then ls_new = ""
If ls_new = "Y" Then ib_new = True

//신규 등록 여부
If ls_new = "Y" Then
	ib_new = True
Else
	ib_new = False
End If


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
	tab_1.idw_tabpage[tab_1.SelectedTab].object.priceplan.Protect = 0
	tab_1.idw_tabpage[tab_1.SelectedTab].Object.priceplan.Background.Color = RGB(108, 147, 137)
	tab_1.idw_tabpage[tab_1.SelectedTab].Object.priceplan.Color = RGB(255, 255, 255)	
			
	Return
Else
		//Retrieve
		ls_where = ""
		If ls_svccod <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "svccod = '" + ls_svccod + "' "
		End If
		
		If ls_priceplan_desc <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "priceplan_desc like '" + ls_priceplan_desc + "%' "
		End If

		dw_master.is_where = ls_where
		ll_row = dw_master.Retrieve()
		
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
Long ll_master_row
String ls_priceplan

ll_master_row = dw_master.GetRow()

Choose Case ai_selected_tab
	Case 1								//Tab 1
		If ib_new = True Then
			//Setting
			tab_1.idw_tabpage[ai_selected_tab].object.decpoint[al_insert_row] = 0
			tab_1.idw_tabpage[ai_selected_tab].object.pricetable[al_insert_row] = is_zoncst
			tab_1.idw_tabpage[ai_selected_tab].object.currency_type[al_insert_row] = is_currency_type

			tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()			//등록일자
			tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
			tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[ai_selected_tab].object.updt_user[al_insert_row] = gs_user_id	
			tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()
			
    		//Insert 시 해당 row 첫번째 컬럼에 포커스
			 tab_1.idw_tabpage[ai_selected_tab].SetColumn("priceplan")
        	 p_insert.TriggerEvent("ue_disable")
			 
		End  If
		
	Case 2								//Tab 2
 		p_insert.TriggerEvent("ue_enable")
		ls_priceplan = dw_master.object.priceplan[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.crtdt[al_insert_row] = fdt_get_dbserver_now()			//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.crt_user[al_insert_row] = gs_user_id						//등록자	
		tab_1.idw_tabpage[ai_selected_tab].object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]			
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan[al_insert_row] = ls_priceplan
		tab_1.idw_tabpage[ai_selected_tab].object.updt_user[al_insert_row] = gs_user_id	
		tab_1.idw_tabpage[ai_selected_tab].object.updtdt[al_insert_row] = fdt_get_dbserver_now()

	Case 3								//Tab 3
		ls_priceplan = dw_master.object.priceplan[ll_master_row]
		//Setting
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan_validkey_type_crtdt[al_insert_row] = fdt_get_dbserver_now()			//등록일자
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan_validkey_type_crt_user[al_insert_row] = gs_user_id						//등록자	
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan_validkey_type_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]			
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan_validkey_type_priceplan[al_insert_row] = ls_priceplan
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan_validkey_type_updt_user[al_insert_row] = gs_user_id	
		tab_1.idw_tabpage[ai_selected_tab].object.priceplan_validkey_type_updtdt[al_insert_row] = fdt_get_dbserver_now()
		
End Choose

Return 0 
end event

event close;call super::close;ib_new = False		//초기화
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("svccod")
tab_1.SelectedTab = 1
ib_new = False
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
Return 0 
end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Long ll_master_row, ll_cnt
String ls_priceplan

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

Choose Case tab_1.SelectedTab
	Case 1						//Tab
		ls_priceplan = dw_master.object.priceplan[ll_master_row]
		
		//가격정책 품목 정보가 존재시 삭제 불가.
		Select count(*)
		  into :ll_cnt
		  from priceplandet
		 where priceplan = :ls_priceplan;
			 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Error")
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, Title, "삭제불가! 품목정보 존재")  //삭제 안됨 
			Return -1
		Else 							
			is_check = "DEL"							   //삭제 가능
		End If
		
End Choose

return 0
end event

event type integer ue_extra_save(integer ai_select_tab);//Save
String ls_svccod, ls_priceplan, ls_priceplan_desc
String ls_currency_type, ls_use_yn, ls_pricetable, ls_decpoint
String ls_itemcod, ls_auth_level, ls_validkey_cnt, ls_validkey_type, ls_dsp_itemnm
Long ll_row, ll_len, ll_len_1, ll_cnt, i, j, ll_groupno, ll_type[], &
     ll_grouptype, ll_gubun[], ll_dsp_itemseq
Integer ll_i

//2005.12.08 juede add
String ls_pricegroup

//Row 수가 없으면aasaa
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

Choose Case ai_select_tab
	Case 1
		//Update Log
		tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()
		
		tab_1.idw_tabpage[ai_select_tab].AcceptText()
		//필수 Check
		ls_priceplan = Trim(tab_1.idw_tabpage[ai_select_tab].object.priceplan[1])
		ls_priceplan_desc = Trim(tab_1.idw_tabpage[ai_select_tab].object.priceplan_desc[1])
		ls_svccod = Trim(tab_1.idw_tabpage[ai_select_tab].object.svccod[1])
		ls_currency_type = Trim(tab_1.idw_tabpage[ai_select_tab].object.currency_type[1])
		ls_decpoint = String(tab_1.idw_tabpage[ai_select_tab].object.decpoint[1])
		ls_use_yn = Trim(tab_1.idw_tabpage[ai_select_tab].object.use_yn[1])
		ls_pricetable = Trim(tab_1.idw_tabpage[ai_select_tab].object.pricetable[1])
		ls_auth_level= String(tab_1.idw_tabpage[ai_select_tab].object.auth_level[1])
		ls_validkey_cnt = String(tab_1.idw_tabpage[ai_select_tab].object.validkeycnt[1])
		ls_pricegroup = String (tab_1.idw_tabpage[ai_select_tab].Object.price_group[1]) //2005.12.08 juede add
		
		If IsNull(ls_priceplan) Then ls_priceplan = ""
		If IsNull(ls_priceplan_desc) Then ls_priceplan_desc = ""
		If IsNull(ls_svccod) Then ls_svccod = ""
		If IsNull(ls_currency_type) Then ls_currency_type = ""
		If IsNull(ls_decpoint) Then ls_decpoint = ""
		If IsNull(ls_use_yn) Then ls_svccod = ""
		If IsNull(ls_pricetable) Then ls_pricetable = ""
		If IsNull(ls_auth_level) Then ls_auth_level = ""
		If IsNull(ls_validkey_cnt) Then ls_validkey_cnt = ""
		If IsNull(ls_pricegroup) Then ls_pricegroup = ""
		
		If ls_priceplan = "" Then
			f_msg_usr_err(200, Title,"가격정책코드")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("priceplan")
			Return -2
		End If
			
		If ls_priceplan_desc = "" Then
			f_msg_usr_err(200, Title,"가격정책명")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("priceplan_desc")
			Return -2
		End If
		
		If ls_svccod = "" Then
			f_msg_usr_err(200, Title,"서비스")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("svccod")
			Return -2
		End If
		
		If ls_currency_type = "" Then
			f_msg_usr_err(200, Title,"통화구분")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("currency_type")
			Return -2
		End If
		
		If ls_decpoint = "" Then
			f_msg_usr_err(200, Title,"소숫점 자리수")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("decpoint")
			Return -2
		End If
		
		If ls_use_yn = "" Then
			f_msg_usr_err(200, Title,"사용여부")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("use_yn")
			Return -2
		End If
		
		If ls_pricetable = "" Then
			f_msg_usr_err(200, Title,"적용요율 테이블")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("pricetable")
			Return -2
		End If
		
		If ls_auth_level = "" Then
			f_msg_usr_err(200, Title,"Authority")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("auth_level")
			Return -2
		End If
		
		If ls_validkey_cnt = "" Then
			f_msg_usr_err(200, Title,"인증Key갯수")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("validkeycnt")
			Return -2
		End If
		
/*		//2005.12.08 juede add ----start
		If ls_pricegroup = "" Then
			f_msg_usr_err(200, Title, "가격정책별 그룹")
			tab_1.idw_tabpage[ai_select_tab].SetFocus()
			tab_1.idw_tabpage[ai_select_tab].SetColumn("price_group")
			Return -2
		End If
		//2005.12.08 juede add ----end   */
		
		//Log
		If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(1, 0, Primary!) = DataModified! THEN
			tab_1.idw_tabpage[ai_select_tab].object.updt_user[1] = gs_user_id
			tab_1.idw_tabpage[ai_select_tab].object.updtdt[1] = fdt_get_dbserver_now()
		End If
		
	Case 2

		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For ll_i = 1 To ll_row
		
			tab_1.idw_tabpage[ai_select_tab].AcceptText()
	
			ls_itemcod   = fs_snvl(tab_1.idw_tabpage[ai_select_tab].object.itemcod[ll_i]  , '')
			ll_groupno   = tab_1.idw_tabpage[ai_select_tab].object.groupno[ll_i]
			ll_grouptype = tab_1.idw_tabpage[ai_select_tab].object.grouptype[ll_i]
			If isnull(ll_groupno)   Then  ll_groupno   = 0
         // khpark add 2006-02-03
			ll_dsp_itemseq  = tab_1.idw_tabpage[ai_select_tab].object.dsp_itemseq[ll_i]
			ls_dsp_itemnm = fs_snvl(tab_1.idw_tabpage[ai_select_tab].object.dsp_itemnm[ll_i]  , '')
			
			If ls_itemcod = "" Then
				f_msg_usr_err(200, Title, "품목명")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("itemcod")
				Return -2		
			End If
			
			If ll_groupno = 0 Then
				f_msg_usr_err(200, Title, "품목Group")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("groupno")
				Return -2		
			End If
			
/*		If isnull(ll_grouptype) Then
				f_msg_usr_err(200, Title, "선택유형")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("grouptype")
				Return -2		
			End If		*/

			If isnull(ll_dsp_itemseq) Then
				f_msg_usr_err(200, Title, "Display순서")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("dsp_itemseq")
				Return -2		
			End If		
			
			If ls_dsp_itemnm = "" Then
				f_msg_usr_err(200, Title, "Display 품목명")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("dsp_itemnm")
				Return -2		
			End If
		   
			ll_gubun[ll_i] = ll_groupno
			ll_type[ll_i]  = ll_grouptype
			//Log
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.updt_user[1] = gs_user_id
				tab_1.idw_tabpage[ai_select_tab].object.updtdt[1] = fdt_get_dbserver_now()
		   End If		
	   Next
		
	   For i = 1 to UpperBound(ll_gubun)
			For j = 2 TO UpperBound(ll_gubun)
				If (ll_gubun[i] = ll_gubun[j]) And (ll_type[i] <> ll_type[j]) Then
					f_msg_info(9000, Title, "품목Group이 같을때 선택유형이 같아야 합니다.")	
					tab_1.idw_tabpage[ai_select_tab].SetRow(j)
					tab_1.idw_tabpage[ai_select_tab].ScrollToRow(j)
					tab_1.idw_tabpage[ai_select_tab].SetColumn("grouptype")
					Return -2		
				End If
			Next
		Next
		
	Case 3

		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For ll_i = 1 To ll_row
		
			tab_1.idw_tabpage[ai_select_tab].AcceptText()
	
			ls_validkey_type = Trim(tab_1.idw_tabpage[ai_select_tab].object.priceplan_validkey_type_validkey_type[1])
			If IsNull(ls_validkey_type) Then ls_validkey_type = ""
			If ls_validkey_type = "" Then
				f_msg_usr_err(200, Title, "인증KeyType")
				tab_1.idw_tabpage[ai_select_tab].SetRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].ScrollToRow(ll_i)
				tab_1.idw_tabpage[ai_select_tab].SetColumn("priceplan_validkey_type_validkey_type")
				Return -2		
			End If
			//Log
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.priceplan_validkey_type_updt_user[1] = gs_user_id
				tab_1.idw_tabpage[ai_select_tab].object.priceplan_validkey_type_updtdt[1] = fdt_get_dbserver_now()
		    End If		
	   Next
	   
End Choose

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_priceplan_desc
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
	 ls_priceplan_desc = tab_1.idw_tabpage[1].Object.priceplan_desc[1]	//조건을 넣고
	 TriggerEvent("ue_reset")
	 dw_cond.object.priceplan_desc[1] = ls_priceplan_desc
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

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1,2,3
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)	
		
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

type dw_cond from w_a_reg_m_tm2`dw_cond within b0w_reg_priceplanmst_v21
integer x = 55
integer width = 2624
integer height = 220
string dataobject = "b0dw_cnd_reg_pricepanmst_v20"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within b0w_reg_priceplanmst_v21
integer x = 2889
integer y = 56
end type

type p_close from w_a_reg_m_tm2`p_close within b0w_reg_priceplanmst_v21
integer x = 3195
integer y = 56
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b0w_reg_priceplanmst_v21
integer width = 2747
integer height = 292
end type

type dw_master from w_a_reg_m_tm2`dw_master within b0w_reg_priceplanmst_v21
integer y = 320
integer width = 3470
integer height = 604
string dataobject = "b0dw_cnd_pricerate1_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.priceplan_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;call super::clicked;Int li_rc, li_return, li_cnt, li_i
String ls_credit_yn, ls_partner

//THIS.b_1.Enabled = TRUE
Choose Case tab_1.SelectedTab
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2,3
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_tm2`p_insert within b0w_reg_priceplanmst_v21
integer y = 1920
end type

type p_delete from w_a_reg_m_tm2`p_delete within b0w_reg_priceplanmst_v21
integer y = 1920
end type

type p_save from w_a_reg_m_tm2`p_save within b0w_reg_priceplanmst_v21
integer y = 1920
end type

type p_reset from w_a_reg_m_tm2`p_reset within b0w_reg_priceplanmst_v21
integer y = 1920
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b0w_reg_priceplanmst_v21
integer y = 964
integer width = 3461
integer height = 928
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "가격정책정보"
is_tab_title[2] = "가격정책품목정보"
is_tab_title[3] = "인증KeyType정보"

is_dwobject[1] = "b0dw_reg_priceplanmst_t1_v21" //2005.12.8 add juede
is_dwobject[2] = "b0dw_reg_priceplanmst_t2_v21"
is_dwobject[3] = "b0dw_reg_priceplanmst_t3_v21"
end event

event tab_1::constructor;call super::constructor;////help Window
////idw_tabpage[1].is_help_win[3] = "b2w_hlp_partnermst"
////idw_tabpage[1].idwo_help_col[3] = idw_tabpage[1].Object.partner
////idw_tabpage[1].is_data[3] = "CloseWithReturn"
//
//idw_tabpage[1].is_help_win[1] = "b2w_hlp_logid"
//idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.logid
//idw_tabpage[1].is_data[1] = "CloseWithReturn"
//
//idw_tabpage[1].is_help_win[2] = "w_hlp_post"
//idw_tabpage[1].idwo_help_col[2] = idw_tabpage[1].Object.zipcod
//idw_tabpage[1].is_data[2] = "CloseWithReturn"
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;//Choose Case ai_tabpage
//	Case 1
//		Choose Case adwo_dwo.name
////			Case "partner"		//partner
////				If ib_new = True Then
////					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
////						 idw_tabpage[ai_tabpage].Object.partner[al_row] = &
////						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
////						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
////						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
////					End If
////				End If
//			Case "logid"		//Log ID
//			//	If ib_new = True Then
//					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
//						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					End If
//			//	End If
//			Case "zipcod"
//				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//					idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//				End If
//		End Choose
//End Choose  
//
Return 0 
//
end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Change Event
String ls_validkey_typenm, ls_crt_kind, ls_prefix, ls_auth_method, ls_type, ls_used_level, ls_itemnm
integer li_rc, li_seltab
long ll_length
li_seltab = tab_1.SelectedTab

Choose Case li_seltab
	Case 2														//Tab 2 2006-02-03 khpark modify
		Choose Case dwo.name
			Case "itemcod"
			
				SELECT itemnm
				  INTO :ls_itemnm
				  FROM itemmst
				 WHERE itemcod = :data;				
					
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(parent.title, "SELECT itemnm from itemmst")				
					Return 1
				End If	
				
			   //display
			   tab_1.idw_tabpage[li_seltab].Object.dsp_itemnm[row] = ls_itemnm
				
	   End Choose
		
	Case 3														//Tab 1
		Choose Case dwo.name
			Case "priceplan_validkey_type_validkey_type"
			
				SELECT crt_kind,
					   prefix,
					   length,
					   auth_method,
					   type,
						USED_LEVEL
				  INTO :ls_crt_kind,
					   :ls_prefix,
					   :ll_length,
					   :ls_auth_method,
					   :ls_type,
						:ls_used_level
				  FROM validkey_type
				 WHERE validkey_type = :data;				
					
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(parent.title, "SELECT validkey_type")				
					Return 1
				End If	
				
			   //display
			   tab_1.idw_tabpage[li_seltab].Object.validkey_type_crt_kind[row] = ls_crt_kind
			   tab_1.idw_tabpage[li_seltab].Object.validkey_type_prefix[row] = ls_prefix
			   tab_1.idw_tabpage[li_seltab].Object.validkey_type_length[row] = ll_length
   			tab_1.idw_tabpage[li_seltab].Object.validkey_type_auth_method[row] = ls_auth_method
			   tab_1.idw_tabpage[li_seltab].Object.validkey_type_type[row] = ls_type
				tab_1.idw_tabpage[li_seltab].Object.validkey_type_used_level[row] = ls_used_level
				
	   End Choose
End Choose

Return 0 
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Retrieve
String ls_where, ls_priceplan, ls_filter
Long ll_row
Integer li_exist
DataWindowChild ldc_child

If al_master_row = 0 Then Return -1		//해당 고객 없음

Choose Case ai_select_tabpage
	Case 1								//Tab 1
		
		ls_priceplan = dw_master.object.priceplan[al_master_row]		
		ls_where = "priceplan = '" + ls_priceplan + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		tab_1.idw_tabpage[ai_select_tabpage].object.priceplan.Protect = 1
		tab_1.idw_tabpage[ai_select_tabpage].Object.priceplan.Background.Color = RGB(255, 251, 240)
		tab_1.idw_tabpage[ai_select_tabpage].Object.priceplan.Color = RGB(0, 0, 0)		

	Case 2		                       //Tab 2
		
      ls_priceplan = Trim(dw_master.object.priceplan[al_master_row])        
		ls_where = "priceplan = '" + ls_priceplan + "' "		
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		//해당 service에 대한 Item만 가져옴
		li_exist = idw_tabpage[ai_select_tabpage].GetChild("itemcod", ldc_child)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild()-Item Code")
		
		ls_filter = "svccod = '" + Trim(dw_master.object.svccod[al_master_row])  + "' "
		ldc_child.SetFilter(ls_filter)							//Filter정함
		ldc_child.Filter()
		ldc_child.SetTransObject(SQLCA)
		li_exist =ldc_child.Retrieve()
		
		If li_exist < 0 Then 								//디비 오류 
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return -1
		End If 		
		
	Case 3								//Tab 3
		
        ls_priceplan = Trim(dw_master.object.priceplan[al_master_row])        
		ls_where = "priceplan_validkey_type.priceplan = '" + ls_priceplan + "' "		
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		  
End Choose

Return 0 
		
end event

event tab_1::selectionchanging;call super::selectionchanging;//1  Prevent the selection from changing
Long ll_master_row
//ll_master_row = dw_master.GetSelectedRow(0)
//신규 등록이면
If ib_new = TRUE Then Return 1


end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn, ls_credit_yn
ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2,3
		p_insert.TriggerEvent("ue_enable")
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b0w_reg_priceplanmst_v21
integer y = 928
end type

