$PBExportHeader$ubs_w_pop_group_retrieve.srw
$PBExportComments$[jhchoi] 모바일 신규 신청 계약서 출력 팝업 - 2009.03.19
forward
global type ubs_w_pop_group_retrieve from w_a_hlp
end type
type dw_1 from datawindow within ubs_w_pop_group_retrieve
end type
type gb_1 from groupbox within ubs_w_pop_group_retrieve
end type
end forward

global type ubs_w_pop_group_retrieve from w_a_hlp
integer width = 2821
integer height = 1760
string title = ""
event ue_print ( )
event ue_psetup ( )
dw_1 dw_1
gb_1 gb_1
end type
global ubs_w_pop_group_retrieve ubs_w_pop_group_retrieve

type variables
String is_print_check
end variables

on ubs_w_pop_group_retrieve.create
int iCurrent
call super::create
this.dw_1=create dw_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_1
this.Control[iCurrent+2]=this.gb_1
end on

on ubs_w_pop_group_retrieve.destroy
call super::destroy
destroy(this.dw_1)
destroy(this.gb_1)
end on

event open;call super::open;datawindow ldw_data[]
LONG		  ll_row

ldw_data[1]		= iu_cust_help.idw_data[1]
ll_row 			= iu_cust_help.il_data[1]

This.Title =  iu_cust_help.is_pgm_name 

dw_1.Object.shop[1] = gs_shopid

dw_hlp.Retrieve(gs_shopid)










end event

event ue_close();Destroy iu_cust_help

CLOSE(THIS)
end event

event ue_ok();STRING	ls_shop

ls_shop = dw_1.Object.shop[1]

dw_hlp.Retrieve(ls_shop)

end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_group_retrieve
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_group_retrieve
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_group_retrieve
integer x = 2464
integer y = 72
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_group_retrieve
integer x = 23
integer y = 1552
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_group_retrieve
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_group_retrieve
integer x = 23
integer y = 240
integer width = 2761
integer height = 1280
string dataobject = "ubs_dw_pop_group_retrieve_mas"
end type

event dw_hlp::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::sqlpreview;//
end event

type dw_1 from datawindow within ubs_w_pop_group_retrieve
integer x = 32
integer y = 28
integer width = 2350
integer height = 188
integer taborder = 30
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_group_retrieve_cond"
boolean border = false
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
InsertRow(0)
end event

type gb_1 from groupbox within ubs_w_pop_group_retrieve
integer x = 23
integer y = 8
integer width = 2761
integer height = 220
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

