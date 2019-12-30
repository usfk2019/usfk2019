$PBExportHeader$ubs_w_pop_priceplan_item.srw
$PBExportComments$[jhchoi] 모바일 신규 신청 계약서 출력 팝업 - 2009.03.19
forward
global type ubs_w_pop_priceplan_item from w_a_hlp
end type
end forward

global type ubs_w_pop_priceplan_item from w_a_hlp
integer width = 2990
integer height = 1360
string title = ""
event ue_print ( )
event ue_psetup ( )
end type
global ubs_w_pop_priceplan_item ubs_w_pop_priceplan_item

type variables
String is_print_check
end variables

on ubs_w_pop_priceplan_item.create
call super::create
end on

on ubs_w_pop_priceplan_item.destroy
call super::destroy
end on

event open;call super::open;datawindow ldw_data[]
LONG		  ll_row
STRING	  ls_contractseq,	ls_priceplan	

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

ldw_data[1]		= iu_cust_help.idw_data[1]
ll_row 			= iu_cust_help.il_data[1]
ls_priceplan 	= iu_cust_help.is_data[1]
ls_contractseq = iu_cust_help.is_data[2]


This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.InsertRow(0)

dw_hlp.Retrieve(ls_priceplan, LONG(ls_contractseq))










end event

event ue_close();Destroy iu_cust_help

CLOSE(THIS)
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_priceplan_item
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_priceplan_item
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_priceplan_item
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_priceplan_item
integer x = 23
integer y = 1144
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_priceplan_item
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_priceplan_item
integer x = 23
integer y = 20
integer width = 2930
integer height = 1088
string dataobject = "b1dw_reg_chg_priceplan_old"
end type

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;Long i
String ls_mainitem_yn

For i = 1 To rowcount 
	dw_hlp.object.chk[i] = "Y" 
	dw_hlp.SetItemStatus(i, 0 , Primary!,NotModified!)
Next

end event

event dw_hlp::sqlpreview;//
end event

