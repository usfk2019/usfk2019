$PBExportHeader$b1w_reg_reserve_confirm_detail_popup_v20.srw
$PBExportComments$[ohj] 서비스 가입예약확정처리(고객정보수정popup) v20
forward
global type b1w_reg_reserve_confirm_detail_popup_v20 from w_base
end type
type st_1 from statictext within b1w_reg_reserve_confirm_detail_popup_v20
end type
type dw_detail from u_d_help within b1w_reg_reserve_confirm_detail_popup_v20
end type
type p_save from u_p_save within b1w_reg_reserve_confirm_detail_popup_v20
end type
type p_close from u_p_close within b1w_reg_reserve_confirm_detail_popup_v20
end type
type gb_1 from groupbox within b1w_reg_reserve_confirm_detail_popup_v20
end type
type ln_2 from line within b1w_reg_reserve_confirm_detail_popup_v20
end type
end forward

global type b1w_reg_reserve_confirm_detail_popup_v20 from w_base
integer width = 3319
integer height = 2032
windowstate windowstate = normal!
event ue_ok ( )
event ue_close ( )
event type integer ue_save ( )
event type integer ue_extra_save ( )
st_1 st_1
dw_detail dw_detail
p_save p_save
p_close p_close
gb_1 gb_1
ln_2 ln_2
end type
global b1w_reg_reserve_confirm_detail_popup_v20 b1w_reg_reserve_confirm_detail_popup_v20

type variables
String  is_credit, is_method, is_pay_method_ori, is_pgm_id
String  is_bank_ori, is_acctno_ori, is_acct_owner_ori, is_acct_ssno_ori, is_mode = 'I'
String  is_validkey_type, is_validkey_typenm, is_crt_kind, is_prefix, is_inv_method, &
        is_auth_method, is_type, is_used_level, is_crt_kind_code[], is_status[], &
		  is_reg_partner, is_priceplan, is_validitem_yn, is_validkey_type_h, &
		  is_crt_kind_h, is_prefix_h, is_auth_method_h, is_type_h, is_used_level_h
Long    il_length,il_length_h, il_seq, il_preseq

end variables

forward prototypes
public function integer wfi_dw_detail_setting ()
public function integer wf_validkey_setting ()
public function integer wf_init (string as_gubun)
end prototypes

event ue_ok();Long ll_row , li_exist, ll_result
String ls_where, ls_filter
DataWindowChild ldc_validkey_type
//조회

ll_row = dw_detail.Retrieve(il_preseq)
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If


end event

event ue_close;Close(This)
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
	Rollback;
	Return LI_ERROR
Else
	Commit;
	dw_detail.ResetUpdate ()
	f_msg_info(3000,This.Title,"Save")
End if

//ii_error_chk = 0
Return 0

end event

event type integer ue_extra_save();//Save Check
b1u_dbmgr1_v20 lu_check

Integer li_validkeytype_cnt, li_rc
String  ls_customerid, ls_bank_chg, ls_paymethod, ls_status
Boolean lb_check1

If dw_detail.RowCount() = 0 Then Return 0

ls_status = dw_detail.Object.status[1]

If is_status[1] <> ls_status Then 
	f_msg_info(9000, Title, "가입예약상태의 고객만 수정 가능합니다.")
	Return -1
End If

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
lu_check.ib_data[1] = False
lu_check.idw_data[1] = dw_detail

lu_check.uf_prc_db_03()
li_rc = lu_check.ii_rc

If li_rc = -1  Then
	Rollback;
	Destroy lu_check
	Return -1
End If

Destroy lu_check
		
Return 0
end event

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
//			dw_detail.Object.h323id.Protect   = 0
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
		dw_detail.Object.ssno.Color = RGB(255, 255, 255)	
		dw_detail.Object.ssno.Background.Color = RGB(108, 147, 137)
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
		dw_detail.Object.card_type.Color    = RGB(255, 255, 255)		
		dw_detail.Object.card_type.Background.Color    = RGB(108, 147, 137)
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
		dw_detail.Object.card_type.Protect    = 0
		dw_detail.Object.card_no.Protect      = 0
		dw_detail.Object.card_expdt.Protect   = 0
		dw_detail.Object.card_holder.Protect  = 0
		dw_detail.Object.card_ssno.Protect    = 0
		dw_detail.Object.card_remark1.Protect = 0
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
	//	dw_detail.Object.card_group1.Color  = RGB(0, 0, 0)		
	//	dw_detail.Object.card_group1.Background.Color  = RGB(255, 251, 240)
		dw_detail.Object.card_type.Protect    = 1
		dw_detail.Object.card_no.Protect      = 1
		dw_detail.Object.card_expdt.Protect   = 1
		dw_detail.Object.card_holder.Protect  = 1
		dw_detail.Object.card_ssno.Protect    = 1
		dw_detail.Object.card_remark1.Protect = 1
	//	dw_detail.Object.card_authyn.Protect  = 1
	//	dw_detail.Object.card_group1.Protect  = 1
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

on b1w_reg_reserve_confirm_detail_popup_v20.create
int iCurrent
call super::create
this.st_1=create st_1
this.dw_detail=create dw_detail
this.p_save=create p_save
this.p_close=create p_close
this.gb_1=create gb_1
this.ln_2=create ln_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_close
this.Control[iCurrent+5]=this.gb_1
this.Control[iCurrent+6]=this.ln_2
end on

on b1w_reg_reserve_confirm_detail_popup_v20.destroy
call super::destroy
destroy(this.st_1)
destroy(this.dw_detail)
destroy(this.p_save)
destroy(this.p_close)
destroy(this.gb_1)
destroy(this.ln_2)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Nmae	: b1w_reg_reserve_confirm_detail_popup_v20
	Desc	: 예약정보상세
	Ver	: 	2.0     
	Date	: 	2005.05.13
	Programer : oh hye jin
-------------------------------------------------------------------------*/
String ls_preseq
String ls_ref_desc, ls_temp

f_center_window(b1w_reg_reserve_confirm_detail_popup_v20)

iu_cust_msg = Message.PowerObjectParm
il_preseq = iu_cust_msg.il_data[1]
is_pgm_id = iu_cust_msg.is_data[1]

//카드정보
is_method = fs_get_control("B0", "P130", ls_ref_desc)
is_credit = fs_get_control("B0", "P131", ls_ref_desc)
is_inv_method = fs_get_control("B0", "P132", ls_ref_desc)  //E-mail 로 발송

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

dw_detail.SetRowFocusIndicator(off!)	

If il_preseq <> 0 Then
	Post Event ue_ok()
End If
end event

type st_1 from statictext within b1w_reg_reserve_confirm_detail_popup_v20
integer x = 50
integer y = 48
integer width = 800
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "서비스가입 예약정보"
alignment alignment = center!
boolean focusrectangle = false
end type

type dw_detail from u_d_help within b1w_reg_reserve_confirm_detail_popup_v20
integer x = 59
integer y = 152
integer width = 3150
integer height = 1604
integer taborder = 10
string dataobject = "b1dw_reg_svc_reserve_v20"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event ue_init();call super::ue_init;//help Window
This.is_help_win[1] = "b1w_hlp_logid_reserve_v20"
This.idwo_help_col[1] = This.Object.logid
This.is_data[1] = "CloseWithReturn"

This.is_help_win[2] = "w_hlp_post"
This.idwo_help_col[2] = This.Object.zipcod
This.is_data[1] = "CloseWithReturn"

This.is_help_win[3] = "b1w_hlp_validkeymst_v20"
This.idwo_help_col[3] = This.Object.validkey
This.is_data[1] = "CloseWithReturn"
end event

event retrieveend;call super::retrieveend;String ls_logid, ls_svccod, ls_filter, ls_priceplan
Long   ll_row
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

Return 0
end event

event constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event itemchanged;call super::itemchanged;//Item Changed
Boolean lb_check1, lb_check2
String ls_data , ls_ctype2, ls_filter, ls_svctype, ls_opendt
String  ls_payid, ls_customerid, ls_munitsec
Integer li_exist, li_exist1, li_rc, ll_row, ll_se
String ls_logid, ls_svccod, ls_priceplan
DataWindowChild ldc, ldc_priceplan

//Tab 1
ls_ctype2 = dw_detail.Object.ctype2[1]
b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check2)

dw_detail.Accepttext()

Choose Case dwo.name
	Case "svccod"			

		//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
		ll_row = dw_detail.GetChild("priceplan", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "svccod = '" + data + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve()

	Case "priceplan"

		//해당 priceplan에 대한 tmcod만 가져오게 - ALL포함
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

event doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부
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

type p_save from u_p_save within b1w_reg_reserve_confirm_detail_popup_v20
integer x = 2533
integer y = 1804
boolean originalsize = false
end type

type p_close from u_p_close within b1w_reg_reserve_confirm_detail_popup_v20
integer x = 2875
integer y = 1804
boolean originalsize = false
end type

type gb_1 from groupbox within b1w_reg_reserve_confirm_detail_popup_v20
integer x = 32
integer y = 96
integer width = 3205
integer height = 1680
integer taborder = 21
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

type ln_2 from line within b1w_reg_reserve_confirm_detail_popup_v20
boolean visible = false
long linecolor = 8421504
integer linethickness = 1
integer beginx = 818
integer beginy = 124
integer endx = 1582
integer endy = 124
end type

