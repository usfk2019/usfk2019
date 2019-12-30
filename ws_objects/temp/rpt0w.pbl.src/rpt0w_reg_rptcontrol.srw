$PBExportHeader$rpt0w_reg_rptcontrol.srw
$PBExportComments$[parkkh] 계정control 등록
forward
global type rpt0w_reg_rptcontrol from w_a_reg_m_tm2
end type
end forward

global type rpt0w_reg_rptcontrol from w_a_reg_m_tm2
integer width = 3552
integer height = 2208
end type
global rpt0w_reg_rptcontrol rpt0w_reg_rptcontrol

type variables
Boolean ib_new			//신규 등록  True
String is_check, is_root
String is_groupcode[], is_groupcodenm[]
int ii_tabcnt

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

on rpt0w_reg_rptcontrol.create
int iCurrent
call super::create
end on

on rpt0w_reg_rptcontrol.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: r0w_reg_rptcontrol
	Desc.	: 계정코드 등록
	Ver.	: 1.0
	Date	: 2003.10.27
	Programer : Park Kyung Hae (parkkh)
------------------------------------------------------------------------*/
int li_i

ib_new = False
is_check = ""

For li_i = 1 To ii_tabcnt
	tab_1.idw_tabpage[li_i].SetRowFocusIndicator(Off!)
Next

p_save.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
end event

event ue_ok();call super::ue_ok;//dw_master 조회
String ls_rptcont, ls_rptcontnm, ls_rptgroup, ls_rptcontgroup, ls_temp, ls_result[]
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

dw_cond.AcceptText()
ls_rptcont = Trim(dw_cond.object.rptcont[1])
ls_rptcontnm = Trim(dw_cond.object.rptcontnm[1])
ls_rptgroup = Trim(dw_cond.object.rptgroup[1])
ls_rptcontgroup = Trim(dw_cond.object.rptcontgroup[1])

//ls_new  = Trim(dw_cond.object.new[1])
//If ls_new = "Y" Then ib_new = True

////신규 등록 
//If ib_new = True Then
//	
//	tab_1.SelectedTab = 1		//Tab 1 Select
//	p_ok.TriggerEvent("ue_disable")
//	dw_cond.Enabled = False
//	p_delete.TriggerEvent("ue_disable")
//	p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	tab_1.Enabled = True
//	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
//  p_insert.TriggerEvent("Clicked")
//	Return
//Else

		//Null Check
		If IsNull(ls_rptcont) Then ls_rptcont = ""
		If IsNull(ls_rptcontnm) Then ls_rptcontnm = ""
		If IsNull(ls_rptgroup) Then ls_rptgroup = ""
		If IsNull(ls_rptcontgroup) Then ls_rptcontgroup = ""
		
		//Retrieve
		ls_where = ""
		IF ls_rptcont <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "rptcont like '" + ls_rptcont + "%' "
		End If

		IF ls_rptcontnm <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "Upper(rptcontnm) like '" + upper(ls_rptcontnm) + "%' "
		End If
		
		IF ls_rptgroup <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "rptgroup = '" + ls_rptgroup + "' "
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
//End If

end event

event close;call super::close;ib_new = False		//초기화
end event

event type integer ue_reset();call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("rptcont")
tab_1.SelectedTab = 1
ib_new = False

//p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_enable")
p_insert.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_disable")

Return 0 
end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Dec lc_troubleno
Long ll_master_row, ll_cnt
String ls_partner

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

//Choose Case tab_1.SelectedTab
//	Case 1						//Tab
//		ls_partner = dw_master.object.partner[ll_master_row]
//
//		//삭제하고자하는 대리점코드가 svcorder(서비스신청내역) table에 존재할때 삭제불가
//		Select count(*)
//		  into :ll_cnt
//		  from svcorder
//		 where reg_partner = :ls_partner
//		    or maintain_partner = :ls_partner
//		    or sale_partner = :ls_partner
//		    or settle_partner = :ls_partner
//		    or partner = :ls_partner;
//			 
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Error")
//			RollBack;
//			Return -1
//		End If				
//		
//		If ll_cnt <> 0 Then
//			f_msg_usr_err(9000, Title, "삭제불가! 서비스신청내역에 해당대리점이 존재합니다.")  //삭제 안됨 
//			Return -1
//		End If
//		
//		//삭제하고자하는 대리점코드가 contractmst(계약마스터) table에 존재할때 삭제불가		
//		Select count(*)
//		  into :ll_cnt
//		  from contractmst
//		 where reg_partner = :ls_partner
//		    or maintain_partner = :ls_partner
//		    or sale_partner = :ls_partner
//		    or settle_partner = :ls_partner
//		    or partner = :ls_partner;
//
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Error")
//			RollBack;
//			Return -1
//		End If				
//		
//		If ll_cnt <> 0 Then
//			f_msg_usr_err(9000, Title, "삭제불가! 계약마스터에 해당대리점이 존재합니다.")  //삭제 안됨 
//			Return -1
//		End If
//		
//		//삭제하고자하는 대리점코드를 상위대리점으로 하는 대리점이 존재하면 삭제 할 수 없다.
//		ll_cnt = 0
//		Select count(*)
//		Into :ll_cnt
//		From partnermst
//		Where hpartner = :ls_partner;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title, "Select Error")
//			RollBack;
//			Return -1
//		End If				
//		
//		If ll_cnt <> 0 Then
//			f_msg_usr_err(9000, Title, "삭제불가! 소속 하위대리점을 먼저 삭제하셔야 합니다.")  //삭제 안됨 
//			Return -1
//		Else 							
//			is_check = "DEL"							   //삭제 가능
//		End If
//		
//End Choose
//
Return 0 
end event

event type integer ue_extra_save(integer ai_select_tab);//Save
String ls_rptcont, ls_rptcontnm, ls_rptgroup, ls_rptcontgroup
Long ll_row, ll_len, ll_len_1, ll_cnt
Integer li_rc, ll_i

//Row 수가 없으면aasaa
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0
 
ll_row = tab_1.idw_tabpage[ai_select_tab].getrow()

tab_1.idw_tabpage[ai_select_tab].AcceptText()
tab_1.idw_tabpage[ai_select_tab].object.updt_user[ll_row] = gs_user_id
tab_1.idw_tabpage[ai_select_tab].object.updtdt[ll_row] = fdt_get_dbserver_now()

//필수 Check
ls_rptcont = Trim(tab_1.idw_tabpage[ai_select_tab].object.rptcont[ll_row])
ls_rptcontnm = Trim(tab_1.idw_tabpage[ai_select_tab].object.rptcontnm[ll_row])
ls_rptgroup = Trim(tab_1.idw_tabpage[ai_select_tab].object.rptgroup[ll_row])
ls_rptcontgroup = Trim(tab_1.idw_tabpage[ai_select_tab].object.rptcontgroup[ll_row])

If IsNull(ls_rptcont) Then ls_rptcont = ""
If IsNull(ls_rptcontnm) Then ls_rptcontnm = ""
If IsNull(ls_rptgroup) Then ls_rptgroup = ""
If IsNull(ls_rptcontgroup) Then ls_rptcontgroup = ""

If ls_rptcont = "" Then
	f_msg_usr_err(200, title, "계정Control코드")
	tab_1.idw_tabpage[ai_select_tab].SetFocus()
	tab_1.idw_tabpage[ai_select_tab].SetColumn("rptcont")
	return -2
End If

If ls_rptcontnm = "" Then
	f_msg_usr_err(200, title, "계정Control코드명")
	tab_1.idw_tabpage[ai_select_tab].SetFocus()
	tab_1.idw_tabpage[ai_select_tab].SetColumn("rptcontnm")
	return -2
End If

If ls_rptgroup = "" Then
	f_msg_usr_err(200, title, "계정Control Type")
	tab_1.idw_tabpage[ai_select_tab].SetFocus()
	tab_1.idw_tabpage[ai_select_tab].SetColumn("rptgroup")
	return -2
End If

If ls_rptcontgroup = "" Then
	f_msg_usr_err(200, title, "계정Control그룹코드")
	tab_1.idw_tabpage[ai_select_tab].SetFocus()
	tab_1.idw_tabpage[ai_select_tab].SetColumn("rptcontgroup")
	return -2
End If

return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_partner
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

tab_1.setredraw(false)

String ls_troubletype
Long ll_row, ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab

//If ib_new = True Then					//신규 등록이면		
//	ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
//	If ll_tab_rowcount < 1 Then Return 0
 	
//	 If  li_selectedtab = 1 Then			//Tab 1
//	 ls_partner = tab_1.idw_tabpage[1].Object.rptcont[1]	//조건을 넣고
	 TriggerEvent("ue_reset")
//	 dw_cond.object.partner[1] = ls_partner
//	 dw_cond.object.new[1] = "N"
	 ib_new = False	 					//초기화 
	 dw_cond.Enabled = True
	 ll_row = TriggerEvent("ue_ok")		//조회
	 
	 If ll_row < 0 Then 
		f_msg_usr_err(2100,Title, "Retrieve()")
		tab_1.setredraw(true)
		Return LI_ERROR
	 End If			
//	End If
//End If
//
//If is_check = "DEL" Then	//Delete 
////	If  li_selectedTab = 1 Then
//		 dw_cond.Reset()
//		 dw_cond.InsertRow(0)
//		 TriggerEvent("ue_ok")
//		 is_check = ""
////	End If
//End If

Tab_1.SelectedTab = li_selectedtab
tab_1.setredraw(true)

Return 0
end event

event type integer ue_insert();//Insert시 조건
Long ll_master_row, ll_seq , i, ll_row
Constant Int LI_ERROR = -1
Integer li_curtab

li_curtab = tab_1.Selectedtab
//ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)
ll_row = 1

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "계정Control등록/INSERT"
iu_cust_msg.is_grp_name = "계정Control등록"
iu_cust_msg.is_data[1] = is_groupcode[li_curtab]
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]			//프로그램 ID

OpenWithParm(rpt0w_reg_rptcontrol_insert_pop, iu_cust_msg)	

tab_1.setredraw(false)

TriggerEvent("ue_reset")
dw_cond.Enabled = True
ll_row = TriggerEvent("ue_ok")		//조회

If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve()")
	tab_1.setredraw(true)	
	Return LI_ERROR
End If			

Tab_1.SelectedTab = li_curtab

//If tab_1.Trigger Event ue_tabpage_retrieve(ll_row, li_curtab) < 0 Then
//	Return -1
//End If

tab_1.setredraw(true)

Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within rpt0w_reg_rptcontrol
integer x = 55
integer y = 44
integer width = 2272
integer height = 228
string dataobject = "rpt0dw_cnd_reg_rptcontrol"
boolean livescroll = false
end type

type p_ok from w_a_reg_m_tm2`p_ok within rpt0w_reg_rptcontrol
integer x = 2523
integer y = 52
end type

type p_close from w_a_reg_m_tm2`p_close within rpt0w_reg_rptcontrol
integer x = 2830
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within rpt0w_reg_rptcontrol
integer width = 2368
integer height = 292
end type

type dw_master from w_a_reg_m_tm2`dw_master within rpt0w_reg_rptcontrol
integer y = 320
integer width = 3456
integer height = 604
string dataobject = "rpt0dw_inq_rptcontrol"
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
dwObject ldwo_SORT
ldwo_SORT = Object.rptcont_t
uf_init(ldwo_SORT)
end event

event dw_master::clicked;call super::clicked;Int li_i
Long ll_selected_row
String ls_rptcontgroup

If row <= 0 Then return -1
	
ls_rptcontgroup = dw_master.object.rptcontgroup[row]
For li_i = 1  to UpperBound(is_groupcode)
	IF ls_rptcontgroup = is_groupcode[li_i] Then
		tab_1.SelectedTab =li_i
		Exit
	End IF
NEXT	

If ib_retrieve Then
		ll_selected_row = dw_master.GetSelectedRow(0)
		If ll_selected_row > 0 Then
			If tab_1.Trigger Event ue_tabpage_retrieve(ll_selected_row, li_i) < 0 Then
				Return -1
			End If
			tab_1.ib_tabpage_check[li_i] = True
		End If
End If


return 0
end event

type p_insert from w_a_reg_m_tm2`p_insert within rpt0w_reg_rptcontrol
integer y = 1920
end type

type p_delete from w_a_reg_m_tm2`p_delete within rpt0w_reg_rptcontrol
integer y = 1920
end type

type p_save from w_a_reg_m_tm2`p_save within rpt0w_reg_rptcontrol
integer y = 1920
end type

type p_reset from w_a_reg_m_tm2`p_reset within rpt0w_reg_rptcontrol
integer y = 1920
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within rpt0w_reg_rptcontrol
integer y = 960
integer width = 3461
integer height = 928
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init();call super::ue_init;int li_i
String ls_ref_desc, ls_temp

//계정 관리코드 
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("R0", "R100", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_groupcode[])

//계정관리코드명
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("R0", "R200", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_groupcodenm[])

ii_tabcnt = UpperBound(is_groupcode)

//Tab 초기화
ii_enable_max_tab = ii_tabcnt //사용할 Tab Page의 갯수 (15 이하)

For li_i = 1 To ii_tabcnt
	is_tab_title[li_i] = is_groupcodenm[li_i]
Next

For li_i = 1 To ii_tabcnt
	is_dwobject[li_i] = "rpt0dw_reg_rptcontrol"
Next
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);//Retrieve
String ls_where, ls_rptcont, ls_rptcontgroup, ls_credit_yn
Long ll_row
Dec lc_troubleno

If al_master_row = 0 Then Return -1				//해당 고객 없음

//ls_rptcont = dw_master.object.rptcont[al_master_row]
//ls_rptcontgroup = dw_master.object.rptcontgroup[al_master_row]
//ls_where = "rptcont = '" + ls_rptcont + "' "
//idw_tabpage[ai_select_tabpage].is_where = ls_where		
ll_row = idw_tabpage[ai_select_tabpage].Retrieve(is_groupcode[ai_select_tabpage])	

If ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	Return -1
End If
	
Return 0 
end event

event tab_1::selectionchanging;call super::selectionchanging;//1  Prevent the selection from changing
String ls_credit_yn, ls_partner
Long ll_master_row
ll_master_row = dw_master.GetSelectedRow(0)
//신규 등록이면
//If ib_new = TRUE Then Return 1

//Choose Case newindex
//	Case 3
//		If ll_master_row > 0 Then
//			ls_partner = Trim(dw_master.object.partner[ll_master_row])
//			
//			select credit_yn
//			 into :ls_credit_yn
//			 from partnermst
//			where partner = :ls_partner;
//			
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(title, "SELECT credit_yn")			
//				Return -1
//			End If	
//		
//			//선불고객이거나 고객과 납입자가 다를경우 
//			If ls_credit_yn = 'N' or isnull(ls_credit_yn) Then Return 1
//		End If
//End Choose

end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn, ls_credit_yn
ll_master_row = dw_master.GetSelectedRow(0)
//If ll_master_row < 0 Then Return 

//Choose Case newindex
//	Case 1
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		
//	Case 2
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//		p_reset.TriggerEvent("ue_enable")
//		
//	Case 3
//		p_insert.TriggerEvent("ue_enable")
//		p_delete.TriggerEvent("ue_enable")
//		p_save.TriggerEvent("ue_enable")
//		p_reset.TriggerEvent("ue_enable")
//		
//End Choose

Return 0 
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부
String ls_logid = "", ls_svctype, ls_customerid
Integer li_exist
 
idw_tabpage[ai_tabpage].accepttext()

ll_master_row = dw_master.GetSelectedRow(0)
//If ll_master_row < 0 Then Return 0

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "계정Control등록/Update"
iu_cust_msg.is_grp_name = "계정Control등록"
iu_cust_msg.is_data[1] = Trim(idw_tabpage[ai_tabpage].object.rptcont[al_row])  	//rptcont
iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]							   	//프로그램 ID
iu_cust_msg.is_data[3] = Trim(idw_tabpage[ai_tabpage].object.rptcontgroup[al_row]) 	//rptcontgroup

OpenWithParm(rpt0w_reg_rptcontrol_update_pop, iu_cust_msg)

If tab_1.Trigger Event ue_tabpage_retrieve(ll_master_row, ai_tabpage) < 0 Then
	Return -1
End If

tab_1.ib_tabpage_check[ai_tabpage] = True
	
Return 0
end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;String ls_rectype, ls_status

If al_row = 0 then Return -1

If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
	 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
Else
	tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
	tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
End If
	
Return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within rpt0w_reg_rptcontrol
integer y = 924
end type

