$PBExportHeader$b1w_reg_svc_actprc_mvno.srw
$PBExportComments$[kem] 서비스개통처리(MVNO) - Window
forward
global type b1w_reg_svc_actprc_mvno from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_svc_actprc_mvno from w_a_reg_m_tm2
end type
global b1w_reg_svc_actprc_mvno b1w_reg_svc_actprc_mvno

type variables
String	is_svcorder,is_svccod,is_customerid,is_payerid, is_beforeopen, is_openning
Boolean ib_check, ib_ok, ib_save, ib_ins
end variables

on b1w_reg_svc_actprc_mvno.create
int iCurrent
call super::create
end on

on b1w_reg_svc_actprc_mvno.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String	ls_where
integer li_rc

String ls_desc, ls_inssvccod[]
Int	 li_result, li_cnt

//개통처리중코드
SELECT ref_content
INTO :is_openning
FROM sysctl1t
WHERE module = 'B0' AND ref_no = 'P230';

//구매확인코드
SELECT ref_content
INTO :is_beforeopen
FROM sysctl1t
WHERE module = 'B0' AND ref_no = 'P229';

b1u_dbmgr2	lu_dbmgr2
lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_svc_actprc_mvno%ok"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.is_data[1] = is_beforeopen
lu_dbmgr2.is_data[2] = is_openning
//lu_dbmgr2.is_data[3] = is_svcorder
//lu_dbmgr2.is_data[4] = is_customerid
//lu_dbmgr2.is_data[5] = is_payerid
//lu_dbmgr2.is_data[6] = is_svccod
lu_dbmgr2.ib_data[1] = ib_ok

lu_dbmgr2.uf_prc_db_05()
li_rc = lu_dbmgr2.ii_rc

//에러발생
If li_rc < 0 Then
	tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)
	MessageBox(Title, "에러발생("+ String(li_rc) +") 관리자에게 문의하십시오.")
	Destroy lu_dbmgr2
	Return
ELSEIF li_rc = 1 THEN
	tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)
	MessageBox(Title, "신규 개통신청 정보가 없습니다.")
	Destroy lu_dbmgr2
	Return
End If


//Return 값을 받아온다.
is_svcorder   = lu_dbmgr2.is_data[3]
is_customerid = lu_dbmgr2.is_data[4]
is_payerid    = lu_dbmgr2.is_data[5]
is_svccod     = lu_dbmgr2.is_data[6]
ib_ok         = lu_dbmgr2.ib_data[1]

Destroy lu_dbmgr2

IF is_svcorder <> "" THEN	//검색결과가 있으면 Tab을 활성화 시킨다.

	Long ll_rows
	
	dw_master.is_where = "orderno = '" + is_svcorder + "' "
	ll_rows = dw_master.Retrieve()
	If ll_rows = 0 Then
		//f_msg_info(1000, Title, "")
	ElseIf ll_rows < 0 Then
		//f_msg_usr_err(2100, Title, "")
		//Return
	Else			
		//검색결과가 있으면
		//서비스코드(svccod)가 '보증보험가입대상 서비스'(sysctl1t B0:P001)인지 확인
//		li_result = fi_cut_string(fs_get_control("B0","P001",ls_desc),";",ls_inssvccod)
//		
//		ib_ins = FALSE
//		
//		FOR li_cnt = 1 TO li_result
//			IF(is_svccod = ls_inssvccod[li_cnt]) THEN
//				ib_ins = TRUE
//				EXIT
//			END IF
//		NEXT
		
		//Tab을 활성화 시킨다.
		tab_1.Selectedtab = 1
		tab_1.Enabled = True
		dw_cond.Enabled = True
		p_save.TriggerEvent("ue_enable")
		p_ok.TriggerEvent("ue_disable")
		p_close.TriggerEvent("ue_disable")		
		
	End If

ELSE	
	//tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)
	MessageBox(Title, "신규 개통신청 정보가 없습니다.")
END IF
end event

event open;call super::open;tab_1.idw_tabpage[1].SetRowFocusIndicator(off!)
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
String	ls_phone, ls_phone1, ls_phone2, ls_banno
String	ls_activedt, ls_actflag
Int		li_insmonths

String	ls_today

If tab_1.idw_tabpage[1].RowCount() = 0 Then Return 0

ls_phone = Trim(tab_1.idw_tabpage[1].Object.phone[1])
ls_phone1 = Trim(tab_1.idw_tabpage[1].Object.phone1[1])
ls_phone2 = Trim(tab_1.idw_tabpage[1].Object.phone2[1])
ls_banno = Trim(tab_1.idw_tabpage[1].Object.banno[1])
ls_activedt = Trim(String(tab_1.idw_tabpage[1].Object.activedt[1],"YYYYMMDD"))
ls_actflag = Trim(tab_1.idw_tabpage[1].Object.actflag[1])
li_insmonths = tab_1.idw_tabpage[1].Object.insmonths[1]

ls_today = Trim(String(fdt_get_dbserver_now(),"YYYYMMDD"))

IF IsNull(ls_phone) THEN ls_phone = ""
IF IsNull(ls_banno) THEN ls_banno = ""
IF IsNull(ls_activedt) THEN ls_activedt = ""
IF IsNull(ls_actflag) THEN ls_actflag = ""


IF ls_actflag = "" THEN
	f_msg_info(200, Title, "개통구분")
	tab_1.idw_tabpage[1].SetColumn("actflag")
	tab_1.idw_tabpage[1].Setfocus()					
	RETURN -1
END IF

If ls_actflag = '1' Then
	IF ls_phone = "" THEN
		f_msg_info(200, Title, "개통번호")
		tab_1.idw_tabpage[1].SetColumn("phone")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	Elseif Isnumber(ls_phone) = False Then
		f_msg_info(9000, Title, "개통번호는 숫자만 입력가능!!")
		tab_1.idw_tabpage[1].SetColumn("phone")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	END IF
	
	IF ls_phone1 = "" THEN
		f_msg_info(200, Title, "개통번호")
		tab_1.idw_tabpage[1].SetColumn("phone1")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	Elseif Isnumber(ls_phone1) = False Then
		f_msg_info(9000, Title, "개통번호는 숫자만 입력가능!!")
		tab_1.idw_tabpage[1].SetColumn("phone1")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	END IF
	
	IF ls_phone2 = "" THEN
		f_msg_info(200, Title, "개통번호")
		tab_1.idw_tabpage[1].SetColumn("phone2")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	Elseif Isnumber(ls_phone2) = False Then
		f_msg_info(9000, Title, "개통번호는 숫자만 입력가능!!")
		tab_1.idw_tabpage[1].SetColumn("phone2")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	END IF
	
	IF ls_banno = "" THEN
		f_msg_info(200, Title, "BAN번호")
		tab_1.idw_tabpage[1].SetColumn("banno")
		tab_1.idw_tabpage[1].Setfocus()						
		RETURN -1
	END IF
	
	IF ls_activedt = "" THEN
		f_msg_info(200, Title, "개통일자")
		tab_1.idw_tabpage[1].SetColumn("activedt")
		tab_1.idw_tabpage[1].Setfocus()			
		RETURN -1
	END IF
	
	IF ls_activedt < ls_today THEN
		f_msg_info(200, Title, "개통일자는 오늘날짜 이후여야 합니다.")
		tab_1.idw_tabpage[1].SetColumn("activedt")
		tab_1.idw_tabpage[1].Setfocus()			
		RETURN -1
	END IF
	
//	IF ib_ins AND IsNull(li_insmonths) THEN
//		f_msg_info(200, Title, "보증보험가입월수")
//		tab_1.idw_tabpage[1].SetColumn("insmonths")
//		tab_1.idw_tabpage[1].Setfocus()			
//		RETURN -1
//	END If
end if


//Step1. Service Order(svcorder) -> Contract Master(contractmst)
b1u_dbmgr2	lu_dbmgr2
lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_svc_actprc_mvno%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = tab_1.idw_tabpage[1]
lu_dbmgr2.is_data[1] = ls_phone + "-" + ls_phone1 + "-" + ls_phone2
lu_dbmgr2.is_data[2] = ls_actflag
lu_dbmgr2.ii_data[1]	= li_insmonths

lu_dbmgr2.uf_prc_db_05()
li_rc = lu_dbmgr2.ii_rc

If li_rc < 0 Then
	tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)	
	p_close.TriggerEvent("ue_enable")
	Destroy lu_dbmgr2
	Return li_rc
End If

ib_save = True
tab_1.idw_tabpage[1].SetItemStatus(1, 0, Primary!, NotModified!)
Destroy lu_dbmgr2

//f_msg_info(3000,title,"개통처리")

TriggerEvent("ue_reset")
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
dw_cond.Enabled = False

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
		If b1f_update_pre_svcstatus(is_svcorder,is_beforeopen) = -1 Then
			return -1
		End if
	End if
End if
	
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_svc_actprc_mvno
boolean visible = false
integer x = 23
integer y = 24
integer width = 2441
integer height = 148
boolean enabled = false
string dataobject = "b1dw_cnd_svcopen"
end type

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_svc_actprc_mvno
integer x = 2450
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_svc_actprc_mvno
integer x = 2752
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_svc_actprc_mvno
boolean visible = false
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_svc_actprc_mvno
boolean visible = false
integer x = 5
integer y = 36
integer width = 2281
integer height = 128
boolean enabled = false
string dataobject = "b1dw_inq_svcopen"
end type

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_svc_actprc_mvno
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_svc_actprc_mvno
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_svc_actprc_mvno
integer x = 69
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_svc_actprc_mvno
boolean visible = false
integer x = 585
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_svc_actprc_mvno
integer y = 196
integer height = 1456
long backcolor = 12632256
end type

event tab_1::ue_init();call super::ue_init;//Tab 초기화
ii_enable_max_tab = 4		//Tab 갯수

//Tab Title
is_tab_title[1] = "개통정보"
is_tab_title[2] = "고객정보"
is_tab_title[3] = "청구정보"
is_tab_title[4] = "인증정보"

//Tab에 해당하는 dw
is_dwObject[1] = "b1dw_reg_svcopen_t1"
is_dwObject[2] = "b1dw_reg_svcopen_t2"
is_dwObject[3] = "b1dw_reg_svcopen_t3"
is_dwObject[4] = "b1dw_reg_svcopen_t4"

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
String ls_orderno
String ls_where
Long ll_row
Int li_tab
Long ll_quotamonths, ll_orderno
String ls_quotainfo
DEC ldc_tramt
String ls_trcod, ls_desc

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
		
		idw_tabpage[1].Object.activedt[1] = fdt_get_dbserver_now()
		idw_tabpage[1].Object.bil_fromdt[1] = fdt_get_dbserver_now()
		idw_tabpage[1].Object.phone.Color = RGB(255, 255, 255)		
		idw_tabpage[1].Object.phone.Background.Color = 9016172  //RGB(0, 128, 128)
		idw_tabpage[1].Object.phone.Protect = 0
		idw_tabpage[1].Object.phone1.Color = RGB(255, 255, 255)		
		idw_tabpage[1].Object.phone1.Background.Color = 9016172  //RGB(0, 128, 128)
		idw_tabpage[1].Object.phone1.Protect = 0
		idw_tabpage[1].Object.phone2.Color = RGB(255, 255, 255)		
		idw_tabpage[1].Object.phone2.Background.Color = 9016172  //RGB(0, 128, 128)
		idw_tabpage[1].Object.phone2.Protect = 0
		idw_tabpage[1].Object.activedt.Color = RGB(255, 255, 255)		
		idw_tabpage[1].Object.activedt.Background.Color = 9016172  //RGB(0, 128, 128)
		idw_tabpage[1].Object.activedt.Protect = 0					
		idw_tabpage[1].Object.contract_no.Color = RGB(0, 0, 255)		
		idw_tabpage[1].Object.contract_no.Background.Color = RGB(255, 255, 255)
		idw_tabpage[1].Object.contract_no.Protect = 0			
		idw_tabpage[1].Object.bil_fromdt.Color = RGB(0, 0, 255)							
		idw_tabpage[1].Object.bil_fromdt.Background.Color = RGB(255, 255, 255)
		idw_tabpage[1].Object.bil_fromdt.Protect = 0		

		IF(ib_ins) THEN
			idw_tabpage[1].Object.insmonths.Color = RGB(255, 255, 255)		
			idw_tabpage[1].Object.insmonths.Background.Color = 9016172  //RGB(0, 128, 128)
		END IF
		
		
		//#할부정보 가져오기
		SELECT count(*)
		INTO :ll_quotamonths
		FROM quota_info
		WHERE orderno = :is_svcorder;
		
		IF SQLCA.SQLCode < 0 THEN
			ls_quotainfo = "할부개월확인실패"
		ELSEIF SQLCA.SQLCode = 100 THEN
			ls_quotainfo = "할부정보 없음"
		ELSE
			ls_quotainfo = String(ll_quotamonths) + "개월"
		END IF	
		
		//#선수금정보 가져오기
		//1.선수금 TR코드
		ls_trcod = fs_get_control('B1','H200',ls_desc)
		ll_orderno = Long(is_svcorder)
		
		//2.선수금정보 가져오기
		SELECT tramt
		INTO :ldc_tramt
		FROM partner_ardtl
		WHERE orderno = :ll_orderno AND artrcod = :ls_trcod;
		
		IF SQLCA.SQLCode < 0 THEN
			ls_quotainfo += ",선수금확인실패"
		ELSEIF SQLCA.SQLCode = 100 THEN
			ls_quotainfo += ",선수금:0"
		ELSE
			ls_quotainfo += ",선수금:"+ String(ldc_tramt)
		END IF	

		
		idw_tabpage[1].Object.t_quotainfo.Text = ls_quotainfo
		
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
		
	Case 4								//Tab 4 - 인증정보
		ls_where = "customerid = '" + is_customerid + "' "
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

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Changed
Boolean lb_check
String ls_data
DateTime ldt_null

SetNull(ldt_null)   //null값 저장

Choose Case tab_1.SelectedTab
	Case 1		//Tab 1
     Choose Case dwo.name
			Case "actflag"
				If data = '1' Then		//개통완료이면 번호 필수
					tab_1.idw_tabpage[1].Object.phone.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[1].Object.phone.Background.Color = 9016172  //RGB(0, 128, 128)
					tab_1.idw_tabpage[1].Object.phone.Protect = 0
					tab_1.idw_tabpage[1].Object.phone1.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[1].Object.phone1.Background.Color = 9016172  //RGB(0, 128, 128)
					tab_1.idw_tabpage[1].Object.phone1.Protect = 0
					tab_1.idw_tabpage[1].Object.phone2.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[1].Object.phone2.Background.Color = 9016172  //RGB(0, 128, 128)
					tab_1.idw_tabpage[1].Object.phone2.Protect = 0
					tab_1.idw_tabpage[1].Object.banno.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[1].Object.banno.Background.Color = 9016172  //RGB(0, 128, 128)
					tab_1.idw_tabpage[1].Object.banno.Protect = 0
					tab_1.idw_tabpage[1].Object.activedt.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[1].Object.activedt.Background.Color = 9016172  //RGB(0, 128, 128)
					tab_1.idw_tabpage[1].Object.activedt.Protect = 0					
					tab_1.idw_tabpage[1].Object.contract_no.Color = RGB(0, 0, 255)		
					tab_1.idw_tabpage[1].Object.contract_no.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.contract_no.Protect = 0			
					tab_1.idw_tabpage[1].Object.bil_fromdt.Color = RGB(0, 0, 255)							
					tab_1.idw_tabpage[1].Object.bil_fromdt.Background.Color = RGB(255, 255, 255)
					tab_1.idw_tabpage[1].Object.bil_fromdt.Protect = 0		
				Else
					tab_1.idw_tabpage[1].Object.phone.Color = RGB(0, 0, 0)
					tab_1.idw_tabpage[1].Object.phone.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.phone[row] = ''										
					tab_1.idw_tabpage[1].Object.phone.Protect = 1
					tab_1.idw_tabpage[1].Object.phone1.Color = RGB(0, 0, 0)
					tab_1.idw_tabpage[1].Object.phone1.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.phone1[row] = ''										
					tab_1.idw_tabpage[1].Object.phone1.Protect = 1					
					tab_1.idw_tabpage[1].Object.phone2.Color = RGB(0, 0, 0)
					tab_1.idw_tabpage[1].Object.phone2.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.phone2[row] = ''										
					tab_1.idw_tabpage[1].Object.phone2.Protect = 1	
					tab_1.idw_tabpage[1].Object.banno.Color = RGB(0, 0, 0)
					tab_1.idw_tabpage[1].Object.banno.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.banno[row] = ''										
					tab_1.idw_tabpage[1].Object.banno.Protect = 1
					tab_1.idw_tabpage[1].Object.activedt.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.activedt.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.activedt.Protect = 1
					tab_1.idw_tabpage[1].Object.contract_no.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[1].Object.contract_no.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.contract_no[row] = ''										
					tab_1.idw_tabpage[1].Object.contract_no.Protect = 1			
					tab_1.idw_tabpage[1].Object.bil_fromdt.Color = RGB(0, 0, 0)							
					tab_1.idw_tabpage[1].Object.bil_fromdt.Background.Color = RGB(255, 251, 240)
					tab_1.idw_tabpage[1].Object.bil_fromdt[row] = ldt_null
					tab_1.idw_tabpage[1].Object.bil_fromdt.Protect = 1			
				End If	

			Case "activedt"
				 tab_1.idw_tabpage[1].Object.bil_fromdt[row] = tab_1.idw_tabpage[1].Object.activedt[row]
				
		End Choose
				
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

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_svc_actprc_mvno
integer y = 172
end type

