$PBExportHeader$b5w_reg_hotreqdtl_cancel_sams.srw
$PBExportComments$[ceusee] Hot Bill 취소
forward
global type b5w_reg_hotreqdtl_cancel_sams from w_a_reg_s
end type
type p_cancel from u_p_cancel within b5w_reg_hotreqdtl_cancel_sams
end type
type dw_day from datawindow within b5w_reg_hotreqdtl_cancel_sams
end type
type dw_income from datawindow within b5w_reg_hotreqdtl_cancel_sams
end type
type dw_item from datawindow within b5w_reg_hotreqdtl_cancel_sams
end type
end forward

global type b5w_reg_hotreqdtl_cancel_sams from w_a_reg_s
integer width = 2171
integer height = 1760
event type integer ue_cancel ( )
p_cancel p_cancel
dw_day dw_day
dw_income dw_income
dw_item dw_item
end type
global b5w_reg_hotreqdtl_cancel_sams b5w_reg_hotreqdtl_cancel_sams

type variables
String is_hotflag, is_payid, is_termdt, is_seq_app
boolean ib_save
Integer il_cnt

STring is_emp_grp, &
is_customerid, &
is_caldt , &
is_userid , &
is_pgm_id , is_basecod, is_control, &
is_method[]
Dec{2} idc_total, idc_receive, idc_change

datawindow idw
Long il_get_row
end variables

forward prototypes
public function integer wfi_get_hotbill_use (integer ai_work, string as_payid)
public function integer wfi_get_payid (string as_payid)
end prototypes

event type integer ue_cancel();Integer 	li_return, i,	li_rtn, li_qty, li_chk_cnt1, li_chk_cnt2
Long 		ll_return, 	ll_cnt, ll_log_cnt, ll_log_cnt1
date     ldt_paydt,   ldt_trdt
decimal  ldc_contractseq
String 	ls_errmsg, ls_approvalno, ls_temp , ls_itemNM
string	ls_facnum, ls_code, ls_codenm, ls_customer, ls_seq
string	ls_memberid,	ls_payid, ls_new_appno, ls_paydt, ls_trcod, ls_regtype

Long     ll_cnt2, ll_totcnt_c, ll_acount,ll_totcnt_d, ll_totcnt 
Integer  li_reg_cnt,li_lp, li_cnt
String   ls_descript, ls_concession, ls_print_desc,  ls_item_name, ls_itemnm1, ls_itemnm2
Dec{2}   ldec_payamt, ldec_payamt2 , ldec_totpayamt_c,ldec_totpayamt_D, ldec_totpayamt, ldc_taxamt

//2019.04.04 변수 추가 Modified by Han
String   ls_surtaxyn, ls_payamt_tot, ls_taxamt_tot
Dec{2}   ldc_payamt_tot, ldc_taxamt_tot

//추가 2019.04.08 modified by Han
String   ls_mmyyyy

ll_return = -1
ls_errmsg = space(256)

ls_seq =  dw_detail.Object.seq_app[1]
ls_mmyyyy = string(dw_detail.Object.req_trdt[1],'MM-YYYY') + ']'// 2019.04.08 청구기준일을 mmyyyy로 변환 Modified by Han

SELECT approvalno, to_char(trdt, 'yyyymmdd') 
INTO :ls_approvalno, :ls_paydt 	
FROM receiptmst
 WHERE seq_app = :ls_seq ;
 
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n', String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
   Return -1
END IF
 
IF IsNull(ls_approvalno) then ls_approvalno = ''

//================================================
// 취소 영수증발행
//================================================
ll_cnt = dw_day.Retrieve(ls_approvalno)
IF ll_cnt = 0  then 
		f_msg_sql_err(title, "해당 발행영수증을 찾을 수 없습니다. 확인 바랍니다.")
		RollBack;
		Return -1
End If			

Long	ll_shopcount
DEC{2}	ldc_amt[],		ldc_total, 	ldc_receive, ldc_change
String 	ls_app,			ls_customerid
date		ldt_shop_closedt

ldt_shop_closedt = f_find_shop_closedt(gs_shopid)
FOR i = 1 to 6
	select SUM(payamt+ taxamt) 
   INTO :ldc_amt[i] 
	FROM dailypayment
	WHERE paymethod  = :is_method[i] 
	and approvalno   = :ls_approvalno;                 

	IF IsNull(ldc_amt[i])  then 
		ldc_amt[i] = 0
	ELSE
		ldc_amt[i] = ldc_amt[i] * -1
	END IF
NEXT

dw_income.Object.amt1[1] = ldc_amt[1]
dw_income.Object.amt2[1] = ldc_amt[2]
dw_income.Object.amt3[1] = ldc_amt[3]
dw_income.Object.amt4[1] = ldc_amt[4]
dw_income.Object.amt5[1] = ldc_amt[5]
dw_income.Object.amt6[1] = ldc_amt[6]

//total
SELECT   SUM(A.PAYAMT + A.TAXAMT) 
INTO :ldc_total		 
FROM DAILYPAYMENT A
WHERE A.APPROVALNO = :ls_approvalno 	;

IF IsNull(ldc_total) then ldc_total = 0

dw_income.Object.total[1] = ldc_total  * -1
dw_income.AcceptText()

ldc_total 	=  dw_income.Object.total[1]
ldc_receive =  dw_income.Object.cp_receive[1]
ldc_change 	=  dw_income.Object.cp_change[1]

//	
Select seq_app.nextval		  
Into :ls_app						  
From dual;

If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Sequence Error(seq_app)")
		RollBack;
		Return -1
End If			
//----------------------------------------------------------
//SHOP COUNT
Select shopcount	    
Into :ll_shopcount	  
From partnermst
 WHERE partner = :GS_SHOPID ;
		 
IF IsNull(ll_shopcount) THEN ll_shopcount = 0
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " Update Error(PARTNERMST)")
	RollBack;
	Return -1
End If			
//----------------------------------------------------------
ll_shopcount += 1
ls_customerid 	= dw_cond.Object.payid[1]
ls_payid 		= dw_cond.Object.payid[1]

select memberid 
INTO :ls_memberid 
from customerm 
where customerid = :ls_customerid ;

IF IsNull(ls_memberid) then ls_memberid = ''

Select seq_receipt.nextval		  
Into :ls_new_appno						  
From dual;

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n', String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	rollback ;
   Return -1
END IF

insert into RECEIPTMST
				( approvalno,	
				shopcount,			receipttype,		shopid,			posno,
				workdt,				trdt,				   memberid,		operator,		total,
				cash,					change, 				seq_app, 		customerid,		prt_yn )
	values ( :ls_new_appno, 	
				:ll_shopcount,		'200',				:GS_SHOPID, 	NULL,
				sysdate,	   		:ldt_shop_closedt,:ls_memberid,	:gs_user_id,	:ldc_total,
			   :ldc_receive, 		:ldc_change,		:ls_app,			:ls_customerid, 'Y' )	 ;
				   
//저장 실패 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " Insert Error(RECEIPTMST)")
	RollBack;
	Return -1
End If			
//----------------------------------------------------------
//ShopCount ADD 1 ==> Update
Update partnermst
Set shopcount 	= :ll_shopcount
Where partner  = :GS_SHOPID ;

//Update 실패 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " Update  Error(PARTNERMST)")
	RollBack;
	Return -1
End If	
//===================================================
//b. dailypayment Insert
// regcod search
//====================================================
String 		ls_itemcod, 	ls_regcod, 	ls_paymethod, 	ls_basecod, ls_dctype
DEC{2}		ldc_saleamt
Long			ll_paycnt, 	ll_payseq,		jj

//customerm Search
select memberid    , basecod
  INTO :ls_memberid, :ls_basecod
  FROM customerm
 WHERE customerid = :ls_customerid ;
		 
IF IsNull(ls_memberid)	THEN ls_memberid 	= ''
IF IsNull(ls_basecod)	THEN ls_basecod 	= ""

FOR i = 1 to dw_day.rowCount()
		Select seq_dailypayment.nextval		  
		Into :ll_payseq  
		From dual;

		IF sqlca.sqlcode < 0 THEN
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
			RollBack;
			Return -1 
		END IF

	
		ls_itemcod 		= trim(dw_day.object.itemcod[i])
		ls_regcod 		= trim(dw_day.object.regcod[i])
		ls_paymethod	= trim(dw_day.object.paymethod[i])
		ll_paycnt      = dw_day.object.paycnt[i]
		ldc_saleamt		= dw_day.object.payamt[i] * -1
		ldc_taxamt = dw_day.object.taxamt[i] * -1
		ldt_trdt =  date(dw_day.object.trdt[i])
		
		
		//품목의 거래유형 DCTYPE도 Cancel시에 품목별로 처리하도록 요청. 박자연씨 요청(2011.11.14)
		//kem modify 2011.11.15
		SELECT Count(*) INTO :li_chk_cnt1 FROM DEPOSIT_REFUND
		 WHERE OUT_ITEM =  :ls_itemcod ;
		IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt1) THEN li_chk_cnt1 = 0
		
		SELECT Count(*) INTO :li_chk_cnt2 FROM PREPAY_REFUND
		 WHERE OUT_ITEM =  :ls_itemcod ;
		IF sqlca.sqlcode <> 0  OR IsNull(li_chk_cnt2) THEN li_chk_cnt2 = 0
		
		IF ( li_chk_cnt1 + li_chk_cnt2 ) > 0 THEN
			ls_dctype = 'C'
		else
			ls_dctype = 'D'
		end if
		
//----------------------------------------------------------
		insert into dailypayment
				( payseq,		
              paydt,             shopid,        operator,      customerid,
              itemcod,           paymethod,     regcod,        payamt,        basecod,
              paycnt,            payid,         remark,        trdt,          mark,
              auto_chk,          dctype,        approvalno,    crtdt,			updtdt,		
              updt_user,         manual_yn,     PGM_ID, taxamt)
		values 
			   ( :ll_payseq,
              :ldt_shop_closedt, :GS_SHOPID,    :gs_user_id,   :ls_customerid,
              :ls_itemcod,			:ls_paymethod,	:ls_regcod,    :ldc_saleamt,	:ls_basecod,
              :ll_paycnt,        :ls_payid,     NULL,          :ldt_trdt,       NULL,
              NULL,					:ls_dctype,    :ls_new_appno,	sysdate,       sysdate,
              :gs_user_id,		   'N',				'HOTCAN' , :ldc_taxamt)	 ;
				   
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title,  SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
			RollBack;
			Return -1
		End If		

		select count(*)  , max(d.contractseq)
		INTO :ll_log_cnt , :ldc_contractseq
		FROM   DEPOSIT_LOG A, DEPOSIT_REFUND B,DAILYPAYMENT C , HOTCONTRACT D
		WHERE  A.PAYID       = :ls_customerid      // '7062311' -- 
		AND    A.ITEMCOD     = B.IN_ITEM
		and    A.pay_type    = 'I'                 // IN_ITEM
		AND    B.OUT_ITEM    = C.ITEMCOD
		and    C.itemcod     = :ls_itemcod
		AND    A.payid       = C.customerid
		AND    A.payid       = D.payid 
		AND    to_char(D.hotdt, 'yyyymmdd') = to_char(sysdate, 'yyyymmdd')
		and    C.payseq      = :ll_payseq
		AND    A.contractseq = D.contractseq;		

		if ll_log_cnt > 0 then  // IN-OUT이 일치하면 insert(그 때의 itemcod)
			insert into DEPOSIT_LOG
				( payseq      , pay_type        , paydt              , shopid        , operator     ,
				  customerid  , contractseq     , itemcod            , paymethod     , regcod       ,
				  payamt      , basecod         , paycnt             , payid         , remark       ,
				  trdt        , mark            , auto_chk           , approvalno    , crtdt        ,
				  crt_user    , dctype          , manual_yn          , pgm_id        , remark2      , orderno  )
			values 
				( :ll_payseq  , 'O'             , :ldt_shop_closedt  , :gs_shopid    , :gs_user_id  , 
				  :ls_payid   , :ldc_contractseq, :ls_itemcod        , :ls_paymethod , :ls_regcod   ,
				  :ldc_saleamt + :ldc_taxamt , :ls_basecod     ,	1                , :ls_payid     , null         ,
				  sysdate     , null            , null               , :ls_new_appno , sysdate      ,
				  :gs_user_id , :ls_dctype      , 'N'                , 'HOTCAN'      , null         , null     );
		   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(DEPOSIT_LOG)")
				RollBack;
				Return -1
			End If	
		end if
		
       SELECT COUNT(*)
        INTO :ll_log_cnt1
        FROM   PREPAY_REFUND A,DAILYPAYMENT B
        WHERE  B.PAYID       = :ls_customerid     // '7062311' -- 
        AND    A.OUT_ITEM    = B.ITEMCOD
        and    B.itemcod     = :ls_itemcod        // 049SSRT, 048SSRT
        and    B.payseq      = :ll_payseq         // 13077633
        AND    to_char(B.paydt, 'yyyymmdd') = to_char(sysdate, 'yyyymmdd'); // '20120709'


		if ll_log_cnt1 > 0 then  // IN-OUT이 일치하면 insert(그 때의 itemcod)
          SELECT I.TRCOD, R.REGTYPE
          INTO :ls_trcod, :ls_regtype
          FROM ITEMMST I, REGCODMST R
          WHERE I.ITEMCOD  = :ls_itemcod
          AND   I.REGCOD   = R.REGCOD;

		
			insert into PREPAYDET
				( payid          , seq                  , rectype     , workdt            , trdt         ,
				  trcod          , tramt                , manual_yn   , note              , itemcod      ,
				  refno          , crtdt                , crt_user    , updtdt            , updt_user    ,
				  pgm_id         , regtype      )
			values 
				( :ls_customerid , seq_prepaydet.nextval, 'O'         , :ldt_shop_closedt , sysdate      , 
				  :ls_trcod      , :ldc_saleamt +  :ldc_taxamt        , 'N'         , null              , :ls_itemcod  ,
				  :ll_payseq     , sysdate              ,	:gs_shopid  , null              , null         ,
				  'HOTCAN'      , :ls_regtype  );
		   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(PREPAYDET)")
				RollBack;
				Return -1
			End If	
		end if
		

//-------------------------------------------------------------
NEXT

SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
   Return -1
	
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
   Return -1
End If 


//-------------------------------------------------------
//마지막으로 영수증 출력........
//-------------------------------------------------------
String ls_lin1, ls_lin2, ls_lin3, ls_empnm, ls_val

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

Long	ll_keynum= 0

dw_item.Retrieve(ls_approvalno)
dw_item.SetSort('itemcod A')
dw_item.Sort()

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// 영수증 한장만 출력하도록 변경 2007-08-13 hcjung
//	FOR jj = 1  to 2
//		IF jj = 1 then 	
			li_rtn = f_pos_header_vat(GS_SHOPID, 'B', ll_shopcount, 1 )
//		ELSE 
//			li_rtn = f_pos_header(GS_SHOPID, 'Z', ll_shopcount, 0 )
//		END IF
		IF li_rtn < 0 then
			MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
			FileClose(li_handle)
//			PRN_ClosePort()
/*			RollBack; */ // 2012.7.3 컴파일시 다시 풀 것
/*			return -9 */
		END IF
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		//2. Item List 출력
		//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		ll_cnt = dw_item.RowCount()
		li_chk_cnt1 = 0
		ldc_total = 0
		
		For i = 1 To ll_cnt
			
			ls_dctype = Trim(dw_item.Object.dctype[i])
			
			If ls_dctype = 'D' Then /* 2014.08.29 김선주 add. Refund부분은 따로 출력하기 위해 */			
			
			ls_temp 			= String(i, '000') + ' ' //순번	
			ls_itemcod 		= trim(dw_item.Object.itemcod[i])
			ls_itemNM 		= trim(dw_item.Object.itemNM[i])
			li_qty 			= dw_item.Object.paycnt[i]
//			ldc_saleamt 	= dw_item.object.payamt[i] * -1
//			ldc_total     += ldc_saleamt
// 2019.04.08 Item별 금액을 net + vat로 변경 Modified by Han
			ldc_saleamt 	= (dw_item.object.payamt[i] + dw_item.object.taxamt[i]) * -1
			ldc_total     += ldc_saleamt


			// 변수 추가된 값에 저장 2019.04.04 Modified by Han
			ldc_payamt_tot += dw_item.object.payamt[i]
			ldc_taxamt_tot += dw_item.Object.taxamt[i] * -1
			ls_surtaxyn     = dw_item.Object.surtaxyn[i]


         iF IsNull(ls_itemnm) 		then ls_itemnm = ''
			
//			ls_temp 			+= LeftA(ls_itemnm + space(25), 24) + ' '   //아이템
// 2019.04.03 아이템 앞에 청구기준일 출력 추가 Modified by Han
			ls_temp 			+= LeftA(ls_mmyyyy + ' ' + ls_itemnm + space(25), 24) + ' '   //아이템
			ls_temp 			+=  RightA(space(4) + String(li_qty), 4) + space(1)   	  //수량
			ls_val 			= fs_convert_amt(ldc_saleamt,  8)
			ls_temp 			+= ls_val //금액
			F_POS_PRINT_VAT(' ' + ls_temp, 1)	
	
			ls_regcod =  trim(dw_item.Object.regcod[i])
			ll_keynum =  dw_item.Object.keynum[i]
			ls_facnum =  trim(dw_item.Object.facnum[i])
			
			// Index Desciption 2010-08-20 jhchoi
			SELECT indexdesc
		  	INTO	 :ls_facnum
		  	FROM	 SHOP_REGIDX
		 	WHERE	 regcod = :ls_regcod
			AND	 shopid = :GS_SHOPID;				
			
         iF IsNull(ll_keynum) 		then ll_keynum = 0
         iF IsNull(ls_facnum) 		then ls_facnum = ''
			
			//2010.08.20 jhchoi 수정.
			//ls_temp =  Space(7) + "("+ ls_facnum + '-KEY#' + String(ll_keynum) + ")"
//			ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")" 2019.04.04 부가세 표시 추가 Modified by Han
			ls_temp =  Space(4) + "(KEY#" + String(ll_keynum) + " " + ls_facnum + ")" + " " + ls_surtaxyn

			
			
			F_POS_PRINT_VAT(' ' + ls_temp, 1)
			
		  End if
		NEXT
		//2. Item List 출력 ----- end
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
		ls_val 	= fs_convert_sign(ldc_total, 8)
		ls_temp 	= LeftA("Total" + space(33), 33) + ls_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin2, 1)
		//--------------------------------------------------------
		
	/************************************************************************************/
	/* From. 2014.08.29 김선주  개별 영수증에도, REFUND내역이 따로 찍히도록 로직 추가   */ 
	/************************************************************************************/
	
	/***********************/
	/*환불 영수증 처리     */
	/***********************/
	ll_cnt = 0;
	li_chk_cnt1 = 0; 
	ldec_totpayamt_c = 0;
	ldec_totpayamt = 0;	

	integer li_refund_cnt
	
	
	/* Refund 항목이 있는지 체크 */
  Select Nvl(Count(A.payseq),0) INTO :li_refund_cnt  
   From DAILYPAYMENT A, REGCODMST B 
  Where ( A.REGCOD                        = B.REGCOD )
    AND ( A.SHOPID                        = :gs_shopid        )
    AND ( A.PAYDT                         = TO_DATE(:ls_paydt, 'YYYYMMDD') )    
    AND ( A.DCTYPE                        = 'C'    )          
  /* AND ( B.REGTYPE                      = :ls_regtype         ) */
    AND ( A.CUSTOMERID                    = :ls_customerid ) ;
		

If li_refund_cnt > 0 Then /*항목이 있을 때만 프린트 합니다 */
	
	f_printpos_VAT("Refund ********************")	
	
	FOR li_lp = 1 to dw_item.RowCount()	
				
		ls_dctype 	= trim(dw_item.Object.dctype[li_lp]) 
		
		If ls_dctype ='c' Or ls_dctype = 'C' Then 			
									
			ldec_payamt	=  dw_item.Object.payamt[li_lp]
			
			/*****출력***************/
			IF ldec_payamt <> 0 THEN			
	
				ll_acount 			+= 1		
				ls_temp 				= String(ll_acount, '000') 				+ ' '	//순번				
				ls_itemcod 			= trim(dw_item.Object.itemcod[li_lp])
				ls_itemnm 			= trim(dw_item.Object.itemnm[li_lp])
				ls_regcod 			= trim(dw_item.Object.regcod[li_lp])					
				ldec_payamt			=  dw_item.Object.payamt[li_lp] * -1	        //금액
				ldec_totpayamt_c 	+= ldec_payamt 
				ls_temp 				+= LeftA(ls_itemnm + space(24), 24) +  ' '   //아이템
				li_cnt 				=  1
				ll_totcnt_c       += li_cnt
				ls_temp 				+= RightA(Space(4) + String(li_cnt), 4) + ' ' //수량
				ls_val 				=  fs_convert_amt(ldec_payamt,  8)
				ls_temp 				+= ls_val //금액			
									
				f_printpos_VAT(' ' + ls_temp)				
				
				/* regcode master read */
				SELECT keynum, 	facnum,	trim(regdesc),    concession
				  INTO :ll_keynum, :ls_facnum, 	:ls_descript,		:ls_concession
				  FROM regcodmst
				 WHERE regcod = :ls_regcod;						

				SELECT Trim(indexdesc)
				INTO	 :ls_facnum
				FROM	 SHOP_REGIDX
				WHERE	 regcod = :ls_regcod
				AND	 shopid = :gs_shopid;

				IF IsNull(ll_keynum) 		then ll_keynum 		= 0 ;
				
				ls_surtaxyn     = dw_item.Object.surtaxyn[li_lp] //2019.04.08 부가세 여부 출력 추가 Modified by Han
				ls_print_desc = "(Key#" + String(ll_keynum) + " " + ls_facnum + ")" + ' ' + ls_surtaxyn
					
				ls_temp =  Space(4) + LeftA(ls_print_desc + space(24), 24)			
				
				f_printpos_VAT(' ' + ls_temp)			
			END IF	
		 END IF
		NEXT
					
		f_printpos_VAT(' ' + ls_lin1)			
		ls_temp =  	LeftA("Refund Total" + space(28), 28) + &
						RightA(Space(3) + String(ll_totcnt_C), 3) + ' ' + &
						fs_convert_sign(ldec_totpayamt_c, 9)
		f_printpos_VAT(' ' + ls_temp)

// Net, VAT Summary 출력 추가 Grand Total에 Vat Sum 추가 2019.04.04 Modified by Han
		ls_temp =  	LeftA("Net" + space(31), 31) + &
						' ' + &
						fs_convert_sign(ldc_payamt_tot, 9)
		f_printpos_VAT(' ' + ls_temp)

		ls_temp =  	LeftA("VAT" + space(31), 31) + &
						' ' + &
						fs_convert_sign(ldc_taxamt_tot, 9)
		f_printpos_VAT(' ' + ls_temp)
		

		f_printpos_VAT(' ' + ls_lin2)
			
		ll_totcnt = ll_totcnt_c + ll_totcnt_D

//  Grand Total에 Vat Sum 추가 2019.04.04 Modified by Han
//		ldec_totpayamt = ldec_totpayamt_c + ldc_total 
		ldec_totpayamt = ldec_totpayamt_c + ldc_total + ldc_taxamt_tot
				
		ls_val  = fs_convert_sign(ldec_totpayamt, 8)		
		ls_temp =  	LeftA("Grand Total" + space(33), 33) + ls_val
		
		f_printpos_VAT(' ' + ls_temp)
		f_printpos_VAT(' ' + ls_lin2) 
End if
	/*********************************/ 
	/*환불 영수증 END                */
	/*********************************/	
		
		
	/***********************************/	
	/*결제수단별 입금액                */
	/***********************************/
  	 	For i = 1 To 6
				if ldc_amt[i] <> 0 then
					ls_val 	= fs_convert_sign(ldc_amt[i],  8)
					ls_code	= is_method[i]
					
					select codenm 
					INTO :ls_codenm 
					from syscod2t
					where grcode = 'B310' 
			 		  and use_yn = 'Y'
					  AND code = :ls_code ;
					  
					ls_temp 	= LeftA(ls_codenm + space(33), 33) + ls_val
					F_POS_PRINT_VAT(' ' + ls_temp, 1)
				END IF
		NEXT
		//거스름돈 처리
		ls_val 	= fs_convert_sign(ldc_change,  8)
		ls_temp 	= LeftA("Changed" + space(33), 33) + ls_val
		F_POS_PRINT_VAT(' ' + ls_temp, 1)
		F_POS_PRINT_VAT(' ' + ls_lin1, 1)
//		F_POS_FOOTER(ls_memberid, ls_seq, gs_user_id) original
//		Fs_POS_FOOTER2(ls_payid,ls_customerid,ls_new_appno,gs_user_id) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 		
//2019.04.08 Pay Date 추가에 따른 수정 Modified by Han
		Fs_POS_FOOTER3_VAT(ls_payid,ls_customerid,ls_new_appno,gs_user_id,ls_paydt) // modified by hcjung 2007-08-13 멤버ID 대신 PAYID 출력하도록 		

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

//-------------------------------------- end....
f_msg_info(3000, Title, "HotBilling Cancel")
For i =1 To dw_detail.RowCount()
	 dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
Next

Commit ;

ib_save = true

/*
//deposit_log 관리
INSERT INTO DEPOSIT_LOG
	( PAYSEQ, PAY_TYPE, PAYDT, SHOPID, OPERATOR,
	  CUSTOMERID, CONTRACTSEQ, ITEMCOD, PAYMETHOD, REGCOD,
	  PAYAMT, BASECOD, PAYCNT, PAYID, REMARK,
	  TRDT, MARK, AUTO_CHK, APPROVALNO, CRTDT,
	  CRT_USER, DCTYPE, MANUAL_YN, PGM_ID, REMARK2,
	  ORDERNO )
SELECT PAYSEQ, 'O', PAYDT, SHOPID, OPERATOR,
		 CUSTOMERID, nvl(CONTRACTSEQ,0), ITEMCOD, PAYMETHOD, REGCOD,
		 PAYAMT * -1, BASECOD, PAYCNT, PAYID, REMARK,
		 TRDT, MARK, AUTO_CHK, APPROVALNO, SYSDATE,
		 :gs_user_id, DCTYPE, MANUAL_YN, 'HOTCAN', REMARK2,
		 ORDERNO
FROM   DEPOSIT_LOG
WHERE  PAYID      = :ls_payid
AND    PAYDT      = TO_DATE(:ls_paydt, 'YYYYMMDD')
AND    PGM_ID     = 'HOTBILL';

//저장 실패 
If SQLCA.SQLCode < 0 Then
	RollBack;
ELSE
	COMMIT;
End If		

*/


TriggerEvent("ue_reset")  //리셋한다.

Return 0
end event

public function integer wfi_get_hotbill_use (integer ai_work, string as_payid);Return 0
end function

public function integer wfi_get_payid (string as_payid);String ls_payid, ls_paynm

ls_payid = as_payid

If IsNull(ls_payid) Then ls_payid = " "

Select Customernm
  Into :ls_paynm
  From Customerm
 Where customerid = :ls_payid;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay id(wfi_get_payid)")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	MessageBox(Title, "납입번호가 없습니다.")
	dw_cond.Object.payid[1] = ""
	dw_cond.Object.paynm[1] = ""
	Return -1
End If

dw_cond.object.paynm[1] = ls_paynm

Return 0

end function

on b5w_reg_hotreqdtl_cancel_sams.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
this.dw_day=create dw_day
this.dw_income=create dw_income
this.dw_item=create dw_item
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
this.Control[iCurrent+2]=this.dw_day
this.Control[iCurrent+3]=this.dw_income
this.Control[iCurrent+4]=this.dw_item
end on

on b5w_reg_hotreqdtl_cancel_sams.destroy
call super::destroy
destroy(this.p_cancel)
destroy(this.dw_day)
destroy(this.dw_income)
destroy(this.dw_item)
end on

event open;call super::open;String ls_format, ls_ref_desc, ls_tmp, ls_useyn

ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_detail.object.tramt.Format 	= "#,##0.0"
	dw_detail.object.adjamt.Format 	= "#,##0.0"
	dw_detail.object.preamt.Format 	= "#,##0.0"	
	dw_detail.object.balance.Format 	= "#,##0.0"	
	dw_detail.object.totamt.Format 	= "#,##0.0"	
	dw_detail.object.sum_amt.Format 	= "#,##0.0"	
	dw_detail.object.taxamt.Format 	= "#,##0.0"
ElseIf ls_format = "2" Then
	dw_detail.object.tramt.Format 	= "#,##0.00"
	dw_detail.object.adjamt.Format 	= "#,##0.00"
	dw_detail.object.preamt.Format 	= "#,##0.00"	
	dw_detail.object.balance.Format 	= "#,##0.00"	
	dw_detail.object.totamt.Format 	= "#,##0.00"	
	dw_detail.object.sum_amt.Format 	= "#,##0.00"	
	dw_detail.object.taxamt.Format 	=  "#,##0.00"	
Else
	dw_detail.object.tramt.Format 	= "#,##0"
	dw_detail.object.adjamt.Format 	= "#,##0"
	dw_detail.object.preamt.Format 	= "#,##0"	
	dw_detail.object.balance.Format 	= "#,##0"	
	dw_detail.object.totamt.Format 	= "#,##0"	
	dw_detail.object.sum_amt.Format 	= "#,##0"
	dw_detail.object.taxamt.Format 	= "#,##0"
End If
ib_save = False





end event

event resize;call super::resize;If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space

Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space

End If
end event

event ue_ok;call super::ue_ok;Long ll_row, il_preamt
DEC{2} ldc_preamt,  ldc_saleamt
is_payid = dw_cond.object.payid[1]

ll_row = dw_detail.Retrieve(is_payid)
If ll_row = 0 Then
	f_msg_info(1000, title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return
End If

/*전월미납액*/
SELECT nvl(SUM(tramt ),0)  + nvl(SUM(taxamt ),0)  INTO :ldc_preamt
FROM     hotreqdtl a, billinginfo b
WHERE  a.payid =  :is_payid
AND      a.payid = b.customerid
AND   ( trdt < (select add_months(reqdt,1) from reqconf where chargedt = b.bilcycle)
           or   TRCOD IS NULL);

dw_detail.object.preamt[1] = ldc_preamt


Return
end event

event ue_reset;call super::ue_reset;p_cancel.TriggerEvent("ue_disable")

dw_income.Reset()
dw_income.InsertRow(0)

dw_day.dataobject = 'b5dw_reg_hotbill_cancel_dailypayment'
dw_day.SetTransObject(sqlca)


//초기화
Integer li_ret, li_mod
String ls_paymethod, ls_ref_desc
date ldt_saledt
String ls_temp
//PayMethod 101, 102, 103, 104, 105, 107
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)

If ls_temp 		= "" Then Return 0
fi_cut_string(ls_temp, ";", is_method[])

dw_income.Object.memberid[1] = ''
dw_income.Object.customerid[1] = ''
dw_income.Object.customernm[1] = ''
dw_income.Object.operator[1] = ''

dw_income.Object.method1[1] = is_method[1]
dw_income.Object.method2[1] = is_method[2]
dw_income.Object.method3[1] = is_method[3]
dw_income.Object.method4[1] = is_method[4]
dw_income.Object.method5[1] = is_method[5]
dw_income.Object.method6[1] = is_method[6]
dw_income.Object.amt1[1] = 0
dw_income.Object.amt2[1] = 0
dw_income.Object.amt3[1] = 0
dw_income.Object.amt4[1] = 0
dw_income.Object.amt5[1] = 0
dw_income.Object.amt6[1] = 0
dw_income.Object.total[1]  = 0
return 0

end event

type dw_cond from w_a_reg_s`dw_cond within b5w_reg_hotreqdtl_cancel_sams
integer y = 80
integer width = 1554
integer height = 160
string dataobject = "b5dw_cnd_reg_hotbill_cancel"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst_hotbill"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			This.Object.payid[1] = iu_cust_help.is_data2[1]
			This.Object.paynm[1] = iu_cust_help.is_data2[2]
			//cb_input.Enabled = True
		End If

End Choose

AcceptText()

Return 0 
		
end event

event dw_cond::itemchanged;call super::itemchanged;//If dwo.name = "payid" Then
//	This.object.payid_1[row] = data
//End If
//
//Return 0

String ls_payid
int    li_rc

Choose Case Dwo.Name
	Case "payid"
		ls_payid = dw_cond.object.payid[1]
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid(ls_payid)

		If li_rc < 0 Then
			dw_cond.Object.payid[1] = ""
			dw_cond.Object.paynm[1] = ""
			dw_cond.SetColumn("payid")
			return 2
		End IF
End Choose

Return 0
end event

type p_ok from w_a_reg_s`p_ok within b5w_reg_hotreqdtl_cancel_sams
integer x = 1746
end type

type p_close from w_a_reg_s`p_close within b5w_reg_hotreqdtl_cancel_sams
integer x = 1746
integer y = 164
boolean originalsize = false
end type

type gb_cond from w_a_reg_s`gb_cond within b5w_reg_hotreqdtl_cancel_sams
integer width = 1637
integer height = 272
end type

type dw_detail from w_a_reg_s`dw_detail within b5w_reg_hotreqdtl_cancel_sams
integer y = 292
integer width = 2066
integer height = 1204
string dataobject = "b5dw_reg_hotbill_cancel_sams"
end type

event dw_detail::retrieveend;call super::retrieveend;String ls_hotbillflag
If rowcount > 0 Then
  
  ls_hotbillflag = Trim(dw_detail.object.hotbillflag[1])
  If ls_hotbillflag = "S" OR ls_hotbillflag = "H" Then  //처리할 수있다.
	 p_cancel.TriggerEvent("ue_enable")
  Else  //취소할 수 없다.
	p_cancel.TriggerEvent("ue_disable")
	End if
End If

Return 0
end event

type p_delete from w_a_reg_s`p_delete within b5w_reg_hotreqdtl_cancel_sams
boolean visible = false
end type

type p_insert from w_a_reg_s`p_insert within b5w_reg_hotreqdtl_cancel_sams
boolean visible = false
end type

type p_save from w_a_reg_s`p_save within b5w_reg_hotreqdtl_cancel_sams
boolean visible = false
integer x = 46
integer y = 1528
end type

type p_reset from w_a_reg_s`p_reset within b5w_reg_hotreqdtl_cancel_sams
integer x = 379
integer y = 1528
end type

type p_cancel from u_p_cancel within b5w_reg_hotreqdtl_cancel_sams
integer x = 41
integer y = 1528
integer height = 92
boolean bringtotop = true
end type

type dw_day from datawindow within b5w_reg_hotreqdtl_cancel_sams
boolean visible = false
integer x = 713
integer y = 836
integer width = 645
integer height = 772
integer taborder = 12
boolean bringtotop = true
boolean enabled = false
string title = "none"
string dataobject = "b5dw_reg_hotbill_cancel_dailypayment"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

type dw_income from datawindow within b5w_reg_hotreqdtl_cancel_sams
boolean visible = false
integer x = 987
integer y = 1512
integer width = 192
integer height = 100
integer taborder = 22
boolean bringtotop = true
string title = "none"
string dataobject = "ssrt_cnd_adsale_sams1"
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
this.InsertRow(0)
////초기화
//Integer li_ret, li_mod
//String ls_paymethod, ls_ref_desc
//date ldt_saledt
//String ls_temp
////PayMethod 101, 102, 103, 104, 105
//ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
//
//If ls_temp 		= "" Then Return
//fi_cut_string(ls_temp, ";", is_method[])
//
//
//
//dw_cond.Object.memberid[1] = ''
//dw_cond.Object.customerid[1] = ''
//dw_cond.Object.customernm[1] = ''
//dw_cond.Object.operator[1] = ''
//
//dw_detail.Reset()
//dw_sale.Reset()
//dw_detail2.Reset()
////dw_detail2.InsertRow(0)
//dw_cond.Object.method1[1] = is_method[1]
//dw_cond.Object.method2[1] = is_method[2]
//dw_cond.Object.method3[1] = is_method[3]
//dw_cond.Object.method4[1] = is_method[4]
//dw_cond.Object.method5[1] = is_method[5]
//dw_cond.Object.amt1[1] = 0
//dw_cond.Object.amt2[1] = 0
//dw_cond.Object.amt3[1] = 0
//dw_cond.Object.amt4[1] = 0
//dw_cond.Object.amt5[1] = 0
//dw_cond.Object.total[1] = 0

end event

type dw_item from datawindow within b5w_reg_hotreqdtl_cancel_sams
boolean visible = false
integer x = 270
integer y = 972
integer width = 1225
integer height = 480
integer taborder = 22
boolean bringtotop = true
boolean enabled = false
string title = "none"
string dataobject = "b5dw_reg_hotbill_cancel_itemcod"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;this.SetTransObject(sqlca)
end event

