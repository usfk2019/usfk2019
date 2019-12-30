$PBExportHeader$b5w_inq_reqdtl_response.srw
$PBExportComments$*[backgu-2002/09/24] 청구거래내역조회
forward
global type b5w_inq_reqdtl_response from window
end type
type st_2 from statictext within b5w_inq_reqdtl_response
end type
type st_marknm from statictext within b5w_inq_reqdtl_response
end type
type st_reqnum from statictext within b5w_inq_reqdtl_response
end type
type st_1 from statictext within b5w_inq_reqdtl_response
end type
type dw_detail from u_d_sort within b5w_inq_reqdtl_response
end type
type ln_1 from line within b5w_inq_reqdtl_response
end type
type ln_2 from line within b5w_inq_reqdtl_response
end type
type str_receive from structure within b5w_inq_reqdtl_response
end type
end forward

type str_receive from structure
	string		s_reqnum
	string		s_marknm
end type

global type b5w_inq_reqdtl_response from window
integer x = 5
integer y = 400
integer width = 3136
integer height = 1876
boolean titlebar = true
string title = "사업자별 거래 세부내역"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29478337
st_2 st_2
st_marknm st_marknm
st_reqnum st_reqnum
st_1 st_1
dw_detail dw_detail
ln_1 ln_1
ln_2 ln_2
end type
global b5w_inq_reqdtl_response b5w_inq_reqdtl_response

on b5w_inq_reqdtl_response.create
this.st_2=create st_2
this.st_marknm=create st_marknm
this.st_reqnum=create st_reqnum
this.st_1=create st_1
this.dw_detail=create dw_detail
this.ln_1=create ln_1
this.ln_2=create ln_2
this.Control[]={this.st_2,&
this.st_marknm,&
this.st_reqnum,&
this.st_1,&
this.dw_detail,&
this.ln_1,&
this.ln_2}
end on

on b5w_inq_reqdtl_response.destroy
destroy(this.st_2)
destroy(this.st_marknm)
destroy(this.st_reqnum)
destroy(this.st_1)
destroy(this.dw_detail)
destroy(this.ln_1)
destroy(this.ln_2)
end on

event open;Long   ll_row
String ls_reqnum, ls_marknm
b5s_str_response lstr_response

lstr_response = Message.PowerObjectParm
ls_reqnum = lstr_response.s_reqnum
ls_marknm = lstr_response.s_marknm

st_reqnum.Text = ls_reqnum
st_marknm.Text = ls_marknm

ll_row = dw_detail.Retrieve(ls_reqnum)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Detail : Retrieve()")
	Return
End If

Return 0

end event

type st_2 from statictext within b5w_inq_reqdtl_response
integer x = 992
integer y = 36
integer width = 489
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "Customer Name:"
alignment alignment = right!
long bordercolor = 16711680
boolean focusrectangle = false
boolean righttoleft = true
boolean disabledlook = true
end type

type st_marknm from statictext within b5w_inq_reqdtl_response
integer x = 1499
integer y = 36
integer width = 1207
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean focusrectangle = false
end type

type st_reqnum from statictext within b5w_inq_reqdtl_response
integer x = 425
integer y = 36
integer width = 498
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
boolean focusrectangle = false
end type

type st_1 from statictext within b5w_inq_reqdtl_response
integer x = 37
integer y = 40
integer width = 375
integer height = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "Invoice No:"
alignment alignment = right!
boolean focusrectangle = false
end type

type dw_detail from u_d_sort within b5w_inq_reqdtl_response
integer x = 27
integer y = 128
integer width = 3072
integer height = 1640
integer taborder = 10
string dataobject = "b5d_inq_reqdtl_response"
end type

event ue_init;call super::ue_init;dwObject ldwo_SORT

ldwo_SORT = Object.reqdtl_trcod_t
uf_init(ldwo_SORT)

end event

type ln_1 from line within b5w_inq_reqdtl_response
long linecolor = 8421504
integer linethickness = 1
integer beginx = 416
integer beginy = 100
integer endx = 983
integer endy = 100
end type

type ln_2 from line within b5w_inq_reqdtl_response
long linecolor = 8421504
integer linethickness = 1
integer beginx = 1472
integer beginy = 100
integer endx = 2702
integer endy = 100
end type

