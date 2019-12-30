$PBExportHeader$b1w_reg_svc_reactorder_a.srw
$PBExportComments$[jhchoi] 서비스 일시정지 해소 신청- 2009.04.16
forward
global type b1w_reg_svc_reactorder_a from w_a_reg_m_m
end type
type dw_detail2 from u_d_base within b1w_reg_svc_reactorder_a
end type
type dw_detail3 from u_d_base within b1w_reg_svc_reactorder_a
end type
type dw_detail4 from datawindow within b1w_reg_svc_reactorder_a
end type
type gb_3 from groupbox within b1w_reg_svc_reactorder_a
end type
type gb_4 from groupbox within b1w_reg_svc_reactorder_a
end type
type gb_2 from groupbox within b1w_reg_svc_reactorder_a
end type
type gb_1 from groupbox within b1w_reg_svc_reactorder_a
end type
end forward

global type b1w_reg_svc_reactorder_a from w_a_reg_m_m
integer width = 3616
integer height = 2004
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref string ai_return )
dw_detail2 dw_detail2
dw_detail3 dw_detail3
dw_detail4 dw_detail4
gb_3 gb_3
gb_4 gb_4
gb_2 gb_2
gb_1 gb_1
end type
global b1w_reg_svc_reactorder_a b1w_reg_svc_reactorder_a

type variables
String is_suspend_status[], is_react_status
end variables

forward prototypes
public subroutine of_resizebars ()
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

event ue_processvalidcheck;//Save Check
STRING	ls_actdt,	ls_partner,		ls_fromdt,		ls_sysdt,		ls_contractseq,		ls_priceplan,  &
			ls_req,		ls_remark,		ls_errmsg
BOOLEAN	lb_check
LONG		ll_rows,		ll_rc,			ll_return,		ll_orderno,		ll_cnt
INT		li_cnt
DATETIME	ld_actdt

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return

dw_detail.AcceptText()
ls_contractseq 	= STRING(dw_detail.object.contractmst_contractseq[1])
ls_actdt 			= STRING(dw_detail.object.actdt[1],'yyyymmdd')
ld_actdt 			= dw_detail.object.actdt[1]
ls_partner 			= Trim(dw_detail.object.partner[1])
ls_sysdt 			= STRING(fdt_get_dbserver_now(),'yyyymmdd')
ls_fromdt 			= dw_detail.object.fromdt[1]
ls_priceplan		= Trim(dw_detail.object.contractmst_priceplan[1])
ls_req				= dw_detail.object.act_gu[1]

//Null Check
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_actdt) Then ls_actdt = ""
If IsNull(ls_actdt) Then ls_fromdt = ""

If ls_actdt = "" Then
	f_msg_usr_err(200, Title, "재개통 요청일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("actdt")
	ai_return = -1
	Return
End If

//재개통 신청내역 존재 여부 check
SELECT COUNT(*) INTO :ll_cnt
FROM   SVCORDER
WHERE  REF_CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
AND    STATUS = :is_react_status; 

IF ll_cnt > 0 THEN
	f_msg_usr_err(200, Title, "이미 재개통신청이 되어있습니다.")	
	ai_return = -1
	RETURN
END IF

ll_cnt = 0 

//해지오더 신청내역 존재 여부 check
SELECT COUNT(*) INTO :ll_cnt
FROM   SVCORDER
WHERE  REF_CONTRACTSEQ = TO_NUMBER(:ls_contractseq)
AND    STATUS IN ('70', '99'); 

IF ll_cnt > 0 THEN
	f_msg_usr_err(200, Title, "해지신청이 되어 있습니다. 취소하신 후 작업하시기 바랍니다.")	
	ai_return = -1
	RETURN
END IF

// 선행 서비스 재개통신청 없이 후행을 먼저 재개통 하는지 체크 -- add hcjung 20071203
SELECT count(*)
  INTO :li_cnt 
  FROM svc_relation 
 WHERE priceplan = :ls_priceplan;

IF li_cnt > 0 THEN
	SELECT count(*) into :li_cnt FROM svcorder where (status = '50' OR status = '20')
	   AND order_type = '50'
	   AND ref_contractseq = (SELECT contractseq FROM contractmst WHERE related_contractseq = :ls_contractseq and status != '99');
	IF li_cnt = 0 THEN
		SELECT count(*) INTO :li_cnt FROM contractmst WHERE related_contractseq = :ls_contractseq and status = '20');
		IF li_cnt = 0 THEN
			f_msg_usr_err(1200, Title, " Check Service Relation")
			ai_return = -1			
		   RollBack;
		   Return
		END IF
   END IF
END IF

////// 날짜 체크
If ls_actdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_actdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'재개통요청일의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		ai_return = -1		
		Return
	End If
	
	If ls_actdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "재개통요청일은 오늘날짜 이상이여야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		ai_return = -1		
		Return
	End If		
	//2009.06.17 일 정팀장님 요청으로  = 제외!
	If ls_actdt < ls_fromdt Then
		f_msg_usr_err(210, Title, "'재개통요청일은 일시정지시작일 이전으로 입력할 수 없습니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		ai_return = -1		
		Return
	End If		
End if

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "수행처")
	dw_detail.SetFocus()
	dw_detail.SetColumn("partner")
	ai_return = -1	
	Return
End If

ai_return = 0

return
end event

event ue_process(ref string ai_return);STRING	ls_customerid,		ls_customernm,		ls_check,			ls_code,				ls_svccod,	ls_payid,	&
			ls_suspendtype,	ls_shop_closedt
LONG		ll_row,				ll_row4,				ll_svc_check,		ll_check,			ll_cnt
INTEGER	ii
DEC		ldc_amount,			ldc_balance
DATE		ldt_shop_closedt

//2019.04.25 VAT 계산을 위한 변수 추가 Modified by Han
string   ls_surtaxyn
dec{2}   ld_vat_amt


dw_detail.AcceptText()
dw_detail4.AcceptText()

//ll_row  = dw_detail.Getrow()
ll_row4 = dw_detail4.RowCount()

ls_customerid  = dw_detail.Object.contractmst_customerid[1]
ls_customernm  = dw_detail.Object.customerm_customernm[1]
ls_svccod      = dw_detail.Object.contractmst_svccod[1]
ls_suspendtype = dw_detail.Object.contractmst_suspend_type[1]

ldt_shop_closedt = f_find_shop_closedt(GS_SHOPID)

ls_shop_closedt = STRING(ldt_shop_closedt, 'yyyymmdd')

IF ls_suspendtype = '400' THEN
	SELECT PAYID INTO :ls_payid
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :ls_customerid;
	
//2009.07.02 로직 정리하면서 빠짐. 수납여부 관계없이 NON-PAYMENT 이면 재개통비를 받는다.	
//	SELECT COUNT(*) INTO :ll_svc_check
//	FROM   SYSCOD2T
//	WHERE  GRCODE = 'UBS09'
//	AND    USE_YN = 'Y'
//	AND    CODE   = :ls_svccod;	
//	
//	IF ll_svc_check > 0 THEN			//당월 까지...
//		SELECT NVL(SUM(DECODE(B.IN_YN, 'N', A.TRAMT, 0)) + SUM(DECODE(B.IN_YN, 'Y', A.TRAMT, 0)), 0) AS BALANCE_AMT
//		INTO   :ldc_balance
//		FROM   REQDTL A, TRCODE B
//		WHERE  A.PAYID = :ls_payid
//		AND    A.TRDT <= TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD')
//		AND    A.TRCOD = B.TRCOD;	
//	ELSE
//		SELECT NVL(SUM(DECODE(B.IN_YN, 'N', A.TRAMT, 0)) + SUM(DECODE(B.IN_YN, 'Y', A.TRAMT, 0)), 0) AS BALANCE_AMT
//		INTO   :ldc_balance
//		FROM   REQDTL A, TRCODE B
//		WHERE  A.PAYID = :ls_payid
//		AND    A.TRDT < TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD')
//		AND    A.TRCOD = B.TRCOD;
//	END IF
	
	SELECT COUNT(*) INTO :ll_cnt
	FROM   DAILYPAYMENT
	WHERE  CUSTOMERID = :ls_payid
	AND    PAYDT BETWEEN TO_DATE(:ls_shop_closedt, 'YYYYMMDD') AND TO_DATE(:ls_shop_closedt, 'YYYYMMDD') + 1
	AND    ITEMCOD IN ( SELECT CODE 
							  FROM   SYSCOD2T
							  WHERE  GRCODE = 'UBS04'
							  AND    USE_YN = 'Y' );
							  
	IF ll_cnt <= 0 THEN		
		ll_check = 0
//		IF ldc_balance > 0 THEN
		FOR ii = 1 TO ll_row4
			ls_check = dw_detail4.Object.fee_check[ii]
			
			IF ls_check = 'Y' THEN
				ll_check  += 1
				ls_code	  = dw_detail4.Object.code[ii]
				ldc_amount = DEC(dw_detail4.Object.codenm[ii])
// 2019.04.25 Vat 처리를 위한 Logic  추가 Modified by Han
				ld_vat_amt  = dw_detail4.Object.vat_amt [ii]
				ls_surtaxyn = dw_detail4.Object.surtaxyn[ii]
			END IF
		NEXT	
		
		IF ll_check <= 0 THEN
			ai_return = 'N'
			RETURN
		END IF
		//수납 팝업 호출
		iu_cust_msg 				= CREATE u_cust_a_msg
		iu_cust_msg.is_pgm_name = "Payment"
		iu_cust_msg.is_data[1]  = "CloseWithReturn"
		iu_cust_msg.il_data[1]  = 1  		//현재 row
		iu_cust_msg.idw_data[1] = dw_master
		iu_cust_msg.idw_data[2] = dw_detail4
		iu_cust_msg.is_data[2]  = ls_customerid
		iu_cust_msg.is_data[3]  = ls_customernm
		iu_cust_msg.is_data[4]  = ""
		iu_cust_msg.is_data[5]  = "N"						//수납 여부
		//품목넘김
		iu_cust_msg.il_data[2]  = 1					//item 갯수
		iu_cust_msg.is_data2[1] = ls_code   		//reactive
		iu_cust_msg.ic_data[1]  = ldc_amount	  	//reactive fee
		iu_cust_msg.ic_data[2]  = ld_vat_amt	  	//vat amt
		
		//수납을 위한 팝업 연결
		OpenWithParm(ubs_w_pop_mobilepayment, iu_cust_msg)
		
		//수납 팝업에서 반환되는 값. 완료:'N', 미완료:'Y'
		IF iu_cust_msg.ib_data[1] THEN
			ai_return = iu_cust_msg.is_data[1]
		END IF
		
		DESTROY iu_cust_msg
//		ELSE
//			ai_return = 'Y'	
//		END IF
	ELSE
		ai_return = 'Y'
	END IF
ELSE
	ai_return = 'Y'
END IF

RETURN
end event

public subroutine of_resizebars ();//
end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

//// Bottom Procesing
//dw_detail2.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//dw_detail2.Resize(idrg_Top.Width / 2 - 200, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

// Bottom Procesing
//idrg_Bottom.Move(cii_WindowBorder + dw_detail2.Width + 40, st_horizontal.Y + cii_BarThickness)
//idrg_Bottom.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height / 2 + 50)

// Bottom Procesing
//dw_detail3.Move(cii_WindowBorder + dw_detail2.Width + 40, idrg_Bottom.Y + idrg_Bottom.Height + 40)
//dw_detail3.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height - idrg_Bottom.Height - 40)

end subroutine

public subroutine of_refreshbars ();//
end subroutine

on b1w_reg_svc_reactorder_a.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_detail3=create dw_detail3
this.dw_detail4=create dw_detail4
this.gb_3=create gb_3
this.gb_4=create gb_4
this.gb_2=create gb_2
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_detail3
this.Control[iCurrent+3]=this.dw_detail4
this.Control[iCurrent+4]=this.gb_3
this.Control[iCurrent+5]=this.gb_4
this.Control[iCurrent+6]=this.gb_2
this.Control[iCurrent+7]=this.gb_1
end on

on b1w_reg_svc_reactorder_a.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_detail3)
destroy(this.dw_detail4)
destroy(this.gb_3)
destroy(this.gb_4)
destroy(this.gb_2)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 서비스 일시정지 해소 신청	                 //
// Name       : b1w_reg_svc_reactorder_a	                 //
// Contents   : 서비스 일시정지를 해소 처리한다.			  //
// Data Window: dw - b1dw_cnd_reg_svc_reactorder		     // 
//							b1dw_inq_svc_reactorder_a				  //
//							b1dw_inq_termorder_popup				  //
//							b1dw_inq_validkey				 			  //
//							b1dw_inq_reactivationfee		  		  //
//							b1dw_reg_svc_reactorder				  	  //
// 작성일자   : 2009.04.17                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//
String ls_ref_desc, ls_temp, ls_priceplan, ls_contractseq
long li_i, is_cnt

//일시정지 상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P225", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , is_suspend_status[])
End if

//재개통신청 상태코드
is_react_status = fs_get_control("B0","P226", ls_ref_desc)

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')
end event

event ue_extra_save;//Save Check
STRING	ls_actdt,	ls_partner,		ls_fromdt,		ls_sysdt,		ls_contractseq,		ls_priceplan,  &
			ls_req,		ls_remark,		ls_errmsg,		ls_svccod,		ls_dacom_svctype,		ls_hostname,	&
			ls_gubunnm, ls_action,		ls_sysdate			
BOOLEAN	lb_check
LONG		ll_rows,		ll_rc,			ll_return,		ll_orderno, 	ll_siid_cnt, 			ll_row_ma,		&
			ll_non_cnt, ll_non_valid_cnt
INT		li_cnt
DATE		ld_actdt

ll_rows 	 = dw_detail.RowCount()
ll_row_ma = dw_master.RowCount()
If ll_rows = 0 Then Return 0

SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO :ls_sysdate
FROM   DUAL;

dw_detail.AcceptText()
ls_contractseq 	= STRING(dw_detail.object.contractmst_contractseq[1])
ls_actdt 			= STRING(dw_detail.object.actdt[1],'yyyymmdd')
ld_actdt 			= DATE(dw_detail.object.actdt[1])
ls_partner 			= Trim(dw_detail.object.partner[1])
ls_sysdt 			= STRING(fdt_get_dbserver_now(),'yyyymmdd')
ls_fromdt 			= dw_detail.object.fromdt[1]
ls_priceplan		= Trim(dw_detail.object.contractmst_priceplan[1])
ls_req				= dw_detail.object.act_gu[1]
ls_svccod			= Trim(dw_detail.object.contractmst_svccod[1])

//Null Check
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_actdt) Then ls_actdt = ""
If IsNull(ls_actdt) Then ls_fromdt = ""

If ls_actdt = "" Then
	f_msg_usr_err(200, Title, "재개통 요청일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("actdt")
	Return -2
End If

// 선행 서비스 재개통신청 없이 후행을 먼저 재개통 하는지 체크 -- add hcjung 20071203
SELECT count(*)
  INTO :li_cnt 
  FROM svc_relation 
 WHERE priceplan = :ls_priceplan;

IF li_cnt > 0 THEN
	SELECT count(*) into :li_cnt FROM svcorder where (status = '50' OR status = '20')
	   AND order_type = '50'
	   AND ref_contractseq = (SELECT contractseq FROM contractmst WHERE related_contractseq = :ls_contractseq and status != '99');
	IF li_cnt = 0 THEN
		SELECT count(*) INTO :li_cnt FROM contractmst WHERE related_contractseq = :ls_contractseq and status = '20';
		IF li_cnt = 0 THEN
			f_msg_usr_err(1200, Title, " Check Service Relation")
		   RollBack;
		   Return -2
		END IF
   END IF
END IF

////// 날짜 체크
If ls_actdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_actdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'재개통요청일의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If
	
	If ls_actdt < ls_sysdt Then
		f_msg_usr_err(210, Title, "재개통요청일은 오늘날짜 이상이여야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If		
	
	//2009.06.17 일 정팀장님 요청으로  = 제외!
	If ls_actdt < ls_fromdt Then
		f_msg_usr_err(210, Title, "'재개통요청일은 일시정지시작일 이전으로 입력할 수 없습니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("actdt")
		Return -2
	End If				
End if

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "수행처")
	dw_detail.SetFocus()
	dw_detail.SetColumn("partner")
	Return -2
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
SQLCA.UBS_REG_REACTIVEORDER(ls_contractseq,	ll_orderno,		ld_actdt,		ls_req,		ls_remark,  &
									 gs_user_id,		gs_pgm_id[1],	ll_return,		ls_errmsg)
										
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_SUSPENDORDER ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	RETURN -1
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_SUSPENDORDER ' + ls_errmsg,Exclamation!,OK!)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	RETURN -1
END IF		

//2009.06.07 추가. 해소신청 SIID 오더번호 업데이트!!!
UPDATE SIID
SET    ORDERNO = :ll_orderno,
		 STATUS  = '500',
		 UPDTDT = SYSDATE
WHERE  CONTRACTSEQ = :ls_contractseq;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
ELSE
	COMMIT;
END IF
//2009.06.07 추가.-------------------------------------END

//2009.06.11 추가. 프로시저 호출...
IF IsNull(ll_orderno) = FALSE AND ( ls_sysdate = ls_actdt ) THEN 
	
//	ls_svccod = dw_master.Object.contractmst_svccod[ll_row_ma]
	
	//인증서비스인지 확인.
	SELECT COUNT(*) INTO :ll_siid_cnt
	FROM   SYSCOD2T
	WHERE  GRCODE = 'BOSS03'
	AND    USE_YN = 'Y'
	AND    CODE   = :ls_svccod;
	
	//인증서비스 중에서도 인증받지 않는 가격정책이 있다. 체크한다.
	SELECT COUNT(*) INTO :ll_non_cnt
	FROM   SYSCOD2T
	WHERE  GRCODE = 'BOSS04'
	AND    USE_YN = 'Y'
	AND    CODE   = :ls_priceplan;
	
	IF ll_non_cnt > 0 THEN
		ll_siid_cnt = 0
	END IF	
	
	
	//인증 받지 않는 장비관리 서비스
		SELECT COUNT(*) INTO :ll_non_valid_cnt
		FROM SYSCOD2T
		WHERE GRCODE = 'BOSS06'
		AND USE_YN = 'Y'
		AND CODE = :ls_svccod;
	
//	IF ls_priceplan = "PRCM06" OR ls_priceplan = "PRCM08" OR ls_priceplan = "PRCM18" OR ls_priceplan = "PRCM19"  THEN
//		ll_siid_cnt = 0
//	END IF
	
	IF ll_siid_cnt > 0 and ll_non_valid_cnt = 0 THEN
		SELECT DACOM_SVCTYPE, VOIP_HOSTNAME, GUBUN_NM INTO :ls_dacom_svctype, :ls_hostname, :ls_gubunnm
		FROM   PRICEPLANINFO
		WHERE  PRICEPLAN = :ls_priceplan;	
	
		If SQLCA.SQLCode <> 0 Then
			f_msg_sql_err(title, " SELECT PRICEPLANINFO Table(DACOM_SVCTYPE)")
			Return -1
		End If
		
		IF ls_gubunnm = "전화" THEN 
			ls_action = "TEL512"
		ELSE
			ls_action = "INT500"
		END IF
		
		ls_errmsg = space(1000)
		SQLCA.UBS_PROVISIONNING(ll_orderno,			ls_action,				0,		&
										'',					gs_shopid,						&
										gs_pgm_id[1],		ll_return,				ls_errmsg)
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX(ls_errmsg, '장비인증오류 ' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			RETURN -1
		ELSEIF ll_return < 0 THEN		//For User
			MESSAGEBOX('확인', '장비인증오류 ' + ls_errmsg,Exclamation!,OK!)
			RETURN -1
		END IF	
	END IF		
END IF
//2009.06.11--------------------------------------------------END
//해소인증중으로 UPDATE
UPDATE EQUIPMST
SET    VALID_STATUS = '600'
WHERE  CONTRACTSEQ = TO_NUMBER(:ls_contractseq);

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF

Return 0
end event

event ue_ok();call super::ue_ok;//Service 별 요금 조회
STRING 	ls_customerid,		ls_validkey,		ls_where,   ls_contractseq,	&
			ls_where_1,			ls_memberid
LONG		ll_row

ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_memberid 	= Trim(dw_cond.object.memberid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_validkey 	= Trim(dw_cond.object.validkey[1])

//Null Check
If IsNull(ls_customerid) 	Then ls_customerid 	= ""
If IsNull(ls_memberid) 		Then ls_memberid		= ""
If IsNull(ls_contractseq) 	Then ls_contractseq 	= ""
If IsNull(ls_validkey) 		Then ls_validkey 		= ""

ls_where = ''
//일시정지인 고객만 조회!!!
ls_where += " CON.STATUS = '" + is_suspend_status[2]  + "' "

IF ls_memberid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CUS.MEMBERID = '" + ls_memberid + "' "
End If

IF ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CON.CUSTOMERID = '" + ls_customerid + "' "
End If

If ls_contractseq <>  "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CON.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
End If

If ls_validkey <>  "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " CON.CONTRACTSEQ IN ( SELECT DISTINCT CONTRACTSEQ FROM VALIDINFO WHERE VALIDKEY = '" + ls_validkey+ "') "
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_master.SetFocus()
end event

event type integer ue_reset();call super::ue_reset;dw_detail2.Reset()
dw_detail3.Reset()
dw_detail4.Reset()

dw_cond.SetColumn("memberid")
Return 0 
end event

event ue_save;//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
CONSTANT INT LI_ERROR = -1
STRING	ls_activedt,		ls_bil_fromdt,		ls_customerid,		ls_contractseq,   &
			ls_contractno, 	ls_validkey,		ls_amt_check
LONG		ll_row, 				li_chk,				i
INTEGER	li_rc

IF dw_detail.AcceptText() < 0 THEN
	dw_detail.SetFocus()
	RETURN -1
END IF

// Ue_inputValidCheck  호출
THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

//Ue_processvalidCheck 호출 
THIS.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

//Ue_processvalidCheck 호출 
THIS.TRIGGER EVENT ue_process(ls_amt_check)

IF ls_amt_check <> 'Y' THEN
	f_msg_usr_err(210, Title, "'수납을 하셔야 재개통 됩니다.")
	RETURN LI_ERROR
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
	f_msg_info(3010, THIS.Title,"재개통신청")
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
	f_msg_info(3000,THIS.Title,"재개통신청")
END IF

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_contractseq = dw_cond.object.contractseq[1]
ls_validkey = Trim(dw_cond.object.validkey[1])

TRIGGER EVENT ue_reset()
dw_cond.object.customerid[1] = ls_customerid
dw_cond.object.contractseq[1] = ls_contractseq
dw_cond.object.validkey[1] = ls_validkey
TRIGGER EVENT ue_ok()

RETURN 0
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
	
	ll_3 					= round((newheight - gb_4.Y - gb_4.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 2, 1)
	//dw_detail.Height	= newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space - 25
	//gb_1.Height			= newheight - gb_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
	
	gb_2.Height			= gb_2.Height + ll_3
	dw_detail2.Height = dw_detail2.Height + ll_3
	
	gb_1.Height			= gb_1.Height + ll_3
	dw_detail.Height  = dw_detail.Height + ll_3	
	
	gb_4.y				= gb_2.y + gb_2.Height + ll_grsize
	dw_detail4.y		= gb_4.y + ll_dwsize
	gb_4.Height 		= gb_4.Height + ll_3	
	dw_detail4.Height = dw_detail4.Height + ll_3	
		
	gb_3.y				= gb_1.y + gb_1.Height + ll_grsize
	dw_detail3.y		= gb_3.y + ll_dwsize
	gb_3.Height 		= gb_3.Height + ll_3	
	dw_detail3.Height = dw_detail3.Height + ll_3		
	
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
	
	gb_4.Width			= gb_4.Width + ll_w
	dw_detail4.Width  = dw_detail4.Width + ll_w
	
	gb_1.x				= gb_2.x + gb_2.Width + ll_wgrsize
	dw_detail.x		   = gb_1.x + (ll_dwsize / 2)	

	gb_3.x				= gb_2.x + gb_2.Width + ll_wgrsize
	dw_detail3.x		= gb_1.x + (ll_dwsize / 2)		
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_reactorder_a
integer x = 46
integer y = 40
integer width = 2487
integer height = 188
string dataobject = "b1dw_cnd_reg_svc_reactorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
 			 This.Object.memberid[1] 	= This.iu_cust_help.is_data[4]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_partner, ls_partnernm, ls_filter
String ls_customernm, ls_paynm
DataWindowChild ldc_priceplan, ldc_svcpromise
Long li_exist

String ls_customerid, ls_memberid
Choose Case dwo.name
	Case "memberid"
		 If data = "" then 
				This.SetFocus()
				This.SetColumn("memberid")
				Return -1
 		 End If		 
		 
		 SELECT customernm, 		customerid
		 INTO :ls_customernm, 	:ls_customerid
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select MemberID")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
				This.Object.memberid[row] = ""
				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("memberid")
				Return -1
		 End if
		 This.Object.customerid[row] = ls_customerid
		 This.Object.customernm[row] = ls_customernm

	Case "customerid"
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 SELECT customernm, memberid
		 INTO :ls_customernm, :ls_memberid
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select CustomerID")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
				This.Object.memberid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] 	= ls_customernm
		 This.Object.memberid[row] 	= ls_memberid
End Choose

Return 0 
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "ssrt_hlp_customer"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"


end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_reactorder_a
integer x = 3227
integer y = 88
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_reactorder_a
integer x = 649
integer y = 1764
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_reactorder_a
integer width = 3520
integer height = 240
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_reactorder_a
integer y = 256
integer width = 3511
integer height = 576
integer taborder = 50
string dataobject = "b1dw_inq_svc_reactorder_a"
end type

event dw_master::clicked;call super::clicked;String ls_status, ls_todt
Long ll_row, ll_selected_row

dw_detail.SetRedraw(false)

ll_selected_row = dw_detail.rowcount()

If ll_selected_row > 0 Then

  	ls_status = dw_detail.object.contractmst_status[1]
	ls_todt = dw_detail.object.todt[1]
	
	If ( ls_status = is_suspend_status[2] OR ls_status = is_suspend_status[3] )  and &
	   isNull(ls_todt) Then
  		p_save.TriggerEvent("ue_enable")	
		dw_detail.object.actdt.protect = 0
		dw_detail.object.partner.protect = 0
		dw_detail.object.act_gu.protect = 0
		dw_detail.object.remark.protect = 0
   Else
		dw_detail.object.actdt.protect = 1
		dw_detail.object.partner.protect = 1
		dw_detail.object.act_gu.protect = 1
		dw_detail.object.remark.protect = 1
		p_save.TriggerEvent("ue_disable")	
   End If
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

dw_detail.SetRedraw(true)
end event

event dw_master::retrieveend;call super::retrieveend;String ls_status, ls_todt
Long ll_row, ll_selected_row

dw_detail.SetRedraw(false)

ll_selected_row = dw_detail.rowcount()

If ll_selected_row > 0 Then

  	ls_status = dw_detail.object.contractmst_status[1]
	ls_todt = dw_detail.object.todt[1]
	
	If ls_status = is_suspend_status[2] and isNull(ls_todt) Then
  		p_save.TriggerEvent("ue_enable")	
		dw_detail.object.actdt.protect = 0
		dw_detail.object.partner.protect = 0
		dw_detail.object.act_gu.protect = 0		
   Else
		dw_detail.object.actdt.protect = 1
		dw_detail.object.partner.protect = 1
		dw_detail.object.act_gu.protect = 1	
		p_save.TriggerEvent("ue_disable")	
   End If
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

dw_detail.SetRedraw(true)
end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_reactorder_a
integer x = 2021
integer y = 912
integer width = 1499
integer height = 380
integer taborder = 60
string dataobject = "b1dw_reg_svc_reactorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_detail::buttonclicked;call super::buttonclicked;////Butonn Click
//String ls_payid, ls_paynm, ls_termtype, ls_partner,	ls_partnernm
//Dec ldc_contractseq
//Datetime ldt_termdt
//
//Choose Case dwo.Name
//	Case "item_detail" //상세품목조회
//		
//		iu_cust_msg = Create u_cust_a_msg
//		iu_cust_msg.is_pgm_name = "상세품목조회"
//		iu_cust_msg.is_grp_name = "서비스재개통신청"
//		iu_cust_msg.is_data[1] = Trim(String(Object.contractmst_contractseq[1]))
//		
//		OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
//		
//End Choose
//
Return 0 
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
STRING	ls_where,			ls_contractseq,		ls_termtype,		ls_partner,		ls_partnernm, &
			ls_susseq,			ls_type,					ls_ref_desc,		ls_svccod,		ls_svctype,   &
			ls_priceplan
LONG	 	ll_row,				ll_cnt
DEC		ldc_contractseq,	ldc_susseq
DATETIME	ldt_termdt

ldc_contractseq = dw_master.object.contractmst_contractseq[al_select_row]
ldc_susseq = dw_master.object.suspendinfo_seq[al_select_row]

ls_contractseq = STRING(ldc_contractseq)

IF IsNull(ldc_contractseq) THEN ls_contractseq = ""

ls_where = ""
IF ls_contractseq <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CON.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
END IF

ls_susseq = string(ldc_susseq)
IF IsNull(ldc_susseq) THEN ls_susseq = ""
IF ls_susseq <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " SUS.SEQ = " + ls_susseq + ""
END IF

//dw_detail 조회
dw_detail.is_where = ls_where
dw_detail.SetRedraw(false)
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

//setting
dw_detail.object.actdt[1] = fdt_get_dbserver_now()

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

If dw_detail2.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

If dw_detail3.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

If dw_detail4.Trigger Event ue_retrieve(al_select_row) < 0 Then
	Return -1
End If

//비과금 후불제 서비스 type
ls_type = fs_get_control("B0", "P103", ls_ref_desc)

ls_svccod 	 = Trim(dw_detail.object.contractmst_svccod[1])
ls_priceplan = Trim(dw_detail.object.contractmst_priceplan[1])

SELECT SVCTYPE
  INTO :ls_svctype
  FROM SVCMST
 WHERE SVCCOD = :ls_svccod;

If SQLCA.SQLCode <> 0 Then
	f_msg_usr_err(2100, Title, "SVCMST Retrieve()")
	Return -2
End If

If ls_svctype = ls_type Then
	dw_detail.object.act_gu.Tabsequence = 0
Else
	dw_detail.object.act_gu.Tabsequence = 20
End If

//만약 계약 내용이 인증용서비스이면 "일시정지확정"의 visible을 uncheck
SELECT COUNT(*) INTO :ll_cnt
FROM   PRICEPLAN_EQUIP
WHERE  PRICEPLAN = :ls_priceplan;

IF ll_cnt > 0 THEN
	dw_detail.object.act_gu.visible = 0	
ELSE
	dw_detail.object.act_gu.visible = 1	
END IF

dw_detail.SetRedraw(True)

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;//2019.04.25 VAT 계산을 위한 Script 추가 Modified by Han
string ls_payid,   ls_itemcod
dec{2} ld_fee_amt, ld_vat_amt
datetime ldt_dttime
int  ii
Long ll_row

choose case dwo.name
	case 'actdt'
		ldt_dttime = datetime(data)
		ll_row = dw_detail4.RowCount()
		if ll_row > 0 then
			ls_payid = dw_master.Object.contractmst_customerid[dw_master.GetSelectedRow(0)]
		
			FOR ii = 1 to ll_row
				ls_itemcod = dw_detail4.Object.code      [ii]
				ld_fee_amt = dec(dw_detail4.Object.codenm[ii])
				SELECT TRUNC(:ld_fee_amt * FNC_GET_TAXRATE(:ls_payid, 'I', :ls_itemcod, :ldt_dttime) / 100, 2)
				  INTO :ld_vat_amt
				  FROM DUAL;
				
				if sqlca.sqlcode = 0 then
					dw_detail4.Object.vat_amt[ii] = ld_vat_amt
				end if
			NEXT
		end if
end choose

 
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_reactorder_a
boolean visible = false
integer y = 1744
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_reactorder_a
boolean visible = false
integer y = 1744
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_reactorder_a
integer x = 37
integer y = 1764
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_reactorder_a
integer x = 338
integer y = 1764
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_reactorder_a
boolean visible = false
integer y = 832
end type

type dw_detail2 from u_d_base within b1w_reg_svc_reactorder_a
event type integer ue_retrieve ( long al_select_row )
integer x = 59
integer y = 912
integer width = 1897
integer height = 380
integer taborder = 30
boolean bringtotop = true
string dataobject = "b1dw_inq_termorder_popup"
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
STRING	ls_where
LONG		ll_row,		ll_contractseq

This.SetRedraw(false)

If al_select_row = 0 Then Return 0
ll_contractseq = dw_master.object.contractmst_contractseq[al_select_row]

ll_row = dw_detail2.Retrieve(ll_contractseq)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

This.SetRedraw(True)

Return 0 
end event

type dw_detail3 from u_d_base within b1w_reg_svc_reactorder_a
event type integer ue_retrieve ( long al_select_row )
integer x = 2021
integer y = 1392
integer width = 1499
integer height = 312
integer taborder = 40
boolean bringtotop = true
string dataobject = "b1dw_inq_validkey"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
String ls_contractseq, ls_where
Long ll_row

This.SetRedraw(False)

If al_select_row = 0 Then Return 0
ls_contractseq = String(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " validinfo.contractseq = TO_NUMBER('" + ls_contractseq + "') "

dw_detail3.is_where = ls_where
ll_row = dw_detail3.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

This.SetRedraw(True)

If dw_detail3.rowcount() > 0 Then
//	dw_detail3.visible = True
Else
//	dw_detail3.visible = False
End if

Return 0
end event

type dw_detail4 from datawindow within b1w_reg_svc_reactorder_a
event type integer ue_retrieve ( long al_select_row )
integer x = 59
integer y = 1392
integer width = 1897
integer height = 312
integer taborder = 50
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_inq_reactivationfee"
boolean vscrollbar = true
boolean livescroll = true
end type

event type integer ue_retrieve(long al_select_row);//조회
String ls_contractseq, ls_where
Long ll_row

// 2019.04.25 VAT 처리를 위한 변수 추가 Modified by Han
string ls_payid,   ls_itemcod
dec{2} ld_fee_amt, ld_vat_amt
datetime   ldt_date
int  ii

This.SetRedraw(false)

If al_select_row = 0 Then Return 0

ls_contractseq = String(dw_master.object.contractmst_contractseq[al_select_row])

ll_row = dw_detail4.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
// Vat 처리를 위해서 elseif 문 추가 값이 있는 경우만 Vat를 구한다. Modified by Han
elseif ll_row > 0 then
	ls_payid = dw_master.Object.contractmst_customerid[al_select_row]
	if dw_detail.Rowcount() > 0 then
		ldt_date = dw_detail.Object.actdt[1]
	else
		ldt_date = fdt_get_dbserver_now()
	end if

	FOR ii = 1 to ll_row
		ls_itemcod = This.Object.code      [ii]
		ld_fee_amt = dec(This.Object.codenm[ii])
		SELECT TRUNC(:ld_fee_amt * FNC_GET_TAXRATE(:ls_payid, 'I', :ls_itemcod, :ldt_date) / 100, 2)
		  INTO :ld_vat_amt
		  FROM DUAL;
		
		if sqlca.sqlcode = 0 then
			This.Object.vat_amt[ii] = ld_vat_amt
		end if
	NEXT
else
	
End If

This.SetRedraw(True)

Return 0 
end event

event constructor;SetTransObject(SQLCA)
end event

event itemchanged;//LONG		ll_row
//INTEGER	ii
//ll_row = THIS.Rowcount()
//
//FOR ii = 1 TO ll_row
//	IF ii = row THEN
//		THIS.Object.fee_check[ii] = 'Y'
//	ELSE
//		THIS.Object.fee_check[ii] = 'N'
//	END IF
//NEXT	
//
//RETURN 0
end event

event clicked;LONG		ll_row
INTEGER	ii

IF row <= 0 THEN RETURN -1

ll_row = THIS.Rowcount()

FOR ii = 1 TO ll_row
	IF ii = row THEN
		THIS.Object.fee_check[ii] = 'Y'
	ELSE
		THIS.Object.fee_check[ii] = 'N'
	END IF
NEXT	

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

RETURN 0

end event

type gb_3 from groupbox within b1w_reg_svc_reactorder_a
integer x = 1993
integer y = 1328
integer width = 1559
integer height = 400
integer taborder = 70
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Phone Number Info"
end type

type gb_4 from groupbox within b1w_reg_svc_reactorder_a
integer x = 37
integer y = 1328
integer width = 1943
integer height = 400
integer taborder = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Reactivation Fee"
end type

type gb_2 from groupbox within b1w_reg_svc_reactorder_a
integer x = 37
integer y = 852
integer width = 1943
integer height = 468
integer taborder = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Contract Info"
end type

type gb_1 from groupbox within b1w_reg_svc_reactorder_a
integer x = 1993
integer y = 852
integer width = 1559
integer height = 468
integer taborder = 80
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Reactivation Request"
end type

