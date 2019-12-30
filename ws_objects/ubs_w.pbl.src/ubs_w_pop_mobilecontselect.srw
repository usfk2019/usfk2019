$PBExportHeader$ubs_w_pop_mobilecontselect.srw
$PBExportComments$[jhchoi] 모바일 렌탈 연장 계약선택 팝업 - 2009.06.04
forward
global type ubs_w_pop_mobilecontselect from w_a_hlp
end type
type gb_1 from groupbox within ubs_w_pop_mobilecontselect
end type
end forward

global type ubs_w_pop_mobilecontselect from w_a_hlp
integer width = 3026
integer height = 888
string title = ""
event ue_print ( )
event ue_psetup ( )
gb_1 gb_1
end type
global ubs_w_pop_mobilecontselect ubs_w_pop_mobilecontselect

type variables
String is_print_check
end variables

on ubs_w_pop_mobilecontselect.create
int iCurrent
call super::create
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_1
end on

on ubs_w_pop_mobilecontselect.destroy
call super::destroy
destroy(this.gb_1)
end on

event open;call super::open;//=============================================================//
// Desciption : 모바일렌탈 연장시 계약을 선택할 수 있는 POP UP //
// Name       : ubs_w_pop_mobilecontselect                     //
// Contents   : 인증장비 이동시 샵을 선택한다				      //
// Data Window: dw - ubs_dw_pop_mobilecontselect_mas	         // 
// 작성일자   : 2009.06.04                                     //
// 작 성 자   : 최재혁 대리                                    //
// 수정일자   :                                                //
// 수 정 자   :                                                //
//=============================================================//

LONG		  ll_row

//==========================================================//
//ubs_w_reg_equipmove transfer 버튼 클릭시 넘어오는 값  		//
//iu_cust_msg 				= CREATE u_cust_a_msg					//
//iu_cust_msg.is_pgm_name = "Contract Select"					//
//iu_cust_msg.is_data[1]  = "CloseWithReturn"					//
//iu_cust_msg.il_data[1]  = 1  		//현재 row					//
//iu_cust_msg.is_data[2]  = data										//
//iu_cust_msg.idw_data[1] = dw_master								//
//==========================================================//

This.Title =  iu_cust_help.is_pgm_name 

dw_hlp.Retrieve(iu_cust_help.is_data[2])

//dw_hlp.InsertRow(0)


end event

event ue_close();STRING	ls_contractseq
LONG		ll_row

dw_hlp.AcceptText()

ll_row = dw_hlp.GetSelectedRow(0)

ls_contractseq = STRING(dw_hlp.Object.contractseq[ll_row])

iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[3] = ls_contractseq    //contractseq

CLOSE(THIS)
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_mobilecontselect
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_mobilecontselect
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_mobilecontselect
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_mobilecontselect
integer x = 32
integer y = 684
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_mobilecontselect
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_mobilecontselect
integer x = 18
integer y = 20
integer width = 2962
integer height = 628
string dataobject = "ubs_dw_pop_mobilecontselect_mas"
boolean hscrollbar = true
boolean border = false
boolean hsplitscroll = false
end type

event dw_hlp::clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If

end event

event dw_hlp::doubleclicked;If row = 0 Then
	Return
Else
	SelectRow(0, False)
	SelectRow(row, True)
End If

Parent.TriggerEvent('ue_close')
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::sqlpreview;//
end event

type gb_1 from groupbox within ubs_w_pop_mobilecontselect
integer x = 5
integer width = 2994
integer height = 664
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

