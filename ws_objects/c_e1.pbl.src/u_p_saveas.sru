$PBExportHeader$u_p_saveas.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_saveas from u_p_base
end type
end forward

global type u_p_saveas from u_p_base
boolean originalsize = true
string picturename = "saveas_e.gif"
end type
global u_p_saveas u_p_saveas

event clicked;Parent.TriggerEvent('ue_saveas')
end event

event ue_buttonup;
This.PictureName = "saveas_e.gif"
end event

event ue_buttondown;This.PictureName = "saveas_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "saveas_d.gif"
end event

event ue_enable();call super::ue_enable;
If fb_enable_button("SAVEAS", gi_group_auth) Then

	This.PictureName = "saveas_e.gif"
	This.Enabled = TRUE
Else

	This.PictureName = "saveas_d.gif"
	This.Enabled = FALSE
End If
end event

on u_p_saveas.create
end on

on u_p_saveas.destroy
end on

