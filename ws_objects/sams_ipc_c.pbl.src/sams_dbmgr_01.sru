$PBExportHeader$sams_dbmgr_01.sru
$PBExportComments$[hcjung] DBmanager
forward
global type sams_dbmgr_01 from u_cust_a_db
end type
end forward

global type sams_dbmgr_01 from u_cust_a_db
end type
global sams_dbmgr_01 sams_dbmgr_01

type variables
String 	is_customerid, is_customernm, &
			is_saledt, 		is_partner,		&
			is_operator,	is_userid, 		 &
			is_appseq, 		is_memberid
DEC{2}	idec_cash,		idec_change,	idec_total, 		idec_saleamt
Long		il_adseq,		il_payseq,		il_row,		il_shopcount, il_keynum
date		idt_saledt

String 	is_itemcod, 	is_regcod, is_basecod, is_payid, &
			is_itemnm, 		is_facnum,		is_contno, is_val
String 	is_paymethod[], is_method
dec{2}	idc_amt[], idc_rem
Integer  ii_amt_su,	ii_method, ii_paycnt
end variables

forward prototypes
public subroutine uf_prc_db_07 ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db_07 ();
end subroutine

public subroutine uf_prc_db_01 ();// ---------------------------------------------------------------------------------------------
// HISTORY
// CREATE : 2008-02-08 : HCJUNG

date		ldt_refunddt,	ldt_shop_closedt			
Integer	i, jj, 			li_first, 			li_pp, 			LI_QTY,		li_rtn, ll_bonus
Long		ll_qty,			ll_retseq,			ll_cnt
dec{2}	ldc_salerem, 	idec_unitcharge, 		ldc_amt0[]
String 	ls_refund_type, 	ls_remark, 		ls_receipt_type, &
			ls_manual_yn,	ls_modelno, 		ls_adlog_yn, 	ls_refundtype
String 	ls_temp, 		ls_method0[], 		ls_trcod[]
String   ls_prt, 			ls_memberid, 		ls_customerid, 		ls_basecod, &
			ls_admst_yn, 	ls_code, 			ls_codenm, &
			ls_dctype, 		ls_receipttype, 	ls_admst_status, ls_ref_desc, &
			ls_rtype[], 	ls_adsta_ret,		ls_pgm_id, &
			ls_pid,	ls_serialno,       ls_sale_type, is_chk

// idw_data[2] : dw_detail
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// ssrtppcif Insert
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Choose Case is_caller
    Case "sams_ipc" 			
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_chk = trim(idw_data[2].Object.chk[i])
			
            IF is_chk = 'Y' THEN
			       
					 ls_pid           = trim(idw_data[2].Object.vic_pin[i])
					 ls_customerid    = trim(idw_data[2].Object.customerid[i])
					 idec_unitcharge   = idw_data[2].Object.unitcharge[i]
					 
					 //카드의 contno 가져오기
                SELECT SERIALNO INTO :ls_serialno FROM ADMST WHERE PID = :ls_pid;
                
					 IF IsNull(ls_serialno) THEN ls_serialno = ""

					 IF SQLCA.SQLCode < 0 THEN
					     f_msg_sql_err(is_title,is_caller + " Select Error (admst)")						
						  ii_rc 		= -1
						  ROLLBACK;
						  RETURN
					 ELSEIF ls_serialno = "" THEN
					     f_msg_sql_err(is_title,is_caller + "Control No. Not Found. (PID :" + ls_pid + ")")
						  ii_rc 		= -2
						  ROLLBACK;
						  RETURN
					 END IF	
					 
                INSERT INTO ssrtppcif 
 					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark, customerid)
					 VALUES 
					 (seq_ssrtppcif.nextval,'RECHARGE','0',:ls_serialno,(:idec_unitcharge+:idec_unitcharge*0.1)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','IPC',:ls_customerid);
					 
                IF SQLCA.SQLCode < 0 THEN
                    ii_rc = -1			
                    f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
                    ROLLBACK;
                    RETURN 
                END IF
            END IF	
        NEXT
END CHOOSE

COMMIT;

RETURN 
end subroutine

on sams_dbmgr_01.create
call super::create
end on

on sams_dbmgr_01.destroy
call super::destroy
end on

event constructor;call super::constructor;////
end event

