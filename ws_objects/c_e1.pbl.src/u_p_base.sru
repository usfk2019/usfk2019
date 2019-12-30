$PBExportHeader$u_p_base.sru
$PBExportComments$Base Picture User Object
forward
global type u_p_base from picture
end type
end forward

global type u_p_base from picture
integer width = 283
integer height = 96
string pointer = "HyperLink!"
boolean focusrectangle = false
event ue_buttonup pbm_lbuttonup
event ue_buttondown pbm_lbuttondown
event ue_disable ( )
event ue_enable ( )
end type
global u_p_base u_p_base

event ue_disable;This.Enabled = False
end event

event ue_enable;This.Enabled = True
end event

on u_p_base.create
end on

on u_p_base.destroy
end on

