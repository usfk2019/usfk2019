$PBExportHeader$u_p_new.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_new from u_p_base
end type
end forward

global type u_p_new from u_p_base
integer width = 219
integer height = 184
boolean originalsize = true
string picturename = "new_e.gif"
end type
global u_p_new u_p_new

event clicked;call super::clicked;Parent.TriggerEvent('ue_new')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "new_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "new_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "new_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "new_e.gif"
end event

on u_p_new.create
end on

on u_p_new.destroy
end on

