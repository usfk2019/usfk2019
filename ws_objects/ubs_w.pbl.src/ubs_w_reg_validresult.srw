$PBExportHeader$ubs_w_reg_validresult.srw
$PBExportComments$[jhchoi] 장비인증 결과 조회- 2009.06.13
forward
global type ubs_w_reg_validresult from w_base
end type
type dw_detail from datawindow within ubs_w_reg_validresult
end type
type dw_4 from datawindow within ubs_w_reg_validresult
end type
type dw_3 from datawindow within ubs_w_reg_validresult
end type
type p_reset from u_p_reset within ubs_w_reg_validresult
end type
type p_ok from u_p_ok within ubs_w_reg_validresult
end type
type dw_master from u_d_base within ubs_w_reg_validresult
end type
type st_horizontal from statictext within ubs_w_reg_validresult
end type
type dw_cond from u_d_help within ubs_w_reg_validresult
end type
type p_close from u_p_close within ubs_w_reg_validresult
end type
type gb_1 from groupbox within ubs_w_reg_validresult
end type
type gb_2 from groupbox within ubs_w_reg_validresult
end type
type gb_3 from groupbox within ubs_w_reg_validresult
end type
type gb_5 from groupbox within ubs_w_reg_validresult
end type
type gb_6 from groupbox within ubs_w_reg_validresult
end type
type dw_1 from datawindow within ubs_w_reg_validresult
end type
end forward

global type ubs_w_reg_validresult from w_base
integer width = 3845
integer height = 2364
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_ok ( )
event type integer ue_reset ( )
dw_detail dw_detail
dw_4 dw_4
dw_3 dw_3
p_reset p_reset
p_ok p_ok
dw_master dw_master
st_horizontal st_horizontal
dw_cond dw_cond
p_close p_close
gb_1 gb_1
gb_2 gb_2
gb_3 gb_3
gb_5 gb_5
gb_6 gb_6
dw_1 dw_1
end type
global ubs_w_reg_validresult ubs_w_reg_validresult

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


String is_cus_status, is_hotbillflag, is_worktype[], is_siid
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
STRING	ls_customerid,		ls_where
STRING	ls_oldsql_1,		ls_oldsql_2,	ls_oldsql_3,		ls_oldsql_4,	&
			ls_subsno,			ls_macaddr,		ls_validkey,							&
			ls_sql_1,			ls_sql_2,		ls_sql_3,								&
			ls_new_sql1,		ls_new_sql2,	ls_new_sql3,		ls_siid,			&
			ls_gubun,			ls_gubun3,		ls_new_validkey
LONG		ll_row,				ll_result,		ll_orderno,			ll_length
LONG		ll_cnd,				ll_order_cnd,	ll_subsno_cnd,		ll_macaddr_cnt,	ll_validkey_cnd,	&
			ll_equip_cnt,		ll_equip_cnt2,	ll_siid_cnt
			
dw_cond.AcceptText()

//ls_customerid	= Trim(dw_cond.object.customerid[1])
ll_orderno		= dw_cond.object.orderno[1]
ls_subsno      = STRING(dw_cond.object.subsno[1])
ls_macaddr     = Lower(dw_cond.object.macaddr[1])
ls_validkey	   = dw_cond.object.validkey[1]		

IF IsNull(ll_orderno)	THEN ll_orderno	 = 0
IF IsNull(ls_subsno)		THEN ls_subsno		 = ""
IF IsNull(ls_macaddr)	THEN ls_macaddr	 = ""
IF IsNull(ls_validkey)	THEN ls_validkey	 = ""

ll_cnd = 0
IF ll_orderno <> 0 THEN
	ll_cnd += 1
	ll_order_cnd += 1
END IF

IF ls_subsno <> "" THEN
	ll_cnd += 1
	ll_subsno_cnd += 1	
END IF

IF ls_macaddr <> "" THEN
	ll_cnd += 1
	ll_macaddr_cnt += 1
END IF

IF ls_validkey <> "" THEN
	ll_cnd += 1
	ll_validkey_cnd += 1
END IF

IF ll_cnd = 0  THEN
	F_MSG_INFO(200, Title, "조회조건을 입력하세요!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("orderno")
	RETURN
ELSEIF ll_cnd > 1 THEN
	F_MSG_INFO(200, Title, "조회조건은 하나만 입력하세요!")
	dw_cond.SetFocus()
	dw_cond.SetColumn("orderno")
	RETURN	
END IF

IF ll_order_cnd > 0 THEN
	//2009.09.07 jhchoi vonet, vocm 일 경우 한개의 계약으로 2개의 siid 가 존재하기 때문에...
	SELECT COUNT(*) INTO :ll_siid_cnt
	FROM   SIID
	WHERE  ORDERNO = :ll_orderno;
	
	IF ll_siid_cnt <= 1 THEN	
		SELECT SIID INTO :is_siid
		FROM   SIID
		WHERE  ORDERNO = :ll_orderno;
	ELSEIF ll_siid_cnt > 1 THEN
		//인터넷 가번 찾기
		SELECT MAX(SIID) INTO :is_siid
		FROM   SIID
		WHERE  ORDERNO = :ll_orderno
		AND    DACOM_SVCTYPE = '1520';
		//인터넷 이외 가번 찾기
		SELECT MAX(SIID) INTO :ls_siid
		FROM   SIID
		WHERE  ORDERNO = :ll_orderno
		AND    DACOM_SVCTYPE <> '1520';
	END IF		

	ls_where = "" 

	ls_where += " a.orderno = '" + STRING(ll_orderno) + "' "

	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()

	IF ll_row < 0 THEN
		F_MSG_INFO(2100, Title, "Retrieve()")
	   RETURN
	END IF
END IF

IF ll_subsno_cnd > 0 THEN
	SELECT ORDERNO INTO :ll_orderno
	FROM   SIID
	WHERE  SIID = :ls_subsno;
		
	IF IsNull(ll_orderno) OR ll_orderno = 0 THEN
		F_MSG_INFO(200, Title, "존재하지 않는 가입자 번호 입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("subsno")
		RETURN
	END IF

	ls_where = "" 
	
	ls_where += " a.orderno = '" + STRING(ll_orderno) + "' "
	
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
	
	IF ll_row < 0 THEN
		F_MSG_INFO(2100, Title, "Retrieve()")
		RETURN
	END IF
END IF

IF ll_macaddr_cnt > 0 THEN
	SELECT ORDERNO, COUNT(*) INTO :ll_orderno, :ll_equip_cnt
	FROM   EQUIPMST
	WHERE  MAC_ADDR = LOWER(:ls_macaddr)
	GROUP BY ORDERNO;
			
	IF IsNull(ll_orderno) OR ll_orderno = 0 THEN
		SELECT ORDERNO, COUNT(*) INTO :ll_orderno, :ll_equip_cnt2
		FROM   EQUIPMST
		WHERE  MAC_ADDR2 = LOWER(:ls_macaddr)
		GROUP BY ORDERNO;
				
		IF IsNull(ll_orderno) OR ll_orderno = 0 THEN
			IF ll_equip_cnt + ll_equip_cnt2 <= 0 THEN
				F_MSG_INFO(200, Title, "존재하지 않는 MAC Address 입니다.")
				dw_cond.SetFocus()
				dw_cond.SetColumn("macaddr")
				RETURN
			END IF
		END IF
	END IF
	
	IF IsNull(ll_orderno) = False OR ll_orderno <> 0 THEN
		SELECT SIID INTO :is_siid
		FROM   SIID
		WHERE  ORDERNO = :ll_orderno;
	ELSE
		ll_orderno = 0	
	END IF

	ls_where = "" 
	
	ls_where += " a.orderno = '" + STRING(ll_orderno) + "' "	
		
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
		
	IF ll_row < 0 THEN
		F_MSG_INFO(2100, Title, "Retrieve()")
		RETURN
	END IF
END IF

IF ll_validkey_cnd > 0 THEN
	SELECT ORDERNO INTO :ll_orderno
	FROM ( SELECT ORDERNO
			 FROM   VALIDINFO
			 WHERE  VALIDKEY = :ls_validkey
			 ORDER BY ORDERNO DESC )
	WHERE  ROWNUM = 1;
				
	IF IsNull(ll_orderno) OR ll_orderno = 0 THEN
		F_MSG_INFO(200, Title, "존재하지 않는 전화번호 입니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("validkey")
		RETURN
	END IF
			
	SELECT SIID INTO :is_siid
	FROM   SIID
	WHERE  ORDERNO = :ll_orderno;
				
	ls_where = "" 
			
	ls_where += " a.orderno = '" + STRING(ll_orderno) + "' "
			
	dw_master.is_where = ls_where
	ll_row = dw_master.Retrieve()
			
	IF ll_row < 0 THEN
		F_MSG_INFO(2100, Title, "Retrieve()")
		RETURN
	END IF
	
	//444 규격 바꾸기	
	ll_length = LenA(ls_validkey)
	ls_gubun  = MidA(ls_validkey, 1, 2)
	ls_gubun3 = MidA(ls_validkey, 1, 3)	
	
	IF ls_gubun = "02" THEN
		IF ll_length = 10 THEN		//얘는 앞에 00 만 붙이면 끝
			ls_new_validkey = "00" + ls_validkey
		ELSEIF ll_length = 9 THEN
			ls_new_validkey = "00" + ls_gubun + '0' + MidA(ls_validkey, 3, 7)
		ELSE
			F_MSG_INFO(200, Title, "전화번호를 확인하시기 바랍니다.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("validkey")
			RETURN			
		END IF
	ELSE
		IF ls_gubun3 = "070" THEN
			ls_new_validkey = "0" + ls_validkey
		ELSE
			IF ll_length = 10 THEN
				ls_new_validkey = "0" + ls_gubun3 + '0' + MidA(ls_validkey, 4, 7)
			ELSEIF ll_length = 11 THEN
				ls_new_validkey = "0" + ls_validkey
			ELSE
				F_MSG_INFO(200, Title, "전화번호를 확인하시기 바랍니다.")
				dw_cond.SetFocus()
				dw_cond.SetColumn("validkey")
				RETURN											
			END IF
		END IF
	END IF
	
END IF

SetRedraw(FALSE)

ls_sql_1 = "SELECT SUBSNO,   SUBSSTATUS,   UPDATETIME,   SETDN,             SIPID, " +&
			  "       SIPPWD,   IPADDRESS,    MACADDRESS,   PROV_UPDATETIME,   SN, 	  " +&
			  "       CPETYPE,  EQUIP_CNT,    SSWIP,        SSWIPFLAG,					  " +&
			  "		 CASE WHEN IPADDRESS = EXT_IPADDR THEN '-'							  " +&
			  "       ELSE EXT_IPADDR END AS EXT_IPADDR,										  " +&	
			  "       CASE WHEN IPADDRESS != EXT_IPADDR THEN 'Y'							  " +&
			  "            ELSE 'N' END AS LINE_SHARER,										  " +&	
			  "       CASE WHEN PROV_FLAG = '0' OR PROV_FLAG = '1' THEN '성공'		  " +&	
			  "	         WHEN PROV_FLAG = '2' AND UPPER(PROV_FAILCAUSE) LIKE UPPER('%ERR_SSW_REG%') THEN '성공'		" +&
			  "            WHEN PROV_FLAG = '2' AND UPPER(PROV_FAILCAUSE) LIKE UPPER('%ERROR_CAUSE%') THEN '성공'		" +&
			  "            WHEN PROV_FLAG = '2' THEN '실패 (' || NVL(PROV_FAILCAUSE,'-') || ')' 							" +&
			  "            WHEN PROV_FLAG IS NULL THEN '단말미접속(로그파일확인)'												" +&
			  "            ELSE '-' END AS PROV_FLAG, 																					" +&	
			  "       CASE WHEN PROV_FLAG = '2' AND UPPER(PROV_FAILCAUSE) LIKE UPPER('%ERROR_CAUSE%') THEN '실패 (' || NVL(PROV_FAILCAUSE,'-') || ')'	" +&
			  "            WHEN PROV_FLAG = '2' AND UPPER(PROV_FAILCAUSE) LIKE UPPER('%ERR_SSW_REG%') THEN '실패 (' || NVL(PROV_FAILCAUSE,'-') || ')'	" +&
			  "            WHEN PROV_FLAG IS NULL THEN '-'			" +&
			  "            ELSE '성공' END AS SSWPROV_FLAG,			" +&
			  "       PRODCD													" +&
			  "FROM   BC_CONFIG_VOIP					"
			  
ls_sql_2 = "SELECT SUBSNO, ACTION, STATUS, TIMESTAMP, UPDATETIME, 			" +&
			  "       SETDN, MACADDRESS, DN, ADDSERVICELIST, CALLRESTRICT,		" +&
			  "       OLDDN, CARRY_NO, PORT_FLAG, BEFORE_COMP, LONG_COMP, 		" +&
			  "       CASE WHEN FLAG = '0' THEN '등록전'  							" +&
			  "            WHEN FLAG = '1' THEN '등록성공'  						" +&
			  "            WHEN FLAG = '8' THEN '등록실패'   						" +&
			  "                            else '등록실패'   						" +&
			  "            END AS FLAG_STR,  											" +&
			  "       NVL(FAILCAUSE,'-') FAILCAUSE, PRODCD 							" +&
			  "FROM   BC_REG_SSW											"

ls_sql_3 = "SELECT SUBSNO, ACTION, STATUS, TIMESTAMP, UPDATETIME, MACADDRESS, 	" +&
			  "       CASE WHEN FLAG = '0' THEN '등록전'  									" +&
			  "            WHEN FLAG = '1' THEN '등록성공'									" +&  
			  "            WHEN FLAG = '8' THEN '등록실패'									" +&   
			  "                            else '등록실패'   						" +&
			  "            END AS FLAG_STR,  													" +&	
			  "       NVL(FAILCAUSE,'-') FAILCAUSE  ,											" +&
			  "       PCCOUNT, NETWORKTYPE, VOIP_HOSTNAME, USERNO, PROD_CD				" +&	
			  "FROM   BC_AUTH														"

IF ll_order_cnd > 0  THEN
	IF ll_siid_cnt <= 1 THEN
		ls_new_sql1 = ls_sql_1 + " WHERE SUBSNO = '" + is_siid + "' ORDER BY UPDATETIME DESC "	
		
		ls_new_sql2 = ls_sql_2 + " WHERE SUBSNO = '" + is_siid + "' AND CPETYPE != '무선AP' ORDER BY UPDATETIME DESC "	
		
		ls_new_sql3 = ls_sql_3 + " WHERE SUBSNO = '" + is_siid + "' ORDER BY UPDATETIME DESC "	
	ELSEIF ll_siid_cnt > 1 THEN
		ls_new_sql1 = ls_sql_1 + " WHERE SUBSNO IN ('" + is_siid + "', '" + ls_siid + "') ORDER BY UPDATETIME DESC "	
		
		ls_new_sql2 = ls_sql_2 + " WHERE SUBSNO IN ('" + is_siid + "', '" + ls_siid + "') AND CPETYPE != '무선AP' ORDER BY UPDATETIME DESC "	
		
		ls_new_sql3 = ls_sql_3 + " WHERE SUBSNO IN ('" + is_siid + "', '" + ls_siid + "') ORDER BY UPDATETIME DESC "			
		
	END IF
END IF

IF ll_subsno_cnd > 0 THEN
	ls_new_sql1 = ls_sql_1 + " WHERE SUBSNO = '" + ls_subsno + "' ORDER BY UPDATETIME DESC "	
	
	ls_new_sql2 = ls_sql_2 + " WHERE SUBSNO = '" + ls_subsno + "' AND CPETYPE != '무선AP' ORDER BY UPDATETIME DESC "	
	
	ls_new_sql3 = ls_sql_3 + " WHERE SUBSNO = '" + ls_subsno + "' ORDER BY UPDATETIME DESC "		
END IF

IF ll_macaddr_cnt > 0 THEN
	ls_new_sql1 = ls_sql_1 + " WHERE MACADDRESS = '" + ls_macaddr + "' ORDER BY UPDATETIME DESC "
	
	ls_new_sql2 = ls_sql_2 + " WHERE MACADDRESS = '" + ls_macaddr + "' AND CPETYPE != '무선AP' ORDER BY UPDATETIME DESC "	
	
	ls_new_sql3 = ls_sql_3 + " WHERE MACADDRESS = '" + ls_macaddr + "' ORDER BY UPDATETIME DESC "			
END IF
	
	
IF ll_validkey_cnd > 0 THEN
	ls_new_sql1 = ls_sql_1 + " WHERE DN = '" + ls_new_validkey + "' ORDER BY UPDATETIME DESC "
	
	ls_new_sql2 = ls_sql_2 + " WHERE DN = '" + ls_new_validkey + "' AND CPETYPE != '무선AP' ORDER BY UPDATETIME DESC "	
	
//	ls_new_sql3 = ls_sql_3 + " WHERE MACADDRESS = '" + ls_macaddr + "' ORDER BY UPDATETIME DESC "
END IF	


dw_1.SetSqlSelect(ls_new_sql1)
dw_1.Retrieve()

dw_3.SetSqlSelect(ls_new_sql2)
dw_3.Retrieve()

IF ll_validkey_cnd <= 0 THEN
	dw_4.SetSqlSelect(ls_new_sql3)
	dw_4.Retrieve()
END IF

is_siid = ""

SetRedraw(TRUE)
end event

event ue_reset;CONSTANT	INT LI_ERROR = -1
INT		li_rc
DATE		ld_sysdate

dw_cond.Reset()
dw_master.Reset()
dw_1.Reset()
dw_3.Reset()
dw_4.Reset()
dw_detail.Reset()

dw_cond.Enabled = True

dw_cond.InsertRow(0)
dw_master.InsertRow(0)
dw_1.InsertRow(0)
dw_3.InsertRow(0)
dw_4.InsertRow(0)
dw_detail.InsertRow(0)

dw_cond.SetFocus()
dw_cond.SetColumn("orderno")

p_ok.TriggerEvent("ue_enable")

is_siid = ""
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

on ubs_w_reg_validresult.create
int iCurrent
call super::create
this.dw_detail=create dw_detail
this.dw_4=create dw_4
this.dw_3=create dw_3
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.st_horizontal=create st_horizontal
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_1=create gb_1
this.gb_2=create gb_2
this.gb_3=create gb_3
this.gb_5=create gb_5
this.gb_6=create gb_6
this.dw_1=create dw_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail
this.Control[iCurrent+2]=this.dw_4
this.Control[iCurrent+3]=this.dw_3
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.p_ok
this.Control[iCurrent+6]=this.dw_master
this.Control[iCurrent+7]=this.st_horizontal
this.Control[iCurrent+8]=this.dw_cond
this.Control[iCurrent+9]=this.p_close
this.Control[iCurrent+10]=this.gb_1
this.Control[iCurrent+11]=this.gb_2
this.Control[iCurrent+12]=this.gb_3
this.Control[iCurrent+13]=this.gb_5
this.Control[iCurrent+14]=this.gb_6
this.Control[iCurrent+15]=this.dw_1
end on

on ubs_w_reg_validresult.destroy
call super::destroy
destroy(this.dw_detail)
destroy(this.dw_4)
destroy(this.dw_3)
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.st_horizontal)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_1)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.gb_5)
destroy(this.gb_6)
destroy(this.dw_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 장비인증 결과 조회 화면					     //
// Name       : ubs_w_reg_validresult		                 //
// Contents   : 장비인증 결과를 확인한다.						  //
// 작성일자   : 2009.06.14                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,		ls_temp,				ls_worktype,		ls_get_value,	&
			ls_customerid,		ls_customernm,		ls_contractseq
LONG		ll_orderno
DATE		ld_sysdate

dw_cond.InsertRow(0)
dw_master.InsertRow(0)

iu_cust_db_app = CREATE u_cust_db_app

// Set the Top, Bottom Controls
idrg_Top = dw_master

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

ls_worktype  = iu_cust_msg.is_call_name[2]
ls_get_value = iu_cust_msg.is_call_name[3]

IF IsNull(ls_worktype) = False THEN
	IF ls_worktype = '100' OR ls_worktype = '400'	THEN		//신규
		dw_cond.Object.orderno[1] = LONG(ls_get_value)
		
		SELECT A.CUSTOMERID, B.CUSTOMERNM INTO :ls_customerid, :ls_customernm
		FROM   SVCORDER A, CUSTOMERM B
		WHERE  A.ORDERNO = TO_NUMBER(:ls_get_value)
		AND    A.CUSTOMERID = B.CUSTOMERID;
		
		dw_cond.Object.customerid[1] = ls_customerid
		dw_cond.Object.customernm[1] = ls_customernm
		
		p_ok.TriggerEvent(Clicked!)
	ELSEIF ls_worktype = '200'	THEN		//장애
		SELECT A.CUSTOMERID, B.CUSTOMERNM, A.CONTRACTSEQ
		INTO   :ls_customerid, :ls_customernm, :ls_contractseq
		FROM   CUSTOMER_TROUBLE A, CUSTOMERM B
		WHERE  A.TROUBLENO = :ls_get_value
		AND    A.CUSTOMERID = B.CUSTOMERID;
		
		dw_cond.Object.customerid[1] = ls_customerid
		dw_cond.Object.customernm[1] = ls_customernm		
		
		SELECT ORDERNO INTO :ll_orderno
		FROM   SIID
		WHERE  CONTRACTSEQ = :ls_contractseq;		
		
		dw_cond.Object.orderno[1] = ll_orderno		
		
		p_ok.TriggerEvent(Clicked!)			
	END IF
END IF

end event

event close;call super::close;DESTROY iu_cust_db_app
end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
LONG		ll_5,		ll_w_2,		ll_grsize,		ll_dwsize,		ll_wgrsize,		ll_w

ll_grsize  = 4    //그룹박스간 사이 간격!
ll_dwsize  = 64   //그룹박스와 dw사이 간격!
ll_wgrsize = 30	//좌우 그룹박스 간 간격!

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_1.Y + iu_cust_w_resize.ii_button_space) Then
//	dw_detail.Height = 0
//	gb_1.Height = 0
  
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	
	ll_5 					= round((newheight - dw_detail.Y - dw_detail.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space) / 3, 1)
	
	gb_3.Height			= gb_3.Height + ll_5
	dw_1.Height 		= dw_1.Height + ll_5
	
	gb_5.y				= gb_3.y + gb_3.Height + ll_grsize
	dw_3.y				= gb_5.y + ll_dwsize
	gb_5.Height 		= gb_5.Height + ll_5	
	dw_3.Height			= dw_3.Height + ll_5	
	
	gb_6.y				= gb_5.y + gb_5.Height + ll_grsize
	dw_4.y				= gb_6.y + ll_dwsize
	gb_6.Height 		= gb_6.Height + ll_5	
	dw_4.Height			= dw_4.Height + ll_5		
	
	dw_detail.y 		= gb_6.y + gb_6.Height + ll_wgrsize
	
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
End If

If newwidth < dw_detail.X  Then
	dw_1.Width = 0
	dw_3.Width = 0
	dw_4.Width = 0	
	dw_detail.Width = 0	
	
	gb_3.Width = 0
	gb_5.Width = 0
	gb_6.Width = 0	
Else
	ll_w = newwidth - gb_3.x - gb_3.width - iu_cust_w_resize.ii_dw_button_space
	
	gb_3.Width			= gb_3.Width + ll_w
	dw_1.Width        = dw_1.Width + ll_w

	gb_5.Width			= gb_5.Width + ll_w
	dw_3.Width        = dw_3.Width + ll_w	
	
	gb_6.Width			= gb_6.Width + ll_w
	dw_4.Width        = dw_4.Width + ll_w	
	
	dw_detail.Width   = dw_detail.Width + ll_w		

End If

If newwidth < dw_master.X  Then
	dw_master.Width = 0
	gb_2.Width      = 0
Else
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space -20
	gb_2.Width 		 = newwidth - gb_2.X - iu_cust_w_resize.ii_dw_button_space	
End If

// Call the resize functions
of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)

////2009-03-17 by kEnn
////Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
////
//IF sizetype = 1 THEN RETURN
//
//SetRedraw(FALSE)
//
//IF newheight < (dw_master.Y + iu_cust_w_resize.ii_button_space) THEN
//	dw_master.Height = 0
//	
//	p_reset.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
//	p_close.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
//ELSE
//	dw_master.Height = newheight - dw_master.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
//
// 	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//END IF
//
//IF newwidth < dw_master.X  THEN
//	dw_master.Width = 0
//ELSE
//	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
//END IF
//
//IF newwidth < dw_master.X  THEN
//	dw_master.Width = 0
//ELSE
//	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
//END IF
//
//// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()
//
//SetRedraw(TRUE)
//
end event

type dw_detail from datawindow within ubs_w_reg_validresult
integer x = 32
integer y = 1800
integer width = 3749
integer height = 268
integer taborder = 70
string title = "none"
string dataobject = "ubs_dw_reg_validresult_det"
boolean border = false
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type dw_4 from datawindow within ubs_w_reg_validresult
integer x = 32
integer y = 1496
integer width = 3735
integer height = 272
integer taborder = 60
string title = "none"
string dataobject = "ubs_dw_reg_validresult_auth"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type dw_3 from datawindow within ubs_w_reg_validresult
integer x = 32
integer y = 1140
integer width = 3735
integer height = 268
integer taborder = 50
string title = "none"
string dataobject = "ubs_dw_reg_validresult_reg_ssw"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type p_reset from u_p_reset within ubs_w_reg_validresult
integer x = 14
integer y = 2108
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_reg_validresult
integer x = 3474
integer y = 56
end type

type dw_master from u_d_base within ubs_w_reg_validresult
integer x = 32
integer y = 244
integer width = 3735
integer height = 440
integer taborder = 30
string dataobject = "ubs_dw_reg_validresult_mas1"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event clicked;//If row = 0 then Return
//
//If IsSelected( row ) then
//	SelectRow( row ,FALSE)
//Else
//   SelectRow(0, FALSE )
//	SelectRow( row , TRUE )
//End If
end event

type st_horizontal from statictext within ubs_w_reg_validresult
boolean visible = false
integer x = 18
integer y = 820
integer width = 891
integer height = 24
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

type dw_cond from u_d_help within ubs_w_reg_validresult
integer x = 37
integer y = 36
integer width = 3410
integer height = 172
integer taborder = 10
string dataobject = "ubs_dw_reg_validresult_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;call super::doubleclicked;DataWindowChild ldwc_orderno
INT		li_rc
STRING	ls_sql,			ls_customerid
LONG		ll_row

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid"
		IF iu_cust_help.ib_data[1] THEN
			is_cus_status 				= iu_cust_help.is_data[3]
			
			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 THEN
				RETURN -1	
			END IF
					
		END IF
		
		ls_customerid = THIS.Object.customerid[1]
		
		li_rc = THIS.GetChild("orderno", ldwc_orderno)
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
				
		ls_sql = " SELECT A.ORDERNO, B.SVCDESC FROM SVCORDER A, SVCMST B " + &
					" WHERE  A.CUSTOMERID = '" + ls_customerid + "' AND A.SVCCOD = B.SVCCOD ORDER BY ORDERNO DESC "

		ldwc_orderno.SetSqlselect(ls_sql)
		ldwc_orderno.SetTransObject(SQLCA)
		ll_row = ldwc_orderno.Retrieve()
		
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "svcorder Retrieve()")
			RETURN -2
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

event itemchanged;call super::itemchanged;DataWindowChild ldwc_orderno
INT		li_rc
STRING	ls_sql
LONG		ll_row

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid" 
   	wfi_get_customerid(data, "")
		  
		li_rc = THIS.GetChild("orderno", ldwc_orderno)
		IF li_rc = -1 THEN
			f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
			RETURN -2
		END IF
				
		ls_sql = " SELECT A.ORDERNO, B.SVCDESC FROM SVCORDER A, SVCMST B " + &
					" WHERE  A.CUSTOMERID = '" + data + "' AND A.SVCCOD = B.SVCCOD ORDER BY ORDERNO DESC "

		ldwc_orderno.SetSqlselect(ls_sql)
		ldwc_orderno.SetTransObject(SQLCA)
		ll_row = ldwc_orderno.Retrieve()
		
		IF ll_row < 0 THEN 				//디비 오류 
			f_msg_usr_err(2100, Title, "svcorder Retrieve()")
			RETURN -2
		END IF			  
		  
END CHOOSE
end event

type p_close from u_p_close within ubs_w_reg_validresult
integer x = 315
integer y = 2108
boolean originalsize = false
end type

type gb_1 from groupbox within ubs_w_reg_validresult
integer x = 14
integer y = 8
integer width = 3776
integer height = 208
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

type gb_2 from groupbox within ubs_w_reg_validresult
integer x = 14
integer y = 220
integer width = 3771
integer height = 480
integer taborder = 20
integer textsize = -2
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

type gb_3 from groupbox within ubs_w_reg_validresult
integer x = 14
integer y = 704
integer width = 3771
integer height = 360
integer taborder = 30
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "전화기 인증결과"
end type

type gb_5 from groupbox within ubs_w_reg_validresult
integer x = 14
integer y = 1072
integer width = 3771
integer height = 352
integer taborder = 50
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "교환기 등록결과"
end type

type gb_6 from groupbox within ubs_w_reg_validresult
integer x = 14
integer y = 1428
integer width = 3771
integer height = 356
integer taborder = 60
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "인터넷 인증결과"
end type

type dw_1 from datawindow within ubs_w_reg_validresult
integer x = 32
integer y = 772
integer width = 3735
integer height = 272
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_validresult_cof_voip"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

