$PBExportHeader$s2w_prt_incompletecdrsummary.srw
$PBExportComments$[chooys] 불완료호 ErrorCode 별 통계
forward
global type s2w_prt_incompletecdrsummary from w_a_print
end type
end forward

global type s2w_prt_incompletecdrsummary from w_a_print
end type
global s2w_prt_incompletecdrsummary s2w_prt_incompletecdrsummary

on s2w_prt_incompletecdrsummary.create
call super::create
end on

on s2w_prt_incompletecdrsummary.destroy
call super::destroy
end on

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 0 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_yyyymmdd_from
String ls_yyyymmdd_to
String ls_tmtype_from
String ls_tmtype_to
String ls_svctype
String ls_errorcode

String ls_where
Long ll_row

ls_yyyymmdd_from = String(dw_cond.object.yyyymmdd_from[1], 'yyyymmdd')
ls_yyyymmdd_to = String(dw_cond.object.yyyymmdd_to[1], 'yyyymmdd')
ls_tmtype_from = String(dw_cond.object.tmtype_from[1])
IF LenA(ls_tmtype_from) = 1 THEN ls_tmtype_from = "0" + ls_tmtype_from
ls_tmtype_to = String(dw_cond.object.tmtype_to[1])
IF not IsNull(ls_tmtype_to) THEN ls_tmtype_to = String(dw_cond.object.tmtype_to[1]-1)
IF LenA(ls_tmtype_to) = 1 THEN ls_tmtype_to = "0" + ls_tmtype_to
ls_svctype = Trim(dw_cond.object.svctype[1])
ls_errorcode = Trim(dw_cond.object.errorcode[1])

If IsNull(ls_yyyymmdd_from) Then ls_yyyymmdd_from = ""
If IsNull(ls_yyyymmdd_to) Then ls_yyyymmdd_to = ""
If IsNull(ls_tmtype_from) Then ls_tmtype_from = ""
If IsNull(ls_tmtype_to) Then ls_tmtype_to = ""
If IsNull(ls_svctype) Then ls_svctype = ""
If IsNull(ls_errorcode) Then ls_errorcode = ""

ls_where = ""

If ls_yyyymmdd_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "yyyymmdd >= '" + ls_yyyymmdd_from + "' "
End If

If ls_yyyymmdd_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "yyyymmdd <= '" + ls_yyyymmdd_to + "' "
End If

If ls_tmtype_from <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tmtype >= '" + ls_tmtype_from + "' "
End If

If ls_tmtype_to <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tmtype <= '" + ls_tmtype_to + "' "
End If

If ls_svctype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svctype = '" + ls_svctype + "' "
End If

If ls_errorcode <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "errorcode = '" + ls_errorcode + "' "
End If


dw_list.is_where = ls_where
ll_row	= dw_list.Retrieve()
If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	s2w_prt_incompletecdrsummary
	Desc.	: 	지역별 요일별 통계 리스트 
	Ver.	:	1.0
	Date	:	2004.01.28
	Programer : Choo Youn-Shik(neo)
--------------------------------------------------------------------------*/

end event

type dw_cond from w_a_print`dw_cond within s2w_prt_incompletecdrsummary
integer y = 40
integer width = 1915
integer height = 232
string dataobject = "s2dw_cnd_incompletecdrsummary"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s2w_prt_incompletecdrsummary
integer x = 2075
integer y = 56
end type

type p_close from w_a_print`p_close within s2w_prt_incompletecdrsummary
integer x = 2391
integer y = 56
end type

type dw_list from w_a_print`dw_list within s2w_prt_incompletecdrsummary
integer y = 316
integer height = 1304
string dataobject = "s2dw_prt_incompletecdrsummary"
end type

type p_1 from w_a_print`p_1 within s2w_prt_incompletecdrsummary
end type

type p_2 from w_a_print`p_2 within s2w_prt_incompletecdrsummary
end type

type p_3 from w_a_print`p_3 within s2w_prt_incompletecdrsummary
end type

type p_5 from w_a_print`p_5 within s2w_prt_incompletecdrsummary
end type

type p_6 from w_a_print`p_6 within s2w_prt_incompletecdrsummary
end type

type p_7 from w_a_print`p_7 within s2w_prt_incompletecdrsummary
end type

type p_8 from w_a_print`p_8 within s2w_prt_incompletecdrsummary
end type

type p_9 from w_a_print`p_9 within s2w_prt_incompletecdrsummary
end type

type p_4 from w_a_print`p_4 within s2w_prt_incompletecdrsummary
end type

type gb_1 from w_a_print`gb_1 within s2w_prt_incompletecdrsummary
end type

type p_port from w_a_print`p_port within s2w_prt_incompletecdrsummary
end type

type p_land from w_a_print`p_land within s2w_prt_incompletecdrsummary
end type

type gb_cond from w_a_print`gb_cond within s2w_prt_incompletecdrsummary
integer width = 1979
integer height = 284
end type

type p_saveas from w_a_print`p_saveas within s2w_prt_incompletecdrsummary
end type

