$PBExportHeader$u_p_log.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_log from u_p_base
end type
end forward

global type u_p_log from u_p_base
boolean originalsize = true
string picturename = "log_e.gif"
end type
global u_p_log u_p_log

event clicked;call super::clicked;Parent.TriggerEvent('ue_log')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "log_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "log_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "log_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "log_e.gif"
end event

on u_p_log.create
end on

on u_p_log.destroy
end on

