$PBExportHeader$b1w_hlp_cardmst.srw
$PBExportComments$[kem] Help : 선불카드 Pin#
forward
global type b1w_hlp_cardmst from w_a_hlp
end type
end forward

global type b1w_hlp_cardmst from w_a_hlp
integer width = 3195
integer height = 1864
end type
global b1w_hlp_cardmst b1w_hlp_cardmst

on b1w_hlp_cardmst.create
call super::create
end on

on b1w_hlp_cardmst.destroy
call super::destroy
end on

event ue_find();call super::ue_find;String ls_where
String ls_pid, ls_contno
String ls_location, ls_buildingno, ls_roomno
Long ll_row

ls_pid = Trim(dw_cond.Object.pid[1])
If IsNull(ls_pid) Then ls_pid = ""

ls_contno = Trim(dw_cond.Object.contno[1])
If IsNull(ls_contno) Then ls_contno = ""


ls_where = ""

If ls_pid <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " pid = '" + ls_pid + "' "
End If

If ls_contno <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " contno like '%" + ls_contno + "%' "
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

event open;call super::open;This.Title = "Help - 선불카드 PIN#"
end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
Close(This)


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.ib_data[1] = True

iu_cust_help.is_data[1] = Trim(dw_hlp.Object.pid[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.contno[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.status[al_selrow])

end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_cardmst
integer x = 1303
integer y = 48
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_cardmst
integer x = 41
integer y = 44
integer width = 1111
integer height = 184
string dataobject = "b1dw_cnd_hlp_cardmst"
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_cardmst
integer x = 1605
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b1w_hlp_cardmst
integer x = 1902
integer y = 48
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_cardmst
integer x = 14
integer width = 1161
integer height = 248
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_cardmst
integer x = 23
integer y = 276
integer width = 3127
integer height = 1476
string dataobject = "b1dw_hlp_cardmst"
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.pid_t
uf_init(ldwo_sort)
end event

