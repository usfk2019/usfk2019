$PBExportHeader$b1w_reg_add_service_req_mobile.srw
$PBExportComments$부가서비스 등록/해지 신청 - 2015.03.12. lys
forward
global type b1w_reg_add_service_req_mobile from w_a_reg_m_m
end type
end forward

global type b1w_reg_add_service_req_mobile from w_a_reg_m_m
integer width = 4389
integer height = 2312
end type
global b1w_reg_add_service_req_mobile b1w_reg_add_service_req_mobile

type variables
String is_operator, is_operatornm, is_partner
end variables

on b1w_reg_add_service_req_mobile.create
call super::create
end on

on b1w_reg_add_service_req_mobile.destroy
call super::destroy
end on

event open;call super::open;//postEvent("resize")
dw_cond.SetFocus()
dw_cond.SetColumn("validkey")
end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_validkey,ls_contractseq, ls_operator

//Condition
ls_validkey    = fs_snvl(dw_cond.Object.validkey[1], "")
ls_customerid  = fs_snvl(dw_cond.Object.customerid[1], "")
ls_contractseq = fs_snvl(dw_cond.Object.contractseq[1], "")
ls_operator 	= fs_snvl(dw_cond.object.operator[1],"")

//Dynamic SQL
ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "con.customerid = '" + ls_customerid + "' "
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "val.validkey ='" + ls_validkey + "' "
END IF

IF ls_contractseq <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "con.contractseq ='" + ls_contractseq + "' "
END IF

//고객번호, 인증키, 계약번호 모두가 Null이면 리턴.
If ls_customerid = "" AND ls_validkey = "" AND ls_contractseq = "" Then
	f_msg_usr_err(9000, Title, "다음 조회조건 중 한가지 이상을 입력하여 주십시오. (Customer ID or ContractSeq. or Phone Number)")
	return
End If

if ls_customerid = "" then
	f_msg_usr_err(9000, Title, "Customerid 를 입력하여 주십시오.")
	return
end if

if ls_operator = "" then
	f_msg_usr_err(9000, Title, "OPERATOR를 입력하여 주십시오.")
	return
end if


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
dw_cond.object.partner[1]    = GS_SHOPID
//dw_cond.Object.validkey[1]   = ""
//dw_cond.Object.customerid[1] = ""
//dw_cond.Object.name[1]       = ""
dw_cond.Object.operator[1]   = is_operator
dw_cond.Object.operatornm[1] = is_operatornm
dw_cond.Object.partner[1]    = is_partner

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

event ue_extra_save;Long		ll_mst_row, ll_det_rowcnt, i, ll_contractseq, ll_contractseq_ori
String	ls_partner, ls_operator, ls_selection, ls_itemcod, ls_request_status, ls_req_code, ls_customerid, ls_ins_yn, ls_settle_partner
Date		ld_bil_fromdt, ld_bil_todt

//Get Mst RowCount
ll_mst_row = dw_master.GetSelectedRow(0)

IF ll_mst_row < 1 THEN Return -1


//Get Det RowCount
ll_det_rowcnt = dw_detail.RowCount()

IF ll_det_rowcnt < 1 THEN Return -1


//Condition
ls_partner  = dw_cond.Object.partner[1]
ls_operator = dw_cond.Object.operator[1]

If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return -1
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1

//Get Mst Info
ls_customerid      = dw_master.Object.contractmst_customerid[ll_mst_row]
ll_contractseq_ori = dw_master.Object.contractseq[ll_mst_row]
ls_settle_partner  = dw_master.object.contractmst_settle_partner[ll_mst_row]



//Row별 처리
FOR i=1 TO ll_det_rowcnt

	ls_selection      = dw_detail.Object.selection[i]
	ls_itemcod        = dw_detail.Object.itemcod[i]
	ld_bil_fromdt     = Date(dw_detail.Object.bil_fromdt[i])
	ld_bil_todt       = Date(dw_detail.Object.bil_todt[i])
	ls_request_status = dw_detail.Object.request_status[i]
	ls_req_code       = dw_detail.Object.req_code[i]				//SVCADD, SVCDEL
	ll_contractseq    = dw_detail.Object.contractseq[i]
//	ls_settle_partner = dw_detail.Object.settle_partner[i]
	
//	If f_nvl_chk(dw_detail, 'settle_partner', i, ls_settle_partner, '개통처를 선택하세요') = False Then
//		Rollback;
//		Return -1
//	End If
	
	//유효성 체크
	IF ls_request_status = "Y" THEN CONTINUE;
	
	//개통처세팅
	if isnull(ls_settle_partner) or ls_settle_partner = '' then
	         
				//1.admst에서 찾는다.
				SELECT REF_CODE1 INTO :ls_settle_partner
				FROM SYSCOD2T
				WHERE GRCODE = 'B816'
				  AND CODE = (   select entstore from admst
                where customerid = :ls_customerid
                 and contractseq = :ll_contractseq);
					  
					  
			  if isnull(ls_settle_partner) or ls_settle_partner = '' then 
				      //2.admstlog_new에서 찾는다.
				      SELECT REF_CODE1 INTO :ls_settle_partner
                    FROM SYSCOD2T
                    WHERE GRCODE = 'B816'
                      AND CODE = (  select entstore from admst where adseq in ( select distinct adseq from admstlog_new
                         where customerid =  :ls_customerid
                          and contractseq = :ll_contractseq));
			  end if
			  if isnull(ls_settle_partner) or ls_settle_partner = '' then 
				      //3. admstlog_new 에도 정보가 없으면 메세지 띄운다.
			  			messagebox("확인", "개통처가 입력되지 않았습니다. 관리자에게 연락하세요.")
				else
					dw_detail.Object.settle_partner[i] = ls_settle_partner
			  end if
	end if
	
	
	//취소건 체크
	IF ls_selection = "N" AND IsNull(ll_contractseq) = False THEN
		ls_ins_yn   = 'Y'
		ld_bil_todt = Date(fdt_get_dbserver_now())
		
	//등록건
	ELSEIF ls_selection = "Y" AND IsNull(ll_contractseq) or string(ld_bil_todt) <> ''  THEN
		ls_ins_yn     = 'Y'
		ld_bil_fromdt = Date(fdt_get_dbserver_now())
		
	ELSE
		ls_ins_yn = 'N'
	END IF	
	
	//부가서비스 취소 신청
	IF ls_ins_yn = "Y" THEN
		
		INSERT INTO SVC_REQ_MST (
						REQNO
					 , REQ_CODE,     REQDT,          CUSTOMERID,     CONTRACTSEQ,         ITEMCOD,     BIL_FROMDT
					 , BIL_TODT,     COMEPLETE_YN,   FR_SHOP,        FR_OPER,             FR_CRTDT,    TO_SHOP )
			  VALUES (
						SEQ_SVC_REQ_MST.NEXTVAL
					 , :ls_req_code, TRUNC(SYSDATE), :ls_customerid, :ll_contractseq_ori, :ls_itemcod, :ld_bil_fromdt
					 , :ld_bil_todt, 'N',            :ls_partner,    :ls_operator,        SYSDATE,     :ls_settle_partner
					 )
					 ;
		IF SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert SVC_REQ_MST Fail. (CONTRACTSEQ=" + String(ll_contractseq_ori) + ")")
			Rollback;
			Return -1
		END IF
	END IF
NEXT

//No Error
RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_add_service_req_mobile
integer y = 64
integer width = 3145
integer height = 212
string dataobject = "b1dw_cnd_add_service_req_mobile"
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
		FROM   SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
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

event dw_cond::ue_init();call super::ue_init;This.is_help_win[1] 		= "SSRT_HLP_CUSTOMER"
This.idwo_help_col[1] 	= dw_cond.object.customerid
This.is_data[1] 			= "CloseWithReturn"

//dw_cond.reset()


end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_add_service_req_mobile
integer x = 3415
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_add_service_req_mobile
integer x = 3721
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_add_service_req_mobile
integer width = 3186
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_add_service_req_mobile
integer height = 644
string dataobject = "b1dw_inq_add_service_req_mobile"
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

event dw_master::clicked;//

Call Super::clicked
end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_add_service_req_mobile
integer y = 1008
integer width = 4165
integer height = 896
string dataobject = "b1dw_reg_add_service_req_mobile"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)

end event

event dw_detail::ue_retrieve;String	ls_where, ls_contractseq, ls_priceplan
String 	ls_partner, ls_sn_partner, ls_settle_partner
Long		ll_contractseq, ll_rows = 0
integer li_cnt

//Retrieve
If al_select_row > 0 Then
	//Get Search Condition
	ll_contractseq    = dw_master.Object.contractseq[al_select_row]
	ls_priceplan      = dw_master.Object.priceplan[al_select_row]	
	ls_settle_partner = dw_master.Object.contractmst_settle_partner[al_select_row]	
	
	ll_rows = dw_detail.Retrieve(ll_contractseq, ls_priceplan)	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		f_msg_info(1000, Title, "")
		//Return 1
	End If
End if

//이미 오늘 신청중인 계약이면 save안되게
select count(*) into :li_cnt
from svc_req_mst
where contractseq = :ll_contractseq
  and reqdt = trunc(sysdate)
  and req_code in ('SVCADD','SVCDEL');  


//1건이상 조회되면 조회버튼 활성화
If ll_rows > 0   and li_cnt = 0 Then
//If ll_rows > 0  Then
	p_save.TriggerEvent("ue_enable")
//	//Shop
//	ls_partner = fs_snvl(dw_cond.Object.partner[1], "")
//	
//	//장비판매 대리점
//	ls_sn_partner = fs_snvl(this.Object.admst_sn_partner[1], "")
//	
//	If ls_partner <> ls_sn_partner Then
//		p_save.TriggerEvent("ue_disable")
//		f_msg_usr_err(9000, Title, "입력한 Shop과 단말판매 Shop이 다릅니다.")
//		Return -1
//	End If
Else
	p_save.TriggerEvent("ue_disable")
End If

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_add_service_req_mobile
boolean visible = false
integer y = 2396
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_add_service_req_mobile
boolean visible = false
integer y = 2396
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_add_service_req_mobile
integer x = 32
integer y = 1952
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_add_service_req_mobile
integer x = 617
integer y = 1952
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_add_service_req_mobile
integer y = 968
end type

