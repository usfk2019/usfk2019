$PBExportHeader$ubs_w_reg_mobileterm.srw
$PBExportComments$[jhchoi] 모바일 해지 신청 - 2009.04.22
forward
global type ubs_w_reg_mobileterm from w_a_reg_m_m
end type
type dw_detail2 from u_d_base within ubs_w_reg_mobileterm
end type
type dw_detail3 from u_d_base within ubs_w_reg_mobileterm
end type
type dw_detail4 from datawindow within ubs_w_reg_mobileterm
end type
type gb_1 from groupbox within ubs_w_reg_mobileterm
end type
type gb_2 from groupbox within ubs_w_reg_mobileterm
end type
type gb_3 from groupbox within ubs_w_reg_mobileterm
end type
type gb_4 from groupbox within ubs_w_reg_mobileterm
end type
end forward

global type ubs_w_reg_mobileterm from w_a_reg_m_m
integer width = 3625
integer height = 2136
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref string ai_return )
dw_detail2 dw_detail2
dw_detail3 dw_detail3
dw_detail4 dw_detail4
gb_1 gb_1
gb_2 gb_2
gb_3 gb_3
gb_4 gb_4
end type
global ubs_w_reg_mobileterm ubs_w_reg_mobileterm

type variables
STRING	is_active[],		is_term[],		is_termstatus[],   &
			is_suspendreq, 	is_suspend,		is_reqactive,		is_term_where, is_over_charge,	&
			is_paydt,			is_appseq
STRING	is_date_check				//해지일 Check 여부
STRING	is_date_allow_yn			// 서비스별 가격정책별 해지일 check여부
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
public subroutine of_resizepanels ()
public subroutine of_refreshbars ()
end prototypes

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_detail.GetRow()

lb_check = fb_save_required(dw_detail, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck;STRING	ls_termdt,		ls_partner,					ls_termtype,		ls_contractseq,		ls_sysdt,  			&
			ls_activedt,	ls_act_status,				ls_ref_desc,		ls_customerid,			ls_priceplan,  	&
			ls_svccod,		ls_related_contractseq,	ls_enddt,			ls_act_gu,				ls_bill_fromdt,	&
			ls_contno,		ls_phone_return
LONG		ll_row,			ll_svccnt,					ll_contractseq,	ll_cnt,					ll_contno_cnt
BOOLEAN	lb_check
INT		li_cnt

dw_detail.AcceptText()
ll_row = dw_detail.GetRow()

ll_contractseq  			= dw_detail.object.contractmst_contractseq[1]
ls_contractseq 	  		= STRING(dw_detail.object.contractmst_contractseq[1])
ls_related_contractseq 	= STRING(dw_detail.object.contractmst_related_contractseq[1])
ls_termdt    				= STRING(dw_detail.object.termdt[1],'yyyymmdd')
ls_partner 					= Trim(dw_detail.object.partner[1])
ls_termtype 				= dw_detail.object.termtype[1]
ls_sysdt 					= STRING(fdt_get_dbserver_now(),'yyyymmdd')
ls_activedt 				= STRING(dw_detail.object.contractmst_activedt[1],'yyyymmdd')
ls_customerid 				= dw_detail.object.contractmst_customerid[1]
ls_priceplan 				= dw_detail.object.contractmst_priceplan[1]
ls_svccod 					= dw_detail.object.contractmst_svccod[1]
ls_enddt						= STRING(dw_detail.object.enddt[1], 'yyyymmdd')
ls_bill_fromdt				= STRING(dw_detail.object.contractmst_bil_fromdt[1], 'yyyymmdd')
ls_act_gu					= dw_detail.object.act_gu[1]
ls_phone_return			= dw_detail.object.phone_return[1]
ls_contno					= dw_detail.object.contno[1]

//Null Check
IF IsNull(ls_partner) 				 THEN ls_partner	 			  = ""
IF IsNull(ls_termtype) 				 THEN ls_termtype 			  = ""
IF IsNull(ls_termdt) 				 THEN ls_termdt 				  = ""
IF IsNull(ls_customerid) 			 THEN ls_customerid 			  = ""
IF IsNull(ls_related_contractseq) THEN ls_related_contractseq = ""

IF ls_termdt = "" THEN
	f_msg_usr_err(200, Title, "해지요청일")
	ai_return = -1
	RETURN
END IF

IF fb_reqdt_check(Title,ls_customerid,ls_termdt,"해지요청일") THEN
ELSE
	ai_return = -1	
	RETURN
END IF

//해지 신청내역 존재 여부 check
SELECT COUNT(*)  INTO :ll_cnt
FROM   SVCORDER
WHERE  REF_CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
AND    STATUS = :is_termstatus[1]; 

IF ll_cnt > 0 THEN
	f_msg_usr_err(200, Title, "이미 해지신청을 하셨습니다.")	
	ai_return = -1
	RETURN
END IF

//관계된 계약이 있는지 확인...
IF ls_related_contractseq <> "" THEN	
	SELECT COUNT(*) INTO :li_cnt 
   FROM   SVC_RELATION
   WHERE  PRE_PRICEPLAN = :ls_priceplan;

   IF li_cnt > 0 THEN
		SELECT COUNT(*) INTO :li_cnt
		FROM   SVCORDER
		WHERE  (STATUS = '70' OR STATUS = '99') 
	   AND    REF_CONTRACTSEQ = (SELECT CONTRACTSEQ FROM CONTRACTMST
		                          WHERE  RELATED_CONTRACTSEQ = :ls_contractseq);
		IF li_cnt = 0 THEN
			f_msg_usr_err(1200, Title, " Check Service Relation")
			ROLLBACK;
			ai_return = -1	
			RETURN
	    END IF
	END IF
END IF

IF ls_termdt <> "" THEN
	lb_check = fb_chk_stringdate(ls_termdt)
	IF NOT lb_check THEN
		f_msg_usr_err(210, Title, "'해지일자의 날짜 포맷 오류입니다.")
		ai_return = -1			
		RETURN
	END IF
	
	//개통일 check 여부 
	IF b1fi_date_allow_chk_yn_v20(THIS.title, ls_svccod, ls_priceplan, is_date_allow_yn) < 0 THEN
		ai_return = -1					
		RETURN
	END IF
	
	IF is_date_check = 'Y' THEN
		IF is_date_allow_yn = 'N' THEN          //2005-12-23 khpark add
			IF ls_termdt < ls_sysdt THEN
				f_msg_usr_err(210, Title, "해지요청일은 오늘보다 커야합니다.")
				ai_return = -1
				RETURN
			END IF
		END IF
	END IF
	
	IF ls_termdt < ls_activedt THEN
		f_msg_usr_err(210, Title, "'해지요청일은 개통일보다 같거나 커야 합니다.")
		ai_return = -1			
		RETURN
	END IF
	
	//개통상태코드
	ls_act_status = fs_get_control("B0","P223", ls_ref_desc)

	//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 변경요청일이 커야한다.
	SELECT COUNT(VALIDKEY) INTO :ll_svccnt
	FROM   VALIDINFO
	WHERE  TO_CHAR(FROMDT, 'YYYYMMDD') > :ls_termdt
	AND    CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
	AND    STATUS = :ls_act_status;
	   
	IF SQLCA.SQLCode < 0 THEN
		f_msg_sql_err(title, " Select count Error(validinfo)")
		ai_return = -1
		RETURN
	END IF
	
	IF ll_svccnt > 0 THEN
		f_msg_usr_err(210, Title, "해지요청일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
		ai_return = -1
		RETURN
	END IF
	
END IF

IF ls_termtype = "" THEN
	f_msg_usr_err(200, Title, "REASON")
	ai_return = -1
	RETURN
END IF

IF ls_partner = "" THEN
	f_msg_usr_err(200, Title, "SHOP")
	ai_return = -1
	RETURN
END IF

IF ls_act_gu = 'Y' THEN
	IF ls_enddt = "" OR Isnull(ls_enddt) THEN
		f_msg_usr_err(200, Title, "Bill End")
		ai_return = -1
		RETURN
	ELSE
		IF ls_enddt <= ls_bill_fromdt THEN
			f_msg_usr_err(200, Title, "Bill End ")
			ai_return = -1			
			RETURN			
		END IF			
	END IF
END IF	

//폰 CONTNO가 틀리는지 맞는지 확인
IF ls_phone_return = "Y" THEN
	SELECT COUNT(*) INTO :ll_contno_cnt
	FROM   AD_MOBILE_RENTAL
	WHERE  CONTNO      = :ls_contno
	AND    CUSTOMERID  = :ls_customerid
	AND    CONTRACTSEQ = :ll_contractseq;
	
	IF ll_contno_cnt <= 0 THEN
		f_msg_usr_err(200, Title, "Phone Contno Error!")
		ai_return = -1		
		RETURN
	END IF
END IF


ai_return = 0

RETURN
end event

event ue_process;STRING	ls_customerid,		ls_customernm,		ls_check,		ls_code[],		&
			ls_phone_itemcd,  ls_phone_return,	ls_sysdt,		ls_lease_todt, &
			ls_lease_itemcd,	ls_out_item,		ls_termdt,		ls_phone_type
LONG		ll_row,				ll_row4,				ll_cnt = 0,		ll_item_cnt = 0,	&
			ll_day_cnt,			ll_contractseq
INTEGER	ii,					jj
DEC		ldc_amount[],		ldc_return_amt,	ldc_bill_amt,	ldc_payamt

ll_row  = dw_master.GetSelectedrow(0)
ll_row4 = dw_detail4.RowCount()

ll_contractseq  = dw_master.Object.contractmst_contractseq[ll_row]
ls_customerid   = dw_master.Object.customerm_customerid[ll_row]
ls_customernm 	 = dw_master.Object.customerm_customernm[ll_row]
ls_phone_return = dw_detail.Object.phone_return[1]
ls_termdt		 = STRING(dw_detail.Object.termdt[1], 'YYYYMMDD')
ls_sysdt			 = String(Date(fdt_get_dbserver_now()), 'yyyymmdd')
//계약기간...contractdet에 있음
ls_lease_todt	 = STRING(DATE(dw_detail2.Object.contractdet_bil_todt[1]), 'YYYYMMDD')

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Payment_Refund"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.idw_data[2] = dw_detail4
iu_cust_msg.is_data[2]  = ls_customerid
iu_cust_msg.is_data[3]  = ls_customernm
iu_cust_msg.is_data[4]  = ""
iu_cust_msg.is_data[5]  = "N"						//수납 여부

//품목넘김
// 미반납일 경우. 품목코드와, 수납해야할 금액을 가져온다!
//IF ls_phone_return = 'N' THEN 
//	SELECT ITEMCOD	 INTO :ls_phone_itemcd
//	FROM   CONTRACTDET
//	WHERE  CONTRACTSEQ = :ll_contractseq
//	AND	 ITEMCOD IN ( SELECT ITEMCOD FROM ITEMMST_MOBILE WHERE RETURN_AMT IS NOT NULL AND PERIOD_YN = 'N' );
//	
//	IF SQLCA.SQLCODE < 0 THEN
//		f_msg_usr_err(200, Title, "Select Error! CONTRACTDET")
//		ai_return = 'X'
//		RETURN
//	END IF
//	
//	SELECT RETURN_AMT INTO :ldc_return_amt
//	FROM   ITEMMST_MOBILE
//	WHERE  ITEMCOD = :ls_phone_itemcd;
//	
//	IF SQLCA.SQLCODE < 0 THEN
//		f_msg_usr_err(200, Title, "Select Error! ITEMMST_MOBILE")
//		ai_return = 'X'
//		RETURN
//	END IF
//	ll_item_cnt++	
//	iu_cust_msg.is_data2[ll_item_cnt] = ls_phone_itemcd  		//itemcod
//	iu_cust_msg.ic_data[ll_item_cnt]  = ldc_return_amt	  		//sale_amt
//END IF

// 계약기간과 현재 날짜를 비교한다...
IF ls_lease_todt < ls_termdt THEN
	//품목코드 구하기
	SELECT ITEMCOD	 INTO :ls_lease_itemcd
	FROM   CONTRACTDET
	WHERE  CONTRACTSEQ = :ll_contractseq
	AND    ITEMCOD IN ( SELECT ITEMCOD FROM ITEMMST_MOBILE WHERE BILL_AMT IS NOT NULL AND PERIOD_YN = 'Y' );

	IF SQLCA.SQLCODE < 0 THEN
		f_msg_usr_err(200, Title, "Select Error! CONTRACTDET")
		ai_return = 'X'
		RETURN
	END IF
	//JHCHOI 2010.01.07 수정 렌탈 초과기간 요금은 하루에 2$로 고정. 금액 세팅할 수 있도록 요청함.
	//SYSCTL1T MODULE = 'U1', REF_NO = 'A400'
	////폰 타입 가져오기. 초과기간 구하기 위해서는 필수임. 
	//SELECT PHONE_TYPE INTO :ls_phone_type
	//FROM   AD_MOBILE_RENTAL
	//WHERE  CONTRACTSEQ = :ll_contractseq;
	
	////초과일수 구하기
	//SELECT TO_DATE(:ls_termdt, 'yyyymmdd') - TO_DATE(:ls_lease_todt, 'yyyymmdd') INTO :ll_day_cnt
	//FROM   DUAL;
	
	////초과금액 구하기
	//SELECT ROUND((BILL_AMT / EXTDAYS) * :ll_day_cnt, 2)  INTO :ldc_bill_amt
	//FROM   ITEMMST_MOBILE
	//WHERE  ITEMCOD = :ls_lease_itemcd
	//AND    PHONE_TYPE = :ls_phone_type;
	
	//초과일수 구하기
	SELECT TO_DATE(:ls_termdt, 'yyyymmdd') - TO_DATE(:ls_lease_todt, 'yyyymmdd') INTO :ll_day_cnt
	FROM   DUAL;	
	
	IF SQLCA.SQLCODE < 0 THEN
		f_msg_usr_err(200, Title, "Select Error! ITEMMST_MOBILE")
		ai_return = 'X'
		RETURN
	END IF	
	
	//초과금액 구하기
	ldc_bill_amt = Round(ll_day_cnt * Dec(is_over_charge), 2)

	ll_item_cnt++	
	iu_cust_msg.is_data2[ll_item_cnt] = ls_lease_itemcd  		//itemcod
	iu_cust_msg.ic_data[ll_item_cnt]  = ldc_bill_amt	  		//sale_amt
END IF	

//디파짓 비용 ...  -금액!   반납인 경우에만 디파짓을 돌려준다.  --2009.06.26 김소연 주임과 협의
IF ls_phone_return = 'Y' THEN 
	IF ll_row4 > 0 THEN
	//	SELECT MAX(OUT_ITEM)  INTO :ls_out_item
	//	FROM   DEPOSIT_REFUND
	//	WHERE  IN_ITEM = ( SELECT ITEMCOD FROM DAILYPAYMENT 
	//   	                WHERE  CUSTOMERID = :ls_customerid
	//							 AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND )
	//							 GROUP BY ITEMCOD);
								 
		SELECT MAX(OUT_ITEM)  INTO :ls_out_item
		FROM   DEPOSIT_REFUND
		WHERE  IN_ITEM = ( SELECT ITEMCOD FROM MOBILE_DEPOSIT
								 WHERE  CUSTOMERID = :ls_customerid
								 AND    CONTRACTSEQ = :ll_contractseq
								 AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND )
								 GROUP BY ITEMCOD);							 
	
		IF SQLCA.SQLCODE < 0 THEN
			f_msg_usr_err(200, Title, "Select Error! DEPOSIT_REFUND")
			ai_return = 'X'
			RETURN
		END IF
		
		SELECT SUM(PAYAMT) INTO :ldc_payamt
		FROM   MOBILE_DEPOSIT
		WHERE  CUSTOMERID = :ls_customerid
		AND    CONTRACTSEQ = :ll_contractseq
		AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND );	
		
		IF SQLCA.SQLCODE < 0 THEN
			f_msg_usr_err(200, Title, "Select Error! DAILYPAYMENT")
			ai_return = 'X'
			RETURN
		END IF	
		ll_item_cnt++		
		iu_cust_msg.is_data2[ll_item_cnt] = ls_out_item  		//itemcod
		iu_cust_msg.ic_data[ll_item_cnt]  = -ldc_payamt	  		//sale_amt
	END IF	
END IF

iu_cust_msg.il_data[2]  = ll_item_cnt			//item 갯수

IF ll_item_cnt > 0 THEN
	//수납을 위한 팝업 연결
	OpenWithParm(ubs_w_pop_mobilepayment, iu_cust_msg)

	//수납 팝업에서 반환되는 값. 완료:'Y', 미완료:'N'
	IF iu_cust_msg.ib_data[1] THEN
		ai_return = iu_cust_msg.is_data[1]
		is_paydt  = iu_cust_msg.is_data[2]
		is_appseq = iu_cust_msg.is_data[3]		
	END IF
ELSE
	ai_return = 'Y'
END IF	

DESTROY iu_cust_msg

RETURN
end event

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
Else
	dw_detail.object.partnernm[1] = as_partner
End If

Return 0
end function

public function integer wfi_get_customerid (string as_customerid);String ls_customernm, ls_memberid

Select customernm, memberid	Into :ls_customernm, :ls_memberid	From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.name[1] = ""
	Return -1
Else
	dw_cond.object.name[1] 		= as_customerid
	dw_cond.object.memberid[1] = ls_memberid
End If

Return 0
end function

public subroutine of_resizepanels ();//// Resize the panels according to the Vertical Line, Horizontal Line,
//// BarThickness, and WindowBorder.
//
//// Validate the controls.
//If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
//
//// Top processing
//idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
//idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)
//
////// Bottom Procesing
//dw_detail2.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//dw_detail2.Resize(idrg_Top.Width / 2 - 200, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)
//
//// Bottom Procesing
//idrg_Bottom.Move(cii_WindowBorder + dw_detail2.Width + 40, st_horizontal.Y + cii_BarThickness)
//idrg_Bottom.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height / 2 + 50)
//
//// Bottom Procesing
//dw_detail3.Move(cii_WindowBorder + dw_detail2.Width + 40, idrg_Bottom.Y + idrg_Bottom.Height + 40)
//dw_detail3.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height - idrg_Bottom.Height - 40)
//

// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
//idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//idrg_Bottom.Resize(idrg_Bottom.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')



end subroutine

public subroutine of_refreshbars ();dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')


end subroutine

on ubs_w_reg_mobileterm.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_detail3=create dw_detail3
this.dw_detail4=create dw_detail4
this.gb_1=create gb_1
this.gb_2=create gb_2
this.gb_3=create gb_3
this.gb_4=create gb_4
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_detail3
this.Control[iCurrent+3]=this.dw_detail4
this.Control[iCurrent+4]=this.gb_1
this.Control[iCurrent+5]=this.gb_2
this.Control[iCurrent+6]=this.gb_3
this.Control[iCurrent+7]=this.gb_4
end on

on ubs_w_reg_mobileterm.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_detail3)
destroy(this.dw_detail4)
destroy(this.gb_1)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.gb_4)
end on

event open;call super::open;//=========================================================//
// Desciption : 모바일 해지 신청		                 		  //
// Name       : ubs_w_reg_mobileterm							  //
// Contents   : 모바일 해지를 신청한다.	 					  //
// Data Window: dw - ubs_dw_reg_mobileterm_cond				  // 
//							ubs_dw_reg_mobileterm_mas  			  //
//							ubs_dw_reg_mobileterm_det			  	  //
//							ubs_dw_reg_mobileterm_det2	  			  //
//							ubs_dw_reg_mobileterm_det3				  //
//							ubs_dw_reg_mobileterm_det4  			  //
// 작성일자   : 2009.04.22                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,		ls_status
INT		li_i

is_suspendreq = ""

//해지신청 가능한 상태
ls_ref_desc =""
ls_status = fs_get_control("B0", "P224", ls_ref_desc)
fi_cut_string(ls_status, ";", is_term[])

//해지신청상태코드
ls_ref_desc = ""
ls_status = fs_get_control("B0","P221", ls_ref_desc)
fi_cut_string(ls_status, ";" , is_termstatus[])

//무조건 해지신청 가능한 것만 select하므로... 계속 쓰인다..
is_term_where = ""
FOR li_i = 1 TO UpperBound(is_term[])
	IF is_term_where <> ""  THEN is_term_where += ", "
	is_term_where += "'" + is_term[li_i] + "'"
NEXT

//해지일 Check 여부
ls_ref_desc = ""
is_date_check = fs_get_control("B0", "P210", ls_ref_desc)

//JHCHOI 2010.01.07 렌탈폰 초과금액 세팅
ls_ref_desc = ""
is_over_charge = fs_get_control("U1", "A400", ls_ref_desc)

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')

end event

event ue_ok();call super::ue_ok;//조회.
STRING	ls_customerid,		ls_contractseq,		ls_svccod,		ls_priceplan,		ls_contractno, &
			ls_memberid,		ls_where,				ls_validkey
LONG		ll_row

ls_memberid 	= Trim(dw_cond.object.memberid[1])
ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_contractno 	= Trim(dw_cond.object.contractno[1])
ls_validkey 	= Trim(dw_cond.object.validkey[1])

IF IsNull(ls_memberid) 		THEN ls_memberid 		= ""
IF IsNull(ls_customerid) 	THEN ls_customerid 	= ""
IF IsNull(ls_contractseq) 	THEN ls_contractseq 	= ""
IF IsNull(ls_contractno) 	THEN ls_contractno 	= ""
IF IsNull(ls_validkey) 		THEN ls_validkey 		= ""

ls_where  = ""
//해지신청 가능한 고객만 조회시킨다.
ls_where += " CNT.STATUS IN (" + is_term_where + ") "
//모바일 계약만 조회시킨다.
IF ls_where <> "" THEN ls_where += " AND "

ls_where += " CNT.PRICEPLAN IN ( SELECT PRICEPLAN FROM AD_MOBILE_TYPE ) "

IF ls_memberid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "CUS.MEMBERID = '" + ls_memberid + "' "
END IF

IF ls_customerid <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "CUS.CUSTOMERID = '" + ls_customerid + "' "
END IF

IF ls_contractseq <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "CNT.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
END IF

IF ls_contractno <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "CNT.CONTRACTNO LIKE '" + ls_contractno + "%' "
END IF

IF ls_validkey <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CNT.CONTRACTSEQ IN (SELECT DISTINCT CONTRACTSEQ FROM VALIDINFO WHERE VALIDKEY = '" + ls_validkey+ "') "
END IF

dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()

IF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
ELSEIF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
END IF




end event

event ue_extra_save;INTEGER	li_cnt
STRING	ls_contractseq,		ls_req,					ls_remark,			&
			ls_errmsg,				ls_suspend_type,		ls_termtype,		&
			ls_admst_status,		ls_customerid,			ls_phone_return,	&
			ls_ref_desc,			ls_contno,				ls_action,			&
			ls_return,				ls_action_last
DATETIME	ld_requestdt,			ld_enddt
LONG		ll_row,					ll_return,				ll_orderno

dw_detail.AcceptText()
//ll_row = dw_detail.GetRow()

ls_contractseq  = STRING(dw_detail.object.contractmst_contractseq[1])
ls_customerid   = dw_detail.object.contractmst_customerid[1]
ld_requestdt	 = dw_detail.Object.termdt[1]
ld_enddt			 = dw_detail.Object.enddt[1]
ls_req			 = dw_detail.Object.act_gu[1]
ls_remark		 = dw_detail.Object.remark[1]
ls_termtype		 = dw_detail.Object.termtype[1]
ls_phone_return = dw_detail.Object.phone_return[1] 
ls_contno		 = dw_detail.Object.contno[1] 

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
SELECT ref_content INTO :ls_action FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A103';

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 반품 )
SELECT ref_content INTO :ls_return FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A105';

//폰 상태 변경.
IF ls_phone_return = "Y" THEN
	ls_admst_status = fs_get_control("E1", "A104", ls_ref_desc)
	ls_action_last = ls_return
	
	UPDATE AD_MOBILE_RENTAL
	SET    CUSTOMERID  = NULL,
			 CONTRACTSEQ = NULL,
			 VALIDKEY	 = NULL,
			 CARD_CONTNO = NULL,
			 SHOPID		 = :gs_shopid,
			 STATUS	    = :ls_admst_status,
			 updt_user   = :gs_user_id,
			 updtdt 	    = sysdate,
			 pgm_id 	    = :gs_pgm_id[gi_open_win_no]
	WHERE  CONTNO = :ls_contno;
ELSE
	ls_admst_status = fs_get_control("E1", "A103", ls_ref_desc)
	ls_action_last = ls_action
	//미반납일 경우 컨트롤 넘버 찾아서 판매로 변경함.
	SELECT CONTNO INTO :ls_contno
	FROM   AD_MOBILE_RENTAL
	WHERE  CUSTOMERID  = :ls_customerid
	AND    CONTRACTSEQ = TO_NUMBER(:ls_contractseq);
	
	IF IsNull(ls_contno) THEN ls_contno = ""
	
	UPDATE AD_MOBILE_RENTAL
	SET    STATUS	    = :ls_admst_status,
			 updt_user   = :gs_user_id,
			 updtdt 	    = sysdate,
			 pgm_id 	    = :gs_pgm_id[gi_open_win_no]
	WHERE  CONTNO = :ls_contno;	
	
END IF

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'AD_MOBILE_RENTAL : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
End If

//장비이력(LEASELOG_NEW) Table에 정보저장 - 반품
INSERT INTO LEASELOG_NEW		
	( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
	  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
	  RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
	  PGM_ID, IDATE )
SELECT SEQ, seq_admstlog.nextval, :ls_action_last, SYSDATE, FR_SHOP, MV_SHOP, CONTNO, STATUS,
		 LEASEDT, SHOPID, 1, 0, 0, PHONE_MODEL, CUSTOMERID, CONTRACTSEQ,
		 TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'), NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
		 :gs_pgm_id[gi_open_win_no], ISEQ
FROM   AD_MOBILE_RENTAL
WHERE  CONTNO = :ls_contno;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'LEASELOG_NEW(RETURN) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
End If	

IF ls_req = 'Y' THEN
	ls_req = 'req-prc'
ELSE
	ls_req = 'req'
END IF

//저장 프로시저 실행!
ls_errmsg  = space(1000)
ll_return  = 0
ll_orderno = 0
SQLCA.UBS_REG_TERMORDER( ls_contractseq,	ll_orderno,		DATE(ld_requestdt),		DATE(ld_enddt),		ls_req,			&
								 ls_termtype,		gs_shopid,		ls_remark,  				gs_user_id,				gs_pgm_id[gi_open_win_no],	&
								 ll_return,			ls_errmsg )
									
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_TERMORDER ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_TERMORDER ' + ls_errmsg,Exclamation!,OK!)
	RETURN -1
END IF	

UPDATE DAILYPAYMENT
SET    CONTRACTSEQ = TO_NUMBER(:ls_contractseq),
		 ORDERNO     = :ll_orderno
WHERE  CUSTOMERID = :ls_customerid
AND    PAYDT = TO_DATE(:is_paydt, 'YYYYMMDD')
AND    APPROVALNO = :is_appseq;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'DAILYPAYMENT(update) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
End If			 

INSERT INTO DEPOSIT_LOG
	( PAYSEQ, PAY_TYPE, PAYDT, SHOPID, OPERATOR,
	  CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
	  PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
	  TRDT, MARK, AUTO_CHK, APPROVALNO, CRTDT,
	  CRT_USER, DCTYPE, MANUAL_YN, PGM_ID, REMARK2,
	  ORDERNO )
SELECT PAYSEQ, 'O', PAYDT, SHOPID, OPERATOR,
		 CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
		 PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
		 TRDT, MARK, AUTO_CHK, APPROVALNO, SYSDATE,
		 :gs_user_id, DCTYPE, MANUAL_YN, 'LEASTERM', REMARK2,
		 ORDERNO
FROM   DAILYPAYMENT
WHERE  CUSTOMERID = :ls_customerid
AND    PAYDT      = TO_DATE(:is_paydt, 'YYYYMMDD')
AND    ITEMCOD IN ( SELECT OUT_ITEM FROM DEPOSIT_REFUND )
AND    APPROVALNO = :is_appseq;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'DEPOSIT_LOG : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
End If		

Return 0

end event

event ue_save;//조회.
STRING	ls_customerid,		ls_contractseq,		ls_contractno,		ls_validkey,	ls_amt_check

CONSTANT	INT LI_ERROR = -1
INTEGER	li_rc
IF dw_detail.AcceptText() < 0 THEN
	dw_detail.SetFocus()
	RETURN LI_ERROR	
END IF

// Ue_inputValidCheck  호출
THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

THIS.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

//Ue_process 호출  ( 수납팝업 )
THIS.TRIGGER EVENT ue_process(ls_amt_check)

IF ls_amt_check <> 'Y' THEN	
	IF ls_amt_check = 'X' THEN
		RETURN LI_ERROR
	ELSE
		f_msg_usr_err(200, Title, "'수납을 하셔야 해지신청 됩니다.")
		RETURN LI_ERROR
	END IF
END IF

li_rc = THIS.TRIGGER EVENT ue_extra_save()
//-2 return 시 rollback되도록 변경 
//원인: 모든 신청메뉴에서 error에 대한 return값을 개념없이 rollback없는 -2값 사용에 대한 조치
IF li_rc = -1 OR li_rc = -2 THEN
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = THIS.Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_detail.SetFocus()
		RETURN LI_ERROR
	END IF
	f_msg_info(3010,THIS.Title,"해지 신청")
	RETURN LI_ERROR
ELSEIF li_rc = 0 THEN
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = THIS.Title

	iu_cust_db_app.uf_prc_db()

	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_detail.SetFocus()
		RETURN LI_ERROR
	END IF
	f_msg_info(3000,THIS.Title,"해지 신청")

END IF

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//재조회 처리
ls_customerid	= Trim(dw_cond.object.customerid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_contractno	= Trim(dw_cond.object.contractno[1])
ls_validkey 	= Trim(dw_cond.object.validkey[1])

TRIGGER EVENT ue_reset()
dw_cond.object.customerid[1]	= ls_customerid
dw_cond.object.contractseq[1] = ls_contractseq
dw_cond.object.contractno[1]	= ls_contractno 
dw_cond.object.validkey[1]		= ls_validkey
TRIGGER EVENT ue_ok()

RETURN 0
end event

event type integer ue_reset();call super::ue_reset;dw_detail2.Reset()
dw_detail3.Reset()
dw_detail4.Reset()


return 0
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
LONG		ll_3,		ll_w_2,		ll_grsize,		ll_dwsize,		ll_wgrsize,		ll_w

ll_grsize  = 4    //그룹박스간 사이 간격!
ll_dwsize  = 64   //그룹박스와 dw사이 간격!
ll_wgrsize = 30	//좌우 그룹박스 간 간격!

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
	gb_1.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	
	ll_3 					= round((newheight - gb_4.Y - gb_4.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 3, 1)
	dw_detail.Height	= newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space - 25
	gb_1.Height			= newheight - gb_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
	
	gb_2.Height			= gb_2.Height + ll_3
	dw_detail2.Height = dw_detail2.Height + ll_3
	
	gb_3.y				= gb_2.y + gb_2.Height + ll_grsize
	dw_detail3.y		= gb_3.y + ll_dwsize
	gb_3.Height 		= gb_3.Height + ll_3	
	dw_detail3.Height = dw_detail3.Height + ll_3	
	
	gb_4.y 				= gb_3.y + gb_3.Height + ll_grsize
	dw_detail4.y 		= gb_4.y + ll_dwsize
	gb_4.Height 		= gb_4.Height + ll_3	
	dw_detail4.Height = dw_detail4.Height + ll_3
	
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
End If

If newwidth < dw_detail2.X  Then
	dw_detail.Width = 0
	gb_1.Width = 0
Else
	ll_w = newwidth - gb_1.x - gb_1.width - iu_cust_w_resize.ii_dw_button_space
	
	gb_2.Width			= gb_2.Width + ll_w
	dw_detail2.Width  = dw_detail2.Width + ll_w
	
	gb_3.Width			= gb_3.Width + ll_w
	dw_detail3.Width  = dw_detail3.Width + ll_w
	
	gb_4.Width			= gb_4.Width + ll_w
	dw_detail4.Width  = dw_detail4.Width + ll_w
	
	gb_1.x				= gb_2.x + gb_2.Width + ll_wgrsize
	dw_detail.x		   = gb_1.x + (ll_dwsize / 2)	
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_mobileterm
integer y = 40
integer width = 2395
integer height = 184
string dataobject = "ubs_dw_reg_mobileterm_cond"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();//고객
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"


end event

event dw_cond::doubleclicked;call super::doubleclicked;If dwo.name = "customerid" Then
	If dw_cond.iu_cust_help.ib_data[1] Then
			 THIS.Object.customerid[row] 	= iu_cust_help.is_data[1]
			 THIS.Object.name[row] 			= iu_cust_help.is_data[2]
			 THIS.Object.memberid[1] 		= iu_cust_help.is_data[4]	 
	End If
End if
end event

event dw_cond::itemchanged;////ohj 주석처리 ..
String ls_customernm, ls_customerid, ls_memberid

choose case dwo.name
	case 'customerid'
		Select customernm, customerid, memberid	
		  Into :ls_customernm, :ls_customerid, :ls_memberid	
		  From customerm
		 Where customerid = :data;
			If SQLCA.SQLCODE = 100 Then
				dw_cond.object.name[1] 			= ""
				dw_cond.object.customerid[1] 	= ""
				dw_cond.object.memberid[1] 	= ""
				Return 2
			Else
				dw_cond.object.name[1] 			= ls_customernm
				dw_cond.object.customerid[1] 	= ls_customerid
				dw_cond.object.memberid[1] 	= ls_memberid
				Return 0
			End If
	case 'memberid'
		Select customernm, customerid, memberid	
		  Into :ls_customernm, :ls_customerid, :ls_memberid	
		  From customerm
		 Where memberid = :data;
			If SQLCA.SQLCODE = 100 Then
				dw_cond.object.name[1] 			= ""
				dw_cond.object.customerid[1] 	= ""
				dw_cond.object.memberid[1] 	= ""
				Return 2
			Else
				dw_cond.object.name[1] 			= ls_customernm
				dw_cond.object.customerid[1] 	= ls_customerid
				dw_cond.object.memberid[1] 	= ls_memberid
				Return 0
			End If
end choose
end event

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_mobileterm
integer x = 3241
integer y = 88
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_mobileterm
integer x = 681
integer y = 1900
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_mobileterm
integer width = 3529
integer height = 240
integer taborder = 0
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_mobileterm
integer x = 27
integer y = 252
integer width = 3534
integer height = 592
integer taborder = 40
string dataobject = "ubs_dw_reg_mobileterm_mas"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::clicked;call super::clicked;Long ll_selected_row,ll_old_selected_row
Int li_rc

ll_old_selected_row = This.GetSelectedRow(0)

//Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_selected_row > 0 Then
	Else
		dw_detail2.Reset()
		dw_detail3.Reset()		
		dw_detail4.Reset()				
	End If
End If

end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_mobileterm
integer x = 2181
integer y = 940
integer width = 1353
integer height = 904
integer taborder = 50
string dataobject = "ubs_dw_reg_mobileterm_det"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event type integer dw_detail::ue_retrieve(long al_select_row);//조회
STRING	ls_contractseq,	ls_where, 		ls_type,			ls_ref_desc,   &
			ls_svccod, 			ls_svctype, 	ls_priceplan
LONG		ll_row,				ll_cnt

THIS.setredraw(FALSE)

IF al_select_row = 0 THEN RETURN 0
ls_contractseq = STRING(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " CONTRACTMST.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

//setting
dw_detail.object.partner[1]	= gs_shopid
dw_detail.object.partnernm[1]	= gs_shopid
dw_detail.object.termdt[1] 	= fdt_get_dbserver_now()

dw_detail.SetItemStatus(1, 0 , Primary!,NotModified!)

IF dw_detail2.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

IF dw_detail3.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

IF dw_detail4.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

//비과금 후불제 서비스 type
ls_type = fs_get_control("B0", "P103", ls_ref_desc)

ls_svccod 	 = Trim(dw_detail.object.contractmst_svccod[1])
ls_priceplan = Trim(dw_detail.object.contractmst_priceplan[1])

SELECT SVCTYPE
  INTO :ls_svctype
  FROM SVCMST
 WHERE SVCCOD = :ls_svccod;

IF SQLCA.SQLCode <> 0 THEN
	f_msg_usr_err(2100, Title, "SVCMST Retrieve()")
	RETURN -2
END IF

IF ls_svctype = ls_type THEN
	dw_detail.object.act_gu.Protect = 1
ELSE
	dw_detail.object.act_gu.Protect = 0
END IF

//만약 계약 내용이 인증용서비스이면 "해지신청 확정" visible을 uncheck
SELECT COUNT(*) INTO :ll_cnt
FROM   PRICEPLAN_EQUIP
WHERE  PRICEPLAN = :ls_priceplan;

IF ll_cnt > 0 THEN
	dw_detail.object.act_gu.visible = 0	
ELSE
	dw_detail.object.act_gu.visible = 1	
END IF

THIS.setredraw(TRUE)

RETURN 0

end event

event dw_detail::doubleclicked;call super::doubleclicked;//If dwo.name = "partner" Then
//	If dw_detail.iu_cust_help.ib_data[1] Then
//			 dw_detail.Object.partner[row] = &
//			 dw_detail.iu_cust_help.is_data[1]
//			 dw_detail.Object.partnernm[row] = &
//			 dw_detail.iu_cust_help.is_data[1]
//	End If
//End If
end event

event dw_detail::itemchanged;call super::itemchanged;STRING	ls_customerid
LONG		ll_cnt, 			ll_contractseq,		ll_row

ll_row = dw_master.GetRow()

ls_customerid  = THIS.Object.contractmst_customerid[1]
ll_contractseq = THIS.Object.contractmst_contractseq[1]

IF dwo.name = "contno" THEN	
	SELECT COUNT(*) INTO :ll_cnt
	FROM   AD_MOBILE_RENTAL
	WHERE  CONTNO = :data
	AND    CUSTOMERID = :ls_customerid
	AND    CONTRACTSEQ = :ll_contractseq;
	
	IF ll_cnt <= 0 THEN
		THIS.Object.contno[row] = ""
		RETURN 2
	END IF
END IF
end event

event dw_detail::buttonclicked;call super::buttonclicked;////Butonn Click
//iu_cust_msg = Create u_cust_a_msg
//iu_cust_msg.is_pgm_name = "상세품목조회"
//iu_cust_msg.is_grp_name = "서비스 일시정지 신청"
//iu_cust_msg.is_data[1] = Trim(String(This.object.contractmst_contractseq[row]))
//		
//OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
//
//Return 0 

end event

event dw_detail::ue_init();call super::ue_init;//수행처
//dw_detail.idwo_help_col[1] = This.Object.partner
//dw_detail.is_help_win[1] = "b1w_hlp_partner_1"
//dw_detail.is_data[1] = "CloseWithReturn"
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_mobileterm
boolean visible = false
integer y = 1816
end type

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_mobileterm
boolean visible = false
integer y = 1816
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_mobileterm
integer x = 59
integer y = 1900
end type

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_mobileterm
integer x = 370
integer y = 1900
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_mobileterm
boolean visible = false
integer y = 844
end type

type dw_detail2 from u_d_base within ubs_w_reg_mobileterm
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 940
integer width = 2071
integer height = 244
integer taborder = 20
boolean bringtotop = true
string dataobject = "ubs_dw_reg_mobileterm_det2"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
LONG	ll_row, ll_contractseq

THIS.SetRedraw(FALSE)

IF al_select_row = 0 THEN RETURN 0

ll_contractseq = dw_master.object.contractmst_contractseq[al_select_row]

ll_row = dw_detail2.Retrieve(ll_contractseq)

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

RETURN 0 
end event

type dw_detail3 from u_d_base within ubs_w_reg_mobileterm
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 1268
integer width = 2071
integer height = 244
integer taborder = 30
boolean bringtotop = true
string dataobject = "ubs_dw_reg_mobileterm_det3"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
STRING	ls_contractseq,		ls_where
LONG		ll_row

THIS.SetRedraw(FALSE)

IF al_select_row = 0 THEN RETURN 0
ls_contractseq = STRING(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " VALIDINFO.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "

dw_detail3.is_where = ls_where
ll_row = dw_detail3.Retrieve()

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

IF dw_detail3.rowcount() > 0 THEN
	dw_detail3.visible = TRUE
ELSE
	dw_detail3.visible = FALSE
END IF

RETURN 0
end event

type dw_detail4 from datawindow within ubs_w_reg_mobileterm
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 1600
integer width = 2071
integer height = 244
integer taborder = 70
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_mobileterm_det4_1"
boolean hscrollbar = true
boolean vscrollbar = true
boolean hsplitscroll = true
boolean livescroll = true
end type

event ue_retrieve;//조회
LONG		ll_row,			ll_contractseq
STRING	ls_customerid

THIS.SetRedraw(FALSE)

IF al_select_row = 0 THEN RETURN 0

ls_customerid  = dw_master.Object.customerm_customerid[al_select_row]
ll_contractseq = dw_master.Object.contractmst_contractseq[al_select_row]

ll_row = dw_detail4.Retrieve(ls_customerid, ll_contractseq)

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Deposit Info Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

RETURN 0 
end event

event constructor;SetTransObject(SQLCA)
end event

type gb_1 from groupbox within ubs_w_reg_mobileterm
integer x = 2153
integer y = 876
integer width = 1413
integer height = 988
integer taborder = 50
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Termination Request"
end type

type gb_2 from groupbox within ubs_w_reg_mobileterm
integer x = 23
integer y = 876
integer width = 2112
integer height = 324
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Contract Detail"
end type

type gb_3 from groupbox within ubs_w_reg_mobileterm
integer x = 23
integer y = 1204
integer width = 2112
integer height = 328
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Telephone Number Info"
end type

type gb_4 from groupbox within ubs_w_reg_mobileterm
integer x = 23
integer y = 1536
integer width = 2112
integer height = 328
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Deposit Info"
end type

