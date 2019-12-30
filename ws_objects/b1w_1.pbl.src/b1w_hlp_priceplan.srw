$PBExportHeader$b1w_hlp_priceplan.srw
$PBExportComments$[kem] Help : 가격정책
forward
global type b1w_hlp_priceplan from w_a_hlp
end type
end forward

global type b1w_hlp_priceplan from w_a_hlp
integer width = 3195
integer height = 1864
end type
global b1w_hlp_priceplan b1w_hlp_priceplan

on b1w_hlp_priceplan.create
call super::create
end on

on b1w_hlp_priceplan.destroy
call super::destroy
end on

event ue_find();call super::ue_find;String ls_where
String ls_svccod, ls_priceplan, ls_priceplan_desc
Long ll_row

ls_svccod = Trim(dw_cond.Object.svccod[1])
If IsNull(ls_svccod) Then ls_svccod = ""

ls_priceplan = Trim(dw_cond.Object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""

ls_priceplan_desc = Trim(dw_cond.Object.priceplan_desc[1])
If IsNull(ls_priceplan_desc) Then ls_priceplan_desc = ""


ls_where = ""

If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " svccod = '" + ls_svccod + "' "
End If

If ls_priceplan <> "" Then 
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " priceplan = '" + ls_priceplan + "' "
End If

If ls_priceplan_desc <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " priceplan_desc like '%" + ls_priceplan_desc + "%' "
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

event open;call super::open;This.Title = "Help - 가격정책"
end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
Close(This)


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.ib_data[1] = True

iu_cust_help.is_data[1] = Trim(dw_hlp.Object.priceplan[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.priceplan_desc[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.svccod[al_selrow])

end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_priceplan
integer x = 2167
integer y = 48
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_priceplan
integer x = 41
integer y = 44
integer width = 2002
integer height = 184
string dataobject = "b1dw_cnd_hlp_priceplan"
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_priceplan
integer x = 2469
integer y = 48
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b1w_hlp_priceplan
integer x = 2766
integer y = 48
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_priceplan
integer x = 14
integer width = 2053
integer height = 248
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_priceplan
integer x = 23
integer y = 276
integer width = 3127
integer height = 1476
string dataobject = "b1dw_hlp_priceplan"
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.priceplan_t
uf_init(ldwo_sort)
end event

