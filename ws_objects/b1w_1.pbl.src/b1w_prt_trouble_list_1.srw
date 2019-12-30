$PBExportHeader$b1w_prt_trouble_list_1.srw
$PBExportComments$[chooys] 유형별 민원내역 리스트_1
forward
global type b1w_prt_trouble_list_1 from w_a_print
end type
end forward

global type b1w_prt_trouble_list_1 from w_a_print
integer width = 4859
integer height = 1992
end type
global b1w_prt_trouble_list_1 b1w_prt_trouble_list_1

event ue_saveas_init();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_trouble_list
	Desc.	: 유형별 민원내역 리스트 
	Ver.	: 1.0
	Date	: 2002.10.13
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
dw_cond.object.rcv_fromdt[1] = fdt_get_dbserver_now()
dw_cond.object.rcv_todt[1] = fdt_get_dbserver_now()

dw_cond.object.troubletypeb.Protect = 1;
dw_cond.object.troubletype.Protect = 1;


end event

on b1w_prt_trouble_list_1.create
call super::create
end on

on b1w_prt_trouble_list_1.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_svccod,          ls_troubletypeb,   ls_troubletype
String ls_receipt_partner, ls_res_partner,    ls_partner,           ls_customerid
String ls_close_yn,        ls_trouble_status, ls_term_user, ls_receipt_user
String ls_sort1, ls_sort2, ls_sort3, ls_sort4
Date   ld_rcv_fromdt,      ld_rcv_todt,       ld_term_fromdt,       ld_term_todt

String ls_temp, ls_result[], ls_sort
String ls_rcv_fromdt, ls_rcv_todt, ls_term_fromdt, ls_term_todt, ls_where, ls_new, ls_close
Long ll_row 
integer li_rc, li_cnt, li_return

dw_cond.AcceptText()
ls_svccod          = Trim(dw_cond.object.svccod[1])
ls_troubletypeb    = Trim(dw_cond.object.troubletypeb[1])
ls_troubletype     = Trim(dw_cond.object.troubletype[1])
ls_receipt_partner = Trim(dw_cond.object.receipt_partner[1])
ls_res_partner     = Trim(dw_cond.object.res_partner[1])
ls_partner			 = Trim(dw_cond.object.partner[1])
ld_rcv_todt        = dw_cond.object.rcv_todt[1]
ld_rcv_fromdt      = dw_cond.object.rcv_fromdt[1]
ld_term_todt       = dw_cond.object.term_todt[1]
ld_term_fromdt     = dw_cond.object.term_fromdt[1]
ls_rcv_todt        = String(ld_rcv_todt, 'yyyymmdd')
ls_rcv_fromdt      = String(ld_rcv_fromdt, 'yyyymmdd')
ls_term_fromdt     = String(ld_term_fromdt, 'yyyymmdd')
ls_term_todt       = String(ld_term_todt, 'yyyymmdd')
ls_close_yn		    = Trim(dw_cond.object.close_yn[1])
ls_trouble_status  = Trim(dw_cond.object.trouble_status[1])
ls_term_user	    = Trim(dw_cond.object.term_user[1])
ls_receipt_user    = Trim(dw_cond.object.receipt_user[1])
ls_customerid      = Trim(dw_cond.object.customerid[1])
ls_sort1           = Trim(dw_cond.object.sort1[1])
ls_sort2           = Trim(dw_cond.object.sort2[1])
ls_sort3           = Trim(dw_cond.object.sort3[1])
ls_sort4           = Trim(dw_cond.object.sort4[1])

//Null Check
IF IsNull(ls_svccod)          THEN ls_svccod = ""
IF IsNull(ls_troubletypeb)    THEN ls_troubletypeb = ""
IF IsNull(ls_troubletype)     THEN ls_troubletype = ""
IF IsNull(ls_receipt_partner) THEN ls_receipt_partner = ""
IF IsNull(ls_res_partner)     THEN ls_res_partner = ""
IF IsNull(ls_partner)         THEN ls_partner = ""
IF IsNull(ls_rcv_todt)        THEN ls_rcv_todt = ""
IF IsNull(ls_rcv_fromdt)      THEN ls_rcv_fromdt = ""
IF IsNull(ls_term_todt)       THEN ls_term_todt = ""
IF IsNull(ls_term_fromdt)     THEN ls_term_fromdt = ""
IF IsNull(ls_close_yn)        THEN ls_close_yn = ""
IF IsNull(ls_trouble_status)  THEN ls_trouble_status = ""
IF IsNull(ls_term_user)       THEN ls_term_user = ""
IF IsNull(ls_receipt_user)    THEN ls_receipt_user = ""
IF IsNull(ls_customerid)      THEN ls_customerid = ""
IF IsNull(ls_sort1)           THEN ls_sort1 = ""
IF IsNull(ls_sort2)           THEN ls_sort2 = ""
IF IsNull(ls_sort3)           THEN ls_sort3 = ""
IF IsNull(ls_sort4)           THEN ls_sort4 = ""
		
//Retrieve
ls_where = ""
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "tro.svccod = '" + ls_svccod + "' "
End If

If ls_troubletypeb <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "ta.troubletypeb = '" + ls_troubletypeb + "' "
End If

If ls_troubletype <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "tro.troubletype = '" + ls_troubletype + "' "
End If

IF ls_receipt_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.receipt_partner = '" + ls_receipt_partner + "' "
End If

IF ls_res_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "res.partner = '" + ls_res_partner + "' "
End If

IF ls_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.partner = '" + ls_partner + "' "
End If

IF ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.customerid = '" + ls_customerid + "' "
End If

//ranger가 확정이 되면
If ls_rcv_fromdt <> ""  and ls_rcv_todt <> "" Then
	ll_row = fi_chk_frto_day(ld_rcv_fromdt, ld_rcv_todt)
	If ll_row = -1 Then
	 f_msg_usr_err(211, Title, "접수일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("rcv_fromdt")
	 Return 
	End If 	
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(tro.receiptdt, 'YYYYMMDD') >='" + ls_rcv_fromdt + "' " + &
				"and to_char(tro.receiptdt, 'YYYYMMDD') < = '" + ls_rcv_todt + "' "
			  
ElseIf ls_rcv_fromdt <> "" and ls_rcv_todt = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(tro.receiptdt,'YYYYMMDD') >= '" + ls_rcv_fromdt + "' "
ElseIf ls_rcv_fromdt = "" and ls_rcv_todt <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(tro.receiptdt, 'YYYYMMDD') <= '" + ls_rcv_todt + "' " 
End If

//ranger가 확정이 되면
If ls_term_fromdt <> ""  and ls_term_todt <> "" Then
	ll_row = fi_chk_frto_day(ld_term_fromdt, ld_term_todt)
	If ll_row < -1 Then
	 f_msg_usr_err(211, Title, "완료일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("term_fromdt")
	 Return 
	End If 	
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(tro.closedt, 'YYYYMMDD') >='" + ls_term_fromdt + "' " + &
				"and to_char(tro.closedt, 'YYYYMMDD') < = '" + ls_term_todt + "' "
			  
ElseIf ls_term_fromdt <> "" and ls_term_todt = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(tro.closedt,'YYYYMMDD') >= '" + ls_term_fromdt + "' "
ElseIf ls_term_fromdt = "" and ls_term_todt <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(tro.closedt, 'YYYYMMDD') <= '" + ls_term_todt + "' " 
End If

If ls_close_yn <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "tro.closeyn = '" + ls_close_yn + "' "
End If

If ls_trouble_status <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "tro.trouble_status = '" + ls_trouble_status + "' "
End If

IF ls_receipt_user <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.receipt_user = '" + ls_receipt_user + "' "
End If

IF ls_term_user <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.close_user = '" + ls_term_user + "' "
End If

//출력순서 order by 때문....
ls_sort = ""
If ls_sort1 <> "" Then
	CHoose Case ls_sort1
		Case "1"
//			ls_sort += " tro.customerid A"
			ls_sort += " customer_trouble_customerid A"			
			
		Case "2"
			ls_sort += " receiptdt A"
			
		Case "3"
			ls_sort += " customer_trouble_troubletype A"
			
		Case "4"			
			ls_sort += " customer_trouble_closeyn A"
			
	END CHoose
End IF	

If ls_sort2 <> "" Then
	CHoose Case ls_sort2
		Case "1"
//			ls_sort += ", tro.customerid A"
			ls_sort += ", customer_trouble_customerid A"						
			
		Case "2"
			ls_sort += ", receiptdt A"
			
		Case "3"
			ls_sort += ", customer_trouble_troubletype A"
			
		Case "4"			
			ls_sort += ", customer_trouble_closeyn A"
			
	END CHoose
End IF	

If ls_sort3 <> "" Then
	CHoose Case ls_sort3
		Case "1"
			ls_sort += ", customer_trouble_customerid A"									
			
		Case "2"
			ls_sort += ", receiptdt A"
			
		Case "3"
			ls_sort += ", customer_trouble_troubletype A"
			
		Case "4"			
			ls_sort += ", customer_trouble_closeyn A"
			
	END CHoose
End IF	

If ls_sort4 <> "" Then
	CHoose Case ls_sort4
		Case "1"
			ls_sort += ", customer_trouble_customerid A"	
			
		Case "2"
			ls_sort += ", receiptdt A"
			
		Case "3"
			ls_sort += ", customer_trouble_troubletype A"
			
		Case "4"			
			ls_sort += ", customer_trouble_closeyn A"
			
	END CHoose
End IF	

dw_list.SetSort(ls_sort)
dw_list.sort()
dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
		
		

end event

type dw_cond from w_a_print`dw_cond within b1w_prt_trouble_list_1
integer x = 46
integer y = 40
integer width = 4046
integer height = 516
string dataobject = "b1dw_cnd_prt_trouble_list_1"
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
String ls_filter, ls_itemcod, ls_svccod, ls_troubletypeb
Long ll_row
integer li_rc
DataWindowChild ldc, ldwc_troubletypeb, ldwc_troubletype


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
				This.Object.customernm[row] = ""
				This.SetFocus()
				This.SetColumn("customerid")
				Return -1
		 End if
		 
		 This.Object.customernm[row] = ls_customernm

    Case "svccod"
  		  ls_svccod = this.object.svccod[1]
		  IF IsNull(ls_svccod) THEN ls_svccod = ""
        
		  dw_cond.object.troubletypeb[1] = ""
  		  dw_cond.object.troubletype[1]  = ""
  		  
		  li_rc = dw_cond.GetChild("troubletypeb", ldwc_troubletypeb)
		  IF li_rc = -1 THEN
		      f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
				RETURN -2
		  END IF
		
		  ls_filter = "svccod = '" + ls_svccod + "' "
		  ldwc_troubletypeb.SetFilter(ls_filter)			//Filter정함
		  ldwc_troubletypeb.Filter()
		  ldwc_troubletypeb.SetTransObject(SQLCA)
		  ll_row = ldwc_troubletypeb.Retrieve() 
			
		  IF ll_row < 0 THEN 				//디비 오류 
			   f_msg_usr_err(2100, Title, "Retrieve()")
			   RETURN -2
		  END IF
		  
		  IF ls_svccod = "" THEN
		      This.object.troubletypeb.Protect = 1
				This.object.troubletype.Protect = 1
		  ELSE
		      //선택할수 있게
		      This.object.troubletypeb.Protect = 0
		  END IF
				
    Case "troubletypeb"
		 ls_troubletypeb = dw_cond.object.troubletypeb[1]
		 IF IsNull(ls_troubletypeb) THEN ls_troubletypeb = ""
		 dw_cond.object.troubletype[1] = ""
		 
		 li_rc = dw_cond.GetChild("troubletype", ldwc_troubletype)
		 IF li_rc = -1 THEN
		     f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			  RETURN -2
		 END IF
		 
		 ls_filter = "troubletypea_troubletypeb = '" + ls_troubletypeb + "' "
		 ldwc_troubletype.SetFilter(ls_filter)			//Filter정함
		 ldwc_troubletype.Filter()
		 ldwc_troubletype.SetTransObject(SQLCA)
		 ll_row =ldwc_troubletype.Retrieve() 	
		 
		 IF ll_row < 0 THEN 				//디비 오류 
		     f_msg_usr_err(2100, Title, "Retrieve()")
			  RETURN -2
		 END IF
		 
 	    IF ls_troubletypeb = "" THEN
		     This.object.troubletype.Protect = 1
		 ELSE
		     //선택할수 있게
		     This.object.troubletype.Protect = 0
		 END IF
				
				
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

type p_ok from w_a_print`p_ok within b1w_prt_trouble_list_1
integer x = 4192
integer y = 64
end type

type p_close from w_a_print`p_close within b1w_prt_trouble_list_1
integer x = 4192
integer y = 184
end type

type dw_list from w_a_print`dw_list within b1w_prt_trouble_list_1
integer y = 604
integer width = 4736
integer height = 1032
string dataobject = "b1dw_prt_trouble_list_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_trouble_list_1
integer x = 2688
integer y = 1684
end type

type p_2 from w_a_print`p_2 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_3 from w_a_print`p_3 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_5 from w_a_print`p_5 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_6 from w_a_print`p_6 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_7 from w_a_print`p_7 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_8 from w_a_print`p_8 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_9 from w_a_print`p_9 within b1w_prt_trouble_list_1
integer y = 1684
end type

type p_4 from w_a_print`p_4 within b1w_prt_trouble_list_1
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_trouble_list_1
integer y = 1652
end type

type p_port from w_a_print`p_port within b1w_prt_trouble_list_1
integer y = 1720
end type

type p_land from w_a_print`p_land within b1w_prt_trouble_list_1
integer y = 1720
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_trouble_list_1
integer width = 4082
integer height = 580
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_trouble_list_1
integer y = 1684
end type

