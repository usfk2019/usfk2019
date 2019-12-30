$PBExportHeader$u_cust_a_msg.sru
$PBExportComments$Ancestor - 일반적인 Message전달
forward
global type u_cust_a_msg from u_cust_base_info
end type
end forward

global type u_cust_a_msg from u_cust_base_info
end type
global u_cust_a_msg u_cust_a_msg

type variables
String is_pgm_id
String is_grp_name
String is_pgm_name
String is_call_name[4]
String is_pgm_type
Window iw_opened[4]


Dec{2} ic_data[]
Date id_data[]
String is_temp[]
String is_data[], is_data_nm[], is_data2[], is_data3[]
Integer ii_data[]
Long il_data[]
Time it_data[]
DateTime idt_data[]
DwObject idwo_data[]
Datawindow idw_data[]
Treeview itv_data[]
Boolean ib_data[]

//Use for Another Database
Transaction iSQLCA
String is_database

end variables

on u_cust_a_msg.create
call super::create
end on

on u_cust_a_msg.destroy
call super::destroy
end on

