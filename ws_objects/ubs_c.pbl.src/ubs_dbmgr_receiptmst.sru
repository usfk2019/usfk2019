$PBExportHeader$ubs_dbmgr_receiptmst.sru
$PBExportComments$[jhchoi] 수납 영수증 출력 Object - 2009.03.23
forward
global type ubs_dbmgr_receiptmst from u_cust_a_db
end type
end forward

global type ubs_dbmgr_receiptmst from u_cust_a_db
end type
global ubs_dbmgr_receiptmst ubs_dbmgr_receiptmst

type variables
String 	is_customerid, is_customernm, &
			is_saledt, 		is_partner,		&
			is_operator,	is_userid, 		 &
			is_appseq, 		is_memberid
DEC{2}	idec_receive,		idec_change,	idec_total, 		idec_saleamt
Long		il_adseq,		il_payseq,		il_row,		il_shopcount, il_keynum
date		idt_paydt

String 	is_itemcod, 	is_regcod, is_basecod, is_payid, &
			is_itemnm, 		is_facnum,		is_contno, is_val
String 	is_method[], 	is_paymethod,		is_paydt, is_app
dec{2}	idc_amt[], idc_rem
Integer  ii_amt_su,	ii_method
Long 		il_paycnt
end variables

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db ()
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_01 ();INTEGER	i,  					li_rtn,				li_cnt,					li_lp
DEC{2}	ldc_amt0[],			ldc_impack,			ldc_amt0_im
STRING 	ls_temp, 			ls_method0[], 		ls_trcod[],				ls_prt, 				&
			ls_memberid, 		ls_payid, 			ls_code, 				ls_codenm,			&
			ls_receipttype,	ls_ref_desc,		ls_rtype[],	 			ls_pgm_id, 			&
	 		ls_lin1,				ls_lin2,				ls_lin3,					ls_appseq,			&
			ls_chk,				ls_itemnm,			ls_val,					ls_regcod,			&
			ls_facnum,			ls_paid_trdt,		ls_trcod_im,			ls_method0_im
DEC		ldc_saleamt,		ldc_total,			ldc_change,			ldc_cash
LONG		ll_seq,				ll_keynum

//2019.04.08 변수 추가 Modified by Han
STRING   ls_surtaxyn
DEC      ld_net_tot,       ld_vat_tot,       ld_grand_tot

//lu_dbmgr.is_caller   = "b5w_reg_mtr_inp_sams%direct"
//lu_dbmgr.is_title	   = Title
//lu_dbmgr.is_data[1]  = ls_payid
//lu_dbmgr.is_data[2]  = ls_paydt
//lu_dbmgr.is_data[3]  = gs_shopid
//lu_dbmgr.is_data[4]  = gs_user_id
//lu_dbmgr.is_data[5]  = 'Y'
//lu_dbmgr.is_data[6]  = ls_memberid
//lu_dbmgr.is_data[7]  = ls_pgm_id
//lu_dbmgr.is_data[8]  = ls_appseq
//lu_dbmgr.idw_data[1] = dw_cond
//lu_dbmgr.idw_data[2] = dw_split
//lu_dbmgr.idw_data[3] = dw_detail2
//
//lu_dbmgr.uf_prc_db_01()

//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])

ls_receipttype 	= ls_rtype[1]

ii_rc			 		= -1

is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_memberid   		= is_data[6]
ls_pgm_id			= is_data[7]
ls_appseq			= is_data[8]

idt_paydt   		= idw_data[1].object.paydt[1]
idec_total   		= idw_data[1].object.total[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]
ldc_impack			= idw_data[1].object.amt5[1] 

ls_trcod[1] 		= idw_data[1].object.trcode3[1]
ls_trcod[2] 		= idw_data[1].object.trcode2[1]
ls_trcod[3] 		= idw_data[1].object.trcode4[1]
ls_trcod[4] 		= idw_data[1].object.trcode1[1]
ls_trcod[5] 		= idw_data[1].object.trcode6[1]
		
ls_method0[1] 		= idw_data[1].object.paymethod3[1]
ls_method0[2] 		= idw_data[1].object.paymethod2[1]
ls_method0[3] 		= idw_data[1].object.paymethod4[1]
ls_method0[4] 		= idw_data[1].object.paymethod1[1]
ls_method0[5] 		= idw_data[1].object.paymethod6[1]
		
ldc_amt0[1] 		= idw_data[1].object.amt3[1]
ldc_amt0[2] 		= idw_data[1].object.amt2[1]
ldc_amt0[3] 		= idw_data[1].object.amt4[1]
ldc_amt0[4] 		= idw_data[1].object.amt1[1]
ldc_amt0[5] 		= idw_data[1].object.amt6[1]

ldc_change        = idec_change

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= idw_data[1].object.trcode5[1]
	ls_method0_im	= idw_data[1].object.paymethod5[1]	
	ldc_amt0_im		= idw_data[1].object.amt5[1]			
END IF

ii_amt_su 			= 0

FOR i = 1 TO 5
	IF ldc_amt0[i] <> 0 THEN 
		ii_amt_su 				+= 1 
		idc_amt[ii_amt_su] 	= ldc_amt0[i]
		is_method[ii_amt_su] = ls_method0[i]
	END IF
NEXT

//customerm Search
SELECT MEMBERID, 		PAYID
INTO   :ls_memberid, :ls_payid
FROM   CUSTOMERM
WHERE  CUSTOMERID = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""

IF ls_prt = "Y" THEN
	//실 영수증 번호임.
	SELECT SEQ_APP.NEXTVAL INTO :is_app FROM DUAL;
	
	IF SQLCA.SQLCODE < 0 THEN
		ii_rc = -1			
		F_MSG_SQL_ERR(is_title, is_caller + " Sequence Error(seq_app)")
		ROLLBACK;
		RETURN 
	END IF
END IF

//----------------------------------------------------------
//SHOP COUNT
SELECT SHOPCOUNT	INTO :il_shopcount
FROM   PARTNERMST
WHERE  PARTNER = :is_partner;

IF ISNULL(il_shopcount) THEN il_shopcount = 0
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//----------------------------------------------------------
il_shopcount += 1
INSERT INTO RECEIPTMST
			( APPROVALNO,		SHOPCOUNT,		RECEIPTTYPE,		SHOPID,				POSNO,
			  WORKDT,			TRDT,				MEMBERID,			OPERATOR,			TOTAL,
			  CASH,				CHANGE,			SEQ_APP,				CUSTOMERID,			PRT_YN )
VALUES	( :ls_appseq,	 	:il_shopcount,	:ls_receipttype,	:is_partner, 		NULL,
			  sysdate,		   :idt_paydt,		:ls_memberid,		:is_operator,		:idec_total,
			  :idec_receive,	:idec_change,	:is_app,				:is_customerid,	:ls_prt )	 ;
			  
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Insert Error(RECEIPTMST)")
	ROLLBACK;
	RETURN
END IF

//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
UPDATE PARTNERMST
SET	 SHOPCOUNT = :il_shopcount
WHERE  PARTNER	  = :is_partner;

IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update  Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//-------------------------------------------------------
//영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[3].SetSort('itemcod A')
idw_data[3].Sort()

// 2019.04.23 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by typark

string ls_prnbuf, ls_name[]
long   ll_print_row
long   ll_prt_ln, ll_temp
string ls_normal = "~h1B" + "!" + "~h08" + "~h1B" + "E" + "~h00"  // Normal Character
String ls_Cut    = "~h1B" + "~h69"                                // Cut Paper
int li_handle

ls_temp 			= GS_PRN
IF IsNull(ls_temp) OR ls_temp = ''  then
	ls_temp = "COM1;6;8;2;0"
END IF	
fi_cut_string(ls_temp, ";", ls_name[])

li_handle = FileOpen(ls_name[1], StreamMode!, Write!)
		
IF li_handle < 1  THEN
	MessageBox('알 림', '프린터 오픈 에러입니다.')
	FileClose(li_handle)
	SetPointer(Arrow!)
//	Return
END IF

// Structure 초기화 
ll_print_row = gs_str_receipt_print.ll_line_num
if ll_print_row > 0 then
	for ll_print_row = 1 to gs_str_receipt_print.ll_line_num
		gs_str_receipt_print.ls_out[ll_print_row] = ""
	next
	gs_str_receipt_print.ll_line_num = 0
end if

ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ii_rc 		= 0
ll_seq		= 0

//2019.04.08 공급가, 부가세, 합계 초기화 Modified by Han
ld_net_tot   = 0
ld_vat_tot   = 0
ld_grand_tot = 0


IF ls_prt = "Y" THEN
	//head 출력
	li_rtn = f_pos_header_vat(GS_SHOPID, 'A', il_shopcount, 1 )
	li_rtn = 1  //임시...
	IF li_rtn < 0 THEN
		MESSAGEBOX('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
		FileClose(li_handle)
//		PRN_CLOSEPORT()
		ii_rc = -9	
		ROLLBACK;
		RETURN
	END IF

	//Item List 출력
	il_row = idw_data[3].RowCount()
	FOR i = 1 TO il_row
		ls_chk = idw_data[3].Object.chk[i]
		
		IF ls_chk = '1' OR ls_chk = '2' then
			ll_seq 		 += 1
			//ls_temp 		 = String(i, '000') + ' ' //순번 2010.07.19 수정. 번호가 중간에 붕 뜨는 경우 생김...
			ls_temp 		 = String(ll_seq, '000') + ' '			
			is_itemcod 	 = trim(idw_data[3].Object.itemcod[i])
			ls_itemnm 	 = trim(idw_data[3].Object.itemnm[i])
//			ls_paid_trdt = MidA(trim(idw_data[3].Object.trdt[i]), 5, 2) + '-' + MidA(trim(idw_data[3].Object.trdt[i]), 1, 4) + ']'					//청구월
// 2019.04.08 청구월 뒤에 space 추가 Modified by Han
			ls_paid_trdt = MidA(trim(idw_data[3].Object.trdt[i]), 5, 2) + '-' + MidA(trim(idw_data[3].Object.trdt[i]), 1, 4) + ']' + ' '			//청구월

// 2019.04.08 공급가, 부가세 합계 금액 계산 및 부가세 여부 값 가져오기 Modified by Han
			ld_net_tot   += idw_data[3].Object.bil_amt2  [i]
			ld_vat_tot   += idw_data[3].Object.bil_taxamt[i]
			ld_grand_tot += idw_data[3].Object.bil_amt2  [i] + idw_data[3].Object.bil_taxamt[i]
			ls_surtaxyn   = idw_data[3].Object.surtaxyn  [i]

			IF IsNull(ls_itemnm) then ls_itemnm 	= ""
			
			ldc_saleamt	 = idw_data[3].Object.income[i]	
			ldc_total 	 += ldc_saleamt 
			//ls_temp 		 += Left(ls_itemnm + space(24), 24) + ' '   //아이템
			ls_temp 		 += LeftA(ls_paid_trdt + ls_itemnm + space(24),24) + ' '			//청구월 + 아이템
			li_cnt 		 =  1
			ls_temp 		 += RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
			ls_val 		 = fs_convert_amt(ldc_saleamt,  8)
			ls_temp 		 += ls_val //금액
			f_printpos_vat(' ' + ls_temp)	
			ls_regcod =  trim(idw_data[3].Object.regcod[i])
			//regcode master read
			SELECT KEYNUM,	TRIM(FACNUM)
			INTO   :ll_keynum,	:ls_facnum
			FROM   REGCODMST
			WHERE  REGCOD = :ls_regcod;
			
			// Index Desciption 2010-08-20 jhchoi
			SELECT indexdesc
		  	INTO	 :ls_facnum
		  	FROM	 SHOP_REGIDX
		 	WHERE	 regcod = :ls_regcod
			AND	 shopid = :is_partner;			
		
			IF IsNull(ll_keynum) OR sqlca.sqlcode < 0	THEN ll_keynum 	= 0
			IF IsNull(ls_facnum) OR sqlca.sqlcode < 0	THEN ls_facnum 	= ""
			
 			//2010.08.20 jhchoi 수정.
			//ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
			
			//2019.04.08 부가세 여부 '*' 출력 추가 Modified by Han
//			ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")"
			ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")" + ls_surtaxyn
						
			f_printpos_vat(' ' + ls_temp)
		END IF
	NEXT			

// 2019.04.08 Grand Total만 출력되던 것을 Net, Vat, Grand Total로 변경
//	F_POS_PRINT(ls_lin1, 1)
//	
//	ls_val 	= fs_convert_sign(ldc_total, 8)
//	ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
//	f_printpos(ls_temp)
//	f_printpos(ls_lin1)

	F_POS_PRINT_vat(' ' + ls_lin1, 1)

	ls_val 	= fs_convert_sign(ld_net_tot, 8)
	ls_temp 	= LeftA("Net" + space(33), 33) + ls_val
	f_printpos_vat(' ' + ls_temp)
	
	ls_val 	= fs_convert_sign(ld_vat_tot, 8)
	ls_temp 	= LeftA("VAT" + space(33), 33) + ls_val
	f_printpos_vat(' ' + ls_temp)

	F_POS_PRINT_VAT(' ' + ls_lin1, 1)

	ls_val 	= fs_convert_sign(ld_grand_tot, 8)
	ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
	f_printpos_vat(' ' + ls_temp)
	f_printpos_vat(' ' + ls_lin1)


	//결제 수단별 금액 처리
	String ls_methodnm
	FOR li_lp = 1 TO 5
		IF li_lp = 1 THEN
			IF ldc_amt0_im <> 0 THEN
				ls_val 	= fs_convert_sign(ldc_amt0_im,  8)
				ls_code	= ls_method0_im
				select codenm INTO :ls_codenm from syscod2t
				where grcode = 'B310' 
				  and use_yn = 'Y'
				  AND code = :ls_code ;
				ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
				f_printpos_vat(' ' + ls_temp)						
			END IF
		END IF				
		ldc_cash = ldc_amt0[li_lp]
		ls_code 	= ls_method0[li_lp]
		IF ldc_cash <> 0 THEN
			ls_val 	= fs_convert_sign(ldc_cash,  8)
			
			SELECT CODENM INTO :ls_codenm FROM syscod2t
			WHERE  GRCODE = 'B310' 
			AND    USE_YN = 'Y'
			AND    CODE   = :ls_code ;
				  
			ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
			f_printpos_vat(' ' + ls_temp)
		END IF
	NEXT
	
	ls_val 	= fs_convert_sign(ldc_change,  8)
	ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
	f_printpos_vat(' ' + ls_temp)
	f_printpos_vat(' ' + ls_lin1)
// 2019.04.08 Footer Pay Date 추가 Modified by Han
//	Fs_POS_FOOTER2(ls_payid,is_customerid,is_app,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록
//	Fs_POS_FOOTER3(ls_payid,is_customerid,is_app,gs_user_id,is_paydt)
	Fs_POS_FOOTER3_vat(ls_payid,is_customerid,ls_appseq,gs_user_id,is_paydt)
	
	
	for ll_prt_ln = 1 to gs_str_receipt_print.ll_line_num
		ls_prnbuf = ls_prnbuf + ls_normal + gs_str_receipt_print.ls_out[ll_prt_ln]
	next

	ls_prnbuf = ls_prnbuf + ls_cut

	ll_temp = fileWrite(li_handle, ls_prnbuf)

	if ll_temp = -1 then
		FileClose(li_handle)
//		return
	end if

//	PRN_ClosePort()
END IF

FileClose(li_handle)

ii_rc = 0
COMMIT;

RETURN
end subroutine

public subroutine uf_prc_db_03 ();DATE		ldt_shop_closedt
INTEGER	i,  					LI_QTY,				li_rtn,					ll_bonus
DEC{2}	ldc_amt0[]
STRING 	ls_receipt_type,	ls_temp, 			ls_method0[], 			ls_trcod[],			ls_prt, 				&
			ls_memberid, 		ls_payid, 			ls_basecod,				ls_code, 			ls_codenm,			&
			ls_dctype, 			ls_receipttype,	ls_ref_desc,			ls_rtype[],	 		ls_pgm_id, 			&
	 		ls_lin1,				ls_lin2,				ls_lin3,					ls_empnm
DEC		ldc_shopCount			

//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])

ls_dctype 			= 'D'
ls_receipttype 	= ls_rtype[1]

ii_rc			 		= -1

//즉시불 환불에서 쓰이는듯...
is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_memberid   		= is_data[6]
ls_pgm_id			= is_data[7]
is_appseq			= is_data[8]			//이거는 특이하게 영수증 번호를 받음...

ldt_shop_closedt 	= f_find_shop_closedt(is_partner)
	
idt_paydt   		= idw_data[1].object.paydt[1]
idec_total   		= idw_data[1].object.total[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]

ls_trcod[1] 		= idw_data[1].object.trcode3[1]
ls_trcod[2] 		= idw_data[1].object.trcode2[1]
ls_trcod[3] 		= idw_data[1].object.trcode5[1]
ls_trcod[4] 		= idw_data[1].object.trcode4[1]
ls_trcod[5] 		= idw_data[1].object.trcode1[1]
ls_trcod[6] 		= idw_data[1].object.trcode6[1]
		
ls_method0[1] 		= idw_data[1].object.paymethod3[1]
ls_method0[2] 		= idw_data[1].object.paymethod2[1]
ls_method0[3] 		= idw_data[1].object.paymethod5[1]
ls_method0[4] 		= idw_data[1].object.paymethod4[1]
ls_method0[5] 		= idw_data[1].object.paymethod1[1]
ls_method0[6] 		= idw_data[1].object.paymethod6[1]
		
ldc_amt0[1] 		= idw_data[1].object.amt3[1]
ldc_amt0[2] 		= idw_data[1].object.amt2[1]
ldc_amt0[3] 		= idw_data[1].object.amt5[1]
ldc_amt0[4] 		= idw_data[1].object.amt4[1]
ldc_amt0[5] 		= idw_data[1].object.amt1[1]
ldc_amt0[6] 		= idw_data[1].object.amt6[1]
ii_amt_su 			= 0

FOR i = 1 TO 6
	IF ldc_amt0[i] <> 0 THEN 
		ii_amt_su 				+= 1 
		idc_amt[ii_amt_su] 	= ldc_amt0[i]
		is_method[ii_amt_su] = ls_method0[i]
	END IF
NEXT

//customerm Search
SELECT MEMBERID, 		PAYID, 		BASECOD
INTO   :ls_memberid, :ls_payid,  :ls_basecod
FROM   CUSTOMERM
WHERE  CUSTOMERID = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""

//----------------------------------------------------------
//receiptMST Insert
//SEQ
//SELECT SEQ_RECEIPT.NEXTVAL	INTO :is_appseq	FROM DUAL;

//IF SQLCA.SQLCODE < 0 THEN
//	ii_rc = -1			
//	F_MSG_SQL_ERR(is_title, is_caller + " Sequence Error(seq_receipt)")
//	ROLLBACK;
//	RETURN
//END IF
		
IF ls_prt = "Y" THEN
	//실 영수증 번호임.
	SELECT SEQ_APP.NEXTVAL INTO :is_app FROM DUAL;
	
	IF SQLCA.SQLCODE < 0 THEN
		ii_rc = -1			
		F_MSG_SQL_ERR(is_title, is_caller + " Sequence Error(seq_app)")
		ROLLBACK;
		RETURN 
	END IF
END IF

//----------------------------------------------------------
//SHOP COUNT
SELECT SHOPCOUNT	INTO :il_shopcount
FROM   PARTNERMST
WHERE  PARTNER = :is_partner;

IF ISNULL(il_shopcount) THEN il_shopcount = 0
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//----------------------------------------------------------
il_shopcount += 1
INSERT INTO RECEIPTMST
			( APPROVALNO,		SHOPCOUNT,		RECEIPTTYPE,		SHOPID,				POSNO,
			  WORKDT,			TRDT,				MEMBERID,			OPERATOR,			TOTAL,
			  CASH,				CHANGE,			SEQ_APP,				CUSTOMERID,			PRT_YN )
VALUES	( :is_appseq,	 	:il_shopcount,	:ls_receipttype,	:is_partner, 		NULL,
			  sysdate,		   :idt_paydt,		:ls_memberid,		:is_operator,		:idec_total,
			  :idec_receive,	:idec_change,	:is_app,				:is_customerid,	:ls_prt )	 ;
				   
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Insert Error(RECEIPTMST)")
	ROLLBACK;
	RETURN
END IF

//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
UPDATE PARTNERMST
SET	 SHOPCOUNT = :il_shopcount
WHERE  PARTNER	  = :is_partner;

IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update  Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//-------------------------------------------------------
//영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[3].SetSort('itemcod A')
idw_data[3].Sort()

// 2019.05.03 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by Han

string ls_prnbuf, ls_name[]
long   ll_print_row
long   ll_prt_ln, ll_temp
string ls_normal = "~h1B" + "!" + "~h08" + "~h1B" + "E" + "~h00"  // Normal Character
String ls_Cut    = "~h1B" + "~h69"                                // Cut Paper
int li_handle

ls_temp 			= GS_PRN
IF IsNull(ls_temp) OR ls_temp = ''  then
	ls_temp = "COM1;6;8;2;0"
END IF	
fi_cut_string(ls_temp, ";", ls_name[])

li_handle = FileOpen(ls_name[1], StreamMode!, Write!)
		
IF li_handle < 1  THEN
	MessageBox('알 림', '영수증 프린터 연결상태를 확인해주세요.')
	FileClose(li_handle)
	SetPointer(Arrow!)
//	Return
END IF

// Structure 초기화 
ll_print_row = gs_str_receipt_print.ll_line_num
if ll_print_row > 0 then
	for ll_print_row = 1 to gs_str_receipt_print.ll_line_num
		gs_str_receipt_print.ls_out[ll_print_row] = ""
	next
	gs_str_receipt_print.ll_line_num = 0
end if


ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ii_rc 		= 0
IF ls_prt = "Y" THEN
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//head 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	li_rtn = 1
	li_rtn = F_POS_HEADER_VAT(is_partner, ls_receipt_type, il_shopcount, 1 )

	IF li_rtn < 0 THEN
		MESSAGEBOX('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
//		PRN_CLOSEPORT()
		ii_rc = -9		
//		RETURN
		FileClose(li_handle)
	END IF
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//2. Item List 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	il_row = idw_data[3].RowCount()
	FOR i = 1 TO il_row
		ls_temp 		= String(i, '000') + ' ' //순번
		is_itemcod 		= trim(idw_data[3].Object.itemcod[i])
		is_itemnm 		= trim(idw_data[3].Object.itemnm[i])	
	   li_qty 			= 1
			    
		IF IsNull(li_qty) OR li_qty  = 0 THEN li_qty = 1

// 2019.05.03 환불의 경우 금액을 마이너스로 출력 Modified by Han
		IF is_itemcod = '048SSRT' or is_itemcod = '049SSRT' THEN // Refund의 경우 
			idec_saleamt = idw_data[3].object.amount[i] * -1
			idec_total   = idec_total * -1
		ELSE
			idec_saleamt = idw_data[3].object.amount[i]
		END IF

      IF IsNull(is_itemnm) THEN is_itemnm 	= ''
	
      ls_temp 	+= LeftA(is_itemnm + space(25), 24)  //아이템
      ls_temp 	+= Space(1) + RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
      is_val 	= fs_convert_amt(idec_saleamt,  8)
	   ls_temp 	+= is_val //금액
		
		F_POS_PRINT_VAT(' ' + ls_temp, 1)	
	
      is_regcod =  trim(idw_data[3].Object.regcod[i])
		
	   //regcode master read
		SELECT KEYNUM,			TRIM(FACNUM)
	   INTO 	 :il_keynum,	:is_facnum
	   FROM 	 REGCODMST
		WHERE  REGCOD = :is_regcod;
					
	   // Index Desciption 2008-05-06 hcjung
		SELECT INDEXDESC
		INTO   :is_facnum
		FROM   SHOP_REGIDX
		WHERE  REGCOD = :is_regcod
		AND	 SHOPID = :is_partner;
	
		IF ISNUll(il_keynum) OR sqlca.sqlcode < 0	THEN il_keynum 	= 0
		IF ISNUll(is_facnum) OR sqlca.sqlcode < 0	THEN is_facnum 	= ""
  	   //2010.08.20 jhchoi 수정.
		//ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
		ls_temp =  Space(4) + "(KEY#" + String(il_keynum) + " " + is_facnum + ")"					
		
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
      
	NEXT
	//2. Item List 출력 ----- end

	F_POS_PRINT_VAT(' ' + ls_lin1, 1)
	
	is_val 	= FS_CONVERT_SIGN(idec_total, 8)
	ls_temp 	= LeftA("Grand Total" + space(33), 33) + is_val
	
	F_POS_PRINT_VAT(' ' + ls_temp, 1)
	F_POS_PRINT_VAT(' ' + ls_lin1, 1)
	
	//--------------------------------------------------------
	//결제수단별 입금액
 	FOR i = 1 TO 6
		IF ldc_amt0[i] <> 0 THEN
			// 2019.05.03 환불의 경우 금액을 마이너스로 출력 Modified by Han
			IF is_itemcod = '048SSRT' or is_itemcod = '049SSRT' THEN // Refund의 경우 
				is_val = FS_CONVERT_SIGN(ldc_amt0[i] * -1,  8)
			ELSE
				is_val = FS_CONVERT_SIGN(ldc_amt0[i],  8)
			END IF
			
			ls_code	= ls_method0[i]
			
			SELECT CODENM INTO :ls_codenm FROM SYSCOD2T
			WHERE  GRCODE = 'B310'
			AND    USE_YN = 'Y'
			AND    CODE   = :ls_code;

			ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
			
			F_POS_PRINT_VAT(' ' + ls_temp, 1)
		END IF
	NEXT
	
	//거스름돈 처리
	is_val 	= FS_CONVERT_SIGN(idec_change,  8)
	ls_temp 	= LeftA("Changed" + space(33), 33) + is_val
	
	F_POS_PRINT_VAT(' ' + ls_temp, 1)
	F_POS_PRINT_VAT(' ' + ls_lin1, 1)	
//	FS_POS_FOOTER2(ls_payid,is_customerid, is_app, gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
	FS_POS_FOOTER3_VAT(ls_payid,is_customerid, is_appseq, gs_user_id, string(idt_paydt,'yyyymmdd'))

//	PRN_ClosePort()
	for ll_prt_ln = 1 to gs_str_receipt_print.ll_line_num
		ls_prnbuf = ls_prnbuf + ls_normal + gs_str_receipt_print.ls_out[ll_prt_ln]
	next

	ls_prnbuf = ls_prnbuf + ls_cut

	ll_temp = fileWrite(li_handle, ls_prnbuf)

	if ll_temp = -1 then
		FileClose(li_handle)
//		return
	end if

	FileClose(li_handle)


END IF
//-------------------------------------- end....
ii_rc = 0
COMMIT;

RETURN
end subroutine

public subroutine uf_prc_db ();DATE		ldt_shop_closedt
INTEGER	i,  					LI_QTY,				li_rtn,					ll_bonus
DEC{2}	ldc_amt0[]
STRING 	ls_receipt_type,	ls_temp, 			ls_method0[], 			ls_trcod[],			ls_prt, 				&
			ls_memberid, 		ls_payid, 			ls_basecod,				ls_code, 			ls_codenm,			&
			ls_dctype, 			ls_receipttype,	ls_ref_desc,			ls_rtype[],	 		ls_pgm_id, 			&
	 		ls_lin1,				ls_lin2,				ls_lin3,					ls_empnm,			ls_refund_type,	&
			ls_appseq
DEC		ldc_shopCount	

dec{2}   ldc_saleamt, ldc_net_tot, ldc_vat_tot
string   ls_surtaxyn, ls_net_tot, ls_vat_tot
//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])

ls_receipt_type  	= 'A'
ls_dctype 			= 'D'
ls_receipttype 	= ls_rtype[1]

ii_rc			 		= -1

is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_memberid   		= is_data[6]
ls_pgm_id			= is_data[7]
ls_appseq			= is_data[8]

ldt_shop_closedt 	= f_find_shop_closedt(is_partner)
	
idt_paydt   		= idw_data[1].object.paydt[1]
idec_total   		= idw_data[1].object.total[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]

ls_trcod[1] 		= idw_data[1].object.trcode3[1]
ls_trcod[2] 		= idw_data[1].object.trcode2[1]
ls_trcod[3] 		= idw_data[1].object.trcode5[1]
ls_trcod[4] 		= idw_data[1].object.trcode4[1]
ls_trcod[5] 		= idw_data[1].object.trcode1[1]
ls_trcod[6] 		= idw_data[1].object.trcode6[1]

		
ls_method0[1] 		= idw_data[1].object.paymethod3[1]
ls_method0[2] 		= idw_data[1].object.paymethod2[1]
ls_method0[3] 		= idw_data[1].object.paymethod5[1]
ls_method0[4] 		= idw_data[1].object.paymethod4[1]
ls_method0[5] 		= idw_data[1].object.paymethod1[1]
ls_method0[6] 		= idw_data[1].object.paymethod6[1]
		
ldc_amt0[1] 		= idw_data[1].object.amt3[1]
ldc_amt0[2] 		= idw_data[1].object.amt2[1]
ldc_amt0[3] 		= idw_data[1].object.amt5[1]
ldc_amt0[4] 		= idw_data[1].object.amt4[1]
ldc_amt0[5] 		= idw_data[1].object.amt1[1]
ldc_amt0[6] 		= idw_data[1].object.amt6[1]
ii_amt_su 			= 0


FOR i = 1 TO 6
	IF ldc_amt0[i] <> 0 THEN 
		ii_amt_su 				+= 1 
		idc_amt[ii_amt_su] 	= ldc_amt0[i]
		is_method[ii_amt_su] = ls_method0[i]
	END IF
NEXT

//customerm Search
SELECT MEMBERID, 		PAYID, 		BASECOD
INTO   :ls_memberid, :ls_payid,  :ls_basecod
FROM   CUSTOMERM
WHERE  CUSTOMERID = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""

//----------------------------------------------------------
//SEQ - pb로 옮김...
//SELECT SEQ_RECEIPT.NEXTVAL	INTO :is_appseq	FROM DUAL;

//IF SQLCA.SQLCODE < 0 THEN
//	ii_rc = -1			
//	F_MSG_SQL_ERR(is_title, is_caller + " Sequence Error(seq_receipt)")
//	ROLLBACK;
//	RETURN
//END IF
		
IF ls_prt = "Y" THEN
	//실 영수증 번호임.
	SELECT SEQ_APP.NEXTVAL INTO :is_app FROM DUAL;
	
	IF SQLCA.SQLCODE < 0 THEN
		ii_rc = -1			
		F_MSG_SQL_ERR(is_title, is_caller + " Sequence Error(seq_app)")
		ROLLBACK;
		RETURN 
	END IF
END IF

//----------------------------------------------------------
//SHOP COUNT
SELECT SHOPCOUNT	INTO :il_shopcount
FROM   PARTNERMST
WHERE  PARTNER = :is_partner;

IF ISNULL(il_shopcount) THEN il_shopcount = 0
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//----------------------------------------------------------
il_shopcount += 1
INSERT INTO RECEIPTMST
			( APPROVALNO,		SHOPCOUNT,		RECEIPTTYPE,		SHOPID,				POSNO,
			  WORKDT,			TRDT,				MEMBERID,			OPERATOR,			TOTAL,
			  CASH,				CHANGE,			SEQ_APP,				CUSTOMERID,			PRT_YN )
VALUES	( :ls_appseq,	 	:il_shopcount,	:ls_receipttype,	:is_partner, 		NULL,
			  sysdate,		   :idt_paydt,		:ls_memberid,		:is_operator,		:idec_total,
			  :idec_receive,	:idec_change,	:is_app,				:is_customerid,	:ls_prt )	 ;
				   
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Insert Error(RECEIPTMST)")
	ROLLBACK;
	RETURN
END IF

//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
UPDATE PARTNERMST
SET	 SHOPCOUNT = :il_shopcount
WHERE  PARTNER	  = :is_partner;

IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update  Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//-------------------------------------------------------
//영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[3].SetSort('itemcod A')
idw_data[3].Sort()

// 2019.04.23 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by typark

string ls_prnbuf, ls_name[]
long   ll_print_row
long   ll_prt_ln, ll_temp
string ls_normal = "~h1B" + "!" + "~h08" + "~h1B" + "E" + "~h00"  // Normal Character
String ls_Cut    = "~h1B" + "~h69"                                // Cut Paper
int li_handle

ls_temp 			= GS_PRN
IF IsNull(ls_temp) OR ls_temp = ''  then
	ls_temp = "COM1;6;8;2;0"
END IF	
fi_cut_string(ls_temp, ";", ls_name[])

li_handle = FileOpen(ls_name[1], StreamMode!, Write!)
		
IF li_handle < 1  THEN
	MessageBox('알 림', '프린터 오픈 에러입니다.')
	FileClose(li_handle)
	SetPointer(Arrow!)
//	Return
END IF

// Structure 초기화 
ll_print_row = gs_str_receipt_print.ll_line_num
if ll_print_row > 0 then
	for ll_print_row = 1 to gs_str_receipt_print.ll_line_num
		gs_str_receipt_print.ls_out[ll_print_row] = ""
	next
	gs_str_receipt_print.ll_line_num = 0
end if

ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ii_rc 		= 0
IF ls_prt = "Y" THEN
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//head 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	li_rtn = 1
	li_rtn = F_POS_HEADER_VAT(is_partner, ls_receipt_type, il_shopcount, 1 )

	IF li_rtn < 0 THEN
		MESSAGEBOX('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
//		PRN_CLOSEPORT()
		FileClose(li_handle)
		ii_rc = 0		
//		RETURN
	END IF
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//2. Item List 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	il_row = idw_data[3].RowCount()
	FOR i = 1 TO il_row
		ls_refund_type = 'A'
		ls_temp 		= String(i, '000') + ' ' //순번
		is_itemcod 		= trim(idw_data[3].Object.itemcod[i])
		is_itemnm 		= trim(idw_data[3].Object.itemnm[i])
	   li_qty 			= 1		
			    
		IF IsNull(li_qty) OR li_qty  = 0 THEN li_qty = 1
			    
		idec_saleamt = idw_data[3].object.bill_amt[i]
		ldc_saleamt  = idw_data[3].Object.bill_amt[i] + idw_data[3].Object.vat_amt[i]
		ldc_net_tot += idw_data[3].Object.bill_amt[i]
		ldc_vat_tot += idw_data[3].Object.vat_amt [i]

      IF IsNull(is_itemnm) THEN is_itemnm 	= ''
	
      ls_temp 	+= LeftA(is_paydt + ' ' + is_itemnm + space(25), 24)  //아이템
      ls_temp 	+= Space(1) + RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
      is_val 	= fs_convert_amt(ldc_saleamt,  8)
	   ls_temp 	+= is_val //금액

		SELECT NVL(DECODE(SURTAXYN, 'N', '*',' '),' ')
		  INTO :ls_surtaxyn
		  FROM ITEMMST
		 WHERE ITEMCOD = :is_itemcod;

		F_POS_PRINT_VAT(' ' + ls_temp, 1)	
	
      is_regcod =  trim(idw_data[3].Object.regcod[i])
		
	   //regcode master read
		SELECT KEYNUM,			TRIM(FACNUM)
	   INTO 	 :il_keynum,	:is_facnum
	   FROM 	 REGCODMST
		WHERE  REGCOD = :is_regcod;
					
	   // Index Desciption 2008-05-06 hcjung
		SELECT INDEXDESC
		INTO   :is_facnum
		FROM   SHOP_REGIDX
		WHERE  REGCOD = :is_regcod
		AND	 SHOPID = :is_partner;
	
		IF ISNUll(il_keynum) OR sqlca.sqlcode < 0	THEN il_keynum 	= 0
		IF ISNUll(is_facnum) OR sqlca.sqlcode < 0	THEN is_facnum 	= ""
		//2010.08.20 jhchoi 수정.
		//ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
		ls_temp =  Space(4) + "(KEY#" + String(il_keynum) + " " + is_facnum + ")" + ' ' + ls_surtaxyn
		
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
      
	NEXT
	//2. Item List 출력 ----- end
   f_printpos_vat(' ' + ls_lin1)

	ls_net_tot = fs_convert_sign(ldc_net_tot, 8)
	ls_temp    = Left("Net" + space(33), 33) + ls_net_tot

	f_printpos_vat(' ' + ls_temp);

	ls_vat_tot = fs_convert_sign(ldc_vat_tot, 8)
	ls_temp    = Left("VAT" + space(33), 33) + ls_vat_tot

	f_printpos_vat(' ' + ls_temp);

	F_POS_PRINT_VAT(' ' + ls_lin1, 1)
	
	is_val 	= FS_CONVERT_SIGN(ldc_net_tot + ldc_vat_tot, 8)
	ls_temp 	= LeftA("Grand Total" + space(33), 33) + is_val
	
	F_POS_PRINT_VAT(' ' + ls_temp, 1)
	F_POS_PRINT_VAT(' ' + ls_lin1, 1)
	
	//--------------------------------------------------------
	//결제수단별 입금액
 	FOR i = 1 TO 6
		IF ldc_amt0[i] <> 0 THEN
			is_val 	= FS_CONVERT_SIGN(ldc_amt0[i],  8)
			ls_code	= ls_method0[i]
			
			SELECT CODENM INTO :ls_codenm FROM SYSCOD2T
			WHERE  GRCODE = 'B310'
			AND    USE_YN = 'Y'
			AND    CODE   = :ls_code;

			ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
			
			F_POS_PRINT_VAT(' ' + ls_temp, 1)
		END IF
	NEXT
	
	//거스름돈 처리
	is_val 	= FS_CONVERT_SIGN(idec_change,  8)
	ls_temp 	= LeftA("Changed" + space(33), 33) + is_val
	
	F_POS_PRINT_VAT(' ' + ls_temp, 1)
	F_POS_PRINT_VAT(' ' + ls_lin1, 1)	
//	FS_POS_FOOTER2(ls_payid,is_customerid, is_app, gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
	FS_POS_FOOTER3_VAT(ls_payid,is_customerid, ls_appseq, gs_user_id, is_paydt)

	for ll_prt_ln = 1 to gs_str_receipt_print.ll_line_num
		ls_prnbuf = ls_prnbuf + ls_normal + gs_str_receipt_print.ls_out[ll_prt_ln]
	next

	ls_prnbuf = ls_prnbuf + ls_cut

	ll_temp = fileWrite(li_handle, ls_prnbuf)

	if ll_temp = -1 then
		FileClose(li_handle)
//		return
	end if
	
//	PRN_ClosePort()
END IF
FileClose(li_handle)
//-------------------------------------- end....
ii_rc = 0
COMMIT;

RETURN
end subroutine

public subroutine uf_prc_db_02 ();INTEGER	i,  					li_rtn,				li_cnt,					li_lp
DEC{2}	ldc_amt0[],			ldc_paymethamt[1 to 6] = {0, 0, 0, 0, 0, 0}
STRING 	ls_temp, 			ls_methodcd[], 	ls_trcod[],				ls_prt, 				&
			ls_memberid, 		ls_payid, 			ls_code, 				ls_codenm,			&
			ls_receipttype,	ls_ref_desc,		ls_rtype[],	 			ls_pgm_id, 			&
	 		ls_lin1,				ls_lin2,				ls_lin3,					ls_appseq,			&
			ls_chk,				ls_itemnm,			ls_val,					ls_regcod,			&
			ls_facnum,			ls_paid_trdt,		ls_method,				ls_method0[]
DEC		ldc_saleamt,		ldc_total,			ldc_change,			ldc_cash,		ldc_payamt
LONG		ll_seq,				ll_keynum,			ll_detrow
DATE		ld_paydt

//itemcod 순으로 정렬
idw_data[3].SetSort('itemcod A')
idw_data[3].Sort()

//lu_dbmgr.is_caller   = "b5w_reg_mtr_inp_cancel%direct"
//lu_dbmgr.is_title	   = Title
//lu_dbmgr.is_data[1]  = ls_customerid
//lu_dbmgr.is_data[2]  = ls_sales_date
//lu_dbmgr.is_data[3]  = gs_shopid
//lu_dbmgr.is_data[4]  = gs_user_id
//lu_dbmgr.is_data[5]  = 'Y'
//lu_dbmgr.is_data[6]  = ls_memberid
//lu_dbmgr.is_data[7]  = gs_pgm_id[1]
//lu_dbmgr.is_data[8]  = ls_new_apprno
//lu_dbmgr.idw_data[1] = dw_cond
//lu_dbmgr.idw_data[2] = dw_master
//lu_dbmgr.idw_data[3] = dw_detail
//
//lu_dbmgr.uf_prc_db_02()


//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])
//환불
ls_receipttype 	= ls_rtype[2]

//paymethod
ls_ref_desc = ""
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_methodcd[])

ii_rc			 		= -1
is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_memberid   		= is_data[6]
ls_pgm_id			= is_data[7]
ls_appseq			= is_data[8]

ld_paydt				= DATE(STRING(is_paydt, '@@@@-@@-@@'))

ll_detrow = idw_data[3].RowCount()

FOR i = 1 TO ll_detrow
	ldc_payamt = idw_data[3].object.payamt[i]  +  idw_data[3].object.taxamt[i]  
	ls_method  = idw_data[3].object.paymethod[i]
	
	IF ls_methodcd[1] = ls_method THEN
		ldc_paymethamt[1] += ldc_payamt
	ELSEIF ls_methodcd[2] = ls_method THEN	
		ldc_paymethamt[2] += ldc_payamt
	ELSEIF ls_methodcd[3] = ls_method THEN	
		ldc_paymethamt[3] += ldc_payamt
	ELSEIF ls_methodcd[4] = ls_method THEN	
		ldc_paymethamt[4] += ldc_payamt
	ELSEIF ls_methodcd[5] = ls_method THEN	
		ldc_paymethamt[5] += ldc_payamt
	ELSEIF ls_methodcd[6] = ls_method THEN	
		ldc_paymethamt[6] += ldc_payamt		
	END IF		
	
	idec_total += ldc_payamt
NEXT	
	
	
//idt_paydt   		= idw_data[1].object.paydt[1]
//idec_total   		= idw_data[1].object.total[1]
//idec_receive		= idw_data[1].object.cp_receive[1]
//idec_change   		= idw_data[1].object.cp_change[1]

//ls_trcod[1] 		= idw_data[1].object.trcode3[1]
//ls_trcod[2] 		= idw_data[1].object.trcode2[1]
//ls_trcod[3] 		= idw_data[1].object.trcode5[1]
//ls_trcod[4] 		= idw_data[1].object.trcode4[1]
//ls_trcod[5] 		= idw_data[1].object.trcode1[1]
		
//ls_method0[1] 		= idw_data[1].object.paymethod3[1]
//ls_method0[2] 		= idw_data[1].object.paymethod2[1]
//ls_method0[3] 		= idw_data[1].object.paymethod5[1]
//ls_method0[4] 		= idw_data[1].object.paymethod4[1]
//ls_method0[5] 		= idw_data[1].object.paymethod1[1]
		
//ldc_amt0[1] 		= idw_data[1].object.amt3[1]
//ldc_amt0[2] 		= idw_data[1].object.amt2[1]
//ldc_amt0[3] 		= idw_data[1].object.amt5[1]
//ldc_amt0[4] 		= idw_data[1].object.amt4[1]
//ldc_amt0[5] 		= idw_data[1].object.amt1[1]
//ii_amt_su 			= 0

//FOR i = 1 TO 5
//	IF ldc_amt0[i] <> 0 THEN 
//		ii_amt_su 				+= 1 
//		idc_amt[ii_amt_su] 	= ldc_amt0[i]
//		is_method[ii_amt_su] = ls_method0[i]
//	END IF
//NEXT

//customerm Search
SELECT MEMBERID, 		PAYID
INTO   :ls_memberid, :ls_payid
FROM   CUSTOMERM
WHERE  CUSTOMERID = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""

IF ls_prt = "Y" THEN
	//실 영수증 번호임.
	SELECT SEQ_APP.NEXTVAL INTO :is_app FROM DUAL;
	
	IF SQLCA.SQLCODE < 0 THEN
		ii_rc = -1			
		F_MSG_SQL_ERR(is_title, is_caller + " Sequence Error(seq_app)")
		ROLLBACK;
		RETURN 
	END IF
END IF

//----------------------------------------------------------
//SHOP COUNT
SELECT SHOPCOUNT	INTO :il_shopcount
FROM   PARTNERMST
WHERE  PARTNER = :is_partner;

IF ISNULL(il_shopcount) THEN il_shopcount = 0
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//----------------------------------------------------------
il_shopcount += 1
INSERT INTO RECEIPTMST
			( APPROVALNO,		SHOPCOUNT,		RECEIPTTYPE,		SHOPID,				POSNO,
			  WORKDT,			TRDT,				MEMBERID,			OPERATOR,			TOTAL,
			  CASH,				CHANGE,			SEQ_APP,				CUSTOMERID,			PRT_YN )
VALUES	( :ls_appseq,	 	:il_shopcount,	:ls_receipttype,	:is_partner, 		NULL,
			  sysdate,		   :ld_paydt,		:ls_memberid,		:is_operator,		:idec_total,
			  :idec_total,		0,					:is_app,				:is_customerid,	:ls_prt )	 ;
			  
IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Insert Error(RECEIPTMST)")
	ROLLBACK;
	RETURN
END IF

//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
UPDATE PARTNERMST
SET	 SHOPCOUNT = :il_shopcount
WHERE  PARTNER	  = :is_partner;

IF SQLCA.SQLCODE < 0 THEN
	ii_rc = -1			
	F_MSG_SQL_ERR(is_title, is_caller + " Update  Error(PARTNERMST)")
	ROLLBACK;
	RETURN 
END IF

//-------------------------------------------------------
//영수증 출력........
//-------------------------------------------------------
// 2019.04.23 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by typark

string ls_prnbuf, ls_name[]
long   ll_print_row
long   ll_prt_ln, ll_temp
string ls_normal = "~h1B" + "!" + "~h08" + "~h1B" + "E" + "~h00"  // Normal Character
String ls_Cut    = "~h1B" + "~h69"                                // Cut Paper
int li_handle

ls_temp 			= GS_PRN
IF IsNull(ls_temp) OR ls_temp = ''  then
	ls_temp = "COM1;6;8;2;0"
END IF	
fi_cut_string(ls_temp, ";", ls_name[])

li_handle = FileOpen(ls_name[1], StreamMode!, Write!)
		
IF li_handle < 1  THEN
	MessageBox('알 림', '프린터 오픈 에러입니다.')
	FileClose(li_handle)
	SetPointer(Arrow!)
//	Return
END IF

// Structure 초기화 
ll_print_row = gs_str_receipt_print.ll_line_num
if ll_print_row > 0 then
	for ll_print_row = 1 to gs_str_receipt_print.ll_line_num
		gs_str_receipt_print.ls_out[ll_print_row] = ""
	next
	gs_str_receipt_print.ll_line_num = 0
end if


ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ii_rc 		= 0
IF ls_prt = "Y" THEN
	//head 출력
	li_rtn = f_pos_header_vat(GS_SHOPID, 'A', il_shopcount, 1 )
	li_rtn = 1  //임시...
	IF li_rtn < 0 THEN
		MESSAGEBOX('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
		FileClose(li_handle)
//		PRN_CLOSEPORT()
		ii_rc = -9	
		ROLLBACK;
//		RETURN
	END IF

	//Item List 출력
	il_row = idw_data[3].RowCount()
	FOR i = 1 TO il_row
		ll_seq 		 += 1
		ls_temp 		 = String(i, '000') + ' ' //순번
		is_itemcod 	 = trim(idw_data[3].Object.itemcod[i])
		ls_itemnm 	 = trim(idw_data[3].Object.itemnm[i])
		IF IsNull(ls_itemnm) then ls_itemnm 	= ""
			
		ldc_saleamt	 = idw_data[3].Object.payamt[i]	
		ldc_total 	 += ldc_saleamt 
		ls_temp 		 += LeftA(ls_itemnm + space(24), 24) + ' '   //아이템
		li_cnt 		 =  1
		ls_temp 		 += RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
		ls_val 		 = fs_convert_amt(ldc_saleamt,  8)
		ls_temp 		 += ls_val //금액
		f_printpos_vat(' ' + ls_temp)	
		ls_regcod =  trim(idw_data[3].Object.regcod[i])
		//regcode master read
		SELECT KEYNUM,	TRIM(FACNUM)
		INTO   :ll_keynum,	:ls_facnum
		FROM   REGCODMST
		WHERE  REGCOD = :ls_regcod;
		
		// Index Desciption 2010-08-20 jhchoi
		SELECT indexdesc
		INTO	 :ls_facnum
		FROM	 SHOP_REGIDX
		WHERE	 regcod = :ls_regcod
		AND	 shopid = :is_partner;					
		
		IF IsNull(ll_keynum) OR sqlca.sqlcode < 0	THEN ll_keynum 	= 0
		IF IsNull(ls_facnum) OR sqlca.sqlcode < 0	THEN ls_facnum 	= ""
		
		//2010.08.20 jhchoi 수정.
		//ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
		ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")"			
			
		f_printpos_vat(' ' + ls_temp)
	NEXT			
			
	F_POS_PRINT_VAT(' ' + ls_lin1, 1)
	
	ls_val 	= fs_convert_sign(ldc_total, 8)
	ls_temp 	= LeftA("Grand Total" + space(33), 33) + ls_val
	f_printpos_vat(' ' + ls_temp)
	f_printpos_vat(' ' + ls_lin1)
	//결제 수단별 금액 처리
	String ls_methodnm
	FOR li_lp = 1 TO 6
		ldc_cash = ldc_paymethamt[li_lp]
		ls_code 	= ls_methodcd[li_lp]
		IF ldc_cash <> 0 THEN
			ls_val 	= fs_convert_sign(ldc_cash,  8)
			
			SELECT CODENM INTO :ls_codenm FROM syscod2t
			WHERE  GRCODE = 'B310' 
			AND    USE_YN = 'Y'
			AND    CODE   = :ls_code ;
				  
			ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
			f_printpos_vat(' ' + ls_temp)
		END IF
	NEXT
	
	ls_val 	= fs_convert_sign(ldc_change,  8)
	ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
	f_printpos_vat(' ' + ls_temp)
	f_printpos_vat(' ' + ls_lin1)
//	Fs_POS_FOOTER2(ls_payid,is_customerid,is_app,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 		
	FS_POS_FOOTER3_VAT(ls_payid,is_customerid,is_app,gs_user_id, String(ld_paydt, "YYYYMMDD"))
	
	for ll_prt_ln = 1 to gs_str_receipt_print.ll_line_num
		ls_prnbuf = ls_prnbuf + ls_normal + gs_str_receipt_print.ls_out[ll_prt_ln]
	next

	ls_prnbuf = ls_prnbuf + ls_cut

	ll_temp = fileWrite(li_handle, ls_prnbuf)

	if ll_temp = -1 then
		FileClose(li_handle)
//		return
	end if

//	PRN_ClosePort()
END IF

FileClose(li_handle)

ii_rc = 0
COMMIT;

RETURN
end subroutine

on ubs_dbmgr_receiptmst.create
call super::create
end on

on ubs_dbmgr_receiptmst.destroy
call super::destroy
end on

event constructor;call super::constructor;//
end event

