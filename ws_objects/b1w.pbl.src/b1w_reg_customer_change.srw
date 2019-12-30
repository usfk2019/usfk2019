$PBExportHeader$b1w_reg_customer_change.srw
$PBExportComments$[kem] 명의변경
forward
global type b1w_reg_customer_change from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_customer_change from w_a_reg_m_tm2
end type
global b1w_reg_customer_change b1w_reg_customer_change

type variables
String is_reqchange	//명의변경신청코드
String is_change	 	//명의변경완료코드
String is_failed		//명의변경실패코드

end variables

event open;call super::open;String ls_status, ls_ref_desc
is_reqchange = ""	//명의변경신청코드
is_change = ""	 	//명의변경완료코드

//명의변경신청코드(B0:P245)
is_reqchange = fs_get_control("B0", "P245", ls_ref_desc)
//명의변경완료코드(B0:P247)
is_change = fs_get_control("B0", "P247", ls_ref_desc)
//명의변경실패코드(B0:P248)
is_failed = fs_get_control("B0", "P248", ls_ref_desc)

tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[4].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[5].SetRowFocusIndicator(off!)

TriggerEvent("ue_reset")

//dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
//dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())

end event

on b1w_reg_customer_change.create
int iCurrent
call super::create
end on

on b1w_reg_customer_change.destroy
call super::destroy
end on

event type integer ue_delete();//Overiding

RETURN 0
end event

event type integer ue_save();tab_1.idw_tabpage[1].AcceptText()

If tab_1.idw_tabpage[1].RowCount() = 0 Then Return 0

Int		li_rc
String ls_type, ls_remark, ls_actnum, ls_banno
String ls_errmsg,ls_pgm_id
DOUBLE ld_return,ld_count, ld_orderno

tab_1.idw_tabpage[1].AcceptText()
ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ld_orderno = DOUBLE(tab_1.idw_tabpage[1].object.svcorder_orderno[1])

If tab_1.idw_tabpage[1].RowCount() = 0 Then Return 0

ls_type = Trim(tab_1.idw_tabpage[1].object.type[1])
ls_remark = Trim(tab_1.idw_tabpage[1].object.svcorder_remark[1])
ls_actnum = Trim(tab_1.idw_tabpage[1].object.actnum[1])
ls_banno = Trim(tab_1.idw_tabpage[1].object.contractmst_banno[1])

IF IsNull(ls_type) THEN ls_type = ""
IF IsNull(ls_actnum) Then ls_actnum = ""
IF IsNull(ls_banno) Then ls_banno = ""

IF ls_type = "" THEN
	f_msg_info(200, Title, "작업구분")
	tab_1.idw_tabpage[1].SetColumn("type")
	tab_1.idw_tabpage[1].Setfocus()					
	RETURN -1
END IF


If ls_type = "2" Then 		//실패
	Update svcorder
	Set status = :is_failed
	Where orderno = :ld_orderno;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Update Svcorder")
		Return -1
	End If
Else
	
	IF ls_banno = "" THEN
		f_msg_info(200, Title, "BAN번호")
		tab_1.idw_tabpage[1].SetColumn("contractmst_banno")
		tab_1.idw_tabpage[1].Setfocus()					
		RETURN -1
	END IF
	
		//프로시저 Call
//subroutine CUSTOMERCHANGE(double P_ORDERNO,string P_NEWPID,string P_BANNO,string P_REMARK,string P_USER,string P_PGMID,ref double P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"COMN~".~"CUSTOMERCHANGE~""
SQLCA.customerchange(ld_orderno, ls_actnum, ls_banno, ls_remark, gs_user_id, ls_pgm_id, ld_return, ls_errmsg, ld_count)
	
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
		p_close.TriggerEvent("ue_enable")
		Return -1
		
	ElseIf ld_return < 0 Then	//For User
		MessageBox(This.Title, ls_errmsg, StopSign!)
		p_close.TriggerEvent("ue_enable")
		Return -1
		
	End If
End If


//성공
tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)   //조회 되지 않게..
f_msg_info(3000,title,"명의 변경처리")
//TriggerEvent("ue_reset")
TriggerEvent("ue_ok")

Return 0 
end event

event ue_ok();call super::ue_ok;//조회
String ls_orderdt, ls_requestdt, ls_where
Long ll_row

//ls_orderdt = String(dw_cond.object.orderdt[1],'yyyymmdd')
//ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')


//If IsNull(ls_orderdt) Then ls_orderdt = ""
//If IsNull(ls_requestdt) Then ls_requestdt = ""

ls_where = ""
ls_where += "svc.status = '" + is_reqchange + "' "

//If ls_orderdt <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "to_char(svc.orderdt,'yyyymmdd') <='" + ls_orderdt + "' "
//End If
//
//If ls_requestdt <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "to_char(svc.requestdt,'yyyymmdd') <='" + ls_requestdt + "' "
//End If
//

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "명의변경신청 내역")
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

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_customer_change
boolean visible = false
integer x = 23
integer y = 24
end type

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_customer_change
integer x = 2313
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_customer_change
integer x = 2610
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_customer_change
boolean visible = false
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_customer_change
integer x = 23
integer y = 256
integer width = 3026
string dataobject = "b1dw_inq_reg_customer_change"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort)
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_customer_change
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_customer_change
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_customer_change
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_customer_change
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_customer_change
integer y = 820
integer width = 3022
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
		
	Case 4	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
	
	Case 5	
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
End Choose
Return 0
	
end event

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 5		//Tab 갯수

//Tab Title
is_tab_title[1] = "명의신청정보"
is_tab_title[2] = "변경고객정보"
is_tab_title[3] = "변경청구정보"
is_tab_title[4] = "기존고객정보"
is_tab_title[5] = "기존청구정보"

//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_customer_change_t1"
is_dwObject[2] = "b1dw_reg_svcopen_t2"
is_dwObject[3] = "b1dw_reg_svcopen_t3"
is_dwObject[4] = "b1dw_reg_svcopen_t2"
is_dwObject[5] = "b1dw_reg_svcopen_t3"


end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_orderno
String ls_ref_contractseq
String ls_old_customerid, ls_old_payid
String ls_new_customerid, ls_new_payid
String ls_where
Long ll_row
Int li_tab

If al_master_row = 0 Then Return -1

li_tab = ai_select_tabpage


Choose Case li_tab
	Case 1								//Tab 1 - 명변 신청 정보
		ls_orderno = String(dw_master.object.svcorder_orderno[al_master_row])
		ls_where = "svc.orderno = '" + ls_orderno + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()
		//자료가 없을때
		If ll_row = 0 Then
			f_msg_info(1000, title, "")
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, title, "Retrieve()")
			Return -1
		End If
  Case 2								//Tab 2 - 변경고객정보
		ls_new_customerid = TRIM(dw_master.object.svcorder_new_customerid[al_master_row])
		ls_where = "customerid = '" + ls_new_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 3							//Tab 3 - 변경청구정보
		ls_new_payid = TRIM(dw_master.object.customerm_new_payid[al_master_row])
		ls_where = "customerid = '" + ls_new_payid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 4							//Tab 4 - 기존 고객정보
		ls_old_customerid = TRIM(dw_master.object.customerm_old_customerid[al_master_row])
		ls_where = "customerid = '" + ls_old_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
	Case 5							//Tab5 - 기존 청구 정보
		ls_old_payid = TRIM(dw_master.object.customerm_old_payid[al_master_row])
		ls_where = "customerid = '" + ls_old_payid + "' "
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
String ls_ref_contractseq, ls_orderno

ls_ref_contractseq = String(tab_1.idw_tabpage[1].object.contractmst_contractseq[1])

Select To_Char(Min(orderno))
  Into :ls_orderno
  From svcorder
 where ref_contractseq = :ls_ref_contractseq;

If SQLCA.SQLCode < 0 Then
	f_msg_usr_err(9000, Title, "Select Error(상세장비조회)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	f_msg_info(9000, Title, "계약SEQ에 해당하는 신청번호 Select Error")
	Return -1
End If

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "상세장비조회"
iu_cust_msg.is_grp_name = "명의변경(MVNO)"
iu_cust_msg.is_data[1]  = ls_orderno
		
OpenWithParm(b1w_inq_popup_svcorderad, iu_cust_msg)

Return 0 
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_customer_change
integer y = 792
end type

