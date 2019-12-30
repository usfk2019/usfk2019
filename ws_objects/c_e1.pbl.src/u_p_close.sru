$PBExportHeader$u_p_close.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_close from u_p_base
end type
end forward

global type u_p_close from u_p_base
boolean originalsize = true
string picturename = "close_e.gif"
end type
global u_p_close u_p_close

event clicked;call super::clicked;Parent.TriggerEvent('ue_close')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "close_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "close_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "close_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "close_e.gif"
end event

on u_p_close.create
end on

on u_p_close.destroy
end on

