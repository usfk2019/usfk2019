$PBExportHeader$u_cust_base_info.sru
$PBExportComments$정보전달 관련 최상위 NVO
forward
global type u_cust_base_info from nonvisualobject
end type
end forward

global type u_cust_base_info from nonvisualobject
end type
global u_cust_base_info u_cust_base_info

on u_cust_base_info.create
TriggerEvent( this, "constructor" )
end on

on u_cust_base_info.destroy
TriggerEvent( this, "destructor" )
end on

