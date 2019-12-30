$PBExportHeader$b0w_prt_zone2.srw
$PBExportComments$[kem] 지역별 대역리스트2 - Window
forward
global type b0w_prt_zone2 from w_a_print
end type
end forward

global type b0w_prt_zone2 from w_a_print
integer width = 3621
end type
global b0w_prt_zone2 b0w_prt_zone2

on b0w_prt_zone2.create
call super::create
end on

on b0w_prt_zone2.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로0, 가로1
ib_margin = False
end event

event ue_saveas;call super::ue_saveas;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_nodeno, ls_country, ls_zoncod, ls_areacod

ls_nodeno  = Trim(dw_cond.Object.nodeno[1])
ls_country = Trim(dw_cond.Object.country[1])  
ls_zoncod  = Trim(dw_cond.Object.zoncod[1])
ls_areacod = Trim(dw_cond.Object.areacod[1])

If( IsNull(ls_nodeno) ) Then ls_nodeno = ""
If( IsNull(ls_country) ) Then ls_country = ""
If( IsNull(ls_zoncod) ) Then ls_zoncod = ""
If( IsNull(ls_areacod) ) Then ls_areacod = ""

//필수 항목 Check
If ls_nodeno = "" Then
	f_msg_info(200, Title,"발신지")
	dw_cond.SetFocus()
	dw_cond.SetColumn("nodeno")
   Return
End If


//Dynamic SQL
ls_where = ""
ls_where += " b.nodeno = '" + ls_nodeno + "' "

If ls_country <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where	+= " a.countrycod = '"+ ls_country +"'"
End If

If ls_zoncod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " b.zoncod = '"+ ls_zoncod +"'"
End If

If ls_areacod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " b.areacod = '"+ ls_areacod +"'"
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

type dw_cond from w_a_print`dw_cond within b0w_prt_zone2
integer x = 50
integer y = 48
integer width = 2624
integer height = 228
string dataobject = "b0dw_cnd_prtzone2"
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within b0w_prt_zone2
integer x = 2825
integer y = 56
end type

type p_close from w_a_print`p_close within b0w_prt_zone2
integer x = 3131
integer y = 56
end type

type dw_list from w_a_print`dw_list within b0w_prt_zone2
integer y = 312
integer width = 3493
integer height = 1328
string dataobject = "b0dw_prt_zone2"
end type

type p_1 from w_a_print`p_1 within b0w_prt_zone2
integer x = 3177
integer y = 1676
end type

type p_2 from w_a_print`p_2 within b0w_prt_zone2
integer x = 722
integer y = 1676
end type

type p_3 from w_a_print`p_3 within b0w_prt_zone2
integer x = 2875
integer y = 1676
end type

type p_5 from w_a_print`p_5 within b0w_prt_zone2
integer x = 1426
integer y = 1676
end type

type p_6 from w_a_print`p_6 within b0w_prt_zone2
integer x = 2030
integer y = 1676
end type

type p_7 from w_a_print`p_7 within b0w_prt_zone2
integer x = 1829
integer y = 1676
end type

type p_8 from w_a_print`p_8 within b0w_prt_zone2
integer x = 1627
integer y = 1676
end type

type p_9 from w_a_print`p_9 within b0w_prt_zone2
integer x = 1019
integer y = 1676
end type

type p_4 from w_a_print`p_4 within b0w_prt_zone2
end type

type gb_1 from w_a_print`gb_1 within b0w_prt_zone2
integer y = 1640
end type

type p_port from w_a_print`p_port within b0w_prt_zone2
integer y = 1704
end type

type p_land from w_a_print`p_land within b0w_prt_zone2
integer y = 1716
end type

type gb_cond from w_a_print`gb_cond within b0w_prt_zone2
integer y = 4
integer width = 2679
integer height = 296
end type

type p_saveas from w_a_print`p_saveas within b0w_prt_zone2
integer x = 2583
integer y = 1676
end type

