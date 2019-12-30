$PBExportHeader$mobile_reg_service_req_mobile.srw
$PBExportComments$모바일해지정산신청
forward
global type mobile_reg_service_req_mobile from w_a_reg_m_m
end type
end forward

global type mobile_reg_service_req_mobile from w_a_reg_m_m
integer width = 4389
integer height = 2288
end type
global mobile_reg_service_req_mobile mobile_reg_service_req_mobile

type variables
String is_operator, is_operatornm, is_partner
end variables

on mobile_reg_service_req_mobile.create
call super::create
end on

on mobile_reg_service_req_mobile.destroy
call super::destroy
end on

event open;call super::open;//postEvent("resize")
dw_cond.SetFocus()
dw_cond.SetColumn("validkey")
end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_validkey,ls_contractseq, ls_req_code, ls_reqdt, ls_operator

//Condition
ls_validkey    = fs_snvl(dw_cond.Object.validkey[1], "")
ls_customerid  = fs_snvl(dw_cond.Object.customerid[1], "")
ls_contractseq = fs_snvl(dw_cond.Object.contractseq[1], "")
ls_req_code = dw_cond.object.req_code[1]
ls_reqdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_operator  = fs_snvl(dw_cond.object.operator[1],"")

//Dynamic SQL
ls_where = ""

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "con.customerid = '" + ls_customerid + "' "
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "val.validkey ='" + ls_validkey + "'"
END IF

IF ls_contractseq <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(con.contractseq) = '" + ls_contractseq + "' "
END IF

//고객번호, 인증키, 계약번호 모두가 Null이면 리턴.
If ls_customerid = "" AND ls_validkey = "" AND ls_contractseq = "" Then
	f_msg_usr_err(9000, Title, "다음 조회조건 중 한가지 이상을 입력하여 주십시오. (Customer ID or ContractSeq. or Phone Number)")
	RETURN
End If

if ls_customerid = "" then
	f_msg_usr_err(9000, Title, "Customerid 를 입력하여 주십시오.")
	return
end if

if ls_operator = "" then
	f_msg_usr_err(9000, Title, "OPERATOR를 입력하여 주십시오.")
	return
end if


//MESSAGEBOX("", ls_where)
//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

if ll_rows > 0 then
	dw_detail.retrieve(ls_customerid, ls_req_code, ls_reqdt, ls_contractseq)
end if

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
string ls_customerid, ls_req_code, ls_reqdt, ls_contractseq

ls_customerid = dw_cond.object.customerid[1]
ls_req_code = dw_cond.object.req_code[1]
ls_reqdt = String(fdt_get_dbserver_now(),'yyyymmdd')
ls_contractseq = fs_snvl(dw_cond.Object.contractseq[1], "")

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

//dw_master 재조회
//ll_mst_row = dw_master.GetSelectedRow(0)

//신청내역 조회
dw_detail.retrieve(ls_customerid, ls_req_code, ls_reqdt, ls_contractseq)

p_save.TriggerEvent("ue_disable")
//ii_error_chk = 0
Return 0

end event

event ue_extra_save;
Long		ll_mst_row, ll_rowcnt, i, ll_contractseq, ll_reqno
String	ls_partner, ls_operator, ls_chk, ls_req_code, ls_customerid,  ls_settle_partner


//IF ll_mst_row < 1 THEN Return -1


//Get mst RowCount
ll_rowcnt = dw_master.RowCount()

IF ll_rowcnt < 1 THEN Return -1


//Condition
ls_partner  = dw_cond.Object.partner[1]
ls_operator = dw_cond.Object.operator[1]
ls_req_code = dw_cond.Object.req_code[1]				//HOTBIL


If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return -1
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1

//Get seqno
SELECT SEQ_SVC_REQ_MST.NEXTVAL INTO :ll_reqno FROM DUAL;

IF SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "SELECT SEQ_SVC_REQ_MST Fail. (SEQ_SVC_REQ_MST.NEXTVAL)")
			Return -1
END IF


//Row별 처리
FOR i=1 TO ll_rowcnt

	ls_customerid      = dw_master.Object.customerid[i]
	ll_contractseq 	 = dw_master.Object.contractseq[i]
	ls_settle_partner  = dw_master.Object.settle_partner[i]
	ls_chk				 = dw_master.object.chk[i]
	
	IF ls_chk = "N" THEN CONTINUE;
	
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
			  end if
	end if
		
	//핫빌해지정산신청
	IF ls_chk = "Y" THEN
		
		INSERT INTO SVC_REQ_MST (
						REQNO
					 , REQ_CODE,     REQDT,          CUSTOMERID,     CONTRACTSEQ,      COMEPLETE_YN
					 , FR_SHOP,        FR_OPER,             FR_CRTDT,    TO_SHOP )
			  VALUES (
						:ll_reqno
					 , :ls_req_code, TRUNC(SYSDATE), :ls_customerid, :ll_contractseq, 			'N'
					 , :ls_partner,    :ls_operator,        SYSDATE,     :ls_settle_partner	 );
					 
		IF SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert SVC_REQ_MST Fail. (CONTRACTSEQ=" + String(ll_contractseq) + ")")
			Rollback;
			Return -1
		END IF
	END IF
NEXT



//No Error
RETURN 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within mobile_reg_service_req_mobile
integer y = 64
integer width = 3145
integer height = 288
string dataobject = "mobile_cnd_add_service_req_mobile"
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

type p_ok from w_a_reg_m_m`p_ok within mobile_reg_service_req_mobile
integer x = 3323
integer y = 152
end type

type p_close from w_a_reg_m_m`p_close within mobile_reg_service_req_mobile
integer x = 3630
integer y = 152
end type

type gb_cond from w_a_reg_m_m`gb_cond within mobile_reg_service_req_mobile
integer width = 3186
integer height = 372
end type

type dw_master from w_a_reg_m_m`dw_master within mobile_reg_service_req_mobile
integer y = 400
integer width = 4151
integer height = 644
string dataobject = "mobile_inq_add_service_req_mobile"
end type

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	p_ok.TriggerEvent("ue_disable")
	
//	p_insert.TriggerEvent("ue_enable")
//	p_delete.TriggerEvent("ue_enable")
	//p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
	
	dw_cond.Enabled = False
End If
end event

event dw_master::clicked;//
end event

event dw_master::itemchanged;string ls_req_code, ls_contractseq
integer li_cnt

ls_req_code = dw_cond.object.req_code[1]


choose case dwo.name
	case 'chk'
		if data = 'Y' then
			
			ls_contractseq = string(this.object.contractseq[row])
			
			select count(*) into :li_cnt
			from svc_req_mst
			where req_code = :ls_req_code
			  and reqdt = trunc(sysdate)
			  and contractseq = to_number(:ls_contractseq)
			  and comeplete_yn = 'N';
			  
			if li_cnt > 0 then
				messagebox("확인", "Contractseq: " + ls_contractseq + " 는 이미 현재일자에 신청되어 있습니다. 처리완료가 되면 다시 신청할 수 있습니다.")
				return 1
			end if
		end if
end choose

end event

event dw_master::itemerror;return 1
end event

type dw_detail from w_a_reg_m_m`dw_detail within mobile_reg_service_req_mobile
integer x = 37
integer y = 1080
integer width = 4165
integer height = 896
string dataobject = "mobile_service_request_info"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)

end event

event dw_detail::itemchanged;call super::itemchanged;
integer li_return
string ls_complete_yn, ls_req_code
long ll_reqno, ll_contractseq

choose case dwo.name
	case 'chk'
		
		ls_complete_yn = this.object.comeplete_yn[row]
		ll_reqno = this.object.reqno[row]
		ll_contractseq = this.object.contractseq[row]
		ls_req_code = this.object.req_code[row]
		
		if data = 'Y' and ls_complete_yn = 'N' then
			
			li_return = messagebox("확인", "미완료 건만 취소가능합니다. 신청내역을 취소하시겠습니까?", Question!,YesNo!, 1)
			if li_return = 1 then //신청취소
			
				delete from svc_req_mst
				where reqno = :ll_reqno
				  and reqdt = trunc(sysdate)
				  and req_code = :ls_req_code
				  and contractseq = :ll_contractseq
				  and comeplete_yn = 'N';
				  
				  IF SQLCA.SQLCODE <> 0 Then
								f_msg_sql_err(SQLCA.SQLERRTEXT, "DELETE SVC_REQ_MST Fail")
								rollback;
								Return -1
				  END IF
				  COMMIT;
				  this.deleterow(row)
				  
		   else  //선택취소
				return 1
			end if
		end if
end choose
end event

event dw_detail::itemerror;return 1
end event

event dw_detail::ue_init;//Set d_dddw_list
f_dddw_list2(This, 'req_code', 'ZM301')
end event

type p_insert from w_a_reg_m_m`p_insert within mobile_reg_service_req_mobile
boolean visible = false
integer y = 2396
end type

type p_delete from w_a_reg_m_m`p_delete within mobile_reg_service_req_mobile
boolean visible = false
integer x = 407
integer y = 2328
end type

type p_save from w_a_reg_m_m`p_save within mobile_reg_service_req_mobile
integer x = 32
integer y = 2032
end type

type p_reset from w_a_reg_m_m`p_reset within mobile_reg_service_req_mobile
integer x = 329
integer y = 2032
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within mobile_reg_service_req_mobile
integer x = 37
integer y = 1044
integer height = 36
end type

