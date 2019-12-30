$PBExportHeader$w_pop_trans_target.srw
$PBExportComments$해지DB이관대상 고객추출_계약팝업
forward
global type w_pop_trans_target from w_a_hlp
end type
type gb_1 from groupbox within w_pop_trans_target
end type
end forward

global type w_pop_trans_target from w_a_hlp
integer width = 5906
integer height = 3088
string title = ""
event ue_print ( )
event ue_psetup ( )
gb_1 gb_1
end type
global w_pop_trans_target w_pop_trans_target

type variables
String is_print_check
end variables

on w_pop_trans_target.create
int iCurrent
call super::create
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.gb_1
end on

on w_pop_trans_target.destroy
call super::destroy
destroy(this.gb_1)
end on

event open;call super::open;
LONG		  ll_row
String 	ls_workno

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

ls_workno = iu_cust_help.is_data[2]

dw_hlp.Retrieve(ls_workno)

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

type p_1 from w_a_hlp`p_1 within w_pop_trans_target
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within w_pop_trans_target
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within w_pop_trans_target
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within w_pop_trans_target
integer x = 50
integer y = 2860
end type

type gb_cond from w_a_hlp`gb_cond within w_pop_trans_target
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within w_pop_trans_target
integer x = 46
integer y = 32
integer width = 5810
integer height = 2796
string title = "추출고객계약정보"
string dataobject = "dw_pop_trans_target_contract"
boolean minbox = true
boolean maxbox = true
boolean hscrollbar = true
boolean resizable = true
boolean border = false
end type

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

event dw_hlp::ue_init;call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.customerid_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

type gb_1 from groupbox within w_pop_trans_target
integer x = 96
integer y = 44
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
end type

