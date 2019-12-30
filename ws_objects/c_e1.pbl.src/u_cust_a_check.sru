$PBExportHeader$u_cust_a_check.sru
forward
global type u_cust_a_check from u_cust_base_info
end type
end forward

global type u_cust_a_check from u_cust_base_info
end type
global u_cust_a_check u_cust_a_check

type variables
String is_caller
String is_title
Int ii_rc
String is_rc

Boolean ib_data[]
Integer ii_data[]
Long il_data[]
Dec ic_data[]
String is_data[]
String is_data2[]
DataWindow idw_data[]

end variables

on u_cust_a_check.create
TriggerEvent( this, "constructor" )
end on

on u_cust_a_check.destroy
TriggerEvent( this, "destructor" )
end on

