$PBExportHeader$u_p_apply.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_apply from u_p_base
end type
end forward

global type u_p_apply from u_p_base
boolean originalsize = true
string picturename = "apply_e.gif"
end type
global u_p_apply u_p_apply

event ue_buttondown;call super::ue_buttondown;This.PictureName = "apply_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "apply_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "apply_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "apply_e.gif"
end event

event clicked;call super::clicked;Parent.TriggerEvent('ue_apply')
end event

on u_p_apply.create
end on

on u_p_apply.destroy
end on

