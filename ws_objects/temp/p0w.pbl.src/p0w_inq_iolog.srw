$PBExportHeader$p0w_inq_iolog.srw
$PBExportComments$[y.k.min] 수불작업로그조회
forward
global type p0w_inq_iolog from w_a_inq_m_m
end type
end forward

global type p0w_inq_iolog from w_a_inq_m_m
integer width = 3195
integer height = 2096
event ue_print ( )
end type
global p0w_inq_iolog p0w_inq_iolog

on p0w_inq_iolog.create
call super::create
end on

on p0w_inq_iolog.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//조회
String ls_issuedt_fr, ls_issuedt_to, ls_issuestat, ls_lotno, ls_pricemodel
Long ll_row
String ls_where

ls_issuedt_fr = String(dw_cond.object.issuedt_fr[1],"YYYYMMDD")
If IsNull(ls_issuedt_fr) Then ls_issuedt_fr = ""

ls_issuedt_to = String(dw_cond.object.issuedt_to[1],"YYYYMMDD")
If IsNull(ls_issuedt_to) Then ls_issuedt_to = ""

ls_issuestat = Trim(dw_cond.object.issuestat[1])
If IsNull(ls_issuestat) Then ls_issuestat = ""

ls_lotno = Trim(dw_cond.object.lotno[1])
If IsNull(ls_lotno) Then ls_lotno = ""

ls_pricemodel = Trim(dw_cond.object.pricemodel[1])
If IsNull(ls_pricemodel) Then ls_pricemodel = ""
	
If ls_issuedt_fr <> "" AND ls_issuedt_to <> "" Then
	If ls_issuedt_fr > ls_issuedt_to Then
		f_msg_usr_err(210, Title, "발행일시작 <= 발행일종료")
		dw_cond.SetFocus()
		dw_cond.setColumn("issuedt_fr")
		Return 
	End If
End If

IF ls_issuedt_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(issuedt, 'yyyymmdd') >= '"+ ls_issuedt_fr +"'"
END IF

IF ls_issuedt_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(issuedt, 'yyyymmdd') <= '"+ ls_issuedt_to +"'"
END IF

IF ls_issuestat <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "issuestat = '"+ ls_issuestat +"'"
END IF

IF ls_lotno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "lotno = '"+ ls_lotno +"'"
END IF

IF ls_pricemodel <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "pricemodel = '"+ ls_pricemodel +"'"
END IF

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")			
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If

end event

type dw_cond from w_a_inq_m_m`dw_cond within p0w_inq_iolog
string dataobject = "p0dw_cnd_inq_iolog"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m_m`p_ok within p0w_inq_iolog
end type

type p_close from w_a_inq_m_m`p_close within p0w_inq_iolog
end type

type gb_cond from w_a_inq_m_m`gb_cond within p0w_inq_iolog
end type

type dw_master from w_a_inq_m_m`dw_master within p0w_inq_iolog
integer width = 3072
string dataobject = "p0dw_mst_inq_iolog"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.issuestat_t
uf_init(ldwo_SORT)
end event

type dw_detail from w_a_inq_m_m`dw_detail within p0w_inq_iolog
integer x = 32
integer y = 768
integer width = 3072
integer height = 1188
string dataobject = "p0dw_inq_iolog"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;Long ll_rows
String ls_where
String ls_issueseq

//입력 조건 처리 부분

ls_issueseq = String(dw_master.Object.issueseq[al_select_row])

//Error 처리부분
If IsNull(ls_issueseq) Then ls_issueseq = ""

//Dynamic SQL 처리부분
ls_where = ""
If ls_issueseq <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where += " issueseq = " + ls_issueseq + " "
End If

//자료 읽기 및 관련 처리부분
is_where = ls_where
ll_rows = Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within p0w_inq_iolog
end type

