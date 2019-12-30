$PBExportHeader$b5w_inq_reqlog_reqpgm.srw
$PBExportComments$[parkkh] 청구작업이력조회
forward
global type b5w_inq_reqlog_reqpgm from w_a_condition
end type
type dw_detail from u_d_sort within b5w_inq_reqlog_reqpgm
end type
end forward

global type b5w_inq_reqlog_reqpgm from w_a_condition
integer width = 3479
integer height = 1864
dw_detail dw_detail
end type
global b5w_inq_reqlog_reqpgm b5w_inq_reqlog_reqpgm

type variables
String is_format
end variables

on b5w_inq_reqlog_reqpgm.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
end on

on b5w_inq_reqlog_reqpgm.destroy
call super::destroy
destroy(this.dw_detail)
end on

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < dw_detail.Y Then
	dw_detail.Height = 0
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If


SetRedraw(True)

end event

event ue_ok();call super::ue_ok;Long ll_rows
String ls_where, ls_chargedt, ls_trdt, ls_pgm_nm

ls_chargedt = Trim(dw_cond.Object.chargedt[1])
ls_trdt = String(dw_cond.Object.trdt[1], "yyyymm")
ls_pgm_nm = dw_cond.Object.pgm_nm[1]

//Error 처리부분
If IsNull(ls_chargedt) Then ls_chargedt = ""
If IsNull(ls_trdt) Then ls_trdt = ""
If IsNull(ls_pgm_nm) Then ls_pgm_nm = ""

//If ls_chargedt = "" Then
//	f_msg_usr_err(200, Title, "Billing Cycle date")
//	dw_cond.SetColumn("chargedt")
//	Return
//End If

ls_where = ""

If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where = "reqlog.chargedt = '" + ls_chargedt + "'"
End If

If ls_trdt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where = "to_char(reqlog.trdt, 'yyyymm') = '" + ls_trdt + "'"
End If

If ls_pgm_nm <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where = "reqlog.pgm_nm like '" + ls_pgm_nm + "%'"
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
ll_rows = dw_detail.Retrieve()

If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If

If is_format = "1" Then
	dw_detail.object.prcamt.Format = "#,##0.0"
	dw_detail.object.sum_prcamt.Format = "#,##0.0"
ElseIf is_format = "2" Then
	dw_detail.object.prcamt.Format = "#,##0.00"
	dw_detail.object.sum_prcamt.Format = "#,##0.00"
Else
	dw_detail.object.prcamt.Format = "#,##0"
	dw_detail.object.sum_prcamt.Format = "#,##0"
End If

//dw_cond.enabled = False

end event

event open;call super::open;String ls_ref_desc

is_format = fs_get_control("B5", "H200", ls_ref_desc)
end event

type dw_cond from w_a_condition`dw_cond within b5w_inq_reqlog_reqpgm
integer x = 59
integer y = 44
integer width = 2203
integer taborder = 10
string dataobject = "b5d_cnd_prc_reqpgm"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_condition`p_ok within b5w_inq_reqlog_reqpgm
integer x = 2482
integer y = 56
end type

type p_close from w_a_condition`p_close within b5w_inq_reqlog_reqpgm
integer x = 2793
integer y = 56
boolean originalsize = false
end type

type gb_cond from w_a_condition`gb_cond within b5w_inq_reqlog_reqpgm
integer width = 2336
end type

type dw_detail from u_d_sort within b5w_inq_reqlog_reqpgm
integer x = 27
integer y = 324
integer width = 3383
integer height = 1384
integer taborder = 0
string dataobject = "b5dw_inq_reglog_regpgm_m"
borderstyle borderstyle = stylebox!
end type

event ue_init();call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.seqno_t
uf_init(ldwo_SORT)

end event

