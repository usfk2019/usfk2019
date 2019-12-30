$PBExportHeader$rpt0w_hlp_level.srw
$PBExportComments$[parkkh] Drive Level HelpWindow
forward
global type rpt0w_hlp_level from w_a_hlp
end type
end forward

global type rpt0w_hlp_level from w_a_hlp
integer height = 1844
end type
global rpt0w_hlp_level rpt0w_hlp_level

type variables
DEC ic_data[]
end variables

on rpt0w_hlp_level.create
call super::create
end on

on rpt0w_hlp_level.destroy
call super::destroy
end on

event open;call super::open;This.Title = "Level HelpWindow"
end event

event ue_find;call super::ue_find;String ls_description, ls_where
String ls_levelno_fr, ls_levelno_to
Long ll_row

ls_levelno_fr = Trim(dw_cond.Object.levelno_fr[1])
ls_levelno_to = Trim(dw_cond.Object.levelno_to[1])
ls_description = Trim(dw_cond.Object.description[1])

If IsNull(ls_levelno_fr) Then ls_levelno_fr = ""
If IsNull(ls_levelno_to) Then ls_levelno_to = ""
If IsNull(ls_description) Then ls_description = ""

ls_where = ""

//전표번호 valid check
If ls_levelno_fr <> "" And ls_levelno_to <> "" Then
	If Long(ls_levelno_fr) > Long(ls_levelno_to) Then
		f_msg_usr_err(200,Title,"Level No를 다시 입력하십시오")
		dw_cond.SetFocus()
		dw_cond.SetColumn("levelno_fr")
		Return
	End If
End If

//sql where절 생성
If ls_levelno_fr <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.levelno >= to_number('" + ls_levelno_fr + "','999999') "
End If

If ls_levelno_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.levelno <= to_number('" + ls_levelno_to + "','999999') "
End If

If ls_description <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " level_dec.description like '%" + ls_description + "%' "
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

event ue_extra_ok_with_return;call super::ue_extra_ok_with_return;
iu_cust_help.ib_data[1] = True
iu_cust_help.ic_data[1] = dw_hlp.Object.levelno[al_selrow]
iu_cust_help.is_data2[2] = Trim(dw_hlp.Object.description[al_selrow])
end event

type p_1 from w_a_hlp`p_1 within rpt0w_hlp_level
integer x = 1179
end type

type dw_cond from w_a_hlp`dw_cond within rpt0w_hlp_level
integer y = 52
integer width = 1019
integer height = 240
string dataobject = "rpt0dw_cnd_hlp_level"
end type

type p_ok from w_a_hlp`p_ok within rpt0w_hlp_level
integer x = 1477
end type

type p_close from w_a_hlp`p_close within rpt0w_hlp_level
integer x = 1774
end type

type gb_cond from w_a_hlp`gb_cond within rpt0w_hlp_level
integer width = 1088
integer height = 312
end type

type dw_hlp from w_a_hlp`dw_hlp within rpt0w_hlp_level
integer y = 344
integer width = 2021
string dataobject = "rpt0dw_detail_hlp_level"
end type

event dw_hlp::ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.levelno_t
uf_init(ldwo_SORT)
end event

