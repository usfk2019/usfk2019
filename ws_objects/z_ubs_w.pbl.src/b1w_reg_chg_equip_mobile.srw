$PBExportHeader$b1w_reg_chg_equip_mobile.srw
$PBExportComments$[lys] 모바일 기변 관리
forward
global type b1w_reg_chg_equip_mobile from w_a_reg_m_m
end type
end forward

global type b1w_reg_chg_equip_mobile from w_a_reg_m_m
integer width = 4389
integer height = 2852
end type
global b1w_reg_chg_equip_mobile b1w_reg_chg_equip_mobile

type variables
String is_operator, is_operatornm
end variables

on b1w_reg_chg_equip_mobile.create
call super::create
end on

on b1w_reg_chg_equip_mobile.destroy
call super::destroy
end on

event open;call super::open;//postEvent("resize")


dw_cond.SetColumn("customerid")
dw_cond.SetFocus()

end event

event ue_ok;call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_validkey, ls_operator

//Condition
ls_validkey   = fs_snvl(dw_cond.Object.validkey[1], "")
ls_customerid = fs_snvl(dw_cond.Object.customerid[1], "")
ls_operator = fs_snvl(dw_cond.Object.operator[1], "")

If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return
If f_nvl_chk(dw_cond, 'customerid', 1, ls_customerid, '') = False Then Return


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

//Retrieve
dw_master.is_where = ls_where
ll_rows = dw_master.retrieve()

IF ll_rows < 0 THEN
	p_reset.TriggerEvent("ue_enable")
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN	
	p_reset.TriggerEvent("ue_enable")
	f_msg_info(1000, Title, "")
END IF

end event

event ue_reset;call super::ue_reset;//조회조건 초기화
dw_cond.object.partner[1]    = GS_SHOPID
dw_cond.Object.validkey[1]   = ""
dw_cond.Object.customerid[1] = ""
//dw_cond.Object.name[1]       = ""
dw_cond.Object.operator[1]   = is_operator
dw_cond.Object.operatornm[1] = is_operatornm

RETURN 0
end event

event ue_extra_save;
Long		ll_rows, ll_rowcnt, ll_master_row
String	ls_itemcod
String   ls_partner, ls_operator, ls_customerid, ls_sn_partner, ls_serial_hw, ls_model_hw, ls_sn_partner_new
String   ls_serialno, ls_contno_new, ls_selfequip_yn, ls_return_yn, ls_return_reason, ls_sale_flag_hw, ls_ref_desc, ls_remark
Long     ll_adseq, ll_contractseq, ll_orderno, ll_adseq_new


//장비가 조회되었을때만
If dw_detail.RowCount() > 0 Then
	//0. 필수 항목 체크
	//dw_cond
	ls_partner  = dw_cond.Object.partner[1]
	//ls_operator = dw_cond.Object.operator[1]
	
	//dw_detail
	//Old
	ll_master_row = dw_master.GetSelectedRow(0)
	ll_adseq			  = dw_detail.Object.adseq[1]
	ls_customerid    = fs_snvl(dw_master.Object.contractmst_customerid[ll_master_row], "")
	ll_contractseq   = Long(fs_snvl(String(dw_detail.Object.admst_contractseq[1]), '0'))
	ls_sn_partner    = fs_snvl(dw_detail.Object.admst_sn_partner[1], "")
	
	If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return -1
	//If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1	
	
	//New
	ls_serialno      = fs_snvl(dw_detail.Object.serialno_new[1], "")
	ls_contno_new    = fs_snvl(dw_detail.Object.contno_new[1], "")
	ls_selfequip_yn  = fs_snvl(dw_detail.Object.selfequip_yn[1], "")
	ls_return_yn     = fs_snvl(dw_detail.Object.return_yn[1], "")
	ls_return_reason = fs_snvl(dw_detail.Object.return_reason[1], "")	
	ls_remark        = fs_snvl(dw_detail.Object.remark_new[1], "")	
	
	ls_serial_hw	= fs_snvl(dw_detail.Object.serial_hw[1], "")
	ls_model_hw		= fs_snvl(dw_detail.Object.model_hw[1], "")
	
	
	IF ls_selfequip_yn = 'N' THEN  //UBS폰
		If f_nvl_chk(dw_detail, 'serialno_new', 1, ls_serialno, '') = False Then Return -1
		If f_nvl_chk(dw_detail, 'contno_new', 1, ls_contno_new, '') = False Then Return -1
	else   //자가폰
		If f_nvl_chk(dw_detail, 'serial_hw', 1, ls_serial_hw, '') = False Then Return -1
		If f_nvl_chk(dw_detail, 'model_hw', 1, ls_model_hw, '') = False Then Return -1
	END IF
	
	If f_nvl_chk(dw_detail, 'return_yn', 1, ls_return_yn, '')   = False Then Return -1
	
	
	//반납여부가 Y인데 사유가 Null이면 체크
	If ls_return_yn = 'Y' Then
		If f_nvl_chk(dw_detail, 'return_reason', 1, ls_return_reason, '') = False Then Return -1
	End If
	
	//신규 단말이 UBS 폰일때만
	If ls_selfequip_yn = 'N' Then
		//1. 신규단말의 대리점과, 조회조건 대리점이 일치하는지 체크 (UBS폰일때만)
		ls_sn_partner_new = dw_detail.object.sn_partner_new[1]
		
		If ls_partner <> ls_sn_partner_new Then
			f_msg_usr_err(9000, Title, "입력한 Shop과 단말판매 Shop이 다릅니다.")
			return -1
		End If
		
		//2. 신규 단말기 존재 여부 체크(UBS폰일때만)
		SELECT ADSEQ INTO :ll_adseq_new
		  FROM ADMST
		 WHERE 1=1
		   AND SERIALNO = :ls_serialno
			AND CONTNO   = :ls_contno_new
			;
		
		if isnull(string(ll_adseq_new)) or  string(ll_adseq_new) = '' then
			messagebox("신규단말정보", "신규단말 정보가 존재하지 않습니다.")
			return -1
	   end if
			
		
	End If
	
	//공통처리
	//1. Insert SVCORDER
	//GET SEQUENCE
	SELECT SEQ_ORDERNO.NEXTVAL INTO :ll_orderno FROM DUAL;
	If SQLCA.SQLCODE <> 0 Then
		f_msg_sql_err(SQLCA.SQLERRTEXT, "Get Sequence SEQ_ORDERNO.")
		Rollback;
		Return -1
	End If
	
	//INSERT INTO SVCORDER( STATUS  = '60', CONTRACTSEQ = '동일', CUSTOMERID = '동일')	
	INSERT INTO SVCORDER (
					ORDERNO,          REG_PREFIXNO, CUSTOMERID, ORDERDT,        REQUESTDT,      STATUS
				 , SVCCOD,           PRICEPLAN,    PRMTYPE,    REG_PARTNER,    SALE_PARTNER,   PARTNER
				 , REF_CONTRACTSEQ,  SELFEQUIP_YN
				 , CRT_USER,         UPDT_USER,    CRTDT,      UPDTDT,         PGM_ID
				 , REMARK )
	     SELECT :ll_orderno,      REG_PREFIXNO, CUSTOMERID, TRUNC(SYSDATE), TRUNC(SYSDATE), '60'
              , SVCCOD,          PRICEPLAN,    PRMTYPE,    REG_PARTNER,    SALE_PARTNER,   PARTNER
              , CONTRACTSEQ,     :ls_selfequip_yn
              , :ls_operator,    :ls_operator, SYSDATE,    SYSDATE,        :gs_pgm_id[gi_open_win_no]
				  , :ls_return_reason 
	       FROM CONTRACTMST
		    WHERE 1=1
		      AND CONTRACTSEQ = :ll_contractseq
				;
	If SQLCA.SQLCODE <> 0 Then
		f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert SVCORDER Fail. (CONTRACTSEQ=" + String(ll_contractseq) + ")")
		Rollback;
		Return -1
	End If
	
	//이전장비처리
	if isnull(string(ll_adseq)) or string(ll_adseq) = '' then // 자가폰이다 
	    //messagebox("이전장비", "자가폰")
	else
		//UBS폰이다.
		//ACTION = '805', ACTDT = SYSDATE, STATUS = 'RT100', RETURNDT = SYSDATE, REFUND_TYPE = '수거사유', ORDERNO = SVCORDER.ORDERNO;
		INSERT INTO ADMSTLOG_NEW (
						ADSEQ,       SEQ,                  ACTION,      ACTDT,      IDATE,       FR_PARTNER
					 , TO_PARTNER,  CONTNO,               STATUS,      SALEDT,     SHOPID,      SALEQTY
					 , SALE_AMT,    SALE_SUM,             MODELNO,     CUSTOMERID, CONTRACTSEQ, ORDERNO
					 , RETURNDT,    REFUND_TYPE,          REMARK
					 , CRT_USER,    UPDT_USER,            CRTDT,       UPDTDT,     PGM_ID) 
			  SELECT 
						ADSEQ, 		 SEQ_ADMSTLOG.NEXTVAL, '805',       SYSDATE,    IDATE,       SN_PARTNER
					 , TO_PARTNER,  CONTNO,               decode(:ls_return_yn, 'Y','RT100', status),     SALEDT,     MV_PARTNER,  1
					 , SALE_AMT, 	 0,                    MODELNO,     CUSTOMERID, CONTRACTSEQ, :ll_orderno
					 , decode(:ls_return_yn, 'Y',sysdate, RETDT),     :ls_return_reason,    REMARK
					 , :gs_user_id, :gs_user_id,          SYSDATE,     SYSDATE,    :gs_pgm_id[gi_open_win_no]
				 FROM ADMST
				WHERE 1=1
				  AND ADSEQ = :ll_adseq
				  ;
				  
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert ADMSTLOG_NEW Fail. (ADSEQ=" + String(ll_adseq) + ")")
			Rollback;
			Return -1
		End If			  
		
		//3. Update ADMST : 이전장비
		UPDATE ADMST 
			SET STATUS      = decode(:ls_return_yn, 'Y','RT100', status)
			  , USE_YN      = decode(:ls_return_yn, 'Y','Y', 'N') //사용가능여부
			  , RETDT       = decode(:ls_return_yn, 'Y',SYSDATE, RETDT)
			  , CONTRACTSEQ = :ll_contractseq
			  , CUSTOMERID  = :ls_customerid
			  , UPDT_USER   = :ls_operator
			  , UPDTDT      = SYSDATE
		 WHERE 1=1
			AND ADSEQ       = :ll_adseq
			;
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Update ADMST Fail. (ADSEQ=" + String(ll_adseq) + ")")
			Rollback;
			Return -1
		End If
	end if
		
	
	
	If ls_selfequip_yn = 'N' Then  //신규 단말이 UBS 폰일때만
		
		//1. 신규장비 정보 갱신
		//Update ADMST
		UPDATE ADMST 
		   SET STATUS      = 'SG100'  //Selling Goods
			  //, USE_YN      = 'N'
			  , CUSTOMERID  = :ls_customerid
			  , CONTRACTSEQ = :ll_contractseq
			  , ORDERNO     = :ll_orderno
			  , REMARK      = :ls_remark
			  , UPDT_USER   = :ls_operator
			  , UPDTDT      = SYSDATE
       WHERE 1=1
		   AND ADSEQ       = :ll_adseq_new
			;
			
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "UPDATE ADMST Fail. (ADSEQ=" + String(ll_adseq_new) + ")")
			Rollback;
			Return -1
		End If
		
		//2. Insert ADMSTLOG_NEW : 변경후 장비
		//ACTION = '805', ACTDT = SYSDATE,  STATUS = 'SG100', ORDERNO = SVCORDER.ORDERNO;
		INSERT INTO ADMSTLOG_NEW (
						ADSEQ,       SEQ,                  ACTION,      ACTDT,      IDATE,       FR_PARTNER
					 , TO_PARTNER,  CONTNO,               STATUS,      SALEDT,     SHOPID,      SALEQTY
					 , SALE_AMT,    SALE_SUM,             MODELNO,     CUSTOMERID, CONTRACTSEQ, ORDERNO
					 , RETURNDT,    REFUND_TYPE,          REMARK
					 , CRT_USER,    UPDT_USER,            CRTDT,       UPDTDT,     PGM_ID) 
			  SELECT 
						ADSEQ, 		 SEQ_ADMSTLOG.NEXTVAL, '805',       SYSDATE,    IDATE,       SN_PARTNER
					 , TO_PARTNER,  CONTNO,               'SG100',     SALEDT,     MV_PARTNER,  1
					 , SALE_AMT, 	 0,                    MODELNO,     CUSTOMERID, CONTRACTSEQ, :ll_orderno
					 , RETDT,       NULL,    				  REMARK
					 , :gs_user_id, :gs_user_id,          SYSDATE,     SYSDATE,    :gs_pgm_id[gi_open_win_no]
				 FROM ADMST
				WHERE 1=1
				  AND ADSEQ = :ll_adseq_new
				  ;
				  
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert ADMSTLOG_NEW Fail. (ADSEQ=" + String(ll_adseq) + ")")
			Rollback;
			Return -1
		End If	
	Else
		//자가폰일때
		//장비임대코드(customer_hw)
		ls_sale_flag_hw = fs_get_control("E1", "A710", ls_ref_desc)		
		
		//1. Insert CUSTOMER_HW
		//INSERT CUSTOMER_HW
		 INSERT INTO CUSTOMER_HW (
						HWSEQ
						, RECTYPE,         CUSTOMERID,     SALE_FLAG,        ADTYPE,  SERIALNO,    MODELNM
						, REMARK,          ORDERNO,        ITEMCOD        
					  , CRT_USER,        UPDT_USER,      CRTDT,            UPDTDT,  PGM_ID
						, CONTRACTSEQ) 
			 VALUES ( 
						SEQ_CUSTOMERHWNO.NEXTVAL
						, 'A',                  :ls_customerid, :ls_sale_flag_hw, 'PRT01',   upper(:ls_serial_hw), upper(:ls_model_hw)
						, :ls_remark,            :ll_orderno,    NULL
					 , :ls_operator,    :ls_operator,   SYSDATE,          SYSDATE, :gs_pgm_id[gi_open_win_no]
					 , :ll_contractseq
						);
		If SQLCA.SQLCODE <> 0 Then
			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert CUSTOMER_HW Fail.")
			Rollback;
			Return -1
		End If					 
	End If
Else
	Return -1
End If

//No Error
RETURN 0
end event

event ue_save;Constant Int LI_ERROR = -1
Long	ll_mst_row
//Int li_return

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

p_save.TriggerEvent("ue_disable")

//ii_error_chk = 0
Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_chg_equip_mobile
integer y = 80
integer width = 2683
integer height = 176
string dataobject = "b1dw_cnd_reg_chg_equip_mobile"
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
			ls_paydt_1,			ls_sysdate,			ls_paydt_c
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
		SELECT EMPNM INTO :ls_empnm
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
		
		is_operator   = data
		is_operatornm = ls_empnm

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

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_chg_equip_mobile
integer x = 2907
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_chg_equip_mobile
integer x = 3214
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_chg_equip_mobile
integer width = 2757
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_chg_equip_mobile
integer height = 596
string dataobject = "b1dw_inq_chg_equip_mobile"
end type

event dw_master::retrieveend;call super::retrieveend;If rowcount > 0 Then
	If dw_detail.Trigger Event ue_retrieve(1) < 0 Then
		Return
	End If
	
	p_ok.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	dw_detail.SetFocus()	
	
	dw_cond.Enabled = False

End If

end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_chg_equip_mobile
integer y = 964
integer width = 4165
integer height = 1564
string dataobject = "b1dw_reg_chg_equip_mobile"
end type

event dw_detail::constructor;call super::constructor;String ls_modify

SetRowFocusIndicator(off!)


end event

event dw_detail::ue_retrieve;String	ls_where, ls_contractseq, ls_customerid
String 	ls_partner, ls_sn_partner
Long		ll_rows = 0

//Retrieve
If al_select_row > 0 Then
	//Get Search Condition
	ls_contractseq = String(dw_master.Object.contractseq[al_select_row])
	ls_customerid  = dw_master.Object.contractmst_customerid[al_select_row]
	
	If ls_contractseq <> "" Then
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "cont.contractseq = '" + ls_contractseq + "'"		
	Else
		Return -1
	End If
	
	If ls_customerid <> "" Then
		ls_where += " AND "
		ls_where += "cont.customerid = '" + ls_customerid + "'"
		ls_where += " AND "
		ls_where += "rownum = 1 "
	Else
		Return -1
	End If	

	dw_detail.is_where = ls_where		
	ll_rows = dw_detail.Retrieve()	
	If ll_rows < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_rows = 0 Then
		//f_msg_info(1000, Title, "")
		this.insertrow(0)
		this.object.admst_contractseq[1] = long(ls_contractseq)
		this.SetItemStatus(1, 0, Primary!, NotModified!)
		//Return 1
	End If
End if


p_save.TriggerEvent("ue_enable")

Return 0
end event

event dw_detail::ue_init();call super::ue_init;//f_dddw_list_ag2(This, 'add_itemmst_colnm' , 'VALIDINFO', 'SVC_%')
//신규 장비상태
f_dddw_list2(This, 'status_new', 'B814')

//기존장비 반납 사유
f_dddw_list2(This, 'return_reason', 'ZM500')
end event

event dw_detail::retrieveend;//조회후 초기값 설정
If rowcount > 0 Then
	this.Object.selfequip_yn[1] = 'N'
	this.SetItemStatus(1, 0, Primary!, NotModified!)
	this.setColumn("contno_new")
	this.setRow(1)
	this.scrollToRow(1)
	this.setFocus()	
End If

end event

event dw_detail::itemchanged;call super::itemchanged;String ls_fcol, ls_serial_new, ls_model_new, ls_status_new, ls_current_contno, ls_sn_partner_new
string ls_status, ls_status2, ls_desc

If row < 1 Then Return 1

Choose case dwo.name 
	case 'selfequip_yn'

//			//자가폰여부에 따라 설정 변경
//			If data = 'N' Then
//				//폰선택(UBS) > Contno(바코드인식) > Serialno > 수거여부 > 수거사유> Remark
//				ls_fcol = "contno_new"
//				this.SetTabOrder("contno_new", 20)
//				this.SetTabOrder("serialno_new", 30)
//				this.SetTabOrder("return_yn", 40)
//				this.SetTabOrder("return_reason", 50)
//				this.SetTabOrder("remark_new", 60)
//				this.SetTabOrder("modelno_new", 70)
//				this.SetTabOrder("serial_hw", 0)
//				this.SetTabOrder("model_hw", 0)	
//				
//				this.Object.serialno_new.edit.case = "any"
//				this.Object.modelno_new.edit.case = "any"		
//			Else
//				//폰선택(자가폼) > upper(serialno) > upper(Model) > Remark(유심정보등록)
//				ls_fcol = "serial_hw"
//				this.SetTabOrder("serial_hw", 20)
//				this.SetTabOrder("model_hw", 30)	
//				this.SetTabOrder("remark_new", 40)
//				this.SetTabOrder("contno_new", 0)
//				this.SetTabOrder("serialno_new", 0)
//				this.SetTabOrder("return_yn", 60)
//				this.SetTabOrder("return_reason", 70)
//				
//				this.Object.serialno_new.edit.case = "upper"
//				this.Object.modelno_new.edit.case = "upper"
//			End If
//			
//			this.setColumn(ls_fcol)
//			this.setRow(1)
//			this.scrollToRow(1)
//			this.setFocus()	
//			
	case	'contno_new'
		
		   ls_status = fs_get_control("E1", "A102", ls_desc)// Retrun goods (판매가능상태)
			ls_status2= fs_get_control("E1", "A104", ls_desc)// Entering goods (판매가능상태)
		
		   SELECT SERIALNO, MODELNO, STATUS, SN_PARTNER INTO :ls_serial_new, :ls_model_new, :ls_status_new, :ls_sn_partner_new
			FROM ADMST
			WHERE CONTNO = :data
			  and    status in ( :ls_status, :ls_status2 ) ;
			  
						
			ls_current_contno = this.object.admst_contno[1]
			
			if data = ls_current_contno then  
				messagebox("확인", "변경전 과 후의 CONTNO 가 동일하여 처리할 수 없습니다.")
				return -1
			end if
			
			If isnull(ls_serial_new) or ls_serial_new = '' Then	
				f_msg_usr_err(201, Title, "해당장비는 판매 가능상태가 아닙니다.")
				Return - 1
			End If
			
			this.object.serialno_new[1] = ls_serial_new
			this.object.modelno_new[1] = ls_model_new
			this.object.status_new[1] = ls_status_new
			this.object.sn_partner_new[1] = ls_sn_partner_new
			
			
End Choose


end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_chg_equip_mobile
boolean visible = false
integer y = 2396
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_chg_equip_mobile
boolean visible = false
integer y = 2396
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_chg_equip_mobile
integer x = 32
integer y = 2588
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_chg_equip_mobile
integer x = 617
integer y = 2588
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_chg_equip_mobile
integer y = 924
end type

