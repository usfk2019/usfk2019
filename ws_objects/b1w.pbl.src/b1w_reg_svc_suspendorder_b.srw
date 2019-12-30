$PBExportHeader$b1w_reg_svc_suspendorder_b.srw
$PBExportComments$[jhchoi] 서비스 일시정지 신청 - 2009.04.14
forward
global type b1w_reg_svc_suspendorder_b from w_a_reg_m_m
end type
type dw_detail2 from u_d_base within b1w_reg_svc_suspendorder_b
end type
type dw_detail3 from u_d_base within b1w_reg_svc_suspendorder_b
end type
type dw_detail4 from datawindow within b1w_reg_svc_suspendorder_b
end type
type gb_1 from groupbox within b1w_reg_svc_suspendorder_b
end type
type gb_2 from groupbox within b1w_reg_svc_suspendorder_b
end type
type gb_3 from groupbox within b1w_reg_svc_suspendorder_b
end type
type gb_4 from groupbox within b1w_reg_svc_suspendorder_b
end type
end forward

global type b1w_reg_svc_suspendorder_b from w_a_reg_m_m
integer width = 3625
integer height = 2136
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
dw_detail2 dw_detail2
dw_detail3 dw_detail3
dw_detail4 dw_detail4
gb_1 gb_1
gb_2 gb_2
gb_3 gb_3
gb_4 gb_4
end type
global b1w_reg_svc_suspendorder_b b1w_reg_svc_suspendorder_b

type variables
String is_active[]
String is_suspendreq, is_suspend
String is_reqactive
end variables

forward prototypes
public function integer wfi_get_partner (string as_partner)
public function integer wfi_get_customerid (string as_customerid)
public subroutine of_refreshbars ()
public subroutine of_resizepanels ()
end prototypes

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_detail.GetRow()

lb_check = fb_save_required(dw_detail, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck;STRING	ls_requestdt,	ls_customerid,	ls_reason
LONG		ll_row,			ll_svccnt,		ll_contractseq,		ll_cnt


dw_detail.AcceptText()
ll_row = dw_detail.GetRow()

ll_contractseq  = dw_detail.object.contractmst_contractseq[ll_row]
ls_requestdt	 = STRING(dw_detail.Object.reqdt[ll_row], 'YYYYMMDD')
ls_customerid 	 = Trim(dw_detail.object.customerm_customerid[ll_row])
ls_reason		 = Trim(dw_detail.object.suspend_type[ll_row])

IF IsNull(ls_reason) THEN ls_reason = ""

//해당계약건의 인증정보 중 적용시작일(FROMDT)보다 해지요청일이 커야한다.
SELECT COUNT(*) INTO :ll_svccnt
FROM   VALIDINFO
WHERE  TO_CHAR(FROMDT, 'YYYYMMDD') > = :ls_requestdt
AND    CONTRACTSEQ = :ll_contractseq
AND    STATUS = :is_active[1];

IF SQLCA.SQLCode < 0 THEN
	F_MSG_INFO(9000, Title, "Select Error! ( validinfo )")
	ai_return = -1
	RETURN  
END IF

IF ll_svccnt > 0 THEN
	F_MSG_INFO(9000, Title, "일시정지일은 해당계약건의 개통중인~r~n~r~n인증KEY의 적용시작일보다 커야합니다.")
	ai_return = -1
	RETURN  
END IF

IF ls_reason = "" THEN
	F_MSG_INFO(9000, Title, "사유를 입력하세요!")
	ai_return = -1
	RETURN  
END IF

//중복 Check
SELECT COUNT(*)
INTO   :ll_cnt
FROM   SVCORDER
WHERE  REF_CONTRACTSEQ = :ll_contractseq AND STATUS = :is_suspendreq;

IF SQLCA.SQLCode <> 0 THEN
	F_MSG_INFO(9000, Title, "Select Error! ( SVCORDER )")
	ai_return = -1
	RETURN  	
END IF
		
IF ll_cnt <> 0 THEN
	F_MSG_INFO(9000, Title, "이미 신청되었습니다.")	
	ai_return = -1	
	RETURN
END IF

//해지 오더 Check - 2010.04.05 cjh
SELECT COUNT(*)
INTO   :ll_cnt
FROM   SVCORDER
WHERE  REF_CONTRACTSEQ = :ll_contractseq 
AND    STATUS IN ('70', '99');

IF SQLCA.SQLCode <> 0 THEN
	F_MSG_INFO(9000, Title, "Select Error! ( SVCORDER )")
	ai_return = -1
	RETURN  	
END IF
		
IF ll_cnt <> 0 THEN
	F_MSG_INFO(9000, Title, "해지신청이 되어 있습니다. 취소하신 후 작업하시기 바랍니다.")	
	ai_return = -1	
	RETURN
END IF

ai_return = 0

RETURN
end event

public function integer wfi_get_partner (string as_partner);String ls_partnernm

Select partnernm
Into :ls_partnernm
From partnermst
Where partner = :as_partner and act_yn ='Y';

If SQLCA.SQLCODE = 100 Then
	Return -1
Else
	dw_detail.object.partnernm[1] = as_partner
End If

Return 0
end function

public function integer wfi_get_customerid (string as_customerid);String ls_customernm, ls_memberid

Select customernm, memberid	Into :ls_customernm, :ls_memberid	From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCODE = 100 Then
	dw_cond.object.name[1] = ""
	Return -1
Else
	dw_cond.object.name[1] 		= as_customerid
	dw_cond.object.memberid[1] = ls_memberid
End If

Return 0
end function

public subroutine of_refreshbars ();dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')


end subroutine

public subroutine of_resizepanels ();//// Resize the panels according to the Vertical Line, Horizontal Line,
//// BarThickness, and WindowBorder.
//
//// Validate the controls.
//If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
//
//// Top processing
//idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
//idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)
//
////// Bottom Procesing
//dw_detail2.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//dw_detail2.Resize(idrg_Top.Width / 2 - 200, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)
//
//// Bottom Procesing
//idrg_Bottom.Move(cii_WindowBorder + dw_detail2.Width + 40, st_horizontal.Y + cii_BarThickness)
//idrg_Bottom.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height / 2 + 50)
//
//// Bottom Procesing
//dw_detail3.Move(cii_WindowBorder + dw_detail2.Width + 40, idrg_Bottom.Y + idrg_Bottom.Height + 40)
//dw_detail3.Resize(idrg_Top.Width - dw_detail2.Width - 40, dw_detail2.Height - idrg_Bottom.Height - 40)
//

// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
//idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
//idrg_Bottom.Resize(idrg_Bottom.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')



end subroutine

on b1w_reg_svc_suspendorder_b.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_detail3=create dw_detail3
this.dw_detail4=create dw_detail4
this.gb_1=create gb_1
this.gb_2=create gb_2
this.gb_3=create gb_3
this.gb_4=create gb_4
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_detail3
this.Control[iCurrent+3]=this.dw_detail4
this.Control[iCurrent+4]=this.gb_1
this.Control[iCurrent+5]=this.gb_2
this.Control[iCurrent+6]=this.gb_3
this.Control[iCurrent+7]=this.gb_4
end on

on b1w_reg_svc_suspendorder_b.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_detail3)
destroy(this.dw_detail4)
destroy(this.gb_1)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.gb_4)
end on

event open;call super::open;//=========================================================//
// Desciption : 서비스 일시정지 신청		                 //
// Name       : b1w_reg_svc_suspendorder_b                 //
// Contents   : 서비스 일시정지를 신청한다. 					  //
// Data Window: dw - b1dw_cnd_reg_svc_suspendorder		     // 
//							b1dw_inq_svc_suspendorder_a  			  //
//							b1dw_reg_svc_suspendorder_b			  //
//							b1dw_inq_termorder_popup	 			  //
//							b1dw_inq_validkey					  		  //
//							b1dw_inq_equipment					  	  //
// 작성일자   : 2009.04.14                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc, ls_name[], ls_status, ls_priceplan,ls_contractseq
INT		is_cnt

is_suspendreq = ""

//개통 상태 코드
ls_ref_desc =""
ls_status = fs_get_control("B0", "P223", ls_ref_desc)
fi_cut_string(ls_status, ";", is_active[])

//일시정지신청 상태코드
ls_status = ""
ls_status = fs_get_control("B0", "P225", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_suspendreq = ls_name[1]
//일시정지
is_suspend = ls_name[2]

//재개통 신청 상태코드
is_reqactive = fs_get_control("B0", "P226", ls_ref_desc)

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')

end event

event ue_ok();call super::ue_ok;//조회.
STRING	ls_customerid,		ls_contractseq,		ls_svccod,		ls_priceplan,		ls_contractno, &
			ls_memberid,		ls_where,				ls_validkey
LONG		ll_row

ls_memberid 	= Trim(dw_cond.object.memberid[1])
ls_customerid 	= Trim(dw_cond.object.customerid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_contractno 	= Trim(dw_cond.object.contractno[1])
ls_validkey 	= Trim(dw_cond.object.validkey[1])

IF IsNull(ls_memberid) 		THEN ls_memberid 		= ""
IF IsNull(ls_customerid) 	THEN ls_customerid 	= ""
IF IsNull(ls_contractseq) 	THEN ls_contractseq 	= ""
IF IsNull(ls_contractno) 	THEN ls_contractno 	= ""
IF IsNull(ls_validkey) 		THEN ls_validkey 		= ""

ls_where  = ""
//개통인 애들만 조회시킨다.
ls_where += " CNT.STATUS = '" + is_active[1] + "' "

IF ls_memberid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CUS.MEMBERID = '" + ls_memberid + "' "
END IF

IF ls_customerid <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CUS.CUSTOMERID = '" + ls_customerid + "' "
END IF

IF ls_contractseq <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CNT.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
END IF

IF ls_contractno <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CNT.CONTRACTNO LIKE '" + ls_contractno + "%' "
END IF

IF ls_validkey <>  "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " CNT.CONTRACTSEQ IN (SELECT DISTINCT CONTRACTSEQ FROM VALIDINFO WHERE VALIDKEY = '" + ls_validkey+ "') "
END IF

//If ls_svccod <>  "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "cnt.svccod = '" + ls_svccod + "' "
//End If
//
//If ls_priceplan <>  "" Then
//	If ls_where <> "" Then ls_where += " And "
//	ls_where += "cnt.priceplan = '" + ls_priceplan + "' "
//End If

dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()

IF ll_row = 0 THEN
	f_msg_info(1000, Title, "일시정지할 고객 내역")
ELSEIF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
END IF




end event

event ue_extra_save;INTEGER	li_cnt
STRING	ls_priceplan,			ls_contractseq,		ls_related_contractseq,		ls_req,			&
			ls_remark,				ls_errmsg,				ls_suspend_type,				ls_action,		&
			ls_svccod,				ls_dacom_svctype,		ls_hostname,					ls_gubunnm,		&
			ls_requestdt,			ls_sysdate,				ls_reactivedt,					ls_req_react,	&
			ls_sysdt,				ls_errmsg_react
DATETIME	ld_requestdt
LONG		ll_row,					ll_return,				ll_orderno,						ll_siid_cnt,	&
			ll_row_ma,				ll_return_react,		ll_orderno_react,				ll_non_cnt, ll_non_valid_cnt
BOOLEAN	lb_check
DATE		ld_reactivedt

dw_detail.AcceptText()
ll_row    = dw_detail.GetRow()
ll_row_ma = dw_master.GetRow()

SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') INTO :ls_sysdate
FROM   DUAL;

ls_contractseq 		= String(dw_detail.object.contractmst_contractseq[1])
ld_requestdt	 		= dw_detail.Object.reqdt[ll_row]
ls_requestdt			= STRING(dw_detail.Object.reqdt[ll_row], 'YYYYMMDD')
ld_reactivedt	 		= DATE(dw_detail.Object.reactivedt[ll_row])
ls_reactivedt			= STRING(dw_detail.Object.reactivedt[ll_row], 'YYYYMMDD')
ls_req					= dw_detail.Object.act_gu[ll_row]
ls_remark				= dw_detail.Object.remark[ll_row]
ls_suspend_type		= dw_detail.Object.suspend_type[ll_row]
ls_svccod				= dw_detail.Object.contractmst_svccod[ll_row]

// 후행 서비스 중지없이 선행을 먼저 중지하는지 체크 -- add hcjung 20071203
ls_priceplan 			  = dw_detail.object.contractmst_priceplan[1]
ls_related_contractseq = String(dw_detail.object.contractmst_related_contractseq[1])

IF IsNull(ls_related_contractseq) THEN ls_related_contractseq = "";

IF ls_related_contractseq <> "" THEN

    SELECT count(*)
      INTO :li_cnt 
      FROM svc_relation 
     WHERE pre_priceplan = :ls_priceplan;

	IF li_cnt > 0 THEN
   	SELECT count(*) INTO :li_cnt FROM svcorder WHERE  (status = '30' OR status = '40') 
	   AND ref_contractseq = (SELECT contractseq FROM contractmst WHERE related_contractseq = :ls_contractseq);
	
		IF li_cnt = 0 THEN
	   	f_msg_usr_err(1200, Title, " Check Service Relation")
	   	ROLLBACK;
			RETURN -2
		END IF	 
	END IF
END IF

IF ls_req = 'Y' THEN
	ls_req = 'req-prc'
ELSE
	ls_req = 'req'
END IF

//저장 프로시저 실행!
ls_errmsg  = space(1000)
ll_return  = 0
ll_orderno = 0
SQLCA.UBS_REG_SUSPENDORDER(ls_contractseq,	ll_orderno,		DATE(ld_requestdt),		ls_req,		ls_remark,  &
									ls_suspend_type,	gs_user_id,		gs_pgm_id[1],				ll_return,	ls_errmsg)
										
										
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_SUSPENDORDER ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	RETURN -1
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_SUSPENDORDER ' + ls_errmsg,Exclamation!,OK!)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	RETURN -1
END IF		

//2009.06.07 추가. SIID 오더번호 업데이트!!!
UPDATE SIID
SET    ORDERNO = :ll_orderno,
		 STATUS  = '300',
		 UPDTDT = SYSDATE
WHERE  CONTRACTSEQ = :ls_contractseq;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
//ELSE
//	COMMIT;
END IF
//2009.06.07 추가.-------------------------------------END	

// 날짜 체크 . 해소신청이 같이 들어오는 경우!
If ls_reactivedt <> "" Then 
	lb_check = fb_chk_stringdate(ls_reactivedt)
	If Not lb_check Then 
		f_msg_usr_err(210, Title, "'재개통요청일의 날짜 포맷 오류입니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("reactivedt")
		Return -2
	End If
	
	If ls_reactivedt < ls_sysdt Then
		f_msg_usr_err(210, Title, "재개통요청일은 오늘날짜 이상이여야 합니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("reactivedt")
		Return -2
	End If		
	
	//2009.06.17 일 정팀장님 요청으로  = 제외!
	If ls_reactivedt < ls_requestdt Then
		f_msg_usr_err(210, Title, "'재개통요청일은 일시정지시작일 이전으로 입력할 수 없습니다.")
		dw_detail.SetFocus()
		dw_detail.SetColumn("reactivedt")
		Return -2
	End If				

	ls_req_react = 'req'
	
	//저장 프로시저 실행!
	ls_errmsg_react  = space(1000)
	ll_return_react  = 0
	ll_orderno_react = 0
	
	SQLCA.UBS_REG_REACTIVEORDER(ls_contractseq,	ll_orderno_react,	ld_reactivedt,		ls_req_react,		ls_remark,  &
										 gs_user_id,		gs_pgm_id[1],		ll_return_react,	ls_errmsg_react)
											
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, 'UBS_REG_REACTIVEORDER ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', 'UBS_REG_REACTIVEORDER ' + ls_errmsg,Exclamation!,OK!)
		RETURN -1
	END IF		
	
	//2009.06.07 추가. 해소신청 SIID 오더번호 업데이트!!!
	UPDATE SIID
	SET    ORDERNO = :ll_orderno_react,
			 STATUS  = '500',
			 UPDTDT = SYSDATE
	WHERE  CONTRACTSEQ = :ls_contractseq;
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX("확인", 'UPDATE SIID' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	END IF
//2009.06.07 추가.-------------------------------------END
END IF

//인증과 별개로 작동하도록...
COMMIT;

//2009.06.11 추가. 프로시저 호출...
IF IsNull(ll_orderno) = FALSE AND ( ls_sysdate = ls_requestdt )  THEN 			//중지신청하고 요청일이 현재일 인 경우만 연동처리.
	
//	ls_svccod = dw_master.Object.contractmst_svccod[ll_row_ma]
	
	//인증서비스인지 확인.
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

//	IF ls_priceplan = "PRCM06" OR ls_priceplan = "PRCM08" OR ls_priceplan = "PRCM18" OR ls_priceplan = "PRCM19"  THEN
//		ll_siid_cnt = 0
//	END IF
	
	IF ll_siid_cnt > 0 and ll_non_valid_cnt = 0 THEN
		SELECT DACOM_SVCTYPE, VOIP_HOSTNAME, GUBUN_NM INTO :ls_dacom_svctype, :ls_hostname, :ls_gubunnm
		FROM   PRICEPLANINFO
		WHERE  PRICEPLAN = :ls_priceplan;	
	
		If SQLCA.SQLCode <> 0 Then
			f_msg_sql_err(title, " SELECT PRICEPLANINFO Table(DACOM_SVCTYPE)")
			Return -1
		End If
		
		IF ls_gubunnm = "전화" THEN 
			ls_action = "TEL412"
		ELSE
			ls_action = "INT400"
		END IF
		
		ls_errmsg = space(1000)
		SQLCA.UBS_PROVISIONNING(ll_orderno,			ls_action,				0,		&
										'',					gs_shopid,						&
										gs_pgm_id[1],		ll_return,				ls_errmsg)
		
		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
			RETURN -1
		ELSEIF ll_return < 0 THEN		//For User
			MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
			RETURN -1
		END IF	
	END IF		
END IF
//2009.06.11--------------------------------------------------END
//해소인증중으로 UPDATE
UPDATE EQUIPMST
SET    VALID_STATUS = '400'
WHERE  CONTRACTSEQ = TO_NUMBER(:ls_contractseq);

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF

Return 0

end event

event type integer ue_save();//조회.
STRING	ls_customerid,		ls_contractseq,		ls_contractno,		ls_validkey

CONSTANT	INT LI_ERROR = -1
INTEGER	li_rc
IF dw_detail.AcceptText() < 0 THEN
	dw_detail.SetFocus()
	RETURN LI_ERROR	
END IF

// Ue_inputValidCheck  호출
THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF

THIS.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN LI_ERROR
END IF


li_rc = THIS.TRIGGER EVENT ue_extra_save()
//-2 return 시 rollback되도록 변경 
//원인: 모든 신청메뉴에서 error에 대한 return값을 개념없이 rollback없는 -2값 사용에 대한 조치
IF li_rc = -1 OR li_rc = -2 THEN
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = THIS.Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_detail.SetFocus()
		RETURN LI_ERROR
	END IF
	f_msg_info(3010,THIS.Title,"일시정지 신청")
	RETURN LI_ERROR
ELSEIF li_rc = 0 THEN
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = THIS.Title

	iu_cust_db_app.uf_prc_db()

	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_detail.SetFocus()
		RETURN LI_ERROR
	END IF
	f_msg_info(3000,THIS.Title,"일시정지 신청")

END IF

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//재조회 처리
ls_customerid	= Trim(dw_cond.object.customerid[1])
ls_contractseq = Trim(dw_cond.object.contractseq[1])
ls_contractno	= Trim(dw_cond.object.contractno[1])
ls_validkey 	= Trim(dw_cond.object.validkey[1])

TRIGGER EVENT ue_reset()
dw_cond.object.customerid[1]	= ls_customerid
dw_cond.object.contractseq[1] = ls_contractseq
dw_cond.object.contractno[1]	= ls_contractno 
dw_cond.object.validkey[1]		= ls_validkey
TRIGGER EVENT ue_ok()

RETURN 0
end event

event type integer ue_reset();call super::ue_reset;dw_detail2.Reset()
dw_detail3.Reset()
dw_detail4.Reset()


return 0
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
LONG		ll_3,		ll_w_2,		ll_grsize,		ll_dwsize,		ll_wgrsize,		ll_w

ll_grsize  = 4    //그룹박스간 사이 간격!
ll_dwsize  = 64   //그룹박스와 dw사이 간격!
ll_wgrsize = 30	//좌우 그룹박스 간 간격!

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
	gb_1.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	
	ll_3 					= round((newheight - gb_4.Y - gb_4.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 3, 1)
	dw_detail.Height	= newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space - 25
	gb_1.Height			= newheight - gb_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
	
	gb_2.Height			= gb_2.Height + ll_3
	dw_detail2.Height = dw_detail2.Height + ll_3
	
	gb_3.y				= gb_2.y + gb_2.Height + ll_grsize
	dw_detail3.y		= gb_3.y + ll_dwsize
	gb_3.Height 		= gb_3.Height + ll_3	
	dw_detail3.Height = dw_detail3.Height + ll_3	
	
	gb_4.y 				= gb_3.y + gb_3.Height + ll_grsize
	dw_detail4.y 		= gb_4.y + ll_dwsize
	gb_4.Height 		= gb_4.Height + ll_3	
	dw_detail4.Height = dw_detail4.Height + ll_3
	
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
End If

If newwidth < dw_detail2.X  Then
	dw_detail.Width = 0
	gb_1.Width = 0
Else
	ll_w = newwidth - gb_1.x - gb_1.width - iu_cust_w_resize.ii_dw_button_space
	
	gb_2.Width			= gb_2.Width + ll_w
	dw_detail2.Width  = dw_detail2.Width + ll_w
	
	gb_3.Width			= gb_3.Width + ll_w
	dw_detail3.Width  = dw_detail3.Width + ll_w
	
	gb_4.Width			= gb_4.Width + ll_w
	dw_detail4.Width  = dw_detail4.Width + ll_w
	
	gb_1.x				= gb_2.x + gb_2.Width + ll_wgrsize
	dw_detail.x		   = gb_1.x + (ll_dwsize / 2)	
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

end event

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_suspendorder_b
integer y = 40
integer width = 2395
integer height = 184
string dataobject = "b1dw_cnd_reg_svc_suspendorder"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();//고객
This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"


end event

event dw_cond::doubleclicked;call super::doubleclicked;If dwo.name = "customerid" Then
	If dw_cond.iu_cust_help.ib_data[1] Then
			 THIS.Object.customerid[row] 	= iu_cust_help.is_data[1]
			 THIS.Object.name[row] 			= iu_cust_help.is_data[2]
			 THIS.Object.memberid[1] 		= iu_cust_help.is_data[4]	 
	End If
End if
end event

event dw_cond::itemchanged;////ohj 주석처리 ..
String ls_customernm, ls_customerid, ls_memberid

choose case dwo.name
	case 'customerid'
		Select customernm, customerid, memberid	
		  Into :ls_customernm, :ls_customerid, :ls_memberid	
		  From customerm
		 Where customerid = :data;
			If SQLCA.SQLCODE = 100 Then
				dw_cond.object.name[1] 			= ""
				dw_cond.object.customerid[1] 	= ""
				dw_cond.object.memberid[1] 	= ""
				Return 2
			Else
				dw_cond.object.name[1] 			= ls_customernm
				dw_cond.object.customerid[1] 	= ls_customerid
				dw_cond.object.memberid[1] 	= ls_memberid
				Return 0
			End If
	case 'memberid'
		Select customernm, customerid, memberid	
		  Into :ls_customernm, :ls_customerid, :ls_memberid	
		  From customerm
		 Where memberid = :data;
			If SQLCA.SQLCODE = 100 Then
				dw_cond.object.name[1] 			= ""
				dw_cond.object.customerid[1] 	= ""
				dw_cond.object.memberid[1] 	= ""
				Return 2
			Else
				dw_cond.object.name[1] 			= ls_customernm
				dw_cond.object.customerid[1] 	= ls_customerid
				dw_cond.object.memberid[1] 	= ls_memberid
				Return 0
			End If
end choose
end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_suspendorder_b
integer x = 3241
integer y = 88
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_suspendorder_b
integer x = 681
integer y = 1900
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_suspendorder_b
integer width = 3529
integer height = 240
integer taborder = 0
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_suspendorder_b
integer x = 27
integer y = 252
integer width = 3534
integer height = 592
integer taborder = 40
string dataobject = "b1dw_inq_svc_suspendorder_a"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractmst_contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::clicked;call super::clicked;Long ll_selected_row,ll_old_selected_row
Int li_rc

ll_old_selected_row = This.GetSelectedRow(0)

//Call Super::clicked

If row > 0 Then
	ll_selected_row = This.GetSelectedRow(0)

	If ll_selected_row > 0 Then
	Else
		dw_detail2.Reset()
		dw_detail3.Reset()		
	End If
End If

end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_suspendorder_b
integer x = 2181
integer y = 940
integer width = 1353
integer height = 904
integer taborder = 50
string dataobject = "b1dw_reg_svc_suspendorder_b"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event type integer dw_detail::ue_retrieve(long al_select_row);//조회
STRING	ls_contractseq,	ls_where, 		ls_type,			ls_ref_desc,   &
			ls_svccod, 			ls_svctype, 	ls_priceplan
LONG		ll_row,				ll_cnt

THIS.setredraw(FALSE)

IF al_select_row = 0 THEN RETURN 0
ls_contractseq = STRING(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " CNT.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

//setting
dw_detail.object.partner[1]	= gs_shopid
dw_detail.object.partnernm[1]	= gs_shopid
dw_detail.object.reqdt[1] 		= fdt_get_dbserver_now()

dw_detail.SetItemStatus(1, 0 , Primary!,NotModified!)

IF dw_detail2.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

IF dw_detail3.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

IF dw_detail4.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

//비과금 후불제 서비스 type - 2003.10.23 김은미 비과금 후불 서비스 추가
ls_type = fs_get_control("B0", "P103", ls_ref_desc)

ls_svccod 	 = Trim(dw_detail.object.contractmst_svccod[1])
ls_priceplan = Trim(dw_detail.object.contractmst_priceplan[1])

SELECT SVCTYPE
  INTO :ls_svctype
  FROM SVCMST
 WHERE SVCCOD = :ls_svccod;

IF SQLCA.SQLCode <> 0 THEN
	f_msg_usr_err(2100, Title, "SVCMST Retrieve()")
	RETURN -2
END IF

IF ls_svctype = ls_type THEN
	dw_detail.object.act_gu.Protect = 1
ELSE
	dw_detail.object.act_gu.Protect = 0
END IF

//만약 계약 내용이 인증용서비스이면 "일시정지확정"의 visible을 uncheck
SELECT COUNT(*) INTO :ll_cnt
FROM   PRICEPLAN_EQUIP
WHERE  PRICEPLAN = :ls_priceplan;

IF ll_cnt > 0 THEN
	dw_detail.object.act_gu.visible = 0	
ELSE
	dw_detail.object.act_gu.visible = 1	
END IF

THIS.setredraw(TRUE)

RETURN 0

end event

event dw_detail::doubleclicked;call super::doubleclicked;//If dwo.name = "partner" Then
//	If dw_detail.iu_cust_help.ib_data[1] Then
//			 dw_detail.Object.partner[row] = &
//			 dw_detail.iu_cust_help.is_data[1]
//			 dw_detail.Object.partnernm[row] = &
//			 dw_detail.iu_cust_help.is_data[1]
//	End If
//End If
end event

event dw_detail::itemchanged;call super::itemchanged;//if dwo.name = "partner" Then
//	If wfi_get_customerid(data) = -1 Then
//		dw_detail.object.partnernm[row] = ""
//	End If
//End If
end event

event dw_detail::buttonclicked;call super::buttonclicked;////Butonn Click
//iu_cust_msg = Create u_cust_a_msg
//iu_cust_msg.is_pgm_name = "상세품목조회"
//iu_cust_msg.is_grp_name = "서비스 일시정지 신청"
//iu_cust_msg.is_data[1] = Trim(String(This.object.contractmst_contractseq[row]))
//		
//OpenWithParm(b1w_inq_termorder_popup, iu_cust_msg)
//
//Return 0 
end event

event dw_detail::ue_init();call super::ue_init;//수행처
//dw_detail.idwo_help_col[1] = This.Object.partner
//dw_detail.is_help_win[1] = "b1w_hlp_partner_1"
//dw_detail.is_data[1] = "CloseWithReturn"
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_suspendorder_b
boolean visible = false
integer y = 1816
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_suspendorder_b
boolean visible = false
integer y = 1816
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_suspendorder_b
integer x = 59
integer y = 1900
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_suspendorder_b
integer x = 370
integer y = 1900
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_suspendorder_b
boolean visible = false
integer y = 844
end type

type dw_detail2 from u_d_base within b1w_reg_svc_suspendorder_b
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 940
integer width = 2071
integer height = 244
integer taborder = 20
boolean bringtotop = true
string dataobject = "b1dw_inq_termorder_popup"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
LONG	ll_row, ll_contractseq

THIS.SetRedraw(FALSE)

IF al_select_row = 0 THEN RETURN 0

ll_contractseq = dw_master.object.contractmst_contractseq[al_select_row]

ll_row = dw_detail2.Retrieve(ll_contractseq)

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

RETURN 0 
end event

type dw_detail3 from u_d_base within b1w_reg_svc_suspendorder_b
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 1268
integer width = 2071
integer height = 244
integer taborder = 30
boolean bringtotop = true
string dataobject = "b1dw_inq_validkey"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event type integer ue_retrieve(long al_select_row);//조회
STRING	ls_contractseq,		ls_where
LONG		ll_row

THIS.SetRedraw(FALSE)

IF al_select_row = 0 THEN RETURN 0
ls_contractseq = STRING(dw_master.object.contractmst_contractseq[al_select_row])

ls_where = ""
ls_where += " VALIDINFO.CONTRACTSEQ = TO_NUMBER('" + ls_contractseq + "') "

dw_detail3.is_where = ls_where
ll_row = dw_detail3.Retrieve()

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

IF dw_detail3.rowcount() > 0 THEN
	dw_detail3.visible = TRUE
ELSE
	dw_detail3.visible = FALSE
END IF

RETURN 0
end event

type dw_detail4 from datawindow within b1w_reg_svc_suspendorder_b
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 1600
integer width = 2071
integer height = 244
integer taborder = 70
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_inq_equipment"
boolean hscrollbar = true
boolean vscrollbar = true
boolean hsplitscroll = true
boolean livescroll = true
end type

event type integer ue_retrieve(long al_select_row);//조회
LONG		ll_row,			 ll_contractseq

THIS.SetRedraw(FALSE)

IF al_select_row = 0 THEN RETURN 0

ll_contractseq = dw_master.object.contractmst_contractseq[al_select_row]

ll_row = dw_detail4.Retrieve(ll_contractseq)
IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Equipment Info Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

RETURN 0 
end event

event constructor;SetTransObject(SQLCA)
end event

type gb_1 from groupbox within b1w_reg_svc_suspendorder_b
integer x = 2153
integer y = 876
integer width = 1413
integer height = 988
integer taborder = 50
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Suspend Request"
end type

type gb_2 from groupbox within b1w_reg_svc_suspendorder_b
integer x = 23
integer y = 876
integer width = 2112
integer height = 324
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Contract Detail"
end type

type gb_3 from groupbox within b1w_reg_svc_suspendorder_b
integer x = 23
integer y = 1204
integer width = 2112
integer height = 328
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Telephone Number Info"
end type

type gb_4 from groupbox within b1w_reg_svc_suspendorder_b
integer x = 23
integer y = 1536
integer width = 2112
integer height = 328
integer taborder = 60
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Equipment Info"
end type

