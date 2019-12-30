$PBExportHeader$b1w_reg_trouble_mst.srw
$PBExportComments$[chooys] 민원유형 마스터 등록
forward
global type b1w_reg_trouble_mst from w_a_reg_m
end type
end forward

global type b1w_reg_trouble_mst from w_a_reg_m
integer width = 3223
integer height = 1852
end type
global b1w_reg_trouble_mst b1w_reg_trouble_mst

type variables
string is_select_cod
end variables

on b1w_reg_trouble_mst.create
call super::create
end on

on b1w_reg_trouble_mst.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where, ls_selectcod, ls_category, ls_troublenm
Long ll_row

ls_selectcod = Trim(dw_cond.object.selectcod[1])
ls_category = Trim(dw_cond.object.category[1])
ls_troublenm = Trim(dw_cond.object.troublenm[1])
If IsNull(ls_selectcod) Then ls_selectcod = ""
If IsNull(ls_category) Then ls_category = ""
If IsNull(ls_troublenm) Then ls_troublenm = ""

ls_where = ""
//분류선택(대,중,소분류)에 따라 select 조건이 다라짐
If ls_category <> "" Then
	Choose Case ls_selectcod
		Case "categoryA"
			If ls_where <> "" Then ls_where += " And "
			ls_where += "troubletypemst.troubletypea = '" + ls_category + "' "
		Case "categoryB"
			If ls_where <> "" Then ls_where += " And "
			ls_where += "troubletypea.troubletypeb = '" + ls_category + "' "
		Case "categoryC"
			If ls_where <> "" Then ls_where += " And "
			ls_where += "troubletypeb.troubletypec = '" + ls_category + "' "
	End Choose		
End If

//민원명(LIKE)
If ls_troublenm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(troubletypemst.troubletypenm) Like '%" + Upper(ls_troublenm) + "%' "
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
dw_detail.SetColumn("troubletypemst_troubletype")

If ls_selectcod = "categoryA" Then
	If ls_category_a <> "" Then
		
		SELECT troubletypea.troubletypeb, troubletypeb.troubletypec 
		INTO :ls_category_b, :ls_category_c
		FROM troubletypea, troubletypeb
		WHERE troubletypea.troubletypea = :ls_category_a
		 AND troubletypea.troubletypeb = troubletypeb.troubletypeb;		
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT categoryc ")
			Return -1
		End If		
		
		dw_detail.object.troubletypemst_troubletypea[al_insert_row] = ls_category_a
		dw_detail.object.troubletypea_troubletypeb[al_insert_row] = ls_category_b
		dw_detail.object.troubletypeb_troubletypec[al_insert_row] = ls_category_c
	End If
End If

//Log 정보
dw_detail.object.troubletypemst_crt_user[al_insert_row] = gs_user_id
dw_detail.object.troubletypemst_crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.troubletypemst_pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]
dw_detail.object.troubletypemst_updt_user[al_insert_row] = gs_user_id
dw_detail.object.troubletypemst_updtdt[al_insert_row] = fdt_get_dbserver_now()

Return 0
end event

event type integer ue_extra_save();//Save Check
String ls_troubletype, ls_name, ls_categorya, ls_svcode, ls_trcode, ls_pricetable
String ls_onoff, ls_subscribed, ls_daily, ls_billing, ls_mainitem
Long ll_row, i, ll_check
DateTime ldt_start, ldt_end
Date ld_start, ld_end
String ls_start, ls_end

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

For i=1 To ll_row
	ls_troubletype = Trim(dw_detail.object.troubletypemst_troubletype[i])			
	ls_name = Trim(dw_detail.object.troubletypemst_troubletypenm[i])	 		   
	ls_categorya = Trim(dw_detail.object.troubletypemst_troubletypea[i])		
		
	If IsNull(ls_troubletype) Then ls_troubletype = ""
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_categorya) Then ls_categorya = ""
	
	//Check
	If ls_troubletype = "" Then
		f_msg_usr_err(200, Title, "민원유형코드")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('troubletypemst_troubletype')
		Return -1
	End If
	If ls_name = "" Then
		f_msg_usr_err(200, Title, "민원유형명")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('troubletypemst_troubletypenm')
		Return -1
	End If
	If ls_categorya = "" Then
		f_msg_usr_err(200, Title, "소분류")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn('troubletypemst_troubletypea')
		Return -1
	End If

  //Update한 log 정보
   If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.troubletypemst_updt_user[i] = gs_user_id
		dw_detail.object.troubletypemst_updtdt[i] = fdt_get_dbserver_now()
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
	Name 	: b1w_reg_trouble_mst
	Desc.	: 민원유형 등록
	Ver 	: 1.0
	Date	: 2003.08.12
	Progrmaer: Choo YoonShik(chooys)
-------------------------------------------------------------------------*/

end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_trouble_mst
integer x = 73
integer y = 40
integer width = 1925
integer height = 224
string dataobject = "b1dw_cnd_reg_troublemst"
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
				Modify("category.dddw.name=b1dc_dddw_troubletypea")
				Modify("category.dddw.DataColumn='troubletypea_troubletypea'")
				Modify("category.dddw.DisplayColumn='troubletypea_troubletypeanm'")
//				
			Case "categoryB"			//중분류
				is_select_cod = "categoryB"				
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b1dc_dddw_troubletypeb")
				Modify("category.dddw.DataColumn='troubletypeb_troubletypeb'")
				Modify("category.dddw.DisplayColumn='troubletypeb_troubletypebnm'")
				 
			Case "categoryC"			//대분류
				is_select_cod = "categoryC"				
				Modify("category.dddw.name=''")
				Modify("category.dddw.DataColumn=''")
				Modify("category.dddw.DisplayColumn=''")
				This.Object.category[row] = ''				
				Modify("category.dddw.name=b1dc_dddw_troubletypec")
				Modify("category.dddw.DataColumn='troubletypec'")
				Modify("category.dddw.DisplayColumn='troubletypecnm'")
				
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

type p_ok from w_a_reg_m`p_ok within b1w_reg_trouble_mst
integer x = 2080
end type

type p_close from w_a_reg_m`p_close within b1w_reg_trouble_mst
integer x = 2382
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_trouble_mst
integer x = 23
integer width = 1993
integer height = 284
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_trouble_mst
integer x = 315
integer y = 1628
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_trouble_mst
integer x = 23
integer y = 1628
end type

type p_save from w_a_reg_m`p_save within b1w_reg_trouble_mst
integer x = 608
integer y = 1628
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_trouble_mst
integer x = 23
integer y = 304
integer width = 3122
integer height = 1272
string dataobject = "b1dw_reg_troublemst"
borderstyle borderstyle = StyleBox!
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
	Case "troubletypemst_troubletypea"    //품목소분류 선택시 품목 중(대)분류 자동 뿌려줌!!
		
		SELECT troubletypea.troubletypeb, troubletypeb.troubletypec 
		INTO :ls_category_b, :ls_category_c
		FROM troubletypea, troubletypeb
		WHERE troubletypea.troubletypea = :data
		 AND troubletypea.troubletypeb = troubletypeb.troubletypeb;		
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(Title, " SELECT categoryc ")
			Return
		End If		
		
		This.Object.troubletypea_troubletypeb[row] = ls_category_b
		This.Object.troubletypeb_troubletypec[row] = ls_category_c
		
End Choose
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_trouble_mst
integer x = 1166
integer y = 1628
end type

