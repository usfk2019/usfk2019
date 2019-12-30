﻿$PBExportHeader$b1w_reg_svc_actorder_pre_2.srw
$PBExportComments$[kem]서비스개통신청-선불제(장비임대포함)
forward
global type b1w_reg_svc_actorder_pre_2 from w_a_reg_m_m3
end type
end forward

global type b1w_reg_svc_actorder_pre_2 from w_a_reg_m_m3
integer width = 3150
integer height = 2304
end type
global b1w_reg_svc_actorder_pre_2 b1w_reg_svc_actorder_pre_2

type variables
Long il_orderno, il_validkey_cnt
String is_act_gu, is_cus_status, is_validkey_yn, is_svctype, is_gkid
String is_SP_code, is_svccode, is_Xener_svccod[], is_xener_svc, is_langtype
Decimal idc_price //slaepricemodel 가격
String is_date_check  //개통일 Check 여부

Long   il_contractseq
String is_n_langtype, is_n_auth_method, is_n_validitem1, is_n_validitem2, is_n_validitem3

//가격정책별 인증Key Type
Integer ii_cnt
String  is_moveyn
end variables

forward prototypes
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
public subroutine of_resizepanels ()
public function integer wf_refill_ratefirst (string as_partner, string as_priceplan, string as_requestdt, decimal adc_price, ref decimal adc_rate_first)
end prototypes

public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check);//선불 고객인지 확인
String ls_ctype3
ab_check = False
	
	select ctype3 
	into :ls_ctype3
	from customerm
	where customerid = :as_customerid;
	
	//Error
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err("선불고객", "Select customerm Table")
		Return 0
	End If
	
	If ls_ctype3 = "0" Then
		ab_check = True
		
	
	Else
		ab_check = False
		
	End If
 
Return 0
end function

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
End If

Return 0
end function

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm
Select customernm,
	   status
Into :ls_customernm,
	 :is_cus_status
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm

Return 0

end function

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

Long		ll_Width, ll_Height, ll_long, ll_long_1, ll_long_2

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Middle) Or Not IsValid(idrg_Bottom) Then Return

ll_Width = WorkSpaceWidth()
ll_Height = WorkspaceHeight()

// Middle processing
idrg_Middle.Move(cii_WindowBorder, st_horizontal2.Y + cii_BarThickness)

If il_validkey_cnt > 0 Then
	idrg_Middle.Resize(idrg_Top.Width, st_horizontal.Y  - st_horizontal2.Y  )	
Else
//	idrg_Middle.Resize(idrg_Top.Width, ll_Height - (dw_cond.Height + cii_BarThickness * 3 ) - (ll_Height - p_insert.Y )	)
	idrg_Middle.Resize(idrg_Top.Width, p_insert.Y - st_horizontal2.Y - cii_BarThickness * 2)	
End If


end subroutine

public function integer wf_refill_ratefirst (string as_partner, string as_priceplan, string as_requestdt, decimal adc_price, ref decimal adc_rate_first);/*2003.07.26. parkkh
   [argument] 
	- as_partner 		string :유치partner
    - as_priceplan 		string :가격정책
	- as_opendt			string :
	- adc_price 		decimal: 상품가격
	- adc_rate_first 	decimal: rate_first   <= reference
	[return]
	   0	: 정상처리
	   1	: data notfound(select)
	  -1	: 비정상처리	*/


Select rate_first
 Into :adc_rate_first
 From refillpolicy
where partner = :as_partner  
 and priceplan = :as_priceplan 
 and to_char(fromdt, 'yyyymmdd') = ( select max(to_char(fromdt, 'yyyymmdd')) 
 	      			  			  	   from refillpolicy 
				      				  where to_char(fromdt, 'yyyymmdd') <= :as_requestdt
									    and partner = :as_partner  
									    and priceplan = :as_priceplan
										and fromamt <= :adc_price
										and nvl(toamt, :adc_price +1) > :adc_price )
 and fromamt <= :adc_price
 and nvl(toamt, :adc_price + 1) > :adc_price ;

If SQLCA.SQLCode < 0 Then
	Return -1
ElseIf SQLCA.SQLCode  = 100 Then
	Return  1
End If

Return 0
end function

on b1w_reg_svc_actorder_pre_2.create
call super::create
end on

on b1w_reg_svc_actorder_pre_2.destroy
call super::destroy
end on

event open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actorder_pre_2
	Desc	: 	서비스 신청
	Ver.	:	1.0
	Date	:   2004.05.21
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
call w_a_condition::open

string ls_ref_desc, ls_temp, ls_result[]

iu_cust_db_app = Create u_cust_db_app

//// Set the TopLeft, TopRight, and Bottom Controls
idrg_Top = dw_master
idrg_Middle = dw_detail2
idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
ii_WindowMiddle = idrg_Middle.Y
st_horizontal.BackColor = BackColor
st_horizontal2.BackColor = BackColor
il_HiddenColor = BackColor

dw_detail.Enabled = False
dw_detail.visible = False

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

//수정불가능
dw_cond.object.priceplan.Protect = 1
dw_cond.object.svccod.Protect = 1

//날짜 Setting
dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.maintain_partner[1] = gs_user_group
dw_cond.object.maintain_partnernm[1] = gs_user_group

ls_ref_desc = ""
//gkid default 값
is_gkid = fs_get_control("00", "G100", ls_ref_desc)
dw_cond.object.gkid[1] = is_gkid

//ls_ref_desc = ""
//ls_temp = fs_get_control("B1", "P200", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , ls_result[])
//is_SP_code = ls_result[2]          //Serial Phone svccode

//개통일 Check 여부
ls_ref_desc = ""
is_date_check = fs_get_control("B0", "P210", ls_ref_desc)


ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   //Xener GateKeeper 연동 svccode

il_orderno = 0

//ValidInfo LangType
is_langtype = fs_get_control("B1", "P204", ls_ref_desc)

dw_cond.object.langtype[1] = is_langtype

//Validkey 할당모듈 사용여부
is_moveyn = fs_get_control("B1", "P401", ls_ref_desc)

SetRedraw(True)
end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String ls_svccod, ls_priceplan, ls_customerid, ls_partner, ls_requestdt
String ls_where, ls_contract_no, ls_gkid, ls_auth_method, ls_sysdt
String ls_ip_address, ls_h323id, ls_bil_fromdt, ls_validkey_loc
String ls_reg_partner, ls_sale_partner, ls_pricemodel, ls_langtype
Long ll_row, ll_result

ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_requestdt = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_bil_fromdt = String(dw_cond.object.bil_fromdt[1],'yyyymmdd')
ls_partner = Trim(dw_cond.object.partner[1])
is_act_gu = Trim(dw_cond.object.act_gu[1])
ls_reg_partner = Trim(dw_cond.object.reg_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])
ls_pricemodel = Trim(dw_cond.object.pricemodel[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_requestdt) Then ls_requestdt = ""
If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(is_act_gu) Then is_act_gu = ""
If IsNull(ls_reg_partner) Then ls_reg_partner = ""
If IsNull(ls_sale_partner) Then ls_sale_partner = ""
If IsNull(ls_pricemodel) Then ls_pricemodel = ""

If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	ll_row = wfi_get_customerid(ls_customerid)		//올바른 고객인지 확인
	If ll_row = -1 Then Return
	 
End If

If ls_requestdt = "" Then
	f_msg_info(200, Title, "개통요청일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("requestdt")
	Return
End If

If is_date_check = 'Y' Then
	If ls_requestdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "개통요청일은 오늘날짜 이상이여야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("requestdt")
		Return
	End If		
End If

If ls_partner = "" Then
	f_msg_info(200, Title, "수행처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

If ls_svccod = "" Then
	f_msg_info(200, Title, "신청서비스")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	Return
End If

If ls_priceplan = "" Then
	f_msg_info(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
	Return
End If

If ls_reg_partner = "" Then
	f_msg_info(200, Title, "유치처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reg_partner")
	Return
End If

If ls_pricemodel = "" Then
	f_msg_info(200, Title, "상품모델")
	dw_cond.SetFocus()
	dw_cond.SetColumn("pricemodel")
	Return
End If

If ls_sale_partner = "" Then
	f_msg_info(200, Title, "매출처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("sale_partner")
	Return
End If

If is_act_gu = "" Then
	f_msg_info(200, Title, "개통처리")
	dw_cond.SetFocus()
	dw_cond.SetColumn("act_gu")
	Return
End IF

If is_act_gu = "Y" Then
	If ls_bil_fromdt = "" Then
		f_msg_info(200, Title, "과금시작일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If
	
	If ls_bil_fromdt < ls_requestdt Then
		f_msg_usr_err(210, Title, "과금시작일은 개통일이상이여야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("bil_fromdt")
		Return
	End If		

End IF

is_n_langtype  = Trim(dw_cond.object.langtype[1])
is_n_auth_method = Trim(dw_cond.object.auth_method[1])
is_n_validitem3 = Trim(dw_cond.object.h323id[1])
is_n_validitem2 = Trim(dw_cond.object.ip_address[1])
is_n_validitem1 = Trim(dw_cond.object.validitem1[1])
If IsNull(is_n_langtype) Then is_n_langtype = ""
If IsNull(is_n_auth_method) Then is_n_auth_method = ""
If IsNull(is_n_validitem1) Then is_n_validitem1 = ""
If IsNull(is_n_validitem2) Then is_n_validitem2 = ""
If IsNull(is_n_validitem3) Then is_n_validitem3 = ""

//If il_validkey_cnt > 0 Then
//
//	ls_gkid = Trim(dw_cond.object.gkid[1])
//	ls_validkey_loc = Trim(dw_cond.object.validkey_loc[1])
//	ls_auth_method = Trim(dw_cond.object.auth_method[1])
//	ls_h323id = Trim(dw_cond.object.h323id[1])
//	ls_ip_address = Trim(dw_cond.object.ip_address[1])
//	ls_langtype  = Trim(dw_cond.object.langtype[1])
//
//	If IsNull(ls_gkid) Then ls_gkid = ""
//	If IsNull(ls_validkey_loc) Then ls_validkey_loc = ""	
//	If IsNull(ls_auth_method) Then ls_auth_method = ""
//	If IsNull(ls_h323id) Then ls_h323id = ""
//	If IsNull(ls_ip_address) Then ls_ip_address = ""
//	If IsNull(ls_langtype) Then ls_langtype = ""	
//	
//	If ls_gkid = "" Then
//		f_msg_info(200, Title, "GKID")		
//		dw_cond.SetFocus()
//		dw_cond.SetColumn("gkid")
//		Return 
//	End If		
//
//	If ls_langtype = "" Then
//		f_msg_info(200, Title, "멘트언어")		
//		dw_cond.SetFocus()
//		dw_cond.SetColumn("langtype")
//		Return 
//	End If
//
////	If ls_validkey_loc = "" Then
////		f_msg_info(200, Title, "인증Key Location")		
////		dw_cond.SetFocus()
////		dw_cond.SetColumn("validkey_loc")
////		Return 
////	End If		
//	
//	If is_xener_svc = 'Y' Then
//		
//		If ls_auth_method = "" Then
//			f_msg_info(200, Title, "인증방법")
//			dw_cond.SetFocus()
//			dw_cond.SetColumn("auth_method")
//			Return 
//		End If		
//		
//		If left(ls_auth_method,1) = 'S' Then
//			ls_ip_address = dw_cond.object.ip_address[1]
//			If IsNull(ls_ip_address) Then ls_ip_address = ""				
//			If ls_ip_address = "" Then
//				f_msg_info(200, Title, "IP ADDRESS")
//				dw_cond.SetFocus()
//				dw_cond.SetColumn("ip_address")
//				Return
//			End If		
//		End if
//		
//		If mid(ls_auth_method,7,1) <> 'E' Then
//			ls_h323id = dw_cond.object.h323id[1]
//			If IsNull(ls_h323id) Then ls_h323id = ""							
//			If ls_h323id = "" Then
//				f_msg_info(200, Title, "H323ID")
//				dw_cond.SetFocus()
//				dw_cond.SetColumn("h323id")
//				Return 
//			End If		
//		End if	
//	End if
//
//End If

ls_where = ""
ls_where += "det.priceplan ='" + ls_priceplan + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

SetRedraw(False)

If ll_row > 0 Then
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail2.SetFocus()
	
	dw_detail2.Enabled = True
	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
End If

If il_validkey_cnt > 0 Then
	dw_detail.ib_insert = True
	dw_detail.ib_delete = True	
	dw_detail.Enabled = True
	dw_detail.visible = True	
	dw_detail.setfocus()
	
	//인증Key 관리 수정 - 2004.06.02
	ll_result = b1fi_validkeytype_check('서비스개통신청', ls_priceplan, ii_cnt)
	
	If ll_result < 0 Then
		f_msg_info(9000, Title , "가격정책별 인증Key Type을 찾을 수가 없습니다.")
		Return
	End If
	
	If ii_cnt > 0 Then
		dw_detail.Object.validkey.protect = 1
	Else
		dw_detail.Object.validkey.protect = 0
	End If
	
Else 
	dw_detail.ib_insert = False
	dw_detail.ib_delete = False
	dw_detail.Enabled = False
	dw_detail.visible = False
End If

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event ue_reset();call super::ue_reset;dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
dw_cond.object.gkid[1] = is_gkid
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.sale_partnernm[1] = gs_user_group
dw_cond.object.langtype[1] = is_langtype
dw_cond.object.maintain_partner[1] = gs_user_group
dw_cond.object.maintain_partnernm[1] = gs_user_group


is_validkey_yn= 'N'
is_xener_svc = 'N'
il_validkey_cnt = 0 

SetRedraw(False)

dw_detail.Enabled = False
dw_detail.visible = False

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
end event

event type integer ue_save();String ls_quota_yn, ls_chk
Long i, ll_row, j, k
Int li_rc
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

This.Trigger Event ue_extra_save(li_rc)
If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"개통신청(처리)")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"개통신청(처리)")
ElseIF li_rc = -2 Then
	dw_detail.SetFocus()	
	Return LI_ERROR
ElseIF li_rc = -3 Then
	dw_detail.SetFocus()	
	Return LI_ERROR
End if

//저장한거로 인식하게 함.
For i = 1 To dw_detail.RowCount()
	dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)
Next  

For i = 1 To dw_detail2.RowCount()
	dw_detail2.SetitemStatus(i, 0, Primary!, NotModified!)
Next  

p_save.TriggerEvent("ue_disable")		//버튼 비활성화
p_insert.TriggerEvent("ue_disable")		//버튼 비활성화
p_delete.TriggerEvent("ue_disable")		//버튼 비활성화
dw_detail.ib_insert = False
dw_detail.ib_delete = False

dw_detail2.enabled = False
dw_detail.enabled = False

String ls_customerid
Boolean lb_quota
iu_cust_msg = Create u_cust_a_msg
j = 1
//할부 품목을 신청했으면
ll_row = dw_detail2.RowCount()
If ll_row = 0 Then Return 0
For i = 1 To ll_row
	ls_chk = Trim(dw_detail2.object.chk[i])
	If ls_chk = "Y" Then
		ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
		If ls_quota_yn = "Y" Then
			iu_cust_msg.is_data[j] = Trim(dw_detail2.object.itemcod[i])
			j++
		End If
	End If
Next

For i = 1 To ll_row
	ls_chk = Trim(dw_detail2.object.chk[i])
	If ls_chk = "Y" Then
		ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
		If ls_quota_yn = "Y" Then
			lb_quota = TRUE
			Exit
		Else
			lb_quota = FALSE
		End If
	End If
Next
	
If lb_quota Then			//할부 Check한게 있으면
	ls_customerid = Trim(dw_cond.object.customerid[1])
	
	iu_cust_msg.is_pgm_name = "서비스품목 할부 등록"
	iu_cust_msg.is_grp_name = "서비스 신청"
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.il_data[1]  = il_orderno						//order number
	iu_cust_msg.il_data[2]  = il_contractseq					//contractseq
	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	iu_cust_msg.is_data2[4] = is_act_gu                   //개통처리 여부
	 
   OpenWithParm(b1w_reg_quotainfo_pop_2, iu_cust_msg)
	
End If

Boolean lb_rental
iu_cust_msg = Create u_cust_a_msg
k = 1
//임대 품목을 신청했으면
ll_row = dw_detail2.RowCount()
If ll_row = 0 Then Return 0
For i = 1 To ll_row
	ls_chk = Trim(dw_detail2.object.chk[i])
	If ls_chk = "Y" Then
		ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
		If ls_quota_yn = "R" Then
			iu_cust_msg.is_data[k] = Trim(dw_detail2.object.itemcod[i])
			k++
		End If
	End If
Next

For i = 1 To ll_row
	ls_chk = Trim(dw_detail2.object.chk[i])
	If ls_chk = "Y" Then
		ls_quota_yn = Trim(dw_detail2.object.quota_yn[i])
		If ls_quota_yn = "R" Then
			lb_rental = TRUE
			Exit
		Else
			lb_rental = FALSE
		End If
	End If
Next
	
If lb_rental Then			//임대 Check한게 있으면
	ls_customerid = Trim(dw_cond.object.customerid[1])
	
	iu_cust_msg.is_pgm_name = "서비스품목 장비임대 등록"
	iu_cust_msg.is_grp_name = "서비스 신청"
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.il_data[1]  = il_orderno						//order number
	iu_cust_msg.il_data[2]  = il_contractseq					//contractseq
	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	iu_cust_msg.is_data2[4] = is_act_gu                   //개통처리 여부
	 
   OpenWithParm(b1w_reg_rental_pop, iu_cust_msg)
	
End If

Return 0
end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;Long ll_row
Integer li_rc
b1u_dbmgr9 	lu_dbmgr

ll_row  = dw_detail2.RowCount()
If ll_row = 0 Then 
	ai_return = 0
	Return
End if

If il_validkey_cnt > 0 Then
	ll_row  = dw_detail.RowCount()
	If ll_row = 0 Then 
		f_msg_usr_err(9000, Title, "사용할 인증KEY를 입력하셔야 합니다.")		
		ai_return = -2
		Return
	End if
End if

//저장
lu_dbmgr = Create b1u_dbmgr9
lu_dbmgr.is_caller = "b1w_reg_svc_actorder_pre_2%save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_cond
lu_dbmgr.idw_data[2] = dw_detail2                //품목
lu_dbmgr.idw_data[3] = dw_detail			     //인증KEY
lu_dbmgr.is_data[1] = gs_user_id
lu_dbmgr.is_data[2] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.is_data[3] = is_act_gu                  //개통처리 check
lu_dbmgr.is_data[4] = is_cus_status              //고객상태
lu_dbmgr.is_data[5] = is_svctype                 //svctype
lu_dbmgr.is_data[6] = string(il_validkey_cnt)    //인증KEY갯수
lu_dbmgr.is_data[7] = is_xener_svc     			 //Xener svc 여부
lu_dbmgr.ii_data[1]  = ii_cnt                    //가격정책별 인증Key 사용:1, 미사용:0

lu_dbmgr.uf_prc_db_03()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	ai_return = -1
	Return
End If

If li_rc = -2 Then
	f_msg_usr_err(9000, Title, "이미 신청 상태 입니다. ~r더이상 같은 서비스를 신청 할 수 없습니다.")
	ai_return = -2	
	Return
End If

il_orderno = lu_dbmgr.il_data[1]

Destroy lu_dbmgr

ai_return = li_rc

Return
end event

event ue_insert();//override
Long ll_row, ll_cnt
Int li_return
String ls_reg_partner, ls_priceplan

ll_cnt = dw_detail.RowCount()
If ll_cnt >= il_validkey_cnt Then
	f_msg_usr_err(9000,title,"해당가격정책에 인증KEY 등록은 ~r~n~r~n" +string(il_validkey_cnt)+ "개까지 등록 가능합니다.")
	Return
End If

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.object.langtype[ll_row] = is_n_langtype
dw_detail.object.auth_method[ll_row] = is_n_auth_method
dw_detail.object.validitem1[ll_row] = is_n_validitem1
dw_detail.object.validitem2[ll_row] = is_n_validitem2
dw_detail.object.validitem3[ll_row] = is_n_validitem3
dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

//This.Trigger Event ue_extra_insert(ll_row,li_return)
//
//If li_return < 0 Then
//	Return
//End if

Choose Case ii_cnt
	Case 0
		dw_detail.Object.validkey.Protect  = 0
		dw_detail.Object.validkey.Pointer  = "Arrow!"
		dw_detail.idwo_help_col[1] = dw_detail.Object.gu
//		is_help_win[1] = "b1w_hlp_validkeymst"
//		is_data[1] = "CloseWithReturn"

	Case 1
		ls_reg_partner = Trim(dw_cond.Object.reg_partner[1])
		ls_priceplan   = Trim(dw_cond.Object.priceplan[1])
		
		dw_detail.Object.validkey.Protect   = 1
		dw_detail.Object.validkey.Pointer   = "Help!"
		dw_detail.idwo_help_col[1] = dw_detail.Object.validkey
		dw_detail.is_help_win[1] = "b1w_hlp_validkeymst"
		dw_detail.is_data[1] = "CloseWithReturn"
		dw_detail.is_data[2] = is_moveyn       //할당모듈 사용여부
		dw_detail.is_data[3] = ls_reg_partner  //유치처
		dw_detail.is_data[4] = ls_priceplan    //가격정책
		
End Choose

end event

type dw_cond from w_a_reg_m_m3`dw_cond within b1w_reg_svc_actorder_pre_2
integer y = 56
integer width = 2578
integer height = 1064
integer taborder = 40
string dataobject = "b1dw_cnd_reg_svc_actorder_pre_2"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod
Long li_exist, ll_i, li_return
String ls_filter, ls_validkey_yn, ls_act_gu, ls_customerid, ls_currency_type
String ls_priceplan, ls_reg_partner, ls_requestdt, ls_pricemodel
Boolean lb_check
datetime ldt_date
Decimal ldc_rate

setnull(ldt_date)
Choose Case dwo.name
	Case "customerid" 
   		wfi_get_customerid(data)		

	Case "requestdt" 
		
		ls_act_gu = This.object.act_gu[row]
		If ls_act_gu = 'Y' Then
			This.object.bil_fromdt[row] = This.object.requestdt[row]
		End If

	Case "act_gu" 
		If data = 'Y' Then
			This.object.bil_fromdt[row] = This.object.requestdt[row]
		ElseIf  data = 'N'Then
			This.object.bil_fromdt[row] = ldt_date
		End If

	Case "svccod"
		
		ls_customerid = Trim(dw_cond.object.customerid[1])
		is_svccode = data

		is_xener_svc = 'N'
		For ll_i = 1  to UpperBound(is_Xener_svccod)
			IF is_svccode = is_Xener_svccod[ll_i] Then
				is_xener_svc = 'Y'
				Exit
			End IF
		NEXT	
		
		Select svctype
		  Into :is_svctype
		  From svcmst
		where svccod = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT svctype from svcmst")				
			Return 1
		End If	
		
		//고객의 납입자의 화폐단위 가져오기
		select currency_type into :ls_currency_type from billinginfo bil, customerm cus
		where bil.customerid = cus.payid and  cus.customerid =:ls_customerid;
		
		
		li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		ls_filter = "svccod = '" + data  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' And " + &
		            "currency_type ='" + ls_currency_type + "' " 
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If  
		
		//선택할수 있게
		dw_cond.object.priceplan.Protect = 0
		
	Case "pricemodel"
		
		Select nvl(price,0)
		  Into :idc_price
		  From salepricemodel
		where pricemodel  = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
			Return 1
		End If	
		
		ls_reg_partner = Trim(This.object.reg_partner[1])
		ls_priceplan = Trim(This.object.priceplan[1])
		ls_requestdt = String(This.object.requestdt[1],'yyyymmdd')
		
		If isnull(ls_reg_partner) Then ls_reg_partner = ""
		If isnull(ls_priceplan) Then ls_priceplan = ""	
		If isnull(ls_requestdt) Then ls_requestdt = ""

		If ls_requestdt = "" Then
		    f_msg_info(9000, parent.title,  "개통요청일을 먼저 입력하여 주십시요.")
			This.Object.pricemodel[1] = ""
			RETURN 2
		End If

		If ls_priceplan = "" Then
		    f_msg_info(9000, parent.title,  "가격정책를 먼저 선택하여 주십시요.")
			This.Object.pricemodel[1] = ""
			RETURN 2
		End IF
		
		If ls_reg_partner = "" Then
		    f_msg_info(9000, parent.title,  "유치처를 먼저 선택하여 주십시요.")
			This.Object.pricemodel[1] = ""
			RETURN 2
		End If
		
		ldc_rate = 0 
		li_return = wf_refill_ratefirst(ls_reg_partner, ls_priceplan, ls_requestdt, idc_price, ldc_rate) 

		If li_return = -1 Then
			f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
			Return 1
		ElseIf li_return = 1 Then
			This.object.first_refill_amt[1] = idc_price
			This.object.first_sale_amt[1] = idc_price		
		ElseIf li_return = 0 Then
			This.object.first_refill_amt[1] = idc_price
			This.object.first_sale_amt[1] = idc_price * ldc_rate/100
		End If
		
	Case "priceplan"
		
		Select nvl(validkeycnt,0)
		  Into :il_validkey_cnt
		  From priceplanmst
		where priceplan  = :data;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(parent.title, "SELECT validkey_yn from priceplanmst")				
			Return 1
		End If	
		
		If il_validkey_cnt > 0 Then
			If is_xener_svc = 'N' Then
				This.object.langtype.Protect = 0						
				This.object.auth_method.Protect = 1
				This.Object.h323id.Protect = 1
				This.Object.ip_address.Protect = 1
				This.Object.langtype.Background.Color = RGB(108, 147, 137)
				This.Object.langtype.Color = RGB(255, 255, 255)
				This.Object.auth_method.Background.Color = RGB(255, 251, 240)
				This.Object.auth_method.Color = RGB(0, 0, 0)		
				This.Object.h323id.Background.Color = RGB(255, 251, 240)
				This.Object.h323id.Color = RGB(0, 0, 0)
				This.Object.ip_address.Background.Color = RGB(255, 251, 240)
				This.Object.ip_address.Color = RGB(0, 0, 0)
			ElseIf is_xener_svc = 'Y' Then
				This.object.langtype.Protect = 0						
				This.object.auth_method.Protect = 0
				This.Object.h323id.Protect = 0
				This.Object.ip_address.Protect = 0
				This.Object.langtype.Background.Color = RGB(108, 147, 137)
				This.Object.langtype.Color = RGB(255, 255, 255)
				This.Object.auth_method.Background.Color = RGB(108, 147, 137)
				This.Object.auth_method.Color = RGB(255, 255, 255)
				This.Object.h323id.Background.Color = RGB(255, 255, 255)
				This.Object.h323id.Color = RGB(0, 0, 0)
				This.Object.ip_address.Background.Color = RGB(255, 255, 255)
				This.Object.ip_address.Color = RGB(0, 0, 0)
			End If
		ElseIf il_validkey_cnt = 0 Then
			This.object.langtype[1] = ""			
			This.object.auth_method[1] = ""
			This.Object.h323id[1] = ""
			This.Object.ip_address[1] = ""
			This.object.langtype.Protect = 1											
			This.object.auth_method.Protect = 1
			This.Object.h323id.Protect = 1
			This.Object.ip_address.Protect = 1
			This.Object.langtype.Background.Color = RGB(255, 251, 240)
			This.Object.langtype.Color = RGB(0, 0, 0)
			This.Object.auth_method.Background.Color = RGB(255, 251, 240)
			This.Object.auth_method.Color = RGB(0, 0, 0)		
			This.Object.h323id.Background.Color = RGB(255, 251, 240)
			This.Object.h323id.Color = RGB(0, 0, 0)
			This.Object.ip_address.Background.Color = RGB(255, 251, 240)
			This.Object.ip_address.Color = RGB(0, 0, 0)
		End If
		
		ls_reg_partner = Trim(This.object.reg_partner[1])
		ls_requestdt = String(This.object.requestdt[1],'yyyymmdd')
		ls_pricemodel = Trim(This.object.pricemodel[1])
		If isnull(ls_reg_partner) Then ls_reg_partner = ""
		If isnull(ls_requestdt) Then ls_requestdt = ""
		If isnull(ls_pricemodel) Then ls_pricemodel = ""
		
		If ls_reg_partner <> "" and ls_requestdt <> "" and ls_pricemodel <> "" Then
			ldc_rate = 0 
			li_return = wf_refill_ratefirst(ls_reg_partner, data, ls_requestdt, idc_price,ldc_rate) 
	
			If li_return = -1 Then
				f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
				Return 1
			ElseIf li_return = 1 Then
				This.object.first_refill_amt[1] = idc_price
				This.object.first_sale_amt[1] = idc_price		
			ElseIf li_return = 0 Then
				This.object.first_refill_amt[1] = idc_price
				This.object.first_sale_amt[1] = idc_price * ldc_rate/100
			End If
		End IF
		
	Case "reg_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.reg_partnernm[1] = ""
		Else
			Object.reg_partnernm[1] = data
		End IF

		ls_priceplan = Trim(This.object.priceplan[1])
		ls_requestdt = String(This.object.requestdt[1],'yyyymmdd')
		ls_pricemodel = Trim(This.object.pricemodel[1])
		If isnull(ls_priceplan) Then ls_priceplan = ""
		If isnull(ls_requestdt) Then ls_requestdt = ""
		If isnull(ls_pricemodel) Then ls_pricemodel = ""
		
		If ls_priceplan <> "" and ls_requestdt <> "" and ls_pricemodel <> "" Then
			ldc_rate = 0 
			li_return = wf_refill_ratefirst(data, ls_priceplan, ls_requestdt, idc_price,ldc_rate) 
	
			If li_return = -1 Then
				f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
				Return 1
			ElseIf li_return = 1 Then
				This.object.first_refill_amt[1] = idc_price
				This.object.first_sale_amt[1] = idc_price		
			ElseIf li_return = 0 Then
				This.object.first_refill_amt[1] = idc_price
				This.object.first_sale_amt[1] = idc_price * ldc_rate/100
			End If
		End IF
		
	Case "sale_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.sale_partnernm[1] = ""
		Else
			Object.sale_partnernm[1] = data
		End IF
		
	Case "auth_method"
	
		If LeftA(data,1) = 'S' Then
			This.Object.ip_address.Protect = 0
			This.Object.ip_address.Background.Color = RGB(108, 147, 137)
			This.Object.ip_address.Color = RGB(255, 255, 255)
		Else
			This.object.ip_address[1] = ""
			This.Object.ip_address.Protect = 1
			This.Object.ip_address.Background.Color = RGB(255, 251, 240)
			This.Object.ip_address.Color = RGB(0, 0, 0)
		End If
		
		If MidA(data, 7,1) <> 'E'  Then
			This.Object.h323id.Protect = 0
			This.Object.h323id.Background.Color = RGB(108, 147, 137)
			This.Object.h323id.Color = RGB(255, 255, 255)
		Else
			This.object.h323id[1] = ""
			This.Object.h323id.Protect = 1
			This.Object.h323id.Background.Color = RGB(255, 251, 240)
			This.Object.h323id.Color = RGB(0, 0, 0)
		End If
	
End Choose	

end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"

//유치파트너
This.idwo_help_col[2] = This.Object.reg_partner
This.is_help_win[2] = "b1w_hlp_partner"
This.is_data[2] = "CloseWithReturn"

//매출 파트너 
This.idwo_help_col[3] = This.Object.sale_partner
This.is_help_win[3] = "b1w_hlp_partner"
This.is_data[3] = "CloseWithReturn"

//관리 파트너 
This.idwo_help_col[4] = This.Object.maintain_partner
This.is_help_win[4] = "b1w_hlp_partner"
This.is_data[4] = "CloseWithReturn"
end event

event dw_cond::clicked;call super::clicked;If dwo.name = "svccod" Then
	dw_cond.object.priceplan[1] = ""
	dw_cond.object.prmtype[1] = ""
End If
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist, li_return
Boolean lb_check
String ls_filter, ls_priceplan, ls_requestdt, ls_pricemodel
Decimal ldc_rate

Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
			 is_cus_status = dw_cond.iu_cust_help.is_data[3]
		End If
		dw_cond.object.svccod.Protect = 0					 		
  Case "reg_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.reg_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.reg_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
		
		ls_priceplan = Trim(This.object.priceplan[1])
		ls_requestdt = String(This.object.requestdt[1],'yyyymmdd')
		ls_pricemodel = Trim(This.object.pricemodel[1])
		If isnull(ls_priceplan) Then ls_priceplan = ""
		If isnull(ls_requestdt) Then ls_requestdt = ""
		If isnull(ls_pricemodel) Then ls_pricemodel = ""
		
		If ls_priceplan <> "" and ls_requestdt <> "" and ls_pricemodel <> "" Then
			ldc_rate = 0 
			li_return = wf_refill_ratefirst(dw_cond.iu_cust_help.is_data[1], ls_priceplan, ls_requestdt, idc_price,ldc_rate) 
	
			If li_return = -1 Then
				f_msg_sql_err(parent.title, "SELECT price from salepricemodel")				
				Return 1
			ElseIf li_return = 1 Then
				This.object.first_refill_amt[1] = idc_price
				This.object.first_sale_amt[1] = idc_price		
			ElseIf li_return = 0 Then
				This.object.first_refill_amt[1] = idc_price
				This.object.first_sale_amt[1] = idc_price * ldc_rate/100
			End If
		End IF
	Case "sale_partner"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.sale_partner[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			  dw_cond.Object.sale_partnernm[row] = &
			 dw_cond.iu_cust_help.is_data[1]
		End If
    Case "maintain_partner"
 		If dw_cond.iu_cust_help.ib_data[1] Then
			dw_cond.Object.maintain_partner[row] = &
			dw_cond.iu_cust_help.is_data[1]
			dw_cond.Object.maintain_partnernm[row] = &
			dw_cond.iu_cust_help.is_data[1]
		End If
End Choose

Return 0 
end event

type p_ok from w_a_reg_m_m3`p_ok within b1w_reg_svc_actorder_pre_2
integer x = 2766
integer y = 140
end type

type p_close from w_a_reg_m_m3`p_close within b1w_reg_svc_actorder_pre_2
integer x = 2766
integer y = 276
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b1w_reg_svc_actorder_pre_2
integer x = 41
integer y = 4
integer width = 2624
integer height = 1132
integer taborder = 20
end type

type dw_master from w_a_reg_m_m3`dw_master within b1w_reg_svc_actorder_pre_2
boolean visible = false
integer x = 23
integer y = 952
integer width = 2670
integer taborder = 50
end type

type dw_detail from w_a_reg_m_m3`dw_detail within b1w_reg_svc_actorder_pre_2
integer y = 1656
integer width = 3045
integer height = 376
integer taborder = 30
string dataobject = "b1dw_reg_svc_actorder_ipn_3"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

//Help Window
This.idwo_help_col[1] = This.Object.validkey
This.is_help_win[1] = "b1w_hlp_validkeymst"
This.is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;
If dwo.name = "validkey" Then
	If ii_cnt > 0 Then
		If dw_detail.iu_cust_help.ib_data[1] Then
			dw_detail.Object.validkey[row] = &
			dw_detail.iu_cust_help.is_data[1]
		End If
	End If
End If


Return 0 
end event

type p_insert from w_a_reg_m_m3`p_insert within b1w_reg_svc_actorder_pre_2
integer x = 46
integer y = 2056
end type

type p_delete from w_a_reg_m_m3`p_delete within b1w_reg_svc_actorder_pre_2
integer x = 379
integer y = 2056
end type

type p_save from w_a_reg_m_m3`p_save within b1w_reg_svc_actorder_pre_2
integer x = 713
integer y = 2056
end type

type p_reset from w_a_reg_m_m3`p_reset within b1w_reg_svc_actorder_pre_2
integer x = 1463
integer y = 2056
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b1w_reg_svc_actorder_pre_2
integer x = 37
integer y = 1180
integer width = 3040
integer height = 440
integer taborder = 10
string dataobject = "b1dw_reg_svc_actorder"
end type

event dw_detail2::constructor;call super::constructor;dw_detail2.SetRowFocusIndicator(off!)
end event

event dw_detail2::retrieveend;call super::retrieveend;Long i
String ls_mainitem_yn

If rowcount = 0 Then
	p_save.TriggerEvent("ue_disable")
End If


For i = 1 To rowcount 

	dw_detail2.object.chk[i] = "Y" 
//	If dw_detail.object.mainitem_yn[i] = "Y" Then
//		dw_detail.object.itemcod.Color = RGB(255,0,255)
//		dw_detail.object.itemnm.Color = RGB(255,0,255)
//		dw_detail.object.quota_yn.Color = RGB(255,0,255)
//		dw_detail.object.chk.Color = RGB(255,0,255)
//	Else
//		dw_detail.object.itemcod.Color = RGB(0,0,0)
//		dw_detail.object.itemnm.Color = RGB(0,0,0)
//		dw_detail.object.quota_yn.Color = RGB(0,0,0)
//		dw_detail.object.chk.Color = RGB(0,0,0)
//	End If

	This.SetItemStatus(i, 0, Primary!, NotModified!)

Next
end event

event dw_detail2::ue_init();call super::ue_init;ib_delete = False
ib_insert = False

end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b1w_reg_svc_actorder_pre_2
integer y = 1136
integer height = 36
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within b1w_reg_svc_actorder_pre_2
boolean visible = false
integer y = 1620
integer height = 36
end type

