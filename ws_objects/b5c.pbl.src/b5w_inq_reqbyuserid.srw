$PBExportHeader$b5w_inq_reqbyuserid.srw
$PBExportComments$[oH] 수동거래등록(userid거래내역조회)
forward
global type b5w_inq_reqbyuserid from window
end type
type dw_cond from u_d_external within b5w_inq_reqbyuserid
end type
type p_1 from u_p_close within b5w_inq_reqbyuserid
end type
type p_ok from u_p_ok within b5w_inq_reqbyuserid
end type
type dw_detail from u_d_sort within b5w_inq_reqbyuserid
end type
type str_receive from structure within b5w_inq_reqbyuserid
end type
end forward

type str_receive from structure
	string		s_reqnum
	string		s_marknm
end type

global type b5w_inq_reqbyuserid from window
integer x = 5
integer y = 400
integer width = 2382
integer height = 1508
boolean titlebar = true
string title = "청구 거래 세부내역"
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
global b5w_inq_reqbyuserid b5w_inq_reqbyuserid

event ue_ok;Long ll_rows, ll_row
String ls_where 
String ls_trdt, ls_payid, ls_customerid

dw_cond.AcceptText()

ls_trdt = dw_cond.Object.trdt[1]
ls_payid = dw_cond.Object.payid[1]
ll_row = dw_cond.GetRow()
ll_rows = dw_cond.RowCount()
ls_customerid = dw_cond.Object.customerid[ll_row]
If IsNull(ls_customerid) Then ls_customerid = ""
//If ls_userid = "" Then
//	f_msg_usr_err(200, Title, "사용자 SVC ID")
//	dw_cond.SetColumn("userid")
//	Return
//End If

ls_where = ""
If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND " 
	ls_where += " payid = '" + ls_payid + "' "
End If
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

on b5w_inq_reqbyuserid.create
this.dw_cond=create dw_cond
this.p_1=create p_1
this.p_ok=create p_ok
this.dw_detail=create dw_detail
this.Control[]={this.dw_cond,&
this.p_1,&
this.p_ok,&
this.dw_detail}
end on

on b5w_inq_reqbyuserid.destroy
destroy(this.dw_cond)
destroy(this.p_1)
destroy(this.p_ok)
destroy(this.dw_detail)
end on

event open;String ls_trdt, ls_payid 
Long   ll_row
b5s_str_response lstr_response
lstr_response = Message.PowerObjectParm	

ls_trdt = lstr_response.s_trdt
ls_payid = lstr_response.s_payid

//ll_row = dw_cond.InsertRow(0)
dw_cond.Object.trdt[1] = ls_trdt
dw_cond.Object.payid[1] = ls_payid

//ll_row = dw_detail.Retrieve(ls_reqnum)
//If ll_row < 0 Then
//	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
//	Return
//End If

Post Event ue_ok()

Return 0 
end event

type dw_cond from u_d_external within b5w_inq_reqbyuserid
integer x = 27
integer y = 12
integer width = 1765
integer height = 212
integer taborder = 10
string dataobject = "b5d_cnd_inq_reqbyuserid"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event ue_init;This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b5w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"

String ls_payid 
b5s_str_response lstr_response

lstr_response = Message.PowerObjectParm	
ls_payid = lstr_response.s_payid

This.is_temp[1] = ls_payid  //SVCID help에서 쓰이는 납입고객번호


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

type p_1 from u_p_close within b5w_inq_reqbyuserid
integer x = 2075
integer y = 44
integer width = 201
integer height = 168
end type

type p_ok from u_p_ok within b5w_inq_reqbyuserid
integer x = 1851
integer y = 44
end type

type dw_detail from u_d_sort within b5w_inq_reqbyuserid
integer x = 27
integer y = 244
integer width = 2318
integer height = 1160
integer taborder = 10
string dataobject = "b5d_inq_reqbyuserid"
end type

event ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.trcod_t
uf_init(ldwo_SORT)

end event

