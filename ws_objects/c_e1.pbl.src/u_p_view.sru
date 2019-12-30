$PBExportHeader$u_p_view.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_view from u_p_base
end type
end forward

global type u_p_view from u_p_base
string pointer = "click.cur"
string picturename = "view_e.gif"
end type
global u_p_view u_p_view

event clicked;call super::clicked;Parent.TriggerEvent('ue_view')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "view_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "view_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "view_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "view_e.gif"
end event

on u_p_view.create
end on

on u_p_view.destroy
end on

