$PBExportHeader$b1w_prt_term_customer.srw
$PBExportComments$[chooys] 해지고객 리스트 - Window
forward
global type b1w_prt_term_customer from w_a_print
end type
end forward

global type b1w_prt_term_customer from w_a_print
integer width = 3561
end type
global b1w_prt_term_customer b1w_prt_term_customer

on b1w_prt_term_customer.create
call super::create
end on

on b1w_prt_term_customer.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_termtype, ls_ctype1
String	ls_macod, ls_location
String	ls_termdtfrom, ls_termdtto
String	ls_termcod	//해지상태코드


ls_termtype		= Trim(dw_cond.Object.termtype[1])
ls_ctype1		= Trim(dw_cond.Object.ctype1[1])
ls_macod			= Trim(dw_cond.Object.macod[1])
ls_location		= Trim(dw_cond.Object.location[1])
ls_termdtfrom	= Trim(String(dw_cond.object.termdtfrom[1],'yyyymmdd'))
ls_termdtto		= Trim(String(dw_cond.object.termdtto[1],'yyyymmdd'))

If( IsNull(ls_termtype) ) Then ls_termtype = ""
If( IsNull(ls_ctype1) ) Then ls_ctype1 = ""
If( IsNull(ls_macod) ) Then ls_macod = ""
If( IsNull(ls_location) ) Then ls_location = ""
If( IsNull(ls_termdtfrom) ) Then ls_termdtfrom = ""
If( IsNull(ls_termdtto) ) Then ls_termdtto = ""


//Dynamic SQL
ls_where = ""

//기본조건: customerm.status = 해지상태코드(해지상태코드: sysctl1t.module='B0', ref_no='P201')
// - 해지상태코드 구하기
SELECT ref_content 
INTO :ls_termcod
FROM sysctl1t
WHERE	module = 'B0' AND ref_no = 'P201';

ls_where	+= "status = '"+ ls_termcod	+"'"



If( ls_termtype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "termtype = '"+ ls_termtype +"'"
End If

If( ls_ctype1 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "ctype1 = '"+ ls_ctype1 +"'"
End If

If( ls_macod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "macod = '"+ ls_macod +"'"
End If

If( ls_location <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "location = '"+ ls_location +"'"
End If

If( ls_termdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(termdt, 'YYYYMMDD') >= '"+ ls_termdtfrom +"'"
End If

If( ls_termdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(termdt, 'YYYYMMDD') <= '"+ ls_termdtto +"'"
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

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b1w_prt_term_customer
integer x = 41
integer width = 2103
integer height = 296
string dataobject = "b1dw_cnd_prttermcustomer"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_term_customer
integer x = 2272
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_term_customer
integer x = 2583
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_term_customer
integer x = 23
integer y = 376
integer width = 3465
integer height = 1232
string dataobject = "b1dw_prt_termcustomer"
end type

type p_1 from w_a_print`p_1 within b1w_prt_term_customer
integer x = 3195
end type

type p_2 from w_a_print`p_2 within b1w_prt_term_customer
end type

type p_3 from w_a_print`p_3 within b1w_prt_term_customer
integer x = 2898
end type

type p_5 from w_a_print`p_5 within b1w_prt_term_customer
integer x = 1490
end type

type p_6 from w_a_print`p_6 within b1w_prt_term_customer
integer x = 2107
end type

type p_7 from w_a_print`p_7 within b1w_prt_term_customer
integer x = 1902
end type

type p_8 from w_a_print`p_8 within b1w_prt_term_customer
integer x = 1696
end type

type p_9 from w_a_print`p_9 within b1w_prt_term_customer
end type

type p_4 from w_a_print`p_4 within b1w_prt_term_customer
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_term_customer
end type

type p_port from w_a_print`p_port within b1w_prt_term_customer
end type

type p_land from w_a_print`p_land within b1w_prt_term_customer
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_term_customer
integer x = 23
integer width = 2135
integer height = 360
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_term_customer
integer x = 2601
end type

