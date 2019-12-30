$PBExportHeader$u_p_create.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_create from u_p_base
end type
end forward

global type u_p_create from u_p_base
boolean originalsize = true
string picturename = "create_e.gif"
end type
global u_p_create u_p_create

event clicked;call super::clicked;Parent.TriggerEvent('ue_create')
end event

on u_p_create.create
end on

on u_p_create.destroy
end on

event ue_buttondown;call super::ue_buttondown;This.PictureName = "create_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "create_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "create_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "create_e.gif"
end event

