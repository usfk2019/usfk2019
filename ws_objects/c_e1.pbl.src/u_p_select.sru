$PBExportHeader$u_p_select.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_select from u_p_base
end type
end forward

global type u_p_select from u_p_base
boolean originalsize = true
string picturename = "select_e.gif"
end type
global u_p_select u_p_select

event clicked;call super::clicked;Parent.TriggerEvent('ue_select')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "select_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "select_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "select_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "select_e.gif"
end event

on u_p_select.create
end on

on u_p_select.destroy
end on

