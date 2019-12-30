$PBExportHeader$b1w_prt_trouble_list.srw
$PBExportComments$[parkkh] 유형별 민원내역 리스트
forward
global type b1w_prt_trouble_list from w_a_print
end type
end forward

global type b1w_prt_trouble_list from w_a_print
integer width = 3323
integer height = 1992
end type
global b1w_prt_trouble_list b1w_prt_trouble_list

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
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

end event

on b1w_prt_trouble_list.create
call super::create
end on

on b1w_prt_trouble_list.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_customerid, ls_partner, ls_temp, ls_result[], ls_sort
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close
String ls_svccod, ls_sort1, ls_sort2, ls_sort3, ls_sort4
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

dw_cond.AcceptText()
ls_customerid = Trim(dw_cond.object.customerid[1])
ls_partner = Trim(dw_cond.object.partner[1])
ls_type = Trim(dw_cond.object.troubletype[1])
ls_close = Trim(dw_cond.object.close_yn[1])
ld_todt = dw_cond.object.todt[1]
ld_fromdt = dw_cond.object.fromdt[1]
ls_todt = String(ld_todt, 'yyyymmdd')
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_svccod  = Trim(dw_cond.object.svccod[1])
ls_sort1  = Trim(dw_cond.object.sort1[1])
ls_sort2  = Trim(dw_cond.object.sort2[1])
ls_sort3  = Trim(dw_cond.object.sort3[1])
ls_sort4  = Trim(dw_cond.object.sort4[1])

//Null Check
If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_close) Then ls_close = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_sort1) Then ls_sort1 = ""
If IsNull(ls_sort2) Then ls_sort2 = ""
If IsNull(ls_sort3) Then ls_sort3 = ""
If IsNull(ls_sort4) Then ls_sort4 = ""
		
//Retrieve
ls_where = ""
IF ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.customerid = '" + ls_customerid + "' "
End If

IF ls_partner <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.partner = '" + ls_partner + "' "
End If

IF ls_type <> "" Then 
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tro.troubletype = '" + ls_type + "' "
End If

//ranger가 확정이 되면
If ls_fromdt <> ""  and ls_todt <> "" Then
	ll_row = fi_chk_frto_day(ld_fromdt, ld_todt)
	If ll_row < 0 Then
	 f_msg_usr_err(211, Title, "접수일자")             //입력 날짜 순저 잘 못 됨
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("fromdt")
	 Return 
	End If 	
  If ls_where <> "" Then ls_where += " And "  
  ls_where += "to_char(tro.receiptdt, 'YYYYMMDD') >='" + ls_fromdt + "' " + &
				"and to_char(tro.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' "
			  
ElseIf ls_fromdt <> "" and ls_todt = "" Then			//시작 날짜만 있을때 
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(tro.receiptdt,'YYYYMMDD') > = '" + ls_fromdt + "' "
ElseIf ls_fromdt = "" and ls_todt <> "" Then			//끝나는 날짜만 있을때   
	If ls_where <> "" Then ls_where += "And "
	ls_where += "to_char(tro.receiptdt, 'YYYYMMDD') < = '" + ls_todt + "' " 
End If

If ls_close <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "tro.closeyn = '" + ls_close + "' "
End If

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "tro.svccod = '" + ls_svccod + "' "
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

ls_sort += " , customer_trouble_troubleno A "


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

type dw_cond from w_a_print`dw_cond within b1w_prt_trouble_list
integer x = 46
integer y = 36
integer width = 2487
integer height = 436
string dataobject = "b1dw_cnd_prt_trouble_list"
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
		
End Choose

Return 0 
end event

type p_ok from w_a_print`p_ok within b1w_prt_trouble_list
integer x = 2670
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_trouble_list
integer x = 2967
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_trouble_list
integer y = 492
integer width = 3227
integer height = 1144
string dataobject = "b1dw_prt_trouble_list"
end type

type p_1 from w_a_print`p_1 within b1w_prt_trouble_list
integer x = 2688
integer y = 1684
end type

type p_2 from w_a_print`p_2 within b1w_prt_trouble_list
integer y = 1684
end type

type p_3 from w_a_print`p_3 within b1w_prt_trouble_list
integer y = 1684
end type

type p_5 from w_a_print`p_5 within b1w_prt_trouble_list
integer y = 1684
end type

type p_6 from w_a_print`p_6 within b1w_prt_trouble_list
integer y = 1684
end type

type p_7 from w_a_print`p_7 within b1w_prt_trouble_list
integer y = 1684
end type

type p_8 from w_a_print`p_8 within b1w_prt_trouble_list
integer y = 1684
end type

type p_9 from w_a_print`p_9 within b1w_prt_trouble_list
integer y = 1684
end type

type p_4 from w_a_print`p_4 within b1w_prt_trouble_list
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_trouble_list
integer y = 1652
end type

type p_port from w_a_print`p_port within b1w_prt_trouble_list
integer y = 1720
end type

type p_land from w_a_print`p_land within b1w_prt_trouble_list
integer y = 1720
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_trouble_list
integer width = 2514
integer height = 480
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_trouble_list
integer y = 1684
end type

