$PBExportHeader$u_p_rename.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_rename from u_p_base
end type
end forward

global type u_p_rename from u_p_base
boolean originalsize = true
string picturename = "rename_e.gif"
end type
global u_p_rename u_p_rename

event clicked;call super::clicked;Parent.TriggerEvent('ue_rename')
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "rename_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "rename_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "rename_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "rename_e.gif"
end event

on u_p_rename.create
end on

on u_p_rename.destroy
end on

