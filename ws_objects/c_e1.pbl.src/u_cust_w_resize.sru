$PBExportHeader$u_cust_w_resize.sru
$PBExportComments$[kEnn] Window Resize
forward
global type u_cust_w_resize from nonvisualobject
end type
end forward

global type u_cust_w_resize from nonvisualobject
end type
global u_cust_w_resize u_cust_w_resize

type variables
//w_a_reg_m, w_a_print_a
Constant Integer ii_dw_button_space = 20
Constant Integer ii_button_space = 200

//w_a_reg_m_m
Constant Integer ii_button_space_1 = 170

//w_a_print_a
Constant Integer ii_gb_space = 20
Constant Integer ii_port_space = 50
Constant Integer ii_land_space = 60

end variables

on u_cust_w_resize.create
call super::create
TriggerEvent( this, "constructor" )
end on

on u_cust_w_resize.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

