$PBExportHeader$ssrt_prt_con_settlement_report_org.srw
$PBExportComments$[kem] AAFES settlement report 출력물(201509이전출력용)
forward
global type ssrt_prt_con_settlement_report_org from w_a_print
end type
end forward

global type ssrt_prt_con_settlement_report_org from w_a_print
integer width = 3323
integer height = 1992
end type
global ssrt_prt_con_settlement_report_org ssrt_prt_con_settlement_report_org

type variables
String 	is_format, is_fm1, is_fm2, is_fm3, &
			is_cutoffdt
date		idt_cutoffdt
end variables

forward prototypes
public subroutine wf_cut (decimal wfdc_amount)
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

on ssrt_prt_con_settlement_report_org.create
call super::create
end on

on ssrt_prt_con_settlement_report_org.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: ssrt_prt_con_settlement_report
	Desc.	: 보고서
	Ver.	: 1.0
	Date	: 2011.11.08
	Programer : kem
-------------------------------------------------------------------------*/
// 2012.10.30 REGCODMST_20111101 테이블에서 REGCODMST 테이블로 수정 HCJUNG

ii_orientation = 2
ib_margin 		= False
dec{2} 			ldc_impact10[], ldc_impact90[], 	ldc_daily[], ldc_total[]
       
f_center_window(THIS)

dw_cond.Hide()
gb_cond.Hide()

String   ls_ref_desc, 	ls_temp
String 	ls_partner,		ls_fromdt, 		ls_todt, 			ls_shoptype,	ls_regtype
String   ls_basecod, 	ls_area,			ls_shop_key,		ls_basenm, 		ls_company
String   ls_contype, 	ls_contractno, ls_contractfee, 	ls_indexdesc
string   ls_gubun
String   ls_method[],   ls_acc_num,    ls_key_nm
date 		ldt_saledt, 	ldt_fromdt, ldt_todt
dec{2}   ldc_closing_amt, ldc_refund_amt,	ldc_payamt, 	ldc_amount, 	ldc_confee
dec{2}   ldc_rpt_amt
Long     ll_keynum, 		ll_row, 			ll_row2,          ll_row3,       ldc_rowcnt
dec{0}   ldc_sales_cnt /* 2013.05.20 김선주 추가 */


dec{2}   ldec_daily, ldec_sum, ldc_in2



ldec_daily 	= 0.0
ldec_sum 	= 0.0
ldc_in2		= 0
ldt_saledt 	= iu_cust_msg.id_data[1]
ls_partner 	= iu_cust_msg.is_data[1]
ls_fromdt  	= iu_cust_msg.is_data[2]
ls_todt  	= iu_cust_msg.is_data[3]
ls_shoptype = iu_cust_msg.is_data[4] + '%'
ls_regtype  = iu_cust_msg.is_data[4]
ldc_rowcnt  = iu_cust_msg.ic_data[1]


dw_list.Reset() 

//--------------------------------------------------------------
// Header 부분
//--------------------------------------------------------------

dw_list.Object.t_title.Text = Title

//area code조회
SELECT TRIM(BASECOD)  
  INTO :ls_basecod  
  FROM PARTNERMST
 WHERE PARTNER = :ls_partner ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " PARTNERMST Select Error ==> " + sqlca.sqlerrtext )
	TriggerEvent("ue_close")
End If		

SELECT trim(AREACODE), BASENM  
  INTO :ls_area, :ls_basenm
  FROM BASEMST
 WHERE BASECOD = :ls_basecod ;
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(title, " BASEMST Select Error ==> " + sqlca.sqlerrtext )
	TriggerEvent("ue_close")
End If		

dw_list.Object.t_name.text = ls_basenm

ldt_fromdt               = f_mon_first_date(ldt_saledt)
ldt_todt                 = f_mon_last_date(ldt_saledt)
dw_list.Object.fromdt[1] = ldt_fromdt
dw_list.Object.todt[1]   = ldt_todt

//SELECT Trim(KEYNUM) INTO :ls_shop_key
//FROM   SHOP_KEY
//WHERE  SHOPID = :ls_partner
//AND    REGTYPE = :ls_regtype;
//
//If IsNull(ls_shop_key) Then ls_shop_key = ""

ls_company 		= fs_get_control("R1", "R100", ls_ref_desc)
dw_list.Object.t_company.Text = ls_company

If ls_regtype = '01' Then  //INTERNET
	ls_contype 		= fs_get_control("R1", "R110", ls_ref_desc)
	dw_list.Object.t_type.Text = ls_contype
	
	ls_contractno 	= fs_get_control("R1", "R120", ls_ref_desc)
	dw_list.Object.t_contractno.Text = ls_contractno
	
	ls_contractfee	= fs_get_control("R1", "R130", ls_ref_desc) // 11.4% : contract fee
	dw_list.Object.t_contractfee.Text = ls_contractfee + '% of sales'
	
Else                       //MOBILE  
	ls_contype 		= fs_get_control("R1", "R140", ls_ref_desc)
	dw_list.Object.t_type.Text = ls_contype
	
//	ls_contractno 	= fs_get_control("R1", "R150", ls_ref_desc)
//	dw_list.Object.t_contractno.Text = ls_contractno

    // 20150930 이전조회용
	ls_contractno 	= fs_get_control("R1", "R155", ls_ref_desc)
	dw_list.Object.t_contractno.Text = ls_contractno
	
	ls_contractfee	= fs_get_control("R1", "R160", ls_ref_desc) // 10.4% : contract fee
	dw_list.Object.t_contractfee.Text = ls_contractfee + '% of sales'
End If

//contractfee 로 exchange fee 금액 계산하기 위한 항목
ldc_confee = Dec(ls_contractfee)

//==============================================================
// SECTION I - SAELS OVERVIEW 부분.
//==============================================================
//1. KEY# 별  ==> DAILYPAYMENT 내역 추출

DECLARE read_dailyamt CURSOR FOR    //Dailypayment

  SELECT B.KEYNUM, A.INDEXDESC
       , SUM(DECODE(D.DCTYPE, 'D', NVL(D.PAYAMT,0), 0)) CLOSING_AMT		 
		 /* 2013.05.31 김선주, Type이 'C'인경우, CREDIT이므로, -1을 곱한다
       , SUM(DECODE(D.DCTYPE, 'C', NVL(D.PAYAMT * -1,0), 0)) REFUND_AMT*/
		, SUM(DECODE(D.DCTYPE, 'C', NVL(D.PAYAMT * -1,0), 0)) REFUND_AMT 
//    FROM DAILYPAYMENT D,  SHOP_REGIDX A , REGCODMST_20111101 B
    FROM DAILYPAYMENT D,  SHOP_REGIDX A , REGCODMST B	 
   WHERE D.REGCOD  = A.REGCOD
     AND A.REGCOD  = B.REGCOD
     AND A.SHOPID  = :ls_partner
     AND D.SHOPID  = :ls_partner
     AND D.PAYDT BETWEEN :ldt_fromdt AND :ldt_todt
     AND B.REGTYPE = :ls_regtype
   GROUP BY B.KEYNUM, A.indexdesc
   ORDER BY B.KEYNUM, A.indexdesc;

OPEN read_dailyamt;

FETCH read_dailyamt INTO :ll_keynum, :ls_indexdesc, :ldc_closing_amt, :ldc_refund_amt;

DO WHILE SQLCA.SQLCODE = 0 
	
	If ll_row = 0 Then
		ll_row = 1
	Else
		ll_row = dw_list.InsertRow(0)
		ldc_rowcnt ++
	End If
			
	dw_list.Object.areacod[ll_row] = ls_area
	dw_list.Object.saledt[ll_row]	= ldt_saledt
	dw_list.Object.confee[ll_row] = ldc_confee
	if ll_keynum = 1 then
		dw_list.object.d1[ll_row]		= "KEY " + String(ll_keynum)		
	else
		dw_list.object.d1[ll_row]		= "KEY " + String(ll_keynum) + "*"		
	end if

	dw_list.object.d2[ll_row] 		= ls_indexdesc
	dw_list.object.d3[ll_row] 		= String(ldc_closing_amt, '###,##0.00')
	
	//2013.05.31 김선주 막음 (refund금액 그대로 보이도록 ABS제거함) 
	//이렇게 수정한 배경은 2013년 5월 청구시에, REFUND금액이 문제가 되어 막음. 
	//dw_list.object.d4[ll_row] 		= String(ABS(ldc_refund_amt), '###,##0.00')
	
	dw_list.object.d4[ll_row] 		= String(ldc_refund_amt, '###,##0.00')
	
	If ls_regtype = '01' AND ll_keynum = 7 Then
		dw_list.Object.lsw[ll_row] = '1'
	ElseIf ls_regtype = '02' AND ll_keynum = 6 Then
		dw_list.Object.lsw[ll_row] = '1'
	Else
		dw_list.Object.lsw[ll_row] = '0'
	End If
	
	FETCH read_dailyamt INTO :ll_keynum, :ls_indexdesc, :ldc_closing_amt, :ldc_refund_amt;
loop
close read_dailyamt ;


//2. KEY# 별  ==> ONLINE/AUTOPAY AAFES_DATA 내역 추출
DECLARE read_autoonlineamt CURSOR FOR    //AAFES_DATA

  SELECT B.KEYNUM, A.INDEXDESC, decode(D.PAY_GUBUN, 'AUTO', '1', 'REFUND', '1', 'PREPAY', '3') GUBUN1
       , SUM(DECODE(D.PAY_GUBUN, 'AUTO', NVL(D.AMOUNT,0),  'PREPAY', NVL(D.AMOUNT, 0),0)) CLOSING_AMT
		 /* #5997 아래를 막고, refund의 경우에는 -1을 곱하는 로직으로 수정. 2013.11.12 김선주*/
       /*, SUM(DECODE(D.PAY_GUBUN, 'REFUND', NVL(D.AMOUNT,0), 0)) REFUND_AMT */
		 , SUM(DECODE(D.PAY_GUBUN, 'REFUND', NVL(D.AMOUNT,0), 0)) * (-1) REFUND_AMT
    FROM AAFES_DATA D,  SHOP_REGIDX A , REGCODMST B
   WHERE D.REGCOD  = A.REGCOD
     AND A.REGCOD  = B.REGCOD
     AND A.SHOPID  = :ls_partner
     AND D.CAMP    = :ls_partner
     AND D.CUTOFF_DT BETWEEN :ldt_fromdt AND :ldt_todt
     AND B.REGTYPE = :ls_regtype
   GROUP BY B.KEYNUM, A.indexdesc, decode(D.PAY_GUBUN, 'AUTO', '1', 'REFUND', '1', 'PREPAY', '3')
   ORDER BY GUBUN1, B.KEYNUM, A.indexdesc;

OPEN read_autoonlineamt;

FETCH read_autoonlineamt INTO :ll_keynum, :ls_indexdesc, :ls_gubun, :ldc_closing_amt, :ldc_refund_amt;

DO WHILE SQLCA.SQLCODE = 0 

	If ll_row = 0 Then
		ll_row2 = 1
	Else
		ll_row2 = dw_list.InsertRow(0)
		ldc_rowcnt ++
	End If
	 
	dw_list.Object.areacod[ll_row2]  = ls_area
	dw_list.Object.saledt [ll_row2]  = ldt_saledt
	dw_list.Object.confee [ll_row2]  = ldc_confee
	
	if ls_gubun = '1' then // AUTO, REFUND
		if ll_keynum = 1 then
			dw_list.object.d1[ll_row2] 		= "CC " + String(ll_keynum)
		else 
			dw_list.object.d1[ll_row2] 		= "CC " + String(ll_keynum) + "*"
		end if
	else  // PREPAY
		if ll_keynum = 1 then		
			dw_list.object.d1[ll_row2] 		= "PR " + String(ll_keynum)
		else
			dw_list.object.d1[ll_row2] 		= "PR " + String(ll_keynum) + "*"
		end if
	end if
	
	dw_list.object.d2[ll_row2] 		= ls_indexdesc
	dw_list.object.d3[ll_row2] 		= String(ldc_closing_amt    , '###,##0.00')
	
	/*[#5997] 2013.12.02 김선주 이윤주대리 요청으로 ABS제거함. */
	/*dw_list.object.d4[ll_row2] 		= String(ABS(ldc_refund_amt), '###,##0.00')*/
	
	dw_list.object.d4[ll_row2] 		= String(ldc_refund_amt, '###,##0.00')
	
	If ls_regtype = '01' AND ll_keynum = 7 Then  // 인터넷
		dw_list.Object.lsw[ll_row2] = '1'
	ElseIf ls_regtype = '02' AND ll_keynum = 6 Then
		dw_list.Object.lsw[ll_row2] = '1'
	Else
		dw_list.Object.lsw[ll_row2] = '0'
	End If

	FETCH read_autoonlineamt INTO :ll_keynum, :ls_indexdesc, :ls_gubun, :ldc_closing_amt, :ldc_refund_amt;
loop
close read_autoonlineamt ;

//2-end. KEY# 별  ==> ONLINE/AUTOPAY AAFES_DATA 내역 추출
DECLARE read_autoonlineamt1 CURSOR FOR    //AAFES_DATA

  SELECT A.INDEXDESC
       , SUM( NVL(D.AMOUNT, 0)) * (-1) CLOSING_AMT
       , SUM(DECODE(D.PAY_GUBUN, 'REFUND', NVL(D.AMOUNT,0), 0))* (-1)  REFUND_AMT
    FROM AAFES_DATA D,  SHOP_REGIDX A , REGCODMST B
   WHERE D.REGCOD    = A.REGCOD
     AND A.REGCOD    = B.REGCOD
     AND A.SHOPID    = :ls_partner
     AND D.CAMP      = :ls_partner
     AND D.CUTOFF_DT BETWEEN :ldt_fromdt AND :ldt_todt
     AND B.REGTYPE   = :ls_regtype
	  AND D.PAY_GUBUN = 'PREPAY'
   GROUP BY A.indexdesc ;
//   ORDER BY GUBUN1, B.KEYNUM, A.indexdesc;

OPEN read_autoonlineamt1;

FETCH read_autoonlineamt1 INTO :ls_indexdesc, :ldc_closing_amt, :ldc_refund_amt;

DO WHILE SQLCA.SQLCODE = 0 

	If ll_row = 0 Then
		ll_row2 = 1
	Else
		ll_row2 = dw_list.InsertRow(0)
		ldc_rowcnt ++
	End If
	 
	dw_list.Object.areacod[ll_row2] = ls_area
	dw_list.Object.saledt [ll_row2] = ldt_saledt
	dw_list.Object.confee [ll_row2] = ldc_confee 
	
	dw_list.object.d1[ll_row2] 		= "PRR 7*"
	
	dw_list.object.d2[ll_row2] 		= ls_indexdesc
//	dw_list.object.d3[ll_row2] 		= "(" + String(ldc_closing_amt * -1   , '###,##0.00') + ")"
	dw_list.object.d3[ll_row2] 		= String(ldc_closing_amt  , '###,##0.00')
	
	/*[#5997] 2013.12.02 김선주 이윤주대리 요청으로 ABS제거함. */
	/*dw_list.object.d4[ll_row2] 		= String(ABS(ldc_refund_amt), '###,##0.00')*/
	dw_list.object.d4[ll_row2] 		= String(ldc_refund_amt, '###,##0.00')
	
   dw_list.Object.lsw[ll_row2] = '1'
	
	FETCH read_autoonlineamt1 INTO :ls_indexdesc, :ldc_closing_amt, :ldc_refund_amt;
loop
close read_autoonlineamt1 ;


//3. KEY# 추가매출  ==> AAFES_REPORT_DATA 내역 추출
DECLARE read_reportamt CURSOR FOR    //Aafes_report_data

  SELECT B.KEYNUM, A.INDEXDESC
       , SUM(NVL(D.AMOUNT,0)) CLOSING_AMT
		 /* #5997 아래를 막고, refund의 경우에는 -1을 곱하는 로직으로 수정. 2013.11.12 김선주*/
       /*, SUM(NVL(D.REFUND_AMT, 0)) REFUND_AMT  */
		 , SUM(NVL(D.REFUND_AMT, 0)) * (-1) REFUND_AMT
    FROM AAFES_REPORT_DATA D,  SHOP_REGIDX A , REGCODMST B
   WHERE D.REGCOD = A.REGCOD
     AND A.REGCOD = B.REGCOD
     AND D.SHOPID = A.SHOPID
     AND D.SHOPID = :ls_partner
     AND TO_CHAR(D.FROMDT,'YYYYMMDD') <= TO_CHAR(:ldt_fromdt,'YYYYMMDD')
     AND NVL(TO_CHAR(D.TODT,'YYYYMMDD'),'29991231') >= TO_CHAR(:ldt_todt,'YYYYMMDD')
     AND B.REGTYPE = :ls_regtype
	  AND D.TYPE    = 'SEC1'
   GROUP BY B.KEYNUM, A.indexdesc
   ORDER BY B.KEYNUM, A.indexdesc;

OPEN read_reportamt;
FETCH read_reportamt INTO :ll_keynum, :ls_indexdesc, :ldc_closing_amt, :ldc_refund_amt;

DO WHILE SQLCA.SQLCODE = 0 

	If ll_row = 0 AND ll_row2 = 0 Then
		ll_row3 = 1
	Else
		ll_row3 = dw_list.InsertRow(0)
		ldc_rowcnt ++
	End If
	 
	dw_list.Object.areacod[ll_row3]  = ls_area
	dw_list.Object.saledt[ll_row3]   = ldt_saledt
	dw_list.Object.confee[ll_row3]   = ldc_confee
	dw_list.object.d1[ll_row3] 		= "IN " + String(ll_keynum)
	dw_list.object.d2[ll_row3] 		= ls_indexdesc
	dw_list.object.d3[ll_row3] 		= String(ldc_closing_amt, '###,##0.00')
	
	/*[#5997] 2013.12.02 김선주 이윤주대리 요청으로 ABS제거함. */
	/*dw_list.object.d4[ll_row3] 		= String(ABS(ldc_refund_amt), '###,##0.00')*/
	dw_list.object.d4[ll_row3] 		= String(ldc_refund_amt, '###,##0.00')
	
	If ls_regtype = '01' AND ll_keynum = 7 Then
		dw_list.Object.lsw[ll_row3] = '1'
	ElseIf ls_regtype = '02' AND ll_keynum = 6 Then
		dw_list.Object.lsw[ll_row3] = '1'
	Else
		dw_list.Object.lsw[ll_row3] = '0'
	End If
	
	FETCH read_reportamt INTO :ll_keynum, :ls_indexdesc, :ldc_closing_amt, :ldc_refund_amt;
loop
close read_reportamt ;


//==============================================================
// SECTION II - TRANSACTION DETAIL 부분.
//==============================================================
//1. PAYMETHOD 별  ==> DAILYPAYMENT 내역 추출

ls_temp	= fs_get_control("B5", "I101", ls_ref_desc)
fi_cut_string(ls_temp, ";", ls_method[])

// CASH, CHECK 금액 추출  ls_method[1], ls_method[2]  -> 이윤주대리 요청 CHECK만 추출(2011.11.07)
SELECT SUM(A.PAYAMT)	
INTO :ldc_payamt
//  FROM DAILYPAYMENT A, REGCODMST_20111101 B   
  FROM DAILYPAYMENT A, REGCODMST B     
 WHERE A.REGCOD    = b.REGCOD
 	AND A.SHOPID  	 = :ls_partner
	AND A.PAYDT     BETWEEN :ldt_fromdt AND :ldt_todt
   AND A.PAYMETHOD = :ls_method[2] 
	AND B.REGTYPE 	 Like :ls_shoptype  ;
	
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0

dw_list.Object.t3[ldc_rowcnt] = ldc_payamt

// MILSTAR CARD 금액 추출  ls_method[4]
SELECT SUM(A.PAYAMT)	
INTO :ldc_payamt
//  FROM DAILYPAYMENT A, REGCODMST_20111101 B 
  FROM DAILYPAYMENT A, REGCODMST B   
 WHERE  A.REGCOD    = b.REGCOD 
 	AND  A.SHOPID    = :ls_partner	  
	AND  A.PAYDT     BETWEEN :ldt_fromdt AND :ldt_todt
   AND  A.PAYMETHOD = :ls_method[4] 
	AND  B.REGTYPE 	Like :ls_shoptype    ;
	
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0

dw_list.Object.t2[ldc_rowcnt] = ldc_payamt

// IMPACT CARD 금액 추출  ls_method[5]
SELECT SUM(A.PAYAMT)	
INTO :ldc_payamt
//  FROM DAILYPAYMENT A, REGCODMST_20111101 B   
  FROM DAILYPAYMENT A, REGCODMST B   
 WHERE  A.REGCOD    = b.REGCOD 
 	AND  A.SHOPID    = :ls_partner	  
	AND  A.PAYDT     BETWEEN :ldt_fromdt AND :ldt_todt  
   AND  A.PAYMETHOD = :ls_method[5]  	
	AND  B.REGTYPE   Like :ls_shoptype   ;
	
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0

dw_list.Object.t5[ldc_rowcnt] = ldc_payamt

// GIFT CARD 금액 추출  ls_method[6]
SELECT SUM(A.PAYAMT)	
INTO :ldc_payamt
//  FROM DAILYPAYMENT A, REGCODMST_20111101 B
  FROM DAILYPAYMENT A, REGCODMST B   
 WHERE  A.REGCOD     = b.REGCOD 
 	AND  A.SHOPID  	= :ls_partner	 
	AND  A.PAYDT      BETWEEN :ldt_fromdt AND :ldt_todt  
   AND  A.PAYMETHOD 	= :ls_method[6]  	
	AND  B.REGTYPE 	Like :ls_shoptype    ;
	
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0

dw_list.Object.t4[ldc_rowcnt] = ldc_payamt


// CREDIT CARD 금액 추출  ls_method[3]
SELECT SUM(A.PAYAMT)	
INTO :ldc_payamt
//  FROM DAILYPAYMENT A, REGCODMST_20111101 B 
  FROM DAILYPAYMENT A, REGCODMST B   
 WHERE A.REGCOD     = b.REGCOD
 	AND A.SHOPID	  = :ls_partner	
	AND A.PAYDT      BETWEEN :ldt_fromdt AND :ldt_todt
   AND A.PAYMETHOD  = :ls_method[3] 
	AND B.REGTYPE 	  Like :ls_shoptype ;
	
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0


dw_list.Object.t1[ldc_rowcnt] = ldc_payamt

//3. 매출추가내역 추출 ==> AAFES_REPORT_DATA 내역 추출
//MWR Account Number, 금액 추출
ls_acc_num = ''
ls_key_nm = 'MWR'

SELECT KEY_NM    , ACC_NUM    , SUM(AMOUNT) 
  INTO :ls_key_nm, :ls_acc_num, :ldc_rpt_amt
  FROM AAFES_REPORT_DATA
 WHERE TYPE = 'SEC2'
   AND KEY_ID = 'MWR'
	AND SHOPID = :ls_partner
	AND SHOP_TYPE Like :ls_shoptype
	AND FROMDT <= :ldt_fromdt AND NVL(TODT,SYSDATE) >= :ldt_todt
 GROUP BY KEY_NM, ACC_NUM;
 
IF IsNUll(ldc_rpt_amt) OR sqlca.sqlcode <> 0	then ldc_rpt_amt	= 0 

dw_list.object.t6[ldc_rowcnt] = ldc_rpt_amt
dw_list.object.t_57.Text      = ls_acc_num
dw_list.object.t_56.Text      = ls_key_nm

//TELEPHONE CHARGES Account Number, 금액 추출
ls_acc_num = ''
ls_key_nm = 'TELEPHONE CHARGES'

SELECT KEY_NM    , ACC_NUM    , SUM(AMOUNT) 
  INTO :ls_key_nm, :ls_acc_num, :ldc_rpt_amt
  FROM AAFES_REPORT_DATA
 WHERE TYPE      = 'SEC2'
   AND KEY_ID    = 'TELEPHONE CHARGES'
	AND SHOPID    = :ls_partner
	AND SHOP_TYPE Like :ls_shoptype
	AND FROMDT    <= :ldt_fromdt 
	AND NVL(TODT,SYSDATE) >= :ldt_todt
 GROUP BY KEY_NM, ACC_NUM;
 
IF IsNUll(ldc_rpt_amt) OR sqlca.sqlcode <> 0	then ldc_rpt_amt	= 0 

dw_list.object.t7[ldc_rowcnt] = ldc_rpt_amt
dw_list.object.t_59.Text      = ls_acc_num
dw_list.object.t_58.Text      = ls_key_nm

//WI-FI CHARGES Account Number, 금액 추출
ls_acc_num = ''
ls_key_nm  = 'WI-FI CHARGES'

SELECT KEY_NM    , ACC_NUM    , SUM(AMOUNT) 
  INTO :ls_key_nm, :ls_acc_num, :ldc_rpt_amt
  FROM AAFES_REPORT_DATA
 WHERE TYPE = 'SEC2'
   AND KEY_ID = 'WI-FI CHARGES'
	AND SHOPID = :ls_partner
	AND SHOP_TYPE Like :ls_shoptype
	AND FROMDT <= :ldt_fromdt AND NVL(TODT,SYSDATE) >= :ldt_todt
 GROUP BY KEY_NM, ACC_NUM;
 
IF IsNUll(ldc_rpt_amt) OR sqlca.sqlcode <> 0	then ldc_rpt_amt	= 0 

dw_list.object.t8[ldc_rowcnt] = ldc_rpt_amt
dw_list.object.t_83.Text      = ls_acc_num
dw_list.object.t_60.Text      = ls_key_nm

//CATV Account Number, 금액 추출
ls_acc_num = ''
ls_key_nm  = 'CATV'

SELECT KEY_NM    , ACC_NUM    , SUM(AMOUNT) 
  INTO :ls_key_nm, :ls_acc_num, :ldc_rpt_amt
  FROM AAFES_REPORT_DATA
 WHERE TYPE      = 'SEC2'
   AND KEY_ID    = 'CATV'
	AND SHOPID    = :ls_partner
	AND SHOP_TYPE Like :ls_shoptype
	AND FROMDT <= :ldt_fromdt 
	AND NVL(TODT,SYSDATE) >= :ldt_todt
 GROUP BY KEY_NM, ACC_NUM;
 
IF IsNUll(ldc_rpt_amt) OR sqlca.sqlcode <> 0	then ldc_rpt_amt	= 0 

dw_list.object.t9[ldc_rowcnt] = ldc_rpt_amt
dw_list.object.t_84.Text      = ls_acc_num
dw_list.object.t_62.Text      = ls_key_nm

//INVOICE Account Number, 금액 추출
ls_acc_num = ''
ls_key_nm  = 'INVOICE'  

SELECT KEY_NM    , ACC_NUM    , SUM(AMOUNT) 
  INTO :ls_key_nm, :ls_acc_num, :ldc_rpt_amt
  FROM AAFES_REPORT_DATA
 WHERE TYPE      = 'SEC2'
   AND KEY_ID    = 'INVOICE'
	AND SHOPID    = :ls_partner
	AND SHOP_TYPE Like :ls_shoptype
	AND FROMDT    <= :ldt_fromdt 
	AND NVL(TODT,SYSDATE) >= :ldt_todt
 GROUP BY KEY_NM, ACC_NUM;

IF IsNUll(ldc_rpt_amt) OR sqlca.sqlcode <> 0	then ldc_rpt_amt	= 0 

dw_list.object.t10[ldc_rowcnt] = ldc_rpt_amt
dw_list.object.t_86.Text       = ls_acc_num
dw_list.object.t_85.Text       = ls_key_nm


// [#4661][2013.05.21 김선주] 로직추가 
// SALES 금액이 0인건수를 "NO SALES COUNT"에 보여주도록 요청함. 
SELECT COUNT(*)
  INTO :ldc_sales_cnt
    FROM DAILYPAYMENT_SUM
   WHERE  SHOPID = :ls_partner
     AND  PAYDT BETWEEN :ldt_fromdt AND :ldt_todt
     AND  REGTYPE  LIKE :ls_shoptype
	  AND  SUM = 0 ;  
	  
	
IF IsNUll(ldc_sales_cnt) OR sqlca.sqlcode <> 0	then ldc_sales_cnt = 0

dw_list.object.t_88.Text       = string(ldc_sales_cnt)

IF ldc_rowcnt = 0 THEN
	dw_list.object.t_100.visible = True
END IF	

//dw_list.GroupCalc()
//dw_list.Modify("DataWindow.Zoom=97")
//dw_list.Modify("DataWindow.Zoom=93")
dw_list.Modify("DataWindow.Zoom=91")
ii_orientation = 1
triggerEvent("ue_preview_set")
//
return
//paymethod list END.........................

end event

event ue_zoom;call super::ue_zoom;//dw_list.object.datawindow.Zoom =   90
triggerEvent("ue_preview_set")
end event

event ue_init();call super::ue_init;ii_orientation = 1  //세로0, 가로1
ib_margin = False

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_con_settlement_report_org
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

type p_ok from w_a_print`p_ok within ssrt_prt_con_settlement_report_org
boolean visible = false
integer x = 2318
integer y = 60
end type

type p_close from w_a_print`p_close within ssrt_prt_con_settlement_report_org
integer x = 2619
integer y = 60
end type

type dw_list from w_a_print`dw_list within ssrt_prt_con_settlement_report_org
integer y = 260
integer width = 3232
integer height = 1348
string dataobject = "ssrt_dw_prt_settlement_report"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_con_settlement_report_org
end type

type p_2 from w_a_print`p_2 within ssrt_prt_con_settlement_report_org
end type

type p_3 from w_a_print`p_3 within ssrt_prt_con_settlement_report_org
end type

type p_5 from w_a_print`p_5 within ssrt_prt_con_settlement_report_org
end type

type p_6 from w_a_print`p_6 within ssrt_prt_con_settlement_report_org
end type

type p_7 from w_a_print`p_7 within ssrt_prt_con_settlement_report_org
end type

type p_8 from w_a_print`p_8 within ssrt_prt_con_settlement_report_org
end type

type p_9 from w_a_print`p_9 within ssrt_prt_con_settlement_report_org
end type

type p_4 from w_a_print`p_4 within ssrt_prt_con_settlement_report_org
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_con_settlement_report_org
end type

type p_port from w_a_print`p_port within ssrt_prt_con_settlement_report_org
end type

type p_land from w_a_print`p_land within ssrt_prt_con_settlement_report_org
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_con_settlement_report_org
boolean visible = false
integer width = 2254
integer height = 240
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_con_settlement_report_org
end type

