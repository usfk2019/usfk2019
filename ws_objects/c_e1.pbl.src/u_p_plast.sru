$PBExportHeader$u_p_plast.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_plast from u_p_base
end type
end forward

global type u_p_plast from u_p_base
integer width = 192
boolean originalsize = true
string picturename = "plast_e.gif"
end type
global u_p_plast u_p_plast

event clicked;call super::clicked;Parent.TriggerEvent('ue_plast')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "plast_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "plast_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "plast_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "plast_e.gif"
end event

on u_p_plast.create
end on

on u_p_plast.destroy
end on

