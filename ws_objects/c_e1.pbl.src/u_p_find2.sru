$PBExportHeader$u_p_find2.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_find2 from u_p_base
end type
end forward

global type u_p_find2 from u_p_base
boolean originalsize = true
string picturename = "find2_e.gif"
end type
global u_p_find2 u_p_find2

event clicked;call super::clicked;Parent.TriggerEvent('ue_find2')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "find2_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "find2_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "find2_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "find2_e.gif"
end event

on u_p_find2.create
end on

on u_p_find2.destroy
end on

