$PBExportHeader$ssrt2_prt_schedule_statistics_report.srw
$PBExportComments$[hcjung] 스케쥴 통계 조회
forward
global type ssrt2_prt_schedule_statistics_report from w_a_print
end type
end forward

global type ssrt2_prt_schedule_statistics_report from w_a_print
end type
global ssrt2_prt_schedule_statistics_report ssrt2_prt_schedule_statistics_report

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_reqdt

ls_reqdt 	= String(dw_cond.Object.reqdt[1], "yyyymm")

If IsNull(ls_reqdt) 		Then ls_reqdt 		= ""

If ls_reqdt = '' Then
	f_msg_usr_err(200, Title, "Request Date")
	dw_cond.Setfocus()
	dw_cond.Setcolumn("reqdt")
	return
end If

ls_temp 		= "Request Date : " + string(dw_cond.Object.reqdt[1], 'mm-yyyy')
ls_temp 		= "t_final.text='" + ls_temp + "'"
dw_list.Modify(ls_temp)

//ls_where = ""
//
//If ls_reqdt <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += " A.REQUESTDT = '" + ls_reqdt +  "' "
//End If
//
//dw_list.is_where = ls_where
ll_row = dw_list.Retrieve(ls_reqdt)

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

on ssrt2_prt_schedule_statistics_report.create
call super::create
end on

on ssrt2_prt_schedule_statistics_report.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

Long ll_row, ll_jj
String ls_nm
IF dw_list.RowCount() > 0 then
	FOR ll_jj = 1 to dw_list.RowCount()
		ls_nm = dw_list.describe("Evaluate('LookUpDisplay(basenm)'," + string(ll_jj) +")")
		dw_list.Object.basenm[ll_jj] = ls_nm
	NEXT
	f_excel_ascii1(dw_list,'ssrt2_prt_schedule_statistics_report')
END IF

end event

type dw_cond from w_a_print`dw_cond within ssrt2_prt_schedule_statistics_report
integer x = 50
integer y = 60
integer width = 855
integer height = 112
string dataobject = "ssrt2_cnd_trouble_statistics"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;//This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
//This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select customernm		  INTO :ls_customernm		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		 IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			return 1
		ELSE
			This.Object.customernm[1] 	=  ls_customernm
		END IF
End Choose

end event

type p_ok from w_a_print`p_ok within ssrt2_prt_schedule_statistics_report
integer x = 946
integer y = 64
end type

type p_close from w_a_print`p_close within ssrt2_prt_schedule_statistics_report
integer x = 1253
integer y = 64
end type

type dw_list from w_a_print`dw_list within ssrt2_prt_schedule_statistics_report
integer y = 200
integer width = 2999
integer height = 1468
string dataobject = "ssrt2_prt_schedule_statistics_list"
end type

type p_1 from w_a_print`p_1 within ssrt2_prt_schedule_statistics_report
end type

type p_2 from w_a_print`p_2 within ssrt2_prt_schedule_statistics_report
end type

type p_3 from w_a_print`p_3 within ssrt2_prt_schedule_statistics_report
end type

type p_5 from w_a_print`p_5 within ssrt2_prt_schedule_statistics_report
end type

type p_6 from w_a_print`p_6 within ssrt2_prt_schedule_statistics_report
end type

type p_7 from w_a_print`p_7 within ssrt2_prt_schedule_statistics_report
end type

type p_8 from w_a_print`p_8 within ssrt2_prt_schedule_statistics_report
end type

type p_9 from w_a_print`p_9 within ssrt2_prt_schedule_statistics_report
end type

type p_4 from w_a_print`p_4 within ssrt2_prt_schedule_statistics_report
end type

type gb_1 from w_a_print`gb_1 within ssrt2_prt_schedule_statistics_report
end type

type p_port from w_a_print`p_port within ssrt2_prt_schedule_statistics_report
end type

type p_land from w_a_print`p_land within ssrt2_prt_schedule_statistics_report
end type

type gb_cond from w_a_print`gb_cond within ssrt2_prt_schedule_statistics_report
integer y = 20
integer width = 882
integer height = 160
end type

type p_saveas from w_a_print`p_saveas within ssrt2_prt_schedule_statistics_report
end type

