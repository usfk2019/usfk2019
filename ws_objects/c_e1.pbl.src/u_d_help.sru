$PBExportHeader$u_d_help.sru
$PBExportComments$dw Help( from u_d_base )
forward
global type u_d_help from u_d_base
end type
end forward

global type u_d_help from u_d_base
event ue_init ( )
end type
global u_d_help u_d_help

type variables
//Help Column's number
Int ii_help_col_no

//Help Window Name
String is_help_win[]

//Help column's DWObject
DWObject idwo_help_col[]

//Help column's color
Long il_help_col_color = Rgb( 255, 0, 0 )

//Help column's Icon
String is_help_cur = "help!"

// Optional Data
String is_data[], is_data_nm[], is_temp[]
String is_data2[], is_data3[] , is_data4[]

// User Object
u_cust_a_msg iu_cust_help

String is_old, is_new //구,신자료

end variables

event doubleclicked;Int li_i
String ls_type, ls_name
Window lw_help

iu_cust_help.il_data[1] = row  // clicked row  , value using at w_a_hlp.il_clicked_row

//kenn : 1999-05-25 Modify *******************
//DW내의 button일 경우를 고려(Column만 Help)
ls_name = dwo.Name
If LeftA(Upper(ls_name), 2) = "B_" Then Return
ls_type = dwo.Type
If ls_type <> "column" Then Return
//*********************************************

For li_i = 1 To ii_help_col_no
	If idwo_help_col[li_i].Name = ls_name Then
		iu_cust_help.idw_data[1] = this

		If UpperBound( is_data ) = 0 Then
			iu_cust_help.is_data[1]='' 
		Else			
			iu_cust_help.is_data[] = is_data[]
		End If
	
		iu_cust_help.is_temp[] = is_temp[]	
		
		OpenwithParm(lw_help, iu_cust_help, is_help_win[li_i]  )
//		is_data[] = iu_cust_help.is_data[]   Absolutely not use for closewithReturn
//		is_data2[] = iu_cust_help.is_data2[]
//		is_data3[] = iu_cust_help.is_data3[]		
//		is_data4[] = iu_cust_help.is_data3[]		
//		
//		is_data_nm[] = iu_cust_help.is_data_nm[]

		Exit
	End If
Next


end event

event constructor;call super::constructor;Int li_i
iu_cust_help = create u_cust_a_msg
//iu_cust_help.ib_data[1] = False

Trigger Event ue_init()  // append by csh

//*****DataWindow의 Help Row의 색깔 및 Pointer 처리
ii_help_col_no = UpperBound(is_help_win)
For li_i = 1 To ii_help_col_no
//	idwo_help_col[li_i].Color = il_help_col_color
	idwo_help_col[li_i].Pointer = is_help_cur
Next
end event

event destructor;call super::destructor;destroy iu_cust_help
end event

event itemchanged;Long ll_row,ll_col,ll_cell
String ls_coltype
Dec lc_temp

ll_row = This.GetRow()
ll_col = This.GetColumn()

is_old = String(This.Object.Data[ll_row, ll_col])
This.accepttext()
is_new = String(This.Object.Data[ll_row, ll_col])

If ll_row > 0 And ll_col > 0 Then
	ls_coltype = This.Describe("#" + String(ll_col) + ".coltype")
   Choose Case LeftA(Trim(ls_coltype), 7)
		CASE "decimal"		//decimal	
			lc_temp = This.Object.Data[ll_row,ll_col]
			If Isnull(lc_temp) Then
		    	This.Object.Data[ll_row, ll_col] = 0
				Return 2
			End if	
	End Choose
End If


end event

on u_d_help.create
end on

on u_d_help.destroy
end on

