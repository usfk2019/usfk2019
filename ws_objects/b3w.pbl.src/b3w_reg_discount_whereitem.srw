$PBExportHeader$b3w_reg_discount_whereitem.srw
$PBExportComments$할인조건항목등록 By 변유신
forward
global type b3w_reg_discount_whereitem from w_a_reg_m
end type
end forward

global type b3w_reg_discount_whereitem from w_a_reg_m
integer height = 1884
end type
global b3w_reg_discount_whereitem b3w_reg_discount_whereitem

on b3w_reg_discount_whereitem.create
call super::create
end on

on b3w_reg_discount_whereitem.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b3w_reg_discount_whereitem
	Desc.	: 할인조건항목등록 
	Ver 	: 1.0
	Date	: 2002.12.28
	Progrmaer: Byun Yu Sin
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

event type integer ue_insert();p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.GetRow()+1)

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()


If This.Trigger Event ue_extra_insert(ll_row) < 0 Then
	Return LI_ERROR
End if

Return 0

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_cditem, ls_nmitem, ls_table, ls_column

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장시 필수입력항목 check
For ll_i = 1 To ll_row
	ls_cditem = Trim(dw_detail.Object.witem[ll_i])
	ls_nmitem = Trim(dw_detail.Object.witemnm[ll_i])	
	ls_table  = Trim(dw_detail.Object.tablenm[ll_i])
	ls_column = Trim(dw_detail.Object.columnm[ll_i])
	
	If IsNull(ls_cditem) Then ls_cditem = ""
	If IsNull(ls_nmitem) Then ls_nmitem = ""
	If IsNull(ls_table) Then ls_table = ""
	If IsNull(ls_column) Then ls_column = ""	
	
	If ls_cditem = "" Then 
		f_msg_usr_err(200, Title, "조건항목코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("witem")
		Return -1
	End If
	
	If ls_nmitem = "" Then 
		f_msg_usr_err(200, Title, "조건항목명")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("witemnm")
		Return -1
	End If
	
	If ls_table = "" Then 
		f_msg_usr_err(200, Title, "Table")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("tablenm")
		Return -1
	End If
   
	If ls_column = "" Then 
		f_msg_usr_err(200, Title, "Column")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("columnm")
		Return -1
	End If
	
	//Update 한 Log 정보
	If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
	End If
Next

Return 0
	
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

return 0

end event

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_cditem, ls_table, ls_column, ls_Sel

//조회시 상단에 입력한 내용으로 조회
ls_cditem = Trim(dw_cond.Object.cditem[1])
ls_table  = Trim(dw_cond.Object.cdtab[1])
ls_column = Trim(dw_cond.Object.cdcol[1])

If IsNull(ls_cditem) Then ls_cditem = ""
If IsNull(ls_table) Then ls_table = ""
If IsNull(ls_column) Then ls_column = ""

ls_where = ""

If ls_cditem <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " witem = '" + ls_cditem + "' "	
End If

If ls_table <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " tablenm = '" + ls_table + "' "	
End If

If ls_column <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " columnm = '" + ls_column + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If


end event

type dw_cond from w_a_reg_m`dw_cond within b3w_reg_discount_whereitem
integer y = 44
integer width = 2167
integer height = 224
string dataobject = "b3dw_cnd_discount_whereitem"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;
String ls_table,ls_column, ls_Sel, ls_addSel, ls_mod, rc, ls_dataType
DataWindowChild dw_chl

Choose Case dwo.name
	case 'cdtab'
		    ls_table = this.Object.cdtab[row]
			 
			 this.Object.cdcol[row] = ''
         
			// Table 별 Column 조회
			 this.Modify("cdcol.dddw.name = 'b3dc_dddw_column'")
			 this.Modify("cdcol.dddw.DataColumn='column_name'")
			 this.Modify("cdcol.dddw.DisplayColumn='column_name'")
			 
			 this.GetChild("cdcol",dw_chl)
			 dw_chl.SetTransObject(sqlca)
			 
			 ls_Sel = dw_chl.Describe("DataWindow.Table.Select")
			 ls_addSel = " WHERE ~~~"USER_TAB_COLUMNS~~~".~~~"TABLE_NAME~~~" = ~~'" + ls_table + "~~'"
			 
			 ls_mod = "DataWindow.Table.Select='" + ls_Sel + ls_addSel + "'"
				
		   
			 rc = dw_chl.Modify(ls_mod)
			 
			 IF rc = "" THEN
				dw_chl.Retrieve()
			 ELSE
				MessageBox("Status", "Modify Failed" + rc)
			 END IF
	  
    

end choose 
end event

type p_ok from w_a_reg_m`p_ok within b3w_reg_discount_whereitem
integer x = 2377
integer y = 60
end type

type p_close from w_a_reg_m`p_close within b3w_reg_discount_whereitem
integer x = 2679
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b3w_reg_discount_whereitem
integer x = 37
integer width = 2226
integer height = 292
end type

type p_delete from w_a_reg_m`p_delete within b3w_reg_discount_whereitem
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within b3w_reg_discount_whereitem
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within b3w_reg_discount_whereitem
integer x = 617
integer y = 1628
end type

type dw_detail from w_a_reg_m`dw_detail within b3w_reg_discount_whereitem
integer y = 304
integer height = 1264
string dataobject = "b3dw_reg_discount_whereitem"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)

//this.Modify("DataWindow.Retrieve.AsNeeded=NO")
end event

event dw_detail::itemchanged;call super::itemchanged;
String ls_table,ls_column, ls_Sel, ls_addSel, ls_mod, rc, ls_dataType
DataWindowChild dw_chl

Choose Case dwo.name
	case 'tablenm'
		    ls_table = this.Object.tablenm[row]
			 
			 this.Object.columnm[row] = ''
			 this.Object.columntype[row] = ''
         			
			// <!-- Table 별 Column 조회 -->
			// Argument 를 받는 관계로 Table 명을 받을시에 Object 를 걸어줌 
			 this.Modify("columnm.dddw.name = 'b3dc_dddw_column'")
			 this.Modify("columnm.dddw.DataColumn='column_name'")
			 this.Modify("columnm.dddw.DisplayColumn='column_name'")
			 
			 this.GetChild("columnm",dw_chl)
			 dw_chl.SetTransObject(sqlca)
			 
			 ls_Sel = dw_chl.Describe("DataWindow.Table.Select")
		
			// DataWindow 수정 
			ls_addSel = " WHERE ~~~"USER_TAB_COLUMNS~~~".~~~"TABLE_NAME~~~" = ~~'" + ls_table + "~~'"
			ls_mod = "DataWindow.Table.Select='" + ls_Sel + ls_addSel + "'"
			
			 dw_chl.Modify(ls_mod)
			 IF rc = "" THEN
				dw_chl.Retrieve()
			 ELSE
				MessageBox("Status", "Modify Failed" + rc)
			 END IF
      
	   case 'columnm'
		      
				ls_table  = this.Object.tablenm[row]
				ls_column = this.Object.columnm[row]
				
				// TABLE,COLUMN 으로 DATATYPE SETTING
				SELECT DATA_TYPE
				 into :ls_dataType
            FROM USER_TAB_COLUMNS
				where TABLE_NAME = :ls_table
    			  and COLUMN_NAME = :ls_column;
		  		    			
		    this.Object.columntype[row] = ls_dataType
			 
End Choose 
end event

event dw_detail::clicked;call super::clicked;String ls_table,ls_column, ls_Sel, ls_addSel, ls_mod, rc, ls_dataType
DataWindowChild dw_chl

Choose Case dwo.name
	case 'columnm'
		    ls_table = this.Object.tablenm[row]
			 			         			
			// <!-- Table 별 Column 조회 -->
			// Argument 를 받는 관계로 Table 명을 받을시에 Object 를 걸어줌 
			 this.Modify("columnm.dddw.name = 'b3dc_dddw_column'")
			 this.Modify("columnm.dddw.DataColumn='column_name'")
			 this.Modify("columnm.dddw.DisplayColumn='column_name'")
			 
			 this.GetChild("columnm",dw_chl)
			 dw_chl.SetTransObject(sqlca)
			 
			 ls_Sel = dw_chl.Describe("DataWindow.Table.Select")
			
			// DataWindow 수정 
			ls_addSel = " WHERE ~~~"USER_TAB_COLUMNS~~~".~~~"TABLE_NAME~~~" = ~~'" + ls_table + "~~'"
			ls_mod = "DataWindow.Table.Select='" + ls_Sel + ls_addSel + "'"
			
			 dw_chl.Modify(ls_mod)
			 IF rc = "" THEN
				dw_chl.Retrieve()
			 ELSE
				MessageBox("Status", "Modify Failed" + rc)
			 END IF
      
	   
		      
				
			 
end choose 
end event

type p_reset from w_a_reg_m`p_reset within b3w_reg_discount_whereitem
integer y = 1628
end type

