$PBExportHeader$b1w_1_prt_trouble_country_v20.srw
$PBExportComments$[jsha] 국가별장애 보고서
forward
global type b1w_1_prt_trouble_country_v20 from w_a_print
end type
end forward

global type b1w_1_prt_trouble_country_v20 from w_a_print
integer width = 3342
end type
global b1w_1_prt_trouble_country_v20 b1w_1_prt_trouble_country_v20

on b1w_1_prt_trouble_country_v20.create
call super::create
end on

on b1w_1_prt_trouble_country_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_svctype, ls_svccod, ls_troubletypec, ls_troubletypeb, ls_troubletypea, ls_troubletype, ls_fromdt, ls_todt
String ls_where
Long ll_row

ls_svctype = fs_snvl(dw_cond.Object.svctype[1], "")
ls_svccod = fs_snvl(dw_cond.Object.svccod[1], "")
ls_troubletypec = fs_snvl(dw_cond.Object.troubletypec[1], "")
ls_troubletypeb = fs_snvl(dw_cond.Object.troubletypeb[1], "")
ls_troubletypea = fs_snvl(dw_cond.Object.troubletypea[1], "")
ls_troubletype = fs_snvl(dw_cond.Object.troubletype[1], "")
ls_fromdt = fs_snvl(String(dw_cond.Object.fromdt[1], 'yyyy-mm-dd'), "")
ls_todt = fs_snvl(String(dw_cond.Object.todt[1], 'yyyy-mm-dd'), "")

ls_where = ""
If ls_svctype <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " e.svctype = '" + ls_svctype + "' "
End If
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " a.svccod = '" + ls_svccod + "' "
End If
If ls_troubletypec <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " d.troubletypec ='" + ls_troubletypec + "' "
End If
If ls_troubletypeb <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " c.troubletypeb = '" + ls_troubletypeb + "' "
End If
If ls_troubletypea <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " b.troubletypea = '" + ls_troubletypea + "' "
End If
If ls_troubletype <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " b.troubletype = '" + ls_troubletype + "' "
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

event ue_saveas_init();call super::ue_saveas_init;//파일로 저장 할 수있게
ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b1w_1_prt_trouble_country_v20
integer width = 2423
integer height = 352
string dataobject = "b1dw_cnd_prt_trouble_country_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String ls_svccod, ls_troubletypec
String ls_filter
Long ll_row
DataWindowChild ldc_svccod, ldc_troubletypeb, ldc_troubletypea, ldc_troubletype

ll_row = dw_cond.GetChild("svccod", ldc_svccod)
If ll_row < 0 Then MessageBox("Error", "Not a DataWindowChild Svccod")

ll_row = dw_cond.GetChild("troubletypeb", ldc_troubletypeb)
If ll_row < 0 Then MessageBox("Error", "Not a DataWindowChild troubletypeb")

ll_row = dw_cond.GetChild("troubletypea", ldc_troubletypea)
If ll_row < 0 Then MessageBox("Error", "Not a DataWindowChild troubletypea")

ll_row = dw_cond.GetChild("troubletype", ldc_troubletype)
If ll_row < 0 Then MessageBox("Error", "Not a DataWindowChild troubletype")

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
	Case "svccod"
		ls_troubletypec = fs_snvl(dw_cond.Object.troubletypec[1], "")
		dw_cond.Object.troubletypeb[1] = ""
				
		ls_filter = "troubletypeb_svccod = '" + data + "' "
		ls_filter += " AND troubletypeb_troubletypec = '" + ls_troubletypec + "' "
	   ldc_troubletypeb.SetFilter(ls_filter)			//Filter정함
		ldc_troubletypeb.Filter()
		ldc_troubletypeb.SetTransObject(SQLCA)
		ll_row =ldc_troubletypeb.Retrieve() 
				
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
	Case "troubletypec"
		ls_svccod = fs_snvl(dw_cond.Object.svccod[1], "")
		dw_cond.Object.troubletypeb[1] = ""
		
		ls_filter = "troubletypeb_troubletypec = '" + data + "' "
		ls_filter += " AND troubletypeb_svccod = '" + ls_svccod + "' "
	   ldc_troubletypeb.SetFilter(ls_filter)			//Filter정함
		ldc_troubletypeb.Filter()
		ldc_troubletypeb.SetTransObject(SQLCA)
		ll_row =ldc_troubletypeb.Retrieve() 
				
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If		
	Case "troubletypeb"
		dw_cond.Object.troubletypea[1] = ""
		
		ls_filter = "troubletypea_troubletypeb = '" + data + "' "
	   ldc_troubletypea.SetFilter(ls_filter)			//Filter정함
		ldc_troubletypea.Filter()
		ldc_troubletypea.SetTransObject(SQLCA)
		ll_row =ldc_troubletypea.Retrieve() 
				
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If		
	Case "troubletypea"
		dw_cond.Object.troubletype[1] = ""
		
		ls_filter = "troubletypea = '" + data + "' "
	   ldc_troubletype.SetFilter(ls_filter)			//Filter정함
		ldc_troubletype.Filter()
		ldc_troubletype.SetTransObject(SQLCA)
		ll_row =ldc_troubletype.Retrieve() 
				
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If				
End Choose

Return 0
end event

type p_ok from w_a_print`p_ok within b1w_1_prt_trouble_country_v20
integer x = 2647
end type

type p_close from w_a_print`p_close within b1w_1_prt_trouble_country_v20
integer x = 2949
end type

type dw_list from w_a_print`dw_list within b1w_1_prt_trouble_country_v20
integer y = 424
string dataobject = "b1dw_1_prt_trouble_country_v20"
end type

type p_1 from w_a_print`p_1 within b1w_1_prt_trouble_country_v20
end type

type p_2 from w_a_print`p_2 within b1w_1_prt_trouble_country_v20
end type

type p_3 from w_a_print`p_3 within b1w_1_prt_trouble_country_v20
end type

type p_5 from w_a_print`p_5 within b1w_1_prt_trouble_country_v20
end type

type p_6 from w_a_print`p_6 within b1w_1_prt_trouble_country_v20
end type

type p_7 from w_a_print`p_7 within b1w_1_prt_trouble_country_v20
end type

type p_8 from w_a_print`p_8 within b1w_1_prt_trouble_country_v20
end type

type p_9 from w_a_print`p_9 within b1w_1_prt_trouble_country_v20
end type

type p_4 from w_a_print`p_4 within b1w_1_prt_trouble_country_v20
end type

type gb_1 from w_a_print`gb_1 within b1w_1_prt_trouble_country_v20
end type

type p_port from w_a_print`p_port within b1w_1_prt_trouble_country_v20
end type

type p_land from w_a_print`p_land within b1w_1_prt_trouble_country_v20
end type

type gb_cond from w_a_print`gb_cond within b1w_1_prt_trouble_country_v20
integer width = 2473
integer height = 412
end type

type p_saveas from w_a_print`p_saveas within b1w_1_prt_trouble_country_v20
end type

