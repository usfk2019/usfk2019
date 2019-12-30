$PBExportHeader$b2w_prt_cdrsummary3_priceplan.srw
$PBExportComments$[ssong] 가격정책별 통화량 증감현황
forward
global type b2w_prt_cdrsummary3_priceplan from w_a_print
end type
end forward

global type b2w_prt_cdrsummary3_priceplan from w_a_print
integer width = 3259
end type
global b2w_prt_cdrsummary3_priceplan b2w_prt_cdrsummary3_priceplan

on b2w_prt_cdrsummary3_priceplan.create
call super::create
end on

on b2w_prt_cdrsummary3_priceplan.destroy
call super::destroy
end on

event ue_init();call super::ue_init;//페이지 설정
ii_orientation = 1 //세로0, 가로1
ib_margin = False
end event

event ue_ok();call super::ue_ok;//조회
String ls_predtfrom, ls_predtto, ls_nowdtfrom, ls_nowdtto, ls_where
Long ll_row

ls_predtfrom = String(dw_cond.object.predtfrom[1], 'yyyymmdd')
ls_predtto = String(dw_cond.object.predtto[1], 'yyyymmdd')
ls_nowdtfrom = String(dw_cond.object.nowdtfrom[1], 'yyyymmdd')
ls_nowdtto = String(dw_cond.object.nowdtto[1], 'yyyymmdd')

If IsNull(ls_predtfrom) Then ls_predtfrom = ""
If IsNull(ls_predtto) Then ls_predtto = ""
If IsNull(ls_nowdtfrom) Then ls_nowdtfrom = ""
If IsNull(ls_nowdtto) Then ls_nowdtto = ""

If ls_predtfrom = "" Then
	f_msg_info(200, title, "전기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("predtfrom")
	Return
End If

If ls_predtto = "" Then
	f_msg_info(200, title, "전기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("predtto")
	Return
End If

If ls_nowdtfrom = "" Then
	f_msg_info(200, title, "당기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("nowdtfrom")
	Return
End If

If ls_nowdtto = "" Then
	f_msg_info(200, title, "당기기간")
	dw_cond.SetFocus()
	dw_cond.SetColumn("nowdtto")
	Return
End If

If ls_predtfrom > ls_predtto Then
	f_msg_usr_err(210, Title, "전기기간시작일 <= 전기기간종료일")
	dw_cond.SetFocus()
	dw_cond.setColumn("predtfrom")
	Return 
End If

If ls_nowdtfrom > ls_nowdtto Then
	f_msg_usr_err(210, Title, "당기기간시작일 <= 당기기간종료일")
	dw_cond.SetFocus()
	dw_cond.setColumn("nowdtfrom")
	Return 
End If

//전기기간, 당기기간 표시
dw_list.object.t_pre.Text = "전기(" + String(dw_cond.object.predtfrom[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.predtto[1], 'yyyy-mm-dd') +")"
dw_list.object.t_now.Text = "당기(" + String(dw_cond.object.nowdtfrom[1], 'yyyy-mm-dd') +" ~~ "+ String(dw_cond.object.nowdtto[1], 'yyyy-mm-dd') +")"

//ll_row = dw_list.Retrieve()
ll_row = dw_list.Retrieve(ls_predtfrom,ls_predtto,ls_nowdtfrom,ls_nowdtto)

If( ll_row = 0 ) Then
	f_msg_info(1000, Title, "")
ElseIf( ll_row < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If


end event

event ue_saveas_init();call super::ue_saveas_init;ib_saveas = True
idw_saveas = dw_list
end event

type dw_cond from w_a_print`dw_cond within b2w_prt_cdrsummary3_priceplan
integer x = 64
integer y = 68
integer width = 2203
integer height = 168
string dataobject = "b2dw_cnd_prt_cdrsummary3_priceplan"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_print`p_ok within b2w_prt_cdrsummary3_priceplan
integer x = 2560
end type

type p_close from w_a_print`p_close within b2w_prt_cdrsummary3_priceplan
integer x = 2862
end type

type dw_list from w_a_print`dw_list within b2w_prt_cdrsummary3_priceplan
integer y = 300
integer width = 3118
integer height = 1320
string dataobject = "b2dw_prt_cdrsummary3_priceplan"
end type

type p_1 from w_a_print`p_1 within b2w_prt_cdrsummary3_priceplan
end type

type p_2 from w_a_print`p_2 within b2w_prt_cdrsummary3_priceplan
end type

type p_3 from w_a_print`p_3 within b2w_prt_cdrsummary3_priceplan
end type

type p_5 from w_a_print`p_5 within b2w_prt_cdrsummary3_priceplan
end type

type p_6 from w_a_print`p_6 within b2w_prt_cdrsummary3_priceplan
end type

type p_7 from w_a_print`p_7 within b2w_prt_cdrsummary3_priceplan
end type

type p_8 from w_a_print`p_8 within b2w_prt_cdrsummary3_priceplan
end type

type p_9 from w_a_print`p_9 within b2w_prt_cdrsummary3_priceplan
end type

type p_4 from w_a_print`p_4 within b2w_prt_cdrsummary3_priceplan
end type

type gb_1 from w_a_print`gb_1 within b2w_prt_cdrsummary3_priceplan
end type

type p_port from w_a_print`p_port within b2w_prt_cdrsummary3_priceplan
end type

type p_land from w_a_print`p_land within b2w_prt_cdrsummary3_priceplan
end type

type gb_cond from w_a_print`gb_cond within b2w_prt_cdrsummary3_priceplan
integer width = 2405
integer height = 260
end type

type p_saveas from w_a_print`p_saveas within b2w_prt_cdrsummary3_priceplan
end type

