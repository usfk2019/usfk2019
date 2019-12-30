$PBExportHeader$b1w_hlp_partner.srw
$PBExportComments$[parkkh] Help Partner ID
forward
global type b1w_hlp_partner from w_a_hlp
end type
end forward

global type b1w_hlp_partner from w_a_hlp
integer width = 2962
integer height = 1756
windowstate windowstate = normal!
end type
global b1w_hlp_partner b1w_hlp_partner

on b1w_hlp_partner.create
call super::create
end on

on b1w_hlp_partner.destroy
call super::destroy
end on

event ue_find();call super::ue_find;//조회
String ls_partner, ls_partnernm, ls_where, ls_type, ls_logid, ls_levelcod
Long ll_row

ls_partner = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_logid = Trim(dw_cond.object.logid[1])
ls_levelcod = Trim(dw_cond.object.levelcod[1])

If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_partnernm) Then ls_partnernm = ""
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_logid) Then ls_logid = ""
If IsNull(ls_levelcod) Then ls_levelcod= ""

ls_where = ""
If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(partner) like '" + Upper(ls_partner) + "%' "
End If

If ls_partnernm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(partnernm) like '%" + Upper(ls_partnernm) + "%' "
End If

If ls_levelcod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "levelcod like '" + ls_levelcod + "' "
End If

If ls_logid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "logid like '" + ls_logid + "%' "
End If


dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;This.Title = "Help Partner "
end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = Trim(dw_hlp.Object.partner[al_selrow])		//ID
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.partnernm[al_selrow])			//Name
end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_partner
integer x = 2057
integer y = 56
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_partner
integer x = 32
integer width = 1957
integer height = 232
string dataobject = "b1dw_cnd_hlp_partner"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_partner
integer x = 2350
integer y = 56
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within b1w_hlp_partner
integer x = 2647
integer y = 56
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_partner
integer x = 23
integer width = 1979
integer height = 296
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_partner
integer x = 23
integer y = 312
integer width = 2907
string dataobject = "b1dw_hlp_partner"
boolean livescroll = false
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.partner_t
uf_init(ldwo_SORT)
end event

