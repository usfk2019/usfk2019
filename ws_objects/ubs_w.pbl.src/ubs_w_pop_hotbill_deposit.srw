$PBExportHeader$ubs_w_pop_hotbill_deposit.srw
$PBExportComments$[jhchoi] 핫빌시 디파짓 확인 팝업 - 2009.07.06
forward
global type ubs_w_pop_hotbill_deposit from w_a_hlp
end type
end forward

global type ubs_w_pop_hotbill_deposit from w_a_hlp
integer width = 4297
string title = ""
event ue_print ( )
event ue_psetup ( )
end type
global ubs_w_pop_hotbill_deposit ubs_w_pop_hotbill_deposit

type variables
String is_print_check
end variables

event ue_psetup();PrintSetup()
end event

on ubs_w_pop_hotbill_deposit.create
call super::create
end on

on ubs_w_pop_hotbill_deposit.destroy
call super::destroy
end on

event open;call super::open;//=========================================================//
// Desciption : 핫빌시 디파짓을 확인하는 팝업				  //
// Name       : ubs_w_pop_hotbill_deposit	                 //
// Contents   : 핫빌시 디파짓을 확인한다.						  //
// Data Window: dw - ubs_dw_pop_hotbill_deposit		        // 
// 작성일자   : 2009.07.06                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//
STRING	ls_payid
LONG		ll_row

//==========================================================//
//ubs_w_shop_reg_mobileorder print 버튼 클릭시 넘어오는 값  //
//iu_cust_msg = Create u_cust_a_msg								   //
//iu_cust_msg.is_pgm_name = "Mobile Contract Print"			//
////iu_cust_msg.is_grp_name = "서비스개통신청"					//
//iu_cust_msg.is_data[1] = "CloseWithReturn"						//
//iu_cust_msg.il_data[1] = 1  		//현재 row					//
//iu_cust_msg.idw_data[1] = dw_master								//
//iu_cust_msg.is_data[2] = ls_payid									//
//==========================================================//

ls_payid = iu_cust_help.is_data[2]

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.Retrieve(ls_payid)

dw_hlp.SetFocus()
end event

event ue_close();iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_print_check    //프린트 했는지 확인 후 값 넘김

CLOSE(THIS)
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_hotbill_deposit
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_hotbill_deposit
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_hotbill_deposit
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_hotbill_deposit
integer x = 27
integer y = 1656
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_hotbill_deposit
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_hotbill_deposit
integer x = 27
integer y = 20
integer width = 4233
integer height = 1584
string dataobject = "ubs_dw_pop_hotbill_deposit"
end type

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::sqlpreview;//
end event

