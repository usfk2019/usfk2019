$PBExportHeader$mobile_reg_model_price.srw
$PBExportComments$모델별 가격정책 맵핑
forward
global type mobile_reg_model_price from w_a_reg_m_m
end type
type p_new from u_p_new within mobile_reg_model_price
end type
end forward

global type mobile_reg_model_price from w_a_reg_m_m
integer height = 2060
event ue_new ( )
p_new p_new
end type
global mobile_reg_model_price mobile_reg_model_price

type variables
String is_priceplan		//Price Plan Code

DataWindowChild idc_itemcod
end variables

on mobile_reg_model_price.create
int iCurrent
call super::create
this.p_new=create p_new
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_new
end on

on mobile_reg_model_price.destroy
call super::destroy
destroy(this.p_new)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	mobile_reg_model_price
	Desc.	: 	단말모델별 사용가능 가격정책 설정
	Ver.	:	1.0
	Date	: 	2015.02.09
	Programer : HMK
--------------------------------------------------------------------------*/
//p_new.TriggerEvent("ue_disable")
end event

event ue_ok;call super::ue_ok;String ls_svccod, ls_salemodelcd, ls_where,  ls_where_1
Long   ll_row, li_i

ls_svccod = Trim(dw_cond.object.svccod[1])

If IsNull(ls_svccod) Then ls_svccod = ""

If ls_svccod = "" Then
	f_msg_info(200, Title, "Service")
	dw_cond.SetFocus()
	dw_cond.SetColumn("svccod")
   Return 
End If

ls_salemodelcd = Trim(dw_cond.object.sale_modelcd[1])

if ls_salemodelcd <> "" then
		ls_where = ""
		
		If ls_where <> "" Then ls_where += " And "
		ls_where += "code = '" + ls_salemodelcd + "' "
end if


dw_master.SetRedraw(False)

dw_master.is_where = ls_where

//Retrieve
ll_row = dw_master.Retrieve()

dw_master.SetRedraw(True)
dw_master.SetFocus()
dw_master.SelectRow(0, False)
dw_master.ScrollToRow(1)
dw_master.SelectRow(1, True)
	
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
//	This.Trigger Event ue_reset()		//찾기가 없으면 reset
//	Return
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	//p_new.TriggerEvent("ue_disable")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
	
Else
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
//	p_new.TriggerEvent("ue_disable")
End If


	
end event

event ue_extra_insert;long ll_row

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("sale_modelcd")

ll_row = dw_master.getrow()
dw_detail.object.sale_modelcd[al_insert_row] = dw_master.object.code[ll_row]


//Log
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]


Return 0 


end event

event ue_extra_save;//Save Check
//Save
Long ll_row, ll_rows, ll_findrow
long ll_i, ll_zoncodcnt, i
String ls_target_code
Long   ll_rows1, ll_rows2

ll_rows = dw_detail.RowCount()

For ll_row = 1 To ll_rows
	//ls_target_code = Trim(dw_detail.Object.target_code[ll_row])

//	If IsNull(ls_target_code) Then ls_target_code = ""
	
    //필수 항목 check 
//	If ls_target_code = "" Then
//		f_msg_usr_err(200, Title, "target code")
//		dw_detail.SetColumn("target_code")
//		dw_detail.SetRow(ll_row)
//		dw_detail.ScrollToRow(ll_row)
//		dw_detail.SetRedraw(True)
//		Return -2
//		
//	End If
	

Next


For ll_rows1 = 1 To dw_detail.RowCount()

	//Update Log
	If dw_detail.GetItemStatus(ll_rows1, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_rows1] = gs_user_id
		dw_detail.object.updtdt[ll_rows1] = fdt_get_dbserver_now()
	End If
	
Next

Return 0
end event

event resize;//2000-06-28 by kem
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)


If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_new.Y	   = dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_new.Y	   = newheight - iu_cust_w_resize.ii_button_space_1
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(True)

end event

event ue_reset;call super::ue_reset;dw_cond.object.svccod[1] = ""
dw_cond.object.sale_modelcd[1] = ""
//p_new.TriggerEvent("ue_disable")

Return 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1
//Int li_return

//ii_error_chk = -1
If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	 dw_detail.ResetUpdate()
	 dw_detail.ReSet()
    This.Trigger Event ue_ok()
	 
	f_msg_info(3000,This.Title,"Save")
End if

//ii_error_chk = 0
//p_new.TriggerEvent("ue_enable")

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within mobile_reg_model_price
integer x = 46
integer y = 92
integer width = 1545
integer height = 240
string dataobject = "mobile_cnd_model_price"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;datawindowchild sale_modelcd
integer li_exist
string ls_filter






CHOOSE CASE DWO.NAME
	CASE 'svccod'
		li_exist 	= This.GetChild("sale_modelcd", sale_modelcd)		//DDDW 구함
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 판매모델명")
			ls_filter = "svccod = '" + data +"'" 

         This.object.sale_modelcd[1] = ""

			
			sale_modelcd.SetTransObject(SQLCA)
			li_exist =sale_modelcd.Retrieve()
			sale_modelcd.SetFilter(ls_filter)			//Filter정함
			sale_modelcd.Filter()
		
			If li_exist < 0 Then 				
				f_msg_usr_err(2100, Title, "Retrieve()")
		  		Return 1  		//선택 취소 focus는 그곳에
			End If  
		
END CHOOSE

end event

type p_ok from w_a_reg_m_m`p_ok within mobile_reg_model_price
integer x = 2057
integer y = 52
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within mobile_reg_model_price
integer x = 2363
integer y = 52
end type

type gb_cond from w_a_reg_m_m`gb_cond within mobile_reg_model_price
integer x = 23
integer width = 1957
integer height = 364
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within mobile_reg_model_price
integer x = 23
integer y = 392
integer height = 448
integer taborder = 30
string dataobject = "mobile_reg_model_pricemst"
boolean ib_sort_use = false
end type

event dw_master::ue_init();call super::ue_init;////Sort
//dwObject ldwo_sort
//ldwo_sort = Object.partnernm_t
//uf_init(ldwo_sort)

end event

event dw_master::rowfocuschanged;
If currentrow = 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
End If
end event

event dw_master::retrieveend;

If rowcount >= 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()

	dw_cond.Enabled = False
	p_ok.TriggerEvent("ue_disable")
	
End If
end event

event dw_master::doubleclicked;
//If row = 0 Then Return 1


end event

event dw_master::clicked;call super::clicked;

//If row = 0 Then Return 1




end event

type dw_detail from w_a_reg_m_m`dw_detail within mobile_reg_model_price
integer x = 23
integer y = 876
integer height = 900
integer taborder = 40
string dataobject = "mobile_reg_model_pricedet"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event dw_detail::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_salemodelcd, ls_filter, ls_svccod
Long ll_row, i



dw_master.AcceptText()

If dw_master.RowCount() > 0 Then
	ls_salemodelcd   = Trim(dw_master.object.code[al_select_row])

	If IsNull(ls_salemodelcd) Then ls_salemodelcd = ""

	ls_where = ""

	If ls_salemodelcd <> "" Then
		If ls_where <> "" Then ls_where += " And "
		ls_where += " SALE_MODELCD = '" + ls_salemodelcd + "' "

	End If
	
	//dw_detail 조회
	dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	dw_detail.SetRedraw(False)
	If ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return -2
	End If
	
	For i = 1 To dw_detail.RowCount()
		dw_detail.SetitemStatus(i, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
	Next
   
	dw_detail.SetRedraw(true)

End If

Return 0

end event

event dw_detail::retrieveend;Long ll_row, i
String ls_filter
Dec lc_data

If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
		
ElseIf rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.SetFocus()   		//데이터 없을경우 다시 조회 할 수있도록 
   dw_cond.Enabled = False

End If


end event

event dw_detail::clicked;//DataWindowChild 	ldc_priceplan
//Integer li_exist
//string ls_svccod, ls_filter
//
//
//if row <= 0 then return
//
////가격정책 DDDW
//ls_svccod = dw_cond.object.svccod[1]
//
//
//li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
//If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
//ls_filter = "svccod = '" + ls_svccod  + "' " 
////messagebox(ls_svccod, ls_filter)
//
//
//This.object.priceplan[1] = ""
//ldc_priceplan.SetTransObject(SQLCA)
//li_exist = ldc_priceplan.Retrieve()
//ldc_priceplan.SetFilter(ls_filter)			//Filter정함
//ldc_priceplan.Filter()
////가격정책 DDDW
//
//
end event

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild 	ldc_priceplan
Integer li_exist
string ls_svccod, ls_filter


if row <= 0 then return

//가격정책 DDDW
ls_svccod = dw_cond.object.svccod[1]


li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
ls_filter = "svccod = '" + ls_svccod  + "' " 

ldc_priceplan.SetTransObject(SQLCA)
li_exist = ldc_priceplan.Retrieve()
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()
//가격정책 DDDW



end event

type p_insert from w_a_reg_m_m`p_insert within mobile_reg_model_price
integer y = 1800
end type

type p_delete from w_a_reg_m_m`p_delete within mobile_reg_model_price
integer y = 1800
end type

type p_save from w_a_reg_m_m`p_save within mobile_reg_model_price
integer x = 617
integer y = 1800
end type

type p_reset from w_a_reg_m_m`p_reset within mobile_reg_model_price
integer x = 1353
integer y = 1800
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within mobile_reg_model_price
integer x = 23
integer y = 840
integer height = 36
end type

type p_new from u_p_new within mobile_reg_model_price
boolean visible = false
integer x = 910
integer y = 1660
integer width = 283
integer height = 96
boolean bringtotop = true
boolean originalsize = false
end type

