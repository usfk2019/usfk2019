$PBExportHeader$ubs_w_pop_mobilecontract.srw
$PBExportComments$[jhchoi] 모바일 신규 신청 계약서 출력 팝업 - 2009.03.19
forward
global type ubs_w_pop_mobilecontract from w_a_hlp
end type
type p_2 from u_p_print within ubs_w_pop_mobilecontract
end type
type p_3 from u_p_psetup within ubs_w_pop_mobilecontract
end type
end forward

global type ubs_w_pop_mobilecontract from w_a_hlp
integer width = 3552
string title = ""
event ue_print ( )
event ue_psetup ( )
p_2 p_2
p_3 p_3
end type
global ubs_w_pop_mobilecontract ubs_w_pop_mobilecontract

type variables
String is_print_check
end variables

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

on ubs_w_pop_mobilecontract.create
int iCurrent
call super::create
this.p_2=create p_2
this.p_3=create p_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_2
this.Control[iCurrent+2]=this.p_3
end on

on ubs_w_pop_mobilecontract.destroy
call super::destroy
destroy(this.p_2)
destroy(this.p_3)
end on

event open;call super::open;//=========================================================//
// Desciption : 모바일 신규 신청시 계약서를 출력하는 POP UP//
// Name       : ubs_w_pop_mobilecontract	                 //
// Contents   : 모바일 신규 신청시 계약서를 출력한다.		  //
// Data Window: dw - ubs_dw_pop_mobilecontract_mas         // 
// 작성일자   : 2009.03.17                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

datawindow ldw_data[]
LONG		  ll_row


is_print_check = 'N'    //print check 값 기본 세팅!

//==========================================================//
//ubs_w_shop_reg_mobileorder print 버튼 클릭시 넘어오는 값  //
//iu_cust_msg = Create u_cust_a_msg								   //
//iu_cust_msg.is_pgm_name = "Mobile Contract Print"			//
////iu_cust_msg.is_grp_name = "서비스개통신청"					//
//iu_cust_msg.is_data[1] = "CloseWithReturn"						//
//iu_cust_msg.il_data[1] = 1  		//현재 row					//
//iu_cust_msg.idw_data[1] = dw_master								//
//iu_cust_msg.idw_data[2] = dw_detail								//
//==========================================================//

ldw_data[1] = iu_cust_help.idw_data[1]
ldw_data[2] = iu_cust_help.idw_data[2]
ll_row 		= iu_cust_help.il_data[1]

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.InsertRow(0)

dw_hlp.Object.customerid[1]		 	= ldw_data[1].Object.customerid[ll_row]
dw_hlp.Object.basecod[1] 				= ldw_data[1].Object.basecod[ll_row]
dw_hlp.Object.firstname[1] 		 	= ldw_data[1].Object.firstname[ll_row]
dw_hlp.Object.lastname[1]  		 	= ldw_data[1].Object.lastname[ll_row]
dw_hlp.Object.buildingno[1]		 	= ldw_data[1].Object.buildingno[ll_row]
dw_hlp.Object.roomno[1]    		 	= ldw_data[1].Object.roomno[ll_row]
dw_hlp.Object.derosdt[1]   		 	= ldw_data[1].Object.derosdt[ll_row]
dw_hlp.Object.unit[1]      			= ldw_data[1].Object.unit[ll_row]
dw_hlp.Object.homephone[1] 			= ldw_data[1].Object.homephone[ll_row]
dw_hlp.Object.phone_type[1]  			= ldw_data[1].Object.phone_type[ll_row]
dw_hlp.Object.lease_period_from[1]  = ldw_data[1].Object.lease_period_from[ll_row]
dw_hlp.Object.lease_period[1]       = ldw_data[1].Object.lease_period[ll_row]
dw_hlp.Object.contno[1]         		= ldw_data[1].Object.contno[ll_row]
dw_hlp.Object.admst_contno[1]       = ldw_data[1].Object.admst_contno[ll_row]
dw_hlp.Object.serialno[1]   		   = ldw_data[1].Object.serialno[ll_row]
dw_hlp.Object.phone_model[1]   	   = ldw_data[1].Object.phone_model[ll_row]
dw_hlp.Object.validkey[1] 		  	   = ldw_data[1].Object.validkey[ll_row]
dw_hlp.Object.lease_fee[1] 		  	= ldw_data[2].Object.lease[ll_row]
dw_hlp.Object.activation_fee[1] 		= ldw_data[2].Object.activation[ll_row]
dw_hlp.Object.deposit_fee[1] 		  	= ldw_data[2].Object.deposit[ll_row]










end event

event ue_close();iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_print_check    //프린트 했는지 확인 후 값 넘김

CLOSE(THIS)
end event

event close;call super::close;iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_print_check    //프린트 했는지 확인 후 값 넘김
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_mobilecontract
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_mobilecontract
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_mobilecontract
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_mobilecontract
integer x = 343
integer y = 1656
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_mobilecontract
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_mobilecontract
integer x = 23
integer y = 20
integer width = 3493
integer height = 1584
string dataobject = "ubs_dw_pop_mobilecontract_mas"
end type

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::sqlpreview;//
end event

type p_2 from u_p_print within ubs_w_pop_mobilecontract
integer x = 23
integer y = 1656
boolean bringtotop = true
boolean originalsize = false
end type

type p_3 from u_p_psetup within ubs_w_pop_mobilecontract
integer x = 3232
integer y = 1656
boolean bringtotop = true
boolean originalsize = false
end type

