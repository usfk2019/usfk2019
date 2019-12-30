$PBExportHeader$b1w_reg_svc_actorder_pre_reserve_v20_moo.srw
$PBExportComments$[kem]선불서비스개통신청(예약개통확정call)  v20 - moohan
forward
global type b1w_reg_svc_actorder_pre_reserve_v20_moo from w_a_reg_m_m3
end type
end forward

global type b1w_reg_svc_actorder_pre_reserve_v20_moo from w_a_reg_m_m3
integer width = 3150
integer height = 2284
end type
global b1w_reg_svc_actorder_pre_reserve_v20_moo b1w_reg_svc_actorder_pre_reserve_v20_moo

type variables
Long il_orderno, il_validkey_cnt, il_seq
String is_act_gu, is_cus_status, is_validkey_yn, is_svctype, is_gkid, is_priceplan
String is_SP_code, is_svccode, is_Xener_svccod[], is_xener_svc, is_langtype
Decimal idc_price //slaepricemodel 가격
String is_date_check  //개통일 Check 여부

Long   il_contractseq
String is_n_langtype, is_n_auth_method, is_n_validitem1, is_n_validitem2, is_n_validitem3

//가격정책별 인증Key Type
Integer ii_cnt
String  is_moveyn, is_M_method, is_D_method

String  is_h323id[], is_reg_partner, is_customerid, is_in_svctype
String   is_out_svctype, is_inout_svc_gu, is_validkey_type, is_status[], is_auth_method
String is_validkey, is_validtype, is_bonsa_partner, is_crt_kind_code[], is_crt_kind

string is_callforward_type, is_callforward_code[], is_addition_itemcod, is_partner

end variables

forward prototypes
public function integer wfi_get_ctype3 (string as_customerid, ref boolean ab_check)
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
public subroutine of_resizepanels ()
public function integer wf_refill_ratefirst (string as_partner, string as_priceplan, string as_requestdt, decimal adc_price, ref decimal adc_rate_first)
public function long wf_refillpolicy (string as_partner, string as_priceplan, long al_amt)
public function integer wf_itemcod_chk ()
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

public function long wf_refillpolicy (string as_partner, string as_priceplan, long al_amt);Long ll_extdays
//[ 선불카드 충전 및 개통 처리 중 충전정책 보완]
//	1.1충전정책 select  (판매율, 기본요율, 기본료정액)

SELECT EXTDAYS
  INTO :ll_extdays
  FROM REFILLPOLICY
 WHERE TO_CHAR(FROMDT,'YYYYMMDD') = (SELECT MAX(TO_CHAR(FROMDT,'YYYYMMDD')) 
                                       FROM REFILLPOLICY 
                                      WHERE TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
                                        AND PRICEPLAN = :as_priceplan
													 AND PARTNER   = :as_partner    )
	AND FROMAMT                            <= :al_amt
	AND DECODE(TOAMT, NULL,:al_amt, TOAMT) >= :al_amt
	AND PRICEPLAN = :as_priceplan 
	AND PARTNER   = :as_partner                     ;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT EXTDAYS from REFILLPOLICY 1")				
	Return -1
	
ElseIf SQLCA.SQLCODE = 100 Then	
	//1.2	(1.1에서 record not found 일경우만)
	SELECT EXTDAYS
	  INTO :ll_extdays
	  FROM REFILLPOLICY
	 WHERE TO_CHAR(FROMDT,'YYYYMMDD') = (SELECT MAX(TO_CHAR(FROMDT,'YYYYMMDD')) 
														FROM REFILLPOLICY 
													  WHERE TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
														 AND PRICEPLAN = 'ALL'
														 AND PARTNER   = :as_partner    )
		AND FROMAMT                            <= :al_amt
		AND DECODE(TOAMT, NULL,:al_amt, TOAMT) >= :al_amt
		AND PRICEPLAN = 'ALL'  
		AND PARTNER   = :as_partner                     ;
		
	If SQLCA.SQLCODE < 0 Then
		f_msg_sql_err(title, "SELECT EXTDAYS from REFILLPOLICY 2")				
		Return -1
		
	ElseIf SQLCA.SQLCODE = 100 Then
		//1.3	(1.1,1.2 에서 모두 record not found 일 경우)
		SELECT EXTDAYS
		  INTO :ll_extdays
		  FROM REFILLPOLICY
		 WHERE TO_CHAR(FROMDT,'YYYYMMDD') = (SELECT MAX(TO_CHAR(FROMDT,'YYYYMMDD')) 
															FROM REFILLPOLICY 
														  WHERE TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
															 AND PRICEPLAN = :as_priceplan
															 AND PARTNER   = 'ALL'        )
			AND FROMAMT                            <= :al_amt
			AND DECODE(TOAMT, NULL,:al_amt, TOAMT) >= :al_amt
			AND PRICEPLAN = :as_priceplan
			AND PARTNER   = 'ALL'                     ;
		If SQLCA.SQLCODE < 0 Then
			f_msg_sql_err(title, "SELECT EXTDAYS from REFILLPOLICY 3")				
			Return -1
			
		ElseIf SQLCA.SQLCODE = 100 Then				
			//1.4	(1.1,1.2,1.3에서 모두 record not found 일 경우)
			SELECT EXTDAYS
			  INTO :ll_extdays
			  FROM REFILLPOLICY
			 WHERE TO_CHAR(FROMDT,'YYYYMMDD') = (SELECT MAX(TO_CHAR(FROMDT,'YYYYMMDD')) 
																FROM REFILLPOLICY 
															  WHERE TO_CHAR(FROMDT,'YYYYMMDD') <= TO_CHAR(SYSDATE,'YYYYMMDD')
																 AND PRICEPLAN = 'ALL'
																 AND PARTNER   = 'ALL'        )
				AND FROMAMT                            <= :al_amt
				AND DECODE(TOAMT, NULL,:al_amt, TOAMT) >= :al_amt
				AND PRICEPLAN = 'ALL'  
				AND PARTNER   = 'ALL'                     ;
			If SQLCA.SQLCODE < 0 Then
				f_msg_sql_err(title, "SELECT EXTDAYS from REFILLPOLICY 4")				
				Return -1
			End If
		End If
	End If
End If
				
Return ll_extdays
end function

public function integer wf_itemcod_chk ();Long    ll_row, ll_gubun[], ll_type[], ll_cnt, ll_cnt_1, ll_item_addunit, ll_item_validity_term
Integer li_rc, i
String  ls_chk, ls_item_method, ls_prebil_yn[]
Boolean ib_jon, ib_jon_1, lb_check = False, lb_check_2 = False
String  ls_addition_code[], ls_callforward_info, ls_itemcod[], ls_priceplan, ls_bil_fromdt
Date    ldt_bilfromdt, ldt_date_next_1, ldt_date_next
ib_jon   = False
ib_jon_1 = False

ll_cnt = 0
is_callforward_type = ''
ls_callforward_info = 'N'

For i = 1 To dw_detail2.RowCount()
	ll_gubun[i]      = dw_detail2.Object.groupno[i]
	ll_type[i]       = dw_detail2.Object.grouptype[i]
	ls_chk           = dw_detail2.Object.chk[i]	
	
	If ls_chk = 'Y' Then
		ll_cnt ++
		ls_itemcod[i]    = dw_detail2.Object.itemcod[i]		
		ls_prebil_yn[i] = fs_snvl(dw_detail2.Object.prebil_yn[i], 'N')
	End If
	IF ll_type[i] = 1 Then
		ib_jon   = True
	Else
		ib_jon_1 = True
	End If
	
	//2005-07-06 khpark add start     //착신전환부가서비스 check
	IF ls_chk = 'Y' Then
		ls_addition_code[i] = dw_detail2.object.itemmst_addition_code[i]
		CHOOSE CASE ls_addition_code[i]    
			CASE is_callforward_code[1],is_callforward_code[2],is_callforward_code[3]   //착신전환유형일때 
				//착신전환부가서비스 품목은 하나만 선택 가능하다.
				IF ls_callforward_info = 'Y' Then
					f_msg_info(9000, Title, "품목구성이 올바르지않습니다.(착신전환부가서비스품목하나이상선택)")						
					return -2
				End IF
				is_callforward_type =  ls_addition_code[i]
				is_addition_itemcod =  dw_detail2.object.itemcod[i]
				ls_callforward_info = 'Y'
		END CHOOSE	
   End IF
   //2005-07-06 khpark add end		
   
Next

If ll_cnt = 0 Then
	f_msg_info(9000, Title, "품목을 선택하여야 합니다.")	
	Return  -2
End If

ll_cnt   = 0
ll_cnt_1 = 0
ls_chk   = ''
//For i = 1 to UpperBound(ll_gubun)
//	ls_chk = dw_detail2.Object.chk[i]
//	If ll_type[i] = 0 Then
//		If ls_chk = 'Y' Then
//			For j = i + 1 TO UpperBound(ll_gubun)
////				If (ll_gubun[i] = ll_gubun[j]) And dw_detail2.Object.chk[j] = 'Y' Then
//				If (ll_type[i] = ll_type[j]) And dw_detail2.Object.chk[j] = 'Y' Then
////					f_msg_info(9000, Title, "품목Group이 같은 품목의 선택유형이 한 품목만 선택가능한 유형이므로 한 품목만 선택하여야 합니다.")	
//					f_msg_info(9000, Title, "선택유형이 한 품목만 선택가능한 유형이므로 한 품목만 선택하여야 합니다.")	
//					ai_return = -2
//					Return	
//				End If
//			Next
//			ll_cnt_1 ++
//		End If
//	ElseIf ll_type[i] = 1 Then
//		If ls_chk = 'Y' Then
//			ll_cnt ++
//		End If
//	End If	
//Next

//동일 그룹일때 선택유형이 0이면 하나만 선택해야하고 동일 그룹일때 선택유형이 1이면 하나 이상  선택하여야한다.
//선택유형이 0인것중 group이  여러종류로 구성되어있다면..각동일그룹에서 하나씩만 선택되어야한다.
long cnt = 0, t
For i = 1 To UpperBound(ll_gubun)  
	If ll_type[i] = 0 Then 
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If dw_detail2.Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group 중 한개 품목은 필수로 선택하셔야 하는 품목이 있습니다.")	
			Return -2		
		End If
		cnt = 0
	Else
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If dw_detail2.Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group중 한 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2		
		End If
		cnt = 0
	End If
Next

//For i = 1 to UpperBound(ll_gubun)  
//	ls_chk = dw_detail2.Object.chk[i]	
//	For j = 1 TO UpperBound(ll_gubun)
//		If i = j Then  continue
//		If ll_gubun[i] = ll_gubun[j] Then
//			If ll_type[i] = 0 Then
//				If ls_chk = 'Y' Then 
//					If dw_detail2.Object.chk[j] = 'Y' Then
//						f_msg_info(9000, Title, "동일Group 중 1개만 선택가능한 유형이므로 한 품목만 선택하여야 합니다.")	
//						ai_return = -2
//						Return	
//					End If
//					lb_check = True
//				Else
//					If dw_detail2.Object.chk[j] = 'Y' Then
//						lb_check = True
//					End If
//				End If
//				
//				p = j+1
//				If UpperBound(ll_gubun) >= p Then
//					If ll_gubun[i] <> ll_gubun[p] Then
//						If lb_check = False Then
//							f_msg_info(9000, Title, "동일Group중 한 품목은 필수로 선택해야하는 유형입니다.")	
//							ai_return = -2
//							Return	
//						End If
//					End If
//				End If
//			Else
//				If ls_chk = 'Y' Then 
//					lb_check_2 = True
//				Else
//					If dw_detail2.Object.chk[j] = 'Y' Then
//						lb_check_2 = True
//					Else
//						lb_check_2 = False
//					End If
//				End If
//				
//				p = j+1
//				If UpperBound(ll_gubun) >= p Then
//					If ll_gubun[i] <> ll_gubun[p] Then
//						If lb_check_2 = False Then
//							f_msg_info(9000, Title, "동일Group중 한 품목 이상 선택해야하는 유형입니다.")	
//							ai_return = -2
//							Return	
//						End If
//					End If
//				Else
//					If lb_check_2 = False Then
//						f_msg_info(9000, Title, "동일Group중 한 품목 이상 선택해야하는 유형입니다.")	
//						ai_return = -2
//						Return	
//					End If
//				End If
//			End If	
//		End If
//	Next
//	lb_check   = False
//	lb_check_2 = False
//Next

//If ll_cnt = 0 And ib_jon = True Then
//	f_msg_info(9000, Title, "선택유형이 1인 상품은 한개 품목이상 필수선택사항 입니다.")	
//	ai_return = -2
//	Return 
//End If
//
//If ll_cnt_1 = 0  And ib_jon_1 = True Then
//	f_msg_info(9000, Title, "선택유형이 0인 상품중 한개 품목은 필수선택사항 입니다.")	
//	ai_return = -2
//	Return 
//End If

ls_priceplan  = fs_snvl(dw_cond.object.priceplan[1], '')
ls_bil_fromdt =  String(dw_cond.object.bil_fromdt[1], 'yyyymmdd')
ldt_bilfromdt = dw_cond.object.bil_fromdt[1]

For i = 1 To upperbound(ls_itemcod)
	
	If fs_snvl(ls_itemcod[i], '') = '' Then continue
	
	If ls_prebil_yn[i] = 'Y' Then 
	
		select method         , nvl(addunit,0)  , nvl(validity_term,0)
		  into :ls_item_method, :ll_item_addunit, :ll_item_validity_term
		  from priceplan_rate2
		 where priceplan = :ls_priceplan
			and itemcod   = :ls_itemcod[i] 
			and fromdt    = (select max(fromdt)
									 from priceplan_rate2
									where priceplan = :ls_priceplan 
									  and itemcod   = :ls_itemcod[i]
									  and fromdt   <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
	
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(title, "Select priceplan_rate2")				
			Return -2
		ElseIF sqlca.sqlcode = 100 Then
			
		End If
		
		ll_item_addunit        = ll_item_addunit * ll_item_validity_term
		
		If ll_item_validity_term > 0 Then
			
			If ls_item_method = is_D_method Then
				
				ldt_date_next_1 = fd_date_next(ldt_bilfromdt, ll_item_addunit)
				
				SELECT :ldt_date_next_1 -1 
				  INTO :ldt_date_next
				  FROM DUAL                 ;
				
				dw_cond.Object.enddt[1] = ldt_date_next
				
			ElseIf ls_item_method = is_M_method Then
				
				SELECT ADD_MONTHS(TO_DATE(:ls_bil_fromdt, 'YYYYMMDD'), :ll_item_addunit) -1
				  INTO :ldt_date_next
				  FROM DUAL;
				  
				dw_cond.Object.enddt[1] = ldt_date_next
	
			Else
	
			End If
			
			EXIT
			
		End If
	End If
Next
return 1   //정상 return
end function

on b1w_reg_svc_actorder_pre_reserve_v20_moo.create
call super::create
end on

on b1w_reg_svc_actorder_pre_reserve_v20_moo.destroy
call super::destroy
end on

event open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actorder_pre_reserve_v20
	Desc	: 	 선불서비스 개통신청(서비스 예약 처리 - 개통처리에서 call)
	Ver.	:	1.0
	Date	:   2005.05.18.
	Programer : ohj
-------------------------------------------------------------------------*/
call w_a_condition::open

string ls_ref_desc, ls_temp, ls_result[], ls_svccod, ls_currency_type, &
       ls_filter, ls_prebil_yn, ls_method, ls_requestdt, ls_bilfromdt, &
		 ls_method_code[], ls_direct_paytype
Long   li_exist, ll_row//, ll_validity_term, ll_addunit, ll_use
//Date   ldt_bilfromdt, ldt_date_next, ldt_date_next_1

DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod, ldc_validkey_type, ldc_wkflag2

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
dw_cond.object.bil_fromdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
//2005.11.17 kem Modify 
//dw_cond.object.reg_partner[1] = gs_user_group
//dw_cond.object.sale_partner[1] = gs_user_group
//dw_cond.object.reg_partnernm[1] = gs_user_group
//dw_cond.object.maintain_partner[1] = gs_user_group
//dw_cond.object.maintain_partnernm[1] = gs_user_group
//dw_cond.Object.endday[1] = Long(String(fdt_get_dbserver_now(),'dd'))

ls_ref_desc = ""
//gkid default 값
is_gkid = fs_get_control("00", "G100", ls_ref_desc)
dw_cond.object.gkid[1] = is_gkid

//본사대리점코드
//is_bonsa_partner = fs_get_control("A1", "C102", ls_ref_desc)

//개통일 Check 여부
ls_ref_desc = ""
is_date_check = fs_get_control("B0", "P210", ls_ref_desc)

il_orderno = 0

//ValidInfo LangType
is_langtype = fs_get_control("B1", "P204", ls_ref_desc)

//Validkey 할당모듈 사용여부
is_moveyn = fs_get_control("B1", "P401", ls_ref_desc)

//2005.02.14 OHJ　h323id 컨트롤..
ls_ref_desc = ""
ls_temp = fs_get_control("00", "Z700", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_h323id[]) 

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

//부가서비스유형코드  //2005-07-08 khpark add
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("B0", "A101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_callforward_code[])

//payment process default setting
ls_direct_paytype = fs_get_control("B1","P602", ls_ref_desc)
dw_cond.object.direct_paytype[1] = ls_direct_paytype

//과금방식코드 ohj 07/12
ls_temp = fs_get_control("B0", "P106" , ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method_code[])
is_M_method  = ls_method_code[1]    //월정액
is_D_method  = ls_method_code[8]    //Daily정액	

dw_cond.object.langtype[1] = is_langtype
dw_cond.object.act_gu[1]   = 'Y'
dw_cond.object.act_gu.Protect = 1
dw_cond.object.bil_fromdt[1] = Date(fdt_get_dbserver_now())

iu_cust_msg   = Message.PowerObjectParm
ls_svccod     = iu_cust_msg.is_data[1]
is_priceplan  = iu_cust_msg.is_data[2]
is_customerid = iu_cust_msg.is_data[4]
is_validtype  = iu_cust_msg.is_data[3]
is_validkey   = iu_cust_msg.is_data[6]
is_partner    = iu_cust_msg.is_data[7]
il_seq        = iu_cust_msg.il_data[1]

//2005.11.17 kem Modify
dw_cond.object.reg_partner[1] = is_partner
dw_cond.object.sale_partner[1] = is_partner
dw_cond.object.reg_partnernm[1] = is_partner
dw_cond.object.sale_partnernm[1] = is_partner
dw_cond.object.maintain_partner[1] = is_partner
dw_cond.object.maintain_partnernm[1] = is_partner

dw_cond.object.svccod[1]        = ls_svccod
dw_cond.object.priceplan[1]     = is_priceplan
dw_cond.object.customerid[1]    = is_customerid
dw_cond.object.validkey_type[1] = is_validtype

wfi_get_customerid(is_customerid)
dw_cond.object.svccod.Protect     = 1
dw_cond.object.priceplan.Protect  = 1
dw_cond.object.customerid.Protect = 1
dw_cond.object.validkey_type.Protect = 1

is_svccode = ls_svccod

Select svctype
  Into :is_svctype
  From svcmst
 where svccod = :ls_svccod;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT svctype from svcmst")				
	Return 1
End If	
		
//고객의 납입자의 화폐단위 가져오기
select currency_type 
  into :ls_currency_type 
  from billinginfo bil
     , customerm   cus
 where bil.customerid = cus.payid 
   and cus.customerid =:is_customerid ;

li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
ls_filter = "svccod        ='" + ls_svccod + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' And " + &
				"currency_type ='" + ls_currency_type + "' " 
				
ldc_priceplan.SetTransObject(SQLCA)
li_exist =ldc_priceplan.Retrieve()
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If  
		
Select nvl(validkeycnt,0)
  Into :il_validkey_cnt
  From priceplanmst
 where priceplan  = :is_priceplan;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, "SELECT validkey_yn from priceplanmst")				
	Return 1
End If	

If il_validkey_cnt > 0 Then
	dw_cond.object.langtype.Protect = 0		
	dw_cond.Object.langtype.Background.Color = RGB(108, 147, 137)
	dw_cond.Object.langtype.Color = RGB(255, 255, 255)
	dw_cond.Object.validkey_type.Protect = 0
	dw_cond.Object.validkey_type.Background.Color =  RGB(108, 147, 137)
	dw_cond.Object.validkey_type.Color = RGB(255, 255, 255)
	
ElseIf il_validkey_cnt = 0 Then
	dw_cond.object.langtype[1] = ""	
	dw_cond.object.langtype.Protect = 1		
	dw_cond.Object.langtype.Background.Color = RGB(255, 251, 240)
	dw_cond.Object.langtype.Color = RGB(0, 0, 0)
	dw_cond.Object.validkey_type[1] = ""
	dw_cond.object.validkey_type.Protect = 1
	dw_cond.Object.validkey_type.Background.Color = RGB(255, 251, 240)
	dw_cond.Object.validkey_type.Color = RGB(0, 0, 0)	
End If

//언어맨트 수정 ohj 07/12
ll_row = dw_cond.GetChild("langtype", ldc_wkflag2)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")

ls_filter = "svccod = '" + ls_svccod + "' "
ldc_wkflag2.SetFilter(ls_filter)			//Filter정함
ldc_wkflag2.Filter()
ldc_wkflag2.SetTransObject(SQLCA)
ll_row = ldc_wkflag2.Retrieve()

If ll_row < 0 Then 				//디비 오류 
	f_msg_usr_err(2100, Title, "언어멘트 Retrieve()")
	Return -1
End If
		
//가격정책별 인증KEYTYPE
li_exist = dw_cond.GetChild("validkey_type", ldc_validkey_type)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
ls_filter = "a.priceplan = '" + is_priceplan + "'  " 
ldc_validkey_type.SetTransObject(SQLCA)
li_exist =ldc_validkey_type.Retrieve()
ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
ldc_validkey_type.Filter()

If li_exist < 0 Then 
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If

// BILL_TODT는 SAVE할때 계산...
//ls_requestdt = String(fdt_get_dbserver_now(), 'yyyymmdd')

//SELECT UNITCHARGE
//	  , ADDUNIT
//	  , METHOD
//	  , NVL(ADDITEM      , '')		ADDITEM
//	  , nvl(VALIDITY_TERM, 0 )  	VALIDITY_TERM
//  INTO :ldc_unitcharge
//	  , :ll_addunit
//	  , :ls_method
//	  , :ls_additem
//	  , :ll_validity_term
//  FROM PRICEPLAN_RATE2
// WHERE PRICEPLAN = :is_priceplan
//	AND ITEMCOD   = :ls_itemcod1
//	and fromdt    = (select max(fromdt) 
//						    from priceplan_rate2
//				         where priceplan = :ls_priceplan
//					        and itemcod   = :ls_itemcod1
//					        And fromdt   <= to_date(:ls_bil_fromdt,'yyyy-mm-dd'));
//										
//SELECT A.VALIDITY_TERM
//	  , NVL(B.PREBIL_YN, 'N')  AS PREBIL_YN
//	  , A.METHOD
//	  , A.ADDUNIT			  
//  INTO :ll_validity_term
//	  , :ls_prebil_yn
//	  , :ls_method
//	  , :ll_addunit
//  FROM PRICEPLAN_RATE2 A,
//		 ITEMMST B
// WHERE A.ITEMCOD   = B.ITEMCOD
//	AND A.PRICEPLAN = :is_priceplan
//	AND B.PREBIL_YN = 'Y'
//	AND TO_CHAR(A.FROMDT,'YYYYMMDD') <= :ls_requestdt
//	AND TO_CHAR(NVL(A.TODT, SYSDATE),'YYYYMMDD') >= :ls_requestdt
//	AND ROWNUM = 1;

//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(title, "SELECT validity_term")				
//	Return 1
//End If
//
//dw_cond.Object.prebil_yn[1] = ls_prebil_yn
//		
//ldt_bilfromdt = dw_cond.Object.bil_fromdt[1]  	//과금시작일
//ll_use        = ll_addunit * ll_validity_term 	//사용가능일(월)
//ls_bilfromdt  = string(ldt_bilfromdt, 'YYYYMMDD')
//
//If ls_method = is_d_method Then
//	
//	ldt_date_next_1 = fd_date_next(ldt_bilfromdt, ll_use)
//	
//	SELECT :ldt_date_next_1 -1 
//	  INTO :ldt_date_next
//	  FROM DUAL                 ;
//	
//	dw_cond.Object.enddt[1] = ldt_date_next
//	
//ElseIf ls_method = is_m_method Then
//	
//	SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_use) -1
//	  INTO :ldt_date_next
//	  FROM DUAL;
//	  
//	dw_cond.Object.enddt[1] = ldt_date_next
//
//Else
////	dw_cond.Object.enddt[1] = 
//End If
		
SetRedraw(True)
end event

event ue_ok();call super::ue_ok;//해당 서비스에 해당하는 품목 조회
String  ls_svccod, ls_priceplan, ls_customerid, ls_partner, ls_requestdt
String  ls_where, ls_contract_no, ls_gkid, ls_auth_method, ls_sysdt
String  ls_ip_address, ls_h323id, ls_bil_fromdt, ls_validkey_loc
String  ls_reg_partner, ls_sale_partner, ls_pricemodel, ls_langtype
Long    ll_row, ll_result, ll_length, ll_inrow//, ll_endday
String  ls_ref_desc, ls_temp, ls_result[], ls_direct_paytype, ls_prebil_yn
String  ls_validkey_typenm, ls_crt_kind, ls_prefix, ls_type, ls_used_level
Integer li_return

ls_sysdt        = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_customerid   = Trim(dw_cond.object.customerid[1])
ls_svccod       = Trim(dw_cond.object.svccod[1])
ls_priceplan    = Trim(dw_cond.object.priceplan[1])
ls_requestdt    = String(dw_cond.object.requestdt[1],'yyyymmdd')
ls_bil_fromdt   = String(dw_cond.object.bil_fromdt[1],'yyyymmdd')
ls_partner      = Trim(dw_cond.object.partner[1])
is_act_gu       = Trim(dw_cond.object.act_gu[1])
ls_reg_partner  = Trim(dw_cond.object.reg_partner[1])
ls_sale_partner = Trim(dw_cond.object.sale_partner[1])
ls_pricemodel   = Trim(dw_cond.object.pricemodel[1])
ls_direct_paytype = Trim(dw_cond.object.direct_paytype[1])
ls_prebil_yn      = Trim(dw_cond.object.prebil_yn[1])
//ll_endday       = dw_cond.Object.endday[1]

If IsNull(ls_customerid) 	  Then ls_customerid = ""
If IsNull(ls_svccod) 		  Then ls_svccod = ""
If IsNull(ls_priceplan) 	  Then ls_priceplan = ""
If IsNull(ls_requestdt) 	  Then ls_requestdt = ""
If IsNull(ls_bil_fromdt) 	  Then ls_bil_fromdt = ""
If IsNull(ls_partner) 		  Then ls_partner = ""
If IsNull(is_act_gu) 		  Then is_act_gu = ""
If IsNull(ls_reg_partner)    Then ls_reg_partner = ""
If IsNull(ls_sale_partner)   Then ls_sale_partner = ""
If IsNull(ls_pricemodel)     Then ls_pricemodel = ""
If IsNull(ls_direct_paytype) Then ls_direct_paytype = ""

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

//가격정책이 선납상품을 포함한 경우 
If ls_prebil_yn = 'Y' Then
	If ls_direct_paytype = "" Then
		f_msg_info(200, Title, "Payment Method")
		dw_cond.SetFocus()
		dw_cond.SetColumn("direct_paytype")
		Return
	End If
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

//If ll_endday > 0 And ll_endday > 31 Then
//	f_msg_info(9000, Title, "납기일은 1일부터 31일까지 입니다.")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("endday")
//	Return	
//End If

//is_n_langtype  = Trim(dw_cond.object.langtype[1])
//is_n_auth_method = Trim(dw_cond.object.auth_method[1])
//is_n_validitem3 = Trim(dw_cond.object.h323id[1])
//is_n_validitem2 = Trim(dw_cond.object.ip_address[1])
//is_n_validitem1 = Trim(dw_cond.object.validitem1[1])
//If IsNull(is_n_langtype) Then is_n_langtype = ""
//If IsNull(is_n_auth_method) Then is_n_auth_method = ""
//If IsNull(is_n_validitem1) Then is_n_validitem1 = ""
//If IsNull(is_n_validitem2) Then is_n_validitem2 = ""
//If IsNull(is_n_validitem3) Then is_n_validitem3 = ""

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

is_n_langtype  = Trim(dw_cond.object.langtype[1])
is_validkey_type = Trim(dw_cond.object.validkey_type[1])

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
	
//	//인증Key 관리 수정 - 2004.06.02
//	ll_result = b1fi_validkeytype_check('서비스개통신청', ls_priceplan, ii_cnt)
//	
//	If ll_result < 0 Then
//		f_msg_info(9000, Title , "가격정책별 인증Key Type을 찾을 수가 없습니다.")
//		Return
//	End If
	
//	If ii_cnt > 0 Then
//		dw_detail.Object.validkey.protect = 1
//	Else
//		dw_detail.Object.validkey.protect = 0
//	End If
	ll_result = b1fi_validkey_loc_chk_yn_v20(this.Title, is_svccode, ii_cnt)

	//인증Key Location 입력여부
		IF ii_cnt > 0 Then
		dw_detail.Object.validkey_loc.visible   = True
		dw_detail.Object.validkey_loc_t.visible = True
	Else
		dw_detail.Object.validkey_loc.visible   = False
		dw_detail.Object.validkey_loc_t.visible = False
	End If	
	
	li_return = b1fi_validkey_type_info_v20(title, is_validtype, ls_validkey_typenm, is_crt_kind,ls_prefix,ll_length,is_auth_method,ls_type,ls_used_level) 

	If li_return = -1 Then
	    return 
	End IF
	
	ll_inrow = dw_detail.Insertrow(0)
	dw_detail.Object.validkey_type[ll_inrow] = is_validtype
	dw_detail.Object.validkey[ll_inrow]      = is_validkey
	dw_detail.Object.langtype[ll_inrow]      = dw_cond.Object.langtype[1]
	dw_detail.Object.auth_method[ll_inrow]   = is_auth_method	
	
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
dw_cond.object.bil_fromdt[1] = Date(fdt_get_dbserver_now())
dw_cond.object.partner[1] = gs_user_group
dw_cond.object.gkid[1] = is_gkid
dw_cond.object.reg_partner[1] = gs_user_group
dw_cond.object.sale_partner[1] = gs_user_group
dw_cond.object.reg_partnernm[1] = gs_user_group
dw_cond.object.sale_partnernm[1] = gs_user_group
dw_cond.object.langtype[1] = is_langtype
dw_cond.object.maintain_partner[1] = gs_user_group
dw_cond.object.maintain_partnernm[1] = gs_user_group
//dw_cond.Object.endday[1] = Long(String(fdt_get_dbserver_now(),'dd'))


is_validkey_yn= 'N'
il_validkey_cnt = 0 

SetRedraw(False)

dw_detail.Enabled = False
dw_detail.visible = False

of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

trigger event ue_close()



end event

event type integer ue_save();String ls_quota_yn, ls_chk, ls_prebil_yn, ls_direct_paytype
Long i, ll_row, j, k
Int li_rc
Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

This.Trigger Event ue_extra_save(li_rc)

//-2 return 시 rollback되도록 변경 
//원인: 모든 신청메뉴에서 error에 대한 return값을 개념없이 rollback없는 -2값 사용에 대한 조치
If li_rc = -1 Or li_rc = -2 Or li_rc = -3 Then
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
//ElseIF li_rc = -2 Then
//	dw_detail.SetFocus()	
//	Return LI_ERROR
//ElseIF li_rc = -3 Then
//	dw_detail.SetFocus()	
//	Return LI_ERROR
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

//2004-12-08 kem 수정
//선납품목이 있을 경우 선납판매정보 Popup 한다.
Boolean lb_prepay
iu_cust_msg = Create u_cust_a_msg
k = 1

ll_row = dw_detail2.RowCount()
If ll_row = 0 Then Return 0

For i = 1 To ll_row
	ls_chk = Trim(dw_detail2.object.chk[i])
	If ls_chk = "Y" Then
		ls_prebil_yn = Trim(dw_detail2.object.prebil_yn[i])
		If ls_prebil_yn = "Y" Then
			lb_prepay = TRUE
			Exit
		Else
			lb_prepay = FALSE
		End If
	End If
Next
	
If lb_prepay Then			//선납품목 Check한게 있으면
	ls_customerid     = Trim(dw_cond.object.customerid[1])
	ls_direct_paytype = Trim(dw_cond.object.direct_paytype[1])
	
	iu_cust_msg.is_pgm_name = "선납판매정보 등록"
	iu_cust_msg.is_grp_name = "선납판매정보"
	iu_cust_msg.ib_data[1]  = True
	iu_cust_msg.il_data[1]  = il_orderno						//order number
	iu_cust_msg.il_data[2]  = il_contractseq					//contractseq
	iu_cust_msg.is_data2[2] = ls_customerid					//customer ID
	iu_cust_msg.is_data2[3] = gs_pgm_id[gi_open_win_no] 	//Pgm ID
	iu_cust_msg.is_data2[4] = is_act_gu                   //개통처리 여부
	iu_cust_msg.is_data2[5] = ls_direct_paytype				//납부방식 
	
   OpenWithParm(b1w_reg_prepayment_pop, iu_cust_msg)
	
End If

Return 0
end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;Long ll_row, ll_gubun[], ll_type[], ll_cnt, ll_validity_term, ll_cnt_1
Integer li_rc, i, j
String ls_chk, ls_prebil_yn, ls_validkey_loc, ls_vpassword, ls_ip_address, ls_h323id,ls_auth_method
Boolean ib_jon, ib_jon_1

b1u_dbmgr3_v20 lu_dbmgr

SetNull(il_contractseq)
ll_row  = dw_detail2.RowCount()
If ll_row = 0 Then 
	ai_return = 0
	Return
End if

//2005-07-07 khpark modify start
//itemcod check 윈도우 함수로 뺀다. wf_itemcod_chk()
//ue_extra_insert에서도 check한다.
ai_return = wf_itemcod_chk()
IF ai_return <= 0 Then
	return
End IF
//2005-07-07 khpark modify end

If il_validkey_cnt > 0 Then
	ll_row  = dw_detail.RowCount()
	If ll_row = 0 Then 
		f_msg_usr_err(9000, Title, "사용할 인증KEY를 입력하셔야 합니다.")		
		ai_return = -2
		Return
	End if
End if

ls_validkey_loc = fs_snvl(dw_detail.object.validkey_loc[1], '')
ls_vpassword    = fs_snvl(dw_detail.object.vpassword[1]   , '')
ls_ip_address   = fs_snvl(dw_detail.object.validitem2[1]  , '')
ls_h323id       = fs_snvl(dw_detail.object.validitem3[1]  , '')
ls_auth_method	 = fs_snvl(dw_detail.object.auth_method[1] , '')

If is_validtype = "" Then
	f_msg_usr_err(200, Title, "인증KeyType")
	ai_return = -2
	Return
End If

IF is_crt_kind = is_crt_kind_code[1] or is_crt_kind = is_crt_kind_code[4] or is_crt_kind = is_crt_kind_code[5] Then
	If is_validkey = "" Then
		f_msg_usr_err(200, Title, "인증 Key")
		ai_return = -2
		Return
	End If
End IF

If LeftA(ls_auth_method,2) = 'PA' Then
	If ls_vpassword = "" Then
		f_msg_usr_err(200, Title, "인증 Password")
		ai_return = -2
		Return
	End If
End If

If LeftA(ls_auth_method,5) = 'STCIP' Then
	If ls_ip_address = "" Then
		f_msg_usr_err(200, Title, "IP ADDRESS")
		ai_return = -2
		Return
	End If		
End if
	
If MidA(ls_auth_method,7,4) = 'BOTH' or  MidA(ls_auth_method,7,4) = 'H323' Then
	If ls_h323id = "" Then
		f_msg_usr_err(200, Title, "H323ID")
		ai_return = -2
		Return
	End If			
End IF

If ii_cnt > 0 Then    //인증KeyLocation 입력여부
	If ls_validkey_loc = "" Then
		f_msg_usr_err(200, Title, "인증KeyLocation")
		ai_return = -2
		Return
	End If
End IF

//저장
lu_dbmgr = Create b1u_dbmgr3_v20
lu_dbmgr.is_caller = "b1w_reg_svc_actorder_pre_reserve_v20_moohan%save"
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
lu_dbmgr.il_data[3]  = il_seq    		          //예약 seq
//khpark add 2005-07-07
lu_dbmgr.is_data[7]  = is_callforward_type    	 //착신전환부가서비스선택유형
lu_dbmgr.is_data[8]  = is_addition_itemcod    	 //착신전환품목서비스선택유형

lu_dbmgr.uf_prc_db_01()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Or li_rc = -3 Then
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
If is_act_gu = "Y" Then
	il_contractseq = lu_dbmgr.il_data[2]
End If

Destroy lu_dbmgr

ai_return = li_rc

Return
end event

event ue_insert();//override
Long ll_row, ll_cnt
Int li_return

ll_cnt = dw_detail.RowCount()
If ll_cnt >= il_validkey_cnt Then
	f_msg_usr_err(9000,title,"해당가격정책에 인증KEY 등록은 ~r~n~r~n" +string(il_validkey_cnt)+ "개까지 등록 가능합니다.")
	Return
End If

This.Trigger Event ue_extra_insert(ll_row,li_return)

If li_return < 0 Then
	Return
End If


end event

event ue_extra_insert(long al_insert_row, ref integer ai_return);call super::ue_extra_insert;long ll_row
String ls_svccod
//2005-07-08 khpark add start
ai_return = wf_itemcod_chk()
IF ai_return <= 0 Then
	return
End IF
//2005-07-08 khpark modify end

is_reg_partner = Trim(dw_cond.Object.reg_partner[1])
is_priceplan   = Trim(dw_cond.Object.priceplan[1])
is_customerid  = Trim(dw_cond.Object.customerid[1])
ls_svccod      = fs_snvl(dw_cond.Object.svccod[1], '')

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "인증정보수정등록"
iu_cust_msg.is_grp_name = "서비스개통신청(선불)"
iu_cust_msg.is_data[1] = "Ue_extra_insert"
iu_cust_msg.is_data[2] =  is_validkey_type  //인증KeyType
iu_cust_msg.is_data[3] = is_n_langtype      //멘트언어
iu_cust_msg.is_data[4] = is_priceplan       //가격정책
iu_cust_msg.is_data[5] = is_reg_partner     //유치처
iu_cust_msg.is_data[6] = is_customerid      //고객번호
iu_cust_msg.is_data[8] = ls_svccod          //서비스코드  언어맨트때문에 추가 0711
iu_cust_msg.is_data[9] = '1'
iu_cust_msg.ii_data[1] = ii_cnt             //발신지Location check yn ii_cnt
iu_cust_msg.il_data[1] = 1                  //현재row
iu_cust_msg.idw_data[1] = dw_detail
//2005-07-08 khpark add
iu_cust_msg.is_data[7] = is_callforward_type //착신전환유형

//dw_detail의 dddw의 retrieve를 위해서
//b1w_reg_svc_actorder_validinfo_pop_v20 에서 close 시 rowscopy 하는데.. 
//이때, dw_detail에 한건도 없을 경우 dddw가 셋팅이 제대로 되지 않아 insertrow 하고 deleterow 한다.
ll_row = dw_detail.rowcount()
If ll_row =  0 Then
	dw_detail.insertrow(0)
	dw_detail.deleterow(0)
End IF

//IF is_inout_svc_gu = 'N' Then    //입출중계서비스가 아닐 경우
	OpenWithParm(b1w_reg_validinfo_reserve_popup_v20_moo, iu_cust_msg)
//Else                             //입출중계서비스일 경우
//	OpenWithParm(b1w_reg_svcorder_validinfo_pop_1_v20, iu_cust_msg)
//End IF
//
end event

type dw_cond from w_a_reg_m_m3`dw_cond within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 69
integer y = 52
integer width = 2578
integer height = 1004
integer taborder = 40
string dataobject = "b1dw_cnd_reg_svc_actorder_pre_3_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise, ldc_svccod, ldc_validkey_type

Long     li_exist, ll_i, li_return, ll_validity_term, ll_extdays, ll_endday, &
         ll_addunit, ll_use
String   ls_filter, ls_validkey_yn, ls_act_gu, ls_customerid, ls_currency_type
String   ls_priceplan, ls_reg_partner, ls_requestdt, ls_pricemodel, ls_enddt, &
         ls_customer_id, ls_h323id, ls_prebil_yn, ls_method, ls_bilfromdt
Boolean  lb_check
datetime ldt_date
Date     ldt_bilfromdt, ldt_enddt, ldt_date_next, ldt_date_next_1
Decimal  ldc_rate

setnull(ldt_date)
Choose Case dwo.name
	Case "customerid" 
		
   		wfi_get_customerid(data)		
			is_customerid = data
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

//	//납기일 추가
//	Case "bil_fromdt"
//		ll_endday = Long(Mid(data,9,2))
//		
//		dw_cond.Object.endday[1] = ll_endday
		
	Case "svccod"
		
		ls_customerid = Trim(dw_cond.object.customerid[1])
		is_svccode = data

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
		
		ls_enddt = String(dw_cond.Object.enddt[1],'yyyymmdd')
		
		If IsNull(ls_enddt) Then ls_enddt = ""
		
//		If ls_enddt = "" Then
//			SELECT EXTDAYS
//			  INTO :ll_extdays
//			  FROM SALEPRICEMODEL
//			 WHERE PRICEMODEL = :data;
//			
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(parent.title, "SELECT extdays")				
//				Return 1
//			End If
			
		ll_extdays = wf_refillpolicy(ls_reg_partner, ls_priceplan, idc_price)	
		
		If ll_extdays > 0 Then
			ldt_bilfromdt = dw_cond.Object.bil_fromdt[1]
			IF isnull(ldt_bilfromdt) Then ldt_bilfromdt = dw_cond.Object.requestdt[1]
		
			ldt_enddt = fd_date_next(ldt_bilfromdt, ll_extdays)
			
			SELECT :ldt_enddt -1 
			  INTO :ldt_enddt
			  FROM DUAL                 ;
			  
			dw_cond.Object.enddt[1] = ldt_enddt
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
			
			This.object.langtype.Protect = 0		
			This.Object.langtype.Background.Color = RGB(108, 147, 137)
			This.Object.langtype.Color = RGB(255, 255, 255)
			This.Object.validkey_type.Protect = 0
			This.Object.validkey_type.Background.Color =  RGB(108, 147, 137)
			This.Object.validkey_type.Color = RGB(255, 255, 255)
			
		ElseIf il_validkey_cnt = 0 Then
			This.object.langtype[1] = ""	
			This.object.langtype.Protect = 1		
			This.Object.langtype.Background.Color = RGB(255, 251, 240)
			This.Object.langtype.Color = RGB(0, 0, 0)
			This.Object.validkey_type[1] = ""
			This.object.validkey_type.Protect = 1
			This.Object.validkey_type.Background.Color = RGB(255, 251, 240)
			This.Object.validkey_type.Color = RGB(0, 0, 0)	
		End If
		
		//가격정책별 인증KEYTYPE
		li_exist = This.GetChild("validkey_type", ldc_validkey_type)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 인증KeyType")
		ls_filter = "a.priceplan = '" + data  + "'  " 
		ldc_validkey_type.SetTransObject(SQLCA)
		li_exist =ldc_validkey_type.Retrieve()
		ldc_validkey_type.SetFilter(ls_filter)			//Filter정함
		ldc_validkey_type.Filter()
	
		If li_exist < 0 Then 				
		
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If
		
		ls_reg_partner = Trim(This.object.reg_partner[1])
		ls_requestdt  = String(This.object.requestdt[1],'yyyymmdd')
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
		
		//2004-12-04 KEM 수정
		//선택한 가격정책에 해당하는 선납품목이 있는 경우
		//서비스별요율등록에 사용기간을 ADD하여 기간만료일을 생성한다.
		//2005.03.09 ohj수정
		//과금방식에 따라 기간만료일계산이 달라진다
		//월정액    = 과금시작일 + addmonth(사용가능월)
		//daily정액 = 과금시작일 + 사용가능일
		//사용가능일 addunit * valid_term		
		
		// 저장할때 BILLTODT계산
//		SELECT A.VALIDITY_TERM
//		     , NVL(B.PREBIL_YN, 'N')  AS PREBIL_YN
//			  , A.METHOD
//			  , A.ADDUNIT			  
//		  INTO :ll_validity_term
//		     , :ls_prebil_yn
//			  , :ls_method
//			  , :ll_addunit
//		  FROM PRICEPLAN_RATE2 A,
//		       ITEMMST B
//		 WHERE A.ITEMCOD = B.ITEMCOD
//		   AND A.PRICEPLAN = :data
//		   AND B.PREBIL_YN = 'Y'
//			AND TO_CHAR(A.FROMDT,'YYYYMMDD') <= :ls_requestdt
//			AND TO_CHAR(NVL(A.TODT, SYSDATE),'YYYYMMDD') >= :ls_requestdt
//			AND ROWNUM = 1;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(parent.title, "SELECT validity_term")				
//			Return 1
//		End If
//		
////		If ll_validity_term > 0 Then
////			ldt_bilfromdt = dw_cond.Object.bil_fromdt[1]
////			
////			ldt_enddt = fd_month_next(ldt_bilfromdt, ll_validity_term)
////			
////			dw_cond.Object.enddt[1] = ldt_enddt
////		End If	
//
//		dw_cond.Object.prebil_yn[1] = ls_prebil_yn
//		
//		ldt_bilfromdt = dw_cond.Object.bil_fromdt[1]  	//과금시작일
//		ll_use        = ll_addunit * ll_validity_term 	//사용가능일(월)
//		ls_bilfromdt  = string(ldt_bilfromdt, 'YYYYMMDD')
//		
//		
//		If ls_method = 'A' Then
//			
//			ldt_date_next_1 = fd_date_next(ldt_bilfromdt, ll_use)
//			
//			SELECT :ldt_date_next_1 -1 
//			  INTO :ldt_date_next
//			  FROM DUAL                 ;
//			
//			dw_cond.Object.enddt[1] = ldt_date_next
//			
//		ElseIf ls_method = 'M' Then
//			
//			SELECT ADD_MONTHS(TO_DATE(:ls_bilfromdt, 'YYYYMMDD'), :ll_use) -1
//           INTO :ldt_date_next
//			  FROM DUAL;
//			  
//     		dw_cond.Object.enddt[1] = ldt_date_next
//
//		Else
////			dw_cond.Object.enddt[1] = 
//		End If
//		
		is_priceplan = data
		
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
		is_reg_partner = data
		
	Case "sale_partner"
		If wfi_get_partner(data)  = -1 Then
			Object.sale_partnernm[1] = ""
		Else
			Object.sale_partnernm[1] = data
		End IF
		
//	Case "auth_method"
//	   ls_customer_id = Trim(This.Object.customerid[1])
//		If IsNull(ls_customer_id) Then ls_customer_id = ""
//		
//		If left(data,1) = 'S' Then
//			This.Object.ip_address.Protect = 0
//			This.Object.ip_address.Background.Color = RGB(108, 147, 137)
//			This.Object.ip_address.Color = RGB(255, 255, 255)
//		Else
//			This.object.ip_address[1] = ""
//			This.Object.ip_address.Protect = 1
//			This.Object.ip_address.Background.Color = RGB(255, 251, 240)
//			This.Object.ip_address.Color = RGB(0, 0, 0)
//		End If
//		
//		If mid(data, 7,1) = 'B'  Then
//         //2005.02.14 ohj 고객번호로 h323id구성 - 굿텔요청
//			If is_h323id[1] = 'Y' And is_h323id[2] = 'C' Then
//				If ls_customer_id = '' Then
//					f_msg_info(9000, parent.title,  "먼저 고객번호를 선택하세요.")
//					This.object.auth_method[1] = ''
//					This.setcolumn('customerid')
//					RETURN 2
//				End If
//				
//				This.object.h323id[1] = ls_customer_id
//			End If
//			
//			This.Object.h323id.Protect = 0
//			This.Object.h323id.Background.Color = RGB(108, 147, 137)
//			This.Object.h323id.Color = RGB(255, 255, 255)
//		Else
//			
//			This.object.h323id[1] = ""
//			This.Object.h323id.Protect = 1
//			This.Object.h323id.Background.Color = RGB(255, 251, 240)
//			This.Object.h323id.Color = RGB(0, 0, 0)
//		End If
//		
		
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

event dw_cond::clicked;call super::clicked;//If dwo.name = "svccod" Then
//	dw_cond.object.priceplan[1] = ""
//	dw_cond.object.prmtype[1] = ""
//End If
end event

event dw_cond::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist, li_return
Boolean lb_check
String ls_filter, ls_priceplan, ls_requestdt, ls_pricemodel
Decimal ldc_rate

Choose Case dwo.name
	Case "customerid"
		f_msg_info(9000, Title, "고객번호를 변경할 수 없습니다.")	
//		If dw_cond.iu_cust_help.ib_data[1] Then
//			 dw_cond.Object.customerid[row] = &
//			 dw_cond.iu_cust_help.is_data[1]
//			 dw_cond.object.customernm[row] = &
//			 dw_cond.iu_cust_help.is_data[2]
//			 is_cus_status = dw_cond.iu_cust_help.is_data[3]
//		End If
//		dw_cond.object.svccod.Protect = 0			

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

type p_ok from w_a_reg_m_m3`p_ok within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 2766
integer y = 140
end type

type p_close from w_a_reg_m_m3`p_close within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 2766
integer y = 276
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 41
integer y = 4
integer width = 2624
integer height = 1068
integer taborder = 20
end type

type dw_master from w_a_reg_m_m3`dw_master within b1w_reg_svc_actorder_pre_reserve_v20_moo
boolean visible = false
integer x = 23
integer y = 1080
integer width = 2670
integer height = 44
integer taborder = 50
end type

type dw_detail from w_a_reg_m_m3`dw_detail within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer y = 1688
integer width = 3045
integer height = 344
integer taborder = 30
string dataobject = "b1dw_reg_svc_actorder_ipn_pre_v20_mh"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::ue_init();call super::ue_init;ib_delete = True
ib_insert = True

////Help Window
//This.idwo_help_col[1] = This.Object.validkey
//This.is_help_win[1] = "b1w_hlp_validkeymst_2"
//This.is_data[1] = "CloseWithReturn"
end event

event dw_detail::doubleclicked;call super::doubleclicked;If row < 1 Then Return 0
String  ls_svccod
Integer li_return

This.accepttext()

//2005-07-08 khpark add start
li_return = wf_itemcod_chk()
IF li_return <= 0 Then
	return
End IF
//2005-07-08 khpark modify end

ls_svccod      = fs_snvl(dw_cond.Object.svccod[1], '')

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "인증정보수정등록"
iu_cust_msg.is_grp_name = "서비스개통신청"
iu_cust_msg.is_data[1] = "Doubleclicked"
iu_cust_msg.is_data[2] = This.object.validkey_type[row]    //인증KeyType
iu_cust_msg.is_data[3] = This.object.langtype[row]         //멘트언어
iu_cust_msg.is_data[4] = is_priceplan                      //가격정책
iu_cust_msg.is_data[5] = is_reg_partner                    //유치처
iu_cust_msg.is_data[6] = is_customerid                     //고객번호
iu_cust_msg.is_data[8] = ls_svccod          //서비스코드  언어맨트때문에 추가 0711
iu_cust_msg.is_data[9] = '1'
iu_cust_msg.ii_data[1] = ii_cnt              //발신지Location check yn ii_cnt
iu_cust_msg.il_data[1] = row                 //현재row
iu_cust_msg.idw_data[1] = dw_detail
//2005-07-08 khpark add
iu_cust_msg.is_data[7] = is_callforward_type //착신전환유형

OpenWithParm(b1w_reg_validinfo_reserve_popup_v20, iu_cust_msg)

Return 0
end event

type p_insert from w_a_reg_m_m3`p_insert within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 46
integer y = 2064
end type

type p_delete from w_a_reg_m_m3`p_delete within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 379
integer y = 2064
end type

type p_save from w_a_reg_m_m3`p_save within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 713
integer y = 2064
end type

type p_reset from w_a_reg_m_m3`p_reset within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 1463
integer y = 2064
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer x = 37
integer y = 1132
integer width = 3040
integer height = 504
integer taborder = 10
string dataobject = "b1dw_reg_svc_actorder_det_v20"
end type

event dw_detail2::constructor;call super::constructor;dw_detail2.SetRowFocusIndicator(off!)
end event

event dw_detail2::retrieveend;call super::retrieveend;Long i
String ls_mainitem_yn, ls_quota_yn

If rowcount = 0 Then
	p_save.TriggerEvent("ue_disable")
End If

For i = 1 To rowcount
	
	ls_mainitem_yn = Trim(dw_detail2.object.mainitem_yn[i])
	ls_quota_yn    = Trim(dw_detail2.object.quota_yn[i])
	
	If IsNull(ls_mainitem_yn) Or ls_mainitem_yn = "" Then ls_mainitem_yn = "N"
	If IsNull(ls_quota_yn) Or ls_quota_yn = "" Then ls_quota_yn = "N"

	If ls_mainitem_yn = "Y" And ls_quota_yn = "N" Then
		dw_detail2.object.chk[i] = ls_mainitem_yn
	ElseIf ls_mainitem_yn = "Y" And ls_quota_yn = "Y" Then
		dw_detail2.object.chk[i] = "N"
	Else
		dw_detail2.object.chk[i] = "N"
	End If
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

event dw_detail2::itemchanged;call super::itemchanged;String ls_mainitem_yn, ls_quota_yn
Long   i, ll_groupno, ll_grouptype, ll_groupno_1, ll_grouptype_1

If dwo.name = "chk" Then
	ls_mainitem_yn = Trim(This.object.mainitem_yn[row])
	ls_quota_yn    = Trim(This.object.quota_yn[row])
	ll_groupno     = This.object.groupno[row]
	ll_grouptype   = This.object.grouptype[row]
	
	If IsNull(ls_mainitem_yn) Or ls_mainitem_yn = "" Then ls_mainitem_yn = "N"
	If IsNull(ls_quota_yn) Or ls_quota_yn = "" Then ls_quota_yn = "N"
	
	//품목group이 동일할때 선택type이 0이면 한품목만 선택 가능
	If ll_grouptype = 0 Then
		If data = "Y" Then
			For i = 1 To dw_detail2.RowCount()
				If i = row Then continue
				
				ll_groupno_1    = This.object.groupno[i]
				ll_grouptype_1  = This.object.grouptype[i]
				
				If ll_groupno = ll_groupno_1  Then					
					IF ll_grouptype_1 = 0 Then
						This.object.chk[i] = "N"
					End If
				End If
				
			Next
		End If
		
	ElseIF ls_mainitem_yn = "Y" and ls_quota_yn = "Y" Then
		If data = "Y" Then
			For i = 1 To dw_detail2.RowCount()
				If i = row Then continue
				
				ls_mainitem_yn = Trim(This.object.mainitem_yn[i])
				ls_quota_yn    = Trim(This.object.quota_yn[i])
				
				If ls_mainitem_yn = "Y" And ls_quota_yn = "Y" Then
					This.object.chk[i] = "N"
				End If	
			Next
		End If
	End If		
End If


end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b1w_reg_svc_actorder_pre_reserve_v20_moo
integer y = 1084
integer height = 36
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within b1w_reg_svc_actorder_pre_reserve_v20_moo
boolean visible = false
integer y = 1644
integer height = 36
end type

