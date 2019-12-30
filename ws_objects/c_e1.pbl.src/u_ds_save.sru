$PBExportHeader$u_ds_save.sru
$PBExportComments$[AJT]DataStore(save, error msg)
forward
global type u_ds_save from u_ds_base
end type
end forward

global type u_ds_save from u_ds_base
end type
global u_ds_save u_ds_save

on u_ds_save.create
call datastore::create
TriggerEvent( this, "constructor" )
end on

on u_ds_save.destroy
call datastore::destroy
TriggerEvent( this, "destructor" )
end on

event dberror;call super::dberror;// prevent database error , and print maked message by own
String ls_err_title, ls_err_text

ls_err_title = "Information!"

CHOOSE CASE SQLDBCode
	CASE -1
		ls_err_text =" Can't connect to the database because of missing values in the transaction object."
	CASE -2
		ls_err_text =" Can't connect to the database."
	CASE -3
		ls_err_text =" The key specified in an Update or Retrieve no longer matches an existing row. "
		/* (This can happen when another user has changed the row after you retrieved it.)*/
	CASE -4
		ls_err_text =" Writing a blob to the database failed."
	CASE 1
		ls_err_text =" You input duplicated data."	
	CASE 1400
		ls_err_text =" You didn't input Mandatory Field. "
		/*hhm*/
	CASE 1438
		ls_err_text =" Value lager than specified precision. "	
		/*HHM */	
	CASE 2292
		ls_err_text =" Delete all the related data first. "	
		/*HHM */			
	CASE 3113
		ls_err_text = " Network Communication Error, Restart Application. "

	CASE 3114
		ls_err_text = " Oracle not connected, Restart Application. "
		
	CASE ELSE
		ls_err_title = "Undefined DB Error(DataWindow)"
		ls_err_text = "SQLDBCode = " + String(SQLDBCode) + "~r~n" + SQLErrText
END CHOOSE

MessageBox( ls_err_title, ls_err_text, Exclamation!)
return 1  // prevent db error

end event

