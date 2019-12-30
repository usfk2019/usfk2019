$PBExportHeader$ubs_w_prt_cdrreport.srw
$PBExportComments$[jhchoi] 서비스별 가입자수 관리 - 2009.07.08
forward
global type ubs_w_prt_cdrreport from w_a_print
end type
type dw_list_temp from u_d_base within ubs_w_prt_cdrreport
end type
type p_create from u_p_create within ubs_w_prt_cdrreport
end type
end forward

global type ubs_w_prt_cdrreport from w_a_print
integer width = 3342
integer height = 1992
event ue_create ( )
dw_list_temp dw_list_temp
p_create p_create
end type
global ubs_w_prt_cdrreport ubs_w_prt_cdrreport

type variables
INTEGER	ii_maxnum, &
			ii_time =  21 //Time의 간격수
String	is_time[]
			
			
end variables

event ue_create;// Local Variable Define
STRING	ls_option,			ls_period,			ls_customerid,			ls_where,			ls_payid
STRING	ls_errmsg,			ls_sysdate
DATE		ld_used_fr,			ld_used_to
LONG		ll_contractseq,	ll_row,				ll_return,				ll_prccount

// Get Data From dw_cond
ls_option		= dw_cond.Object.option[1]
ls_customerid  = dw_cond.Object.customerid[1]
ll_contractseq = dw_cond.Object.contractseq[1]

//Null Check
IF IsNull(ls_option)			THEN 	ls_option		= ""
IF IsNull(ls_customerid) 	THEN 	ls_customerid 	= ""
IF IsNull(ll_contractseq)  THEN  ll_contractseq = 0
		
//Retrieve. Key Value Check
IF ls_customerid = "" THEN
	f_msg_info(200, title, "Customer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	RETURN
END IF

IF ll_contractseq = 0 THEN
	f_msg_info(200, title, "Contract Seq.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	RETURN
END IF

IF ls_option <> 'C' THEN
	f_msg_info(200, title, "Check Option!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("option")
	RETURN	
END IF	

SELECT PAYID INTO :ls_payid
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_customerid;

SELECT  TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD'),
        TO_DATE(TO_CHAR(LAST_DAY(SYSDATE), 'YYYYMMDD'), 'YYYYMMDD'),
		  TO_CHAR(SYSDATE, 'YYYYMMDD')
INTO	  :ld_used_fr, :ld_used_to, :ls_sysdate		  
FROM    DUAL;

ls_errmsg		= space(1000)
SQLCA.APPENDPOST_BILCDR_CUST(ls_payid,			ll_contractseq,	ls_sysdate,		gs_user_id,		&
									  gs_pgm_id[gi_open_win_no],	ll_return, 		   ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'APPENDPOST_BILCDR_CUST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'APPENDPOST_BILCDR_CUST' + ls_errmsg,Exclamation!,OK!)
	RETURN
END IF

ll_return   = 0
ll_prccount = 0
ls_errmsg		= space(1000)

SQLCA.CALC_CDRRETRIEVE(ls_payid,			ll_contractseq,	ld_used_fr,		ld_used_to,		&
							  gs_pgm_id[gi_open_win_no],	gs_user_id,			ll_return, 		ls_errmsg,		ll_prccount)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'CALC_CDRRETRIEVE(1)')
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'CALC_CDRRETRIEVE' + ls_errmsg,Exclamation!,OK!)
	RETURN
END IF

COMMIT;

f_msg_info(3000,This.Title,"OK")





end event

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init;call super::ue_init;ii_orientation = 2
ib_margin = True
end event

on ubs_w_prt_cdrreport.create
int iCurrent
call super::create
this.dw_list_temp=create dw_list_temp
this.p_create=create p_create
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_list_temp
this.Control[iCurrent+2]=this.p_create
end on

on ubs_w_prt_cdrreport.destroy
call super::destroy
destroy(this.dw_list_temp)
destroy(this.p_create)
end on

event ue_ok;// 화면 리셋
dw_list.Reset()
dw_list_temp.Reset()

// Local Variable Define
STRING	ls_option,			ls_period,			ls_customerid,			ls_where,			ls_payid
STRING	ls_sysdate,			ls_min_day,			ls_max_day,				ls_frdt,				ls_todt
STRING	ls_priceplan,		ls_validkey,		ls_itemnm
LONG		ll_contractseq,	ll_row
DATE		ld_period

dw_cond.AcceptText()

// Get Data From dw_cond
ls_option		= dw_cond.Object.option[1]
ls_period		= String(dw_cond.Object.workdt[1], 'yyyymm')
ls_customerid  = dw_cond.Object.customerid[1]
ll_contractseq = dw_cond.Object.contractseq[1]

//Null Check
IF IsNull(ls_option)			THEN 	ls_option		= ""
IF IsNull(ls_period) 		THEN 	ls_period	 	= ""
IF IsNull(ls_customerid) 	THEN 	ls_customerid 	= ""
IF IsNull(ll_contractseq)  THEN  ll_contractseq = 0
		
//Retrieve. Key Value Check
IF ls_customerid = "" THEN
	f_msg_info(200, title, "Customer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	RETURN
END IF

IF ls_option <> 'C' THEN
	IF ls_period = "" THEN
		f_msg_info(200, title, "Period")
		dw_cond.SetFocus()
		dw_cond.SetColumn("Period")
		RETURN
	END IF
END IF

IF ll_contractseq = 0 THEN
	f_msg_info(200, title, "Contract Seq.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("contractseq")
	RETURN
END IF

SELECT PAYID INTO :ls_payid
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_customerid;

IF ls_option = 'C' THEN
	dw_list.DataObject = "ubs_dw_prt_cdrreport_det"
	dw_list.SetTransObject(SQLCA)	
	
	SELECT PRICEPLAN, VALIDKEY
	INTO	 :ls_priceplan, :ls_validkey
	FROM   VALIDINFO
	WHERE  CUSTOMERID = :ls_customerid
	AND    CONTRACTSEQ = :ll_contractseq
	AND    (TODT IS NULL OR TODT >= TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD') );
	
	ll_row = dw_list.Retrieve(ls_payid, ll_contractseq, ls_priceplan, ls_validkey)
ELSE
	SELECT TO_CHAR(SYSDATE, 'YYYYMM'), TO_DATE(:ls_period||'01')
	INTO	 :ls_sysdate, :ld_period
	FROM   DUAL;
	
	IF ls_period = ls_sysdate THEN		//당월 청구분에 대한 내용 조회시
	
		dw_list.DataObject = "ubs_dw_prt_cdrreport_det1"
		dw_list.SetTransObject(SQLCA)	
		ll_row = dw_list.Retrieve(ls_payid, ll_contractseq, ld_period)	
		
	ELSEIF ls_period < ls_sysdate THEN
		dw_list.DataObject = "ubs_dw_prt_cdrreport_det2"
		dw_list.SetTransObject(SQLCA)	
		ll_row = dw_list.Retrieve(ls_payid, ll_contractseq, ld_period)			
	
	END IF
END IF	

//ls_where = ""
//
//IF ls_period <> "" THEN
//	IF ls_where <> "" Then ls_where += " And "
//	ls_where += "(CON.BIL_TODT > TO_DATE('" + ls_workdt + "', 'YYYYMMDD') OR BIL_TODT IS NULL) "
//END IF		
//
//IF ls_workdt_to <> "" THEN
//	IF ls_where <> "" Then ls_where += " And "
//	ls_where += "CON.BIL_FROMDT < TO_DATE('" + ls_workdt_to + "', 'YYYYMMDD') "
//END IF			
//
//IF ls_svccod = "" AND ls_priceplan = "" THEN
//	dw_list.is_where = ls_where
//	
//	ll_row = dw_list.Retrieve()		
//ELSE
//	IF ls_svccod <> "" THEN 
//		IF ls_where <> "" Then ls_where += " And "
//		ls_where += "CON.SVCCOD = '" + ls_svccod + "' "
//	END IF
//	
//	IF ls_priceplan <> "" THEN 
//		IF ls_where <> "" Then ls_where += " And "
//		ls_where += "CON.PRICEPLAN = '" + ls_priceplan + "' "
//	END IF	
//
//	dw_list.is_where = ls_where
//	
//	ll_row = dw_list.Retrieve()
//END IF
	
IF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
ELSEIF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
END IF

IF ls_option = 'C' THEN
	SELECT MIN(YYYYMMDD) AS MIN_DAY, MAX(YYYYMMDD) AS MAX_DAY
	INTO   :ls_min_day, :ls_max_day
	FROM   POST_BILCDR_CUST
	WHERE  PAYID = :ls_payid
	AND    CONTRACTSEQ = :ll_contractseq;
	
	dw_list.Object.usage_fr.text = MidA(ls_min_day, 5, 2)+'-'+MidA(ls_min_day, 7, 2)+'-'+MidA(ls_min_day, 1, 4)
	dw_list.Object.usage_to.text = MidA(ls_max_day, 5, 2)+'-'+MidA(ls_max_day, 7, 2)+'-'+MidA(ls_max_day, 1, 4)	
	
	SELECT B.ITEMNM INTO :ls_itemnm
	FROM   CONTRACTDET A, ITEMMST B
	WHERE  A.CONTRACTSEQ = :ll_contractseq
	AND    (A.BIL_TODT IS NULL OR A.BIL_TODT >= TO_DATE(TO_CHAR(SYSDATE, 'YYYYMM')||'01', 'YYYYMMDD') )
	AND    A.ITEMCOD IN ( SELECT CODE FROM SYSCOD2T WHERE GRCODE = 'UBS215' AND USE_YN = 'Y' )
	AND    A.ITEMCOD = B.ITEMCOD
	AND    ROWNUM = 1;

	dw_list.Object.mobile_plan.text = ls_itemnm
	
ELSE
	SELECT TO_CHAR(ADD_MONTHS(TO_DATE(:ls_period, 'yyyymm'), -1) - 1, 'YYYYMMDD'),
          TO_CHAR(LAST_DAY(ADD_MONTHS(TO_DATE(:ls_period, 'yyyymm'), -1)) - 1, 'YYYYMMDD')
	INTO	 :ls_frdt, :ls_todt			 
   FROM   DUAL;
	
	dw_list.Object.usage_fr.text = MidA(ls_frdt, 5, 2)+'-'+MidA(ls_frdt, 7, 2)+'-'+MidA(ls_frdt, 1, 4)
	dw_list.Object.usage_to.text = MidA(ls_todt, 5, 2)+'-'+MidA(ls_todt, 7, 2)+'-'+MidA(ls_todt, 1, 4)	
	
	SELECT B.ITEMNM INTO :ls_itemnm
	FROM   CONTRACTDET A, ITEMMST B
	WHERE  A.CONTRACTSEQ = :ll_contractseq
	AND    :ls_period BETWEEN TO_CHAR(A.BIL_FROMDT, 'YYYYMM') AND NVL(TO_CHAR(A.BIL_TODT, 'YYYYMM'), '209912')
	AND    A.ITEMCOD IN ( SELECT CODE FROM SYSCOD2T WHERE GRCODE = 'UBS215' AND USE_YN = 'Y' )
	AND    A.ITEMCOD = B.ITEMCOD
	AND    ROWNUM = 1;

	dw_list.Object.mobile_plan.text = ls_itemnm	
	
END IF	
 

// 출력 및 여백 조정 
dw_list.Object.DataWindow.Print.Preview = 'Yes'

IF ib_margin THEN
	dw_list.object.datawindow.print.margin.Top = 0
   dw_list.object.datawindow.print.margin.Bottom = 0
   dw_list.object.datawindow.print.margin.Left = 0
   dw_list.object.datawindow.print.margin.Right = 0
END IF

RETURN
end event

event open;call super::open;DATE	ld_sysdate

dw_cond.Object.option[1] = 'C'

//SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') INTO :ld_sysdate
//FROM   DUAL;
//
//dw_cond.Object.workdt_from[1]	 = ld_sysdate
//dw_cond.Object.workdt_to[1]	 = ld_sysdate
end event

event ue_saveas;datawindow	ldw

ldw = dw_list

f_excel(ldw)

end event

event ue_reset;call super::ue_reset;dw_cond.Object.option[1] = 'C'
end event

type dw_cond from w_a_print`dw_cond within ubs_w_prt_cdrreport
integer x = 73
integer y = 40
integer width = 2478
integer height = 244
string dataobject = "ubs_dw_prt_cdrreport_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;STRING	ls_customerid,		ls_sql
INT		li_rc
LONG		ll_row
DataWindowChild ldwc_contractseq

//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
			 ls_customerid = This.iu_cust_help.is_data[1]
		End If
		
		li_rc = This.GetChild("contractseq", ldwc_contractseq)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " SELECT A.CONTRACTSEQ, C.PRICEPLAN_DESC, B.VALIDKEY, B.STATUS 	" + &
					" FROM   CONTRACTMST A, VALIDINFO B, PRICEPLANMST C	" + &
					" WHERE  A.CUSTOMERID = '" + ls_customerid + "' " +&
					" AND	   A.CONTRACTSEQ = B.CONTRACTSEQ		" + &
					" AND    A.PRICEPLAN = C.PRICEPLAN	" + &
					" ORDER BY A.CONTRACTSEQ, B.STATUS "
					
		ldwc_contractseq.SetSqlselect(ls_sql)
		ldwc_contractseq.SetTransObject(SQLCA)
		ll_row = ldwc_contractseq.Retrieve()
		
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "contractmst Retrieve()")
			RETURN -2
		END IF		

End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String	ls_sql,		ls_customernm
Long 		ll_row
INT		li_rc
DataWindowChild ldwc_contractseq

Choose Case dwo.name
	Case "customerid"
		
		SELECT CUSTOMERNM
		INTO   :ls_customernm
		FROM	 CUSTOMERM
		WHERE	 CUSTOMERID = :data;
				
		IF SQLCA.SQLCODE <> 0 THEN
			f_msg_usr_err(2100, Title, "SELECT CUSTOMERM ")
			dw_cond.Object.customerid[1] = ""
			RETURN -1
		END IF		
		
		li_rc = dw_cond.GetChild("contractseq", ldwc_contractseq)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " SELECT A.CONTRACTSEQ, C.PRICEPLAN_DESC, B.VALIDKEY, B.STATUS 	" + &
					" FROM   CONTRACTMST A, VALIDINFO B, PRICEPLANMST C	" + &
					" WHERE  A.CUSTOMERID = '" + data + "' " +&
					" AND	   A.CONTRACTSEQ = B.CONTRACTSEQ		" + &
					" AND    A.PRICEPLAN = C.PRICEPLAN	" + &
					" ORDER BY A.CONTRACTSEQ, B.STATUS "
					
		ldwc_contractseq.SetSqlselect(ls_sql)
		ldwc_contractseq.SetTransObject(SQLCA)
		ll_row = ldwc_contractseq.Retrieve()
		
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "contractmst Retrieve()")
			RETURN -2
		END IF		

		dw_cond.Object.customernm[1] = ls_customernm
End Choose

Return 0 
end event

event dw_cond::buttonclicked;//u_cust_a_msg iu_cust_help2
//STRING	ls_lease_period
//DATE		ld_sysdate
//
//IF dwo.name = 'b_car_from' THEN
//	
//	iu_cust_help2 = CREATE u_cust_a_msg
//	
//	iu_cust_help2.is_pgm_name = "Calendar"
//	iu_cust_help2.is_grp_name = "날짜선택"
//	iu_cust_help2.ib_data[1]  = True
//	iu_cust_help2.idw_data[1] = dw_cond
//	iu_cust_help2.is_data[1]  = "workdt_from"
//	
//	OpenWithParm(ubs_w_pop_calendar2, iu_cust_help2)	
//	
//	destroy iu_cust_help2
//	
//ELSEIF dwo.name = 'b_car_to' THEN
//	iu_cust_help2 = CREATE u_cust_a_msg
//	
//	iu_cust_help2.is_pgm_name = "Calendar"
//	iu_cust_help2.is_grp_name = "날짜선택"
//	iu_cust_help2.ib_data[1]  = True
//	iu_cust_help2.idw_data[1] = dw_cond
//	iu_cust_help2.is_data[1]  = "workdt_to"	
//	
//	OpenWithParm(ubs_w_pop_calendar2, iu_cust_help2)	
//
//	destroy iu_cust_help2	
//		
//END IF	
end event

type p_ok from w_a_print`p_ok within ubs_w_prt_cdrreport
integer x = 2647
integer y = 40
end type

type p_close from w_a_print`p_close within ubs_w_prt_cdrreport
integer x = 2944
integer y = 40
end type

type dw_list from w_a_print`dw_list within ubs_w_prt_cdrreport
integer y = 320
integer width = 3227
integer height = 1388
string dataobject = "ubs_dw_prt_cdrreport_det"
end type

type p_1 from w_a_print`p_1 within ubs_w_prt_cdrreport
integer x = 2546
integer y = 1740
end type

type p_2 from w_a_print`p_2 within ubs_w_prt_cdrreport
integer x = 370
integer y = 1740
end type

type p_3 from w_a_print`p_3 within ubs_w_prt_cdrreport
integer x = 2254
integer y = 1740
end type

type p_5 from w_a_print`p_5 within ubs_w_prt_cdrreport
integer x = 1074
integer y = 1740
end type

type p_6 from w_a_print`p_6 within ubs_w_prt_cdrreport
integer x = 1678
integer y = 1740
end type

type p_7 from w_a_print`p_7 within ubs_w_prt_cdrreport
integer x = 1477
integer y = 1740
end type

type p_8 from w_a_print`p_8 within ubs_w_prt_cdrreport
integer x = 1275
integer y = 1740
end type

type p_9 from w_a_print`p_9 within ubs_w_prt_cdrreport
integer x = 667
integer y = 1740
end type

type p_4 from w_a_print`p_4 within ubs_w_prt_cdrreport
integer y = 1756
end type

type gb_1 from w_a_print`gb_1 within ubs_w_prt_cdrreport
boolean visible = false
integer y = 1652
boolean enabled = false
end type

type p_port from w_a_print`p_port within ubs_w_prt_cdrreport
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type p_land from w_a_print`p_land within ubs_w_prt_cdrreport
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type gb_cond from w_a_print`gb_cond within ubs_w_prt_cdrreport
integer width = 2551
integer height = 300
end type

type p_saveas from w_a_print`p_saveas within ubs_w_prt_cdrreport
integer x = 1961
integer y = 1740
end type

type dw_list_temp from u_d_base within ubs_w_prt_cdrreport
boolean visible = false
integer x = 3040
integer y = 536
integer width = 823
integer height = 156
integer taborder = 11
boolean bringtotop = true
boolean enabled = false
string dataobject = "ssrt_prt_schedule_list_temp"
end type

type p_create from u_p_create within ubs_w_prt_cdrreport
integer x = 2647
integer y = 172
boolean bringtotop = true
boolean originalsize = false
end type

