$PBExportHeader$ssrt_prt_autopay_result_list.srw
$PBExportComments$[1hera] Autopayment Result List
forward
global type ssrt_prt_autopay_result_list from w_a_print
end type
end forward

global type ssrt_prt_autopay_result_list from w_a_print
end type
global ssrt_prt_autopay_result_list ssrt_prt_autopay_result_list

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_reqdt, ls_ok

ls_reqdt 	= String(dw_cond.Object.reqdt[1], "yyyymm")
ls_ok 		= Trim(dw_cond.Object.ok[1])
If IsNull(ls_reqdt) 		Then ls_reqdt 		= ""
If IsNull(ls_ok) 			Then ls_ok 			= ""

If ls_reqdt = '' Then
	f_msg_usr_err(200, Title, "Request Date")
	dw_cond.Setfocus()
	dw_cond.Setcolumn("reqdt")
	return
end If

ls_temp 		= "Request Date : " + string(dw_cond.Object.reqdt[1], 'mm-yyyy')
ls_temp += '        Result : ' + ls_ok 
ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

ls_where = ""

If ls_reqdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.REQUESTDT LIKE '" + ls_reqdt + '%' + "' "
End If
If ls_ok <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " A.RESULT = '" + ls_ok + "' "
End If

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

on ssrt_prt_autopay_result_list.create
call super::create
end on

on ssrt_prt_autopay_result_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 2
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list,'ssrt_prt_autopay_result_list')

end event

event ue_reset();call super::ue_reset;dw_cond.Object.ok[1] = 'Y'
end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_autopay_result_list
integer x = 50
integer y = 56
integer width = 2089
integer height = 132
string dataobject = "ssrt_cnd_prt_autopay_result_list"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within ssrt_prt_autopay_result_list
integer x = 2203
integer y = 76
end type

type p_close from w_a_print`p_close within ssrt_prt_autopay_result_list
integer x = 2514
integer y = 76
end type

type dw_list from w_a_print`dw_list within ssrt_prt_autopay_result_list
integer x = 23
integer y = 236
integer height = 1432
string dataobject = "ssrt_prt_autopay_result_list"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_autopay_result_list
end type

type p_2 from w_a_print`p_2 within ssrt_prt_autopay_result_list
end type

type p_3 from w_a_print`p_3 within ssrt_prt_autopay_result_list
end type

type p_5 from w_a_print`p_5 within ssrt_prt_autopay_result_list
end type

type p_6 from w_a_print`p_6 within ssrt_prt_autopay_result_list
end type

type p_7 from w_a_print`p_7 within ssrt_prt_autopay_result_list
end type

type p_8 from w_a_print`p_8 within ssrt_prt_autopay_result_list
end type

type p_9 from w_a_print`p_9 within ssrt_prt_autopay_result_list
end type

type p_4 from w_a_print`p_4 within ssrt_prt_autopay_result_list
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_autopay_result_list
end type

type p_port from w_a_print`p_port within ssrt_prt_autopay_result_list
end type

type p_land from w_a_print`p_land within ssrt_prt_autopay_result_list
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_autopay_result_list
integer y = 20
integer width = 2107
integer height = 184
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_autopay_result_list
end type

