$PBExportHeader$u_d_dberr.sru
$PBExportComments$dw Dberror( from u_d_dberr )
forward
global type u_d_dberr from u_d_help
end type
end forward

global type u_d_dberr from u_d_help
end type
global u_d_dberr u_d_dberr

type variables
//String is_old, is_new  //For old & New Data
end variables

event dberror;is_errtext = sqlerrtext
il_dbcode = sqldbcode
is_syntax = sqlsyntax
il_row = row

//OpenWithParm(w_db_error, This, Parent)

// prevent database error , and print maked message by own
String ls_err_title, ls_err_text

//ls_err_title = "Information!"
Choose Case SQLDBCode
	Case -1
		ls_err_text = " Can't connect to the database because of missing values in the transaction object."
	Case -2
		ls_err_text = " Can't connect to the database."
	Case -3
		ls_err_text = " The key specified in an Update or Retrieve no longer matches an existing row. "
		/* (This can happen when another user has changed the row after you retrieved it.)*/
	Case -4
		ls_err_text = " Writing a blob to the database failed."
	Case 1
		ls_err_text = " Duplicated data."	
	
	Case 1400
		ls_err_text = " You didn't input Mandatory Field. "
		/*hhm*/
	Case 1438
		ls_err_text = " Value larger than specified precision. "	
		/*HHM */	
	Case 2292
		ls_err_text = " Delete all the related data first. "	
		/*HHM */			
	Case 3113
		ls_err_text = " Network Communication Error, Restart Application. "

	Case 3114
		ls_err_text = " Oracle not connected, Restart Application. "
		
	Case Else
		ls_err_title = "Undefined DB Error(DataWindow)"
		ls_err_text = "SQLDBCode = " + String(SQLDBCode) + "~r~n" + SQLErrText
End Choose

MessageBox(ls_err_title, ls_err_text, Exclamation!)

Return 1  // prevent db error

end event

