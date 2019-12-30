$PBExportHeader$rpt0w_hlp_rptcode.srw
$PBExportComments$[parkkh] rpr_code HelpWindow
forward
global type rpt0w_hlp_rptcode from w_a_hlp
end type
end forward

global type rpt0w_hlp_rptcode from w_a_hlp
integer width = 2208
integer height = 1844
end type
global rpt0w_hlp_rptcode rpt0w_hlp_rptcode

type variables
DEC ic_data[]
end variables

on rpt0w_hlp_rptcode.create
call super::create
end on

on rpt0w_hlp_rptcode.destroy
call super::destroy
end on

event open;call super::open;This.Title = "Level HelpWindow"
end event

event ue_find();call super::ue_find;String ls_rptcodenm, ls_where
String ls_rptcode_fr, ls_rptcode_to
Long ll_row

ls_rptcode_fr = Trim(dw_cond.Object.rptcode_fr[1])
ls_rptcode_to = Trim(dw_cond.Object.rptcode_to[1])
ls_rptcodenm = Trim(dw_cond.Object.rptcodenm[1])

If IsNull(ls_rptcode_fr) Then ls_rptcode_fr = ""
If IsNull(ls_rptcode_to) Then ls_rptcode_to = ""
If IsNull(ls_rptcodenm) Then ls_rptcodenm = ""

ls_where = ""

//전표번호 valid check
If ls_rptcode_fr <> "" And ls_rptcode_to <> "" Then
	If Long(ls_rptcode_fr) > Long(ls_rptcode_to) Then
		f_msg_usr_err(200,Title,"계정코드를 다시 입력하십시오")
		dw_cond.SetFocus()
		dw_cond.SetColumn("rptcode_fr")
		Return
	End If
End If

//sql where절 생성
If ls_rptcode_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " rpt_code.rptcode >= '" + ls_rptcode_fr + "' "
End If

If ls_rptcode_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " rpt_code.rptcode <= '" + ls_rptcode_to + "' "
End If

If ls_rptcodenm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " rpt_code.rptcodenm like '%" + ls_rptcodenm + "%' "
End If

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100,Title,"Retrieve(): dw_hlp")
	Return 
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100,Title,"") 
End If
end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);call super::ue_extra_ok_with_return;
iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = dw_hlp.Object.rptcode[al_selrow]
iu_cust_help.is_data2[2] = Trim(dw_hlp.Object.rptcodenm[al_selrow])
end event

type p_1 from w_a_hlp`p_1 within rpt0w_hlp_rptcode
integer x = 1280
end type

type dw_cond from w_a_hlp`dw_cond within rpt0w_hlp_rptcode
integer x = 50
integer y = 52
integer width = 1161
integer height = 240
string dataobject = "rpt0dw_cnd_hlp_rptcode"
end type

type p_ok from w_a_hlp`p_ok within rpt0w_hlp_rptcode
integer x = 1577
end type

type p_close from w_a_hlp`p_close within rpt0w_hlp_rptcode
integer x = 1874
end type

type gb_cond from w_a_hlp`gb_cond within rpt0w_hlp_rptcode
integer width = 1193
integer height = 312
end type

type dw_hlp from w_a_hlp`dw_hlp within rpt0w_hlp_rptcode
integer y = 344
integer width = 2139
string dataobject = "rpt0dw_detail_hlp_rptcode"
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.rptcode_t
uf_init(ldwo_SORT)
end event

