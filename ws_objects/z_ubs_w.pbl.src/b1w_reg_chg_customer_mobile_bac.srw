$PBExportHeader$b1w_reg_chg_customer_mobile_bac.srw
$PBExportComments$[lys] 모바일 명의변경 관리 - 2015.03.07. lys
forward
global type b1w_reg_chg_customer_mobile_bac from w_a_reg_m_tm2
end type
type cb_new from commandbutton within b1w_reg_chg_customer_mobile_bac
end type
end forward

global type b1w_reg_chg_customer_mobile_bac from w_a_reg_m_tm2
integer width = 4169
cb_new cb_new
end type
global b1w_reg_chg_customer_mobile_bac b1w_reg_chg_customer_mobile_bac

type variables
String is_check, is_item[], is_dwobjectnm, is_fileformcd
Long il_cnt

Boolean ib_new, ib_billing, ib_ctype3
String is_method, is_credit, is_inv_method, is_status, is_select_cod
Long il_row
String is_pay_method_ori, is_receiptcod          //결재방법(origin), 신청접수처
String is_drawingtype[], is_drawingresult[]		 //출금이체신청유형, 출금이체신청결과
string is_drawingtype_ori, is_drawingresult_ori  //출금이체신청유형(origin), 출금이체신청결과(origin)
String is_receiptcod_ori, is_resultcod_ori       //신청접수처(origin), 신청결과코드(origin)
String is_bank_ori, is_acctno_ori, is_acct_owner_ori, is_acct_ssno_ori //은행,계좌번호,예금주, 예금주민번호(origin)
datetime id_drawingreqdt_ori, id_receiptdt_ori 	 //이체신청일자(origin), 신청접수일자(origin)
String is_chg_flag                               //pay_method변경flag
String is_bank_chg_ori							       //자동이체 정보 변경(origin)
datetime idt_sysdate
string is_drawingtype_bef, is_drawingresult_bef  //출금이체신청유형(before), 출금이체신청결과(before)
String is_receiptcod_bef, is_resultcod_bef       //신청접수처(before), 신청결과코드(before)
String is_bank_bef, is_acctno_bef, is_acct_owner_bef, is_acct_ssno_bef //은행,계좌번호,예금주, 예금주민번호(before)
datetime id_drawingreqdt_bef, id_receiptdt_bef 	 //이체신청일자(before), 신청접수일자(before)
String is_bonsa, is_bonsa_prefix
//Currency_type
String is_currency_old, is_payid_old
//선불제 svctype
String is_svctype_pre, is_card_prefix_yn
String is_operator, is_operatornm

//dw child
DataWindowChild idc_itemcod



end variables

forward prototypes
public function integer wf_paymethod_chg_check ()
public function integer wfi_get_payid (string as_customerid, boolean ab_check)
public function boolean wf_unpay_chk (string as_customerid)
end prototypes

public function integer wf_paymethod_chg_check ();String ls_drawingresult, ls_drawingtype

//신청결과=처리중
IF is_drawingresult_ori = is_drawingresult[3] Then
	is_chg_flag = 'N'			//pay_method 변경 Flag 
	return 2
End If

//신청유형=변경, 신청결과=미처리
IF is_drawingtype_ori = is_drawingtype[3] Then
	IF is_drawingresult_ori = is_drawingtype[2] Then
		is_chg_flag = 'N'       //pay_method 변경 Flag 
		return 2
	End If
End If

is_chg_flag = 'Y'
				
return 0
end function

public function integer wfi_get_payid (string as_customerid, boolean ab_check);//납입자랑 고객과 같은지 확인
String ls_payid
ab_check = False

Select payid
Into :ls_payid
From customerm
Where customerid = :as_customerid;

//Error
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err("납입자", "Select customerm Table")
	Return 0
End If

If ls_payid <> as_customerid Then
	ab_check = True					//같지 않음
Else
	ab_check = False					//같음
	
End If
Return 0

end function

public function boolean wf_unpay_chk (string as_customerid);Long ll_unpay_amt = 0

SELECT SUM (NVL(TRAMT,0) - NVL(PAYIDAMT,0)) TRAMT INTO :ll_unpay_amt
  FROM REQDTL
 WHERE 1=1
   AND COMPLETE_YN = 'N'
   AND PAYID       = :as_customerid
	;
	
If SQLCA.SQLCode <> 0 Then
	f_msg_sql_err(SQLCA.SQLERRTEXT, "SELECT REQDTL. (" + as_customerid + ")")
	Return False
End If

If ll_unpay_amt <> 0 Then
	f_msg_usr_err(9000, Title, "미납액이 발생하여 명의변경할 수 없습니다. (미납액=" + String(ll_unpay_amt, '###,0') + ")")
	Return False
End If

Return True
end function

on b1w_reg_chg_customer_mobile_bac.create
int iCurrent
call super::create
this.cb_new=create cb_new
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_new
end on

on b1w_reg_chg_customer_mobile_bac.destroy
call super::destroy
destroy(this.cb_new)
end on

event open;call super::open;String ls_ref_desc, ls_temp, ls_name[]

ib_new 			= False
ib_billing 		= False
ib_ctype3		= False		//선불 고객여부
is_check 		= ""
is_method 		= ""
is_credit 		= ""
is_inv_method 	= ""

//손모양 없애기
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)

//결제 정보
//카드 정보 가져오기
ls_ref_desc 	= ""
is_method 		= fs_get_control("B0", "P130", ls_ref_desc)
is_credit 		= fs_get_control("B0", "P131", ls_ref_desc)
is_inv_method 	= fs_get_control("B0", "P132", ls_ref_desc)  //E-mail 로 발송
is_status 		= fs_get_control("B0", "P202", ls_ref_desc)	//등록상태

//선불제서비스TYPE
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)

//출금이체 신청유형(1.없음(0);2.신규(1);3.변경(2);4.해지(3);5.임의해지(7))
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("B7", "A320", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_drawingtype[])

//출금이체 신청결과(1.없음(0);2.신청(1);3.처리중(2);4.처리성공(S);5.처리실패(F))
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("B7", "A330", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", is_drawingresult[])

//출금이체 신청접수처
ls_ref_desc 	= ""
ls_temp 			= ""
ls_temp 			= fs_get_control("B7", "A300", ls_ref_desc)
If ls_temp 		= "" Then Return
fi_cut_string(ls_temp, ";", ls_name[])
is_receiptcod 	= ls_name[2]

idt_sysdate 	= fdt_get_dbserver_now()    //sysdatetime
//본사 코드 본사 prefix
is_bonsa        = fs_get_control("A1", "C102", ls_ref_desc)  
is_bonsa_prefix = fs_get_control("A1", "C101", ls_ref_desc)  

//신용카드prefix 사용여부... y이면-> 카드번호 입력시 자동으로 카드사 setting, edit 불가
is_card_prefix_yn = fs_get_control("00", "Z930", ls_ref_desc)  


//postEvent("resize")
dw_cond.SetFocus()
dw_cond.SetColumn("validkey")

end event

event ue_ok;call super::ue_ok;//조회
String	ls_new, ls_validkey, ls_customerid, ls_where
Long		ll_row

//Condition
ls_validkey   = fs_snvl(dw_cond.Object.validkey[1], "")
ls_customerid = fs_snvl(dw_cond.Object.customerid[1], "")

//validkey 와 customerid 둘다 null이면 중단
If ls_validkey = "" and ls_customerid = "" Then
	If f_nvl_chk(dw_cond, 'validkey', 1, ls_validkey, '') = False Then Return
	If f_nvl_chk(dw_cond, 'customerid', 1, ls_customerid, '') = False Then Return
End If

	
//Dynamic SQL
ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "cus.customerid = '" + ls_customerid + "' "
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "val.validkey like '" + ls_validkey + "%' "
END IF

//Retrieve
dw_master.is_where = ls_where
ll_row = dw_master.retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
Else			
	//검색을 찾으면 Tab를 활성화 시킨다.
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
End If
end event

event type integer ue_insert();Constant Int LI_ERROR = -1
String 	ls_cusid, 	ls_cusnm
Long 		ll_row,  	ll_master_row
Integer 	li_curtab
//Int li_return

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return -1
li_curtab = tab_1.Selectedtab

ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(1)

tab_1.idw_tabpage[li_curtab].ScrollToRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetRow(ll_row)
tab_1.idw_tabpage[li_curtab].SetFocus()

If This.Trigger Event ue_extra_insert(li_curtab, ll_row) < 0 Then
	Return LI_ERROR
End if

//ii_error_chk = 0
Return 0
end event

event type integer ue_extra_insert(integer ai_selected_tab, long al_insert_row);call super::ue_extra_insert;//Insert
b1u_check lu_check	
Integer 	li_rc, 			li_tab
Long 		ll_master_row
String 	ls_customerid, ls_ref_desc, ls_reqnum_dw, ls_name[], ls_operator, ls_basecod
Boolean 	lb_check1

li_tab 	= ai_selected_tab
lu_check = create b1u_check

ll_master_row = dw_master.GetSelectedRow(0)

If ll_master_row < 1 Then Return -1

ls_operator   = Trim(dw_cond.object.operator[1])
ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])

If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1

Choose Case li_tab
	Case 1		//Tab 1 고객정보
		If ib_new = True Then
			//Status
			ls_ref_desc 	= ""
			ls_reqnum_dw 	= fs_get_control("B0", "P200", ls_ref_desc)
			If ls_reqnum_dw = "" Then Return -1
			
			fi_cut_string(ls_reqnum_dw, ";", ls_name[])
			tab_1.idw_tabpage[li_tab].object.status[li_tab] 		= ls_name[1]
			
			ls_ref_desc 	= ""
			ls_reqnum_dw 	= fs_get_control("C1", "A100", ls_ref_desc)
			IF  ls_reqnum_dw <> '' THEN 
				fi_cut_string(ls_reqnum_dw, ";", ls_name[])
				tab_1.idw_tabpage[li_tab].object.ctype2[1] 		= ls_name[1]
				tab_1.idw_tabpage[li_tab].object.ctype1[1] 		= ls_name[2]
			END IF
			
			//고객번호, 납입자번호는 기존ID를 승계 한다. (변경불가) - 2015.03.07. lys
			tab_1.idw_tabpage[li_tab].object.customerid[1]      = ls_customerid
			tab_1.idw_tabpage[li_tab].object.customerid.Protect = 1
			
			tab_1.idw_tabpage[li_tab].object.payid[1]           = ls_customerid
			tab_1.idw_tabpage[li_tab].object.payid.Protect 		 = 1			
				
			//Display
			tab_1.idw_tabpage[li_tab].object.termdt.Protect 		      = 1			
			tab_1.idw_tabpage[li_tab].object.termtype.Protect 		      = 1
			tab_1.idw_tabpage[li_tab].Object.termdt.Background.Color 	= RGB(255, 251, 240)
			tab_1.idw_tabpage[li_tab].Object.termdt.Color 					= RGB(0, 0, 0)
			tab_1.idw_tabpage[li_tab].Object.termtype.Background.Color 	= RGB(255, 251, 240)
			tab_1.idw_tabpage[li_tab].Object.termtype.Color 				= RGB(0, 0, 0)
				
			//원상태로..
			tab_1.idw_tabpage[li_tab].object.logid.Protect 					= 0
			tab_1.idw_tabpage[li_tab].Object.logid.Color 					= RGB(0, 0, 255)
			tab_1.idw_tabpage[li_tab].Object.logid.Background.Color 		= RGB(255, 255, 255)
				
			//Setting
			tab_1.idw_tabpage[li_tab].object.enterdt[li_tab] 				= fdt_get_dbserver_now()			//가입일
			tab_1.idw_tabpage[li_tab].object.partner[li_tab] 				= GS_SHOPID
			
			//ADD-2007-1-11
			select basecod INTO :ls_basecod FROM partnermst 
			 WHERE partner = :GS_SHOPID ;
			IF IsNull(ls_basecod) OR sqlca.sqlcode < 0 THEN ls_basecod = ''
			tab_1.idw_tabpage[li_tab].object.basecod[li_tab] = ls_basecod
			//ADD end...
			
//			tab_1.idw_tabpage[li_tab].object.partner_prefix[li_tab] = is_bonsa_prefix				
		End  If

		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[1] 	= ls_operator
		tab_1.idw_tabpage[li_tab].object.crtdt[1] 		= fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[1] 		= gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= ls_operator
		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
			
	Case 2		//Tab 2 청구지정보
		//Setting
		tab_1.idw_tabpage[li_tab].object.customerid[1]      = ls_customerid
		tab_1.idw_tabpage[li_tab].object.customerid.Protect = 1
		
		//Log
		tab_1.idw_tabpage[li_tab].object.crt_user[1] 	= ls_operator
		tab_1.idw_tabpage[li_tab].object.crtdt[1] 		= fdt_get_dbserver_now()
		tab_1.idw_tabpage[li_tab].object.pgm_id[1] 		= gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= ls_operator
		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
		
		p_insert.TriggerEvent("ue_disable")	

End Choose

Destroy lu_check
Return 0

end event

event ue_reset;//초기화
Constant Int LI_ERROR = -1
Int li_tab_index,li_rc

li_tab_index = tab_1.SelectedTab

//Reset 문제
If tab_1.ib_tabpage_check[li_tab_index] = True Then
	tab_1.idw_tabpage[li_tab_index].AcceptText() 

	If (tab_1.idw_tabpage[li_tab_index].ModifiedCount() > 0) or &
		(tab_1.idw_tabpage[li_tab_index].DeletedCount() > 0)	Then
		
		li_rc = MessageBox(Tab_1.is_parent_title,"Data is Modified.! Do you want to cancel?" &
					,Question!,YesNo!)
		If li_rc <> 1 Then
			Return LI_ERROR
		End If
	End If
End If
	
//p_insert.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")
cb_new.Enabled = True

dw_cond.ReSet()
dw_master.Reset()
For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Reset()
	tab_1.idw_tabpage[li_tab_index].Enabled = false
Next

dw_cond.Enabled = True
dw_cond.InsertRow(0)

//조회조건 초기화
//dw_cond.object.partner[1]    = GS_SHOPID
//dw_cond.Object.validkey[1]   = ""
//dw_cond.Object.customerid[1] = ""
//dw_cond.Object.name[1]       = ""
dw_cond.Object.operator[1]   = is_operator
dw_cond.Object.operatornm[1] = is_operatornm

dw_cond.SetColumn("customerid")
ib_new = False
is_chg_flag  = 'Y'




RETURN 0

Return 0 
end event

event ue_save;//Override
Constant Int LI_ERROR = -1
Int li_tab_index, li_return

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

//실패했으면 일단은 무조건 롤백처리 한다. - 2015.03.07. lys
If li_return <> 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		ib_update = False
		Return -1
	End If	
End If

Choose Case li_return
	Case -3
		ib_billing = True 	
	Case -2
		//필수항목 미입력
		tab_1.idw_tabpage[li_tab_index].SetFocus()
		Return -2
	Case -1
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

//cuesee
//저장 되어있으므로
String ls_customerid, ls_payid
Int li_rc, li_selectedTab
Long ll_row, ll_tab_rowcount, ll_master_row
Boolean lb_check2

li_selectedTab = tab_1.SelectedTab
If li_selectedTab = 1 Then						//Tab 1
	
	//신규등록
	If ib_new Then
		//Tab2로 이동시키기 위해서 잠시 ib_new를 false로 변경시킨다.
		ib_new = false
		tab_1.idw_tabpage[1].Enabled = false
		
		ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()
		If ll_tab_rowcount < 1 Then Return 0
		dw_cond.Reset()
		dw_cond.InsertRow(0)
		ls_customerid 						= tab_1.idw_tabpage[1].object.customerid[1]
		dw_cond.object.customerid[1] 	= ls_customerid 
		dw_cond.Object.operator[1]   = is_operator
		dw_cond.Object.operatornm[1] = is_operatornm
		TriggerEvent("ue_ok")
		
		//청구 정보를 입력하게 한다.
		tab_1.SelectedTab = 2
		
		//청구정보를 저장하기 전까지는 tab이동을 못하도록 ib_new를 true로 변경 한다.
		ib_new = true
		
		//버튼처리
		p_save.TriggerEvent("ue_enable")
	End If	
  
ElseIf li_selectedTab = 2 Then	
	
	ib_new = false
	dw_cond.Enabled = True
	cb_new.Enabled = True
	p_ok.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")	
	
	//tab_1.idw_tabpage[1].Reset()
	tab_1.idw_tabpage[2].Reset()
	tab_1.ib_tabpage_check[2] = False
	tab_1.idw_tabpage[2].Enabled = false
	
	tab_1.Trigger Event SelectionChanged(2, 2)
 
 
End If

Return 0
end event

event ue_extra_save;//Save Check
Integer 	li_tab, 				li_rc
Long 		i, 					ll_row, 			ll_master_row,    ll_orderno
String 	ls_customerid, 	ls_bank_chg, 	ls_paymethod, 		ls_drawingtype, 	ls_enddt, &
       	ls_osvccod, 		ls_svccod, 		ls_svccod1, 		ls_svccod2, ls_operator, ls_partner_prefix, ls_partner
Boolean 	lb_check1

String 	ls_parttype1, 		ls_partcod1, 	ls_zoncod1, ls_opendt1, ls_enddt1, ls_tmcod1, ls_frpoint1, ls_areanum1, ls_itemcod1
String 	ls_parttype2, 		ls_partcod2, 	ls_zoncod2, ls_opendt2, ls_enddt2, ls_tmcod2, ls_frpoint2, ls_areanum2, ls_itemcod2
Long   	ll_rows1, 			ll_rows2, 		li_pre_cnt, li_old_cnt
Int		li_logid_cnt

String 	ls_firstnm, ls_lastnm, ls_midnm, ls_logid, ls_card_no_1, ls_card_no_2

li_tab = ai_select_tab
If tab_1.idw_tabpage[li_tab].RowCount() = 0 Then Return 0

b1u_check1_v20 lu_check
lu_check = Create b1u_check1_v20

ls_operator = dw_cond.Object.operator[1]
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -2

Choose Case li_tab
	Case 1
		ls_customerid = tab_1.idw_tabpage[li_tab].object.customerid[1]
		ls_logid 	  = tab_1.idw_tabpage[li_tab].object.logid[1]
		If f_nvl_chk_tab(tab_1.idw_tabpage[li_tab], 'logid', 1, ls_logid, '') = False Then Return -2
		
		//customernm 컬럼 set 
		ls_firstnm 	= trim(tab_1.idw_tabpage[li_tab].object.firstname[1])
		ls_midnm 	= trim(tab_1.idw_tabpage[li_tab].object.midname[1])
		ls_lastnm 	= trim(tab_1.idw_tabpage[li_tab].object.lastname[1]) 
		IF IsNull(ls_firstnm) 	then	ls_firstnm 	= ''
		IF IsNull(ls_midnm) 		then	ls_midnm 	= ''
		IF IsNull(ls_lastnm) 	then	ls_lastnm 	= ''
		
		tab_1.idw_tabpage[li_tab].object.customernm[1] = ls_firstnm + ls_midnm + ls_lastnm
		
		//양도, 양수자의 login-id가 같은지 체크 한다.
		SELECT COUNT(*) INTO :li_logid_cnt
  		  FROM CUSTOMERM
	    WHERE 1=1
		   AND CUSTOMERID = :ls_customerid
			AND LOGID      = :ls_logid
			;
			
		If SQLCA.SQLCODE < 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Check LOGID Fail. (CUSTOMERID=" + ls_customerid + ", LOGID=" + ls_logid + ")")
			Return -2
			
		ElseIf li_logid_cnt > 0 Then
			f_msg_usr_err(9000, Title, "양도자와 양수자의 LogIn ID가 같을수 없습니다. (LOG-ID="+ ls_logid +")")
			Return -2			
		End If
		
		//Process Call 전에 Billinginfo를 delete 한다.
		//Process에서 Billinginfo를 insert하는 로직이 있다
		DELETE BILLINGINFO WHERE CUSTOMERID = :ls_customerid;
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "DELETE BILLINGINFO Fail. (CUSTOMERID=" + ls_customerid + ")")
			Return -1
		End If		
		
		//Call Process
		lu_check.is_caller 	= "b1w_reg_customer_d_v20%save_tab1"
		lu_check.is_title 	= Title
		lu_check.ii_data[1] 	= li_tab
		lu_check.ib_data[1] 	= ib_new
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]
				
		lu_check.uf_prc_check_07()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc = -2 Then
			Destroy lu_check
			Return -2
		End If
		
	   //납입자 오류
		If li_rc = -3 Then
			Destroy lu_check
			Return -3
		End If
		Destroy lu_check
		
		//기존의 customerm, billinginfo를 백업 후 삭제 한다.
		//(명변은 무조건 신규 등록 처리이기 때문에, 기존의 정보삭제를 해야 다음 절차에서 정상처리가 가능하다.) - 2015.03.07. lys
		//1. GET SEQUENCE ORDERNO
		SELECT SEQ_ORDERNO.NEXTVAL INTO :ll_orderno FROM DUAL;
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert SVCORDER Fail.")
			Return -1
		End If
		
		//2. Insert SVCORDER
		//INSERT INTO SVCORDER( STATUS  = '65', CONTRACTSEQ = '동일', CUSTOMERID = '동일')
		ls_partner_prefix = tab_1.idw_tabpage[li_tab].object.partner_prefix[1]
		ls_partner        = tab_1.idw_tabpage[li_tab].object.partner[1]
		
      INSERT INTO SVCORDER (
                  ORDERNO,      REG_PREFIXNO,       CUSTOMERID,     ORDERDT,        REQUESTDT,      STATUS
                , REG_PARTNER,  SALE_PARTNER,       PARTNER
                , CRT_USER,     UPDT_USER,          CRTDT,          UPDTDT,         PGM_ID )
           VALUES ( 
			         :ll_orderno,  :ls_partner_prefix, :ls_customerid, TRUNC(SYSDATE), TRUNC(SYSDATE), '65'
                , :ls_partner,  :ls_partner,        :ls_partner
                , :ls_operator, :ls_operator,       SYSDATE,        SYSDATE,        :gs_pgm_id[gi_open_win_no] )
					 ;
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert SVCORDER Fail. (CUSTOMERID" + ls_customerid + ")")
			Return -1
		End If
		
		//3. Log기록
		INSERT INTO CUSTOMER_LOG_DELETE (
			    ORDERNO,         CUSTOMERID,     PAYID,          LOGID,            MEMBERID,     MAILID
			  , PASSWORD,        SECUWORD,       CUSTOMERNM,     FIRSTNAME,        MIDNAME,      LASTNAME
			  , STITLE,          BIRTHDT,        ANNIVERSARY,    CTYPE1,           CTYPE2,       CTYPE3
			  , CLEVEL,          BASECOD,        UNIT,           ORGANIZATION,     BUILDINGNO,   ROOMNO
			  , HOMEADDR,        HOMEPHONE,      ZIPCODE,        CELLPHONE,        LOCATION,     NATIONALITY
			  , USPHONE,         USZIPCODE,      USCITY,         USSTATE,          PHONE1,       SSNO
			  , DRIVELCNO,       PASSPORTNO,     RANK,           SPONSORNM,        DEROSDT,      DUTYADDR1
			  , DUTYADDR2,       DUTYPHONE,      DUTYFAX,        URL,              EMAIL1,       EMAIL2
			  , CREGNO,          CORPNO,         CORPNM,         REPRESENTATIVENM, BUSINESSTYPE, BUSINESSITEM
			  , ADDR1,           ADDR2,          STATUS,         ENTERDT,          TERMDT,       TERMTYPE
			  , PARTNER,         PARTNER_PREFIX, WORKDT,         SMS_YN,           EMAIL_YN,     HOTBILLFLAG
			  , CONTACT,         CONTACTDEP,     REMARK
			  , CRT_USER,        UPDT_USER,      CRTDT,          UPDTDT,           PGM_ID
		     , CUSTOMERINFO_YN, POINT,          ADDRTYPE,       CITYCOD,          CORPNM_2,     FAXNO
		     , FINCONFDT,       FINSTATUS,      HOLDER,         HOLDER_ADDR1,     HOLDER_ADDR2, HOLDER_ADDRTYPE
		     , HOLDER_ITEM,     HOLDER_SSNO,    HOLDER_TYPE,    HOLDER_ZIPCOD,    JOB,          LANGTYPE
		     , MACOD,           MARKET_SRC,     PHONE2,         PHONE3,           PROVINCE,     RELATION
		     , REMARK1,         REMARK2,        REPRESENTATIVE, SMSPHONE,         ZIPCOD,       SOCIALSECURITY
		     , TRANSDT )
 		SELECT 
		       :ll_orderno,     CUSTOMERID,     PAYID,          LOGID,            MEMBERID,     MAILID
			  , PASSWORD,        SECUWORD,       CUSTOMERNM,     FIRSTNAME,        MIDNAME,      LASTNAME
			  , STITLE,          BIRTHDT,        ANNIVERSARY,    CTYPE1,           CTYPE2,       CTYPE3
			  , CLEVEL,          BASECOD,        UNIT,           ORGANIZATION,     BUILDINGNO,   ROOMNO
			  , HOMEADDR,        HOMEPHONE,      ZIPCODE,        CELLPHONE,        LOCATION,     NATIONALITY
			  , USPHONE,         USZIPCODE,      USCITY,         USSTATE,          PHONE1,       SSNO
			  , DRIVELCNO,       PASSPORTNO,     RANK,           SPONSORNM,        DEROSDT,      DUTYADDR1
			  , DUTYADDR2,       DUTYPHONE,      DUTYFAX,        URL,              EMAIL1,       EMAIL2
			  , CREGNO,          CORPNO,         CORPNM,         REPRESENTATIVENM, BUSINESSTYPE, BUSINESSITEM
			  , ADDR1,           ADDR2,          STATUS,         ENTERDT,          TERMDT,       TERMTYPE
			  , PARTNER,         PARTNER_PREFIX, WORKDT,         SMS_YN,           EMAIL_YN,     HOTBILLFLAG
			  , CONTACT,         CONTACTDEP,     REMARK
			  , CRT_USER,        UPDT_USER,      CRTDT,          UPDTDT,           PGM_ID
		     , CUSTOMERINFO_YN, POINT,          ADDRTYPE,       CITYCOD,          CORPNM_2,     FAXNO
		     , FINCONFDT,       FINSTATUS,      HOLDER,         HOLDER_ADDR1,     HOLDER_ADDR2, HOLDER_ADDRTYPE
		     , HOLDER_ITEM,     HOLDER_SSNO,    HOLDER_TYPE,    HOLDER_ZIPCOD,    JOB,          LANGTYPE
		     , MACOD,           MARKET_SRC,     PHONE2,         PHONE3,           PROVINCE,     RELATION
		     , REMARK1,         REMARK2,        REPRESENTATIVE, SMSPHONE,         ZIPCOD,       SOCIALSECURITY
		     , SYSDATE
		  FROM CUSTOMERM
		 WHERE 1=1
		   AND CUSTOMERID = :ls_customerid
			;
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "INSERT CUSTOMER_LOG_DELETE Fail. (CUSTOMERID" + ls_customerid + ")")
			Return -1
		End If			
			
	   //4. Delete CUSTOMERM
		DELETE CUSTOMERM WHERE CUSTOMERID = :ls_customerid;
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "DELETE CUSTOMERM Fail. (CUSTOMERID" + ls_customerid + ")")
			Return -1
		End If
	   
		//Update Log
		tab_1.idw_tabpage[li_tab].object.updt_user[1] = ls_operator
		tab_1.idw_tabpage[li_tab].object.updtdt[1] 	 = fdt_get_dbserver_now()
		
   Case 2
		ls_card_no_1 = tab_1.idw_tabpage[li_tab].object.card_no_1[1] + tab_1.idw_tabpage[li_tab].object.card_no_2[1]
		ls_card_no_2 = tab_1.idw_tabpage[li_tab].object.card_no_3[1] + tab_1.idw_tabpage[li_tab].object.card_no_4[1]
			
		tab_1.idw_tabpage[li_tab].object.card_no[1] = trim(ls_card_no_1 + ls_card_no_2);
		
		lu_check.is_caller 		= "b1w_reg_customer_d%save_tab2"
		lu_check.is_title 		= Title
		lu_check.ii_data[1] 		= li_tab
		lu_check.is_data[1] 		= is_method
		lu_check.is_data[2] 		= is_credit
		lu_check.is_data[3] 		= is_inv_method
		lu_check.is_data[4] 		= is_bank_chg_ori	
		lu_check.idw_data[1] 	= tab_1.idw_tabpage[li_tab]
		lu_check.uf_prc_check_2()
		li_rc = lu_check.ii_rc
		
		//필수 항목 오류
		If li_rc < 0 Then
			Destroy lu_check
			Return -2
		End If
		
		//Update Log
		tab_1.idw_tabpage[li_tab].object.crt_user[1] 	= ls_operator
		tab_1.idw_tabpage[li_tab].object.updt_user[1] 	= ls_operator
		tab_1.idw_tabpage[li_tab].object.updtdt[1] 		= fdt_get_dbserver_now()
	
		//변경시 - 변경전정보 before 컬럼에 저장....
		ls_bank_chg 	= tab_1.idw_tabpage[li_tab].object.bank_chg[1] 
		ls_paymethod 	= tab_1.idw_tabpage[li_tab].object.pay_method[1] 
		ls_drawingtype = tab_1.idw_tabpage[li_tab].object.drawingtype[1] 		
		
		//변경check = 'Y' & 결재방법 = '자동이체' & 신청유형 = '변경' 일때만... before 저장...
		If ls_bank_chg = 'Y' and ls_paymethod = is_method and ls_drawingtype = is_drawingtype[3]Then
			If is_bank_chg_ori = 'Y' Then
			Else 
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_bank[1] 			= is_bank_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acctno[1] 			= is_acctno_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_owner[1] 	= is_acct_owner_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_ssno[1] 		= is_acct_ssno_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingresult[1] = is_drawingresult_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingtype[1] 	= is_drawingtype_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingreqdt[1] 	= id_drawingreqdt_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptdt[1] 		= id_receiptdt_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_resultcod[1] 		= is_resultcod_ori
				tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptcod[1] 	= is_receiptcod_ori
			End IF
		End If
		
End Choose

If ib_billing = True	 Then ib_billing = False
		
Return 0
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_chg_customer_mobile_bac
integer y = 92
integer width = 2368
integer height = 196
string dataobject = "b1dw_cnd_chg_customer_mobile"
end type

event dw_cond::itemchanged;call super::itemchanged;String 	ls_customerid,		ls_customernm,		ls_memberid, 	&
		 	ls_operator,		ls_empnm,			ls_paydt,		&
			ls_paydt_1,			ls_sysdate,			ls_paydt_c
Integer	li_cnt
Date		ldt_paydt
DEC{2}	ldc_total,			ldc_90
LONG		ll_return

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select memberid, 		customernm
		  INTO :ls_memberid, :ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_memberid) 	OR sqlca.sqlcode <> 0 	then ls_memberid 		= ""
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		 
		IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			
			Return
			
		ELSE
			//This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] =  ls_customernm
		END IF
		
	case 'operator'
		SELECT EMPNM INTO :ls_empnm
		FROM   SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm		

		//instance variable set
		is_operator   = data
		is_operatornm = ls_empnm		

End Choose

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::losefocus;call super::losefocus;//입력정보 동기화
//this.Accepttext()
end event

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

//dw_cond.reset()


end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_chg_customer_mobile_bac
integer x = 2661
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_chg_customer_mobile_bac
integer x = 2962
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_chg_customer_mobile_bac
integer width = 2423
integer taborder = 20
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_chg_customer_mobile_bac
integer taborder = 30
string dataobject = "b1dw_1_inq_customer_mobile_sams"
end type

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

Return 0




end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = this.Object.customerm_customernm_t
//customerm_customernm_t
uf_init(ldwo_SORT)
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_chg_customer_mobile_bac
boolean visible = false
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_chg_customer_mobile_bac
boolean visible = false
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_chg_customer_mobile_bac
integer x = 37
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_chg_customer_mobile_bac
integer x = 329
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_chg_customer_mobile_bac
integer taborder = 40
end type

event tab_1::constructor;call super::constructor;Integer li_exist
DataWindowChild ldc_priceplan
//help Window
idw_tabpage[1].is_help_win[1] = "b1w_hlp_logid_1"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.logid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

//PayID는 기존ID 승계(변경불가) - 2015.03.07. lys
//idw_tabpage[1].is_help_win[2] = "b1w_hlp_payid"
//idw_tabpage[1].idwo_help_col[2] = idw_tabpage[1].Object.payid
//idw_tabpage[1].is_data[2] = "CloseWithReturn"

idw_tabpage[1].is_help_win[2] = "w_hlp_post"
idw_tabpage[1].idwo_help_col[2] = idw_tabpage[1].Object.zipcode
idw_tabpage[1].is_data[2] = "CloseWithReturn"

idw_tabpage[2].is_help_win[1] 		= "w_hlp_post"
idw_tabpage[2].idwo_help_col[1] 		= idw_tabpage[2].Object.bil_zipcod
idw_tabpage[2].is_data[1] 				= "CloseWithReturn"
end event

event tab_1::ue_init();call super::ue_init;
String    ls_code, ls_codenm, ls_yn, ls_dwnm
long    ll_chk, ll_cnt, i, ll_num, ll_n

//Tab 초기화
ii_enable_max_tab = 2		//Tab 갯수

DECLARE fileupload_cur CURSOR FOR
		SELECT CODE,
				 CODENM,
				 DWNM,
				 USE_YN
		  FROM TABINFO
		 WHERE GUBUN = 'chg_customer_mobile'
		ORDER  BY 1,2; 
	
OPEN fileupload_cur;

DO WHILE SQLCA.SQLCODE = 0
	
	FETCH fileupload_cur 
	 INTO  :ls_code    ,
			 :ls_codenm  ,
			 :ls_dwnm    ,
			 :ls_yn      ;
			 
	If sqlca.sqlcode <> 0 then
		exit;
	end if
	
	ll_cnt ++
	//Tab 초기화
	//Tab Title
		is_tab_title[ll_cnt] = ls_codenm
		is_dwObject[ll_cnt]  = ls_dwnm
LOOP 
CLOSE fileupload_cur;
//end

If ll_cnt > 2 THEN
	is_dwobjectnm = is_dwObject[2]
End If

////Tab 초기화
ii_enable_max_tab = ll_cnt		//Tab 갯수

//is_tab_title[1] = "파일유형마스터"
//is_tab_title[2] = "Data 검증항목"
//is_tab_title[3] = "파일유형상세"
//
//Tab에 해당하는 dw

//is_dwObject[1] = "b1dw_reg_fileupload_mst_t1_v30"
//is_dwObject[2] = "b1dw_reg_fileupload_mst_t2_v30"
//is_dwObject[3] = "b1dw_reg_fileupload_mst_t3_v30"

//--> Sort
wf_tab_init(ii_enable_max_tab)

end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_tab_row, ll_exist
String ls_customerid, ls_payid, ls_type, ls_desc
Boolean lb_check2

ll_master_row = dw_master.GetSelectedRow(0)

If ll_master_row < 0 Then Return 
	
ll_tab_row = tab_1.idw_tabpage[newindex].RowCount()

//Sort 정렬 click 했을때
If ll_master_row = 0 Then
	//p_insert.TriggerEvent("ue_disable")
	//p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_disable")
	//p_view.TriggerEvent("ue_disable")	
   Return 0
End If
	
//우편번호 팝업 비활성화
If newindex = 1 Then
	tab_1.idw_tabpage[newindex].object.zipcode.Pointer = "Arrow!"
	tab_1.idw_tabpage[newindex].idwo_help_col[2] = idw_tabpage[newindex].object.crt_user
ElseIf newindex = 2 Then
	tab_1.idw_tabpage[newindex].object.bil_zipcod.Pointer = "Arrow!"
	tab_1.idw_tabpage[newindex].idwo_help_col[1] = idw_tabpage[newindex].object.crt_user		
End If

//버튼 처리
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")

Return 0
	
end event

event tab_1::selectionchanging;//Occurs when another tab is about to be selected.
//Long. Return code choices (specify in a RETURN statement):

//0  Allow the selection to change
//1  Prevent the selection from changing

//신규 등록이면
If ib_new = TRUE Then Return 1

end event

event tab_1::ue_dw_buttonclicked;//Butonn Click
String ls_payid, ls_zip, ls_addr1, ls_addr2
String ls_svccod, ls_priceplan, ls_customerid, ls_where, ls_acct_ssno
Long i, ll_master_row

//조회모드인 경우 리턴
If Not ib_new Then Return -1

If ai_tabpage = 1 Then		//납입자 청구정보
	tab_1.idw_tabpage[1].AcceptText()
	ls_payid = Trim(tab_1.idw_tabpage[1].object.payid[al_row])
	OpenWithParm(b1w_inq_payid_billing_info, ls_payid)				//Open
End If

//INSOOK 수정 주민등록번호 유효성 Check 버튼(2004.06.29)
If ai_tabpage = 2 Then  //주민번호 check

	tab_1.idw_tabpage[2].AcceptText()
	
	Choose Case adwo_dwo.name
		Case "b_check"
			ls_acct_ssno = Trim(tab_1.idw_tabpage[2].object.acct_ssno[al_row])
		
			//주민등록 번호(13자리),법인번호(10자리)format)
			If LenA(ls_acct_ssno) = 13 Then
				If fi_check_juminnum(ls_acct_ssno) = -1 Then
					f_msg_usr_err(201, gs_title, "잘못된 주민번호 입니다.")
					tab_1.idw_tabpage[2].SetFocus()
					tab_1.idw_tabpage[2].SetColumn("acct_ssno")
					Return -1
				else
					MessageBox("주민번호 Check", "유효한 주민번호입니다.", information!, OK!, 1)
					tab_1.idw_tabpage[2].SetFocus()
					tab_1.idw_tabpage[2].SetColumn("acct_ssno")
				End If
			else
				f_msg_usr_err(201, gs_title, "잘못된 주민번호 입니다.")
				tab_1.idw_tabpage[2].SetFocus()
				tab_1.idw_tabpage[2].SetColumn("acct_ssno")
				Return -1
		
			End If	
		Case "b_copy"
			ls_customerid = Trim(tab_1.idw_tabpage[2].object.customerid[al_row])
			
			SELECT ZIPCOD
			     , ADDR1
				  , ADDR2
			  INTO :ls_zip
			     , :ls_addr1
				  , :ls_addr2
			  FROM CUSTOMERM
			 WHERE CUSTOMERID = :ls_customerid ;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " Select Error(customerm)")
				Return  -1
			End If 
			
			tab_1.idw_tabpage[2].Object.bil_zipcod[al_row] = ls_zip
			tab_1.idw_tabpage[2].Object.bil_addr1[al_row]  = ls_addr1
			tab_1.idw_tabpage[2].Object.bil_addr2[al_row]  = ls_addr2
			
	End Choose

end if


Return 0 
end event

event tab_1::ue_dw_doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부
String ls_logid = ""
String ls_svctype, ls_customerid
Integer li_exist

//조회모드인 경우 리턴
If Not ib_new Then Return -1

If tab_1.idw_tabpage[ai_tabpage].AcceptText() < 0 Then Return -1
 
Choose Case ai_tabpage
	Case 1
		Choose Case adwo_dwo.name
			Case "logid"		//Log ID
				
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
					 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
				End If
				
				idw_tabpage[ai_tabpage].Object.password.Color = RGB(255,255,255)		
				idw_tabpage[ai_tabpage].Object.password.Background.Color = RGB(108, 147, 137)				
//				ls_logid = Trim(idw_tabpage[ai_tabpage].Object.logid[al_row])
//				If IsNull(ls_logid) Then ls_logid = ""
//				If ls_logid = ""  Then
//					If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//						 idw_tabpage[ai_tabpage].Object.logid[al_row] = &
//						 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					End If
//					
//					idw_tabpage[ai_tabpage].Object.password.Color = RGB(255,255,255)		
//			      idw_tabpage[ai_tabpage].Object.password.Background.Color = RGB(108, 147, 137)
//				End If
//			Case "payid"		//납입자 번호
//				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//					idw_tabpage[ai_tabpage].Object.payid[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					
//					 ls_customerid = tab_1.idw_tabpage[1].Object.customerid[1]
//				  Select count(*) Into:li_exist from  svcorder where customerid = :ls_customerid;
//				  If li_exist > 0 Then 
//					 f_msg_usr_err(404, title, "")
//					 tab_1.idw_tabpage[1].Object.payid[1] = is_payid_old
//					 tab_1.idw_tabpage[1].SetitemStatus(1, "payid", Primary!, NotModified!)   //수정 안되었다고 인식.
//					 Return 0
//				 End If
//				
//					
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.zipcod[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.zipcod[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.zipcod[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//					End If
////					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row])) or &
////					    Trim(idw_tabpage[ai_tabpage].Object.addr1[al_row]) = ""  Then
////						idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
////						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
////					End If
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.addr2[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
//					End If
//					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.homephone[al_row])) or &
//					    Trim(idw_tabpage[ai_tabpage].Object.homephone[al_row]) = ""  Then
//						idw_tabpage[ai_tabpage].Object.homephone[al_row] = &
//						idw_tabpage[ai_tabpage].iu_cust_help.is_data[6]
//					End If
//					
//					
////					//명의인 정보에 넣기
////					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row])) or &
////					    Trim(idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row]) = ""  Then
////						idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
////						idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
////					End If
////					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row])) or &
////					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr1[al_row]) = ""  Then
////						idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
////						idw_tabpage[ai_tabpage].iu_cust_help.is_data[4]
////					End If
////					If	isnull(Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row])) or &
////					    Trim(idw_tabpage[ai_tabpage].Object.holder_addr2[al_row]) = ""  Then
////						idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
////						idw_tabpage[ai_tabpage].iu_cust_help.is_data[5]
////					End If
//					
//				End If
			Case "zipcode"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.zipcode[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
					
//					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
			Case "holder_zipcod"
//				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//					idw_tabpage[ai_tabpage].Object.holder_zipcod[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//					idw_tabpage[ai_tabpage].Object.holder_addr1[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//					idw_tabpage[ai_tabpage].Object.holder_addr2[al_row] = &
//					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
//				End If
		End Choose
	Case 2
		Choose Case adwo_dwo.name
			Case "bil_zipcod"
				If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
					idw_tabpage[ai_tabpage].Object.bil_zipcod[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
					idw_tabpage[ai_tabpage].Object.bil_addr1[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
					idw_tabpage[ai_tabpage].Object.bil_addr2[al_row] = &
					idw_tabpage[ai_tabpage].iu_cust_help.is_data[3]
				End If
		End Choose

End Choose  

Return 0
end event

event type long tab_1::ue_dw_clicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_clicked;//String ls_rectype, ls_status
//
////신청 상태일때만 delete
//
//Choose Case ai_tabpage
//	Case 3
//		If al_row = 0 then Return -1
//		
//		If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
//			 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
//		Else
//			tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
//			tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
//		End If
//	
////rectype = "A" 이면 Delete 막음
////ElseIf ai_tabpage = 4 Then
////	il_row = al_row
////	If al_row <= 0 Then Return 0
////	ls_rectype = tab_1.idw_tabpage[tab_1.SelectedTab].object.rectype[al_row]
////	If ls_rectype = "A" Then
////		p_delete.TriggerEvent("ue_disable")
////	Else
////		p_delete.TriggerEvent("ue_enable")
////	End If
//	Case 13
//		If al_row = 0 then Return -1
//		
//		If tab_1.idw_tabpage[ai_tabpage].IsSelected( al_row ) then
//			 tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row ,FALSE)
//		Else
//			tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
//			tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
//		End If
//		
//End Choose
//
Return 0
end event

event tab_1::ue_itemchanged;call super::ue_itemchanged;//Item Changed
Boolean 	lb_check1, 	lb_check2
String 	ls_data ,	ls_ctype2, 		ls_filter, 		ls_svctype, 	ls_opendt, 			ls_prefixno
String  	ls_payid, 	ls_customerid, ls_munitsec, 	ls_card_type, 	ls_card_group, ls_basecod
Integer 	li_exist, 	li_exist1, 		li_rc, li_tab

DataWindowChild ldc_priceplan
b1u_check	lu_check
lu_check = Create b1u_check

li_tab = tab_1.SelectedTab

If tab_1.idw_tabpage[li_tab].AcceptText() < 0 Then Return -1

Choose Case tab_1.SelectedTab
	Case 1		//Tab 1
		ls_ctype2 	= Trim(tab_1.idw_tabpage[1].Object.ctype2[1])
		b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
		b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
		
	    Choose Case dwo.name
		   Case "logid"
				If IsNull(data) Or data = "" Then
					tab_1.idw_tabpage[1].Object.password.Color 				= RGB(0,0,0)		
					tab_1.idw_tabpage[1].Object.password.Background.Color = RGB(255,255,255)
				Else //필수
					tab_1.idw_tabpage[1].Object.password.Color 				= RGB(255,255,255)		
					tab_1.idw_tabpage[1].Object.password.Background.Color = RGB(108, 147, 137)
				End If
				
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
			 
			Case "partner"				
				select basecod
				  into :ls_basecod
				  from partnermst
				 where partner = :data ;
				tab_1.idw_tabpage[1].Object.basecod[1] =	ls_basecod
//		   //sms 수신여부
//		   Case "sms_yn"
//			  If data = 'Y' Then 
//				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(255,255,255)		
//				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(108, 147, 137)
//  			  Else
//				  tab_1.idw_tabpage[1].Object.smsphone.Color = RGB(0,0,0)				
//				  tab_1.idw_tabpage[1].Object.smsphone.Background.Color = RGB(255,255,255)
//			  End If

		   //email 수신여부
		   Case "email_yn"
				If data = 'Y' Then 
					tab_1.idw_tabpage[1].Object.email1_t.Color = NAVY	
				   tab_1.idw_tabpage[1].Object.email1_t.Background.Color = WHITE
				Else
				   tab_1.idw_tabpage[1].Object.email1_t.Color = BLACK				
				   tab_1.idw_tabpage[1].Object.email1_t.Background.Color = WHITE
			   End If
			 
			Case "ctype2"
//				If lb_check1 Then		//개인이면 주민등록 번호 필수
//					tab_1.idw_tabpage[1].Object.socialsecurity.Color = RGB(255,255,255)		
//					tab_1.idw_tabpage[1].Object.socialsecurity.Background.Color = RGB(108, 147, 137)
////					tab_1.idw_tabpage[1].Object.holder_ssno.Format = "@@@@@@@@@@@@@"
////					tab_1.idw_tabpage[1].object.holder[row] = tab_1.idw_tabpage[1].object.customernm[row]
////					tab_1.idw_tabpage[1].object.holder_ssno[row] = tab_1.idw_tabpage[1].object.ssno[row]
//				Else
//					tab_1.idw_tabpage[1].Object.socialsecurity.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.socialsecurity.Background.Color = RGB(255, 255, 255)
//				End If	
				
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
//					
//					tab_1.idw_tabpage[1].Object.cregno.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.cregno.Background.Color = RGB(255, 255, 255)
//
//					tab_1.idw_tabpage[1].Object.representative.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.representative.Background.Color = RGB(255, 255, 255)
					
//					tab_1.idw_tabpage[1].Object.businesstype.Color = RGB(0, 0, 0)		
//					tab_1.idw_tabpage[1].Object.businesstype.Background.Color = RGB(255, 255, 255)
//					
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
		  End Choose
		  
		  //개인이면
		  If lb_check1 Then
//				Choose Case dwo.name
//					Case "customernm"
//						tab_1.idw_tabpage[1].object.holder[row] = data
//					Case "zipcode" 
//						tab_1.idw_tabpage[1].object.holder_zipcod[row] = data
//					Case "ssno"
//						tab_1.idw_tabpage[1].object.holder_ssno[row] = data
//				End Choose
			ElseIf lb_check2 Then		//법인이면
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
			End If
		
//Billing Info		
	Case 2		//Tab
		Choose Case dwo.name
			Case "inv_method"
				If is_inv_method = Trim(data) Then
					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(108, 147, 137)
				Else
					tab_1.idw_tabpage[2].Object.bil_email.Color = RGB(0, 0, 0)		
					tab_1.idw_tabpage[2].Object.bil_email.Background.Color = RGB(255, 255, 255)
				End If
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
			 Case "billinginfo_currency_type"
				 
				 ls_payid = tab_1.idw_tabpage[2].object.customerid[1]		//Pay ID
				 
				 Select count(customerid) into :li_exist from customerm where customerid <> payid and payid = :ls_payid;
				 Select count(customerid) into :li_exist1 From svcorder where customerid = :ls_payid;
				 If li_exist > 0  Or li_exist1 > 0 Then 
					f_msg_usr_err(404, title, "") 
					//다시 원복 한다.
					tab_1.idw_tabpage[2].object.billinginfo_currency_type[1] = is_currency_old
					tab_1.idw_tabpage[2].SetitemStatus(1, "billinginfo_currency_type", Primary!, NotModified!)   //수정 안되었다고 인식.
					Return 2
				 End If
			
			Case "pay_method"
//				Choose case is_pay_method_ori     //변경전데이타
//					case is_method    			  //자동이체
//						If Trim(data) <> is_pay_method_ori Then   //변경된데이타: 자동이체가 아닌경우
//							If is_drawingresult_ori = is_drawingresult[4] Then   //변경전 신청결과가 처리성공인경우
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= idt_sysdate			   //신청일자:sysdate
//								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[4]     //신청유형:해지
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]   //신청결과:미처리
//								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod         //신청접수처:이용이관
//							Else
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= idt_sysdate			   //신청일자:sysdate
//								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[1]		   //신청유형:없음
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[1]	   //신청결과:없음
//								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod			   //신청접수처:이용기관
//							End If
//						Elseif Trim(data) = is_pay_method_ori Then      //자동이체 -> 지로, 기타 -> 자동이체 일경우가 존재 할 수 있기 때문에...원래대로 setting
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= id_drawingreqdt_ori
//								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype_ori
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
//								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod_ori
//								tab_1.idw_tabpage[2].Object.receiptdt[1] 		= id_receiptdt_ori
//								tab_1.idw_tabpage[2].Object.resultcod[1] 		= is_resultcod_ori	
//								tab_1.idw_tabpage[2].Object.bank[1] 			= is_bank_ori
//								tab_1.idw_tabpage[2].Object.acctno[1] 			= is_acctno_ori
//								tab_1.idw_tabpage[2].Object.acct_owner[1] 	= is_acct_owner_ori
//								tab_1.idw_tabpage[2].Object.acct_ssno[1] 		= is_acct_ssno_ori
//    					End IF
//					case else    //변경전데이타가 자동이체가 아닌경우
//						If Trim(data) = is_method Then      //변경한 데이타가 자동이체인 경우
//						    //지로/카드->자동이체로 변경시 해지 미처리일때 는  자동이체의 신규 처리성공으로 셋팅...
//							If is_drawingtype_ori = is_drawingtype[4] and is_drawingresult_ori = is_drawingresult[2] Then
//								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[2]		//신청유형:신규
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[4]	//신청결과:처리성공
//							Else
//								ls_ctype2 = Trim(tab_1.idw_tabpage[2].Object.customerm_ctype2[1])
//								b1fb_check_control("B0", "P111", "", ls_ctype2,lb_check1)
//								b1fb_check_control("B0", "P110", "", ls_ctype2,lb_check2)
//								tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= idt_sysdate			//신청일자:sysdate
//								tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype[2]		//신청유형:신규
//								tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
//								tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod			//접수처:이용기관
//								If lb_check1 Then //개인이면 주민등록 번호 필수
//									tab_1.idw_tabpage[2].object.acct_ssno[1] 	= tab_1.idw_tabpage[2].Object.customerm_ssno[1]
//								End If	
//								If lb_check2 Then //법인이면 사업장 정보 필수					
//									tab_1.idw_tabpage[2].object.acct_ssno[1] 	= tab_1.idw_tabpage[2].Object.customerm_cregno[1]
//								End If
//							End If
//					    Else
//							tab_1.idw_tabpage[2].Object.drawingreqdt[1] 	= id_drawingreqdt_ori
//							tab_1.idw_tabpage[2].Object.drawingtype[1] 	= is_drawingtype_ori
//							tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult_ori
//							tab_1.idw_tabpage[2].Object.receiptcod[1] 	= is_receiptcod_ori
//							tab_1.idw_tabpage[2].Object.receiptdt[1] 		= id_receiptdt_ori
//							tab_1.idw_tabpage[2].Object.resultcod[1] 		= is_resultcod_ori								
//    					End IF
//				End Choose
				
				lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
				lu_check.is_title    = Title
				lu_check.ii_data[1]  = tab_1.SelectedTab
				lu_check.is_data[1] 	= is_method
				lu_check.is_data[2] 	= is_credit
				lu_check.is_data[3] 	= is_inv_method
				lu_check.is_data[4] 	= is_chg_flag
				lu_check.idw_data[1] = tab_1.idw_tabpage[tab_1.SelectedTab]		
				lu_check.uf_prc_check_11()
				li_rc 					= lu_check.ii_rc
				If li_rc < 0 Then 
					Destroy 	lu_check
					Return 	li_rc
				End If				

			Case "bank_chg"			
				If data = 'Y' Then
					tab_1.idw_tabpage[2].Object.bank.Color = RGB(255, 255, 255)		
					tab_1.idw_tabpage[2].Object.bank.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.acctno.Color = RGB(255, 255, 255)	
					tab_1.idw_tabpage[2].Object.acctno.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.acct_owner.Color = RGB(255, 255, 255)			
					tab_1.idw_tabpage[2].Object.acct_owner.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.acct_ssno.Color = RGB(255, 255, 255)			
					tab_1.idw_tabpage[2].Object.acct_ssno.Background.Color = RGB(108, 147, 137)
					tab_1.idw_tabpage[2].Object.bank.Protect =0
					tab_1.idw_tabpage[2].Object.acctno.Protect = 0
					tab_1.idw_tabpage[2].Object.acct_owner.Protect =0
					tab_1.idw_tabpage[2].Object.acct_ssno.Protect =0
					tab_1.idw_tabpage[2].Object.drawingreqdt[1] = idt_sysdate			//신청일자:sysdate
					tab_1.idw_tabpage[2].Object.drawingtype[1] = is_drawingtype[3]		//신청유형:변경
					tab_1.idw_tabpage[2].Object.drawingresult[1] = is_drawingresult[2]	//신청결과:미처리
					tab_1.idw_tabpage[2].Object.receiptcod[1] = is_receiptcod			//접수처:이용기관
				Else
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
					End If
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
		End Choose
End Choose

Return 0

end event

event type integer tab_1::ue_tabpage_retrieve(long al_master_row, integer ai_select_tabpage);call super::ue_tabpage_retrieve;//Tab Retrieve
DataWindowChild ldc
String 	ls_customerid, ls_payid, ls_zoncod, ls_priceplan, ls_contractseq, ls_validkey
String 	ls_where, ls_filter, ls_type, ls_desc
Long 		ll_row, i, ll_cnt, ll_rowcount, ll_exist
Integer 	li_rc, li_tab
Boolean 	lb_check
Dec     	lc_data, ldc_contractseq, ldc_balance

//b1u_check	lu_check
//lu_check = Create b1u_check

b1u_check1_v20		lu_check
lu_check = Create b1u_check1_v20

li_tab = ai_select_tabpage
If al_master_row = 0 Then Return -1
ls_customerid = Trim(dw_master.object.customerm_customerid[al_master_row])
ls_payid = Trim(dw_master.object.customerm_payid[al_master_row])
//ls_validkey = Trim(dw_master.object.validinfo_validkey[al_master_row])

Choose Case li_tab
	Case 1								//Tab 1	
		//Set
		ls_where = "customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		SELECT NVL(SUM(DECODE(B.IN_YN, 'N', A.TRAMT, 0)) + SUM(DECODE(B.IN_YN, 'Y', A.TRAMT, 0)), 0)
		INTO	 :ldc_balance
		FROM   REQDTL A, TRCODE B
		WHERE  A.PAYID = :ls_payid
		AND    A.TRDT <= TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD')
		AND    A.TRCOD = B.TRCOD;
		
		tab_1.idw_tabpage[li_tab].object.balance[1] = ldc_balance	
		
		tab_1.idw_tabpage[li_tab].SetItemStatus(1, 0, Primary!, NotModified!)
		
		lu_check.is_caller   = "b1w_reg_customer_v20%inq_customer_tab1"
		lu_check.is_title    = Title
		lu_check.ii_data[1]  = li_tab
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
		lu_check.uf_prc_check()
		li_rc = lu_check.ii_rc
		If li_rc < 0 Then 
			Destroy 	lu_check
			Return 	li_rc
		End If
		
		//logid의 데이터가 없을경우
		String ls_logid
		ls_logid = tab_1.idw_tabpage[li_tab].object.logid[1]
		If IsNull(ls_logid) Then ls_logid = ""
		If ls_logid <> "" Then
			tab_1.idw_tabpage[li_tab].object.logid.Pointer = "Arrow!"
			tab_1.idw_tabpage[li_tab].idwo_help_col[1] = idw_tabpage[ai_select_tabpage].object.crt_user
		Else
			If ib_new Then
				tab_1.idw_tabpage[li_tab].object.logid.Pointer = "help!"
				tab_1.idw_tabpage[li_tab].idwo_help_col[1] = idw_tabpage[ai_select_tabpage].object.logid
			End If
		End If
		is_payid_old = tab_1.idw_tabpage[li_tab].object.payid[1]
		
	Case 2
		
		ls_where = "customerm_a.customerid = '" + ls_customerid + "' "
		idw_tabpage[li_tab].is_where = ls_where		
		ll_row = idw_tabpage[li_tab].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_row = 0 Then 
			Return 0 		//해당자료 없는것
		End If
		
		//origin data
		is_pay_method_ori 	= tab_1.idw_tabpage[li_tab].object.pay_method[1]
		is_bank_ori 			= tab_1.idw_tabpage[li_tab].object.bank[1]
		is_acctno_ori 			= tab_1.idw_tabpage[li_tab].object.acctno[1]
		is_acct_owner_ori 	= tab_1.idw_tabpage[li_tab].object.acct_owner[1]
		is_acct_ssno_ori 		= tab_1.idw_tabpage[li_tab].object.acct_ssno[1]			
		is_drawingresult_ori = tab_1.idw_tabpage[li_tab].object.drawingresult[1]
		is_drawingtype_ori 	= tab_1.idw_tabpage[li_tab].object.drawingtype[1]
		id_drawingreqdt_ori 	= tab_1.idw_tabpage[li_tab].object.drawingreqdt[1]
		id_receiptdt_ori 		= tab_1.idw_tabpage[li_tab].object.receiptdt[1]
		is_resultcod_ori 		= tab_1.idw_tabpage[li_tab].object.resultcod[1]		
		is_receiptcod_ori		= tab_1.idw_tabpage[li_tab].object.receiptcod[1]			

		If is_drawingtype_ori = is_drawingtype[3] and is_drawingresult_ori = is_drawingresult[2] Then
			is_bank_chg_ori = 'Y' 
        	tab_1.idw_tabpage[li_tab].object.bank_chg[1]  = 'Y'
			tab_1.idw_tabpage[li_tab].SetitemStatus(1, "bank_chg", Primary!, NotModified!)   //수정 안되었다고 인식.				
			is_bank_bef 			= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_bank[1]
			is_acctno_bef 			= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acctno[1]
			is_acct_owner_bef 	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_owner[1]
			is_acct_ssno_bef 		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_acct_ssno[1]			
			is_drawingresult_bef = tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingresult[1]
			is_drawingtype_bef 	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingtype[1]
			id_drawingreqdt_bef 	= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_drawingreqdt[1]
			id_receiptdt_bef 		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptdt[1]
			is_resultcod_bef 		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_resultcod[1]		
			is_receiptcod_bef		= tab_1.idw_tabpage[li_tab].object.billinginfo_bef_receiptcod[1]
		End If
		
		wf_paymethod_chg_check()
		
		lu_check.is_caller   = "b1w_reg_customer_d_v20%inq_customer_tab2"
		lu_check.is_title    = Title
		lu_check.ii_data[1]  = li_tab
		lu_check.is_data[1] 	= is_method
		lu_check.is_data[2] 	= is_credit
		lu_check.is_data[3] 	= is_inv_method
		lu_check.is_data[4] 	= is_chg_flag
		lu_check.idw_data[1] = tab_1.idw_tabpage[li_tab]		
		lu_check.uf_prc_check_11()
		li_rc = lu_check.ii_rc
		If li_rc < 0 Then 
			Destroy lu_check
			Return li_rc
		End If		

	   //화폐
	   is_currency_old = tab_1.idw_tabpage[li_tab].object.billinginfo_currency_type[1]
		
End Choose

Destroy lu_check

Return 0

end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_chg_customer_mobile_bac
end type

type cb_new from commandbutton within b1w_reg_chg_customer_mobile_bac
integer x = 2665
integer y = 176
integer width = 581
integer height = 96
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "New"
end type

event clicked;//양수자 정보 입력 모드
String	ls_new, ls_validkey, ls_customerid, ls_where, ls_operator
Long		ll_master_row, ll_tab_row
Int		li_tab_index

//dw_cond
ls_operator = Trim(dw_cond.object.operator[1])
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1

//dw_master
ll_master_row = dw_master.GetSelectedRow(0)

If ll_master_row < 1 Then Return

ls_customerid = fs_snvl(dw_master.Object.customerm_customerid[ll_master_row], "")

//미납금 체크
If Not wf_unpay_chk(ls_customerid) Then Return

//양수자 정보 등록 Set
tab_1.SetRedraw(False)

ib_new = True
tab_1.SelectedTab 	= 1		//Tab 1 Select
tab_1.Enabled = True
tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
parent.TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.

//tab_1 데이터윈도우 활성화
For li_tab_index = 1 To tab_1.ii_enable_max_tab
	tab_1.idw_tabpage[li_tab_index].Enabled = true
Next

tab_1.SetRedraw(True)

dw_cond.Enabled = False
p_ok.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
cb_new.Enabled = False

Return 0
end event

