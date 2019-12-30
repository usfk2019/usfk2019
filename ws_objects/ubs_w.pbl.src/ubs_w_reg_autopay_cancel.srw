$PBExportHeader$ubs_w_reg_autopay_cancel.srw
$PBExportComments$[jhchoi] 수납 취소- 2009.04.29
forward
global type ubs_w_reg_autopay_cancel from w_base
end type
type dw_detail2 from u_d_base within ubs_w_reg_autopay_cancel
end type
type dw_detail from datawindow within ubs_w_reg_autopay_cancel
end type
type p_cancel from u_p_cancel within ubs_w_reg_autopay_cancel
end type
type p_reset from u_p_reset within ubs_w_reg_autopay_cancel
end type
type p_ok from u_p_ok within ubs_w_reg_autopay_cancel
end type
type dw_master from u_d_base within ubs_w_reg_autopay_cancel
end type
type st_horizontal from statictext within ubs_w_reg_autopay_cancel
end type
type dw_cond from u_d_help within ubs_w_reg_autopay_cancel
end type
type p_close from u_p_close within ubs_w_reg_autopay_cancel
end type
type gb_1 from groupbox within ubs_w_reg_autopay_cancel
end type
end forward

global type ubs_w_reg_autopay_cancel from w_base
integer width = 3314
integer height = 2024
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event type integer ue_process ( )
event ue_ok ( )
event type integer ue_reset ( )
dw_detail2 dw_detail2
dw_detail dw_detail
p_cancel p_cancel
p_reset p_reset
p_ok p_ok
dw_master dw_master
st_horizontal st_horizontal
dw_cond dw_cond
p_close p_close
gb_1 gb_1
end type
global ubs_w_reg_autopay_cancel ubs_w_reg_autopay_cancel

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


String is_cus_status, is_hotbillflag, is_worktype[],	is_approvalno
Date   idt_shop_closedt
end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine of_resizebars ()
public subroutine of_refreshbars ()
public function integer wfi_get_payid (string as_payid, string as_memberid)
public subroutine wf_protect (string ai_gubun)
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN	lb_check
LONG		ll_row

ll_row = dw_cond.GetRow()

lb_check = fb_save_required(dw_cond, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck;STRING	ls_payid,				ls_prcyn,		ls_sysdate,		ls_sales_date,		ls_chk
LONG		ll_reqpaylog_cnt,		ll_row,			ll_cnt,			ll_seqno
INT		ii

dw_cond.AcceptText()
dw_master.AcceptText()

ll_row = dw_master.RowCount()

ls_payid			= dw_cond.Object.payid[1]
//ls_sales_date     = STRING(dw_cond.object.sales_date[1], 'YYYYMMDD')

FOR ii = 1 TO ll_row
	ls_chk = dw_master.Object.chk[ii]
	
	IF ls_chk = 'Y' THEN
		ll_cnt = ll_cnt + 1
		ll_seqno = dw_master.Object.seqno[ii]
		ls_prcyn = dw_master.Object.prc_yn[ii]
	END IF
NEXT

IF ll_cnt > 1 THEN 
	f_msg_usr_err(9000, Title, "취소는 한건씩 처리하시기 바랍니다.")	
	ai_return = -1
	RETURN
END IF	
	
IF ls_prcyn = 'Y' THEN

	SELECT COUNT(*) INTO :ll_reqpaylog_cnt
	FROM   REQPAY2DTL_LOG
	WHERE  PAYID = :ls_payid
	AND    SEQNO = :ll_seqno;
	
	IF ll_reqpaylog_cnt <= 0 THEN
		f_msg_usr_err(9000, Title, "수납반영된 기록이 없어서 처리 불가합니다.")	
		ai_return = -1
		RETURN
	END IF
END IF	

//SELECT TO_CHAR(SYSDATE, 'YYYYMM') INTO :ls_sysdate
//FROM   DUAL;
//
//IF Mid(ls_sales_date, 1, 6) <> ls_sysdate THEN
//	f_msg_usr_err(9000, Title, "당월 수납만 취소할 수 있습니다.")	
//	ai_return = -1
//	RETURN
//END IF	

ai_return = 0

RETURN
end event

event ue_process;STRING	ls_payid,			ls_remark,		ls_errmsg,			ls_sales_date,			ls_chk, ls_seqno
LONG		ll_row,				ll_return,		ll_seqno
INTEGER	li_rc,				ii

dw_cond.AcceptText()
dw_master.AcceptText()

p_cancel.TriggerEvent("ue_disable")
dw_cond.Enabled = False

//Process Validation Check
THIS.TRIGGER EVENT ue_processvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN -1
END IF

ll_row 			= dw_master.RowCount()

IF ll_row <= 0 THEN RETURN -1

ls_payid			= dw_cond.Object.payid[1]
ls_remark		= dw_cond.Object.remark[1]
//ls_sales_date	= STRING(dw_cond.Object.sales_date[1], 'YYYYMMDD')

//FOR ii = 1 TO ll_row
//	
//	ls_chk = dw_master.Object.chk[ii]
//	
//	IF ls_chk = 'Y' THEN
//		ll_seqno = dw_master.Object.seqno[ii]
//	END IF
//	
//	//수납 입력
//	ls_errmsg = space(1000)
//	SQLCA.B5REQPAY2DTL_PAYID_AP_CANCEL(ls_payid, ll_seqno, ls_remark,	gs_user_id,	gs_pgm_id[gi_open_win_no], ll_return, ls_errmsg)
//											
//	IF SQLCA.SQLCODE < 0 THEN		//For Programer
//		MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
//		ROLLBACK;
//		RETURN -1
//	ELSEIF ll_return < 0 THEN		//For User
//		MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
//		ROLLBACK;	
//		RETURN -1
//	END IF
//	
//NEXT




FOR ii = 1 TO ll_row
	ls_chk = dw_master.Object.chk[ii]
	
	IF ls_chk = 'Y' THEN
		ll_seqno = dw_master.Object.seqno[ii]
		ls_seqno = string(ll_seqno)
		ls_payid = dw_master.object.payid[ii]
	END IF
	
NEXT

//수납 입력
ls_errmsg = space(1000)
SQLCA.B5REQPAY2DTL_PAYID_AP_CANCEL(ls_payid, ll_seqno, ls_remark,	gs_user_id,	gs_pgm_id[gi_open_win_no], ll_return, ls_errmsg)

										
IF SQLCA.SQLCODE < 0 THEN		//For Programer
	MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
	ROLLBACK;
	RETURN -1
ELSEIF ll_return < 0 THEN		//For User
	MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
	ROLLBACK;	
	RETURN -1
END IF

F_MSG_INFO(3000,THIS.Title,"Cancel Complete!")

THIS.TRIGGER EVENT ue_ok()

//수납반영내역 
dw_detail2.Retrieve(ls_payid, ls_seqno)	



COMMIT;

Return 0

end event

event ue_ok;//해당 서비스에 해당하는 품목 조회
STRING	ls_sales_date,			ls_receiptno,		ls_payid,	ls_where,		ls_remark,		&
			ls_trdt
LONG		ll_row
INTEGER	li_rc
DATE		ld_sales_date

//Input Validation Check
THIS.TRIGGER EVENT ue_inputvalidcheck(li_rc)

IF li_rc <> 0 THEN
	RETURN
END IF

//ld_sales_date     = DATE(dw_cond.object.sales_date[1])
//ls_sales_date     = STRING(dw_cond.object.sales_date[1], 'YYYYMMDD')
ls_remark	      = STRING(dw_cond.object.remark[1], 'YYYYMMDD')
ls_payid				= Trim(dw_cond.object.payid[1])

//IF ISNULL(ls_sales_date)	THEN ls_sales_date = ""
IF ISNULL(ls_remark)			THEN ls_remark	 	 = ""
IF ISNULL(ls_payid)			THEN ls_payid	 	 = ""

//IF ls_sales_date = "" THEN
//	F_MSG_INFO(200, Title, "Sales Date")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("sales Date")
//	RETURN
//END IF

IF ls_remark = "" THEN
	F_MSG_INFO(200, Title, "Reason")
	dw_cond.SetFocus()
	dw_cond.SetColumn("remark")
	RETURN
END IF

SELECT TO_CHAR(REQDT, 'YYYYMMDD') INTO :ls_trdt
FROM   REQCONF
WHERE  CHARGEDT = '1';

ls_where = "" 

IF ls_payid <> "" THEN
	ls_where += " A.PAYID = '" + ls_payid + "' "		
	ls_where += " AND A.TRDT  <= TO_DATE('" + ls_trdt + "', 'YYYYMMDD') "
	ls_where += " AND A.REMARK LIKE 'LG%' "	
END IF	

//IF ls_sales_date <> "" THEN
//	ls_where += " AND A.TRDT = TO_DATE('" + ls_sales_date + "', 'yyyymmdd') "
//END IF

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
ELSEIF ll_row = 0	THEN
//	F_MSG_INFO(1000, Title, "")
//   RETURN
END IF

SetRedraw(FALSE)

dw_master.SetFocus()

dw_cond.Enabled = FALSE
p_ok.TriggerEvent("ue_disable")
p_cancel.TriggerEvent("ue_enable")

SetRedraw(TRUE)
end event

event ue_reset;Constant Int LI_ERROR = -1
Int 		li_rc
STRING	ls_groupid

//dw_detail.AcceptText()
//
//If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
//	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
//		Question!, YesNo!)
//   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
//End If

p_cancel.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_master.Reset()
dw_detail.Reset()
//dw_list.Reset()

dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)

//조회조건 기본 세팅!
dw_cond.Object.sales_date[1]	= idt_shop_closedt
//dw_cond.Object.operator[1]	= gs_user_id
dw_cond.SetFocus()

////PAY_DATE PROTECT
//SELECT GROUP_ID INTO :ls_groupid
//FROM   SYSUSR3T
//WHERE  EMP_ID = :gs_user_id;
//
//IF ls_groupid <> "00000000" THEN
//	dw_cond.Object.sales_date.Protect = 1
//END IF

Return 0

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

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public function integer wfi_get_payid (string as_payid, string as_memberid);String ls_payid, ls_paynm, ls_memberid

ls_payid 		= as_payid

IF ls_payID <> '' THEN
	Select Customernm, memberid  Into :ls_paynm, :ls_memberid  From Customerm
    Where customerid = :ls_payid;
ELSE
	Select CUSTOMERID, Customernm  Into :ls_payid, :ls_paynm  From Customerm
    Where MEMBERID = :as_memberid;
END IF

IF IsNull(ls_paynm) 		then ls_paynm 		= ''
IF IsNull(ls_payid) 		then ls_payid 		= ''
IF IsNull(ls_memberid) 	then ls_memberid 	= ''

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "Pay ID(wfi_get_payid)")
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	Return -1
End If

dw_cond.object.customernm[1] 		= ls_paynm
dw_cond.object.payid[1] 			= ls_payid
//dw_cond.object.memberid[1] 		= ls_memberid

Return 0

end function

public subroutine wf_protect (string ai_gubun);String	ls_np_did,		ls_np_ori_carrier

dw_master.AcceptText()

//CHOOSE CASE ai_gubun
////	CASE "N"
////		dw_master.Object.customerid.Color = RGB(255,255,255)						//글씨색
////		dw_master.Object.customerid.Background.Color = RGB(107, 146, 140)		//필수 배경색
////	CASE "Y"
////		dw_master.Object.customerid.Color = RGB(0,0,0)								//글씨색
////		dw_master.Object.customerid.Background.Color = RGB(255, 255, 255)		//선택 배경색		
//
//END CHOOSE
//


end subroutine

on ubs_w_reg_autopay_cancel.create
int iCurrent
call super::create
this.dw_detail2=create dw_detail2
this.dw_detail=create dw_detail
this.p_cancel=create p_cancel
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.st_horizontal=create st_horizontal
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail2
this.Control[iCurrent+2]=this.dw_detail
this.Control[iCurrent+3]=this.p_cancel
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.p_ok
this.Control[iCurrent+6]=this.dw_master
this.Control[iCurrent+7]=this.st_horizontal
this.Control[iCurrent+8]=this.dw_cond
this.Control[iCurrent+9]=this.p_close
this.Control[iCurrent+10]=this.gb_1
end on

on ubs_w_reg_autopay_cancel.destroy
call super::destroy
destroy(this.dw_detail2)
destroy(this.dw_detail)
destroy(this.p_cancel)
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.st_horizontal)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 수납 취소 화면									  //
// Name       : b5w_reg_mtr_inp_cancel				           //
// Contents   : 수납을 취소할 수 있다.							  //
// Data Window: dw - b5w_dw_reg_inp_cancel_cnd		 	     // 
//							b5w_dw_reg_inp_cancel_mas				  //
// 작성일자   : 2009.04.29                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc,	ls_temp
DATE		ld_sysdate

dw_cond.InsertRow(0)
dw_master.InsertRow(0)

iu_cust_db_app = CREATE u_cust_db_app
idt_shop_closedt 	= f_find_shop_closedt(GS_SHOPID)

dw_cond.Object.sales_date[1]	= idt_shop_closedt

dw_cond.SetFocus()
dw_cond.setColumn("payid")

// Set the Top, Bottom Controls
idrg_Top = dw_master

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

p_ok.TriggerEvent("ue_enable")
p_cancel.TriggerEvent("ue_disable")


end event

event close;call super::close;DESTROY iu_cust_db_app
end event

event resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

//IF newheight < (dw_master.Y +  iu_cust_w_resize.ii_button_space) THEN
//	dw_master.Height = 0
//  
//	p_cancel.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
//	p_reset.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space	
//	p_close.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
//ELSE
//	dw_master.Height = newheight - dw_master.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
// 
//	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
//	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//END IF
//
//IF newwidth < dw_master.X  THEN
//	dw_master.Width = 0
//ELSE
//	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
//END IF

IF newheight < (dw_master.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_master.Height = 0
  
	p_cancel.Y	= dw_master.Y +  iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_master.Y +  iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_master.Y +  iu_cust_w_resize.ii_dw_button_space
ELSE
	dw_master.Height  = newheight - dw_master.Y  - dw_detail2.Height -  iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 	dw_detail2.Y =  dw_master.Height  + 300
  
	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
END IF

IF newwidth < dw_master.X  THEN
	dw_master.Width = 0
ELSE
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
	dw_detail2.Width = newwidth - dw_detail2.X - iu_cust_w_resize.ii_dw_button_space
END IF


// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(TRUE)

end event

type dw_detail2 from u_d_base within ubs_w_reg_autopay_cancel
integer x = 14
integer y = 788
integer width = 3237
integer height = 952
integer taborder = 20
string dataobject = "ubs_dw_reg_autopay_cancel_det1"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event clicked;//This.AcceptText()
//
//If row = 0 then Return
//
//If IsSelected( row ) then
//	SelectRow( row ,FALSE)
//Else
//   SelectRow(0, FALSE )
//	SelectRow( row , TRUE )
//End If
//
//dw_detail.Reset()

//STRING	ls_cancel_yn, ls_pos_no

//ls_cancel_yn = dw_master.Object.cancel_yn[row]
//ls_pos_no	 = dw_master.Object.posno[row]

//IF Isnull(ls_cancel_yn) THEN ls_cancel_yn = "" 

//IF ls_cancel_yn = 'Y' THEN
//	dw_list.Retrieve(ls_pos_no)	
//	p_cancel.TriggerEvent("ue_disable")
//ELSE
//	dw_list.Reset()
////	dw_list.InsertRow(0)
//	p_cancel.TriggerEvent("ue_enable")	
//END IF
end event

event retrieveend;//STRING	ls_cancel_yn, ls_pos_no
//
//This.AcceptText()
//
//IF rowcount <= 0 THEN RETURN -1

//ls_cancel_yn = This.Object.cancel_yn[1]
//ls_pos_no	 = This.Object.posno[1]
//
//IF Isnull(ls_cancel_yn) THEN ls_cancel_yn = "" 

//IF ls_cancel_yn = 'Y' THEN
//	dw_list.Retrieve(ls_pos_no)
//	p_cancel.TriggerEvent("ue_disable")
//ELSE
//	dw_list.Reset()
////	dw_list.InsertRow(0)	
//	p_cancel.TriggerEvent("ue_enable")	
//END IF
//



end event

type dw_detail from datawindow within ubs_w_reg_autopay_cancel
boolean visible = false
integer x = 2811
integer y = 1332
integer width = 411
integer height = 84
integer taborder = 40
string title = "none"
string dataobject = "b5w_dw_reg_inp_cancel_det"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

type p_cancel from u_p_cancel within ubs_w_reg_autopay_cancel
integer x = 73
integer y = 1760
integer height = 92
end type

event clicked;Parent.TriggerEvent('ue_process')
end event

type p_reset from u_p_reset within ubs_w_reg_autopay_cancel
integer x = 389
integer y = 1760
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_reg_autopay_cancel
integer x = 2930
integer y = 56
end type

type dw_master from u_d_base within ubs_w_reg_autopay_cancel
integer x = 14
integer y = 292
integer width = 3237
integer height = 464
integer taborder = 30
string dataobject = "ubs_dw_reg_autopay_cancel_mas"
boolean hscrollbar = false
borderstyle borderstyle = stylebox!
end type

event clicked;string ls_payid, ls_rseqno, ls_chk
integer ii
long  ll_cnt

This.AcceptText()

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

dw_detail.Reset()


ls_payid = dw_master.object.payid[row]
ls_rseqno = string(dw_master.object.seqno[row])

dw_detail2.Retrieve(ls_payid, ls_rseqno)	

//
//ll_cnt = 0
//FOR ii = 1 TO this.rowcount()
//	ls_chk = this.getitemstring(ii, 'chk')
//	IF ls_chk = 'Y' THEN
//		ll_cnt = ll_cnt + 1
//	END IF
//NEXT
//
//IF ll_cnt >= 1 THEN 
//	f_msg_usr_err(9000, Title, "한 건씩 취소 처리하시기 바랍니다.")	
//	this.setitem(ii,'chk','N')
//	this.setredraw(true)
//	return 
//END IF
end event

event retrieveend;STRING	ls_cancel_yn, ls_pos_no

This.AcceptText()

IF rowcount <= 0 THEN RETURN -1

//ls_cancel_yn = This.Object.cancel_yn[1]
//ls_pos_no	 = This.Object.posno[1]
//
//IF Isnull(ls_cancel_yn) THEN ls_cancel_yn = "" 

//IF ls_cancel_yn = 'Y' THEN
//	dw_list.Retrieve(ls_pos_no)
//	p_cancel.TriggerEvent("ue_disable")
//ELSE
//	dw_list.Reset()
////	dw_list.InsertRow(0)	
//	p_cancel.TriggerEvent("ue_enable")	
//END IF
//



end event

type st_horizontal from statictext within ubs_w_reg_autopay_cancel
boolean visible = false
integer x = 18
integer y = 752
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

type dw_cond from u_d_help within ubs_w_reg_autopay_cancel
integer x = 37
integer y = 36
integer width = 2862
integer height = 232
integer taborder = 10
string dataobject = "ubs_dw_reg_autopay_cancel_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;call super::doubleclicked;STRING	ls_empnm

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "payid"
		IF iu_cust_help.ib_data[1] THEN
			is_cus_status 				= iu_cust_help.is_data[3]
			
			IF wfi_get_payid(iu_cust_help.is_data[1], "") = -1 THEN
				RETURN -1	
			END IF
		END IF
		

END CHOOSE

RETURN 0 
end event

event ue_init();call super::ue_init;//Help Window
THIS.idwo_help_col[1] 	= THIS.Object.payid
THIS.is_help_win[1] 		= "SSRT_hlp_customer"
THIS.is_data[1] 			= "CloseWithReturn"

THIS.SetFocus()
THIS.SetRow(1)
THIS.SetColumn('payid')
end event

event itemchanged;call super::itemchanged;STRING	ls_payid,	ls_empnm, 	ls_approvalno,		ls_sysdate,		ls_sales_date
INTEGER	li_rc
LONG		ll_cnt

THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "sales_date"
		ls_sales_date     = STRING(dw_cond.object.sales_date[1], 'YYYYMMDD')
		
		SELECT TO_CHAR(SYSDATE, 'YYYYMM') INTO :ls_sysdate
		FROM   DUAL;
		
		IF Mid(ls_sales_date, 1, 6) <> ls_sysdate THEN
			f_msg_usr_err(9000, Title, "당월 수납분만 취소할 수 있습니다.")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.Object.sales_date[row]	= idt_shop_closedt			
			dw_cond.SetColumn("sales_date")
			RETURN 2			
		END IF		
	
	CASE "payid" 
   	  wfi_get_payid(data, "")
		  
	case 'memberid'
		ls_payid = Trim(dw_cond.object.memberid[1])
		
		If IsNull(ls_payid) Then ls_payid = " "
		li_rc = wfi_get_payid("", ls_payid)

		If li_rc < 0 Then
			dw_cond.object.memberid[1] 	= ""
			dw_cond.object.payid[1] 		= ""
			dw_cond.object.customernm[1]	= ""
			dw_cond.SetColumn("memberid")
			Return 0
		End IF
	CASE 'operator'
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

	CASE 'receiptno'
		ls_payid = dw_cond.object.payid[row]
		
		SELECT COUNT(*) INTO :ll_cnt
		FROM   RECEIPTMST
		WHERE  SEQ_APP = :data;
		
		IF ll_cnt > 0 THEN
			
			SELECT APPROVALNO INTO :is_approvalno
			FROM   RECEIPTMST
			WHERE  SEQ_APP = :data;
			
		END IF
		
END CHOOSE
end event

type p_close from u_p_close within ubs_w_reg_autopay_cancel
integer x = 704
integer y = 1760
boolean originalsize = false
end type

type gb_1 from groupbox within ubs_w_reg_autopay_cancel
integer x = 14
integer y = 8
integer width = 3237
integer height = 268
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

