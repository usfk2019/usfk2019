$PBExportHeader$u_p_detail.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_detail from u_p_base
end type
end forward

global type u_p_detail from u_p_base
boolean originalsize = true
string picturename = "detail_e.gif"
end type
global u_p_detail u_p_detail

event clicked;call super::clicked;Parent.TriggerEvent('ue_detail')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "detail_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "detail_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "detail_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "detail_e.gif"
end event

on u_p_detail.create
end on

on u_p_detail.destroy
end on

