$PBExportHeader$w_calendar.srw
$PBExportComments$[oh] u_ddcal  이용한 간단한 달력
forward
global type w_calendar from window
end type
type uo_1 from u_ddcal within w_calendar
end type
end forward

global type w_calendar from window
integer x = 823
integer y = 360
integer width = 1134
integer height = 936
boolean titlebar = true
string title = "Calendar 1.01  "
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29478337
uo_1 uo_1
end type
global w_calendar w_calendar

type variables
uo_1 iu_1
end variables

on w_calendar.create
this.uo_1=create uo_1
this.Control[]={this.uo_1}
end on

on w_calendar.destroy
destroy(this.uo_1)
end on

event open;//Initialize the userobject by calling its local function Init_cal and passing it a start date
uo_1.init_cal(today())
uo_1.set_date_format ( "YYYY년MM월DD일" )
//is_date = String(today(),"YYYY-MM-DD")
end event

event close;//String ls_date
//
////ls_date = String(uo_1.sle_date.text,"YYYY-MM-DD") 
//ls_date = uo_1.sle_date.text
//
//CloseWithReturn( This, ls_date )
//
//
end event

event key;String ls_date

Choose Case key
	Case KeyEnter!
		ls_date = uo_1.sle_date.text
		CloseWithReturn( This, ls_date )
	Case KeyEscape!
		close(This)
End Choose

end event

type uo_1 from u_ddcal within w_calendar
integer x = 27
integer y = 16
integer width = 1074
integer height = 860
integer taborder = 10
end type

on uo_1.destroy
call u_ddcal::destroy
end on

