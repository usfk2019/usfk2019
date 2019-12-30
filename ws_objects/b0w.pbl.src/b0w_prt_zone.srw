$PBExportHeader$b0w_prt_zone.srw
$PBExportComments$[chooys] 지역별 대역리스트 - Window
forward
global type b0w_prt_zone from w_a_print
end type
end forward

global type b0w_prt_zone from w_a_print
integer width = 3621
end type
global b0w_prt_zone b0w_prt_zone

on b0w_prt_zone.create
call super::create
end on

on b0w_prt_zone.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로0, 가로1
ib_margin = False
end event

event ue_saveas;call super::ue_saveas;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_priceplan, ls_nodeno, ls_zoncod

ls_priceplan	= Trim(dw_cond.Object.priceplan[1])
ls_nodeno		= Trim(dw_cond.Object.nodeno[1])
ls_zoncod		= Trim(dw_cond.Object.zoncod[1])

If( IsNull(ls_priceplan) ) Then ls_priceplan = ""
If( IsNull(ls_nodeno) ) Then ls_nodeno = ""
If( IsNull(ls_zoncod) ) Then ls_zoncod = ""

//가격정책은 필수입력
If( ls_priceplan = "" ) Then
	f_msg_info(200, Title, "가격정책")
	RETURN
End If


//Dynamic SQL
ls_where = ""

If( ls_priceplan <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "priceplan = '"+ ls_priceplan +"'"
End If

If( ls_nodeno <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "nodeno = '"+ ls_nodeno +"'"
End If

If( ls_zoncod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "zoncod = '"+ ls_zoncod +"'"
End If


dw_list.is_where	= ls_where

//Retrieve
ll_rows	= dw_list.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If



end event

event ue_saveas_init;call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b0w_prt_zone
integer x = 50
integer y = 48
integer width = 2761
integer height = 228
string dataobject = "b0dw_cnd_prtzone"
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within b0w_prt_zone
integer x = 2926
integer y = 56
end type

type p_close from w_a_print`p_close within b0w_prt_zone
integer x = 3232
integer y = 56
end type

type dw_list from w_a_print`dw_list within b0w_prt_zone
integer y = 312
integer width = 3493
integer height = 1328
string dataobject = "b0dw_prt_zone"
end type

type p_1 from w_a_print`p_1 within b0w_prt_zone
integer x = 3177
integer y = 1676
end type

type p_2 from w_a_print`p_2 within b0w_prt_zone
integer x = 722
integer y = 1676
end type

type p_3 from w_a_print`p_3 within b0w_prt_zone
integer x = 2875
integer y = 1676
end type

type p_5 from w_a_print`p_5 within b0w_prt_zone
integer x = 1426
integer y = 1676
end type

type p_6 from w_a_print`p_6 within b0w_prt_zone
integer x = 2030
integer y = 1676
end type

type p_7 from w_a_print`p_7 within b0w_prt_zone
integer x = 1829
integer y = 1676
end type

type p_8 from w_a_print`p_8 within b0w_prt_zone
integer x = 1627
integer y = 1676
end type

type p_9 from w_a_print`p_9 within b0w_prt_zone
integer x = 1019
integer y = 1676
end type

type p_4 from w_a_print`p_4 within b0w_prt_zone
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_zone
integer y = 1640
end type

type p_port from w_a_print`p_port within b0w_prt_zone
integer y = 1704
end type

type p_land from w_a_print`p_land within b0w_prt_zone
integer y = 1716
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_zone
integer y = 4
integer width = 2816
integer height = 296
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_zone
integer x = 2583
integer y = 1676
end type

