$PBExportHeader$b8w_inq_partner_adstock.srw
$PBExportComments$[parkkh] 대리점재고현황조회
forward
global type b8w_inq_partner_adstock from w_a_inq_m_m
end type
end forward

global type b8w_inq_partner_adstock from w_a_inq_m_m
integer width = 3529
integer height = 1852
end type
global b8w_inq_partner_adstock b8w_inq_partner_adstock

event ue_ok();call super::ue_ok;//조회
String ls_where, ls_value, ls_name, ls_levelcod
Integer li_check
Long ll_row

ls_value = Trim(dw_cond.object.value[1])
ls_name = Trim(dw_cond.object.name[1])
ls_levelcod = Trim(dw_cond.object.levelcod[1])

If IsNull(ls_value) Then ls_value = ""
If IsNull(ls_name) Then ls_name = ""
If IsNull(ls_levelcod) Then ls_levelcod = ""

ls_where = ""
If ls_value <> "" Then
	If ls_name <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_value
			Case "partner"
				ls_where += "partner like '" + ls_name + "%' "
			Case "partnernm"
				ls_where += "Upper(partnernm) like '%" + Upper(ls_name) + "%' "
			Case "prefixno"
				ls_where += "refixno like '" + ls_name + "%' "
		End Choose		
   End If
End If

IF ls_levelcod <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "levelcod = '" + ls_levelcod + "'"
END IF

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row < 0 Then 
	f_msg_usr_err(2100,Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_info(1000, Title, "")
	Return
End If
end event

on b8w_inq_partner_adstock.create
call super::create
end on

on b8w_inq_partner_adstock.destroy
call super::destroy
end on

type dw_cond from w_a_inq_m_m`dw_cond within b8w_inq_partner_adstock
integer x = 64
integer y = 76
integer width = 2697
integer height = 92
string dataobject = "b8dw_cnd_inq_partner_adstock"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m_m`p_ok within b8w_inq_partner_adstock
integer x = 2862
end type

type p_close from w_a_inq_m_m`p_close within b8w_inq_partner_adstock
integer x = 3163
integer y = 52
end type

type gb_cond from w_a_inq_m_m`gb_cond within b8w_inq_partner_adstock
integer width = 2770
integer height = 224
end type

type dw_master from w_a_inq_m_m`dw_master within b8w_inq_partner_adstock
integer x = 23
integer y = 260
integer width = 3429
integer height = 636
string dataobject = "b8dw_inq_partner_adstock"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_SORT

ib_sort_use = True
ldwo_SORT = Object.partner_t
uf_init(ldwo_SORT)

end event

type dw_detail from w_a_inq_m_m`dw_detail within b8w_inq_partner_adstock
integer x = 23
integer y = 928
integer width = 3429
integer height = 776
string dataobject = "b8dw_inq_partner_adstock_detail"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;String	ls_where, ls_partner
Long		ll_rows

ls_partner = Trim(String(dw_master.Object.partner[al_select_row]))

//Retrieve
If al_select_row > 0 Then
	ls_where = "mv_partner= '" + ls_partner + "' "
	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//Return 1
	End If
End if

Return 0
end event

event dw_detail::doubleclicked;call super::doubleclicked;Long ll_master_row		//dw_master의 row 선택 여부

Choose Case dwo.Name
	Case "iqty" //
		
		dw_master.accepttext()
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "대리점입고내역"
		iu_cust_msg.is_grp_name = "대리점재고현황조회"
		iu_cust_msg.is_data[1] = Trim(String(dw_master.Object.partner[ll_master_row]))
		iu_cust_msg.is_data[2] = Trim(String(dw_detail.Object.modelno[row]))
		
		OpenWithParm(b8w_entering_popup, iu_cust_msg)
		
	Case "sale_cnt", "rent_cnt", "oqty" //
		
		dw_master.accepttext()
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "대리점고내역"
		iu_cust_msg.is_grp_name = "대리점재고현황조회"
		iu_cust_msg.is_data[1] = Trim(String(dw_master.Object.partner[ll_master_row]))
		iu_cust_msg.is_data[2] = Trim(String(dw_detail.Object.modelno[row]))
		
		OpenWithParm(b8w_outing_popup, iu_cust_msg)
		
	Case "sqty" //
		
		dw_master.accepttext()
		//row Double Click시 해당 청구 자료 보여줌
		ll_master_row = dw_master.GetSelectedRow(0)
		If ll_master_row < 0 Then Return 0
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "대리점재고내역"
		iu_cust_msg.is_grp_name = "대리점재고현황조회"
		iu_cust_msg.is_data[1] = Trim(String(dw_master.Object.partner[ll_master_row]))
		iu_cust_msg.is_data[2] = Trim(String(dw_detail.Object.modelno[row]))
		
		OpenWithParm(b8w_stock_popup, iu_cust_msg)

		
End Choose

Return 0 
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b8w_inq_partner_adstock
integer x = 32
integer y = 896
integer height = 36
end type

