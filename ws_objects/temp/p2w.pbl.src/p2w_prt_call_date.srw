$PBExportHeader$p2w_prt_call_date.srw
$PBExportComments$[jojo] 통화명세서(기간)
forward
global type p2w_prt_call_date from w_a_print
end type
end forward

global type p2w_prt_call_date from w_a_print
integer height = 2120
end type
global p2w_prt_call_date p2w_prt_call_date

on p2w_prt_call_date.create
call super::create
end on

on p2w_prt_call_date.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_priceplan, ls_pid, ls_validkey, ls_mgpartner, ls_partner
String ls_stime_fr, ls_stime_to
Date ld_stime_fr, ld_stime_to
Long ll_row
String ls_svctype, ls_ref_desc

ls_svctype = fs_get_control("P0", "P100", ls_ref_desc)

ld_stime_fr = dw_cond.object.stime_fr[1]
ld_stime_to = dw_cond.object.stime_to[1]
ls_stime_fr = String(ld_stime_fr, 'yyyymmdd')
ls_stime_to = String(ld_stime_to, 'yyyymmdd')
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_pid = Trim(dw_cond.object.pid[1])
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_mgpartner = Trim(dw_cond.object.mgpartner[1])
ls_partner = Trim(dw_cond.Object.partner[1])

//Null Check
If IsNull(ls_stime_fr) Then ls_stime_fr = ""
If IsNull(ls_stime_fr) Then ls_stime_fr = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_pid) Then ls_pid = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_mgpartner) Then ls_mgpartner = ""
If IsNull(ls_partner) Then ls_partner = ""

If ls_stime_fr = ""  and ls_stime_to = "" Then
	 f_msg_info(200, Title, "통화일자")     
	 dw_cond.SetFocus()
	 dw_cond.SetColumn("stime_fr")
	 Return 
End IF

//Retrieve
ls_where = ""
ls_where += "cdr.svctype = '" + ls_svctype + "' "
If ls_stime_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	//ls_where += "to_char(cdr.stime, 'yyyymmdd') >= '" + ls_stime_fr + "' "
	ls_where += "cdr.stime >= to_date('" + ls_stime_fr + "', 'yyyymmdd') "
End If

If ls_stime_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	//ls_where += "to_char(cdr.stime, 'yyyymmdd') <= '" + ls_stime_to + "' "
	ls_where += "cdr.stime <= to_date('" + ls_stime_to + "', 'yyyymmdd') + 0.99999 "
End If

//조회조건 입력값을 보여준다.
dw_list.Modify ( "t_stime_fr.text='" + String(ld_stime_fr, 'yyyy-mm-dd')+ "'" )
dw_list.Modify ( "t_stime_to.text='" + String(ld_stime_to, 'yyyy-mm-dd')+ "'" )

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "cdr.priceplan = '" + ls_priceplan + "' "
End If

If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "cdr.pid = '" + ls_pid + "' "
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += "And "
	ls_where += "cdr.validkey LIKE '" + ls_validkey + "%' "
End If

If ls_mgpartner <> "" AND ls_partner = "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "par.prefixno LIKE '" + ls_mgpartner + "%'"
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "cdr.sale_partner = '" + ls_partner + "' "
End If

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

type dw_cond from w_a_print`dw_cond within p2w_prt_call_date
integer y = 56
integer width = 2249
integer height = 292
string dataobject = "p2dw_cnd_prt_call_date"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_partner
Long ll_row
String ls_filter, ls_levelcod, ls_ref_desc

Choose Case dwo.Name
	Case "mgpartner"
		This.Object.partner[1] = ""
		
		ls_levelcod = fs_get_control("A1", "C100", ls_ref_desc)
		
		ll_row = dw_cond.GetChild("partner", ldc_partner)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		
		ls_filter = "prefixno LIKE '" + data + "%' "
		//ls_filter += "AND levelcod > '" + ls_levelcod + "' "
		ldc_partner.setFilter(ls_Filter)
		ldc_partner.Filter()
		
		ldc_partner.SetTransObject(SQLCA)
		ll_row =ldc_partner.Retrieve() 
				
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
End Choose 

end event

type p_ok from w_a_print`p_ok within p2w_prt_call_date
integer y = 56
end type

type p_close from w_a_print`p_close within p2w_prt_call_date
integer y = 56
end type

type dw_list from w_a_print`dw_list within p2w_prt_call_date
integer y = 380
string dataobject = "p2dw_prt_call_date"
end type

type p_1 from w_a_print`p_1 within p2w_prt_call_date
integer y = 1696
end type

type p_2 from w_a_print`p_2 within p2w_prt_call_date
integer y = 1696
end type

type p_3 from w_a_print`p_3 within p2w_prt_call_date
integer y = 1696
end type

type p_5 from w_a_print`p_5 within p2w_prt_call_date
integer y = 1696
end type

type p_6 from w_a_print`p_6 within p2w_prt_call_date
integer y = 1696
end type

type p_7 from w_a_print`p_7 within p2w_prt_call_date
integer y = 1696
end type

type p_8 from w_a_print`p_8 within p2w_prt_call_date
integer y = 1696
end type

type p_9 from w_a_print`p_9 within p2w_prt_call_date
integer y = 1696
end type

type p_4 from w_a_print`p_4 within p2w_prt_call_date
end type

type gb_1 from w_a_print`gb_1 within p2w_prt_call_date
integer y = 1656
end type

type p_port from w_a_print`p_port within p2w_prt_call_date
integer y = 1720
end type

type p_land from w_a_print`p_land within p2w_prt_call_date
integer y = 1732
end type

type gb_cond from w_a_print`gb_cond within p2w_prt_call_date
integer width = 2313
integer height = 360
end type

type p_saveas from w_a_print`p_saveas within p2w_prt_call_date
integer y = 1696
end type

