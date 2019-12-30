$PBExportHeader$b5w_inq_inpbypayid.srw
$PBExportComments$[kwon] 수동거래등록(payid입금거래조회)
forward
global type b5w_inq_inpbypayid from window
end type
type dw_cond from u_d_external within b5w_inq_inpbypayid
end type
type p_1 from u_p_close within b5w_inq_inpbypayid
end type
type p_ok from u_p_ok within b5w_inq_inpbypayid
end type
type dw_detail from u_d_sort within b5w_inq_inpbypayid
end type
type str_receive from structure within b5w_inq_inpbypayid
end type
end forward

type str_receive from structure
	string		s_reqnum
	string		s_marknm
end type

global type b5w_inq_inpbypayid from window
integer x = 5
integer y = 400
integer width = 2267
integer height = 1508
boolean titlebar = true
string title = "입금 세부 내역"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 12632256
event ue_ok ( )
event ue_close ( )
dw_cond dw_cond
p_1 p_1
p_ok p_ok
dw_detail dw_detail
end type
global b5w_inq_inpbypayid b5w_inq_inpbypayid

event ue_ok;Long ll_rows, ll_row
String ls_where 
String ls_trdt, ls_payid, ls_customerid

//ls_payid = dw_cond.Object.payid[1]
ls_trdt = dw_cond.Object.trdt[1]
If IsNull(ls_trdt) Then ls_trdt = ""

ls_customerid = dw_cond.Object.customerid[1]
If IsNull(ls_customerid) Then ls_customerid = ""
If ls_customerid = "" Then
	f_msg_usr_err(200, Title, "고객 ID")
	dw_cond.SetColumn("payid")
	Return
End If

ls_where = ""
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " AND " 
	ls_where += " customerid = '" + ls_customerid + "' "
End If
If ls_trdt <> "" Then
	If ls_where <> "" Then ls_where += " AND " 
	ls_where += " trdt = '" + ls_trdt + "' "
End If

dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "청구 자료 없음")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "detail : Retrieve()")
	Return
End If


end event

event ue_close;Close(This)
end event

on b5w_inq_inpbypayid.create
this.dw_cond=create dw_cond
this.p_1=create p_1
this.p_ok=create p_ok
this.dw_detail=create dw_detail
this.Control[]={this.dw_cond,&
this.p_1,&
this.p_ok,&
this.dw_detail}
end on

on b5w_inq_inpbypayid.destroy
destroy(this.dw_cond)
destroy(this.p_1)
destroy(this.p_ok)
destroy(this.dw_detail)
end on

event open;String ls_trdt, ls_payid, ls_marknm 
Long   ll_row
b5s_str_response lstr_response
lstr_response = Message.PowerObjectParm	

//ls_trdt = lstr_response.s_trdt
ls_payid = lstr_response.s_payid
ls_marknm = lstr_response.s_marknm

//dw_cond.Object.trdt[1] = ls_trdt
dw_cond.Object.payid[1] = ls_payid
dw_cond.Object.marknm[1] = ls_marknm

ll_row = dw_detail.Retrieve(ls_payid)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
	Return
End If

Return 0 
end event

type dw_cond from u_d_external within b5w_inq_inpbypayid
integer x = 37
integer y = 16
integer width = 1449
integer height = 160
integer taborder = 10
string dataobject = "b5d_cnd_inq_inpbypayid"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event ue_init;This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b5w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
 
end event

event doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			This.Object.customerid[1] = iu_cust_help.is_data2[1]
			This.Object.customernm[1] = iu_cust_help.is_data2[2]
		End If
End Choose

Return 0
end event

type p_1 from u_p_close within b5w_inq_inpbypayid
integer x = 1582
integer y = 12
integer width = 201
integer height = 168
end type

type p_ok from u_p_ok within b5w_inq_inpbypayid
boolean visible = false
integer x = 1659
integer y = 40
end type

type dw_detail from u_d_sort within b5w_inq_inpbypayid
integer x = 23
integer y = 188
integer width = 2213
integer height = 1216
integer taborder = 10
string dataobject = "b5d_inq_inpbypayid"
end type

event ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.paydt_t
uf_init(ldwo_SORT)

end event

