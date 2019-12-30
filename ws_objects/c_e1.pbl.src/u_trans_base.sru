$PBExportHeader$u_trans_base.sru
$PBExportComments$Transaction Base
forward
global type u_trans_base from transaction
end type
end forward

global type u_trans_base from transaction
end type
global u_trans_base u_trans_base

on u_trans_base.create
call transaction::create
TriggerEvent( this, "constructor" )
end on

on u_trans_base.destroy
call transaction::destroy
TriggerEvent( this, "destructor" )
end on

