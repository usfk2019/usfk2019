$PBExportHeader$ubs_w_reg_mobilechange.srw
$PBExportComments$[jhchoi] 모바일 기기 변경 - 2009.03.13
forward
global type ubs_w_reg_mobilechange from w_base
end type
type p_reset from u_p_reset within ubs_w_reg_mobilechange
end type
type p_ok from u_p_ok within ubs_w_reg_mobilechange
end type
type dw_master from u_d_base within ubs_w_reg_mobilechange
end type
type st_horizontal from statictext within ubs_w_reg_mobilechange
end type
type dw_detail from u_d_base within ubs_w_reg_mobilechange
end type
type dw_cond from u_d_help within ubs_w_reg_mobilechange
end type
type p_close from u_p_close within ubs_w_reg_mobilechange
end type
type p_save from u_p_save within ubs_w_reg_mobilechange
end type
type p_payment from u_p_payment within ubs_w_reg_mobilechange
end type
type gb_1 from groupbox within ubs_w_reg_mobilechange
end type
end forward

global type ubs_w_reg_mobilechange from w_base
integer width = 2917
integer height = 1888
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
dw_detail dw_detail
dw_cond dw_cond
p_close p_close
p_save p_save
p_payment p_payment
gb_1 gb_1
end type
global ubs_w_reg_mobilechange ubs_w_reg_mobilechange

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


String is_cus_status, is_hotbillflag, is_admst_status, is_amt_check, is_print_check
String is_return_status
Dec    idc_bil_amt   
Long   il_extdays
end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine wf_protect (string ai_gubun)
public subroutine of_resizepanels ()
public subroutine of_refreshbars ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_detail.GetRow()

lb_check = FB_SAVE_REQUIRED(dw_detail, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);IF is_amt_check = 'N' THEN
	F_MSG_INFO(9000, Title, "수납이 완료되지 않았습니다")
	ai_return = -1
	RETURN
END IF

ai_return = 0

RETURN
end event

event ue_process;STRING	ls_errmsg,			ls_customerid,		ls_new_cont,	ls_old_cont,	ls_ref_desc,	&
			ls_admst_Status,	ls_contno,			ls_action,		ls_return,		ls_old_validkey,	&
			ls_old_card_contno
LONG		ll_row,				ll_return,			ll_seq,			ll_new_seq,		ll_row_mas,		&
			ll_contractseq


dw_detail.AcceptText()
dw_master.AcceptText()
 
ll_row_mas  = dw_master.GetRow()
ll_row 	   = dw_detail.GetRow()
ll_seq      = dw_detail.Object.seq[ll_row]
ll_new_seq  = dw_detail.Object.new_seq[ll_row]
ls_new_cont = dw_detail.Object.new_contno[ll_row]
ls_old_cont = dw_detail.Object.contno[ll_row]

ls_customerid  = dw_master.Object.customerid[ll_row]
ll_contractseq = dw_master.Object.contractseq[ll_row]

ls_ref_desc = ""
ls_admst_Status	= fs_get_control("E1", "A101", ls_ref_desc)

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 판매 )
SELECT ref_content INTO :ls_action FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A103';

//ADMSTLOG_NEW 테이블에 ACTION 값 ( 반품 )
SELECT ref_content INTO :ls_return FROM sysctl1t 
WHERE module = 'U2' AND ref_no = 'A105';

//프로시저 실행
ls_errmsg = space(1000)
SQLCA.UBS_REG_MOBILE_AD_CHANGE(String(ll_seq), String(ll_new_seq), gs_user_id, gs_pgm_id[gi_open_win_no], ll_return, ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
	ai_return = -1		
	RETURN
END IF

SELECT VALIDKEY, CARD_CONTNO INTO :ls_old_validkey, :ls_old_card_contno
FROM   AD_MOBILE_RENTAL
WHERE  CONTNO = :ls_old_cont;

//new 장비 
UPDATE AD_MOBILE_RENTAL
SET    CUSTOMERID 	= :ls_customerid,
       CONTRACTSEQ 	= :ll_contractseq,
		 VALIDKEY		= :ls_old_validkey,
		 CARD_CONTNO	= :ls_old_card_contno,
		 LEASEDT			= TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),
		 STATUS	 		= :ls_admst_Status,
       updt_user  	= :gs_user_id,
       updtdt 	   	= sysdate,
       pgm_id 	  		= :gs_pgm_id[gi_open_win_no]					 
WHERE  CONTNO			= :ls_new_cont;

If SQLCA.SQLCode < 0 Then
	MESSAGEBOX(ls_errmsg, 'AD_MOBILE_RENTAL(NEW) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If

//장비이력(LEASELOG_NEW) Table에 정보저장 - 판매
INSERT INTO LEASELOG_NEW		
	( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
	  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
	  RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
	  PGM_ID, IDATE )
SELECT SEQ, seq_admstlog.nextval, :ls_action, SYSDATE, FR_SHOP, MV_SHOP, CONTNO, STATUS,
		 LEASEDT, SHOPID, 1, 0, 0, PHONE_MODEL, CUSTOMERID, CONTRACTSEQ,
		 NULL, NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
		 :gs_pgm_id[gi_open_win_no], ISEQ
FROM   AD_MOBILE_RENTAL
WHERE  CONTNO = :ls_new_cont;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'LEASELOG_NEW(LEASE) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If	

//old 장비
UPDATE AD_MOBILE_RENTAL
SET    CUSTOMERID 	= NULL,
       CONTRACTSEQ 	= NULL,
		 VALIDKEY	   = NULL,
		 CARD_CONTNO   = NULL,		 
		 STATUS	 		= :is_admst_Status,
       updt_user  	= :gs_user_id,
       updtdt 	   	= sysdate,
       pgm_id 	  		= :gs_pgm_id[gi_open_win_no]					 
WHERE  CONTNO = :ls_old_cont;

If SQLCA.SQLCode < 0 Then
	MESSAGEBOX(ls_errmsg, 'AD_MOBILE_RENTAL(OLD) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If

//장비이력(LEASELOG_NEW) Table에 정보저장 - 반품
INSERT INTO LEASELOG_NEW		
	( ADSEQ, SEQ, ACTION, ACTDT, FR_PARTNER, TO_PARTNER, CONTNO, STATUS, 
	  SALEDT, SHOPID, SALEQTY, SALE_AMT, SALE_SUM, MODELNO, CUSTOMERID, CONTRACTSEQ,
	  RETURNDT, REFUND_TYPE, REMARK, CRT_USER, CRTDT, UPDT_USER, UPDTDT,
	  PGM_ID, IDATE )
SELECT SEQ, seq_admstlog.nextval, :ls_return, SYSDATE, FR_SHOP, MV_SHOP, CONTNO, STATUS,
		 LEASEDT, SHOPID, 1, 0, 0, PHONE_MODEL, CUSTOMERID, CONTRACTSEQ,
		 TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'), NULL, REMARK, :gs_user_id, SYSDATE, UPDT_USER, UPDTDT,
		 :gs_pgm_id[gi_open_win_no], ISEQ
FROM   AD_MOBILE_RENTAL
WHERE  CONTNO = :ls_old_cont;

If SQLCA.SQLCode <> 0 Then
	MESSAGEBOX(ls_errmsg, 'LEASELOG_NEW(RETURN) : ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN 	
End If	

SetPointer(Arrow!)
F_MSG_INFO(3000,THIS.Title,"Save")

ai_return = 0

is_amt_check = 'N'       //수납 팝업 확인 초기값

RETURN
end event

event ue_ok();//해당 서비스에 해당하는 품목 조회
STRING	ls_customerid,		ls_where
LONG		ll_row,				ll_result

ls_customerid   = Trim(dw_cond.object.customerid[1])

IF ISNULL(ls_customerid) THEN ls_customerid = ""

IF ls_customerid = "" THEN
	F_MSG_INFO(200, Title, "Customer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	RETURN
END IF

ls_where = ""
ls_where += " CONTRACTMST.CUSTOMERID ='" + ls_customerid + "' "
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
ELSEIF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
   RETURN	
END IF	

SetRedraw(FALSE)

IF ll_row >= 0 THEN
	p_save.TriggerEvent("ue_enable")
	p_payment.TriggerEvent("ue_enable")
	dw_master.SetFocus()

	dw_cond.Enabled = FALSE
	p_ok.TriggerEvent("ue_disable")
END IF

SetRedraw(TRUE)
end event

event type integer ue_reset();Constant Int LI_ERROR = -1
Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

//초기화
p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
p_payment.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
dw_cond.Enabled = True

dw_master.Reset()
dw_detail.Reset()
dw_cond.ReSet()
dw_cond.InsertRow(0)
dw_cond.object.memberid.protect = 0
dw_cond.SetFocus()
dw_cond.SetColumn("customerid")

Return 0



end event

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

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

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
dw_cond.object.memberid[1] 	= ls_memberid

RETURN 0

end function

on ubs_w_reg_mobilechange.create
int iCurrent
call super::create
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.st_horizontal=create st_horizontal
this.dw_detail=create dw_detail
this.dw_cond=create dw_cond
this.p_close=create p_close
this.p_save=create p_save
this.p_payment=create p_payment
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reset
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.dw_master
this.Control[iCurrent+4]=this.st_horizontal
this.Control[iCurrent+5]=this.dw_detail
this.Control[iCurrent+6]=this.dw_cond
this.Control[iCurrent+7]=this.p_close
this.Control[iCurrent+8]=this.p_save
this.Control[iCurrent+9]=this.p_payment
this.Control[iCurrent+10]=this.gb_1
end on

on ubs_w_reg_mobilechange.destroy
call super::destroy
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.st_horizontal)
destroy(this.dw_detail)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.p_save)
destroy(this.p_payment)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 모바일 기기 변경을 받는 화면               //
// Name       : ubs_w_reg_mobilechange		                 //
// Contents   : 모바일 고객의 기기를 변경한다.				  //
// Data Window: dw - ubs_dw_reg_mobilechange_mas		     // 
//							ubs_dw_shop_reg_mobilefee 				  //
// 작성일자   : 2009.03.13                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc

iu_cust_db_app = CREATE u_cust_db_app

// Set the Top, Bottom Controls
idrg_Top = dw_master
idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

dw_cond.InsertRow(0)
dw_detail.InsertRow(0)

p_reset.TriggerEvent("ue_enable")
p_payment.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")

is_print_check = 'N'     //수납팝업 확인 초기 값

ls_ref_desc = ""
is_admst_status = fs_get_control("E1", "A104", ls_ref_desc)
is_return_status = fs_get_control("E1", "A102", ls_ref_desc)
end event

event close;call super::close;DESTROY iu_cust_db_app
end event

event resize;call super::resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_detail.Height = 0
  
	p_payment.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
ELSE
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
   p_payment.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
END IF

IF newwidth < dw_detail.X  THEN
	dw_detail.Width = 0
ELSE
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
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

event closequery;call super::closequery;Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

type p_reset from u_p_reset within ubs_w_reg_mobilechange
integer x = 645
integer y = 1652
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_reg_mobilechange
integer x = 2542
integer y = 56
end type

type dw_master from u_d_base within ubs_w_reg_mobilechange
integer x = 14
integer y = 300
integer width = 2843
integer height = 656
integer taborder = 30
string dataobject = "ubs_dw_reg_mobilechange_mas"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event clicked;call super::clicked;LONG	ll_contractseq,	ll_row

IF row <= 0 THEN RETURN

THIS.AcceptText()

ll_contractseq = THIS.Object.contractseq[row]

ll_row = dw_detail.Retrieve(ll_contractseq)

IF ll_row > 0 THEN
	dw_detail.Object.new_contno[1] = ""
END IF

is_amt_check = 'N'

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
end event

event retrieveend;call super::retrieveend;LONG	ll_contractseq,	ll_row

IF rowcount <= 0 THEN RETURN

THIS.AcceptText()

ll_contractseq = THIS.Object.contractseq[1]

dw_detail.Reset()

ll_row = dw_detail.Retrieve(ll_contractseq)

IF ll_row > 0 THEN
	dw_detail.Object.new_contno[1] = ""
END IF

is_amt_check = 'N'

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)




end event

type st_horizontal from statictext within ubs_w_reg_mobilechange
event mousedown pbm_lbuttondown
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
integer x = 18
integer y = 956
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

event mousedown;SetPosition(ToTop!)

BackColor = 0  // Show Bar in Black while being moved.

end event

event mousemove;Constant Integer li_MoveLimit = 100
Integer	li_prevposition

If KeyDown(keyLeftButton!) Then
	// Store the previous position.
	li_prevposition = Y

	// Refresh the Bar attributes.
	If Not (Parent.PointerY() <= idrg_Top.Y + li_MoveLimit Or Parent.PointerY() >= idrg_Bottom.Y + idrg_Bottom.Height - li_MoveLimit) Then
		Y = Parent.PointerY()
	End If
	
	// Perform redraws when appropriate.
	If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return
	If li_prevposition < idrg_Top.Y + idrg_Top.Height Then
		idrg_Top.SetRedraw(True)
		idrg_Bottom.SetRedraw(True)
	End If
	If Not IsValid(idrg_Bottom) Then Return
	If li_prevposition > idrg_Bottom.Y Then idrg_Bottom.SetRedraw(True)
End If

end event

event mouseup;// Hide the bar
//BackColor = il_HiddenColor

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

end event

type dw_detail from u_d_base within ubs_w_reg_mobilechange
integer x = 14
integer y = 992
integer width = 2843
integer height = 628
integer taborder = 20
string dataobject = "ubs_dw_reg_mobilechange_det"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;STRING	ls_new_serialno,	ls_new_phone_model, 	ls_new_phone_type,	ls_phone_type,		&
			ls_old_item,		ls_new_item
LONG		ll_day,				ll_extdays,				ll_cnt,					ll_bill_amt,		&
			ll_new_bill_amt,  ll_seq
DEC{2}	ldc_old_amt,		ldc_new_amt

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "new_contno"	
		
		SELECT COUNT(*), MIN(SERIALNO), MIN(PHONE_MODEL), MIN(PHONE_TYPE), MIN(SEQ)
		INTO   :ll_cnt, :ls_new_serialno, :ls_new_phone_model, :ls_new_phone_type, :ll_seq
		FROM   AD_MOBILE_RENTAL
		WHERE  CONTNO = :data
		AND    STATUS IN (:is_admst_status, :is_return_status)
		AND    SHOPID = :gs_shopid;
		
		IF ll_cnt <= 0 THEN
			F_MSG_INFO(9000, Title, "Phone Control No가 유효하지 않습니다")						
			THIS.Object.new_contno[1] = ""
			RETURN 2
		END IF
		
		THIS.Object.new_phone_type[1]  = ls_new_phone_type
		THIS.Object.new_serialno[1]    = ls_new_serialno
		THIS.Object.new_phone_model[1] = ls_new_phone_model	
		THIS.Object.new_seq[1]			 = ll_seq
		
		ls_phone_type = THIS.Object.phone_type[1]
		
		SELECT ITEMCOD, BILL_AMT INTO :ls_old_item, :ldc_old_amt
		FROM   ITEMMST_MOBILE
		WHERE  PHONE_TYPE = :ls_phone_type
		AND    DEFAULT_YN = 'Y';
		
		SELECT ITEMCOD, BILL_AMT INTO :ls_new_item, :ldc_new_amt
		FROM   ITEMMST_MOBILE
		WHERE  PHONE_TYPE = :ls_new_phone_type
		AND    DEFAULT_YN = 'Y';			

		THIS.Object.new_item[1] = ls_new_item
		THIS.Object.new_amt[1]  = ldc_new_amt
		THIS.Object.old_item[1] = ls_old_item
		THIS.Object.old_amt[1]  = ldc_old_amt		
		
		THIS.Object.new_payment[1] = ldc_new_amt - ldc_old_amt	
		
		IF ls_phone_type <> ls_new_phone_type THEN
			F_MSG_INFO(9000, Title, "Phone Type 을 다르게 변경할 수 없습니다.")						
			THIS.Object.new_contno[1] = ""
			RETURN 2
		END IF		
		
END CHOOSE

Return 0 
end event

type dw_cond from u_d_help within ubs_w_reg_mobilechange
integer x = 37
integer y = 36
integer width = 2455
integer height = 232
integer taborder = 10
string dataobject = "ubs_dw_reg_mobilechange_cnd"
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
					
			THIS.Object.memberid.protect = 1					
			
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

event itemchanged;call super::itemchanged;String	ls_customerid

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "memberid" 
   	IF wfi_get_customerid("", data) = -1 THEN
			RETURN -1
		END IF				
	CASE "customerid"		
   	IF wfi_get_customerid(data, "") = -1 THEN
			RETURN -1
		ELSE
			THIS.Object.memberid.protect = 1
		END IF
	CASE "number"		
		SELECT CUSTOMERID INTO :ls_customerid
		FROM   AD_MOBILE_RENTAL
		WHERE  VALIDKEY = :data;
		
		IF SQLCA.SQLCODE <> 0 THEN
			THIS.Object.number[row] = ""
	   	F_MSG_USR_ERR(201, Title, "Customer ID")
			RETURN 2
		END IF
						
		THIS.Object.customerid[row] = ls_customerid
		
   	IF wfi_get_customerid(ls_customerid, "") = -1 THEN
			RETURN -1
		ELSE
			THIS.Object.memberid.protect = 1
		END IF		
	CASE "serialno"		
		SELECT CUSTOMERID INTO :ls_customerid
		FROM   AD_MOBILE_RENTAL
		WHERE  SERIALNO = :data;		

		IF SQLCA.SQLCODE <> 0 THEN
			THIS.Object.serialno[row] = ""
	   	F_MSG_USR_ERR(201, Title, "Customer ID")			
			RETURN 2
		END IF
		
		THIS.Object.customerid[row] = ls_customerid
		
   	IF wfi_get_customerid(ls_customerid, "") = -1 THEN
			RETURN -1
		ELSE
			THIS.Object.memberid.protect = 1
		END IF				
		
	CASE "contno"		
		SELECT CUSTOMERID INTO :ls_customerid
		FROM   AD_MOBILE_RENTAL
		WHERE  CONTNO = :data;		
		
		IF SQLCA.SQLCODE <> 0 THEN
			THIS.Object.contno[row] = ""
	   	F_MSG_USR_ERR(201, Title, "Customer ID")
			RETURN 2
		END IF
		
		THIS.Object.customerid[row] = ls_customerid
		
   	IF wfi_get_customerid(ls_customerid, "") = -1 THEN
			RETURN -1
		ELSE
			THIS.Object.memberid.protect = 1
		END IF						
		
END CHOOSE
end event

type p_close from u_p_close within ubs_w_reg_mobilechange
integer x = 960
integer y = 1652
boolean originalsize = false
end type

type p_save from u_p_save within ubs_w_reg_mobilechange
integer x = 329
integer y = 1652
boolean originalsize = false
end type

event clicked;INTEGER		 li_rc
CONSTANT INT LI_ERROR = -1

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.

PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

PARENT.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

PARENT.TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = PARENT.Title

	iu_cust_db_app.uf_prc_db()
	
	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN LI_ERROR
	END IF
	RETURN LI_ERROR
ELSEIF li_rc = 0 THEN
		
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = PARENT.Title

	iu_cust_db_app.uf_prc_db()

	IF iu_cust_db_app.ii_rc = -1 THEN
		dw_master.SetFocus()
		RETURN LI_ERROR
	END IF
END IF
	
end event

type p_payment from u_p_payment within ubs_w_reg_mobilechange
integer x = 14
integer y = 1652
boolean originalsize = false
end type

event clicked;LONG		ll_row
INTEGER	li_rc
STRING	ls_customerid,		ls_customernm,		ls_phone_type,		ls_save_check,		&
			ls_old_item,		ls_new_item,		ls_new_type,		ls_old_type		
DEC{2}	ldc_old_amt,		ldc_new_amt

dw_detail.AcceptText()
dw_master.AcceptText()

ll_row = dw_master.GetRow()
ls_customerid = dw_master.Object.customerid[ll_row]
ls_old_item   = dw_detail.Object.old_item[1]
ls_new_item   = dw_detail.Object.new_item[1]
ldc_old_amt   = dw_detail.Object.old_amt[1]
ldc_new_amt   = dw_detail.Object.new_amt[1]

SELECT CUSTOMERNM	INTO :ls_customernm
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_customerid;

ls_phone_type = dw_detail.Object.new_phone_type[1]

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.

PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

//이미 수납을 했는지 확인
IF is_amt_check = 'Y' THEN 
	ls_save_check = 'Y'
ELSE
	ls_save_check = 'N'
END IF	

ls_new_type = dw_detail.Object.new_phone_type[1]
ls_old_type = dw_detail.Object.phone_type[1]

IF ls_new_type <> ls_old_type THEN
	
	iu_cust_msg 				= CREATE u_cust_a_msg
	iu_cust_msg.is_pgm_name = "Mobile Contract Payment"
	iu_cust_msg.is_data[1]  = "CloseWithReturn"
	iu_cust_msg.il_data[1]  = 1  		//현재 row
	iu_cust_msg.idw_data[1] = dw_master
	iu_cust_msg.idw_data[2] = dw_detail
	iu_cust_msg.is_data[2]  = ls_customerid
	iu_cust_msg.is_data[3]  = ls_customernm
	iu_cust_msg.is_data[4]  = ls_phone_type
	iu_cust_msg.is_data[5]  = ls_save_check
	
	//임시세팅
	iu_cust_msg.il_data[2]  = 2						//item 갯수
	iu_cust_msg.is_data2[1] = ls_old_item  		//item 값을 갯수만큼 배열로 넘김
	iu_cust_msg.is_data2[2] = ls_new_item  		//item 값을 갯수만큼 배열로 넘김
	iu_cust_msg.ic_data[1]  = ldc_old_amt * -1   //item 값을 갯수만큼 배열로 넘김
	iu_cust_msg.ic_data[2]  = ldc_new_amt	   	//item 값을 갯수만큼 배열로 넘김
	
	//수납 팝업 연결 연결
	OpenWithParm(ubs_w_pop_mobilepayment, iu_cust_msg)
	
	//is_amt_check 값 세팅 : 수납 팝업에서 반환되는 값. 완료:'N', 미완료:'Y'
	IF iu_cust_msg.ib_data[1] THEN
		is_amt_check = iu_cust_msg.is_data[1]
	END IF
	
	DESTROY iu_cust_msg
ELSE
//	MessageBox("확인", "Phone Type이 동일합니다. 다음단계로 진행하세요.")
	is_amt_check = 'Y'
END IF

RETURN 0
end event

type gb_1 from groupbox within ubs_w_reg_mobilechange
integer x = 14
integer y = 8
integer width = 2843
integer height = 280
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

