$PBExportHeader$c1w_inq_areacod_traffic_v20.srw
$PBExportComments$[parkkh] 지역별트래픽현황(ASR)
forward
global type c1w_inq_areacod_traffic_v20 from w_a_inq_m_m
end type
type p_saveas from u_p_saveas within c1w_inq_areacod_traffic_v20
end type
end forward

global type c1w_inq_areacod_traffic_v20 from w_a_inq_m_m
integer width = 3058
integer height = 2016
event ue_saveas ( )
p_saveas p_saveas
end type
global c1w_inq_areacod_traffic_v20 c1w_inq_areacod_traffic_v20

type variables
String is_filename[], is_filepath, is_filenm

end variables

event ue_saveas();Boolean lb_return
String ls_curdir
u_api lu_api
Long ll_rc, ll_selrow
Integer li_curtab, li_return
String ls_saveas

ls_saveas = dw_cond.object.saveas[1]
If IsNull(ls_saveas) Then ls_saveas = ""

If ls_saveas = "" Then
	f_msg_info(200, Title, "파일저장대상")
	dw_cond.SetColumn("saveas")
	dw_cond.SetFocus()
	Return
End If

ll_selrow = dw_master.GetSelectedRow(0)

If ls_saveas = 'M' Then 
	
	If dw_master.RowCount() <= 0 Then
		f_msg_info(1000, This.Title, "Data exporting")
		Return
	End If

	lu_api = Create u_api
	ls_curdir = lu_api.uf_getcurrentdirectorya()
	If IsNull(ls_curdir) Or ls_curdir = "" Then
		f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
		Destroy lu_api
		Return
	End If
	
	li_return = dw_master.SaveAs("", Excel!, True)
	
	lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
	If li_return <> 1 Then
		f_msg_info(9000, This.Title, "User cancel current job.")
		
	Else
		f_msg_info(9000, This.Title, "Data export finished.")
	End If
	
	Destroy lu_api
ElseIF ls_saveas = 'D' Then
	
	If dw_detail.RowCount() <= 0 Then
		f_msg_info(1000, This.Title, "Data exporting")
		Return
	End If

	lu_api = Create u_api
	ls_curdir = lu_api.uf_getcurrentdirectorya()
	If IsNull(ls_curdir) Or ls_curdir = "" Then
		f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
		Destroy lu_api
		Return
	End If
	
	li_return = dw_detail.SaveAs("", Excel!, True)
	
	lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
	If li_return <> 1 Then
		f_msg_info(9000, This.Title, "User cancel current job.")
		
	Else
		f_msg_info(9000, This.Title, "Data export finished.")
	End If
	
	Destroy lu_api
End IF
end event

on c1w_inq_areacod_traffic_v20.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on c1w_inq_areacod_traffic_v20.destroy
call super::destroy
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;String ls_customerid, ls_yyyymmdd_fr, ls_yyyymmdd_to
String ls_where
Long   ll_rows

dw_cond.AcceptText()

ls_yyyymmdd_fr  = Trim(String(dw_cond.Object.yyyymmdd_fr[1],'yyyymmdd'))
ls_yyyymmdd_to    = Trim(String(dw_cond.Object.yyyymmdd_to[1],'yyyymmdd'))
ls_customerid = Trim(dw_cond.Object.customerid[1])

If IsNull(ls_yyyymmdd_fr) Then ls_yyyymmdd_fr = ""
If IsNull(ls_yyyymmdd_to) Then ls_yyyymmdd_to = ""
If IsNull(ls_customerid) Then ls_customerid = ""

If ls_yyyymmdd_fr = "" Then
	f_msg_info(200, Title, "기간 from")
	dw_cond.SetColumn("yyyymmdd_fr")
	dw_cond.SetFocus()
	Return
End If

If ls_yyyymmdd_to = "" Then
	f_msg_info(200, Title, "기간 to")
	dw_cond.SetColumn("yyyymmdd_to")
	dw_cond.SetFocus()
	Return
End If

IF  (ls_yyyymmdd_fr > ls_yyyymmdd_to) THEN
	f_msg_info(200, Title, "기간from 은 기간to 보다 작아야 합니다.")
	dw_cond.SetColumn("yyyymmdd_fr")
	dw_cond.SetFocus()
	RETURN
END IF

//Dynamic SQL
ls_where = ""

If ls_yyyymmdd_fr <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(a.workdt,'YYYYMMDD') >= '" + ls_yyyymmdd_fr + "' "
End If

If ls_yyyymmdd_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " to_char(a.workdt,'YYYYMMDD') <= '" + ls_yyyymmdd_to + "' "
End IF

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "a.customerid = '" + ls_customerid + "' "
End If

dw_master.is_where = ls_where
ll_rows = dw_master.Retrieve()
If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
ElseIF ll_rows > 0 Then
End If
end event

event open;call super::open;String	ls_ref_desc, ls_temp
String ls_dir
Date ld_sysdt, ld_orderdt
Int	 li_cnt, li_day

ld_sysdt = date(fdt_get_dbserver_now())

end event

type dw_cond from w_a_inq_m_m`dw_cond within c1w_inq_areacod_traffic_v20
integer x = 91
integer y = 100
integer width = 1417
integer height = 312
string dataobject = "c1dw_cnd_areacod_traffic_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m_m`p_ok within c1w_inq_areacod_traffic_v20
integer x = 1792
integer y = 88
end type

type p_close from w_a_inq_m_m`p_close within c1w_inq_areacod_traffic_v20
integer x = 2098
integer y = 88
end type

type gb_cond from w_a_inq_m_m`gb_cond within c1w_inq_areacod_traffic_v20
integer x = 41
integer y = 40
integer width = 1614
integer height = 392
end type

type dw_master from w_a_inq_m_m`dw_master within c1w_inq_areacod_traffic_v20
integer x = 27
integer y = 452
integer width = 2903
integer height = 632
string dataobject = "c1dw_inq_areagroup_traffic_m_v20"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.areagroup_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

type dw_detail from w_a_inq_m_m`dw_detail within c1w_inq_areacod_traffic_v20
integer x = 27
integer y = 1116
integer width = 2903
integer height = 764
string dataobject = "c1dw_inq_areacod_traffic_d_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String ls_areagroup, ls_where
Long   ll_rows

ls_areagroup = Trim(String(dw_master.Object.areagroup[al_select_row]))


//Retrieve
If al_select_row > 0 Then
	ls_where = "to_char(a.areagroup) = '"+ ls_areagroup +"' "
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within c1w_inq_areacod_traffic_v20
integer y = 1088
end type

type p_saveas from u_p_saveas within c1w_inq_areacod_traffic_v20
integer x = 2400
integer y = 88
boolean bringtotop = true
end type

