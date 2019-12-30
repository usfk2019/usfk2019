$PBExportHeader$b1w_inq_payid_billing_info.srw
$PBExportComments$[ceusee] 납입자 청구 정보
forward
global type b1w_inq_payid_billing_info from window
end type
type st_name from statictext within b1w_inq_payid_billing_info
end type
type st_payid from statictext within b1w_inq_payid_billing_info
end type
type st_1 from statictext within b1w_inq_payid_billing_info
end type
type p_ok from u_p_ok within b1w_inq_payid_billing_info
end type
type dw_cond from u_d_external within b1w_inq_payid_billing_info
end type
type p_close from u_p_close within b1w_inq_payid_billing_info
end type
type dw_detail from u_d_sort within b1w_inq_payid_billing_info
end type
type ln_2 from line within b1w_inq_payid_billing_info
end type
type ln_1 from line within b1w_inq_payid_billing_info
end type
end forward

global type b1w_inq_payid_billing_info from window
integer width = 3250
integer height = 1412
boolean titlebar = true
string title = "납입자 청구정보"
windowtype windowtype = response!
long backcolor = 29478337
event ue_close ( )
event ue_ok ( )
st_name st_name
st_payid st_payid
st_1 st_1
p_ok p_ok
dw_cond dw_cond
p_close p_close
dw_detail dw_detail
ln_2 ln_2
ln_1 ln_1
end type
global b1w_inq_payid_billing_info b1w_inq_payid_billing_info

type variables

end variables

event ue_close;Close(This)
end event

event ue_ok;//조회
String ls_payid, ls_where
Long ll_row

ls_payid = Trim(dw_cond.object.payid[1])
If IsNull(ls_payid) Then ls_payid = ""
If ls_payid = "" Then
	f_msg_info(200, Title, "납입자")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
   Return
End If

ls_where = "customerid = '" + ls_payid + "' "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If
end event

on b1w_inq_payid_billing_info.create
this.st_name=create st_name
this.st_payid=create st_payid
this.st_1=create st_1
this.p_ok=create p_ok
this.dw_cond=create dw_cond
this.p_close=create p_close
this.dw_detail=create dw_detail
this.ln_2=create ln_2
this.ln_1=create ln_1
this.Control[]={this.st_name,&
this.st_payid,&
this.st_1,&
this.p_ok,&
this.dw_cond,&
this.p_close,&
this.dw_detail,&
this.ln_2,&
this.ln_1}
end on

on b1w_inq_payid_billing_info.destroy
destroy(this.st_name)
destroy(this.st_payid)
destroy(this.st_1)
destroy(this.p_ok)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.dw_detail)
destroy(this.ln_2)
destroy(this.ln_1)
end on

event open;/*-------------------------------------------------------
	Name	: b1w_inq_payid_billing_info
	Desc.	: 납입자 청구 정보
	Ver.	: 1.0
	Date	: 2002.09.27
	Programer : Choi Bo Ra(ceusee)
---------------------------------------------------------*/
Long   ll_row
String ls_payid, ls_name

f_center_window(b1w_inq_payid_billing_info)
ls_payid = Message.StringParm
select customernm
into :ls_name
from customerm where to_char(customerid) = :ls_payid;



st_payid.Text = ls_payid
st_name.Text = ls_name
If ls_payid <>  "" Then
	dw_cond.object.payid[1] = ls_payid
	Post Event ue_ok()
End If
Return 0


end event

type st_name from statictext within b1w_inq_payid_billing_info
integer x = 837
integer y = 60
integer width = 736
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 29478337
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_payid from statictext within b1w_inq_payid_billing_info
integer x = 439
integer y = 60
integer width = 352
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 29478337
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_1 from statictext within b1w_inq_payid_billing_info
integer x = 69
integer y = 60
integer width = 366
integer height = 64
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "납입고객 :"
boolean focusrectangle = false
end type

type p_ok from u_p_ok within b1w_inq_payid_billing_info
boolean visible = false
integer x = 1216
integer y = 24
end type

type dw_cond from u_d_external within b1w_inq_payid_billing_info
boolean visible = false
integer x = 23
integer y = 24
integer width = 1033
integer height = 148
integer taborder = 10
string dataobject = "b1dw_cnd_reg_billing_info"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event ue_init;dw_cond.is_help_win[1] = "b1w_hlp_payid"
dw_cond.idwo_help_col[1] = dw_cond.Object.payid
dw_cond.is_data[1] = "CloseWithReturn"
end event

event doubleclicked;call super::doubleclicked;If dwo.name = "payid" Then
	If dw_cond.iu_cust_help.ib_data[1] Then
		dw_cond.Object.payid[1] = &
		dw_cond.iu_cust_help.is_data[1]
	End If
End If

Return 0
end event

type p_close from u_p_close within b1w_inq_payid_billing_info
integer x = 2921
integer y = 1124
boolean originalsize = false
end type

type dw_detail from u_d_sort within b1w_inq_payid_billing_info
integer x = 41
integer y = 140
integer width = 3163
integer height = 944
integer taborder = 10
string dataobject = "b1dw_inq_billing_info"
boolean hscrollbar = false
end type

type ln_2 from line within b1w_inq_payid_billing_info
long linecolor = 8421504
integer linethickness = 1
integer beginx = 841
integer beginy = 124
integer endx = 1605
integer endy = 124
end type

type ln_1 from line within b1w_inq_payid_billing_info
long linecolor = 8421504
integer linethickness = 1
integer beginx = 425
integer beginy = 124
integer endx = 800
integer endy = 124
end type

