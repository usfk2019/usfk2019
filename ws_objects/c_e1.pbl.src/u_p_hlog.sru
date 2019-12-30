$PBExportHeader$u_p_hlog.sru
$PBExportComments$Picture User Object (from u_p_base)
forward
global type u_p_hlog from u_p_base
end type
end forward

global type u_p_hlog from u_p_base
boolean originalsize = true
string picturename = "hlog_e.gif"
end type
global u_p_hlog u_p_hlog

event clicked;call super::clicked;Parent.TriggerEvent('ue_log')
end event

event ue_buttonup;call super::ue_buttonup;This.PictureName = "hlog_e.gif"
end event

event ue_buttondown;call super::ue_buttondown;This.PictureName = "hlog_x.gif"
end event

event ue_disable();call super::ue_disable;This.PictureName = "hlog_d.gif"
end event

event ue_enable();call super::ue_enable;This.PictureName = "hlog_e.gif"
end event

on u_p_hlog.create
end on

on u_p_hlog.destroy
end on

