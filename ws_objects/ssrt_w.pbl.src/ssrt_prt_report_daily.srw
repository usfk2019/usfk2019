$PBExportHeader$ssrt_prt_report_daily.srw
$PBExportComments$[1hera]ssrt Daily Report
forward
global type ssrt_prt_report_daily from w_a_print
end type
end forward

global type ssrt_prt_report_daily from w_a_print
integer width = 3323
integer height = 1992
end type
global ssrt_prt_report_daily ssrt_prt_report_daily

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

on ssrt_prt_report_daily.create
call super::create
end on

on ssrt_prt_report_daily.destroy
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
			ldc_in1, 		ldc_in2


String	ls_facnum,		ls_desc,			ls_indexdesc
Long		ll,				ll_keynum
String 	ls_method[]
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

select max(cutoff_dt) + 1
  INTO :idt_cutoffdt
  from cutoff 
 where to_char(cutoff_dt, 'yyyymmdd') < :ls_saledt ;
//
is_cutoffdt =  String(idt_cutoffdt, 'yyyymmdd')
dw_list.Reset()

//area code조회
select trim(basecod)  INTO :ls_basecod  FROM PARTNERMST
 WHERE PARTNER = :ls_partner ;

SELECT trim(AREACODE)   INTO :ls_area FROM BASEMST
 WHERE BASECOD = :ls_basecod ;

//--------------------------------------------------------------
//1. HEAD 부분 & CASH 부분 --> 수기로 하는 부분.
//--------------------------------------------------------------
//1. PayMethod ==> 현금101, 102, 103, 104, 105
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
	dw_list.Object.areacod[1] 		= ls_area
	dw_list.Object.saledt[1] 		= ldt_saledt
	dw_list.object.d1[ll_row] 		= ''
	dw_list.object.d2[ll_row] 		= ls_indexdesc
	dw_list.object.d3[ll_row] 		= "KEY#" + String(ll_keynum) 
	dw_list.object.d4[ll_row] 		= ls_descript
	
	 
	SELECT SUM(A.PAYAMT)  INTO :ldc_payamt  
	  FROM dailypayment A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt   )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
	
	SELECT SUM(A.PAYAMT)  INTO :ldc_in2
	  FROM dailypaymentH A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt   )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
	
	ldc_payamt	= ldc_payamt + ldc_in2
	
	
	IF ldc_payamt <> 0 THEN
		wf_cut(ldc_payamt)
		dw_list.object.t1[ll_row] 		= is_fm1
		dw_list.object.t2[ll_row] 		= is_fm2
		dw_list.object.t3[ll_row] 		= is_fm3
	END IF
//=======================================================================		
// 누계구하기 
//=======================================================================		
	SELECT SUM(A.PAYAMT)  INTO :ldc_payamt  
	  FROM DAILYPAYMENT A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt )
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt   )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0
	
	SELECT SUM(A.PAYAMT)  INTO :ldc_in2
	  FROM DAILYPAYMENTH A, regcodmst B   
    WHERE ( A.regcod								= b.regcod     )
	   AND ( A.SHOPID  							= :ls_partner  )
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt )
	 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt   )
	   AND ( A.regcod  							= :ls_regcod   )	
		AND ( b.regtype 							Like :ls_shoptype ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0
	
   ldc_payamt = ldc_payamt + ldc_in2	
	
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
SELECT SUM(A.PAYAMT)  INTO :ldc_payamt  
  FROM dailypayment A, regcodmst B  
 WHERE ( A.regcod 							= b.regcod      )
   AND ( A.SHOPID  							= :ls_partner	 )
	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	 ) 
	AND ( B.regtype							Like :ls_shoptype  );
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0

SELECT SUM(A.PAYAMT)  INTO :ldc_in2
  FROM dailypaymentH A, regcodmst B  
 WHERE ( A.regcod 							= b.regcod      )
   AND ( A.SHOPID  							= :ls_partner	 )
	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	 ) 
	AND ( B.regtype							Like :ls_shoptype  );
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0

ldc_payamt = ldc_payamt + ldc_in2

IF ldc_payamt <> 0 THEN
	wf_cut(ldc_payamt)
	dw_list.object.t_f81.Text = is_fm1
	dw_list.object.t_GR1.Text = is_fm1
	dw_list.object.t_f82.Text = is_fm2
	dw_list.object.t_GR2.Text = is_fm2
	dw_list.object.t_f83.Text = is_fm3
	dw_list.object.t_GR3.Text = is_fm3
END IF
	
//====================================================================
// 누계구하기 
//====================================================================
SELECT SUM(A.PAYAMT)	  INTO :ldc_payamt	  
  FROM DAILYPAYMENT A, regcodmst B
 WHERE ( A.regcod 							= b.regcod )
   AND ( A.SHOPID  							= :ls_partner)
	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt) 
	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt) 
	AND ( B.regtype							Like :ls_shoptype );
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0.0

SELECT SUM(A.PAYAMT)	  INTO :ldc_in2	  
  FROM DAILYPAYMENTH A, regcodmst B
 WHERE ( A.regcod 							= b.regcod )
   AND ( A.SHOPID  							= :ls_partner)
	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt) 
	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt) 
	AND ( B.regtype							Like :ls_shoptype );
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0.0

ldc_payamt = ldc_payamt + ldc_in2

//단위로 나누기.....
IF ldc_payamt <> 0 THEN
	wf_cut(ldc_payamt)
	dw_list.object.t_f84.Text = is_fm1
	dw_list.object.t_GR4.Text = is_fm1
	dw_list.object.t_f85.Text = is_fm2
	dw_list.object.t_GR5.Text = is_fm2
	dw_list.object.t_f86.Text = is_fm3
	dw_list.object.t_GR6.Text = is_fm3
END IF
//==================================================
// CHECK 구하기 -===? DAILY 만
//==================================================
SELECT SUM(A.PAYAMT)	INTO :ldc_payamt
  FROM dailypayment A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  )
   AND ( A.paymethod 						= :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0

SELECT SUM(A.PAYAMT)	INTO :ldc_in2
  FROM dailypaymentH A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  )
   AND ( A.paymethod 						= :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0

ldc_payamt = ldc_payamt + ldc_in2
IF ldc_payamt <> 0 THEN
	wf_cut(ldc_payamt)
	dw_list.object.T_CK1.text 	= is_fm1
	dw_list.object.T_ck2.text 	= is_fm2
	dw_list.object.T_ck3.text 	= is_fm3
END IF
//=============================================================
// CASH + CHECK 구하기 daily
//=============================================================
SELECT SUM(A.PAYAMT)	INTO :ldc_payamt
  FROM dailypayment A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  )
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt = 0

SELECT SUM(A.PAYAMT)	INTO :ldc_in2
  FROM dailypaymentH A, regcodmst B   
 WHERE ( A.regcod  = b.regcod ) 
 	AND ( A.SHOPID  							= :ls_partner	  )
 	AND ( to_char(A.paydt, 'yyyymmdd') 	= :ls_saledt 	  )
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2]  )	
	AND ( b.regtype 							Like :ls_shoptype   ) ;
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0

ldc_payamt = ldc_payamt + ldc_in2
IF ldc_payamt <> 0 THEN
	wf_cut(ldc_payamt)
	dw_list.object.T_CASH1.text 	= is_fm1
	dw_list.object.T_CASH2.text 	= is_fm2
	dw_list.object.T_CASH3.text 	= is_fm3
END IF

//=============================================================
//2.  누계구하기 
//=============================================================
SELECT SUM(A.PAYAMT)	INTO :ldc_payamt
  FROM DAILYPAYMENT A, regcodmst B   
 WHERE ( A.regcod  							= b.regcod     ) 
 	AND ( A.SHOPID  							= :ls_partner	)
 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt 	)
 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt 	)
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2] )	
	AND ( b.regtype 							Like :ls_shoptype ) ;
IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0

SELECT SUM(A.PAYAMT)	INTO :ldc_in2
  FROM DAILYPAYMENTH A, regcodmst B   
 WHERE ( A.regcod  							= b.regcod     ) 
 	AND ( A.SHOPID  							= :ls_partner	)
 	AND ( to_char(A.paydt, 'yyyymmdd') 	>= :is_cutoffdt 	)
 	AND ( to_char(A.paydt, 'yyyymmdd') 	<= :ls_saledt 	)
   AND ( A.paymethod = :ls_method[1] OR A.paymethod = :ls_method[2] )	
	AND ( b.regtype 							Like :ls_shoptype ) ;
IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0

ldc_payamt = ldc_payamt + ldc_in2
IF ldc_payamt <> 0 THEN
	wf_cut(ldc_payamt)
	dw_list.object.t_cash4.Text = is_fm1
	dw_list.object.t_cash5.Text = is_fm2
	dw_list.object.t_cash6.Text = is_fm3
END IF

//payMethod == daily
for LL = 3 TO 5
	ldc_payamt 	= 0
	ldc_in2		= 0
	SELECT SUM(A.PAYAMT)	  INTO :ldc_payamt
	  FROM dailypayment A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
	 	AND ( to_char(A.paydt, 'yyyymmdd')  = :ls_saledt     )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0
	
	SELECT SUM(A.PAYAMT)	  INTO :ldc_in2
	  FROM dailypaymentH A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
	 	AND ( to_char(A.paydt, 'yyyymmdd')  = :ls_saledt     )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0
	
	ldc_payamt 		= ldc_payamt + ldc_in2
	ldc_daily[ll] 	= ldc_payamt
//=====================================================================
// 누계구하기 
//=====================================================================
	ldc_payamt 	= 0
	ldc_in2		= 0
	SELECT SUM(A.PAYAMT)	  INTO :ldc_payamt
	  FROM DAILYPAYMENT A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
	 	AND ( to_char(A.paydt, 'yyyymmdd')  >= :is_cutoffdt     )
	 	AND ( to_char(A.paydt, 'yyyymmdd')  <= :ls_saledt     )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_payamt) OR sqlca.sqlcode <> 0	then ldc_payamt	= 0
	
	SELECT SUM(A.PAYAMT)	  INTO :ldc_in2
	  FROM DAILYPAYMENTH A, regcodmst B
    WHERE (A.regcod								= b.regcod       )
	 	AND ( A.SHOPID  							= :ls_partner    )
	 	AND ( to_char(A.paydt, 'yyyymmdd')  >= :is_cutoffdt     )
	 	AND ( to_char(A.paydt, 'yyyymmdd')  <= :ls_saledt     )
	   AND ( A.paymethod  						= :ls_method[ll] )
		AND ( b.regtype 							Like :ls_shoptype   ) ;
	IF IsNUll(ldc_in2) OR sqlca.sqlcode <> 0	then ldc_in2	= 0

	ldc_payamt 		= ldc_payamt + ldc_in2
	ldc_total[ll] 	= ldc_payamt
NEXT


FOR ll = 3  to 5
	ldc_payamt = ldc_daily[ll]
	IF ldc_payamt <> 0 THEN
		wf_cut(ldc_payamt)
		choose case ll
		case 3
				dw_list.object.t_f31.Text = is_fm1
				dw_list.object.t_f32.Text = is_fm2
				dw_list.object.t_f33.Text = is_fm3
		case 4
				dw_list.object.t_f71.Text = is_fm1
				dw_list.object.t_f72.Text = is_fm2
				dw_list.object.t_f73.Text = is_fm3
		case 5
				dw_list.object.t_f21.Text = is_fm1
				dw_list.object.t_f22.Text = is_fm2
				dw_list.object.t_f23.Text = is_fm3
		end choose
	END IF
	
	ldc_payamt = ldc_total[ll]
	IF ldc_payamt <> 0 THEN
		wf_cut(ldc_payamt)

		choose case ll
		case 3
				dw_list.object.t_f34.Text = is_fm1
				dw_list.object.t_f35.Text = is_fm2
				dw_list.object.t_f36.Text = is_fm3
		case 4
				dw_list.object.t_f74.Text = is_fm1
				dw_list.object.t_f75.Text = is_fm2
				dw_list.object.t_f76.Text = is_fm3
		case 5
				dw_list.object.t_f24.Text = is_fm1
				dw_list.object.t_f25.Text = is_fm2
				dw_list.object.t_f26.Text = is_fm3
		end choose
	END IF
NEXT

dw_list.GroupCalc()
dw_list.Modify("DataWindow.Zoom=97")
triggerEvent("ue_preview_set")
//
return
//paymethod list END.........................


//Trigger Event ue_ok()




end event

event ue_zoom();call super::ue_zoom;//dw_list.object.datawindow.Zoom =   90
triggerEvent("ue_preview_set")
end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_report_daily
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

type p_ok from w_a_print`p_ok within ssrt_prt_report_daily
boolean visible = false
integer x = 2318
integer y = 60
end type

type p_close from w_a_print`p_close within ssrt_prt_report_daily
integer x = 2619
integer y = 60
end type

type dw_list from w_a_print`dw_list within ssrt_prt_report_daily
integer y = 260
integer width = 3232
integer height = 1348
string dataobject = "ssrt_prt_daily_report_ALL_1"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_report_daily
end type

type p_2 from w_a_print`p_2 within ssrt_prt_report_daily
end type

type p_3 from w_a_print`p_3 within ssrt_prt_report_daily
end type

type p_5 from w_a_print`p_5 within ssrt_prt_report_daily
end type

type p_6 from w_a_print`p_6 within ssrt_prt_report_daily
end type

type p_7 from w_a_print`p_7 within ssrt_prt_report_daily
end type

type p_8 from w_a_print`p_8 within ssrt_prt_report_daily
end type

type p_9 from w_a_print`p_9 within ssrt_prt_report_daily
end type

type p_4 from w_a_print`p_4 within ssrt_prt_report_daily
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_report_daily
end type

type p_port from w_a_print`p_port within ssrt_prt_report_daily
end type

type p_land from w_a_print`p_land within ssrt_prt_report_daily
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_report_daily
boolean visible = false
integer width = 2254
integer height = 240
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_report_daily
end type

