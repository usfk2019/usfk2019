$PBExportHeader$b1w_1_prt_trouble_svccod_v20.srw
$PBExportComments$[jsha] 서비스별 장애보고서
forward
global type b1w_1_prt_trouble_svccod_v20 from w_a_print
end type
end forward

global type b1w_1_prt_trouble_svccod_v20 from w_a_print
integer width = 3259
end type
global b1w_1_prt_trouble_svccod_v20 b1w_1_prt_trouble_svccod_v20

on b1w_1_prt_trouble_svccod_v20.create
call super::create
end on

on b1w_1_prt_trouble_svccod_v20.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list

end event

event ue_ok();call super::ue_ok;String ls_svctype, ls_svccod, ls_fromdt, ls_todt
String ls_where
Long ll_row

ls_svctype = fs_snvl(dw_cond.Object.svctype[1], "")
ls_svccod = fs_snvl(dw_cond.Object.svccod[1], "")
ls_fromdt = fs_snvl(String(dw_cond.Object.fromdt[1], 'yyyy-mm-dd'), "")
ls_todt = fs_snvl(String(dw_cond.Object.todt[1], 'yyyy-mm-dd'), "")

ls_where = ""
If ls_svctype <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " b.svctype = '" + ls_svctype + "' "
End If
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " a.svccod = '" + ls_svccod + "' "
End If
IF ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " a.receiptdt >= to_date('" + ls_fromdt + "', 'yyyy-mm-dd') "
End If
If ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " a.receiptdt <= to_date('" + ls_todt + "', 'yyyy-mm-dd') + 0.99999 "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.TItle, "")
End IF
end event

type dw_cond from w_a_print`dw_cond within b1w_1_prt_trouble_svccod_v20
integer width = 2075
integer height = 244
string dataobject = "b1dw_1_cnd_prt_trouble_svccod_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_svccod, ls_troubletypec
String ls_filter
Long ll_row
DataWindowChild ldc_svccod

ll_row = dw_cond.GetChild("svccod", ldc_svccod)
If ll_row < 0 Then MessageBox("Error", "Not a DataWindowChild Svccod")

Choose Case dwo.Name
	Case "svctype"
		dw_cond.Object.svccod[1] = ""				
		ls_filter = "svctype = '" + data + "' "

		ldc_svccod.SetFilter(ls_filter)			//Filter정함
		ldc_svccod.Filter()
		ldc_svccod.SetTransObject(SQLCA)
		ll_row =ldc_svccod.Retrieve() 
				
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
	
End Choose

Return 0
end event

type p_ok from w_a_print`p_ok within b1w_1_prt_trouble_svccod_v20
integer x = 2267
end type

type p_close from w_a_print`p_close within b1w_1_prt_trouble_svccod_v20
integer x = 2569
end type

type dw_list from w_a_print`dw_list within b1w_1_prt_trouble_svccod_v20
integer y = 324
integer width = 3118
string dataobject = "b1dw_1_prt_trouble_svccod_v20"
end type

type p_1 from w_a_print`p_1 within b1w_1_prt_trouble_svccod_v20
end type

type p_2 from w_a_print`p_2 within b1w_1_prt_trouble_svccod_v20
end type

type p_3 from w_a_print`p_3 within b1w_1_prt_trouble_svccod_v20
end type

type p_5 from w_a_print`p_5 within b1w_1_prt_trouble_svccod_v20
end type

type p_6 from w_a_print`p_6 within b1w_1_prt_trouble_svccod_v20
end type

type p_7 from w_a_print`p_7 within b1w_1_prt_trouble_svccod_v20
end type

type p_8 from w_a_print`p_8 within b1w_1_prt_trouble_svccod_v20
end type

type p_9 from w_a_print`p_9 within b1w_1_prt_trouble_svccod_v20
end type

type p_4 from w_a_print`p_4 within b1w_1_prt_trouble_svccod_v20
end type

type gb_1 from w_a_print`gb_1 within b1w_1_prt_trouble_svccod_v20
end type

type p_port from w_a_print`p_port within b1w_1_prt_trouble_svccod_v20
end type

type p_land from w_a_print`p_land within b1w_1_prt_trouble_svccod_v20
end type

type gb_cond from w_a_print`gb_cond within b1w_1_prt_trouble_svccod_v20
integer width = 2117
integer height = 312
end type

type p_saveas from w_a_print`p_saveas within b1w_1_prt_trouble_svccod_v20
end type

