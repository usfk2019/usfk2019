$PBExportHeader$u_p_sort.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_sort from u_p_base
end type
end forward

global type u_p_sort from u_p_base
boolean originalsize = true
string picturename = "sort_e.gif"
end type
global u_p_sort u_p_sort

event clicked;call super::clicked;Parent.TriggerEvent('ue_sort')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "sort_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "sort_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "sort_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "sort_e.gif"
end event

on u_p_sort.create
end on

on u_p_sort.destroy
end on

