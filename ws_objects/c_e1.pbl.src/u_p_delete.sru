﻿$PBExportHeader$u_p_delete.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_delete from u_p_base
end type
end forward

global type u_p_delete from u_p_base
boolean originalsize = true
string picturename = "delete_e.gif"
end type
global u_p_delete u_p_delete

event clicked;call super::clicked;Parent.TriggerEvent('ue_delete')


end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "delete_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "delete_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "delete_d.gif"
end event

event ue_enable();call super::ue_enable;
If fb_enable_button("DELETE", gi_group_auth) Then
   This.PictureName = "delete_e.gif"
	This.Enabled = TRUE
Else
	This.PictureName = "delete_d.gif"
	This.Enabled = FALSE
End If
end event

on u_p_delete.create
end on

on u_p_delete.destroy
end on

