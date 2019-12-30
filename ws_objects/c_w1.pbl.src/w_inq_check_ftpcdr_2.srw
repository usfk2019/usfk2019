$PBExportHeader$w_inq_check_ftpcdr_2.srw
$PBExportComments$[ssong]시스템 점검관리 윈도우
forward
global type w_inq_check_ftpcdr_2 from w_a_inq_m
end type
end forward

global type w_inq_check_ftpcdr_2 from w_a_inq_m
end type
global w_inq_check_ftpcdr_2 w_inq_check_ftpcdr_2

forward prototypes
public function integer wfi_get_customerid (string as_payid)
end prototypes

public function integer wfi_get_customerid (string as_payid);String ls_paynm

Select marknm
Into :ls_paynm
From paymst
Where payid = :as_payid;

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.paynm[1] = ""
	Return -1
	
Else
	dw_cond.object.paynm[1] = as_payid
End If

Return 0
end function

on w_inq_check_ftpcdr_2.create
call super::create
end on

on w_inq_check_ftpcdr_2.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	w_inq_check_ftpcdr
	Desc	: 	FILE 처리 Log 조회
	Ver.	: 	1.0
	Date	:	2004.07.14
	Programer : Song Eun Mi
-------------------------------------------------------------------------*/
end event

event ue_ok();call super::ue_ok;String ls_filename
String ls_fromdt, ls_todt, ls_where
Date ld_fromdt, ld_todt
Long ll_row
Integer li_check

ls_filename = Trim(dw_cond.object.filename[1])
ld_fromdt = dw_cond.object.fromdt[1]
ld_todt = dw_cond.object.todt[1]
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_todt = String(ld_todt, 'yyyymmdd')

If IsNull(ls_filename) Then ls_filename = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""


ls_where = ""
If ls_filename <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " filename like '%" + ls_filename + "%' "
End IF


If ls_fromdt <> ""  and ls_todt <> "" Then

	li_check = fi_chk_frto_day(ld_fromdt, ld_todt)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "처리일자")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fromdt")
		Return
	Else
		If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(stime, 'yyyymmdd') >= '" + ls_fromdt + "' And " + &
						"to_char(etime, 'yyyymmdd') <= '" + ls_todt + "' "
	End If
ElseIf ls_fromdt <> "" and ls_todt = "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(stime, 'yyyymmdd') >= '" + ls_fromdt + "' "
ElseIf ls_fromdt = "" and ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += "to_char(etime, 'yyyymmdd') <= '" + ls_todt + "' "
End If


dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If
end event

type dw_cond from w_a_inq_m`dw_cond within w_inq_check_ftpcdr_2
integer x = 41
integer y = 52
integer width = 1582
integer height = 268
string dataobject = "d_cnd_inq_check_ftpcdr"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;if dwo.name = "payid" Then
	wfi_get_customerid(data)
End If
end event

type p_ok from w_a_inq_m`p_ok within w_inq_check_ftpcdr_2
integer x = 1765
integer y = 96
end type

type p_close from w_a_inq_m`p_close within w_inq_check_ftpcdr_2
integer x = 2066
integer y = 96
end type

type gb_cond from w_a_inq_m`gb_cond within w_inq_check_ftpcdr_2
integer x = 9
integer width = 1646
integer height = 340
end type

type dw_detail from w_a_inq_m`dw_detail within w_inq_check_ftpcdr_2
integer y = 372
integer height = 1332
string dataobject = "d_inq_check_ftpcdr_2"
boolean hsplitscroll = false
borderstyle borderstyle = stylelowered!
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.seqno_t
uf_init(ldwo_SORT)
end event

