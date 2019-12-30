$PBExportHeader$u_p_reload.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_reload from u_p_base
end type
end forward

global type u_p_reload from u_p_base
boolean originalsize = true
string picturename = "reload_e.gif"
end type
global u_p_reload u_p_reload

event clicked;call super::clicked;Parent.TriggerEvent('ue_reload')
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "reload_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "reload_e.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "reload_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "reload_e.gif"
end event

on u_p_reload.create
end on

on u_p_reload.destroy
end on

