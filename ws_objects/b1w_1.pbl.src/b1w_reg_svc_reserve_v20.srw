$PBExportHeader$b1w_reg_svc_reserve_v20.srw
$PBExportComments$[ohj] 서비스 가입예약 v20
forward
global type b1w_reg_svc_reserve_v20 from w_a_reg_m_m
end type
end forward

global type b1w_reg_svc_reserve_v20 from w_a_reg_m_m
integer width = 3406
integer height = 1976
end type
global b1w_reg_svc_reserve_v20 b1w_reg_svc_reserve_v20

type variables
Boolean ib_new
String  is_credit, is_method, is_pay_method_ori, is_card_prefix_yn//, is_inv_method
String  is_bank_ori, is_acctno_ori, is_acct_owner_ori, is_acct_ssno_ori, is_mode = 'I'
String  is_validkey_type, is_validkey_typenm, is_crt_kind, is_prefix, is_inv_method, &
        is_auth_method, is_type, is_used_level, is_crt_kind_code[], is_status[], &
		  is_reg_partner, is_priceplan, is_validitem_yn, is_validkey_type_h, &
		  is_crt_kind_h, is_prefix_h, is_auth_method_h, is_type_h, is_used_level_h
Long    il_length,il_length_h, il_seq


end variables

forward prototypes
public function integer wf_validkey_setting ()
public function integer wfi_dw_detail_setting ()
public function integer wf_init (string as_gubun)
end prototypes

public function integer wf_validkey_setting ();integer li_return
String  ls_customerid, ls_ref_desc

If is_validkey_type <> "" Then
	
	//validkey_type에 따른 info 가져오기
	li_return = b1fi_validkey_type_info_v20(this.title,is_validkey_type,is_validkey_typenm,is_crt_kind,is_prefix,il_length,is_auth_method,is_type,is_used_level) 

	If li_return = -1 Then
	    return -1
	End IF

//	is_reg_partner = dw_detail.Object.reg_partner[1]
	is_reg_partner = fs_get_control("A1", "C102", ls_ref_desc)
	ls_customerid  = dw_detail.Object.customerid[1]

	dw_detail.Object.validkey.Pointer    = "Arrow!"
	// 몰라 dw_detail.idwo_help_col[1] = dw_detail.Object.gu

	Choose Case is_crt_kind			
		Case is_crt_kind_code[1]         //수동Manual
			dw_detail.Object.validkey.protect = 0
			dw_detail.Object.validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)
			
		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
	
			dw_detail.Object.validkey.protect = 0
			dw_detail.Object.validkey.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.validkey.Color =  RGB(0, 0, 0)					
			
		Case is_crt_kind_code[4]         //자원관리Resource
			
			dw_detail.Object.validkey.Protect = 0
			dw_detail.Object.validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)
			
			dw_detail.Object.validkey.Pointer = "Help!"
			dw_detail.idwo_help_col[3] = dw_detail.Object.validkey
			dw_detail.is_help_win[3] = "b1w_hlp_validkeymst_v20"
			dw_detail.is_data[1] = "CloseWithReturn"
			dw_detail.is_data[2] = is_reg_partner       //유치처
			dw_detail.is_data[3] = is_priceplan         //가격정책

		Case is_crt_kind_code[5]         //고객대체
		
			dw_detail.Object.validkey.Protect   = 0
			dw_detail.Object.validkey.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.validkey.Color = RGB(255, 255, 255)	
			 
//			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
//			Else
				dw_detail.Object.validkey[1] = ls_customerid
//			End IF			
		
	End Choose

End IF

Return 0
end function

public function integer wfi_dw_detail_setting ();//integer li_return
//DataWindowChild ldc_validkey_type
//Long li_exist, ll_result
//String ls_filter
//
////인증KeyLocation 입력여부 
////ll_result = b1fi_validkey_loc_chk_yn_v20(this.Title, is_svccod, ii_cnt)
////IF ii_cnt > 0 Then
////	dw_detail.Object.new_validkey_loc.visible = True
////    dw_detail.Object.new_validkey_loc_t.visible = True
////Else
////	dw_detail.Object.new_validkey_loc.visible = False
////    dw_detail.Object.new_validkey_loc_t.visible = False
////End IF	
////
//////가격정책별 인증KEYTYPE
////li_exist = dw_detail.GetChild("new_validkey_type", ldc_validkey_type)		//DDDW 구함
////If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
////ls_filter = "a.priceplan = '" + is_priceplan + "'  " 
////ldc_validkey_type.SetTransObject(SQLCA)
////li_exist =ldc_validkey_type.Retrieve()
////ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
////ldc_validkey_type.Filter()
////
////If li_exist < 0 Then 				
////  f_msg_usr_err(2100, Title, "Retrieve()")
////  Return -1  		//선택 취소 focus는 그곳에
////End If
//
////해당 가격정책에 VALIDTIEM에 따른 info 가져오기
//li_return = b1fi_validitem_info_v20(this.title,is_priceplan,is_validitem_yn,is_validkey_type_h,is_crt_kind_h,is_prefix_h,il_length_h,is_auth_method_h,is_type_h, is_used_level_h) 
//
//If li_return = -1 Then
//    return -1
//End IF
//
//dw_detail.Object.h323id.Pointer = "Arrow!"
////dw_detail.idwo_help_col[2] = dw_detail.Object.gu
//	
//IF is_validitem_yn = 'Y' Then	
//	
//	Choose Case is_crt_kind_h		
//		Case is_crt_kind_code[1]                         //수동Manual
//			dw_detail.Object.h323id.protect = 0
//			dw_detail.Object.h323id.Pointer = "Arrow!"
//		//	dw_detail.idwo_help_col[2] = dw_detail.Object.gu
//			
//		Case is_crt_kind_code[2], is_crt_kind_code[3]    //AutoRandom,AutoSeq
//	
//			dw_detail.Object.h323id.protect = 1
//			dw_detail.Object.h323id.Background.Color = RGB(255, 251, 240)
//			dw_detail.Object.h323id.Color =  RGB(0, 0, 0)					
//			
//		Case is_crt_kind_code[4]                        //자원관리Resource
//			
//			dw_detail.Object.h323id.Protect   = 1
////			dw_detail.Object.validitem3.Background.Color = RGB(108, 147, 137)
////			dw_detail.Object.validitem3.Color = RGB(255, 255, 255)
//			
//			dw_detail.Object.h323id.Pointer   = "Help!"
//			dw_detail.idwo_help_col[2] = dw_detail.Object.h323id
//			dw_detail.is_help_win[2] = "b1w_hlp_validkeymst_v20"
//			dw_detail.is_data[1] = "CloseWithReturn"
//			dw_detail.is_data[2] = is_reg_partner         //유치처
//			dw_detail.is_data[3] = is_priceplan           //가격정책
//	
//		Case is_crt_kind_code[5]              //고객대체
//		
////			dw_detail.Object.h323id.Protect   = 0
////			dw_detail.Object.validitem3.Background.Color = RGB(108, 147, 137)
////			dw_detail.Object.validitem3.Color = RGB(255, 255, 255)	
//
//// 			IF is_first_gu = 'Y' and is_pgm_gu = "Doubleclicked" Then
////			Else
//				dw_detail.Object.h323id[1] = is_customerid
////			End IF			
//		
//	End Choose
//End IF
//
return  0
end function

public function integer wf_init (string as_gubun);String  ls_logid, ls_email_yn, ls_sms_yn
Boolean lb_check, lb_check1

//If dw_detail.RowCount() <= 0 Then Return 1

If as_gubun = '1' Or as_gubun = '3' Then 
	ls_logid = fs_snvl(dw_detail.object.logid[1], '')
	
	If ls_logid <> "" Then
		dw_detail.object.logid.Protect = 1
		dw_detail.Object.logid.Color = RGB(0, 0, 0)
		dw_detail.Object.logid.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.password.Color = RGB(255,255,255)		
		dw_detail.Object.password.Background.Color = RGB(108, 147, 137)
	
	Else
		dw_detail.object.logid.Protect = 0
		dw_detail.Object.logid.Color = RGB(0, 0, 0)
		dw_detail.Object.logid.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.password.Color = RGB(0,0,0)		
		dw_detail.Object.password.Background.Color = RGB(255,255,255)
	End If
	
	//개인 구분
	b1fb_check_control("B0", "P111", "", dw_detail.object.ctype2[1], lb_check)
	//법인구분
	b1fb_check_control("B0", "P110", "", dw_detail.object.ctype2[1], lb_check1)
	
	If lb_check Then		//개인이면 주민등록 번호 필수
		dw_detail.Object.ssno.Color = RGB(255, 255, 255)		
		dw_detail.Object.ssno.Background.Color = RGB(108, 147, 137)
	Else
		dw_detail.Object.ssno.Color = RGB(0, 0, 0)	
		dw_detail.Object.ssno.Background.Color = RGB(255, 255, 255)
	End If	
	
	If lb_check1 Then		//법인이면 사업장 정보 필수
	
		dw_detail.Object.corpnm.Color = RGB(255, 255, 255)			
		dw_detail.Object.corpnm.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.corpno.Color = RGB(255, 255, 255)			
		dw_detail.Object.corpno.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.cregno.Color = RGB(255, 255, 255)			
		dw_detail.Object.cregno.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.representative.Color = RGB(255, 255, 255)			
		dw_detail.Object.representative.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.businesstype.Color = RGB(255, 255, 255)			
		dw_detail.Object.businesstype.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.businessitem.Color =RGB(255, 255, 255)			
		dw_detail.Object.businessitem.Background.Color = RGB(108, 147, 137)
		
	Else
		
		dw_detail.Object.corpnm.Color = RGB(0, 0, 0)		
		dw_detail.Object.corpnm.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.corpno.Color = RGB(0, 0, 0)		
		dw_detail.Object.corpno.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.cregno.Color = RGB(0, 0, 0)		
		dw_detail.Object.cregno.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.representative.Color = RGB(0, 0, 0)		
		dw_detail.Object.representative.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.businesstype.Color = RGB(0, 0,0)		
		dw_detail.Object.businesstype.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.businessitem.Color = RGB(0, 0, 0)		
		dw_detail.Object.businessitem.Background.Color = RGB(255, 255, 255)
	End If	
	
	 ls_email_yn = dw_detail.Object.email_yn[1]
	If IsNull(ls_email_yn) Then ls_email_yn = ""
	If ls_email_yn = 'Y' Then
		dw_detail.Object.email1.Color = RGB(255, 255, 255)			
		dw_detail.Object.email1.Background.Color = RGB(108, 147, 137)
	Else
		dw_detail.Object.email1.Color = RGB(0, 0, 0)			
		dw_detail.Object.email1.Background.Color = RGB(255, 255, 255)
	End IF
	
	 ls_sms_yn = dw_detail.Object.sms_yn[1]
	If IsNull(ls_sms_yn) Then ls_sms_yn = ""
	If ls_sms_yn = 'Y' Then
		dw_detail.Object.smsphone.Color = RGB(255, 255, 255)			
		dw_detail.Object.smsphone.Background.Color = RGB(108, 147, 137)
	Else
		dw_detail.Object.smsphone.Color = RGB(0, 0, 0)			
		dw_detail.Object.smsphone.Background.Color = RGB(255, 255, 255)
	End IF
End IF

If as_gubun = '2' OR as_gubun = '3' Then

	dw_detail.Object.pay_method.Color = RGB(255, 255, 255)			
	dw_detail.Object.pay_method.Background.Color = RGB(108, 147, 137)
	dw_detail.Object.pay_method.Protect = 0
	
	//신용카드 결제	
	If is_credit = Trim(dw_detail.object.pay_method[1]) Then		
//		dw_detail.Object.card_type.Color    = RGB(255, 255, 255)		
//		dw_detail.Object.card_type.Background.Color    = RGB(108, 147, 137)
		dw_detail.Object.card_no.Color      = RGB(255, 255, 255)		
		dw_detail.Object.card_no.Background.Color      = RGB(108, 147, 137)
		dw_detail.Object.card_expdt.Color   = RGB(255, 255, 255)		
		dw_detail.Object.card_expdt.Background.Color   = RGB(108, 147, 137)
		dw_detail.Object.card_holder.Color  = RGB(255, 255, 255)		
		dw_detail.Object.card_holder.Background.Color  = RGB(108, 147, 137)
		dw_detail.Object.card_ssno.Color    = RGB(255, 255, 255)		
		dw_detail.Object.card_ssno.Background.Color    = RGB(108, 147, 137)
		dw_detail.Object.card_remark1.Color = RGB(255, 255, 255)	
		dw_detail.Object.card_remark1.Background.Color = RGB(108, 147, 137)	
//		dw_detail.Object.card_type.Protect    = 0
		dw_detail.Object.card_no.Protect      = 0
		dw_detail.Object.card_expdt.Protect   = 0
		dw_detail.Object.card_holder.Protect  = 0
		dw_detail.Object.card_ssno.Protect    = 0
		dw_detail.Object.card_remark1.Protect = 0
		
		//신용카드자동setting 이면 수정불가 
		If is_card_prefix_yn = 'Y' Then
			dw_detail.Object.card_type.Color =  RGB(0, 0, 0)		
			dw_detail.Object.card_type.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.card_type.Protect = 1
			
			dw_detail.Object.card_group1.Color = RGB(0, 0, 0)		
			dw_detail.Object.card_group1.Background.Color = RGB(255, 251, 240)
			dw_detail.Object.card_group1.Protect = 1
		Else
			dw_detail.Object.card_type.Color = RGB(255, 255, 255)	
			dw_detail.Object.card_type.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.card_type.Protect = 0
			dw_detail.Object.card_group1.Color = RGB(255, 255, 255)		
			dw_detail.Object.card_group1.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.card_group1.Protect = 0
		End If		
	Else 			//신용카드가 아닐경우
		dw_detail.Object.card_type.Color    = RGB(0, 0, 0)		
		dw_detail.Object.card_type.Background.Color   = RGB(255, 251, 240)
		dw_detail.Object.card_no.Color      = RGB(0, 0, 0)		
		dw_detail.Object.card_no.Background.Color     = RGB(255, 251, 240)
		dw_detail.Object.card_expdt.Color   = RGB(0, 0, 0)		
		dw_detail.Object.card_expdt.Background.Color  = RGB(255, 251, 240)
		dw_detail.Object.card_holder.Color  = RGB(0, 0, 0)		
		dw_detail.Object.card_holder.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.card_ssno.Color    = RGB(0, 0, 0)		
		dw_detail.Object.card_ssno.Background.Color   = RGB(255, 251, 240)
		dw_detail.Object.card_remark1.Color = RGB(0, 0, 0)		
		dw_detail.Object.card_remark1.Background.Color = RGB(255, 251, 240)
	//	dw_detail.Object.card_authyn.Color  = RGB(0, 0, 0)		
	//	dw_detail.Object.card_authyn.Background.Color  = RGB(255, 251, 240)
		dw_detail.Object.card_group1.Color  = RGB(0, 0, 0)		
		dw_detail.Object.card_group1.Background.Color  = RGB(255, 251, 240)
		dw_detail.Object.card_type.Protect    = 1
		dw_detail.Object.card_no.Protect      = 1
		dw_detail.Object.card_expdt.Protect   = 1
		dw_detail.Object.card_holder.Protect  = 1
		dw_detail.Object.card_ssno.Protect    = 1
		dw_detail.Object.card_remark1.Protect = 1
	//	dw_detail.Object.card_authyn.Protect  = 1
		dw_detail.Object.card_group1.Protect  = 1
	End If
	
	//자동이체일경우 
	If is_method = Trim(dw_detail.object.pay_method[1]) Then
		
		dw_detail.Object.bank.Color = RGB(255, 255, 255)		
		dw_detail.Object.bank.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.acctno.Color = RGB(255, 255, 255)		
		dw_detail.Object.acctno.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.acct_owner.Color = RGB(255, 255, 255)	
		dw_detail.Object.acct_owner.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.acct_ssno.Color = RGB(255, 255, 255)
		dw_detail.Object.acct_ssno.Background.Color = RGB(108, 147, 137)
		dw_detail.Object.bank.Protect       = 0
		dw_detail.Object.acctno.Protect     = 0
		dw_detail.Object.acct_owner.Protect = 0
		dw_detail.Object.acct_ssno.Protect  = 0
		
	Else   //자동이체가 아닐경우
		dw_detail.Object.bank.Color = RGB(0, 0, 0)		
		dw_detail.Object.bank.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.acctno.Color = RGB(0, 0, 0)		
		dw_detail.Object.acctno.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.acct_owner.Color = RGB(0, 0, 0)	
		dw_detail.Object.acct_owner.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.acct_ssno.Color = RGB(0, 0, 0)		
		dw_detail.Object.acct_ssno.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.bank.Protect =1
		dw_detail.Object.acctno.Protect = 1
		dw_detail.Object.acct_owner.Protect =1
		dw_detail.Object.acct_ssno.Protect =1
	End If
	
	////Email 청구이면
	//If is_inv_method = dw_detail.object.inv_method[1] Then			
	//	dw_detail.Object.bil_email.Color = RGB(255, 255, 255)		
	//	dw_detail.Object.bil_email.Background.Color = RGB(108, 147, 137)
	//Else
	//	dw_detail.Object.bil_email.Color = RGB(0, 0, 0)		
	//	dw_detail.Object.bil_email.Background.Color = RGB(255, 255, 255)
	//End If
End If

Return 0
end function

on b1w_reg_svc_reserve_v20.create
call super::create
end on

on b1w_reg_svc_reserve_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_yyyymmdd_fr, ls_yyyymmdd_to, ls_status, ls_svccod, ls_priceplan, &
       ls_customerid, ls_validkey, ls_new, ls_where
Long   ll_row

ls_new = Trim(dw_cond.object.new[1])

If ls_new = "Y" Then 
	ib_new = True
Else
	ib_new = False
End If

//신규 등록
If ib_new Then
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
   TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.
	Return
//조회
Else
	ls_yyyymmdd_fr = string(dw_cond.object.yyyymmdd_fr[1], 'yyyymmdd')
	ls_yyyymmdd_to = string(dw_cond.object.yyyymmdd_to[1], 'yyyymmdd')	
	ls_status      = fs_snvl(dw_cond.object.status[1]    , '')
	ls_svccod      = fs_snvl(dw_cond.object.svccod[1]    , '')
	ls_priceplan   = fs_snvl(dw_cond.object.priceplan[1] , '')
	ls_customerid  = fs_snvl(dw_cond.object.customerid[1], '')
	ls_validkey    = fs_snvl(dw_cond.object.validkey[1]  , '')
		
	ls_where = ""
	IF ls_yyyymmdd_fr <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(reservedt,'YYYYMMDD') >= '" + ls_yyyymmdd_fr + "'"
	END IF
	
	IF ls_yyyymmdd_to <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "to_char(reservedt,'YYYYMMDD') >= '" + ls_yyyymmdd_to + "'"
	END IF
	
	IF ls_status <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "status = '" + ls_status + "'"
	END IF
	
	IF ls_svccod <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "svccod = '" + ls_svccod + "'"
	END IF
	
	IF ls_priceplan <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "priceplan = '" + ls_priceplan + "'"
	END IF
	
	IF ls_customerid <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "customerid = '" + ls_customerid + "'"
	END IF

	IF ls_validkey <> "" THEN
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "validkey like '" + ls_validkey + "%'"
	END IF
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")			
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")			
		Return
	Else			
	
	End If
	dw_detail.object.customerid_t.visible  = True
	dw_detail.object.customerid.visible    = True
	dw_detail.object.contractseq_t.visible = True
	dw_detail.object.contractseq.visible   = True
	dw_detail.object.reservedt_t.visible   = True
	dw_detail.object.reservedt.visible     = True	
	dw_detail.object.status_t.visible      = True
	dw_detail.object.status.visible        = True	
	
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")   		
	dw_cond.Enabled = False	
	
	dw_detail.SetFocus()
	is_mode = 'I'
	
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
//Insert
If ib_new = True Then
	dw_detail.object.customerid_t.visible  = False
	dw_detail.object.customerid.visible    = False
	dw_detail.object.contractseq_t.visible = False
	dw_detail.object.contractseq.visible   = False
	dw_detail.object.reservedt_t.visible   = False
	dw_detail.object.reservedt.visible     = False	
	dw_detail.object.status_t.visible      = False
	dw_detail.object.status.visible        = False	

//	dw_detail.object.logid.Protect = 0
//	dw_detail.Object.logid.Color = RGB(0, 0, 255)
//	dw_detail.Object.logid.Background.Color = RGB(255, 255, 255)
	
	If wf_init('3') <> 0 Then 
		Return -1
	End If 		
	
	//preseq sequence 
	SELECT SEQ_PRESEQ.NEXTVAL
	  INTO :il_seq
	  FROM DUAL;
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Select Error(validinfo check AutoRandom)")
		Return -1
	End If
		
	//Setting
	dw_detail.object.preseq[al_insert_row]    = il_seq
	dw_detail.object.status[al_insert_row]    = is_status[1]  //가입000
	dw_detail.object.reservedt[al_insert_row] = fdt_get_dbserver_now()			
	dw_detail.object.crtdt[al_insert_row]     = fdt_get_dbserver_now()
	dw_detail.Object.crt_user[al_insert_row]	= gs_user_id
	dw_detail.Object.pgm_id[al_insert_row]		= gs_pgm_id[gi_open_win_no]
	
	//2005.11.17 kem Modify 추가
	dw_detail.Object.partner[al_insert_row]   = gs_user_group
	
	dw_detail.object.logid.Pointer = "help!"
	dw_detail.idwo_help_col[1] = dw_detail.object.logid
End  If

dw_detail.SetitemStatus(al_insert_row, 0, Primary!, NotModified!)

Return 0

end event

event open;call super::open;String ls_ref_desc, ls_temp
//카드정보
is_method = fs_get_control("B0", "P130", ls_ref_desc)
is_credit = fs_get_control("B0", "P131", ls_ref_desc)
is_inv_method = fs_get_control("B0", "P132", ls_ref_desc)  //E-mail 로 발송
//is_status = fs_get_control("B0", "P202", ls_ref_desc)    //등록상태

//인증Keytype생성KIND(수동Manual;AutoRandom;AutoSeq;자원관리Resource;고객대체)   M;AR;AS;R;C
ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P503", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_crt_kind_code[]) 


//가입자예약신청상태:가입예약;고객확정;계약확정  000;100;200
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "P270", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_status[]) 

//신용카드prefix 사용여부... y이면-> 카드번호 입력시 자동으로 카드사 setting, edit 불가
is_card_prefix_yn = fs_get_control("00", "Z930", ls_ref_desc)  

dw_detail.SetRowFocusIndicator(off!)
end event

event type integer ue_extra_save();call super::ue_extra_save;//Save Check
b1u_dbmgr1_v20 lu_check

Integer li_validkeytype_cnt, li_rc
String  ls_customerid, ls_bank_chg, ls_paymethod, ls_drawingtype, ls_enddt
Boolean lb_check1

If dw_detail.RowCount() = 0 Then Return 0

Select nvl(validkeycnt,0)
  Into :li_validkeytype_cnt
  From priceplanmst
where priceplan  = :is_priceplan;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT validkey_yn from priceplanmst")				
	Return -1
End If	

lu_check = Create b1u_dbmgr1_v20
lu_check.is_caller = "b1w_reg_svc_reserve_v20%ue_extra_save"
lu_check.is_title = Title
lu_check.is_data[1] = is_method
lu_check.is_data[2] = is_credit
lu_check.ii_data[1] = li_validkeytype_cnt
lu_check.il_data[1] = il_seq
lu_check.ib_data[1] = ib_new
lu_check.idw_data[1] = dw_detail

lu_check.uf_prc_db_03()
li_rc = lu_check.ii_rc

////필수 항목 오류
//If li_rc = -2 Then
//	Destroy lu_check
//	Return -2
//End If
//
////납입자 오류
//If li_rc = -3 Then
//	Destroy lu_check
//	Return -3
//End If

If li_rc = -1  Then
	Rollback;
	Destroy lu_check
	Return -1
End If

Destroy lu_check
		
Return 0
end event

event type integer ue_save();
Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	If is_mode = 'D' Then
		DELETE FROM PRE_VALIDINFO
		 WHERE PRESEQ = :il_seq;
		 
		If SQLCA.SQLCODE < 0 Then
			ROLLBACK;
			Return LI_ERROR
		End If
	End If
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	 
	dw_detail.ResetUpdate ()
	f_msg_info(3000,This.Title,"Save")
End if

If ib_new Then
	ib_new = False
	dw_cond.object.new[1] = 'N'
	TriggerEvent("ue_ok")	
Else
	If is_mode = 'D' Then
		TriggerEvent("ue_reset")
	End If	
End If

is_mode = 'I'
//ii_error_chk = 0
Return 0

end event

event type integer ue_reset();call super::ue_reset;dw_detail.object.customerid_t.visible  = True
dw_detail.object.customerid.visible    = True
dw_detail.object.contractseq_t.visible = True
dw_detail.object.contractseq.visible   = True
dw_detail.object.reservedt_t.visible   = True
dw_detail.object.reservedt.visible     = True	
dw_detail.object.status_t.visible      = True
dw_detail.object.status.visible        = True	

is_pay_method_ori = ''
is_bank_ori       = ''
is_acctno_ori     = ''
is_acct_owner_ori = ''
is_acct_ssno_ori  = ''	
is_priceplan      = ''
is_validkey_type  = ''
is_crt_kind       = ''
dw_detail.Object.validkey.Protect = 0
dw_detail.Object.validkey.Background.Color = RGB(255, 255, 255)
dw_detail.Object.validkey.Color = RGB(0, 0, 0)

dw_detail.Object.validkey.Pointer = "Arrow!"
is_mode = 'I'

Return 0
end event

event type integer ue_extra_delete();call super::ue_extra_delete;If dw_detail.Rowcount() <= 0 Then Return -1

String ls_status

ls_status = fs_snvl(dw_detail.object.status[1], '')

If is_status[1] <> ls_status Then
	f_msg_usr_err(200, Title, "가입예약상태만 삭제 가능합니다.")
	Return -1
End If
is_mode = 'D'
Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_reserve_v20
integer x = 55
integer y = 52
integer width = 2537
integer height = 312
string dataobject = "b1dw_cnd_svc_reserve_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist
Boolean lb_check
String ls_filter

Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			dw_cond.Object.customerid[row] = dw_cond.iu_cust_help.is_data[1]
			dw_cond.object.customernm[row] = dw_cond.iu_cust_help.is_data[2]
		End If

End Choose
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_reserve_v20
integer x = 2715
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_reserve_v20
integer x = 3022
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_reserve_v20
integer width = 2601
integer height = 388
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_reserve_v20
integer x = 32
integer y = 404
integer width = 3287
string dataobject = "b1dw_reg_cnd_svc_reserve_v20"
end type

event dw_master::retrieveend;call super::retrieveend;p_insert.TriggerEvent("ue_disable")
end event

event dw_master::clicked;call super::clicked;p_insert.TriggerEvent("ue_disable")
end event

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.preseq_t
uf_init(ldwo_SORT)
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_reserve_v20
integer x = 32
integer y = 856
integer width = 3287
string dataobject = "b1dw_reg_svc_reserve_v20"
boolean hsplitscroll = false
end type

event dw_detail::constructor;call super::constructor;//SetRowFocusIndicator(off!)

end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where
Long ll_row, ll_preseq

ll_preseq = dw_master.object.PRESEQ[al_select_row]

ll_row = dw_detail.Retrieve(ll_preseq)
dw_detail.SetRedraw(False)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

//ls_customerid = Trim(dw_master.object.customerm_customerid[al_master_row])
//ls_payid = Trim(dw_master.object.customerm_payid[al_master_row])

//
//logid의 데이터가 없을경우
String ls_logid, ls_svccod, ls_filter, ls_priceplan
DataWindowChild ldc, ldc_priceplan

ls_logid = fs_snvl(dw_detail.object.logid[1], '')

If ls_logid <> "" Then
	dw_detail.object.logid.Pointer = "Arrow!"
	dw_detail.idwo_help_col[1] = dw_detail.object.crt_user
Else
	dw_detail.object.logid.Pointer = "help!"
	dw_detail.idwo_help_col[1] = dw_detail.object.logid
End If

is_pay_method_ori = dw_detail.object.pay_method[1]
is_bank_ori       = dw_detail.object.bank[1]
is_acctno_ori     = dw_detail.object.acctno[1]
is_acct_owner_ori = dw_detail.object.acct_owner[1]
is_acct_ssno_ori  = dw_detail.object.acct_ssno[1]	
ls_svccod = fs_snvl(dw_detail.object.svccod[1], '')

//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
ll_row = dw_detail.GetChild("priceplan", ldc)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = "svccod = '" + ls_svccod + "' "
ldc.SetFilter(ls_filter)			//Filter정함
ldc.Filter()
ldc.SetTransObject(SQLCA)
ll_row =ldc.Retrieve()

ls_priceplan = fs_snvl(dw_detail.object.priceplan[1], '')
is_priceplan = ls_priceplan

//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
ll_row = dw_detail.GetChild("validkey_type", ldc_priceplan)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = "priceplan = '" + ls_priceplan + "' "
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()
ldc_priceplan.SetTransObject(SQLCA)
ll_row =ldc_priceplan.Retrieve()

This.object.zipcod.Pointer = "help!"

is_validkey_type = fs_snvl(dw_detail.object.validkey_type[1], '')
il_seq           = dw_detail.object.preseq[1]

dw_detail.SetRedraw(True)

If wf_validkey_setting() = -1 Then
	return -1
End IF

If wf_init('3') = 1 Then 
	Return -1
End If 

p_insert.TriggerEvent("ue_disable")

Return 0
end event

event dw_detail::doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부
String ls_logid = ""
String ls_svctype, ls_customerid
Integer li_exist

Choose Case dwo.name	
	Case "validkey" 
		IF is_crt_kind_code[4] <> is_crt_kind Then return
		If is_validkey_type = "" Then
			f_msg_usr_err(200, Title, "인증KeyType")
			dw_detail.SetRow(1)
			dw_detail.ScrollToRow(1)
			dw_detail.SetColumn("validkey_type")
			return -1 
		End If
		this.is_data[4] = is_validkey_type	     //validkey_type
		this.is_data[5] = is_used_level          //대리점의 인증Key사용권한
		
End Choose

Call u_d_help::doubleclicked

Choose Case dwo.name
	Case "logid"		//Log ID
		ls_logid = Trim(dw_detail.Object.logid[1])
		If IsNull(ls_logid) Then ls_logid = ""
		
		If ls_logid = ""  Then
			If dw_detail.iu_cust_help.ib_data[1] Then
				 dw_detail.Object.logid[1] = dw_detail.iu_cust_help.is_data[1]
			End If
			
			dw_detail.Object.password.Color = RGB(255,255,255)		
			dw_detail.Object.password.Background.Color = RGB(108, 147, 137)
		End If
		
	Case "zipcod"
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.zipcod[1] = dw_detail.iu_cust_help.is_data[1]
			dw_detail.Object.addr1[1]  = dw_detail.iu_cust_help.is_data[2]
			dw_detail.Object.addr2[1]  = dw_detail.iu_cust_help.is_data[3]			
		End If
		
	Case "validkey" 
	
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.validkey[1] = dw_detail.iu_cust_help.is_data[1]
		End If
		
	
End Choose


Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;//Item Changed
Boolean lb_check1, lb_check2
String ls_data , ls_ctype2, ls_filter, ls_svctype, ls_opendt, ls_card_type, ls_card_group
String  ls_payid, ls_customerid, ls_munitsec
Integer li_exist, li_exist1, li_rc, ll_row, ll_se
String ls_logid, ls_svccod, ls_priceplan, ls_currency_type, ls_partner
DataWindowChild ldc, ldc_priceplan

//Tab 1
ls_ctype2 = dw_detail.Object.ctype2[1]
b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check2)

dw_detail.Accepttext()

Choose Case dwo.name
	Case "svccod"			
/*
		//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
		ll_row = dw_detail.GetChild("priceplan", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "svccod = '" + data + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve()
*/
		//2005.11.17 kem Modify 고객의 화폐단위, 대리점에 따라 가격정책 찾아오는걸로 변경
		//고객의 납입자의 화폐단위 가져오기
		ls_currency_type = Trim(This.Object.currency_type[1])
		ls_partner       = Trim(This.Object.partner[1])
		If IsNull(ls_currency_type) Then
			f_msg_info(9000, title, "고객의 통화유형을 먼저 선택하세요!")
			Return -1
		End If
		If IsNull(ls_partner) Then
			f_msg_info(9000, title, "대리점을 먼저 선택하세요!")
			Return -1
		End If
		
		li_exist = This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		ls_filter = "svccod = '" + data  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' And " + &
		   	         "currency_type ='" + ls_currency_type + "' And partner = '" + ls_partner + "' " 

		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  
		
		//선택할수 있게
		This.object.priceplan.Protect = 0

	Case "priceplan"

		//해당 priceplan에 대한 인증Key Type만 가져오게
		ll_row = dw_detail.GetChild("validkey_type", ldc_priceplan)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "priceplan = '" + data + "' "
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		ldc_priceplan.SetTransObject(SQLCA)
		ll_row =ldc_priceplan.Retrieve()
		
		is_priceplan = data
		
	Case "validkey_type"
		is_validkey_type = data		

		dw_detail.Object.validkey[1] = ""
		
		//dw_detail validkey 셋팅값
		wf_validkey_setting()	
		
	Case "logid"
		If IsNull(data) Or data = "" Then
			dw_detail.Object.password.Color = RGB(0,0,0)		
			dw_detail.Object.password.Background.Color = RGB(255,255,255)
		Else //필수
			dw_detail.Object.password.Color = RGB(255,255,255)		
			dw_detail.Object.password.Background.Color = RGB(108, 147, 137)
		End If
	 
	//sms 수신여부
	Case "sms_yn"
	  If data = 'Y' Then 
		  dw_detail.Object.smsphone.Color = RGB(255,255,255)		
		  dw_detail.Object.smsphone.Background.Color = RGB(108, 147, 137)
		  Else
		  dw_detail.Object.smsphone.Color = RGB(0,0,0)				
		  dw_detail.Object.smsphone.Background.Color = RGB(255,255,255)
	  End If
	
	//email 수신여부
	Case "email_yn"
	  If data = 'Y' Then 
		  dw_detail.Object.email1.Color = RGB(255,255,255)		
		  dw_detail.Object.email1.Background.Color = RGB(108, 147, 137)
		  Else
		  dw_detail.Object.email1.Color = RGB(0,0,0)				
		  dw_detail.Object.email1.Background.Color = RGB(255,255,255)
	  End If
	 
	Case "ctype2"
		If lb_check1 Then		//개인이면 주민등록 번호 필수
			dw_detail.Object.ssno.Color = RGB(255,255,255)		
			dw_detail.Object.ssno.Background.Color = RGB(108, 147, 137)
		Else
			dw_detail.Object.ssno.Color = RGB(0, 0, 0)		
			dw_detail.Object.ssno.Background.Color = RGB(255, 255, 255)
		End If	
		
		If lb_check2 Then		//법인이면 사업장 정보 필수
			dw_detail.Object.corpnm.Color = RGB(255, 255, 255)			
			dw_detail.Object.corpnm.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.corpno.Color = RGB(255, 255, 255)			
			dw_detail.Object.corpno.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.cregno.Color = RGB(255, 255, 255)	
			dw_detail.Object.cregno.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.representative.Color = RGB(255, 255, 255)		
			dw_detail.Object.representative.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.businesstype.Color = RGB(255, 255, 255)	
			dw_detail.Object.businesstype.Background.Color = RGB(108, 147, 137)
			dw_detail.Object.businessitem.Color = RGB(255, 255, 255)
			dw_detail.Object.businessitem.Background.Color = RGB(108, 147, 137)
		Else
			dw_detail.Object.corpnm.Color = RGB(0, 0, 0)		
			dw_detail.Object.corpnm.Background.Color = RGB(255, 255, 255)
			dw_detail.Object.corpno.Color = RGB(0, 0, 0)		
			dw_detail.Object.corpno.Background.Color = RGB(255, 255, 255)
			dw_detail.Object.cregno.Color = RGB(0, 0, 0)		
			dw_detail.Object.cregno.Background.Color = RGB(255, 255, 255)
			dw_detail.Object.representative.Color = RGB(0, 0, 0)		
			dw_detail.Object.representative.Background.Color = RGB(255, 255, 255)
			dw_detail.Object.businesstype.Color = RGB(0, 0, 0)		
			dw_detail.Object.businesstype.Background.Color = RGB(255, 255, 255)
			dw_detail.Object.businessitem.Color = RGB(0, 0, 0)		
			dw_detail.Object.businessitem.Background.Color = RGB(255, 255, 255)
		End If
	Case "pay_method"
		Choose case is_pay_method_ori      //변경전 데이타
				case is_method    			  //자동이체
					//변경된데이타: 자동이체가 아닌경우
					//If Trim(data) <> is_pay_method_ori Then   
					//자동이체 -> 지로, 기타 -> 자동이체 일경우가 존재 할 수 있기 때문에...원래대로 setting
					//Else
					if Trim(data) = is_pay_method_ori Then      
							
						dw_detail.Object.bank[1]       = is_bank_ori
						dw_detail.Object.acctno[1]     = is_acctno_ori
						dw_detail.Object.acct_owner[1] = is_acct_owner_ori
						dw_detail.Object.acct_ssno[1]  = is_acct_ssno_ori
					End IF
				Case else    //변경전데이타가 자동이체가 아닌경우
					If Trim(data) = is_method Then      //변경한 데이타가 자동이체인 경우
						ls_ctype2 = Trim(dw_detail.Object.ctype2[1])
						b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
						b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check2)
						
						If lb_check1 Then //개인이면 주민등록 번호 필수
							dw_detail.object.acct_ssno[1] = dw_detail.Object.ssno[1]
						End If	
						If lb_check2 Then //법인이면 사업장 정보 필수					
							dw_detail.object.acct_ssno[1] = dw_detail.Object.cregno[1]
						End If
					End If
		End Choose
		
		If wf_init('2') <> 0 Then 
			Return -1
		End If 	
		
	Case "card_no"
		If is_card_prefix_yn = 'Y' Then
			SELECT CARD_TYPE
			  INTO :ls_card_type
			  FROM CARDPREFIX  
			 WHERE CARDPREFIX = (SELECT MAX(CARDPREFIX)
										  FROM CARDPREFIX  
										 WHERE :data LIKE CARDPREFIX ||'%' );
										 
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(Title, "SELECT ERROR CARDPREFIX")
				Return -1
			ElseIf sqlca.sqlcode = 100 Then
				f_msg_info(9000, title, "신용카드번호[" + data +"]의 prefix가 존재하지 않습니다.")	
				dw_detail.setcolumn("card_no")
				Return -1
			Else
				dw_detail.object.card_type[1] = ls_card_type
			End If							
		End If
		
	Case "card_remark1"
		If is_card_prefix_yn = 'Y' Then
			SELECT card_group 
			  INTO :ls_card_group
			  FROM CARDREMARK
			 WHERE CARD_REMARK = :data ;
			 
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(Title, "SELECT ERROR CARDREMARK")
				Return -1
			ElseIf sqlca.sqlcode = 100 Then
				f_msg_info(9000, title, "신용카드유형[" + data +"]가 존재하지 않습니다.")	
				dw_detail.setcolumn("card_remark1")
				Return -1
			Else
				dw_detail.object.card_group1[1] = ls_card_group
			End If
			 
		End If
//		
End Choose
//		
//	Case 3
//		Choose Case dwo.name
//			Case "svccod"
//				li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//				If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//			
//				ldc_priceplan.SetTransObject(SQLCA)
//				ldc_priceplan.Retrieve(data)
//				
//		End Choose
//	
//	Case 10
//		If (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!) = New!) Or (tab_1.idw_tabpage[10].GetItemStatus(row, 0, Primary!)) = NewModified!	Then
//			ls_munitsec = "0"
//		Else
//			ls_munitsec = String(tab_1.idw_tabpage[10].object.munitsec[row])
//			If IsNull(ls_munitsec) Then ls_munitsec = ""
//		End If
//		
//		Choose Case dwo.name
//			Case "zoncod"
//				If data <> "ALL" Then
//					tab_1.idw_tabpage[10].Object.areanum[row] = "ALL"
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 1
//				Else
//					tab_1.idw_tabpage[10].Object.areanum[row] = ""
//					tab_1.idw_tabpage[10].Object.areanum.Protect = 0
//				End If
//				
//			Case "enddt"
//				//적용종료일 체크
//				ls_opendt	= Trim(String(tab_1.idw_tabpage[10].Object.opendt[row],'yyyymmdd'))
//		
//				If data <> "" Then
//					If ls_opendt > data Then
//						f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
//						tab_1.idw_tabpage[10].setColumn("enddt")
//						tab_1.idw_tabpage[10].setRow(row)
//						tab_1.idw_tabpage[10].scrollToRow(row)
//						tab_1.idw_tabpage[10].setFocus()
//						Return -1
//					End If
//				End If
//				
//			Case "unitsec"
//			If ls_munitsec = '0' Or ls_munitsec = "" Then
//				If NOT(tab_1.idw_tabpage[10].Object.munitsec[row] > 0)  Then
//					tab_1.idw_tabpage[10].object.munitsec[row] = Long(data)
//				End If
//			End If
//			
//	
//End Choose
Return 0

end event

event dw_detail::ue_init();call super::ue_init;//SetRowFocusIndicator(off!)

//Integer li_exist
//DataWindowChild ldc_priceplan

//help Window
This.is_help_win[1] = "b1w_hlp_logid_reserve_v20"
This.idwo_help_col[1] = This.Object.logid
This.is_data[1] = "CloseWithReturn"

This.is_help_win[2] = "w_hlp_post"
This.idwo_help_col[2] = This.Object.zipcod
This.is_data[1] = "CloseWithReturn"

This.is_help_win[3] = "b1w_hlp_validkeymst_v20"
This.idwo_help_col[3] = This.Object.validkey
This.is_data[1] = "CloseWithReturn"

//dw_detail.is_data[2] = is_req_yn

//li_exist = tab_1.idw_tabpage[3].GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//
//ldc_priceplan.SetTransObject(SQLCA)
//ldc_priceplan.Retrieve("I")
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_reserve_v20
integer y = 1740
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_reserve_v20
integer y = 1744
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_reserve_v20
integer y = 1744
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_reserve_v20
integer y = 1744
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_reserve_v20
integer x = 32
integer y = 816
end type

