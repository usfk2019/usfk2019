$PBExportHeader$u_p_modify.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_modify from u_p_base
end type
end forward

global type u_p_modify from u_p_base
boolean originalsize = true
string picturename = "modify_e.gif"
end type
global u_p_modify u_p_modify

event clicked;call super::clicked;Parent.TriggerEvent('ue_modify')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "modify_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "modify_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "modify_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "modify_e.gif"
end event

on u_p_modify.create
end on

on u_p_modify.destroy
end on

