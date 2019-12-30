$PBExportHeader$w_db_error.srw
forward
global type w_db_error from window
end type
type dw_error from datawindow within w_db_error
end type
type cb_print from commandbutton within w_db_error
end type
type cb_exit from commandbutton within w_db_error
end type
type cb_continue from commandbutton within w_db_error
end type
end forward

global type w_db_error from window
integer x = 379
integer y = 428
integer width = 2711
integer height = 1560
boolean titlebar = true
string title = "DB Error"
windowtype windowtype = response!
long backcolor = 79741120
toolbaralignment toolbaralignment = alignatleft!
dw_error dw_error
cb_print cb_print
cb_exit cb_exit
cb_continue cb_continue
end type
global w_db_error w_db_error

type variables
u_d_base idw_1
end variables

on w_db_error.create
this.dw_error=create dw_error
this.cb_print=create cb_print
this.cb_exit=create cb_exit
this.cb_continue=create cb_continue
this.Control[]={this.dw_error,&
this.cb_print,&
this.cb_exit,&
this.cb_continue}
end on

on w_db_error.destroy
destroy(this.dw_error)
destroy(this.cb_print)
destroy(this.cb_exit)
destroy(this.cb_continue)
end on

event open;dw_error.insertrow (0)


idw_1 = Message.PowerObjectParm

If Not Isvalid( idw_1 ) then Return



dw_error.Object.errtext[1] = idw_1.is_errtext 
dw_error.Object.syntax[1] = idw_1.is_syntax
dw_error.Object.dbcode[1] = idw_1.il_dbcode
dw_error.Object.row[1] = idw_1.il_row



end event

type dw_error from datawindow within w_db_error
integer x = 37
integer y = 32
integer width = 2610
integer height = 1284
integer taborder = 10
string dataobject = "d_db_error"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_print from commandbutton within w_db_error
integer x = 658
integer y = 1336
integer width = 590
integer height = 108
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "Print && Close"
end type

event clicked;dw_error.AcceptText()
dw_error.print()

Close( parent ) 
end event

type cb_exit from commandbutton within w_db_error
integer x = 1280
integer y = 1336
integer width = 590
integer height = 108
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "Program Close"
end type

event clicked;
close( parent )
end event

type cb_continue from commandbutton within w_db_error
boolean visible = false
integer x = 859
integer y = 1396
integer width = 430
integer height = 88
integer taborder = 20
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
string text = "&Continue"
end type

on clicked;/////////////////////////////////////////////////////////////////////////
//
// Event	 :  w_system_error.cb_continue
//
// Purpose:
// 			Closes w_system_error
//
// Log:
// 
// DATE		NAME				REVISION
//------		-------------------------------------------------------------
// Powersoft Corporation	INITIAL VERSION
//
///////////////////////////////////////////////////////////////////////////

close(parent)
end on

