﻿$PBExportHeader$b1w_prt_customer_detlist.srw
$PBExportComments$[chooys] 고객 상세 리스트 - Window
forward
global type b1w_prt_customer_detlist from w_a_print
end type
end forward

global type b1w_prt_customer_detlist from w_a_print
integer width = 3749
integer height = 1976
end type
global b1w_prt_customer_detlist b1w_prt_customer_detlist

on b1w_prt_customer_detlist.create
call super::create
end on

on b1w_prt_customer_detlist.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2//세로2, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_item, ls_value
String	ls_status, ls_ctype1, ls_macod
String	ls_ctype2, ls_ctype3, ls_location
String	ls_enterdtfrom, ls_enterdtto
String	ls_termdtfrom, ls_termdtto

ls_item			= Trim(dw_cond.Object.item[1])
ls_value			= Trim(dw_cond.Object.value[1])
ls_status		= Trim(dw_cond.Object.status[1])
ls_ctype1		= Trim(dw_cond.Object.ctype1[1])
ls_macod			= Trim(dw_cond.Object.macod[1])
ls_ctype2		= Trim(dw_cond.Object.ctype2[1])
ls_ctype3		= Trim(dw_cond.Object.ctype3[1])
ls_location		= Trim(dw_cond.Object.location[1])
ls_enterdtfrom	= Trim(String(dw_cond.object.enterdtfrom[1],'yyyymmdd'))
ls_enterdtto	= Trim(String(dw_cond.object.enterdtto[1],'yyyymmdd'))
ls_termdtfrom	= Trim(String(dw_cond.object.termdtfrom[1],'yyyymmdd'))
ls_termdtto		= Trim(String(dw_cond.object.termdtto[1],'yyyymmdd'))

If( IsNull(ls_item) ) Then ls_item = ""
If( IsNull(ls_value) ) Then ls_value = ""
If( IsNull(ls_status) ) Then ls_status = ""
If( IsNull(ls_ctype1) ) Then ls_ctype1 = ""
If( IsNull(ls_macod) ) Then ls_macod = ""
If( IsNull(ls_ctype2) ) Then ls_ctype2 = ""
If( IsNull(ls_ctype3) ) Then ls_ctype3 = ""
If( IsNull(ls_location) ) Then ls_location = ""
If( IsNull(ls_enterdtfrom) ) Then ls_enterdtfrom = ""
If( IsNull(ls_enterdtto) ) Then ls_enterdtto = ""
If( IsNull(ls_termdtfrom) ) Then ls_termdtfrom = ""
If( IsNull(ls_termdtto) ) Then ls_termdtto = ""


//Dynamic SQL
ls_where = ""

	If ls_item <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_item
			Case "customerid"
				ls_where += "a.customerid like '" + ls_value + "%' "
			Case "customernm"
				ls_where += "Upper(a.customernm) like '" + Upper(ls_value) + "%' "
			Case "payid"
				ls_where += "a.payid like '" + ls_value + "%' "
			Case "logid"
				ls_where += "Upper(a.logid) like '" + Upper(ls_value) + "%' "
			Case "ssno"
				ls_where += "a.ssno like '" + ls_value + "%' "
			Case "corpno"
				ls_where += "a.corpno like '" + ls_value + "%' "
			Case "corpnm"
				ls_where += "a.corpnm like '" + ls_value + "%' "
			Case "cregno"
				ls_where += "a.cregno like '" + ls_value + "%' "
			Case "phone1"
				ls_where += "a.phone1 like '" + ls_value + "%' "
			End Choose		
	End If

If( ls_status <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "a.status = '"+ ls_status +"'"
End If

If( ls_ctype1 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "a.ctype1 = '"+ ls_ctype1 +"'"
End If

If( ls_macod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "a.macod = '"+ ls_macod +"'"
End If

If( ls_ctype2 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "a.ctype2 = '"+ ls_ctype2 +"'"
End If

If( ls_ctype3 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "a.ctype3 = '"+ ls_ctype3 +"'"
End If

If( ls_location <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "a.location = '"+ ls_location +"'"
End If

If( ls_enterdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(a.enterdt, 'YYYYMMDD') >= '"+ ls_enterdtfrom +"'"
End If

If( ls_enterdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(a.enterdt, 'YYYYMMDD') <= '"+ ls_enterdtto +"'"
End If

If( ls_termdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(a.termdt, 'YYYYMMDD') >= '"+ ls_termdtfrom +"'"
End If

If( ls_termdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(a.termdt, 'YYYYMMDD') <= '"+ ls_termdtto +"'"
End If


dw_list.is_where	= ls_where

//Retrieve
ll_rows	= dw_list.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

//MessageBox( "ls_where",ls_where )
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_customer_detlist
integer x = 46
integer y = 40
integer width = 2953
integer height = 208
string dataobject = "b1dw_cnd_prtcustomerdetlist"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_customer_detlist
integer x = 3072
integer y = 56
end type

type p_close from w_a_print`p_close within b1w_prt_customer_detlist
integer x = 3383
integer y = 56
end type

type dw_list from w_a_print`dw_list within b1w_prt_customer_detlist
integer x = 32
integer width = 3653
integer height = 1220
string dataobject = "b1dw_prt_customerdetlist_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_customer_detlist
end type

type p_2 from w_a_print`p_2 within b1w_prt_customer_detlist
end type

type p_3 from w_a_print`p_3 within b1w_prt_customer_detlist
end type

type p_5 from w_a_print`p_5 within b1w_prt_customer_detlist
end type

type p_6 from w_a_print`p_6 within b1w_prt_customer_detlist
end type

type p_7 from w_a_print`p_7 within b1w_prt_customer_detlist
end type

type p_8 from w_a_print`p_8 within b1w_prt_customer_detlist
end type

type p_9 from w_a_print`p_9 within b1w_prt_customer_detlist
end type

type p_4 from w_a_print`p_4 within b1w_prt_customer_detlist
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_customer_detlist
end type

type p_port from w_a_print`p_port within b1w_prt_customer_detlist
end type

type p_land from w_a_print`p_land within b1w_prt_customer_detlist
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_customer_detlist
integer width = 2999
integer height = 264
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_customer_detlist
end type

