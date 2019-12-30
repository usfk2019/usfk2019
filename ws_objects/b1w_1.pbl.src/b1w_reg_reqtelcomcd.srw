$PBExportHeader$b1w_reg_reqtelcomcd.srw
$PBExportComments$[parkkh] 고객수신정보 사업자등록
forward
global type b1w_reg_reqtelcomcd from w_a_reg_m
end type
end forward

global type b1w_reg_reqtelcomcd from w_a_reg_m
integer width = 1888
integer height = 1964
end type
global b1w_reg_reqtelcomcd b1w_reg_reqtelcomcd

type variables
Date id_sysdt
end variables

on b1w_reg_reqtelcomcd.create
call super::create
end on

on b1w_reg_reqtelcomcd.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where, ls_comcd

//조회 시 상단 대분류명 like 조회
ls_comcd = Trim(dw_cond.Object.comcd[1])

If IsNull(ls_comcd) Then ls_comcd = ""

ls_where = ""
If ls_comcd <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " comcd = '" + Upper(ls_comcd) + "' "	
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

event type integer ue_extra_save();call super::ue_extra_save;
Long ll_row, ll_i
String ls_comcd, ls_comkey, ls_fromdt

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
	ls_comcd = Trim(dw_detail.Object.comcd[ll_i])
	ls_fromdt = String(dw_detail.object.fromdt[ll_row],'yyyymmdd')
	ls_comkey = Trim(dw_detail.Object.comkey[ll_i])	
	
	If IsNull(ls_comcd) Then ls_comcd = ""
	If IsNull(ls_fromdt) Then ls_fromdt = ""
	If IsNull(ls_comkey) Then ls_comkey = ""
	
	If ls_comcd = "" Then 
		f_msg_usr_err(200, Title, "사업자")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("comcd")
		Return -1
	End If

	If ls_fromdt = "" Then
		f_msg_usr_err(200, Title, "적용시작일")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("fromdt")
		Return -1
	End If
	
	
	If ls_comkey = "" Then 
		f_msg_usr_err(200, Title, "사업자KEY")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("comkey")
		Return -1
	End If
	
	//log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
    	dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
	End If
Next

Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b1w_reg_reqtelcomcd
	Desc.	: 사업자 등록
	Ver 	: 1.0
	Date	: 2004.03.05
	Progrmaer: Park Kyung Hae(parkkh)

-------------------------------------------------------------------------*/
id_sysdt = Date(fdt_get_dbserver_now())

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
dw_cond.SetColumn("comcd")

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("comcd")

//Log 정보
dw_detail.object.fromdt[al_insert_row] =  id_sysdt
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_reqtelcomcd
integer x = 41
integer y = 52
integer width = 1056
integer height = 148
string dataobject = "b1dw_cnd_reg_reqtelcomcd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_reqtelcomcd
integer x = 1211
integer y = 44
end type

type p_close from w_a_reg_m`p_close within b1w_reg_reqtelcomcd
integer x = 1509
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_reqtelcomcd
integer x = 23
integer width = 1143
integer height = 220
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_reqtelcomcd
integer x = 315
integer y = 1720
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_reqtelcomcd
integer x = 23
integer y = 1720
end type

type p_save from w_a_reg_m`p_save within b1w_reg_reqtelcomcd
integer x = 608
integer y = 1720
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_reqtelcomcd
integer x = 23
integer y = 244
integer width = 1792
integer height = 1444
string dataobject = "b1dw_reg_reqtelcomcd"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::editchanged;call super::editchanged;//Update log
//dw_detail.object.updt_user[row] = gs_user_id
//dw_detail.object.updtdt[row] = fdt_get_dbserver_now()
end event

event dw_detail::retrieveend;call super::retrieveend;//처음 입력 했을시
If rowcount = 0 Then
	p_ok.TriggerEvent("ue_disable")
	
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	dw_cond.Enabled = False
End If
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_reqtelcomcd
integer x = 1193
integer y = 1720
end type

