$PBExportHeader$w_a_print_preview_retrieve.srw
$PBExportComments$Print Preview Ancestor(from w_a_print_a ) - Response Window , retrieve
forward
global type w_a_print_preview_retrieve from w_a_print_preview_a
end type
end forward

global type w_a_print_preview_retrieve from w_a_print_preview_a
end type
global w_a_print_preview_retrieve w_a_print_preview_retrieve

on w_a_print_preview_retrieve.create
call super::create
end on

on w_a_print_preview_retrieve.destroy
call super::destroy
end on

event open;call super::open;//////////////////////////////////////////////////////////////////////////////////////
////   Argument for preview
//////////////////////////////////////////////////////////////////////////////////////
//iu_cust_msg.is_data[1]  is dataobject( string )
//iu_cust_msg.is_data[2]  is print title ( string )
//iu_cust_msg.is_data[3]  is is_where ( string )




iu_cust_msg1 = Message.PowerObjectParm

dw_list.DataObject = iu_cust_msg1.is_data[1] 
dw_list.SetTransObject( Sqlca )
is_pgm_name = iu_cust_msg1.is_data[2] 
dw_list.is_where = iu_cust_msg1.is_data[3] 

If UpperBound( iu_cust_msg1.is_temp[]  ) > 0 then
	is_condition = iu_cust_msg1.is_temp[1] 
End IF	

If UpperBound( iu_cust_msg1.ii_data[]  ) > 0 then
	ii_orientation = iu_cust_msg1.ii_data[1] 
End IF	


is_pgm_id1 =  iu_cust_msg1.is_pgm_id

dw_list.Retrieve()

Trigger Event ue_init()
Post Event ue_set_header()
Post Event ue_preview_set()



end event

type dw_cond from w_a_print_preview_a`dw_cond within w_a_print_preview_retrieve
end type

type p_ok from w_a_print_preview_a`p_ok within w_a_print_preview_retrieve
end type

type p_close from w_a_print_preview_a`p_close within w_a_print_preview_retrieve
integer x = 2807
end type

type dw_list from w_a_print_preview_a`dw_list within w_a_print_preview_retrieve
end type

type p_1 from w_a_print_preview_a`p_1 within w_a_print_preview_retrieve
integer x = 2510
end type

type p_2 from w_a_print_preview_a`p_2 within w_a_print_preview_retrieve
end type

type p_3 from w_a_print_preview_a`p_3 within w_a_print_preview_retrieve
end type

type p_5 from w_a_print_preview_a`p_5 within w_a_print_preview_retrieve
integer x = 1161
integer y = 40
end type

type p_6 from w_a_print_preview_a`p_6 within w_a_print_preview_retrieve
integer x = 1765
integer y = 40
end type

type p_7 from w_a_print_preview_a`p_7 within w_a_print_preview_retrieve
integer x = 1563
integer y = 40
end type

type p_8 from w_a_print_preview_a`p_8 within w_a_print_preview_retrieve
integer x = 1358
integer y = 40
end type

type p_9 from w_a_print_preview_a`p_9 within w_a_print_preview_retrieve
end type

type p_4 from w_a_print_preview_a`p_4 within w_a_print_preview_retrieve
end type

type gb_1 from w_a_print_preview_a`gb_1 within w_a_print_preview_retrieve
end type

type p_port from w_a_print_preview_a`p_port within w_a_print_preview_retrieve
end type

type p_land from w_a_print_preview_a`p_land within w_a_print_preview_retrieve
end type

type gb_cond from w_a_print_preview_a`gb_cond within w_a_print_preview_retrieve
boolean visible = false
integer x = 27
integer y = 20
end type

