$PBExportHeader$b1w_prt_trouble_sumlist_1.srw
$PBExportComments$[choous] 민원처리통계 리스트_1
forward
global type b1w_prt_trouble_sumlist_1 from w_a_print
end type
end forward

global type b1w_prt_trouble_sumlist_1 from w_a_print
integer width = 3099
integer height = 1952
end type
global b1w_prt_trouble_sumlist_1 b1w_prt_trouble_sumlist_1

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 2 //가로 기준
ib_margin = True
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_trouble_sumlist
	Desc.	: 민원처리통계 리스트 
	Ver.	: 1.0
	Date	: 2002.10.14
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/

end event

on b1w_prt_trouble_sumlist_1.create
call super::create
end on

on b1w_prt_trouble_sumlist_1.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_type, ls_fromdt, ls_todt, ls_where, ls_svctype
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

dw_cond.AcceptText()
ls_type = Trim(dw_cond.object.troubletype[1])
ld_todt = dw_cond.object.todt[1]
ld_fromdt = dw_cond.object.fromdt[1]
ls_todt = String(ld_todt, 'yyyymmdd')
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_svctype  = Trim(dw_cond.object.svctype[1])

//Null Check
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_svctype) Then ls_svctype = ""
		
//Retrieve
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


If ls_type = "1"  Then 
	dw_list.DataObject = "b1dw_prt_trouble_sumlist_type_1"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()
ElseIf ls_svctype = "1" Then
	dw_list.DataObject = "b1dw_prt_trouble_sumlist_svccod"
	dw_list.SetTransObject(SQLCA)
	dw_list.is_where = ls_where
	ll_row = dw_list.Retrieve()
End If

If ls_fromdt <> ""  Then
	dw_list.object.fromdt_t.Text = String(ld_fromdt,'yyyy-mm-dd') 
End If

If ls_todt <> "" Then
	dw_list.object.todt_t.Text = String(ld_todt,'yyyy-mm-dd') 
End If

dw_list.SetRedraw(false)

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

dw_list.setredraw(true)
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_trouble_sumlist_1
integer y = 40
integer width = 1271
integer height = 316
string dataobject = "b1dw_cnd_prt_trouble_sumlist"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;//Item Change Event
String ls_customernm

Choose Case dwo.name
	Case "troubletype"
		
		 If data = '1' then 
			 This.Object.svctype[1] = '0'		
			 Return -1
		 End If		 

		 
	Case "svctype"
		
		 If data = '1' then 
			 This.Object.troubletype[1] = '0'			
			 Return -1
		 End If		 
		 
End Choose

Return 0 
end event

type p_ok from w_a_print`p_ok within b1w_prt_trouble_sumlist_1
integer x = 1495
end type

type p_close from w_a_print`p_close within b1w_prt_trouble_sumlist_1
integer x = 1815
end type

type dw_list from w_a_print`dw_list within b1w_prt_trouble_sumlist_1
integer x = 23
integer y = 420
integer width = 2981
integer height = 1144
string dataobject = "b1dw_prt_trouble_sumlist_type_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_2 from w_a_print`p_2 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_3 from w_a_print`p_3 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_5 from w_a_print`p_5 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_6 from w_a_print`p_6 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_7 from w_a_print`p_7 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_8 from w_a_print`p_8 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_9 from w_a_print`p_9 within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

type p_4 from w_a_print`p_4 within b1w_prt_trouble_sumlist_1
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_trouble_sumlist_1
integer y = 1596
end type

type p_port from w_a_print`p_port within b1w_prt_trouble_sumlist_1
integer y = 1660
end type

type p_land from w_a_print`p_land within b1w_prt_trouble_sumlist_1
integer y = 1672
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_trouble_sumlist_1
integer width = 1335
integer height = 392
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_trouble_sumlist_1
integer y = 1636
end type

