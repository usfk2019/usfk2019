$PBExportHeader$u_p_save.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_save from u_p_base
end type
end forward

global type u_p_save from u_p_base
boolean originalsize = true
string picturename = "save_e.gif"
end type
global u_p_save u_p_save

event clicked;call super::clicked;Parent.TriggerEvent('ue_save')


end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "save_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "save_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "save_d.gif"
end event

event ue_enable();call super::ue_enable;If fb_enable_button("SAVE", gi_group_auth) Then
	This.PictureName = "save_e.gif"
	This.Enabled = TRUE
Else
	This.PictureName = "save_d.gif"
	This.Enabled = FALSE
End If
end event

on u_p_save.create
end on

on u_p_save.destroy
end on

