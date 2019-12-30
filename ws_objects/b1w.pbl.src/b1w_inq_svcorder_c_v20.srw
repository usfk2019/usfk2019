$PBExportHeader$b1w_inq_svcorder_c_v20.srw
$PBExportComments$[ohj] 서비스 신청내역 조회/취소 Window
forward
global type b1w_inq_svcorder_c_v20 from w_a_inq_m_m
end type
type p_1 from u_p_reset within b1w_inq_svcorder_c_v20
end type
type st_horizontal2 from st_horizontal within b1w_inq_svcorder_c_v20
end type
type dw_list from datawindow within b1w_inq_svcorder_c_v20
end type
end forward

global type b1w_inq_svcorder_c_v20 from w_a_inq_m_m
integer width = 4009
integer height = 1916
event ue_reset ( )
p_1 p_1
st_horizontal2 st_horizontal2
dw_list dw_list
end type
global b1w_inq_svcorder_c_v20 b1w_inq_svcorder_c_v20

type variables
String is_partner, is_status_1, is_status_2, is_action
String is_termcodes[], is_cancelcodes[], is_actorder, is_amt_check
Integer ii_termcodcnt, ii_cancelcnt

Integer ii_cnt
end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public function long f_cancell_validation_check (string p_orderno)
end prototypes

event ue_reset();dw_cond.reset()
dw_cond.insertrow(1)

dw_master.reset()
dw_detail.reset()

dw_detail.Enabled = False
dw_detail.visible = False

of_ResizeBars()
of_ResizePanels()

end event

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

st_horizontal.Y = WorkSpaceHeight() - cii_BarThickness - (WorkSpaceHeight() * 0.25)

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

st_horizontal2.Move(idrg_Top.X, st_horizontal2.Y)
st_horizontal2.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()
end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness)

// Top processing
If dw_detail.rowcount() > 0 Then
	idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
	idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y - cii_BarThickness)
Else
	idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
	idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y + idrg_Bottom.Height )
End If




end subroutine

public function long f_cancell_validation_check (string p_orderno);long ll_result
String ls_contractseq, ls_related_orderno

ll_result = 0;
ls_contractseq = '0';
ls_related_orderno = '-1';
// 해지 신청에 대한 취소이고, 해지 신청된 서비스의 선행 서비스가 이미 다른 서비스에 
// 사용되고 있다면, 해지 신청전에 신규 신청을 먼저 취소해야한다.
// 해지 신청에 대한 취소이고, 신청된 해지 계약의 선행 계약의 번호를 이용해서
// 해당 계약의 개통 오더에 다른 후행이 등록되었다면 에러 발생
    
	 select related_contractseq
	   into :ls_contractseq
		from svcorder 
	  where orderno = p_orderno
	    and status = '70';
		 
	IF ls_contractseq <> '0' THEN
		select related_orderno
		  into :ls_related_orderno
	     from svcorder
		 where ref_contractseq = :ls_contractseq
		   and order_type = '10';
		 
      IF ls_related_orderno <> '-1' THEN
			ll_result = -1;
		END IF;
	END IF;

return ll_result;
end function

event ue_ok();call super::ue_ok;Long		ll_rows
String	ls_where
String	ls_customerid, ls_orderno
String	ls_orderdtfrom, ls_orderdtto, ls_status
String	ls_requestdtfrom, ls_requestdtto, ls_svccod
String	ls_priceplan, ls_prmtype
String	ls_partner, ls_settle_partner
String	ls_maintain_partner, ls_reg_partner
String	ls_sale_partner, ls_validkey

ls_customerid		= Trim(dw_cond.Object.customerid[1])
ls_orderno			= Trim(dw_cond.Object.orderno[1])
ls_orderdtfrom		= Trim(String(dw_cond.object.orderdtfrom[1],'yyyymmdd'))
ls_orderdtto		= Trim(String(dw_cond.object.orderdtto[1],'yyyymmdd'))
ls_status			= Trim(dw_cond.Object.status[1])
ls_requestdtfrom	= Trim(String(dw_cond.object.requestdtfrom[1],'yyyymmdd'))
ls_requestdtto		= Trim(String(dw_cond.object.requestdtto[1],'yyyymmdd'))
ls_svccod			= Trim(dw_cond.Object.svccod[1])
ls_priceplan		= Trim(dw_cond.Object.priceplan[1])
ls_prmtype			= Trim(dw_cond.Object.prmtype[1])
ls_partner			= Trim(dw_cond.Object.partner[1])
ls_settle_partner	= Trim(dw_cond.Object.settle_partner[1])
ls_maintain_partner	= Trim(dw_cond.Object.maintain_partner[1])
ls_reg_partner		= Trim(dw_cond.Object.reg_partner[1])
ls_sale_partner	= Trim(dw_cond.Object.sale_partner[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

If( IsNull(ls_customerid) ) Then ls_customerid = ""
If( IsNull(ls_orderno) ) Then ls_orderno = ""
If( IsNull(ls_orderdtfrom) ) Then ls_orderdtfrom = ""
If( IsNull(ls_orderdtto) ) Then ls_orderdtto = ""
If( IsNull(ls_status) ) Then ls_status = ""
If( IsNull(ls_requestdtfrom) ) Then ls_requestdtfrom = ""
If( IsNull(ls_requestdtto) ) Then ls_requestdtto = ""
If( IsNull(ls_svccod) ) Then ls_svccod = ""
If( IsNull(ls_priceplan) ) Then ls_priceplan = ""
If( IsNull(ls_prmtype) ) Then ls_prmtype = ""
If( IsNull(ls_partner) ) Then ls_partner = ""
If( IsNull(ls_settle_partner) ) Then ls_settle_partner = ""
If( IsNull(ls_maintain_partner) ) Then ls_maintain_partner = ""
If( IsNull(ls_reg_partner) ) Then ls_reg_partner = ""
If( IsNull(ls_sale_partner) ) Then ls_sale_partner = ""
If IsNull(ls_validkey) Then ls_validkey = ""


//Dynamic SQL
ls_where = ""
If( ls_customerid <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where	+= "B.customerid = '"+ ls_customerid +"'"
End If

If( ls_orderno <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.orderno = '"+ ls_orderno +"'"
End If

If( ls_orderdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(B.orderdt, 'YYYYMMDD') >= '"+ ls_orderdtfrom +"'"
End If

If( ls_orderdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(B.orderdt, 'YYYYMMDD') <= '"+ ls_orderdtto +"'"
End If

If( ls_status <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.status = '"+ ls_status +"'"
End If

If( ls_requestdtfrom <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(B.requestdt, 'YYYYMMDD') >= '"+ ls_requestdtfrom +"'"
End If

If( ls_requestdtto <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "to_char(B.requestdt, 'YYYYMMDD') <= '"+ ls_requestdtto +"'"
End If

If( ls_svccod <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.svccod = '"+ ls_svccod +"'"
End If

If( ls_priceplan <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.priceplan = '"+ ls_priceplan +"'"
End If

If( ls_prmtype <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.prmtype = '"+ ls_prmtype +"'"
End If

If( ls_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.partner = '"+ ls_partner +"'"
End If

If( ls_settle_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.settle_partner = '"+ ls_settle_partner +"'"
End If

If( ls_maintain_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.maintain_partner = '"+ ls_maintain_partner +"'"
End If

If( ls_reg_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.reg_partner = '"+ ls_reg_partner +"'"
End If

If( ls_sale_partner <> "" ) Then
	If( ls_where <> "" ) Then ls_where += " AND "
	ls_where += "B.sale_partner = '"+ ls_sale_partner +"'"
End If

If ls_validkey <>  "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " B.orderno  in (select distinct orderno from validinfo where validkey = '" + ls_validkey+ "') "
End If

dw_master.is_where	= ls_where

//Retrieve
ll_rows	= dw_master.Retrieve()
If( ll_rows = 0 ) Then
	f_msg_info(1000, Title, "")
	TriggerEvent("ue_reset")
ElseIf( ll_rows < 0 ) Then
	f_msg_usr_err(2100, Title, "Retrieve()")
End If

end event

on b1w_inq_svcorder_c_v20.create
int iCurrent
call super::create
this.p_1=create p_1
this.st_horizontal2=create st_horizontal2
this.dw_list=create dw_list
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.st_horizontal2
this.Control[iCurrent+3]=this.dw_list
end on

on b1w_inq_svcorder_c_v20.destroy
call super::destroy
destroy(this.p_1)
destroy(this.st_horizontal2)
destroy(this.dw_list)
end on

event open;call super::open;/*--------------------------------------------------------------------
	Name	:	b1w_inq_svcorder
	Desc	:	서비스 신청 취소
	Ver.	: 	1.0
	Date	: 	2002.10.30
	Programer : Chooys(추윤식), ceusee(최보라)
--------------------------------------------------------------------*/
String ls_ref_desc, ls_termcod, ls_cancelcod
st_horizontal2.BackColor = BackColor

ls_ref_desc = ""
is_partner = fs_get_control("A1", "C102", ls_ref_desc)		//본사 대리점 코드
is_status_1 = fs_get_control("E1", "A100", ls_ref_desc)		//본사 재고 상태 코드
is_status_2 = fs_get_control("E1", "A102", ls_ref_desc)		//대리점 재고 상태 코드
is_action = fs_get_control("E1", "A302", ls_ref_desc)			//판매 취소

ls_termcod= fs_get_control("B0", "P221", ls_ref_desc)       //해지 상태 코드
ii_termcodcnt	= fi_cut_string( ls_termcod, ";", is_termcodes )
ls_cancelcod= fs_get_control("B0", "P222", ls_ref_desc)       //취소 상태 코드
ii_cancelcnt	= fi_cut_string( ls_cancelcod, ";", is_cancelcodes )
is_actorder= fs_get_control("B0", "P220", ls_ref_desc)       //개통신청상태

end event

type dw_cond from w_a_inq_m_m`dw_cond within b1w_inq_svcorder_c_v20
integer x = 64
integer width = 2848
integer height = 632
string dataobject = "b1dw_cnd_inqorderbysvc"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::ue_init();call super::ue_init;idwo_help_col[1] = Object.customerid
is_help_win[1] = "b1w_hlp_customerm"
is_data[1] = "CloseWithReturn"

idwo_help_col[2] = Object.maintain_partner
is_help_win[2] = "b1w_hlp_partner"
is_data[2] = "CloseWithReturn"

idwo_help_col[3] = Object.reg_partner
is_help_win[3] = "b1w_hlp_partner"
is_data[3] = "CloseWithReturn"

idwo_help_col[4] = Object.sale_partner
is_help_win[4] = "b1w_hlp_partner"
is_data[4] = "CloseWithReturn"


end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "customerid"
		If iu_cust_help.ib_data[1] Then
			Object.customerid[row] = iu_cust_help.is_data[1]
			Object.customernm[row] = iu_cust_help.is_data[2]
		End If
		
	Case "maintain_partner"
		If iu_cust_help.ib_data[1] Then
			Object.maintain_partner[row] = iu_cust_help.is_data[1]
			Object.maintain_partnernm[row] = iu_cust_help.is_data[2]
		End If
		
	Case "reg_partner"
		If iu_cust_help.ib_data[1] Then
			Object.reg_partner[row] = iu_cust_help.is_data[1]
			Object.reg_partnernm[row] = iu_cust_help.is_data[2]
		End If
		
	Case "sale_partner"
		If iu_cust_help.ib_data[1] Then
			Object.sale_partner[row] = iu_cust_help.is_data[1]
			Object.sale_partnernm[row] = iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case Dwo.Name
	Case "customerid"
		Object.customernm[1] = ""
		
	Case "maintain_partner"
		Object.maintain_partnernm[1] = ""
		
	Case "reg_partner"
		Object.reg_partnernm[1] = ""
		
	Case "sale_partner"
		Object.sale_partnernm[1] = ""
		
End Choose
end event

type p_ok from w_a_inq_m_m`p_ok within b1w_inq_svcorder_c_v20
integer x = 3026
integer y = 60
end type

type p_close from w_a_inq_m_m`p_close within b1w_inq_svcorder_c_v20
integer x = 3639
integer y = 60
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within b1w_inq_svcorder_c_v20
integer x = 27
integer width = 2907
integer height = 688
end type

type dw_master from w_a_inq_m_m`dw_master within b1w_inq_svcorder_c_v20
integer x = 27
integer y = 744
integer width = 3913
integer height = 1036
string dataobject = "b1dw_inq_mst_inqorderbysvc_a_ssrt"
end type

event dw_master::ue_init();call super::ue_init;dwObject ldwo_sort

ldwo_sort = Object.svcorder_orderno_t
uf_init( ldwo_sort, "D", RGB(0,0,128) )
end event

event dw_master::buttonclicked;long		ll_master_row, ll_result, ll_row_list, ll_orderno
String	ls_priceplan, ls_customerid, ls_svccod, ls_chk, ls_quota_yn, ls_onefee, ls_bil, ls_itemcod, ls_status
string   ls_check,		ls_requestdt,	ls_sysdt, ls_cause
DEC{2} 	ldc_total, ldc_unitamt
BOOLEAN  lb_direct
INT		i
LONG		ll_contractseq,		ll_cnt,			ll_valid_cnt,			ll_boss_04, ll_related_orderno
LONG		ll_related_contractseq, ll_vocm_cnt, 	ll_non_valid_cnt

lb_direct =  False
iu_cust_msg = Create u_cust_a_msg


Choose Case dwo.Name
	Case "svcorder_cancel" //신청내역취소버튼
		
		is_amt_check = 'N'
		
//		ll_master_row = dw_master.Getselectedrow(0)
		ll_master_row = dw_master.Getrow()
		If ll_master_row = 0 Then	return -1
		
		ll_orderno     = dw_master.Object.svcorder_orderno[ll_master_row]
		ls_customerid  = dw_master.Object.svcorder_customerid[ll_master_row]
		ls_svccod	   = dw_master.Object.svcorder_svccod[ll_master_row]
		ls_status	   = dw_master.Object.svcorder_status[ll_master_row]
		ll_contractseq = dw_master.Object.svcorder_ref_contractseq[ll_master_row]
		ls_requestdt   = STRING(dw_master.Object.svcorder_requestdt[ll_master_row], 'yyyymmdd')
		ls_sysdt   		= STRING(fdt_get_dbserver_now(),'yyyymmdd')
		ls_cause			= dw_master.Object.svcorder_direct_paytype[ll_master_row]
			
		IF IsNull(ls_cause) OR ls_cause = "" THEN
			F_MSG_INFO(200, Title, "취소사유를 등록하세요.")
			RETURN -1
		END IF
	
		//삭제처리 User Object생성
		Integer	li_result
		li_result = f_msg_ques_yesno2(2070,title, "",2)
		
		ls_priceplan = Trim(dw_master.Object.svcorder_priceplan[ll_master_row])
		
		SELECT COUNT(*) INTO :ll_valid_cnt
		FROM   SYSCOD2T
		WHERE  GRCODE = 'BOSS03'
		AND    USE_YN = 'Y'
		AND    CODE   = :ls_svccod;
		
		//인증 받지 않는 장비관리 서비스
		SELECT COUNT(*) INTO :ll_non_valid_cnt
		FROM SYSCOD2T
		WHERE GRCODE = 'BOSS06'
		AND USE_YN = 'Y'
		AND CODE = :ls_svccod;
		

		IF ll_valid_cnt > 0  THEN			
			SELECT COUNT(*) INTO :ll_boss_04
			FROM   SYSCOD2T
			WHERE  GRCODE = 'BOSS04'
			AND    USE_YN = 'Y'
			AND    CODE   = :ls_priceplan;				
				
			IF ll_boss_04 > 0 THEN
				ls_check = 'N'
			ELSE
				ls_check = 'Y'
			END IF
		ELSE 
			ls_check = 'N'
		END IF				
	
		IF ls_check = 'Y' and ll_non_valid_cnt = 0 THEN
				//vocm 인 경우 확인...
			SELECT COUNT(*) INTO :ll_vocm_cnt
			FROM   PRICEPLAN_EQUIP
			WHERE  PRICEPLAN = :ls_priceplan
			AND    ADTYPE = 'VO01';	
			
			IF ll_vocm_cnt > 0 THEN //VOCM 인 경우...
				IF ls_status = '10' THEN
					SELECT RELATED_ORDERNO INTO :ll_related_orderno
					FROM   SVCORDER
					WHERE  ORDERNO = :ll_orderno;
				ELSE
					SELECT RELATED_CONTRACTSEQ INTO :ll_related_contractseq
					FROM   CONTRACTMST
					WHERE  CONTRACTSEQ = :ll_contractseq;
				END IF
			END IF
					
			IF ls_status = '10' THEN			//신규신청 ( 신규인증중, 신규인증완료 )
				IF ll_vocm_cnt <= 0 THEN
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  ORDERNO = :ll_orderno
					AND    VALID_STATUS IN ('200', '300');	
				ELSE
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  ORDERNO = :ll_related_orderno
					AND    VALID_STATUS IN ('200', '300');	
				END IF					
			ELSEIF ls_status = '30' THEN		//중지신청 ( 중지인증중, 중지인증완료 )
				IF ll_vocm_cnt <= 0 THEN
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  CONTRACTSEQ = :ll_contractseq
					AND    VALID_STATUS IN ('400', '500');							
				ELSE
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  CONTRACTSEQ = :ll_related_contractseq
					AND    VALID_STATUS IN ('400', '500');							
				END IF
				
				//#4379 2013.08.26 김선주 
				//고객이 훈련이나 휴가로 핸드폰을 중지하고 개통날짜를 미래로 설정한  후에,
				//예정된 날짜보다 미리 핸드폰 재개통을 요청한 경우, SVCORDER.REQUESTDT가 , 
				//인증처리가 전이기 때문에, EQUIPMST.VALID_STATUS IN ('600','700') 이 조건으로 인해
				//취소 처리가 되지 않음.
				//이에 svcorder.requestdt가 미래일자일 경우는 
				//중지/재개통 취소가 가능하도록 아래 로직을 추가하여, 취소처리 Process가 타도록 함. 
				IF ls_requestdt > ls_sysdt THEN 
					ll_cnt = 0 
				END IF
								
				
			ELSEIF ls_status = '50' THEN		//해소신청 ( 해소인증중, 해소인증완료 )    
				IF ll_vocm_cnt <= 0 THEN
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  CONTRACTSEQ = :ll_contractseq
					AND    VALID_STATUS IN ('600', '700');		
				ELSE
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  CONTRACTSEQ = :ll_related_contractseq
					AND    VALID_STATUS IN ('600', '700');	
				END IF					
				
				//#4379 2013.08.26 김선주 
				//고객이 훈련이나 휴가로 핸드폰을 중지하고 개통날짜를 미래로 설정한  후에,
				//예정된 날짜보다 미리 핸드폰 재개통을 요청한 경우, SVCORDER.REQUESTDT가 , 
				//인증처리가 전이기 때문에, EQUIPMST.VALID_STATUS IN ('600','700') 이 조건으로 인해
				//취소 처리가 되지 않음.
				//이에 svcorder.requestdt가 미래일자일 경우는 
				//중지/재개통 취소가 가능하도록 아래 로직을 추가하여, 취소처리 Process가 타도록 함. 
				IF ls_requestdt > ls_sysdt THEN 
					ll_cnt = 0 
				END IF
				
			ELSEIF ls_status = '70' THEN		//해지신청 ( 해지인증중, 해지인증완료 )
				IF ll_vocm_cnt <= 0 THEN				
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  CONTRACTSEQ = :ll_contractseq
					AND    VALID_STATUS IN ('800', '900');	
				ELSE
					SELECT COUNT(*) INTO :ll_cnt
					FROM   EQUIPMST
					WHERE  CONTRACTSEQ = :ll_related_contractseq
					AND    VALID_STATUS IN ('800', '900');	
				END IF	
				
				//#4379 2013.08.26 김선주 
				//고객이 훈련이나 휴가로 핸드폰을 중지하고 개통날짜를 미래로 설정한  후에,
				//예정된 날짜보다 미리 핸드폰 재개통을 요청한 경우, SVCORDER.REQUESTDT가 , 
				//인증처리가 전이기 때문에, EQUIPMST.VALID_STATUS IN ('600','700') 이 조건으로 인해
				//취소 처리가 되지 않음.
				//이에 svcorder.requestdt가 미래일자일 경우는 
				//중지/재개통 취소가 가능하도록 아래 로직을 추가하여, 취소처리 Process가 타도록 함. 
				IF ls_requestdt > ls_sysdt THEN 
					ll_cnt = 0 
				END IF			
			ELSE
				ll_cnt = 0
			END IF
			
			IF ll_cnt > 0 THEN
				F_MSG_INFO(200, Title, "장비인증중 또는 장비인증완료 상태라 취소가 불가합니다.")
				RETURN -1
			END IF
		END IF				

		// 해지 신청에 대한 취소이고, 해지 신청된 서비스의 선행 서비스가 이미 다른 서비스에 
		// 사용되고 있다면, 해지 신청전에 신규 신청을 먼저 취소해야한다.
		// 해지 신청에 대한 취소이고, 신청된 해지 계약의 선행 계약의 번호를 이용해서
		// 해당 계약의 개통 오더에 다른 후행이 등록되었다면 에러 발생
		ll_result = f_cancell_validation_check(Trim(String(Object.svcorder_orderno[This.getrow()])))
		
		If ll_result < 0 Then
			f_msg_info(9000, Title , "선행 서비스가 이미 다른 서비스에 연결되었습니다.")
			Return -1
		End If
		
		IF ls_status = '10' OR ls_status = '50' THEN				//신청, 재개통 상태일 때만..
		
			ll_row_list = dw_list.RowCount()
		
			If ll_row_list > 0 Then
				ldc_total = 0
				For i = 1 To ll_row_list
					ls_chk 		= Trim(dw_list.object.chk[i])
					ls_quota_yn = Trim(dw_list.object.quota_yn[i])
					ls_onefee 	= Trim(dw_list.object.ONEOFFCHARGE_YN[i])
					ls_bil 		= Trim(dw_list.object.bilitem_yn[i])
					ls_itemcod  = Trim(dw_list.object.itemcod[i])
		
					If ls_chk = "Y" AND ls_onefee = "Y" and ls_bil = 'N' Then
						ldc_unitamt = dw_list.object.unit_amt[i]
		
						IF Isnull(ldc_unitamt) THEN ldc_unitamt = 0
						
						ldc_total = ldc_total + ldc_unitamt																
						
						lb_direct = True
					End If
				Next
		
				IF ldc_total <= 0 THEN
					lb_direct = true
					//messagebox("ldc_total", "0")
					//return -1
				END IF
		
				If lb_direct Then			//즉시불 취소 처리
					iu_cust_msg.is_pgm_name = "서비스품목 장비 즉시불 취소"
					iu_cust_msg.is_grp_name = "서비스 신청"
					iu_cust_msg.ib_data[1]  = True
					iu_cust_msg.il_data[1]  = ll_orderno					//order number
					iu_cust_msg.il_data[2]  = 0								//contractseq
					iu_cust_msg.is_data[1] 	= ls_customerid				//customer ID
					iu_cust_msg.is_data[2] 	= gs_pgm_id[gi_open_win_no]//Pgm ID
					iu_cust_msg.is_data[3] 	= ""			 					//member ID
					iu_cust_msg.is_data[4] 	= ""								//
					iu_cust_msg.is_data[5] 	= ls_priceplan 				//가격정책
					iu_cust_msg.is_data[6] 	= ls_svccod 				   //서비스
					
					
					iu_cust_msg.idw_data[1] = dw_list
					
					//수납내역이 있을때만 즉시불 취소창 띄운다 2013-06-13 BY HMK
					if dw_list.object.sum_unit_amt[1] <> 0 then
						OpenWithParm(b1w_reg_directpaycan_pop_sams, iu_cust_msg)
					end if
							
					IF iu_cust_msg.ib_data[1] THEN
						is_amt_check = iu_cust_msg.is_data[1]
					END IF
					
					IF is_amt_check = 'N' OR IsNull(is_amt_check) = True THEN
						f_msg_info(3010,This.Title,"수납 취소")
						Rollback;
						Destroy iu_cust_msg
						Return -1
					END IF
				ELSE
					is_amt_check = 'Y'
				END IF
			ELSE 
				is_amt_check = 'Y'
			END IF
		END IF
		
		If (li_result = 1) Then
			b1u_dbmgr12_v20	lu_dbmgr
			lu_dbmgr = Create b1u_dbmgr12_v20
			lu_dbmgr.is_caller = "b1w_inq_svcorder_c_v20%cancel"
			lu_dbmgr.is_data[1]	= Trim(String(Object.svcorder_orderno[This.getrow()]))
			lu_dbmgr.is_data[2] = is_partner
			lu_dbmgr.is_data[3] = is_status_1     //본사 재고  상태 코드
			lu_dbmgr.is_data[4] = is_status_2	   //대리점 재고 상태 코드 
			lu_dbmgr.is_data[5] = is_action	   //발생 이력
			lu_dbmgr.is_data[6] = gs_user_id
			lu_dbmgr.is_data[7] = gs_pgm_id[gi_open_win_no]
			lu_dbmgr.is_data[8] = ls_priceplan
			lu_dbmgr.idw_data[1] = dw_master
			//lu_dbmgr.ii_data[1]  = ii_cnt
			lu_dbmgr.uf_prc_db_01()
			IF lu_dbmgr.ii_rc = 0 Then
				f_msg_info(3000,This.Title,"신청내역 취소")
				//dw_master.Retrieve()
				Trigger event ue_ok()
				Commit;
			ElseIf lu_dbmgr.ii_rc < 0 Then
				f_msg_info(3010,This.Title,"신청내역 취소")
				Rollback;
				Destroy lu_dbmgr
				Return
			End If
			
			Destroy lu_dbmgr
		End If
		
	Case "svcitem_detail" //상세품목조회
		
			iu_cust_msg = Create u_cust_a_msg
			iu_cust_msg.is_pgm_name = "상세품목조회"
			iu_cust_msg.is_grp_name = "서비스 신청내역 조회/취소"
			iu_cust_msg.is_data[1] = Trim(String(Object.svcorder_orderno[This.getrow()]))
			
			OpenWithParm(b1w_inq_popup_svcorderitem_v20, iu_cust_msg)
   
   Case "svcorder_update"  //수정할 수 있는 상태
		iu_cust_msg = Create u_cust_a_msg
		iu_cust_msg.is_pgm_name = "신쳥내역 수정"
		iu_cust_msg.is_grp_name = "서비스 신청내역 수정"
		iu_cust_msg.is_data[1] = Trim(String(Object.svcorder_orderno[This.getrow()]))
		iu_cust_msg.is_data[2] = is_actorder   //개통 신청 상태
		iu_cust_msg.is_data[3] = is_termcodes[1]  //해지 신청 상태 코드
		
		OpenWithParm(b1w_reg_svcorder_update_a, iu_cust_msg)
			
			
End Choose


RETURN 0

end event

event dw_master::clicked;call super::clicked;STRING	ls_status
LONG		ll_orderno

//Check1.해지사유는 신청상태가 해지요청 또는 해지 일 경우에만 Visible
//->해지요청, 해지 신청상태 = sysctl1t.module='B0', ref_no='P221'
If row > 0 Then
	
//해지요청, 해지신청상태 코드 알아내기
   Integer li_cnt



	This.Object.svcorder_termtype_t.visible = false
	This.Object.svcorder_termtype.visible = false
			
	For li_cnt=1 To ii_termcodcnt
		If( This.Object.svcorder_status[row] = is_termcodes[li_cnt] ) Then
			This.Object.svcorder_termtype_t.visible = true
			This.Object.svcorder_termtype.visible = true
		End If
	Next
	
	//Check2.신청상태가 취소가능한 때만 클릭할 수 있다.
	//->취소가능한 상태 = sysctl1t.module='B0', ref_no='P222'
	
	//취소가능한 상태 코드 알아내기
	
	Integer li_cnt2
    This.Object.svcorder_cancel.visible = False
	 This.Object.svcorder_update.visible = False
	
	For li_cnt2=1 To ii_cancelcnt
			//messagebox("1", string(this.object.svcorder_status[row])+' '+string(is_cancelcodes[li_cnt2])) 
		
		If( This.Object.svcorder_status[row] = is_cancelcodes[li_cnt2] ) Then
			This.Object.svcorder_cancel.visible = True
			This.Object.svcorder_update.visible = True       //수정할 수 있게
		End If
	Next
	
	// Call the resize functions
	of_ResizeBars()
	of_ResizePanels()
	
	This.SetRow(row)
	This.ScrollToRow(row)
	
	ll_orderno = THIS.Object.svcorder_orderno[row]
	ls_status  = THIS.Object.svcorder_status[row]
	
	IF ls_status = '50' THEN
		dw_list.DataObject = "b1dw_inq_det_inq_svcorder_can2"
		dw_list.SetTransObject(SQLCA)		
	ELSE
		dw_list.DataObject = "b1dw_inq_det_inq_svcorder_can"
		dw_list.SetTransObject(SQLCA)				
	END IF		
	
	dw_list.Retrieve(ll_orderno)	
	
//	b1dw_inq_det_inq_svcorder_can2
	
Else
	
	If dw_detail.rowcount() > 0 Then
		dw_detail.Visible = True
	Else
		dw_detail.Visible = False
	End if
	
End If






end event

event dw_master::retrieveend;STRING	ls_status
LONG		ll_getrow, ll_orderno

ll_getrow = This.getrow()
//Check1.해지사유는 신청상태가 해지요청 또는 해지 일 경우에만 Visible
//->해지요청, 해지 신청상태 = sysctl1t.module='B0', ref_no='P221'
If ll_getrow  > 0 Then
	
	//해지요청, 해지신청상태 코드 알아내기
   Integer li_cnt

	This.Object.svcorder_termtype_t.visible = false
	This.Object.svcorder_termtype.visible = false
			
	For li_cnt=1 To ii_termcodcnt
		If( This.Object.svcorder_status[ll_getrow] = is_termcodes[li_cnt] ) Then
			This.Object.svcorder_termtype_t.visible = true
			This.Object.svcorder_termtype.visible = true
		End If
	Next
	
	//Check2.신청상태가 취소가능한 때만 클릭할 수 있다.
	//->취소가능한 상태 = sysctl1t.module='B0', ref_no='P222'
	
	//취소가능한 상태 코드 알아내기
	
	Integer li_cnt2
    This.Object.svcorder_cancel.visible = False
	 This.Object.svcorder_update.visible = False
	
	For li_cnt2=1 To ii_cancelcnt
		
	
		
		If( This.Object.svcorder_status[ll_getrow] = is_cancelcodes[li_cnt2] ) Then
			This.Object.svcorder_cancel.visible = True
			This.Object.svcorder_update.visible = True       //수정할 수 있게
		End If
	Next
	
	// Call the resize functions
	of_ResizeBars()
	of_ResizePanels()
	
	This.SetRow(ll_getrow )
	This.ScrollToRow(ll_getrow )
	
	ll_orderno = THIS.Object.svcorder_orderno[1]
	ls_status  = THIS.Object.svcorder_status[1]
	
	IF ls_status = '50' THEN
		dw_list.DataObject = "b1dw_inq_det_inq_svcorder_can2"
		dw_list.SetTransObject(SQLCA)		
	ELSE
		dw_list.DataObject = "b1dw_inq_det_inq_svcorder_can"
		dw_list.SetTransObject(SQLCA)				
	END IF			
	
	dw_list.Retrieve(ll_orderno)	
	
Else
	
	If dw_detail.rowcount() > 0 Then
		dw_detail.Visible = True
	Else
		dw_detail.Visible = False
	End if
	
End If


end event

type dw_detail from w_a_inq_m_m`dw_detail within b1w_inq_svcorder_c_v20
integer x = 27
integer y = 1376
integer width = 3566
integer height = 268
string dataobject = "b1dw_inq_validkey"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//조회
String ls_orderno, ls_where, ls_contractno
Long ll_row

This.SetRedraw(False)

If al_select_row = 0 Then Return 0
ls_orderno = String(dw_master.object.svcorder_orderno[al_select_row])
ls_contractno = String(dw_master.object.svcorder_ref_contractseq[al_select_row])

If ls_contractno  = '0' or isnull(ls_contractno) Then
	ls_where = ""
	ls_where += " to_char(orderno) = '" + ls_orderno + "'"
Else
	ls_where = ""
	ls_where += " to_char(orderno) = '" + ls_orderno + "' Or to_char(contractseq) = '" + ls_contractno + "' "
End IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

If dw_detail.rowcount() > 0 Then
	dw_detail.visible = True
Else
	dw_detail.visible = False
End if

This.SetRedraw(True)

Return 0
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within b1w_inq_svcorder_c_v20
boolean visible = false
integer y = 1324
integer height = 52
end type

type p_1 from u_p_reset within b1w_inq_svcorder_c_v20
integer x = 3333
integer y = 60
boolean bringtotop = true
boolean originalsize = false
end type

type st_horizontal2 from st_horizontal within b1w_inq_svcorder_c_v20
boolean visible = true
integer y = 700
integer height = 44
end type

type dw_list from datawindow within b1w_inq_svcorder_c_v20
integer x = 3072
integer y = 276
integer width = 878
integer height = 384
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_inq_det_inq_svcorder_can"
boolean border = false
boolean livescroll = true
end type

event constructor;	SetTransObject(SQLCA)
	this.visible = false
end event

