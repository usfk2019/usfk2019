$PBExportHeader$u_p_print.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_print from u_p_base
end type
end forward

global type u_p_print from u_p_base
boolean originalsize = true
string picturename = "print_e.gif"
end type
global u_p_print u_p_print

event clicked;call super::clicked;Parent.TriggerEvent('ue_print')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "print_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "print_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "print_d.gif"
end event

event ue_enable();call super::ue_enable;If fb_enable_button("PRINT", gi_group_auth) Then

	This.PictureName = "print_e.gif"
	This.Enabled = TRUE
Else

	This.PictureName = "print_d.gif"
	This.Enabled = FALSE
End If
end event

on u_p_print.create
end on

on u_p_print.destroy
end on

