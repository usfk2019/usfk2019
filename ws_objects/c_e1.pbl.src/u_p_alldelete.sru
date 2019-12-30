$PBExportHeader$u_p_alldelete.sru
$PBExportComments$[jjuhm] All Delete 버튼
forward
global type u_p_alldelete from u_p_base
end type
end forward

global type u_p_alldelete from u_p_base
string picturename = "alldelete_e.gif"
end type
global u_p_alldelete u_p_alldelete

on u_p_alldelete.create
end on

on u_p_alldelete.destroy
end on

event ue_disable();call super::ue_disable;This.PictureName = "alldelete_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "alldelete_e.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "alldelete_e.gif"
end event

event clicked;call super::clicked;Parent.TriggerEvent('ue_alldelete')
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "alldelete_x.gif"
end event

