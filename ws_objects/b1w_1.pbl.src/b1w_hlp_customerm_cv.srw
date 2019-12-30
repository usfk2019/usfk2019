$PBExportHeader$b1w_hlp_customerm_cv.srw
$PBExportComments$[ceusee] Help : 사용자 ID
forward
global type b1w_hlp_customerm_cv from w_a_hlp
end type
end forward

global type b1w_hlp_customerm_cv from w_a_hlp
integer width = 2139
integer height = 1864
end type
global b1w_hlp_customerm_cv b1w_hlp_customerm_cv

on b1w_hlp_customerm_cv.create
call super::create
end on

on b1w_hlp_customerm_cv.destroy
call super::destroy
end on

event ue_find();call super::ue_find;String ls_where
String ls_customerid, ls_customernm
String ls_location, ls_buildingno, ls_roomno
Long ll_row

ls_customerid = Trim(dw_cond.Object.customerid[1])
If IsNull(ls_customerid) Then ls_customerid = ""

ls_customernm = Trim(dw_cond.Object.customernm[1])
If IsNull(ls_customernm) Then ls_customernm = ""

ls_location = Trim(dw_cond.Object.location[1])
If IsNull(ls_location) Then ls_location = ""

ls_buildingno = Trim(dw_cond.Object.buildingno[1])
If IsNull(ls_buildingno) Then ls_buildingno = ""

ls_roomno = Trim(dw_cond.Object.roomno[1])
If IsNull(ls_roomno) Then ls_roomno = ""

ls_where = ""

If ls_customerid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " customerid = '" + ls_customerid + "' "
End If

If ls_customernm <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " customernm like '%" + ls_customernm + "%' "
End If

If ls_location <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " location = '" + ls_location + "' "
End If

If ls_buildingno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " buildingno = '" + ls_buildingno + "' "
End If

If ls_roomno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " roomno = '" + ls_roomno + "' "
End If

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;This.Title = "Help - 사용자 Customer ID"
end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
Close(This)


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.ib_data[1] = True

iu_cust_help.is_data[1] = Trim(dw_hlp.Object.customerid[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.customernm[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.status[al_selrow])

end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_customerm_cv
integer x = 1216
integer y = 48
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_customerm_cv
integer x = 41
integer y = 44
integer width = 1111
integer height = 344
string dataobject = "b1dw_cnd_hlp_customerm_cv"
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_customerm_cv
integer x = 1518
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b1w_hlp_customerm_cv
integer x = 1815
integer y = 48
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_customerm_cv
integer x = 14
integer width = 1161
integer height = 396
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_customerm_cv
integer x = 23
integer y = 424
integer width = 2071
integer height = 1328
string dataobject = "b1dw_hlp_customerm_cv"
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.customerid_t
uf_init(ldwo_sort)
end event

