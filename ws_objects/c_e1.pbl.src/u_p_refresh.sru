$PBExportHeader$u_p_refresh.sru
$PBExportComments$[ceusee] Refresh 버튼
forward
global type u_p_refresh from u_p_base
end type
end forward

global type u_p_refresh from u_p_base
integer width = 197
integer height = 176
string picturename = "refresh_e.gif"
end type
global u_p_refresh u_p_refresh

on u_p_refresh.create
end on

on u_p_refresh.destroy
end on

event clicked;call super::clicked;Parent.TriggerEvent('ue_refresh')
end event

event ue_disable();call super::ue_disable;This.PictureName = "refresh_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "refresh_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "refresh_x.gif"
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "refresh_e.gif"
end event

