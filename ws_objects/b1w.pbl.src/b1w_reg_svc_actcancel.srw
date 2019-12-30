$PBExportHeader$b1w_reg_svc_actcancel.srw
$PBExportComments$[kem] 계약철회 Window
forward
global type b1w_reg_svc_actcancel from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_svc_actcancel from w_a_reg_m_tm2
end type
global b1w_reg_svc_actcancel b1w_reg_svc_actcancel

type variables
String is_reqcancel	//계약철회신청
String is_calcel	 	//계약철회

end variables

event open;call super::open;String ls_status, ls_ref_desc
is_reqcancel = ""	//계약철회신청
is_calcel = ""	 	//계약철회

//계약철회신청코드(B0:P242)
is_reqcancel = fs_get_control("B0", "P242", ls_ref_desc)
//계약철회완료코드(B0:P244)
is_calcel = fs_get_control("B0", "P244", ls_ref_desc)


tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(off!)

TriggerEvent("ue_reset")

dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())

end event

on b1w_reg_svc_actcancel.create
int iCurrent
call super::create
end on

on b1w_reg_svc_actcancel.destroy
call super::destroy
end on

event type integer ue_delete();//Overiding

RETURN 0
end event

event type integer ue_save();tab_1.idw_tabpage[1].AcceptText()

Int		li_rc
String	ls_phone
String	ls_termdt, ls_actflag
String	ls_today

If tab_1.idw_tabpage[1].RowCount() = 0 Then Return 0

ls_termdt = Trim(String(tab_1.idw_tabpage[1].Object.termdt[1],"YYYYMMDD"))
ls_today = Trim(String(fdt_get_dbserver_now(),"YYYYMMDD"))

IF IsNull(ls_termdt) THEN ls_termdt = ""

IF ls_termdt = "" THEN
	f_msg_info(200, Title, "철회일자")
	tab_1.idw_tabpage[1].SetColumn("termdt")
	tab_1.idw_tabpage[1].Setfocus()			
	RETURN -1
END IF

IF ls_termdt < ls_today THEN
	f_msg_usr_err(210, Title, "철회일자는 오늘날짜 이후이여야 합니다.")
	tab_1.idw_tabpage[1].SetColumn("termdt")
	tab_1.idw_tabpage[1].Setfocus()			
	RETURN -1
END IF
	
//Step1. Service Order(svcorder) -> Contract Master(contractmst)
b1u_dbmgr3	lu_dbmgr3
lu_dbmgr3 = CREATE b1u_dbmgr3

lu_dbmgr3.is_caller = "b1w_reg_svc_actcancel%save"
lu_dbmgr3.is_title  = Title
lu_dbmgr3.idw_data[1] = tab_1.idw_tabpage[1]
lu_dbmgr3.is_data[1] = ls_termdt

lu_dbmgr3.uf_prc_db_03()
li_rc = lu_dbmgr3.ii_rc

If li_rc < 0 Then
	tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)	
	p_close.TriggerEvent("ue_enable")	
	Destroy lu_dbmgr3
	Return li_rc
End If

tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)

Destroy lu_dbmgr3
f_msg_info(3000,title,"서비스계약철회")

//TriggerEvent("ue_reset")
TriggerEvent("ue_ok")

RETURN 0
end event

event ue_ok();call super::ue_ok;//조회
String ls_orderdt, ls_requestdt, ls_where
Long ll_row

ls_orderdt = String(dw_cond.object.orderdt[1],'yyyymmdd')
ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')


If IsNull(ls_orderdt) Then ls_orderdt = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""

ls_where = ""
ls_where += "svc.status = '" + is_reqcancel + "' "

If ls_orderdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.orderdt,'yyyymmdd') <='" + ls_orderdt + "' "
End If

If ls_requestdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(svc.requestdt,'yyyymmdd') <='" + ls_requestdt + "' "
End If

//ls_where =  ls_where + " And svc.partner = '" + gs_user_group + "' "  //해당 로그인 그룹

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "계약철회신청 내역")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
Else			
	//검색결과가 있으면 Tab을 활성화 시킨다.
	tab_1.Selectedtab = 1
	tab_1.Enabled = True
	dw_cond.Enabled = True
	p_save.TriggerEvent("ue_enable")
	p_ok.TriggerEvent("ue_disable")
End If


end event

event type integer ue_reset();call super::ue_reset;dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())

Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_svc_actcancel
integer x = 64
integer height = 180
string dataobject = "b1dw_cnd_reg_actcancel"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_svc_actcancel
integer x = 2391
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_svc_actcancel
integer x = 2683
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_svc_actcancel
integer height = 256
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_svc_actcancel
integer x = 23
integer y = 272
string dataobject = "b1dw_inq_reg_actcancel"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort)
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_svc_actcancel
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_svc_actcancel
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_svc_actcancel
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_svc_actcancel
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_svc_actcancel
integer y = 836
integer height = 972
end type

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row		
String ls_customerid, ls_payid
Boolean lb_check1, lb_check2

ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

Choose Case newindex
	Case 1
		p_delete.TriggerEvent("ue_enable")
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 2	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 3	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")

End Choose
Return 0
	
end event

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3		//Tab 갯수

//Tab Title
is_tab_title[1] = "계약철회"
is_tab_title[2] = "고객정보"
is_tab_title[3] = "청구정보"

//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_svc_actcancel"
is_dwObject[2] = "b1dw_reg_svcopen_t2"
is_dwObject[3] = "b1dw_reg_svcopen_t3"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_orderno, ls_customerid, ls_payid
String ls_where
Long ll_row
Int li_tab

If al_master_row = 0 Then Return -1

li_tab = ai_select_tabpage

Choose Case li_tab
	Case 1								//Tab 1 - 계약철회
		ls_orderno = String(dw_master.object.svcorder_orderno[al_master_row])
		ls_where = "to_char(svc.orderno) = '" + ls_orderno + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)	
	
	Case 2								//Tab 2 - 고객정보
		ls_customerid = dw_master.object.svcorder_customerid[al_master_row]
		ls_where = "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 3							//Tab 3 - 청구정보
		ls_payid = dw_master.object.customerm_payid[al_master_row]
		ls_where = "customerid = '" + ls_payid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
End Choose


Return 0

end event

event type integer tab_1::ue_tabpage_update(integer oldindex, integer newindex);//****kenn : 1999-05-11 火 *****************************
// Return : -1 Save Error
//           0 Save
//           1 User Abort(Retrieve oldindex)
//           2 System Ignore
//******************************************************
Integer li_return

If oldindex <= 0 Then Return 2
If oldindex = 1 And newindex = 1 Then Return 2
ib_update = True
If tab_1.ib_tabpage_check[oldindex] Then
	tab_1.idw_tabpage[oldindex].AcceptText()
	If (tab_1.idw_tabpage[oldindex].ModifiedCount() > 0) Or &
		(tab_1.idw_tabpage[oldindex].DeletedCount() > 0) Then
		tab_1.SelectedTab = oldindex
		li_return = MessageBox(Tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]" &
					, "Data is Modified.! Do you want to save?", Question!, YesNo!)
		If li_return <> 1 Then
			ib_update = False
			Return 1
		End If
	Else
		ib_update = False
		Return 2
	End If

	li_return = Trigger Event ue_save()
	Choose Case li_return
		Case -1
				ib_update = False
				Return -1
	End Choose

	ib_update = False

End If

Return 0

end event

event type integer tab_1::ue_dw_buttonclicked(integer ai_tabpage, long al_row, long al_actionreturncode, dwobject adwo_dwo);call super::ue_dw_buttonclicked;//Butonn Click

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "상세품목조회"
iu_cust_msg.is_grp_name = "서비스 신청내역 조회/취소"
iu_cust_msg.is_data[1] = string(tab_1.idw_tabpage[1].object.contractmst_contractseq[1])
		
OpenWithParm(b1w_inq_actcancel_popup, iu_cust_msg)

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_svc_actcancel
integer y = 808
end type

