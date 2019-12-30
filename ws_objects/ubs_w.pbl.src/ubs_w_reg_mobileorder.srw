$PBExportHeader$ubs_w_reg_mobileorder.srw
$PBExportComments$[jhchoi] 모바일 신규 신청 - 2009.03.13
forward
global type ubs_w_reg_mobileorder from w_base
end type
type cb_1 from commandbutton within ubs_w_reg_mobileorder
end type
type p_reset from u_p_reset within ubs_w_reg_mobileorder
end type
type st_horizontal from statictext within ubs_w_reg_mobileorder
end type
type dw_detail from u_d_base within ubs_w_reg_mobileorder
end type
type dw_master from u_d_help within ubs_w_reg_mobileorder
end type
type p_close from u_p_close within ubs_w_reg_mobileorder
end type
type p_print from u_p_print within ubs_w_reg_mobileorder
end type
type p_save from u_p_save within ubs_w_reg_mobileorder
end type
type p_payment from u_p_payment within ubs_w_reg_mobileorder
end type
end forward

global type ubs_w_reg_mobileorder from w_base
integer width = 3653
integer height = 1780
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event type integer ue_reset ( )
event ue_process_customer ( ref integer ai_return )
event ue_clip ( string as_value )
cb_1 cb_1
p_reset p_reset
st_horizontal st_horizontal
dw_detail dw_detail
dw_master dw_master
p_close p_close
p_print p_print
p_save p_save
p_payment p_payment
end type
global ubs_w_reg_mobileorder ubs_w_reg_mobileorder

type variables
u_cust_db_app iu_cust_db_app

INT	ii_error_chk

//Resize Panels by kEnn 2000-06-28
INTEGER		ii_WindowTop						//The virtual top of the window
INTEGER		ii_WindowMiddle					//The virtual middle of the window
LONG			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Middle							//Reference to the Top Middle control
Dragobject	idrg_Bottom							//Reference to the Top Bottom control
CONSTANT INTEGER	cii_BarThickness = 20	//Bar Thickness
CONSTANT INTEGER	cii_WindowBorder = 20	//Window border to be used on all sides

STRING	is_cus_status,		is_hotbillflag,	is_admst_status,	is_amt_check,	is_print_check,	&
			is_cont_period,	is_paydt,			is_return_status,	is_save_check,	is_appseq
DEC		idc_bil_amt   
LONG		il_extdays
end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public subroutine wf_protect (string ai_gubun)
public subroutine of_refreshbars ()
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_master.GetRow()

lb_check = fb_save_required(dw_master, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck;STRING	ls_new_customer

dw_master.AcceptText()

//ls_new_customer = dw_master.Object.new_customer[1]

IF is_amt_check = 'N' THEN
	F_MSG_INFO(9000, Title, "수납이 완료되지 않았습니다")
	ai_return = -1
	RETURN
END IF
	
IF is_print_check = 'N' THEN
	F_MSG_INFO(9000, Title, "계약서 출력이 완료되지 않았습니다")
	ai_return = -1
	RETURN
END IF
	
ai_return = 0

RETURN
end event

event ue_process;STRING	ls_errmsg,		ls_customerid,		ls_payid,			ls_lastname,		ls_firstname,		&
			ls_basecod, 	ls_buildingno, 	ls_roomno, 			ls_unit,				ls_homephone, 		&
			ls_contno,		ls_itemcod, 		ls_phone_type, 	ls_admst_contno, 	ls_serialno,		&
			ls_phonemodel, ls_derosdt, 		ls_midname, 		ls_validkey, 		ls_contractseq,	&
			ls_priceplan,	ls_orderno,			ls_new_customer,	ls_order_type,		ls_admst_Status,	&
			ls_ref_desc,	ls_modelno,			ls_deposit_item,	ls_app,				ls_rental_status,	&
			ls_action
LONG		ll_row,			ll_return,			ll_contractseq,	ll_card_check
INTEGER	ii
DATE		ld_cont_period
DEC{2}	ldc_activ,		ldc_deposit

dw_master.AcceptText()
ll_row = dw_master.GetRow()

ls_new_customer = dw_master.Object.new_customer[ll_row]
ls_customerid   = dw_master.Object.customerid[ll_row]
ls_payid        = dw_master.Object.payid[ll_row]
ls_lastname     = dw_master.Object.lastname[ll_row]
ls_firstname    = dw_master.Object.firstname[ll_row]
ls_midname      = dw_master.Object.midname[ll_row]
ls_basecod      = dw_master.Object.basecod[ll_row]
ls_buildingno   = dw_master.Object.buildingno[ll_row]
ls_roomno       = dw_master.Object.roomno[ll_row]
ls_unit         = dw_master.Object.unit[ll_row]
ls_homephone    = dw_master.Object.homephone[ll_row]
ls_derosdt      = STRING(dw_master.Object.derosdt[ll_row], 'yyyymmdd')
ls_contno       = dw_master.Object.contno[ll_row]
ls_phone_type   = dw_master.Object.phone_type[ll_row]
ls_admst_contno = dw_master.Object.admst_contno[ll_row]
ls_serialno     = dw_master.Object.serialno[ll_row]
ls_phonemodel   = dw_master.Object.phone_model[ll_row] 
ls_validkey     = dw_master.Object.validkey[ll_row] 
ls_order_type   = 'I'					//신규신청화면 이므로...contract, contractdet 는 항상 신규다!
ldc_activ		 = dw_detail.Object.activation[1]
ldc_deposit     = dw_detail.Object.deposit[1]
ls_deposit_item = dw_detail.Object.item_deposit[1]

ls_ref_desc = ""
ls_admst_Status	= fs_get_control("E1", "A103", ls_ref_desc)
ls_rental_Status	= fs_get_control("E1", "A101", ls_ref_desc)
//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
SELECT ref_content INTO :ls_action FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A103';

//카드 체크
//저장할 때도 상태 확인.
SELECT COUNT(*) INTO :ll_card_check
FROM   ADMST
WHERE  CONTNO = :ls_admst_contno
AND    STATUS IN ('MG100', 'RP100', 'SG100');						
				
IF ll_card_check > 0 THEN
	F_MSG_INFO(3010, Title, 'Act. Card No Error!')	
	ai_return = -1		
	RETURN
END IF

//PRICEPLAN 찾아서 프로시저로 넘긴다.
SELECT PRICEPLAN 		 INTO :ls_priceplan
FROM 	 AD_MOBILE_TYPE
WHERE  PHONE_TYPE 	= :ls_phone_type;

IF SQLCA.SQLCODE <> 0 THEN
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)	
	ai_return = -1		
	RETURN
END IF

//프로시저 실행 - 고객 id 생성은 ue_process_customer 로 변경
//IF ls_new_customer = 'Y' THEN
//	ls_errmsg		= space(1000)
//	ls_customerid	= space(14)
//	SQLCA.UBS_REG_MOBILE_CUSTOMER(ls_customerid,		ls_lastname,	ls_firstname,	ls_midname,		&
//     	               	         ls_basecod,		 	ls_buildingno, ls_roomno, 		ls_unit, 		&
//											ls_homephone, 		ls_derosdt, 	gs_shopid, 		gs_user_id,		&
//											gs_pgm_id[1], 		ll_return, 		ls_errmsg)
//
//	IF SQLCA.SQLCODE < 0 THEN		//For Programer
//		MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CUSTOMER' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
//		ai_return = -1		
//		RETURN
//	ELSEIF ll_return < 0 THEN		//For User
//		MESSAGEBOX('확인', 'UBS_REG_MOBILE_CUSTOMER' + ls_errmsg,Exclamation!,OK!)
//		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
//		ai_return = -1		
//		RETURN
//	END IF
//	
//	dw_master.Object.customerid[ll_row] = ls_customerid	
//	
//END IF	

ls_errmsg = space(1000)
ll_return = 0
SQLCA.UBS_REG_MOBILE_CONTRACT(ls_customerid, 	ll_contractseq, 	ls_contno,			ls_priceplan, 	&
										ls_admst_contno, 	ls_validkey, 		gs_shopid,			ls_order_type,	&
										gs_user_id,			gs_pgm_id[gi_open_win_no],		ll_return,			ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CONTRACT ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_MOBILE_CONTRACT ' + ls_errmsg,Exclamation!,OK!)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	ai_return = -1		
	RETURN
END IF

ls_contractseq = String(ll_contractseq)

ls_errmsg = space(1000)
ll_return = 0
ls_orderno = space(100)
SQLCA.UBS_REG_MOBILE_SVCORDER(ls_customerid,		ls_priceplan,		ls_orderno,		ls_contractseq,	&
										gs_user_id,			gs_pgm_id[gi_open_win_no],		ll_return,		ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_SVCORDER ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_MOBILE_SVCORDER ' + ls_errmsg,Exclamation!,OK!)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	ai_return = -1		
	RETURN
END IF		

SELECT TO_DATE(:is_cont_period, 'YYYYMMDD') INTO :ld_cont_period
FROM   DUAL;

FOR ii = 1 TO 3  //itemcod 가 정해지지 않아서 임시적으로 반영!
	ls_errmsg = space(1000)
	ll_return = 0
	IF ii = 1 THEN
		ls_itemcod = dw_detail.Object.item_deposit[1]
	ELSEIF ii = 2 THEN
		ls_itemcod = dw_detail.Object.item_lease[1]
	ELSE
		ls_itemcod = dw_detail.Object.item_activ[1]
		//하드코딩 2009.09.16 011로 넣으면 청구작업시 정액 RATING 에서 에러.PRICEPLAN_RATE2 에 데이터 없음
		//데이터를 넣을라 했는데 안들어감. 011 아이템 서비스가 999ET 로 되어 있어서...
		IF ls_itemcod = '011' THEN
			ls_itemcod = 'STR032'     //Phone Lease Activation Fee
		END IF
	END IF
		
	SQLCA.UBS_REG_MOBILE_CONTRACTDET(ls_customerid, 		ls_contractseq,	ls_orderno,			ls_itemcod, 	&
												ld_cont_period,		ls_order_type,		gs_user_id,			gs_pgm_id[gi_open_win_no],	&
												ll_return,				ls_errmsg)	

	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CONTRACTDET ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		ai_return = -1		
		RETURN
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', 'UBS_REG_MOBILE_CONTRACTDET ' + ls_errmsg,Exclamation!,OK!)
		ai_return = -1		
		RETURN
	END IF
NEXT	

//validinfo orderno 넣기
UPDATE VALIDINFO
SET    ORDERNO = TO_NUMBER(:ls_orderno)
WHERE  VALIDKEY = :ls_validkey
AND    CONTRACTSEQ = TO_NUMBER(:ls_contractseq);

IF SQLCA.SQLCODE <> 0 THEN		//For Programer
	MESSAGEBOX('확인', 'VALIDINFO ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 
END IF

//카드 UPDATE
UPDATE ADMST
 SET   saledt 	   = TO_DATE(:is_paydt, 'YYYYMMDD'),
       customerid = :ls_customerid,
		 contractseq = TO_NUMBER(:ls_contractseq),
       sale_amt   = :ldc_activ,
       status     = :ls_admst_status,
       sale_flag	= '1',
       updt_user  = :gs_user_id,
       updtdt 	   = sysdate,
       pgm_id 	   = :gs_pgm_id[gi_open_win_no]					 
 WHERE contno 	   = :ls_admst_contno;
 
IF SQLCA.SQLCODE <> 0 THEN		//For Programer
	MESSAGEBOX('확인', 'ADMST ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 
END IF

SELECT MODELNO INTO :ls_modelno
FROM   ADMST
WHERE  CONTNO = :ls_admst_contno;

Insert Into ad_salelog	(saleseq, 	
								saledt, 					SHOPID,				saleqty,			sale_amt,		
								sale_sum,				paymethod,			modelno,			contno,		
								note,						crt_user,			crtdt, 			pgm_id)
Values( seq_ad_salelog.nextval,
		  TO_DATE(:is_paydt, 'yyyymmdd'),	  :gs_shopid,			1,			 		:ldc_activ, 
		  :ldc_activ, 									null,					:ls_modelno,	:ls_admst_contno,
		  null,										  :gs_user_id,			sysdate,			:gs_pgm_id[gi_open_win_no]	);
		  
If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX('확인', 'AD_SALELOG ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If

//2011.03.01  카드 판매 정보 남김...
INSERT INTO ADMSTLOG_NEW		
	( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
	  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
	  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
	  PGM_ID, IDATE )
SELECT ADSEQ, seq_admstlog.nextval, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
		 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
		 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
		 :gs_pgm_id[gi_open_win_no], IDATE
FROM   ADMST
WHERE  CONTNO = :ls_admst_contno;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX('확인', 'ADMSTLOG_NEW ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If

UPDATE AD_MOBILE_RENTAL
SET    CUSTOMERID  = :ls_customerid,
       CONTRACTSEQ = TO_NUMBER(:ls_contractseq),
		 VALIDKEY    = :ls_validkey,
		 CARD_CONTNO = :ls_admst_contno,
		 STATUS	    = :ls_rental_status,
		 LEASEDT		 = :ld_cont_period,
       updt_user   = :gs_user_id,
       updtdt 	    = sysdate,
       pgm_id 	    = :gs_pgm_id[1]					 
WHERE  CONTNO      = :ls_contno;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'AD_MOBILE_RENTAL : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If	

//장비이력(LEASELOG_NEW) Table에 정보저장
INSERT INTO LEASELOG_NEW		
	( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
	  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
	  RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
	  PGM_ID, IDATE )
SELECT SEQ, seq_admstlog.nextval, :ls_action, SYSDATE, FR_SHOP, MV_SHOP, CONTNO, STATUS,
		 LEASEDT, SHOPID, 1, 0, 0, PHONE_MODEL, CUSTOMERID, CONTRACTSEQ,
		 NULL, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
		 :gs_pgm_id[gi_open_win_no], ISEQ
FROM   AD_MOBILE_RENTAL
WHERE  CONTNO = :ls_contno;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'LEASELOG_NEW : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If	

//모바일 디파짓 아이템만 따로 저장
SELECT MAX(APPROVALNO) INTO :ls_app
FROM   DAILYPAYMENT
WHERE  CUSTOMERID = :ls_customerid
AND    PAYDT		= TO_DATE(:is_paydt, 'YYYYMMDD');

INSERT INTO MOBILE_DEPOSIT
			( PAYSEQ, CUSTOMERID, CONTRACTSEQ, ITEMCOD,
			  PAYDT,  PAYAMT, 	 CRT_USER, 	  CRTDT, 	PGM_ID)
VALUES	( TO_NUMBER(:ls_app), 					:ls_customerid, TO_NUMBER(:ls_contractseq), :ls_deposit_item,
			  TO_DATE(:is_paydt, 'YYYYMMDD'),   :ldc_deposit,	 :gs_user_id, 						SYSDATE, 			:gs_pgm_id[1]	);

			  
If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'MOBILE_DEPOSIT : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If	

UPDATE DAILYPAYMENT
SET    CONTRACTSEQ = TO_NUMBER(:ls_contractseq),
		 ORDERNO     = TO_NUMBER(:ls_orderno)
WHERE  CUSTOMERID = :ls_customerid
AND    PAYDT = TO_DATE(:is_paydt, 'YYYYMMDD')
AND    APPROVALNO = :is_appseq;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'DAILYPAYMENT(update) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If			 

INSERT INTO DEPOSIT_LOG
	( PAYSEQ, PAY_TYPE, PAYDT, SHOPID, OPERATOR,
	  CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
	  PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
	  TRDT, MARK, AUTO_CHK, APPROVALNO, CRTDT,
	  CRT_USER, DCTYPE, MANUAL_YN, PGM_ID, REMARK2,
	  ORDERNO )
SELECT PAYSEQ, 'I', PAYDT, SHOPID, OPERATOR,
		 CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
		 PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
		 TRDT, MARK, AUTO_CHK, APPROVALNO, SYSDATE,
		 :gs_user_id, DCTYPE, MANUAL_YN, 'LEASE', REMARK2,
		 ORDERNO
FROM   DAILYPAYMENT
WHERE  CUSTOMERID = :ls_customerid
AND    PAYDT      = TO_DATE(:is_paydt, 'YYYYMMDD')
AND    ITEMCOD IN ( SELECT IN_ITEM FROM DEPOSIT_REFUND )
AND    APPROVALNO = :is_appseq;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'DEPOSIT_LOG : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If			 

SetPointer(Arrow!)

ai_return = 0

is_amt_check = 'N'       //프린트 팝업 확인 초기 값
is_print_check = 'N'     //수납팝업 확인 초기 값

RETURN
end event

event ue_reset;CONSTANT	INT LI_ERROR = -1
INT		li_rc

IF (dw_master.ModifiedCount() > 0) OR (dw_master.DeletedCount() > 0) THEN
	li_rc = MessageBox(THIS.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then
		RETURN LI_ERROR //Process Cancel
	Else		
		If is_amt_check = 'Y' or is_print_check = 'Y' THEN
			F_MSG_INFO(9000, Title, "수납 또는 계약서 출력을 하셨습니다. 계약서 저장을 하셔야 합니다.")
			RETURN LI_ERROR
		End if
	End if		
END IF

dw_detail.Reset()
dw_master.Reset()

is_amt_check = 'N'       //프린트 팝업 확인 초기 값
is_print_check = 'N'     //수납팝업 확인 초기 값
il_extdays = 0
idc_bil_amt = 0
is_paydt = ""

dw_master.InsertRow(0)
dw_detail.InsertRow(0)

dw_master.Object.lease_period_from[1] = fdt_get_dbserver_now()

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_master.SetItemStatus(1, 0, Primary!, NotModified!)

dw_master.SetFocus()
dw_master.SetColumn("new_customer")
//기본 세팅
wf_protect('N')  

RETURN 0

end event

event ue_process_customer(ref integer ai_return);STRING	ls_errmsg,		ls_customerid,		ls_payid,			ls_lastname,		ls_firstname,		&
			ls_basecod, 	ls_buildingno, 	ls_roomno, 			ls_unit,				ls_homephone, 		&
			ls_derosdt, 	ls_midname, 		ls_new_customer,	ls_order_type
LONG		ll_row,			ll_return

dw_master.AcceptText()
ll_row = dw_master.GetRow()

ls_new_customer = dw_master.Object.new_customer[ll_row]
ls_customerid   = dw_master.Object.customerid[ll_row]
ls_payid        = dw_master.Object.payid[ll_row]
ls_lastname     = dw_master.Object.lastname[ll_row]
ls_firstname    = dw_master.Object.firstname[ll_row]
ls_midname      = dw_master.Object.midname[ll_row]
ls_basecod      = dw_master.Object.basecod[ll_row]
ls_buildingno   = dw_master.Object.buildingno[ll_row]
ls_roomno       = dw_master.Object.roomno[ll_row]
ls_unit         = dw_master.Object.unit[ll_row]
ls_homephone    = dw_master.Object.homephone[ll_row]
ls_derosdt      = STRING(dw_master.Object.derosdt[ll_row], 'yyyymmdd')

//프로시저 실행

ls_errmsg		= space(1000)
IF ls_new_customer = 'Y' THEN	
	ls_customerid	= space(14)
	ls_order_type  = 'I'
ELSE
	ls_order_type  = 'U'
END IF	
SQLCA.UBS_REG_MOBILE_CUSTOMER(ls_customerid,		ls_lastname,	ls_firstname,	ls_midname,		&
  	               	         ls_basecod,		 	ls_buildingno, ls_roomno, 		ls_unit, 		&
										ls_homephone, 		ls_derosdt, 	gs_shopid,		ls_order_type, &
										gs_user_id,			gs_pgm_id[1], 	ll_return, 		ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CUSTOMER' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_MOBILE_CUSTOMER' + ls_errmsg,Exclamation!,OK!)
	ai_return = -1		
	RETURN
END IF

IF ls_new_customer = 'Y' THEN	
	dw_master.Object.customerid[ll_row] = ls_customerid	
	dw_master.Object.customernm[ll_row] = ls_firstname + " " + ls_midname + " " + ls_lastname
END IF

SetPointer(Arrow!)
F_MSG_INFO(3000,THIS.Title,"Customer Save")

ai_return = 0

RETURN
end event

event ue_clip(string as_value);Clipboard(as_value)
end event

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

IF st_horizontal.Y < ii_WindowTop + 150 THEN
	st_horizontal.Y = ii_WindowTop + 150
END IF

IF st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 THEN
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
END IF

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
IF NOT IsValid(idrg_Top) OR NOT IsValid(idrg_Bottom) THEN RETURN

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

end subroutine

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
STRING	ls_customernm,		ls_payid,	ls_partner,		ls_customerid,		ls_memberid
INTEGER	li_sw

IF as_customerid <> "" THEN
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
	SELECT  CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
			, MEMBERID
	INTO	  :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner,
			  :ls_memberid
	FROM 	  CUSTOMERM
	WHERE	  CUSTOMERID = :as_customerid;
	 
	ls_customerid = as_customerid
ELSE
	SELECT  CUSTOMERID
			, CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
	INTO	  :ls_customerid,
	        :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner
	FROM 	  CUSTOMERM
	WHERE   MEMBERID = :as_memberid;
	
	ls_memberid = as_customerid
END IF

IF SQLCA.SQLCODE = 100 THEN		//Not Found
	IF li_sw = 1 THEN
   	F_MSG_USR_ERR(201, Title, "Customer ID")
   	dw_master.SetFocus()
   	dw_master.SetColumn("customerid")
	END IF
   RETURN -1
END IF

SELECT HOTBILLFLAG
INTO   :is_hotbillflag
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_payid;

IF SQLCA.SQLCODE = 100 THEN		//Not Found
   F_MSG_USR_ERR(201, Title, "고객번호(납입자번호)")
   dw_master.SetFocus()
   dw_master.SetColumn("customerid")
   RETURN -1
END IF

IF ISNULL(is_hotbillflag) THEN is_hotbillflag = ""
IF is_hotbillflag = 'S' THEN    //현재 Hotbilling고객이면 개통신청 못하게 한다.
   F_MSG_USR_ERR(201, Title, "즉시불처리중인고객")
   dw_master.SetFocus()
   dw_master.SetColumn("customerid")
   RETURN -1
END IF

dw_master.object.customernm[1] 	= ls_customernm
dw_master.object.customerid[1] 	= ls_customerid

RETURN 0

end function

public subroutine wf_protect (string ai_gubun);STRING	ls_np_did, ls_np_ori_carrier

dw_master.AcceptText()

CHOOSE CASE ai_gubun
	CASE "N"
		dw_master.Object.customerid.Color = RGB(255,255,255)						//글씨색
		dw_master.Object.customerid.Background.Color = RGB(107, 146, 140)		//필수 배경색
		dw_master.Object.customerid.protect	= 0
		dw_master.Object.lastname.protect 	= 1
		dw_master.Object.firstname.protect 	= 1
		dw_master.Object.midname.protect 	= 1
		dw_master.Object.basecod.protect 	= 1
		dw_master.Object.buildingno.protect = 1
		dw_master.Object.roomno.protect 		= 1
		dw_master.Object.homephone.protect 	= 1
		dw_master.Object.derosdt.protect 	= 1		
	CASE "Y"
		dw_master.Object.customerid.Color = RGB(0,0,0)								//글씨색
		dw_master.Object.customerid.Background.Color = RGB(255, 255, 255)		//선택 배경색		
		dw_master.Object.customerid.protect	= 1		
		dw_master.Object.lastname.protect 	= 0
		dw_master.Object.firstname.protect 	= 0
		dw_master.Object.midname.protect		= 0
		dw_master.Object.basecod.protect 	= 0
		dw_master.Object.buildingno.protect = 0
		dw_master.Object.roomno.protect 		= 0
		dw_master.Object.homephone.protect 	= 0
		dw_master.Object.derosdt.protect 	= 0		

END CHOOSE



end subroutine

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

on ubs_w_reg_mobileorder.create
int iCurrent
call super::create
this.cb_1=create cb_1
this.p_reset=create p_reset
this.st_horizontal=create st_horizontal
this.dw_detail=create dw_detail
this.dw_master=create dw_master
this.p_close=create p_close
this.p_print=create p_print
this.p_save=create p_save
this.p_payment=create p_payment
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
this.Control[iCurrent+2]=this.p_reset
this.Control[iCurrent+3]=this.st_horizontal
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.dw_master
this.Control[iCurrent+6]=this.p_close
this.Control[iCurrent+7]=this.p_print
this.Control[iCurrent+8]=this.p_save
this.Control[iCurrent+9]=this.p_payment
end on

on ubs_w_reg_mobileorder.destroy
call super::destroy
destroy(this.cb_1)
destroy(this.p_reset)
destroy(this.st_horizontal)
destroy(this.dw_detail)
destroy(this.dw_master)
destroy(this.p_close)
destroy(this.p_print)
destroy(this.p_save)
destroy(this.p_payment)
end on

event open;call super::open;//=========================================================//
// Desciption : 모바일 신규 신청을 받는 화면               //
// Name       : ubs_w_reg_mobileorder		                 //
// Contents   : 모바일 신규 신청을 받는다. 신규 또는 기존  //
//              고객을 대상으로 한다.		                 //
// Data Window: dw - ubs_dw_reg_mobileorder_mas		        // 
//							ubs_dw_reg_mobileorder_det				  //
// 작성일자   : 2009.03.13                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc

iu_cust_db_app = CREATE u_cust_db_app

// Set the Top, Bottom Controls
idrg_Top = dw_master
idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

is_amt_check = 'N'       //프린트 팝업 확인 초기 값
is_print_check = 'N'     //수납팝업 확인 초기 값

dw_master.InsertRow(0)
dw_detail.InsertRow(0)

ls_ref_desc = ""
is_admst_status = fs_get_control("E1", "A104", ls_ref_desc)
is_return_status = fs_get_control("E1", "A102", ls_ref_desc)

dw_master.Object.lease_period_from[1] = DATE(fdt_get_dbserver_now())

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_master.SetItemStatus(1, 0, Primary!, NotModified!)

dw_master.SetFocus()
dw_master.SetColumn("new_customer")
//기본 세팅
wf_protect('N')  

end event

event close;call super::close;DESTROY	iu_cust_db_app
end event

event resize;call super::resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_detail.Height = 0
  
	p_payment.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_print.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
ELSE
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
   p_payment.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_print.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
END IF

IF newwidth < dw_detail.X  THEN
	dw_detail.Width = 0
ELSE
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
END IF

IF newwidth < dw_master.X  THEN
	dw_master.Width = 0
ELSE
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
END IF

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(TRUE)

end event

event closequery;Int li_rc

dw_master.AcceptText()

If (dw_master.ModifiedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then
		Return 1 //Process Cancel
	Else		
		If is_amt_check = 'Y' or is_print_check = 'Y' THEN
			F_MSG_INFO(9000, Title, "수납 또는 계약서 출력을 하셨습니다. 계약서 저장을 하셔야 합니다.")
			Return 1
		End if
	End if
End If
end event

type cb_1 from commandbutton within ubs_w_reg_mobileorder
event ue_clip ( string as_value )
boolean visible = false
integer x = 2926
integer y = 1428
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
end type

event ue_clip;Clipboard(as_value)
end event

type p_reset from u_p_reset within ubs_w_reg_mobileorder
integer x = 965
integer y = 1536
end type

type st_horizontal from statictext within ubs_w_reg_mobileorder
event mousedown pbm_lbuttondown
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
integer x = 18
integer y = 1120
integer width = 553
integer height = 36
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16776960
boolean focusrectangle = false
end type

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.

end event

event mousemove(unsignedlong flags, integer xpos, integer ypos);Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = Y

	// Refresh the Bar attributes.
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
	If Not IsValid(idrg_Bottom) Then Return
	If li_prevposition > idrg_Bottom.Y Then idrg_Bottom.SetRedraw(True)
End If

end event

event mouseup;//// Hide the bar
//BackColor = il_HiddenColor
//
//// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()
//
end event

type dw_detail from u_d_base within ubs_w_reg_mobileorder
integer x = 14
integer y = 1160
integer width = 2007
integer height = 332
integer taborder = 20
string dataobject = "ubs_dw_reg_mobileorder_det"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

type dw_master from u_d_help within ubs_w_reg_mobileorder
integer x = 14
integer y = 16
integer width = 3579
integer height = 1104
integer taborder = 10
string dataobject = "ubs_dw_reg_mobileorder_mas"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;INTEGER	li_exist
BOOLEAN	lb_check
STRING	ls_filter,		ld_lease_period,		ls_lastname,		ls_firstname,		ls_midname,		&
			ls_basecod,		ls_buildingno, 		ls_roomno,			ls_unit,				ls_homephone,	&
			ls_customerid,	ls_new_customer
DATETIME	ld_derosdt

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid"
		ls_new_customer = THIS.Object.new_customer[row]
		
		IF ls_new_customer = "Y" THEN
			F_MSG_INFO(9000, Title, "신규고객은 ID를 선택할 수 없습니다")
			RETURN -1
		END IF
END CHOOSE

Call u_d_help::doubleclicked

CHOOSE CASE dwo.name
	CASE "customerid"
		IF iu_cust_help.ib_data[1] THEN
			is_cus_status 				= iu_cust_help.is_data[3]
				
			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 THEN
				RETURN -1
			END IF
				
			ls_customerid = THIS.Object.customerid[row]			
			
			SELECT LASTNAME, FIRSTNAME, MIDNAME, 
					 BASECOD, BUILDINGNO, ROOMNO, 
					 UNIT, HOMEPHONE, DEROSDT
			INTO   :ls_lastname, :ls_firstname, :ls_midname,
					 :ls_basecod, :ls_buildingno, :ls_roomno,
					 :ls_unit, :ls_homephone, :ld_derosdt
			FROM   CUSTOMERM
			WHERE  CUSTOMERID = :ls_customerid;
			
			THIS.Object.lastname[row]   = ls_lastname
			THIS.Object.firstname[row]  = ls_firstname
			THIS.Object.midname[row]    = ls_midname
			THIS.Object.basecod[row]    = ls_basecod
			THIS.Object.buildingno[row] = ls_buildingno
			THIS.Object.roomno[row]     = ls_roomno
			THIS.Object.unit[row]       = ls_unit
			THIS.Object.homephone[row]  = ls_homephone
			THIS.Object.derosdt[row]    = ld_derosdt					
			
		END IF
END CHOOSE

RETURN 0 
end event

event ue_init();call super::ue_init;//Help Window
THIS.idwo_help_col[1] 	= THIS.Object.customerid
THIS.is_help_win[1] 		= "SSRT_hlp_customer"
THIS.is_data[1] 			= "CloseWithReturn"

dw_master.SetFocus()
dw_master.SetRow(1)
dw_master.SetColumn('customerid')
end event

event itemchanged;call super::itemchanged;INTEGER	li_exist
BOOLEAN	lb_check
STRING	ls_filter,			ls_lease_period,		 ls_sysdate,		ls_cont_period,		ls_serialno,	&
			ls_phone_model, 	ls_phone_type,			 ls_customerid,	ls_lastname,			ls_firstname,	&
			ls_midname,			ls_basecod,				 ls_buildingno,	ls_roomno,				ls_unit,			&
			ls_homephone,		ls_lease_period_from, ls_bill_item,		ls_lease_item,			ls_card_item,	&
			ls_modelno
LONG		ll_day, 				ll_extdays, 			 ll_cnt
DEC{2}	ldc_sale_amt,		ldc_bill_amt,			 ldc_lease_amt
DATE		ld_derosdt

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid"
		IF wfi_get_customerid(data, "") = -1 THEN
			RETURN -1
		END IF
			
		SELECT LASTNAME, FIRSTNAME, MIDNAME, 
				 BASECOD, BUILDINGNO, ROOMNO, 
				 UNIT, HOMEPHONE, DEROSDT
		INTO   :ls_lastname, :ls_firstname, :ls_midname,
				 :ls_basecod, :ls_buildingno, :ls_roomno,
				 :ls_unit, :ls_homephone, :ld_derosdt
		FROM   CUSTOMERM
		WHERE  CUSTOMERID = :data;
		
		THIS.Object.lastname[row]   = ls_lastname
		THIS.Object.firstname[row]  = ls_firstname
		THIS.Object.midname[row]    = ls_midname
		THIS.Object.basecod[row]    = ls_basecod
		THIS.Object.buildingno[row] = ls_buildingno
		THIS.Object.roomno[row]     = ls_roomno
		THIS.Object.unit[row]       = ls_unit
		THIS.Object.homephone[row]  = ls_homephone
		THIS.Object.derosdt[row]    = ld_derosdt					
		
		
	CASE "new_customer"
		ls_customerid = THIS.Object.customerid[row]
		
		IF IsNull(ls_customerid) OR ls_customerid = "" THEN ls_customerid = ""
					
		IF ls_customerid <> "" THEN
			F_MSG_INFO(9000, Title, "고객 ID가 선택되어 있으면 신규고객을 클릭할 수 없습니다.")
			THIS.Object.new_customer[row] = "N"
			RETURN 2			
		END IF
		
		wf_protect(data)

	CASE "lease_period"
		ls_lease_period_from = STRING(THIS.Object.lease_period_from[1], 'YYYYMMDD')
		ls_lease_period 		= STRING(THIS.Object.lease_period[1], 'YYYYMMDD')

		//날짜 계산.
		SELECT  (TO_DATE(:ls_lease_period, 'yyyymmdd') - TO_DATE(:ls_lease_period_from, 'YYYYMMDD')) + 1
				, TO_CHAR(SYSDATE, 'YYYYMMDD')
		INTO    :ll_day, :ls_sysdate
		FROM    DUAL;		
		
		IF ls_lease_period < ls_lease_period_from THEN
			F_MSG_INFO(9000, Title, "시작일 보다 이전으로 입력할 수 없습니다.")
			THIS.Object.lease_period[1] = fdt_get_dbserver_now()
			RETURN 2
		END IF			
		
		//Contract Period 계산
		SELECT MIN(EXTDAYS) INTO :il_extdays
		FROM   ITEMMST_MOBILE
		WHERE  EXTDAYS = ( SELECT MIN(EXTDAYS)
								 FROM   ITEMMST_MOBILE
								 WHERE  EXTDAYS >= :ll_day
								 AND    PERIOD_YN = 'Y' )
		AND    PERIOD_YN = 'Y';
		
		//contract Period 구하기						 
		SELECT TO_CHAR(TO_DATE(:ls_lease_period_from, 'YYYYMMDD') + :il_extdays - 1 , 'YYYYMMDD')
		INTO   :is_cont_period
		FROM   DUAL;
		
		dw_master.Object.contract_period[1] = MidA(ls_lease_period_from, 5, 2)+"-"+MidA(ls_lease_period_from, 7, 2)+"-"+MidA(ls_lease_period_from, 1, 4)+ &
														  " ∼ " + MidA(is_cont_period, 5, 2)+"-"+MidA(is_cont_period, 7, 2)+"/"+MidA(is_cont_period, 1, 4)
		//dw_detail.Object.lease[1] = idc_bil_amt		
		
	CASE "contno"	
		
		IF il_extdays = 0 OR IsNull(il_extdays) THEN
			F_MSG_INFO(9000, Title, "계약 기간을 먼저 선택하세요!")						
			THIS.Object.contno[1] 		= ""
			THIS.Object.phone_type[1]	= ""
			THIS.Object.serialno[1] 	= ""
			THIS.Object.phone_model[1] = ""					
			RETURN 2
		END IF			
		
//		IF IsNumber(data) = FALSE THEN
//			F_MSG_INFO(9000, Title, "숫자만 입력하세요!")						
//			THIS.Object.contno[1] 		= ""
//			THIS.Object.phone_type[1]	= ""
//			THIS.Object.serialno[1] 	= ""
//			THIS.Object.phone_model[1] = ""					
//			RETURN 2
//		END IF		
		
		SELECT COUNT(*), MIN(SERIALNO), MIN(PHONE_MODEL), MIN(PHONE_TYPE)
		INTO   :ll_cnt, :ls_serialno, :ls_phone_model, :ls_phone_type
		FROM   AD_MOBILE_RENTAL
		WHERE  CONTNO = :data
		AND    STATUS IN ( :is_admst_status, :is_return_status )
		AND    SHOPID = :gs_shopid;
		
		IF ll_cnt <= 0 THEN
			F_MSG_INFO(9000, Title, "Phone Control No가 유효하지 않습니다")						
			THIS.Object.contno[1] = ""
			RETURN 2
		END IF
		
		THIS.Object.phone_type[1] 	= ls_phone_type
		THIS.Object.serialno[1]		= ls_serialno
		THIS.Object.phone_model[1] = ls_phone_model		
		
		//item, 금액 세팅!
		SELECT ITEMCOD, BILL_AMT INTO :ls_bill_item, :ldc_bill_amt
		FROM   ITEMMST_MOBILE
		WHERE  PHONE_TYPE = :ls_phone_type
		AND    DEFAULT_YN = 'Y';
	
		dw_detail.Object.deposit[1]		= ldc_bill_amt		
		dw_detail.Object.item_deposit[1] = ls_bill_item	
		
		//lease fee 세팅!		
		SELECT ITEMCOD, BILL_AMT INTO :ls_lease_item, :ldc_lease_amt
		FROM   ITEMMST_MOBILE
		WHERE  PHONE_TYPE = :ls_phone_type
		AND    EXTDAYS    = :il_extdays
		AND    PERIOD_YN  = 'Y';
		
		dw_detail.Object.lease[1]		 = ldc_lease_amt		
		dw_detail.Object.item_lease[1] = ls_lease_item			
		
	CASE "admst_contno"	
		
//		IF IsNumber(data) = FALSE THEN
//			F_MSG_INFO(9000, Title, "숫자만 입력하세요!")						
//			THIS.Object.admst_contno[1] = ""
//			RETURN 2
//		END IF	
		
		SELECT COUNT(*), MAX(ADMODEL.MODELNO) INTO :ll_cnt, :ls_modelno
		FROM   ADMST, ADMODEL
		WHERE  ADMST.CONTNO = :data
		AND    ADMST.STATUS = :is_admst_status		
		AND    ADMST.MODELNO = ADMODEL.MODELNO;
		
		IF ll_cnt <= 0 THEN
			F_MSG_INFO(9000, Title, "Act. Card No가 유효하지 않습니다")			
			THIS.Object.admst_contno[1] = ""
			RETURN 2
		END IF
		
		SELECT SALE_UNITAMT INTO :ldc_sale_amt
		FROM   MODEL_PRICE
		WHERE  MODELNO = :ls_modelno
		AND	 TO_CHAR(FROMDT, 'YYYYMMDD') = ( SELECT MAX(TO_CHAR(FROMDT, 'YYYYMMDD'))
															FROM   MODEL_PRICE
															WHERE  MODELNO = :ls_modelno
															AND    TO_CHAR(FROMDT, 'YYYYMMDD') <= TO_CHAR(SYSDATE, 'YYYYMMDD') );
															
		
		SELECT ITEMCOD INTO :ls_card_item
		FROM   ADMODEL_ITEM
		WHERE  MODELNO = :ls_modelno;
		
		dw_detail.Object.activation[1] = ldc_sale_amt	
		dw_detail.Object.item_activ[1] = ls_card_item

	CASE "validkey"
		IF IsNumber(data) = FALSE THEN
			F_MSG_INFO(9000, Title, "숫자만 입력하세요!")						
			THIS.Object.validkey[1] = ""
			RETURN 2
		END IF
		
		ls_lease_period_from = STRING(THIS.Object.lease_period_from[1], 'YYYYMMDD')
		
		SELECT COUNT(VALIDKEY)
		INTO   :ll_cnt
		FROM   VALIDINFO
		WHERE  ((TO_CHAR(FROMDT, 'YYYYMMDD') > :ls_lease_period_from ) OR
				  (TO_CHAR(FROMDT, 'YYYYMMDD') <= :ls_lease_period_from AND
				   :ls_lease_period_from < NVL(TO_CHAR(TODT, 'YYYYMMDD'), '99991231')) )
		AND    VALIDKEY = :data;
//		AND	 SVCCOD = :

		IF ll_cnt > 0 THEN
			F_MSG_INFO(9000, Title, "전화번호 사용기간이 중복됩니다.")
			THIS.Object.validkey[1] = ""
			RETURN 2
		END IF	
		
END CHOOSE

RETURN 0 
end event

event buttonclicked;call super::buttonclicked;u_cust_a_msg iu_cust_help2
STRING	ls_lease_period

IF dwo.name = 'b_1' THEN
	iu_cust_help2 = CREATE u_cust_a_msg
	
	iu_cust_help2.is_pgm_name = "Calendar"
	iu_cust_help2.is_grp_name = "날짜선택"
	iu_cust_help2.ib_data[1]  = True
	iu_cust_help2.idw_data[1] = dw_master
	
	OpenWithParm(ubs_w_pop_calendar, iu_cust_help2)	
	
	destroy iu_cust_help2
	
END IF	

	
end event

event rbuttondown;call super::rbuttondown;STRING ls_temp, ls_coltype

IF dwo.type = "column" THEN
	
	IF MidA(String(dwo.coltype), 1, 2) = "ch" THEN											//Char
		ls_temp = THIS.GetItemString(row, String(dwo.name))
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "da" THEN										//Datetime
		ls_temp = String(THIS.GetItemDateTime(row, String(dwo.name)), 'mm-dd-yyyy')
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "nu" THEN										//Number
		ls_temp = String(THIS.GetItemNumber(row, String(dwo.name)))
	ELSEIF MidA(String(dwo.coltype), 1, 2) = "de" THEN										//Decimal
		ls_temp = String(THIS.GetItemDecimal(row, String(dwo.name)))
	ELSE																									//Else
		RETURN
	END IF
	
	IF IsNull(ls_temp) OR ls_temp = "" THEN RETURN			
	PARENT.POST Event ue_clip(ls_temp)	
	
END IF
end event

type p_close from u_p_close within ubs_w_reg_mobileorder
integer x = 1285
integer y = 1536
boolean originalsize = false
end type

type p_print from u_p_print within ubs_w_reg_mobileorder
integer x = 329
integer y = 1536
boolean originalsize = false
end type

event clicked;INTEGER	li_rc

dw_master.AcceptText()
dw_detail.AcceptText()

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.
PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Mobile Contract Print"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.idw_data[2] = dw_detail

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_mobilecontract, iu_cust_msg)

IF iu_cust_msg.ib_data[1] THEN
	//is_print_check 값 세팅!  - 출력 팝업에서 반환되는 값. 완료 : 'Y', 미완료:'N'
	is_print_check = iu_cust_msg.is_data[1]
END IF

DESTROY iu_cust_msg

RETURN 0


end event

type p_save from u_p_save within ubs_w_reg_mobileorder
integer x = 645
integer y = 1536
boolean originalsize = false
end type

event clicked;INTEGER		 li_rc
CONSTANT	INT LI_ERROR = -1

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.

PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

PARENT.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

PARENT.TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
	F_MSG_INFO(3010, PARENT.Title, "Save")
	
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = PARENT.Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN LI_ERROR
	END IF
	
	RETURN LI_ERROR
ELSEIF li_rc = 0 THEN
	
	F_MSG_INFO(3000, PARENT.Title, "Save")
		
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = PARENT.Title

	iu_cust_db_app.uf_prc_db()

	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN LI_ERROR
	END IF
	
END IF

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
	
end event

type p_payment from u_p_payment within ubs_w_reg_mobileorder
integer x = 14
integer y = 1536
boolean originalsize = false
end type

event clicked;INTEGER	li_rc
STRING	ls_customerid,		ls_customernm,		ls_phone_type,		ls_new_customer, &
			ls_save_check, 	ls_item_deposit,	ls_item_lease,		ls_item_activ,		ls_paydt
DEC{2}	ldc_deposit,		ldc_lease,			ldc_activ			

dw_master.AcceptText()
dw_detail.AcceptText()

ls_new_customer = dw_master.Object.new_customer[1]
ls_customerid 	 = dw_master.Object.customerid[1]
ls_customernm 	 = dw_master.Object.customernm[1]
ls_phone_type 	 = dw_master.Object.phone_type[1]

ls_item_deposit = dw_detail.Object.item_deposit[1]
ls_item_lease   = dw_detail.Object.item_lease[1]
ls_item_activ   = dw_detail.Object.item_activ[1]

ldc_deposit 	 = dw_detail.Object.deposit[1]
ldc_lease 		 = dw_detail.Object.lease[1]
ldc_activ 		 = dw_detail.Object.activation[1]

IF IsNull(ls_item_deposit) THEN ls_item_deposit = ""
IF IsNull(ls_item_lease) 	THEN ls_item_lease = ""
IF IsNull(ls_item_activ) 	THEN ls_item_activ = ""

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.

PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

IF ls_new_customer = 'Y' THEN
	IF IsNull(ls_customerid) OR ls_customerid = "" THEN			//고객 ID가 있다면 이미 실행됐음!
		PARENT.TRIGGER EVENT ue_process_customer(li_rc)

		IF li_rc <> 0 THEN
			ROLLBACK;
			RETURN -1
		ELSEIF li_rc = 0 THEN
			COMMIT;
			ls_customerid 	 = dw_master.Object.customerid[1]
			ls_customernm 	 = dw_master.Object.customernm[1]		
		END IF
	END IF		
END IF

//이미 수납을 했는지 확인
IF is_amt_check = 'Y' THEN 
	ls_save_check = 'Y'
ELSE
	ls_save_check = 'N'
END IF	

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Mobile Contract Payment"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.idw_data[2] = dw_detail
iu_cust_msg.is_data[2]  = ls_customerid
iu_cust_msg.is_data[3]  = ls_customernm
iu_cust_msg.is_data[4]  = ls_phone_type
iu_cust_msg.is_data[5]  = ls_save_check
//품목넘김
iu_cust_msg.il_data[2]  = 3							//item 갯수
iu_cust_msg.is_data2[1] = ls_item_deposit   		//deposit
iu_cust_msg.is_data2[2] = ls_item_lease  			//lease
iu_cust_msg.is_data2[3] = ls_item_activ  			//activation
iu_cust_msg.ic_data[1]  = ldc_deposit	   		//deposit fee
iu_cust_msg.ic_data[2]  = ldc_lease	   			//lease fee
iu_cust_msg.ic_data[3]  = ldc_activ	   			//activation fee

//수납을 위한 팝업 연결
OpenWithParm(ubs_w_pop_mobilepayment, iu_cust_msg)

//is_amt_check 값 세팅 : 수납 팝업에서 반환되는 값. 완료:'N', 미완료:'Y'
IF iu_cust_msg.ib_data[1] THEN
	is_amt_check = iu_cust_msg.is_data[1]
	is_paydt		 = iu_cust_msg.is_data[2]	
	is_appseq    = iu_cust_msg.is_data[3]	
END IF

ls_paydt = is_paydt

DESTROY iu_cust_msg

RETURN 0
end event

