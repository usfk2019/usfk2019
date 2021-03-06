﻿$PBExportHeader$ssrt_prt_report_daily_new_vat.srw
$PBExportComments$[1hera]ssrt Daily Report
forward
global type ssrt_prt_report_daily_new_vat from w_a_print
end type
end forward

global type ssrt_prt_report_daily_new_vat from w_a_print
integer width = 3323
integer height = 1992
end type
global ssrt_prt_report_daily_new_vat ssrt_prt_report_daily_new_vat

type variables
String 	is_format, is_fm1, is_fm2, is_fm3, &
			is_cutoffdt, is_fm_vat1, is_fm_vat2, is_fm_vat3
date		idt_cutoffdt
end variables

forward prototypes
public subroutine wf_cut (decimal wfdc_amount)
public subroutine wf_cut_total (decimal wfdc_amount)
end prototypes

public subroutine wf_cut (decimal wfdc_amount);DEC{2} ldc_payamt
String ls_sign

ldc_payamt 	= wfdc_amount
is_fm1 		= ''
is_fm2 		= ''
is_fm3 		= ''
		
is_format			= String(ldc_payamt)
IF LeftA(is_format, 1) = '-' Then
	ls_sign = '-'
	is_format = RightA(is_format, LenA(is_format) - 1)
ELSE
	ls_sign = '+'
END IF
is_fm3		 		= RightA(is_format, 2)
is_format 			= LeftA(is_format, LenA(is_format) - 3)
		
IF LenA(is_format) > 3 then
	is_fm2 			= RightA(is_format, 3)
	is_format 		=  LeftA(is_format, LenA(is_format) - 3)
ELSE
	is_fm2 			= is_format
	is_format 		= ''
END IF
is_fm1				= is_format

choose case ls_sign
	case '-'
		IF is_fm1 <> ''THEN
			is_fm1 =  '-' + is_fm1
			RETURN
		END IF
		IF is_fm2 <> '' THEN
			is_fm2 =  '-' + is_fm2
			RETURN
		END IF
	case '+'
		IF is_fm2 = '0' then is_fm2 = ''
end choose

RETURN

end subroutine

public subroutine wf_cut_total (decimal wfdc_amount);DEC{2} ldc_totalamt
String ls_sign

ldc_totalamt 	= wfdc_amount
is_fm_vat1 		= ''
is_fm_vat2 		= ''
is_fm_vat3 		= ''
		
is_format			= String(ldc_totalamt)
IF LeftA(is_format, 1) = '-' Then
	ls_sign = '-'
	is_format = RightA(is_format, LenA(is_format) - 1)
ELSE
	ls_sign = '+'
END IF
is_fm_vat3		 		= RightA(is_format, 2)
is_format 			= LeftA(is_format, LenA(is_format) - 3)
		
IF LenA(is_format) > 3 then
	is_fm_vat2 			= RightA(is_format, 3)
	is_format 		=  LeftA(is_format, LenA(is_format) - 3)
ELSE
	is_fm_vat2 			= is_format
	is_format 		= ''
END IF
is_fm_vat1				= is_format

choose case ls_sign
	case '-'
		IF is_fm_vat1 <> ''THEN
			is_fm_vat1 =  '-' + is_fm_vat1
			RETURN
		END IF
		IF is_fm_vat2 <> '' THEN
			is_fm_vat2 =  '-' + is_fm_vat2
			RETURN
		END IF
	case '+'
		IF is_fm_vat2 = '0' then is_fm_vat2 = ''
end choose

RETURN

end subroutine

on ssrt_prt_report_daily_new_vat.create
call super::create
end on

on ssrt_prt_report_daily_new_vat.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: ssrt_prt_report_daily
	Desc.	: 보고서
	Ver.	: 1.0
	Date	: 2006.05.08
	Programer : K.B.CHO(1hera)
-------------------------------------------------------------------------*/
ii_orientation = 2
ib_margin 		= False
dec{2} 			ldc_impact10[], ldc_impact90[], 	ldc_daily[], ldc_total[]

f_center_window(THIS)

dw_cond.Hide()
gb_cond.Hide()

String 	ls_partner, 	ls_saledt, 		ls_member, 		ls_approval, &
			ls_paymethod, 	ls_descript, &
			ls_ref_desc, 	ls_temp, 		ls_result[], &
			ls_regcod, 		ls_shopcode, 	ls_shoptype
Long		ll_seq, 			ll_total
String 	ls_basecod, 	ls_area
Long		ll_row, 			ll_row2, 		ll_center,	ll_cnt
dec{2}	ldc_payamt, 	ldec_daily, 	ldec_sum, &
			ldc_in1, 		ldc_in2,			Idc_rowcnt
dec{2}      ldc_taxamt, ldc_invat2, ldc_totalamt


String	ls_facnum,		ls_desc,			ls_indexdesc,		ls_shop_key
Long		ll,				ll_keynum
String 	ls_method[],	ls_regtype
date 		ldt_saledt
//------------------------------------------------------------------
ldec_daily 	= 0.0
ldec_sum 	= 0.0
ldc_in2		= 0
ldt_saledt 	= iu_cust_msg.id_data[1]
ls_partner 	= iu_cust_msg.is_data[1]
ls_saledt  	= iu_cust_msg.is_data[2]
ls_member  	= iu_cust_msg.is_data[3]
ls_shoptype = iu_cust_msg.is_data[4] + '%'
ls_regtype  = iu_cust_msg.is_data[4]
Idc_rowcnt  = iu_cust_msg.ic_data[1]

select max(cutoff_dt) + 1
  INTO :idt_cutoffdt
  from cutoff 
 where to_char(cutoff_dt, 'yyyymmdd') < :ls_saledt ;
//
is_cutoffdt =  String(idt_cutoffdt, 'yyyymmdd')
dw_list.Reset()

//2010.08.19 jhchoi 수정. areacod 부분에 SHOP_KEY 테이블 뒤져서 뿌린다.
////area code조회
//select trim(basecod)  INTO :ls_basecod  FROM PARTNERMST
// WHERE PARTNER = :ls_partner ;
//
//SELECT trim(AREACODE)   INTO :ls_area FROM BASEMST
// WHERE BASECOD = :ls_basecod ;
SELECT Trim(KEYNUM) INTO :ls_shop_key
FROM   SHOP_KEY
WHERE  SHOPID = :ls_partner
AND    REGTYPE = :ls_regtype;

If IsNull(ls_shop_key) Then ls_shop_key = ""
//2010.08.19 jhchoi 수정 End

//--------------------------------------------------------------
//1. HEAD 부분 & CASH 부분 --> 수기로 하는 부분.
//--------------------------------------------------------------
//1. PayMethod ==> 현금101, 102, 103, 104, 105, 107
ls_temp 			= fs_get_control("C1", "A200", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])
  SELECT Count(*) INTO :ll_cnt
    FROM SHOP_REGIDX A, REGCODMST B 
   WHERE ( A.REGCOD = B.REGCOD )
	  AND ( A.SHOPID 	= :ls_partner ) 
	  AND ( B.REGTYPE Like :ls_shoptype ) ;

IF IsNull(ll_cnt) then ll_cnt = 0
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " SHOP_REGIDX Select Error ==> " + sqlca.sqlerrtext )
	TriggerEvent("ue_close")
End If			

//==================================================================
//3. REGCOD 별 집계
//SHOP_REGIDX Read
//==================================================================
 DECLARE read_reglist CURSOR FOR  
  SELECT A.REGCOD,      A.INDEXDESC
    FROM SHOP_REGIDX A, REGCODMST B 
   WHERE ( A.REGCOD = B.REGCOD )
	  AND ( A.SHOPID 	= :ls_partner ) 
	  AND ( B.REGTYPE Like :ls_shoptype )
ORDER BY B.SEQ ASC  ;

OPEN read_reglist;
FETCH read_reglist INTO :ls_regcod, :ls_indexdesc;

DO WHILE SQLCA.SQLCODE = 0 
	select KEYNUM,	trim(CONCESSION)  INTO :ll_keynum,	:ls_descript
	  FROM REGCODMST
	 where REGCOD = :ls_regcod ;
	 
	ll_row = dw_list.InsertRow(0)
	//dw_list.Object.areacod[1] 		= ls_area
	dw_list.Object.areacod[1] 		= ls_shop_key
	dw_list.Object.saledt[1] 		= ldt_saledt
	dw_list.object.d1[ll_row] 		= ''
	dw_list.object.d2[ll_row] 		= ls_indexdesc
	dw_list.object.d3[ll_row] 		= "KEY#" + String(ll_keynum) 
	dw_list.object.d4[ll_row] 		= ls_descript
	
	//	 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt   ) 수정.. 2011.02.23
	SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))  INTO :ldc_payamt , :ldc_taxamt 
	  FROM dailypayment A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
		AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
	IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0.0
	
	//	 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt   ) 수정.. 2011.02.23	
	SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0)) INTO :ldc_in2, :ldc_invat2
	  FROM dailypaymentH A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
		AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
	IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0.0
	
	ldc_payamt	= ldc_payamt + ldc_in2
	ldc_taxamt	= ldc_taxamt + ldc_invat2
	
	
	IF ldc_payamt <> 0 THEN
		wf_cut(ldc_payamt)
		dw_list.object.t1[ll_row] 		= is_fm1
		dw_list.object.t2[ll_row] 		= is_fm2
		dw_list.object.t3[ll_row] 		= is_fm3
	END IF
	
	

//=======================================================================		
// 누계구하기 
//=======================================================================		
		
	//	 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt )
	// 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt   ) 수정.. 2011.02.23
	SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))  INTO :ldc_payamt  , :ldc_taxamt 
	  FROM DAILYPAYMENT A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
		AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
		AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
	IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0.0
	
	//	 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt )
	// 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt   ) 수정.. 2011.02.23	
	SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))  INTO :ldc_in2, :ldc_invat2
	  FROM DAILYPAYMENTH A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
		AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
		AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
	IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0.0
	
   	ldc_payamt = ldc_payamt + ldc_in2	
	ldc_taxamt = ldc_taxamt + ldc_invat2	
	
	IF ldc_payamt <> 0 THEN
		wf_cut(ldc_payamt)
		dw_list.object.s1[ll_row] 		= is_fm1
		dw_list.object.s2[ll_row] 		= is_fm2
		dw_list.object.s3[ll_row] 		= is_fm3
	END IF
	FETCH read_reglist INTO :ls_regcod, :ls_indexdesc;
loop
close read_reglist ;
//======================================================================
IF ll_row > 0 THEN
	dw_list.object.lsw[ll_row] 	= '1'
	ll_center = Truncate( ll_row / 2	, 0)
	IF ll_center = 0 then  ll_center = 1
	dw_list.object.d1[ll_center] 	= 'DAILY COMPUTATION'
END IF

IF ll_row <= 0 then return
//============REGLIST end.........--------------------------------------------
// grand total  - TODAY
//	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	 ) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))  INTO :ldc_payamt,   :ldc_taxamt
  FROM dailypayment A, regcodmst B  
 WHERE ( A.regcod 							= b.regcod      )
   AND ( A.SHOPID  							= :ls_partner	 )
	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') ) 
	AND ( B.regtype							Like :ls_shoptype  );
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0.0

//	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	 ) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))  INTO :ldc_in2, :ldc_invat2
  FROM dailypaymentH A, regcodmst B  
 WHERE ( A.regcod 							= b.regcod      )
   AND ( A.SHOPID  							= :ls_partner	 )
	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') ) 
	AND ( B.regtype							Like :ls_shoptype  );
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0.0

ldc_payamt = ldc_payamt + ldc_in2
ldc_taxamt = ldc_taxamt + ldc_invat2
ldc_totalamt = ldc_payamt + ldc_taxamt

//2011.01.26 이윤주 대리 요청사항. Difference 부분에 당일 합계 금액을 뿌리자...
IF ldc_payamt <> 0 THEN//공급가액
	wf_cut(ldc_payamt)	
	dw_list.object.t_GR1.Text  = is_fm1
	dw_list.object.t_GR2.Text  = is_fm2
	dw_list.object.t_GR3.Text  = is_fm3	
END IF
IF ldc_totalamt <> 0 THEN//합계금액(공급가 + 부가세)
	wf_cut_total(ldc_totalamt)
	dw_list.object.t_f81.Text  = is_fm_vat1 	
	dw_list.object.t_df_1.Text = is_fm_vat1		
	dw_list.object.t_f82.Text  = is_fm_vat2 
	dw_list.object.t_df_2.Text = is_fm_vat2		
	dw_list.object.t_f83.Text  = is_fm_vat3  
	dw_list.object.t_df_3.Text = is_fm_vat3	 	
END IF
//====================================================================
// 누계구하기 
//====================================================================
	//	 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt )
	// 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt   ) 수정.. 2011.02.23	
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0)) 	  INTO :ldc_payamt	 ,   :ldc_taxamt 
  FROM DAILYPAYMENT A, regcodmst B
 WHERE ( A.regcod 							= b.regcod )
   AND ( A.SHOPID  							= :ls_partner)
	AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
	AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )	
	AND ( B.regtype							Like :ls_shoptype );
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0.0

	//	 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt )
	// 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt   ) 수정.. 2011.02.23	
SELECT SUM(A.PAYAMT),  SUM(NVL(A.TAXAMT,0)) 	  INTO :ldc_in2	  , :ldc_invat2
  FROM DAILYPAYMENTH A, regcodmst B
 WHERE ( A.regcod 							= b.regcod )
   AND ( A.SHOPID  							= :ls_partner)
	AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
	AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )		
	AND ( B.regtype							Like :ls_shoptype );
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0.0

ldc_payamt = ldc_payamt + ldc_in2
ldc_taxamt = ldc_taxamt + ldc_invat2
ldc_totalamt = ldc_payamt + ldc_taxamt

//단위로 나누기.....
//2011.01.26 이윤주 대리 요청사항. CLOSING 부분에 GRAND TOTAL 을 뿌리자.
IF ldc_payamt <> 0 THEN//공급가액
	wf_cut(ldc_payamt)
	dw_list.object.t_GR4.Text  = is_fm1
	dw_list.object.t_GR5.Text  = is_fm2
	dw_list.object.t_GR6.Text  = is_fm3

END IF
IF ldc_totalamt <> 0 THEN//합계금액(공급가 + 부가세)
	wf_cut_total(ldc_totalamt)
	dw_list.object.t_f84.Text  = is_fm_vat1
	dw_list.object.t_cl_1.Text = is_fm_vat1
	dw_list.object.t_f85.Text  = is_fm_vat2
	dw_list.object.t_cl_2.Text = is_fm_vat2
	dw_list.object.t_f86.Text  = is_fm_vat3
	dw_list.object.t_cl_3.Text = is_fm_vat3
END IF

//====================================================================
// Opening 누계구하기  ( 전날까지의 Grand Total ). 2011.01.26 이윤주 대리 요청사항.
//====================================================================
//	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt) 
//	AND ( to_char(A.paydt, 'yyyymmdd') 	< :ls_saledt) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT)	, SUM(NVL(A.TAXAMT,0))   INTO :ldc_payamt ,  :ldc_taxamt 
  FROM DAILYPAYMENT A, regcodmst B
 WHERE ( A.regcod 							= b.regcod )
   AND ( A.SHOPID  							= :ls_partner)
	AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
	AND ( A.PAYDT								< TO_DATE(:ls_saledt, 'yyyymmdd') )		
	AND ( B.regtype							Like :ls_shoptype );
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
IF IsNUll(ldc_taxamt)  OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0.0

//	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt) 
//	AND ( to_char(A.paydt, 'yyyymmdd') 	< :ls_saledt) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))	  INTO :ldc_in2	  , :ldc_invat2
  FROM DAILYPAYMENTH A, regcodmst B
 WHERE ( A.regcod 							= b.regcod )
   AND ( A.SHOPID  							= :ls_partner)
	AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
	AND ( A.PAYDT								< TO_DATE(:ls_saledt, 'yyyymmdd') )			
	AND ( B.regtype							Like :ls_shoptype );
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0.0

ldc_payamt = ldc_payamt + ldc_in2
ldc_taxamt = ldc_taxamt + ldc_invat2
ldc_totalamt = ldc_payamt + ldc_taxamt

//단위로 나누기.....
//2011.01.26 이윤주 대리 요청사항. CLOSING 부분에 GRAND TOTAL 을 뿌리자.
IF ldc_totalamt <> 0 THEN//합계금액(공급가 + 부가세)
	wf_cut_total(ldc_totalamt)
	dw_list.object.t_op_1.Text = is_fm_vat1
	dw_list.object.t_op_2.Text = is_fm_vat2
	dw_list.object.t_op_3.Text = is_fm_vat3
END IF

//==================================================
// CHECK 구하기 -===? DAILY 만
//==================================================
// 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  ) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT) 	, SUM(NVL(A.TAXAMT,0))	INTO :ldc_payamt,  :ldc_taxamt 
  FROM dailypayment A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )
   AND ( A.paymethod 						= :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0
IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0

// 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  ) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))	INTO :ldc_in2, :ldc_invat2
  FROM dailypaymentH A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )
   AND ( A.paymethod 						= :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0
IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0

ldc_payamt = ldc_payamt + ldc_in2
ldc_taxamt = ldc_taxamt + ldc_invat2
ldc_totalamt = ldc_payamt + ldc_taxamt

IF ldc_totalamt <> 0 THEN
	wf_cut_total(ldc_totalamt)
	dw_list.object.T_CK1.text = is_fm_vat1
	dw_list.object.T_ck2.text 	= is_fm_vat2
	dw_list.object.T_ck3.text 	= is_fm_vat3
END IF
//=============================================================
// CASH + CHECK 구하기 daily
//=============================================================
// 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  ) 수정. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))	INTO :ldc_payamt,  :ldc_taxamt 
  FROM dailypayment A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )	 
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt = 0
IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt = 0

// 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  ) 수정. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))		INTO :ldc_in2, :ldc_invat2
  FROM dailypaymentH A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )	 
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0
IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0

ldc_payamt = ldc_payamt + ldc_in2
ldc_taxamt = ldc_taxamt + ldc_invat2
ldc_totalamt = ldc_payamt + ldc_taxamt

IF ldc_totalamt <> 0 THEN//합계금액(공급가 + 부가세)
	wf_cut_total(ldc_totalamt)
	dw_list.object.T_CASH1.text 	= is_fm_vat1
	dw_list.object.T_CASH2.text 	= is_fm_vat2
	dw_list.object.T_CASH3.text 	= is_fm_vat3
END IF

//=============================================================
//2.  누계구하기 
//=============================================================
//	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt) 
//	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))	INTO :ldc_payamt,  :ldc_taxamt 	
  FROM DAILYPAYMENT A, regcodmst B   
 WHERE ( A.regcod  							= b.regcod     ) 
 	AND ( A.SHOPID  							= :ls_partner	)
	AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
	AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )			 
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2] )	
	AND ( b.regtype 							Like :ls_shoptype ) ;
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0
IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0

//	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt) 
//	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt) 수정.. 2011.02.23
SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))	INTO :ldc_in2, :ldc_invat2
  FROM DAILYPAYMENTH A, regcodmst B   
 WHERE ( A.regcod  							= b.regcod     ) 
 	AND ( A.SHOPID  							= :ls_partner	)
	AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
	AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )			 
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2] )	
	AND ( b.regtype 							Like :ls_shoptype ) ;
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0
IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0

ldc_payamt = ldc_payamt + ldc_in2
ldc_taxamt = ldc_taxamt + ldc_invat2
ldc_totalamt = ldc_payamt + ldc_taxamt

IF ldc_totalamt <> 0 THEN
	wf_cut_total(ldc_totalamt)
	dw_list.object.t_cash4.Text = is_fm_vat1
	dw_list.object.t_cash5.Text = is_fm_vat2
	dw_list.object.t_cash6.Text = is_fm_vat3
END IF

//payMethod == daily
for LL = 3 TO 6
	ldc_payamt 	= 0
	ldc_in2		= 0
	ldc_taxamt	 = 0
	ldc_invat2	= 0
		//	 	AND ( to_char(A.paydt, 'yyyymmdd')  = :ls_saledt     )	수정.. 2011.02.23
	SELECT SUM(A.PAYAMT)	, SUM(NVL(A.TAXAMT,0))   INTO :ldc_payamt, :ldc_taxamt
	  FROM dailypayment A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
	 	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0
	IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0
	
		//	 	AND ( to_char(A.paydt, 'yyyymmdd')  = :ls_saledt     )	수정.. 2011.02.23
	SELECT SUM(A.PAYAMT)	, SUM(NVL(A.TAXAMT,0))  INTO :ldc_in2, :ldc_invat2
	  FROM dailypaymentH A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
	 	AND ( A.PAYDT								= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0
	IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0
	
	ldc_payamt 		= ldc_payamt + ldc_in2
	ldc_taxamt 		= ldc_taxamt + ldc_invat2
	ldc_daily[ll] 	= ldc_payamt + ldc_taxamt
//=====================================================================
// 누계구하기 
//=====================================================================
	ldc_payamt 	= 0
	ldc_in2		= 0
	ldc_taxamt	 = 0
	ldc_invat2	= 0

	// 	AND ( to_char(A.paydt, 'yyyymmdd')  >= :is_cutoffdt     )
	// 	AND ( to_char(A.paydt, 'yyyymmdd')  <= :ls_saledt     )	수정.. 2011.02.23
	SELECT SUM(A.PAYAMT)	, SUM(NVL(A.TAXAMT,0))   INTO :ldc_payamt, :ldc_taxamt
	  FROM DAILYPAYMENT A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
		AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
		AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0
	IF IsNUll(ldc_taxamt) OR sqlca.sqlcode <> 0	then ldc_taxamt	= 0
	
	// 	AND ( to_char(A.paydt, 'yyyymmdd')  >= :is_cutoffdt     )
	// 	AND ( to_char(A.paydt, 'yyyymmdd')  <= :ls_saledt     )	수정.. 2011.02.23	
	SELECT SUM(A.PAYAMT)	, SUM(NVL(A.TAXAMT,0))  INTO :ldc_in2, :ldc_invat2
	  FROM DAILYPAYMENTH A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
		AND ( A.PAYDT								>= TO_DATE(:is_cutoffdt, 'yyyymmdd') )
		AND ( A.PAYDT								<= TO_DATE(:ls_saledt, 'yyyymmdd') )		 
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0
	IF IsNUll(ldc_invat2) OR sqlca.sqlcode <> 0	then ldc_invat2	= 0

	ldc_payamt 		= ldc_payamt + ldc_in2
	ldc_taxamt 		= ldc_taxamt + ldc_invat2
	ldc_total[ll] 		= ldc_payamt + ldc_taxamt
NEXT


FOR ll = 3  to 6
	ldc_totalamt = ldc_daily[ll]
	IF ldc_totalamt <> 0 THEN
		wf_cut_total(ldc_totalamt)
		choose case ll
		case 3
				dw_list.object.t_f31.Text = is_fm_vat1
				dw_list.object.t_f32.Text = is_fm_vat2
				dw_list.object.t_f33.Text = is_fm_vat3
		case 4
				dw_list.object.t_f71.Text = is_fm_vat1
				dw_list.object.t_f72.Text = is_fm_vat2
				dw_list.object.t_f73.Text = is_fm_vat3
		case 5
				dw_list.object.t_f21.Text = is_fm_vat1
				dw_list.object.t_f22.Text = is_fm_vat2
				dw_list.object.t_f23.Text = is_fm_vat3
		case 6
				dw_list.object.t_f41.Text = is_fm_vat1
				dw_list.object.t_f42.Text = is_fm_vat2
				dw_list.object.t_f43.Text = is_fm_vat3				
		end choose
	END IF
	
	ldc_totalamt = ldc_total[ll]
	IF ldc_totalamt <> 0 THEN
		wf_cut_total(ldc_totalamt)

		choose case ll
		case 3
				dw_list.object.t_f34.Text = is_fm_vat1
				dw_list.object.t_f35.Text = is_fm_vat2
				dw_list.object.t_f36.Text = is_fm_vat3
		case 4
				dw_list.object.t_f74.Text = is_fm_vat1
				dw_list.object.t_f75.Text = is_fm_vat2
				dw_list.object.t_f76.Text = is_fm_vat3
		case 5
				dw_list.object.t_f24.Text = is_fm_vat1
				dw_list.object.t_f25.Text = is_fm_vat2
				dw_list.object.t_f26.Text = is_fm_vat3
		case 6
				dw_list.object.t_f44.Text = is_fm_vat1
				dw_list.object.t_f45.Text = is_fm_vat2
				dw_list.object.t_f46.Text = is_fm_vat3				
		end choose
	END IF
NEXT

IF Idc_rowcnt = 0 THEN
	dw_list.object.t_62.visible = True
END IF	

dw_list.GroupCalc()
//dw_list.Modify("DataWindow.Zoom=97")
dw_list.Modify("DataWindow.Zoom=87")
triggerEvent("ue_preview_set")
//
return
//paymethod list END.........................


//Trigger Event ue_ok()




end event

event ue_zoom();call super::ue_zoom;//dw_list.object.datawindow.Zoom =   90
triggerEvent("ue_preview_set")
end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_report_daily_new_vat
boolean visible = false
integer x = 69
integer y = 36
integer width = 2190
integer height = 184
string dataobject = "b1dw_cnd_prt_charge_detail"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within ssrt_prt_report_daily_new_vat
boolean visible = false
integer x = 2318
integer y = 60
end type

type p_close from w_a_print`p_close within ssrt_prt_report_daily_new_vat
integer x = 2619
integer y = 60
end type

type dw_list from w_a_print`dw_list within ssrt_prt_report_daily_new_vat
integer y = 260
integer width = 3232
integer height = 1348
string dataobject = "ssrt_prt_daily_report_ALL_1_new_vat"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_report_daily_new_vat
end type

type p_2 from w_a_print`p_2 within ssrt_prt_report_daily_new_vat
end type

type p_3 from w_a_print`p_3 within ssrt_prt_report_daily_new_vat
end type

type p_5 from w_a_print`p_5 within ssrt_prt_report_daily_new_vat
end type

type p_6 from w_a_print`p_6 within ssrt_prt_report_daily_new_vat
end type

type p_7 from w_a_print`p_7 within ssrt_prt_report_daily_new_vat
end type

type p_8 from w_a_print`p_8 within ssrt_prt_report_daily_new_vat
end type

type p_9 from w_a_print`p_9 within ssrt_prt_report_daily_new_vat
end type

type p_4 from w_a_print`p_4 within ssrt_prt_report_daily_new_vat
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_report_daily_new_vat
end type

type p_port from w_a_print`p_port within ssrt_prt_report_daily_new_vat
end type

type p_land from w_a_print`p_land within ssrt_prt_report_daily_new_vat
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_report_daily_new_vat
boolean visible = false
integer width = 2254
integer height = 240
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_report_daily_new_vat
end type

