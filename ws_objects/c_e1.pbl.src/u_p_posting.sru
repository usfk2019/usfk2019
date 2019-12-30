$PBExportHeader$u_p_posting.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_posting from u_p_base
end type
end forward

global type u_p_posting from u_p_base
boolean originalsize = true
string picturename = "pos_e.gif"
end type
global u_p_posting u_p_posting

event clicked;call super::clicked;Parent.TriggerEvent('ue_posting')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "pos_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "pos_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "pos_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "pos_e.gif"
end event

on u_p_posting.create
end on

on u_p_posting.destroy
end on

