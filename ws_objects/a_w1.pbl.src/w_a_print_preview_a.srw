$PBExportHeader$w_a_print_preview_a.srw
$PBExportComments$Print Preview Ancestor(from w_a_print_a ) - Response Window
forward
global type w_a_print_preview_a from w_a_print_a
end type
end forward

global type w_a_print_preview_a from w_a_print_a
integer x = 9
integer y = 4
integer width = 3616
integer height = 2412
string title = "Print Preview"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
end type
global w_a_print_preview_a w_a_print_preview_a

on w_a_print_preview_a.create
call super::create
end on

on w_a_print_preview_a.destroy
call super::destroy
end on

event open;//



end event

event close;//
end event

event resize;//Override Ancestor Script by kEnn
//About Window Resize
end event

type dw_cond from w_a_print_a`dw_cond within w_a_print_preview_a
boolean visible = false
integer x = 2002
integer width = 64
integer height = 128
end type

type p_ok from w_a_print_a`p_ok within w_a_print_preview_a
boolean visible = false
integer x = 1943
integer y = 24
end type

type p_close from w_a_print_a`p_close within w_a_print_preview_a
integer x = 2811
integer y = 36
end type

type dw_list from w_a_print_a`dw_list within w_a_print_preview_a
integer x = 27
integer y = 228
integer width = 3552
integer height = 2064
end type

type p_1 from w_a_print_a`p_1 within w_a_print_preview_a
integer x = 2514
integer y = 36
end type

type p_2 from w_a_print_a`p_2 within w_a_print_preview_a
integer x = 517
integer y = 36
end type

type p_3 from w_a_print_a`p_3 within w_a_print_preview_a
integer x = 2217
integer y = 36
end type

type p_5 from w_a_print_a`p_5 within w_a_print_preview_a
integer x = 1221
integer y = 44
end type

type p_6 from w_a_print_a`p_6 within w_a_print_preview_a
integer x = 1815
integer y = 44
end type

type p_7 from w_a_print_a`p_7 within w_a_print_preview_a
integer x = 1614
integer y = 44
end type

type p_8 from w_a_print_a`p_8 within w_a_print_preview_a
integer x = 1417
integer y = 44
end type

type p_9 from w_a_print_a`p_9 within w_a_print_preview_a
boolean visible = false
integer x = 745
integer y = 36
end type

type p_4 from w_a_print_a`p_4 within w_a_print_preview_a
integer x = 960
integer y = 36
end type

type gb_1 from w_a_print_a`gb_1 within w_a_print_preview_a
integer x = 55
integer y = 12
integer height = 208
end type

type p_port from w_a_print_a`p_port within w_a_print_preview_a
integer x = 105
integer y = 72
end type

type p_land from w_a_print_a`p_land within w_a_print_preview_a
integer y = 88
end type

type gb_cond from w_a_print_a`gb_cond within w_a_print_preview_a
boolean visible = false
end type

