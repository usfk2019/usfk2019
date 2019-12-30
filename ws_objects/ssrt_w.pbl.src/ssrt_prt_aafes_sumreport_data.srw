$PBExportHeader$ssrt_prt_aafes_sumreport_data.srw
$PBExportComments$[kem] AAFES 캠프별 월별정산요약리포트
forward
global type ssrt_prt_aafes_sumreport_data from w_a_print
end type
type cb_process from commandbutton within ssrt_prt_aafes_sumreport_data
end type
end forward

global type ssrt_prt_aafes_sumreport_data from w_a_print
integer width = 3104
cb_process cb_process
end type
global ssrt_prt_aafes_sumreport_data ssrt_prt_aafes_sumreport_data

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

	ls_sql = " SELECT B.REGTYPE					                                 " + &				
		  		"      , TO_CHAR(A.PAYDT, 'DD') DAY	                            	" + &
				"  	 , SUM(DECODE(A.PAYMETHOD, '101', A.PAYAMT, 0)) CASH_AMT		" + &	
				"		 , SUM(DECODE(A.PAYMETHOD, '102', A.PAYAMT, 0)) CHECK_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '103', A.PAYAMT, 0)) CCARD_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '104', A.PAYAMT, 0)) MSTAR_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '105', A.PAYAMT, 0)) IMCARD_AMT	" + &
				"		 , SUM(DECODE(A.PAYMETHOD, '107', A.PAYAMT, 0)) GIFT_AMT		" + &
				"	 FROM DAILYPAYMENT A, REGCODMST_20111101 B		               " + &
				"	WHERE A.REGCOD = B.REGCOD													"
				
	ls_sql = ls_sql + ls_where 
				
	ls_sql = ls_sql + "	  AND B.REGTYPE = '" + ls_shoptype + "'								" + &
				"	  AND A.PAYDT BETWEEN TO_DATE('" + ls_fromdt + "','yyyymmdd') AND TO_DATE('" + ls_todt + "','yyyymmdd') " + &
				"  GROUP BY B.REGTYPE, TO_CHAR(A.PAYDT, 'DD') " + &
				"  ORDER BY B.REGTYPE, TO_CHAR(A.PAYDT, 'DD') "
	 
PREPARE SQLSA FROM :ls_sql;
OPEN DYNAMIC CUR_1;

Do While(True)
FETCH CUR_1 INTO :ls_type, :ls_day, :ldc_cash_amt, :ldc_check_amt, :ldc_ccard_amt,:ldc_mstar_amt, :ldc_imcard_amt, :ldc_gift_amt;

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
	FROM   REGCODMST_20111101 A, SHOP_KEY B
	WHERE  A.REGTYPE = B.REGTYPE
	AND    B.SHOPID  = :ls_shopid
	AND    A.REGTYPE = :ls_shoptype;

	If SQLCA.SQLCode <> 0 Then
		f_msg_sql_err(Title, " Facility Number Select error")
		Return -1
	End If
	
ElseIf ls_shopid = "" and ls_basecod <> "" Then
	
	SELECT DISTINCT B.KEYNUM 
	INTO   :ls_keynum
	FROM   REGCODMST_20111101 A, SHOP_KEY B
	WHERE  A.REGTYPE = B.REGTYPE
	AND    B.SHOPID  IN (SELECT PARTNER FROM PARTNERMST WHERE BASECOD = :ls_basecod)
	AND    A.REGTYPE = :ls_shoptype;

	If SQLCA.SQLCode <> 0 Then
		f_msg_sql_err(Title, " Facility Number Select error")
		Return -1
	End If
End If
dw_list.Object.Keynum[1] = ls_keynum
dw_list.SetReDraw(True)

Return ll_row
end function

event ue_ok;call super::ue_ok;Long 		ll_row, ll_cnt
String 	ls_where, ls_basecod, ls_shopid, ls_shoptype, ls_issuedt, ls_fromdt, ls_todt, ls_month
String   ls_paymethod1, ls_paymethod2, ls_paymethod3, ls_paymethod4, ls_paymethod5, ls_paymethod6
//#6269 2013.12.09 김선주 추가 
String   ls_contractfee, ls_ref_desc 


ls_basecod     = Trim(dw_cond.Object.basecod[1])
ls_shoptype		= Trim(dw_cond.Object.shoptype[1])
ls_issuedt 		= String(dw_cond.Object.issuedt[1],'yyyymm')
ls_fromdt 		= String(dw_cond.Object.fromdt[1],'yyyymmdd')
ls_todt	 		= String(dw_cond.Object.todt[1],'yyyymmdd')

If IsNull(ls_basecod) 	Then ls_basecod	= ""
If IsNull(ls_shoptype)	Then ls_shoptype	= ""
If IsNull(ls_issuedt)	Then ls_issuedt	= ""
If IsNull(ls_fromdt)		Then ls_fromdt	   = ""
If IsNull(ls_todt) 		Then ls_todt		= ""

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

//#6269 2013.12.09 김선주 추가
//조회시에, fee 타이틀에, shoptype에 따라, %를 보여달라는 요청사항 반영. 
ls_ref_desc = "" 
If ls_shoptype = '01' Then  //INTERNET
	ls_contractfee	= fs_get_control("R1", "R130", ls_ref_desc) // 11.4% : contract fee
	dw_list.Object.t_contractfee.Text = 'Fee(' +ls_contractfee + '%)'
	
ElseIf ls_shoptype = '02' Then  //INTERNET                       //MOBILE  
	ls_contractfee	= fs_get_control("R1", "R160", ls_ref_desc) // 10.4% : contract fee
	dw_list.Object.t_contractfee.Text = 'Fee(' +ls_contractfee + '%)'
Else
	   dw_list.Object.t_contractfee.Text = 'Fee'
End If



/* [#5997] 2013.11.19 김선주, 아래의 로직을 막고, argument로 넘겨서, 처리하도록 수정함.
If ls_basecod <> "" Then
	If ls_where <> "" Then ls_where += " And "	
	ls_where += " SD.BASECOD = '" + ls_basecod + "' "
End If

If ls_shoptype <> "" Then
	If ls_where <> "" Then ls_where += " And "
   ls_where += " SHOP_TYPE = '" + ls_shoptype + "'"
End If

If ls_fromdt <> "" And ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "	
   ls_where += " to_char(cutoff_dt,'yyyymmdd') >= '" + ls_fromdt + "'"
	ls_where += " AND to_char(cutoff_dt,'yyyymmdd') <= '" + ls_todt + "' " 
Else
	f_msg_info(200, Title, "Sales Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("issuedt")
	Return 
End If  */	

dw_list.Reset()

SetPointer(Hourglass!)

//[#5997] 2013.11.19 김선주 막고, 아래와 같이 argument로 처리함. 
//dw_list.is_where = ls_where [#5997] 2013.11.19 김선주 막음. 
//ll_row = dw_list.Retrieve(ls_basecod, ls_shoptype,ls_fromdt,ls_todt)

ll_row = dw_list.Retrieve(ls_basecod, ls_shoptype,ls_fromdt,ls_todt)

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If



dw_list.Object.salesdt_t.Text = String(dw_cond.Object.fromdt[1],'mm/dd/yyyy') + " - " + &
                              String(dw_cond.Object.todt[1],'mm/dd/yyyy')
//dw_list.Object.shop_type_t.Text = dw_cond.describe("Evaluate('LookUpDisplay(shoptype)'," + "1" +")") 

If ls_shoptype = '01' Then
	dw_list.Object.shop_type_t.Text = "Telecom"
ElseIF ls_shoptype = '02' Then
	dw_list.Object.shop_type_t.Text = "Mobile"
ELSE	
	dw_list.Object.shop_type_t.Text = "CATV"
End If

dw_list.Modify("DataWindow.Zoom=70")
ii_orientation = 1
triggerEvent("ue_preview_set")
dw_list.object.datawindow.Zoom = 70;

SetPointer(Arrow!)
end event

event ue_saveas_init;ib_saveas = True
//idw_saveas = dw_list

end event

on ssrt_prt_aafes_sumreport_data.create
int iCurrent
call super::create
this.cb_process=create cb_process
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_process
end on

on ssrt_prt_aafes_sumreport_data.destroy
call super::destroy
destroy(this.cb_process)
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False

end event

event ue_saveas;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

string ls_salesdt

ls_salesdt = String(dw_cond.Object.issuedt[1],'yyyymm') 

f_excel_ascii1(dw_list, "aafes_sumreport_data_"+ls_salesdt)


//dw_list.SaveAsAscii("D:\ssrt.xls","~t","")



//MESSAGEBOX("CHECK22","1")
end event

event open;call super::open;string ls_contractfee, ls_regtype, ls_ref_desc

dw_cond.object.issuedt[1] 				= Date(fdt_get_dbserver_now())



end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_aafes_sumreport_data
integer x = 50
integer y = 64
integer height = 256
string dataobject = "ssrt_cnd_prt_aafes_sumreport_data"
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

event dw_cond::itemerror;call super::itemerror;return 1 
end event

type p_ok from w_a_print`p_ok within ssrt_prt_aafes_sumreport_data
integer x = 2427
integer y = 56
end type

type p_close from w_a_print`p_close within ssrt_prt_aafes_sumreport_data
integer x = 2734
integer y = 56
end type

type dw_list from w_a_print`dw_list within ssrt_prt_aafes_sumreport_data
integer x = 23
integer y = 360
integer height = 1236
string dataobject = "ssrt_prt_aafes_sumreport_data"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_aafes_sumreport_data
end type

type p_2 from w_a_print`p_2 within ssrt_prt_aafes_sumreport_data
end type

type p_3 from w_a_print`p_3 within ssrt_prt_aafes_sumreport_data
end type

type p_5 from w_a_print`p_5 within ssrt_prt_aafes_sumreport_data
end type

type p_6 from w_a_print`p_6 within ssrt_prt_aafes_sumreport_data
end type

type p_7 from w_a_print`p_7 within ssrt_prt_aafes_sumreport_data
end type

type p_8 from w_a_print`p_8 within ssrt_prt_aafes_sumreport_data
end type

type p_9 from w_a_print`p_9 within ssrt_prt_aafes_sumreport_data
end type

type p_4 from w_a_print`p_4 within ssrt_prt_aafes_sumreport_data
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_aafes_sumreport_data
end type

type p_port from w_a_print`p_port within ssrt_prt_aafes_sumreport_data
end type

type p_land from w_a_print`p_land within ssrt_prt_aafes_sumreport_data
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_aafes_sumreport_data
integer y = 20
integer width = 2277
integer height = 312
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_aafes_sumreport_data
end type

type cb_process from commandbutton within ssrt_prt_aafes_sumreport_data
integer x = 2432
integer y = 188
integer width = 576
integer height = 104
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Summary Process"
end type

event clicked;Long 		ll_return
Double   ldb_count
String 	ls_where, ls_pgm_id, ls_errmsg, ls_issuedt, ls_fromdt, ls_todt, ls_today


ls_issuedt 		= String(dw_cond.Object.issuedt[1],'yyyymm')
ls_fromdt 		= String(dw_cond.Object.fromdt[1],'yyyymmdd')
ls_todt	 		= String(dw_cond.Object.todt[1],'yyyymmdd')

ls_today  	= string(Date(fdt_get_dbserver_now()), 'yyyymmdd')

If IsNull(ls_issuedt)	Then ls_issuedt	= ""
If IsNull(ls_fromdt)		Then ls_fromdt	   = ""
If IsNull(ls_todt) 		Then ls_todt		= ""

If ls_issuedt = "" Then
	f_msg_info(200, Title, "Sales Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("issuedt")
	Return 
End If

If ls_fromdt = "" Or ls_todt = "" Then
	f_msg_info(200, Title, "Sales Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("issuedt")
	Return 
End If

//ls_pgm_id 				= gs_pgm_id[gi_open_win_no]

ll_return = -1
ls_errmsg = space(1000)
ldb_count  = 0

SetPointer (HourGlass!)

//처리부분...
IF ls_issuedt >= '201701' THEN //CATV 추가
	SQLCA.PRC_AAFES_SUMREPORT_DATA_CATV(ls_fromdt, gs_user_id, ll_return, ls_errmsg, ldb_count)
ELSE
	SQLCA.PRC_AAFES_SUMREPORT_DATA(ls_fromdt, gs_user_id, ll_return, ls_errmsg, ldb_count)
END IF

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg)
End If	

SetPointer (Arrow!)

If ll_return <> 0 Then	//실패
	//is_msg_process = "Fail"
	f_msg_info(3001,Title,"Settlement Summary Fail");
	Return -1
Else				//성공
	//is_msg_process = String(lb_count, "#,##0") + " Hit(s)"
	f_msg_info(3000,Title,"Settlement Summary Count:" + String(ldb_count, "#,##0") + " Hits(s)");
	Return 0
End If


end event

