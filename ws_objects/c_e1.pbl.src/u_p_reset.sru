$PBExportHeader$u_p_reset.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_reset from u_p_base
end type
end forward

global type u_p_reset from u_p_base
boolean originalsize = true
string picturename = "reset_e.gif"
end type
global u_p_reset u_p_reset

event clicked;call super::clicked;Parent.TriggerEvent('ue_reset')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "reset_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "reset_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "reset_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "reset_e.gif"
end event

on u_p_reset.create
end on

on u_p_reset.destroy
end on

