$PBExportHeader$ubs_w_reg_mobileextdays.srw
$PBExportComments$[jhchoi] 모바일 렌탈 연장 - 2009.04.22
forward
global type ubs_w_reg_mobileextdays from w_base
end type
type p_reset from u_p_reset within ubs_w_reg_mobileextdays
end type
type st_horizontal from statictext within ubs_w_reg_mobileextdays
end type
type dw_detail from u_d_base within ubs_w_reg_mobileextdays
end type
type dw_master from u_d_help within ubs_w_reg_mobileextdays
end type
type p_close from u_p_close within ubs_w_reg_mobileextdays
end type
type p_print from u_p_print within ubs_w_reg_mobileextdays
end type
type p_save from u_p_save within ubs_w_reg_mobileextdays
end type
type p_payment from u_p_payment within ubs_w_reg_mobileextdays
end type
end forward

global type ubs_w_reg_mobileextdays from w_base
integer width = 3653
integer height = 1232
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event type integer ue_reset ( )
p_reset p_reset
st_horizontal st_horizontal
dw_detail dw_detail
dw_master dw_master
p_close p_close
p_print p_print
p_save p_save
p_payment p_payment
end type
global ubs_w_reg_mobileextdays ubs_w_reg_mobileextdays

type variables
u_cust_db_app iu_cust_db_app

INT	ii_error_chk

//Resize Panels by kEnn 2000-06-28
INTEGER		ii_WindowTop						//The virtual top of the window
INTEGER		ii_WindowMiddle					//The virtual middle of the window
LONG			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Middle							//Reference to the Top Middle control
Dragobject	idrg_Bottom							//Reference to the Top Bottom control
CONSTANT INTEGER	cii_BarThickness = 20	//Bar Thickness
CONSTANT INTEGER	cii_WindowBorder = 20	//Window border to be used on all sides

STRING	is_cus_status,		is_hotbillflag,	is_admst_status,	is_amt_check,	is_print_check,	&
			is_cont_period,	is_paydt
DEC		idc_bil_amt   
LONG		il_extdays
end variables

forward prototypes
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public subroutine of_refreshbars ()
public subroutine wf_protect (string ai_gubun)
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_master.GetRow()

lb_check = fb_save_required(dw_master, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);STRING	ls_new_customer

dw_master.AcceptText()

IF is_amt_check = 'N' THEN
	F_MSG_INFO(9000, Title, "수납이 완료되지 않았습니다")
	ai_return = -1
	RETURN
END IF
	
//IF is_print_check = 'N' THEN
//	F_MSG_INFO(9000, Title, "계약서 출력이 완료되지 않았습니다")
//	ai_return = -1
//	RETURN
//END IF
	
ai_return = 0

RETURN
end event

event ue_process(ref integer ai_return);STRING	ls_errmsg,		ls_customerid,		ls_payid,			ls_lastname,		ls_firstname,		&
			ls_basecod, 	ls_buildingno, 	ls_roomno, 			ls_unit,				ls_homephone, 		&
			ls_contno,		ls_itemcod, 		ls_phone_type, 	ls_admst_contno, 	ls_serialno,		&
			ls_phonemodel, ls_derosdt, 		ls_midname, 		ls_validkey, 		ls_contractseq,	&
			ls_priceplan,	ls_orderno,			ls_item_lease
LONG		ll_row,			ll_return,			ll_contractseq
INTEGER	ii
DATE		ld_cont_period

dw_master.AcceptText()
dw_detail.AcceptText()
ll_row = dw_master.GetRow()

ls_customerid   = dw_master.Object.customerid[ll_row]
ls_payid        = dw_master.Object.payid[ll_row]
ls_lastname     = dw_master.Object.lastname[ll_row]
ls_firstname    = dw_master.Object.firstname[ll_row]
ls_midname      = dw_master.Object.midname[ll_row]
ls_basecod      = dw_master.Object.basecod[ll_row]
ls_buildingno   = dw_master.Object.buildingno[ll_row]
ls_roomno       = dw_master.Object.roomno[ll_row]
ls_unit         = dw_master.Object.unit[ll_row]
ls_homephone    = dw_master.Object.homephone[ll_row]
ls_derosdt      = STRING(dw_master.Object.derosdt[ll_row], 'yyyymmdd')
ls_contno       = dw_master.Object.contno[ll_row]
ls_phone_type   = dw_master.Object.phone_type[ll_row]
ls_admst_contno = dw_master.Object.admst_contno[ll_row]
ls_serialno     = dw_master.Object.serialno[ll_row]
ls_phonemodel   = dw_master.Object.phone_model[ll_row] 
ls_validkey     = dw_master.Object.validkey[ll_row] 
ll_contractseq  = dw_master.Object.contractseq[ll_row] 
ls_contractseq  = STRING(dw_master.Object.contractseq[ll_row])
ls_item_lease   = dw_detail.Object.item_lease[1] 

//PRICEPLAN 찾아서 프로시저로 넘긴다.
SELECT PRICEPLAN 		 INTO :ls_priceplan
FROM 	 AD_MOBILE_TYPE
WHERE  PHONE_TYPE 	= :ls_phone_type;

IF SQLCA.SQLCODE <> 0 THEN
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)	
	ai_return = -1		
	RETURN
END IF

//프로시저 실행 - 고객 id 생성은 ue_process_customer 로 변경, 'U' 는 order type
ls_errmsg		= space(1000)
SQLCA.UBS_REG_MOBILE_CUSTOMER(ls_customerid,		ls_lastname,	ls_firstname,	ls_midname,		&
  	               	         ls_basecod,		 	ls_buildingno, ls_roomno, 		ls_unit, 		&
										ls_homephone, 		ls_derosdt, 	gs_shopid, 		'U',				&
										gs_user_id,			gs_pgm_id[1], 	ll_return, 		ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CUSTOMER ' + STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_MOBILE_CUSTOMER ' + ls_errmsg,Exclamation!,OK!)
	ai_return = -1		
	RETURN
END IF
	
ls_errmsg = space(1000)
ll_return = 0
SQLCA.UBS_REG_MOBILE_CONTRACT(ls_customerid, 	ll_contractseq, 	ls_contno,		ls_priceplan, 	&
										ls_admst_contno, 	ls_validkey, 		gs_shopid,		'U',				&
										gs_user_id,			gs_pgm_id[1],		ll_return,		ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CONTRACT ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_MOBILE_CONTRACT ' + ls_errmsg,Exclamation!,OK!)
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + ls_errmsg)
	ai_return = -1		
	RETURN
END IF

ls_errmsg = space(1000)
ll_return = 0

SELECT TO_DATE(:is_cont_period, 'YYYYMMDD') INTO :ld_cont_period
FROM   DUAL;
	
SQLCA.UBS_REG_MOBILE_CONTRACTDET(ls_customerid, 			ls_contractseq,	ls_orderno,		ls_item_lease,		&
										   ld_cont_period, 		   'U',					gs_user_id,		gs_pgm_id[1],	&
											ll_return,					ls_errmsg)

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, 'UBS_REG_MOBILE_CONTRACTDET ' + String(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ai_return = -1		
	RETURN
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', 'UBS_REG_MOBILE_CONTRACTDET ' + ls_errmsg,Exclamation!,OK!)
	ai_return = -1		
	RETURN
END IF

SetPointer(Arrow!)
F_MSG_INFO(3000,THIS.Title,"Save")

ai_return = 0

is_amt_check = 'N'       //프린트 팝업 확인 초기 값
is_print_check = 'N'     //수납팝업 확인 초기 값

RETURN
end event

event type integer ue_reset();CONSTANT	INT LI_ERROR = -1
INT		li_rc

IF (dw_master.ModifiedCount() > 0) OR (dw_master.DeletedCount() > 0) THEN
	li_rc = MessageBox(THIS.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   IF li_rc <> 1 THEN  RETURN LI_ERROR//Process Cancel
END IF

dw_detail.Reset()
dw_master.Reset()

is_amt_check = 'N'       //프린트 팝업 확인 초기 값
is_print_check = 'N'     //수납팝업 확인 초기 값

dw_master.InsertRow(0)
dw_detail.InsertRow(0)

dw_master.Object.lease_period_from[1] = fdt_get_dbserver_now()

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_master.SetItemStatus(1, 0, Primary!, NotModified!)

dw_master.SetFocus()
//dw_master.SetColumn("new_customer")
//기본 세팅
//wf_protect('N')  

RETURN 0

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

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
STRING	ls_customernm,		ls_payid,	ls_partner,		ls_customerid,		ls_memberid
INTEGER	li_sw

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
	FROM 	  CUSTOMERM
	WHERE	  CUSTOMERID = :as_customerid;
	 
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
	FROM 	  CUSTOMERM
	WHERE   MEMBERID = :as_memberid;
	
	ls_memberid = as_customerid
END IF

IF SQLCA.SQLCODE = 100 THEN		//Not Found
	IF li_sw = 1 THEN
   	F_MSG_USR_ERR(201, Title, "Customer ID")
   	dw_master.SetFocus()
   	dw_master.SetColumn("customerid")
	END IF
   RETURN -1
END IF

SELECT HOTBILLFLAG
INTO   :is_hotbillflag
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_payid;

IF SQLCA.SQLCODE = 100 THEN		//Not Found
   F_MSG_USR_ERR(201, Title, "고객번호(납입자번호)")
   dw_master.SetFocus()
   dw_master.SetColumn("customerid")
   RETURN -1
END IF

IF ISNULL(is_hotbillflag) THEN is_hotbillflag = ""
IF is_hotbillflag = 'S' THEN    //현재 Hotbilling고객이면 개통신청 못하게 한다.
   F_MSG_USR_ERR(201, Title, "즉시불처리중인고객")
   dw_master.SetFocus()
   dw_master.SetColumn("customerid")
   RETURN -1
END IF

dw_master.object.customernm[1] 	= ls_customernm
dw_master.object.customerid[1] 	= ls_customerid

RETURN 0

end function

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public subroutine wf_protect (string ai_gubun);STRING	ls_np_did, ls_np_ori_carrier

dw_master.AcceptText()

CHOOSE CASE ai_gubun
	CASE "N"
		dw_master.Object.customerid.Color = RGB(255,255,255)						//글씨색
		dw_master.Object.customerid.Background.Color = RGB(107, 146, 140)		//필수 배경색
		dw_master.Object.lastname.protect 	= 1
		dw_master.Object.firstname.protect 	= 1
		dw_master.Object.midname.protect 	= 1
		dw_master.Object.basecod.protect 	= 1
		dw_master.Object.buildingno.protect = 1
		dw_master.Object.roomno.protect 		= 1
		dw_master.Object.homephone.protect 	= 1
		dw_master.Object.derosdt.protect 	= 1		
	CASE "Y"
		dw_master.Object.customerid.Color = RGB(0,0,0)								//글씨색
		dw_master.Object.customerid.Background.Color = RGB(255, 255, 255)		//선택 배경색		
		dw_master.Object.lastname.protect 	= 0
		dw_master.Object.firstname.protect 	= 0
		dw_master.Object.midname.protect		= 0
		dw_master.Object.basecod.protect 	= 0
		dw_master.Object.buildingno.protect = 0
		dw_master.Object.roomno.protect 		= 0
		dw_master.Object.homephone.protect 	= 0
		dw_master.Object.derosdt.protect 	= 0		

END CHOOSE



end subroutine

on ubs_w_reg_mobileextdays.create
int iCurrent
call super::create
this.p_reset=create p_reset
this.st_horizontal=create st_horizontal
this.dw_detail=create dw_detail
this.dw_master=create dw_master
this.p_close=create p_close
this.p_print=create p_print
this.p_save=create p_save
this.p_payment=create p_payment
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reset
this.Control[iCurrent+2]=this.st_horizontal
this.Control[iCurrent+3]=this.dw_detail
this.Control[iCurrent+4]=this.dw_master
this.Control[iCurrent+5]=this.p_close
this.Control[iCurrent+6]=this.p_print
this.Control[iCurrent+7]=this.p_save
this.Control[iCurrent+8]=this.p_payment
end on

on ubs_w_reg_mobileextdays.destroy
call super::destroy
destroy(this.p_reset)
destroy(this.st_horizontal)
destroy(this.dw_detail)
destroy(this.dw_master)
destroy(this.p_close)
destroy(this.p_print)
destroy(this.p_save)
destroy(this.p_payment)
end on

event open;call super::open;//=========================================================//
// Desciption : 모바일 렌탈 연장을 하는 화면	              //
// Name       : ubs_w_reg_mobileextdays	                 //
// Contents   : 모바일 렌탈 연장을 신청받아 처리하는 화면  //
// Data Window: dw - ubs_dw_reg_mobileextdays_mas          // 
//							ubs_dw_reg_mobileextdays_det			  //
// 작성일자   : 2009.04.22                                 //
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

is_amt_check = 'N'       //프린트 팝업 확인 초기 값
is_print_check = 'N'     //수납팝업 확인 초기 값

dw_master.InsertRow(0)
dw_detail.InsertRow(0)

ls_ref_desc = ""
is_admst_status = fs_get_control("E1", "A104", ls_ref_desc)

dw_master.Object.lease_period_from[1] = fdt_get_dbserver_now()

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_master.SetItemStatus(1, 0, Primary!, NotModified!)

dw_master.SetFocus()

//기본 세팅
//wf_protect('N')  

end event

event close;call super::close;DESTROY	iu_cust_db_app
end event

event resize;call super::resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_detail.Height = 0
  
	p_payment.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_print.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
ELSE
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
   p_payment.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_print.Y	= newheight - iu_cust_w_resize.ii_button_space_1
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

dw_master.AcceptText()

If (dw_master.ModifiedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

type p_reset from u_p_reset within ubs_w_reg_mobileextdays
integer x = 965
integer y = 976
end type

type st_horizontal from statictext within ubs_w_reg_mobileextdays
event mousedown pbm_lbuttondown
event mousemove pbm_mousemove
event mouseup pbm_lbuttonup
integer x = 18
integer y = 704
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

event mousemove(unsignedlong flags, integer xpos, integer ypos);Constant Integer li_MoveLimit = 100
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

event mouseup;//// Hide the bar
//BackColor = il_HiddenColor
//
//// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()
//
end event

type dw_detail from u_d_base within ubs_w_reg_mobileextdays
integer x = 14
integer y = 740
integer width = 2007
integer height = 184
integer taborder = 20
string dataobject = "ubs_dw_reg_mobileextdays_det"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

type dw_master from u_d_help within ubs_w_reg_mobileextdays
integer x = 14
integer y = 16
integer width = 3579
integer height = 684
integer taborder = 10
string dataobject = "ubs_dw_reg_mobileextdays_mas"
boolean hscrollbar = false
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;call super::doubleclicked;STRING	ls_customerid,	ls_contractseq
LONG		ll_row,			ll_cont_cnt

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid"
		IF iu_cust_help.ib_data[1] THEN
			is_cus_status 				= iu_cust_help.is_data[3]
				
			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 THEN
				RETURN -1
			END IF
				
			ls_customerid = THIS.Object.customerid[row]	
			
			SELECT COUNT(CON.CONTRACTSEQ), MAX(CON.CONTRACTSEQ) INTO :ll_cont_cnt, :ls_contractseq
			FROM   CUSTOMERM CUS, CONTRACTMST CON, AD_MOBILE_RENTAL ADREN, ADMST ADM
			WHERE  CUS.CUSTOMERID = :ls_customerid
			AND    CUS.CUSTOMERID = CON.CUSTOMERID
			AND    CON.PRICEPLAN IN ( SELECT PRICEPLAN FROM AD_MOBILE_TYPE )
			AND    CON.STATUS = '20'
			AND    CON.CUSTOMERID  = ADREN.CUSTOMERID
			AND    CON.CONTRACTSEQ = ADREN.CONTRACTSEQ
			AND    CON.CUSTOMERID  = ADM.CUSTOMERID
			AND    CON.CONTRACTSEQ = ADM.CONTRACTSEQ;
		
			IF ll_cont_cnt <= 1 THEN		
				ll_row = dw_master.Retrieve(ls_customerid, ls_contractseq)
			ELSE
				
				iu_cust_msg 				= CREATE u_cust_a_msg
				iu_cust_msg.is_pgm_name = "Contract Select"
				iu_cust_msg.is_data[1]  = "CloseWithReturn"
				iu_cust_msg.il_data[1]  = 1  		//현재 row
				iu_cust_msg.is_data[2]  = ls_customerid
				iu_cust_msg.idw_data[1] = dw_master
	
				//계약선택을 위한 팝업
				OpenWithParm(ubs_w_pop_mobilecontselect, iu_cust_msg)
	
				IF iu_cust_msg.ib_data[1] THEN
					//is_print_check 값 세팅!  - 출력 팝업에서 반환되는 값. 완료 : 'Y', 미완료:'N'
					ls_contractseq = iu_cust_msg.is_data[3]
				END IF
	
				DESTROY iu_cust_msg
				
				ll_row = dw_master.Retrieve(ls_customerid, ls_contractseq)
			END IF							
		
			IF ll_row <= 0 THEN
				F_MSG_INFO(9000, Title, "계약정보가 없습니다.")
				THIS.InsertRow(0)			
				THIS.SetFocus()
				THIS.SetRow(1)
				THIS.SetColumn('customerid')
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

dw_master.SetFocus()
dw_master.SetRow(1)
dw_master.SetColumn('customerid')
end event

event itemchanged;call super::itemchanged;STRING	ls_filter,			ls_lease_period,		ls_sysdate,		ls_cont_period,		ls_customerid,	&
			ls_lease_from,		ls_contractseq,		ls_phone_type,	ls_lease_item
LONG		ll_day, 				ll_extdays, 			ll_cnt, 			ll_sale_amt,			ll_bill_amt,   &
			ll_row,				ll_cont_cnt
DEC{2}	ldc_lease_amt

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "customerid"
		IF wfi_get_customerid(data, "") = -1 THEN
			RETURN -1
		END IF
		
		SELECT COUNT(CON.CONTRACTSEQ), MAX(CON.CONTRACTSEQ) INTO :ll_cont_cnt, :ls_contractseq
		FROM   CUSTOMERM CUS, CONTRACTMST CON, AD_MOBILE_RENTAL ADREN, ADMST ADM
		WHERE  CUS.CUSTOMERID = :data
		AND    CUS.CUSTOMERID = CON.CUSTOMERID
		AND    CON.PRICEPLAN IN ( SELECT PRICEPLAN FROM AD_MOBILE_TYPE )
		AND    CON.STATUS = '20'
		AND    CON.CUSTOMERID  = ADREN.CUSTOMERID
		AND    CON.CONTRACTSEQ = ADREN.CONTRACTSEQ
		AND    CON.CUSTOMERID  = ADM.CUSTOMERID
		AND    CON.CONTRACTSEQ = ADM.CONTRACTSEQ;
		
		IF ll_cont_cnt <= 1 THEN		
			ll_row = dw_master.Retrieve(data, ls_contractseq)
		ELSE
			
			iu_cust_msg 				= CREATE u_cust_a_msg
			iu_cust_msg.is_pgm_name = "Contract Select"
			iu_cust_msg.is_data[1]  = "CloseWithReturn"
			iu_cust_msg.il_data[1]  = 1  		//현재 row
			iu_cust_msg.is_data[2]  = data
			iu_cust_msg.idw_data[1] = dw_master

			//계약선택을 위한 팝업
			OpenWithParm(ubs_w_pop_mobilecontselect, iu_cust_msg)

			IF iu_cust_msg.ib_data[1] THEN
				//is_print_check 값 세팅!  - 출력 팝업에서 반환되는 값. 완료 : 'Y', 미완료:'N'
				ls_contractseq = iu_cust_msg.is_data[3]
			END IF

			DESTROY iu_cust_msg
			
			ll_row = dw_master.Retrieve(data, ls_contractseq)
		END IF				

		IF ll_row <= 0 THEN
			F_MSG_INFO(9000, Title, "계약정보가 없습니다.")
			THIS.InsertRow(0)	
			THIS.SetFocus()
			THIS.SetRow(1)
			THIS.SetColumn('customerid')
			RETURN -1
		END IF						
		
	CASE "lease_period"
		ls_lease_period = STRING(THIS.Object.lease_period[1], 'YYYYMMDD')
		ls_lease_from	 = STRING(THIS.Object.lease_period_from[1], 'YYYYMMDD')
		ls_phone_type   = THIS.Object.phone_type[1]

		//날짜 계산.
		SELECT  (TO_DATE(:ls_lease_period, 'yyyymmdd') - TO_DATE(:ls_lease_from, 'YYYYMMDD')) + 1
				, TO_CHAR(SYSDATE, 'YYYYMMDD')
		INTO    :ll_day, :ls_sysdate
		FROM    DUAL;		
		
		IF ls_lease_period < ls_sysdate THEN
			F_MSG_INFO(9000, Title, "현재일 보다 이전으로 입력할 수 없습니다.")
			THIS.Object.lease_period[1] = fdt_get_dbserver_now()
			RETURN 2
		END IF		
		
		IF ls_lease_period <= ls_lease_from THEN
			F_MSG_INFO(9000, Title, "이전계약 종료일 이전으로 입력할 수 없습니다.")
			THIS.Object.lease_period[1] = fdt_get_dbserver_now()
			RETURN 2
		END IF				
		
		//Contract Period 계산
		SELECT MIN(BILL_AMT), MIN(EXTDAYS) INTO :idc_bil_amt, :il_extdays
		FROM   ITEMMST_MOBILE
		WHERE  EXTDAYS = ( SELECT MIN(EXTDAYS)
								 FROM   ITEMMST_MOBILE
								 WHERE  EXTDAYS >= :ll_day
								 AND    PERIOD_YN = 'Y' )
		AND    PERIOD_YN = 'Y';
		
		//contract Period 구하기						 
		SELECT TO_CHAR(TO_DATE(:ls_lease_from, 'YYYYMMDD') + :il_extdays - 1, 'YYYYMMDD')
		INTO   :is_cont_period
		FROM   DUAL;
		
		dw_master.Object.contract_period[1] = MidA(ls_lease_from, 5, 2)+"-"+MidA(ls_lease_from, 7, 2)+"-"+MidA(ls_lease_from, 1, 4)+ &
														  " ∼ " + MidA(is_cont_period, 5, 2)+"-"+MidA(is_cont_period, 7, 2)+"/"+MidA(is_cont_period, 1, 4)

		
		//lease fee 세팅!		
		SELECT ITEMCOD, BILL_AMT INTO :ls_lease_item, :ldc_lease_amt
		FROM   ITEMMST_MOBILE
		WHERE  PHONE_TYPE = :ls_phone_type
		AND    EXTDAYS    = :il_extdays
		AND    PERIOD_YN  = 'Y';
		
		dw_detail.Object.lease[1]		 = ldc_lease_amt		
		dw_detail.Object.item_lease[1] = ls_lease_item			
		
END CHOOSE

RETURN 0 
end event

event buttonclicked;call super::buttonclicked;u_cust_a_msg iu_cust_help2
STRING	ls_lease_period

IF dwo.name = 'b_1' THEN
	iu_cust_help2 = CREATE u_cust_a_msg
	
	iu_cust_help2.is_pgm_name = "Calendar"
	iu_cust_help2.is_grp_name = "날짜선택"
	iu_cust_help2.ib_data[1]  = True
	iu_cust_help2.idw_data[1] = dw_master
	
	OpenWithParm(ubs_w_pop_calendar, iu_cust_help2)	
	
	destroy iu_cust_help2
	
END IF	

	
end event

type p_close from u_p_close within ubs_w_reg_mobileextdays
integer x = 1285
integer y = 976
boolean originalsize = false
end type

type p_print from u_p_print within ubs_w_reg_mobileextdays
integer x = 329
integer y = 976
boolean originalsize = false
end type

event clicked;INTEGER	li_rc

//dw_master.AcceptText()
//dw_detail.AcceptText()

// Ue_inputValidCheck  호출
// 가격정보를 가지고 수납을 위한 팝업을 띄움.
PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Mobile Contract Print"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.idw_data[2] = dw_detail

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_mobilecontract, iu_cust_msg)

IF iu_cust_msg.ib_data[1] THEN
	//is_print_check 값 세팅!  - 출력 팝업에서 반환되는 값. 완료 : 'Y', 미완료:'N'
	is_print_check = iu_cust_msg.is_data[1]
END IF

DESTROY iu_cust_msg

RETURN 0


end event

type p_save from u_p_save within ubs_w_reg_mobileextdays
integer x = 645
integer y = 976
boolean originalsize = false
end type

event clicked;INTEGER		 li_rc
CONSTANT	INT LI_ERROR = -1

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

//수정된 내용이 없도록 하기 위해서 강제 세팅!
dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
	
end event

type p_payment from u_p_payment within ubs_w_reg_mobileextdays
integer x = 14
integer y = 976
boolean originalsize = false
end type

event clicked;INTEGER	li_rc
STRING	ls_customerid,		ls_customernm,		ls_phone_type,		ls_save_check,		ls_item_lease
DEC{2}	ldc_lease

dw_master.AcceptText()
dw_detail.AcceptText()

ls_customerid 	 = dw_master.Object.customerid[1]
ls_customernm 	 = dw_master.Object.customernm[1]
ls_phone_type 	 = dw_master.Object.phone_type[1]
ls_item_lease	 = dw_detail.Object.item_lease[1]
ldc_lease		 = dw_detail.Object.lease[1]

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
//품목넘김
iu_cust_msg.il_data[2]  = 1					//item 갯수
iu_cust_msg.is_data2[1] = ls_item_lease   //lease
iu_cust_msg.ic_data[1]  = ldc_lease	   	//lease fee

//수납을 위한 팝업 연결
OpenWithParm(ubs_w_pop_mobilepayment, iu_cust_msg)

//is_amt_check 값 세팅 : 수납 팝업에서 반환되는 값. 완료:'N', 미완료:'Y'
IF iu_cust_msg.ib_data[1] THEN
	is_amt_check = iu_cust_msg.is_data[1]
	is_paydt		 = iu_cust_msg.is_data[2]		
END IF

DESTROY iu_cust_msg

RETURN 0
end event

