$PBExportHeader$u_cust_a_db.sru
$PBExportComments$Ancestor - f_dbmgr()의 인자료 사용
forward
global type u_cust_a_db from u_cust_a_msg
end type
end forward

global type u_cust_a_db from u_cust_a_msg
end type
global u_cust_a_db u_cust_a_db

type variables
String is_caller
String is_title
Int ii_rc
String is_rc
DataWindow idw_id[]

end variables

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_04 ()
public subroutine uf_prc_db_05 ()
end prototypes

public subroutine uf_prc_db ();
end subroutine

public subroutine uf_prc_db_01 ();
end subroutine

public subroutine uf_prc_db_02 ();
end subroutine

public subroutine uf_prc_db_03 ();
end subroutine

public subroutine uf_prc_db_06 ();
end subroutine

public subroutine uf_prc_db_04 ();
end subroutine

public subroutine uf_prc_db_05 ();
end subroutine

on u_cust_a_db.create
TriggerEvent( this, "constructor" )
end on

on u_cust_a_db.destroy
TriggerEvent( this, "destructor" )
end on

