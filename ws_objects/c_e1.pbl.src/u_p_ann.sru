$PBExportHeader$u_p_ann.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_ann from u_p_base
end type
end forward

global type u_p_ann from u_p_base
integer width = 201
integer height = 176
boolean originalsize = true
string picturename = "ann_e.bmp"
end type
global u_p_ann u_p_ann

event clicked;call super::clicked;Parent.TriggerEvent('ue_ann')
end event

event ue_buttonup;call super::ue_buttonup;PictureName = "ann_e.bmp"
end event

event ue_buttondown;call super::ue_buttondown;PictureName = "ann_x.bmp"
end event

event ue_disable;call super::ue_disable;PictureName = "ann_d.bmp"
end event

event ue_enable;call super::ue_enable;PictureName = "ann_e.bmp"
end event

on u_p_ann.create
end on

on u_p_ann.destroy
end on

