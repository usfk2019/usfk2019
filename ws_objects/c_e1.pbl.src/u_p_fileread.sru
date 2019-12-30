$PBExportHeader$u_p_fileread.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_fileread from u_p_base
end type
end forward

global type u_p_fileread from u_p_base
boolean originalsize = true
string picturename = "fileread_e.gif"
end type
global u_p_fileread u_p_fileread

event clicked;Parent.TriggerEvent('ue_fileread')
end event

event ue_buttonup;This.PictureName = "fileread_e.gif"
end event

event ue_buttondown;This.PictureName = "fileread_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "fileread_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "fileread_e.gif"
end event

on u_p_fileread.create
end on

on u_p_fileread.destroy
end on

