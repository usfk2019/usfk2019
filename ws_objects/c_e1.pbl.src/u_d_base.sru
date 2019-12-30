$PBExportHeader$u_d_base.sru
$PBExportComments$Dw Base Ancestor
forward
global type u_d_base from datawindow
end type
end forward

global type u_d_base from datawindow
integer width = 1262
integer height = 368
integer taborder = 1
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type
global u_d_base u_d_base

type variables
//SetTransObject에 사용할 Transaction
Transaction itrans_connect = SQLCA

//Dynamic SQL의 처리
String is_where


string is_errtext 
string is_syntax
Long il_dbcode
Long il_row

end variables

forward prototypes
private function string ufs_where (string as_sql_stmt)
end prototypes

private function string ufs_where (string as_sql_stmt);Integer li_where, li_group, li_order, li_sql_len, li_temp
String  ls_sql_stmt_upper, ls_sql_state, ls_group, &
			ls_before_where, ls_after_where, ls_where_clause, ls_order, &
			ls_before_group, ls_before_order

// find where clause
ls_sql_stmt_upper = upper(as_sql_stmt)


li_where = 0
li_temp = 1
DO WHILE True   // append by csh for except subquery
	li_temp = PosA(ls_sql_stmt_upper, " WHERE" , li_temp )
	if li_temp = 0 then exit
	li_where = li_temp	
	li_where = li_temp + 1
	li_temp ++
LOOP
if li_where <> 0 then	
	ls_sql_state = 'where'
	li_temp = li_where
Else
	li_temp = 1
End If	


// find group by

DO WHILE TRUE // APPEND BY CSH
	li_temp = PosA(ls_sql_stmt_upper, "GROUP BY", li_temp )
	if li_temp = 0 then exit
	li_group	  = li_temp
	li_temp ++
LOOP	
	
if li_group <> 0 then	
	ls_sql_state = ls_sql_state + 'group'
	li_temp = li_group
Else
	li_temp = 1
End If	

// find order by
DO WHILE TRUE // APPEND BY CSH
	li_temp = PosA(ls_sql_stmt_upper, "ORDER BY" , li_temp )
	if li_temp = 0 then exit	
	li_order  = li_temp
	li_temp ++
LOOP	
if li_order <> 0 then	ls_sql_state = ls_sql_state + 'order'

// get the total length of the sql stmt
li_sql_len = LenA(as_sql_stmt)

// depending on ls_sql_state, construct the proper SQL stmt
CHOOSE CASE ls_sql_state
		CASE ''
			 return (as_sql_stmt + 	" where " + & 
						is_where)				

		CASE 'where'
				ls_before_where = LeftA(as_sql_stmt, li_where - 1)
				ls_after_where = RightA(as_sql_stmt, li_sql_len - li_where - 4)
				return(ls_before_where + &
						" where (" + &
						ls_after_where + ") and " + &
						is_where)				
	
		CASE 'wheregrouporder', 'wheregroup'
				ls_before_where = LeftA(as_sql_stmt, li_where - 1)
				ls_after_where = RightA(as_sql_stmt, li_sql_len - li_where - 4)
				ls_where_clause = LeftA(ls_after_where, PosA(ls_after_where, "GROUP BY") - 1)
				ls_group = RightA(as_sql_stmt,li_sql_len - li_group + 1)
				return(ls_before_where + &
						" where (" + &
						ls_where_clause + ") and " + & 
						is_where + &
						ls_group)				
	
		CASE 'whereorder'
				ls_before_where = LeftA(as_sql_stmt, li_where - 1)
				ls_after_where = RightA(as_sql_stmt, li_sql_len - li_where - 4)
				ls_where_clause = LeftA(ls_after_where, PosA(ls_after_where, "ORDER BY") - 1)
				ls_order = RightA(as_sql_stmt,li_sql_len - li_order + 1)
				return(ls_before_where + &
						" where (" + &
						ls_where_clause + ") and " + & 
						is_where + &
						ls_order)				

		CASE 'group' , 'grouporder'
				ls_before_group = LeftA(as_sql_stmt, li_group - 1)
				ls_group = RightA(as_sql_stmt,li_sql_len - li_group + 1)

				return(ls_before_group + " where " + &
							is_where + &
							ls_group)				

		CASE 'order'
				ls_before_order = LeftA(as_sql_stmt, li_order - 1)
				ls_order = RightA(as_sql_stmt, li_sql_len - li_order + 1)

				return(ls_before_order + " where " + &
							is_where + &
							ls_order)				
END CHOOSE


end function

event constructor;//If IsNull(itrans_connect) Then
	SetTransObject(SQLCA)
	f_modify_dw_title(this)
	
//Else
//	SetTransObject(itrans_connect)
//End If

end event

event sqlpreview;String  ls_upper_sqlsyntax, ls_before_union, ls_after_union, ls_where
Integer li_union, li_sql_len

If is_where = "" Then Return

ls_upper_sqlsyntax = Upper(sqlsyntax)
li_sql_len = LenA(sqlsyntax)

li_union = PosA(ls_upper_sqlsyntax, "UNION ")
if li_union <> 0 then
	ls_before_union = LeftA(sqlsyntax, li_union - 1)
	ls_after_union = RightA(sqlsyntax, li_sql_len - li_union - 4)
	ls_where = ufs_where(ls_before_union) + " union " + &
	 ufs_where(ls_after_union) 
Else
	ls_where = ufs_where(sqlsyntax)
End If

SetSQLPreview(ls_where)
sqlsyntax = ls_where

is_where = ""

end event

on u_d_base.create
end on

on u_d_base.destroy
end on

