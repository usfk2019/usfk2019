$PBExportHeader$u_p_add.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_add from u_p_base
end type
end forward

global type u_p_add from u_p_base
boolean originalsize = true
string picturename = "add_e.gif"
end type
global u_p_add u_p_add

event clicked;call super::clicked;Parent.TriggerEvent('ue_add')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "add_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "add_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "add_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "add_e.gif"
end event

on u_p_add.create
end on

on u_p_add.destroy
end on

