$PBExportHeader$b5w_reg_reqinfo_mdf_1.srw
$PBExportComments$[backgu-2002/09-26] 월별 고객 정보 History
forward
global type b5w_reg_reqinfo_mdf_1 from w_a_reg_m
end type
end forward

global type b5w_reg_reqinfo_mdf_1 from w_a_reg_m
integer width = 3429
integer height = 1912
end type
global b5w_reg_reqinfo_mdf_1 b5w_reg_reqinfo_mdf_1

type variables
String is_cur_gu, is_jiro, is_card, is_bank, is_inv_method
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_get_customerid (string as_customerid);String ls_customerid, ls_customernm

ls_customerid = as_customerid

If IsNull(ls_customerid) Then ls_customerid = " "

Select Customernm
  Into :ls_customernm
  From Customerm
 Where customerid = :ls_customerid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Customer ID(wfi_get_customerid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "고객번호가 없습니다.")
	Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0

end function

event ue_extra_save;call super::ue_extra_save;String ls_payid    , ls_ctype2    , ls_customernm  , ls_ssno
String ls_corpnm   , ls_corpno    , ls_businesstype, ls_businessitem, ls_representative
String ls_cregno
String ls_chargedt , ls_inv_yn    , ls_invdetail_yn, ls_inv_method  , ls_pay_method
String ls_bil_email, ls_bil_addr1 , ls_bil_addr2   , ls_bil_addrtype, ls_bil_zipcod
String ls_bank     , ls_acctno    , ls_acct_owner  , ls_acct_ssno   , ls_drawingreqdt
String ls_receiptdt, ls_resultcod , ls_receiptcod  , ls_drawingtype , ls_drawingresult
String ls_card_no  , ls_card_type , ls_creditreqdt , ls_card_remark1, ls_card_holder
String ls_card_ssno, ls_card_expdt, ls_card_group1 , ls_card_authyn, ls_inv_type
Long   ll_row
Boolean lb_check

ls_payid      = dw_detail.object.payid[1]
ls_customernm = dw_detail.object.customernm[1]
ls_ctype2     = dw_detail.object.ctype2[1]
ls_ssno       = dw_detail.object.ssno[1]

ls_corpnm         = dw_detail.object.corpnm[1]
ls_corpno         = dw_detail.object.corpno[1]
ls_representative = dw_detail.object.representative[1]
ls_cregno         = dw_detail.object.cregno[1]
ls_businesstype   = dw_detail.object.businesstype[1]
ls_businessitem   = dw_detail.object.businessitem[1]

ls_chargedt   = dw_detail.object.chargedt[1]
ls_inv_yn     = Trim(dw_detail.object.inv_yn[1])
ls_invdetail_yn = Trim(dw_detail.object.invdetail_yn[1])
ls_inv_method = Trim(dw_detail.object.inv_method[1])
ls_pay_method = Trim(dw_detail.object.pay_method[1])
ls_inv_type     = Trim(dw_detail.object.inv_type[1])

ls_bil_addrtype = Trim(dw_detail.object.bil_addrtype[1])
ls_bil_zipcod   = dw_detail.object.bil_zipcod[1]
ls_bil_addr1    = dw_detail.object.bil_addr1[1]
ls_bil_addr2    = dw_detail.object.bil_addr2[1]
ls_bil_email    = dw_detail.object.bil_email[1]

ls_bank          = Trim(dw_detail.object.bank[1])
ls_acctno        = dw_detail.object.acctno[1]
ls_acct_owner    = dw_detail.object.acct_owner[1]
ls_acct_ssno     = dw_detail.object.acct_ssno[1]
ls_drawingreqdt  = String(dw_detail.object.drawingreqdt[1], "yyyymmdd")
ls_drawingtype   = Trim(dw_detail.object.drawingtype[1])
ls_drawingresult = Trim(dw_detail.object.drawingresult[1])
ls_receiptcod    = Trim(dw_detail.object.receiptcod[1])
ls_receiptdt     = String(dw_detail.object.receiptdt[1], "yyyymmdd")
ls_resultcod     = Trim(dw_detail.object.resultcod[1])

ls_creditreqdt  = String(dw_detail.object.creditreqdt[1], "yyyymmdd")
ls_card_type    = Trim(dw_detail.object.card_type[1])
ls_card_remark1 = Trim(dw_detail.object.card_remark1[1])
ls_card_no      = dw_detail.object.card_no[1]
ls_card_expdt   = String(dw_detail.object.card_expdt[1], "yyyymmdd")
ls_card_group1  = dw_detail.object.card_group1[1]
ls_card_holder  = dw_detail.object.card_holder[1]
ls_card_ssno    = dw_detail.object.card_ssno[1]
ls_card_authyn  = Trim(dw_detail.object.card_authyn[1])

If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_customernm) Then ls_customernm = ""
If IsNull(ls_ctype2) Then ls_ctype2 = ""
If IsNull(ls_ssno) Then ls_ssno = ""

If IsNull(ls_corpnm) Then ls_corpnm = ""
If IsNull(ls_corpno) Then ls_corpno = ""
If IsNull(ls_representative) Then ls_representative = ""
If IsNull(ls_cregno) Then ls_cregno = ""
If IsNull(ls_businesstype) Then ls_businesstype = ""
If IsNull(ls_businessitem) Then ls_businessitem = ""

If IsNull(ls_chargedt) Then ls_chargedt = ""
If IsNull(ls_inv_yn) Then ls_inv_yn = ""
If IsNull(ls_invdetail_yn) Then ls_invdetail_yn = ""
If IsNull(ls_inv_method) Then ls_inv_method = ""
If IsNull(ls_pay_method) Then ls_pay_method = ""
If IsNull(ls_inv_type) Then ls_inv_type = ""

If IsNull(ls_bil_addrtype) Then ls_bil_addrtype = ""
If IsNull(ls_bil_zipcod) Then ls_bil_zipcod = ""
If IsNull(ls_bil_addr1) Then ls_bil_addr1 = ""
If IsNull(ls_bil_addr2) Then ls_bil_addr2 = ""
If IsNull(ls_bil_email) Then ls_bil_email = ""

If IsNull(ls_bank) Then ls_bank = ""
If IsNull(ls_acctno) Then ls_acctno = ""
If IsNull(ls_acct_owner) Then ls_acct_owner = ""
If IsNull(ls_acct_ssno) Then ls_acct_ssno = ""
If IsNull(ls_drawingreqdt) Then ls_drawingreqdt = ""
If IsNull(ls_drawingtype) Then ls_drawingtype = ""
If IsNull(ls_drawingresult) Then ls_drawingresult = ""
If IsNull(ls_receiptcod) Then ls_receiptcod = ""
If IsNull(ls_receiptdt) Then ls_receiptdt = ""
If IsNull(ls_resultcod) Then ls_resultcod = ""

If IsNull(ls_creditreqdt) Then ls_creditreqdt = ""
If IsNull(ls_card_type) Then ls_card_type = ""
If IsNull(ls_card_remark1) Then ls_card_remark1 = ""
If IsNull(ls_card_no) Then ls_card_no = ""
If IsNull(ls_card_expdt) Then ls_card_expdt = ""
If IsNull(ls_card_group1) Then ls_card_group1 = ""
If IsNull(ls_card_holder) Then ls_card_holder = ""
If IsNull(ls_card_ssno) Then ls_card_ssno = ""
If IsNull(ls_card_authyn) Then ls_card_authyn = ""

//If ls_payid = "" Then
//	f_msg_usr_err(200, Title, "Payer ID")
//	dw_detail.SetColumn("payid")
//	dw_detail.SetFocus()
//	Return -2
//End If
//
//If ls_customernm = "" Then
//	f_msg_usr_err(200, Title, "납입자명")
//	dw_detail.SetColumn("customernm")
//	dw_detail.SetFocus()
//	Return -2
//End If

//법인
b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check)
If lb_check Then
		If ls_corpnm = "" Then
			f_msg_usr_err(200, Title, "법인명")
			dw_detail.SetColumn("corpnm")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_corpno = "" Then
			f_msg_usr_err(200, Title, "법인등록번호")
			dw_detail.SetColumn("corpno")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_representative = "" Then
			f_msg_usr_err(200, Title, "대표자성명")
			dw_detail.SetColumn("representative")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_cregno = "" Then
			f_msg_usr_err(200, Title, "사업자등록번호")
			dw_detail.SetColumn("cregno")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_businesstype = "" Then
			f_msg_usr_err(200, Title, "업태")
			dw_detail.SetColumn("businesstype")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_businessitem = "" Then
			f_msg_usr_err(200, Title, "업종")
			dw_detail.SetColumn("businessitem")
			dw_detail.SetFocus()
			Return -2
		End If
End If

//If ls_chargedt = "" Then
//	f_msg_usr_err(200, Title, "Billing Cycle date")
//	dw_detail.SetColumn("chargedt")
//	dw_detail.SetFocus()
//	Return -2
//End If

If ls_inv_yn = "" Then
	f_msg_usr_err(200, Title, "청구서발송")
	dw_detail.SetColumn("inv_yn")
	dw_detail.SetFocus()
	Return -2
End If

If ls_invdetail_yn = "" Then
	f_msg_usr_err(200, Title, "청구내역전송")
	dw_detail.SetColumn("invdetail_yn")
	dw_detail.SetFocus()
	Return -2
End If

If ls_inv_method = "" Then
	f_msg_usr_err(200, Title, "청구발송방법")
	dw_detail.SetColumn("inv_method")
	dw_detail.SetFocus()
	Return -2
Else
	If ls_inv_method = is_inv_method Then
		If ls_bil_email = "" Then
			f_msg_usr_err(200, Title, "청구 Email")
			dw_detail.SetColumn("bil_email")
			dw_detail.SetFocus()
			Return -2
		End If
	End If
End If

If ls_inv_type = "" Then
	f_msg_usr_err(200, Title, "청구서유형")
	dw_detail.SetColumn("inv_type")
	dw_detail.SetFocus()
	Return -2
End If

If ls_pay_method = "" Then
	f_msg_usr_err(200, Title, "결제방법")
	dw_detail.SetColumn("pay_method")
	dw_detail.SetFocus()
	Return -2
Else
	If ls_pay_method = is_bank Then
		If ls_bank = "" Then
			f_msg_usr_err(200, Title, "은행")
			dw_detail.SetColumn("bank")
			dw_detail.SetFocus()
			Return -2
		End If
		
		If ls_acctno = "" Then
			f_msg_usr_err(200, Title, "계좌번호")
			dw_detail.SetColumn("acctno")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_acct_owner = "" Then
			f_msg_usr_err(200, Title, "예금주")
			dw_detail.SetColumn("acct_owner")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_acct_ssno = "" Then
			f_msg_usr_err(200, Title, "예금주주민번호")
			dw_detail.SetColumn("acct_ssno")
			dw_detail.SetFocus()
			Return -2
		End If

//		If ls_drawingreqdt = "" Then
//			f_msg_usr_err(200, Title, "이체신청일자")
//			dw_detail.SetColumn("drawingreqdt")
//			dw_detail.SetFocus()
//			Return -2
//		End If
//
//		If ls_drawingtype = "" Then
//			f_msg_usr_err(200, Title, "이체신청유형")
//			dw_detail.SetColumn("drawingtype")
//			dw_detail.SetFocus()
//			Return -2
//		End If
//
//		If ls_drawingresult = "" Then
//			f_msg_usr_err(200, Title, "이체신청결과")
//			dw_detail.SetColumn("drawingresult")
//			dw_detail.SetFocus()
//			Return -2
//		End If
//
//		If ls_receiptcod = "" Then
//			f_msg_usr_err(200, Title, "신청접수처")
//			dw_detail.SetColumn("receiptcod")
//			dw_detail.SetFocus()
//			Return -2
//		End If
//
//		If ls_receiptdt = "" Then
//			f_msg_usr_err(200, Title, "신청접수일자")
//			dw_detail.SetColumn("receiptdt")
//			dw_detail.SetFocus()
//			Return -2
//		End If
//
//		If ls_resultcod = "" Then
//			f_msg_usr_err(200, Title, "신청결과코드")
//			dw_detail.SetColumn("resultcod")
//			dw_detail.SetFocus()
//			Return -2
//		End If
	End If

	If ls_pay_method = is_card Then
//		If ls_creditreqdt = "" Then
//			f_msg_usr_err(200, Title, "카드결제신청일")
//			dw_detail.SetColumn("creditreqdt")
//			dw_detail.SetFocus()
//			Return -2
//		End If
		
		If ls_card_type = "" Then
			f_msg_usr_err(200, Title, "신용카드종류")
			dw_detail.SetColumn("card_type")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_card_remark1 = "" Then
			f_msg_usr_err(200, Title, "카드유형")
			dw_detail.SetColumn("card_remark1")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_card_no = "" Then
			f_msg_usr_err(200, Title, "신용카드번호")
			dw_detail.SetColumn("card_no")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_card_expdt = "" Then
			f_msg_usr_err(200, Title, "카드유효기간")
			dw_detail.SetColumn("card_expdt")
			dw_detail.SetFocus()
			Return -2
		End If

//		If ls_card_group1 = "" Then
//			f_msg_usr_err(200, Title, "카드그룹")
//			dw_detail.SetColumn("card_group1")
//			dw_detail.SetFocus()
//			Return -2
//		End If
//
		If ls_card_holder = "" Then
			f_msg_usr_err(200, Title, "카드회원명")
			dw_detail.SetColumn("card_holder")
			dw_detail.SetFocus()
			Return -2
		End If

		If ls_card_ssno = "" Then
			f_msg_usr_err(200, Title, "카드회원 주민번호")
			dw_detail.SetColumn("card_ssno")
			dw_detail.SetFocus()
			Return -2
		End If

//		If ls_card_authyn = "" Then
//			f_msg_usr_err(200, Title, "카드인증여부")
//			dw_detail.SetColumn("card_authyn")
//			dw_detail.SetFocus()
//			Return -2
//		End If
	End If
End If

If ls_bil_addrtype = "" Then
	f_msg_usr_err(200, Title, "주소구분")
	dw_detail.SetColumn("bil_addrtype")
	dw_detail.SetFocus()
	Return -2
End If

If ls_bil_zipcod = "" Then
	f_msg_usr_err(200, Title, "우편번호")
	dw_detail.SetColumn("bil_zipcod")
	dw_detail.SetFocus()
	Return -2
End If

If ls_bil_addr1 = "" Then
	f_msg_usr_err(200, Title, "주소")
	dw_detail.SetColumn("bil_addr1")
	dw_detail.SetFocus()
	Return -2
End If

If ls_bil_addr2 = "" Then
	f_msg_usr_err(200, Title, "주소")
	dw_detail.SetColumn("bil_addr2")
	dw_detail.SetFocus()
	Return -2
End If

Return 0

end event

event ue_ok();call super::ue_ok;//조회
String ls_customerid, ls_name, ls_trdt, ls_reqnum, ls_where
Long   ll_row  , ll_cnt
Boolean lb_check, lb_check1

dw_cond.accepTtext()
//신규 등록
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_trdt = String(dw_cond.object.trdt[1], "yyyymmdd")

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_trdt) Then ls_trdt = ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "납입번호")
	dw_cond.SetFocus()
	dw_cond.setColumn("customerid")
	Return 
End If

If ls_trdt = "" Then
	f_msg_info(200, Title, "청구기준일")
	dw_cond.SetFocus()
	dw_cond.setColumn("trdt")
	Return 
End If

ls_where = ""
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "payid = '" + ls_customerid + "' "
End If

If ls_trdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(trdt, 'yyyymmdd') = '" + ls_trdt + "' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(is_cur_gu,is_inv_method,is_jiro,is_bank,is_card)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
Else
	p_ok.TriggerEvent("ue_disable")
End If

If is_cur_gu = 'N' Then 
	p_save.TriggerEvent("ue_disable")
    dw_detail.object.bil_zipcod.Pointer = "Arrow!"
	dw_detail.idwo_help_col[1] = dw_detail.object.cur_gu
    dw_detail.object.holder_zipcod.Pointer = "Arrow!"
	dw_detail.idwo_help_col[2] = dw_detail.object.cur_gu
ElseIf is_cur_gu = 'Y' Then
	p_save.TriggerEvent("ue_enable")
	dw_detail.object.bil_zipcod.Pointer = "help.cur"
	dw_detail.idwo_help_col[1] = dw_detail.object.bil_zipcod
    dw_detail.object.holder_zipcod.Pointer = "help.cur"
	dw_detail.idwo_help_col[2] = dw_detail.object.holder_zipcod
End if


//법인구분
If is_cur_gu = 'Y' Then
	b1fb_check_control("B0", "P110", "", dw_detail.object.ctype2[1],lb_check)
	
	If lb_check Then		//법인이면 사업장 정보 필수
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
		//dw_detail.Object.corpnm.Color = RGB(0, 0, 255)		
		dw_detail.Object.corpnm.Background.Color = RGB(255, 255, 255)
		//dw_detail.Object.corpno.Color = RGB(0, 0, 255)		
		dw_detail.Object.corpno.Background.Color = RGB(255, 255, 255)
		//dw_detail.Object.cregno.Color = RGB(0, 0, 255)		
		dw_detail.Object.cregno.Background.Color = RGB(255, 255, 255)
		//dw_detail.Object.representative.Color = RGB(0, 0, 255)		
		dw_detail.Object.representative.Background.Color = RGB(255, 255, 255)
		//dw_detail.Object.businesstype.Color = RGB(0, 0, 255)		
		dw_detail.Object.businesstype.Background.Color = RGB(255, 255, 255)
		//dw_detail.Object.businessitem.Color = RGB(0, 0, 255)		
		dw_detail.Object.businessitem.Background.Color = RGB(255, 255, 255)
	End If	
Else
		dw_detail.Object.corpnm.Color = RGB(0, 0, 0)		
		dw_detail.Object.corpnm.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.corpno.Color = RGB(0, 0, 0)		
		dw_detail.Object.corpno.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.cregno.Color = RGB(0, 0, 0)		
		dw_detail.Object.cregno.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.representative.Color = RGB(0, 0, 0)		
		dw_detail.Object.representative.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.businesstype.Color = RGB(0, 0, 0)		

		dw_detail.Object.businesstype.Background.Color = RGB(255, 251, 240)
		dw_detail.Object.businessitem.Color = RGB(0, 0, 0)		
		dw_detail.Object.businessitem.Background.Color = RGB(255, 251, 240)
End if	



end event

on b5w_reg_reqinfo_mdf_1.create
call super::create
end on

on b5w_reg_reqinfo_mdf_1.destroy
call super::destroy
end on

event open;call super::open;String ls_ref_desc

is_jiro = fs_get_control("B0", "P129", ls_ref_desc)   //지로코드
is_bank = fs_get_control("B0", "P130", ls_ref_desc)   //자동이체코드
is_card = fs_get_control("B0", "P131", ls_ref_desc)	  //카드코드
is_inv_method = fs_get_control("B0", "P132", ls_ref_desc)  //E-mail 로 발송

end event

type dw_cond from w_a_reg_m`dw_cond within b5w_reg_reqinfo_mdf_1
integer x = 55
integer y = 44
integer width = 2112
integer height = 244
string dataobject = "b5dw_cnd_reg_customer"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b5w_hlp_paymst"
is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_trdt
Long li_exist
String ls_filter

Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			This.Object.customerid[1] = iu_cust_help.is_data2[1]
			This.Object.customernm[1] = iu_cust_help.is_data2[2]
			
			This.Modify("trdt.dddw.name='b5dc_dddw_reqinfo_trdt_arg'")
			This.Modify("trdt.dddw.DataColumn='trdt'")
			This.Modify("trdt.dddw.DisplayColumn='trdt'")
			
			li_exist = dw_cond.GetChild("trdt", ldc_trdt)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Billing Cycle Date")
//			ls_filter = "payid = '" + iu_cust_help.is_data2[1]  + "' " 
//			
//			ldc_trdt.SetFilter(ls_filter)			//Filter정함
//			ldc_trdt.Filter()
			
			ldc_trdt.SetTransObject(SQLCA)
			li_exist = ldc_trdt.Retrieve(iu_cust_help.is_data2[1])
			
			If li_exist < 0 Then 				
			  f_msg_usr_err(2100, Title, "Retrieve()")
			  Return 1  		//선택 취소 focus는 그곳에
			End If  
			
	
		End If	
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_trdt, ldc_chargedt
Long li_exist
String ls_filter, ls_customerid, ls_description, ls_reqdt
Int    li_rc

Choose Case Dwo.Name
	Case "customerid"
		
		This.Modify("trdt.dddw.name='b5dc_dddw_reqinfo_trdt_arg'")
		This.Modify("trdt.dddw.DataColumn='trdt'")
		This.Modify("trdt.dddw.DisplayColumn='trdt'")
		
		If IsNull(data) Then data = " "
		li_rc = wfi_get_customerid(data)

		If li_rc < 0 Then
			dw_cond.object.customerid[1] = ""
			dw_cond.object.customernm[1] = ""			
			dw_cond.SetColumn("customerid")
			return 2
		End IF		
				
		li_exist = dw_cond.GetChild("trdt", ldc_trdt)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Billing Cycle Date")
//		ls_filter = "payid = '" + data  + "' " 
//		
//		ldc_trdt.SetFilter(ls_filter)			//Filter정함
//		ldc_trdt.Filter()
		
		ldc_trdt.SetTransObject(SQLCA)
		li_exist =ldc_trdt.Retrieve(data)
		
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  

	Case "trdt"
		
		ls_customerid = This.Object.customerid[1]
		
		Select reqconf.description,
				 to_char(reqconf.reqdt,'yyyy-mm-dd')
		  into :ls_description,
		  		 :ls_reqdt
		  From reqconf, ( select payid, trdt, chargedt from reqinfo
		  						union all	select payid, trdt, chargedt from reqinfoh )	reqinfo
		 Where reqconf.chargedt = reqinfo.chargedt
		  And reqinfo.payid = :ls_customerid
		  And to_char(reqinfo.trdt,'yyyy-mm-dd') = :data;
		
		This.Object.chargedt[1] = ls_description
		
		If data = ls_reqdt Then
			 is_cur_gu = 'Y'
		Else
			 is_cur_gu = 'N'
		End if
		
End Choose
end event

type p_ok from w_a_reg_m`p_ok within b5w_reg_reqinfo_mdf_1
integer x = 2377
end type

type p_close from w_a_reg_m`p_close within b5w_reg_reqinfo_mdf_1
integer x = 2683
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b5w_reg_reqinfo_mdf_1
integer width = 2231
end type

type p_delete from w_a_reg_m`p_delete within b5w_reg_reqinfo_mdf_1
boolean visible = false
integer y = 1664
end type

type p_insert from w_a_reg_m`p_insert within b5w_reg_reqinfo_mdf_1
boolean visible = false
integer y = 1664
end type

type p_save from w_a_reg_m`p_save within b5w_reg_reqinfo_mdf_1
integer x = 69
integer y = 1664
end type

type dw_detail from w_a_reg_m`dw_detail within b5w_reg_reqinfo_mdf_1
integer y = 324
integer width = 3337
integer height = 1288
string dataobject = "b5d_reg_reqinfo_mdf_1"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init();call super::ue_init;idwo_help_col[1] = Object.bil_zipcod
is_help_win[1] = "w_hlp_post"
is_data[1] = "CloseWithReturn"

idwo_help_col[2] = Object.holder_zipcod
is_help_win[2] = "w_hlp_post"
is_data[2] = "CloseWithReturn"



end event

event dw_detail::doubleclicked;call super::doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부
String ls_logid = ""
 
Choose Case dwo.name
	Case "bil_zipcod"
		If is_cur_gu = 'Y' Then
			If iu_cust_help.ib_data[1] Then
				This.Object.bil_zipcod[row] = iu_cust_help.is_data[1]
				This.Object.bil_addr1[row] =  iu_cust_help.is_data[2]
				This.Object.bil_addr2[row] = iu_cust_help.is_data[3]
				
	//			This.Object.holder_zipcod[row] = iu_cust_help.is_data[1]
	//			This.Object.holder_addr1[row] = iu_cust_help.is_data[2]
	//			This.Object.holder_addr2[row] = iu_cust_help.is_data[3]
			End If
		End if
	Case "holder_zipcod"
		If is_cur_gu = 'Y' Then
			If iu_cust_help.ib_data[1] Then
				This.Object.holder_zipcod[row] = iu_cust_help.is_data[1]
				This.Object.holder_addr1[row] = iu_cust_help.is_data[2]
				This.Object.holder_addr2[row] = iu_cust_help.is_data[3]
			End If
		End if
End Choose

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;Boolean lb_check

Choose Case dwo.Name
	Case "ctype2"    		
		//법인구분
		b1fb_check_control("B0", "P110", "", data,lb_check)
		
		If lb_check Then		//법인이면 사업장 정보 필수
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
			dw_detail.Object.corpnm.Color = RGB(0, 0,0)		
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
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b5w_reg_reqinfo_mdf_1
integer x = 402
integer y = 1664
end type

