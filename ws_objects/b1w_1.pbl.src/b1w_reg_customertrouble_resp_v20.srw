$PBExportHeader$b1w_reg_customertrouble_resp_v20.srw
$PBExportComments$[jwlee] 민원처리V20
forward
global type b1w_reg_customertrouble_resp_v20 from w_a_reg_m_tm2
end type
end forward

global type b1w_reg_customertrouble_resp_v20 from w_a_reg_m_tm2
integer width = 4123
integer height = 2620
end type
global b1w_reg_customertrouble_resp_v20 b1w_reg_customertrouble_resp_v20

type variables
Boolean ib_new			//신규 등록  True
String is_check, is_customerid, is_customernm, is_troubletype, is_troublenote, is_troubletype_nm
String is_trouble_note[], is_trouble_sum, is_closeyn, is_partner, is_trouble_status, is_rec_status[]
decimal ic_troubleno
String is_rec_auth, is_req_auth, is_center, is_prefixno
DataWindowChild idcA, idcB , idwc_troubletype, idwc_close_troubletype

end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wfi_check_boss (string troubletype)
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

public function integer wfi_check_boss (string troubletype);return 1
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
		
//		SELECT codenm
//		INTO :as_codename
//		FROM syscod2t
//		WHERE grcode = 'B330' 
//		  and use_yn = 'Y'
//		  and code = :as_code ;

		SELECT troubletypenm
		INTO :as_codename
		FROM troubletypemst
		WHERE troubletype = :as_code; 
		
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

on b1w_reg_customertrouble_resp_v20.create
int iCurrent
call super::create
end on

on b1w_reg_customertrouble_resp_v20.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_reg_customertrouble
	Desc.	: 고객 민원접수 및 처리
	Ver.	: 1.0
	Date	: 2002.10.01
	Programer : Park Kyung Hae (parkkh)
------------------------------------------------------------------------*/
String ls_temp, ls_ref_desc, ls_customerid
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)
ib_new = False
is_check = ""

is_req_auth = fs_get_control("A1", "C810", ls_ref_desc)

dw_cond.object.partner[1] = gs_user_group

If is_req_auth = "" Then
	f_msg_usr_err(9000, Title, "민원처리처권한 정보가 없습니다.(SYSCTL1T:A1:C810)")
	return
End If

is_center = fs_get_control("A1", "C102", ls_ref_desc)   

If is_center = "" Then
	f_msg_usr_err(9000, Title, "본사대리점코드 정보가 없습니다.(SYSCTL1T:A1:C102)")
	return
End If

ls_temp = fs_get_control("A1", "C830", ls_ref_desc)
If ls_temp = "" Then Return 0
fi_cut_string(ls_temp, ";" , is_rec_status[])
If is_rec_status[3] = "" Then
	f_msg_usr_err(9000, Title, "민원처리상태 정보가 없습니다.(SYSCTL1T:A1:C830)")
	Close(This)
End If

SELECT PREFIXNO
  INTO :is_prefixno
  FROM PARTNERMST
 WHERE PARTNER = :gs_user_group;
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title, "PREFIXNO SELECT")
	Return
End If

ls_customerid = iu_cust_msg.is_call_name[2]

IF IsNull(ls_customerid) = False THEN
	dw_cond.Object.customerid[1] = ls_customerid
	p_ok.TriggerEvent(Clicked!)	
END IF
	
end event

event ue_ok();call super::ue_ok;//dw_master 조회
String ls_customerid, ls_partner, ls_temp, ls_result[], ls_modelno, ls_trouble_status
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close, ls_pid, ls_validkey
String ls_category, ls_selectcod
String ls_customernm, ls_ssno, ls_cregno, ls_svccod, ls_receipt_user
String ls_filter
Date ld_fromdt, ld_todt
Long ll_row
integer li_rc, li_cnt, li_return
DataWindowChild ldwc_partner

dw_cond.AcceptText()
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_partner    = Trim(dw_cond.object.partner[1])
ls_type       = Trim(dw_cond.object.troubletype[1])
ls_category   = Trim(dw_cond.object.category[1])
ls_selectcod  = Trim(dw_cond.object.selectcod[1])
ls_close      = Trim(dw_cond.object.close_yn[1])
ld_todt       = dw_cond.object.todt[1]
ld_fromdt     = dw_cond.object.fromdt[1]
ls_todt       = String(ld_todt, 'yyyymmdd')
ls_fromdt     = String(ld_fromdt, 'yyyymmdd')
ls_new        = Trim(dw_cond.object.new[1])

If ls_new = "Y" Then ib_new = True

ls_modelno        = Trim(dw_cond.object.model[1])
ls_trouble_status = Trim(dw_cond.object.trouble_status[1])
ls_validkey       = fs_snvl(Trim(dw_cond.Object.validkey[1]), "")
ls_pid            = fs_snvl(Trim(dw_cond.Object.pid[1]), "")

ls_customernm     = fs_snvl(Trim(dw_cond.Object.customernm[1]), "")
ls_ssno           = fs_snvl(Trim(dw_cond.Object.ssno[1]), "")
ls_cregno         = fs_snvl(Trim(dw_cond.Object.cregno[1]), "")
ls_svccod         = fs_snvl(Trim(dw_cond.Object.svccod[1]), "")
ls_receipt_user   = fs_snvl(Trim(dw_cond.Object.receipt_user[1]), "")

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
	
	// partner filter - jsha(2005/06/27)
	li_rc = tab_1.idw_tabpage[1].GetChild("customer_trouble_partner", ldwc_partner)
	If li_rc = -1 Then
		f_msg_usr_err(9000, This.Title, "GetChild(Customer_trouble_partner")
		Return
	End If
		
	ls_filter = "prefixno LIKE '" + is_prefixno + "%' "
	ldwc_partner.SetFilter(ls_filter)
	ldwc_partner.Filter()
	ldwc_partner.SetTransObject(SQLCA)
	ll_row = ldwc_partner.Retrieve()
	
	If ll_row < 0 Then
		f_msg_usr_err(2100, This.Title, "Retrieve() DDDW")
		Return
	End IF
	
	
	Return
Else
		//Null Check
		If IsNull(ls_customerid)     Then ls_customerid     = ""
		If IsNull(ls_partner)        Then ls_partner        = ""
		If IsNull(ls_type)           Then ls_type           = ""
		If IsNull(ls_category)       Then ls_category       = ""
		If IsNull(ls_selectcod)      Then ls_selectcod      = ""
		If IsNull(ls_todt)           Then ls_todt           = ""
		If IsNull(ls_fromdt)         Then ls_fromdt         = ""
		If IsNull(ls_close)          Then ls_close          = ""
		If IsNull(ls_modelno)        Then ls_modelno        = ""
      If IsnUll(ls_trouble_status) Then ls_trouble_status = ""

		//	필수입력 Check
		If ls_partner = "" Then
			f_msg_usr_err(200, This.Title, "민원처리처")
			dw_cond.SetRow(1)
			dw_cond.SetColumn("partner")
			dw_cond.SetFocus()
			Return
		End If
		
		//Retrieve
		ls_where = ""
		IF ls_customerid <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.customerid = '" + ls_customerid + "' "
		End If
		
		If ls_customernm <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.customernm = '" + ls_customernm + "' "
		End If
		
		If ls_ssno <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.ssno LIKE '" + ls_ssno + "%' "
		End If
		
		If ls_cregno <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.cregno = '" + ls_cregno + "' "
		End If
		
		If ls_svccod <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.svccod = '" + ls_svccod + "' "
		End If
		
		IF ls_partner <> is_center THEN
			IF ls_partner <> "" Then 
				If ls_where <> "" Then ls_where += " And "
				ls_where += "customer_trouble.partner = '" + ls_partner + "' "
			End If
		END IF
		
		IF ls_type <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.troubletype = '" + ls_type + "' "
		End If
//		//start 민원처리를 정책에 따라 조회 jwlee 2005.12.29
//		CHOOSE CASE is_req_auth
//			CASE '1'
//				If ls_where <> "" Then ls_where += " And "
//				ls_where += "CUSTOMERM.PARTNER_PREFIX = '" + is_PREFIXNO + "' "
//			CASE '2'
//				If ls_where <> "" Then ls_where += " And "
//				ls_where += "CUSTOMERM.PARTNER_PREFIX LIKE '" + is_PREFIXNO+ "%' "
//			CASE '3'
//				If ls_where <> "" Then ls_where += " And "
//				ls_where += "'"+is_PREFIXNO+"'"+" LIKE CUSTOMERM.PARTNER_PREFIX||'%' " 
//		END CHOOSE
		//end
		
		
		IF ls_selectcod <> "" Then 
			IF ls_category <> "" Then 
				If ls_where <> "" Then ls_where += " And "
				CHOOSE CASE ls_selectcod
					CASE "categoryC"
						ls_where += "troubletypeb.troubletypec = '" + ls_category + "' "
					CASE "categoryB"
						ls_where += "troubletypea.troubletypeb = '" + ls_category + "' "
					CASE "categoryA"
						ls_where += "troubletypemst.troubletypea = '" + ls_category + "' "
				END CHOOSE
				
			End If
		End If
      
			IF ls_modelno <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.modelno = '" + ls_modelno + "' "
		End If
		
		IF ls_trouble_status <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "customer_trouble.trouble_status = '" + ls_trouble_status + "' "
		End If
		
		If ls_validkey <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.validkey = '" + ls_validkey + "' "
		End If
		
		If ls_pid <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.pid = '" + ls_pid + "' "
		End If
		
		If ls_receipt_user <> "" Then
			If ls_where <> "" Then ls_where += " AND "
			ls_where += "customer_trouble.receipt_user = '" + ls_receipt_user + "' "
		End IF
		
		//ranger가 확정이 되면
		If ls_fromdt <> ""  and ls_todt <> "" Then
		   ll_row = fi_chk_frto_day(ld_fromdt, ld_todt)
		   If ll_row < 0 Then
			 f_msg_usr_err(211, Title, "접수일자")             //입력 날짜 순저 잘 못 됨
			 dw_cond.SetFocus()
			 dw_cond.SetColumn("fromdt")
			 Return 
		   End If 	
		  If ls_where <> "" Then ls_where += " And "  
		  ls_where += "to_char(customer_trouble.receiptdt, 'YYYYMMDD') >='" + ls_fromdt + "' " + &
						"and to_char(customer_trouble.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' "
					  
		ElseIf ls_fromdt <> "" and ls_todt = "" Then			//시작 날짜만 있을때 
		   If ls_where <> "" Then ls_where += "And "
		   ls_where += "to_char(customer_trouble.receiptdt,'YYYYMMDD') > = '" + ls_fromdt + "' "
		ElseIf ls_fromdt = "" and ls_todt <> "" Then			//끝나는 날짜만 있을때   
			If ls_where <> "" Then ls_where += "And "
		   ls_where += "to_char(customer_trouble.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' " 
		End If
		
		If ls_close <> "" Then
			If ls_where <> "" Then ls_where += "And "
			ls_where += " customer_trouble.closeyn = '" + ls_close + "' "
		End If
		
		dw_master.is_where = ls_where
		ll_row = dw_master.Retrieve()
		
		If ll_row > 0 Then
			ic_troubleno = dw_master.object.troubleno[1]
			is_customerid = dw_master.object.customerid[1] 
			is_customernm = dw_master.object.customernm[1]
			is_troubletype = dw_master.object.troubletype[1]
			is_troublenote = dw_master.object.trouble_note[1]
			
			is_trouble_note[] = ls_result[]
			If is_troublenote <> '' Then li_return = wfi_cut_string(is_troublenote,"~r", is_trouble_note[])

			is_trouble_sum = ""			
			If UpperBound(is_trouble_note) >= 5 Then
				For li_cnt = 5 To UpperBound(is_trouble_note)
					 is_trouble_sum += is_trouble_note[li_cnt]				
				Next
			End if
			
			li_rc = wfi_set_codename("T", is_troubletype, is_troubletype_nm)
			If li_rc < 0 then return 
			
		End if
		
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

event ue_extra_insert;//Insert시 조건
Dec    lc_troubleno
Dec    lc_num
Long   ll_master_row, ll_seq , i, ll_row
STRING ls_troubleno

dw_master.AcceptText()

ll_master_row = dw_master.GetSelectedRow(0)

Choose Case ai_selected_tab
	Case 1								//Tab 1
		Select seq_troubleno.nextval 
		Into :lc_num
		From dual;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select seq_troubleno.nextval")
			RollBack;
			Return -1
		End If				

		tab_1.idw_tabpage[1].object.customer_trouble_contractseq.Protect    = 1	
		tab_1.idw_tabpage[1].object.customer_trouble_svccod.Protect         = 1
		tab_1.idw_tabpage[1].object.customer_trouble_priceplan.Protect      = 1	
		tab_1.idw_tabpage[1].object.troubletypea_troubletypeb.Protect       = 1	
		tab_1.idw_tabpage[1].object.customer_trouble_troubletype.Protect    = 1		
	   
		tab_1.idw_tabpage[1].object.customer_trouble_troubleno[al_insert_row] = lc_num	//Trouble Num Setting
		tab_1.idw_tabpage[1].object.customer_trouble_receipt_user[al_insert_row] = gs_user_id //접수자
		tab_1.idw_tabpage[1].object.customer_trouble_receiptdt[al_insert_row] = Date(fdt_get_dbserver_now()) //date
		//Log
		tab_1.idw_tabpage[1].object.customer_trouble_crt_user[al_insert_row] = gs_user_id
		tab_1.idw_tabpage[1].object.customer_trouble_crtdt[al_insert_row] = fdt_get_dbserver_now()
		tab_1.idw_tabpage[1].object.customer_trouble_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[1].object.customer_trouble_updt_user[1] = gs_user_id
		tab_1.idw_tabpage[1].object.customer_trouble_updtdt[1] = fdt_get_dbserver_now()
		
	Case 2							   //Tab 2
		
		If ll_master_row = 0 Then Return -1
		lc_troubleno = dw_master.object.troubleno[ll_master_row]
		
		ls_troubleno = tab_1.idw_tabpage[2].object.troubleno_t.text
		//2009.12.22 jhchoi 추가함. ll_master_row 가 틀어져서 잘못들어가기 때문에...
		IF ls_troubleno <> String(lc_troubleno) THEN
			lc_troubleno = Dec(ls_troubleno)
		END IF
		
		//Seq Number
		Select nvl(max(seq) + 1, 1)
		Into   :ll_seq
		From   troubl_response
		Where  troubleno = :lc_troubleno ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Seq")
			RollBack;
			Return -1
		End If				
		
		//Seq 비교 확인
		ll_row = tab_1.idw_tabpage[2].RowCount()
		If ll_row <> 0 Then
			For i = 1 To ll_row
				//seq number 이 같으면
				If ll_seq = tab_1.idw_tabpage[2].object.troubl_response_seq[i] Then
					ll_seq += 1
				End If	
			Next
		End If	
		
		//모든 row 를 삭제하고 다시 insert할때.
//		If al_insert_row = 1 Then
//			tab_1.idw_tabpage[2].object.customer_trouble_troubleno[al_insert_row] = &
//				lc_troubleno
//			tab_1.idw_tabpage[2].object.customer_trouble_troubletype[al_insert_row] = &
//				dw_master.object.customer_trouble_troubletype[ll_master_row]
//			tab_1.idw_tabpage[2].object.customer_trouble_customerid[al_insert_row] = &
//				dw_master.object.customer_trouble_customerid[ll_master_row]
//			tab_1.idw_tabpage[2].object.customer_trouble_note[al_insert_row] = &
//			 	dw_master.object.customer_trouble_note[ll_master_row]
//		End If

		tab_1.idw_tabpage[2].object.troubl_response_seq[al_insert_row]            = ll_seq  //seq
		tab_1.idw_tabpage[2].object.troubl_response_response_user[al_insert_row]  = gs_user_id //처리자
		tab_1.idw_tabpage[2].object.troubl_response_responsedt[al_insert_row]     = Date(fdt_get_dbserver_now()) //date
		tab_1.idw_tabpage[2].object.troubl_response_partner[al_insert_row]        = gs_user_group //조치자의 Parter
		tab_1.idw_tabpage[2].object.troubl_response_troubleno[al_insert_row]      = lc_troubleno
		tab_1.idw_tabpage[2].object.close_yn[al_insert_row]                       = is_closeyn  //처리완료
		tab_1.idw_tabpage[2].object.troubl_response_trouble_status[al_insert_row] = is_rec_status[2] //민원처리를 하면 처리중으로 SETTING
//		tab_1.idw_tabpage[2].object.status[1]                                     = is_rec_status[2] //민원처리를 하면 처리중으로 SETTING
		tab_1.idw_tabpage[2].object.status[al_insert_row]                         = is_rec_status[2] //민원처리를 하면 처리중으로 SETTING
		tab_1.idw_tabpage[2].object.partner[al_insert_row]                        = is_partner
		//Log
		tab_1.idw_tabpage[2].object.troubl_response_crt_user[al_insert_row]       = gs_user_id
		tab_1.idw_tabpage[2].object.troubl_response_crtdt[al_insert_row]          = fdt_get_dbserver_now()
		tab_1.idw_tabpage[2].object.troubl_response_pgm_id[al_insert_row]         = gs_pgm_id[gi_open_win_no]
		tab_1.idw_tabpage[2].object.troubl_response_updt_user[al_insert_row]      = gs_user_id	
		tab_1.idw_tabpage[2].object.troubl_response_updtdt[al_insert_row]         = fdt_get_dbserver_now()
		
		tab_1.idw_tabpage[2].SetFocus()
		tab_1.idw_tabpage[2].SetColumn('troubl_response_response_note')
		
End Choose

Return 0 
end event

event close;call super::close;ib_new = False		//초기화
end event

event ue_reset;call super::ue_reset;dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("customerid")
tab_1.SelectedTab = 1
ib_new = False
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")


dw_cond.object.partner[1] = gs_user_group
Return 0
end event

event type integer ue_extra_delete();call super::ue_extra_delete;//Delete 조건
Dec lc_troubleno
Long ll_master_row, ll_cnt
String ls_receipt_user, ls_troubletype
Integer li_check = 1

ll_master_row = dw_master.GetRow()
If ll_master_row = 0 Then  Return 0    //삭제 가능

Choose Case tab_1.SelectedTab
	Case 1						//Tab
		lc_troubleno = dw_master.object.troubleno[ll_master_row]
		ls_receipt_user = dw_master.object.receipt_user[ll_master_row]		
		ls_troubletype = dw_master.object.troubletype[ll_master_row]

//		=========================================================================================
//		2008-03-05 hcjung				
//		보스 연동 대상인 장애는 삭제할 수 없다. 
//		=========================================================================================	
		SELECT COUNT(*) 
		  INTO :li_check
		  FROM TROUBLE_BOSS 
		 WHERE USE_YN = 'Y'
		   AND TROUBLETYPE = :ls_troubletype;

		IF SQLCA.SQLCode < 0 THEN
			f_msg_sql_err(This.Title,"TROUBLETYPE Select Error")
			Return -1
		END IF

		IF  li_check > 0 THEN
			f_msg_usr_err(9000, Title, "삭제불가! 보스 연동 대상은 삭제할 수 없습니다.")  //삭제 안됨
			RETURN -1
		END IF			
		
		If ls_receipt_user <> gs_user_id Then
			f_msg_usr_err(9000, Title, "삭제불가! 접수자만 삭제가능합니다.")  //삭제 안됨
			Return -1
		End if			
		
		//trouble_shoothing table에 해당 사항이 있으면 삭제 불가능
		Select count(*)
		Into :ll_cnt
		From troubl_response
		Where troubleno = :lc_troubleno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(This.Title, "Select Error")
			RollBack;
			Return -1
		End If				
		
		If ll_cnt <> 0 Then
			f_msg_usr_err(9000, Title, "삭제불가! 장애처리건이 존재합니다.")  //삭제 안됨 
			Return -1
		Else 							
			is_check = "DEL"							   //삭제 가능
		End If
		
End Choose

Return 0 
end event

event type integer ue_extra_save(integer ai_select_tab);call super::ue_extra_save;//Save
Long ll_row
Integer li_rc, ll_i
b1u_check_v20  lu_check
lu_check = Create b1u_check_v20

//Row 수가 없으면
ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
If ll_row = 0 Then Return 0

lu_check.is_caller   = "b1w_reg_customermtrouble_v20%extra_save"
lu_check.is_title    = This.Title
lu_check.ib_data[1]  = ib_new
lu_check.ii_data[1]  = ai_select_tab 								//SelectedTab 
lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]		//Data Window
lu_check.uf_prc_check()

li_rc = lu_check.ii_rc

If li_rc < 0 Then 
	Destroy lu_check
	Return li_rc
End If
commit;
Destroy lu_check

Choose Case ai_select_tab
	Case 1
		//Update Log
		tab_1.idw_tabpage[ai_select_tab].object.customer_trouble_updt_user[1] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.customer_trouble_updtdt[1] = fdt_get_dbserver_now()
		
   Case 2 
		//Update Log
		ll_row = tab_1.idw_tabpage[ai_select_tab].RowCount()
		For ll_i = 1 To ll_row
			If tab_1.idw_tabpage[ai_select_tab].GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
				tab_1.idw_tabpage[ai_select_tab].object.troubl_response_updt_user[ll_row] = gs_user_id	
				tab_1.idw_tabpage[ai_select_tab].object.troubl_response_updtdt[ll_row] = fdt_get_dbserver_now()
			End If
	   Next
	Case 3
		//Update Log
		tab_1.idw_tabpage[ai_select_tab].object.customer_trouble_updt_user[1] = gs_user_id
		tab_1.idw_tabpage[ai_select_tab].object.customer_trouble_updtdt[1] = fdt_get_dbserver_now()
		
End Choose

Return 0
end event

event ue_save;Constant Int LI_ERROR = -1
Int li_tab_index, li_return, ll_row
String ls_payid, ls_shopid, ls_customerid, ls_close_yn, ls_trouble_status, ls_partner, ls_status, ls_close_user
LONG	ll_selected_row 
Dec lc_troubleno
//date ld_closedt
datetime ld_closedt

dw_master.AcceptText()

ll_row  = dw_master.GetRow()
li_tab_index = tab_1.SelectedTab

//2009.11.04 JHCHOI 추가함. 
ll_selected_row = dw_master.GetSelectedRow(0)
lc_troubleno = dw_master.Object.troubleno[ll_selected_row]

IF ic_troubleno <> lc_troubleno THEN
	f_msg_sql_err(title, "Error! 접수번호가 틀립니다.")
	Return LI_ERROR
END IF

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

Long ll_tab_rowcount
Integer li_selectedTab
li_selectedtab = tab_1.SelectedTab
ll_tab_rowcount = tab_1.idw_tabpage[li_selectedTab].RowCount()

//	2번째 Tab이면 처리완료 Customer_Trouble Update
If li_tab_index = 2 Then
	If ll_tab_rowcount > 0 Then
		ls_close_yn = tab_1.idw_tabpage[li_tab_index].object.close_yn[1]
		ls_trouble_status = tab_1.idw_tabpage[li_tab_index].object.status[1]
		ls_partner = tab_1.idw_tabpage[li_tab_index].object.partner[1]
		
		IF ls_close_yn = '' OR IsNull(ls_close_yn) THEN ls_close_yn = 'N'
		
		// Update Customer_trouble
		UPDATE customer_trouble 
		   SET closeyn = :ls_close_yn,
				 partner = :ls_partner, 
				 trouble_status = :is_rec_status[2] 
		 WHERE troubleno = :ic_troubleno;
		
	  If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Update Error (customer_trouble)")
			Return LI_ERROR
		End If
	End If
ElseIf li_tab_index = 3 Then
	If ll_tab_rowcount > 0 Then
		ls_close_yn   = tab_1.idw_tabpage[li_tab_index].object.customer_trouble_closeyn[1]
//		ld_closedt    = date(tab_1.idw_tabpage[li_tab_index].object.customer_trouble_closedt[1])
		ld_closedt    = datetime(tab_1.idw_tabpage[li_tab_index].object.customer_trouble_closedt[1])		
		ls_close_user = tab_1.idw_tabpage[li_tab_index].object.customer_trouble_close_user[1]
		
		If ls_close_yn = 'Y' Then
			ls_status = is_rec_status[3] 
		Else 
			ls_status = is_rec_status[2] 
		End If
		// Update Customer_trouble
		UPDATE customer_trouble 
			SET closeyn = :ls_close_yn,
				 partner = :gs_user_group, 
				 closedt = :ld_closedt, 
				 close_user = :ls_close_user, 
				 close_partner  = :gs_user_group,
				 trouble_status = :ls_status
		 WHERE troubleno = :ic_troubleno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Update Error (customer_trouble)")
			Return LI_ERROR
		End If
		
		UPDATE troubl_response
			SET trouble_status = :ls_status
		 WHERE troubleno = :ic_troubleno;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, "Update Error (customer_trouble)")
			Return LI_ERROR
		End If
			
	End If
	
End If

//COMMIT와 동일한 기능

COMMIT;
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = tab_1.is_parent_title
iu_cust_db_app.uf_prc_db()
If iu_cust_db_app.ii_rc = -1 Then
	Return LI_ERROR
End If

tab_1.idw_tabpage[li_tab_index].ResetUpdate ()		
f_msg_info(3000,tab_1.is_parent_title,"Save")

//TriggerEvent("ue_ok")

//dw_master.SelectRow(1, FALSE)
//dw_master.setRow(ll_row)
//dw_master.SelectRow(ll_row, TRUE)
//
If is_check = "DEL" Then 				//삭제 후
	TriggerEvent("ue_reset")
	is_check = ""
End If

Return 0
end event

event type integer ue_insert();//tab2는 맨 마지막에만 insert 되어야 하므로... 조상 스크립트 수정!!

Constant Int LI_ERROR = -1
Long ll_row
Integer li_curtab
//Int li_return
//ii_error_chk = -1

li_curtab = tab_1.Selectedtab

Choose Case li_curtab
	Case 1
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].GetRow() + 1)		
		
	Case 2  //tab2는 항상 맨 마지막줄에 insert 시킨다... 
		
		ll_row = tab_1.idw_tabpage[li_curtab].InsertRow(tab_1.idw_tabpage[li_curtab].RowCount() + 1)		
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

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_reg_customertrouble_resp_v20
integer x = 55
integer y = 44
integer width = 2985
integer height = 444
string dataobject = "b1dw_cnd_reg_customeridtrouble_resp_v20"
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 //This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_codename, ls_closeyn
integer li_rc, li_seltab
datetime ldt_date
li_seltab = tab_1.SelectedTab
Long ll_row
String ls_filter, ls_itemcod
DataWindowChild ldc

Choose Case dwo.name
//	Case "customerid"
//		
//		 If data = "" then 
//				This.Object.customernm[row] = ""			
//				This.SetFocus()
//				This.SetColumn("customerid")
//				Return -1
// 		 End If		 
//		 
//		 li_rc = wfi_set_codename("C", data, ls_codename)
//		 If li_rc < 0 then return -2
//		 
//		 If ls_codename = "" or isnull(ls_codename ) then
//				This.Object.customerid[row] = ""
//				This.Object.customernm[row] = ""
//				This.SetFocus()
//				This.SetColumn("customerid")
//				Return -1
//		 End if
//		 
//		 This.Object.customernm[row] = ls_codename
		 
//	Case "partner"
//		
//		 If data = "" then 
//			   This.Object.partnernm[row] = ""
//				This.SetFocus()
//				This.SetColumn("partner")
//				Return -1
// 		 End If		 
//
//		 li_rc = wfi_set_codename("P", data, ls_codename)
//		 If li_rc < 0 then return -2
//		 
//		 If ls_codename = "" or isnull(ls_codename ) then
////				This.Object.partner[row] = ""
//			   This.Object.partnernm[row] = ""
//				This.SetFocus()
//				This.SetColumn("partner")
//				Return 1
//		 End if
//		 
//		 This.Object.partnernm[row] = ls_codename
//		 
//2009.05.31 조회조건수정에 따라 제거됨.
//	Case "selectcod"
//		Choose Case data
//			Case "categoryA"         //소분류
//				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''				
//				Modify("category.dddw.name=b1dc_dddw_troubletypea")
//				Modify("category.dddw.DataColumn='troubletypea_troubletypea'")
//				Modify("category.dddw.DisplayColumn='troubletypea_troubletypeanm'")
////				
//			Case "categoryB"			//중분류
//				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''				
//				Modify("category.dddw.name=b1dc_dddw_troubletypeb")
//				Modify("category.dddw.DataColumn='troubletypeb_troubletypeb'")
//				Modify("category.dddw.DisplayColumn='troubletypeb_troubletypebnm'")
//				 
//			Case "categoryC"			//대분류
//				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''				
//				Modify("category.dddw.name=b1dc_dddw_troubletypec")
//				Modify("category.dddw.DataColumn='troubletypec'")
//				Modify("category.dddw.DisplayColumn='troubletypecnm'")
//				
//			Case else					//분류선택 안했을 경우...
//				Modify("category.dddw.name=''")
////				Modify("category.dddw.DataColumn=''")
////				Modify("category.dddw.DisplayColumn=''")
//				This.Object.category[row] = ''
//		End Choose
//2009.05.31-----------------------------------END
	Case "category"	
		This.object.troubletype[1] = ""
		//해당 priceplan에 대한 itemcod
		ll_row = This.GetChild("troubletype", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = " troubletypea_troubletypeb = '" + data + "' "		
	
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve() 
		
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
End Choose

Return 0 
end event

event dw_cond::constructor;call super::constructor;// 민원처리처 dddw Filter - jsha(2005/06/27)
String ls_filter, ls_prefixno
Int li_rc
Long ll_row
DataWindowChild ldc_partner

li_rc = This.GetChild("partner", ldc_partner)
IF li_rc = -1 THEN 
	f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
	Return -2
End If

SELECT prefixno
INTO	:ls_prefixno
FROM	partnermst
WHERE	partner = :gs_user_group;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(This.Title, "PREFIXNO SELECT ERROR")
	Return -2
End If

ls_filter = " prefixno LIKE '" + ls_prefixno + "%' "
ldc_partner.SetFilter(ls_filter)
ldc_partner.Filter()
ldc_partner.SetTransObject(SQLCA)
ll_row = ldc_partner.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Parent.Title, "PARTNER DDDW Retrieve()")
	Return -1
End If
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_reg_customertrouble_resp_v20
integer x = 3054
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_reg_customertrouble_resp_v20
integer x = 1216
integer y = 2392
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_reg_customertrouble_resp_v20
integer width = 3337
integer height = 504
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_reg_customertrouble_resp_v20
integer y = 524
integer width = 3333
integer height = 892
string dataobject = "b1dw_reg_customeridtrouble_resp_m_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort 지정
//dwObject ldwo_SORT
//ldwo_SORT = Object.customernm_t
//uf_init(ldwo_SORT)


DWObject ldwo_col

ldwo_col = Object.troubleno_t

uf_init(ldwo_col, 'D', RGB(0, 0, 128))
end event

event dw_master::clicked;call super::clicked;INT		li_rc,			li_return,			li_cnt,			li_i
STRING	ls_result[],	ls_closeyn
LONG		ll_selected_row

//2009.11.04 jhchoi 추가함. 혹시 몰라서...
dw_master.AcceptText()

//THIS.b_1.Enabled = TRUE

If row > 0 Then
	ic_troubleno = dec(This.object.troubleno[row])
	is_customerid = This.object.customerid[row]
	is_customernm = This.object.customernm[row]
	//tab2에 붙일때... 줄바꾸기해서 붙이기 위해서....
	is_troublenote = This.object.trouble_note[row]
	
	ll_selected_row = This.GetSelectedrow(0)
	
	IF row <> ll_selected_row THEN				// 취소컨택화면에서 취소를 하게되면 SELECTED ROW가 원복된다. 이거 막기위해..
		If IsSelected( row ) then
			SelectRow( row ,FALSE)
		Else
		   SelectRow(0, FALSE )
			SelectRow( row , TRUE )
		End If
	END IF	

	is_trouble_note[]	= ls_result[]
	If is_troublenote <> '' Then li_return = wfi_cut_string(is_troublenote,"~r", is_trouble_note[])
	is_trouble_sum = ""			
	If UpperBound(is_trouble_note) >= 5 Then
		For li_cnt = 5 To UpperBound(is_trouble_note)
			 is_trouble_sum += is_trouble_note[li_cnt]				
		Next
	End if
		
	is_troubletype = This.object.troubletype[row]	
	//troubletype에 맞는 이름 가져오기!!!
	li_rc = wfi_set_codename("T", is_troubletype, is_troubletype_nm)
	If li_rc < 0 then return -2
	 
	//현재 tab2에 focus가 맞춰져 있을때는 text를 붙여준다... 
	If tab_1.Selectedtab = 2 then
		tab_1.idw_tabpage[2].modify("troubleno_t.text = '"+ string(ic_troubleno)+ "'")  //접수번호
		tab_1.idw_tabpage[2].modify("customerid_t.text = '["+ is_customerid + "]'")  //고객번호
		tab_1.idw_tabpage[2].modify("customernm_t.text = '"+ is_customernm + "'")  //고객명
		tab_1.idw_tabpage[2].modify("troubletype_t.text = '"+ is_troubletype_nm + "'")  //고객명
		
		For li_i = 1 To 5
			tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = ''")  //접수내역
		Next

		Choose Case UpperBound(is_trouble_note)
			Case 1 to 4
				
				For li_i = 1 To UpperBound(is_trouble_note)
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = '" + is_trouble_note[li_i] + "'")  //접수내역
				Next
			
			Case Is >= 5
				For li_i = 1 To 4
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) +".text = '"+ is_trouble_note[li_i] + "'")  //접수내역
				Next
				tab_1.idw_tabpage[2].modify("trouble_note_t_5.text = '"+ is_trouble_sum + "'")  //접수내역
				
		End Choose

	End if
End if

Choose Case tab_1.SelectedTab
	Case 1
		
		p_insert.TriggerEvent("ue_disable")
      IF is_closeyn = 'Y' THEN
		   p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
		ELSE
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
		END IF;
		p_reset.TriggerEvent("ue_enable")
		
	Case 2
		
		If is_closeyn = 'Y' then
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		Else
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		End If
	Case 3
//		If ib_new = TRUE Then 
//			f_msg_usr_err(210, parent.Title, "처리내역이 존재하지 않으면 마감을 할수 없습니다.")
//			tab_1.SelectedTab = 2
//			Return 1
//		End If

		If fs_snvl(is_closeyn,'N') = 'N' Then
			tab_1.idw_tabpage[3].object.customer_trouble_close_user[1] = gs_user_id //처리자
			tab_1.idw_tabpage[3].object.customer_trouble_closedt[1]    = Date(fdt_get_dbserver_now()) //date
			tab_1.idw_tabpage[3].object.close_partner[1]               = gs_user_group //조치자의 Parter
			tab_1.idw_tabpage[3].object.customer_trouble_closeyn[1]    = 'Y'    //처리완료
			//Log
			tab_1.idw_tabpage[3].object.customer_trouble_crt_user[1]   = gs_user_id
			tab_1.idw_tabpage[3].object.customer_trouble_crtdt[1]      = fdt_get_dbserver_now()
			tab_1.idw_tabpage[3].object.customer_trouble_pgm_id[1]     = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[3].object.customer_trouble_updt_user[1]  = gs_user_id	
			tab_1.idw_tabpage[3].object.customer_trouble_updtdt[1]     = fdt_get_dbserver_now()
			
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_close_user" , Primary!, NotModified!)  //마스터에 저장하기 위한 컬럼
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_closedt" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "close_partner" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_closeyn" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_crt_user" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_crtdt" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_pgm_id" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_updt_user" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_updtdt" , Primary!, NotModified!)
		End If
		If is_closeyn = 'Y' then
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		Else
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		End If
		
End Choose

Return 0 
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_reg_customertrouble_resp_v20
integer y = 2392
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_reg_customertrouble_resp_v20
integer y = 2392
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_reg_customertrouble_resp_v20
integer y = 2392
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_reg_customertrouble_resp_v20
integer x = 923
integer y = 2392
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_reg_customertrouble_resp_v20
integer y = 1472
integer width = 3337
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init;call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "장애접수"
is_tab_title[2] = "장애처리"
is_tab_title[3] = "장애마감"

is_dwobject[1] = "b1dw_reg_customertrouble_resp_t1_v20"
is_dwobject[2] = "b1dw_reg_customertrouble_resp_t2_v20"
is_dwobject[3] = "b1dw_reg_customertrouble_resp_t3_v20"
end event

event tab_1::constructor;call super::constructor;//Help Window
idw_tabpage[1].is_help_win[1] = "b1w_hlp_customerm"
idw_tabpage[1].idwo_help_col[1] = idw_tabpage[1].Object.customer_trouble_customerid
idw_tabpage[1].is_data[1] = "CloseWithReturn"

Long ll_row
//중분류
ll_row = tab_1.idw_tabpage[1].GetChild("troubletypea_troubletypeb", idcB)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 1")
//소분류
ll_row = tab_1.idw_tabpage[1].GetChild("troubletypemst_troubletypea", idcA)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 2")

//민원유형
ll_row = tab_1.idw_tabpage[1].GetChild("customer_trouble_troubletype", idwc_troubletype)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 3")

// 처리완료시 민원유형
ll_row = tab_1.idw_tabpage[3].GetChild("customer_trouble_close_troubletype", idwc_close_troubletype)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild 4")
end event

event type long tab_1::ue_dw_doubleclicked(integer ai_tabpage, integer ai_xpos, integer ai_ypos, long al_row, dwobject adwo_dwo);call super::ue_dw_doubleclicked;String ls_customerid, ls_sql
int li_null_num, li_rc
Long ll_cnt
DataWindowChild ldwc_contractseq
SetNull(li_null_num)

Choose Case adwo_dwo.name
	Case "customer_trouble_customerid"
		If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
			 idw_tabpage[ai_tabpage].Object.customer_trouble_customerid[al_row] = &
			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
			 
			 idw_tabpage[ai_tabpage].Object.customer_trouble_customernm[al_row] = &
			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
			 
		End If
		
		ls_customerid = idw_tabpage[ai_tabpage].Object.customer_trouble_customerid[al_row]
		
		tab_1.idw_tabpage[1].object.customer_trouble_contractseq[1] = li_null_num
		tab_1.idw_tabpage[1].object.customer_trouble_svccod[1]		= ""
		tab_1.idw_tabpage[1].object.customer_trouble_priceplan[1]   = ""
		tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1]  = ""	
		tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
		tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1]    = ""						
		
		//	=========================================================================================
      //	2008-02-22 hcjung				
      // 고객 번호를 입력 받으면 해당 고객의 개통 상태 계약건만 조회된다.
      // =========================================================================================
		tab_1.idw_tabpage[1].object.customer_trouble_contractseq.protect = 0
		tab_1.idw_tabpage[1].object.customer_trouble_contractseq[1] = li_null_num	
		
		li_rc = tab_1.idw_tabpage[1].GetChild("customer_trouble_contractseq", ldwc_contractseq)
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " select a.contractseq, b.svcdesc, a.customerid  from contractmst a, svcmst b " + &
					" where a.customerid = '" + ls_customerid + "' and a.svccod = b.svccod order by contractseq desc "
		ldwc_contractseq.SetSqlselect(ls_sql)
		ldwc_contractseq.SetTransObject(SQLCA)
		ll_cnt = ldwc_contractseq.Retrieve()

		IF ll_cnt < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "contractmst Retrieve()")
			RETURN -2
		END IF	
		
//	Case "customer_trouble_partner"
//		If idw_tabpage[ai_tabpage].iu_cust_help.ib_data[1] Then
//			 idw_tabpage[ai_tabpage].Object.customer_trouble_partner[al_row] = &
//			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[1]
//			 
//			 idw_tabpage[ai_tabpage].Object.partnermst_partnernm[al_row] = &
//			 idw_tabpage[ai_tabpage].iu_cust_help.is_data[2]
//			 
//		End If
		
End Choose
Return 0 
end event

event type integer tab_1::ue_itemchanged(long row, dwobject dwo, string data);call super::ue_itemchanged;//Item Change Event
String ls_codename, ls_closeyn, ls_svccod, ls_troubletypec, ls_priceplan
integer li_rc, li_seltab, li_row, li_null_num
datetime ldt_date
li_seltab = tab_1.SelectedTab
Long ll_row, i
String ls_filter, ls_itemcod, ls_admodel_yn, ls_sql
DataWindowChild ldc, ldwc_troubletype, ldwc_contractseq, ldwc_troubletypeb
SetNull(li_null_num)


Choose Case li_seltab
	Case 1														//Tab 1
		Choose Case dwo.name
			Case "customer_trouble_customerid"
				
				 li_rc = wfi_set_codename("C", data, ls_codename)
				 If li_rc < 0 then return -2
				 
				 If ls_codename = "" or isnull(ls_codename ) then
						tab_1.idw_tabpage[li_seltab].Object.customer_trouble_customerid[row] = ""
	 				   tab_1.idw_tabpage[li_seltab].Object.customer_trouble_customernm[row] = ""
						tab_1.idw_tabpage[li_seltab].SetFocus()
						tab_1.idw_tabpage[li_seltab].SetColumn("customer_trouble_customerid")
						Return 1
				 End if
				 
				 tab_1.idw_tabpage[li_seltab].Object.customer_trouble_customernm[row] = ls_codename
				 
				tab_1.idw_tabpage[1].object.customer_trouble_contractseq[1] = li_null_num
				tab_1.idw_tabpage[1].object.customer_trouble_svccod[1]		= ""
				tab_1.idw_tabpage[1].object.customer_trouble_priceplan[1]   = ""
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1]  = ""	
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1]    = ""								 
				 
//				=========================================================================================
//				2008-02-22 hcjung				
//				고객 번호를 입력 받으면 해당 고객의 개통 상태 계약건만 조회된다.
//				=========================================================================================
            tab_1.idw_tabpage[1].object.customer_trouble_contractseq.protect = 0
				tab_1.idw_tabpage[1].object.customer_trouble_contractseq[1] = li_null_num	
				
				li_rc = tab_1.idw_tabpage[1].GetChild("customer_trouble_contractseq", ldwc_contractseq)
				IF li_rc = -1 THEN
					f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
					RETURN -2
				END IF
				
				ls_sql = " select a.contractseq, b.svcdesc, a.customerid  from contractmst a, svcmst b " + &
							" where a.customerid = '" + data + "' and a.svccod = b.svccod order by contractseq desc "
				ldwc_contractseq.SetSqlselect(ls_sql)
				ldwc_contractseq.SetTransObject(SQLCA)
				ll_row = ldwc_contractseq.Retrieve()
		
				IF ll_row < 0 THEN 				//디비 오류 
					f_msg_usr_err(2100, Title, "contractmst Retrieve()")
					RETURN -2
				END IF		
//			=========================================================================================
//			2008-02-25 hcjung				
//			계약을 선택하면 서비스와 가격정책를 자동으로 자동으로 세팅하고,
//       민원 중분류를 새로운 Dropdown으로 자동으로 세팅한다.
//			=========================================================================================
			CASE "customer_trouble_contractseq"
				tab_1.idw_tabpage[1].object.customer_trouble_svccod.Protect         = 0
				tab_1.idw_tabpage[1].object.customer_trouble_priceplan.Protect      = 0
				tab_1.idw_tabpage[1].object.troubletypea_troubletypeb.Protect   	  = 0
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype.Protect    = 0				
				tab_1.idw_tabpage[1].object.customer_trouble_svccod[1]				  = ""
				tab_1.idw_tabpage[1].object.customer_trouble_priceplan[1]           = ""
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1]          = ""				
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1]			  = ""
				tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1]  			  = ""				
				
				SELECT svccod,priceplan 
				  INTO :ls_svccod,:ls_priceplan
				  FROM CONTRACTMST
				 WHERE CONTRACTSEQ = :data;
				 
				IF SQLCA.SQLCODE <> 0 THEN
					f_msg_usr_err(2100, Title, "SELECT CONTRACT")
					tab_1.idw_tabpage[1].SetRow(1)
					tab_1.idw_tabpage[1].SetColumn("customer_trouble_contractseq")
					tab_1.idw_tabpage[1].SetFocus()
					RETURN 0
				END IF 

				tab_1.idw_tabpage[1].object.customer_trouble_svccod[1]				  = ls_svccod
				tab_1.idw_tabpage[1].object.customer_trouble_priceplan[1]           = ls_priceplan				


				li_rc = tab_1.idw_tabpage[1].GetChild("troubletypea_troubletypeb", ldwc_troubletypeb)
				IF li_rc = -1 THEN
					f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
					RETURN -2
				END IF
		
				ls_filter = "SVCCOD = '" + ls_svccod + "' "
			
				ldwc_troubletypeb.SetFilter(ls_filter)			//Filter정함
				ldwc_troubletypeb.Filter()
				ldwc_troubletypeb.SetTransObject(SQLCA)
				ll_row = ldwc_troubletypeb.Retrieve() 
				
				IF ll_row < 0 THEN 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					RETURN -2
				END IF
				
			Case "customer_trouble_closeyn"

				 If data = "Y" then
						tab_1.idw_tabpage[1].object.customer_trouble_close_user[row] = gs_user_id
						tab_1.idw_tabpage[1].object.customer_trouble_closedt[row] = fdt_get_dbserver_now()
				 ElseIf data = "N" then
						setnull(ldt_date)				 					
						tab_1.idw_tabpage[1].object.customer_trouble_close_user[row] = ""
						tab_1.idw_tabpage[1].object.customer_trouble_closedt[row] = ldt_date
				 End if
			
			// 서비스선택에 따른 중분류 Filtering
			Case "customer_trouble_svccod"
				ls_troubletypec = fs_snvl(tab_1.idw_tabpage[1].object.troubletypeb_troubletypec[1], "")
				tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1] = ""
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1] = ""
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				
				ls_filter = "troubletypeb_svccod = '" + data + "' "
				ls_filter += " AND troubletypeb_troubletypec = '" + ls_troubletypec + "' "
			   idcB.SetFilter(ls_filter)			//Filter정함
				idcB.Filter()
				idcB.SetTransObject(SQLCA)
				ll_row =idcB.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				 
			//민원유형 중분류 Filtering
			Case "troubletypeb_troubletypec"
				ls_svccod = fs_snvl(tab_1.idw_tabpage[1].object.customer_trouble_svccod[1], "")
				tab_1.idw_tabpage[1].object.troubletypea_troubletypeb[1] = ""
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1] = ""
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				
				ls_filter = "troubletypeb_troubletypec = '" + data + "' "
				ls_filter += " AND troubletypeb_svccod = '" + ls_svccod + "' "
				
			   idcB.SetFilter(ls_filter)			//Filter정함
				idcB.Filter()
				idcB.SetTransObject(SQLCA)
				ll_row =idcB.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
			//민원유형 소분류 Filtering
			Case "troubletypea_troubletypeb"
				tab_1.idw_tabpage[1].object.troubletypemst_troubletypea[1] = ""
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				
				ls_filter = "troubletypea_troubletypeb = '" + data + "' "
			
				idcA.SetFilter(ls_filter)			//Filter정함
				idcA.Filter()
				idcA.SetTransObject(SQLCA)
				ll_row =idcA.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
			//민원유형
			Case "troubletypemst_troubletypea"
				tab_1.idw_tabpage[1].object.customer_trouble_troubletype[1] = ""
				ls_filter = "troubletypea = '" + data + "' "
			   idwc_troubletype.SetFilter(ls_filter)			//Filter정함
				idwc_troubletype.Filter()
				idwc_troubletype.SetTransObject(SQLCA)
				ll_row =idwc_troubletype.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
			
		   Case "customer_trouble_troubletype"
			
				//tab_1.idw_tabpage[1].GetChild("customer_trouble_troubletype", ldwc_troubletype)
				
				li_row= idwc_troubletype.GetRow()
     			ls_admodel_yn = idwc_troubletype.GetItemString(li_row,"troubletypemst_admodel_yn")
				
//			   If ls_admodel_yn = "Y" Then
//					tab_1.idw_tabpage[1].object.customer_trouble_modelno.Background.Color = RGB(108, 147, 137)
//					tab_1.idw_tabpage[1].object.customer_trouble_modelno.Color = Rgb(255,255,255)
//				Else
//					tab_1.idw_tabpage[1].object.customer_trouble_modelno.Background.Color = RGB(255, 255, 255)
//					tab_1.idw_tabpage[1].object.customer_trouble_modelno.Color = Rgb(0,0,0)
//				End If	
				
	End Choose

Case 2
	//필요한 컬럼은 수정되면 모두 바뀌게 한다. 
	//이것은 customer_trouble Update 되는 컬럼이다.
	If dwo.name = "close_yn" Then
		For i = 1 To tab_1.idw_tabpage[2].RowCount()
			tab_1.idw_tabpage[2].object.close_yn[i] = data
		Next
	ElseIf dwo.name = "partner" Then
		For i =1 To tab_1.idw_tabpage[2].RowCount()
			tab_1.idw_tabpage[2].object.partner[i] = data
		Next
	ElseIf dwo.name = "troubl_response_trouble_status" Then
		tab_1.idw_tabpage[2].object.status[1] = data
   End If	
	
End Choose

Return 0 
end event

event tab_1::ue_tabpage_retrieve;//Retrieve
String ls_where, ls_admodel_yn, ls_troubletype, ls_troubletypea, ls_troubletypeb, ls_troubletypec, ls_svccod
String ls_filter, ls_prefixno, ls_receipt_user, ls_EMP_GROUP, ls_close_yn, ls_sql, ls_customerid
Long ll_row, i, ll_row_dddw
Dec lc_troubleno
Int li_rc, li_rc2
DataWindowChild ldwc_partner, ldwc_contractseq
dw_master.Accepttext()
If al_master_row = 0 Then Return -1		//해당 고객 없음

//tab_1.idw_tabpage[ai_select_tabpage].accepttext()
idw_tabpage[ai_select_tabpage].Reset()
//trouble number
lc_troubleno 	= dw_master.object.troubleno[al_master_row]
ls_customerid	= dw_master.object.customerid[al_master_row]

SELECT closeyn, partner, trouble_status
INTO   :is_closeyn, :is_partner, :is_trouble_status
FROM   customer_trouble
WHERE  troubleno = :lc_troubleno ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(parent.Title,"Select Error(CUSTOMER_TROUBLE)")
	Return -2
End If
		
Choose Case ai_select_tabpage
	Case 1								//Tab 1
		tab_1.idw_tabpage[1].object.customer_trouble_contractseq.Protect    = 1
		tab_1.idw_tabpage[1].object.customer_trouble_svccod.Protect         = 1
		tab_1.idw_tabpage[1].object.customer_trouble_priceplan.Protect      = 1		
		tab_1.idw_tabpage[1].object.customer_trouble_troubletype.Protect    = 1
		tab_1.idw_tabpage[1].object.troubletypea_troubletypeb.Protect       = 1	
		
		
		ls_where = "to_char(customer_trouble.troubleno) = '" + String(lc_troubleno) + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		ls_receipt_user    =  tab_1.idw_tabpage[ai_select_tabpage].object.customer_trouble_receipt_user[1]
		
		SELECT EMP_GROUP
		  INTO :ls_EMP_GROUP
		  FROM sysusr1t
		 WHERE emp_id = :ls_receipt_user;
		 
		IF SQLCA.SQLCODE = 0 THEN
			tab_1.idw_tabpage[ai_select_tabpage].object.customer_trouble_receipt_partner[1] = ls_EMP_GROUP
			tab_1.idw_tabpage[ai_select_tabpage].SetItemStatus(1, "customer_trouble_receipt_partner" , Primary!, NotModified!)
		END IF
				
		ls_troubletypec =  tab_1.idw_tabpage[ai_select_tabpage].object.troubletypeb_troubletypec[1]
		ls_troubletypeb =  tab_1.idw_tabpage[ai_select_tabpage].object.troubletypea_troubletypeb[1]
		ls_troubletypea = tab_1.idw_tabpage[ai_select_tabpage].object.troubletypemst_troubletypea[1]
		ls_troubletype  = tab_1.idw_tabpage[ai_select_tabpage].object.customer_trouble_troubletype[1]
		ls_svccod       = tab_1.idw_tabpage[ai_select_tabpage].object.customer_trouble_svccod[1]
		
		//속도가 느려서 변경 처리. 2009.06.01
		li_rc2 = tab_1.idw_tabpage[1].GetChild("customer_trouble_contractseq", ldwc_contractseq)
		IF li_rc2 = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " select a.contractseq, b.svcdesc, a.customerid  from contractmst a, svcmst b " + &
					" where a.customerid = '" + ls_customerid + "' and a.svccod = b.svccod order by contractseq desc "
		ldwc_contractseq.SetSqlselect(ls_sql)
		ldwc_contractseq.SetTransObject(SQLCA)
		ll_row_dddw = ldwc_contractseq.Retrieve()

		IF ll_row_dddw < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "contractmst Retrieve()")
			RETURN -2
		END IF		
		//2009.06.01---------------------------------------------END
		
		// 2008-02-04 오류로 인해 급한대로 수정. hcjung 
		IF IsNull(ls_troubletypec) THEN ls_troubletypec = ''
		IF IsNull(ls_troubletypeb) THEN ls_troubletypeb = ''
		IF IsNull(ls_troubletypea) THEN ls_troubletypea = ''
		IF IsNull(ls_troubletype) THEN ls_troubletype = ''
		IF IsNull(ls_svccod) THEN ls_svccod = ''		
		
		//Filter
		ls_filter = "troubletypeb_troubletypec = '" + ls_troubletypec + "' "
		ls_filter += " AND troubletypeb_svccod = '" + ls_svccod + "' "
		idcB.SetFilter(ls_filter)			
		idcB.Filter()
		idcB.SetTransObject(SQLCA)
		ll_row =idcB.Retrieve() 
	
	   ls_filter = "troubletypea_troubletypeb = '" + ls_troubletypeb + "' "
		idcA.SetFilter(ls_filter)			
		idcA.Filter()
		idcA.SetTransObject(SQLCA)
		ll_row =idcA.Retrieve() 
		
		
	   ls_filter = "troubletypea = '" + ls_troubletypea + "' "
		idwc_troubletype.SetFilter(ls_filter)			//Filter정함
		idwc_troubletype.Filter()
		idwc_troubletype.SetTransObject(SQLCA)
		ll_row =idwc_troubletype.Retrieve() 
		
		SELECT PREFIXNO
		INTO	:ls_prefixno
		FROM	PARTNERMST
		WHERE	partner = :gs_user_group;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Parent.Title, "PREFIXNO")
			Return -2
		End IF
		
		li_rc = tab_1.idw_tabpage[ai_select_tabpage].GetChild("customer_trouble_partner", ldwc_partner)
		If li_rc = -1 Then
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			Return -2
		End If
		
		ls_filter = "prefixno LIKE '" + ls_prefixno + "%' "
		ldwc_partner.SetFilter(ls_Filter)
		ldwc_partner.Filter()
		ldwc_partner.SetTransObject(SQLCA)
		ll_row = ldwc_partner.Retrieve()
		
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "DDDW Retrieve()")
			Return -2
		End If
		
	Case 2								//Tab 2
		ls_where = "to_char(troubl_response.troubleno) = '" + String(lc_troubleno) + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If
		
		li_rc = wfi_set_codename("T", is_troubletype, is_troubletype_nm)
		If li_rc < 0 then return -2
		
		//값 Setting
		For i = 1 To tab_1.idw_tabpage[2].RowCount()
			//tab_1.idw_tabpage[2].object.close_yn[i] = is_closeyn  //처리완료
			tab_1.idw_tabpage[2].object.partner[i] = is_partner
			
			//상태 수정 인식 못하게
			//tab_1.idw_tabpage[2].SetItemStatus(i, "close_yn" , Primary!, NotModified!)
			tab_1.idw_tabpage[2].SetItemStatus(i, "status" , Primary!, NotModified!)  //마스터에 저장하기 위한 컬럼
			tab_1.idw_tabpage[2].SetItemStatus(i, "partner" , Primary!, NotModified!)
	  Next
		
		ls_close_yn = dw_master.object.closeyn[dw_master.GetSelectedRow(0)]
		
		//Messagebox('확인', is_closeyn)
		
		//처리 완료 되었으면 수정 불가능
		If is_closeyn = 'Y' Then
			idw_tabpage[2].object.troubl_response_seq.Protect = 1		
			idw_tabpage[2].object.troubl_response_responsedt.Protect = 1
			idw_tabpage[2].object.troubl_response_response_note.Protect = 1
			idw_tabpage[2].object.troubl_response_response_note2.Protect = 1
			idw_tabpage[2].object.troubl_response_trouble_status.Protect = 1
			//idw_tabpage[ai_select_tabpage].object.close_yn.Protect = 1
			idw_tabpage[2].object.partner.Protect = 1
			idw_tabpage[2].object.troubl_response_responsedt.Color = RGB(0,0,0)
			idw_tabpage[2].object.troubl_response_responsedt.BackGround.Color = RGB(255,251,240)
			idw_tabpage[2].object.troubl_response_response_note.Color = RGB(0,0,0)
			idw_tabpage[2].object.troubl_response_response_note.BackGround.Color = RGB(255,251,240)
			idw_tabpage[2].object.troubl_response_response_note2.Color = RGB(0,0,0)
			idw_tabpage[2].object.troubl_response_response_note2.BackGround.Color = RGB(255,251,240)
			idw_tabpage[2].object.troubl_response_trouble_status.Color = RGB(0,0,0)
			idw_tabpage[2].object.troubl_response_trouble_status.BackGround.Color = RGB(255,251,240)
			//idw_tabpage[ai_select_tabpage].object.close_yn.Color = RGB(0,0,0)
			//idw_tabpage[ai_select_tabpage].object.close_yn.BackGround.Color = RGB(255,251,240)
			idw_tabpage[2].object.partner.Color = RGB(0,0,0)
			idw_tabpage[2].object.partner.BackGround.Color = RGB(255,251,240)
		Else
			idw_tabpage[2].object.troubl_response_seq.Protect = 0					
			idw_tabpage[2].object.troubl_response_responsedt.Protect = 0
			idw_tabpage[2].object.troubl_response_response_note.Protect = 0
			idw_tabpage[2].object.troubl_response_response_note2.Protect = 0
			idw_tabpage[2].object.troubl_response_trouble_status.Protect = 0
			//idw_tabpage[ai_select_tabpage].object.close_yn.Protect = 0
			idw_tabpage[2].object.partner.Protect = 0
			idw_tabpage[2].object.troubl_response_responsedt.Color = RGB(255,255,255)
			idw_tabpage[2].object.troubl_response_responsedt.BackGround.Color = RGB(108,147,137)
			idw_tabpage[2].object.troubl_response_response_note.Color = RGB(0,0,0)
			idw_tabpage[2].object.troubl_response_response_note.BackGround.Color = RGB(255,255,255)
			idw_tabpage[2].object.troubl_response_response_note2.Color = RGB(0,0,0)
			idw_tabpage[2].object.troubl_response_response_note2.BackGround.Color = RGB(255,255,255)
			idw_tabpage[2].object.troubl_response_trouble_status.Color = RGB(255,255,255)
			idw_tabpage[2].object.troubl_response_trouble_status.BackGround.Color = RGB(108,147,137)
			//idw_tabpage[ai_select_tabpage].object.close_yn.Color = RGB(0,0,0)
			//idw_tabpage[ai_select_tabpage].object.close_yn.BackGround.Color = RGB(255,255,255)
			idw_tabpage[2].object.partner.Color = RGB(0,0,0)
			idw_tabpage[2].object.partner.BackGround.Color = RGB(255,255,255)
		End If
	Case 3								//Tab 3
		
		ls_where = "to_char(customer_trouble.troubleno) = '" + String(lc_troubleno) + "' "
		idw_tabpage[ai_select_tabpage].is_where = ls_where		
		ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
		If ll_row < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		End If

		If is_closeyn = 'Y' Then
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closedt.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closeyn.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_user.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_restype.Protect = 1
			idw_tabpage[ai_select_tabpage].object.close_partner.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_troubletype.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_troubletype.Protect = 1		
			idw_tabpage[ai_select_tabpage].object.customer_trouble_phone.Protect = 1
			idw_tabpage[ai_select_tabpage].object.close_note.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid_after.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid.Protect = 1
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid_after.Protect = 1

			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_troubletype.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_troubletype.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closedt.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closedt.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closeyn.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closeyn.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_user.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_user.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_restype.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_restype.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.close_partner.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.close_partner.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_phone.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_phone.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.close_note.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.close_note.BackGround.Color = RGB(255,251,240)
			
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid_after.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid_after.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid_after.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid_after.BackGround.Color = RGB(255,251,240)
		Else
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closedt.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closeyn.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_user.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_close_troubletype.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_restype.Protect = 0
			idw_tabpage[ai_select_tabpage].object.close_partner.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_phone.Protect = 0
			idw_tabpage[ai_select_tabpage].object.close_note.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid_after.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid.Protect = 0
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid_after.Protect = 0

			idw_tabpage[ai_select_tabpage].object.customer_trouble_closedt.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closedt.BackGround.Color = RGB(108,147,137)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closeyn.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_closeyn.BackGround.Color = RGB(108,147,137)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_restype.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_restype.BackGround.Color = RGB(108,147,137)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_phone.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_phone.BackGround.Color = RGB(108,147,137)

			idw_tabpage[ai_select_tabpage].object.close_note.BackGround.Color = RGB(108,147,137)
			idw_tabpage[ai_select_tabpage].object.close_note.Color = RGB(255,255,255)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid_after.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_inid_after.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid.BackGround.Color = RGB(255,251,240)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid_after.Color = RGB(0,0,0)
			idw_tabpage[ai_select_tabpage].object.customer_trouble_outid_after.BackGround.Color = RGB(255,251,240)
		End If
			
		ls_filter = "troubletypeb_troubletypeb = '" + idw_tabpage[ai_select_tabpage].object.troubletypea_troubletypeb[1] + "' "

		idwc_close_troubletype.SetFilter(ls_filter)			//Filter정함
		idwc_close_troubletype.Filter()
		idwc_close_troubletype.SetTransObject(SQLCA)
		ll_row = idwc_close_troubletype.Retrieve() 
			
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			RETURN -2
		END IF

End Choose

Return 0 
end event

event tab_1::selectionchanging;//신규 등록이면
tab_1.idw_tabpage[newindex].setredraw(false)
If ib_new = TRUE Then 
//	f_msg_usr_err(210, parent.Title, "처리내역이 존재하지 않으면 마감을 할수 없습니다.")
	Return 1
End If
tab_1.idw_tabpage[newindex].setredraw(true)


end event

event tab_1::selectionchanged;call super::selectionchanged;//Tab Page 선택 할때 버튼의 활성화 여부
Long ll_master_row, ll_cnt	//dw_master의 row 선택 여부
int li_i
dec lc_troubleno
String ls_closeyn
ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row < 0 Then Return 

Choose Case newindex
	Case 1
		p_insert.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
      IF is_closeyn = 'Y' THEN
		   p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
		ELSE
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
		END IF;
		
	Case 2
	   tab_1.idw_tabpage[newindex].modify("troubleno_t.text   = '"+ string(ic_troubleno)+ "'")  //접수번호
	   tab_1.idw_tabpage[newindex].modify("customerid_t.text  = '["+ is_customerid + "]'")      //고객번호
	   tab_1.idw_tabpage[newindex].modify("customernm_t.text  = '"+ is_customernm + "'")        //고객명
		tab_1.idw_tabpage[newindex].modify("troubletype_t.text = '"+ is_troubletype_nm + "'")    //민원유형
		
		For li_i = 1 To 5
			tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = ''")  //접수내역 전부 "" setting
		Next
		
		Choose Case UpperBound(is_trouble_note)
			Case 1 to 4
				
				For li_i = 1 To UpperBound(is_trouble_note)
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) + ".text = '" + is_trouble_note[li_i] + "'")  //접수내역
				Next
			
			Case Is >= 5
				For li_i = 1 To 4
					tab_1.idw_tabpage[2].modify("trouble_note_t_" + string(li_i) +".text = '"+ is_trouble_note[li_i] + "'")  //접수내역
				Next
				tab_1.idw_tabpage[2].modify("trouble_note_t_5.text = '"+ is_trouble_sum + "'")  //접수내역
				
		End Choose

		lc_troubleno = dw_master.object.troubleno[ll_master_row]  //처리완료이면 버튼 disable
		
		SELECT closeyn
		  INTO :is_closeyn
		  FROM customer_trouble
		 WHERE troubleno = :lc_troubleno ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.Title,"Select Error(CUSTOMER_TROUBLE)")
			Return -2
		End If
		
		If is_closeyn = 'Y' then
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		Else
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		End If
	Case 3	
		tab_1.idw_tabpage[3].SetFocus()
		lc_troubleno = dw_master.object.troubleno[ll_master_row]
		
//		SELECT count(*)
//		  INTO :ll_cnt
//		  FROM troubl_response
//		 WHERE troubleno = :lc_troubleno ;
		 
//		If ll_cnt < 1 Then
//			f_msg_usr_err(210, parent.Title, "처리내역이 존재하지 않으면 마감을 할수 없습니다.")
//			tab_1.SelectedTab = 2
//			Return
//		End If
		
		IF is_closeyn = 'Y' THEN
			p_insert.TriggerEvent("ue_disable")
			p_delete.TriggerEvent("ue_disable")
			p_save.TriggerEvent("ue_disable")
			p_reset.TriggerEvent("ue_enable")
		ELSE
			p_insert.TriggerEvent("ue_enable")
			p_delete.TriggerEvent("ue_enable")
			p_save.TriggerEvent("ue_enable")
			p_reset.TriggerEvent("ue_enable")
		END IF
		
		IF fs_snvl(is_closeyn,'N') = 'N' THEN
			tab_1.idw_tabpage[3].object.customer_trouble_close_user[1] = gs_user_id //처리자
			tab_1.idw_tabpage[3].object.customer_trouble_close_user.Protect = 1
//			tab_1.idw_tabpage[3].object.customer_trouble_closedt[1]    = Date(fdt_get_dbserver_now()) //date
			tab_1.idw_tabpage[3].object.customer_trouble_closedt[1]    = fdt_get_dbserver_now() //date			
			tab_1.idw_tabpage[3].object.close_partner[1]               = gs_user_group //조치자의 Parter
			tab_1.idw_tabpage[3].object.customer_trouble_closeyn[1]    = 'Y'    //처리완료
			//Log
//			tab_1.idw_tabpage[3].object.customer_trouble_crt_user[1]   = gs_user_id
//			tab_1.idw_tabpage[3].object.customer_trouble_crtdt[1]      = fdt_get_dbserver_now()
			tab_1.idw_tabpage[3].object.customer_trouble_pgm_id[1]     = gs_pgm_id[gi_open_win_no]
			tab_1.idw_tabpage[3].object.customer_trouble_updt_user[1]  = gs_user_id	
			tab_1.idw_tabpage[3].object.customer_trouble_updtdt[1]     = fdt_get_dbserver_now()
			
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_close_user" , Primary!, NotModified!)  //마스터에 저장하기 위한 컬럼
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_closedt" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "close_partner" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_closeyn" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_crt_user" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_crtdt" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_pgm_id" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_updt_user" , Primary!, NotModified!)
			tab_1.idw_tabpage[3].SetItemStatus(1, "customer_trouble_updtdt" , Primary!, NotModified!)
			
		End If
			
End Choose

Return 0 
end event

event tab_1::ue_tabpage_update;//****kenn : 1999-05-11 火 *****************************
// Return : -1 Save Error
//           0 Save
//           1 User Abort(Retrieve oldindex)
//           2 System Ignore
//******************************************************
Integer li_return

If oldindex <= 0 Then Return 2
If oldindex = 1 And newindex = 1 Then Return 2
ib_update = True
//If tab_1.ib_tabpage_check[oldindex] Then
	tab_1.idw_tabpage[oldindex].AcceptText()
	If (tab_1.idw_tabpage[oldindex].ModifiedCount() > 0) Or &
		(tab_1.idw_tabpage[oldindex].DeletedCount() > 0) Then
		tab_1.SelectedTab = oldindex
		li_return = MessageBox(Tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]" &
					, "Data is Modified.! Do you want to save?", Question!, YesNo!)
		If li_return <> 1 Then
			ib_update = False
			tab_1.idw_tabpage[oldindex].SetItemStatus(1, 0, Primary!, NotModified!)
			tab_1.idw_tabpage[oldindex].Reset()
			Return 1
		End If
	Else
		ib_update = False
		tab_1.idw_tabpage[oldindex].Reset()		
		Return 2
	End If

	li_return = Trigger Event ue_extra_save(oldindex)
	Choose Case li_return
		Case -2
			//필수항목 미입력
			//tab_1.SelectedTab = oldindex
			//tab_1.idw_tabpage[oldindex].SetFocus()
			ib_update = False
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
	
			f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
			ib_update = False
			Return -1
	End Choose

	If tab_1.idw_tabpage[oldindex].Update(True, False) < 0 Then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.is_title = tab_1.is_parent_title
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then
			ib_update = False
			Return -1
		End If

		f_msg_info(3010, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
		ib_update = False
		Return -1
	End If

	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = tab_1.is_parent_title
	iu_cust_db_app.uf_prc_db()
	If iu_cust_db_app.ii_rc = -1 Then
		ib_update = False
		Return -1
	End If

	tab_1.idw_tabpage[oldindex].ResetUpdate()
	f_msg_info(3000, tab_1.is_parent_title + "[" + is_tab_title[oldindex] + "]", "Save")
	ib_update = False
	//tab_1.SelectedTab = newindex
//End If

Return 0

end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_reg_customertrouble_resp_v20
integer y = 1420
end type

