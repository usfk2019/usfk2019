$PBExportHeader$b1w_reg_act_confirm.srw
$PBExportComments$[kem] 구매확인call - Window
forward
global type b1w_reg_act_confirm from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_act_confirm from w_a_reg_m_tm2
integer height = 2024
end type
global b1w_reg_act_confirm b1w_reg_act_confirm

type variables
String  is_svcorder, is_svccod, is_customerid, is_payerid
String  is_beforeOpen, is_openning, is_gumaejung, is_beforestatus


Boolean ib_check, ib_save, ib_ok
end variables

on b1w_reg_act_confirm.create
int iCurrent
call super::create
end on

on b1w_reg_act_confirm.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where, ls_ref_desc, ls_status
String	ls_orderno	//Fetched Data1
String	ls_svcorderno, ls_svccod, ls_customerid, ls_payerid //Fetched Data2
String	ls_gumae	   //구매확인코드
Long li_rc

dw_cond.Accepttext()
ls_status = dw_cond.Object.status[1]
If Isnull(ls_status) Then
	f_msg_info(200, Title, "구분")
	dw_cond.SetColumn("status")
	dw_cond.Setfocus()					
	RETURN 	 
End if	
		
If ls_status = '1' Then
	//개통신청코드
	is_beforeOpen = fs_get_control("B0","P220", ls_ref_desc)
Elseif ls_status = '2' Then
	//구매재확인중
	is_beforeOpen = fs_get_control("B0","P228", ls_ref_desc)
End if
	
//구매확인 처리중코드
is_openning = fs_get_control("B0","P227", ls_ref_desc)

b1u_dbmgr2	lu_dbmgr2
lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_act_confirm_cl%ok"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.is_data[1] = is_beforeopen
lu_dbmgr2.is_data[2] = is_openning
lu_dbmgr2.is_data[7] = ls_status
//lu_dbmgr2.is_data[3] = is_svcorder
//lu_dbmgr2.is_data[4] = is_customerid
//lu_dbmgr2.is_data[5] = is_payerid
//lu_dbmgr2.is_data[6] = is_svccod

lu_dbmgr2.ib_data[1] = ib_ok

lu_dbmgr2.uf_prc_db_05()
ib_ok = lu_dbmgr2.ib_data[1]
li_rc = lu_dbmgr2.ii_rc

If li_rc < 0 Then
	tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy lu_dbmgr2
	Return 
End If

is_svcorder = lu_dbmgr2.is_data[3]
is_customerid = lu_dbmgr2.is_data[4]
is_payerid = lu_dbmgr2.is_data[5]
is_svccod = lu_dbmgr2.is_data[6]
ib_ok = lu_dbmgr2.ib_data[1]

Destroy lu_dbmgr2

IF is_svcorder <> "" THEN	//검색결과가 있으면 Tab을 활성화 시킨다.
	//Retrieve
	Long ll_rows
	
	dw_master.is_where = "to_char(orderno) = '" + is_svcorder + "' "
	ll_rows = dw_master.Retrieve()
	If ll_rows = 0 Then
		//f_msg_info(1000, Title, "")
	ElseIf ll_rows < 0 Then
		//f_msg_usr_err(2100, Title, "")
		//Return
	Else			
		//검색결과가 있으면 Tab을 활성화 시킨다.
		tab_1.Selectedtab = 1
		tab_1.Enabled = True
		tab_1.idw_tabpage[1].Enabled = True
		p_save.TriggerEvent("ue_enable")
		p_ok.TriggerEvent("ue_disable")
		p_close.TriggerEvent("ue_disable")
	End If
END IF
end event

event open;call super::open;String ls_lock
String ls_before
String ls_desc

//로그인아이디로 구매확인중인 DATA가 있으면 신청완료로 변경해준다.
//1.구매확인중(Sysctrl-B0:P231)
ls_lock = fs_get_control('B0','P227',ls_desc)

//2.신청완료(Sysctrl-B0:P220)
ls_before = fs_get_control('B0','P220',ls_desc)

UPDATE svcorder
SET status = :ls_before
WHERE status = :ls_lock AND updt_user = :gs_user_id;

IF SQLCA.SqlCode < 0 THEN
	ROLLBACK;
ELSE
	COMMIT;
END IF


tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(off!)

p_save.TriggerEvent("ue_disable")

ib_check = True
ib_save = False
ib_ok = False


end event

event type integer ue_save();tab_1.idw_tabpage[1].AcceptText()

Int		li_rc
String	ls_phone
String	ls_activedt, ls_actflag

If tab_1.idw_tabpage[1].RowCount() = 0 Then Return 0

ls_actflag = Trim(tab_1.idw_tabpage[1].Object.actflag[1])

IF IsNull(ls_actflag) THEN ls_actflag = ""

IF ls_actflag = "" THEN
	f_msg_info(200, Title, "작업구분")
	tab_1.idw_tabpage[1].SetColumn("actflag")
	tab_1.idw_tabpage[1].Setfocus()					
	RETURN -1
END IF
	
//Step1. Service Order(svcorder) -> Contract Master(contractmst)
b1u_dbmgr2	lu_dbmgr2
lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_act_confirm_cl%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = tab_1.idw_tabpage[1]
lu_dbmgr2.is_data[1] = ls_actflag

lu_dbmgr2.uf_prc_db_05()
li_rc = lu_dbmgr2.ii_rc

If li_rc < 0 Then
	tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)	
	p_close.TriggerEvent("ue_enable")
	Destroy lu_dbmgr2
	Return li_rc
End If

ib_save = TRUE
Destroy lu_dbmgr2

tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)
f_msg_info(3000,title,"구매확인Call")

String ls_cond 
ls_cond = dw_cond.Object.status[1]
TriggerEvent("ue_reset")
dw_cond.Object.status[1] = ls_cond
//TriggerEvent("ue_ok")

RETURN 0
end event

event type integer ue_reset();call super::ue_reset;//주문번호
is_svcorder = ""
//서비스코드
is_svccod = ""
//고객번호
is_customerid = ""
//납입자번호
is_payerid = ""

dw_cond.reset()
dw_cond.insertRow(0)
dw_cond.Enabled = True

p_save.TriggerEvent("ue_disable")
p_close.TriggerEvent("ue_enable")
p_ok.TriggerEvent("ue_enable")

ib_ok = False
ib_save = False

RETURN 0
end event

event type integer ue_delete();//Overiding

RETURN 0
end event

event closequery;call super::closequery;IF ib_ok = True Then
	If ib_save = False then
		If b1f_update_pre_svcstatus(is_svcorder,is_beforeOpen) = -1 Then
			return -1
		End if
	End if
End if
	
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_act_confirm
integer x = 59
integer y = 52
integer width = 1065
integer height = 144
string dataobject = "b1dw_cnd_act_comfirm"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_act_confirm
integer x = 1257
integer y = 64
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_act_confirm
integer x = 1563
integer y = 64
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_act_confirm
integer width = 1111
integer height = 232
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_act_confirm
boolean visible = false
integer x = 5
integer y = 36
integer width = 2537
integer height = 152
boolean enabled = false
string dataobject = "b1dw_inq_svcopen"
end type

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_act_confirm
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_act_confirm
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_act_confirm
integer x = 41
integer y = 1796
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_act_confirm
boolean visible = false
integer x = 585
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_act_confirm
integer y = 300
integer height = 1432
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 4		//Tab 갯수

//Tab Title
is_tab_title[1] = "개통정보"
is_tab_title[2] = "고객정보"
is_tab_title[3] = "청구정보"
is_tab_title[4] = "인증정보"

//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_act_confirm"
is_dwObject[2] = "b1dw_reg_svcopen_t2"
is_dwObject[3] = "b1dw_reg_svcopen_t3"
is_dwObject[4] = "b1dw_reg_svcopen_t4"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_orderno
String ls_where
Long ll_row
Int li_tab

If al_master_row = 0 Then Return -1

li_tab = ai_select_tabpage

Choose Case li_tab
	Case 1								//Tab 1 - 개통정보
		ls_where = "to_char(svc.orderno) = '" + is_svcorder + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
//		idw_tabpage[1].Object.activedt[1] = fdt_get_dbserver_now()
//		idw_tabpage[1].Object.bil_fromdt[1] = fdt_get_dbserver_now()
		
		idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)	
	
	Case 2								//Tab 2 - 고객정보
		ls_where = "customerid = '" + is_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 3							//Tab 3 - 청구정보

		ls_where = "customerid = '" + is_payerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
	
	Case 4							//Tab 3 - 인증정보

		ls_where = "customerid = '" + is_payerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If

End Choose


Return 0

end event

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
		
		If ib_check Then
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_disable")
	   	ib_check = False
		End If
		
	Case 2	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 3	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
	Case 4	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		
End Choose
Return 0
	
end event

event type integer tab_1::ue_dw_buttonclicked(integer ai_tabpage, long al_row, long al_actionreturncode, dwobject adwo_dwo);call super::ue_dw_buttonclicked;//Butonn Click

If adwo_dwo.name = "b_item" Then
	iu_cust_msg = Create u_cust_a_msg
	iu_cust_msg.is_pgm_name = "상세품목조회"
	iu_cust_msg.is_grp_name = "서비스 신청내역 조회/취소"
	iu_cust_msg.is_data[1] = is_svcorder
		
	OpenWithParm(b1w_inq_popup_svcorderitem, iu_cust_msg)
	
ElseIf adwo_dwo.name = "b_admodel" Then
	iu_cust_msg = Create u_cust_a_msg
	iu_cust_msg.is_pgm_name = "상세장비조회"
	iu_cust_msg.is_grp_name = "구매확인Call 조회"
	iu_cust_msg.is_data[1] = is_svcorder
		
	OpenWithParm(b1w_inq_popup_svcorderad, iu_cust_msg)
	
End If

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

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_act_confirm
integer x = 18
integer y = 244
integer height = 40
end type

