$PBExportHeader$ubs_w_reg_schedule.srw
$PBExportComments$[jhchoi] Tech 스케쥴 관리 - 2009.03.25
forward
global type ubs_w_reg_schedule from w_base
end type
type p_reset from u_p_reset within ubs_w_reg_schedule
end type
type p_ok from u_p_ok within ubs_w_reg_schedule
end type
type dw_master from u_d_base within ubs_w_reg_schedule
end type
type st_horizontal from statictext within ubs_w_reg_schedule
end type
type dw_cond from u_d_help within ubs_w_reg_schedule
end type
type p_close from u_p_close within ubs_w_reg_schedule
end type
type gb_1 from groupbox within ubs_w_reg_schedule
end type
end forward

global type ubs_w_reg_schedule from w_base
integer width = 3611
integer height = 1732
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_ok ( )
event type integer ue_reset ( )
p_reset p_reset
p_ok p_ok
dw_master dw_master
st_horizontal st_horizontal
dw_cond dw_cond
p_close p_close
gb_1 gb_1
end type
global ubs_w_reg_schedule ubs_w_reg_schedule

type variables
u_cust_db_app iu_cust_db_app

Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop						//The virtual top of the window
Integer		ii_WindowMiddle					//The virtual middle of the window
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Middle							//Reference to the Top Middle control
Dragobject	idrg_Bottom							//Reference to the Top Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides


String is_cus_status, is_hotbillflag, is_worktype[]
end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine wf_protect (string ai_gubun)
public subroutine of_resizebars ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public subroutine of_refreshbars ()
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck(ref integer ai_return);//필요없음...

ai_return = 0

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);//필요없음...

ai_return = 0

RETURN
end event

event ue_process(ref integer ai_return);//필요 없음...

ai_return = 0

RETURN
end event

event ue_ok;//해당 서비스에 해당하는 품목 조회
STRING	ls_shopid,			ls_workdt_from,		ls_workdt_to,		ls_work_type,		ls_phone_number, 	&
			ls_customerid,		ls_where
LONG		ll_row,				ll_result

dw_cond.AcceptText()

ls_shopid			= Trim(dw_cond.object.shopid[1]) 
ls_workdt_from		= Trim(String(dw_cond.object.workdt_from[1], 'yyyymmdd'))
ls_workdt_to		= Trim(String(dw_cond.object.workdt_to[1], 'yyyymmdd'))
ls_work_type		= Trim(dw_cond.object.work_type[1])
ls_phone_number	= Trim(dw_cond.object.phone_number[1])
ls_customerid		= Trim(dw_cond.object.customerid[1])

IF ISNULL(ls_shopid)			THEN ls_shopid			 = ""
IF ISNULL(ls_workdt_from)	THEN ls_workdt_from	 = ""
IF ISNULL(ls_workdt_to)		THEN ls_workdt_to		 = ""
IF ISNULL(ls_work_type)		THEN ls_work_type		 = ""
IF ISNULL(ls_phone_number)	THEN ls_phone_number	 = ""
IF ISNULL(ls_customerid)	THEN ls_customerid	 = ""

IF ls_workdt_from = "" THEN
	F_MSG_INFO(200, Title, "Work Date ( From )")
	dw_cond.SetFocus()
	dw_cond.SetColumn("worddt_from")
	RETURN
END IF

IF ls_workdt_to = "" THEN
	F_MSG_INFO(200, Title, "Work Date ( To )")
	dw_cond.SetFocus()
	dw_cond.SetColumn("worddt_to")
	RETURN
END IF

ls_where = "" 

ls_where += " SCHEDULE_DETAIL.PARTNER_WORK = '" + ls_shopid + "' "
//ls_where += " AND SCHEDULE_DETAIL.REQUESTDT BETWEEN TO_DATE('" + ls_workdt_from + "', 'YYYYMMDD') "
ls_where += " AND SCHEDULE_DETAIL.YYYYMMDD >= '" + ls_workdt_from + "' "
//ls_where += " AND TO_DATE('" + ls_workdt_to + "', 'YYYYMMDD') "
ls_where += " AND SCHEDULE_DETAIL.YYYYMMDD <= '" + ls_workdt_to + "' "

IF ls_work_type <> "" THEN
	ls_where += " AND SCHEDULE_DETAIL.WORKTYPE = '" + ls_work_type + "' "
END IF

IF ls_phone_number <> "" THEN
	ls_where += " AND CUSTOMERM.CUSTOMERID IN ( SELECT VALIDINFO.CUSTOMERID FROM VALIDINFO " + &
													 	   " WHERE  VALIDINFO.VALIDKEY = '" + ls_phone_number + "' ) "				
END IF														

IF ls_customerid <> "" THEN
	ls_where += " AND CUSTOMERM.CUSTOMERID = '" + ls_customerid + "' "
END IF								

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
END IF

SetRedraw(FALSE)

IF ll_row >= 0 THEN
	dw_master.SetFocus()

	dw_cond.Enabled = FALSE
	p_ok.TriggerEvent("ue_disable")
END IF

SetRedraw(TRUE)
end event

event type integer ue_reset();CONSTANT	INT LI_ERROR = -1
INT		li_rc
DATE		ld_sysdate

dw_master.Reset()
dw_cond.Reset()

dw_cond.Enabled = True

dw_master.InsertRow(0)
dw_cond.InsertRow(0)

SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') INTO :ld_sysdate
FROM   DUAL;

dw_cond.Object.workdt_from[1] = ld_sysdate
dw_cond.Object.workdt_to[1]	= ld_sysdate
dw_cond.Object.shopid[1]		= String(gs_shopid)

dw_cond.SetFocus()
dw_cond.SetColumn("workdt_from")
p_ok.TriggerEvent("ue_enable")

RETURN 0

end event

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
IF NOT IsValid(idrg_Top) OR NOT IsValid(idrg_Bottom) THEN RETURN

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

end subroutine

public subroutine wf_protect (string ai_gubun);String	ls_np_did,		ls_np_ori_carrier

dw_master.AcceptText()

CHOOSE CASE ai_gubun
	CASE "N"
		dw_master.Object.customerid.Color = RGB(255,255,255)						//글씨색
		dw_master.Object.customerid.Background.Color = RGB(107, 146, 140)		//필수 배경색
	CASE "Y"
		dw_master.Object.customerid.Color = RGB(0,0,0)								//글씨색
		dw_master.Object.customerid.Background.Color = RGB(255, 255, 255)		//선택 배경색		

END CHOOSE



end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

IF st_horizontal.Y < ii_WindowTop + 150 THEN
	st_horizontal.Y = ii_WindowTop + 150
END IF

IF st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 THEN
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
END IF

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

end subroutine

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
STRING 	ls_customernm, 	ls_payid, 	ls_partner, 	ls_customerid, 	ls_memberid
Integer	li_sw

IF as_customerid <> "" THEN
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
	SELECT  CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
			, MEMBERID
	INTO	  :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner,
			  :ls_memberid
	FROM    CUSTOMERM
	WHERE   CUSTOMERID = :as_customerid;
	 
	ls_customerid = as_customerid
ELSE
	SELECT  CUSTOMERID
			, CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
	INTO	  :ls_customerid,
	        :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner
	FROM    CUSTOMERM
	WHERE   MEMBERID = :as_memberid;
	
	ls_memberid = as_customerid
END IF

IF SQLCA.SQLCODE = 100 THEN		//Not Found
	IF li_sw = 1 THEN
   	F_MSG_USR_ERR(201, Title, "Customer ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("customerid")
	ELSE
   	F_MSG_USR_ERR(201, Title, "Member ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("memberid")
	END IF
   RETURN -1
END IF

SELECT HOTBILLFLAG
INTO   :is_hotbillflag
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_payid;

IF SQLCA.SQLCODE = 100 THEN		//Not Found
   F_MSG_USR_ERR(201, Title, "고객번호(납입자번호)")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   RETURN -1
END IF

IF IsNull(is_hotbillflag) THEN is_hotbillflag = ""
IF is_hotbillflag = 'S' THEN    //현재 Hotbilling고객이면 개통신청 못하게 한다.
   F_MSG_USR_ERR(201, Title, "즉시불처리중인고객")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   RETURN -1
END IF

dw_cond.object.customernm[1] 	= ls_customernm
dw_cond.object.customerid[1] 	= ls_customerid

RETURN 0

end function

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

on ubs_w_reg_schedule.create
int iCurrent
call super::create
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.st_horizontal=create st_horizontal
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reset
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.dw_master
this.Control[iCurrent+4]=this.st_horizontal
this.Control[iCurrent+5]=this.dw_cond
this.Control[iCurrent+6]=this.p_close
this.Control[iCurrent+7]=this.gb_1
end on

on ubs_w_reg_schedule.destroy
call super::destroy
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.st_horizontal)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : Tech(엔지니어) 스케쥴 관리 및 처리 화면    //
// Name       : ubs_w_prc_techschedule		                 //
// Contents   : Tech 스케쥴을 관리 한다. 지시서 출력 등	  //
// Data Window: dw - ubs_dw_prc_techschedule_cnd		     // 
//							ubs_dw_prc_techschedule_mas			  //
// 작성일자   : 2009.03.25                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,	ls_temp
DATE		ld_sysdate

dw_cond.InsertRow(0)
dw_master.InsertRow(0)

iu_cust_db_app = CREATE u_cust_db_app

SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') INTO :ld_sysdate
FROM   DUAL;

dw_cond.Object.workdt_from[1] = ld_sysdate
dw_cond.Object.workdt_to[1]	= ld_sysdate
dw_cond.Object.shopid[1]		= String(gs_shopid)

//작업 유형 값을 가져온다. sysctl1t('S1','C100')의 값을 가져와서 파싱
ls_ref_desc = ""
ls_temp     = fs_get_control("S1", "C100", ls_ref_desc)

IF ls_temp  = "" THEN RETURN

fi_cut_string(ls_temp, ";", is_worktype[])

// Set the Top, Bottom Controls
idrg_Top = dw_master

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()


end event

event close;call super::close;DESTROY iu_cust_db_app
end event

event resize;call super::resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_master.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_master.Height = 0
	
	p_reset.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
ELSE
	dw_master.Height = newheight - dw_master.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 

 	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
END IF

IF newwidth < dw_master.X  THEN
	dw_master.Width = 0
ELSE
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
END IF

IF newwidth < dw_master.X  THEN
	dw_master.Width = 0
ELSE
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
END IF

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(TRUE)

end event

type p_reset from u_p_reset within ubs_w_reg_schedule
integer x = 14
integer y = 1492
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_reg_schedule
integer x = 3227
integer y = 56
end type

type dw_master from u_d_base within ubs_w_reg_schedule
integer x = 14
integer y = 384
integer width = 3534
integer height = 1072
integer taborder = 30
string dataobject = "ubs_dw_reg_schedule_mas2"
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event buttonclicked;STRING	ls_worktype,			ls_orderno,			ls_priceplan,		ls_svccod,		ls_hostname, 	&
			ls_status,				ls_gubunnm,			ls_troubleno,		ls_set_value
LONG		ll_equipseq_update,	ll_scheduleseq, 	ll_valid_cnt,		ll_non_cnt

String ls_pgm_id, ls_pgm_name, ls_call_type, 	ls_call_name[4], ls_pgm_type, ls_p_pgm_id, ls_p_pgm_name
String ls_customerid, ls_call_nm
Dec{0} lc_upd_auth
Long ll_cnt,	ll_dsl_cnt, ll_non_valid_cnt
u_cust_a_msg lu_cust_msg
Window lw_temp
Any la_open
Int li_i
long ll_row

ll_row = row


CHOOSE CASE dwo.name
	CASE 'b_print'
		// 프린트 팝업 호출
	CASE 'b_valid'
		ls_orderno   = STRING(dw_master.Object.orderno[row])
		ls_priceplan = dw_master.Object.priceplan[row]
		ls_svccod	 = dw_master.Object.svccod[row]	
		ls_status	 = dw_master.Object.status[row]
		ls_worktype  = dw_master.Object.worktype[row]
		ls_troubleno = STRING(dw_master.Object.troubleno[row])
		
		IF (ls_worktype = '100' AND ls_status = '10') OR ls_worktype = '200' OR ls_worktype = '400' THEN  		//Install, 신규개통, A/S, auto
		
			SELECT COUNT(*) INTO :ll_dsl_cnt
			FROM   SYSCOD2T
			WHERE  GRCODE = 'BOSS05'
			AND    USE_YN = 'Y'
			AND    CODE   = :ls_svccod;		
			
			//인증 받지 않는 장비관리 서비스
			SELECT COUNT(*) INTO :ll_non_valid_cnt
			FROM SYSCOD2T
			WHERE GRCODE = 'BOSS06'
			AND USE_YN = 'Y'
			AND CODE = :ls_svccod;
		
			SELECT COUNT(*) INTO :ll_valid_cnt
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
			
			//DSL 장비 연결을 위한 팝업...
			IF ll_dsl_cnt > 0 THEN
				iu_cust_msg 				= CREATE u_cust_a_msg
				iu_cust_msg.is_pgm_name = "Schedule"
				iu_cust_msg.is_data2[1] = ls_worktype
				iu_cust_msg.is_data2[2] = ls_troubleno
				iu_cust_msg.is_data[1]  = "CloseWithReturn"
				iu_cust_msg.il_data[1]  = row
				iu_cust_msg.idw_data[1] = dw_master
				iu_cust_msg.is_data[2]  = ls_orderno
				iu_cust_msg.is_data[3]  = gs_shopid
				iu_cust_msg.is_data[4]  = gs_user_id
				iu_cust_msg.is_data[5]  = ls_priceplan
				iu_cust_msg.is_data[6]  = ls_svccod
				iu_cust_msg.is_data[7]  = ''
				iu_cust_msg.is_data[8]  = ls_status	
				iu_cust_msg.is_data[9]  = ''
				
				//장비인증 팝업 연결
				OpenWithParm(ubs_w_pop_equipvalid_dsl, iu_cust_msg)
			
				DESTROY iu_cust_msg			
				
			ELSEIF ll_non_valid_cnt > 0 THEN  //인증 받지 않는 장비관리 서비스(NEW CATV)
				
				iu_cust_msg 				= CREATE u_cust_a_msg
				iu_cust_msg.is_pgm_name = "Schedule"
				iu_cust_msg.is_data2[1] = ls_worktype
				iu_cust_msg.is_data2[2] = ls_troubleno
				iu_cust_msg.is_data[1]  = "CloseWithReturn"
				iu_cust_msg.il_data[1]  = row
				iu_cust_msg.idw_data[1] = dw_master
				iu_cust_msg.is_data[2]  = ls_orderno
				iu_cust_msg.is_data[3]  = gs_shopid
				iu_cust_msg.is_data[4]  = gs_user_id
				iu_cust_msg.is_data[5]  = ls_priceplan
				iu_cust_msg.is_data[6]  = ls_svccod
				iu_cust_msg.is_data[7]  = ''
				iu_cust_msg.is_data[8]  = ls_status	
				iu_cust_msg.is_data[9]  = ls_gubunnm
				
			
				//장비인증 팝업 연결
				OpenWithParm(ubs_w_pop_equipvalid_nonvalid, iu_cust_msg)
			
				DESTROY iu_cust_msg
				
			ELSE			
				IF ll_valid_cnt <= 0 THEN
					F_MSG_INFO(200, Title, "장비인증이 필요없는 서비스 입니다.")
					RETURN -1
				ELSE
					IF ll_non_cnt > 0 THEN
						F_MSG_INFO(200, Title, "장비인증이 필요없는 서비스 입니다.")
						RETURN -1
					END IF				
	//				IF ls_priceplan = "PRCM06" OR ls_priceplan = "PRCM08" OR ls_priceplan = "PRCM18" OR ls_priceplan = "PRCM19" THEN
	//					F_MSG_INFO(200, Title, "장비인증이 필요없는 서비스 입니다.")
	//					RETURN -1
	//				END IF
				END IF
					
		
				iu_cust_msg 				= CREATE u_cust_a_msg
				iu_cust_msg.is_pgm_name = "Schedule"
				iu_cust_msg.is_data2[1] = ls_worktype
				iu_cust_msg.is_data2[2] = ls_troubleno
				iu_cust_msg.is_data[1]  = "CloseWithReturn"
				iu_cust_msg.il_data[1]  = row
				iu_cust_msg.idw_data[1] = dw_master
				iu_cust_msg.is_data[2]  = ls_orderno
				iu_cust_msg.is_data[3]  = gs_shopid
				iu_cust_msg.is_data[4]  = gs_user_id
				iu_cust_msg.is_data[5]  = ls_priceplan
				iu_cust_msg.is_data[6]  = ls_svccod
				
				SELECT VOIP_HOSTNAME, GUBUN_NM INTO :ls_hostname, :ls_gubunnm
				FROM   PRICEPLANINFO
				WHERE  PRICEPLAN = :ls_priceplan;
				
				IF ls_hostname = 'VOCM' THEN
					iu_cust_msg.is_data[7]  = 'VOCM'
				ELSE
					iu_cust_msg.is_data[7]  = ''
				END IF		
		
				iu_cust_msg.is_data[8]  = ls_status	
				iu_cust_msg.is_data[9]  = ls_gubunnm
				
				//장비인증 팝업 연결
				OpenWithParm(ubs_w_pop_equipvalid, iu_cust_msg)
			
				DESTROY iu_cust_msg
			END IF				
		ELSE
			F_MSG_INFO(200, Title, "장비인증을 할 수 없는 WORK TYPE 입니다.")
			RETURN -1
		END IF
		
	CASE 'b_retrieve'
		// worktype 값에 따른 팝업 화면 분기. sysctl1t('S1','C100')의 값으로 분기				
		ls_orderno   = STRING(dw_master.Object.orderno[row])
		ls_worktype  = dw_master.Object.worktype[row]
		ls_troubleno = STRING(dw_master.Object.troubleno[row])	
		
		IF ls_worktype = is_worktype[1] OR ls_worktype = is_worktype[4] THEN				// worktype 이 첫번째 값(100) : 'install'인 경우
			ls_set_value = ls_orderno
		ELSE
			ls_set_value = ls_troubleno
		END IF

		//인증결과조회 호출	
		//화면띄워주기 위해 강제로 코딩!!! - 2009.06.03 최재혁			
		SetPointer(HourGlass!)
			
		SELECT PGM_ID, PGM_NM, P_PGM_ID,  UPD_AUTH, CALL_TYPE, PGM_TYPE, CALL_NM1
		INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
		FROM   SYSPGM1T
		WHERE  CALL_NM1 = 'ubs_w_reg_validresult'
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
		lu_cust_msg.is_call_name[2] = ls_worktype
		lu_cust_msg.is_call_name[3] = ls_set_value
		
		lu_cust_msg.is_pgm_type 	 = ls_pgm_type
		
		If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
			f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " + "window is not opened")
			Return -1
		End If		
		
//		// 세부정보 ( 인증, 계약, 가입자 정보 ) 팝업 호출
//		
//		ls_orderno   = STRING(dw_master.Object.orderno[row])
//		ls_worktype  = dw_master.Object.worktype[row]
//		ls_troubleno = STRING(dw_master.Object.troubleno[row])
//		
//		IF ls_worktype = '100' THEN  		//Install
//			iu_cust_msg 				= CREATE u_cust_a_msg
//			iu_cust_msg.is_pgm_name = "Schedule"
//			iu_cust_msg.is_data[1] = ls_worktype
//			iu_cust_msg.is_data[2] = ls_orderno
//			iu_cust_msg.idw_data[1] = dw_master	
//			iu_cust_msg.il_data[1]  = row			
//		ELSE
//			iu_cust_msg 				= CREATE u_cust_a_msg
//			iu_cust_msg.is_pgm_name = "Schedule"
//			iu_cust_msg.is_data[1] = ls_worktype
//			iu_cust_msg.is_data[2] = ls_troubleno	
//			iu_cust_msg.idw_data[1] = dw_master	
//			iu_cust_msg.il_data[1]  = row						
//		END IF		
//		
//		//조회 팝업 연결
//		OpenWithParm(ubs_w_pop_validresult, iu_cust_msg)
//	
//		DESTROY iu_cust_msg		
		
	CASE 'b_complete'		
		
		IF Messagebox("확인", "스케쥴 완료처리를 하시겠습니까?", Question!, YesNO!, 1) = 1 THEN
			ll_scheduleseq = dw_master.Object.scheduleseq[row]
		
			UPDATE SCHEDULE_DETAIL
			SET    STATUS = 'Y'
			WHERE  SCHEDULESEQ = :ll_scheduleseq;
			
			IF SQLCA.SQLCODE <> 0 THEN		//For Programer
				MessageBox("확인", SQLCA.SQLErrText)
				ROLLBACK;
				RETURN
			ELSE
				MessageBox("확인", "완료되었습니다")
				COMMIT;
			END IF
			
			THIS.Object.work_status[row] = 'Y'
			
		ELSE
			RETURN
		END IF
//2009.06.18일 막음...교체이기 때문에...
//		// worktype 값에 따른 팝업 화면 분기. sysctl1t('S1','C100')의 값으로 분기		
//		ls_worktype  = THIS.object.worktype[row]
//		ls_troubleno = STRING(THIS.object.troubleno[row])
//
//		IF ls_worktype = is_worktype[1] THEN				// worktype 이 첫번째 값(100) : 'install'인 경우
//			//	
//		ELSEIF ls_worktype = is_worktype[2] THEN			// worktype 이 첫번째 값(200) : 'A/S'인 경우
//			IF IsNull(ls_troubleno) = FALSE THEN
//				SELECT EQUIPSEQ INTO :ll_equipseq_update
//				FROM   EQUIP_CHANGE
//				WHERE  TROUBLENO = TO_NUMBER(:ls_troubleno);
//				
//				UPDATE EQUIPMST
//				SET    VALID_STATUS = '100',
//						 ORDERNO		  = NULL
//				WHERE  EQUIPSEQ     = :ll_equipseq_update;
//				
//				IF SQLCA.SQLCODE <> 0 THEN		//For Programer
//					ROLLBACK;
//					RETURN
//				ELSE
//					MessageBox("확인", "완료되었습니다")
//					COMMIT;
//				END IF
//			END IF
//		ELSE															// worktype 이 첫번째 값(300) : 'DUMMY'인 경우
//			// 처리로직..
//			
//		END IF
//2009.06.18-----------------------------------------------END
	CASE 'b_process'
		// worktype 값에 따른 팝업 화면 분기. sysctl1t('S1','C100')의 값으로 분기		
		ls_worktype = THIS.object.worktype[row]
		ls_orderno   = STRING(dw_master.Object.orderno[row])
		ls_status	 = dw_master.Object.status[row]
		
		IF ls_worktype = is_worktype[1] THEN				// worktype 이 첫번째 값(100) : 'install'인 경우
			// 개통처리 팝업 호출	
			//화면띄워주기 위해 강제로 코딩!!! - 2009.06.03 최재혁
			
			SetPointer(HourGlass!)
			
			SELECT PGM_ID, PGM_NM, P_PGM_ID,  UPD_AUTH, CALL_TYPE, PGM_TYPE, CALL_NM1
			INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
			FROM   SYSPGM1T
			WHERE  CALL_NM1 = 'ubs_w_reg_activation'
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
			lu_cust_msg.is_call_name[2] = ls_orderno
			lu_cust_msg.is_pgm_type 	 = ls_pgm_type
			
			If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
				f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " + "window is not opened")
				Return -1
			End If
			
		ELSEIF ls_worktype = is_worktype[2] THEN			// worktype 이 두번째 값(200) : 'A/S'인 경우
			// 장애처리 팝업 호출
			//화면띄워주기 위해 강제로 코딩!!! - 2009.06.18 최재혁
			ls_customerid   = STRING(dw_master.Object.customerid[row])
			
			SetPointer(HourGlass!)
			
			SELECT PGM_ID, PGM_NM, P_PGM_ID,  UPD_AUTH, CALL_TYPE, PGM_TYPE, CALL_NM1
			INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
			FROM   SYSPGM1T
			WHERE  CALL_NM1 = 'b1w_reg_customertrouble_v30'
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
		ELSEIF ls_worktype = is_worktype[4] THEN					// worktype 이 네번째 값(400) : 'AUTO'인 경우
			IF ls_status = '30' OR ls_status = '50' OR ls_status = '70' THEN			//SUSPENSION REQUEST: 중지, //Reactivation Request: 해소, //Termination Request: 해지
				SetPointer(HourGlass!)
				
				IF ls_status = '30' THEN
					ls_call_nm = 'b1w_reg_svc_suspend_b'
				ELSEIF ls_status = '50' THEN
					ls_call_nm = 'b1w_reg_svc_reactprc_a'
				ELSEIF ls_status = '70' THEN
					ls_call_nm = 'b1w_reg_svc_termprc_b_v20'
				END IF
				
				SELECT PGM_ID, PGM_NM, P_PGM_ID,  UPD_AUTH, CALL_TYPE, PGM_TYPE, CALL_NM1
				INTO   :ls_pgm_id, :ls_pgm_name, :ls_p_pgm_id, :lc_upd_auth, :ls_call_type, :ls_pgm_type, :ls_call_name[1]
				FROM   SYSPGM1T
				WHERE  CALL_NM1 = :ls_call_nm
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
				lu_cust_msg.is_pgm_type 	 = ls_pgm_type
				
				If OpenSheetWithParm(lw_temp, lu_cust_msg, ls_call_name[1], gw_mdi_frame, 1, Original!) <> 1 Then
					f_msg_usr_err_app(503, Parent.Title, "'" + ls_call_name[1] + "' " + "window is not opened")
					Return -1
				End If
			END IF
		ELSE
			// 처리로직..			
		END IF
END CHOOSE			


Trigger Event ue_ok()

SelectRow( ll_row , TRUE )
this.scrolltorow(ll_row)

end event

event clicked;call super::clicked;If row = 0 then Return

If IsSelected( row ) then
	//SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If


end event

type st_horizontal from statictext within ubs_w_reg_schedule
boolean visible = false
integer x = 18
integer y = 888
integer width = 553
integer height = 36
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16776960
boolean focusrectangle = false
end type

type dw_cond from u_d_help within ubs_w_reg_schedule
integer x = 37
integer y = 36
integer width = 3163
integer height = 312
integer taborder = 10
string dataobject = "ubs_dw_reg_schedule_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;call super::doubleclicked;THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid"
		IF iu_cust_help.ib_data[1] THEN
			is_cus_status 				= iu_cust_help.is_data[3]
			
			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 THEN
				RETURN -1	
			END IF
					
		END IF
END CHOOSE

RETURN 0 
end event

event ue_init();call super::ue_init;//Help Window
THIS.idwo_help_col[1] 	= THIS.Object.customerid
THIS.is_help_win[1] 		= "SSRT_hlp_customer"
THIS.is_data[1] 			= "CloseWithReturn"

THIS.SetFocus()
THIS.SetRow(1)
THIS.SetColumn('customerid')
end event

event itemchanged;call super::itemchanged;THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid" 
   	  wfi_get_customerid(data, "")
END CHOOSE
end event

event buttonclicked;call super::buttonclicked;u_cust_a_msg iu_cust_help2
STRING	ls_lease_period
DATE		ld_sysdate

IF dwo.name = 'b_car_from' THEN
	
	SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') INTO :ld_sysdate
	FROM   DUAL;	
	
	iu_cust_help2 = CREATE u_cust_a_msg
	
	iu_cust_help2.is_pgm_name = "Calendar"
	iu_cust_help2.is_grp_name = "날짜선택"
	iu_cust_help2.ib_data[1]  = True
	iu_cust_help2.idw_data[1] = dw_cond
	iu_cust_help2.is_data[1]  = "workdt_from"
	
	OpenWithParm(ubs_w_pop_calendar2, iu_cust_help2)	
	
	destroy iu_cust_help2
	
ELSEIF dwo.name = 'b_car_to' THEN
	iu_cust_help2 = CREATE u_cust_a_msg
	
	iu_cust_help2.is_pgm_name = "Calendar"
	iu_cust_help2.is_grp_name = "날짜선택"
	iu_cust_help2.ib_data[1]  = True
	iu_cust_help2.idw_data[1] = dw_cond
	iu_cust_help2.is_data[1]  = "workdt_to"	
	
	OpenWithParm(ubs_w_pop_calendar2, iu_cust_help2)	

	destroy iu_cust_help2	
		
END IF	

	
end event

type p_close from u_p_close within ubs_w_reg_schedule
integer x = 315
integer y = 1492
boolean originalsize = false
end type

type gb_1 from groupbox within ubs_w_reg_schedule
integer x = 14
integer y = 8
integer width = 3538
integer height = 360
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

