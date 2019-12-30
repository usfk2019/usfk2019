$PBExportHeader$ubs_w_prt_svc_count.srw
$PBExportComments$[jhchoi] 서비스별 가입자수 관리 - 2009.07.08
forward
global type ubs_w_prt_svc_count from w_a_print
end type
type dw_list_temp from u_d_base within ubs_w_prt_svc_count
end type
end forward

global type ubs_w_prt_svc_count from w_a_print
integer width = 4041
integer height = 1992
dw_list_temp dw_list_temp
end type
global ubs_w_prt_svc_count ubs_w_prt_svc_count

type variables
INTEGER	ii_maxnum, &
			ii_time =  21 //Time의 간격수
String	is_time[]
			
			
end variables

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = True
end event

on ubs_w_prt_svc_count.create
int iCurrent
call super::create
this.dw_list_temp=create dw_list_temp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_list_temp
end on

on ubs_w_prt_svc_count.destroy
call super::destroy
destroy(this.dw_list_temp)
end on

event ue_ok;call super::ue_ok;// 화면 리셋
dw_list.Reset()
dw_list_temp.Reset()

// Local Variable Define
STRING	ls_svccod,		ls_priceplan,		ls_workdt,		ls_workdt_to,		ls_where
DATE		ld_workdt,		ld_workdt_to
LONG		ll_row

// Get Data From dw_cond
ld_workdt		= dw_cond.object.workdt_from[1]
ls_workdt		= String(ld_workdt, 'yyyymmdd')
ld_workdt_to	= dw_cond.object.workdt_to[1]
ls_workdt_to	= String(ld_workdt_to, 'yyyymmdd')

ls_svccod		= trim(dw_cond.object.svccod[1])
ls_priceplan 	= trim(dw_cond.object.priceplan[1])

//Null Check
IF IsNull(ls_priceplan)	THEN ls_priceplan	= ""
IF IsNull(ls_svccod) 	THEN ls_svccod 	= ""
IF IsNull(ls_workdt) 	THEN ls_workdt 	= ""
IF IsNull(ls_workdt_to) THEN ls_workdt_to = ""

		
//Retrieve. Key Value Check
IF ls_workdt = "" THEN
	f_msg_info(200, title, "Active Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt")
	RETURN
END IF

IF ls_workdt_to = "" THEN
	f_msg_info(200, title, "Active Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt_to")
	RETURN
END IF

ls_where = ""

IF ls_workdt <> "" THEN
	IF ls_where <> "" Then ls_where += " And "
	ls_where += "(CON.BIL_TODT > TO_DATE('" + ls_workdt + "', 'YYYYMMDD') OR BIL_TODT IS NULL) "
END IF		

IF ls_workdt_to <> "" THEN
	IF ls_where <> "" Then ls_where += " And "
	ls_where += "CON.BIL_FROMDT < TO_DATE('" + ls_workdt_to + "', 'YYYYMMDD') "
END IF			

IF ls_svccod = "" AND ls_priceplan = "" THEN
	dw_list.is_where = ls_where
	
	ll_row = dw_list.Retrieve()		
ELSE
	IF ls_svccod <> "" THEN 
		IF ls_where <> "" Then ls_where += " And "
		ls_where += "CON.SVCCOD = '" + ls_svccod + "' "
	END IF
	
	IF ls_priceplan <> "" THEN 
		IF ls_where <> "" Then ls_where += " And "
		ls_where += "CON.PRICEPLAN = '" + ls_priceplan + "' "
	END IF	

	dw_list.is_where = ls_where
	
	ll_row = dw_list.Retrieve()
END IF
	
IF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
ELSEIF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
END IF

// 조회 날짜 출력하기
dw_list.Object.workdate_t.text 	 = MidA(ls_workdt,5,2) + "-" + MidA(ls_workdt,7,2) + "-" + MidA(ls_workdt,1,4)
dw_list.Object.workdate_to_t.text = MidA(ls_workdt_to,5,2) + "-" + MidA(ls_workdt_to,7,2) + "-" + MidA(ls_workdt_to,1,4)

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

SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') INTO :ld_sysdate
FROM   DUAL;

dw_cond.Object.workdt_from[1]	 = ld_sysdate
dw_cond.Object.workdt_to[1]	 = ld_sysdate
end event

event ue_saveas;datawindow	ldw

ldw = dw_list

f_excel(ldw)

end event

type dw_cond from w_a_print`dw_cond within ubs_w_prt_svc_count
integer x = 73
integer y = 40
integer width = 3095
integer height = 244
string dataobject = "ubs_dw_prt_svc_count_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;//Help Window
//Customer ID help
//This.is_help_win[1] = "b1w_hlp_customerm"
//This.idwo_help_col[1] = dw_cond.object.customerid
//This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
//Choose Case dwo.name
//	Case "customerid"
//		If This.iu_cust_help.ib_data[1] Then
//			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
// 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
//		End If
//		
//End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String	ls_sql
Long 		ll_row
INT		li_rc
DataWindowChild ldwc_priceplan

Choose Case dwo.name
	Case "service"
		
		li_rc = dw_cond.GetChild("priceplan", ldwc_priceplan)
		
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
		
		ls_sql = " SELECT PRICEPLANMST.PRICEPLAN, PRICEPLANMST.PRICEPLAN_DESC, PRICEPLANMST.SVCCOD   "	+ &
					" FROM	PRICEPLANMST "	+ &
					" WHERE  PRICEPLANMST.SVCCOD = '" + data + "' " +&
					" ORDER BY PRICEPLANMST.PRICEPLAN_DESC ASC "
					
		ldwc_priceplan.SetSqlselect(ls_sql)
		ldwc_priceplan.SetTransObject(SQLCA)
		ll_row = ldwc_priceplan.Retrieve()
		
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "contractmst Retrieve()")
			RETURN -2
		END IF		
		
End Choose

Return 0 
end event

event dw_cond::buttonclicked;u_cust_a_msg iu_cust_help2
STRING	ls_lease_period
DATE		ld_sysdate

IF dwo.name = 'b_car_from' THEN
	
	iu_cust_help2 = CREATE u_cust_a_msg
	
	iu_cust_help2.is_pgm_name = "Calendar"
	iu_cust_help2.is_grp_name = "날짜선택"
	iu_cust_help2.ib_data[1]  = True
	iu_cust_help2.idw_data[1] = dw_cond
	iu_cust_help2.is_data[1]  = "workdt_from"
	
	OpenWithParm(ubs_w_pop_calendar2, iu_cust_help2)	
	
	destroy iu_cust_help2
	
ELSEIF dwo.name = 'b_car_to' THEN
	iu_cust_help2 = CREATE u_cust_a_msg
	
	iu_cust_help2.is_pgm_name = "Calendar"
	iu_cust_help2.is_grp_name = "날짜선택"
	iu_cust_help2.ib_data[1]  = True
	iu_cust_help2.idw_data[1] = dw_cond
	iu_cust_help2.is_data[1]  = "workdt_to"	
	
	OpenWithParm(ubs_w_pop_calendar2, iu_cust_help2)	

	destroy iu_cust_help2	
		
END IF	
end event

type p_ok from w_a_print`p_ok within ubs_w_prt_svc_count
integer x = 3291
integer y = 40
end type

type p_close from w_a_print`p_close within ubs_w_prt_svc_count
integer x = 3589
integer y = 40
end type

type dw_list from w_a_print`dw_list within ubs_w_prt_svc_count
integer y = 320
integer width = 3227
integer height = 1388
string dataobject = "ubs_dw_prt_svc_count_mas"
end type

type p_1 from w_a_print`p_1 within ubs_w_prt_svc_count
integer x = 2688
integer y = 1744
end type

type p_2 from w_a_print`p_2 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_3 from w_a_print`p_3 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_5 from w_a_print`p_5 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_6 from w_a_print`p_6 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_7 from w_a_print`p_7 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_8 from w_a_print`p_8 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_9 from w_a_print`p_9 within ubs_w_prt_svc_count
integer y = 1744
end type

type p_4 from w_a_print`p_4 within ubs_w_prt_svc_count
integer y = 1756
end type

type gb_1 from w_a_print`gb_1 within ubs_w_prt_svc_count
boolean visible = false
integer y = 1652
boolean enabled = false
end type

type p_port from w_a_print`p_port within ubs_w_prt_svc_count
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type p_land from w_a_print`p_land within ubs_w_prt_svc_count
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type gb_cond from w_a_print`gb_cond within ubs_w_prt_svc_count
integer width = 3168
integer height = 300
end type

type p_saveas from w_a_print`p_saveas within ubs_w_prt_svc_count
integer y = 1744
end type

type dw_list_temp from u_d_base within ubs_w_prt_svc_count
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

