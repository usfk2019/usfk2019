$PBExportHeader$u_p_change.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_change from u_p_base
end type
end forward

global type u_p_change from u_p_base
string picturename = "change_e.gif"
end type
global u_p_change u_p_change

event clicked;call super::clicked;Parent.TriggerEvent('ue_change')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "change_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "change_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "change_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "change_e.gif"
end event

on u_p_change.create
end on

on u_p_change.destroy
end on

