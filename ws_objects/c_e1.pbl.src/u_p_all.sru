$PBExportHeader$u_p_all.sru
$PBExportComments$[ceusee] All 버튼
forward
global type u_p_all from u_p_base
end type
end forward

global type u_p_all from u_p_base
string picturename = "all_e.gif"
end type
global u_p_all u_p_all

on u_p_all.create
end on

on u_p_all.destroy
end on

event ue_disable();call super::ue_disable;This.PictureName = "all_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "all_e.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "all_e.gif"
end event

event clicked;call super::clicked;Parent.TriggerEvent('ue_all')
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "all_x.gif"
end event

