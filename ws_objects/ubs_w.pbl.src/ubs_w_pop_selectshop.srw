$PBExportHeader$ubs_w_pop_selectshop.srw
$PBExportComments$[jhchoi] 인증장비 이동 샵 선택 팝업 - 2009.04.13
forward
global type ubs_w_pop_selectshop from w_a_hlp
end type
type p_save from u_p_ok within ubs_w_pop_selectshop
end type
end forward

global type ubs_w_pop_selectshop from w_a_hlp
integer width = 942
integer height = 888
string title = ""
event ue_print ( )
event ue_psetup ( )
p_save p_save
end type
global ubs_w_pop_selectshop ubs_w_pop_selectshop

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

on ubs_w_pop_selectshop.create
int iCurrent
call super::create
this.p_save=create p_save
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_save
end on

on ubs_w_pop_selectshop.destroy
call super::destroy
destroy(this.p_save)
end on

event open;call super::open;//=========================================================//
// Desciption : 인증장비 이동시 샵을 선택할 수 있는 POP UP //
// Name       : ubs_w_pop_selectshop		                 //
// Contents   : 인증장비 이동시 샵을 선택한다				  //
// Data Window: dw - ubs_dw_pop_selectshop_mas   		     // 
// 작성일자   : 2009.04.14                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

LONG		  ll_row

//==========================================================//
//ubs_w_reg_equipmove transfer 버튼 클릭시 넘어오는 값  		//
//iu_cust_msg = Create u_cust_a_msg								   //
//iu_cust_msg.is_pgm_name = "Select Shop"							//
//iu_cust_msg.is_grp_name = ""								   	//
//iu_cust_msg.is_data[1] = "CloseWithReturn"						//
//iu_cust_msg.il_data[1] = 1  		//현재 row					//
//==========================================================//

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.InsertRow(0)


end event

event ue_close();STRING	ls_shop,		ls_remark

dw_hlp.AcceptText()

ls_shop   = dw_hlp.Object.partner[1]
ls_remark = dw_hlp.Object.remark[1]

iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = ls_shop    //shop
iu_cust_help.is_data[2] = ls_remark  //remark

CLOSE(THIS)
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_selectshop
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_selectshop
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_selectshop
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_selectshop
boolean visible = false
integer x = 334
integer y = 672
boolean enabled = false
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_selectshop
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_selectshop
integer x = 23
integer y = 20
integer width = 891
integer height = 644
string dataobject = "ubs_dw_pop_selectshop_mas"
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::sqlpreview;//
end event

type p_save from u_p_ok within ubs_w_pop_selectshop
integer x = 23
integer y = 672
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Parent.TriggerEvent("ue_close")

end event

