$PBExportHeader$b1w_prt_customer_loc_sum_cv_1.srw
$PBExportComments$[parkkh] 지역구분별 고객상태현황 - Window
forward
global type b1w_prt_customer_loc_sum_cv_1 from w_a_print
end type
end forward

global type b1w_prt_customer_loc_sum_cv_1 from w_a_print
integer width = 3561
end type
global b1w_prt_customer_loc_sum_cv_1 b1w_prt_customer_loc_sum_cv_1

on b1w_prt_customer_loc_sum_cv_1.create
call super::create
end on

on b1w_prt_customer_loc_sum_cv_1.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 2 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_ctype2, ls_ctype1
String	ls_status, ls_location

ls_ctype2		= Trim(dw_cond.Object.ctype2[1])
ls_ctype1		= Trim(dw_cond.Object.ctype1[1])
ls_status			= Trim(dw_cond.Object.status[1])
ls_location		= Trim(dw_cond.Object.location[1])

If( IsNull(ls_ctype2) ) Then ls_ctype2 = ""
If( IsNull(ls_ctype1) ) Then ls_ctype1 = ""
If( IsNull(ls_status) ) Then ls_status = ""
If( IsNull(ls_location) ) Then ls_location = ""

//Dynamic SQL
ls_where = ""

If( ls_location <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "c.location = '"+ ls_location +"'"
End If

If( ls_status <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "c.status = '"+ ls_status +"'"
End If

If( ls_ctype2 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "c.ctype2 = '"+ ls_ctype2 +"'"
End If

If( ls_ctype1 <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "c.ctype1 = '"+ ls_ctype1 +"'"
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

type dw_cond from w_a_print`dw_cond within b1w_prt_customer_loc_sum_cv_1
integer x = 37
integer y = 76
integer width = 2085
integer height = 220
string dataobject = "b1dw_cnd_customer_loc_sum_cv"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_customer_loc_sum_cv_1
integer x = 2272
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_customer_loc_sum_cv_1
integer x = 2583
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_customer_loc_sum_cv_1
integer x = 23
integer width = 3465
integer height = 1248
string dataobject = "b1dw_prt_customer_loc_sum_cv_1"
end type

type p_1 from w_a_print`p_1 within b1w_prt_customer_loc_sum_cv_1
integer x = 3195
end type

type p_2 from w_a_print`p_2 within b1w_prt_customer_loc_sum_cv_1
end type

type p_3 from w_a_print`p_3 within b1w_prt_customer_loc_sum_cv_1
integer x = 2898
end type

type p_5 from w_a_print`p_5 within b1w_prt_customer_loc_sum_cv_1
integer x = 1490
end type

type p_6 from w_a_print`p_6 within b1w_prt_customer_loc_sum_cv_1
integer x = 2107
end type

type p_7 from w_a_print`p_7 within b1w_prt_customer_loc_sum_cv_1
integer x = 1902
end type

type p_8 from w_a_print`p_8 within b1w_prt_customer_loc_sum_cv_1
integer x = 1696
end type

type p_9 from w_a_print`p_9 within b1w_prt_customer_loc_sum_cv_1
end type

type p_4 from w_a_print`p_4 within b1w_prt_customer_loc_sum_cv_1
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_customer_loc_sum_cv_1
end type

type p_port from w_a_print`p_port within b1w_prt_customer_loc_sum_cv_1
end type

type p_land from w_a_print`p_land within b1w_prt_customer_loc_sum_cv_1
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_customer_loc_sum_cv_1
integer x = 23
integer width = 2135
integer height = 308
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_customer_loc_sum_cv_1
integer x = 2601
end type

