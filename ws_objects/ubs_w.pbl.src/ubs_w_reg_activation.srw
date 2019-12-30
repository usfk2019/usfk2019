$PBExportHeader$ubs_w_reg_activation.srw
$PBExportComments$[jhchoi]서비스 신규 개통처리 - 2009.05.06
forward
global type ubs_w_reg_activation from w_a_reg_m_m
end type
type cb_1 from commandbutton within ubs_w_reg_activation
end type
type dw_add from datawindow within ubs_w_reg_activation
end type
end forward

global type ubs_w_reg_activation from w_a_reg_m_m
integer width = 3218
integer height = 2124
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
cb_1 cb_1
dw_add dw_add
end type
global ubs_w_reg_activation ubs_w_reg_activation

type variables
String is_priceplan		//Price Plan Code
String is_actstatus
Boolean ib_save
String is_date_allow_yn,	is_validstatus[]


String is_agent //개통처여부(개통처이면 'Y')
end variables

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_detail.GetRow()

lb_check = fb_save_required(dw_detail, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);
STRING	ls_activedt,		ls_bil_fromdt,		ls_sysdt,		ls_priceplan,		ls_svccod,			&
			ls_hostname,		ls_gubun_nm,		ls_siid_int,	ls_siid_tel, 		ls_validkey
BOOLEAN	lb_check
LONG		ll_rows,				ll_rc,				ll_svcctl_cnt,	ll_orderno,			ll_validcnt,		&
			ll_siid_cnt,		ll_ret_orderno,	ll_non_cnt,		ll_sum_cnt, 		ll_val_cnt, ll_non_valid_cnt, ll_equipcnt, ll_priceplan_cnt

dw_detail.AcceptText()

ls_activedt		= STRING(dw_detail.object.activedt[1],'yyyymmdd')
ls_bil_fromdt	= STRING(dw_detail.object.bil_fromdt[1],'yyyymmdd')
ls_sysdt			= STRING(fdt_get_dbserver_now(),'yyyymmdd')
ll_orderno		= dw_detail.object.svcorder_orderno[1]
ls_svccod		= dw_detail.object.svcorder_svccod[1]
ls_priceplan	= dw_detail.object.svcorder_priceplan[1]


If IsNull(ls_activedt) Then ls_activedt = ""
If ls_activedt = "" Then
	f_msg_usr_err(200, Title, "개통일자")
	dw_detail.SetFocus()
	dw_detail.SetColumn("activedt")
	ai_return = -1
	RETURN
End If

If IsNull(ls_bil_fromdt) Then ls_bil_fromdt = ""
If ls_bil_fromdt = "" Then
	f_msg_usr_err(200, Title, "과금시작일")
	dw_detail.SetFocus()
	dw_detail.SetColumn("bil_fromdt")
	ai_return = -1
	RETURN
End If

ls_svccod = dw_detail.object.svcorder_svccod[1]
ls_priceplan = dw_detail.object.svcorder_priceplan[1]


//개통일 check 여부 
IF b1fi_date_allow_chk_yn_v20(this.title,ls_svccod,ls_priceplan,is_date_allow_yn) < 0 Then
	ai_return = -1
	RETURN
End IF

////// 날짜 체크
If ls_activedt <> "" Then 
	lb_check = fb_chk_stringdate(ls_activedt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'개통일자의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("activedt")
		ai_return = -1
		RETURN
	End If
End if

If ls_bil_fromdt <> "" Then 
	lb_check = fb_chk_stringdate(ls_bil_fromdt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'과금시작일의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("bil_fromdt")
		ai_return = -1
		RETURN
	End If
	
	If ls_bil_fromdt < ls_activedt Then
		f_msg_usr_err(210, Title, "'과금시작일은 개통일보다 크거나 같아야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("bil_fromdt")
		ai_return = -1
		RETURN
	End If		
End if

//RQ-UBS-201303-03  동일 번호가 해지한 이력이 있으면 다음 날 처리하도록
string ls_todt

ls_validkey = dw_detail.object.validkey[1]

select  to_char(max(todt),'yyyymmdd') into :ls_todt
from validinfo
where validkey = :ls_validkey
  and status = '99'  /* 해지 */
  and to_char(todt,'yyyymmdd') > :ls_activedt; /* 해지일자 > 개통일자 */


If ls_todt > ls_activedt Then
		f_msg_usr_err(281, Title, ls_todt + ' ' + ls_activedt + "금일 해지된 전화번호입니다. 내일 해당 작업을 재처리 하거나, UBS관리자에게 요청하여 주세요")
		dw_detail.SetFocus()
		dw_detail.SetColumn("activedt")
		ai_return = -1
		RETURN
End If	
//RQ-UBS-201303-03  동일 번호가 해지한 이력이 있으면 다음 날 처리하도록

//모바일서비스 번호할당
SELECT COUNT(*) INTO :ll_val_cnt
FROM SYSCOD2T
WHERE GRCODE = 'ZM103'
AND    USE_YN = 'Y'
AND    CODE   = :ls_svccod;
//messagebox("", ls_svccod)

IF ll_val_cnt > 0 AND (ls_validkey = '' OR ISNULL(ls_validkey))  THEN
		f_msg_usr_err(200, Title, "'모바일 번호를 할당하고 진행하세요.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("validkey")
		ai_return = -1
		RETURN
END IF


SELECT COUNT(*) INTO :ll_siid_cnt
FROM   SYSCOD2T
WHERE  GRCODE = 'BOSS03'
AND    USE_YN = 'Y'
AND    CODE   = :ls_svccod;

//인증서비스 중에서도 인증받지 않는 가격정책이 있다. 체크한다.
SELECT COUNT(*) INTO :ll_non_cnt
FROM   SYSCOD2T
WHERE  GRCODE = 'BOSS04'
AND    USE_YN = 'Y'
AND    CODE   = :ls_priceplan;

IF ll_non_cnt > 0 THEN
	ll_siid_cnt = 0
END IF	

//인증 받지 않는 장비관리 서비스
SELECT COUNT(*) INTO :ll_non_valid_cnt
FROM SYSCOD2T
WHERE GRCODE = 'BOSS06'
AND USE_YN = 'Y'
AND CODE = :ls_svccod;

SELECT COUNT(*)  INTO :ll_priceplan_cnt
FROM SYSCOD2T A, PRICEPLANMST B, PRICEPLAN_EQUIP C
WHERE A.GRCODE = 'BOSS06'
    AND A.USE_YN = 'Y'
    AND A.CODE = :ls_svccod
    AND A.CODE = B.SVCCOD
    AND B.PRICEPLAN = C.PRICEPLAN
    AND C.PRICEPLAN = :ls_priceplan;

IF ll_priceplan_cnt > 0 THEN 
	
		SELECT count(*) into :ll_equipcnt
		FROM   EQUIPMST
		WHERE  ORDERNO = :ll_orderno;
		
		IF ll_equipcnt = 0 THEN
				f_msg_usr_err(201, Title, "장비연결이 필요한 서비스입니다. 장비연결 후 개통처리 하세요. ")
				dw_detail.SetFocus()
				ai_return = -1
				RETURN
		END IF
		
END IF

IF ll_non_valid_cnt > 0 then 
	ll_siid_cnt = 0
END IF	

IF ll_siid_cnt > 0 THEN
	
	SELECT VOIP_HOSTNAME, GUBUN_NM
	INTO   :ls_hostname,	:ls_gubun_nm
	FROM   PRICEPLANINFO
	WHERE  PRICEPLAN = :ls_priceplan;
	
	IF ISNULL(ls_hostname) THEN ls_hostname = ""
	IF IsNull(ls_gubun_nm) THEN ls_gubun_nm = ""
	
	IF ls_hostname = "VOCM" AND ls_gubun_nm = "전화" THEN				//vocm 의 경우!
		SELECT RELATED_ORDERNO INTO :ll_ret_orderno
		FROM   SVCORDER
		WHERE  ORDERNO = :ll_orderno;
		
		//2011.06.16 jhchoi 수정. vocm 전화는 인터넷 장비 따라가기에...인터넷 장비는 이미 '300' 이 되어있기 때문에 무조건 체크...
		ll_validcnt = 1
		//SELECT NVL(SUM(DECODE(VALID_STATUS, :is_validstatus[1], 0, 1)), 1) INTO :ll_validcnt
		//FROM   EQUIPMST
		//WHERE  ORDERNO = :ll_ret_orderno;
	ELSE
		SELECT NVL(SUM(DECODE(VALID_STATUS, :is_validstatus[1], 0, 1)), 1) INTO :ll_validcnt
		FROM   EQUIPMST
		WHERE  ORDERNO = :ll_orderno;
	END IF
	
	IF ll_validcnt > 0 THEN  //2010.10.12 jhchoi 수정. '200' 인 상태인 애들이 있으면 인증을 확인한다.
		IF ls_hostname = "VOCM" AND ls_gubun_nm = "전화" THEN				//vocm 의 경우!
			//전화 SIID
			SELECT SIID INTO :ls_siid_tel
			FROM   SIID
			WHERE  ORDERNO = :ll_orderno;
			
			SELECT SIID INTO :ls_siid_int
			FROM   SIID
			WHERE  ORDERNO = :ll_ret_orderno;
			
			SELECT SUM(CNT) INTO :ll_sum_cnt
			FROM ( SELECT COUNT(*) CNT
					 FROM   BC_AUTH AUTH
					 WHERE  AUTH.FLAG = '1'
					 AND    AUTH.SUBSNO = :ls_siid_int
					 AND    AUTH.MACADDRESS IN ( SELECT MAC_ADDR FROM EQUIPMST 
					 									  WHERE  ORDERNO = :ll_ret_orderno
														  UNION ALL
														  SELECT NVL(MAC_ADDR2, 'X') FROM EQUIPMST
														  WHERE   ORDERNO = :ll_ret_orderno )
					 UNION ALL
					 SELECT COUNT(*) CNT
					 FROM   BC_REG_SSW AUTH
					 WHERE  AUTH.FLAG = '1'
					 AND    AUTH.SUBSNO = :ls_siid_tel
					 AND    AUTH.MACADDRESS IN ( SELECT MAC_ADDR FROM EQUIPMST 
					 									  WHERE  ORDERNO = :ll_ret_orderno
														  UNION ALL
														  SELECT NVL(MAC_ADDR2, 'X') FROM EQUIPMST
														  WHERE   ORDERNO = :ll_ret_orderno ) );
					 
			IF ll_sum_cnt > 1 THEN //VOCM 은 전화, 인터넷 따로 인증받기에 최소 2개 
				UPDATE EQUIPMST
				SET    VALID_STATUS = :is_validstatus[1]
				WHERE  ORDERNO = :ll_ret_orderno;
					
				IF SQLCA.SQLCODE <> 0 THEN
					ROLLBACK;
					f_msg_usr_err(201, Title, "인증상태 UPDATE Error!")
					dw_detail.SetFocus()
					ai_return = -1
					RETURN					
				END IF			
			ELSE
				f_msg_usr_err(201, Title, "인증장비의 신규인증이 완료되지 않았습니다.")
				dw_detail.SetFocus()
				ai_return = -1
				RETURN
			END IF
			
		ELSEIF ll_non_valid_cnt > 0 THEN  //인증 받지 않는 장비관리 서비스(NEW CATV)
			
				UPDATE EQUIPMST
				SET    VALID_STATUS = :is_validstatus[1]
				WHERE  ORDERNO = :ll_ret_orderno;
					
				IF SQLCA.SQLCODE <> 0 THEN
					ROLLBACK;
					f_msg_usr_err(201, Title, "인증상태 UPDATE Error!")
					dw_detail.SetFocus()
					ai_return = -1
					RETURN					
				END IF	
				
		ELSE		
			SELECT SIID INTO :ls_siid_tel
			FROM   SIID
			WHERE  ORDERNO = :ll_orderno;
				
			SELECT SUM(CNT) INTO :ll_sum_cnt
			FROM ( SELECT COUNT(*) CNT
					 FROM   BC_AUTH AUTH
					 WHERE  AUTH.FLAG = '1'
					 AND    AUTH.SUBSNO = :ls_siid_tel
					 AND    AUTH.MACADDRESS IN ( SELECT MAC_ADDR FROM EQUIPMST 
					 									  WHERE  ORDERNO = :ll_orderno
														  UNION ALL
														  SELECT NVL(MAC_ADDR2, 'X') FROM EQUIPMST
														  WHERE   ORDERNO = :ll_orderno )
					 UNION ALL
					 SELECT COUNT(*) CNT
					 FROM   BC_REG_SSW AUTH
					 WHERE  AUTH.FLAG = '1'
					 AND    AUTH.SUBSNO = :ls_siid_tel
					 AND    AUTH.MACADDRESS IN ( SELECT MAC_ADDR FROM EQUIPMST 
					 									  WHERE  ORDERNO = :ll_orderno
														  UNION ALL
														  SELECT NVL(MAC_ADDR2, 'X') FROM EQUIPMST
														  WHERE   ORDERNO = :ll_orderno ) );	
														  
			IF ll_sum_cnt > 0 THEN
				UPDATE EQUIPMST
				SET    VALID_STATUS = :is_validstatus[1]
				WHERE  ORDERNO = :ll_orderno;
					
				IF SQLCA.SQLCODE <> 0 THEN
					ROLLBACK;
					f_msg_usr_err(201, Title, "인증상태 UPDATE Error!")
					dw_detail.SetFocus()
					ai_return = -1 
					RETURN					
				END IF			
			ELSE
				f_msg_usr_err(201, Title, "인증장비의 신규인증이 완료되지 않았습니다.")
				dw_detail.SetFocus()
				ai_return = -1 
				RETURN
			END IF
		END IF
	END IF		
END IF

ai_return = 0

RETURN
end event

on ubs_w_reg_activation.create
int iCurrent
call super::create
this.cb_1=create cb_1
this.dw_add=create dw_add
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
this.Control[iCurrent+2]=this.dw_add
end on

on ubs_w_reg_activation.destroy
call super::destroy
destroy(this.cb_1)
destroy(this.dw_add)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_svc_actprc_cl
	Desc.	: 	서비스개통처리
	Ver.	:	1.0
	Date	: 	2002.10.03
	Programer : Kim Eun Mi(kem)
--------------------------------------------------------------------------*/
DATE		ld_sysdate
STRING	ls_partner, ls_partnernm,	ls_ref_desc,	ls_temp,	ls_orderno,	ls_shop_type
LONG		ll_cnt
integer  li_count
long li_exist, ll_row
datawindowchild ldc_svccod
string ls_sql


is_agent = 'N'

ld_sysdate = Date(fdt_get_dbserver_now())
ib_save = False									//처리 여부

SELECT PARTNERNM, NVL(SHOP_TYPE, 'ETC') INTO :ls_partnernm, :ls_shop_type
FROM   PARTNERMST
WHERE  PARTNER = :gs_user_group
AND    ACT_YN = 'Y';

//개통처 확인/////////////////////////////////////////////////////////////////

SELECT COUNT(*) INTO :li_count
FROM SYSUSR1T
WHERE EMP_GROUP IN ( SELECT CODE FROM SYSCOD2T WHERE GRCODE = 'ZM300')
  AND EMP_ID = :gs_user_id;

IF li_count > 0 THEN
	is_agent = 'Y'
	dw_cond.object.partner.protect = 1  //샵수정 금지(타개통처 조회할 수 없음)
	
//	//svccod 개통처에 해당하는
//	li_exist 	= dw_cond.GetChild("svccod", ldc_svccod)		//DDDW 구함
//	If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 서비스")
//	   
//		ls_sql =  "SELECT svccod, "  + &
//						"svcdesc,  "  + &
//						"partner  "  + &
//					"FROM svcmst "  + &
//					"WHERE  svccod in (select code from syscod2t where grcode = 'ZM103')" 
//		
//		ldc_svccod.SetSqlselect(ls_sql)
//		messagebox("", ls_sql)
//		ldc_svccod.SetTransObject(SQLCA)
//		ll_row = ldc_svccod.Retrieve()
//		
//		IF ll_row < 0 THEN 				//디비 오류 
//			f_msg_usr_err(2100, Title, "svccod Retrieve()")
//			RETURN 
//		END IF				

END IF

//개통처 확인/////////////////////////////////////////////////////////////////

//SELECT COUNT(*) INTO :ll_cnt
//FROM   PARTNERMST
//WHERE  GROUP_ID = ( SELECT REF_CONTENT FROM SYSCTL1T WHERE MODULE = 'PI' AND REF_NO = 'A101' );
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title,"수행처 select")
//	Return -1
//End If

//인증장비 상태값 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E600", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_validstatus[])

//IF ll_cnt > 0 THEN	
//	dw_cond.Object.tech_shop[1] = gs_user_group
//	dw_cond.Object.partnernm[1] = ls_partnernm
//ELSE
//	dw_cond.Object.partner[1] = gs_user_group
//	dw_cond.Object.partnernm[1] = ls_partnernm
//END IF

IF ls_shop_type = "TECH" THEN	
	dw_cond.Object.tech_shop[1] = gs_user_group
	dw_cond.Object.partnernm[1] = ls_partnernm
ELSE
	dw_cond.Object.partner[1] = gs_user_group
	dw_cond.Object.partnernm[1] = ls_partnernm
END IF

dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn("orderno")

ls_orderno = iu_cust_msg.is_call_name[2]

IF IsNull(ls_orderno) = False THEN
	dw_cond.Object.orderno[1] = ls_orderno	
	p_ok.TriggerEvent(Clicked!)	
END IF

end event

event ue_ok;call super::ue_ok;//Service 별 요금 조회
STRING	ls_partner,		ls_where,			ls_orderdt,		ls_requestdt,	&
			ls_temp,			ls_result[],		ls_result1[],	ls_ref_desc,	&
			ls_where_1,		ls_detail_where,	ls_orderno,		ls_where_2,		&
			ls_tech_shop,	ls_svccod,			ls_priceplan,	ls_customerid, 	ls_emp_group
DATE		ld_orderdt,		ld_requestdt
LONG		ll_row,			ll_cur_row,			ll_detail_row, li_count
INT		li_i

ls_orderno	  = dw_cond.object.orderno[1]
ls_customerid = dw_cond.object.customerid[1]
ld_orderdt	  = dw_cond.object.orderdt[1]
ld_requestdt  = dw_cond.object.requestdt[1]
ls_orderdt	  = String(ld_orderdt, 'yyyymmdd')
ls_requestdt  = String(ld_requestdt, 'yyyymmdd')
ls_partner	  = Trim(dw_cond.object.partner[1])
ls_tech_shop  = Trim(dw_cond.object.tech_shop[1])
ls_svccod	  = Trim(dw_cond.object.svccod[1]) 
ls_priceplan  = Trim(dw_cond.object.priceplan[1])

//Null Check
IF IsNull(ls_orderno)		THEN ls_orderno = ""
IF IsNull(ls_customerid)	THEN ls_customerid = ""
IF IsNull(ls_partner)		THEN ls_partner = ""
IF IsNull(ls_orderdt)		THEN ls_orderdt = ""
IF IsNull(ls_requestdt) 	THEN ls_requestdt = ""
IF IsNull(ls_tech_shop) 	THEN ls_tech_shop = ""
IF IsNull(ls_svccod)			THEN ls_svccod = ""
IF IsNull(ls_priceplan) 	THEN ls_priceplan = ""

IF ls_orderno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " SVCORDER.ORDERNO = TO_NUMBER('" + ls_orderno + "') "
END IF

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " SVCORDER.CUSTOMERID = '" + ls_customerid + "' "
END IF

IF ls_partner <> "" THEN 
	
	IF is_agent = 'Y' THEN  //개통처일경우
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += "SVCORDER.SETTLE_PARTNER = '" + ls_partner + "' "
		
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += " SVCORDER.SVCCOD in (select code from syscod2t where grcode = 'ZM103')" 
		//messagebox("", ls_where)
	else  
		IF ls_where <> "" THEN ls_where += " AND "
		ls_where += " SVCORDER.PARTNER = '" + ls_partner + "' "
	end if
END IF

IF ls_orderdt <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "  
  ls_where += "TO_CHAR(SVCORDER.ORDERDT, 'YYYYMMDD') <= '" + ls_orderdt + "' " 
END IF

IF ls_requestdt <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "  
  ls_where += "( TO_CHAR(SVCORDER.REQUESTDT, 'YYYYMMDD') <= '" + ls_requestdt + "' OR SVCORDER.REQUESTDT IS NULL )" 
END IF

//IF ls_tech_shop <> "" THEN
//  IF ls_where <> "" THEN ls_where += " AND "  
//  ls_where += " SVCORDER.TECH_SHOP ='" + ls_tech_shop + "' " 
//END IF

IF ls_svccod <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "  
  ls_where += " SVCORDER.SVCCOD = '" + ls_svccod + "' " 
END IF

IF ls_priceplan <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "  
  ls_where += " SVCORDER.PRICEPLAN = '" + ls_priceplan + "' " 
END IF




//개통요청상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P220", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result[])
End if

ls_where_1 = ""
For li_i = 1 To UpperBound(ls_result[])
	If ls_where_1 <> "" Then ls_where_1 += " And "
	ls_where_1 += "svcorder.status = '" + ls_result[li_i] + "'"
Next

//구매확인Call 서비스코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P300", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result[])
End if
For li_i = 1 To UpperBound(ls_result[])
	If ls_where_1 <> "" Then
		If li_i = 1 Then
			ls_where_1 += " And ( "
		Else
			ls_where_1 += " Or  "
		End If
	End If
	
	ls_where_1 += " svcorder.svccod <> '" + ls_result[li_i] + "' "
Next
ls_where_1 += ")"

If ls_where <> "" Then
	If ls_where_1 <> "" Then ls_where = ls_where + " And (( " + ls_where_1 + " )  "  
Else
	ls_where = ls_where_1
End if

//구매확인완료상태코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P229", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result1[])
End if

ls_where_2 = ""
For li_i = 1 To UpperBound(ls_result1[])
	If ls_where_2 <> "" Then ls_where_2 += " And "
	ls_where_2 += " svcorder.status = '" + ls_result1[li_i] + "' "
Next

//구매확인Call 서비스코드
ls_ref_desc = ""
ls_temp = fs_get_control("B0","P300", ls_ref_desc)
If ls_temp <> "" Then
   fi_cut_string(ls_temp, ";" , ls_result1[])
End if
For li_i = 1 To UpperBound(ls_result1[])
	If ls_where_2 <> "" Then
		If li_i = 1 Then
			ls_where_2 += " And ("
		Else
			ls_where_2 += " OR "
		End If
	End If
		
	ls_where_2 += " svcorder.svccod = '" + ls_result1[li_i] + "' "
Next
ls_where_2 += ")"

If ls_where <> "" Then
	If ls_where_2 <> "" Then ls_where = ls_where + " OR ( " + ls_where_2 + " )) "
Else
	ls_where = ls_where_2
End If
	
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If
end event

event ue_reset;call super::ue_reset;//초기화
Date		ld_sysdate
String	ls_partner, ls_partnernm,	ls_shop_type
LONG	 	ll_cnt

dw_cond.SetRedraw(false)
//dw_cond.ReSet()
//dw_cond.InsertRow(0)

ld_sysdate = Date(fdt_get_dbserver_now())

SELECT PARTNERNM, NVL(SHOP_TYPE, 'ETC') INTO :ls_partnernm, :ls_shop_type
FROM   PARTNERMST
WHERE  PARTNER = :gs_user_group
AND    ACT_YN = 'Y';

//SELECT COUNT(*) INTO :ll_cnt
//FROM   PARTNERMST
//WHERE  GROUP_ID = ( SELECT REF_CONTENT FROM SYSCTL1T WHERE MODULE = 'PI' AND REF_NO = 'A101' ); 
//
//If SQLCA.SQLCode < 0 Then
//	f_msg_sql_err(This.Title,"수행처 select")
//	Return -1
//End If

IF  ls_shop_type = "TECH" THEN
	dw_cond.Object.tech_shop[1] = gs_user_group
	dw_cond.Object.partnernm[1] = ls_partnernm	
ELSE
	dw_cond.Object.partner[1] = gs_user_group
	dw_cond.Object.partnernm[1] = ls_partnernm
END IF
dw_cond.Object.orderdt[1] = ld_sysdate
dw_cond.Object.requestdt[1] = ld_sysdate

dw_cond.SetColumn("orderdt")

dw_cond.SetRedraw(true)
dw_detail.reset()
dw_add.reset()

Return 0 
end event

event ue_extra_save;//Save Check
STRING	ls_sysdt,			ls_priceplan,		ls_svccod,			ls_remark,		ls_errmsg, 			ls_customerid
STRING	ls_activedt,		ls_action,			ls_serial,			ls_portno,		ls_switch,			ls_mng_no,		&
			ls_router,			ls_model,			ls_up,				ls_down,			ls_static,			ls_svc_gubun,	&
			ls_validkey,		ls_sale_flag_hw,	ls_ref_desc,		ls_admst_action
BOOLEAN	lb_check
LONG		ll_rows,				ll_rc,				ll_svcctl_cnt,		ll_orderno,		ll_contractseq,		&
			ll_return,			ll_client,			ll_dial,				ll_admst_cnt,	ll_card_cnt
DATE		ld_activedt,		ld_bil_fromdt
INTEGER  li_self, 			li_rc


//b1u_dbmgr1_v20 lu_dbmgr

dw_detail.AcceptText()

ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

ld_activedt	  = DATE(dw_detail.object.activedt[1])
ls_activedt   = STRING(dw_detail.object.activedt[1], 'yyyymmdd')
ld_bil_fromdt = DATE(dw_detail.object.bil_fromdt[1])
ls_sysdt 	  = STRING(fdt_get_dbserver_now(),'yyyymmdd')
ls_svccod 	  = dw_detail.object.svcorder_svccod[1]
ls_priceplan  = dw_detail.object.svcorder_priceplan[1]
ll_orderno 	  = dw_detail.object.svcorder_orderno[1]
ls_remark 	  = dw_detail.object.remark[1]
ls_customerid = dw_detail.object.svcorder_customerid[1]
ls_validkey	  = trim(dw_detail.object.validkey[1])


	// 모바일 번호 할당후
	//모바일 서비스는 신청 후 개통시 번호할당 start
	int li_cnt
	
	SELECT COUNT(*) INTO :li_cnt 
	FROM SYSCOD2T
	WHERE GRCODE = 'ZM103'
	  AND CODE = :ls_svccod;
	  
	IF li_cnt > 0 THEN

		
		if ls_validkey <> '' then
			
			ubs_dbmgr_activeorder	lu_dbmgr
			
			//저장
			lu_dbmgr = Create ubs_dbmgr_activeorder
			lu_dbmgr.is_caller   = "ubs_w_reg_activation%save"
			lu_dbmgr.is_title    = Title
			lu_dbmgr.idw_data[1] = dw_detail
			lu_dbmgr.is_data[1]  = gs_user_id
			lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
	
			lu_dbmgr.uf_prc_db_05()
			li_rc = lu_dbmgr.ii_rc
			
			If li_rc = -1 Then
				setnull(ls_validkey)
				dw_detail.object.validkey[1] = ls_validkey
				Destroy lu_dbmgr
				RETURN -1
			End If
			
			If li_rc = -3 Then
				setnull(ls_validkey)
				dw_detail.object.validkey[1] = ls_validkey
				Destroy lu_dbmgr
				RETURN -1
			End If
	
			if li_rc = 0 then
				//commit;
			end if
			
			Destroy lu_dbmgr
			
		end if

	END IF
	//모바일 서비스는 신청 후 개통시 번호할당 end


//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

ls_errmsg		= space(1000)
ll_contractseq = 0
SQLCA.UBS_REG_ACTIVATION(ll_orderno,		ll_contractseq,	ls_remark,		ld_activedt,	&
								 ld_bil_fromdt,	gs_user_id,			gs_pgm_id[1], 	ll_return, 		&
								 ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_ACTIVATION' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_ACTIVATION' + ls_errmsg,Exclamation!,OK!)
	RETURN -1
END IF

//2015.05.18 추가 : 자가폰으로 개통신청한 건을 완료처리할 때는 계약번호 입력처리 되도록
select count(*) into :li_self
from svcorder
where orderno = :ll_orderno
  and selfequip_yn = 'Y';
  
if li_self > 0 then
		update customer_hw  set
				  contractseq = :ll_contractseq,
				  updtdt = sysdate
		where orderno = :ll_orderno;
end if;
// 

//2009.06.07 추가. 개통처리시 SIID 계약번호 업데이트!!!
UPDATE SIID
SET    CONTRACTSEQ = TO_CHAR(:ll_contractseq),
		 UPDTDT = SYSDATE
WHERE  ORDERNO = :ll_orderno;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF
//2009.06.07 추가.-------------------------------------END

//2009.06.11 추가. 개통처리시 EQUIPMST 계약번호 업데이트!!!
UPDATE EQUIPMST
SET    CONTRACTSEQ = :ll_contractseq,
		 CUSTOMERID  = :ls_customerid,
		 SALEDT		 = TO_DATE(:ls_activedt, 'YYYYMMDD'),
		 VALID_STATUS= '300',
		 UPDT_USER   = :gs_user_id,		 
		 UPDTDT = SYSDATE
WHERE  ORDERNO = :ll_orderno;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF
//2009.06.11 추가.-------------------------------------END

//2011.02.11 추가
//INSERT EQUIPLOG
INSERT INTO EQUIPLOG
(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
		 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
		 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
		 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
FROM   EQUIPMST
WHERE  ORDERNO = :ll_orderno;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'INSERT EQUIPLOG' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF

//2011.03.05. 부가 설정 항목 저장!!!
SELECT NVL(SVC_GUBUN, 'X') INTO :ls_svc_gubun
FROM   SVCMST
WHERE  SVCCOD = :ls_svccod;

IF ls_svc_gubun <> "SC01" AND ls_svc_gubun <> "SC02" AND ls_svc_gubun <> "SC05" AND  ls_svc_gubun <> "SC07" THEN
	ls_serial	= dw_add.Object.serial[1]
	ls_portno	= dw_add.Object.portno[1]
	ls_switch	= dw_add.Object.switch[1]
	ls_mng_no	= dw_add.Object.uplus_mng_no[1]
	ls_router	= dw_add.Object.router_yn[1]
	ls_model		= dw_add.Object.model[1]
	ll_client	= dw_add.Object.client_cnt[1]
	ls_up			= dw_add.Object.up_speed[1]
	ls_down		= dw_add.Object.down_speed[1]
	ll_dial		= dw_add.Object.dial_tone[1]
	ls_static	= dw_add.Object.static_ip[1]
	ls_remark	= dw_add.Object.remark[1]
	
	INSERT INTO CONTRACTDET_ADD
		( CUSTOMERID,	ORDERNO,			CONTRACTSEQ,	SERIAL,		PORTNO,
		  SWITCH,		UPLUS_MNG_NO,	ROUTER_YN,		MODEL,		CLIENT_CNT,
		  UP_SPEED,		DOWN_SPEED,		DIAL_TONE,		STATIC_IP,	REMARK,
		  CRT_USER,		CRTDT,			PGM_ID )
	VALUES
		( :ls_customerid, :ll_orderno, :ll_contractseq, :ls_serial, :ls_portno,
		  :ls_switch,	:ls_mng_no,		:ls_router,	:ls_model, :ll_client,
		  :ls_up,	:ls_down, :ll_dial, :ls_static, :ls_remark,
		  :gs_user_id, SYSDATE, :gs_pgm_id[gi_open_win_no]);
		  
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX("확인", 'INSERT CONTRACTDET_ADD' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	END IF
	
	
ELSE
	IF ls_svc_gubun = "SC02" THEN 		
		UPDATE CUSTOMERM
		SET    HOMEPHONE = :ls_validkey
		WHERE  CUSTOMERID = :ls_customerid;

		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX("확인", 'UPDATE CUSTOMERM' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			RETURN -1
		END IF
	END IF	
	
	IF ls_svc_gubun = "SC05" THEN
		UPDATE CUSTOMERM
		SET    CELLPHONE = :ls_validkey
		WHERE  CUSTOMERID = :ls_customerid;

		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX("확인", 'UPDATE CUSTOMERM' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			RETURN -1
		END IF
	END IF	
	
END IF	

//deposit_log, dailypayment 에 계약번호 update 하기
UPDATE DAILYPAYMENT
SET    CONTRACTSEQ = :ll_contractseq,
		 UPDTDT		 = SYSDATE,
		 UPDT_USER	 = :gs_user_id
WHERE  CUSTOMERID  = :ls_customerid
AND    ORDERNO     = :ll_orderno;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE DAILYPAYMENT' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF
  
//deposit_log, dailypayment 에 계약번호 update 하기
UPDATE DEPOSIT_LOG
SET    CONTRACTSEQ = :ll_contractseq
WHERE  CUSTOMERID  = :ls_customerid
AND    ORDERNO     = :ll_orderno;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE DEPOSIT_LOG' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF

//ADMST 에 기록 CONTRACTSEQ 업데이튼 및 CUSTOEMR_HW 에 데이터 입력. 카드...
SELECT COUNT(*) INTO :ll_admst_cnt
FROM   ADMST
WHERE  CUSTOMERID = :ls_customerid
AND    ORDERNO    = :ll_orderno
AND    CONTRACTSEQ IS NULL;

IF ll_admst_cnt > 0 THEN
	//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
	SELECT ref_content INTO :ls_admst_action FROM sysctl1t 
	WHERE module = 'U2' AND ref_no = 'A103';	
	
	SELECT COUNT(*) INTO :ll_card_cnt
	FROM   ADMST_ITEM
	WHERE  PRICEPLAN = :ls_priceplan;	
	
	IF ll_card_cnt > 0 THEN
		ls_sale_flag_hw = fs_get_control("E1", "A700", ls_ref_desc)
		
		SELECT MAX(VALIDKEY) INTO :ls_validkey
		FROM   VALIDINFO
		WHERE  CUSTOMERID = :ls_customerid
		AND    ORDERNO = :ll_orderno
		AND    STATUS = '20';

		//CUSTOMER_HW
		INSERT INTO CUSTOMER_HW
			( HWSEQ, RECTYPE, CUSTOMERID, SALE_FLAG, ADTYPE,
			  SERIALNO, REMARK, ORDERNO, ITEMCOD, CRT_USER,
			  CRTDT, PGM_ID, CONTRACTSEQ )
		SELECT  SEQ_CUSTOMERHWNO.NEXTVAL, 'C', A.CUSTOMERID, :ls_sale_flag_hw, B.ADTYPE,
				  DECODE(B.PWD_YN, 'Y', A.SPEC_ITEM1, A.PID), :ls_validkey, A.ORDERNO, B.ITEMCOD, :gs_user_id,
				  SYSDATE, :gs_pgm_id[gi_open_win_no], :ll_contractseq
		FROM    ADMST A, ADMST_ITEM B
		WHERE   A.CUSTOMERID = :ls_customerid
		AND     A.ORDERNO = :ll_orderno
		AND     A.CONTRACTSEQ IS NULL
		AND     A.ITEMCOD = B.ITEMCOD
		AND     B.PRICEPLAN = :ls_priceplan;
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX("확인", 'INSERT CUSTOMER_HW' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			RETURN -1
		END IF
	END IF

	UPDATE ADMST
	SET    CONTRACTSEQ = :ll_contractseq,
			 UPDT_USER   = :gs_user_id,
			 UPDTDT		 = SYSDATE
	WHERE  CUSTOMERID = :ls_customerid
	AND    ORDERNO    = :ll_orderno
	AND    CONTRACTSEQ IS NULL;
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX("확인", 'UPDATE ADMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	END IF	
	
	INSERT INTO ADMSTLOG_NEW		
		( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
		  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
		  ORDERNO, RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
		  PGM_ID, IDATE )
	SELECT ADSEQ, seq_admstlog.nextval, :ls_admst_action, SYSDATE, SN_PARTNER, TO_PARTNER, CONTNO, STATUS,
			 SALEDT, MV_PARTNER, 1, SALE_AMT, 0, MODELNO, CUSTOMERID, CONTRACTSEQ,
			 ORDERNO, RETDT, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
			 :gs_pgm_id[gi_open_win_no], IDATE
	FROM   ADMST
	WHERE  CUSTOMERID = :ls_customerid
	AND    ORDERNO    = :ll_orderno
	AND  	 CONTRACTSEQ = :ll_contractseq;	
	
	If SQLCA.SQLCode < 0 Then
		MESSAGEBOX("확인", 'INSERT ADMSTLOG_NEW' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	End If									
	
END IF	

dw_detail.object.contractseq[1] = STRING(ll_contractseq)
//저장후에 데이터 윈도우는 수정상태로 남아있는거 없앤다.
dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Return 0
end event

event ue_save;//dw_detail을 save 하는 것이 아니므로 조상 스트립트 수정!!
STRING 	ls_activedt,		ls_bil_fromdt,		ls_contractno,		ls_contractseq,	&
			ls_orderno,			ls_svccod,			ls_priceplan,		ls_customerid,		&
			ls_sms_yn,			ls_cellphone,		ls_send_flag,		ls_cell,				&
			ls_massage,			ls_sender,			ls_sysdate,			ls_sms_msg
LONG		ll_row,				ll_len
INT		li_rc

Constant Int LI_ERROR = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

ls_customerid = dw_detail.Object.svcorder_customerid[1]

THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

THIS.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

li_rc = This.Trigger Event ue_extra_save()

If li_rc = -1 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"서비스개통처리")
	Return LI_ERROR
ElseIf li_rc = 0 Then
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"서비스개통처리")
	
	//SMS 자동 발송 처리...
	ls_send_flag = 'N'
	
	SELECT NVL(SMS_YN, 'N'), NVL(REPLACE(CELLPHONE, '-', ''), '') INTO :ls_sms_yn, :ls_cellphone
	FROM   CUSTOMERM
	WHERE  CUSTOMERID = :ls_customerid;
	
	IF ls_sms_yn = 'Y' THEN
		ll_len = LenA(ls_cellphone)
		
		IF ll_len < 10 OR ll_len > 11 THEN
			F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_cellphone)
			ls_send_flag = 'N'
		ELSE
			ls_cell = MidA(ls_cellphone, 1, 3)
			
			IF ls_cell <> '010' AND ls_cell <> '011' AND ls_cell <> '016' AND ls_cell <> '017' AND ls_cell <> '018' AND ls_cell <> '019' THEN
				F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_cellphone)
				ls_send_flag = 'N'
			ELSE
				ls_send_flag = 'Y'					
			END IF
		END IF
		
		IF ls_send_flag = 'Y' THEN		
			SELECT MESSAGE, SENDER INTO :ls_massage, :ls_sender
			FROM   SMS_MESSAGE
			WHERE  MSGCOD = 'A02';
			
			SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MI') INTO :ls_sysdate
			FROM   DUAL;
			
			ls_sms_msg = ls_massage + ' ' + MidA(ls_sysdate, 9, 2) + ':' + MidA(ls_sysdate, 11, 2)
			
			IF LenA(ls_sms_msg) > 80 THEN
				ls_sms_msg = MidA(ls_sms_msg, 1, 80 )
			END IF
			
			INSERT INTO SMS.SC_TRAN
				( TR_NUM, TR_SENDDATE, TR_SENDSTAT, TR_PHONE,
				  TR_CALLBACK, TR_MSG,	TR_MSGTYPE )
			VALUES ( SMS.SC_SEQUENCE.NEXTVAL, SYSDATE, '0', :ls_cellphone,
						:ls_sender, :ls_sms_msg, '0');
						
			IF SQLCA.SQLCode = -1 THEN 
				ROLLBACK;
				f_msg_sql_err(title, "INSERT ERROR! (SMS.SC_TRAN)"+SQLCA.sqlerrtext)
			ELSE
				COMMIT;
			END IF	
		END IF	
	END IF
ElseIF li_rc = -2 Then
	Return LI_ERROR
End if

//재정의
String ls_partner
Date ld_orderdt, ld_requestdt

ls_orderno 	 = dw_cond.object.orderno[1]
ld_orderdt 	 = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_partner 	 = Trim(dw_cond.object.partner[1])
ls_svccod 	 = Trim(dw_cond.object.svccod[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])

//Reset
Trigger Event ue_reset()
dw_cond.object.orderno[1]	 = ls_orderno
dw_cond.object.orderdt[1] 	 = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt
dw_cond.object.partner[1] 	 = ls_partner
dw_cond.object.svccod[1] 	 = ls_svccod
dw_cond.object.priceplan[1] = ls_priceplan
Trigger Event ue_ok()

Return 0
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
LONG ll_2, ll_dwsize

ll_dwsize = 25

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	cb_1.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	ll_2 = round((newheight - dw_add.Y - dw_add.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 2, 1)
	
//	dw_detail.Height = newheight - dw_add.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space - ll_dwsize
	dw_add.Y = dw_add.Y + ll_2
	dw_add.Height = dw_add.Height + ll_2
	dw_detail.Height = dw_add.y - dw_detail.y - ll_dwsize	

	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	cb_1.Y		= newheight - iu_cust_w_resize.ii_button_space_1	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
	dw_add.Width = newwidth - dw_add.X - iu_cust_w_resize.ii_dw_button_space	
End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
End If

// Call the resize functions
of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn("orderno")
end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_activation
integer y = 16
integer width = 2715
integer height = 384
string dataobject = "ubs_dw_reg_activation_cond"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init;This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"


dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('orderno')


end event

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild 	ldc_priceplan
Long 					li_exist
String 				ls_filter,			ls_sql,		ls_customernm

Choose Case dwo.name
	Case "svccod"
		li_exist 	= This.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		ls_filter = "svccod = '" + data  + &
					   "'  And  String(auth_level) 	>= '"  	+ String(gi_auth) 	+ &
						"'  And  partner 					= '" 		+ gs_user_group 		+ "' " 

  		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
			f_msg_usr_err(2100, Title, "Retrieve()")
	  		Return 1  		//선택 취소 focus는 그곳에
		End If 
		
	Case "customerid"		
		
		SELECT CUSTOMERNM INTO :ls_customernm
		FROM   CUSTOMERM
		WHERE  CUSTOMERID = :data;
		
		IF IsNull(ls_customernm) THEN ls_customernm = ""
		
		IF ls_customernm = "" THEN
			f_msg_usr_err(2100, Title, "CustomerID Not Found!")
			THIS.Object.customerid[1] = ""
			THIS.Object.customernm[1] = ""
	  		Return 2  		//선택 취소 focus는 그곳에
		End If

		THIS.Object.customernm[1] = ls_customernm		

End Choose	
end event

event dw_cond::doubleclicked;call super::doubleclicked;
Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			Object.customerid[row] 	= iu_cust_help.is_data[1]
			object.customernm[row] 	= iu_cust_help.is_data[2]
		End If

End Choose

Return 0 
end event

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_activation
integer x = 2821
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_activation
integer x = 649
integer y = 1876
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_activation
integer x = 27
integer width = 3113
integer height = 428
integer textsize = -2
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_activation
integer x = 23
integer y = 444
integer width = 3122
integer height = 556
string dataobject = "ubs_dw_reg_activation_mas"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::clicked;call super::clicked;//Dec ldc_ref_contractseq
//String ls_activedt, ls_bil_fromdt, ls_contractno, ls_type
//datetime ldt_activedt, ldt_bil_fromdt
//Long ll_row, ll_selected_row
//
//ll_selected_row = dw_detail.rowcount()
//
//If ll_selected_row > 0 Then
//
//	ldc_ref_contractseq = dw_detail.object.svcorder_ref_contractseq[1]
//	
//	If Isnull(ldc_ref_contractseq) Then
//		p_save.TriggerEvent("ue_enable")	
//		dw_detail.object.activedt.protect = 0
//		dw_detail.object.bil_fromdt.protect = 0
//		dw_detail.object.contract_no.protect = 0
//		dw_detail.object.contractseq.protect = 0
//		
//	Else
//		Select activedt,
//				 bil_fromdt,
//				 contractno
//		 Into :ldt_activedt,
//				:ldt_bil_fromdt,
//				:ls_contractno
//		 From contractmst
//		Where contractseq = :ldc_ref_contractseq;
//		
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(This.Title,"contractmst select")
//			Return -2
//		End If
//		
//		dw_detail.object.activedt[1] = ldt_activedt
//		dw_detail.object.bil_fromdt[1] = ldt_bil_fromdt
//		dw_detail.object.contract_no[1] = ls_contractno
//		dw_detail.object.contractseq[1] = string(ldc_ref_contractseq)
//		dw_detail.object.activedt.protect = 1
//		dw_detail.object.bil_fromdt.protect = 1
//		dw_detail.object.contract_no.protect = 1
//		dw_detail.object.contractseq.protect = 1
//		p_save.TriggerEvent("ue_disable")		
//		
//		dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
//		
//	End If
//End If
//
//dw_detail.SetRedraw(true)
end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_activation
integer x = 23
integer y = 1028
integer width = 3122
integer height = 452
string dataobject = "ubs_dw_reg_activation_det"
boolean vscrollbar = false
end type

event dw_detail::buttonclicked;//Butonn Click
string ls_reg_partner,	ls_priceplan,	ls_customerid,	ls_svccod,	ls_partner, ls_validkey, ls_validkey_new
long li_rc

CHOOSE CASE DWO.NAME
		
	CASE 'b_1'
		
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "상세품목조회"
		iu_cust_msg.is_grp_name = "서비스 신청내역 조회/취소"
		iu_cust_msg.is_data[1] = Trim(String(This.object.svcorder_orderno[row]))
				
		OpenWithParm(b1w_inq_popup_svcorderitem_v20, iu_cust_msg)
		
	CASE 'b_validkey' //모바일서비스는 (grcode ='ZM103') 개통시 번호할당
      
		ls_validkey = trim(dw_detail.object.validkey[1])//할당전
		if isnull(ls_validkey) then
			
			ls_reg_partner = Trim(dw_detail.Object.svcorder_reg_partner[1])
			ls_priceplan   = Trim(dw_detail.Object.svcorder_priceplan[1])
			ls_customerid  = Trim(dw_detail.Object.svcorder_customerid[1])
			ls_svccod      = fs_snvl(dw_detail.Object.svcorder_svccod[1], '')
			ls_partner 		= Trim(dw_detail.Object.svcorder_partner[1])
			
			iu_cust_msg = Create u_cust_a_msg
			iu_cust_msg.is_pgm_name = "인증정보등록"
			iu_cust_msg.is_grp_name = "서비스개통"
			iu_cust_msg.is_data[1] = "ubs_w_reg_activation"
			iu_cust_msg.is_data[2] = ""						//ls_validkey_type  //인증KeyType
			iu_cust_msg.is_data[3] = ""      				//멘트언어  ls_n_langtype
			iu_cust_msg.is_data[4] = ls_priceplan       	//가격정책
			iu_cust_msg.is_data[5] = ls_reg_partner     	//유치처
			iu_cust_msg.is_data[6] = ls_customerid      	//고객번호
			iu_cust_msg.is_data[8] = ls_svccod           //서비스코드  언어맨트때문에 추가 0711
			iu_cust_msg.is_data[9] = ls_partner  			//add - ssrt Shopid
			iu_cust_msg.ii_data[1] = 0             		//발신지Location check yn ii_cnt
			iu_cust_msg.il_data[1] = 1                  	//현재row
			iu_cust_msg.idw_data[1] = dw_detail
			iu_cust_msg.is_data[7] = ""						//ls_callforward_type //착신전환유형
			
			OpenWithParm(ubs_w_pop_validkey, iu_cust_msg) //dw_detail에 validkey 할당하는 기능 밖에 없음 ㅜㅜ
			
//			//할당후
//			ls_validkey_new = trim(dw_detail.object.validkey[1])
//			if ls_validkey_new <> '' then
//				
//				ubs_dbmgr_activeorder	lu_dbmgr
//				
//				//저장
//				lu_dbmgr = Create ubs_dbmgr_activeorder
//				lu_dbmgr.is_caller   = "ubs_w_reg_activation%save"
//				lu_dbmgr.is_title    = Title
//				lu_dbmgr.idw_data[1] = dw_detail
//				lu_dbmgr.is_data[1]  = gs_user_id
//				lu_dbmgr.is_data[2]  = gs_pgm_id[gi_open_win_no]
//
//				lu_dbmgr.uf_prc_db_05()
//				li_rc = lu_dbmgr.ii_rc
//				
//				If li_rc = -1 Then
//					setnull(ls_validkey)
//					dw_detail.object.validkey[1] = ls_validkey
//					Destroy lu_dbmgr
//					Return
//				End If
//				
//				If li_rc = -3 Then
//					setnull(ls_validkey)
//					dw_detail.object.validkey[1] = ls_validkey
//					Destroy lu_dbmgr
//					Return
//				End If
//
//				if li_rc = 0 then
//					commit;
//				end if
//				
//				Destroy lu_dbmgr
//				
//			end if
			
		end if
		
END CHOOSE

Return 0 
end event

event dw_detail::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_orderno,	ls_svccod, ls_svc_gubun, ls_siid, ls_customerid
Long ll_row,	ll_row_add, ll_non_valid_cnt
dec ldc_ref_contractseq

ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])
ls_customerid = dw_master.object.svcorder_customerid[al_select_row]

If IsNull(ls_orderno) Then ls_orderno = ""
ls_where = ""
If ls_orderno <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "svc.orderno = " + ls_orderno + ""
End If

//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
dw_detail.SetRedraw(false)
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

//If al_select_row > 0 Then
//
//	ldc_ref_contractseq = dw_detail.object.svcorder_ref_contractseq[1]
//	
//	If Isnull(ldc_ref_contractseq) Then
//		p_save.TriggerEvent("ue_enable")	
//		dw_detail.object.activedt.protect = 0
//		dw_detail.object.bil_fromdt.protect = 0
//		dw_detail.object.contract_no.protect = 0
//		dw_detail.object.contractseq.protect = 0
//	Else
//		dw_detail.object.activedt.protect = 1
//		dw_detail.object.bil_fromdt.protect = 1
//		dw_detail.object.contract_no.protect = 1
//		dw_detail.object.contractseq.protect = 1
//		p_save.TriggerEvent("ue_disable")		
//	End If
//	
//End If

//2011.03.05 서비스별 부가항목 등록...
ls_svccod = Trim(dw_master.object.svcorder_svccod[al_select_row])

SELECT NVL(SVC_GUBUN, 'X') INTO :ls_svc_gubun
FROM   SVCMST
WHERE  SVCCOD = :ls_svccod;



IF ls_svc_gubun = "SC01" THEN				//인터넷..
	dw_add.DataObject = "ubs_dw_reg_activation_det2_int"
	dw_add.SetTransObject(SQLCA)	
	
	SELECT NVL(SIID, '') INTO :ls_siid
	FROM   SIID
	WHERE  ORDERNO = TO_NUMBER(:ls_orderno);
	
	IF IsNull(ls_siid) = FALSE OR ls_siid <> '' THEN
		ll_row_add = dw_add.Retrieve(ls_siid)
		dw_add.SetRedraw(false)
		
		If ll_row_add < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If		
	END IF
ELSEIF ls_svc_gubun = "SC02" THEN		//VOIP
	dw_add.DataObject = "ubs_dw_reg_activation_det2_voip"
	dw_add.SetTransObject(SQLCA)	
	
	SELECT NVL(SIID, '') INTO :ls_siid
	FROM   SIID
	WHERE  ORDERNO = TO_NUMBER(:ls_orderno);
	
	IF IsNull(ls_siid) = FALSE OR ls_siid <> '' THEN
		ll_row_add = dw_add.Retrieve(ls_siid)
		dw_add.SetRedraw(false)
		
		If ll_row_add < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If		
	END IF	
ELSEIF ls_svc_gubun = "SC03" OR ls_svc_gubun = "SC04"  THEN		//DSL, 광랜
	dw_add.DataObject = "ubs_dw_reg_activation_det2_dsl"
	dw_add.SetTransObject(SQLCA)
	dw_add.InsertRow(0)	
	
	dw_add.Object.up_speed[1]	 = '1'
	dw_add.Object.down_speed[1] = '1'
	
ELSEIF ls_svc_gubun = "SC07" THEN		//CATV
	dw_add.DataObject = "ubs_dw_reg_activation_det2_catv"
	dw_add.SetTransObject(SQLCA)	
	dw_add.InsertRow(0)	
ELSEIF ls_svc_gubun = "SC09" THEN		//dial tone
	dw_add.DataObject = "ubs_dw_reg_activation_det2_dial"
	dw_add.SetTransObject(SQLCA)		
	dw_add.InsertRow(0)	
ELSEIF ls_svc_gubun = "SC11" THEN		//고정 ip
	dw_add.DataObject = "ubs_dw_reg_activation_det2_ip"
	dw_add.SetTransObject(SQLCA)		
	dw_add.InsertRow(0)		
ELSEIF ls_svc_gubun = "SC05" THEN		//모바일서비스
	dw_add.DataObject = "ubs_dw_reg_activation_det2_mobile"
	dw_add.SetTransObject(SQLCA)		
	dw_add.retrieve(ls_orderno, ls_customerid)	
ELSE
	dw_add.DataObject = "ubs_dw_reg_activation_det2_etc"
	dw_add.SetTransObject(SQLCA)
	dw_add.InsertRow(0)	
END IF	

//인증 받지 않는 장비관리 서비스
SELECT COUNT(*) INTO :ll_non_valid_cnt
FROM SYSCOD2T
WHERE GRCODE = 'BOSS06'
AND USE_YN = 'Y'
AND CODE = :ls_svccod;

IF ll_non_valid_cnt > 0 THEN  //인증 받지 않는 장비관리 서비스(NEW CATV)
	dw_add.DataObject = "ubs_dw_reg_activation_det2_newcatv"
	dw_add.SetTransObject(SQLCA)		
	dw_add.retrieve(ls_orderno, ls_customerid)	
END IF

//모바일 서비스는 신청 후 개통시 번호할당 start
int li_cnt

SELECT COUNT(*) INTO :li_cnt 
FROM SYSCOD2T
WHERE GRCODE = 'ZM103'
  AND CODE = :ls_svccod;
  
IF li_cnt > 0 THEN
	this.object.b_validkey.visible = true
ELSE
	this.object.b_validkey.visible = false
END IF
//모바일 서비스는 신청 후 개통시 번호할당 end
 
// 무조건 오늘 날짜로 나오게 2007 08 20 hcjung
This.object.activedt[1] = fdt_get_dbserver_now() //This.object.svcorder_requestdt[1]
This.object.bil_fromdt[1] = fdt_get_dbserver_now() //This.object.svcorder_requestdt[1]

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

dw_detail.SetRedraw(true)

Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;//Item Change Event

Choose Case dwo.name
	Case "activedt"
		 This.Object.bil_fromdt[row] = This.Object.activedt[row]
End Choose

Return 0 
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_activation
boolean visible = false
integer y = 1716
end type

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_activation
boolean visible = false
integer y = 1716
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_activation
integer x = 50
integer y = 1876
string picturename = "active_e.gif"
end type

event p_save::ue_buttondown;call super::ue_buttondown;This.PictureName = "active_x.gif"
end event

event p_save::ue_buttonup;call super::ue_buttonup;This.PictureName = "active_e.gif"
end event

event p_save::ue_disable();call super::ue_disable;This.PictureName = "active_d.gif"
end event

event p_save::ue_enable();call super::ue_enable;If fb_enable_button("SAVE", gi_group_auth) Then
	This.PictureName = "active_e.gif"
	This.Enabled = TRUE
Else
	This.PictureName = "active_d.gif"
	This.Enabled = FALSE
End If
end event

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_activation
integer x = 347
integer y = 1876
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_activation
integer x = 23
integer y = 996
end type

type cb_1 from commandbutton within ubs_w_reg_activation
integer x = 1984
integer y = 1876
integer width = 402
integer height = 96
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "Customer"
end type

event clicked;STRING	ls_customerid,		ls_pgm_id,		ls_pgm_name,		ls_p_pgm_id,		&
			ls_call_type,		ls_pgm_type,	ls_call_name[],	ls_p_pgm_name
DEC		lc_upd_auth
LONG		ll_row
INT		li_i
u_cust_a_msg lu_cust_msg
Window lw_temp

dw_detail.AcceptText()

ll_row = dw_detail.RowCount()

IF ll_row <= 0 THEN RETURN -1

ls_customerid = dw_detail.Object.svcorder_customerid[1]

// 고객관리 팝업 호출	
//화면띄워주기 위해 강제로 코딩!!! - 2009.06.27 최재혁
			
SetPointer(HourGlass!)
			
SELECT PGM_ID, PGM_NM, P_PGM_ID,  UPD_AUTH, CALL_TYPE, PGM_TYPE, CALL_NM1
INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
FROM   SYSPGM1T
WHERE  CALL_NM1 = 'b1w_reg_customer_d_v20_sams2'
AND    ROWNUM = 1;
			
//같은 프로그램 작동 중인지를 검사
For li_i = 1 To gi_open_win_no
	If gs_pgm_id[li_i] = ls_pgm_id Then
		f_msg_usr_err_app(504, Parent.Title, ls_pgm_name)
		Return
	End If
Next
			
//Window가 Max값 이상 열려있닌지 비교
If gi_open_win_no + 1 > gi_max_win_no Then
	f_msg_usr_err_app(505, Parent.Title, "")
	Return -1
End If
			
//Clicked TreeViewItem의 상위 TreeViewItem 정보 
//ls_p_pgm_id = '15000000'
			
SELECT PGM_NM INTO :ls_p_pgm_name
FROM   SYSPGM1T
WHERE  PGM_ID = :ls_p_pgm_id;
			
//*** 메세지 전달 객체에 자료 저장 ***
lu_cust_msg = Create u_cust_a_msg
			
lu_cust_msg.is_pgm_id   	 = ls_pgm_id
lu_cust_msg.is_grp_name 	 = ls_p_pgm_name
lu_cust_msg.is_pgm_name	    = ls_pgm_name
lu_cust_msg.is_call_name[1] = ls_call_name[1]
lu_cust_msg.is_call_name[2] = ls_customerid
lu_cust_msg.is_pgm_type 	 = ls_pgm_type
			
If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
	f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " + "window is not opened")
	Return -1
End If
			
end event

type dw_add from datawindow within ubs_w_reg_activation
integer x = 23
integer y = 1516
integer width = 3122
integer height = 324
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_activation_det2_voip"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

event itemchanged;LONG		ll_cnt,			ll_number

IF dwo.name = "portno" THEN
	
	SELECT COUNT(*) INTO :ll_cnt
	FROM   CONTRACTDET_ADD DET, CONTRACTMST MST
	WHERE  DET.PORTNO IS NOT NULL
	AND    DET.PORTNO = :data
	AND    DET.CONTRACTSEQ = MST.CONTRACTSEQ
	AND    MST.STATUS IN ('20', '40');
	
	IF ll_cnt > 0 THEN
		F_MSG_INFO(9000, Title, "Port No. 가 다른 고객과 중복됩니다.")
		THIS.Object.portno[row] = ""
		RETURN 2
	END IF
ELSEIF dwo.name = "dial_tone" THEN
	
	SetNull(ll_number)
	
	IF LONG(data) < 880000 THEN
		F_MSG_INFO(9000, Title, "880000 보다 크거나 같아야 합니다.")
		THIS.Object.dial_tone[row] = ll_number
		RETURN 2
	ELSEIF LONG(data) > 899999 THEN
		F_MSG_INFO(9000, Title, "899999 보다 작거나 같아야 합니다.")
		THIS.Object.dial_tone[row] = ll_number
		RETURN 2			
	END IF			
	
	SELECT COUNT(*) INTO :ll_cnt
	FROM   CONTRACTDET_ADD DET, CONTRACTMST MST
	WHERE  DET.DIAL_TONE IS NOT NULL
	AND    DET.DIAL_TONE = :data
	AND    DET.CONTRACTSEQ = MST.CONTRACTSEQ
	AND    MST.STATUS IN ('20', '40');
	
	IF ll_cnt > 0 THEN
		F_MSG_INFO(9000, Title, "Real No. 가 다른 고객과 중복됩니다.")
		THIS.Object.dial_tone[row] = ""
		RETURN 2
	END IF		
END IF
end event

