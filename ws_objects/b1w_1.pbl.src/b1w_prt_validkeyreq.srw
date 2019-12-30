$PBExportHeader$b1w_prt_validkeyreq.srw
forward
global type b1w_prt_validkeyreq from w_a_print
end type
end forward

global type b1w_prt_validkeyreq from w_a_print
integer width = 3323
integer height = 1992
end type
global b1w_prt_validkeyreq b1w_prt_validkeyreq

on b1w_prt_validkeyreq.create
call super::create
end on

on b1w_prt_validkeyreq.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prt_validkeyreq
	Desc.	: 인증key요청 내역 보고서
	Ver.	: 1.0
	Date	: 2004.07.26
	Programer : Kwon Jung Min(KwonJM)
-------------------------------------------------------------------------*/

end event

event ue_init();call super::ue_init;ii_orientation = 1 //가로 기준
ib_margin = True
end event

event ue_ok();call super::ue_ok;String ls_fromdt,	ls_todt,	ls_type,	ls_status,	ls_partner,	ls_where
Date ld_fromdt, ld_todt
Long ll_row
Integer li_check
//
ld_fromdt = dw_cond.object.ymd_fr[1]
ld_todt = dw_cond.object.ymd_to[1]
//
ls_fromdt = Trim(String(ld_fromdt,'yyyymmdd'))
ls_todt = Trim(String(ld_todt,'yyyymmdd'))
ls_type = Trim(dw_cond.object.type[1])
ls_status = Trim(dw_cond.object.status[1])
ls_partner = Trim(dw_cond.object.partner[1])

If IsNull(ls_fromdt) Then ls_fromdt = ""
If IsNull(ls_todt) Then ls_todt = ""
If IsNull(ls_type) Then ls_type = ""
If IsNull(ls_status) Then ls_status = ""
If IsNull(ls_partner) Then ls_partner = ""
// 요청일자
//Messagebox('ls_fromdt', ls_fromdt)
//Messagebox('ls_todt', ls_todt)
If ls_fromdt <> "" AND ls_todt <> "" Then
	li_check = fi_chk_frto_day(ld_fromdt, ld_todt)
	If li_check <> -3 AND li_check < 0 Then
		f_msg_usr_err(211, Title, '요청일자')
		dw_cond.setcolumn("ymd_fr")
		Return 
	End If
End If

//SQL

ls_where = ""

IF ls_fromdt <> "" THEN
	If ls_where <> "" Then ls_where += " AND "
	ls_where = " to_char(REQDT, 'yyyymmdd') >= '"+ls_fromdt+"'"
End IF

IF ls_todt<> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where = " to_char(REQDT, 'yyyymmdd') <= '"+ls_todt+"'"
End IF

IF ls_type <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " reqtype = '"+ls_type+"'"
END IF

IF ls_status <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "status = '"+ls_status+"'"
END IF

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "req_partner = '"+ls_partner+"'"
END IF

dw_list.is_where = ls_where
ll_row = dw_list.Retrieve()


If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

end event

type dw_cond from w_a_print`dw_cond within b1w_prt_validkeyreq
integer x = 69
integer y = 36
integer width = 2103
integer height = 232
string dataobject = "b1dw_cnd_prt_validkeyreq"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b1w_prt_validkeyreq
integer x = 2318
integer y = 60
end type

type p_close from w_a_print`p_close within b1w_prt_validkeyreq
integer x = 2619
integer y = 60
end type

type dw_list from w_a_print`dw_list within b1w_prt_validkeyreq
integer y = 312
integer width = 3232
integer height = 1296
string dataobject = "b1dw_prt_validkeyreq"
end type

type p_1 from w_a_print`p_1 within b1w_prt_validkeyreq
end type

type p_2 from w_a_print`p_2 within b1w_prt_validkeyreq
end type

type p_3 from w_a_print`p_3 within b1w_prt_validkeyreq
end type

type p_5 from w_a_print`p_5 within b1w_prt_validkeyreq
end type

type p_6 from w_a_print`p_6 within b1w_prt_validkeyreq
end type

type p_7 from w_a_print`p_7 within b1w_prt_validkeyreq
end type

type p_8 from w_a_print`p_8 within b1w_prt_validkeyreq
end type

type p_9 from w_a_print`p_9 within b1w_prt_validkeyreq
end type

type p_4 from w_a_print`p_4 within b1w_prt_validkeyreq
end type

type gb_1 from w_a_print`gb_1 within b1w_prt_validkeyreq
end type

type p_port from w_a_print`p_port within b1w_prt_validkeyreq
end type

type p_land from w_a_print`p_land within b1w_prt_validkeyreq
end type

type gb_cond from w_a_print`gb_cond within b1w_prt_validkeyreq
integer width = 2167
integer height = 288
end type

type p_saveas from w_a_print`p_saveas within b1w_prt_validkeyreq
end type

