$PBExportHeader$b1w_inq_comments.srw
$PBExportComments$[islim] table print
forward
global type b1w_inq_comments from w_a_inq_m_m
end type
type lv_table from listview within b1w_inq_comments
end type
type lv_column from listview within b1w_inq_comments
end type
type st_1 from statictext within b1w_inq_comments
end type
type p_reset from u_p_reset within b1w_inq_comments
end type
type p_where from u_p_where within b1w_inq_comments
end type
type p_query from u_p_query within b1w_inq_comments
end type
type mle_create from multilineedit within b1w_inq_comments
end type
type dw_1 from u_d_sgl_sel within b1w_inq_comments
end type
type st_column from statictext within b1w_inq_comments
end type
type st_join from statictext within b1w_inq_comments
end type
type lv_column_where from listview within b1w_inq_comments
end type
type st_where from statictext within b1w_inq_comments
end type
type st_print from statictext within b1w_inq_comments
end type
type p_1 from u_p_saveas within b1w_inq_comments
end type
end forward

global type b1w_inq_comments from w_a_inq_m_m
integer width = 5202
integer height = 2380
event ue_query ( )
event ue_where ( )
event ue_reset ( )
event ue_saveas ( )
lv_table lv_table
lv_column lv_column
st_1 st_1
p_reset p_reset
p_where p_where
p_query p_query
mle_create mle_create
dw_1 dw_1
st_column st_column
st_join st_join
lv_column_where lv_column_where
st_where st_where
st_print st_print
p_1 p_1
end type
global b1w_inq_comments b1w_inq_comments

type variables
datastore ids_lv_column
datastore ids_lv_table
datastore ids_lv_column_where
end variables

forward prototypes
public subroutine wf_set_listview_title_table ()
public subroutine wf_set_listview_title_column ()
public subroutine wf_set_listview_title_column_where ()
public subroutine of_resizepanels ()
public function boolean wf_set_listview_table ()
public function boolean wf_set_listview_column (string data)
public function boolean wf_set_listview_column_where (string as_table, string as_column)
public subroutine gf_multi_select (datawindow a_dw)
public function boolean wf_del_listview_column (string data)
end prototypes

event ue_query();Long ll_row
int i
string ls_a , ls_join
string error_syntaxfromSQL, error_create
string new_sql, new_syntax
integer li_count, li_index, li_flag, li_flag_col, j, li_count_col
string ls_table, ls_tables, ls_column, ls_columns
string ls_where
String ls_column_where, ls_check, ls_table_column, ls_group, ls_order, ls_w2, ls_w1, ls_andor
String ls_group_1, ls_group_2, ls_group_3
String ls_error_message
listviewitem llvi_table, llvi_column


ll_row=dw_master.rowcount()
li_flag=0
ls_a = ""
for i=1 to ll_row
	dw_master.AcceptText()
	ls_join= dw_master.object.t_join[i]
	
	if ls_join = "=" then
 		If li_flag<>0 then
   		ls_a += " AND "
		End If

	    ls_a += dw_master.object.user_col_comments_table_name[i]
		 ls_a += "."
		 ls_a += dw_master.object.user_col_comments_column_name[i]
		 ls_a += dw_master.object.t_join[i]
		 ls_a += dw_master.object.user_col_comments_table_name_1[i]
		 ls_a += "."
		 ls_a += dw_master.object.user_col_comments_column_name_1[i]

       li_flag =1
		
	End if
	
Next



//dw_1   
ll_row=dw_1.rowcount()
li_flag=0
for i=1 to ll_row
	dw_1.AcceptText()
	ls_check= dw_1.object.w_check[i]
	
	if ls_check = "1" then

		 ls_group = dw_1.object.w_group[i]
		  
		 Choose Case ls_group
			Case "1"
				 If ls_group_1 <>"" Then
      			 ls_group_1 += "  And  "
				 End If
				 ls_group_1 += dw_1.object.table_name[i]
				 ls_group_1 += "."
				 ls_group_1 += dw_1.object.column_name[i]
				 ls_group_1 += " "
				 ls_group_1 += dw_1.object.w_1[i]
				 ls_group_1 += " "				 
				 ls_group_1 += dw_1.object.w_2[i]
				 ls_group_1 += " "				 
//				 ls_group_1 += dw_1.object.w_a_o[i]
// 				 ls_group_1 += " "
				  
			Case "2"
				 If ls_group_2 <> "" Then
				    ls_group_2 += "  And  "
             End If
				 ls_group_2 += dw_1.object.table_name[i]
				 ls_group_2 += "."
				 ls_group_2 += dw_1.object.column_name[i]
				 ls_group_2 += " "
				 ls_group_2 += dw_1.object.w_1[i]
				 ls_group_2 += " "				 
				 ls_group_2 += dw_1.object.w_2[i]
				 ls_group_2 += " "				 
//				 ls_group_2 += dw_1.object.w_a_o[i]
// 				 ls_group_2 += " "				

			Case "3"
				 If ls_group_3 <> "" Then
				    ls_group_3 += "  And  "
				 End If
				 ls_group_3 += dw_1.object.table_name[i]
				 ls_group_3 += "."
				 ls_group_3 += dw_1.object.column_name[i]
				 ls_group_3 += " "
				 ls_group_3 += dw_1.object.w_1[i]
				 ls_group_3 += " "				 
				 ls_group_3 += dw_1.object.w_2[i]
				 ls_group_3 += " "				 
//				 ls_group_3 += dw_1.object.w_a_o[i]
// 				 ls_group_3 += " "				

		End Choose

	End If
	
Next

// messagebox("그룹1",ls_group_1)
// messagebox("그룹2",ls_group_2)
// messagebox("그룹3",ls_group_3)



li_count=lv_table.totalitems()
li_count_col = lv_column.totalitems()

li_flag=0
li_flag_col=0


for i=1 to li_count
	
	lv_table.GetItem(i, llvi_table)

	If llvi_table.statepictureindex = 2 then
		If li_flag<>0 then
   		ls_tables += ","
		End If
		
		lv_table.setitem(i, llvi_table)
		ls_table = String(llvi_table.data)	
		ls_tables += ls_table
		//messagebox("ls_table", ls_tables)
		li_flag =1
	end if

Next

//messagebox("ls_table", ls_tables)

for j=1 to li_count_col
	
	lv_column.GetItem(j, llvi_column)
	If llvi_column.statepictureindex = 2 then
		
		If li_flag_col<>0 then
			ls_columns =  ls_columns + ","
		End If

		lv_column.setitem(j, llvi_column)
		ls_column = String(llvi_column.data)	
		ls_columns += ls_column
	//	messagebox("ls_table", ls_columns)
		li_flag_col = 1
	end if

Next


//messagebox("ls_column", ls_columns)



new_sql = 'SELECT '+ ls_columns + ' ' &
			+ 'FROM ' + ls_tables +' ' &
			

If ls_a <> "" Then			//조인조건이 있으면
	new_sql += 'where ' + ls_a +' '
	
	If ls_group_1 <> "" Then
		new_sql += "  And "
		new_sql += ls_group_1
	End If
	If ls_group_2 <> "" Then
		new_sql += ' Or  ' + ls_group_2
	End If
	If ls_group_3 <> "" Then
		new_sql += ' Or  ' + ls_group_3
	End If
	
ElseIf ls_a = ""  and ls_group_1 <>"" Then	  //조인조건이 없으면
	new_sql += 'where '
	If ls_group_1 <> "" Then
		new_sql += ls_group_1
	End If
	If ls_group_2 <> "" Then
		new_sql += ' Or  ' + ls_group_2
	End If
   If ls_group_3 <> "" Then
		new_sql += ' Or  ' + ls_group_3
	End If
	
End If

			
			
			
//messagebox("조회sql", new_sql)
			
new_syntax = SQLCA.SyntaxFromSQL(new_sql, &
		'Style(Type=Grid)', error_syntaxfromSQL)

IF LenA(error_syntaxfromSQL) > 0 THEN
		// Display errors
		ls_error_message = error_syntaxfromSQL
		f_msg_usr_err(2100, Title, "Retrieve()")
ELSE
		// Generate new DataWindow
		dw_detail.Create(new_syntax, error_create)
		IF LenA(error_create) > 0 THEN
			mle_create.Text = error_create

		END IF
END IF

dw_detail.SetTransObject(SQLCA)
dw_detail.Retrieve()
end event

event ue_where();
string error_syntaxfromSQL, error_create

string new_sql, new_syntax

integer li_count, li_index,i , li_flag, li_flag_col, j, li_count_col , li_result
string ls_table, ls_tables, ls_column, ls_columns, new_sql_2
string ls_where
long ll_row, ll_row2
listviewitem llvi_table, llvi_column



li_count=lv_table.totalitems()
li_count_col = lv_column.totalitems()

If li_count_col < 0 Then
   f_msg_usr_err(200, Title, "선택된 컬럼이 없습니다.")
	return
End If

li_flag=0
li_flag_col=0


for i=1 to li_count
	
	lv_table.GetItem(i, llvi_table)

	If llvi_table.statepictureindex = 2 then
		If li_flag<>0 then
   		ls_tables += ","
		End If
		
		lv_table.setitem(i, llvi_table)
		ls_table = String(llvi_table.data)	
		ls_tables += "'" +ls_table +"'"
		//messagebox("ls_table", ls_tables)
		li_flag =1
	end if

Next

//messagebox("ls_table", ls_tables)

for j=1 to li_count_col
	
	lv_column.GetItem(j, llvi_column)
	If llvi_column.statepictureindex = 2 then
		
		If li_flag_col<>0 then
			ls_columns =  ls_columns + ","
		End If

		lv_column.setitem(j, llvi_column)
		ls_column = String(llvi_column.data)	
		ls_columns += ls_column
		//messagebox("ls_table", ls_columns)
		li_flag_col = 1
	end if

Next


new_sql ='select a.table_name, a.column_name, a.comments, b.table_name,b.column_name, b.comments, ' &
+ "' '"+ '  t_join ' &
+'from (select table_name, column_name, comments from user_col_comments where table_name in('+ ls_tables + ')) a, ' &
+'(select table_name, column_name, comments from user_col_comments where table_name in('+ ls_tables + ')) b ' &
+' where a.column_name = b.column_name and a.table_name <> b.table_name'


new_sql_2 ='select table_name, column_name, comments, '+"'     '"+' w_1, ' &
          +"'                                                 '"+'  w_2, '+"'       '"+'  w_a_o , '+"'      '" &
			 +' w_group,'+"'      '" +' w_check ' &
          +' from user_col_comments where table_name in('+ ls_tables + ')'
			 
//new_syntax = SQLCA.SyntaxFromSQL(new_sql, &
//		"", error_syntaxfromSQL)
//
//IF Len(error_syntaxfromSQL) > 0 THEN
//		// Display errors
//		mle_sfs.Text = error_syntaxfromSQL
//ELSE
//		// Generate new DataWindow
//		dw_master.Create(new_syntax, error_create)
//		IF Len(error_create) > 0 THEN
//			mle_create.Text = error_create
//
//		END IF
//END IF
//

//new_sql_2 = "  table_name in (" + ls_tables + ") "
ls_where =""
ls_where = "  table_name in (" + ls_tables + ") "
//dw_master.SetTransObject(SQLCA)
//ll_row = dw_master.Retrieve()

//clipboard(new_sql_2)
//IF dw_master.Retrieve() = 0 THEN
		dw_master.SetSQLSelect(new_sql)
		ll_row = dw_master.Retrieve()
//END IF
		//messagebox("new_sql_2", new_sql_2)
		
//      dw_1.SetTransObject(SQLCA)
//	   dw_1.SetSQLSelect(new_sql_2)
//		ll_row=dw_1.Retrieve(ls_tables)
//      dw_1.is_where = new_sql_2
      dw_1.is_where = ls_where

		ll_row = dw_1.Retrieve()

return

end event

event ue_reset();String ls_ref_desc, ls_temp
String new_syntax, error_create
Int li_rc, li_ret

listviewitem llvi_table
listview llv_table
String ls_table




dw_detail.AcceptText()

//If dw_detail.ModifiedCount() > 0 or &
//	dw_detail.DeletedCount() > 0 or &
//	dw_detail2.ModifiedCount() > 0 or &
//	dw_detail2.DeletedCount() > 0 then
//	
//	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
//	CHOOSE CASE li_ret
//		CASE 1
//			li_ret = -1 
//			li_ret = Event ue_save()
//			If Isnull( li_ret ) or li_ret < 0 then return
//		CASE 2
//
//		CASE ELSE
//			Return 
//	END CHOOSE
//		
//end If
//
//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
//p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_where.TriggerEvent("ue_disable")
p_query.TriggerEvent("ue_disable")

dw_detail.Reset()
//dw_detail2.Reset()
dw_master.Reset()
dw_1.Reset()


//dw_cond.Enabled = True
//dw_cond.Reset()
//dw_cond.InsertRow(0)
//dw_cond.SetFocus()
//
//ii_error_chk = 0
//
//dw_cond.object.priceplan.Protect = 1
//dw_cond.object.prmtype.Protect = 1
//dw_cond.object.svccod.Protect = 1
//
//dw_cond.object.orderdt[1] = Date(fdt_get_dbserver_now())
//dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
//dw_cond.object.partner[1] = gs_user_group
//dw_cond.object.reg_partner[1] = gs_user_group
//dw_cond.object.sale_partner[1] = gs_user_group
//dw_cond.object.reg_partnernm[1] = gs_user_group
//dw_cond.object.sale_partnernm[1] = gs_user_group
//dw_cond.object.maintain_partner[1] = gs_user_group
//dw_cond.object.maintain_partnernm[1] = gs_user_group
//dw_cond.object.priority[1] = '0'
//dw_cond.object.langtype[1] = is_langtype
//
//is_validkey_yn= 'N'
//il_validkey_cnt = 0
//is_xener_svc = 'N'
//
//dw_cond.object.gkid[1] = is_gkid
//
//il_orderno = 0

//SetRedraw(False)

//dw_detail.Enabled = False
//dw_detail.visible = False
//st_horizontal.Visible = False
//
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)
		// Generate new DataWindow
		dw_detail.Create(new_syntax, error_create)
		IF LenA(error_create) > 0 THEN
			mle_create.Text = error_create

		END IF
		
	

wf_set_listview_title_table()
lv_column.Deleteitems()
wf_set_listview_title_column()
//llvi_table.StatePictureIndex = 1  //unchecked
end event

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel! , True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

public subroutine wf_set_listview_title_table ();integer i

//Delete all existing columns from the listview

For i=1 To 2
	lv_table.DeleteColumn(1)
Next

//Add the Columns to the Listview

lv_table.AddColumn("comments", Left!, 600)
lv_table.AddColumn("table", Left!, 600)



If wf_set_listview_table() = False Then Return


end subroutine

public subroutine wf_set_listview_title_column ();integer i

//Delete all existing columns from the listview

For i=1 To 3
	lv_column.DeleteColumn(1)
Next

//Add the Columns to the Listview

lv_column.AddColumn("comments", Left!, 500)
lv_column.AddColumn("column", Left!, 400)
lv_column.AddColumn("table", Left!, 500)


//If wf_set_listview_column() = False Then Return




end subroutine

public subroutine wf_set_listview_title_column_where ();integer i

//Delete all existing columns from the listview

For i=1 To 3
	lv_column_where.DeleteColumn(1)
Next

//Add the Columns to the Listview

//lv_column_where.AddColumn("comments", Left!, 500)
lv_column_where.AddColumn("table.column", Left!, 500)
lv_column_where.AddColumn("조건1", Center!,100)
lv_column_where.AddColumn("조건2", Center!,200)
lv_column_where.Addcolumn("조건3", Center!,100)
lv_column_where.AddColumn("그룹",Left!,100)
lv_column_where.AddColumn("순서",Left!,100)



//If wf_set_listview_column() = False Then Return
end subroutine

public subroutine of_resizepanels ();//dw_master.width =2350
//dw_1.width =2350
//lv_column.height = 1980
//lv_table.height = 1980

end subroutine

public function boolean wf_set_listview_table ();int i, li_rowcount
listviewitem llvi
String ls_comments, ls_table

lv_table.DeleteItems()

//Retrieve
li_rowcount = ids_lv_table.Retrieve()
If li_rowcount< 0 Then Return False


For i = 1 To li_rowcount
	
	ls_comments = ids_lv_table.Object.comments[i]
//	ls_column = ids_lv_column.Object.column_name[i]
	ls_table = ids_lv_table.Object.table_name[i]
	
	llvi.Label = ls_comments + "~t" +&
					 ls_table 
					 
	llvi.Data =  ls_table 
					 
   llvi.statepictureindex = 1

	
	If lv_table.AddItem(llvi) < 1 then
		f_msg_info(9000, This.Title, "Error adding item to the ListView")
		Return False
	End If
	
Next

Return True



end function

public function boolean wf_set_listview_column (string data);int i, li_rowcount
listviewitem llvi
String ls_comments, ls_column, ls_table


//Retrieve
li_rowcount = ids_lv_column.Retrieve(data)
If li_rowcount< 0 Then Return False


For i = 1 To li_rowcount
	
	ls_comments = ids_lv_column.Object.comments[i]
	ls_column = ids_lv_column.Object.column_name[i]
	ls_table = ids_lv_column.Object.table_name[i]
	
	llvi.Label = ls_comments + "~t" +&
					 ls_column + "~t" +&
					 ls_table 
					 
	llvi.Data =  ls_table+ "." +&
					 ls_column 
	
					 
   llvi.statepictureindex = 1	
	
	If lv_column.AddItem(llvi) < 1 then
		f_msg_info(9000, This.Title, "Error adding item to the ListView")
		Return False
	End If
	
Next

Return True

end function

public function boolean wf_set_listview_column_where (string as_table, string as_column);int i, li_rowcount
listviewitem llvi
String ls_column, ls_table, ls_where1, ls_where2,ls_where3, ls_order, ls_group

//lv_column.DeleteItems()

//Retrieve
//li_rowcount = ids_lv_column_where.Retrieve(as_table,as_column)
If li_rowcount< 0 Then Return False


For i = 1 To li_rowcount
	
	ls_table = ids_lv_column_where.Object.table_name[i]
	ls_column = ids_lv_column_where.Object.column_name[i]
	ls_where1 = ids_lv_column_where.Object.where_1[i]
	ls_where2 = ids_lv_column_where.Object.where_2[i]
	ls_where3 = ids_lv_column_where.Object.where_3[i]	
	ls_group = ids_lv_column_where.Object.group[i]	
	ls_order = ids_lv_column_where.Object.order[i]	
	
	llvi.Label= ls_table + "." +&
					 ls_column + "~t" +&
					 ls_where1 + "~t" +&
					 ls_where2 + "~t" +&
					 ls_where3 + "~t" +&
					 ls_group + "~t" +&
					 ls_order
					 
	llvi.Data =  ls_table+ "." +&
					 ls_column + "~t" +&
					 ls_where1 + "~t" +&
					 ls_where2 + "~t" +&
					 ls_where3 + "~t" +&
					 ls_group + "~t" +&
					 ls_order
					 
	
	If lv_column_where.AddItem(llvi) < 1 then
		f_msg_info(9000, This.Title, "Error adding item to the ListView")
		Return False
	End If

Next

Return True

end function

public subroutine gf_multi_select (datawindow a_dw);long w_rownum,w_selrow,iw_rownum 
int i

w_rownum = a_dw.GetClickedRow()
w_selrow = a_dw.GetClickedRow()
iw_rownum = a_dw.GetClickedRow()


if w_rownum <= 0 then return

if keydown(keyshift!) then
	w_selrow = a_dw.GetSelectedRow(0)

	if w_selrow > 0 then
		for i = min(w_selrow,w_rownum) to max(w_selrow,w_rownum)
		a_dw.SelectRow(i,true)
		next
	else
		a_dw.SelectRow(w_rownum,true)
	end if
elseif keydown(KeyControl!) then 
	if a_dw.isSelected(w_rownum) then
		a_dw.SelectRow(w_rownum,false)
	else
		a_dw.SelectRow(w_rownum,true)
	end if
else
	if a_dw.isSelected(w_rownum) then
		a_dw.SelectRow(0,false)
	else
		a_dw.SelectRow(0,false)
		a_dw.SelectRow(w_rownum,true)
	end if
end if


end subroutine

public function boolean wf_del_listview_column (string data);int i, li_rowcount, li_index, li_totalitem, count, li_flag
listviewitem llvi
String ls_comments, ls_column, ls_table, ls_con

 
//messagebox("table unchecked",data)


li_totalitem = lv_column.totalitems()

For i = 1 To li_totalitem	
	lv_column.GetItem (i, llvi)
	
	ls_table = LeftA(String(llvi.data),PosA(String(llvi.data),".")-1)

	if String(data) = ls_table then
//		messagebox("index", String(i))
		li_index= i
		li_flag =1
		i=li_totalitem
	end if
 
next


li_totalitem = lv_column.totalitems()

for i=li_index To li_totalitem
	lv_column.GetItem (li_index, llvi)
	If li_flag =1 and data = LeftA(String(llvi.data),PosA(String(llvi.data),".")-1) Then
		lv_column.DeleteItem(li_index)
	ElseIf String(data)<>LeftA(String(llvi.data),PosA(String(llvi.data),".")-1) Then
		i = li_totalitem
	End If
Next


Return True

end function

on b1w_inq_comments.create
int iCurrent
call super::create
this.lv_table=create lv_table
this.lv_column=create lv_column
this.st_1=create st_1
this.p_reset=create p_reset
this.p_where=create p_where
this.p_query=create p_query
this.mle_create=create mle_create
this.dw_1=create dw_1
this.st_column=create st_column
this.st_join=create st_join
this.lv_column_where=create lv_column_where
this.st_where=create st_where
this.st_print=create st_print
this.p_1=create p_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.lv_table
this.Control[iCurrent+2]=this.lv_column
this.Control[iCurrent+3]=this.st_1
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.p_where
this.Control[iCurrent+6]=this.p_query
this.Control[iCurrent+7]=this.mle_create
this.Control[iCurrent+8]=this.dw_1
this.Control[iCurrent+9]=this.st_column
this.Control[iCurrent+10]=this.st_join
this.Control[iCurrent+11]=this.lv_column_where
this.Control[iCurrent+12]=this.st_where
this.Control[iCurrent+13]=this.st_print
this.Control[iCurrent+14]=this.p_1
end on

on b1w_inq_comments.destroy
call super::destroy
destroy(this.lv_table)
destroy(this.lv_column)
destroy(this.st_1)
destroy(this.p_reset)
destroy(this.p_where)
destroy(this.p_query)
destroy(this.mle_create)
destroy(this.dw_1)
destroy(this.st_column)
destroy(this.st_join)
destroy(this.lv_column_where)
destroy(this.st_where)
destroy(this.st_print)
destroy(this.p_1)
end on

event open;call super::open;//Call w_a_m_master::Open

ids_lv_table = Create DataStore
ids_lv_table.DataObject = 'b1dw_inq_table1'
ids_lv_table.SetTransObject(sqlca)

ids_lv_column = Create Datastore
ids_lv_column.DataObject = 'b1dw_inq_column2'
ids_lv_column.SetTransObject(sqlca)

//ids_lv_column_where = Create Datastore
//ids_lv_column_where.DataObject = 'b1dw_inq_column_where'
//ids_lv_column_where.SetTransObject(sqlca)

wf_set_listview_title_column()
wf_set_listview_title_table()
//wf_set_listview_title_column_where()

p_where.TriggerEvent("ue_disable")
p_query.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")










end event

event ue_ok();call super::ue_ok;//
//string error_syntaxfromSQL, error_create
//
//string new_sql, new_syntax
//
//integer li_count, li_index,i , li_flag, li_flag_col, j, li_count_col
//string ls_table, ls_tables, ls_column, ls_columns, new_sql_2
//string ls_where
//long ll_row
//listviewitem llvi_table, llvi_column
//
//
//
//li_count=lv_table.totalitems()
//li_count_col = lv_column.totalitems()
//
//li_flag=0
//li_flag_col=0
//
//
//for i=1 to li_count
//	
//	lv_table.GetItem(i, llvi_table)
//
//	If llvi_table.statepictureindex = 2 then
//		If li_flag<>0 then
//   		ls_tables += ","
//		End If
//		
//		lv_table.setitem(i, llvi_table)
//		ls_table = String(llvi_table.data)	
//		ls_tables += "'" +ls_table +"'"
//		messagebox("ls_table", ls_tables)
//		li_flag =1
//	end if
//
//Next
//
//messagebox("ls_table", ls_tables)
//
//for j=1 to li_count_col
//	
//	lv_column.GetItem(j, llvi_column)
//	If llvi_column.statepictureindex = 2 then
//		
//		If li_flag_col<>0 then
//			ls_columns =  ls_columns + ","
//		End If
//
//		lv_column.setitem(j, llvi_column)
//		ls_column = String(llvi_column.data)	
//		ls_columns += ls_column
//		messagebox("ls_table", ls_columns)
//		li_flag_col = 1
//	end if
//
//Next
//
//
//new_sql ='select a.table_name, a.column_name, a.comments, b.table_name,b.column_name, b.comments, ' &
//+ "' '"+ '  t_join ' &
//+'from (select table_name, column_name, comments from user_col_comments where table_name in('+ ls_tables + ')) a, ' &
//+'(select table_name, column_name, comments from user_col_comments where table_name in('+ ls_tables + ')) b ' &
//+' where a.column_name = b.column_name and a.table_name <> b.table_name'
//
//
//new_sql_2 ='select table_name, column_name,'+"'     '"+','+"'                                                 '"+','+"'       '"+','+" '      '"+','+"'      '"+ &
//          +' from user_col_comments where table_name in('+ ls_tables + ')'
////new_syntax = SQLCA.SyntaxFromSQL(new_sql, &
////		"", error_syntaxfromSQL)
////
////IF Len(error_syntaxfromSQL) > 0 THEN
////		// Display errors
////		mle_sfs.Text = error_syntaxfromSQL
////ELSE
////		// Generate new DataWindow
////		dw_master.Create(new_syntax, error_create)
////		IF Len(error_create) > 0 THEN
////			mle_create.Text = error_create
////
////		END IF
////END IF
////
////dw_master.SetTransObject(SQLCA)
////ll_row = dw_master.Retrieve()
//
////IF dw_master.Retrieve() = 0 THEN
//		dw_master.SetSQLSelect(new_sql)
//		ll_row=dw_master.Retrieve()
////END IF
//		dw_1.SetTransObject(SQLCA)
//		dw_1.SetSQLSelect(new_sql_2)
//		ll_row=dw_1.Retrieve()
//
////dw_master.is_where = ls_where
////ll_row = dw_master.Retrieve()
////If ll_row < 0 Then 
////	f_msg_usr_err(2100,Title, "Retrieve()")
////	Return
////ElseIf ll_row = 0 Then
////	f_msg_usr_err(1100,Title,"(Master)")
////	Return
////End If
////
//
//
////messagebox("ls_column", ls_columns)
////
//////new_sql = 'SELECT emp_data.emp_id, ' &
//////		+ 'emp_data.emp_name ' &
//////		+ 'from emp_data ' &
//////		+ 'WHERE emp_data.emp_salary>45000'
//////
////
////new_sql = 'SELECT '+ ls_columns + ' ' &
////			+ 'FROM ' + ls_tables
////			
////			
////new_syntax = SQLCA.SyntaxFromSQL(new_sql, &
////		'Style(Type=Grid)', error_syntaxfromSQL)
////
////IF Len(error_syntaxfromSQL) > 0 THEN
////		// Display errors
////		mle_sfs.Text = error_syntaxfromSQL
////ELSE
////		// Generate new DataWindow
////		dw_detail.Create(new_syntax, error_create)
////		IF Len(error_create) > 0 THEN
////			mle_create.Text = error_create
////
////		END IF
////END IF
////
////dw_detail.SetTransObject(SQLCA)
////dw_detail.Retrieve()
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//

Call w_a_m_master::resize
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < dw_detail.Y Then
	dw_detail.Height = 0
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If


If newheight < lv_column.Y Then
	lv_column.Height = 0
Else
	lv_column.Height = newheight - lv_column.Y - iu_cust_w_resize.ii_dw_button_space
End If


If newheight < lv_table.Y Then
	lv_table.Height = 0
Else
	lv_table.Height = newheight - lv_table.Y - iu_cust_w_resize.ii_dw_button_space
End If


If newwidth < dw_1.X  Then
	dw_1.Width = 0
Else
	dw_1.Width = newwidth - dw_1.X - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If
// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

type dw_cond from w_a_inq_m_m`dw_cond within b1w_inq_comments
boolean visible = false
integer x = 55
integer y = 180
integer width = 1106
integer height = 76
end type

event dw_cond::itemchanged;call super::itemchanged;Long ll_rows
String ls_where

If dwo.name = "table_comments" Then
	

	//Dynamic SQL
	ls_where = ""

	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "table_name = '"+ data +"'"

	dw_master.is_where	= ls_where

	//Retrieve
	ll_rows	= dw_master.Retrieve()
	If( ll_rows = 0 ) Then
		f_msg_info(1000, Title, "")
	ElseIf( ll_rows < 0 ) Then
		f_msg_usr_err(2100, Title, "Retrieve()")
	End If
	
	
	//If wf_set_listview(data) = False Then Return

End If
end event

type p_ok from w_a_inq_m_m`p_ok within b1w_inq_comments
boolean visible = false
integer x = 1582
integer y = 32
boolean enabled = false
end type

type p_close from w_a_inq_m_m`p_close within b1w_inq_comments
integer x = 1097
integer y = 36
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b1w_inq_comments
boolean visible = false
integer x = 50
integer y = 20
integer width = 1554
integer height = 260
integer taborder = 20
end type

type dw_master from w_a_inq_m_m`dw_master within b1w_inq_comments
integer x = 2551
integer y = 232
integer width = 2350
integer height = 668
integer taborder = 30
string dataobject = "b1d_inq_column_join"
borderstyle borderstyle = stylelowered!
end type

event dw_master::clicked;gf_multi_select(this) 

end event

type dw_detail from w_a_inq_m_m`dw_detail within b1w_inq_comments
integer x = 2551
integer y = 1888
integer width = 2350
integer height = 232
end type

type st_horizontal from w_a_inq_m_m`st_horizontal within b1w_inq_comments
integer x = 2551
integer y = 904
boolean enabled = false
end type

type lv_table from listview within b1w_inq_comments
integer x = 41
integer y = 232
integer width = 1170
integer height = 1884
integer taborder = 40
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean autoarrange = true
boolean extendedselect = true
boolean fixedlocations = true
boolean labelwrap = false
boolean hideselection = false
boolean trackselect = true
boolean oneclickactivate = true
boolean gridlines = true
boolean headerdragdrop = true
boolean fullrowselect = true
listviewview view = listviewreport!
long largepicturemaskcolor = 536870912
integer smallpicturewidth = 16
integer smallpictureheight = 16
long smallpicturemaskcolor = 536870912
string statepicturename[] = {"check_off.jpg","check_on.jpg"}
long statepicturemaskcolor = 553648127
end type

event clicked;listviewitem llvi_table
listview llv_table
String ls_table

This.GetItem(index, llvi_table)


if llvi_table.StatePictureIndex = 1 then
	llvi_table.StatePictureIndex = 2
	this.setitem(index, llvi_table)
	ls_table = String(llvi_table.data)
	If wf_set_listview_column(ls_table) = FALSE Then return

elseIf llvi_table.statepictureindex = 2 then  //checked
	llvi_table.StatePictureIndex = 1  //unchecked
	this.setitem(index, llvi_table)
	ls_table = String(llvi_table.data)	
	If wf_del_listview_column(ls_table) = FALSE Then return
end If

p_reset.TriggerEvent("ue_enable")


RETURN 0
end event

type lv_column from listview within b1w_inq_comments
integer x = 1257
integer y = 232
integer width = 1243
integer height = 1884
integer taborder = 80
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean autoarrange = true
boolean extendedselect = true
boolean fixedlocations = true
boolean hideselection = false
boolean gridlines = true
boolean fullrowselect = true
listviewview view = listviewreport!
long largepicturemaskcolor = 536870912
long smallpicturemaskcolor = 536870912
string statepicturename[] = {"check_off.jpg","check_on.jpg"}
long statepicturemaskcolor = 536870912
end type

event clicked;listviewitem llvi_column
listview llv_column
String ls_column, ls_table

This.GetItem(index, llvi_column)

If llvi_column.statepictureindex = 2 then
	llvi_column.StatePictureIndex = 1
	this.setitem(index, llvi_column)
   ls_column = String(llvi_column.data)
	ls_table = LeftA(ls_column, PosA(ls_column,".")-1)
	ls_column = MidA(ls_column, PosA(ls_column,".")+1)	
	
//	If wf_del_listview_column_where(ls_table,ls_column) = FALSE Then return
	
elseif llvi_column.StatePictureIndex = 1 then
	llvi_column.StatePictureIndex = 2
	this.setitem(index, llvi_column)
	ls_column = String(llvi_column.data)
	ls_table = LeftA(ls_column, PosA(ls_column,".")-1)
	ls_column = MidA(ls_column, PosA(ls_column,".")+1)	
   If wf_set_listview_column_where(ls_table, ls_column) = FALSE Then return
end If


p_where.TriggerEvent("ue_enable")
p_query.TriggerEvent("ue_enable")

RETURN 0


end event

type st_1 from statictext within b1w_inq_comments
integer x = 41
integer y = 164
integer width = 1170
integer height = 72
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "1) 테이블 선택"
boolean focusrectangle = false
end type

type p_reset from u_p_reset within b1w_inq_comments
integer x = 1440
integer y = 36
boolean bringtotop = true
boolean originalsize = false
end type

type p_where from u_p_where within b1w_inq_comments
integer x = 69
integer y = 36
boolean bringtotop = true
boolean originalsize = false
end type

type p_query from u_p_query within b1w_inq_comments
integer x = 411
integer y = 36
boolean bringtotop = true
boolean originalsize = false
string picturename = "query_e.gif"
end type

type mle_create from multilineedit within b1w_inq_comments
boolean visible = false
integer x = 731
integer y = 24
integer width = 480
integer height = 300
integer taborder = 90
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
string text = "none"
borderstyle borderstyle = stylelowered!
end type

type dw_1 from u_d_sgl_sel within b1w_inq_comments
integer x = 2551
integer y = 1056
integer width = 2350
integer height = 668
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_inq_column_where_2"
boolean ib_sort_use = false
end type

type st_column from statictext within b1w_inq_comments
integer x = 1266
integer y = 164
integer width = 1824
integer height = 68
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "2) 컬럼 선택( 조회할 컬럼을 선택)"
boolean focusrectangle = false
end type

type st_join from statictext within b1w_inq_comments
integer x = 2546
integer y = 164
integer width = 1440
integer height = 68
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "3) 조인 조건을 선택하세요.(빈 공간에 ~'=~' 표시하세요)"
boolean focusrectangle = false
end type

type lv_column_where from listview within b1w_inq_comments
boolean visible = false
integer x = 2382
integer y = 124
integer width = 1289
integer height = 560
integer taborder = 70
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
boolean deleteitems = true
boolean editlabels = true
boolean extendedselect = true
boolean labelwrap = false
boolean hideselection = false
boolean trackselect = true
boolean gridlines = true
boolean fullrowselect = true
listviewview view = listviewlist!
long largepicturemaskcolor = 536870912
long smallpicturemaskcolor = 536870912
long statepicturemaskcolor = 536870912
end type

event clicked;listviewitem llvi_column
listview llv_column
String ls_column

This.GetItem(index, llvi_column)
	integer li_selected

li_selected = lv_column_where.SelectedIndex()

lv_column_where.EditLabel(li_selected)

If llvi_column.statepictureindex = 2 then
	llvi_column.StatePictureIndex = 1
	this.setitem(index, llvi_column)
	ls_column = String(llvi_column.data)	
//	If wf_del_listview_column(ls_column) = FALSE Then return
	
elseif llvi_column.StatePictureIndex = 1 then
	llvi_column.StatePictureIndex = 2
	this.setitem(index, llvi_column)
	ls_column = String(llvi_column.data)
//	If wf_set_listview_column(ls_table) = FALSE Then return
end If


RETURN 0
end event

type st_where from statictext within b1w_inq_comments
integer x = 2546
integer y = 988
integer width = 2126
integer height = 68
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "4) Where 조건을 입력하세요.(빈 칸에 해당 조건을 입력하신 후 체크 표시 하세요)"
boolean focusrectangle = false
end type

type st_print from statictext within b1w_inq_comments
integer x = 2560
integer y = 1824
integer width = 2126
integer height = 68
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long backcolor = 29478337
string text = "5) 최종 Report"
boolean focusrectangle = false
end type

type p_1 from u_p_saveas within b1w_inq_comments
integer x = 754
integer y = 36
boolean bringtotop = true
boolean originalsize = false
end type

