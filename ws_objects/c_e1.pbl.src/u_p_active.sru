$PBExportHeader$u_p_active.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_active from u_p_base
end type
end forward

global type u_p_active from u_p_base
boolean originalsize = true
string picturename = "active_e.gif"
end type
global u_p_active u_p_active

event clicked;call super::clicked;Parent.TriggerEvent('ue_save')


end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "active_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "active_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "active_d.gif"
end event

event ue_enable();If fb_enable_button("SAVE", gi_group_auth) Then
	This.PictureName = "active_e.gif"
	This.Enabled = TRUE
Else
	This.PictureName = "active_d.gif"
	This.Enabled = FALSE
End If
end event

on u_p_active.create
end on

on u_p_active.destroy
end on

