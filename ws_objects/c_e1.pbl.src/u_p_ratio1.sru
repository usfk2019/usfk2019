$PBExportHeader$u_p_ratio1.sru
$PBExportComments$Picture User Object (from u_p_base )
forward
global type u_p_ratio1 from u_p_base
end type
end forward

global type u_p_ratio1 from u_p_base
integer width = 201
integer height = 176
boolean originalsize = true
string picturename = "ratio1_e.gif"
end type
global u_p_ratio1 u_p_ratio1

event clicked;call super::clicked;Parent.TriggerEvent('ue_ratio1')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "ratio1_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "ratio1_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "ratio1_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "ratio1_e.gif"
end event

on u_p_ratio1.create
end on

on u_p_ratio1.destroy
end on

