$PBExportHeader$b3w_reg_crt_discount_where.srw
$PBExportComments$정기할인조건등록 By 변유신
forward
global type b3w_reg_crt_discount_where from w_a_reg_m_m
end type
type dw_buffer from datawindow within b3w_reg_crt_discount_where
end type
end forward

global type b3w_reg_crt_discount_where from w_a_reg_m_m
integer height = 1908
dw_buffer dw_buffer
end type
global b3w_reg_crt_discount_where b3w_reg_crt_discount_where

forward prototypes
public function integer wf_valid ()
end prototypes

public function integer wf_valid ();String ls_witem
int li_RowCount, li_Count

// dw_detail Vaildation
  li_RowCount = dw_detail.Rowcount()
  
  if li_RowCount = 0 then return 0
  
  for li_Count = 1 to li_RowCount
      
		// 필수입력 Checking 
		if (isNull(dw_detail.Object.wgroup[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "조건그룹")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('wgroup')
	  	  return -1	
		end if
		
		if (isNull(dw_detail.Object.witem[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "조건항목")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('witem')
	  	  return -1	
		end if 
		
		if (isNull(dw_detail.Object.opcod[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "OPERATION")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('opcod')
	  	  return -1	
		end if
		
		if (isNull(dw_detail.Object.item_values[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "VALUE")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('item_values')
	  	  return -1	
		else
		  // 각각의 Row 의 DataType Validation
		  ls_witem = dw_detail.Object.witem[li_Count]
		  dw_buffer.Retrieve(ls_witem)
		 
		 Choose case dw_buffer.Object.columntype[1]
							
			Case 'VARCHAR2' 
				  
		   Case 'CHAR'
			
			Case 'DATE' 
				      If isDate(dw_detail.Object.item_values[li_Count]) =FALSE then 
				      	f_msg_usr_err(201, THIS.TITLE, "value Data 타입이 일치하지 않습니다.~r~n날짜 YYYY-mm-dd 형식을 입력하셔야합니다.")
	  	  					dw_detail.SetFocus()
		  					dw_detail.SetRow(li_Count)	 
	  	  					dw_detail.SetColumn('item_values')
	  	  					return -1	   
						End if
			Case 'NUMBER'
				      If isNumber(dw_detail.Object.item_values[li_Count]) =FALSE then 
				      	f_msg_usr_err(201, THIS.TITLE, "value Data 타입이 일치하지 않습니다.~r~n~t숫자 형식을 입력하셔야합니다.")
	  	  					dw_detail.SetFocus()
		  					dw_detail.SetRow(li_Count)	 
	  	  					dw_detail.SetColumn('item_values')
	  	  					return -1	   
						End if
		End Choose
	End If		
		
	//Update 한 Log 정보
	If dw_detail.GetItemStatus(li_Count, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[li_Count] = gs_user_id
		dw_detail.object.updtdt[li_Count] = fdt_get_dbserver_now()
	End If
	
Next	 
  
 Return 0
end function

on b3w_reg_crt_discount_where.create
int iCurrent
call super::create
this.dw_buffer=create dw_buffer
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_buffer
end on

on b3w_reg_crt_discount_where.destroy
call super::destroy
destroy(this.dw_buffer)
end on

event ue_ok();call super::ue_ok;
String ls_cdtype, ls_from, ls_where
Long ll_row
Date ld_from

ls_where = ""
ls_cdtype = Trim(dw_cond.object.cdtype[1])
ls_from   = string(dw_cond.Object.dtfrom[1])

If IsNull(ls_cdtype) Then ls_cdtype = ""

If ls_cdtype = "" Then
	 
   if ls_from <> "" then 
		If ls_where <> "" Then ls_where += " And "
		ls_where += " fromdt > '" + ls_from + "' "
   end if		
else 
	If ls_where <> "" Then ls_where += " And "
		ls_where += " discountplan = '" + ls_cdtype + "' "
		if ls_from <> "" then
		   ls_where += " And fromdt > '" + ls_from + "' "
		end if	
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "등록된 할인유형이 없습니다.")
	This.Trigger Event ue_reset()		//찾기가 없으면 resert
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;
String ls_code

ls_code = dw_master.Object.discountplan[dw_master.GetRow()]
dw_detail.Object.Discountplan[al_insert_row] = ls_code

//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] =gs_pgm_id[1] 

dw_detail.SetColumn("wgroup")

return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;
int li_Return 

li_Return = wf_valid()
If li_Return < 0 Then return -1

return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b3w_reg_crt_discount_where
integer x = 41
integer y = 64
integer width = 1769
integer height = 144
string dataobject = "b3dw_cnd_crt_discount_where"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within b3w_reg_crt_discount_where
integer x = 2062
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b3w_reg_crt_discount_where
integer x = 2359
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b3w_reg_crt_discount_where
integer x = 18
integer y = 8
integer width = 1929
integer height = 208
end type

type dw_master from w_a_reg_m_m`dw_master within b3w_reg_crt_discount_where
integer x = 18
integer y = 224
integer height = 672
string dataobject = "b3w_inq_reg_crt_discount_where"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.discountplan_t
uf_init(ldwo_sort)
end event

event dw_master::retrieveend;call super::retrieveend;//
//String ls_cdDis, ls_where
//Long ll_row
//
//
//ls_where = ""
//ls_cdDis = Trim(dw_master.object.discountplan[1])
//
//If IsNull(ls_cdDis) Then ls_cdDis = ""
//
//If ls_where <> "" Then ls_where += " And "
//	ls_where += "discountplan = '" + ls_cdDis + "' "
//
//dw_detail.is_where = ls_where
////dw_detail.Retrieve()


end event

type dw_detail from w_a_reg_m_m`dw_detail within b3w_reg_crt_discount_where
integer x = 18
integer y = 936
integer height = 648
string dataobject = "b3dw_reg_crt_discount_where"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;Long		ll_rows , ll_masterrow
String	ls_cdDis, ls_where

dw_master.AcceptText()		

ll_rows = dw_master.GetRow()

//ls_cdDis = Trim(dw_master.object.discountplan[ll_rows])
ls_cdDis = Trim(dw_master.object.discountplan[al_select_row])
If IsNull(ls_cdDis) Then ls_cdDis = ""

//Retrieve

	ls_where = "discountplan = '" + ls_cdDis + "' "	
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If


Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;
Choose case dwo.name
		
	case 'witem'
		      dw_buffer.Retrieve(Object.witem[row])
	end choose
end event

type p_insert from w_a_reg_m_m`p_insert within b3w_reg_crt_discount_where
integer x = 18
integer y = 1664
end type

type p_delete from w_a_reg_m_m`p_delete within b3w_reg_crt_discount_where
integer x = 311
integer y = 1664
end type

type p_save from w_a_reg_m_m`p_save within b3w_reg_crt_discount_where
integer x = 603
integer y = 1664
end type

type p_reset from w_a_reg_m_m`p_reset within b3w_reg_crt_discount_where
integer y = 1664
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b3w_reg_crt_discount_where
integer x = 14
integer y = 900
end type

type dw_buffer from datawindow within b3w_reg_crt_discount_where
boolean visible = false
integer x = 1230
integer y = 936
integer width = 1623
integer height = 404
integer taborder = 30
boolean bringtotop = true
boolean titlebar = true
string title = "dw_buffer[할인조건항목 마스터]"
string dataobject = "b3dw_buffer_discountwhereitem"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
hide()
end event

