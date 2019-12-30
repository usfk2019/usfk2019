$PBExportHeader$b5w_customerlist_prev_req_cv.srw
$PBExportComments$[chooys] 지난청구대상자 리스트
forward
global type b5w_customerlist_prev_req_cv from w_a_print
end type
end forward

global type b5w_customerlist_prev_req_cv from w_a_print
end type
global b5w_customerlist_prev_req_cv b5w_customerlist_prev_req_cv

type variables
String is_firstdt
String is_lastdt


String is_pos
end variables

on b5w_customerlist_prev_req_cv.create
call super::create
end on

on b5w_customerlist_prev_req_cv.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;String ls_trdt
String ls_location
Dec ld_minamt

String ls_where
Long ll_rows

//최소청구금액
ld_minamt = 1000

ls_trdt = String(dw_cond.Object.trdt[1],"yyyymm")
If IsNull(ls_trdt) Then ls_trdt = ""

IF ls_trdt = "" THEN
	f_msg_info(200, title, "청구년월")
	dw_cond.SetFocus()
	dw_cond.SetColumn("trdt")
	Return
END IF

ls_location = dw_cond.Object.location[1]
If IsNull(ls_location) Then ls_location = ""

ls_where = ""

IF ls_location <> "" THEN
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "cus.location = '"+ ls_location +"'"
END IF


dw_list.is_where	= ls_where


ll_rows = dw_list.retrieve(ls_trdt,ld_minamt)


If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
END IF

end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_reset();call super::ue_reset;Date ld_trdt
String ls_chargedt

ls_chargedt = '1'

//청구기준일 가져오기
select reqdt 
into :ld_trdt
from reqconf
where chargedt = :ls_chargedt;


dw_cond.object.trdt[1] = ld_trdt

end event

type dw_cond from w_a_print`dw_cond within b5w_customerlist_prev_req_cv
integer x = 64
integer y = 88
integer width = 1696
integer height = 148
string dataobject = "b5dw_cnd_customerlist_prev_req"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b5w_customerlist_prev_req_cv
integer x = 1856
integer y = 36
end type

type p_close from w_a_print`p_close within b5w_customerlist_prev_req_cv
integer x = 2158
integer y = 36
end type

type dw_list from w_a_print`dw_list within b5w_customerlist_prev_req_cv
integer y = 288
integer height = 1332
string dataobject = "b5dw_customerlist_prev_req_cv"
end type

type p_1 from w_a_print`p_1 within b5w_customerlist_prev_req_cv
end type

type p_2 from w_a_print`p_2 within b5w_customerlist_prev_req_cv
end type

type p_3 from w_a_print`p_3 within b5w_customerlist_prev_req_cv
end type

type p_5 from w_a_print`p_5 within b5w_customerlist_prev_req_cv
end type

type p_6 from w_a_print`p_6 within b5w_customerlist_prev_req_cv
end type

type p_7 from w_a_print`p_7 within b5w_customerlist_prev_req_cv
end type

type p_8 from w_a_print`p_8 within b5w_customerlist_prev_req_cv
end type

type p_9 from w_a_print`p_9 within b5w_customerlist_prev_req_cv
end type

type p_4 from w_a_print`p_4 within b5w_customerlist_prev_req_cv
end type

type gb_1 from w_a_print`gb_1 within b5w_customerlist_prev_req_cv
end type

type p_port from w_a_print`p_port within b5w_customerlist_prev_req_cv
end type

type p_land from w_a_print`p_land within b5w_customerlist_prev_req_cv
end type

type gb_cond from w_a_print`gb_cond within b5w_customerlist_prev_req_cv
integer width = 1737
integer height = 264
end type

type p_saveas from w_a_print`p_saveas within b5w_customerlist_prev_req_cv
end type

