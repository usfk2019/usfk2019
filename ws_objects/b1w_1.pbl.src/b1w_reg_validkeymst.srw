$PBExportHeader$b1w_reg_validkeymst.srw
$PBExportComments$[ssong]인증Key 마스터 관리
forward
global type b1w_reg_validkeymst from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_validkeymst from w_a_reg_m_tm2
integer width = 3401
end type
global b1w_reg_validkeymst b1w_reg_validkeymst

on b1w_reg_validkeymst.create
int iCurrent
call super::create
end on

on b1w_reg_validkeymst.destroy
call super::destroy
end on

event open;call super::open;tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)

p_reset.TriggerEvent("ue_enable")
end event

event ue_ok();call super::ue_ok;	Long		ll_rows
	String	ls_where
	String	ls_validkey_type, ls_sale_flag, ls_validkey
	String	ls_status
	String	ls_idate, ls_idate_2
	String	ls_partner
	String	ls_activedt, ls_activedt_2
	String	ls_customerid


	//Condition
	ls_validkey_type		= Trim(dw_cond.Object.validkey_type[1])
	ls_sale_flag		   = Trim(dw_cond.Object.sale_flag[1])
	ls_status		      = Trim(dw_cond.Object.status[1])
	ls_idate          	= Trim(String(dw_cond.Object.idate[1],"YYYYMMDD"))
	ls_idate_2		      = Trim(String(dw_cond.Object.idate_2[1],"YYYYMMDD"))
	ls_partner  			= Trim(dw_cond.Object.partner[1])
	ls_activedt       	= Trim(String(dw_cond.Object.activedt[1],"YYYYMMDD"))
	ls_activedt_2		   = Trim(String(dw_cond.Object.activedt_2[1],"YYYYMMDD"))
	ls_customerid     	= Trim(dw_cond.Object.customerid[1])
	ls_validkey    		= fs_snvl(dw_cond.Object.validkey[1], '')
	
	
	IF IsNull(ls_validkey_type) THEN ls_validkey_type = ""
	IF IsNull(ls_sale_flag) THEN ls_sale_flag = ""
	IF IsNull(ls_status) THEN ls_status = ""
	IF IsNull(ls_idate) THEN ls_idate = ""
	IF IsNull(ls_idate_2) THEN ls_idate_2 = ""
	IF IsNull(ls_partner) THEN ls_partner = ""
	IF IsNull(ls_activedt) THEN ls_activedt = ""
	IF IsNull(ls_activedt_2) THEN ls_activedt_2 = ""
	IF IsNull(ls_customerid) THEN ls_customerid = ""
	
	
	//입력조건이 모두 null이면 에러
	IF ls_validkey_type = "" AND &
		ls_sale_flag     = "" AND &
		ls_status        = "" AND &
		ls_idate         = "" AND &
		ls_idate_2       = "" AND &
		ls_partner       = "" AND &
		ls_activedt      = "" AND &
		ls_activedt_2    = "" AND &
		ls_customerid    = "" AND &
		ls_validkey      = "" THEN	
		
		f_msg_usr_err(200, Title, "조회조건")
		RETURN
		
	END IF
	
	//Dynamic SQL
	ls_where = ""
	
	IF ls_validkey_type <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "validkey_type = '" + ls_validkey_type + "'"
	END IF
	
	IF ls_sale_flag <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "sale_flag = '" + ls_sale_flag + "'"
	END IF
	
	IF ls_status <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "status = '" + ls_status + "'"
	END IF
	
	IF ls_idate <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(idate,'YYYYMMDD') >= '" + ls_idate + "'"
	END IF
	
	IF ls_idate_2 <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(idate_2,'YYYYMMDD') <= '" + ls_idate_2 + "'"
	END IF
	
	IF ls_partner <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "partner = '" + ls_partner + "'"
	END IF
	
	IF ls_activedt <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(activedt,'YYYYMMDD') >= '" + ls_activedt + "'"
	END IF
	
	IF ls_activedt_2 <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(activedt_2,'YYYYMMDD') <= '" + ls_activedt_2 + "'"
	END IF
	
	IF ls_customerid <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "customerid = '" + ls_customerid + "'"
	END IF
	
	IF ls_validkey <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "validkey Like '" + ls_validkey + "%'"
	END IF	
	
	//Retrieve
	dw_master.is_where = ls_where
	ll_rows = dw_master.Retrieve()
	If ll_rows = 0 Then
		f_msg_info(1000, Title, "")
		p_reset.TriggerEvent("ue_enable")
	ElseIf ll_rows < 0 Then
		f_msg_usr_err(2100, Title, "")
		p_reset.TriggerEvent("ue_enable")
		Return
	Else			
		//검색결과가 있으면 Tab을 활성화 시킨다.
		tab_1.Trigger Event SelectionChanged(1, 1)
		tab_1.Enabled = True
	End If
end event

event type integer ue_reset();call super::ue_reset;dw_cond.reset()
dw_cond.insertRow(0)

RETURN 0
end event

event type integer ue_save();//Override
Constant Int LI_ERROR = -1
Int li_tab_index


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
End if

//COMMIT와 동일한 기능

iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")




RETURN 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_validkeymst
integer x = 69
integer width = 2519
integer height = 348
string dataobject = "b1dw_reg_cnd_validkeymst"
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name
	Case "customerid"
		
		If data <> "" then 
			SELECT CUSTOMERNM
			  INTO :ls_customernm
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :data ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_info(9000, title, 'select error')
				Return -1
			ElseIf SQLCA.SQLCode = 100 Then
				f_msg_info(9000, title, 'select not found')
				Return -1
			Else
				This.object.customernm[1] = ls_customernm
			End If
		Else
			This.object.customernm[1] = ""
			
		End If
		 
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_validkeymst
integer x = 2697
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_validkeymst
integer x = 2999
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_validkeymst
integer x = 37
integer width = 2574
integer height = 416
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_validkeymst
integer y = 432
integer width = 3305
integer height = 580
string dataobject = "b1dw_reg_master_validkeymst"
end type

event dw_master::clicked;call super::clicked;//마지막에 선택된 Row로 간다.
tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.validkey_type_t
uf_init(ldwo_SORT)
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_validkeymst
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_validkeymst
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_validkeymst
integer x = 32
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_validkeymst
integer x = 699
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_validkeymst
integer x = 32
integer y = 1052
integer width = 3305
integer height = 760
end type

event tab_1::selectionchanged;call super::selectionchanged;Long ll_master_row, ll_tab_row	

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


end event

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 2		//Tab 갯수
//Tab Title
is_tab_title[1] = "마스터정보"
is_tab_title[2] = "변경이력"


//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_validkeymst_t1"
is_dwObject[2] = "b1dw_reg_validkeymst_t2"
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_validkey, ls_temp
String ls_where
Long ll_row
Int li_tab

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_validkey = dw_master.object.validkey[al_master_row]

Choose Case li_tab
	Case 1								//Tab 1
		ls_where = "VALID.validkey = '" + ls_validkey + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		
		
		p_save.TriggerEvent("ue_enable")
	
	Case 2								//Tab 2
		ls_where = "a.validkey = '" + ls_validkey + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		//세부 정보 표시..
//		idw_tabpage[li_tab].object.t_validkey.Text = ls_validkey
//		idw_tabpage[li_tab].object.t_validkey_type.Text = dw_master.object.validkey_type[al_master_row]
		
		
		
		p_save.TriggerEvent("ue_disable")

End Choose


Return 0

end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_validkeymst
integer x = 32
integer y = 1020
end type

