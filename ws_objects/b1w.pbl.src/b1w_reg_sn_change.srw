$PBExportHeader$b1w_reg_sn_change.srw
$PBExportComments$[kem] 기기변경
forward
global type b1w_reg_sn_change from w_a_reg_m
end type
end forward

global type b1w_reg_sn_change from w_a_reg_m
integer width = 3904
integer height = 1924
end type
global b1w_reg_sn_change b1w_reg_sn_change

type variables
String is_status
end variables

on b1w_reg_sn_change.create
call super::create
end on

on b1w_reg_sn_change.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_chgreqdt, ls_act_status, ls_value, ls_name

ls_chgreqdt = String(dw_cond.Object.chgreqdt[1],'yyyymmdd')
ls_act_status = dw_cond.Object.act_status[1]
ls_value = Trim(dw_cond.object.value[1])
ls_name = Trim(dw_cond.object.name[1])

If IsNull(ls_chgreqdt) Then ls_chgreqdt = ""
If IsNull(ls_act_status) Then ls_act_status = ""
If IsNull(ls_value) Then ls_value = ""
If IsNull(ls_name) Then ls_name = ""

If ls_chgreqdt = "" Then
	f_msg_info(200, Title, "요청일")
	dw_cond.SetColumn("chgreqdt")
	Return
End If

If ls_name <> "" Then
	If ls_value = "" Then
		f_msg_info(200, Title, "검색조건")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If
End If

ls_where = ""
If ls_chgreqdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(SNC.chgreqdt,'yyyymmdd') <= '" + ls_chgreqdt + "'"	
End If

If ls_act_status <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " act_status = '" + ls_act_status + "' "	
End If

If ls_value <> "" and ls_name <> "" Then
	If ls_where <> "" Then ls_where += " And "
	Choose Case ls_value
		Case "customerid"
			ls_where += "snc.customerid like '" + ls_name + "%' "
		Case "customernm"
			ls_where += "Upper(cus.customernm) like '" + Upper(ls_name) + "%' "
		Case "ssno"
			ls_where += "cus.ssno like '" + ls_name + "%' "
		Case "corpno"
			ls_where += "cus.corpno like '" + ls_name + "%' "
		Case "corpnm"
			ls_where += "cus.corpnm like '" + ls_name + "%' "
		Case "cregno"
			ls_where += "cus.cregno like '" + ls_name + "%' "
		Case "phone1"
			ls_where += "cus.phone1 like '" + ls_name + "%' "
		Case "payid"
			ls_where += "cus.payid like '" + ls_name + "%' "
		Case "logid"
			ls_where += "Upper(cus.logid) like '" + Upper(ls_name) + "%' "
	End Choose		
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(is_status, gs_user_id)

If ll_row = 0 Then
	f_msg_usr_err(1100, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b1w_reg_sn_change
	Desc.	: 기기변경
	Ver 	: 1.0
	Date	: 2003.10.16
	Progrmaer: Kim Eun Mi(kem)
-------------------------------------------------------------------------*/
String ls_ref_desc

dw_cond.object.chgreqdt[1] = date(fdt_get_dbserver_now())

//기기변경신청
ls_ref_desc = ""
is_status = fs_get_control("E1", "E200", ls_ref_desc)
end event

event type integer ue_insert();call super::ue_insert;//p_delete.TriggerEvent("ue_enable")
//p_save.TriggerEvent("ue_enable")
//p_reset.TriggerEvent("ue_enable")
//
Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("chgreqdt")
dw_cond.Object.chgreqdt[1] = date(fdt_get_dbserver_now())

//p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_save();Long ll_row, ll_i, li_rc, ll_cnt, ll_cnt1, ll_prcnt
String ls_countrycod, ls_countrynm, ls_msg, ls_msg1

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

b1u_dbmgr2	lu_dbmgr2
lu_dbmgr2 = CREATE b1u_dbmgr2

lu_dbmgr2.is_caller = "b1w_reg_sn_change%save"
lu_dbmgr2.is_title  = Title
lu_dbmgr2.idw_data[1] = dw_detail
lu_dbmgr2.is_data[1] = is_status      //기기변경신청코드

lu_dbmgr2.uf_prc_db_06()
li_rc = lu_dbmgr2.ii_rc

If li_rc < 0 Then
	f_msg_info(3010,This.Title,"Save")	
	Destroy lu_dbmgr2
	Return li_rc
End If

ls_msg = lu_dbmgr2.is_data[2] 
ll_cnt = lu_dbmgr2.ii_data[1]
ll_cnt1 = lu_dbmgr2.ii_data[2]
ls_msg1 = lu_dbmgr2.is_data[3]
ll_prcnt = lu_dbmgr2.ii_data[3]

If ll_prcnt = 0 and ll_cnt = 0 and ll_cnt1 = 0 Then
	f_msg_info(3000,This.Title,"[기변처리건수가 0 건]")
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
	Return 0
End if

If ll_cnt = 0 and ll_cnt1 = 0 then
	f_msg_info(3000,This.Title,"Save [기변처리건수 : " + string(ll_prcnt) + "건]")
elseif ll_cnt > 0 and ll_cnt1 > 0 then
	f_msg_info(3000,This.Title,"Save [기변처리건수 : " + string(ll_prcnt) + "건] ~r~n~r~n Seq => " + LeftA(ls_msg,LenA(ls_msg)-1) + " 은 변경할단말기 출고된상태로 기기변경불가!~r~n"+ &
                                   " Seq => " + LeftA(ls_msg1,LenA(ls_msg1)-1) + " 은 단말기SN가 해당총판에 "+ &
                                   "할당되어 있지 않아 기기변경불가! 확인하세요!!" )
elseif ll_cnt > 0 then
	f_msg_info(3000,This.Title,"Save [기변처리건수 : " + string(ll_prcnt) + "건] ~r~n~r~n Seq => " + LeftA(ls_msg,LenA(ls_msg)-1) + " 은 변경할단말기 출고된상태로"+ &
                                   "기기변경불가! 확인하세요!!" )
elseif ll_cnt1 > 0 then
	f_msg_info(3000,This.Title,"Save [기변처리건수 : " + string(ll_prcnt) + "건] ~r~n~r~n Seq => " + LeftA(ls_msg1,LenA(ls_msg1)-1) + " 은 단말기SN가 해당총판에 "+ &
                                   "할당되어 있지 않아 기기변경불가! 확인하세요!!" )
end if

Destroy lu_dbmgr2

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

//p_save.TriggerEvent("ue_disable")

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_sn_change
integer x = 41
integer y = 44
integer width = 2391
integer height = 244
string dataobject = "b1dw_cnd_reg_sn_change"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_sn_change
integer x = 2565
integer y = 56
end type

type p_close from w_a_reg_m`p_close within b1w_reg_sn_change
integer x = 2862
integer y = 56
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_sn_change
integer width = 2418
integer height = 304
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_sn_change
boolean visible = false
integer x = 329
integer y = 1696
integer height = 172
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_sn_change
boolean visible = false
integer x = 91
integer y = 1696
end type

type p_save from w_a_reg_m`p_save within b1w_reg_sn_change
integer x = 91
integer y = 1688
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_sn_change
integer x = 23
integer width = 3794
integer height = 1340
string dataobject = "b1dw_reg_sn_change"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_sn_change
integer x = 389
integer y = 1688
end type

