$PBExportHeader$b2w_prt_partnerbond.srw
$PBExportComments$[chooys] 대리점여신한도리스트 - Window
forward
global type b2w_prt_partnerbond from w_a_print
end type
end forward

global type b2w_prt_partnerbond from w_a_print
integer width = 3168
integer height = 1952
end type
global b2w_prt_partnerbond b2w_prt_partnerbond

on b2w_prt_partnerbond.create
call super::create
end on

on b2w_prt_partnerbond.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_partner, ls_partnernm
String	ls_bonddate

ls_partner		= Trim(dw_cond.Object.partner[1])
ls_partnernm	= Trim(dw_cond.Object.partnernm[1])
ls_bonddate		= Trim(String(dw_cond.object.bonddate[1],'yyyymmdd'))

If( IsNull(ls_partner) ) Then ls_partner = ""
If( IsNull(ls_partnernm) ) Then ls_partnernm = ""
If( IsNull(ls_bonddate) ) Then ls_bonddate = ""

//조회기준일 체크
IF(ls_bonddate = "") THEN
	f_msg_info(200, Title, "조회기준일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
	RETURN
END IF

//Dynamic SQL
ls_where = ""

If( ls_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "partnermst.partner = '"+ ls_partner +"'"
End If

If( ls_partnernm <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "partnermst.partnernm LIKE '%"+ ls_partnernm +"%'"
End If

If( ls_bonddate <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "to_char(partnerbond.fromdt, 'YYYYMMDD') <= '"+ ls_bonddate + "'" + &
	" AND to_char(decode(partnerbond.todt,null,sysdate,partnerbond.todt), 'YYYYMMDD') >= '"+ ls_bonddate +"'"
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

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 0 //세로1, 가로0
ib_margin = False
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;dw_cond.Object.bonddate[1] = fdt_get_dbserver_now()
end event

event open;call super::open;dw_cond.Object.bonddate[1] = fdt_get_dbserver_now()
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_partnerbond
integer x = 27
integer y = 48
integer width = 2098
integer height = 180
string dataobject = "b2dw_cnd_prtpartnerbond"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_partnerbond
integer x = 2249
integer y = 48
end type

type p_close from w_a_print`p_close within b2w_prt_partnerbond
integer x = 2560
integer y = 48
end type

type dw_list from w_a_print`dw_list within b2w_prt_partnerbond
integer x = 23
integer y = 268
integer width = 3067
string dataobject = "b2dw_prt_partnerbond"
end type

type p_1 from w_a_print`p_1 within b2w_prt_partnerbond
integer y = 1624
end type

type p_2 from w_a_print`p_2 within b2w_prt_partnerbond
integer y = 1624
end type

type p_3 from w_a_print`p_3 within b2w_prt_partnerbond
integer y = 1624
end type

type p_5 from w_a_print`p_5 within b2w_prt_partnerbond
integer y = 1624
end type

type p_6 from w_a_print`p_6 within b2w_prt_partnerbond
integer y = 1624
end type

type p_7 from w_a_print`p_7 within b2w_prt_partnerbond
integer y = 1624
end type

type p_8 from w_a_print`p_8 within b2w_prt_partnerbond
integer y = 1624
end type

type p_9 from w_a_print`p_9 within b2w_prt_partnerbond
integer y = 1624
end type

type p_4 from w_a_print`p_4 within b2w_prt_partnerbond
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_partnerbond
integer y = 1584
end type

type p_port from w_a_print`p_port within b2w_prt_partnerbond
integer y = 1648
end type

type p_land from w_a_print`p_land within b2w_prt_partnerbond
integer y = 1660
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_partnerbond
integer x = 18
integer width = 2121
integer height = 256
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_partnerbond
integer y = 1624
end type

