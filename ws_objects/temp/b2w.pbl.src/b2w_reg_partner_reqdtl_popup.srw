$PBExportHeader$b2w_reg_partner_reqdtl_popup.srw
$PBExportComments$[chooys]지급거래등록 Popup Window
forward
global type b2w_reg_partner_reqdtl_popup from window
end type
type p_2 from u_p_close within b2w_reg_partner_reqdtl_popup
end type
type p_1 from u_p_ok within b2w_reg_partner_reqdtl_popup
end type
type dw_cond from datawindow within b2w_reg_partner_reqdtl_popup
end type
end forward

global type b2w_reg_partner_reqdtl_popup from window
integer width = 1819
integer height = 380
boolean titlebar = true
string title = "총판대리점/발생년월 입력"
boolean controlmenu = true
windowtype windowtype = response!
long backcolor = 29478337
event ue_ok ( )
event ue_close ( )
p_2 p_2
p_1 p_1
dw_cond dw_cond
end type
global b2w_reg_partner_reqdtl_popup b2w_reg_partner_reqdtl_popup

type variables
Private :
 //메세지 객체에 있는 ii_pgm_index를 저장할 변수
 Int ii_pgm_index

Protected :
 //메세지 전달 객체
 u_cust_a_msg iu_cust_msg

Public :
 //Default Event
 String is_default = "ue_ok"

 //Cancel Event
String is_close = "ue_close"

//Window Resize
u_cust_w_resize iu_cust_w_resize

/////////////////////////////////////////////////

u_cust_a_msg	iu_msg
String	is_partner
end variables

event ue_ok();If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망
	dw_cond.SetFocus()
	Return
End If

//////////////////////////////////////////////////

String ls_partner
String ls_commdt

ls_partner = Trim(dw_cond.object.partner[1])
ls_commdt = String(dw_cond.object.commdt[1],"YYYYMM")

IF IsNull(ls_partner) THEN ls_partner = ""
IF IsNull(ls_commdt) THEN ls_commdt = ""

//필수항목
IF ls_partner = "" THEN
	f_msg_info(200, Title, "대리점")
	dw_cond.SetColumn("partner")
	dw_cond.SetFocus()
	Return
END IF

IF ls_commdt = "" THEN
	f_msg_info(200, Title, "발생년월")
	dw_cond.SetColumn("commdt")
	dw_cond.SetFocus()
	Return
END IF

iu_msg.is_data[1] = ls_partner
iu_msg.is_data[2] = ls_commdt


CloseWithReturn(this,iu_msg)

end event

event ue_close();iu_msg.is_data[1] = ""
iu_msg.is_data[2] = ""


CloseWithReturn(this,iu_msg)


end event

event open;Int li_i

iu_cust_msg = Create u_cust_a_msg

iu_cust_msg = Message.PowerObjectParm

//윈도우 Title 설정
This.Title = "특판대리점/발생년월 입력"

//프로그램 관리 Queue에 저장 & 저장할 Index를 결정
For li_i = 1 To gi_max_win_no
	If gs_pgm_id[li_i] = "" Then
		ii_pgm_index = li_i
		gs_pgm_id[li_i] = iu_cust_msg.is_pgm_id
		Exit
	End If
Next

//열인 윈도우 갯수 증가
gi_open_win_no ++

iu_cust_w_resize = Create u_cust_w_resize

////////////////////////////////////////////////////////////

f_center_window(this)

iu_msg = Message.PowerObjectParm

dw_cond.object.partner[1] = Trim(iu_msg.is_data[1])
end event

on b2w_reg_partner_reqdtl_popup.create
this.p_2=create p_2
this.p_1=create p_1
this.dw_cond=create dw_cond
this.Control[]={this.p_2,&
this.p_1,&
this.dw_cond}
end on

on b2w_reg_partner_reqdtl_popup.destroy
destroy(this.p_2)
destroy(this.p_1)
destroy(this.dw_cond)
end on

type p_2 from u_p_close within b2w_reg_partner_reqdtl_popup
integer x = 1486
integer y = 160
end type

type p_1 from u_p_ok within b2w_reg_partner_reqdtl_popup
integer x = 1486
integer y = 32
end type

type dw_cond from datawindow within b2w_reg_partner_reqdtl_popup
integer x = 23
integer y = 24
integer width = 1362
integer height = 232
integer taborder = 10
string dataobject = "b2dw_cnd_reg_partner_reqdtl_popup"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)

//Int li_i
//iu_cust_help = create u_cust_a_msg
////iu_cust_help.ib_data[1] = False
//
//Trigger Event ue_init()  // append by csh
//
////*****DataWindow의 Help Row의 색깔 및 Pointer 처리
//ii_help_col_no = UpperBound(is_help_win)
//For li_i = 1 To ii_help_col_no
////	idwo_help_col[li_i].Color = il_help_col_color
//	idwo_help_col[li_i].Pointer = is_help_cur
//Next

InsertRow( 0 )


end event

event destructor;//destroy iu_cust_help
end event

