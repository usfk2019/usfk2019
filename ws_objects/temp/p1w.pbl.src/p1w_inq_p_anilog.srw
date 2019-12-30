$PBExportHeader$p1w_inq_p_anilog.srw
$PBExportComments$[parkkh] anilog 조회
forward
global type p1w_inq_p_anilog from w_a_inq_m
end type
end forward

global type p1w_inq_p_anilog from w_a_inq_m
end type
global p1w_inq_p_anilog p1w_inq_p_anilog

on p1w_inq_p_anilog.create
call super::create
end on

on p1w_inq_p_anilog.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_pid, ls_validkey, ls_crtdtfr, ls_crtdtto
Long ll_row

ls_pid = Trim(dw_cond.Object.pid[1])
ls_validkey = Trim(dw_cond.Object.validkey[1])

ls_crtdtfr = String(dw_cond.object.crtdt_fr[1],"YYYYMMDD")
If IsNull(ls_crtdtfr) Then ls_crtdtfr = ""

ls_crtdtto = String(dw_cond.object.crtdt_to[1],"YYYYMMDD")
If IsNull(ls_crtdtto) Then ls_crtdtto = ""


If ls_crtdtto <> "" Then
	If ls_crtdtfr <> "" Then
		If ls_crtdtfr > ls_crtdtto Then
			f_msg_usr_err(210, Title, "수정일From <= 수정일To")
			dw_cond.SetFocus()
			dw_cond.setColumn("crtdt_fr")
			Return 
		End If
	End If
End If




If ls_pid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "pid = '" + ls_pid + "' "
End If

If ls_validkey <> "" then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "validkey = '" + ls_validkey + "' "
End If

IF ls_crtdtfr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(crtdt,'YYYYMMDD') >= '"+ ls_crtdtfr +"'"
END IF

IF ls_crtdtto <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(crtdt,'YYYYMMDD') <= '"+ ls_crtdtto +"'"
END IF

If ls_where = "" Then
	f_msg_info(200, Title, "1가지 이상 조회 조건")
	dw_cond.SetFocus()
	dw_cond.setColumn("pid")
	Return 
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
ElseIf ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
End If
end event

type dw_cond from w_a_inq_m`dw_cond within p1w_inq_p_anilog
integer x = 69
integer y = 60
integer width = 1623
integer height = 224
string dataobject = "p1dw_cnd_inq_p_anilog"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_inq_m`p_ok within p1w_inq_p_anilog
integer x = 1934
end type

type p_close from w_a_inq_m`p_close within p1w_inq_p_anilog
integer x = 2235
end type

type gb_cond from w_a_inq_m`gb_cond within p1w_inq_p_anilog
integer y = 12
integer width = 1755
integer height = 288
end type

type dw_detail from w_a_inq_m`dw_detail within p1w_inq_p_anilog
integer y = 324
integer height = 1396
string dataobject = "p1dw_p_anilog"
end type

event dw_detail::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.logseq_t
uf_init(ldwo_sort,'D', RGB(0,0,128))
end event

