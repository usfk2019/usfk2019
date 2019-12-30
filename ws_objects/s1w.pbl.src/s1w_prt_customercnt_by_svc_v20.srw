$PBExportHeader$s1w_prt_customercnt_by_svc_v20.srw
$PBExportComments$[ohj] 서비스별 가입고객현황 v20
forward
global type s1w_prt_customercnt_by_svc_v20 from w_a_print
end type
end forward

global type s1w_prt_customercnt_by_svc_v20 from w_a_print
end type
global s1w_prt_customercnt_by_svc_v20 s1w_prt_customercnt_by_svc_v20

on s1w_prt_customercnt_by_svc_v20.create
call super::create
end on

on s1w_prt_customercnt_by_svc_v20.destroy
call super::destroy
end on

event ue_init();call super::ue_init;ii_orientation = 1 //가로인쇄
ib_margin = True
end event

event ue_saveas();call super::ue_saveas;ib_saveas = True
idw_saveas = dw_list
end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

event ue_ok();call super::ue_ok;//조회
String ls_predtfrom, ls_predtto
String ls_nowdtfrom, ls_nowdtto
Long ll_row


ls_predtfrom = String(dw_cond.object.predtfrom[1], 'yyyymmdd')
ls_predtto = String(dw_cond.object.predtto[1], 'yyyymmdd')
ls_nowdtfrom = String(dw_cond.object.nowdtfrom[1], 'yyyymmdd')
ls_nowdtto = String(dw_cond.object.nowdtto[1], 'yyyymmdd')

If IsNull(ls_predtfrom) Then ls_predtfrom = ""
If IsNull(ls_predtto) Then ls_predtto = ""
If IsNull(ls_nowdtfrom) Then ls_nowdtfrom = ""
If IsNull(ls_nowdtto) Then ls_nowdtto = ""


IF ls_predtfrom = "" THEN
	f_msg_info(200, Title, "전기기간")
	dw_cond.SetFocus()
	dw_cond.setColumn("predtfrom")
	RETURN
END IF

IF ls_predtto = "" THEN
	f_msg_info(200, Title, "전기기간")
	dw_cond.SetFocus()
	dw_cond.setColumn("predtto")
	RETURN
END IF

IF ls_nowdtfrom = "" THEN
	f_msg_info(200, Title, "당기기간")
	dw_cond.SetFocus()
	dw_cond.setColumn("nowdtfrom")
	RETURN
END IF

IF ls_nowdtto = "" THEN
	f_msg_info(200, Title, "당기기간")
	dw_cond.SetFocus()
	dw_cond.setColumn("nowdtto")
	RETURN
END IF

//전기기간, 당기기간 표시
dw_list.object.t_pre.Text = "전기(" + String(dw_cond.object.predtfrom[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.predtto[1], 'yyyy-mm-dd') +")"
dw_list.object.t_now.Text = "당기(" + String(dw_cond.object.nowdtfrom[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.nowdtto[1], 'yyyy-mm-dd') +")"

//ll_row = dw_list.Retrieve()
ll_row = dw_list.Retrieve(ls_predtfrom,ls_predtto,ls_nowdtfrom,ls_nowdtto)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

type dw_cond from w_a_print`dw_cond within s1w_prt_customercnt_by_svc_v20
integer y = 56
integer height = 136
string dataobject = "s1dw_cnd_prt_customercnt_by_svc"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within s1w_prt_customercnt_by_svc_v20
end type

type p_close from w_a_print`p_close within s1w_prt_customercnt_by_svc_v20
end type

type dw_list from w_a_print`dw_list within s1w_prt_customercnt_by_svc_v20
integer y = 252
integer height = 1368
string dataobject = "s1dw_inq_prt_customercnt_by_svc_v20"
end type

type p_1 from w_a_print`p_1 within s1w_prt_customercnt_by_svc_v20
end type

type p_2 from w_a_print`p_2 within s1w_prt_customercnt_by_svc_v20
end type

type p_3 from w_a_print`p_3 within s1w_prt_customercnt_by_svc_v20
end type

type p_5 from w_a_print`p_5 within s1w_prt_customercnt_by_svc_v20
end type

type p_6 from w_a_print`p_6 within s1w_prt_customercnt_by_svc_v20
end type

type p_7 from w_a_print`p_7 within s1w_prt_customercnt_by_svc_v20
end type

type p_8 from w_a_print`p_8 within s1w_prt_customercnt_by_svc_v20
end type

type p_9 from w_a_print`p_9 within s1w_prt_customercnt_by_svc_v20
end type

type p_4 from w_a_print`p_4 within s1w_prt_customercnt_by_svc_v20
end type

type gb_1 from w_a_print`gb_1 within s1w_prt_customercnt_by_svc_v20
end type

type p_port from w_a_print`p_port within s1w_prt_customercnt_by_svc_v20
end type

type p_land from w_a_print`p_land within s1w_prt_customercnt_by_svc_v20
end type

type gb_cond from w_a_print`gb_cond within s1w_prt_customercnt_by_svc_v20
integer height = 220
end type

type p_saveas from w_a_print`p_saveas within s1w_prt_customercnt_by_svc_v20
end type

