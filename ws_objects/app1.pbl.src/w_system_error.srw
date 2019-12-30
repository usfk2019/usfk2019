$PBExportHeader$w_system_error.srw
forward
global type w_system_error from window
end type
type cb_2 from commandbutton within w_system_error
end type
type cb_1 from commandbutton within w_system_error
end type
type dw_1 from datawindow within w_system_error
end type
end forward

global type w_system_error from window
integer x = 283
integer y = 628
integer width = 3067
integer height = 1136
boolean titlebar = true
string title = "System Error"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 12632256
cb_2 cb_2
cb_1 cb_1
dw_1 dw_1
end type
global w_system_error w_system_error

on w_system_error.create
this.cb_2=create cb_2
this.cb_1=create cb_1
this.dw_1=create dw_1
this.Control[]={this.cb_2,&
this.cb_1,&
this.dw_1}
end on

on w_system_error.destroy
destroy(this.cb_2)
destroy(this.cb_1)
destroy(this.dw_1)
end on

type cb_2 from commandbutton within w_system_error
integer x = 1280
integer y = 920
integer width = 517
integer height = 108
integer taborder = 3
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "Program Close"
end type

event clicked;Halt

end event

type cb_1 from commandbutton within w_system_error
integer x = 731
integer y = 920
integer width = 517
integer height = 108
integer taborder = 20
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "Print && Close"
end type

event clicked;dw_1.Print()

Halt
end event

type dw_1 from datawindow within w_system_error
integer x = 37
integer y = 32
integer width = 2967
integer height = 836
integer taborder = 10
string dataobject = "d_system_error"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;insertRow( 0)



Object.Line[1] = error.line
Object.Number[1] = error.number
Object.object[1] = error.object
Object.Object_Event[1] = Error.ObjectEvent
Object.Text[1] = Error.Text
Object.Window_Menu[1] = Error.windowmenu
end event

