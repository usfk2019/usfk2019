$PBExportHeader$b0w_reg_p_pricemst.srw
$PBExportComments$[kem] 통화요금상품등록
forward
global type b0w_reg_p_pricemst from w_a_reg_m
end type
end forward

global type b0w_reg_p_pricemst from w_a_reg_m
integer width = 3200
end type
global b0w_reg_p_pricemst b0w_reg_p_pricemst

on b0w_reg_p_pricemst.create
call super::create
end on

on b0w_reg_p_pricemst.destroy
call super::destroy
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b0w_reg_p_pricemst
	Desc.	: 통화요금상품등록
	Ver 	: 1.0
	Date	: 2003.11.18
	Progrmaer: Kim Eun Mi(kem)
-------------------------------------------------------------------------*/
end event

event ue_ok();call super::ue_ok;//조회
String ls_partner, ls_vpricenm, ls_where
Long ll_row

ls_partner  = Trim(dw_cond.object.partner[1])
ls_vpricenm = Trim(dw_cond.object.vpricenm[1])
If IsNull(ls_partner) Then ls_partner = ""
If IsNull(ls_vpricenm) Then ls_vpricenm = ""

ls_where = ""
If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner = '" + ls_partner + "' "
End If

If ls_vpricenm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "upper(vpricenm) like '" + upper(ls_vpricenm) + "%' "
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
end event

event type integer ue_extra_insert(long al_insert_row);//Insert 
String ls_partner

ls_partner = Trim (dw_cond.object.partner[1])
If IsNull(ls_partner) Then ls_partner = ""
If ls_partner <> "" Then
	dw_detail.object.partner[al_insert_row] = ls_partner
End If

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("partner")

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

event type integer ue_extra_save();//Save시 Check
String ls_partner, ls_vpricecod, ls_vpricenm, ls_use_yn
Long ll_rows, i

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

For i = 1 To ll_rows
	ls_partner = Trim(dw_detail.object.partner[i])
	If IsNull(ls_partner) Then ls_partner = ""
	If ls_partner = "" Then
		f_msg_usr_err(200, Title,"사업자")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("partner")
		Return - 1
	End If
	
	ls_vpricecod = Trim(dw_detail.object.vpricecod[i])
	If IsNull(ls_vpricecod) Then ls_vpricecod = ""
	If ls_vpricecod = "" Then
		f_msg_usr_err(200, Title,"요금상품코드")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("vpricecod")
		Return - 1
	End If
	
	ls_vpricenm = Trim(dw_detail.object.vpricenm[i])
	If IsNull(ls_vpricenm) Then ls_vpricenm = ""
	If ls_vpricenm = "" Then
		f_msg_usr_err(200, Title,"요금상품명")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("vpricenm")
		Return - 1
	End If
	
	ls_use_yn = Trim(dw_detail.object.use_yn[i])
	If IsNull(ls_use_yn) Then ls_use_yn = ""
	If ls_use_yn = "" Then
		f_msg_usr_err(200, Title,"사용여부")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("use_yn")
		Return - 1
	End If
	
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[i] = gs_user_id
		dw_detail.object.updtdt[i] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[i] = gs_pgm_id[gi_open_win_no]		
   End If
	
Next

Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b0w_reg_p_pricemst
integer x = 46
integer y = 44
integer width = 2299
integer height = 200
string dataobject = "b0dw_cnd_reg_p_pricemst"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b0w_reg_p_pricemst
integer x = 2469
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b0w_reg_p_pricemst
integer y = 44
end type

type gb_cond from w_a_reg_m`gb_cond within b0w_reg_p_pricemst
integer height = 256
end type

type p_delete from w_a_reg_m`p_delete within b0w_reg_p_pricemst
integer y = 1604
end type

type p_insert from w_a_reg_m`p_insert within b0w_reg_p_pricemst
integer y = 1604
end type

type p_save from w_a_reg_m`p_save within b0w_reg_p_pricemst
integer y = 1604
end type

type dw_detail from w_a_reg_m`dw_detail within b0w_reg_p_pricemst
integer y = 268
integer width = 3118
integer height = 1320
string dataobject = "b0dw_reg_p_pricemst"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력했을시 버튼 활성화
If rowcount = 0 Then
	p_delete.TriggerEvent("ue_enable")
	p_insert.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.SetFocus()   //데이터 없을경우 다시 조회 할 수있도록 
End If
end event

type p_reset from w_a_reg_m`p_reset within b0w_reg_p_pricemst
integer y = 1604
end type

