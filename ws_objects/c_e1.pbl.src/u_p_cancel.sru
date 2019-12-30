$PBExportHeader$u_p_cancel.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_cancel from u_p_base
end type
end forward

global type u_p_cancel from u_p_base
integer height = 93
string picturename = "cancel_e.gif"
end type
global u_p_cancel u_p_cancel

event clicked;call super::clicked;Parent.TriggerEvent('ue_cancel')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "cancel_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "cancel_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "cancel_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "cancel_e.gif"
end event

on u_p_cancel.create
end on

on u_p_cancel.destroy
end on

