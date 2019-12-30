$PBExportHeader$w_zoom_size.srw
$PBExportComments$(csh) Print Zoom Size
forward
global type w_zoom_size from window
end type
type em_custom from editmask within w_zoom_size
end type
type rb_5 from radiobutton within w_zoom_size
end type
type rb_4 from radiobutton within w_zoom_size
end type
type rb_3 from radiobutton within w_zoom_size
end type
type rb_2 from radiobutton within w_zoom_size
end type
type rb_1 from radiobutton within w_zoom_size
end type
type p_2 from u_p_cancel within w_zoom_size
end type
type p_1 from u_p_ok within w_zoom_size
end type
type gb_1 from groupbox within w_zoom_size
end type
end forward

global type w_zoom_size from window
integer x = 1161
integer y = 540
integer width = 1106
integer height = 796
boolean titlebar = true
string title = "Zoom Size Select"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29478337
event ue_ok ( )
event ue_cancel ( )
em_custom em_custom
rb_5 rb_5
rb_4 rb_4
rb_3 rb_3
rb_2 rb_2
rb_1 rb_1
p_2 p_2
p_1 p_1
gb_1 gb_1
end type
global w_zoom_size w_zoom_size

type variables
integer il_size
end variables

event ue_ok;



CloseWithReturn( This, il_size )

end event

event ue_cancel;CloseWithReturn( This, 0 )
end event

on w_zoom_size.create
this.em_custom=create em_custom
this.rb_5=create rb_5
this.rb_4=create rb_4
this.rb_3=create rb_3
this.rb_2=create rb_2
this.rb_1=create rb_1
this.p_2=create p_2
this.p_1=create p_1
this.gb_1=create gb_1
this.Control[]={this.em_custom,&
this.rb_5,&
this.rb_4,&
this.rb_3,&
this.rb_2,&
this.rb_1,&
this.p_2,&
this.p_1,&
this.gb_1}
end on

on w_zoom_size.destroy
destroy(this.em_custom)
destroy(this.rb_5)
destroy(this.rb_4)
destroy(this.rb_3)
destroy(this.rb_2)
destroy(this.rb_1)
destroy(this.p_2)
destroy(this.p_1)
destroy(this.gb_1)
end on

event open;il_size = 100
end event

event key;IF keyflags = 0 THEN
	IF key = KeyEnter! THEN
			p_1.Trigger Event clicked()
	ELSEIF key  = KeyEscape! THEN
			p_2.Trigger Event clicked()	
	END IF
END IF
end event

type em_custom from editmask within w_zoom_size
integer x = 407
integer y = 528
integer width = 251
integer height = 80
integer taborder = 2
integer textsize = -10
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 16777215
string text = "100"
string mask = "###"
boolean spin = true
string displaydata = "8"
string minmax = "1~~999"
end type

event modified;il_size = integer( text )
end event

type rb_5 from radiobutton within w_zoom_size
integer x = 82
integer y = 532
integer width = 347
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "Custom"
end type

event clicked;il_size = integer( em_custom.text )
end event

type rb_4 from radiobutton within w_zoom_size
integer x = 82
integer y = 444
integer width = 247
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "30%"
borderstyle borderstyle = stylelowered!
end type

event clicked;il_size = 30
end event

type rb_3 from radiobutton within w_zoom_size
integer x = 82
integer y = 340
integer width = 247
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "65%"
borderstyle borderstyle = stylelowered!
end type

event clicked;il_size = 65
end event

type rb_2 from radiobutton within w_zoom_size
integer x = 82
integer y = 236
integer width = 247
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "100%"
boolean checked = true
borderstyle borderstyle = stylelowered!
end type

type rb_1 from radiobutton within w_zoom_size
integer x = 82
integer y = 132
integer width = 247
integer height = 76
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "200%"
borderstyle borderstyle = stylelowered!
end type

event clicked;il_size = 200
end event

type p_2 from u_p_cancel within w_zoom_size
integer x = 786
integer y = 188
integer height = 96
end type

type p_1 from u_p_ok within w_zoom_size
integer x = 786
integer y = 60
end type

type gb_1 from groupbox within w_zoom_size
integer x = 37
integer y = 32
integer width = 699
integer height = 644
integer taborder = 1
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 29478337
string text = "Size"
borderstyle borderstyle = stylelowered!
end type

