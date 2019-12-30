$PBExportHeader$ubs_w_pop_contract_info2.srw
$PBExportComments$[jhchoi] 장비인증 결과 조회- 2009.06.13
forward
global type ubs_w_pop_contract_info2 from w_base
end type
type dw_detail1 from u_d_dberr within ubs_w_pop_contract_info2
end type
type cb_1 from commandbutton within ubs_w_pop_contract_info2
end type
type p_save from u_p_save within ubs_w_pop_contract_info2
end type
type p_reset from u_p_reset within ubs_w_pop_contract_info2
end type
type p_ok from u_p_ok within ubs_w_pop_contract_info2
end type
type dw_master from u_d_base within ubs_w_pop_contract_info2
end type
type st_horizontal from statictext within ubs_w_pop_contract_info2
end type
type dw_cond from u_d_help within ubs_w_pop_contract_info2
end type
type p_close from u_p_close within ubs_w_pop_contract_info2
end type
type gb_2 from groupbox within ubs_w_pop_contract_info2
end type
type gb_4 from groupbox within ubs_w_pop_contract_info2
end type
type dw_1 from datawindow within ubs_w_pop_contract_info2
end type
type gb_3 from groupbox within ubs_w_pop_contract_info2
end type
end forward

global type ubs_w_pop_contract_info2 from w_base
integer width = 3845
integer height = 2840
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_ok ( )
event type integer ue_reset ( )
event ue_save ( )
dw_detail1 dw_detail1
cb_1 cb_1
p_save p_save
p_reset p_reset
p_ok p_ok
dw_master dw_master
st_horizontal st_horizontal
dw_cond dw_cond
p_close p_close
gb_2 gb_2
gb_4 gb_4
dw_1 dw_1
gb_3 gb_3
end type
global ubs_w_pop_contract_info2 ubs_w_pop_contract_info2

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


String is_cus_status, is_hotbillflag, is_worktype[], is_siid,	is_save_check,	is_payid
end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine wf_protect (string ai_gubun)
public subroutine of_resizebars ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
public subroutine of_refreshbars ()
end prototypes

event ue_close;CLOSE(THIS)
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

event ue_reset;CONSTANT	INT LI_ERROR = -1
INT		li_rc
DATE		ld_sysdate

dw_master.Reset()
dw_1.Reset()

dw_master.InsertRow(0)
dw_1.InsertRow(0)

RETURN 0

end event

event ue_save();STRING	ls_check,			ls_hotbill
LONG		ll_contractseq,	ll_row,			ll_req_cnt
INTEGER	ii

dw_master.AcceptText()

ll_row = dw_master.RowCount()

IF ll_row <= 0 THEN RETURN


FOR ii = 1 TO ll_row
	ls_check 		= dw_master.Object.bill_hotbillflag[ii]
	ll_contractseq = dw_master.Object.contractseq[ii]
	ls_hotbill 		= dw_master.Object.contractmst_hotbill_check[ii]
	
	IF ls_check = 'R' THEN
		IF ls_hotbill = 'S' OR ls_hotbill = 'E' OR ls_hotbill = 'H' OR ls_hotbill = 'P'  THEN
			f_msg_usr_err(9000, Title, "핫빌이 진행중이거나 완료된 상태입니다. 신청 할 수 없습니다.")
			ROLLBACK;
			RETURN
		END IF		
		
		UPDATE CONTRACTMST
		SET    BILL_HOTBILLFLAG = 'R'
		WHERE  CONTRACTSEQ = :ll_contractseq;
		
		IF SQLCA.SQLCODE <> 0 THEN
			f_msg_usr_err(9000, Title, "UPDATE ERROR!(CONTRACTMST)")
			ROLLBACK;
			RETURN			
		END IF
		
		INSERT INTO HOTCONTRACT
			( PAYID,			CONTRACTSEQ,		HOTDT,
			  CRT_USER,		CRTDT )
		VALUES
			( :is_payid,	:ll_contractseq,	TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD'),
			  :gs_user_id,	SYSDATE );
			  
		IF SQLCA.SQLCODE <> 0 THEN
			Messagebox('확인', SQLCA.SQLERRTEXT)
			f_msg_usr_err(9000, Title, "UPDATE ERROR!(HOTCONTRACT)")
			ROLLBACK;
			RETURN
		END IF
		
		ll_req_cnt += 1
		
	END IF	
NEXT

IF ll_req_cnt <= 0 THEN
	f_msg_usr_err(9000, Title, "신청된 계약이 없습니다.")
	ROLLBACK;
	RETURN				
END IF

COMMIT;
f_msg_info(3000,This.Title,"HOT BILL 신청")
dw_master.Retrieve(is_payid)


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

on ubs_w_pop_contract_info2.create
int iCurrent
call super::create
this.dw_detail1=create dw_detail1
this.cb_1=create cb_1
this.p_save=create p_save
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.st_horizontal=create st_horizontal
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_2=create gb_2
this.gb_4=create gb_4
this.dw_1=create dw_1
this.gb_3=create gb_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_detail1
this.Control[iCurrent+2]=this.cb_1
this.Control[iCurrent+3]=this.p_save
this.Control[iCurrent+4]=this.p_reset
this.Control[iCurrent+5]=this.p_ok
this.Control[iCurrent+6]=this.dw_master
this.Control[iCurrent+7]=this.st_horizontal
this.Control[iCurrent+8]=this.dw_cond
this.Control[iCurrent+9]=this.p_close
this.Control[iCurrent+10]=this.gb_2
this.Control[iCurrent+11]=this.gb_4
this.Control[iCurrent+12]=this.dw_1
this.Control[iCurrent+13]=this.gb_3
end on

on ubs_w_pop_contract_info2.destroy
call super::destroy
destroy(this.dw_detail1)
destroy(this.cb_1)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.st_horizontal)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_2)
destroy(this.gb_4)
destroy(this.dw_1)
destroy(this.gb_3)
end on

event open;//=========================================================//
// Desciption : 장비인증 결과 조회 화면					     //
// Name       : ubs_w_reg_validresult		                 //
// Contents   : 장비인증 결과를 확인한다.						  //
// 작성일자   : 2009.06.14                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_payid
long 		ll_reqno, ll_row

dw_master.InsertRow(0)

is_save_check = 'N'

iu_cust_db_app = CREATE u_cust_db_app
iu_cust_msg = Create u_cust_a_msg
iu_cust_w_resize = Create u_cust_w_resize

iu_cust_msg = Message.PowerObjectParm

// Set the Top, Bottom Controls
idrg_Top = dw_master

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
st_horizontal.BackColor = BackColor
il_HiddenColor = BackColor

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

ls_payid = iu_cust_msg.is_data[2]

is_payid = ls_payid

dw_master.Retrieve(is_payid)

select max(reqno) into :ll_reqno
from svc_req_mst
where req_code = 'HOTBIL'
  and customerid = :is_payid;


ll_row = dw_detail1.retrieve(ll_reqno, is_payid)
if ll_row > 0 then
	dw_detail1.visible = true
else
	dw_detail1.visible = false
end if


Int li_i
String ls_title





end event

event resize;////Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//LONG		ll_5,		ll_w_2,		ll_grsize,		ll_dwsize,		ll_wgrsize,		ll_w
//
//ll_grsize  = 4    //그룹박스간 사이 간격!
//ll_dwsize  = 64   //그룹박스와 dw사이 간격!
//ll_wgrsize = 30	//좌우 그룹박스 간 간격!
//
//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_detail1.Y + iu_cust_w_resize.ii_button_space) Then
////	dw_detail.Height = 0
////	gb_1.Height = 0
//  
//	p_close.Y	= dw_detail1.Y + iu_cust_w_resize.ii_dw_button_space	
//	p_save.Y		= dw_detail1.Y + iu_cust_w_resize.ii_dw_button_space
//	cb_1.Y		= dw_detail1.Y + iu_cust_w_resize.ii_dw_button_space	
//Else
//	
//	ll_5 					= round((newheight - dw_detail1.Y - dw_detail1.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space), 1)
//	
//	gb_3.Height			= gb_3.Height + ll_5
//	dw_1.Height 		= dw_1.Height + ll_5
//	
//	gb_4.Height			= gb_4.Height + ll_5 + ll_wgrsize
//	dw_detail1.Height = dw_detail1.Height +ll_5 + ll_wgrsize
//	
//	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
//	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
//	cb_1.Y		= newheight - iu_cust_w_resize.ii_button_space_1	
//	
//End If
//
//If newwidth < dw_master.X  Then
//	dw_master.Width = 0
//	gb_2.Width      = 0
//	
//	dw_1.Width = 0
//	gb_3.Width = 0
//	
//	gb_4.Height			= 0
//	dw_detail1.Height = 0
//
//Else
//	
//	ll_w = newwidth - gb_3.x - gb_3.width - iu_cust_w_resize.ii_dw_button_space
//	
//	gb_3.Width			= gb_3.Width + ll_w
//	dw_1.Width        = dw_1.Width + ll_w
//
//	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space -20
//	gb_2.Width 		 = newwidth - gb_2.X - iu_cust_w_resize.ii_dw_button_space	
//	
//	gb_4.Width 		 = gb_3.Width + ll_w
//	dw_detail1.Width = dw_1.Width + ll_w
//	
//End If
//
//// Call the resize functions
////of_ResizeBars()
////of_ResizePanels()
//
//SetRedraw(True)
//
//
//////Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
////LONG		ll_5,		ll_w_2,		ll_grsize,		ll_dwsize,		ll_wgrsize,		ll_w
////
////ll_grsize  = 4    //그룹박스간 사이 간격!
////ll_dwsize  = 64   //그룹박스와 dw사이 간격!
////ll_wgrsize = 30	//좌우 그룹박스 간 간격!
////
////If sizetype = 1 Then Return
////
////SetRedraw(False)
////
////If newheight < (dw_1.Y + iu_cust_w_resize.ii_button_space) Then
//////	dw_detail.Height = 0
//////	gb_1.Height = 0
////  
////	p_close.Y	= dw_1.Y + iu_cust_w_resize.ii_dw_button_space	
////	p_save.Y		= dw_1.Y + iu_cust_w_resize.ii_dw_button_space
////	cb_1.Y		= dw_1.Y + iu_cust_w_resize.ii_dw_button_space	
////Else
////	
////	ll_5 					= round((newheight - dw_1.Y - dw_1.Height - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space), 1)
////	
////	gb_3.Height			= gb_3.Height + ll_5
////	dw_1.Height 		= dw_1.Height + ll_5
////	
////	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
////	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
////	cb_1.Y		= newheight - iu_cust_w_resize.ii_button_space_1	
////	
////End If
////
////If newwidth < dw_master.X  Then
////	dw_master.Width = 0
////	gb_2.Width      = 0
////	
////	dw_1.Width = 0
////	gb_3.Width = 0
////
////Else
////	ll_w = newwidth - gb_3.x - gb_3.width - iu_cust_w_resize.ii_dw_button_space
////	
////	gb_3.Width			= gb_3.Width + ll_w
////	dw_1.Width        = dw_1.Width + ll_w
////
////	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space -20
////	gb_2.Width 		 = newwidth - gb_2.X - iu_cust_w_resize.ii_dw_button_space		
////
////End If
////
////// Call the resize functions
////of_ResizeBars()
//////of_ResizePanels()
////
////SetRedraw(True)
end event

event close;Destroy iu_cust_msg
Destroy iu_cust_w_resize
end event

type dw_detail1 from u_d_dberr within ubs_w_pop_contract_info2
integer x = 23
integer y = 1500
integer width = 3735
integer height = 1020
integer taborder = 20
boolean bringtotop = true
string dataobject = "ubs_dw_reg_hotbill_cont_agent"
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

type cb_1 from commandbutton within ubs_w_pop_contract_info2
integer x = 969
integer y = 2572
integer width = 283
integer height = 96
integer taborder = 50
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "CLEAR"
end type

event clicked;STRING	ls_check,			ls_hotbill
LONG		ll_contractseq,	ll_row,			ll_req_cnt
INTEGER	ii

dw_master.AcceptText()

ll_row = dw_master.RowCount()

IF ll_row <= 0 THEN RETURN

FOR ii = 1 TO ll_row
	ls_check 		= dw_master.Object.bill_hotbillflag[ii]
	ll_contractseq = dw_master.Object.contractseq[ii]
	ls_hotbill 		= dw_master.Object.contractmst_hotbill_check[ii]
	
	IF IsNull(ls_check) THEN ls_check = ""
	IF IsNull(ls_hotbill) THEN ls_hotbill = ""		
	
	IF ls_hotbill = 'S' OR ls_hotbill = 'E' OR ls_hotbill = 'H' OR ls_hotbill = 'P' THEN
		//
	ELSE
		IF ls_check = 'R' THEN
			UPDATE CONTRACTMST
			SET    BILL_HOTBILLFLAG = NULL
			WHERE  CONTRACTSEQ = :ll_contractseq;
		
			IF SQLCA.SQLCODE <> 0 THEN
				f_msg_usr_err(9000, 'Hot Bill', "UPDATE ERROR!(CONTRACTMST)")
				ROLLBACK;
				RETURN			
			END IF
			
			DELETE FROM HOTCONTRACT
			WHERE  PAYID = :is_payid
			AND    CONTRACTSEQ = :ll_contractseq
			AND    HOTDT = TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD');

			IF SQLCA.SQLCODE <> 0 THEN
				f_msg_usr_err(9000, 'Hot Bill', "DELETE ERROR!(HOTCONTRACT)")
				ROLLBACK;
				RETURN			
			END IF			
		END IF
	END IF	
NEXT

COMMIT;
f_msg_info(3000, 'Hot Bill',"Clear")
dw_master.Retrieve(is_payid)


end event

type p_save from u_p_save within ubs_w_pop_contract_info2
integer x = 37
integer y = 2572
boolean originalsize = false
end type

type p_reset from u_p_reset within ubs_w_pop_contract_info2
boolean visible = false
integer x = 2277
integer y = 2120
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_pop_contract_info2
boolean visible = false
integer x = 3474
integer y = 56
end type

type dw_master from u_d_base within ubs_w_pop_contract_info2
integer x = 32
integer y = 32
integer width = 3735
integer height = 620
integer taborder = 30
string dataobject = "ubs_dw_pop_contract_info2"
borderstyle borderstyle = stylebox!
end type

event clicked;LONG	ll_contractseq

If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

ll_contractseq = THIS.Object.contractseq[row]

dw_1.Retrieve(ll_contractseq)
end event

event retrieveend;LONG	ll_contractseq

IF rowcount <= 0 THEN RETURN -1

ll_contractseq = THIS.Object.contractseq[1]

dw_1.Retrieve(ll_contractseq)
//dw_2.Retrieve(ll_contractseq)

SelectRow( 1 ,FALSE)

end event

type st_horizontal from statictext within ubs_w_pop_contract_info2
integer x = 18
integer y = 668
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

type dw_cond from u_d_help within ubs_w_pop_contract_info2
boolean visible = false
integer x = 37
integer y = 36
integer width = 105
integer height = 168
integer taborder = 10
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;//THIS.AcceptText()
//
//CHOOSE CASE dwo.name
//	CASE "customerid"
//		IF iu_cust_help.ib_data[1] THEN
//			is_cus_status 				= iu_cust_help.is_data[3]
//			
//			IF wfi_get_customerid(iu_cust_help.is_data[1], "") = -1 THEN
//				RETURN -1	
//			END IF
//					
//		END IF
//END CHOOSE
//
//RETURN 0 
end event

event ue_init();call super::ue_init;////Help Window
//THIS.idwo_help_col[1] 	= THIS.Object.customerid
//THIS.is_help_win[1] 		= "SSRT_hlp_customer"
//THIS.is_data[1] 			= "CloseWithReturn"
//
//THIS.SetFocus()
//THIS.SetRow(1)
//THIS.SetColumn('customerid')
end event

event itemchanged;//THIS.AcceptText()
//
//CHOOSE CASE dwo.name
//	CASE "customerid" 
//   	  wfi_get_customerid(data, "")
//END CHOOSE
end event

event constructor;//
end event

event destructor;//
end event

event sqlpreview;//
end event

type p_close from u_p_close within ubs_w_pop_contract_info2
integer x = 352
integer y = 2572
boolean originalsize = false
end type

type gb_2 from groupbox within ubs_w_pop_contract_info2
integer x = 14
integer y = 8
integer width = 3771
integer height = 660
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

type gb_4 from groupbox within ubs_w_pop_contract_info2
integer x = 14
integer y = 1432
integer width = 3771
integer height = 1108
integer taborder = 30
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 255
long backcolor = 29478337
string text = "개통처 해지정산내역"
end type

type dw_1 from datawindow within ubs_w_pop_contract_info2
integer x = 32
integer y = 752
integer width = 3735
integer height = 640
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_contractdet_info2"
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type gb_3 from groupbox within ubs_w_pop_contract_info2
integer x = 14
integer y = 684
integer width = 3771
integer height = 736
integer taborder = 40
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Item List"
end type

