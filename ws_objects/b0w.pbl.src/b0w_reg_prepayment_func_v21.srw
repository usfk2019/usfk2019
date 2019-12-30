$PBExportHeader$b0w_reg_prepayment_func_v21.srw
$PBExportComments$[parkkh] 상품별선납품목조건구성 등록
forward
global type b0w_reg_prepayment_func_v21 from w_a_reg_m
end type
end forward

global type b0w_reg_prepayment_func_v21 from w_a_reg_m
integer width = 3122
integer height = 1960
end type
global b0w_reg_prepayment_func_v21 b0w_reg_prepayment_func_v21

on b0w_reg_prepayment_func_v21.create
call super::create
end on

on b0w_reg_prepayment_func_v21.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where,ls_svccod, ls_priceplan,ls_funccod, ls_code

ls_svccod = Trim(dw_cond.Object.svccod[1])
ls_priceplan = Trim(dw_cond.Object.priceplan[1])
ls_funccod = Trim(dw_cond.Object.funccod[1])
ls_code = Trim(dw_cond.object.code[1])

If IsNull(ls_svccod) Then ls_svccod = ""
If IsNull(ls_priceplan) Then ls_priceplan = ""
If IsNull(ls_funccod) Then ls_funccod = ""
If IsNull(ls_code) Then ls_code = ""

ls_where = ""
If ls_svccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " svccod = '" + ls_svccod + "' "	
End If

If ls_priceplan <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " priceplan = '" + ls_priceplan + "' "	
End If

If ls_funccod <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " funccod = '" + ls_funccod + "' "	
End If

If ls_code<> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " code = '" + ls_code + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i
String ls_svccod,ls_priceplan,ls_funccod,ls_code

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_svccod = Trim(dw_detail.Object.svccod[ll_i])
	ls_priceplan = Trim(dw_detail.Object.priceplan[ll_i])	
	ls_funccod = Trim(dw_detail.Object.funccod[ll_i])
   ls_code = Trim(dw_detail.Object.code[ll_i])
	
	If IsNull(ls_svccod) Then ls_svccod = ""
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	If IsNull(ls_funccod) Then ls_funccod = ""	
	If IsNull(ls_code) Then ls_code = ""	

	If ls_svccod = "" Then 
		f_msg_usr_err(200, Title, "서비스코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("svccod")
		Return -1
	End If
	
	If ls_priceplan = "" Then 
		f_msg_usr_err(200, Title, "가격정책")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("priceplan")
		Return -1
	End If

	If ls_funccod = "" Then 
		f_msg_usr_err(200, Title, "기능코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("funccod")
		Return -1
	End If
	
	If ls_code = "" Then 
		f_msg_usr_err(200, Title, "내용코드")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("code")
		Return -1
	End If
	
	//Update 한 Log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]
   End If
Next

Return 0
	
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b0w_reg_prepayment_func_v21
	Desc.	: 상품별선납품목조건구성등록
	Ver 	: 1.0
	Date	: 2006.02.03
	Progrmaer: Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
p_insert.TriggerEvent("ue_enable")
end event

event ue_insert;call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("svccod")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_svccod, ls_priceplan
Long ll_row

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("svccod")

//insert시 상단에 국가토드, 지역상위그룹이 존재하면 default로 뿌려줌!
ls_svccod = Trim(dw_cond.Object.svccod[1])
If IsNull(ls_svccod) Then ls_svccod = ""

ls_priceplan = Trim(dw_cond.Object.priceplan[1])
If IsNull(ls_priceplan) Then ls_priceplan = ""

If ls_svccod <> "" Then 
	dw_detail.Object.svccod[al_insert_row] = ls_svccod
End If

If ls_priceplan <> "" Then 
	dw_detail.Object.priceplan[al_insert_row] = ls_priceplan
End If

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_prepayment_func_v21
integer x = 64
integer y = 68
integer width = 2226
integer height = 212
string dataobject = "b0dw_cnd_reg_prepayment_func_v21"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_prepayment_func_v21
integer x = 2423
integer y = 52
end type

type p_close from w_a_reg_m`p_close within b0w_reg_prepayment_func_v21
integer x = 2738
integer y = 52
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_prepayment_func_v21
integer x = 37
integer width = 2286
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_prepayment_func_v21
integer y = 1716
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_prepayment_func_v21
integer y = 1716
end type

type p_save from w_a_reg_m`p_save within b0w_reg_prepayment_func_v21
integer x = 617
integer y = 1716
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_prepayment_func_v21
integer y = 308
integer width = 3035
integer height = 1388
string dataobject = "b0dw_reg_prepayment_func_v21"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan
string ls_filter
Int li_exist

This.AcceptText()

Choose Case dwo.name
	Case "svccod"
		li_exist = This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
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
END CHoose
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_prepayment_func_v21
integer x = 1175
integer y = 1716
end type

