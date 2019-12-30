$PBExportHeader$ubs_w_reg_equipment2.srw
$PBExportComments$[jhchoi] 인증장비관리 - 2009.05.04
forward
global type ubs_w_reg_equipment2 from w_a_reg_m_tm2
end type
type p_1 from u_p_saveas within ubs_w_reg_equipment2
end type
end forward

global type ubs_w_reg_equipment2 from w_a_reg_m_tm2
integer width = 3410
integer height = 2060
event ue_saveas ( )
p_1 p_1
end type
global ubs_w_reg_equipment2 ubs_w_reg_equipment2

type variables
//SN할당대리점
String is_snpartner,	is_not_status[]
end variables

forward prototypes
public function integer wf_maccheck (string as_macaddr)
end prototypes

event ue_saveas;datawindow	ldw

ldw = dw_master

f_excel(ldw)

end event

public function integer wf_maccheck (string as_macaddr);STRING	ls_temp
LONG		ll_length, ll_ascii
INT		ii

ll_length = LenA(as_macaddr)

IF ll_length <> 14 THEN
	Return -1	
END IF

FOR ii = 1 TO ll_length
	ls_temp = MidA(as_macaddr, ii, 1)
	
	ll_ascii = AscA(ls_temp)
	
	IF ll_ascii = 46 OR (ll_ascii >= 48 AND ll_ascii <= 57) OR (ll_ascii >= 97 AND ll_ascii <= 102) OR (ll_ascii >= 65 AND ll_ascii <= 70) THEN
		//숫자 0~9, 대문자 A~F
	ELSE
		RETURN -1
		EXIT
	END IF
NEXT

return 0
end function

on ubs_w_reg_equipment2.create
int iCurrent
call super::create
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
end on

on ubs_w_reg_equipment2.destroy
call super::destroy
destroy(this.p_1)
end on

event ue_ok;call super::ue_ok;LONG		ll_rows,			ll_CONTRACTSEQ
STRING	ls_where
STRING	ls_modelno,		ls_contno_fr,		ls_contno_to,		ls_serialno_fr,		ls_serialno_to,	&
			ls_saledt_fr,	ls_saledt_to,		ls_status,			ls_macaddr,				ls_idatefrom,		&
			ls_idateto,		ls_mv_partner,		ls_adstat,			ls_validkey,			ls_validno,			&
			ls_sale_flag,	ls_macaddr2,		ls_uplus_no

//Condition
ls_modelno		= Trim(dw_cond.Object.modelno[1])
ls_contno_fr	= Trim(dw_cond.Object.contno_fr[1])
ls_contno_to	= Trim(dw_cond.Object.contno_to[1])
ls_serialno_fr	= Trim(dw_cond.Object.serialno_fr[1])
ls_serialno_to	= Trim(dw_cond.Object.serialno_to[1])	
ls_saledt_fr	= Trim(String(dw_cond.Object.saledt_fr[1],"YYYYMMDD"))
ls_saledt_to	= Trim(String(dw_cond.Object.saledt_to[1],"YYYYMMDD"))
ls_status		= Trim(dw_cond.Object.status[1])
ls_macaddr		= LOWER(Trim(dw_cond.Object.macaddr[1]))
ls_macaddr2		= LOWER(Trim(dw_cond.Object.macaddr2[1]))
ls_idatefrom	= Trim(String(dw_cond.Object.idatefrom[1],"YYYYMMDD"))
ls_idateto		= Trim(String(dw_cond.Object.idateto[1],"YYYYMMDD"))
ls_mv_partner	= Trim(dw_cond.Object.mv_partner[1])
ls_adstat		= Trim(dw_cond.Object.adstat[1])
ls_validkey		= Trim(dw_cond.Object.validkey[1])
ls_validno		= Trim(dw_cond.Object.validno[1])	
ls_sale_flag	= Trim(dw_cond.Object.sale_flag[1])
ls_uplus_no		= Trim(dw_cond.Object.dacom_mng_no[1])
		
IF IsNull(ls_modelno)		THEN ls_modelno = ""
IF IsNull(ls_contno_fr)		THEN ls_contno_fr = ""
IF IsNull(ls_contno_to)		THEN ls_contno_to = ""	
IF IsNull(ls_serialno_fr)	THEN ls_serialno_fr = ""
IF IsNull(ls_serialno_to)	THEN ls_serialno_to = ""	
IF IsNull(ls_saledt_fr) 	THEN ls_saledt_fr = ""
IF IsNull(ls_saledt_to) 	THEN ls_saledt_to = ""	
IF IsNull(ls_status) 		THEN ls_status = ""
IF IsNull(ls_macaddr) 		THEN ls_macaddr = ""
IF IsNull(ls_macaddr2) 		THEN ls_macaddr2 = ""
IF IsNull(ls_idatefrom) 	THEN ls_idatefrom = ""
IF IsNull(ls_idateto) 		THEN ls_idateto = ""
IF IsNull(ls_mv_partner) 	THEN ls_mv_partner = ""	
IF IsNull(ls_adstat) 		THEN ls_adstat = ""
IF IsNull(ls_validkey) 		THEN ls_validkey = ""
IF IsNull(ls_validno) 		THEN ls_validno = ""
IF IsNull(ls_sale_flag) 	THEN ls_sale_flag = ""
IF IsNull(ls_uplus_no)		THEN ls_uplus_no = ""

//입력조건이 모두 null이면 에러
IF ls_modelno		= "" AND ls_uplus_no 	= "" AND &
	ls_serialno_fr = "" AND ls_serialno_to = "" AND &
	ls_saledt_fr 	= "" AND ls_saledt_to 	= "" AND &
	ls_status 		= "" AND ls_macaddr 		= "" AND &
	ls_idatefrom 	= "" AND ls_idateto 		= "" AND &
	ls_mv_partner 	= "" AND ls_adstat 		= "" AND &
	ls_validkey 	= "" AND ls_validno 		= "" AND &
	ls_sale_flag 	= "" AND ls_macaddr2		= "" THEN
	
	f_msg_usr_err(200, Title, "조회조건")
	RETURN
	
END IF
	
//Dynamic SQL
ls_where = ""

IF ls_modelno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.MODELNO = '" + ls_modelno + "'"
END IF
	
//2010.11.25 조회조건 제거. 이윤주 대리 요청
//IF ls_contno_fr <> "" THEN
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += " MST.CONTNO >= '" + UPPER(ls_contno_fr) + "' "
//END IF	
//
//IF ls_contno_to <> "" THEN
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += " MST.CONTNO <= '" + UPPER(ls_contno_to) + "' "
//END IF	
//2010.11.25 조회조건 제거 end

//2010.11.25 조회조건 추가. 이윤주 대리 요청
IF ls_uplus_no <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.DACOM_MNG_NO = '" + ls_uplus_no + "' "
END IF	
//2010.11.25 조회조건 추가 end

IF ls_serialno_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " UPPER(MST.SERIALNO) >= '" + UPPER(ls_serialno_fr) + "' "
END IF

IF ls_serialno_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " UPPER(MST.SERIALNO) <= '" + UPPER(ls_serialno_to) + "' "
END IF		

IF ls_saledt_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " TO_CHAR(MST.SALEDT, 'YYYYMMDD') >= '" + ls_saledt_fr + "' " 
END IF	

IF ls_saledt_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " TO_CHAR(MST.SALEDT, 'YYYYMMDD') <= '" + ls_saledt_to + "' " 
END IF		

IF ls_status <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.STATUS = '" + ls_status + "'"
END IF

IF ls_macaddr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.MAC_ADDR = '" + Lower(ls_macaddr) + "'"
END IF		

IF ls_macaddr2 <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.MAC_ADDR2 = '" + Lower(ls_macaddr2) + "'"
END IF			

IF ls_idatefrom <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " TO_CHAR(MST.IDATE, 'YYYYMMDD') >= '" + ls_idatefrom + "' "
END IF

IF ls_idateto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " TO_CHAR(MST.IDATE, 'YYYYMMDD') <= '" + ls_idateto + "' "
END IF

IF ls_mv_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.SN_PARTNER = '" + ls_mv_partner + "'"
END IF

IF ls_adstat <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.ADSTAT = '" + ls_adstat + "'"
END IF	

IF ls_validkey <> "" THEN
	SELECT CONTRACTSEQ INTO :ll_CONTRACTSEQ
	FROM   VALIDKEYMST
	WHERE  VALIDKEY = :ls_validkey;
			
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.CONTRACTSEQ = '" + String(ll_CONTRACTSEQ) + "' "
END IF
	
//	IF ls_validno <> "" THEN
//		IF ls_where <> "" THEN ls_where += " AND "
//		ls_where += " MST.VALIDNO = '" + ls_validno + "' "
//	END IF
	
IF ls_sale_flag <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " MST.SALE_FLAG = '" + ls_sale_flag + "'"
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
	p_1.TriggerEvent("ue_enable")
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
End If
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

//ii_error_chk = -1

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	If tab_1.ib_tabpage_check[li_tab_index] = True Then
		tab_1.idw_tabpage[li_tab_index].AcceptText() 
	
		If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
			(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
			tab_1.SelectedTab = li_tab_index
			li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
						,Question!,YesNo!)
			If li_rc <> 1 Then
				Return LI_ERROR
			End If
		End If
	End If
Next

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_1.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.ib_tabpage_check[li_tab_index] = False
Next

dw_master.Reset()
dw_cond.Enabled = True
//dw_cond.Reset()
//dw_cond.InsertRow(0)
dw_cond.SetFocus()
tab_1.enabled = False

ib_retrieve = FALSE

//ii_error_chk = 0
Return 0
end event

event open;call super::open;STRING	ls_ref_desc,	ls_temp

tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(off!)

dw_cond.Object.mv_partner[1] = gs_shopid
//dw_cond.Object.saledt_fr[1] = DATE(fdt_get_dbserver_now())
//dw_cond.Object.idatefrom[1] = DATE(fdt_get_dbserver_now())

p_reset.TriggerEvent("ue_enable")

//TAB1 장비상태값 변경 못하는 값들.
//ls_ref_desc = ""
//ls_temp = ""
//ls_temp = fs_get_control("U0", "S700", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";", is_not_status[])
end event

event ue_save;//Override
Constant Int LI_ERROR = -1
Int li_tab_index, li_return
String ls_snpartner
Date ldt_null

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

IF li_tab_index = 1 THEN
   //Update정보
	tab_1.idw_tabpage[li_tab_index].Object.updt_user[1] = gs_user_id
	tab_1.idw_tabpage[li_tab_index].Object.updtdt[1] = fdt_get_dbserver_now()
	
	//S/N변경정보
	ls_snpartner = Trim(tab_1.idw_tabpage[li_tab_index].Object.sn_partner[1])
	IF is_snpartner <> ls_snpartner THEN
		IF ls_snpartner = "" THEN
			SetNull(ldt_null)
			tab_1.idw_tabpage[li_tab_index].Object.snmovedt[1] = ldt_null
		ELSE
			tab_1.idw_tabpage[li_tab_index].Object.snmovedt[1] = fdt_get_dbserver_now()
		END IF
	END If
	
END IF


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

//tab_1.idw_tabpage[li_tab_index].Retrieve()
//tab_1.idw_tabpage[li_tab_index].ResetUpdate()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

RETURN 0
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
Integer	li_index

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (tab_1.Y + iu_cust_w_resize.ii_button_space) Then
	tab_1.Height = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = 0
	Next

	p_insert.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= tab_1.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	tab_1.Height = newheight - tab_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Height = tab_1.Height - 130
	Next

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
End If

If newwidth < tab_1.X  Then
	tab_1.Width = 0
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = 0
	Next
Else
	tab_1.Width = newwidth - tab_1.X - iu_cust_w_resize.ii_dw_button_space
	For li_index = 1 To tab_1.ii_enable_max_tab
		tab_1.idw_tabpage[li_index].Width = tab_1.Width - 50
	Next
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within ubs_w_reg_equipment2
integer x = 41
integer y = 20
integer width = 2720
integer height = 460
string dataobject = "ubs_dw_reg_equipment_cond"
end type

event dw_cond::itemchanged;call super::itemchanged;LONG ll_return

THIS.AcceptText()

IF dwo.name = "macaddr" THEN
	ll_return = wf_maccheck(data)

	IF ll_return < 0 THEN
		f_msg_usr_err(200, Title, "MAC Address Error")
		Object.macaddr[row] = ""
		RETURN 2
	END IF
	
END IF
	
end event

type p_ok from w_a_reg_m_tm2`p_ok within ubs_w_reg_equipment2
integer x = 3013
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_reg_m_tm2`p_close within ubs_w_reg_equipment2
integer x = 338
integer y = 1816
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within ubs_w_reg_equipment2
integer x = 27
integer width = 3314
integer height = 488
integer textsize = -2
end type

type dw_master from w_a_reg_m_tm2`dw_master within ubs_w_reg_equipment2
integer x = 23
integer y = 500
integer width = 3314
integer height = 520
string dataobject = "ubs_dw_reg_equipment_mas"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort
ldwo_sort = Object.equipseq_t
uf_init( ldwo_sort )

end event

event dw_master::clicked;call super::clicked;//마지막에 선택된 Row로 간다.
tab_1.Trigger Event SelectionChanged(1,Tab_1.SelectedTab)

end event

type p_insert from w_a_reg_m_tm2`p_insert within ubs_w_reg_equipment2
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within ubs_w_reg_equipment2
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within ubs_w_reg_equipment2
boolean visible = false
integer x = 1061
integer y = 1824
end type

type p_reset from w_a_reg_m_tm2`p_reset within ubs_w_reg_equipment2
integer x = 23
integer y = 1816
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within ubs_w_reg_equipment2
integer x = 23
integer y = 1052
integer width = 3301
integer height = 728
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3		//Tab 갯수
//Tab Title
is_tab_title[1] = "Equip. Infomation"
is_tab_title[2] = "Equip. History"
is_tab_title[3] = "Equip. Validation History"


//Tab에 해당하는 dw
is_dwObject[1] = "ubs_dw_reg_equipment_tab5"
is_dwObject[2] = "ubs_dw_reg_equipment_tab4"
is_dwObject[3] = "ubs_dw_reg_equipment_tab3"






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

		
	Case 2	


End Choose
Return 0
	
end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
STRING	ls_equipseq,		ls_mac_addr,		ls_where,		ls_status
LONG		ll_row,				ll_not_cnt
INTEGER	li_tab,				li_i

li_tab = ai_select_tabpage

IF al_master_row = 0 THEN RETURN -1

ls_equipseq = Trim(STRING(dw_master.object.equipseq[al_master_row]))
ls_mac_addr = Trim(STRING(dw_master.object.mac_addr[al_master_row]))


CHOOSE CASE li_tab
	CASE 1								//Tab 1
		ls_where = " MST.EQUIPSEQ = '" + ls_equipseq + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		IF ll_row < 0 THEN
			f_msg_usr_err(2100, PARENT.Title, "Retrieve()")
			RETURN -1
		END IF
		
		is_snpartner = Trim(idw_tabpage[li_tab].Object.sn_partner[1])
		ls_status	 = Trim(idw_tabpage[li_tab].Object.status[1])
		
//		//변경불가한 상태 체크해서 막기
//		FOR li_i = 1 TO UpperBound(is_not_status[])
//			IF ls_status = is_not_status[li_i] THEN
//				ll_not_cnt = ll_not_cnt + 1
//			END IF
//		NEXT
//		
//		IF ll_not_cnt > 0 THEN
//			idw_tabpage[li_tab].Object.status.protect = 1
//		ELSE
//			idw_tabpage[li_tab].Object.status.protect = 0
//		END IF	
		
		p_save.TriggerEvent("ue_enable")
	
	CASE 3								//Tab 3
		ls_where = " MACADDRESS = '" + ls_mac_addr + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		p_save.TriggerEvent("ue_disable")

End Choose


Return 0

end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within ubs_w_reg_equipment2
integer x = 14
integer y = 1020
end type

type p_1 from u_p_saveas within ubs_w_reg_equipment2
integer x = 3013
integer y = 212
boolean bringtotop = true
boolean originalsize = false
end type

