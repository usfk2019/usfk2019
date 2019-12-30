$PBExportHeader$b1w_reg_customer_d_v20_vtel.srw
$PBExportComments$[ohj] 고객정보 등록 v20
forward
global type b1w_reg_customer_d_v20_vtel from b1w_reg_customer_d_v20
end type
end forward

global type b1w_reg_customer_d_v20_vtel from b1w_reg_customer_d_v20
end type
global b1w_reg_customer_d_v20_vtel b1w_reg_customer_d_v20_vtel

on b1w_reg_customer_d_v20_vtel.create
int iCurrent
call super::create
end on

on b1w_reg_customer_d_v20_vtel.destroy
call super::destroy
end on

event ue_ok();Call w_a_reg_m_tm2::ue_ok

//조회
String ls_customerid, ls_customername, ls_payid, ls_logid, ls_value, ls_name
String ls_ssno, ls_corpno, ls_corpnm, ls_cregno, ls_phone, ls_status
String ls_ctype1, ls_ctype2, ls_ctype3, ls_macod, ls_location, ls_new, ls_where
String ls_enterdtfrom, ls_enterdtto, ls_termdtfrom, ls_termdtto
Date ld_enterdtfrom, ld_enterdtto, ld_termdtfrom, ld_termdtto
String ls_value_1
Integer li_check
Long ll_row

ls_new = Trim(dw_cond.object.new[1])
If ls_new = "Y" Then 
	ib_new = True
Else
	ib_new = False
End If

//신규 등록
If ib_new Then
	tab_1.SelectedTab = 1		//Tab 1 Select
	p_ok.TriggerEvent("ue_disable")
	dw_cond.Enabled = False
	p_delete.TriggerEvent("ue_disable")
	p_view.TriggerEvent("ue_disable")	
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	tab_1.Enabled = True
	tab_1.ib_tabpage_check[tab_1.SelectedTab] = True 
   TriggerEvent("ue_insert")	//첫 페이지에 Insert row 한다.
	Return
//조회
Else
	ls_value = Trim(dw_cond.object.value[1])
	ls_name = Trim(dw_cond.object.name[1])
	ls_location = Trim(dw_cond.object.location[1])			//지역구분
	ls_value_1 = Trim(dw_cond.object.value_1[1])
	
	If IsNull(ls_value) Then ls_value = ""
	If IsNull(ls_name) Then ls_name = ""
	If IsNull(ls_value_1) Then ls_value_1 = ""
	If IsNull(ls_location) Then ls_location= ""
   
	If (ls_value = ""  Or ls_name = "" ) And ( ls_value_1 = "" Or ls_location = "") Then
		f_msg_info(200, Title, "조건항목 혹은 지역 분류")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If

	/*If ls_value = "" Then
		f_msg_info(200, Title, "조건항목")
		dw_cond.SetFocus()
		dw_cond.setColumn("value")
		Return 
	End If
	
	If ls_name = "" Then
		f_msg_info(200, Title, "조건내역")
		dw_cond.SetFocus()
		dw_cond.setColumn("name")
		Return 
	End If */
		
		
	ls_where = ""
	If ls_value <> "" Then
		If ls_where <> "" Then ls_where += " And "
		Choose Case ls_value
			Case "customerid"
				ls_where += "cus.customerid like '" + ls_name + "%' " 
			Case "customernm"
				ls_where += "Upper(cus.customernm) like '%" + Upper(ls_name) + "%' "  //2005.12.08 modify juede
			Case "payid"
				ls_where += "cus.payid like '" + ls_name + "%' "
			Case "logid"
				ls_where += "Upper(cus.logid) like '" + Upper(ls_name) + "%' "
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
			Case "key"
				ls_where += "Upper(val.validkey) like '" + Upper(ls_name) + "%' "
		End Choose		
	End If
	
	//분류선택(대,중,소분류)에 따라 select 조건이 다라짐
	If ls_value_1 <> "" Then
		Choose Case is_select_cod
			Case "categoryA"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "a.categorya = '" + ls_location + "' "
			Case "categoryB"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "b.categoryb = '" + ls_location + "' "
			Case "categoryC"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "c.categoryc = '" + ls_location + "' "
		   Case "locationL"
				If ls_where <> "" Then ls_where += " And "
				ls_where += "loc.location = '" + ls_location + "' "
		End Choose		
	End If
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	If ll_row = 0 Then
		f_msg_info(1000, Title, "")
		p_view.TriggerEvent("ue_disable")			
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "")
		p_view.TriggerEvent("ue_disable")			
		Return
	Else			
		//검색을 찾으면 Tab를 활성화 시킨다.
		tab_1.Trigger Event SelectionChanged(1, 1)
		tab_1.Enabled = True
	End If

End If
end event

event ue_view();String ls_customerid, ls_where
Long i, ll_master_row

ll_master_row = dw_master.GetSelectedRow(0)
If ll_master_row <> 0 Then
	If ll_master_row < 0 Then Return 
	ls_customerid = Trim(dw_master.object.customerm_customerid[ll_master_row])
End If

If ls_customerid = "" Then Return

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "고객정보등록"
iu_cust_msg.is_grp_name = "청구및사용내역상세조회"
iu_cust_msg.is_data[1] = ls_customerid

OpenWithParm(b1w_inq_inv_detail_pop_vtel, iu_cust_msg, gw_mdi_frame)

end event

type dw_cond from b1w_reg_customer_d_v20`dw_cond within b1w_reg_customer_d_v20_vtel
end type

type p_ok from b1w_reg_customer_d_v20`p_ok within b1w_reg_customer_d_v20_vtel
end type

type p_close from b1w_reg_customer_d_v20`p_close within b1w_reg_customer_d_v20_vtel
end type

type gb_cond from b1w_reg_customer_d_v20`gb_cond within b1w_reg_customer_d_v20_vtel
end type

type dw_master from b1w_reg_customer_d_v20`dw_master within b1w_reg_customer_d_v20_vtel
end type

type p_insert from b1w_reg_customer_d_v20`p_insert within b1w_reg_customer_d_v20_vtel
end type

type p_delete from b1w_reg_customer_d_v20`p_delete within b1w_reg_customer_d_v20_vtel
end type

type p_save from b1w_reg_customer_d_v20`p_save within b1w_reg_customer_d_v20_vtel
end type

type p_reset from b1w_reg_customer_d_v20`p_reset within b1w_reg_customer_d_v20_vtel
end type

type tab_1 from b1w_reg_customer_d_v20`tab_1 within b1w_reg_customer_d_v20_vtel
end type

type st_horizontal from b1w_reg_customer_d_v20`st_horizontal within b1w_reg_customer_d_v20_vtel
end type

type p_view from b1w_reg_customer_d_v20`p_view within b1w_reg_customer_d_v20_vtel
end type

