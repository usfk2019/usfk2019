$PBExportHeader$ssrt_hlp_other_sales.srw
$PBExportComments$[1hera] Help : Other Sales
forward
global type ssrt_hlp_other_sales from w_a_hlp
end type
end forward

global type ssrt_hlp_other_sales from w_a_hlp
integer width = 2350
integer height = 1032
end type
global ssrt_hlp_other_sales ssrt_hlp_other_sales

on ssrt_hlp_other_sales.create
call super::create
end on

on ssrt_hlp_other_sales.destroy
call super::destroy
end on

event ue_find();call super::ue_find;//String 	ls_where
//String 	ls_value, 	ls_name, 	ls_status, 	ls_ctype
//Long 		ll_row
//
//ls_value 	= Trim(dw_cond.object.value[1])
//ls_name 		= Trim(dw_cond.object.name[1])
//ls_status 	= Trim(dw_cond.object.status[1])
//ls_ctype 	= Trim(dw_cond.object.ctype[1])
//If IsNull(ls_value) 		Then ls_value 	= ""
//If IsNull(ls_name) 		Then ls_name 	= ""
//If IsNull(ls_status) 	Then ls_status = ""
//If IsNull(ls_ctype) 		Then ls_ctype 	= ""
//
//If (ls_value = ""  Or ls_name = "" ) And ls_status = "" And ls_ctype = "" Then
//		f_msg_info(200, Title, "최소한 하나이상의 조건항목을 입력하십시오.")
//		dw_cond.SetFocus()
//		dw_cond.setColumn("value")
//		Return 
//	End If
//
//
//ls_where = ""
//
//If ls_value <> "" Then
//		If ls_where <> "" Then ls_where += " And "
//		Choose Case ls_value
//			Case "memberid"
//				ls_where += "memberid like '" + ls_name + "%' "
//			Case "customernm"
//				ls_where += "Upper(customernm) like '%" + Upper(ls_name) + "%' "
//			Case "payid"
//				ls_where += "payid like '" + ls_name + "%' "
//			Case "logid"
//				ls_where += "Upper(logid) like '%" + Upper(ls_name) + "%' "
//			Case "ssno"
//				ls_where += "SOCIALSECURITY like '" + ls_name + "%' "
//			Case "corpnm"
//				ls_where += "Upper(corpnm) like '%" + Upper(ls_name) + "%' "
//			Case "phone1"
//				ls_where += "homephone like '" + ls_name + "%' "
//			Case "email"
//				ls_where += "Upper(EMAIL1) like '%" + Upper(ls_name) + "%' "
//		End Choose		
//	End If
//
//If ls_status <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "status = '" + ls_status + "'"
//End If
//
//If ls_ctype <> "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "ctype1 = '" + ls_ctype + "'"
//End If
//
//
//dw_hlp.is_where = ls_where
//ll_row = dw_hlp.Retrieve()
//
//If ll_row = 0 Then
//	f_msg_info(1000, Title, "")
//ElseIf ll_row < 0 Then
//	f_msg_usr_err(2100, Title, "Retrieve()")
//	Return
//End If
end event

event open;call super::open;Integer 				li_exist
String				ls_filter, ls_svccod
DataWindowChild 	ldc_priceplan, 	ldc_itemcod


ls_svccod = 'SSRT'

dw_cond.Object.svccod[1] = ls_svccod
li_exist 	= dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
ls_filter = "svccod = '" + ls_svccod  + "'"

ldc_priceplan.SetTransObject(SQLCA)
li_exist =ldc_priceplan.Retrieve()
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()

li_exist 	= dw_cond.GetChild("itemcod", ldc_itemcod)		//DDDW 구함

ls_filter 	= "priceplan = '" + 'P999'  + "' " 

ldc_itemcod.SetTransObject(SQLCA)
li_exist =ldc_itemcod.Retrieve()
ldc_itemcod.SetFilter(ls_filter)			//Filter정함
ldc_itemcod.Filter()
		

end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
Close(This)


end event

event ue_extra_ok_with_return(long al_selrow, ref integer ai_return);iu_cust_help.ib_data[1] = True

iu_cust_help.is_data[1] = Trim(dw_hlp.Object.svccod[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.priceplan[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.itemcod[al_selrow])

end event

type p_1 from w_a_hlp`p_1 within ssrt_hlp_other_sales
boolean visible = false
integer x = 2011
integer y = 52
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ssrt_hlp_other_sales
integer x = 41
integer y = 44
integer width = 1847
integer height = 700
string dataobject = "ssrt_cnd_reg_other_pop"
end type

event dw_cond::itemchanged;call super::itemchanged;DEC{2} 				ldc_saleamt
Integer 				li_exist
String				ls_filter
Long					ll_qty
DataWindowChild 	ldc_priceplan, 	ldc_itemcod

choose case dwo.name
	Case "svccod"
			this.Object.priceplan[row] 	= ''
			this.Object.itemcod[row]	 = ''
			li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			ls_filter = "svccod = '" + data  + "' " 

			ldc_priceplan.SetTransObject(SQLCA)
			li_exist =ldc_priceplan.Retrieve()
			ldc_priceplan.SetFilter(ls_filter)			//Filter정함
			ldc_priceplan.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
	Case "priceplan"
			this.Object.itemcod[row] = ''
		
			li_exist 	= This.GetChild("itemcod", ldc_itemcod)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Item code")
			ls_filter = "priceplan = '" + data  + "' " 

			ldc_itemcod.SetTransObject(SQLCA)
			li_exist =ldc_itemcod.Retrieve()
			ldc_itemcod.SetFilter(ls_filter)			//Filter정함
			ldc_itemcod.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
end choose

end event

type p_ok from w_a_hlp`p_ok within ssrt_hlp_other_sales
integer x = 2011
integer y = 168
boolean originalsize = false
end type

type p_close from w_a_hlp`p_close within ssrt_hlp_other_sales
integer x = 2011
integer y = 284
end type

type gb_cond from w_a_hlp`gb_cond within ssrt_hlp_other_sales
integer x = 14
integer width = 1947
integer height = 800
end type

type dw_hlp from w_a_hlp`dw_hlp within ssrt_hlp_other_sales
boolean visible = false
integer x = 18
integer y = 852
integer width = 1975
integer height = 48
boolean enabled = false
string dataobject = "ssrt_hlp_memberm_sams"
boolean hscrollbar = true
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort
ldwo_sort = This.Object.memberid_t
uf_init(ldwo_sort)
end event

