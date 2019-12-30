$PBExportHeader$b0w_reg_itemmst_2.srw
$PBExportComments$[kem] 품목 마스터 등록(장비임대포함)
forward
global type b0w_reg_itemmst_2 from w_a_reg_m
end type
end forward

global type b0w_reg_itemmst_2 from w_a_reg_m
integer width = 3351
integer height = 1852
end type
global b0w_reg_itemmst_2 b0w_reg_itemmst_2

type variables
string is_select_cod
end variables

on b0w_reg_itemmst_2.create
call super::create
end on

on b0w_reg_itemmst_2.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_category, ls_svccod, ls_where, ls_selectcod, ls_itemnm
Long ll_row

ls_selectcod = Trim(dw_cond.object.selectcod[1])
ls_category = Trim(dw_cond.object.category[1])
ls_svccod = Trim(dw_cond.object.svccod[1])
ls_itemnm = Trim(dw_cond.object.itemnm[1])
If IsNull(ls_selectcod) Then ls_selectcod = ""
If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_itemnm) Then ls_itemnm = ""
If IsNull(ls_category) Then ls_category = ""

ls_where = ""
//분류선택(대,중,소분류)에 따라 select 조건이 다라짐
If ls_category <> "" Then
	Choose Case ls_selectcod
		Case "categoryA"
			If ls_where <> "" Then ls_where += " And "
			ls_where += "itemmst.categorya = '" + ls_category + "' "
		Case "categoryB"
			If ls_where <> "" Then ls_where += " And "
			ls_where += "categorya.categoryb = '" + ls_category + "' "
		Case "categoryC"
			If ls_where <> "" Then ls_where += " And "
			ls_where += "categoryb.categoryc = '" + ls_category + "' "
	End Choose		
End If

//서비스조건
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "itemmst.svccod = '" + ls_svccod + "' "
End If

//품목명(LIKE)
If ls_itemnm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(itemmst.itemnm) Like '%" + Upper(ls_itemnm) + "%' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_category_a, ls_category_b, ls_category_c, ls_selectcod

ls_selectcod = Trim(dw_cond.Object.selectcod[1])
ls_category_a = Trim(dw_cond.Object.category[1])
If IsNull(ls_selectcod) Then ls_selectcod = ""
If IsNull(ls_category_a) Then ls_category_a = ""

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("itemmst_itemcod")

If ls_selectcod = "categoryA" Then
	If ls_category_a <> "" Then
		
		SELECT categorya.categoryb, categoryb.categoryc 
		INTO :ls_category_b, :ls_category_c
		FROM categorya, categoryb
		WHERE categorya.categorya = :ls_category_a
		 AND categorya.categoryb = categoryb.categoryb;		
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT categoryc ")
			Return -1
		End If		
		
		dw_detail.object.itemmst_categorya[al_insert_row] = ls_category_a
		dw_detail.object.categorya_categoryb[al_insert_row] = ls_category_b
		dw_detail.object.categoryb_categoryc[al_insert_row] = ls_category_c
	End If
End If

//Log 정보
dw_detail.object.itemmst_crt_user[al_insert_row] = gs_user_id
dw_detail.object.itemmst_crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.itemmst_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.itemmst_updt_user[al_insert_row] = gs_user_id
dw_detail.object.itemmst_updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0
end event

event type integer ue_extra_save();//Save Check
String ls_item_code, ls_name, ls_categorya, ls_svcode, ls_trcode, ls_pricetable
String ls_onoff, ls_subscribed, ls_daily, ls_billing, ls_mainitem
Long ll_row, i, ll_check
DateTime ldt_start, ldt_end
Date ld_start, ld_end
String ls_start, ls_end

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

For i=1 To ll_row
	ls_item_code = Trim(dw_detail.object.itemmst_itemcod[i])			//품목코드
	ls_name = Trim(dw_detail.object.itemmst_itemnm[i])	 		   //품목명
	ls_categorya = Trim(dw_detail.object.itemmst_categorya[i])		//품목소분류
	ls_svcode = Trim(dw_detail.object.itemmst_svccod[i])				//서비스코드
	ls_trcode = Trim(dw_detail.object.itemmst_trcod[i])				//거래유형코드
	ls_pricetable = Trim(dw_detail.object.itemmst_pricetable[i]) 	//적용요율형식
	
	
	If IsNull(ls_item_code) Then ls_item_code = ""
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_categorya) Then ls_categorya = ""
	If IsNull(ls_svcode) Then ls_svcode =""
	If IsNull(ls_trcode) Then ls_trcode =""
	If IsNull(ls_pricetable) Then ls_pricetable =""
	

	//Check
	If ls_item_code = "" Then
		f_msg_usr_err(200, Title, "품목ID")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('itemmst_itemcod')
		Return -1
	End If
	If ls_name = "" Then
		f_msg_usr_err(200, Title, "품목명")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('itemmst_itemnm')
		Return -1
	End If
	If ls_svcode = "" Then
		f_msg_usr_err(200, Title, "서비스")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('itemmst_svccod')
		Return -1
	End If
	If ls_categorya = "" Then
		f_msg_usr_err(200, Title, "소분류")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('itemmst_categorya')
		Return -1
	End If

  If ls_trcode = "" Then
		f_msg_usr_err(200, Title, "거래유형")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('itemmst_trcod')
		Return -1
	End If
	
	
	
	If ls_pricetable = "" Then
		f_msg_usr_err(200, Title, "적용요율형식")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('itemmst_pricetable')
		Return -1
	End If
	

  //Update한 log 정보
   If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.itemmst_updt_user[i] = gs_user_id
		dw_detail.object.itemmst_updtdt[i] = fdt_get_dbserver_now()
   End If
Next

//저장 성공
//p_ok.TriggerEvent("ue_enable")
//dw_cond.Enabled = True

Return 0	
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("selectcod")

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b0w_reg_itemmst
	Desc.	: 	품목마스터 등록
	Ver.	:	1.0
	Date	: 	2002.09.24
	Programer : Park Kyung Hae(parkkh)
--------------------------------------------------------------------------*/

end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_itemmst_2
integer x = 37
integer y = 40
integer width = 2382
integer height = 224
string dataobject = "b0dw_cnd_reg_itemmst"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;
//분류선택에서 대분류, 중분류, 소분류를 선택함에 따라 category 컬럼의 dddw를 바꾼다.
Choose Case dwo.Name
	Case "selectcod"
		Choose Case data
			Case "categoryA"         //소분류
				is_select_cod = "categoryA"
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b0dc_dddw_categorya")
				Modify("category.dddw.DataColumn='categorya'")
				Modify("category.dddw.DisplayColumn='categoryanm'")
//				
			Case "categoryB"			//중분류
				is_select_cod = "categoryB"				
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b0dc_dddw_categoryb")
				Modify("category.dddw.DataColumn='categoryb'")
				Modify("category.dddw.DisplayColumn='categorybnm'")
				 
			Case "categoryC"			//대분류
				is_select_cod = "categoryC"				
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b0dc_dddw_categoryc")
				Modify("category.dddw.DataColumn='categoryc'")
				Modify("category.dddw.DisplayColumn='categorycnm'")
				
			Case else					//분류선택 안했을 경우...
				is_select_cod = ""				
				Modify("category.dddw.name=''")
//				Modify("category.dddw.DataColumn=''")
//				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''
		End Choose
End Choose

Return 0
end event

event dw_cond::clicked;string ls_selectcod

//분류선택을 선택하지 않고 category 컬럼을 클릭할 때 메세지!!
Choose Case dwo.Name
	Case "category"
		ls_selectcod = This.Object.selectcod[row]
		If IsNull(ls_selectcod) or ls_selectcod = "" Then
			 f_msg_usr_err(9000, parent.Title, "분류선택을 먼저 선택하세요!")
			 return -1
		End If
//	Case "selectcod"
//		ls_selectcod = This.Object.selectcod[row]		
//		Choose Case ls_selectcod
//			Case "categoryA"         //소분류
//				Modify("category.dddw.DataColumn='categorya'")
//				Modify("category.dddw.DisplayColumn='categoryanm'")		
//			Case "categoryA"         //소분류
//				Modify("category.dddw.DataColumn='categorya'")
//				Modify("category.dddw.DisplayColumn='categoryanm'")		
//			Case "categoryA"         //소분류
//				Modify("category.dddw.DataColumn='categorya'")
//				Modify("category.dddw.DisplayColumn='categoryanm'")		
//		End Choose				
End Choose




end event

type p_ok from w_a_reg_m`p_ok within b0w_reg_itemmst_2
integer x = 2555
end type

type p_close from w_a_reg_m`p_close within b0w_reg_itemmst_2
integer x = 2857
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_itemmst_2
integer x = 23
integer width = 2409
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_itemmst_2
integer x = 315
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_itemmst_2
integer x = 23
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within b0w_reg_itemmst_2
integer x = 608
integer y = 1628
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_itemmst_2
integer x = 23
integer y = 304
integer width = 3264
integer height = 1272
string dataobject = "b0dw_reg_itemmst_2"
end type

event dw_detail::retrieveend;call super::retrieveend;String ls_category_a
//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If



end event

event dw_detail::constructor;call super::constructor;//손모양을 막는다.
dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;String ls_category_b, ls_category_c, ls_oneoffcharger, ls_quota

Choose Case dwo.Name
	Case "itemmst_categorya"    //품목소분류 선택시 품목 중(대)분류 자동 뿌려줌!!
		
		SELECT categorya.categoryb, categoryb.categoryc 
		INTO :ls_category_b, :ls_category_c
		FROM categorya, categoryb
		WHERE categorya.categorya = :data
		 AND categorya.categoryb = categoryb.categoryb;		
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT categoryc ")
			Return
		End If		
		
		This.Object.categorya_categoryb[row] = ls_category_b
		This.Object.categoryb_categoryc[row] = ls_category_c
		

		
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_itemmst_2
integer x = 1166
integer y = 1628
end type

