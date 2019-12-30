$PBExportHeader$u_p_filewrite.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_filewrite from u_p_base
end type
end forward

global type u_p_filewrite from u_p_base
boolean originalsize = true
string picturename = "filewrite_e.gif"
end type
global u_p_filewrite u_p_filewrite

event clicked;Parent.TriggerEvent('ue_filewrite')
end event

event ue_buttonup;This.PictureName = "filewrite_e.gif"
end event

event ue_buttondown;This.PictureName = "filewrite_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "filewrite_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "filewrite_e.gif"
end event

on u_p_filewrite.create
end on

on u_p_filewrite.destroy
end on

