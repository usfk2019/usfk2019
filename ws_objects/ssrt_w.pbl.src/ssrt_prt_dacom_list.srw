$PBExportHeader$ssrt_prt_dacom_list.srw
$PBExportComments$[hcjung] 데이콤 카드 연동 조회 리스트
forward
global type ssrt_prt_dacom_list from w_a_print
end type
end forward

global type ssrt_prt_dacom_list from w_a_print
end type
global ssrt_prt_dacom_list ssrt_prt_dacom_list

event ue_ok();call super::ue_ok;Long 		ll_row
String 	ls_where, 			ls_temp, 			ls_reqdt, &
			ls_worktype,		ls_date_fr,			ls_date_to,       ls_serialno, &
			ls_pid,				ls_contno,			ls_anino, &
			ls_serialno2

ls_worktype 		= Trim(dw_cond.Object.work_type[1])
ls_date_fr  		= String(dw_cond.Object.date_fr[1],'yyyymmdd')
ls_date_to  		= String(dw_cond.Object.date_to[1],'yyyymmdd')
ls_serialno			= Trim(dw_cond.Object.serialno[1])
ls_anino				= Trim(dw_cond.Object.anino[1])
ls_contno			= Trim(dw_cond.Object.contno[1])
ls_pid				= Trim(dw_cond.Object.pid[1])

If IsNull(ls_worktype) 	Then ls_worktype	= ""
If IsNull(ls_date_fr)	Then ls_date_fr	= ""
If IsNull(ls_date_to)	Then ls_date_to	= ""
If IsNull(ls_serialno)	Then ls_serialno	= ""
If IsNull(ls_anino) 		Then ls_anino		= ""
If IsNull(ls_contno) 	Then ls_contno		= ""
If IsNull(ls_pid) 		Then ls_pid			= ""

ls_where = ""

If ls_worktype <> "" Then
	IF ls_worktype = "Balance" THEN
		ls_where += " work_type = 'Balance Check' "
	ELSEIF ls_worktype = "CardNo" THEN
		ls_where += " work_type = 'Card No. Check' "
	ELSE 
		ls_where += " work_type = '" + ls_worktype + "' "
	END IF
//	If ls_where <> "" Then ls_where += " AND "
End If

If ls_date_fr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(updtdt,'yyyymmdd') >= '" + ls_date_fr + "' "
End If

If ls_date_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(updtdt,'yyyymmdd') <= '" + ls_date_to + "' "
End If

If ls_serialno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " cardno = '" + ls_serialno + "' "
End If

If ls_anino <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " anino = '" + ls_anino + "' "
End If

If ls_contno <> "" Then
	SELECT SERIALNO 
	INTO :ls_serialno2
	FROM ADMST
	WHERE CONTNO = :ls_contno;
	
	If IsNull(ls_serialno2) Then ls_serialno2	= ""
	
	IF ls_serialno2 <> "" THEN
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " cardno = '" + ls_serialno2 + "' "
	END IF
End If

If ls_pid <> "" Then
	SELECT SERIALNO 
	INTO :ls_serialno2
	FROM ADMST
	WHERE PID = :ls_pid;
	
	IF IsNull(ls_serialno2) Then ls_serialno2	= ""
	
	IF ls_serialno2 <> "" THEN
		If ls_where <> "" Then ls_where += " AND "
		ls_where += " cardno = '" + ls_serialno2 + "' "
	END IF
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

on ssrt_prt_dacom_list.create
call super::create
end on

on ssrt_prt_dacom_list.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1
ib_margin = False

end event

event ue_saveas();//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

f_excel_ascii1(dw_list,'ssrt_prt_prepay_list')

end event

event open;call super::open;dw_cond.object.date_fr[1] 				= Date(fdt_get_dbserver_now())
dw_cond.object.date_to[1] 				= Date(fdt_get_dbserver_now())
end event

type dw_cond from w_a_print`dw_cond within ssrt_prt_dacom_list
integer x = 50
integer y = 68
integer width = 1998
integer height = 276
string dataobject = "ssrt_cnd_prt_dacom_list"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_print`p_ok within ssrt_prt_dacom_list
integer x = 2112
integer y = 56
end type

type p_close from w_a_print`p_close within ssrt_prt_dacom_list
integer x = 2423
integer y = 56
end type

type dw_list from w_a_print`dw_list within ssrt_prt_dacom_list
integer x = 23
integer y = 376
integer height = 1292
string dataobject = "ssrt_prt_dacom_list"
end type

type p_1 from w_a_print`p_1 within ssrt_prt_dacom_list
end type

type p_2 from w_a_print`p_2 within ssrt_prt_dacom_list
end type

type p_3 from w_a_print`p_3 within ssrt_prt_dacom_list
end type

type p_5 from w_a_print`p_5 within ssrt_prt_dacom_list
end type

type p_6 from w_a_print`p_6 within ssrt_prt_dacom_list
end type

type p_7 from w_a_print`p_7 within ssrt_prt_dacom_list
end type

type p_8 from w_a_print`p_8 within ssrt_prt_dacom_list
end type

type p_9 from w_a_print`p_9 within ssrt_prt_dacom_list
end type

type p_4 from w_a_print`p_4 within ssrt_prt_dacom_list
end type

type gb_1 from w_a_print`gb_1 within ssrt_prt_dacom_list
end type

type p_port from w_a_print`p_port within ssrt_prt_dacom_list
end type

type p_land from w_a_print`p_land within ssrt_prt_dacom_list
end type

type gb_cond from w_a_print`gb_cond within ssrt_prt_dacom_list
integer y = 20
integer width = 2030
end type

type p_saveas from w_a_print`p_saveas within ssrt_prt_dacom_list
end type

