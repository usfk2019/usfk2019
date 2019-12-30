﻿$PBExportHeader$b1w_inq_sinyong_request.srw
$PBExportComments$[ceusee] validinfo server 조회
forward
global type b1w_inq_sinyong_request from w_a_inq_m
end type
end forward

global type b1w_inq_sinyong_request from w_a_inq_m
integer width = 3118
integer height = 1908
end type
global b1w_inq_sinyong_request b1w_inq_sinyong_request

type variables
String is_coid
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_get_customerid (string as_customerid);String ls_customernm

Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.name[1] = ""
	Return -1
	
Else
	dw_cond.object.name[1] = as_customerid
End If

Return 0
end function

on b1w_inq_sinyong_request.create
call super::create
end on

on b1w_inq_sinyong_request.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_inq_sinyong_request
	Desc	: 	신용보증보험내역조회
	Ver.	: 	1.0
	Date	:	2005.12.28
	Programer : Kem
-------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;String ls_customerid, ls_validkey, ls_worktype, ls_result
String ls_fromdt, ls_todt, ls_where
Date ld_fromdt, ld_todt
Long ll_row
Integer li_check

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_validkey = Trim(dw_cond.object.validkey[1])
ls_worktype = Trim(dw_cond.object.worktype[1])
ls_result = Trim(dw_cond.object.result[1])
ld_fromdt = dw_cond.object.fromdt[1]
ld_todt = dw_cond.object.todt[1]
ls_fromdt = String(ld_fromdt, 'yyyymmdd')
ls_todt = String(ld_todt, 'yyyymmdd')

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_validkey) Then ls_validkey = ""
If IsNull(ls_worktype) Then ls_worktype = ""
If IsNull(ls_result) Then ls_result = ""
If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""

ls_where = ""
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "customerid = '" + ls_customerid + "' "
End IF

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "assso_tel = '" + ls_validkey + "' "
End IF

If ls_result <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "retn_code = '" + ls_result + "' "
End IF

If ls_worktype <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "tele_code = '" + ls_worktype + "' "
End IF

If ls_fromdt <> ""  and ls_todt <> "" Then

	li_check = fi_chk_frto_day(ld_fromdt, ld_todt)
	If li_check <> -3 and li_check < 0 Then
		f_msg_usr_err(211, Title, "작업요청일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fromdt")
		Return
	Else
		If ls_where <> "" Then ls_where += " And "
		ls_where += " tran_date >= '" + ls_fromdt + "' And " + &
						" tran_date <= '" + ls_todt + "' "
	End If
ElseIf ls_fromdt <> "" and ls_todt = "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += " tran_date >= '" + ls_fromdt + "' "
ElseIf ls_fromdt = "" and ls_todt <> "" Then
	If ls_where <> "" Then ls_where += " And "
		ls_where += " tran_date <= '" + ls_todt + "' "
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

type dw_cond from w_a_inq_m`dw_cond within b1w_inq_sinyong_request
integer x = 55
integer y = 44
integer width = 1975
integer height = 396
string dataobject = "b1dw_cnd_reg_sinyong_request"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.name[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

Return 0 
end event

event dw_cond::itemchanged;call super::itemchanged;if dwo.name = "customerid" Then
	wfi_get_customerid(data)
End If
end event

type p_ok from w_a_inq_m`p_ok within b1w_inq_sinyong_request
integer x = 2272
integer y = 68
end type

type p_close from w_a_inq_m`p_close within b1w_inq_sinyong_request
integer x = 2592
integer y = 68
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b1w_inq_sinyong_request
integer width = 2094
integer height = 492
end type

type dw_detail from w_a_inq_m`dw_detail within b1w_inq_sinyong_request
integer x = 32
integer y = 516
integer height = 1284
string dataobject = "b1dw_inq_sinyong_request"
end type

event dw_detail::ue_init;call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.seqno_t
uf_init(ldwo_SORT)
end event
