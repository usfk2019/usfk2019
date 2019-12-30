$PBExportHeader$w_print_page_setup.srw
$PBExportComments$c_w1.pbl
forward
global type w_print_page_setup from w_base
end type
type em_copy from editmask within w_print_page_setup
end type
type em_to from editmask within w_print_page_setup
end type
type em_from from editmask within w_print_page_setup
end type
type st_3 from statictext within w_print_page_setup
end type
type st_2 from statictext within w_print_page_setup
end type
type p_ok from u_p_ok within w_print_page_setup
end type
type p_cancel from u_p_cancel within w_print_page_setup
end type
type p_port from picture within w_print_page_setup
end type
type p_land from picture within w_print_page_setup
end type
type st_4 from statictext within w_print_page_setup
end type
type gb_1 from groupbox within w_print_page_setup
end type
end forward

global type w_print_page_setup from w_base
integer x = 1083
integer y = 700
integer width = 1147
integer height = 544
string title = "Print Option"
boolean controlmenu = false
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_cancel ( )
event ue_ok ( )
em_copy em_copy
em_to em_to
em_from em_from
st_3 st_3
st_2 st_2
p_ok p_ok
p_cancel p_cancel
p_port p_port
p_land p_land
st_4 st_4
gb_1 gb_1
end type
global w_print_page_setup w_print_page_setup

type variables
str_print_ref istr_print_ref
Boolean ib_close
end variables

event ue_cancel;call super::ue_cancel;ib_close = True
closewithReturn( this, istr_print_ref )
end event

event ue_ok;call super::ue_ok;

If Not isnumber( em_from.text ) Or Not isnumber( em_to.text ) Or integer( em_from.text ) > integer( em_to.text ) Then
	f_msg_info( 100, "Information", "Page Range" )
	Return
Else	
	istr_print_ref.s_page_range = em_from.text +'-'+ em_to.text
End If	


If Not isnumber( em_copy.text ) Then
	f_msg_info( 100, "Information", "Copies" )
	Return
Else
	istr_print_ref.i_copies_n = integer(em_copy.text)
end If	



istr_print_ref.i_ret = 1
ib_close = True
closewithReturn( this, istr_print_ref )
end event

on w_print_page_setup.create
int iCurrent
call super::create
this.em_copy=create em_copy
this.em_to=create em_to
this.em_from=create em_from
this.st_3=create st_3
this.st_2=create st_2
this.p_ok=create p_ok
this.p_cancel=create p_cancel
this.p_port=create p_port
this.p_land=create p_land
this.st_4=create st_4
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.em_copy
this.Control[iCurrent+2]=this.em_to
this.Control[iCurrent+3]=this.em_from
this.Control[iCurrent+4]=this.st_3
this.Control[iCurrent+5]=this.st_2
this.Control[iCurrent+6]=this.p_ok
this.Control[iCurrent+7]=this.p_cancel
this.Control[iCurrent+8]=this.p_port
this.Control[iCurrent+9]=this.p_land
this.Control[iCurrent+10]=this.st_4
this.Control[iCurrent+11]=this.gb_1
end on

on w_print_page_setup.destroy
call super::destroy
destroy(this.em_copy)
destroy(this.em_to)
destroy(this.em_from)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.p_ok)
destroy(this.p_cancel)
destroy(this.p_port)
destroy(this.p_land)
destroy(this.st_4)
destroy(this.gb_1)
end on

event open;
string ls_page_cnt
int li_page_cnt

istr_print_ref = Message.PowerObjectParm

em_from.text = '1'
em_to.text = istr_print_ref.s_page_cnt
em_copy.text = '1'

end event

event close;
end event

event closequery;call super::closequery;
If Not ib_close Then Return 1
end event

type em_copy from editmask within w_print_page_setup
integer x = 274
integer y = 200
integer width = 288
integer height = 84
integer taborder = 20
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 16777215
string text = "1"
alignment alignment = center!
string mask = "####"
boolean spin = true
string displaydata = ""
double increment = 1
string minmax = "1~~1000"
end type

type em_to from editmask within w_print_page_setup
integer x = 745
integer y = 96
integer width = 283
integer height = 84
integer taborder = 30
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 16777215
alignment alignment = center!
string mask = "####"
boolean spin = true
string displaydata = ""
double increment = 1
string minmax = "1~~10000"
end type

type em_from from editmask within w_print_page_setup
integer x = 274
integer y = 100
integer width = 283
integer height = 84
integer taborder = 10
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 16777215
alignment alignment = center!
string mask = "####"
boolean spin = true
string displaydata = ""
double increment = 1
string minmax = "1~~10000"
end type

type st_3 from statictext within w_print_page_setup
integer x = 50
integer y = 224
integer width = 192
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "Copies"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_2 from statictext within w_print_page_setup
integer x = 622
integer y = 112
integer width = 110
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "To"
alignment alignment = center!
boolean focusrectangle = false
end type

type p_ok from u_p_ok within w_print_page_setup
integer x = 489
integer y = 328
end type

type p_cancel from u_p_cancel within w_print_page_setup
integer x = 795
integer y = 324
integer height = 96
end type

type p_port from picture within w_print_page_setup
boolean visible = false
integer x = 805
integer y = 368
integer width = 123
integer height = 132
boolean bringtotop = true
string picturename = "port.bmp"
boolean invert = true
boolean focusrectangle = false
end type

event clicked;p_land.invert = false
invert = true
end event

type p_land from picture within w_print_page_setup
boolean visible = false
integer x = 997
integer y = 368
integer width = 151
integer height = 100
boolean bringtotop = true
string picturename = "land.bmp"
boolean focusrectangle = false
end type

event clicked;p_port.invert = false
invert = true
end event

type st_4 from statictext within w_print_page_setup
integer x = 41
integer y = 100
integer width = 192
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
boolean enabled = false
string text = "Page"
alignment alignment = right!
boolean focusrectangle = false
end type

type gb_1 from groupbox within w_print_page_setup
boolean visible = false
integer x = 731
integer y = 300
integer width = 494
integer height = 228
integer taborder = 21
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 12632256
string text = "Orientation"
borderstyle borderstyle = stylelowered!
end type

