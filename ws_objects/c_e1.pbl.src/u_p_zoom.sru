$PBExportHeader$u_p_zoom.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_zoom from u_p_base
end type
end forward

global type u_p_zoom from u_p_base
boolean originalsize = true
string picturename = "zoom_e.gif"
end type
global u_p_zoom u_p_zoom

event clicked;call super::clicked;Parent.TriggerEvent('ue_zoom')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "zoom_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "zoom_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "zoom_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "zoom_e.gif"
end event

on u_p_zoom.create
end on

on u_p_zoom.destroy
end on

