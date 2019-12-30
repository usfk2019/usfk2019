$PBExportHeader$b1u_dbmgr_dailypayment.sru
$PBExportComments$[1hera] DBmanager
forward
global type b1u_dbmgr_dailypayment from u_cust_a_db
end type
end forward

global type b1u_dbmgr_dailypayment from u_cust_a_db
end type
global b1u_dbmgr_dailypayment b1u_dbmgr_dailypayment

type variables
String 	is_customerid, is_customernm, &
			is_saledt, 		is_partner,		&
			is_operator,	is_userid, 		 &
			is_appseq, 		is_memberid
DEC{2}	idec_receive,	idec_change,	idec_total, 		idec_saleamt,	idec_imnot,	idec_im
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
public subroutine uf_prc_db_05 ()
public subroutine uf_prc_db_09 ()
public subroutine uf_prc_db_07 ()
public subroutine uf_prc_db_08 ()
end prototypes

public subroutine uf_prc_db_05 ();//개통신청시 즉시불 화면 전용!
//total 이 - 이면 + 금액부터 정렬 시켜서 처리   (-) - (+) 는 계속  -로 누적되기 때문에
//         + 이면 - 금액부터 정렬 시켜서 처리   (+) - (-) 는 계속  +로 누적되기 때문에...
// ---------------------------------------------------------------------------------------------
// HISTORY
// ADD : 2009-06-13 : 최재혁  impack 카드 금액 분리시키기 위해 새로 적용된 로직!

date		ldt_refunddt,	ldt_shop_closedt			
Integer	i, jj, 			li_first, 			li_pp, 			LI_QTY,		li_rtn, ll_bonus, li_update
Long		ll_qty,			ll_retseq,			ll_cnt
dec{2}	ldc_salerem, 	ldc_saleamt, 		ldc_amt0[],		ldc_impack,	ldc_impack_in
String 	ls_refund_type, 	ls_remark, 		ls_receipt_type, &
			ls_manual_yn,	ls_modelno, 		ls_adlog_yn, 	ls_refundtype
String 	ls_temp, 		ls_method0[], 		ls_trcod[]
String   ls_prt, 			ls_memberid, 		ls_payid, 		ls_basecod, &
			ls_admst_yn, 	ls_code, 			ls_codenm, &
			ls_dctype, 		ls_receipttype, 	ls_admst_status, ls_ref_desc, &
			ls_rtype[], 	ls_adsta_ret,		ls_pgm_id, 		ls_orderno,		&
			ls_serialno,	ls_remark2,       ls_sale_type,	ls_end, ls_add

// 2019.04.24 VAT 처리를 위한 변수 추가 Modified by Han
//string   ls_customerid
dec{2}   ld_taxrate,    ld_sale_tot, ld_taxamt, ld_vat

//add - 2009.06.13
String	ls_trcod_im,	ls_method0_im
DEC{2}	ldc_amt0_im

//장비 status
ls_admst_Status	= fs_get_control("E1", "A103", ls_ref_desc)
//E1,A103
ls_adsta_ret		= fs_get_control("E1", "A102", ls_ref_desc)

//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])
//정렬 순서 조정. 토탈이 - 일경우 + 금액부터, +금액일 경우 - 금액부터
idec_total   		= idw_data[1].object.total[1]
ldc_impack 			= idw_data[1].object.amt5[1] 	


Choose Case is_caller
	case "save_refund"
			ls_receipt_type  	= 'B'
			ls_dctype 			= 'C'
			ls_receipttype 	= ls_rtype[2]
			idw_data[2].SetSort('refund_price A')
			idw_data[2].Sort()
	CASE 'hotbill'
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'D'
			ls_receipttype 	= ls_rtype[2]
			idw_data[2].SetSort('ss A, cp_amt A')
			idw_data[2].Sort()
	//개통오더 취소시에 DCTYP을 무조건 'C'로 변경 요청 박자연(2011.11.17)
	//아래 'direct_can' 을 별도로 구성 처리함. kem modify 2011.11.17
	CASE 'direct_can'
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'C'
			ls_receipttype 	= ls_rtype[1]
			IF idec_total > 0 THEN
				IF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt A')
				ELSEIF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt A')
				ELSE
					idw_data[2].SetSort('sale_amt A')
				END IF
			ELSE
				IF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt D')
				ELSEIF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt D')
				ELSE
					idw_data[2].SetSort('sale_amt D')
				END IF				
			END IF
			idw_data[2].Sort()
	//--------------------------------------------------------------------------
	Case ELSE
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'D'
			ls_receipttype 	= ls_rtype[1]
			IF idec_total > 0 THEN
				IF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt A')
				ELSEIF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt A')
				ELSE
					idw_data[2].SetSort('sale_amt A')
				END IF
			ELSE
				IF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt D')
				ELSEIF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt D')
				ELSE
					idw_data[2].SetSort('sale_amt D')
				END IF				
			END IF
			idw_data[2].Sort()
End Choose


ii_rc 		= -1
li_first 	= 0

is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_admst_yn			= is_data[7]
ls_memberid   		= is_data[8]
ls_adlog_yn   		= is_data[9]
ls_pgm_id			= is_data[10]
ldt_shop_closedt 	= f_find_shop_closedt(is_partner)
idt_paydt   		= idw_data[1].object.paydt[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]
ls_orderno			= idw_data[1].object.orderno[1]
		
ls_trcod[1] 		= idw_data[1].object.trcod3[1]
ls_trcod[2] 		= idw_data[1].object.trcod2[1]
ls_trcod[3] 		= idw_data[1].object.trcod4[1]
ls_trcod[4] 		= idw_data[1].object.trcod1[1]	
ls_trcod[5] 		= idw_data[1].object.trcod6[1]	

ls_method0[1] 		= idw_data[1].object.method3[1]
ls_method0[2] 		= idw_data[1].object.method2[1]
ls_method0[3] 		= idw_data[1].object.method4[1]
ls_method0[4] 		= idw_data[1].object.method1[1]
ls_method0[5] 		= idw_data[1].object.method6[1]

ldc_amt0[1] 		= idw_data[1].object.amt3[1]
ldc_amt0[2] 		= idw_data[1].object.amt2[1]
ldc_amt0[3] 		= idw_data[1].object.amt4[1]
ldc_amt0[4] 		= idw_data[1].object.amt1[1]
ldc_amt0[5] 		= idw_data[1].object.amt6[1]

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= idw_data[1].object.trcod5[1]
	ls_method0_im	= idw_data[1].object.method5[1]	
	ldc_amt0_im		= idw_data[1].object.amt5[1]			
END IF
	
ii_amt_su 			= 0
//----------------------------------------------------------
FOR i = 1 to 5			//impack 은 별도!!!
			IF ldc_amt0[i] <> 0 THEN 
				ii_amt_su 				+= 1 
				idc_amt[ii_amt_su] 	= ldc_amt0[i]
				is_method[ii_amt_su] = ls_method0[i]
			end if
NEXT
//----------------------------------------------------------
//customerm Search
select memberid, 		payid, 		basecod
  INTO :ls_memberid, :ls_payid, :ls_basecod
  FROM customerm
 WHERE customerid = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""
//----------------------------------------------------------
//1.receiptMST Insert
//SEQ 
Select seq_receipt.nextval		  Into :is_appseq						  From dual;
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_receipt)")
	RollBack;
	Return 
End If			
		
IF ls_prt = "Y" then
	//실 영수증 번호임.
	Select seq_app.nextval		  Into :is_app						  From dual;
	If SQLCA.SQLCode < 0 Then
		ii_rc = -1			
		f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_app)")
		RollBack;
		Return 
	End If			
END IF
//----------------------------------------------------------
//SHOP COUNT
Select shopcount	    Into :il_shopcount	  From partnermst
 WHERE partner = :is_partner ;
		 
IF IsNull(il_shopcount) THEN il_shopcount = 0
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update Error(PARTNERMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
il_shopcount += 1
insert into RECEIPTMST
				( approvalno,	shopcount,			receipttype,	shopid,			posno,
				  workdt,		trdt,				   memberid,		operator,		total,
				  cash,			change, 				seq_app, 		customerid,		prt_yn )
			values 
			   ( :is_appseq, 	:il_shopcount,		:ls_receipttype,:is_partner, 	NULL,
				  sysdate,	   :idt_paydt,			:ls_memberid,	:is_operator,	:idec_total,
				  :idec_receive,:idec_change,		:is_app,			:is_customerid,:ls_prt )	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Insert Error(RECEIPTMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
Update partnermst
			Set shopcount 	= :il_shopcount
			Where partner  = :is_partner ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update  Error(PARTNERMST)")
	RollBack;
	Return 
End If	
//----------------------------------------------------------
// ADMST Update & dailypament에 Insert
il_row 		= idw_data[2].RowCount()
ii_method	= 1

IF is_caller = "save_refund" THEN
	ls_remark =  trim(idw_data[1].Object.remark[1])
	ls_remark2 = ''
	ldt_refunddt =  idw_data[1].Object.paydt[1]
ELSEIF is_caller = "direct" or is_caller = "direct_can" THEN
	ls_remark =  trim(idw_data[1].Object.remark[1])
END IF
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ls_add = 'N'
ls_end = 'N'

For i = 1 To il_row
	is_contno 		= trim(idw_data[2].object.contno[i])
	ls_modelno 		= trim(idw_data[2].object.modelno[i])
	ll_qty 			= idw_data[2].object.qty[i]
	IF is_caller = "save_refund" then
		ls_refund_type = trim(idw_data[2].object.refund_type[i])
	ELSE
		ls_refund_type =''
	END IF
	IF IsNull(ls_refund_type) then ls_refund_type = ''
		
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refundtype	= idw_data[2].object.REFUND_TYPE[i]
				if iSnULL(ls_refundtype) then ls_refundtype = ""
		Case else
				idec_saleamt 	= idw_data[2].object.sale_amt[i]								
				
				// 2019.04.24 Vat 포함한 금액 및  Vat  추가 Modified By Han
				ld_sale_tot    = idw_data[2].Object.sale_amt[i] + idw_data[2].Object.vat_amt[i]
				ld_vat         = idw_data[2].Object.vat_amt [i]

				IF ldc_impack <> 0 THEN
					idec_imnot 		= idw_data[2].object.impack_not[i]
					idec_im			= idw_data[2].object.impack_card[i]
				END IF
	End Choose
	li_first 		= 0
	li_update		= 0	
			
	//장비마스터 Update 여부 확인....
	if ls_admst_yn = "Y" THEN
		IF is_contno <> "" THEN
			choose case is_caller
				CASE "save_refund" //반품 처리
				   IF ls_refund_type <> '' THEN
						ls_modelno 		= trim(idw_data[2].Object.modelno[i])
						ls_refund_type	= trim(idw_data[2].Object.refund_type[i])
						idec_saleamt 	= idw_data[2].object.refund_price[i]
						Select seq_adreturn.nextval		  Into :ll_retseq	  From dual;
						If SQLCA.SQLCode < 0 Then
								ii_rc = -1			
								f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_adreturn)")
								RollBack;
								Return 
						End If			
						//1.adreturn insert		장비반품정보
						Insert Into adreturn 
										( retseq, 				returndt, 		partner, 		contno, 		modelno, 
										  refund_type, 		refund_amt,	  	note, 			crtdt, 		crt_user, 	pgm_id)
								Values( :ll_retseq, 			:ldt_refunddt, :is_partner,	:is_contno, :ls_modelno, 
										  :ls_refund_type, 	:idec_saleamt, :ls_remark,  	sysdate, 	:gs_user_id, :is_data[5]);
						If SQLCA.SQLCode < 0 Then
							ii_rc = -1
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADRETURN)")
							Rollback ;
							Return 
						End If		
					
					
					//a. ADMST Update
						Update ADMST
							Set retdt 		= :idt_paydt,
  					  	  		Status 		= :ls_adsta_ret,
								mv_partner  = :is_partner,
  					   	 	sale_flag	= '0',
  					   	 	retseqno	   = :ll_retseq,
								updt_user 	= :gs_user_id,
						 		updtdt 		= sysdate,
						 		pgm_id 		= :is_pgm_id					 
							Where contno 	= :is_contno ;
					END IF
				CASE ELSE
					ls_sale_type     		= trim(idw_data[2].Object.sale_type[i])
					IF ls_sale_type = 'Y' THEN // 장비 판매인 경우, 판매와 충전이 동시에 올경우 판매에서만 Update 2007-08-06 hcjung
					    //a. ADMST Update
						 UPDATE ADMST
							 SET saledt 	 = :idt_paydt,
  							     customerid = :is_customerid,
  							     sale_amt   = :idec_saleamt,
  					  	  		  status     = :ls_admst_status,
  					   	 	  sale_flag	 = '1',
								  updt_user  = :gs_user_id,
						 		  updtdt 	 = sysdate,
						 		  pgm_id 	 = :is_pgm_id					 
						  WHERE contno 	 = :is_contno;
					END IF
				END CHOOSE
				
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
				End If
			END IF
			IF ls_adlog_yn = "Y" AND ls_modelno <> "" THEN
				//--------------AD_SALELOG 처리
				//ad_salelog insert	
				Insert Into ad_salelog	(saleseq, 	
								saledt, 					SHOPID,				saleqty,			sale_amt,		
								sale_sum,				paymethod,			modelno,			contno,		
								note,						crt_user,			crtdt, 			pgm_id)
				Values(		seq_ad_salelog.nextval,
								:idt_paydt,	:is_partner,		:ll_qty, 		:idec_saleamt , 
								:idec_saleamt, 		null,					:ls_modelno,	:is_contno,
								null,						:gs_user_id,		sysdate,			:is_data[5]		);
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(AD_SALELOG)")
					RollBack;
					Return 
				End If
			END IF
	END IF
		
	//===================================================
	//b. dailypayment Insert
	// regcod search
	//====================================================
	is_itemcod 		= trim(idw_data[2].object.itemcod[i])
	ll_qty 			= idw_data[2].object.qty[i]
	is_regcod 		= trim(idw_data[2].object.regcod[i])
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
				
				ls_manual_yn 	= 'N'
				ls_remark 		= is_contno
				ls_remark2		= idw_data[2].object.remark[i]
		Case "direct", "direct_can" 
				ls_remark 		= idw_data[1].object.remark[1]
				ls_remark2		= ""
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= 'N'
		Case "save_sales" 
				ls_remark 		= idw_data[2].object.remark[i]
				ls_remark2 		= idw_data[2].object.remark2[i]
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= idw_data[2].object.manual_yn[i]
		case else
				ls_remark 		= ''
				ls_remark2		= ""
				idec_saleamt 	= 0
				ls_refund_type = ''
				ls_manual_yn 	= ''
	End Choose
	
	IF ( is_caller = 'save_refund' AND ls_refund_type <> '' ) OR  is_caller <> 'save_refund' THEN
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		IF ii_amt_su > 0 THEN
			IF ldc_impack > 0 THEN											//IMPACK 카드로 수납 + 경우
				IF idec_im <> 0 THEN
					IF li_first 	= 0 then									//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty									//ITEM 수량 입력
						li_first 	= 1										//첫번째 로우 아니라는 표시
					else 
						il_paycnt 	= 0										//첫번째 로우 아니면 수량 0 세팅!
					END IF					
					
					IF ldc_impack - idec_im < 0 THEN						//받은 IMPACK 카드보다 ITEM 할인율이 더 높으면 종료
						idec_saleamt = idec_saleamt - ldc_impack		//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = ldc_impack
						ldc_impack = 0											//IMPACK 카드 처리를 종료시킨다.										
					ELSE
						ldc_impack = ldc_impack - idec_im				//IMPACK 카드수납금에서 아이템 IMPACK 금액을 깐다.
						idec_saleamt = idec_imnot							//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = idec_im									
					END IF
					
					li_update = 1					
					
				END IF
			ELSEIF ldc_impack < 0 THEN										//IMPACK 카드로 수납을 했을 경우!
				IF idec_im <> 0 THEN
					IF li_first 	= 0 then									//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty									//ITEM 수량 입력
						li_first 	= 1										//첫번째 로우 아니라는 표시
					else 
						il_paycnt 	= 0										//첫번째 로우 아니면 수량 0 세팅!
					END IF
					
					IF ldc_impack - idec_im > 0 THEN						//받은 IMPACK 카드보다 ITEM 할인율이 더 높으면 종료
						idec_saleamt = idec_saleamt - ldc_impack		//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = ldc_impack
						ldc_impack = 0											//IMPACK 카드 처리를 종료시킨다.										
					ELSE
						ldc_impack = ldc_impack - idec_im				//IMPACK 카드수납금에서 아이템 IMPACK 금액을 깐다.
						idec_saleamt = idec_imnot							//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = idec_im									
					END IF
					
					li_update = 1
					
				END IF				
			END IF	
			
			IF li_update = 1 THEN
				INSERT INTO dailypayment
						( payseq,							paydt,			
						  shopid,		operator,		customerid,
						  itemcod,		paymethod,		regcod,			payamt,			basecod,
						  paycnt,		payid,			remark,			trdt,				mark,
						  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
						  manual_yn,	pgm_ID,			remark2,			orderno)
				VALUES
						( seq_dailypayment.nextval, 	 :idt_paydt, 	
						  :is_partner, :is_operator, 	 :is_customerid,
						  :is_itemcod,	:ls_method0_im, :is_regcod,		:ldc_impack_in,	:ls_basecod,
						  :il_paycnt,	:ls_payid,		 :ls_remark,		sysdate,				null,
						  NULL,			:ls_dctype,		 :is_appseq,		sysdate,				sysdate,		:gs_user_id,
						  :ls_manual_yn, :ls_pgm_id,	 :ls_remark2,		:ls_orderno )	 ;	
				//저장 실패 
				IF SQLCA.SQLCode < 0 THEN
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_impact)")
					ROLLBACK;
					RETURN
				END IF
			END IF

// 2019.04.24 Item별 taxrate를 가져온다 Modified by Han

			SELECT FNC_GET_TAXRATE(:is_customerid, 'I', :is_itemcod, :idt_paydt)
			  INTO :ld_taxrate
			  FROM DUAL;

			IF ld_taxrate <> 0 then
				//합계액으로 공급가액과 부가세를 나눠주는 공식임.
				ld_taxrate = 1 + ( ld_taxrate / 100)
			ELSE
				// 0으로 나눠주면 에러남
				ld_taxrate = 1
			END IF

			IF ls_end = 'N' THEN											//수납이 끝나지 않았을 경우!
				//FOR li_pp Start											//임팩 카드를 제외한 수납 처리!
				FOR li_pp =  ii_method to ii_amt_su					//수납유형 수만큼 루프.
					is_paymethod 	= is_method[li_pp]				//수납유형 있는것만...
					idc_rem 			= idc_amt[li_pp]					//수납유형에 있는 금액...
					
					IF li_first 	= 0 then								//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty								//ITEM 수량 입력
						li_first 	= 1									//첫번째 로우 아니라는 표시
					ELSE 														//첫번째 로우 아니면 수량 0 세팅!
						il_paycnt 	= 0
					END IF								
					
					IF idc_rem > 0 THEN									//수납유형에 + 금액이면
						IF idc_rem - idec_saleamt <= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
//							ldc_saleamt	 = idc_rem						//품목금액을 넣는다.
//							idec_saleamt = idec_saleamt - idc_rem	//loop 를 돌리기 위해서
// 2019.04.24 Vat 처리 추가
							ldc_saleamt	 = round(idc_rem / ld_taxrate, 2) // 품목공급금액을 넣는다.
							ld_taxamt    = idc_rem - ldc_saleamt          // 부가세
							ld_sale_tot  = ld_sale_tot - idc_rem	       // loop 를 돌리기 위해서

							IF ii_method = ii_amt_su THEN				//나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								//나누기 처리 끝...
								IF idec_saleamt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
									ls_add = 'Y'
								END IF
							END IF	
							idc_rem		 = 0								//수납금액을 0으로
							ii_method	+= 1		

						ELSE													//수납유형에 돈이 남아있으면...다음 아이템으로						
//							idc_rem		 = idc_rem - idec_saleamt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = idec_saleamt				//품목금액을 넣는다.
//							idec_saleamt = 0								//loop 를 빼기 위해서!		
// 2019.04.24 Vat 처리 추가
							idc_rem		 = idc_rem - ld_sale_tot	            // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
							ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
							ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
							ld_sale_tot  = 0				                        // loop 를 빼기 위해서!		

						END IF
					ELSEIF idc_rem < 0 THEN								//수납유형에 - 금액이면
//						IF idc_rem - idec_saleamt >= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
						IF idc_rem - ld_sale_tot >= 0 THEN			// 2019.04.24 Modified by Han
//							ldc_saleamt	 = idc_rem						//품목금액을 넣는다.
//							idec_saleamt = idec_saleamt - idc_rem	//loop 를 돌리기 위해서
// 2019.04.24 Vat 처리 추가
							ldc_saleamt	 = round(idc_rem / ld_taxrate, 2) // 품목금액을 넣는다.
							ld_taxamt    = idc_rem - ldc_saleamt           // 부가세
							ld_sale_tot  = ld_sale_tot - idc_rem          // loop 를 돌리기 위해서
							IF ii_method = ii_amt_su THEN				//나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								//나누기 처리 끝...
//								IF idec_saleamt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
								IF ld_sale_tot <> 0 THEN				// 2019.04.24 Modified by Han
									ls_add = 'Y'
								END IF
							END IF
							idc_rem		 = 0								//수납유형에 있는 금액에서 아이템 금액을 빼준다.													
							ii_method	+= 1												
						ELSE
//							idc_rem		 = idc_rem - idec_saleamt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = idec_saleamt				//품목금액을 넣는다.
//							idec_saleamt = 0								//loop 를 빼기 위해서!	
// 2019.04.24 Vat 처리 추가
							idc_rem		 = idc_rem - ld_sale_tot               // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
							ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
							ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
							ld_sale_tot  = 0                                   // loop 를 빼기 위해서!	

						END IF						
					ELSE														//아이템은 있는데 수납이 다 까졌을 때...
//						ldc_saleamt  = idec_saleamt					//품목금액을 넣는다.
//						idec_saleamt = 0									//loop 를 빼기 위해서!
// 2019.04.24 Vat 처리 추가
						ldc_saleamt  = ld_sale_tot - ld_vat              // 품목금액을 넣는다.
						ld_taxamt    = ld_vat                            //부가세
						ld_sale_tot  = 0									       //loop 를 빼기 위해서!
						is_paymethod = '101'								//cash
					END IF
	
					insert into dailypayment
							( payseq,							paydt,			
							  shopid,		operator,		customerid,
							  itemcod,		paymethod,		regcod,			payamt,			basecod,
							  paycnt,		payid,			remark,			trdt,				mark,
							  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
							  manual_yn,	pgm_ID,			remark2,			orderno,       taxamt)
					values 
							( seq_dailypayment.nextval, 	:idt_paydt, 	
							  :is_partner, :is_operator, 	:is_customerid,
							  :is_itemcod,	:is_paymethod,	:is_regcod,		:ldc_saleamt,	:ls_basecod,
							  :il_paycnt,	:ls_payid,		:ls_remark,		sysdate,			null,
							  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
							  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ls_orderno,   :ld_taxamt )	 ;
							
					//저장 실패 
					If SQLCA.SQLCode < 0 Then
						ii_rc = -1			
						f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_paymethod)")
						RollBack;
						Return 
					End If
					
					IF ls_add = 'Y' THEN
//						is_paymethod = '101'
//						
//						insert into dailypayment
//								( payseq,							paydt,			
//								  shopid,		operator,		customerid,
//								  itemcod,		paymethod,		regcod,			payamt,			basecod,
//								  paycnt,		payid,			remark,			trdt,				mark,
//								  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
//								  manual_yn,	pgm_ID,			remark2)
//						values 
//								( seq_dailypayment.nextval, 	:idt_paydt, 	
//								  :is_partner, :is_operator, 	:is_customerid,
//								  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
//								  0,				:ls_payid,		:ls_remark,		sysdate,			null,
//								  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
//								  :ls_manual_yn, :ls_pgm_id,	:ls_remark2 )	 ;
//								
//						//저장 실패 
//						If SQLCA.SQLCode < 0 Then
//							ii_rc = -1			
//							f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_add)")
//							RollBack;
//							Return 
//						End If
					END IF				
			
					idc_amt[li_pp]	= idc_rem					
					IF idec_saleamt = 0 then exit
				NEXT
			ELSE				//수납이 끝났지만 ITEM 이 남아 있을 경우!
				is_paymethod = '101'    // B310, cash
			
				insert into dailypayment
						( payseq,							paydt,			
						  shopid,		operator,		customerid,
						  itemcod,		paymethod,		regcod,			payamt,			basecod,
						  paycnt,		payid,			remark,			trdt,				mark,
						  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
						  manual_yn,	pgm_ID,			remark2,			orderno)
				values 
						( seq_dailypayment.nextval, 	:idt_paydt, 	
						  :is_partner, :is_operator, 	:is_customerid,
						  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
						  :ll_qty,		:ls_payid,		:ls_remark,		sysdate,			null,
						  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
						  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ls_orderno )	 ;
						
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
					RollBack;
					Return 
				End If				
			END IF				
		ELSE		//수납유형이 한개도 없을 경우!
			is_paymethod = '101'    // B310, cash
		
			insert into dailypayment
					( payseq,							paydt,			
					  shopid,		operator,		customerid,
					  itemcod,		paymethod,		regcod,			payamt,			basecod,
					  paycnt,		payid,			remark,			trdt,				mark,
					  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
					  manual_yn,	pgm_ID,			remark2,			orderno)
			values 
					( seq_dailypayment.nextval, 	:idt_paydt, 	
					  :is_partner, :is_operator, 	:is_customerid,
					  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
					  :ll_qty,		:ls_payid,		:ls_remark,		sysdate,			null,
					  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
					  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ls_orderno )	 ;
					
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
				RollBack;
				Return 
			End If
		END IF
		
		//FOR li_pp END
	END IF

NEXT

////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// ssrtppcif Insert
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Choose Case is_caller
    Case "save_sales" 			
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	          WHERE grcode = 'DacomPPC02' 
				   AND use_yn = 'Y'
	            AND CODE  = :is_itemcod;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.sale_amt[i]
		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;

		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (seq_ssrtppcif.nextval,'SALES','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If		
	         ELSE 
		      // Check 2
	             SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	              WHERE grcode = 'DacomPPC01' 
					    AND use_yn = 'Y'
	                AND CODE  = :is_itemcod ;
		
                IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
                IF ll_cnt > 0  AND is_caller = "save_sales" then
                    idec_saleamt 	= idw_data[2].object.sale_amt[i]
		              is_contno 		= trim(idw_data[2].object.contno[i])
				
                    select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
					 
                    SELECT count(*) INTO :ll_bonus FROM syscod2t
					      WHERE grcode = 'DacomPPC03'
							  AND use_yn = 'Y'
					        AND code = :is_itemcod; 

						  IF sqlca.sqlcode <> 0 OR IsNull(ll_bonus) THEN ll_bonus  = 0
                    
						  IF ll_bonus > 0  THEN
                        INSERT INTO ssrtppcif
								(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
							   VALUES
                        (seq_ssrtppcif.nextval,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.1)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
						  ELSE
                        INSERT INTO ssrtppcif 
								(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
								VALUES 
								(seq_ssrtppcif.nextval,'Recharge','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
						  END IF
								
                    If SQLCA.SQLCode < 0 Then
                        ii_rc = -1			
                        f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
                        RollBack ;
                        Return 
                    END IF
                End If	
            END IF
        NEXT
    Case "save_refund"
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         select Count(*) INTO :ll_cnt FROM syscod2t 
	          where grcode = 'DacomPPC02' 
	            AND CODE  = :is_itemcod ;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.refund_price[i]
//		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (seq_ssrtppcif.nextval,'REFUND','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0',:ls_pgm_id);

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If
				End IF
        NEXT		
End Choose
	

// ssrtppcif Insert ============>> END.....

//-------------------------------------------------------
//마지막으로 영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[2].SetSort('itemcod A')
idw_data[2].Sort()


String ls_lin1, ls_lin2, ls_lin3, ls_empnm
DEC	 ldc_shopCount

// 2019.04.24 VAT 출력을 위한 변수 추가 Modified by Han
string ls_surtaxyn
DEC{2} ld_vat_tot, ld_net_tot

// 2019.04.22 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by Han

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
	//1. head 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//	FOR jj = 1  to 2
//		IF jj = 1 then 
			li_rtn = f_pos_header_vat(is_partner, ls_receipt_type, il_shopcount, 1 )
//		ELSE 
//			li_rtn = f_pos_header(is_partner, 'Z', il_shopcount, 0 )
//		END IF
		IF li_rtn < 0 then
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
//			PRN_ClosePort()
			FileClose(li_handle)
			ii_rc = -9		
//			return 
		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		il_row = idw_data[2].RowCount()
		For i = 1 To il_row
			is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			IF is_caller = "save_refund" then
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
			ELSE
				ls_refund_type = 'A'
			END IF
			
	      IF ls_refund_type <> '' THEN
			    ls_temp 		= String(i, '000') + ' ' //순번
			    is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			    is_itemNM 		= trim(idw_data[2].Object.itemNM[i])
			    li_qty 			= idw_data[2].Object.qty[i]
			    
				 IF IsNull(li_qty) OR li_qty  = 0 THEN li_qty = 1
			    
				 Choose Case is_caller
				     case "save_refund"
					       idec_saleamt 	= idw_data[2].object.refund_price[i]
				     Case "direct", "save_sales", "direct_can"  
					       idec_saleamt 	= idw_data[2].object.sale_amt[i] + idw_data[2].Object.vat_amt[i]
							 ld_net_tot   += idw_data[2].object.sale_amt[i]
							 ld_vat_tot   += idw_data[2].Object.vat_amt [i]
							 ls_surtaxyn   = idw_data[2].Object.surtaxyn[i]
			    End Choose

			    IF IsNull(is_itemNM) then is_itemNM 	= ''
	
	          ls_temp 	+= LeftA(is_itemnm + space(25), 24)  //아이템
			    ls_temp 	+= Space(1) + RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
			    is_val 	= fs_convert_amt(idec_saleamt,  8)
			    ls_temp 	+= is_val //금액
			    F_POS_PRINT_VAT(' ' + ls_temp, 1)	
	
			    is_regcod =  trim(idw_data[2].Object.regcod[i])
			    //regcode master read
			    select keynum, 		trim(facnum)
		  	      INTO :il_keynum,	:is_facnum
		  	      FROM regcodmst
		 	     where regcod = :is_regcod ;
					
				 // Index Desciption 2008-05-06 hcjung
			    SELECT indexdesc
		  	      INTO :is_facnum
		  	      FROM SHOP_REGIDX
		 	     WHERE regcod = :is_regcod
					 AND shopid = :is_partner;
	
			    IF IsNull(il_keynum) or sqlca.sqlcode < 0	then il_keynum 	= 0
			    IF IsNull(is_facnum) or sqlca.sqlcode < 0	then is_facnum 	= ""
				 //ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
			    ls_temp =  Space(4) + "(KEY#" + String(il_keynum) + " " + is_facnum + ")"	+  ' ' + ls_surtaxyn
			    F_POS_PRINT_VAT(' ' + ls_temp, 1)
         END IF
		NEXT
		//2. Item List 출력 ----- end
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		is_val 	= fs_convert_sign(ld_net_tot, 8)
		ls_temp 	= LeftA("Net Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)

		is_val 	= fs_convert_sign(ld_vat_tot, 8)
		ls_temp 	= LeftA("Vat Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)

		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		is_val 	= fs_convert_sign(idec_total, 8)
		ls_temp 	= LeftA("Grand Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		//--------------------------------------------------------
		//결제수단별 입금액
  	 	For i = 1 To 5				//impack 은 별도처리!
				IF i = 1 THEN
					IF ldc_amt0_im <> 0 THEN
						is_val 	= fs_convert_sign(ldc_amt0_im,  8)
						ls_code	= ls_method0_im
						select codenm INTO :ls_codenm from syscod2t
						where grcode = 'B310' 
						  and use_yn = 'Y'
						  AND code = :ls_code ;
						ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
						F_POS_PRINT_VAT(' ' + ls_temp, 1)						
					END IF
				END IF
						
				if ldc_amt0[i] <> 0 then
					is_val 	= fs_convert_sign(ldc_amt0[i],  8)
					ls_code	= ls_method0[i]
					select codenm INTO :ls_codenm from syscod2t
					where grcode = 'B310' 
			 		  and use_yn = 'Y'
					  AND code = :ls_code ;
					ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
					F_POS_PRINT_VAT(' ' + ls_temp, 1)
				END IF
		NEXT
		//거스름돈 처리
		is_val 	= fs_convert_sign(idec_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
//		F_POS_FOOTER(ls_memberid, is_app, gs_user_id)
//		FS_POS_FOOTER2_VAT(ls_payid,is_customerid, is_app, gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
		FS_POS_FOOTER3_VAT(ls_payid,is_customerid, is_appseq, gs_user_id, string(idt_paydt,'yyyymmdd')) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
//	next 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
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
commit ;

Return 
end subroutine

public subroutine uf_prc_db_09 ();//개통신청시 즉시불 화면 전용!
//total 이 - 이면 + 금액부터 정렬 시켜서 처리   (-) - (+) 는 계속  -로 누적되기 때문에
//         + 이면 - 금액부터 정렬 시켜서 처리   (+) - (-) 는 계속  +로 누적되기 때문에...
// ---------------------------------------------------------------------------------------------
// HISTORY
// ADD : 2009-06-13 : 최재혁  impack 카드 금액 분리시키기 위해 새로 적용된 로직!

date		ldt_refunddt,	ldt_shop_closedt			
Integer	i, jj, 			li_first, 			li_pp, 			LI_QTY,		li_rtn, ll_bonus, li_update
Long		ll_qty,			ll_retseq,			ll_cnt
dec{2}	ldc_salerem, 	ldc_saleamt, 		ldc_amt0[],		ldc_impack,	ldc_impack_in
String 	ls_refund_type, 	ls_remark, 		ls_receipt_type, &
			ls_manual_yn,	ls_modelno, 		ls_adlog_yn, 	ls_refundtype
String 	ls_temp, 		ls_method0[], 		ls_trcod[]
String   ls_prt, 			ls_memberid, 		ls_payid, 		ls_basecod, &
			ls_admst_yn, 	ls_code, 			ls_codenm, &
			ls_dctype, 		ls_receipttype, 	ls_admst_status, ls_ref_desc, &
			ls_rtype[], 	ls_adsta_ret,		ls_pgm_id, &
			ls_serialno,	ls_remark2,       ls_sale_type,	ls_end, ls_add,	ls_orderno

// 2019.04.24 VAT 처리를 위한 변수 추가 Modified by Han
//string   ls_customerid
dec{2}   ld_taxrate,    ld_sale_tot, ld_taxamt, ld_vat

//add - 2009.06.13
String	ls_trcod_im,	ls_method0_im
DEC{2}	ldc_amt0_im

//장비 status
ls_admst_Status	= fs_get_control("E1", "A103", ls_ref_desc)
//E1,A103
ls_adsta_ret		= fs_get_control("E1", "A102", ls_ref_desc)

//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])
//정렬 순서 조정. 토탈이 - 일경우 + 금액부터, +금액일 경우 - 금액부터
idec_total   		= idw_data[1].object.total[1]
ldc_impack 			= idw_data[1].object.amt5[1] 	


Choose Case is_caller
	case "save_refund"
			ls_receipt_type  	= 'B'
			ls_dctype 			= 'C'
			ls_receipttype 	= ls_rtype[2]
			idw_data[2].SetSort('refund_price A')
			idw_data[2].Sort()
	CASE 'hotbill'
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'D'
			ls_receipttype 	= ls_rtype[2]
			idw_data[2].SetSort('ss A, cp_amt A')
			idw_data[2].Sort()
	Case ELSE
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'D'
			ls_receipttype 	= ls_rtype[1]
			IF idec_total > 0 THEN
				IF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt A')
				ELSEIF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt A')
				ELSE
					idw_data[2].SetSort('sale_amt A')
				END IF
			ELSE
				IF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt D')
				ELSEIF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt D')
				ELSE
					idw_data[2].SetSort('sale_amt D')
				END IF				
			END IF
			idw_data[2].Sort()
End Choose


ii_rc 		= -1
li_first 	= 0

is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_admst_yn			= is_data[7]
ls_memberid   		= is_data[8]
ls_adlog_yn   		= is_data[9]
ls_pgm_id			= is_data[10]
ldt_shop_closedt 	= f_find_shop_closedt(is_partner)
idt_paydt   		= idw_data[1].object.paydt[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]
IF is_caller = 'direct' THEN
	ls_orderno		= idw_data[1].object.orderno[1]
END IF		
		
ls_trcod[1] 		= idw_data[1].object.trcod3[1]
ls_trcod[2] 		= idw_data[1].object.trcod2[1]
ls_trcod[3] 		= idw_data[1].object.trcod4[1]
ls_trcod[4] 		= idw_data[1].object.trcod1[1]	
ls_trcod[5] 		= idw_data[1].object.trcod6[1]	


ls_method0[1] 		= idw_data[1].object.method3[1]
ls_method0[2] 		= idw_data[1].object.method2[1]
ls_method0[3] 		= idw_data[1].object.method4[1]
ls_method0[4] 		= idw_data[1].object.method1[1]
ls_method0[5] 		= idw_data[1].object.method6[1]

ldc_amt0[1] 		= idw_data[1].object.amt3[1]
ldc_amt0[2] 		= idw_data[1].object.amt2[1]
ldc_amt0[3] 		= idw_data[1].object.amt4[1]
ldc_amt0[4] 		= idw_data[1].object.amt1[1]
ldc_amt0[5] 		= idw_data[1].object.amt6[1]

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= idw_data[1].object.trcod5[1]
	ls_method0_im	= idw_data[1].object.method5[1]	
	ldc_amt0_im		= idw_data[1].object.amt5[1]			
END IF
	
ii_amt_su 			= 0
//----------------------------------------------------------
FOR i = 1 to 5			//impack 은 별도!!!
			IF ldc_amt0[i] <> 0 THEN 
				ii_amt_su 				+= 1 
				idc_amt[ii_amt_su] 	= ldc_amt0[i]
				is_method[ii_amt_su] = ls_method0[i]
			end if
NEXT
//----------------------------------------------------------
//customerm Search
select memberid, 		payid, 		basecod
  INTO :ls_memberid, :ls_payid, :ls_basecod
  FROM customerm
 WHERE customerid = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""
//----------------------------------------------------------
//1.receiptMST Insert
//SEQ 
Select seq_receipt.nextval		  Into :is_appseq						  From dual;
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_receipt)")
	RollBack;
	Return 
End If			
		
IF ls_prt = "Y" then
	//실 영수증 번호임.
	Select seq_app.nextval		  Into :is_app						  From dual;
	If SQLCA.SQLCode < 0 Then
		ii_rc = -1			
		f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_app)")
		RollBack;
		Return 
	End If			
END IF
//----------------------------------------------------------
//SHOP COUNT
Select shopcount	    Into :il_shopcount	  From partnermst
 WHERE partner = :is_partner ;
		 
IF IsNull(il_shopcount) THEN il_shopcount = 0
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update Error(PARTNERMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
il_shopcount += 1
insert into RECEIPTMST
				( approvalno,	shopcount,			receipttype,	shopid,			posno,
				  workdt,		trdt,				   memberid,		operator,		total,
				  cash,			change, 				seq_app, 		customerid,		prt_yn )
			values 
			   ( :is_appseq, 	:il_shopcount,		:ls_receipttype,:is_partner, 	NULL,
				  sysdate,	   :idt_paydt,			:ls_memberid,	:is_operator,	:idec_total,
				  :idec_receive,:idec_change,		:is_app,			:is_customerid,:ls_prt )	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Insert Error(RECEIPTMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
Update partnermst
			Set shopcount 	= :il_shopcount
			Where partner  = :is_partner ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update  Error(PARTNERMST)")
	RollBack;
	Return 
End If	
//----------------------------------------------------------
// ADMST Update & dailypament에 Insert
il_row 		= idw_data[2].RowCount()
ii_method	= 1

IF is_caller = "save_refund" THEN
	ls_remark =  trim(idw_data[1].Object.remark[1])
	ls_remark2 = ''
	ldt_refunddt =  idw_data[1].Object.paydt[1]
ELSEIF is_caller = "direct" THEN
	ls_remark =  trim(idw_data[1].Object.remark[1])
END IF
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ls_add = 'N'
ls_end = 'N'

For i = 1 To il_row
	is_contno 		= trim(idw_data[2].object.contno[i])
	ls_modelno 		= trim(idw_data[2].object.modelno[i])
	ll_qty 			= idw_data[2].object.qty[i]
	IF is_caller = "save_refund" then
		ls_refund_type = trim(idw_data[2].object.refund_type[i])
	ELSE
		ls_refund_type =''
	END IF
	IF IsNull(ls_refund_type) then ls_refund_type = ''
		
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refundtype	= idw_data[2].object.REFUND_TYPE[i]
				if iSnULL(ls_refundtype) then ls_refundtype = ""
		Case else
				idec_saleamt 	= idw_data[2].object.sale_amt[i]								

				// 2019.04.24 Vat 포함한 금액 및  Vat  추가 Modified By Han
				ld_sale_tot    = idw_data[2].Object.sale_amt[i] + idw_data[2].Object.vat_amt[i]
				ld_vat         = idw_data[2].Object.vat_amt [i]

				IF ldc_impack <> 0 THEN
					idec_imnot 		= idw_data[2].object.impack_not[i]
					idec_im			= idw_data[2].object.impack_card[i]
				END IF
	End Choose
	li_first 		= 0
	li_update		= 0	
			
	//장비마스터 Update 여부 확인....
	if ls_admst_yn = "Y" THEN
		IF is_contno <> "" THEN
			choose case is_caller
				CASE "save_refund" //반품 처리
				   IF ls_refund_type <> '' THEN
						ls_modelno 		= trim(idw_data[2].Object.modelno[i])
						ls_refund_type	= trim(idw_data[2].Object.refund_type[i])
						idec_saleamt 	= idw_data[2].object.refund_price[i]
						Select seq_adreturn.nextval		  Into :ll_retseq	  From dual;
						If SQLCA.SQLCode < 0 Then
								ii_rc = -1			
								f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_adreturn)")
								RollBack;
								Return 
						End If			
						//1.adreturn insert		장비반품정보
						Insert Into adreturn 
										( retseq, 				returndt, 		partner, 		contno, 		modelno, 
										  refund_type, 		refund_amt,	  	note, 			crtdt, 		crt_user, 	pgm_id)
								Values( :ll_retseq, 			:ldt_refunddt, :is_partner,	:is_contno, :ls_modelno, 
										  :ls_refund_type, 	:idec_saleamt, :ls_remark,  	sysdate, 	:gs_user_id, :is_data[5]);
						If SQLCA.SQLCode < 0 Then
							ii_rc = -1
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADRETURN)")
							Rollback ;
							Return 
						End If		
					
					
					//a. ADMST Update
						Update ADMST
							Set retdt 		= :idt_paydt,
  					  	  		Status 		= :ls_adsta_ret,
								mv_partner  = :is_partner,
  					   	 	sale_flag	= '0',
  					   	 	retseqno	   = :ll_retseq,
								updt_user 	= :gs_user_id,
						 		updtdt 		= sysdate,
						 		pgm_id 		= :is_pgm_id					 
							Where contno 	= :is_contno ;
					END IF
				CASE ELSE
					ls_sale_type     		= trim(idw_data[2].Object.sale_type[i])
					IF ls_sale_type = 'Y' THEN // 장비 판매인 경우, 판매와 충전이 동시에 올경우 판매에서만 Update 2007-08-06 hcjung
					    //a. ADMST Update
						 UPDATE ADMST
							 SET saledt 	 = :idt_paydt,
  							     customerid = :is_customerid,
  							     sale_amt   = :idec_saleamt,
  					  	  		  status     = :ls_admst_status,
  					   	 	  sale_flag	 = '1',
								  updt_user  = :gs_user_id,
						 		  updtdt 	 = sysdate,
						 		  pgm_id 	 = :is_pgm_id					 
						  WHERE contno 	 = :is_contno;
					END IF
				END CHOOSE
				
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
				End If
			END IF
			IF ls_adlog_yn = "Y" AND ls_modelno <> "" THEN
				//--------------AD_SALELOG 처리
				//ad_salelog insert	
				Insert Into ad_salelog	(saleseq, 	
								saledt, 					SHOPID,				saleqty,			sale_amt,		
								sale_sum,				paymethod,			modelno,			contno,		
								note,						crt_user,			crtdt, 			pgm_id)
				Values(		seq_ad_salelog.nextval,
								:idt_paydt,	:is_partner,		:ll_qty, 		:idec_saleamt , 
								:idec_saleamt, 		null,					:ls_modelno,	:is_contno,
								null,						:gs_user_id,		sysdate,			:is_data[5]		);
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(AD_SALELOG)")
					RollBack;
					Return 
				End If
			END IF
	END IF
		
	//===================================================
	//b. dailypayment Insert
	// regcod search
	//====================================================
	is_itemcod 		= trim(idw_data[2].object.itemcod[i])
	ll_qty 			= idw_data[2].object.qty[i]
	is_regcod 		= trim(idw_data[2].object.regcod[i])
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
				
				ls_manual_yn 	= 'N'
				ls_remark 		= is_contno
				ls_remark2		= idw_data[2].object.remark[i]
		Case "direct" 
				ls_remark 		= ""
				ls_remark2		= idw_data[1].object.remark[1]
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= 'N'
		Case "save_sales" 
				ls_remark 		= idw_data[2].object.remark[i]
				ls_remark2 		= idw_data[2].object.remark2[i]
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= idw_data[2].object.manual_yn[i]
		case else
				ls_remark 		= ''
				ls_remark2		= ""
				idec_saleamt 	= 0
				ls_refund_type = ''
				ls_manual_yn 	= ''
	End Choose
	
	IF ( is_caller = 'save_refund' AND ls_refund_type <> '' ) OR  is_caller <> 'save_refund' THEN
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		IF ii_amt_su > 0 THEN
			IF ldc_impack > 0 THEN											//IMPACK 카드로 수납 + 경우
				IF idec_im <> 0 THEN
					IF li_first 	= 0 then									//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty									//ITEM 수량 입력
						li_first 	= 1										//첫번째 로우 아니라는 표시
					else 
						il_paycnt 	= 0										//첫번째 로우 아니면 수량 0 세팅!
					END IF					
					
					IF ldc_impack - idec_im < 0 THEN						//받은 IMPACK 카드보다 ITEM 할인율이 더 높으면 종료
						idec_saleamt = idec_saleamt - ldc_impack		//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = ldc_impack
						ldc_impack = 0											//IMPACK 카드 처리를 종료시킨다.										
					ELSE
						ldc_impack = ldc_impack - idec_im				//IMPACK 카드수납금에서 아이템 IMPACK 금액을 깐다.
						idec_saleamt = idec_imnot							//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = idec_im									
					END IF
					
					li_update = 1					
					
				END IF
			ELSEIF ldc_impack < 0 THEN										//IMPACK 카드로 수납을 했을 경우!
				IF idec_im <> 0 THEN
					IF li_first 	= 0 then									//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty									//ITEM 수량 입력
						li_first 	= 1										//첫번째 로우 아니라는 표시
					else 
						il_paycnt 	= 0										//첫번째 로우 아니면 수량 0 세팅!
					END IF
					
					IF ldc_impack - idec_im > 0 THEN						//받은 IMPACK 카드보다 ITEM 할인율이 더 높으면 종료
						idec_saleamt = idec_saleamt - ldc_impack		//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = ldc_impack
						ldc_impack = 0											//IMPACK 카드 처리를 종료시킨다.										
					ELSE
						ldc_impack = ldc_impack - idec_im				//IMPACK 카드수납금에서 아이템 IMPACK 금액을 깐다.
						idec_saleamt = idec_imnot							//IMPACK 카드 금액을 제외하기 위하여
						ldc_impack_in = idec_im									
					END IF
					
					li_update = 1
					
				END IF				
			END IF	
			
			IF li_update = 1 THEN
				INSERT INTO dailypayment
						( payseq,							paydt,			
						  shopid,		operator,		customerid,
						  itemcod,		paymethod,		regcod,			payamt,			basecod,
						  paycnt,		payid,			remark,			trdt,				mark,
						  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
						  manual_yn,	pgm_ID,			remark2,			orderno)
				VALUES
						( seq_dailypayment.nextval, 	 :idt_paydt, 	
						  :is_partner, :is_operator, 	 :is_customerid,
						  :is_itemcod,	:ls_method0_im, :is_regcod,		:ldc_impack_in,	:ls_basecod,
						  :il_paycnt,	:ls_payid,		 :ls_remark,		sysdate,				null,
						  NULL,			:ls_dctype,		 :is_appseq,		sysdate,				sysdate,		:gs_user_id,
						  :ls_manual_yn, :ls_pgm_id,	 :ls_remark2,		:ls_orderno )	 ;	
				//저장 실패 
				IF SQLCA.SQLCode < 0 THEN
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_impact)")
					ROLLBACK;
					RETURN
				END IF
			END IF

// 2019.04.24 Item별 taxrate를 가져온다 Modified by Han

			SELECT FNC_GET_TAXRATE(:is_customerid, 'I', :is_itemcod, :idt_paydt)
			  INTO :ld_taxrate
			  FROM DUAL;

			IF ld_taxrate <> 0 then
				//합계액으로 공급가액과 부가세를 나눠주는 공식임.
				ld_taxrate = 1 + ( ld_taxrate / 100)
			ELSE
				// 0으로 나눠주면 에러남
				ld_taxrate = 1
			END IF

			IF ls_end = 'N' THEN											//수납이 끝나지 않았을 경우!
				//FOR li_pp Start											//임팩 카드를 제외한 수납 처리!
				FOR li_pp =  ii_method to ii_amt_su					//수납유형 수만큼 루프.
					is_paymethod 	= is_method[li_pp]				//수납유형 있는것만...
					idc_rem 			= idc_amt[li_pp]					//수납유형에 있는 금액...
					
					IF li_first 	= 0 then								//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty								//ITEM 수량 입력
						li_first 	= 1									//첫번째 로우 아니라는 표시
					ELSE 														//첫번째 로우 아니면 수량 0 세팅!
						il_paycnt 	= 0
					END IF								
					
					IF idc_rem > 0 THEN									//수납유형에 + 금액이면
						IF idc_rem - ld_sale_tot <= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
//							ldc_saleamt	 = idc_rem						//품목금액을 넣는다.
//							idec_saleamt = idec_saleamt - idc_rem	//loop 를 돌리기 위해서
// 2019.04.24 Vat 처리 추가
							ldc_saleamt	 = round(idc_rem / ld_taxrate, 2) // 품목공급금액을 넣는다.
							ld_taxamt    = idc_rem - ldc_saleamt          // 부가세
							ld_sale_tot  = ld_sale_tot - idc_rem	       // loop 를 돌리기 위해서

							IF ii_method = ii_amt_su THEN				//나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								//나누기 처리 끝...
								IF idec_saleamt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
									ls_add = 'Y'
								END IF
							END IF
							
							idc_rem		 = 0								//수납금액을 0으로
							ii_method	+= 1

						ELSE													//수납유형에 돈이 남아있으면...다음 아이템으로						
//							idc_rem		 = idc_rem - idec_saleamt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = idec_saleamt				//품목금액을 넣는다.
//							idec_saleamt = 0								//loop 를 빼기 위해서!		
// 2019.04.24 Vat 처리 추가
							idc_rem		 = idc_rem - ld_sale_tot	            // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
							ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
							ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
							ld_sale_tot  = 0				                        // loop 를 빼기 위해서!		
						END IF
					ELSEIF idc_rem < 0 THEN								//수납유형에 - 금액이면
//						IF idc_rem - idec_saleamt >= 0 THEN			//수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
						IF idc_rem - ld_sale_tot >= 0 THEN		// 2019.04.24 Modified by Han
//							ldc_saleamt	 = idc_rem						//품목금액을 넣는다.
//							idec_saleamt = idec_saleamt - idc_rem	//loop 를 돌리기 위해서
// 2019.04.24 Vat 처리 추가
							ldc_saleamt	 = round(idc_rem / ld_taxrate, 2) // 품목금액을 넣는다.
							ld_taxamt    = idc_rem - ldc_saleamt           // 부가세
							ld_sale_tot  = ld_sale_tot - idc_rem          // loop 를 돌리기 위해서
							IF ii_method = ii_amt_su THEN				//나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								//나누기 처리 끝...
//								IF idec_saleamt <> 0 THEN				//아이템 금액이 남아 있다면 추가 작업!-CASH
								IF ld_sale_tot <> 0 THEN				// 2019.04.24 Modified by Han
									ls_add = 'Y'
								END IF
							END IF
							idc_rem		 = 0								//수납유형에 있는 금액에서 아이템 금액을 빼준다.													
							ii_method	+= 1												
						ELSE
//							idc_rem		 = idc_rem - idec_saleamt	//수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = idec_saleamt				//품목금액을 넣는다.
//							idec_saleamt = 0								//loop 를 빼기 위해서!	
// 2019.04.24 Vat 처리 추가
							idc_rem		 = idc_rem - ld_sale_tot               // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
							ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
							ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
							ld_sale_tot  = 0                                   // loop 를 빼기 위해서!	

						END IF						
					ELSE														//아이템은 있는데 수납이 다 까졌을 때...
//						ldc_saleamt  = idec_saleamt					//품목금액을 넣는다.
//						idec_saleamt = 0									//loop 를 빼기 위해서!
// 2019.04.24 Vat 처리 추가
						ldc_saleamt  = ld_sale_tot - ld_vat              // 품목금액을 넣는다.
						ld_taxamt    = ld_vat                            //부가세
						ld_sale_tot  = 0									       //loop 를 빼기 위해서!
						is_paymethod = '101'								//cash
					END IF
	
					insert into dailypayment
							( payseq,							paydt,			
							  shopid,		operator,		customerid,
							  itemcod,		paymethod,		regcod,			payamt,			basecod,
							  paycnt,		payid,			remark,			trdt,				mark,
							  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
							  manual_yn,	pgm_ID,			remark2,			orderno,       taxamt)
					values 
							( seq_dailypayment.nextval, 	:idt_paydt, 	
							  :is_partner, :is_operator, 	:is_customerid,
							  :is_itemcod,	:is_paymethod,	:is_regcod,		:ldc_saleamt,	:ls_basecod,
							  :il_paycnt,	:ls_payid,		:ls_remark,		sysdate,			null,
							  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
							  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ls_orderno,   :ld_taxamt )	 ;
							
					//저장 실패 
					If SQLCA.SQLCode < 0 Then
						ii_rc = -1			
						f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_paymethod)")
						RollBack;
						Return 
					End If
					
					IF ls_add = 'Y' THEN
//						is_paymethod = '101'
//						
//						insert into dailypayment
//								( payseq,							paydt,			
//								  shopid,		operator,		customerid,
//								  itemcod,		paymethod,		regcod,			payamt,			basecod,
//								  paycnt,		payid,			remark,			trdt,				mark,
//								  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
//								  manual_yn,	pgm_ID,			remark2)
//						values 
//								( seq_dailypayment.nextval, 	:idt_paydt, 	
//								  :is_partner, :is_operator, 	:is_customerid,
//								  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
//								  0,				:ls_payid,		:ls_remark,		sysdate,			null,
//								  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
//								  :ls_manual_yn, :ls_pgm_id,	:ls_remark2 )	 ;
//								
//						//저장 실패 
//						If SQLCA.SQLCode < 0 Then
//							ii_rc = -1			
//							f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_add)")
//							RollBack;
//							Return 
//						End If
					END IF				
			
					idc_amt[li_pp]	= idc_rem					
					IF idec_saleamt = 0 then exit
				NEXT
			ELSE				//수납이 끝났지만 ITEM 이 남아 있을 경우!
				is_paymethod = '101'    // B310, cash
			
				insert into dailypayment
						( payseq,							paydt,			
						  shopid,		operator,		customerid,
						  itemcod,		paymethod,		regcod,			payamt,			basecod,
						  paycnt,		payid,			remark,			trdt,				mark,
						  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
						  manual_yn,	pgm_ID,			remark2,			orderno)
				values 
						( seq_dailypayment.nextval, 	:idt_paydt, 	
						  :is_partner, :is_operator, 	:is_customerid,
						  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
						  :ll_qty,		:ls_payid,		:ls_remark,		sysdate,			null,
						  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
						  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ls_orderno )	 ;
						
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
					RollBack;
					Return 
				End If				
			END IF				
		ELSE		//수납유형이 한개도 없을 경우!
			is_paymethod = '101'    // B310, cash
		
			insert into dailypayment
					( payseq,							paydt,			
					  shopid,		operator,		customerid,
					  itemcod,		paymethod,		regcod,			payamt,			basecod,
					  paycnt,		payid,			remark,			trdt,				mark,
					  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
					  manual_yn,	pgm_ID,			remark2,			orderno)
			values 
					( seq_dailypayment.nextval, 	:idt_paydt, 	
					  :is_partner, :is_operator, 	:is_customerid,
					  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
					  :ll_qty,		:ls_payid,		:ls_remark,		sysdate,			null,
					  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
					  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ls_orderno )	 ;
					
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
				RollBack;
				Return 
			End If
		END IF
		
		//FOR li_pp END
	END IF

NEXT

////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// ssrtppcif Insert
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Choose Case is_caller
    Case "save_sales" 			
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	          WHERE grcode = 'DacomPPC02' 
				   AND use_yn = 'Y'
	            AND CODE  = :is_itemcod;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.sale_amt[i]
		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;

		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (seq_ssrtppcif.nextval,'SALES','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If		
	         ELSE 
		      // Check 2
	             SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	              WHERE grcode = 'DacomPPC01' 
					    AND use_yn = 'Y'
	                AND CODE  = :is_itemcod ;
		
                IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
                IF ll_cnt > 0  AND is_caller = "save_sales" then
                    idec_saleamt 	= idw_data[2].object.sale_amt[i]
		              is_contno 		= trim(idw_data[2].object.contno[i])
				
                    select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
					 
                    SELECT count(*) INTO :ll_bonus FROM syscod2t
					      WHERE grcode = 'DacomPPC03'
							  AND use_yn = 'Y'
					        AND code = :is_itemcod; 

						  IF sqlca.sqlcode <> 0 OR IsNull(ll_bonus) THEN ll_bonus  = 0
                    
						  IF ll_bonus > 0  THEN
                        INSERT INTO ssrtppcif
								(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
							   VALUES
                        (seq_ssrtppcif.nextval,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.1)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
						  ELSE
                        INSERT INTO ssrtppcif 
								(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
								VALUES 
								(seq_ssrtppcif.nextval,'Recharge','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
						  END IF
								
                    If SQLCA.SQLCode < 0 Then
                        ii_rc = -1			
                        f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
                        RollBack ;
                        Return 
                    END IF
                End If	
            END IF
        NEXT
    Case "save_refund"
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         select Count(*) INTO :ll_cnt FROM syscod2t 
	          where grcode = 'DacomPPC02' 
	            AND CODE  = :is_itemcod ;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.refund_price[i]
//		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (seq_ssrtppcif.nextval,'REFUND','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0',:ls_pgm_id);

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If
				End IF
        NEXT		
End Choose
	

// ssrtppcif Insert ============>> END.....

//-------------------------------------------------------
//마지막으로 영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[2].SetSort('itemcod A')
idw_data[2].Sort()


String ls_lin1, ls_lin2, ls_lin3, ls_empnm
DEC	 ldc_shopCount

// 2019.04.24 VAT 출력을 위한 변수 추가 Modified by Han
string ls_surtaxyn
DEC{2} ld_vat_tot, ld_net_tot

// 2019.04.24 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by Han

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
	//1. head 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//	FOR jj = 1  to 2
//		IF jj = 1 then 
			li_rtn = f_pos_header_vat(is_partner, ls_receipt_type, il_shopcount, 1 )
//		ELSE 
//			li_rtn = f_pos_header(is_partner, 'Z', il_shopcount, 0 )
//		END IF
		IF li_rtn < 0 then
			MessageBox('확인', '영수증 프린터 연결상태를 확인해주세요.')
//			PRN_ClosePort()
			FileClose(li_handle)
			ii_rc = -9		
//			return 
		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		il_row = idw_data[2].RowCount()
		For i = 1 To il_row
			is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			IF is_caller = "save_refund" then
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
			ELSE
				ls_refund_type = 'A'
			END IF
			
	      IF ls_refund_type <> '' THEN
			    ls_temp 		= String(i, '000') + ' ' //순번
			    is_itemcod 	= trim(idw_data[2].Object.itemcod[i])
			    is_itemNM 		= trim(idw_data[2].Object.itemNM[i])
			    li_qty 			= idw_data[2].Object.qty[i]
			    
				 IF IsNull(li_qty) OR li_qty  = 0 THEN li_qty = 1
			    
				 Choose Case is_caller
				     case "save_refund"
					       idec_saleamt 	= idw_data[2].object.refund_price[i]
				     Case "direct", "save_sales"  
					       idec_saleamt 	= idw_data[2].object.sale_amt[i] + idw_data[2].Object.vat_amt[i]
							 ld_net_tot   += idw_data[2].object.sale_amt[i]
							 ld_vat_tot   += idw_data[2].Object.vat_amt [i]
							 ls_surtaxyn   = idw_data[2].Object.surtaxyn[i]

			    End Choose

			    IF IsNull(is_itemNM) then is_itemNM 	= ''
	
	          ls_temp 	+= LeftA(is_itemnm + space(25), 24)  //아이템
			    ls_temp 	+= Space(1) + RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
			    is_val 	= fs_convert_amt(idec_saleamt,  8)
			    ls_temp 	+= is_val //금액
			    F_POS_PRINT_VAT(' ' + ls_temp, 1)	
	
			    is_regcod =  trim(idw_data[2].Object.regcod[i])
			    //regcode master read
			    select keynum, 		trim(facnum)
		  	      INTO :il_keynum,	:is_facnum
		  	      FROM regcodmst
		 	     where regcod = :is_regcod ;
					
				 // Index Desciption 2008-05-06 hcjung
			    SELECT indexdesc
		  	      INTO :is_facnum
		  	      FROM SHOP_REGIDX
		 	     WHERE regcod = :is_regcod
					 AND shopid = :is_partner;
	
			    IF IsNull(il_keynum) or sqlca.sqlcode < 0	then il_keynum 	= 0
			    IF IsNull(is_facnum) or sqlca.sqlcode < 0	then is_facnum 	= ""
	 			 //2010.08.20 jhchoi 수정.
				 //ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
			    ls_temp =  Space(4) + "(KEY#" + String(il_keynum) + " " + is_facnum + ")"	+  ' ' + ls_surtaxyn			 
			    F_POS_PRINT_VAT(' ' + ls_temp, 1)
         END IF
		NEXT
		//2. Item List 출력 ----- end

		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		is_val 	= fs_convert_sign(ld_net_tot, 8)
		ls_temp 	= LeftA("Net Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)

		is_val 	= fs_convert_sign(ld_vat_tot, 8)
		ls_temp 	= LeftA("Vat Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)

		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		is_val 	= fs_convert_sign(idec_total, 8)
		ls_temp 	= LeftA("Grand Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		//--------------------------------------------------------
		//결제수단별 입금액
  	 	For i = 1 To 5				//impack 은 별도처리!
				IF i = 1 THEN
					IF ldc_amt0_im <> 0 THEN
						is_val 	= fs_convert_sign(ldc_amt0_im,  8)
						ls_code	= ls_method0_im
						select codenm INTO :ls_codenm from syscod2t
						where grcode = 'B310' 
						  and use_yn = 'Y'
						  AND code = :ls_code ;
						ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
						F_POS_PRINT_VAT(' ' + ls_temp, 1)						
					END IF
				END IF
						
				if ldc_amt0[i] <> 0 then
					is_val 	= fs_convert_sign(ldc_amt0[i],  8)
					ls_code	= ls_method0[i]
					select codenm INTO :ls_codenm from syscod2t
					where grcode = 'B310' 
			 		  and use_yn = 'Y'
					  AND code = :ls_code ;
					ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
					F_POS_PRINT_VAT(' ' + ls_temp, 1)
				END IF
		NEXT
		//거스름돈 처리
		is_val 	= fs_convert_sign(idec_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
//		F_POS_FOOTER(ls_memberid, is_app, gs_user_id)
//		FS_POS_FOOTER2(ls_payid,is_customerid, is_app, gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
		FS_POS_FOOTER3_VAT(ls_payid,is_customerid, is_appseq, gs_user_id, string(idt_paydt,'yyyymmdd')) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
//	next 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
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
commit ;

Return 
end subroutine

public subroutine uf_prc_db_07 ();// ---------------------------------------------------------------------------------------------
// HISTORY
// ADD : 2006-12-06 : 정희찬 : dailypayment.remark2 컬럼 추가 ( 용도: SingleItem Sales 시 비고 입력된 부분 )

date		ldt_refunddt,	ldt_shop_closedt			
Integer	i, jj, 			li_first, 			li_pp, 			LI_QTY,		li_rtn, ll_bonus
Long		ll_qty,			ll_retseq,			ll_cnt
dec{2}	ldc_salerem, 	ldc_saleamt, 		ldc_amt0[],		ldc_impack
String 	ls_refund_type, 	ls_remark, 		ls_receipt_type, &
			ls_manual_yn,	ls_modelno, 		ls_adlog_yn, 	ls_refundtype
String 	ls_temp, 		ls_method0[], 		ls_trcod[]
String   ls_prt, 			ls_memberid, 		ls_payid, 		ls_basecod, &
			ls_admst_yn, 	ls_code, 			ls_codenm, &
			ls_dctype, 		ls_receipttype, 	ls_admst_status, ls_ref_desc, &
			ls_rtype[], 	ls_adsta_ret,		ls_pgm_id, &
			ls_serialno,	ls_remark2,       ls_sale_type

//장비 status
ls_admst_Status	= fs_get_control("E1", "A103", ls_ref_desc)
//E1,A103
ls_adsta_ret		= fs_get_control("E1", "A102", ls_ref_desc)

//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])


Choose Case is_caller
		case "save_refund"
				ls_receipt_type  	= 'B'
				ls_dctype 			= 'C'
				ls_receipttype 	= ls_rtype[2]
				idw_data[2].SetSort('refund_price A')
				idw_data[2].Sort()
		CASE 'hotbill'
				ls_receipt_type  	= 'A'
				ls_dctype 			= 'D'
				ls_receipttype 	= ls_rtype[2]
				idw_data[2].SetSort('ss A, cp_amt A')
				idw_data[2].Sort()
		Case ELSE
				ls_receipt_type  	= 'A'
				ls_dctype 			= 'D'
				ls_receipttype 	= ls_rtype[1]
//				idw_data[2].SetSort('sale_amt A')
				idw_data[2].SetSort('priority A')
				idw_data[2].Sort()
End Choose

ii_rc 		= -1
li_first 	= 0

is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_admst_yn			= is_data[7]
ls_memberid   		= is_data[8]
ls_adlog_yn   		= is_data[9]
ls_pgm_id			= is_data[10]

ldt_shop_closedt 	= f_find_shop_closedt(is_partner)
ldc_impack 			= idw_data[1].object.amt5[1] 
	
idt_paydt   		= idw_data[1].object.paydt[1]
//idt_paydt			= dateTime( date(idw_data[1].object.paydt[1]), time('00:00:00') )
idec_total   		= idw_data[1].object.total[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]
		
IF ldc_impack = 0 THEN 		
	ls_trcod[1] 		= idw_data[1].object.trcod3[1]
	ls_trcod[2] 		= idw_data[1].object.trcod2[1]
	ls_trcod[3] 		= idw_data[1].object.trcod5[1]
	ls_trcod[4] 		= idw_data[1].object.trcod4[1]
	ls_trcod[5] 		= idw_data[1].object.trcod1[1]	
	
	ls_method0[1] 		= idw_data[1].object.method3[1]
	ls_method0[2] 		= idw_data[1].object.method2[1]
	ls_method0[3] 		= idw_data[1].object.method5[1]
	ls_method0[4] 		= idw_data[1].object.method4[1]
	ls_method0[5] 		= idw_data[1].object.method1[1]

	ldc_amt0[1] 		= idw_data[1].object.amt3[1]
	ldc_amt0[2] 		= idw_data[1].object.amt2[1]
	ldc_amt0[3] 		= idw_data[1].object.amt5[1]
	ldc_amt0[4] 		= idw_data[1].object.amt4[1]
	ldc_amt0[5] 		= idw_data[1].object.amt1[1]
ELSE	
	ls_trcod[1] 		= idw_data[1].object.trcod5[1]
	ls_trcod[2] 		= idw_data[1].object.trcod3[1]
	ls_trcod[3] 		= idw_data[1].object.trcod2[1]
	ls_trcod[4] 		= idw_data[1].object.trcod4[1]
	ls_trcod[5] 		= idw_data[1].object.trcod1[1]
	
	ls_method0[1] 		= idw_data[1].object.method5[1]
	ls_method0[2] 		= idw_data[1].object.method3[1]
	ls_method0[3] 		= idw_data[1].object.method2[1]
	ls_method0[4] 		= idw_data[1].object.method4[1]
	ls_method0[5] 		= idw_data[1].object.method1[1]
	
	ldc_amt0[1] 		= idw_data[1].object.amt5[1]		
	ldc_amt0[2] 		= idw_data[1].object.amt3[1]
	ldc_amt0[3] 		= idw_data[1].object.amt2[1]
	ldc_amt0[4] 		= idw_data[1].object.amt4[1]
	ldc_amt0[5] 		= idw_data[1].object.amt1[1]	
END IF
	
ii_amt_su 			= 0
//----------------------------------------------------------
FOR i = 1 to 5
			IF ldc_amt0[i] <> 0 THEN 
				ii_amt_su 				+= 1 
				idc_amt[ii_amt_su] 	= ldc_amt0[i]
				is_method[ii_amt_su] = ls_method0[i]
			end if
NEXT
//----------------------------------------------------------
//customerm Search
select memberid, 		payid, 		basecod
  INTO :ls_memberid, :ls_payid, :ls_basecod
  FROM customerm
 WHERE customerid = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""
//----------------------------------------------------------
//1.receiptMST Insert
//SEQ 
Select seq_receipt.nextval		  Into :is_appseq						  From dual;
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_receipt)")
	RollBack;
	Return 
End If			
		
IF ls_prt = "Y" then
	//실 영수증 번호임.
	Select seq_app.nextval		  Into :is_app						  From dual;
	If SQLCA.SQLCode < 0 Then
		ii_rc = -1			
		f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_app)")
		RollBack;
		Return 
	End If			
END IF
//----------------------------------------------------------
//SHOP COUNT
Select shopcount	    Into :il_shopcount	  From partnermst
 WHERE partner = :is_partner ;
		 
IF IsNull(il_shopcount) THEN il_shopcount = 0
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update Error(PARTNERMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
il_shopcount += 1
insert into RECEIPTMST
				( approvalno,	shopcount,			receipttype,	shopid,			posno,
				  workdt,		trdt,				   memberid,		operator,		total,
				  cash,			change, 				seq_app, 		customerid,		prt_yn )
			values 
			   ( :is_appseq, 	:il_shopcount,		:ls_receipttype,:is_partner, 	NULL,
				  sysdate,	   :idt_paydt,			:ls_memberid,	:is_operator,	:idec_total,
				  :idec_receive,:idec_change,		:is_app,			:is_customerid,:ls_prt )	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Insert Error(RECEIPTMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
Update partnermst
			Set shopcount 	= :il_shopcount
			Where partner  = :is_partner ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update  Error(PARTNERMST)")
	RollBack;
	Return 
End If	
//----------------------------------------------------------
// ADMST Update & dailypament에 Insert
il_row 		= idw_data[2].RowCount()
ii_method	= 1

IF is_caller = "save_refund" then
	ls_remark =  trim(idw_data[1].Object.remark[1])
	ls_remark2 = ''
	ldt_refunddt =  idw_data[1].Object.paydt[1]
END IF
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
For i = 1 To il_row
	is_contno 		= trim(idw_data[2].object.contno[i])
	ls_modelno 		= trim(idw_data[2].object.modelno[i])
	ll_qty 			= idw_data[2].object.qty[i]
	IF is_caller = "save_refund" then
		ls_refund_type = trim(idw_data[2].object.refund_type[i])
	ELSE
		ls_refund_type =''
	END IF
	IF IsNull(ls_refund_type) then ls_refund_type = ''
		
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refundtype	= idw_data[2].object.REFUND_TYPE[i]
				if iSnULL(ls_refundtype) then ls_refundtype = ""
		Case else
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
	End Choose
	li_first 		= 0
			
	//장비마스터 Update 여부 확인....
	if ls_admst_yn = "Y" THEN
		IF is_contno <> "" THEN
			choose case is_caller
				CASE "save_refund" //반품 처리
				   IF ls_refund_type <> '' THEN
						ls_modelno 		= trim(idw_data[2].Object.modelno[i])
						ls_refund_type	= trim(idw_data[2].Object.refund_type[i])
						idec_saleamt 	= idw_data[2].object.refund_price[i]
						Select seq_adreturn.nextval		  Into :ll_retseq	  From dual;
						If SQLCA.SQLCode < 0 Then
								ii_rc = -1			
								f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_adreturn)")
								RollBack;
								Return 
						End If			
						//1.adreturn insert		장비반품정보
						Insert Into adreturn 
										( retseq, 				returndt, 		partner, 		contno, 		modelno, 
										  refund_type, 		refund_amt,	  	note, 			crtdt, 		crt_user, 	pgm_id)
								Values( :ll_retseq, 			:ldt_refunddt, :is_partner,	:is_contno, :ls_modelno, 
										  :ls_refund_type, 	:idec_saleamt, :ls_remark,  	sysdate, 	:gs_user_id, :is_data[5]);
						If SQLCA.SQLCode < 0 Then
							ii_rc = -1
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADRETURN)")
							Rollback ;
							Return 
						End If		
					
					
					//a. ADMST Update
						Update ADMST
							Set retdt 		= :idt_paydt,
  					  	  		Status 		= :ls_adsta_ret,
								mv_partner  = :is_partner,
  					   	 	sale_flag	= '0',
  					   	 	retseqno	   = :ll_retseq,
								updt_user 	= :gs_user_id,
						 		updtdt 		= sysdate,
						 		pgm_id 		= :is_pgm_id					 
							Where contno 	= :is_contno ;
					END IF
				CASE ELSE
					ls_sale_type     		= trim(idw_data[2].Object.sale_type[i])
					IF ls_sale_type = 'Y' THEN // 장비 판매인 경우, 판매와 충전이 동시에 올경우 판매에서만 Update 2007-08-06 hcjung
					    //a. ADMST Update
						 UPDATE ADMST
							 SET saledt 	 = :idt_paydt,
  							     customerid = :is_customerid,
  							     sale_amt   = :idec_saleamt,
  					  	  		  status     = :ls_admst_status,
  					   	 	  sale_flag	 = '1',
								  updt_user  = :gs_user_id,
						 		  updtdt 	 = sysdate,
						 		  pgm_id 	 = :is_pgm_id					 
						  WHERE contno 	 = :is_contno;
					END IF
				END CHOOSE
				
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
				End If
			END IF
			IF ls_adlog_yn = "Y" AND ls_modelno <> "" THEN
				//--------------AD_SALELOG 처리
				//ad_salelog insert	
				Insert Into ad_salelog	(saleseq, 	
								saledt, 					SHOPID,				saleqty,			sale_amt,		
								sale_sum,				paymethod,			modelno,			contno,		
								note,						crt_user,			crtdt, 			pgm_id)
				Values(		seq_ad_salelog.nextval,
								:idt_paydt,	:is_partner,		:ll_qty, 		:idec_saleamt , 
								:idec_saleamt, 		null,					:ls_modelno,	:is_contno,
								null,						:gs_user_id,		sysdate,			:is_data[5]		);
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Insert Error(AD_SALELOG)")
					RollBack;
					Return 
				End If
			END IF
	END IF
		
	//===================================================
	//b. dailypayment Insert
	// regcod search
	//====================================================
	is_itemcod 		= trim(idw_data[2].object.itemcod[i])
	ll_qty 			= idw_data[2].object.qty[i]
	is_regcod 		= trim(idw_data[2].object.regcod[i])
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
				
				ls_manual_yn 	= 'N'
//				ls_remark 		= idw_data[2].object.remark[i]
				ls_remark 		= is_contno
				ls_remark2		= idw_data[2].object.remark[i]
		Case "direct" 
				ls_remark 		= ''
				ls_remark2		= ""
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= 'N'
		Case "save_sales" 
				ls_remark 		= idw_data[2].object.remark[i]
				ls_remark2 		= idw_data[2].object.remark2[i]
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= idw_data[2].object.manual_yn[i]
		case else
				ls_remark 		= ''
				ls_remark2		= ""
				idec_saleamt 	= 0
				ls_refund_type = ''
				ls_manual_yn 	= ''
	End Choose
IF ( is_caller = 'save_refund' AND ls_refund_type <> '' ) OR  is_caller <> 'save_refund' THEN
	//-------------------------------------------------------------------------
	//입금내역 처리  Start........ 
	//-------------------------------------------------------------------------
	IF ii_amt_su > 0 THEN
		//FOR li_pp Start
		FOR li_pp =  ii_method to ii_amt_su
			is_paymethod 	= is_method[li_pp]				//수납유형 있는것만...
			idc_rem 			= idc_amt[li_pp]					//수납유형에 있는 금액...
			IF idec_receive < 0 THEN							//수납 받은 총 금액...
					idc_rem 			= idc_rem - idec_saleamt			//itemcod
					ldc_saleamt 	= idec_saleamt
					idec_saleamt 	= 0
					IF idc_rem = 0 THEN
						idc_amt[ii_method] = 0
					END IF
					
					IF li_first 	= 0 then
							il_paycnt	= ll_qty
							li_first 	= 1
					else 
							il_paycnt 	= 0
					END IF
			ELSE
					IF idc_rem >= idec_saleamt THEN
						ldc_saleamt 	=  idec_saleamt
						IF li_first 	=  0 then
							il_paycnt	= ll_qty
							li_first 	= 1
						else 
							il_paycnt 	= 0
						END IF
						idc_rem 			=  idc_rem -  ldc_saleamt
						IF idc_rem 		= 0 		then 	ii_method += 1
						idec_saleamt 	= 0
					ELSE
						ldc_saleamt 	= idc_rem
						ldc_salerem 	= idec_saleamt - idc_rem
						IF li_first 	=  0 then
							il_paycnt 	= ll_qty
							li_first 	= 1
						else
							il_paycnt 	= 0
						END IF
						idec_saleamt 	= ldc_salerem 
						ii_method		+= 1
					END IF
			END IF
			
			
			insert into dailypayment
					( payseq,							paydt,			
					  shopid,		operator,		customerid,
					  itemcod,		paymethod,		regcod,			payamt,			basecod,
					  paycnt,		payid,			remark,			trdt,				mark,
					  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
					  manual_yn,	pgm_ID,			remark2)
			values 
					( seq_dailypayment.nextval, 	:idt_paydt, 	
					  :is_partner, :is_operator, 	:is_customerid,
					  :is_itemcod,	:is_paymethod,	:is_regcod,		:ldc_saleamt,	:ls_basecod,
					  :il_paycnt,	:ls_payid,		:ls_remark,		sysdate,			null,
					  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
					  :ls_manual_yn, :ls_pgm_id,	:ls_remark2 )	 ;
						
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
				RollBack;
				Return 
			End If		
		
			IF idec_saleamt = 0 then exit
		next
	ELSE		//수납유형이 한개도 없을 경우!
		is_paymethod = '101'    // B310, cash
		
		insert into dailypayment
				( payseq,							paydt,			
				  shopid,		operator,		customerid,
				  itemcod,		paymethod,		regcod,			payamt,			basecod,
				  paycnt,		payid,			remark,			trdt,				mark,
				  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
				  manual_yn,	pgm_ID,			remark2)
		values 
				( seq_dailypayment.nextval, 	:idt_paydt, 	
				  :is_partner, :is_operator, 	:is_customerid,
				  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
				  1,				:ls_payid,		:ls_remark,		sysdate,			null,
				  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
				  :ls_manual_yn, :ls_pgm_id,	:ls_remark2 )	 ;
					
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
			RollBack;
			Return 
		End If
	END IF
		
	//FOR li_pp END
END IF
	//--------------------------------------------
	// 입금처리 END.....
	//--------------------------------------------
	IF idc_rem <> 0 then
		idc_amt[ii_method] = idc_rem
	END IF
Next

////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// ssrtppcif Insert
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Choose Case is_caller
    Case "save_sales" 			
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	          WHERE grcode = 'DacomPPC02' 
				   AND use_yn = 'Y'
	            AND CODE  = :is_itemcod;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.sale_amt[i]
		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;

		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (seq_ssrtppcif.nextval,'SALES','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If		
	         ELSE 
		      // Check 2
	             SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	              WHERE grcode = 'DacomPPC01' 
					    AND use_yn = 'Y'
	                AND CODE  = :is_itemcod ;
		
                IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
                IF ll_cnt > 0  AND is_caller = "save_sales" then
                    idec_saleamt 	= idw_data[2].object.sale_amt[i]
		              is_contno 		= trim(idw_data[2].object.contno[i])
				
                    select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
					 
                    SELECT count(*) INTO :ll_bonus FROM syscod2t
					      WHERE grcode = 'DacomPPC03'
							  AND use_yn = 'Y'
					        AND code = :is_itemcod; 

						  IF sqlca.sqlcode <> 0 OR IsNull(ll_bonus) THEN ll_bonus  = 0
                    
						  IF ll_bonus > 0  THEN
                        INSERT INTO ssrtppcif
								(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
							   VALUES
                        (seq_ssrtppcif.nextval,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.1)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
						  ELSE
                        INSERT INTO ssrtppcif 
								(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
								VALUES 
								(seq_ssrtppcif.nextval,'Recharge','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
						  END IF
								
                    If SQLCA.SQLCode < 0 Then
                        ii_rc = -1			
                        f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
                        RollBack ;
                        Return 
                    END IF
                End If	
            END IF
        NEXT
    Case "save_refund"
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         select Count(*) INTO :ll_cnt FROM syscod2t 
	          where grcode = 'DacomPPC02' 
	            AND CODE  = :is_itemcod ;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.refund_price[i]
//		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (seq_ssrtppcif.nextval,'REFUND','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0',:ls_pgm_id);

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If
				End IF
        NEXT		
End Choose
	

// ssrtppcif Insert ============>> END.....

//-------------------------------------------------------
//마지막으로 영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[2].SetSort('itemcod A')
idw_data[2].Sort()


String ls_lin1, ls_lin2, ls_lin3, ls_empnm
DEC	 ldc_shopCount

ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

ii_rc 		= 0
IF ls_prt = "Y" THEN
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	//1. head 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//	FOR jj = 1  to 2
//		IF jj = 1 then 
			li_rtn = f_pos_header(is_partner, ls_receipt_type, il_shopcount, 1 )
//		ELSE 
//			li_rtn = f_pos_header(is_partner, 'Z', il_shopcount, 0 )
//		END IF
		IF li_rtn < 0 then
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
			PRN_ClosePort()
			ii_rc = -9		
			return 
		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		il_row = idw_data[2].RowCount()
		For i = 1 To il_row
			is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			IF is_caller = "save_refund" then
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
			ELSE
				ls_refund_type = 'A'
			END IF
			
	      IF ls_refund_type <> '' THEN
			    ls_temp 		= String(i, '000') + ' ' //순번
			    is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			    is_itemNM 		= trim(idw_data[2].Object.itemNM[i])
			    li_qty 			= idw_data[2].Object.qty[i]
			    
				 IF IsNull(li_qty) OR li_qty  = 0 THEN li_qty = 1
			    
				 Choose Case is_caller
				     case "save_refund"
					       idec_saleamt 	= idw_data[2].object.refund_price[i]
				     Case "direct", "save_sales"  
					       idec_saleamt 	= idw_data[2].object.sale_amt[i]
			    End Choose

			    IF IsNull(is_itemNM) then is_itemNM 	= ''
	
	          ls_temp 	+= LeftA(is_itemnm + space(25), 24)  //아이템
			    ls_temp 	+= Space(1) + RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
			    is_val 	= fs_convert_amt(idec_saleamt,  8)
			    ls_temp 	+= is_val //금액
			    F_POS_PRINT(ls_temp, 1)	
	
			    is_regcod =  trim(idw_data[2].Object.regcod[i])
			    //regcode master read
			    select keynum, 		trim(facnum)
		  	      INTO :il_keynum,	:is_facnum
		  	      FROM regcodmst
		 	     where regcod = :is_regcod ;
					
				 // Index Desciption 2008-05-06 hcjung
			    SELECT indexdesc
		  	      INTO :is_facnum
		  	      FROM SHOP_REGIDX
		 	     WHERE regcod = :is_regcod
					 AND shopid = :is_partner;
	
			    IF IsNull(il_keynum) or sqlca.sqlcode < 0	then il_keynum 	= 0
			    IF IsNull(is_facnum) or sqlca.sqlcode < 0	then is_facnum 	= ""
			    ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
			    F_POS_PRINT(ls_temp, 1)
         END IF
		NEXT
		//2. Item List 출력 ----- end
		F_POS_PRINT(ls_lin1, 1)
		is_val 	= fs_convert_sign(idec_total, 8)
		ls_temp 	= LeftA("Grand Total" + space(33), 33) + is_val
		F_POS_PRINT(ls_temp, 1)
		F_POS_PRINT(ls_lin1, 1)
		//--------------------------------------------------------
		//결제수단별 입금액
  	 	For i = 1 To 5
				if ldc_amt0[i] <> 0 then
					is_val 	= fs_convert_sign(ldc_amt0[i],  8)
					ls_code	= ls_method0[i]
					select codenm INTO :ls_codenm from syscod2t
					where grcode = 'B310' 
			 		  and use_yn = 'Y'
					  AND code = :ls_code ;
					ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
					F_POS_PRINT(ls_temp, 1)
				END IF
		NEXT
		//거스름돈 처리
		is_val 	= fs_convert_sign(idec_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + is_val
		F_POS_PRINT(ls_temp, 1)
		F_POS_PRINT(ls_lin1, 1)
//		F_POS_FOOTER(ls_memberid, is_app, gs_user_id)
		FS_POS_FOOTER2(ls_payid,is_customerid, is_app, gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 
//	next 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
	PRN_ClosePort()
END IF
//-------------------------------------- end....
ii_rc = 0
commit ;

Return 
end subroutine

public subroutine uf_prc_db_08 ();//sales 화면 전용!
//total 이 - 이면 + 금액부터 정렬 시켜서 처리   (-) - (+) 는 계속  -로 누적되기 때문에
//         + 이면 - 금액부터 정렬 시켜서 처리   (+) - (-) 는 계속  +로 누적되기 때문에...
// ---------------------------------------------------------------------------------------------
// HISTORY
// ADD : 2009-06-13 : 최재혁  impack 카드 금액 분리시키기 위해 새로 적용된 로직!

date		ldt_refunddt,	ldt_shop_closedt			
Integer	i, jj, 			li_first, 			li_pp, 			LI_QTY,		li_rtn, ll_bonus, li_update
Long		ll_qty,			ll_retseq,			ll_cnt,			ll_group_cnt,	ll_card_check, ll_all20
LONG		ll_seq,			ll_groupdet_seq,	ll_contractseq, ll_orderno, ll_seqno, ll_payseq
dec{2}	ldc_salerem, 	ldc_saleamt, 		ldc_amt0[],		ldc_impack,	ldc_impack_in, ldec_payamt, ldec_refund_amt,ldec_balance, ldec_card_balance
String 	ls_refund_type, 	ls_remark, 		ls_receipt_type, &
			ls_manual_yn,	ls_modelno, 		ls_adlog_yn, 	ls_refundtype
String 	ls_temp, 		ls_method0[], 		ls_trcod[]
String   ls_prt, 			ls_memberid, 		ls_payid, 		ls_basecod, &
			ls_admst_yn, 	ls_code, 			ls_codenm, &
			ls_dctype, 		ls_receipttype, 	ls_admst_status, ls_ref_desc, &
			ls_rtype[], 	ls_adsta_ret,		ls_pgm_id, &
			ls_serialno,	ls_remark2,       ls_sale_type,	ls_end, ls_add,	&
			ls_action,		ls_refund,			ls_pgmid,		ls_remark3,    &
			ls_status,     ls_result, ls_balance_amt

// 2019.04.17 VAT 처리를 위한 변수 추가 Modified by Han
//string   ls_customerid
dec{2}   ld_taxrate,    ld_sale_tot, ld_taxamt, ld_vat



//add - 2009.06.13
String	ls_trcod_im,	ls_method0_im,		ls_remark_group
DEC{2}	ldc_amt0_im

//장비 status
ls_admst_Status	= fs_get_control("E1", "A103", ls_ref_desc)
//E1,A103
ls_adsta_ret		= fs_get_control("E1", "A102", ls_ref_desc)

//영수증  Type 100, 200, 300, 400 ==> 수금,환불,비판매,Xreport
ls_temp = fs_get_control("S1", "A100", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_rtype[])

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
SELECT ref_content INTO :ls_action FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A103';

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 반품 )
SELECT ref_content INTO :ls_refund FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A105';


//정렬 순서 조정. 토탈이 - 일경우 + 금액부터, +금액일 경우 - 금액부터
idec_total   		= idw_data[1].object.total[1]
ldc_impack 			= idw_data[1].object.amt5[1] 	

Choose Case is_caller
	case "save_refund"
			ls_receipt_type  	= 'B'
			ls_dctype 			= 'C'
			ls_receipttype 	= ls_rtype[2]
			IF idec_total > 0 THEN
				IF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, refund_price A')
				ELSEIF ldc_impack < 0 THEN	
					idw_data[2].SetSort('impack_check A, impack_card D, refund_price A')
				ELSE
					idw_data[2].SetSort('refund_price A')
				END IF
			ELSE
				IF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, refund_price D')
				ELSEIF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, refund_price D')
				ELSE
					idw_data[2].SetSort('refund_price D')
				END IF
			END IF			
			idw_data[2].Sort()
			
	CASE 'hotbill'
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'D'
			ls_receipttype 	= ls_rtype[2]
			idw_data[2].SetSort('ss A, cp_amt A')
			idw_data[2].Sort()
	Case ELSE
			ls_receipt_type  	= 'A'
			ls_dctype 			= 'D'
			ls_receipttype 	= ls_rtype[1]
			IF idec_total > 0 THEN
				IF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt A')
				ELSEIF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt A')
				ELSE
					idw_data[2].SetSort('sale_amt A')
				END IF
			ELSE
				IF ldc_impack < 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card D, sale_amt D')
				ELSEIF ldc_impack > 0 THEN
					idw_data[2].SetSort('impack_check A, impack_card A, sale_amt D')
				ELSE
					idw_data[2].SetSort('sale_amt D')
				END IF				
			END IF
			idw_data[2].Sort()
End Choose


ii_rc 		= -1
li_first 	= 0

is_customerid   	= is_data[1]
is_paydt   			= is_data[2]
is_partner    		= is_data[3]
is_operator   		= is_data[4]
ls_prt   			= is_data[5]
ls_admst_yn			= is_data[7]
ls_memberid   		= is_data[8]
ls_adlog_yn   		= is_data[9]
ls_pgm_id			= is_data[10]
ls_pgmid				= is_data[6]
ldt_shop_closedt 	= f_find_shop_closedt(is_partner)
idt_paydt   		= idw_data[1].object.paydt[1]
idec_receive		= idw_data[1].object.cp_receive[1]
idec_change   		= idw_data[1].object.cp_change[1]
		
ls_trcod[1] 		= idw_data[1].object.trcod3[1]
ls_trcod[2] 		= idw_data[1].object.trcod2[1]
ls_trcod[3] 		= idw_data[1].object.trcod4[1]
ls_trcod[4] 		= idw_data[1].object.trcod1[1]
ls_trcod[5] 		= idw_data[1].object.trcod6[1]	

ls_method0[1] 		= idw_data[1].object.method3[1]
ls_method0[2] 		= idw_data[1].object.method2[1]
ls_method0[3] 		= idw_data[1].object.method4[1]
ls_method0[4] 		= idw_data[1].object.method1[1]
ls_method0[5] 		= idw_data[1].object.method6[1]

ldc_amt0[1] 		= idw_data[1].object.amt3[1]
ldc_amt0[2] 		= idw_data[1].object.amt2[1]
ldc_amt0[3] 		= idw_data[1].object.amt4[1]
ldc_amt0[4] 		= idw_data[1].object.amt1[1]
ldc_amt0[5] 		= idw_data[1].object.amt6[1]

IF ldc_impack <> 0 THEN 		
	ls_trcod_im		= idw_data[1].object.trcod5[1]
	ls_method0_im	= idw_data[1].object.method5[1]	
	ldc_amt0_im		= idw_data[1].object.amt5[1]			
END IF
	
ii_amt_su 			= 0
//----------------------------------------------------------
FOR i = 1 to 5			//impack 은 별도!!!
			IF ldc_amt0[i] <> 0 THEN 
				ii_amt_su 				+= 1 
				idc_amt[ii_amt_su] 	= ldc_amt0[i]
				is_method[ii_amt_su] = ls_method0[i]
			end if
NEXT
//----------------------------------------------------------
//customerm Search
select memberid, 		payid, 		basecod
  INTO :ls_memberid, :ls_payid, :ls_basecod
  FROM customerm
 WHERE customerid = :is_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_payid)		THEN ls_payid 		= ""
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""
//----------------------------------------------------------
//1.receiptMST Insert
//SEQ 
Select seq_receipt.nextval		  Into :is_appseq						  From dual;
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_receipt)")
	RollBack;
	Return 
End If			
		
IF ls_prt = "Y" then
	//실 영수증 번호임.
	Select seq_app.nextval		  Into :is_app						  From dual;
	If SQLCA.SQLCode < 0 Then
		ii_rc = -1			
		f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_app)")
		RollBack;
		Return 
	End If			
END IF
//----------------------------------------------------------
//SHOP COUNT
Select shopcount	    Into :il_shopcount	  From partnermst
 WHERE partner = :is_partner ;
		 
IF IsNull(il_shopcount) THEN il_shopcount = 0
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update Error(PARTNERMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
il_shopcount += 1
insert into RECEIPTMST
				( approvalno,	shopcount,			receipttype,	shopid,			posno,
				  workdt,		trdt,				   memberid,		operator,		total,
				  cash,			change, 				seq_app, 		customerid,		prt_yn )
			values 
			   ( :is_appseq, 	:il_shopcount,		:ls_receipttype,:is_partner, 	NULL,
				  sysdate,	   :idt_paydt,			:ls_memberid,	:is_operator,	:idec_total,
				  :idec_receive,:idec_change,		:is_app,			:is_customerid,:ls_prt )	 ;
				   
//저장 실패
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Insert Error(RECEIPTMST)")
	RollBack;
	Return 
End If			
//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
Update partnermst
			Set shopcount 	= :il_shopcount
			Where partner  = :is_partner ;
//Update 실패 
If SQLCA.SQLCode < 0 Then
	ii_rc = -1			
	f_msg_sql_err(is_title, is_caller + " Update  Error(PARTNERMST)")
	RollBack;
	Return 
End If	
//----------------------------------------------------------
// ADMST Update & dailypament에 Insert
il_row 		= idw_data[2].RowCount()
ii_method	= 1

IF is_caller = "save_refund" then
	ls_remark =  trim(idw_data[1].Object.remark[1])
	ls_remark2 = ''
	ldt_refunddt =  idw_data[1].Object.paydt[1]
END IF
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ls_add = 'N'
ls_end = 'N'

For i = 1 To il_row
	is_contno 		= trim(idw_data[2].object.contno[i])
	ls_modelno 		= trim(idw_data[2].object.modelno[i])
	ll_qty 			= idw_data[2].object.qty[i]
	IF	is_caller = "save_sales" THEN 
		ll_contractseq = idw_data[2].object.contractseq[i]
		ll_orderno		= idw_data[2].object.orderno[i]
	END IF		
	
	IF IsNull(ls_modelno) THEN ls_modelno = ""
	ll_group_cnt = 0	
	IF ls_modelno <> "" THEN
		SELECT COUNT(*) INTO :ll_group_cnt
		FROM   SYSCOD2T
		WHERE  GRCODE = 'UBS11'
		AND    USE_YN = 'Y'
		AND    CODE   = :ls_modelno;		
	END IF	
	
	IF is_caller = "save_refund" then
		ls_refund_type = trim(idw_data[2].object.refund_type[i])
	ELSE
		ls_refund_type =''
	END IF
	IF IsNull(ls_refund_type) then ls_refund_type = ''
		
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refundtype	= idw_data[2].object.REFUND_TYPE[i]
				// 2019.04.19 Vat 포함한 금액 및  Vat  추가 Modified By Han
				ld_sale_tot    = idw_data[2].Object.refund_price[i] + idw_data[2].Object.refund_vat[i]
				ld_vat         = idw_data[2].Object.refund_vat  [i]
				
				if iSnULL(ls_refundtype) then ls_refundtype = ""

				IF ldc_impack <> 0 THEN
					idec_imnot 		= idw_data[2].object.impack_not[i]
					idec_im			= idw_data[2].object.impack_card[i]
				END IF
		Case else
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				// 2019.04.17 VAT 포함한 Total 금액 추가
            ld_sale_tot    = idw_data[2].Object.sale_tot[i]
				ld_vat         = idw_data[2].Object.vat     [i]
				IF ldc_impack <> 0 THEN
					idec_imnot 		= idw_data[2].object.impack_not[i]
					idec_im			= idw_data[2].object.impack_card[i]
				END IF
	End Choose
	li_first 		= 0
	li_update		= 0	
			
	//장비마스터 Update 여부 확인....
	if ls_admst_yn = "Y" THEN
		IF is_contno <> "" THEN
			choose case is_caller
				CASE "save_refund" //반품 처리
				   IF ls_refund_type <> '' THEN
						ls_modelno 		= trim(idw_data[2].Object.modelno[i])
						ls_refund_type	= trim(idw_data[2].Object.refund_type[i])
						idec_saleamt 	= idw_data[2].object.refund_price[i]
						Select seq_adreturn.nextval		  Into :ll_retseq	  From dual;
						If SQLCA.SQLCode < 0 Then
								ii_rc = -1			
								f_msg_sql_err(is_title, is_caller + " Sequence Error(seq_adreturn)")
								RollBack;
								Return 
						End If			
						//1.adreturn insert		장비반품정보
						Insert Into adreturn 
										( retseq, 				returndt, 		partner, 		contno, 		modelno, 
										  refund_type, 		refund_amt,	  	note, 			crtdt, 		crt_user, 	pgm_id)
								Values( :ll_retseq, 			:ldt_refunddt, :is_partner,	:is_contno, :ls_modelno, 
										  :ls_refund_type, 	:idec_saleamt, :ls_remark,  	sysdate, 	:gs_user_id, :ls_pgmid);
						If SQLCA.SQLCode < 0 Then
							ii_rc = -1
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADRETURN)")
							Rollback ;
							Return 
						End If					
					
						//a. ADMST Update
						Update ADMST
							Set retdt 		= :idt_paydt,
  					  	  		Status 		= :ls_adsta_ret,
								mv_partner  = :is_partner,
  					   	 	sale_flag	= '0',
  					   	 	retseqno	   = :ll_retseq,
								updt_user 	= :gs_user_id,
						 		updtdt 		= sysdate,
						 		pgm_id 		= :ls_pgmid					 
							Where contno 	= :is_contno ;
							
						//장비이력(admstlog) Table에 정보저장
						//일련번호(seq)추출
						SELECT seq_admstlog.nextval	INTO :ll_seq	FROM dual;		
						
						INSERT INTO ADMSTLOG_NEW		
							( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
							  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
							  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
							  PGM_ID, IDATE )
						SELECT ADSEQ, :ll_seq, :ls_refund, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
								 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
								 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
								 :ls_pgmid, IDATE
						FROM   ADMST
						WHERE  CONTNO = :is_contno;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG_NEW)")
							RollBack;
							Return 
						End If									
					END IF
				CASE ELSE
					ls_sale_type     		= trim(idw_data[2].Object.sale_type[i])
					IF ls_sale_type = 'Y' THEN // 장비 판매인 경우, 판매와 충전이 동시에 올경우 판매에서만 Update 2007-08-06 hcjung
						//저장할 때도 상태 확인.
						
						
						SELECT COUNT(*) INTO :ll_card_check
						FROM   ADMST
						WHERE  CONTNO = :is_contno
						AND    STATUS IN ('MG100', 'RP100', 'SG100');						
						
						
						
						IF ll_card_check <= 0 THEN
							//a. ADMST Update
							UPDATE ADMST
							SET    saledt 	   = :idt_paydt,
									 customerid = :is_customerid,
									 sale_amt   = :idec_saleamt,
									 status     = :ls_admst_status,
									 sale_flag	= '1',
									 updt_user  = :gs_user_id,
									 updtdt 	   = sysdate,
									 pgm_id 	   = :ls_pgmid					 
							WHERE  contno 	   = :is_contno;
						ELSE
							ii_rc = -1			
							f_msg_sql_err(is_title, is_caller + " Cont No. Error(ADMST)")
							RollBack;
							Return 
						END IF
					END IF
			END CHOOSE
				
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
					RollBack;
					Return 
			End If
		END IF
		IF ls_adlog_yn = "Y" AND ls_modelno <> "" THEN
			//--------------AD_SALELOG 처리
			//ad_salelog insert	
			Insert Into ad_salelog	(saleseq, 	
							saledt, 					SHOPID,				saleqty,			sale_amt,		
							sale_sum,				paymethod,			modelno,			contno,		
							note,						crt_user,			crtdt, 			pgm_id)
			Values(		seq_ad_salelog.nextval,
							:idt_paydt,	:is_partner,		:ll_qty, 		:idec_saleamt , 
							:idec_saleamt, 		null,					:ls_modelno,	:is_contno,
							null,						:gs_user_id,		sysdate,			:ls_pgmid );
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(AD_SALELOG)")
				RollBack;
				Return 
			End If
			
			//장비이력(admstlog) Table에 정보저장
			//일련번호(seq)추출
			SELECT seq_admstlog.nextval	INTO :ll_seq	FROM dual;		
			
			INSERT INTO ADMSTLOG_NEW		
				( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
				  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
				  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
				  PGM_ID, IDATE )
			SELECT ADSEQ, :ll_seq, :ls_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
					 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
					 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
					 :ls_pgmid, IDATE
			FROM   ADMST
			WHERE  CONTNO = :is_contno;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(ADMSTLOG_NEW)")
				RollBack;
				Return 
			End If		
		END IF
	END IF
	
	IF ll_group_cnt > 0 THEN   //그룹물품이면....
		IF ll_qty <> 0 THEN
			
			ls_remark_group = idw_data[2].object.remark[i]
			
			//2014.07.18 NVL처리해줌. 
			UPDATE AD_GROUPMST
			SET    OAMT = NVL(OAMT,0) + :ll_qty,
			       AMOUNT = NVL(AMOUNT,0) - :ll_qty,
					 UPDT_USER = :gs_user_id,
					 UPDTDT   = SYSDATE
			WHERE  MODELNO = :ls_modelno
			AND    PARTNER = :gs_shopid;

			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(AD_GROUPMST)")
				RollBack;
				Return 
			End If
			
			SELECT SEQ_AD_GROUPDET.NEXTVAL INTO :ll_groupdet_seq
			FROM   DUAL;
			
			/* 2014.07.08 #8459 - 판매플래그가 'S'인경우, CUSTOMERID도 입력되도록 추가함 */
			
			INSERT INTO AD_GROUPDET
					( SEQNO,			ACTION_FLAG,		MODELNO,		PARTNER,
					  CUSTOMERID,
					  AMOUNT,		WORKDT,				REMARK,		CRT_USER,
					  CRTDT,			PGM_ID )
			VALUES ( :ll_groupdet_seq,				'S',					:ls_modelno,		:gs_shopid,
			         :is_customerid,
						:ll_qty,							:idt_paydt,			:ls_remark_group, :gs_user_id,
						SYSDATE,							:ls_pgmid );
						
			
						
			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(AD_GROUPDET)")
				RollBack;
				Return 
			End If	
			
         INSERT INTO GROUPLOG_NEW
					(ADSEQ,		SEQ,			ACTION,		ACTDT,     SALEDT,
					 SHOPID,		SALEQTY,		SALE_AMT,	SALE_SUM,
					 MODELNO,	REMARK,		CRT_USER,	CRTDT,		PGM_ID ) 
			VALUES ( SEQ_AD_GROUPLOG.NEXTVAL,	:ll_groupdet_seq,		:ls_action,			SYSDATE,			:idt_paydt,
						:gs_shopid, 					:ll_qty,	 				0, 					0,
						:ls_modelno,					:ls_remark_group,		:gs_user_id,		SYSDATE,			:ls_pgmid );

			If SQLCA.SQLCode <> 0 Then
				f_msg_sql_err(is_title, is_caller + " Insert Error(GROUPLOG_NEW)")
				RollBack;
				Return 
			End If	
		END IF
	END IF
					 
	
		
	//===================================================
	//b. dailypayment Insert
	// regcod search
	//====================================================
	is_itemcod 		= trim(idw_data[2].object.itemcod[i])
	ll_qty 			= idw_data[2].object.qty[i]
	is_regcod 		= trim(idw_data[2].object.regcod[i])
	Choose Case is_caller
		case "save_refund"
				idec_saleamt 	= idw_data[2].object.refund_price[i]
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
				
				ls_manual_yn 	= 'N'
				ls_remark 		= is_contno
				ls_remark2		= idw_data[2].object.remark[i]
// 2019.04.29 DailySale Table Insert 추가 Modified by Han
				INSERT    INTO DAILYSALE(PAYID    , ITEMCOD    , SALEAMT      , TAXAMT , APPNO     , PGM_ID , CRTDT  )
				        VALUES          (:ls_payid, :is_itemcod, :idec_saleamt, :ld_vat, :is_appseq, 'REFUND', sysdate);
		Case "direct" 
				ls_remark 		= ''
				ls_remark2		= ""
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= 'N'
		Case "save_sales" 
				ls_remark 		= idw_data[2].object.remark[i]
				ls_remark2 		= idw_data[2].object.remark2[i]
				ls_remark3		= idw_data[2].object.remark3[i]
				idec_saleamt 	= idw_data[2].object.sale_amt[i]
				ls_refund_type = ''
				ls_manual_yn 	= idw_data[2].object.manual_yn[i]

// 2019.04.29 DailySale Table Insert 추가 Modified by Han
				INSERT    INTO DAILYSALE(PAYID    , ITEMCOD    , SALEAMT      , TAXAMT , APPNO     , PGM_ID , CRTDT  )
				        VALUES          (:ls_payid, :is_itemcod, :idec_saleamt, :ld_vat, :is_appseq, 'SALES', sysdate);

		case else
				ls_remark 		= ''
				ls_remark2		= ""
				idec_saleamt 	= 0
				ls_refund_type = ''
				ls_manual_yn 	= ''
	End Choose
	
	IF ( is_caller = 'save_refund' AND ls_refund_type <> '' ) OR  is_caller <> 'save_refund' THEN
		//-------------------------------------------------------------------------
		//입금내역 처리  Start........ 
		//-------------------------------------------------------------------------
		IF ii_amt_su > 0 THEN
// 2019.04.17 Item별 taxrate를 가져온다 Modified by Han

			SELECT FNC_GET_TAXRATE(:is_customerid, 'I', :is_itemcod, to_date(:Is_paydt))
			  INTO :ld_taxrate
			  FROM DUAL;

			IF ld_taxrate <> 0 then
				//합계액으로 공급가액과 부가세를 나눠주는 공식임.
				ld_taxrate = 1 + ( ld_taxrate / 100)
			ELSE
				// 0으로 나눠주면 에러남
				ld_taxrate = 1
			END IF

			IF ls_end = 'N' THEN											//수납이 끝나지 않았을 경우!
				//FOR li_pp Start											//임팩 카드를 제외한 수납 처리!
				FOR li_pp =  ii_method to ii_amt_su					//수납유형 수만큼 루프.
					is_paymethod 	= is_method[li_pp]				//수납유형 있는것만...
					idc_rem 			= idc_amt[li_pp]					//수납유형에 있는 금액...
					
					IF li_first 	= 0 then								//ITEM 수량을 넣기 위해서...첫번째 로우라면..
						il_paycnt	= ll_qty								//ITEM 수량 입력
						li_first 	= 1									//첫번째 로우 아니라는 표시
					ELSE 														//첫번째 로우 아니면 수량 0 세팅!
						il_paycnt 	= 0
					END IF								
					
// 2019.04.17 Total Vat 포함한 금액에서 처리 Modified by Han
					IF idc_rem > 0 THEN									       // 수납유형에 + 금액이면
						IF idc_rem - ld_sale_tot <= 0 THEN			       // 수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이하이면 다음 수납유형
							ldc_saleamt	 = round(idc_rem / ld_taxrate, 2) // 품목공급금액을 넣는다.
							ld_taxamt    = idc_rem - ldc_saleamt          // 부가세
							ld_sale_tot  = ld_sale_tot - idc_rem	       // loop 를 돌리기 위해서
							
							IF ii_method = ii_amt_su THEN				       // 나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								       // 나누기 처리 끝...
								
								IF ld_sale_tot <> 0 THEN				       // 아이템 금액이 남아 있다면 추가 작업!-CASH
									ls_add = 'Y'
								END IF
							END IF	
							
							idc_rem		 = 0								       // 수납금액을 0으로
							ii_method	+= 1		
						ELSE													       // 수납유형에 돈이 남아있으면...다음 아이템으로						
							idc_rem		 = idc_rem - ld_sale_tot	       // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = ld_sale_tot - ld_vat           // 품목금액을 넣는다. idec_saleamt = ld_sale_tot - ld_vat
//							ld_taxamt    = ld_vat                         // 부가세
							ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
							ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
							ld_sale_tot  = 0				                   // loop 를 빼기 위해서!		
						END IF
					ELSEIF idc_rem < 0 THEN                             // 수납유형에 - 금액이면
						IF idc_rem - ld_sale_tot >= 0 THEN               // 수납금액에서 ITEM(IMPACK 제외) 제외 금액이 0 이상이면 다음 수납유형
							ldc_saleamt	 = round(idc_rem / ld_taxrate, 2) // 품목금액을 넣는다.
							ld_taxamt    = idc_rem - ldc_saleamt           // 부가세
							ld_sale_tot  = ld_sale_tot - idc_rem          // loop 를 돌리기 위해서

							IF ii_method = ii_amt_su THEN				       // 나누기 처리는 다 끝났다는 신호!
								ls_end = 'Y'								       // 나누기 처리 끝...
								IF ld_sale_tot <> 0 THEN                   // 아이템 금액이 남아 있다면 추가 작업!-CASH
									ls_add = 'Y'
								END IF
							END IF
							idc_rem		 = 0								       // 수납유형에 있는 금액에서 아이템 금액을 빼준다.													
							ii_method	+= 1												
						ELSE
							idc_rem		 = idc_rem - ld_sale_tot          // 수납유형에 있는 금액에서 아이템 금액을 빼준다.
//							ldc_saleamt	 = ld_sale_tot - ld_vat           // 품목금액을 넣는다.
//							ld_taxamt    = ld_vat                         // 부가세
							ldc_saleamt	 = round(ld_sale_tot / ld_taxrate, 2)  // 품목금액을 넣는다.
							ld_taxamt    = ld_sale_tot - ldc_saleamt           // 부가세
							ld_sale_tot  = 0                              // loop 를 빼기 위해서!	
						END IF						
					ELSE														       // 아이템은 있는데 수납이 다 까졌을 때...
						ldc_saleamt  = ld_sale_tot - ld_vat              // 품목금액을 넣는다.
						ld_taxamt    = ld_vat                            //부가세
						ld_sale_tot  = 0									       //loop 를 빼기 위해서!
						is_paymethod = '101'								       //cash
					END IF
	
					insert into dailypayment
							( payseq,							paydt,			
							  shopid,		operator,		customerid,
							  itemcod,		paymethod,		regcod,			payamt,			basecod,
							  paycnt,		payid,			remark,			trdt,				mark,
							  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
							  manual_yn,	pgm_ID,			remark2,			contractseq,	orderno,		remark3  ,  taxamt)
					values 
							( seq_dailypayment.nextval, 	:idt_paydt, 	
							  :is_partner, :is_operator, 	:is_customerid,
							  :is_itemcod,	:is_paymethod,	:is_regcod,		:ldc_saleamt,	:ls_basecod,
							  :il_paycnt,	:ls_payid,		:ls_remark,		sysdate,			null,
							  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
							  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ll_contractseq,	:ll_orderno , :ls_remark3, :ld_taxamt )	 ;
							
					//저장 실패 
					If SQLCA.SQLCode < 0 Then
						ii_rc = -1			
						f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_paymethod)")
						RollBack;
						Return 
					End If
					
					IF ls_add = 'Y' THEN
//						is_paymethod = '101'
//						
//						insert into dailypayment
//								( payseq,							paydt,			
//								  shopid,		operator,		customerid,
//								  itemcod,		paymethod,		regcod,			payamt,			basecod,
//								  paycnt,		payid,			remark,			trdt,				mark,
//								  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
//								  manual_yn,	pgm_ID,			remark2)
//						values 
//								( seq_dailypayment.nextval, 	:idt_paydt, 	
//								  :is_partner, :is_operator, 	:is_customerid,
//								  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
//								  0,				:ls_payid,		:ls_remark,		sysdate,			null,
//								  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
//								  :ls_manual_yn, :ls_pgm_id,	:ls_remark2 )	 ;
//								
//						//저장 실패 
//						If SQLCA.SQLCode < 0 Then
//							ii_rc = -1			
//							f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT_add)")
//							RollBack;
//							Return 
//						End If
					END IF				
			
					idc_amt[li_pp]	= idc_rem					
					IF ld_sale_tot = 0 then exit
				NEXT
			ELSE				//수납이 끝났지만 ITEM 이 남아 있을 경우!
				is_paymethod = '101'    // B310, cash
			
				insert into dailypayment
						( payseq,							paydt,			
						  shopid,		operator,		customerid,
						  itemcod,		paymethod,		regcod,			payamt,			basecod,
						  paycnt,		payid,			remark,			trdt,				mark,
						  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
						  manual_yn,	pgm_ID,			remark2,			contractseq,	orderno,		remark3 )
				values 
						( seq_dailypayment.nextval, 	:idt_paydt, 	
						  :is_partner, :is_operator, 	:is_customerid,
						  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
						  :ll_qty,		:ls_payid,		:ls_remark,		sysdate,			null,
						  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
						  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ll_contractseq,	:ll_orderno, :ls_remark3 )	 ;
						
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
					RollBack;
					Return 
				End If				
			END IF				
		ELSE		//수납유형이 한개도 없을 경우!
			is_paymethod = '101'    // B310, cash
		
			insert into dailypayment
					( payseq,							paydt,			
					  shopid,		operator,		customerid,
					  itemcod,		paymethod,		regcod,			payamt,			basecod,
					  paycnt,		payid,			remark,			trdt,				mark,
					  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user,
					  manual_yn,	pgm_ID,			remark2, 		contractseq,	orderno,		remark3)
			values 
					( seq_dailypayment.nextval, 	:idt_paydt, 	
					  :is_partner, :is_operator, 	:is_customerid,
					  :is_itemcod,	:is_paymethod,	:is_regcod,		:idec_saleamt,	:ls_basecod,
					  :ll_qty,		:ls_payid,		:ls_remark,		sysdate,			null,
					  NULL,			:ls_dctype,		:is_appseq,		sysdate,			sysdate,		:gs_user_id,
					  :ls_manual_yn, :ls_pgm_id,	:ls_remark2,	:ll_contractseq,	:ll_orderno, :ls_remark3)	 ;
					
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
				RollBack;
				Return 
			End If
		END IF
		
		//FOR li_pp END
	END IF

NEXT

//dailiypayment 부가세 보정 start
integer li_ret
Choose Case is_caller
	case "save_refund"
		li_ret = f_vat_diff_update('REFUND', ls_payid, 'APPROV', is_appseq)

	case "save_sales"
		li_ret = f_vat_diff_update('SALES', ls_payid, 'APPROV', is_appseq)
end choose

if li_ret < 0 then
	messagebox("부가세보정","부가세를 보정하지 못했습니다.");
end if

//dailiypayment 부가세 보정 end

////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//// ssrtppcif Insert
////+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Choose Case is_caller
    Case "save_sales" 			
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	          WHERE grcode = 'DacomPPC02' 
				   AND use_yn = 'Y'
	            AND CODE  = :is_itemcod;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.sale_amt[i]
		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
					 
					 //2011.09.07 추가함.
					 SELECT SEQ_SSRTPPCIF.NEXTVAL INTO :ll_seqno
					 FROM   DUAL;	
					 //2011.09.07 추가함. end

		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (:ll_seqno,'SALES','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');

					 If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If							 
					 
				
					 //2011.09.07 추가함.
					 SELECT SUM(PAYAMT), MAX(PAYSEQ) INTO :ldec_payamt, :ll_payseq
					 FROM   DAILYPAYMENT
					 WHERE  CUSTOMERID = :is_customerid
					 AND    PAYDT = TO_DATE(TO_CHAR(:idt_paydt, 'YYYYMMDD'), 'YYYYMMDD')
					 AND    ITEMCOD = :is_itemcod;
					 
					 INSERT INTO SSRTPPCIF_LOG
					 ( CUSTOMERID, PAYDT, ITEMCOD, PAYAMT, PAYSEQ, CARDSEQ, SERIALNO, CRTDT, CRT_USER )
					 VALUES
					 ( :is_customerid, :idt_paydt, :is_itemcod, :ldec_payamt, :ll_payseq, :ll_seqno, :ls_serialno, SYSDATE, :gs_user_id ); 

 					 If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif_log)")
			           RollBack ;
			           Return 
		          End If	
 					 //2011.09.07 추가함. end
	         ELSE 
		      // Check 2
	             SELECT Count(*) INTO :ll_cnt FROM syscod2t 
	              WHERE grcode = 'DacomPPC01' 
					    AND use_yn = 'Y'
	                AND CODE  = :is_itemcod ;
		
                IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
                IF ll_cnt > 0  AND is_caller = "save_sales" then
                    idec_saleamt 	= idw_data[2].object.sale_amt[i]
		              is_contno 		= trim(idw_data[2].object.contno[i])
				
                    select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
					 
                    SELECT count(*) INTO :ll_bonus FROM syscod2t
					      WHERE grcode = 'DacomPPC03'
							  AND use_yn = 'Y'
					        AND code = :is_itemcod; 

						  IF sqlca.sqlcode <> 0 OR IsNull(ll_bonus) THEN ll_bonus  = 0
                    
						  IF ll_bonus > 0  THEN
							   //2013.02.04 Sunzu Kim 막음. 이윤주 대리 요청으로 충전시, Balance Check데이타 들어가지 않도록  
								//2011.09.07 충전하기 전에 BALANCE CHECK 먼저 하도록...
//								//INSERT INTO ssrtppcif 
//								//(seqno, msgcode, work_type, data_status, cardno, balance, amount, crtdt, crt_user, usercode)
//								//VALUES (seq_ssrtppcif.nextval, 'PCM21010T0', 'Balance Check', '0', :ls_serialno, 0, 0, sysdate, :gs_user_id, 'USSRT2');
							
							 	//2011.09.07 추가함.
								SELECT SEQ_SSRTPPCIF.NEXTVAL INTO :ll_seqno
								FROM   DUAL;	
								//2011.09.07 추가함. end
							
								//2010.05.07 추가. 보너스 카드이고 50불 이상이면 20% 추가충전...아니면 기존처럼...
								IF idec_saleamt >= 50 or idec_saleamt <= -50 THEN  
									INSERT INTO ssrtppcif
									(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
									VALUES
									(:ll_seqno,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.2)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
								ELSE
									INSERT INTO ssrtppcif
									(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
									VALUES
									(:ll_seqno,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.1)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
								END IF
								
																
								 //2011.09.07 추가함.
								 SELECT SUM(PAYAMT), MAX(PAYSEQ) INTO :ldec_payamt, :ll_payseq
								 FROM   DAILYPAYMENT
								 WHERE  CUSTOMERID = :is_customerid
								 AND    PAYDT = TO_DATE(TO_CHAR(:idt_paydt, 'YYYYMMDD'), 'YYYYMMDD')
								 AND    ITEMCOD = :is_itemcod;
								 
								 INSERT INTO SSRTPPCIF_LOG
								 ( CUSTOMERID, PAYDT, ITEMCOD, PAYAMT, PAYSEQ, CARDSEQ, SERIALNO, CRTDT, CRT_USER )
								 VALUES
								 ( :is_customerid, :idt_paydt, :is_itemcod, :ldec_payamt, :ll_payseq, :ll_seqno, :ls_serialno, SYSDATE, :gs_user_id ); 
			
								 If SQLCA.SQLCode < 0 Then
									  ii_rc = -1			
									  f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif_log)")
									  RollBack ;
									  Return 
								 End If	
								 //2011.09.07 추가함. end			
								
						  ELSE	
							   //2013.02.04 Sunzu Kim 막음. 이윤주 대리 요청으로 충전시, Balance Check데이타 들어가지 않도록
								//2011.09.07 충전하기 전에 BALANCE CHECK 먼저 하도록...
								//INSERT INTO ssrtppcif 
								//(seqno, msgcode, work_type, data_status, cardno, balance, amount, crtdt, crt_user, usercode)
								//VALUES (seq_ssrtppcif.nextval, 'PCM21010T0', 'Balance Check', '0', :ls_serialno, 0, 0, sysdate, :gs_user_id, 'USSRT2');
																
								
								 //2011.09.07 추가함.
								 SELECT SEQ_SSRTPPCIF.NEXTVAL INTO :ll_seqno
								 FROM   DUAL;	
								 //2011.09.07 추가함. end	
								 
								
								 
								IF ll_all20 > 0 THEN
									INSERT INTO ssrtppcif
									(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
									VALUES
									(:ll_seqno,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.2)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');									
								ELSE
									IF idec_saleamt >= 50 or idec_saleamt <= -50 THEN
										INSERT INTO ssrtppcif
										(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
										VALUES
										(:ll_seqno,'Recharge','0',:ls_serialno,(:idec_saleamt+:idec_saleamt*0.2)*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');																			
									ELSE
										INSERT INTO ssrtppcif 
										(seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
										VALUES 
										(:ll_seqno,'Recharge','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0','');
									END IF
								END IF						
								
								
								
								 //2011.09.07 추가함.
								 SELECT SUM(PAYAMT), MAX(PAYSEQ) INTO :ldec_payamt, :ll_payseq
								 FROM   DAILYPAYMENT
								 WHERE  CUSTOMERID = :is_customerid
								 AND    PAYDT = TO_DATE(TO_CHAR(:idt_paydt, 'YYYYMMDD'), 'YYYYMMDD')
								 AND    ITEMCOD = :is_itemcod;
								 
								 INSERT INTO SSRTPPCIF_LOG
								 ( CUSTOMERID, PAYDT, ITEMCOD, PAYAMT, PAYSEQ, CARDSEQ, SERIALNO, CRTDT, CRT_USER )
								 VALUES
								 ( :is_customerid, :idt_paydt, :is_itemcod, :ldec_payamt, :ll_payseq, :ll_seqno, :ls_serialno, SYSDATE, :gs_user_id ); 
			
								 If SQLCA.SQLCode < 0 Then
									  ii_rc = -1			
									  f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif_log)")
									  RollBack ;
									  Return 
								 End If	
								 //2011.09.07 추가함. end										
						  END IF
								
								 
								
                    If SQLCA.SQLCode < 0 Then
                        ii_rc = -1			
                        f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
                        RollBack ;
                        Return 
                    END IF			
				        
                End If	
            END IF
        NEXT
    Case "save_refund"
        il_row = idw_data[2].RowCount()
        For i = 1 To il_row
	         is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			
            // Check 1
	         select Count(*) INTO :ll_cnt FROM syscod2t 
	          where grcode = 'DacomPPC02' 
	            AND CODE  = :is_itemcod ;
			
	         IF sqlca.sqlcode <> 0 OR IsNull(ll_cnt) then ll_cnt  = 0
	         IF ll_cnt > 0  then
                idec_saleamt 	= idw_data[2].object.refund_price[i]
					 
					 //(#6481)여러건의 카드가 선택될 경우, 각각의 카드로 REFUND되도록 수정함. (2014.01.03 김선주)
		          is_contno 		= trim(idw_data[2].object.contno[i])
				
		          select serialno INTO :ls_serialno FROM admst where contno = trim(:is_contno) ;
					 
					//2013.02.04 Sunzu Kim 막음. 이윤주 대리 요청으로 충전시, Balance Check데이타 들어가지 않도록 
					//2011.09.07 충전하기 전에 BALANCE CHECK 먼저 하도록...
					//INSERT INTO ssrtppcif 
					//(seqno, msgcode, work_type, data_status, cardno, balance, amount, crtdt, crt_user, usercode)
					//VALUES (seq_ssrtppcif.nextval, 'PCM21010T0', 'Balance Check', '0', :ls_serialno, 0, 0, sysdate, :gs_user_id, 'USSRT2');					 
					 
					  //2011.09.07 추가함.
					 SELECT SEQ_SSRTPPCIF.NEXTVAL INTO :ll_seqno
					 FROM   DUAL;	
					 //2011.09.07 추가함. end

		          insert into ssrtppcif 
					 (seqno, work_type, data_status, cardno, amount, anino, fromcardno, usercode, balance, result, result_msg, crtdt, updtdt, crt_user, msgcode, remark)
					 values 
					 (:ll_seqno,'REFUND','0',:ls_serialno,:idec_saleamt*100,'','','USSRT2',0,'','',sysdate,'',:gs_user_id,'PCM21010T0',:ls_pgm_id);

		          If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif)")
			           RollBack ;
			           Return 
		          End If
					 
										 
					 //2011.09.07 추가함.
					 SELECT SUM(PAYAMT), MAX(PAYSEQ) INTO :ldec_payamt, :ll_payseq
					 FROM   DAILYPAYMENT
					 WHERE  CUSTOMERID = :is_customerid
					 AND    PAYDT = TO_DATE(TO_CHAR(:idt_paydt, 'YYYYMMDD'), 'YYYYMMDD')
					 AND    ITEMCOD = :is_itemcod;
					 
					 INSERT INTO SSRTPPCIF_LOG
					 ( CUSTOMERID, PAYDT, ITEMCOD, PAYAMT, PAYSEQ, CARDSEQ, SERIALNO, CRTDT, CRT_USER )
					 VALUES
					 ( :is_customerid, :idt_paydt, :is_itemcod, :ldec_payamt, :ll_payseq, :ll_seqno, :ls_serialno, SYSDATE, :gs_user_id ); 

 					 If SQLCA.SQLCode < 0 Then
			           ii_rc = -1			
			           f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(ssrtppcif_log)")
			           RollBack ;
			           Return 
		          End If						 
					 
				End IF
        NEXT		
End Choose
	

// ssrtppcif Insert ============>> END.....

//-------------------------------------------------------
//마지막으로 영수증 출력........
//-------------------------------------------------------
//Sort ==> Itemcod 순으로
idw_data[2].SetSort('itemcod A')
idw_data[2].Sort()


String ls_lin1, ls_lin2, ls_lin3, ls_empnm
DEC	 ldc_shopCount

// 2019.04.17 VAT 출력을 위한 변수 추가 Modified by Han
string ls_surtaxyn
DEC{2} ld_vat_tot, ld_net_tot

// 2019.04.22 영수증 Printer 출력 방식 변경에 따른 변수 및 처리 추가 Modified by Han

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
	//1. head 출력
	//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//	FOR jj = 1  to 2
//		IF jj = 1 then 
			li_rtn = f_pos_header_vat(is_partner, ls_receipt_type, il_shopcount, 1 )
//		ELSE 
//			li_rtn = f_pos_header(is_partner, 'Z', il_shopcount, 0 )
//		END IF
		IF li_rtn < 0 then
			MessageBox('확인', '영수증 프린터 연결상태를 확인해주세요.')
//			ROLLBACK;
//			PRN_ClosePort()
			FileClose(li_handle)
			ii_rc = -9		
//			return 
		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		il_row = idw_data[2].RowCount()
		For i = 1 To il_row
			is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
			IF is_caller = "save_refund" then
				ls_refund_type = idw_data[2].object.refund_type[i]
				IF IsNULL(ls_refund_type) then ls_refund_type = ''
			ELSE
				ls_refund_type = 'A'
			END IF
			
	      IF ls_refund_type <> '' THEN
			    ls_temp 		= String(i, '000') + ' ' //순번
			    is_itemcod 	= trim(idw_data[2].Object.itemcod[i])
			    is_itemNM 		= trim(idw_data[2].Object.itemNM[i])
			    li_qty 			= idw_data[2].Object.qty[i]
			    
				 IF IsNull(li_qty) OR li_qty  = 0 THEN li_qty = 1
			    
				 Choose Case is_caller
				     case "save_refund"
					       idec_saleamt 	= idw_data[2].object.refund_price[i] + idw_data[2].Object.refund_vat[i]
							 ld_net_tot   += idw_data[2].object.refund_price[i]
							 ld_vat_tot   += idw_data[2].Object.refund_vat  [i]
							 ls_surtaxyn   = idw_data[2].Object.surtaxyn[i]
				     Case "direct", "save_sales"  
					       idec_saleamt 	= idw_data[2].object.sale_amt[i] + idw_data[2].Object.vat[i]
							 ld_net_tot   += idw_data[2].object.sale_amt[i]
							 ld_vat_tot   += idw_data[2].Object.vat     [i]
							 ls_surtaxyn   = idw_data[2].Object.surtaxyn[i]
			    End Choose

			    IF IsNull(is_itemNM) then is_itemNM 	= ''
	
	          ls_temp 	+= LeftA(is_itemnm + space(25), 24)  //아이템
			    ls_temp 	+= Space(1) + RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
			    is_val 	= fs_convert_amt(idec_saleamt,  8)
			    ls_temp 	+= is_val //금액
			    F_POS_PRINT_VAT(' ' + ls_temp, 1)	
	
			    is_regcod =  trim(idw_data[2].Object.regcod[i])
			    //regcode master read
			    select keynum, 		trim(facnum)
		  	      INTO :il_keynum,	:is_facnum
		  	      FROM regcodmst
		 	     where regcod = :is_regcod ;
					
				 // Index Desciption 2008-05-06 hcjung
			    SELECT indexdesc
		  	      INTO :is_facnum
		  	      FROM SHOP_REGIDX
		 	     WHERE regcod = :is_regcod
					 AND shopid = :is_partner;
	
			    IF IsNull(il_keynum) or sqlca.sqlcode < 0	then il_keynum 	= 0
			    IF IsNull(is_facnum) or sqlca.sqlcode < 0	then is_facnum 	= ""
	 			 //2010.08.20 jhchoi 수정.
				 //ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
			    ls_temp =  Space(4) + "(KEY#" + String(il_keynum) + " " + is_facnum + ")" + ' ' + ls_surtaxyn
			    F_POS_PRINT_VAT(' ' + ls_temp, 1)
         END IF
		NEXT

		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		is_val 	= fs_convert_sign(ld_net_tot, 8)
		ls_temp 	= LeftA("Net Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)

		is_val 	= fs_convert_sign(ld_vat_tot, 8)
		ls_temp 	= LeftA("Vat Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)

		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		is_val 	= fs_convert_sign(idec_total, 8)
		ls_temp 	= LeftA("Grand Total" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin2, 1)
		//--------------------------------------------------------
		//결제수단별 입금액
  	 	For i = 1 To 5				//impack 은 별도처리!
				IF i = 1 THEN
					IF ldc_amt0_im <> 0 THEN
						is_val 	= fs_convert_sign(ldc_amt0_im,  8)
						ls_code	= ls_method0_im
						select codenm INTO :ls_codenm from syscod2t
						where grcode = 'B310' 
						  and use_yn = 'Y'
						  AND code = :ls_code ;
						ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
						F_POS_PRINT_VAT(' ' + ls_temp, 1)						
					END IF
				END IF
						
				if ldc_amt0[i] <> 0 then
					is_val 	= fs_convert_sign(ldc_amt0[i],  8)
					ls_code	= ls_method0[i]
					select codenm INTO :ls_codenm from syscod2t
					where grcode = 'B310' 
			 		  and use_yn = 'Y'
					  AND code = :ls_code ;
					ls_temp 	= LeftA(ls_codenm + space(33), 33) + is_val
					F_POS_PRINT_VAT(' ' + ls_temp, 1)
				END IF
		NEXT
		//거스름돈 처리
		is_val 	= fs_convert_sign(idec_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + is_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
//		F_POS_FOOTER(ls_memberid, is_app, gs_user_id)
//		FS_POS_FOOTER2(ls_payid,is_customerid, is_app, gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록
// 2019.04.17  Approval No 출력 변경
		FS_POS_FOOTER3_VAT(ls_payid,is_customerid, is_appseq, gs_user_id, Is_paydt) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록
//	next 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
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
commit ;
Return 
end subroutine

on b1u_dbmgr_dailypayment.create
call super::create
end on

on b1u_dbmgr_dailypayment.destroy
call super::destroy
end on

event constructor;call super::constructor;////
end event

