$PBExportHeader$ssrt_prt_schedule_list.srw
$PBExportComments$[hcjung] 스케쥴 리스트 출력
forward
global type ssrt_prt_schedule_list from w_a_print
end type
type dw_list_temp from u_d_base within ssrt_prt_schedule_list
end type
end forward

global type ssrt_prt_schedule_list from w_a_print
integer width = 4041
integer height = 1992
dw_list_temp dw_list_temp
end type
global ssrt_prt_schedule_list ssrt_prt_schedule_list

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

on ssrt_prt_schedule_list.create
int iCurrent
call super::create
this.dw_list_temp=create dw_list_temp
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_list_temp
end on

on ssrt_prt_schedule_list.destroy
call super::destroy
destroy(this.dw_list_temp)
end on

event ue_ok();call super::ue_ok;// 화면 리셋
dw_list.Reset()
dw_list_temp.Reset()

// Local Variable Define
String	ls_customerid, ls_partner, ls_svccod, ls_basecod, ls_workdt, ls_where, ls_worktype, &
			ls_partnernm, ls_range, ls_where_tmp, ls_time, ls_svc, ls_work, ls_price,i
Date		ld_workdt
long 		ll_row, ll, jj, ll_cnt, ll_insert_cnt

// Get Data From dw_cond
ld_workdt		= dw_cond.object.workdt[1]
ls_workdt		= String(ld_workdt, 'yyyymmdd')
ls_partner		= trim(dw_cond.object.partner[1])
ls_svccod		= trim(dw_cond.object.svccod[1])
ls_basecod		= trim(dw_cond.object.basecod[1])
ls_customerid 	= trim(dw_cond.object.customerid[1])
ls_worktype 	= trim(dw_cond.object.worktype[1])
ls_range			= trim(dw_cond.object.range[1])

//Null Check
IF IsNull(ls_customerid)	THEN ls_customerid	= ""
IF IsNull(ls_partner) 		THEN ls_partner 		= ""
IF IsNull(ls_workdt) 		THEN ls_workdt 		= ""
IF IsNull(ls_svccod) 		Then ls_svccod 		= ""
IF IsNull(ls_basecod) 		THEN ls_basecod 		= ""
IF Isnull(ls_range)			THEN ls_range			= ""
		
//Retrieve. Key Value Check
IF ls_workdt = "" THEN
	f_msg_info(200, title, "Work Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("workdt")
	RETURN
END IF

IF ls_partner = "" THEN
	f_msg_info(200, title, "Shop")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	RETURN
END IF

ls_where = ""
IF ls_customerid <> "" THEN 
	IF ls_where <> "" Then ls_where += " And "
	ls_where += "b.customerid = '" + ls_customerid + "' "
END IF

IF ls_partner <> "" THEN 
	If ls_where <> "" THEN ls_where += " And "
	ls_where += "a.partner_work = '" + ls_partner + "' "
END If

IF ls_workdt <> "" THEN 
	If ls_where <> "" THEN ls_where += " And "
	ls_where += "a.yyyymmdd = '" + ls_workdt + "' "
END If

IF ls_svccod <> "" THEN 
	IF ls_where <> "" THEN ls_where += " And "
	ls_where += "a.svccod = '" + ls_svccod + "' "
END IF

IF ls_basecod <> "" THEN
	IF ls_where <> "" THEN ls_where += " And "
	ls_where += "b.basecod = '" + ls_basecod + "' "
END IF

IF ls_worktype <> "" THEN
	IF ls_where <> "" THEN ls_where += " And "
	ls_where += "a.worktype = '" + ls_worktype + "' "
END IF

// Range Check
IF ls_range <> "Y" THEN
// 현재 잡혀있는 스케쥴만 출력함.
	dw_list.is_where = ls_where
	
	ll_row = dw_list.Retrieve()
	IF ll_row = 0 THEN
		f_msg_info(1000, Title, "")
	ELSEIF ll_row < 0 THEN
		f_msg_usr_err(2100, Title, "Retrieve()")
	END IF
ELSE
// 빈 일정도 포함해서 출력함.
// Time Define
	is_time[1] 	= '0930'
	is_time[2] 	= '1000'
	is_time[3] 	= '1030'
	is_time[4] 	= '1100'
	is_time[5] 	= '1130'
	is_time[6] 	= '1200'
	is_time[7] 	= '1230'
	is_time[8] 	= '1300'
	is_time[9] 	= '1330'
	is_time[10] = '1400'
	is_time[11] = '1430'
	is_time[12] = '1500'
	is_time[13] = '1530'
	is_time[14] = '1600'
	is_time[15] = '1630'
	is_time[16] = '1700'
	is_time[17] = '1730'
	is_time[18] = '1800'
	is_time[19] = '1830'
	is_time[20] = '1900'
	is_time[21] = '1930'
	
	// 샵별 시간당 최대 건수 구해오기
	SELECT WORKERNUM INTO :ii_maxnum FROM SCHEDULE_FRAME WHERE PARTNER = :ls_partner ;

	IF IsNull(ii_maxnum) THEN ii_maxnum = 0
	IF sqlca.sqlcode < 0 OR ii_maxnum = 0 THEN
		f_msg_sql_err(title, "Select SCHEDULE_FRAME Table")
		RETURN 
	END IF

	ls_where_tmp = ls_where
	
	// 조회된 일정을 먼저 tmp에 붙이고 남은 건수만큼 빈건수 채워넣기
	FOR ll =  1 TO ii_time
		ls_time 	= is_time[ll]
		ls_where = ls_where_tmp + " And a.worktime = '" + ls_time + "' "
		dw_list_temp.is_where = ls_where
		ll_cnt = dw_list_temp.Retrieve()

		IF ll_cnt > 0 THEN
			FOR jj =  1 TO ll_cnt
				ls_svc 		= dw_list_temp.describe("Evaluate('LookUpDisplay(svcmst_svcdesc)'," + string(jj) +")") 
				ls_price 	= dw_list_temp.describe("Evaluate('LookUpDisplay(priceplanmst_priceplan_desc)'," + string(jj) +")") 
				ls_work 		= dw_list_temp.describe("Evaluate('LookUpDisplay(syscod2t_codenm)'," + string(jj) +")") 
				dw_list_temp.Object.svcmst_svcdesc[jj] 					= ls_svc
				dw_list_temp.Object.priceplanmst_priceplan_desc[jj] 	= ls_price
				dw_list_temp.Object.syscod2t_codenm[jj]					= ls_work
			NEXT
			dw_list_temp.RowsCopy(1, dw_list_temp.RowCount(), Primary!, dw_list, dw_list.RowCount() + 1, Primary!)
		END IF
	
	ll_insert_cnt	= ii_maxnum - ll_cnt
	IF ll_insert_cnt < 0 THEN ll_insert_cnt = 0
		IF ll_insert_cnt > 0 THEN
			FOR jj = 1 TO ll_insert_cnt
				ll_row = dw_list.InsertRow(0)
				dw_list.Object.schedule_detail_yyyymmdd[ll_row]		= ls_workdt
				dw_list.Object.schedule_detail_worktime[ll_row]		= ls_time
				dw_list.Object.partnermst_partnernm[ll_row]			= ls_partner
				dw_list.Object.customerm_buildingno[ll_row]			= ""
			NEXT
		END IF
	NEXT	
END IF

// 조회 날짜 출력하기
dw_list.Object.workdate_t.text = MidA(ls_workdt,1,4) + "-" + MidA(ls_workdt,5,2) + "-" + MidA(ls_workdt,7,2) 

// 조회한 샵 이름 출력하기
SELECT PARTNERNM
  INTO :ls_partnernm
  FROM PARTNERMST
 WHERE PARTNER = :ls_partner;
	 
IF SQLCA.SQLCode <> 0 THEN
	RETURN
ELSE
	dw_list.Object.shop_t.text = ls_partnernm
End IF

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

type dw_cond from w_a_print`dw_cond within ssrt_prt_schedule_list
integer x = 73
integer y = 40
integer width = 3095
integer height = 300
string dataobject = "ssrt_cnd_prt_schedule_list"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Help Window
//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm
String ls_filter, ls_itemcod
Long ll_row
DataWindowChild ldc


Choose Case dwo.name
	Case "customerid"
		
		 If data = "" then 
				This.Object.customernm[row] = ""			
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
 		 End If		 
		 
		 SELECT customernm
		 INTO :ls_customernm
		 FROM customerm
		 WHERE customerid = :data ;
		 If SQLCA.SQLCode < 0 Then
			 f_msg_sql_err(parent.Title,"select 고객명")
			 Return 1
		 End If		 
		 
		 If ls_customernm = "" or isnull(ls_customernm ) then
//				This.Object.customerid[row] = ""
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_customernm
		 

			//민원유형 중분류 Filtering
			Case "troubletypec"
				dw_cond.object.troubletypeb[1] = ""
				dw_cond.object.troubletypea[1] = ""
				dw_cond.object.troubletype[1] = ""
				//해당 priceplan에 대한 itemcod
				ll_row = dw_cond.GetChild("troubletypeb", ldc)
				If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
				ls_filter = "troubletypeb_troubletypec = '" + data + "' "
			
				ldc.SetFilter(ls_filter)			//Filter정함
				ldc.Filter()
				ldc.SetTransObject(SQLCA)
				ll_row =ldc.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
			//민원유형 소분류 Filtering
			Case "troubletypeb"
				dw_cond.object.troubletypea[1] = ""
				dw_cond.object.troubletype[1] = ""
				//해당 priceplan에 대한 itemcod
				ll_row = dw_cond.GetChild("troubletypea", ldc)
				If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
				ls_filter = "troubletypea_troubletypeb = '" + data + "' "
			
				ldc.SetFilter(ls_filter)			//Filter정함
				ldc.Filter()
				ldc.SetTransObject(SQLCA)
				ll_row =ldc.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
			//민원유형 Filtering
			Case "troubletypea"
				dw_cond.object.troubletype[1] = ""
				//해당 priceplan에 대한 itemcod
				ll_row = dw_cond.GetChild("troubletype", ldc)
				If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
				ls_filter = "troubletypea = '" + data + "' "
			
				ldc.SetFilter(ls_filter)			//Filter정함
				ldc.Filter()
				ldc.SetTransObject(SQLCA)
				ll_row =ldc.Retrieve() 
				
				If ll_row < 0 Then 				//디비 오류 
					f_msg_usr_err(2100, Title, "Retrieve()")
					Return -2
				End If
				
End Choose

Return 0 
end event

type p_ok from w_a_print`p_ok within ssrt_prt_schedule_list
integer x = 3291
integer y = 40
end type

type p_close from w_a_print`p_close within ssrt_prt_schedule_list
integer x = 3589
integer y = 40
end type

type dw_list from w_a_print`dw_list within ssrt_prt_schedule_list
integer y = 392
integer width = 3227
integer height = 1324
string dataobject = "ssrt_prt_schedule_list"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_schedule_list
integer x = 2688
integer y = 1744
end type

type p_2 from w_a_print`p_2 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_3 from w_a_print`p_3 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_5 from w_a_print`p_5 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_6 from w_a_print`p_6 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_7 from w_a_print`p_7 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_8 from w_a_print`p_8 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_9 from w_a_print`p_9 within ssrt_prt_schedule_list
integer y = 1744
end type

type p_4 from w_a_print`p_4 within ssrt_prt_schedule_list
integer y = 1756
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_schedule_list
boolean visible = false
integer y = 1652
boolean enabled = false
end type

type p_port from w_a_print`p_port within ssrt_prt_schedule_list
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type p_land from w_a_print`p_land within ssrt_prt_schedule_list
boolean visible = false
integer y = 1720
boolean enabled = false
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_schedule_list
integer width = 3168
integer height = 356
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_schedule_list
integer y = 1744
end type

type dw_list_temp from u_d_base within ssrt_prt_schedule_list
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

