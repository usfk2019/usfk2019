$PBExportHeader$ubs_w_pop_hotbill_info.srw
$PBExportComments$[jhchoi] 핫빌 금액 안내- 2009.07.28
forward
global type ubs_w_pop_hotbill_info from w_base
end type
type p_reset from u_p_reset within ubs_w_pop_hotbill_info
end type
type p_ok from u_p_ok within ubs_w_pop_hotbill_info
end type
type dw_master from u_d_base within ubs_w_pop_hotbill_info
end type
type dw_cond from u_d_help within ubs_w_pop_hotbill_info
end type
type p_close from u_p_close within ubs_w_pop_hotbill_info
end type
type gb_2 from groupbox within ubs_w_pop_hotbill_info
end type
end forward

global type ubs_w_pop_hotbill_info from w_base
integer width = 2610
integer height = 2020
windowstate windowstate = normal!
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_ok ( )
event type integer ue_reset ( )
p_reset p_reset
p_ok p_ok
dw_master dw_master
dw_cond dw_cond
p_close p_close
gb_2 gb_2
end type
global ubs_w_pop_hotbill_info ubs_w_pop_hotbill_info

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
public subroutine wf_protect (string ai_gubun)
public subroutine of_refreshbars ()
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
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

event ue_reset;CONSTANT	INT LI_ERROR = -1
INT		li_rc
DATE		ld_sysdate

dw_master.Reset()
dw_master.InsertRow(0)

RETURN 0

end event

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

public subroutine of_refreshbars ();
end subroutine

public subroutine of_resizebars ();
end subroutine

public subroutine of_resizepanels ();
end subroutine

public function integer wfi_get_customerid (string as_customerid, string as_memberid);return 0
end function

on ubs_w_pop_hotbill_info.create
int iCurrent
call super::create
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_2=create gb_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_reset
this.Control[iCurrent+2]=this.p_ok
this.Control[iCurrent+3]=this.dw_master
this.Control[iCurrent+4]=this.dw_cond
this.Control[iCurrent+5]=this.p_close
this.Control[iCurrent+6]=this.gb_2
end on

on ubs_w_pop_hotbill_info.destroy
call super::destroy
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_2)
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

STRING	ls_payid
LONG		ll_row
DEC{2} 	ldc_preamt

dw_master.InsertRow(0)

iu_cust_db_app = CREATE u_cust_db_app

// Set the Top, Bottom Controls
idrg_Top = dw_master

//Change the back color so they cannot be seen.
ii_WindowTop = idrg_Top.Y
il_HiddenColor = BackColor

ls_payid = iu_cust_msg.is_data[1]

ll_row = dw_master.Retrieve(ls_payid)

If ll_row = 0 Then
	f_msg_info(1000, title, "")
	Return -1
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, title, "Retrieve()")
	Return -1
End If

//select nvl(tramt,0) into :il_preamt from hotreqdtl where payid = :is_payid and rownum =1;
//2009.07.10 CJH 수정.
SELECT nvl(SUM(tramt),0) INTO :ldc_preamt
FROM	 hotreqdtl
WHERE  payid = :ls_payid
AND    TRCOD IS NULL;

dw_master.object.preamt[1] = ldc_preamt
end event

event close;call super::close;DESTROY iu_cust_db_app
end event

type p_reset from u_p_reset within ubs_w_pop_hotbill_info
boolean visible = false
integer x = 2277
integer y = 2120
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_pop_hotbill_info
boolean visible = false
integer x = 3474
integer y = 56
end type

type dw_master from u_d_base within ubs_w_pop_hotbill_info
integer x = 32
integer y = 32
integer width = 2473
integer height = 1624
integer taborder = 30
string dataobject = "ubs_dw_pop_hotbill_info"
borderstyle borderstyle = stylebox!
end type

type dw_cond from u_d_help within ubs_w_pop_hotbill_info
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

type p_close from u_p_close within ubs_w_pop_hotbill_info
integer x = 14
integer y = 1704
boolean originalsize = false
end type

type gb_2 from groupbox within ubs_w_pop_hotbill_info
integer x = 14
integer y = 8
integer width = 2510
integer height = 1664
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

