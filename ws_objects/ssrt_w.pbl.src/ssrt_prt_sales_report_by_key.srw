$PBExportHeader$ssrt_prt_sales_report_by_key.srw
$PBExportComments$ssrt sales report - Group by
forward
global type ssrt_prt_sales_report_by_key from w_a_print
end type
end forward

global type ssrt_prt_sales_report_by_key from w_a_print
end type
global ssrt_prt_sales_report_by_key ssrt_prt_sales_report_by_key

type variables
String is_option = '1', is_shopid
end variables

on ssrt_prt_sales_report_by_key.create
call super::create
end on

on ssrt_prt_sales_report_by_key.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;//조회
String 	ls_saledt_fr, ls_saledt_to, ls_operator, ls_partner, &
			ls_date, ls_where, 	ls_date_to,		ls_partnernm, ls_shoptype, &
			ls_option
Long		ll_row

ls_saledt_fr    	= String(dw_cond.object.saledt_fr[1], 'yyyymmdd')
ls_saledt_to    	= String(dw_cond.object.saledt_to[1], 'yyyymmdd')
ls_partner      	= Trim(dw_cond.object.partner[1])
ls_operator 		= Trim(dw_cond.object.operator[1])
ls_shoptype       = Trim(dw_cond.object.shoptype[1])
ls_option			= Trim(dw_cond.object.option[1])
is_shopid =  ls_partner

If IsNull(ls_shoptype)     Then ls_shoptype = ""
If IsNull(ls_saledt_fr)    Then ls_saledt_fr = ""
If IsNull(ls_saledt_to)    Then ls_saledt_to = ""
If IsNull(ls_partner)    	Then ls_partner = ""
If IsNull(ls_operator)      Then ls_operator = ""

If ls_saledt_fr = "" Then 
	f_msg_info(200, title, "Sales date - from")
	dw_cond.SetFocus()
	dw_cond.SetColumn("saledt_fr")
	Return
End If
If ls_saledt_to = "" Then 
	f_msg_info(200, title, "sales date - to")
	dw_cond.SetFocus()
	dw_cond.SetColumn("saledt_to")
	Return
End If

If ls_saledt_fr > ls_saledt_to Then
	f_msg_info(200, title, "sales date (to)를 확인하세요.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("saledt_to")
	Return
End If


If ls_partner = "" Then 
	f_msg_info(200, title, "Partner")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

IF ls_option = '1' THEN
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.REGCOD = B.REGCOD "
ELSEIF ls_option = '4' THEN	
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.SHOPID = B.SHOPID AND A.REGCOD = B.REGCOD "	
ELSEIF ls_option = '6' THEN
	If ls_where <> "" Then ls_where += " And "
	ls_where += " A.CUSTOMERID = B.CUSTOMERID "	
END IF

If ls_saledt_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	IF ls_option = '1' OR ls_option = '4' OR ls_option = '6' THEN
		ls_where += " a.paydt >= TO_DATE('" + ls_saledt_fr + "', 'YYYYMMDD') "	
	ELSE
		ls_where += " paydt >= TO_DATE('" + ls_saledt_fr + "', 'YYYYMMDD') "
	END IF
End If

If ls_saledt_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	IF ls_option = '1' OR ls_option = '4' OR ls_option = '6' THEN
		ls_where += " a.paydt <= TO_DATE('" + ls_saledt_to + "', 'YYYYMMDD') "	
	ELSE
		ls_where += " paydt <= TO_DATE('" + ls_saledt_to + "', 'YYYYMMDD') "
	END IF
End If

If ls_shoptype <> "" AND ls_shoptype <> "00" Then
	If ls_where <> "" Then ls_where += " And "
	IF ls_option = '1' OR ls_option = '4' OR ls_option = '6' THEN
		ls_where += " a.regcod in (select regcod from regcodmst where regtype = '" + ls_shoptype + "') "
	ELSE
		ls_where += " regcod in (select regcod from regcodmst where regtype = '" + ls_shoptype + "') "	
	END IF
End If

ls_date    = MidA(ls_saledt_fr,1,4) + "-" +  MidA(ls_saledt_fr, 5,2)+ "-" +  MidA(ls_saledt_fr, 7,2) 
ls_date_to = MidA(ls_saledt_to,1,4) + "-" +  MidA(ls_saledt_to, 5,2)+ "-" +  MidA(ls_saledt_to, 7,2)
ls_partnernm 	= dw_cond.describe("Evaluate('LookUpDisplay(partner)'," + "1" +")") 

dw_list.object.t_date.Text 		= ls_date
dw_list.object.t_date_to.Text 	= ls_date_to
dw_list.object.t_shop.Text 		= ls_partnernm
//dw_list.object.t_operator.Text 	= ls_operator

If ls_operator <> "" Then
	If ls_where <> "" Then ls_where += " And "
	IF ls_option = '1' OR ls_option = '4' OR ls_option = '6' THEN
		ls_where += "a.operator = '" + ls_operator + "' "
	ELSE
		ls_where += "operator = '" + ls_operator + "' "
	END IF
End If
//
If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	IF ls_option = '1' OR ls_option = '4' OR ls_option = '6' THEN
		ls_where += "a.shopid = '" + ls_partner + "' "
	ELSE
		ls_where += "shopid = '" + ls_partner + "' "
	END IF
End If


//조건 Setting
SetPointer(HourGlass!)
dw_list.SetRedraw(False)
dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve(ls_saledt_fr, ls_saledt_to)
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	dw_list.SetRedraw(True)
	Return 
End If

dw_list.SetRedraw(True)
SetPointer(Arrow!)




end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 0 //세로0, 가로1
ib_margin = False
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	ssrt_prt_sales_report_by_key
	Desc.	: 	sales report
	Ver.	:	1.0
	Date	:	2007-7-23
	Programer : 1hera
--------------------------------------------------------------------------*/

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset;call super::ue_reset;STRING	ls_ref_desc,		ls_sql
INT		li_rc
LONG		ll_row
DEC{2}	ldc_cash_hand
DataWindowChild	ldwc_sysusr1t


dw_cond.Object.saledt_fr[1] 	= date(fdt_get_dbserver_now())
dw_cond.Object.saledt_to[1] 	= date(fdt_get_dbserver_now())
dw_cond.Object.partner[1] 		= gs_shopid

SELECT NVL(CASH_HAND, 0) INTO :ldc_cash_hand
FROM   PARTNERMST
WHERE  PARTNER = :gs_shopid;

dw_cond.Object.cash_hand[1] = ldc_cash_hand
dw_cond.Object.operator[1] 	= ''
dw_cond.Object.option[1]	 	= '1'
dw_cond.Object.shoptype[1]	 	= '00'

li_rc = dw_cond.GetChild("operator", ldwc_sysusr1t)
IF li_rc = -1 THEN
	f_msg_usr_err(9000, Title, "Not a DataWindow Child")
	RETURN
END IF
		
ls_sql = " SELECT EMP_ID, EMPNM, RPAD(EMP_ID, 8, ' ')||' '||NVL(EMPNM, '') EMP " + &
			" FROM   SYSUSR1T " +&		
			" WHERE  EMP_GROUP = '" + gs_shopid + "' " +&
			" ORDER BY EMPNM ASC "
ldwc_sysusr1t.SetTransObject(SQLCA)
ldwc_sysusr1t.SetSqlselect(ls_sql)
ldwc_sysusr1t.SetTransObject(SQLCA)		

ll_row = ldwc_sysusr1t.Retrieve()

IF ll_row < 0 THEN 				//디비 오류 
	f_msg_usr_err(2100, Title, "Model Retrieve()")
	RETURN
END IF		

end event

event ue_saveas;String 	ls_saledt_fr, ls_saledt_to, ls_partner, ls_partnernm, ls_file_name, ls_sysdate

ls_saledt_fr    	= String(dw_cond.object.saledt_fr[1], 'yyyymmdd')
ls_saledt_to    	= String(dw_cond.object.saledt_to[1], 'yyyymmdd')
ls_partner      	= Trim(dw_cond.object.partner[1])

SELECT PARTNERNM INTO :ls_partnernm
FROM   PARTNERMST
WHERE  PARTNER = :ls_partner;

SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO :ls_sysdate
FROM   DUAL;

ls_file_name = 'SalesReport('+ls_saledt_fr+'-'+ls_saledt_to+')_'+ls_partnernm+'_'+ls_sysdate


f_excel_new(idw_saveas, ls_file_name)
end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_sales_report_by_key
integer width = 2075
integer height = 288
string dataobject = "ssrt_cnd_prt_sales_report_by_key"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DATE		ldt_saledt_fr
INTEGER	li_rc
STRING	ls_sql,	ls_saledt_to
LONG		ll_row
DEC{2}	ldc_cash_hand
DataWindowChild ldwc_sysusr1t

choose case dwo.name
	case 'partner'
		SELECT NVL(CASH_HAND, 0) INTO :ldc_cash_hand
		FROM   PARTNERMST
		WHERE  PARTNER = :data;

		This.Object.cash_hand[1] = ldc_cash_hand		
		
		
		THIS.Object.operator[1] = ''
		
		li_rc = dw_cond.GetChild("operator", ldwc_sysusr1t)
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " SELECT EMP_ID, EMPNM, RPAD(EMP_ID, 8, ' ')||' '||NVL(EMPNM, '') EMP " + &
					" FROM   SYSUSR1T " +&		
					" WHERE  EMP_GROUP = '" + data + "' " +&
					" ORDER BY EMPNM ASC "
		ldwc_sysusr1t.SetTransObject(SQLCA)
		ldwc_sysusr1t.SetSqlselect(ls_sql)
		ldwc_sysusr1t.SetTransObject(SQLCA)		
		ll_row = ldwc_sysusr1t.Retrieve()

		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "Model Retrieve()")
			RETURN -2
		END IF		
		
	case 'saledt_fr'
		ls_saledt_to = String(this.Object.saledt_to[1], 'yyyymmdd')
		ldt_saledt_fr =  this.Object.saledt_fr[1]
		
		IF IsNull(ls_saledt_to) OR ls_saledt_to = "" THEN
			this.Object.saledt_to[1] = ldt_saledt_fr
		END IF			
		
	case 'option'
		choose case data
			case '1'
				is_option = '1'
				dw_list.dataobject =  'ssrt_prt_sales_report_by_key_reg'
				dw_list.SetTransObject(sqlca)
			case '2'
				is_option = '2'
				dw_list.dataobject =  'ssrt_prt_sales_report_by_key_item'
				dw_list.SetTransObject(sqlca)
			case '3'
				is_option = '3'
				dw_list.dataobject =  'ssrt_prt_sales_report_by_key_operator'
				dw_list.SetTransObject(sqlca)
			case '4'
				is_option = '4'
				dw_list.dataobject =  'ssrt_prt_sales_report_by_key_regidx'
				dw_list.SetTransObject(sqlca)
			case '5'
				is_option = '5'
				dw_list.dataobject =  'ssrt_prt_sales_report_by_key_pay'
				dw_list.SetTransObject(sqlca)
			case '6'
				is_option = '6'
				dw_list.dataobject =  'ssrt_prt_sales_report_by_key_cid'
				dw_list.SetTransObject(sqlca)				
		end choose
end choose
end event

type p_ok from w_a_print`p_ok within ssrt_prt_sales_report_by_key
integer x = 2190
end type

type p_close from w_a_print`p_close within ssrt_prt_sales_report_by_key
integer x = 2491
end type

type dw_list from w_a_print`dw_list within ssrt_prt_sales_report_by_key
integer y = 372
integer height = 1248
string dataobject = "ssrt_prt_sales_report_by_key_reg"
end type

event dw_list::retrieveend;call super::retrieveend;Long	ll_jj
String ls_regcod, ls_desc
IF rowcount <= 0 then return


//IF is_option = '4' then
//	FOR ll_jj = 1 to rowcount
//		ls_regcod  = Trim(this.Object.regcod[ll_jj])
//		SELECT INDEXDESC INTO :ls_desc 
//        FROM SHOP_REGIDX
//       WHERE REGCOD = :ls_regcod 
//		   AND SHOPID = :is_shopid 		   ;
//		
//		IF IsNull(ls_desc) OR sqlca.sqlcode < 0 THEN ls_desc = ''
//		this.Object.indexdesc[ll_jj] = ls_desc
//	NEXT
//	this.SetSort("indexdesc  A")
//	this.Sort()
//	this.GroupCalc()
//END IF
end event

event dw_list::constructor;//If IsNull(itrans_connect) Then
	SetTransObject(SQLCA)
//	f_modify_dw_title(this)
	
//Else
//	SetTransObject(itrans_connect)
//End If

end event

type p_1 from w_a_print`p_1 within ssrt_prt_sales_report_by_key
end type

type p_2 from w_a_print`p_2 within ssrt_prt_sales_report_by_key
end type

type p_3 from w_a_print`p_3 within ssrt_prt_sales_report_by_key
end type

type p_5 from w_a_print`p_5 within ssrt_prt_sales_report_by_key
end type

type p_6 from w_a_print`p_6 within ssrt_prt_sales_report_by_key
end type

type p_7 from w_a_print`p_7 within ssrt_prt_sales_report_by_key
end type

type p_8 from w_a_print`p_8 within ssrt_prt_sales_report_by_key
end type

type p_9 from w_a_print`p_9 within ssrt_prt_sales_report_by_key
end type

type p_4 from w_a_print`p_4 within ssrt_prt_sales_report_by_key
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_sales_report_by_key
end type

type p_port from w_a_print`p_port within ssrt_prt_sales_report_by_key
end type

type p_land from w_a_print`p_land within ssrt_prt_sales_report_by_key
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_sales_report_by_key
integer width = 2121
integer height = 352
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_sales_report_by_key
end type

