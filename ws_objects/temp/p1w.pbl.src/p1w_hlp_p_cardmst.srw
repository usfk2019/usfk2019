$PBExportHeader$p1w_hlp_p_cardmst.srw
$PBExportComments$[parkkh] Help Pid(P_cardmst)
forward
global type p1w_hlp_p_cardmst from w_a_hlp
end type
end forward

global type p1w_hlp_p_cardmst from w_a_hlp
integer width = 2853
integer height = 1688
end type
global p1w_hlp_p_cardmst p1w_hlp_p_cardmst

type variables
String is_status
end variables

on p1w_hlp_p_cardmst.create
call super::create
end on

on p1w_hlp_p_cardmst.destroy
call super::destroy
end on

event ue_find();call super::ue_find;//조회
String ls_contnofr, ls_contnoto, ls_fromdt, ls_todt, ls_where
Long ll_row

ls_contnofr = Trim(dw_cond.object.contnofr[1])
ls_contnoto = Trim(dw_cond.object.contnoto[1])
ls_fromdt = String(dw_cond.object.fromdt[1],'yyyymmdd')
ls_todt = String(dw_cond.object.todt[1],'yyyymmdd')

If IsNull(ls_contnofr) Then ls_contnofr = ""
If IsNull(ls_contnoto) Then ls_contnoto = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

ls_where = ""
If ls_contnofr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contno >= '" + ls_contnofr + "' "
End If

If ls_contnoto <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "contno <= '" + ls_contnoto + "' "
End If

If ls_fromdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(opendt,'yyyymmdd') >= '" + ls_fromdt + "' "
End If

If ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "to_char(opendt,'yyyymmdd') <= '" + ls_todt + "' "
End If

If ls_where = "" Then
	f_msg_info(200, Title, "1가지 이상 조회 조건")
	dw_cond.SetFocus()
	dw_cond.setColumn("contnofr")
	Return 
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

event open;call super::open;This.Title = "Help Pin#"

String ls_ref_desc

ls_ref_desc = ""
is_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태

end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = string(dw_hlp.Object.pid[al_selrow])		//pid
iu_cust_help.is_data[2] = Trim(dw_hlp.object.status[al_selrow])   //카드 상태
iu_cust_help.is_data[3] = String(dw_hlp.object.balance[al_selrow], "#,##0.00")
iu_cust_help.is_data[4] = Trim(dw_hlp.object.contno[al_selrow])


end event

type p_1 from w_a_hlp`p_1 within p1w_hlp_p_cardmst
integer x = 1495
integer y = 64
end type

type dw_cond from w_a_hlp`dw_cond within p1w_hlp_p_cardmst
integer x = 46
integer y = 44
integer width = 1285
integer height = 224
string dataobject = "p1dw_cnd_hlp_p_cardmst"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within p1w_hlp_p_cardmst
integer x = 1792
integer y = 64
end type

type p_close from w_a_hlp`p_close within p1w_hlp_p_cardmst
integer x = 2089
integer y = 64
end type

type gb_cond from w_a_hlp`gb_cond within p1w_hlp_p_cardmst
integer x = 27
integer width = 1362
integer height = 300
end type

type dw_hlp from w_a_hlp`dw_hlp within p1w_hlp_p_cardmst
integer x = 27
integer y = 328
integer width = 2789
integer height = 1240
string dataobject = "p1dw_inq_hlp_p_cardmst"
boolean livescroll = false
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.contno_t
uf_init(ldwo_SORT)
end event

