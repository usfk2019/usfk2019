$PBExportHeader$ubs_w_reg_equipmove.srw
$PBExportComments$[jhchoi] 인증장비 이동 - 2009.04.13
forward
global type ubs_w_reg_equipmove from w_a_reg_m
end type
type p_transfer from u_p_transfer within ubs_w_reg_equipmove
end type
type p_confirm from u_p_confirm within ubs_w_reg_equipmove
end type
end forward

global type ubs_w_reg_equipmove from w_a_reg_m
integer width = 2967
integer height = 1928
event type integer ue_confirm ( )
event type integer ue_transfer ( )
p_transfer p_transfer
p_confirm p_confirm
end type
global ubs_w_reg_equipmove ubs_w_reg_equipmove

type variables
String is_move, is_sale, is_return, is_all, is_new, is_put[], is_get[]
end variables

forward prototypes
public subroutine wf_set_total ()
end prototypes

event ue_confirm;INTEGER	li_chk
STRING 	ls_chk,		ls_status, 		ls_contno,   ls_emp_group,		ls_partner,	&
			ls_action
LONG		ll_cnt,		ll_equipseq,	ii

// Move ==> Sale 

ll_cnt =  dw_detail.rowCount()
IF dw_detail.Object.cp_tot[ll_cnt]  =  0 THEN
	f_msg_usr_err(9000, Title, "처리하고자 하는 장비를 선택하세요.")
	dw_detail.SetFocus()
	RETURN -1
END IF

//로그 행위(action)추출
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A102';	


//그룹 체크
SELECT EMP_GROUP INTO :ls_emp_group
FROM	 SYSUSR1T
WHERE  EMP_ID = :gs_user_id;

FOR ii = 1 TO ll_cnt
	li_chk 		= dw_detail.Object.chk[ii]
	ls_status 	= Trim(dw_detail.Object.status[ii])
	ls_contno 	= Trim(dw_detail.Object.contno[ii])
	ll_equipseq	= dw_detail.Object.equipseq[ii]
	IF li_chk = 1 THEN		//선택일 경우		
		IF ls_status <> is_move THEN		//상태가 이동중일 때만 처리 가능!
			f_msg_usr_err(9000, Title, "Control No : " + ls_contno + "의 상태를 확인하세요")
			ROLLBACK;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			RETURN -1
		END IF
		
		SELECT TO_PARTNER INTO :ls_partner
		FROM   EQUIPMST 
		WHERE  EQUIPSEQ = :ll_equipseq;
		
		IF ls_partner <> ls_emp_group THEN
			f_msg_usr_err(9000, Title, "샵 권한이 불충분합니다. Control No : " + ls_contno )
			ROLLBACK;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			RETURN -1			
		END IF		
		
		//UPDATE EQUIPMOVEMST
		UPDATE EQUIPMOVEMST
      SET	 GET_DT 		= SYSDATE,
				 STATUS 		= :is_sale,
				 GET_USER 	= :gs_user_id,
				 UPDTDT 		= SYSDATE,
				 UPDT_USER	= :gs_user_id,
				 PGM_ID 		= :gs_pgm_id[gi_open_win_no]
		WHERE  EQUIPSEQ 	= :ll_equipseq;
			  
		IF sqlca.sqlcode < 0 THEN
			f_msg_usr_err(9000, Title, "Update Error( EQUIPMOVEMST ) ==> EQUIPSEQ : " + String(ll_equipseq))
			ROLLBACK;
			RETURN -1
		END IF		
		
		//UPDATE EQUIPMST
		UPDATE EQUIPMST
		SET	 SN_PARTNER  = :gs_shopid,
				 SNMOVEDT	 = SYSDATE,
				 STATUS		 = :is_sale,
				 CUSTOMERID  = NULL,
				 CONTRACTSEQ = NULL,
				 ORDERNO     = NULL,
				 CUST_NO		 = NULL,		 				 
				 UPDTDT 		= SYSDATE,
				 UPDT_USER 	= :gs_user_id,
				 PGM_ID 		= :gs_pgm_id[gi_open_win_no]
		WHERE  EQUIPSEQ 	= :ll_equipseq;
			  
		IF sqlca.sqlcode < 0 THEN
			f_msg_usr_err(9000, Title, "Update Error( EQUIPMST ) ==> EQUIPSEQ : " + String(ll_equipseq))
			ROLLBACK;
			RETURN -1
		END IF
		//INSERT EQUIPLOG
		INSERT INTO EQUIPLOG
		(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
		 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
		 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
		 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
		SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
				 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
				 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
				 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
				 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
				 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
				 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
				 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
				 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
				 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
		FROM   EQUIPMST
		WHERE  EQUIPSEQ = :ll_equipseq;			
		
		
	END IF
NEXT

COMMIT;

f_msg_info(3000, Title, "Confirm")

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
THIS.TriggerEvent("ue_ok")

RETURN 0
end event

event ue_transfer;Integer	ii, li_chk
String 	ls_chk,			ls_shop,			ls_status,		ls_contno,	&
			ls_emp_group,	ls_partner, 	ls_remark,		ls_macaddr,	&
			ls_action
Long		ll_cnt,			ll_equipseq,	ll_moveno

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Select Shop"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_detail

//샵 선택 팝업
OpenWithParm(ubs_w_pop_selectshop, iu_cust_msg)

//is_amt_check 값 세팅 : 수납 팝업에서 반환되는 값. 완료:'N', 미완료:'Y'
IF iu_cust_msg.ib_data[1] THEN
	ls_shop	 = iu_cust_msg.is_data[1]
	ls_remark = iu_cust_msg.is_data[2]
END IF

DESTROY iu_cust_msg

IF IsNull(ls_shop) THEN ls_shop = ''
IF ls_shop = "" THEN
	f_msg_usr_err(200, Title, "shop")
	RETURN -1
END IF

// Sale, Return ==> Move 
ll_cnt =  dw_detail.rowCount()
IF dw_detail.Object.cp_tot[ll_cnt]  =  0 THEN
	f_msg_usr_err(9000, Title, "처리하고자 하는 장비를 선택하세요.")
	dw_detail.SetFocus()
	RETURN -1
END IF

//로그 행위(action)추출
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A101';	

SELECT EMP_GROUP INTO :ls_emp_group FROM SYSUSR1T WHERE EMP_ID = :gs_user_id;

FOR ii = 1 TO ll_cnt
	li_chk 		= dw_detail.Object.chk[ii]
	ls_status 	= Trim(dw_detail.Object.status[ii])
	ls_macaddr	= Trim(dw_detail.Object.mac_addr[ii])
	ll_equipseq = dw_detail.Object.equipseq[ii]	

	IF li_chk = 1 THEN
		IF ls_status = is_new OR ls_status = is_return THEN   //( ls_status = is_sale OR ls_status = is_return ) THEN    //입고나 반환상태인 데이터만 
		ELSE
			f_msg_usr_err(9000, Title, "Mac Address : " + ls_macaddr + "의 상태를 확인하세요")
			ROLLBACK ;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			RETURN -1
		END IF
		
		SELECT SN_PARTNER INTO :ls_partner FROM EQUIPMST WHERE EQUIPSEQ = :ll_equipseq;
		
   	IF ls_partner <> ls_emp_group THEN
			f_msg_usr_err(9000, Title, "해당 물품은 이동할 수 있는 권한이 없습니다. Mac Address : " + ls_macaddr )
			ROLLBACK ;
			dw_detail.SetFocus()
			dw_detail.SetRow(ii)
			RETURN -1
		END IF
		
		SELECT SEQ_EQUIPMOVE.NEXTVAL INTO :ll_moveno FROM DUAL;				
		
		//INSERT EQUIPMOVEMST
		INSERT INTO EQUIPMOVEMST
					( MOVENO,		EQUIPSEQ,		FR_PARTNER, 	TO_PARTNER, 
					  TNS_DT, 		STATUS,			TNS_USER,		REMARK,
					  CRT_USER,		CRTDT,			PGM_ID )
		VALUES   (:ll_moveno,	:ll_equipseq,	:gs_shopid,		:ls_shop,
					 SYSDATE,		:is_move, 		:gs_user_id,	:ls_remark,
					 :gs_user_id,	SYSDATE,			:gs_pgm_id[gi_open_win_no] );
				  
		IF sqlca.sqlcode < 0 THEN
			f_msg_usr_err(9000, Title, "Insert Error( EQUIPMOVEMST ) ==> EQUIPSEQ : " + String(ll_equipseq))
			ROLLBACK;
			RETURN -1
		END IF		
		
		//UPDATE EQUIPMST
		UPDATE EQUIPMST
		SET	 MOVENO		= :ll_moveno,
				 TO_PARTNER = :ls_shop,
				 MV_PARTNER = :gs_shopid,	
				 DLVDT		= SYSDATE,
				 STATUS		= :is_move,
				 UPDTDT 		= SYSDATE,
				 UPDT_USER 	= :gs_user_id,
				 PGM_ID 		= :gs_pgm_id[gi_open_win_no]
		WHERE  EQUIPSEQ 	= :ll_equipseq;
			  
		IF sqlca.sqlcode < 0 THEN
			f_msg_usr_err(9000, Title, "Update Error( EQUIPMST ) ==> EQUIPSEQ : " + String(ll_equipseq))
			ROLLBACK;
			RETURN -1
		END IF	
		
		//INSERT EQUIPLOG
		INSERT INTO EQUIPLOG
		(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
		 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
		 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
		 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
		SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
				 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
				 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
				 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
				 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
				 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
				 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
				 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
				 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
				 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
		FROM   EQUIPMST
		WHERE  EQUIPSEQ = :ll_equipseq;					
		
		IF sqlca.sqlcode < 0 THEN
			f_msg_usr_err(9000, Title, "Update Error( EQUIPLOG ) ==> EQUIPSEQ : " + String(ll_equipseq))
			ROLLBACK;
			RETURN -1
		END IF			

	END IF
NEXT

COMMIT;
f_msg_info(3000, Title, "Transfer")
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

THIS.TriggerEvent("ue_reset")

RETURN 0
end event

public subroutine wf_set_total ();dec{2} ldc_TOTAL, ldc_receive, ldc_change, &
			ldc_tot1, ldc_tot2, ldc_tot3

ldc_total = 0
ldc_tot1 = 0
ldc_tot2 = 0
ldc_tot3 = 0

IF dw_detail.RowCount() > 0 THEN
	ldc_total 	=  dw_detail.GetItemNumber(dw_detail.RowCount(), "cp_refund")
END IF
dw_cond.Object.total[1] 		= ldc_total

//
//F_INIT_DSP(2, "", String(ldc_total))
//
return 
end subroutine

on ubs_w_reg_equipmove.create
int iCurrent
call super::create
this.p_transfer=create p_transfer
this.p_confirm=create p_confirm
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_transfer
this.Control[iCurrent+2]=this.p_confirm
end on

on ubs_w_reg_equipmove.destroy
call super::destroy
destroy(this.p_transfer)
destroy(this.p_confirm)
end on

event ue_ok;STRING 	ls_where,  			ls_partner, 		ls_status, &
		 	ls_contno_fr, 		ls_contno_to,		ls_adtype, &
			ls_modelno,			ls_enter_fr,		ls_enter_to, &
			ls_dacom_fr,		ls_dacom_to,		ls_serial_fr, &
			ls_serial_to,		ls_status_where,  ls_mac_addr
LONG 		ll_row
INT		li_i

//인수 상태값(P) : 100, 300, 500, 600
//인계 상태값(G) : 200

dw_cond.AcceptText()

ls_status 		= Trim(dw_cond.object.status[1])
ls_adtype 		= Trim(dw_cond.object.adtype[1])
ls_modelno 		= Trim(dw_cond.object.modelno[1])
ls_enter_fr    = STRING(dw_cond.object.enter_fr[1], 'yyyymmdd')
ls_enter_to    = STRING(dw_cond.object.enter_to[1], 'yyyymmdd')
ls_dacom_fr		= UPPER(Trim(dw_cond.object.dacom_fr[1]))
ls_dacom_to		= UPPER(Trim(dw_cond.object.dacom_to[1]))
ls_serial_fr	= Trim(dw_cond.object.serial_fr[1])
ls_serial_to	= Trim(dw_cond.object.serial_to[1])
//start 2013.04.30 Mac_addr 추가 [RQ-UBS-201304-10] 근거
ls_mac_addr		= Trim(dw_cond.object.macaddr[1])
//end
//2009.06.10 jhchoi 제거
//ls_contno_fr	= Trim(dw_cond.object.contno_fr[1])
//ls_contno_to	= Trim(dw_cond.object.contno_to[1])

IF IsNull(ls_status) 		THEN ls_status 		= ""
IF IsNull(ls_adtype) 		THEN ls_adtype 		= ""
IF IsNull(ls_modelno) 		THEN ls_modelno 		= ""
IF IsNull(ls_enter_fr) 		THEN ls_enter_fr 		= ""
IF IsNull(ls_enter_to) 		THEN ls_enter_to 		= ""
IF IsNull(ls_dacom_fr) 		THEN ls_dacom_fr 		= ""
IF IsNull(ls_dacom_to) 		THEN ls_dacom_to 		= ""
IF IsNull(ls_serial_fr)		THEN ls_serial_fr 	= ""
IF IsNull(ls_serial_to)		THEN ls_serial_to 	= ""
IF IsNull(ls_mac_addr)		THEN ls_mac_addr 		= "%"
//IF IsNull(ls_contno_fr) 	THEN ls_contno_fr 	= ""
//IF IsNull(ls_contno_to) 	THEN ls_contno_to 	= ""

IF ls_status = "" THEN
	f_msg_usr_err(200, Title, "Status")
	dw_cond.SetFocus()
	dw_cond.SetRow(1)
	dw_cond.SetColumn("status")
	RETURN
END IF

ls_where = ""
ls_status_where = ""
IF ls_status = 'P' THEN
	FOR li_i = 1 TO UpperBound(is_put[])
		IF ls_status_where <> ""  THEN ls_status_where += ", "
		ls_status_where += "'" + is_put[li_i] + "'"
	NEXT
	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.STATUS IN (" + ls_status_where + ") "
	ls_where += " AND EQUIPMST.SN_PARTNER = '" + GS_SHOPID + "' "
ELSE
	FOR li_i = 1 TO UpperBound(is_get[])
		IF ls_status_where <> ""  THEN ls_status_where += ", "
		ls_status_where += "'" + is_get[li_i] + "'"
	NEXT
	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.STATUS IN (" + ls_status_where + ") "
	ls_where += " AND EQUIPMST.TO_PARTNER = '" + GS_SHOPID + "' "		
END IF

//ADTYPE
IF ls_adtype <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.ADTYPE = '" + ls_adtype + "' "
END IF

//MODEL NO
IF ls_modelno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.MODELNO = '" + ls_modelno + "' "
END IF

//Entering Date
IF ls_enter_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " TO_CHAR(EQUIPMST.IDATE, 'YYYYMMDD') >= '" + ls_enter_fr + "' "
END IF
IF ls_enter_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " TO_CHAR(EQUIPMST.IDATE, 'YYYYMMDD') <= '" + ls_enter_to + "' "
END IF

//DACOM MNG NO From ~ To
IF ls_dacom_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.DACOM_MNG_NO >= '" + ls_dacom_fr + "' "
END IF
IF ls_dacom_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.DACOM_MNG_NO <= '" + ls_dacom_to + "' "
END IF

//SERIAL NO From ~ To
IF ls_serial_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.SERIALNO >= '" + ls_serial_fr + "' "
END IF
IF ls_serial_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " EQUIPMST.SERIALNO <= '" + ls_serial_to + "' "
END IF

//Mac Address
IF ls_mac_addr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	IF not IsNull(ls_mac_addr) then ls_mac_addr = '%'+ ls_mac_addr +'%'
	ls_where += " EQUIPMST.MAC_ADDR LIKE '" + ls_mac_addr + "' "
END IF

//clipboard(ls_where)

//Contno From ~ To
//IF ls_contno_fr <> "" THEN
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += " EQUIPMST.CONTNO >= '" + ls_contno_fr + "' "
//END IF
//IF ls_contno_to <> "" THEN
//	IF ls_where <> "" THEN ls_where += " AND "
//	ls_where += " EQUIPMST.CONTNO <= '" + ls_contno_to + "' "
//END IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
IF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
ELSEIF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN
END IF
//
end event

event type integer ue_extra_save();//Long 		ll_row, 		i, 	ll_seq, 		ll_tmp
//Dec{2} 	lc_amt[], 	lc_totalamt,		ldc_tmp
//Dec 		lc_saleamt
//Integer 	li_rc, 		li_rtn,				li_tmp
//String 	ls_itemcod, ls_paydt, 			ls_customerid, 		ls_memberid, &
//			ls_rf_type, ls_partner,			ls_tmp,					ls_operator, &
//			ls_remark
//
//b1u_dbmgr_dailypayment	lu_dbmgr
//dw_cond.AcceptText()
//
//idc_total 		= 0
//ls_remark 		= trim(dw_cond.Object.remark[1])
//ls_customerid 	= trim(dw_cond.Object.customerid[1])
//ls_Operator 	= trim(dw_cond.Object.operator[1])
//ls_MEMBERid 	= trim(dw_cond.Object.memberid[1])
//idc_total 		= dw_cond.Object.total[1]
//idc_receive 	= dw_cond.Object.cp_receive[1]
//idc_change 		= dw_cond.Object.cp_change[1]
//ls_paydt 		= String(dw_cond.Object.paydt[1], 'yyyymmdd')
//ls_partner 		= Trim(dw_cond.object.partner[1])
//
////고객번호 및 오퍼레이터 존재여부 확인
//IF IsNUll(ls_remark) 		then ls_remark 	= ''
//IF IsNUll(ls_customerid) 	then ls_customerid 	= ''
//IF IsNUll(ls_operator) 		then ls_operator 		= ''
//li_rtn = f_check_ID(ls_customerid, ls_operator)
//IF li_rtn =  -1 THEN
//		f_msg_usr_err(9000, Title, "Customerid가 존재하지 않습니다.")
//		dw_cond.SetFocus()
//		dw_cond.SetRow(1)
//		dw_cond.Object.customerid[1] = ''
//		dw_cond.Object.customernm[1] = ''
//		dw_cond.SetColumn("customerid")
//		Return -1 
//ELSEIF li_rtn = -2 THEN 
//		f_msg_usr_err(9000, Title, "Operator가 존재하지 않습니다.")
//		dw_cond.SetFocus()
//		dw_cond.SetRow(1)
//		dw_cond.Object.operator[1] = ''
//		dw_cond.SetColumn("operator")
//		Return -1 
//END IF
//
//
//
//
//FOR i =  1 to dw_detail.rowCount()
//	dw_detail.Object.remark[i]	= ls_remark
//	ls_rf_type = dw_detail.Object.refund_type[i]
//	IF IsNull(ls_rf_type) then ls_rf_type = ""
//	IF ls_rf_type <> "" THEN
//		idc_total 	+= dw_detail.Object.refund_price[i]
//	END IF
//NEXT
//
//IF idc_total <> idc_receive then
//	f_msg_usr_err(9000, Title, "입금액이 맞지 않습니다. 확인 바랍니다.")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("amt1")
//	Return -2	
//END IF
////==========================================================
//// 입금액이 sale금액보다 크거나 같으면.... 처리
////==========================================================
//
////li_rtn = MessageBox("Result", "영수증 출력을 하시겠습니까?", Exclamation!, YesNo!, 1)
//li_rtn = 1
////저장
//lu_dbmgr = Create b1u_dbmgr_dailypayment
//
//lu_dbmgr.is_caller 	= "save_refund"
//lu_dbmgr.is_title 	= Title
//lu_dbmgr.idw_data[1] = dw_cond 	//조건
//lu_dbmgr.idw_data[2] = dw_detail //조건
//
//lu_dbmgr.is_data[1] 	= ls_customerid
//lu_dbmgr.is_data[2] 	= ls_paydt  //paydt(shop별 마감일 )
//lu_dbmgr.is_data[3] 	= ls_partner //shopid
//lu_dbmgr.is_data[4] 	= GS_USER_ID //Operator
//IF li_rtn = 1 THEN 
//	lu_dbmgr.is_data[5] 	= "Y"
//ELSE
//	lu_dbmgr.is_data[5] 	= "N"
//END IF
//
//lu_dbmgr.is_data[6] 	= gs_pgm_id[gi_open_win_no]
//lu_dbmgr.is_data[7] 	= "Y" //ADMST Update 여부
//lu_dbmgr.is_data[8] 	= ls_memberid //memberid
//lu_dbmgr.is_data[9] 	= "N" //ADLOG Update여부
//lu_dbmgr.is_data[10]	= "REFUND" //PGM_ID
//
//
//lu_dbmgr.uf_prc_db_07()
////위 함수에서 이미 commit 한 상태임.
//li_rc = lu_dbmgr.ii_rc
//Destroy lu_dbmgr
//
//If li_rc = -1 Or li_rc = -3 Then
//	Return -1
//ELSEIf li_rc = -2 Then
//	f_msg_usr_err(9000, Title, "!!")
//	Return -1
//End If
//
//dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
//dw_cond.SetFocus()
//dw_detail.Reset()
Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화

p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_disable")
p_confirm.TriggerEvent("ue_disable")
p_transfer.TriggerEvent("ue_disable")
dw_cond.Enabled = True

dw_cond.ReSet()
dw_cond.InsertRow(0)

dw_cond.SetFocus()
dw_cond.SetColumn("status")

is_all = '0'

Return 0
end event

event open;call super::open;//=========================================================//
// Desciption : 인증장비 이동						              //
// Name       : ubs_w_reg_equipmove			                 //
// Contents   : 인증 장비를 본사->텍 혹은 다른 텍으로		  //
//					 이동시키는 메뉴이다. 이동가능, 인수가능    //
// Data Window: dw - ubs_dw_reg_equipmove_cnd	           // 
//							ubs_dw_reg_equipmove_mas 				  //
// 작성일자   : 2009.04.13                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,	ls_temp

//장비상태- Move
is_new 			= fs_get_control("U1", "E200", ls_ref_desc)		//이동가능한 상태
is_move 			= fs_get_control("U1", "E300", ls_ref_desc)		//이동중인 상태
is_return 		= fs_get_control("U1", "E500", ls_ref_desc)		//반납 상태
is_sale 			= fs_get_control("U1", "E400", ls_ref_desc)		//완료 상태

//인수 상태값(P) : 100, 300, 500, 600
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "S500", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_put[])

//인계 상태값(G) : 200
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "S600", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_get[])


end event

event type integer ue_save();//Constant Int LI_ERROR = -1
//
//If dw_detail.AcceptText() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End If
//
//If This.Trigger Event ue_extra_save() < 0 Then
//	dw_detail.SetFocus()
//	Return LI_ERROR
//End If
//
//If dw_detail.Update() < 0 then
//	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//	
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return LI_ERROR
//	End If
//
//	f_msg_info(3010,This.Title,"Save")
//	Return LI_ERROR
//Else
//	//COMMIT와 동일한 기능
//	iu_cust_db_app.is_caller = "COMMIT"
//	iu_cust_db_app.is_title = This.Title
//
//	iu_cust_db_app.uf_prc_db()
//
//	If iu_cust_db_app.ii_rc = -1 Then
//		dw_detail.SetFocus()
//		Return LI_ERROR
//	End If
//	
//	f_msg_info(3000,This.Title,"Save")
//	This.Trigger Event ue_reset() 
//	
//End If
//
Return 0
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정

IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_detail.Height = 0
   p_confirm.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_transfer.Y	  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y		  = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
ELSE
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
   p_confirm.Y		  = newheight - iu_cust_w_resize.ii_button_space
	p_transfer.Y	  = newheight - iu_cust_w_resize.ii_button_space
	p_close.Y		  = newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y		  = newheight - iu_cust_w_resize.ii_button_space
	
END IF

IF newwidth < dw_detail.X  THEN
	dw_detail.Width = 0
ELSE
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
END IF

SetRedraw(TRUE)
end event

type dw_cond from w_a_reg_m`dw_cond within ubs_w_reg_equipmove
integer x = 55
integer y = 16
integer width = 2432
integer height = 392
integer taborder = 10
string dataobject = "ubs_dw_reg_equipmove_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;Choose Case dwo.name
	case "contno_fr"
		this.Object.contno_to[1] =  data
End Choose

end event

type p_ok from w_a_reg_m`p_ok within ubs_w_reg_equipmove
integer x = 2578
integer y = 96
end type

type p_close from w_a_reg_m`p_close within ubs_w_reg_equipmove
integer x = 987
integer y = 1684
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within ubs_w_reg_equipmove
integer x = 23
integer width = 2880
integer height = 440
integer taborder = 0
integer textsize = -2
end type

type p_delete from w_a_reg_m`p_delete within ubs_w_reg_equipmove
boolean visible = false
integer x = 315
integer y = 1616
end type

type p_insert from w_a_reg_m`p_insert within ubs_w_reg_equipmove
boolean visible = false
integer x = 23
integer y = 1616
end type

type p_save from w_a_reg_m`p_save within ubs_w_reg_equipmove
boolean visible = false
integer x = 608
integer y = 1616
end type

type dw_detail from w_a_reg_m`dw_detail within ubs_w_reg_equipmove
integer x = 23
integer y = 460
integer width = 2875
integer height = 1204
integer taborder = 20
string dataobject = "ubs_dw_reg_equipmove_mas"
end type

event dw_detail::retrieveend;call super::retrieveend;If rowcount = 0 Then
	p_ok.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_disable")
	p_confirm.TriggerEvent("ue_disable")
	p_transfer.TriggerEvent("ue_disable")
	dw_cond.Enabled = True
ELSE
	p_ok.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	p_transfer.TriggerEvent("ue_enable")
	p_confirm.TriggerEvent("ue_enable")
	dw_cond.Enabled = false
END IF


end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemerror;call super::itemerror;return 1
end event

event dw_detail::buttonclicked;call super::buttonclicked;Long	ll,	ll_cnt

ll_cnt = this.rowCount()
IF ll_cnt  = 0 then Return
choose case dwo.name
	case 'b_all'
		IF is_all = '0' then
			is_all = '1'
		ELSE
			is_all = '0'
		END IF
		for ll =  1 to ll_cnt
			IF is_all = '1' then
				this.Object.chk[ll] = 1
			ELSE
				this.Object.chk[ll] = 0
			END IF
		NEXT
	case else
end choose
end event

type p_reset from w_a_reg_m`p_reset within ubs_w_reg_equipmove
integer x = 667
integer y = 1684
end type

type p_transfer from u_p_transfer within ubs_w_reg_equipmove
integer x = 343
integer y = 1684
boolean bringtotop = true
boolean originalsize = false
end type

type p_confirm from u_p_confirm within ubs_w_reg_equipmove
integer x = 23
integer y = 1684
boolean bringtotop = true
boolean originalsize = false
end type

