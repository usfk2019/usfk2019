$PBExportHeader$ssrt_prt_prepaydet_list.srw
$PBExportComments$[1hera] Base별 선수금 Report
forward
global type ssrt_prt_prepaydet_list from w_a_print
end type
end forward

global type ssrt_prt_prepaydet_list from w_a_print
end type
global ssrt_prt_prepaydet_list ssrt_prt_prepaydet_list

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_yn, &
			ls_base, 			ls_workdt_fr,		ls_workdt_to

ls_workdt_fr	= String(dw_cond.Object.workdt_fr[1], 'yyyymmdd')
ls_workdt_to	= String(dw_cond.Object.workdt_to[1], 'yyyymmdd')
ls_base 			= Trim(dw_cond.Object.base[1])
ls_yn 			= Trim(dw_cond.Object.item_yn[1])

If IsNull(ls_workdt_fr) 		Then ls_workdt_fr		= ""
If IsNull(ls_workdt_to) 		Then ls_workdt_to		= ""
If IsNull(ls_base) 				Then ls_base		= ""

ls_temp 		= "Date : " + string(dw_cond.Object.workdt_fr[1], 'mm-dd-yyyy') + ' ~ ' + &
								  string(dw_cond.Object.workdt_to[1], 'mm-dd-yyyy')
ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

ls_where = ""

If ls_workdt_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " TO_CHAR( a.workdt, 'yyyymmdd' ) >= '" + ls_workdt_fr + "' "
End If
If ls_workdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " TO_CHAR(A.WORKDT, 'yyyymmdd') <= '" + ls_workdt_to + "' "
End If
If ls_base <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " C.BASECOD = '" + ls_base + "' "
End If
IF ls_yn = '1' THEN
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.RECTYPE IN ('I', 'F') " 
ELSE
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.RECTYPE IN ('O', 'R') " 
END IF

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If


end event

event ue_saveas_init();ib_saveas = True
idw_saveas = dw_list
end event

on ssrt_prt_prepaydet_list.create
call super::create
end on

on ssrt_prt_prepaydet_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list,'ssrt_prt_prepaydet_list')

end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_prepaydet_list
integer x = 50
integer y = 56
integer width = 1838
integer height = 192
string dataobject = "ssrt_cnd_prt_prepaydet_list"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within ssrt_prt_prepaydet_list
integer x = 1929
integer y = 76
end type

type p_close from w_a_print`p_close within ssrt_prt_prepaydet_list
integer x = 2240
integer y = 76
end type

type dw_list from w_a_print`dw_list within ssrt_prt_prepaydet_list
integer x = 23
integer y = 276
integer height = 1392
string dataobject = "ssrt_prt_prepaydet_list"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_prepaydet_list
end type

type p_2 from w_a_print`p_2 within ssrt_prt_prepaydet_list
end type

type p_3 from w_a_print`p_3 within ssrt_prt_prepaydet_list
end type

type p_5 from w_a_print`p_5 within ssrt_prt_prepaydet_list
end type

type p_6 from w_a_print`p_6 within ssrt_prt_prepaydet_list
end type

type p_7 from w_a_print`p_7 within ssrt_prt_prepaydet_list
end type

type p_8 from w_a_print`p_8 within ssrt_prt_prepaydet_list
end type

type p_9 from w_a_print`p_9 within ssrt_prt_prepaydet_list
end type

type p_4 from w_a_print`p_4 within ssrt_prt_prepaydet_list
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_prepaydet_list
end type

type p_port from w_a_print`p_port within ssrt_prt_prepaydet_list
end type

type p_land from w_a_print`p_land within ssrt_prt_prepaydet_list
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_prepaydet_list
integer y = 20
integer width = 1883
integer height = 236
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_prepaydet_list
end type

