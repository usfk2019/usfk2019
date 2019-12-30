$PBExportHeader$u_p_deny.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_deny from u_p_base
end type
end forward

global type u_p_deny from u_p_base
boolean originalsize = true
string picturename = "deny_e.gif"
end type
global u_p_deny u_p_deny

event clicked;call super::clicked;Parent.TriggerEvent('ue_deny')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "deny_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "deny_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "deny_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "deny_e.gif"
end event

on u_p_deny.create
end on

on u_p_deny.destroy
end on

