$PBExportHeader$b1w_reg_svc_termprc_b_v20.srw
$PBExportComments$[jhchoi] 서비스 해지 처리 - 2009.04.21
forward
global type b1w_reg_svc_termprc_b_v20 from w_a_reg_m_m
end type
type dw_detail2 from u_d_base within b1w_reg_svc_termprc_b_v20
end type
type dw_detail3 from u_d_base within b1w_reg_svc_termprc_b_v20
end type
type dw_detail4 from datawindow within b1w_reg_svc_termprc_b_v20
end type
type gb_1 from groupbox within b1w_reg_svc_termprc_b_v20
end type
type gb_2 from groupbox within b1w_reg_svc_termprc_b_v20
end type
type gb_3 from groupbox within b1w_reg_svc_termprc_b_v20
end type
type gb_4 from groupbox within b1w_reg_svc_termprc_b_v20
end type
end forward

global type b1w_reg_svc_termprc_b_v20 from w_a_reg_m_m
integer width = 3790
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
global b1w_reg_svc_termprc_b_v20 b1w_reg_svc_termprc_b_v20

type variables
String is_active[]
String is_suspendreq, is_suspend, is_equipstatus, is_reqactive
STRING	is_requestactive,		is_reqterm,		is_term,		is_termstatus,		is_date_check
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

event ue_processvalidcheck(ref integer ai_return);STRING	ls_sysdt,		ls_termdt,		ls_enddt,		ls_activedt,		ls_remark,		ls_status,	&
			ls_svccod
LONG		ll_row,			ll_cnt = 0,		ll_not_cnt = 0
INTEGER	ii

dw_detail.AcceptText()
dw_detail4.AcceptText()
ll_row = dw_detail4.RowCount()

ls_svccod = dw_master.Object.svcorder_svccod[dw_master.GetRow()]

SELECT COUNT(*) INTO :ll_not_cnt
FROM   SYSCOD2T
WHERE  GRCODE = 'BOSS05' 
AND    CODE = :ls_svccod;

IF ll_not_cnt <= 0  and ls_svccod <> '940CT' THEN  //new CATV 서비스 제외
	FOR ii = 1 TO ll_row
		ls_status = dw_detail4.object.valid_status[ii]
	
		IF ls_status <> is_equipstatus THEN
			ll_cnt++
		END IF
	NEXT	
	
	IF ll_cnt > 0 THEN
		F_MSG_INFO(9000, Title, "인증장비 해지 처리 오류입니다.")
		ai_return = -1
		RETURN  
	END IF
END IF	

//필수 항목 Check
ls_sysdt			= STRING(fdt_get_dbserver_now(),'yyyymmdd')		
ls_termdt		= STRING(dw_detail.object.termdt[1], 'yyyymmdd')
ls_enddt			= STRING(dw_detail.object.enddt[1],'yyyymmdd')
ls_activedt 	= STRING(dw_detail.object.contractmst_activedt[1],'yyyymmdd')
ls_remark 		= Trim(dw_detail.object.remark[1])
	
IF IsNull(ls_termdt)			THEN ls_termdt = ""
IF IsNull(ls_enddt) 			THEN ls_enddt = ""
IF IsNull(ls_activedt) 		THEN ls_activedt = ""		
IF IsNull(ls_remark) 		THEN ls_remark = ""
		
IF ls_termdt = "" THEN
	f_msg_usr_err(200, title, "Termination Date")
	ai_return = -1
	RETURN
END IF

IF ls_termdt < ls_sysdt OR ls_enddt < ls_sysdt THEN
	f_msg_usr_err(200, title, "해지일자, 과금종료일은 오늘날짜보다 커야 합니다.")
	ai_return = -1
	RETURN	
END IF

IF ls_termdt <= ls_activedt THEN
	f_msg_usr_err(200, title, "해지일자는 개통일보다 커야 합니다.")
	ai_return = -1
	RETURN
END IF
		
IF ls_enddt = "" THEN
	f_msg_usr_err(200, title, "Bill End Date")
	ai_return = -1
	RETURN
END IF
		
//과금종료일 <= 해지요청일
IF  ls_termdt <= ls_enddt THEN
	f_msg_usr_err(200, title, "과금종료일은 해지일자보다 작아야 합니다.")
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
dw_cond.SetColumn('orderdt')


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
dw_cond.SetColumn('orderdt')



end subroutine

on b1w_reg_svc_termprc_b_v20.create
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

on b1w_reg_svc_termprc_b_v20.destroy
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
// Desciption : 서비스 해지 처리				                 //
// Name       : b1w_reg_svc_termprc_b_v20	                 //
// Contents   : 서비스 해지 처리를 처리한다. 				  //
// Data Window: dw - b1dw_cnd_reg_suspend	       		     // 
//							b1dw_inq_termprc_ubs			  			  //
//							b1dw_inq_termorder_popup				  //
//							b1dw_inq_validkey				 			  //
//							b1dw_inq_equipment				  		  //
//							b1dw_reg_tremprc_ubs					  	  //
// 작성일자   : 2009.04.21                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc, ls_name[], ls_status
INT		is_cnt

is_requestactive = ""
is_reqterm 		  = ""
is_term 			  = ""
is_termstatus 	  = ""
is_date_check 	  = ""

//해지신청 상태코드 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_reqterm = ls_name[1]
is_term	  = ls_name[2]

is_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
is_termstatus 	  = fs_get_control("B0", "P201", ls_ref_desc)
//서비스계약/신청 :개통해지날짜 CHECK
is_date_check    = fs_get_control("B0", "P210", ls_ref_desc)
//해지처리 가능한 인증상태
is_equipstatus = fs_get_control("U0", "E300", ls_ref_desc)		

dw_cond.object.orderdt[1] 		= Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] 	= Date(fdt_get_dbserver_now())
dw_cond.Object.partner[1] 		= gs_shopid
end event

event ue_ok;call super::ue_ok;//조회
STRING	ls_orderdt,		ls_requestdt,		ls_partner,		ls_where,	&
			ls_customerid,	ls_svccod,			ls_priceplan
LONG		ll_row

ls_orderdt 		= STRING(dw_cond.object.orderdt[1],   'yyyymmdd')
ls_requestdt 	= STRING(dw_cond.object.requestdt[1], 'yyyymmdd')
ls_customerid = dw_cond.object.customerid[1]
ls_partner 		= Trim(dw_cond.object.partner[1])
ls_svccod	  = Trim(dw_cond.object.svccod[1]) 
ls_priceplan  = Trim(dw_cond.object.priceplan[1])

If IsNull(ls_orderdt) 		Then ls_orderdt 		= ""
If IsNull(ls_requestdt) 	Then ls_requestdt 	= ""
IF IsNull(ls_customerid)	THEN ls_customerid = ""
If IsNull(ls_partner) 		Then ls_partner 		= ""
IF IsNull(ls_svccod)			THEN ls_svccod = ""
IF IsNull(ls_priceplan) 	THEN ls_priceplan = ""

ls_where = ""
ls_where += " SVC.STATUS = '" + is_reqterm + "' "

IF ls_customerid <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += " SVC.CUSTOMERID = '" + ls_customerid + "' "
END IF

If ls_orderdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " TO_CHAR(SVC.ORDERDT, 'YYYYMMDD') <= '" + ls_orderdt + "' "
End If

If ls_requestdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " SVC.REQUESTDT <= TO_DATE('" + ls_requestdt + "', 'YYYYMMDD') "
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += " SVC.PARTNER = '" + ls_partner + "' "
End If

IF ls_svccod <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "  
  ls_where += " SVC.SVCCOD = '" + ls_svccod + "' " 
END IF

IF ls_priceplan <> "" THEN
  IF ls_where <> "" THEN ls_where += " AND "  
  ls_where += " SVC.PRICEPLAN = '" + ls_priceplan + "' " 
END IF

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If
	
dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.





end event

event ue_extra_save;INTEGER	li_cnt
STRING	ls_contractseq,		ls_remark,				ls_errmsg,		ls_termtype,	&
			ls_action,				ls_status,		ls_svccod
DATETIME	ld_requestdt,			ld_enddt
LONG		ll_row,					ll_return,				ll_orderno,		ll_equip_cnt,		ll_non_valid_cnt

dw_detail.AcceptText()
ll_row = dw_detail.GetRow()

ls_contractseq 		= String(dw_detail.object.contractmst_contractseq[ll_row])
ld_requestdt	 		= dw_detail.Object.termdt[ll_row]
ld_enddt					= dw_detail.Object.enddt[ll_row]
ls_remark				= dw_detail.Object.remark[ll_row]
ls_termtype				= dw_detail.Object.svcorder_termtype[ll_row]
ll_orderno				= dw_detail.Object.svcorder_orderno[ll_row]
ls_svccod				= dw_detail.Object.contractmst_svccod[ll_row]

//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

//저장 프로시저 실행!
ls_errmsg  = space(1000)
ll_return  = 0
SQLCA.UBS_REG_TERMORDER( ls_contractseq,	ll_orderno,		DATE(ld_requestdt),		DATE(ld_enddt),		'prc',			&
								 ls_termtype,		gs_shopid,	   ls_remark,  				gs_user_id,				gs_pgm_id[1],	&
								 ll_return,			ls_errmsg )
										
										
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_TERMORDER ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_TERMORDER ' + ls_errmsg,Exclamation!,OK!)
	RETURN -1
END IF	

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
		 MAKERCD,	MODELNO,						STATUS,		'900',			USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			NULL,				NULL,			NULL,				CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
		 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
		 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
FROM   EQUIPMST
WHERE  CONTRACTSEQ = :ls_contractseq;

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX("확인", 'INSERT EQUIPLOG' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	RETURN -1
END IF


//인증 받지 않는 장비관리 서비스
SELECT COUNT(*) INTO :ll_non_valid_cnt
FROM SYSCOD2T
WHERE GRCODE = 'BOSS06'
AND USE_YN = 'Y'
AND CODE = :ls_svccod;

//2009.06.11 추가. 개통처리시 EQUIPMST 계약번호 업데이트!!!
SELECT COUNT(*), MAX(STATUS) INTO :ll_equip_cnt, :ls_status
FROM   EQUIPMST
WHERE  CONTRACTSEQ = :ls_contractseq;

IF ll_equip_cnt > 0 THEN
	IF ls_status = '700' OR ls_status = '701' or ll_non_valid_cnt > 0 THEN   //분실, 미반납...
		UPDATE EQUIPMST
		SET    VALID_STATUS	= '900',
				 UPDT_USER		= :gs_user_id,
				 UPDTDT			= SYSDATE
		WHERE  CONTRACTSEQ	= :ls_contractseq;	
	ELSE
		UPDATE EQUIPMST
		SET    ORDERNO		 = NULL,
				 CONTRACTSEQ = NULL,
				 CUSTOMERID  = NULL,
				 VALID_STATUS = '900',
				 UPDT_USER		= :gs_user_id,				 
				 UPDTDT = SYSDATE
		WHERE  CONTRACTSEQ = :ls_contractseq;
	END IF
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX("확인", 'UPDATE EQUIPMST' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		RETURN -1
	END IF		
END IF	
//2009.06.11 추가.-------------------------------------END

Return 0
end event

event type integer ue_save();//조회.
STRING	ls_partner
DATE		ld_orderdt,		ld_requestdt

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
	f_msg_info(3010,THIS.Title,"해지 처리")
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
	f_msg_info(3000,THIS.Title,"해지 처리")

END IF

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//재조회 처리
ld_orderdt	 = dw_cond.object.orderdt[1]
ld_requestdt = dw_cond.object.requestdt[1]
ls_partner	 = Trim(dw_cond.object.partner[1])

TRIGGER EVENT ue_reset()
dw_cond.object.orderdt[1] = ld_orderdt
dw_cond.object.requestdt[1] = ld_requestdt
dw_cond.object.partner[1] = ls_partner
TRIGGER EVENT ue_ok()

RETURN 0
end event

event type integer ue_reset();call super::ue_reset;dw_detail.Reset()
dw_detail2.Reset()
dw_detail3.Reset()
dw_detail4.Reset()

//Setting
dw_cond.object.orderdt[1]	 = Date(fdt_get_dbserver_now())
dw_cond.object.requestdt[1] = Date(fdt_get_dbserver_now())
dw_cond.Object.partner[1]	 = gs_shopid

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

type dw_cond from w_a_reg_m_m`dw_cond within b1w_reg_svc_termprc_b_v20
integer y = 40
integer width = 3328
integer height = 232
string dataobject = "b1dw_cnd_reg_suspend_new"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

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

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			Object.customerid[row] 	= iu_cust_help.is_data[1]
			object.customernm[row] 	= iu_cust_help.is_data[2]
		End If

End Choose

Return 0 
end event

event dw_cond::ue_init;This.idwo_help_col[1] 	= This.Object.customerid
This.is_help_win[1] 		= "SSRT_hlp_customer"
This.is_data[1] 			= "CloseWithReturn"

dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn('customerid')

end event

type p_ok from w_a_reg_m_m`p_ok within b1w_reg_svc_termprc_b_v20
integer x = 3401
integer y = 88
end type

type p_close from w_a_reg_m_m`p_close within b1w_reg_svc_termprc_b_v20
integer x = 681
integer y = 1900
end type

type gb_cond from w_a_reg_m_m`gb_cond within b1w_reg_svc_termprc_b_v20
integer width = 3694
integer height = 288
integer taborder = 0
end type

type dw_master from w_a_reg_m_m`dw_master within b1w_reg_svc_termprc_b_v20
integer x = 27
integer y = 304
integer width = 3698
integer height = 556
integer taborder = 40
string dataobject = "b1dw_inq_termprc_ubs"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.svcorder_orderno_t
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
		dw_detail4.Reset()				
	End If
End If

end event

type dw_detail from w_a_reg_m_m`dw_detail within b1w_reg_svc_termprc_b_v20
integer x = 1701
integer y = 940
integer width = 2002
integer height = 904
integer taborder = 50
string dataobject = "b1dw_reg_tremprc_ubs"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event type integer dw_detail::ue_retrieve(long al_select_row);//조회
STRING	ls_orderno, 	ls_where
LONG		ll_row
DATE		ld_termdt

IF al_select_row = 0 THEN RETURN 0

THIS.setredraw(FALSE)

ls_orderno = STRING(dw_master.object.svcorder_orderno[al_select_row])

ls_where = ""
ls_where += " SVC.ORDERNO = TO_NUMBER('" + ls_orderno + "') "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') + 1 INTO :ld_termdt
FROM   DUAL;

//setting
dw_detail.object.enddt[1] = DATE(fdt_get_dbserver_now())
dw_detail.object.termdt[1] = ld_termdt                     //RelativeDate(DATE(fdt_get_dbserver_now()), 1)

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

IF dw_detail2.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

IF dw_detail3.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

IF dw_detail4.TRIGGER EVENT ue_retrieve(al_select_row) < 0 THEN
	RETURN -1
END IF

THIS.setredraw(TRUE)

Return 0
end event

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;//Setting
If dwo.name = "termdt" Then
	dw_detail.object.enddt[row] =  datetime(relativedate(date(This.object.termdt[row]), -1))			
End If
end event

type p_insert from w_a_reg_m_m`p_insert within b1w_reg_svc_termprc_b_v20
boolean visible = false
integer y = 1816
end type

type p_delete from w_a_reg_m_m`p_delete within b1w_reg_svc_termprc_b_v20
boolean visible = false
integer y = 1816
end type

type p_save from w_a_reg_m_m`p_save within b1w_reg_svc_termprc_b_v20
integer x = 59
integer y = 1900
end type

type p_reset from w_a_reg_m_m`p_reset within b1w_reg_svc_termprc_b_v20
integer x = 370
integer y = 1900
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b1w_reg_svc_termprc_b_v20
boolean visible = false
integer y = 844
end type

type dw_detail2 from u_d_base within b1w_reg_svc_termprc_b_v20
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 940
integer width = 1609
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

ll_contractseq = dw_master.object.svcorder_ref_contractseq[al_select_row]

ll_row = dw_detail2.Retrieve(ll_contractseq)

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve()")
	RETURN -1
END IF

THIS.SetRedraw(TRUE)

RETURN 0 
end event

type dw_detail3 from u_d_base within b1w_reg_svc_termprc_b_v20
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 1268
integer width = 1609
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
ls_contractseq = STRING(dw_master.object.svcorder_ref_contractseq[al_select_row])

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

type dw_detail4 from datawindow within b1w_reg_svc_termprc_b_v20
event type integer ue_retrieve ( long al_select_row )
integer x = 41
integer y = 1600
integer width = 1609
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

ll_contractseq = dw_master.object.svcorder_ref_contractseq[al_select_row]

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

type gb_1 from groupbox within b1w_reg_svc_termprc_b_v20
integer x = 1682
integer y = 876
integer width = 2048
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
string text = "Request Info"
end type

type gb_2 from groupbox within b1w_reg_svc_termprc_b_v20
integer x = 23
integer y = 876
integer width = 1650
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

type gb_3 from groupbox within b1w_reg_svc_termprc_b_v20
integer x = 23
integer y = 1204
integer width = 1650
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

type gb_4 from groupbox within b1w_reg_svc_termprc_b_v20
integer x = 23
integer y = 1536
integer width = 1650
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

