$PBExportHeader$b1w_reg_add_service_prc_mobile.srw
$PBExportComments$부가서비스 등록/해지 신청 처리 - 2015.03.15. lys
forward
global type b1w_reg_add_service_prc_mobile from w_a_reg_m_m
end type
end forward

global type b1w_reg_add_service_prc_mobile from w_a_reg_m_m
integer width = 4389
integer height = 2324
event type integer ue_process ( integer al_row )
end type
global b1w_reg_add_service_prc_mobile b1w_reg_add_service_prc_mobile

type variables
String is_operator, is_operatornm, is_partner
end variables

event ue_process;String ls_errmsg, ls_partner, ls_operator, ls_req_code
Long   ll_rc, LI_ERROR, ll_reqno
double lb_count, ll_return

//Row Check
IF al_row < 1 THEN Return -1

//Condition
ls_partner  = dw_cond.Object.partner[1]
ls_operator = dw_cond.Object.operator[1]

If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return -1
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1

//Get Mst Info
ll_reqno    = dw_master.Object.svc_req_mst_reqno[al_row]
ls_req_code = dw_master.Object.svc_req_mst_req_code[al_row]


//Procedure Call
ll_return 		= -1
ls_errmsg 		= space(800)

//처리부분...
SQLCA.B1W_PRC_SVC_REQ_MST(ll_reqno, ls_req_code, ls_operator, ll_return, ls_errmsg)
ll_rc = ll_return
If ll_rc < 0 Then
	//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
	MessageBox(This.Title, ls_errmsg)
	Return ll_rc
End If

//성공처리
f_msg_info(3000,This.Title,"Save")

//재조회
dw_master.reset()
dw_detail.reset()
this.TriggerEvent("ue_ok")


//No Error
RETURN 0
end event

on b1w_reg_add_service_prc_mobile.create
call super::create
end on

on b1w_reg_add_service_prc_mobile.destroy
call super::destroy
end on

event open;call super::open;//postEvent("resize")
dw_cond.SetFocus()
dw_cond.SetColumn("validkey")
end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_validkey,ls_contractseq, ls_operator, ls_partner, ls_req_code, ls_reqdt_fr, ls_reqdt_to, ls_comeplete_yn

//Condition
ls_validkey    = fs_snvl(dw_cond.Object.validkey[1], "")
ls_customerid  = fs_snvl(dw_cond.Object.customerid[1], "")
//ls_contractseq = fs_snvl(dw_cond.Object.contractseq[1], "")

ls_operator     = fs_snvl(dw_cond.Object.operator[1], "")
ls_partner      = fs_snvl(dw_cond.Object.partner[1], "")
ls_req_code     = fs_snvl(dw_cond.Object.req_code[1], "")
ls_comeplete_yn = fs_snvl(dw_cond.Object.comeplete_yn[1], "")
ls_reqdt_fr     = String(dw_cond.Object.reqdt_fr[1], "yyyymmdd")
ls_reqdt_to     = String(dw_cond.Object.reqdt_to[1], "yyyymmdd")

If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return


//Dynamic SQL
ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "a.customerid = '" + ls_customerid + "' "
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "b.validkey = '" + ls_validkey + "' "
END IF

IF ls_comeplete_yn <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "a.comeplete_yn like '" + ls_comeplete_yn + "' "
END IF

IF ls_partner <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "a.to_shop = '" + ls_partner + "' "
END IF

IF ls_req_code <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "a.req_code = '" + ls_req_code + "' "
END IF

IF ls_reqdt_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "a.reqdt between to_date('" + ls_reqdt_fr + "', 'yyyymmdd') and to_date('" + ls_reqdt_to + "', 'yyyymmdd') "
END IF


//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	p_reset.TriggerEvent("ue_enable")
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	//p_insert.TriggerEvent("ue_disable")
	//p_delete.TriggerEvent("ue_disable")
	//p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	f_msg_info(1000, Title, "")
END IF
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

//버튼 처리
//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

//Reset
dw_detail.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

//조회조건 초기화
dw_cond.object.partner[1]      = GS_SHOPID
//dw_cond.Object.validkey[1]   = ""
//dw_cond.Object.customerid[1] = ""
//dw_cond.Object.name[1]       = ""
dw_cond.Object.operator[1]     = is_operator
dw_cond.Object.operatornm[1]   = is_operatornm
dw_cond.Object.partner[1]      = is_partner
dw_cond.Object.comeplete_yn[1] = "%"

dw_cond.Object.reqdt_fr[1] = Date(fdt_get_dbserver_now())
dw_cond.Object.reqdt_to[1] = Date(fdt_get_dbserver_now())

RETURN 0
end event

event ue_save;Constant Int LI_ERROR = -1
Long		ll_mst_row
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


//COMMIT와 동일한 기능
iu_cust_db_app.is_caller = "COMMIT"
iu_cust_db_app.is_title = This.Title

iu_cust_db_app.uf_prc_db()

If iu_cust_db_app.ii_rc = -1 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If
f_msg_info(3000,This.Title,"Save")

//dw_detail 재조회
ll_mst_row = dw_master.GetSelectedRow(0)

dw_detail.Reset()
dw_detail.Trigger Event ue_retrieve(ll_mst_row)


//ii_error_chk = 0
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_add_service_prc_mobile
integer y = 64
integer width = 3013
integer height = 284
string dataobject = "b1dw_cnd_add_service_prc_mobile"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[1] = dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[1] = dw_cond.iu_cust_help.is_data[2]
		End If
End Choose

end event

event dw_cond::itemchanged;call super::itemchanged;String 	ls_customerid,		ls_customernm,		ls_memberid, 	&
		 	ls_operator,		ls_empnm,			ls_paydt,		&
			ls_paydt_1,			ls_sysdate,			ls_paydt_c, ls_partner
Integer	li_cnt
Date		ldt_paydt
DEC{2}	ldc_total,			ldc_90
LONG		ll_return

Choose Case dwo.name
	Case "customerid"
		ls_customerid = trim(data)
		select memberid, 		customernm
		  INTO :ls_memberid, :ls_customernm
		  FROM customerm
		 where customerid = :ls_customerid ;
		 
		 IF IsNull(ls_memberid) 	OR sqlca.sqlcode <> 0 	then ls_memberid 		= ""
		 IF IsNull(ls_customernm) 	OR sqlca.sqlcode <> 0 	then ls_customernm 	= ""
		IF ls_customernm = '' THEN
			f_msg_usr_err(9000, Title, "해당고객을 찾을수 없습니다. 확인 후 다시 입력하세요.")
			This.Object.customernm[1] 	=  ''
			This.Object.customerid[1] 	=  ''
			dw_cond.SetFocus()
			dw_cond.SetRow(1)
			dw_cond.SetColumn("customerid")
			
			return
			
		ELSE
			//This.Object.memberid[1] 	=  ls_memberid
			This.Object.customernm[1] 	=  ls_customernm
		END IF
		
	case 'operator'
		SELECT EMPNM, EMP_GROUP INTO :ls_empnm, :ls_partner
		  FROM SYSUSR1T
		 WHERE 1=1
		   AND EMP_NO    = :data
			AND EMP_GROUP IN (
			                 SELECT CODE
								    FROM SYSCOD2T
									WHERE 1=1
									  AND GRCODE = 'ZM300'
			                 )
			;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요! (처리권한이 있는 Operator를 선택하세요)")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm
		dw_cond.object.partner[row]    = ls_partner
		
		is_operator   = data
		is_operatornm = ls_empnm
		is_partner    = ls_partner
		
	case 'validkey'
		
		IF IsNumber(data) = False THEN
			f_msg_usr_err(9000, Title, "Phone Number는 숫자만 입력이 가능합니다! (입력값=" + data + ")")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.validkey[row]		= ""
			dw_cond.object.validkey[row]	= ""
			dw_cond.SetColumn("validkey")
			RETURN 2				
		END IF
End Choose

end event

event dw_cond::losefocus;call super::losefocus;//입력정보 동기화
//this.Accepttext()
end event

event dw_cond::ue_init;//Set Pop-Up
This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

//Set d_dddw_list
f_dddw_list2(This, 'req_code', 'ZM301')
//f_dddw_list2(This, 'comeplete_yn', 'ZM301')

//dw_cond.reset()


end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_add_service_prc_mobile
integer x = 3291
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_add_service_prc_mobile
integer x = 3598
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_add_service_prc_mobile
integer width = 3058
integer height = 376
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_add_service_prc_mobile
integer y = 408
integer height = 892
string dataobject = "b1dw_inq_add_service_prc_mobile"
end type

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
	//p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If
end event

event dw_master::ue_init;//Set d_dddw_list
f_dddw_list2(This, 'svc_req_mst_req_code', 'ZM301')
end event

event dw_master::buttonclicked;string ls_req_code


dw_cond.AcceptText()

//ls_req_code = dw_cond.object.req_code[1]
ls_req_code = this.object.svc_req_mst_req_code[row]

If dwo.name = "b_proc" Then
	
	if ls_req_code = 'HOTBIL' THEN
		
		iu_cust_msg 				= CREATE u_cust_a_msg
		iu_cust_msg.is_pgm_name = "개통처 해지정산내역"
		iu_cust_msg.ib_data[1]  = FALSE
		iu_cust_msg.is_data[1]  = "CloseWithReturn"
		iu_cust_msg.il_data[1]  = row  		//현재 row
		iu_cust_msg.idw_data[1] = dw_master
		iu_cust_msg.is_data[2]  = ls_req_code
		
		//핫빌 해지정산내역을 입력하기 위한 팝업 연결
		OpenWithParm(mobile_reg_svc_req_hot, iu_cust_msg)
		DESTROY iu_cust_msg
		
		//재조회
		dw_master.reset()
		dw_detail.reset()
		this.TriggerEvent("ue_ok")

	else //부가서비스 신청/해지
		
			Parent.Trigger Event ue_process(row)
			
	End If

end if
end event

event dw_master::clicked;Long ll_selected_row,ll_old_selected_row
Int li_rc

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

//If row > 0 Then
	//dw_detail 조회
	//If dw_detail.Trigger Event ue_retrieve(ll_selected_row) < 0 Then
	
	
	If dw_detail.Trigger Event ue_retrieve(row) < 0 Then
		Return
	End If	

end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_add_service_prc_mobile
integer y = 1344
integer width = 4165
integer height = 644
boolean enabled = false
string dataobject = "b1dw_reg_add_service_req_mobile"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)

end event

event dw_detail::ue_retrieve;String	ls_where, ls_contractseq, ls_priceplan, ls_req_code
String 	ls_partner, ls_sn_partner, ls_settle_partner, ls_customerid
Long		ll_contractseq, ll_rows = 0, ll_seqno

//Retrieve
If al_select_row > 0 Then
	
	//Get Search Condition
	ll_contractseq    = dw_master.Object.svc_req_mst_contractseq[al_select_row]
	ls_priceplan      = dw_master.Object.validinfo_priceplan[al_select_row]	
	ls_settle_partner = dw_master.Object.svc_req_mst_to_shop[al_select_row]	
	ls_req_code 		= dw_master.Object.svc_req_mst_req_code[al_select_row]	
	ll_seqno 			= dw_master.Object.svc_req_mst_reqno[al_select_row]	
	ls_customerid		= dw_master.Object.svc_req_mst_customerid[al_select_row]	
	
	if ls_req_code = 'HOTBIL' then //핫빌해지정산
		dw_detail.dataobject = 'b1dw_reg_add_service_req_hotbil'
		dw_detail.settransobject(SQLCA)
		ll_rows = dw_detail.Retrieve(ll_seqno, ls_customerid,ll_contractseq )	
		If ll_rows < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rows = 0 Then
			//f_msg_info(1000, Title, "")
			//Return 1
		End If
		dw_detail.enabled = true
		
	else  //부가서비스 신청, 해지
	   dw_detail.dataobject = 'b1dw_reg_add_service_req_mobile'
		dw_detail.settransobject(SQLCA)
		ll_rows = dw_detail.Retrieve(ll_contractseq, ls_priceplan, ls_settle_partner)	
		If ll_rows < 0 Then
			f_msg_usr_err(2100, Parent.Title, "Retrieve()")
			Return -1
		ElseIf ll_rows = 0 Then
			f_msg_info(1000, Title, "")
			//Return 1
		End If
		dw_detail.enabled = false
	end if
End if



Return 0
end event

event dw_detail::ue_init;//체크박스 숨김처리
this.Modify('selection.visible= "0" compute_1.visible= "0" ')
end event

event dw_detail::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_add_service_prc_mobile
boolean visible = false
integer y = 2484
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_add_service_prc_mobile
boolean visible = false
integer y = 2484
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_add_service_prc_mobile
boolean visible = false
integer x = 32
integer y = 2484
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_add_service_prc_mobile
integer x = 32
integer y = 2052
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_add_service_prc_mobile
integer y = 1308
end type

