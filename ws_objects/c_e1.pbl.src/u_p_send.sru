$PBExportHeader$u_p_send.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_send from u_p_base
end type
end forward

global type u_p_send from u_p_base
boolean originalsize = true
string picturename = "send_e.gif"
end type
global u_p_send u_p_send

event clicked;Parent.TriggerEvent('ue_send')
end event

event ue_buttonup;This.PictureName = "send_e.gif"
end event

event ue_buttondown;This.PictureName = "send_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "send_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "send_e.gif"
end event

on u_p_send.create
end on

on u_p_send.destroy
end on

