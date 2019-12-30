$PBExportHeader$ssrt_prt_paymethod_dailysale.srw
$PBExportComments$[kem] 결제방법별 Daily Report
forward
global type ssrt_prt_paymethod_dailysale from w_a_print
end type
end forward

global type ssrt_prt_paymethod_dailysale from w_a_print
end type
global ssrt_prt_paymethod_dailysale ssrt_prt_paymethod_dailysale

forward prototypes
public function long wf_set_sqlselect ()
end prototypes

public function long wf_set_sqlselect ();String ls_sql, ls_where, ls_basecod, ls_shopid, ls_shoptype, ls_issuedt, ls_fromdt, ls_todt, ls_keynum
String ls_paymethod1, ls_paymethod2, ls_paymethod3, ls_paymethod4, ls_paymethod5, ls_paymethod6
String ls_shop, ls_type, ls_day, ls_amt1, ls_amt2, ls_amt3, ls_mon, ls_month, ls_tt1, ls_tt2, ls_tt3
Dec    ldc_cash_amt, ldc_check_amt, ldc_ccard_amt, ldc_mstar_amt, ldc_imcard_amt, ldc_gift_amt
Long   ll_row, ll_foundrow, ll_check
Date   ldt_fromdt, ldt_todt


ls_basecod     = Trim(dw_cond.Object.basecod[1])
ls_shopid 		= Trim(dw_cond.Object.partner[1])
ls_shoptype		= Trim(dw_cond.Object.shoptype[1])
ls_issuedt 		= String(dw_cond.Object.issuedt[1],'yyyymm')
ls_mon	      = String(dw_cond.Object.issuedt[1],'mmm')
ldt_fromdt 		= dw_cond.Object.fromdt[1]
ldt_todt			= dw_cond.Object.todt[1]
ls_fromdt 		= String(dw_cond.Object.fromdt[1],'yyyymmdd')
ls_todt	 		= String(dw_cond.Object.todt[1],'yyyymmdd')
ls_paymethod1	= Trim(dw_cond.Object.paymethod1[1])
ls_paymethod2	= Trim(dw_cond.Object.paymethod2[1])
ls_paymethod3	= Trim(dw_cond.Object.paymethod3[1])
ls_paymethod4	= Trim(dw_cond.Object.paymethod4[1])
ls_paymethod5	= Trim(dw_cond.Object.paymethod5[1])
ls_paymethod6	= Trim(dw_cond.Object.paymethod6[1])

If IsNull(ls_basecod) 	Then ls_basecod	= ""
If IsNull(ls_shopid) 	Then ls_shopid	   = ""
If IsNull(ls_shoptype)	Then ls_shoptype	= ""
If IsNull(ls_issuedt)	Then ls_issuedt	= ""
If IsNull(ls_fromdt)		Then ls_fromdt	   = ""
If IsNull(ls_todt) 		Then ls_todt		= ""
If IsNull(ls_paymethod1) 	Then ls_paymethod1	= ""
If IsNull(ls_paymethod2)	Then ls_paymethod2	= ""
If IsNull(ls_paymethod3)	Then ls_paymethod3	= ""
If IsNull(ls_paymethod4)	Then ls_paymethod4	= ""
If IsNull(ls_paymethod5)	Then ls_paymethod5	= ""
If IsNull(ls_paymethod6)	Then ls_paymethod6	= ""

If ls_shopid = "" And ls_basecod <> "" Then
	ls_where = " AND A.SHOPID IN (SELECT PARTNER FROM PARTNERMST WHERE BASECOD = '" + ls_basecod + "') "
Else
	ls_where = " AND A.SHOPID = '" + ls_shopid + "' "
End If

dw_list.SetReDraw(False) 

DO WHILE ldt_fromdt <= ldt_todt
	//messagebox('날짜', String(ldt_fromdt,'yyyymmdd'))
	ll_row = dw_list.InsertRow(0)
	
	dw_list.Object.day[ll_row] = String(ldt_fromdt,'dd')
	ldt_fromdt = fd_date_next(ldt_fromdt, 1)
Loop

DECLARE CUR_1 DYNAMIC CURSOR FOR SQLSA;

//	ls_sql = " SELECT B.REGTYPE					                                 " + &				
//		  		"      , TO_CHAR(A.PAYDT, 'DD') DAY	                            	" + &
//				"  	 , SUM(DECODE(A.PAYMETHOD, '101', A.PAYAMT, 0)) CASH_AMT		" + &	
//				"		 , SUM(DECODE(A.PAYMETHOD, '102', A.PAYAMT, 0)) CHECK_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '103', A.PAYAMT, 0)) CCARD_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '104', A.PAYAMT, 0)) MSTAR_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '105', A.PAYAMT, 0)) IMCARD_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '107', A.PAYAMT, 0)) GIFT_AMT		" + &
//				"	 FROM DAILYPAYMENT A, REGCODMST_20111101 B		               " + &
//				"	WHERE A.REGCOD = B.REGCOD													"
//				
//	ls_sql = ls_sql + ls_where 
//				
//	ls_sql = ls_sql + "	  AND B.REGTYPE = '" + ls_shoptype + "'								" + &
//				"	  AND A.PAYDT BETWEEN TO_DATE('" + ls_fromdt + "','yyyymmdd') AND TO_DATE('" + ls_todt + "','yyyymmdd') " + &
//				"  GROUP BY B.REGTYPE, TO_CHAR(A.PAYDT, 'DD') " + &
//				"  ORDER BY B.REGTYPE, TO_CHAR(A.PAYDT, 'DD') "
//	 
//	 
//PREPARE SQLSA FROM :ls_sql;
//OPEN DYNAMIC CUR_1;
//
//Do While(True)
//FETCH CUR_1 INTO :ls_type, :ls_day, :ldc_cash_amt, :ldc_check_amt, :ldc_ccard_amt,:ldc_mstar_amt, :ldc_imcard_amt, :ldc_gift_amt;
//


//	ls_sql = " SELECT TO_CHAR(A.PAYDT, 'DD') DAY	                            	" + &
//				"  	 , SUM(DECODE(A.PAYMETHOD, '101', A.PAYAMT, 0)) CASH_AMT		" + &	
//				"		 , SUM(DECODE(A.PAYMETHOD, '102', A.PAYAMT, 0)) CHECK_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '103', A.PAYAMT, 0)) CCARD_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '104', A.PAYAMT, 0)) MSTAR_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '105', A.PAYAMT, 0)) IMCARD_AMT	" + &
//				"		 , SUM(DECODE(A.PAYMETHOD, '107', A.PAYAMT, 0)) GIFT_AMT		" + &
//				"	 FROM DAILYPAYMENT A, REGCODMST B		               " + &
//				"	WHERE A.REGCOD = B.REGCOD													"

// 2019.05.07 Vat Add 추가 Modified by Han
	ls_sql = " SELECT TO_CHAR(A.PAYDT, 'DD') DAY	                            	" + &
				"  	 , SUM(DECODE(A.PAYMETHOD, '101', A.PAYAMT + NVL(A.TAXAMT,0), 0)) CASH_AMT		" + &	
				"		 , SUM(DECODE(A.PAYMETHOD, '102', A.PAYAMT + NVL(A.TAXAMT,0), 0)) CHECK_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '103', A.PAYAMT + NVL(A.TAXAMT,0), 0)) CCARD_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '104', A.PAYAMT + NVL(A.TAXAMT,0), 0)) MSTAR_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '105', A.PAYAMT + NVL(A.TAXAMT,0), 0)) IMCARD_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '107', A.PAYAMT + NVL(A.TAXAMT,0), 0)) GIFT_AMT		" + &
				"	 FROM DAILYPAYMENT A, REGCODMST B		               " + &
				"	WHERE A.REGCOD = B.REGCOD													"

	ls_sql = ls_sql + ls_where 
				
ls_sql = ls_sql + "	  AND B.REGTYPE like '" + ls_shoptype + "'								" + &
				"	  AND A.PAYDT BETWEEN TO_DATE('" + ls_fromdt + "','yyyymmdd') AND TO_DATE('" + ls_todt + "','yyyymmdd') " + &
				"  GROUP BY TO_CHAR(A.PAYDT, 'DD') " + &
				"  ORDER BY TO_CHAR(A.PAYDT, 'DD') "
	 
PREPARE SQLSA FROM :ls_sql;
OPEN DYNAMIC CUR_1;

Do While(True)
FETCH CUR_1 INTO  :ls_day, :ldc_cash_amt, :ldc_check_amt, :ldc_ccard_amt,:ldc_mstar_amt, :ldc_imcard_amt, :ldc_gift_amt;

	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "CUR_1")
		CLOSE cur_1;
		Return -1
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	ll_check = 0
	
	//ll_row = dw_list.InsertRow(0)
	//dw_list.Object.day[ll_row] = ls_day
	
	ll_foundrow = dw_list.Find("day = '" + ls_day + "'", 1, dw_list.RowCount())
	//messagebox(ls_day, ll_foundrow)
	
	If ls_paymethod1 = '1' Then
		dw_list.Object.amt1[ll_foundrow] = ldc_cash_amt
		ls_amt1 = 'Cash Sales'
		ls_tt1  = 'Cash'
		ll_check ++
	End If
	
	If ls_paymethod2 = '1' Then
		If ls_paymethod1 = '1' Then
			dw_list.Object.amt2[ll_foundrow] = ldc_check_amt
			ls_amt2 = 'Check Sales'
			ls_tt2  = ' && Check '
		Else
			dw_list.Object.amt1[ll_foundrow] = ldc_check_amt
			ls_amt1 = 'Check Sales'
			ls_tt1  = 'Check'
		End If
		ll_check ++
	End If
	
	If ls_paymethod3 = '1' Then
		If ls_paymethod1 = '1' AND ls_paymethod2 = '1' Then
			dw_list.Object.amt3[ll_foundrow] = ldc_ccard_amt
			ls_amt3 = 'Credit card Sales'
			ls_tt3  = ' && Credit card '
		ElseIf ls_paymethod1 = '1' OR ls_paymethod2 = '1' Then
			dw_list.Object.amt2[ll_foundrow] = ldc_ccard_amt
			ls_amt2 = 'Credit card Sales'
			ls_tt2  = ' && Credit card'	
		Else
			dw_list.Object.amt1[ll_foundrow] = ldc_ccard_amt
			ls_amt1 = 'Credit card Sales'
			ls_tt1  = 'Credit card'
		End If
		ll_check ++
	End If
			
	If ll_check <> 3 AND ls_paymethod4 = '1' Then
		If ll_check = 2 Then
			dw_list.Object.amt3[ll_foundrow] = ldc_mstar_amt
			ls_amt3 = 'Military Star Sales'
			ls_tt3  = ' && Military Star '
		ElseIf ll_check  = 1 Then
			dw_list.Object.amt2[ll_foundrow] = ldc_mstar_amt
			ls_amt2 = 'Military Star Sales'
			ls_tt2  = ' && Military Star '
		Else
			dw_list.Object.amt1[ll_foundrow] = ldc_mstar_amt
			ls_amt1 = 'Military Star Sales'
			ls_tt1  = 'Military Star'
		End If
		ll_check ++
	End If		
	
	If ll_check <> 3 AND ls_paymethod5 = '1' Then
		If ll_check = 2 Then
			dw_list.Object.amt3[ll_foundrow] = ldc_imcard_amt
			ls_amt3 = 'IMPACT card Sales'
			ls_tt3  = ' && IMPACT card '
		ElseIf ll_check = 1 Then
			dw_list.Object.amt2[ll_foundrow] = ldc_imcard_amt
			ls_amt2 = 'IMPACT card Sales'
			ls_tt2  = ' && IMPACT card '
		Else
			dw_list.Object.amt1[ll_foundrow] = ldc_imcard_amt
			ls_amt1 = 'IMPACT card Sales'
			ls_tt1  = 'IMPACT card'
		End If
		ll_check ++
	End If	
	
	If ll_check <> 3 AND ls_paymethod6 = '1' Then
		If ll_check = 2 Then
			dw_list.Object.amt3[ll_foundrow] = ldc_gift_amt
			ls_amt3 = 'Gift card Sales'
			ls_tt3  = ' && Gift card '
		ElseIf ll_check = 1 Then
			dw_list.Object.amt2[ll_foundrow] = ldc_gift_amt
			ls_amt2 = 'Gift card Sales'
			ls_tt2  = ' && Gift card '
		Else
			dw_list.Object.amt1[ll_foundrow] = ldc_gift_amt
			dw_list.Object.amt2[ll_foundrow] = 0
			ls_amt1 = 'Gift card Sales'
			ls_tt1  = 'Gift card'
		End If
		ll_check ++
	End If
	
	If ll_check = 2 Then
		dw_list.Object.amt3[ll_foundrow] = 0
		ls_amt3 = ''
		ls_tt3  = ' '
	ElseIf ll_check = 1 Then
		dw_list.Object.amt3[ll_foundrow] = 0
		ls_amt3 = ''
		ls_tt3  = ' '
		dw_list.Object.amt2[ll_foundrow] = 0
		ls_amt2 = ''
		ls_tt2  = ' '
	End If
	
Loop
CLOSE CUR_1;

//월 변환 로직
If ls_mon = 'Jan' Then
	ls_month = 'January'
ElseIf ls_mon = 'Feb' Then
	ls_month = 'February'
ElseIf ls_mon = 'Mar' Then
	ls_month = 'March'
ElseIf ls_mon = 'Apr' Then
	ls_month = 'April'
ElseIf ls_mon = 'May' Then
	ls_month = 'May'
ElseIf ls_mon = 'Jun' Then
	ls_month = 'June'
ElseIf ls_mon = 'Jul' Then
	ls_month = 'July'
ElseIf ls_mon = 'Aug' Then
	ls_month = 'August'
ElseIf ls_mon = 'Sep' Then
	ls_month = 'September'
ElseIf ls_mon = 'Oct' Then
	ls_month = 'October'
ElseIf ls_mon = 'Nov' Then
	ls_month = 'November'
ElseIf ls_mon = 'Dec' Then
	ls_month = 'December'
Else
	ls_month = ''
End If


dw_list.Object.amt1_t.text = ls_amt1
dw_list.Object.amt2_t.text = ls_amt2
dw_list.Object.amt3_t.text = ls_amt3
dw_list.Object.month_t.text = 'Month of ' + ls_month
dw_list.Object.Title_t.text = ls_tt1 + ls_tt2 + ls_tt3


If ls_shopid <> "" Then
	
	SELECT DISTINCT B.KEYNUM 
	INTO   :ls_keynum
	//		BY HMK 2015/11/20
	//FROM   REGCODMST_20111101 A, SHOP_KEY B
	FROM   REGCODMST A, SHOP_KEY B
	WHERE  A.REGTYPE = B.REGTYPE
	AND    B.SHOPID  = :ls_shopid
	AND    A.REGTYPE like :ls_shoptype
	AND    rownum = 1;

	If SQLCA.SQLCode <> 0 Then
		f_msg_sql_err(Title, " Facility Number Select error")
		Return -1
	End If
	
ElseIf ls_shopid = "" and ls_basecod <> "" Then
	
	SELECT DISTINCT B.KEYNUM 
	INTO   :ls_keynum
	//		BY HMK 2015/11/20
	//FROM   REGCODMST_20111101 A, SHOP_KEY B
	FROM   REGCODMST A, SHOP_KEY B
	WHERE  A.REGTYPE = B.REGTYPE
	AND    B.SHOPID  IN (SELECT PARTNER FROM PARTNERMST WHERE BASECOD = :ls_basecod)
	AND    A.REGTYPE like :ls_shoptype
	AND    rownum = 1;

	If SQLCA.SQLCode <> 0 Then
		f_msg_sql_err(Title, " Facility Number Select error")
		Return -1
	End If
End If

if ls_shoptype = '%' then ls_keynum = 'ALL' 

dw_list.Object.Keynum[1] = ls_keynum
dw_list.SetReDraw(True)

Return ll_row
end function

event ue_ok();call super::ue_ok;Long 		ll_row, ll_cnt
String 	ls_where, ls_basecod, ls_shopid, ls_shoptype, ls_issuedt, ls_fromdt, ls_todt, ls_month
String   ls_paymethod1, ls_paymethod2, ls_paymethod3, ls_paymethod4, ls_paymethod5, ls_paymethod6


ls_basecod     = Trim(dw_cond.Object.basecod[1])
ls_shopid 		= Trim(dw_cond.Object.partner[1])
ls_shoptype		= Trim(dw_cond.Object.shoptype[1])
ls_issuedt 		= String(dw_cond.Object.issuedt[1],'yyyymm')
ls_fromdt 		= String(dw_cond.Object.fromdt[1],'yyyymmdd')
ls_todt	 		= String(dw_cond.Object.todt[1],'yyyymmdd')
ls_paymethod1	= Trim(dw_cond.Object.paymethod1[1])
ls_paymethod2	= Trim(dw_cond.Object.paymethod2[1])
ls_paymethod3	= Trim(dw_cond.Object.paymethod3[1])
ls_paymethod4	= Trim(dw_cond.Object.paymethod4[1])
ls_paymethod5	= Trim(dw_cond.Object.paymethod5[1])
ls_paymethod6	= Trim(dw_cond.Object.paymethod6[1])

If IsNull(ls_basecod) 	Then ls_basecod	= ""
If IsNull(ls_shopid) 	Then ls_shopid	   = ""
If IsNull(ls_shoptype)	Then ls_shoptype	= ""
If IsNull(ls_issuedt)	Then ls_issuedt	= ""
If IsNull(ls_fromdt)		Then ls_fromdt	   = ""
If IsNull(ls_todt) 		Then ls_todt		= ""
If IsNull(ls_paymethod1) 	Then ls_paymethod1	= ""
If IsNull(ls_paymethod2)	Then ls_paymethod2	= ""
If IsNull(ls_paymethod3)	Then ls_paymethod3	= ""
If IsNull(ls_paymethod4)	Then ls_paymethod4	= ""
If IsNull(ls_paymethod5)	Then ls_paymethod5	= ""
If IsNull(ls_paymethod6)	Then ls_paymethod6	= ""

If ls_basecod = "" And ls_shopid = "" Then
	f_msg_info(200, Title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return 
End If

If ls_shoptype = "" Then
	f_msg_info(200, Title, "Shop Type")
	dw_cond.SetFocus()
	dw_cond.SetColumn("shoptype")
	Return 
End If

If ls_issuedt = "" Then
	f_msg_info(200, Title, "Sales Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("issuedt")
	Return 
End If

If ls_paymethod1 <> "1" AND ls_paymethod2 <> "1" AND ls_paymethod3 <> "1" AND ls_paymethod4 <> "1" AND ls_paymethod5 <> "1" AND ls_paymethod6 <> "1" Then
	f_msg_info(200, Title, "Paymethod")
	dw_cond.SetFocus()
	dw_cond.SetColumn("paymethod1")
	Return 
Else
	If ls_paymethod1 = '1' Then
		ll_cnt ++
	End If
	If ls_paymethod2 = '1' Then
		ll_cnt ++
	End If
	If ls_paymethod3 = '1' Then
		ll_cnt ++
	End If
	If ls_paymethod4 = '1' Then
		ll_cnt ++
	End If
	If ls_paymethod5 = '1' Then
		ll_cnt ++
	End If
	If ls_paymethod6 = '1' Then
		ll_cnt ++
	End If
	
	If ll_cnt > 3 Then
		f_msg_info(9000, Title, "Paymethod 선택은 최대 세가지만 선택할 수 있습니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("Paymethod1")
		Return
	End If	
End If

dw_list.Reset()

SetPointer(Hourglass!)

ll_row = wf_set_sqlselect()


//ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If

SetPointer(Arrow!)


end event

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_list
end event

on ssrt_prt_paymethod_dailysale.create
call super::create
end on

on ssrt_prt_paymethod_dailysale.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list, "ssrt_prt_paymethod_dailysale")

end event

event open;call super::open;dw_cond.object.issuedt[1] 				= Date(fdt_get_dbserver_now())

//shoptype에 All 조건 추가 2014/08/05 BY HMK
DataWindowChild state_child
integer rtncode
long ll_row

rtncode = dw_cond.GetChild('shoptype', state_child)
IF rtncode = -1 THEN MessageBox( "Error", "Not a DataWindowChild")

ll_row = state_child.Insertrow(0)
state_child.setitem(ll_row, 'codenm', 'ALL')
state_child.setitem(ll_row, 'code', '%')

CONNECT USING SQLCA;
state_child.SetTransObject(SQLCA)
//shoptype에 All 조건 추가 2014/08/05 BY HMK

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_paymethod_dailysale
integer x = 50
integer y = 64
integer width = 2290
integer height = 452
string dataobject = "ssrt_cnd_prt_paymethod_dailysale"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;Date ldt_fromdt, ldt_todt

If dwo.name = 'issuedt' Then
	ldt_fromdt = f_mon_first_date(Date(data))
	ldt_todt   = f_mon_last_date(Date(data))
	dw_cond.Object.fromdt[1] = ldt_fromdt
	dw_cond.Object.todt[1]   = ldt_todt
End If
end event

type p_ok from w_a_print`p_ok within ssrt_prt_paymethod_dailysale
integer y = 56
end type

type p_close from w_a_print`p_close within ssrt_prt_paymethod_dailysale
integer x = 2770
integer y = 56
end type

type dw_list from w_a_print`dw_list within ssrt_prt_paymethod_dailysale
integer x = 23
integer y = 556
integer height = 1076
string dataobject = "ssrt_prt_paymethod_dailysale"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_paymethod_dailysale
end type

type p_2 from w_a_print`p_2 within ssrt_prt_paymethod_dailysale
end type

type p_3 from w_a_print`p_3 within ssrt_prt_paymethod_dailysale
end type

type p_5 from w_a_print`p_5 within ssrt_prt_paymethod_dailysale
end type

type p_6 from w_a_print`p_6 within ssrt_prt_paymethod_dailysale
end type

type p_7 from w_a_print`p_7 within ssrt_prt_paymethod_dailysale
end type

type p_8 from w_a_print`p_8 within ssrt_prt_paymethod_dailysale
end type

type p_9 from w_a_print`p_9 within ssrt_prt_paymethod_dailysale
end type

type p_4 from w_a_print`p_4 within ssrt_prt_paymethod_dailysale
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_paymethod_dailysale
end type

type p_port from w_a_print`p_port within ssrt_prt_paymethod_dailysale
end type

type p_land from w_a_print`p_land within ssrt_prt_paymethod_dailysale
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_paymethod_dailysale
integer y = 20
integer width = 2322
integer height = 508
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_paymethod_dailysale
end type

