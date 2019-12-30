$PBExportHeader$ubs_w_pop_validresult.srw
$PBExportComments$[jhchoi] 장비인증 결과 조회 - 2009.06.09
forward
global type ubs_w_pop_validresult from w_a_hlp
end type
type st_1 from statictext within ubs_w_pop_validresult
end type
type dw_1 from datawindow within ubs_w_pop_validresult
end type
type dw_2 from datawindow within ubs_w_pop_validresult
end type
type dw_3 from datawindow within ubs_w_pop_validresult
end type
type st_2 from statictext within ubs_w_pop_validresult
end type
type st_3 from statictext within ubs_w_pop_validresult
end type
type st_4 from statictext within ubs_w_pop_validresult
end type
type st_horizontal from statictext within ubs_w_pop_validresult
end type
type gb_1 from groupbox within ubs_w_pop_validresult
end type
type gb_2 from groupbox within ubs_w_pop_validresult
end type
type gb_3 from groupbox within ubs_w_pop_validresult
end type
type gb_4 from groupbox within ubs_w_pop_validresult
end type
end forward

global type ubs_w_pop_validresult from w_a_hlp
integer width = 3552
integer height = 2584
string title = ""
event ue_print ( )
event ue_psetup ( )
st_1 st_1
dw_1 dw_1
dw_2 dw_2
dw_3 dw_3
st_2 st_2
st_3 st_3
st_4 st_4
st_horizontal st_horizontal
gb_1 gb_1
gb_2 gb_2
gb_3 gb_3
gb_4 gb_4
end type
global ubs_w_pop_validresult ubs_w_pop_validresult

type variables
String is_print_check


//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Bottom							//Reference to the Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides

//NVO For Common Processing
u_cust_db_app iu_cust_db_app
end variables

forward prototypes
public subroutine of_refreshbars ()
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
end prototypes

event ue_print();STRING			ls_page_cnt,	 ls_page
str_print_ref	lstr_print_ref

IF dw_hlp.RowCount() <= 0 THEN RETURN


dw_hlp.Object.DataWindow.Print.Page.Range = ""

ls_page_cnt = dw_hlp.DESCRIBE("Evaluate('pagecount()',1)")

lstr_print_ref.s_page_cnt = ls_page_cnt
lstr_print_ref.i_ret		  = -1
//프린터 페이지 SETUP 팝업 호출
OpenWithParm(w_print_page_setup, lstr_print_ref)

lstr_print_ref = Message.PowerObjectParm

IF NOT isnull( lstr_print_ref ) AND lstr_print_ref.i_ret = 1 THEN
	dw_hlp.object.datawindow.print.copies = String(lstr_print_ref.i_copies_n )
	dw_hlp.object.datawindow.print.page.range = lstr_print_ref.s_page_range

	dw_hlp.print()
	
	is_print_check = 'Y'
	
END IF

end event

event ue_psetup();PrintSetup()
end event

public subroutine of_refreshbars ();// Refresh the size bars

// Force appropriate order
st_horizontal.SetPosition(ToTop!)

// Make sure the Width is not lost
st_horizontal.Height = cii_BarThickness

end subroutine

public subroutine of_resizebars ();//Resize Bars according to Bars themselves, WindowBorder, and BarThickness.

If st_horizontal.Y < ii_WindowTop + 150 Then
	st_horizontal.Y = ii_WindowTop + 150
End If

If st_horizontal.Y > WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150 Then
	st_horizontal.Y = WorkSpaceHeight() - iu_cust_w_resize.ii_button_space - cii_BarThickness - 150
End If

st_horizontal.Move(idrg_Top.X, st_horizontal.Y)
st_horizontal.Resize(idrg_Top.Width, cii_Barthickness)

of_RefreshBars()

end subroutine

public subroutine of_resizepanels ();// Resize the panels according to the Vertical Line, Horizontal Line,
// BarThickness, and WindowBorder.
Integer	li_index

// Validate the controls.
If Not IsValid(idrg_Top) Or Not IsValid(idrg_Bottom) Then Return

// Top processing
idrg_Top.Move(cii_WindowBorder, ii_WindowTop)
idrg_Top.Resize(idrg_Top.Width, st_horizontal.Y - idrg_Top.Y)

// Bottom Procesing
idrg_Bottom.Move(cii_WindowBorder, st_horizontal.Y + cii_BarThickness)
idrg_Bottom.Resize(idrg_Top.Width, WorkspaceHeight() - st_horizontal.Y - cii_BarThickness - iu_cust_w_resize.ii_button_space)

end subroutine

on ubs_w_pop_validresult.create
int iCurrent
call super::create
this.st_1=create st_1
this.dw_1=create dw_1
this.dw_2=create dw_2
this.dw_3=create dw_3
this.st_2=create st_2
this.st_3=create st_3
this.st_4=create st_4
this.st_horizontal=create st_horizontal
this.gb_1=create gb_1
this.gb_2=create gb_2
this.gb_3=create gb_3
this.gb_4=create gb_4
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.dw_1
this.Control[iCurrent+3]=this.dw_2
this.Control[iCurrent+4]=this.dw_3
this.Control[iCurrent+5]=this.st_2
this.Control[iCurrent+6]=this.st_3
this.Control[iCurrent+7]=this.st_4
this.Control[iCurrent+8]=this.st_horizontal
this.Control[iCurrent+9]=this.gb_1
this.Control[iCurrent+10]=this.gb_2
this.Control[iCurrent+11]=this.gb_3
this.Control[iCurrent+12]=this.gb_4
end on

on ubs_w_pop_validresult.destroy
call super::destroy
destroy(this.st_1)
destroy(this.dw_1)
destroy(this.dw_2)
destroy(this.dw_3)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.st_4)
destroy(this.st_horizontal)
destroy(this.gb_1)
destroy(this.gb_2)
destroy(this.gb_3)
destroy(this.gb_4)
end on

event open;call super::open;//=========================================================//
// Desciption : 인증내역 조회 							  POP UP//
// Name       : ubs_w_pop_validresult		                 //
// Contents   : 인증내역을 조회한다.							  //
// Data Window: dw - ubs_w_pop_validresult 			        // 
// 작성일자   : 2009.06.09                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

LONG		  ll_row,			ll_return
STRING 	  ls_data[],		ls_siid,			ls_contractseq
STRING	  ls_oldsql_1,		ls_oldsql_2,	ls_oldsql_3

//iu_cust_msg 				= CREATE u_cust_a_msg
//iu_cust_msg.is_pgm_name = "Schedule"
//iu_cust_msg.is_data[1] = ls_worktype
//iu_cust_msg.is_data[2] = ls_orderno

//==========================================================//
//iu_cust_msg = Create u_cust_a_msg								   //
//iu_cust_msg.is_pgm_name = "Mobile Contract Print"			//
//iu_cust_msg.is_grp_name = "서비스개통신청"						//
//iu_cust_msg.is_data[1] = "CloseWithReturn"						//
//iu_cust_msg.il_data[1] = 1  		//현재 row					//
//iu_cust_msg.idw_data[1] = dw_master								//
//iu_cust_msg.idw_data[2] = dw_detail								//
//==========================================================//

ls_data[1] = iu_cust_help.is_data[1]				//work_type
ls_data[2] = iu_cust_help.is_data[2]				//orderno 또는 Troubleno

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.InsertRow(0)

//SIID 조회
IF ls_data[1] = '100' THEN 		//신규!
	SELECT SIID INTO :ls_siid
	FROM   SIID
	WHERE  ORDERNO = :ls_data[2];
ELSE
	
	SELECT TO_CHAR(CONTRACTSEQ)	INTO :ls_contractseq
	FROM   CUSTOMER_TROUBLE
	WHERE  TROUBLENO = :ls_data[2];
	
	SELECT SIID INTO :ls_siid
	FROM   SIID
	WHERE  CONTRACTSEQ = :ls_contractseq;	
	
END IF

//일단 데이터 윈도우 변경, 조회
IF ls_data[1] = '100' THEN 		//신규!
	ll_return = dw_hlp.Retrieve(Long(ls_data[2]))
ELSE
	dw_hlp.DataObject = 'ubs_dw_prc_validresult_mas2'
	dw_hlp.SetTransObject(SQLCA)
	
	ll_return = dw_hlp.Retrieve(Long(ls_data[2]))	
	
END IF

IF ll_return < 0 THEN
	MessageBox("확인", "조회할 데이터가 없습니다.")
	return -1
END IF

//dw_1 조회
//"from   buuser.bc_auth@boss_db " +&
ls_oldsql_1 = "select timestamp, action, status, effectdate, macaddress, flag, failcause " +&
				  "from   bc_auth " +&
				  "where   subsno = '" + ls_siid + "' "
				  
dw_1.SetSQLSelect(ls_oldsql_1)
dw_1.Retrieve()

//dw_2 조회
//"from   buuser.bc_reg_ssw@boss_db " +&
ls_oldsql_2 = "select timestamp, action, status, effectdate, macaddress, flag, failcause " +&
				  "from   bc_reg_ssw" +&
				  "where   subsno = '" + ls_siid + "' "
				  
dw_2.SetSQLSelect(ls_oldsql_2)
dw_2.Retrieve()

//dw_3 조회
//"from   buuser.bc_config_voip@boss_db " +&
ls_oldsql_3 = "select updatetime, subsstatus, dn, prov_flag, prov_failcause " +&
				  "from   bc_config_voip" +&
				  "where   subsno = '" + ls_siid + "' "
				  
dw_3.SetSQLSelect(ls_oldsql_3)
dw_3.Retrieve()

end event

event ue_close();iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_print_check    //프린트 했는지 확인 후 값 넘김

CLOSE(THIS)
end event

event close;call super::close;iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_print_check    //프린트 했는지 확인 후 값 넘김
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_validresult
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_validresult
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_validresult
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_validresult
integer x = 27
integer y = 2356
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_validresult
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_validresult
integer x = 50
integer y = 44
integer width = 3442
integer height = 476
string dataobject = "ubs_dw_prc_validresult_mas"
end type

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::sqlpreview;//
end event

event dw_hlp::constructor;call super::constructor;INSERTROW(0)
end event

type st_1 from statictext within ubs_w_pop_validresult
integer x = 50
integer y = 556
integer width = 859
integer height = 64
boolean bringtotop = true
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Internet Validation Result"
boolean focusrectangle = false
end type

type dw_1 from datawindow within ubs_w_pop_validresult
integer x = 46
integer y = 644
integer width = 3447
integer height = 312
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_prc_validresult_dw1"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type dw_2 from datawindow within ubs_w_pop_validresult
integer x = 46
integer y = 1100
integer width = 3447
integer height = 312
integer taborder = 50
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_prc_validresult_dw2"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type dw_3 from datawindow within ubs_w_pop_validresult
integer x = 46
integer y = 1564
integer width = 3447
integer height = 648
integer taborder = 60
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_prc_validresult_dw3"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
INSERTROW(0)
end event

type st_2 from statictext within ubs_w_pop_validresult
integer x = 50
integer y = 1008
integer width = 745
integer height = 64
boolean bringtotop = true
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "SSW Validation Result"
boolean focusrectangle = false
end type

type st_3 from statictext within ubs_w_pop_validresult
integer x = 50
integer y = 1464
integer width = 859
integer height = 64
boolean bringtotop = true
integer textsize = -11
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Voip Validation Result"
boolean focusrectangle = false
end type

type st_4 from statictext within ubs_w_pop_validresult
integer x = 41
integer y = 2252
integer width = 2034
integer height = 72
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 65535
string text = "*[성공여부] 결과참조 : 1-성공, 2-DB에러(Voip), 7-단말인증실패."
boolean focusrectangle = false
end type

type st_horizontal from statictext within ubs_w_pop_validresult
boolean visible = false
integer x = 37
integer y = 540
integer width = 754
integer height = 36
boolean bringtotop = true
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long backcolor = 16776960
boolean focusrectangle = false
end type

type gb_1 from groupbox within ubs_w_pop_validresult
integer x = 27
integer y = 20
integer width = 3488
integer height = 520
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

type gb_2 from groupbox within ubs_w_pop_validresult
integer x = 27
integer y = 620
integer width = 3488
integer height = 360
integer taborder = 30
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

type gb_3 from groupbox within ubs_w_pop_validresult
integer x = 27
integer y = 1540
integer width = 3488
integer height = 692
integer taborder = 40
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

type gb_4 from groupbox within ubs_w_pop_validresult
integer x = 27
integer y = 1076
integer width = 3488
integer height = 360
integer taborder = 50
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

