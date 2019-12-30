$PBExportHeader$ubs_w_pop_sms_send.srw
$PBExportComments$[jhchoi] SMS 전송팝업 - 2011.02.19
forward
global type ubs_w_pop_sms_send from w_a_hlp
end type
type p_save from u_p_save within ubs_w_pop_sms_send
end type
type st_1 from statictext within ubs_w_pop_sms_send
end type
type mle_message from multilineedit within ubs_w_pop_sms_send
end type
type sle_1 from singlelineedit within ubs_w_pop_sms_send
end type
type st_2 from statictext within ubs_w_pop_sms_send
end type
type st_3 from statictext within ubs_w_pop_sms_send
end type
type st_4 from statictext within ubs_w_pop_sms_send
end type
type st_5 from statictext within ubs_w_pop_sms_send
end type
type st_6 from statictext within ubs_w_pop_sms_send
end type
type st_7 from statictext within ubs_w_pop_sms_send
end type
type st_8 from statictext within ubs_w_pop_sms_send
end type
type st_9 from statictext within ubs_w_pop_sms_send
end type
type st_10 from statictext within ubs_w_pop_sms_send
end type
type st_11 from statictext within ubs_w_pop_sms_send
end type
type st_12 from statictext within ubs_w_pop_sms_send
end type
type st_13 from statictext within ubs_w_pop_sms_send
end type
type st_14 from statictext within ubs_w_pop_sms_send
end type
type st_15 from statictext within ubs_w_pop_sms_send
end type
type st_16 from statictext within ubs_w_pop_sms_send
end type
type st_17 from statictext within ubs_w_pop_sms_send
end type
type st_18 from statictext within ubs_w_pop_sms_send
end type
type st_19 from statictext within ubs_w_pop_sms_send
end type
type sle_recvnumber1 from singlelineedit within ubs_w_pop_sms_send
end type
type sle_recvnumber2 from singlelineedit within ubs_w_pop_sms_send
end type
type sle_recvnumber3 from singlelineedit within ubs_w_pop_sms_send
end type
type sle_recvnumber4 from singlelineedit within ubs_w_pop_sms_send
end type
type sle_recvnumber5 from singlelineedit within ubs_w_pop_sms_send
end type
type st_20 from statictext within ubs_w_pop_sms_send
end type
type sle_sendnumber from singlelineedit within ubs_w_pop_sms_send
end type
type st_21 from statictext within ubs_w_pop_sms_send
end type
end forward

global type ubs_w_pop_sms_send from w_a_hlp
integer width = 2437
integer height = 1744
string title = ""
event ue_print ( )
event ue_psetup ( )
event type integer ue_insert ( )
event type integer ue_delete ( )
event ue_save ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
p_save p_save
st_1 st_1
mle_message mle_message
sle_1 sle_1
st_2 st_2
st_3 st_3
st_4 st_4
st_5 st_5
st_6 st_6
st_7 st_7
st_8 st_8
st_9 st_9
st_10 st_10
st_11 st_11
st_12 st_12
st_13 st_13
st_14 st_14
st_15 st_15
st_16 st_16
st_17 st_17
st_18 st_18
st_19 st_19
sle_recvnumber1 sle_recvnumber1
sle_recvnumber2 sle_recvnumber2
sle_recvnumber3 sle_recvnumber3
sle_recvnumber4 sle_recvnumber4
sle_recvnumber5 sle_recvnumber5
st_20 st_20
sle_sendnumber sle_sendnumber
st_21 st_21
end type
global ubs_w_pop_sms_send ubs_w_pop_sms_send

type variables
u_cust_db_app iu_cust_db_app
String is_print_check
end variables

event ue_delete;dwItemStatus l_status

dw_hlp.AcceptText()

l_status = dw_hlp.GetItemStatus(dw_hlp.GetRow(), 0, Primary!)

IF l_status = NewModified! OR l_status = New! THEN
	dw_hlp.Deleterow(0)
END IF	

return 0
end event

event ue_save;LONG			ll_bytes,	ll_len,				ll_row
STRING		ls_chk,		ls_sms_phone,		ls_sms_msg,		ls_from,		ls_gubun
INTEGER		ii,			jj

ll_bytes = LONG(sle_1.Text)

IF ll_bytes > 80 THEN
	F_MSG_INFO(9000, Title, "메세지는 최대 80 Bytes 까지 가능합니다.")
   RETURN
END IF

ls_sms_msg = mle_message.Text
ls_from	  = sle_sendnumber.Text

IF Isnull(ls_sms_msg) OR ls_sms_msg = '' THEN
	F_MSG_INFO(9000, Title, "메세지를 확인하세요.")
   RETURN	
END IF

IF Isnull(ls_from) OR ls_from = '' THEN
	F_MSG_INFO(9000, Title, "송신번호를 확인하세요.")
   RETURN
END IF

ll_row = dw_hlp.RowCount()

//DW 에서 선택된 번호...
FOR ii = 1 TO ll_row
	ls_chk			= dw_hlp.Object.chk[ii]
	ls_sms_phone	= dw_hlp.Object.smsphone[ii]
	IF IsNull(ls_sms_phone) THEN ls_sms_phone = ''
	
	IF ls_chk = 'Y' THEN
		ll_len = LenA(ls_sms_phone)
		
		IF ll_len < 10 OR ll_len > 11 THEN
			F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_sms_phone)
			ROLLBACK;
		   RETURN
		ELSE
			ls_gubun = MidA(ls_sms_phone, 1, 3)
			
			IF ls_gubun <> '010' AND ls_gubun <> '011' AND ls_gubun <> '016' AND ls_gubun <> '017' AND ls_gubun <> '018' AND ls_gubun <> '019' THEN
				F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_sms_phone)
				ROLLBACK;
			   RETURN
			END IF
		END IF
		
		INSERT INTO SMS.SC_TRAN
			( TR_NUM, TR_SENDDATE, TR_SENDSTAT, TR_PHONE,
			  TR_CALLBACK, TR_MSG,	TR_MSGTYPE )
		VALUES ( SMS.SC_SEQUENCE.NEXTVAL, SYSDATE, '0', :ls_sms_phone,
					:ls_from, :ls_sms_msg, '0');
										
		IF SQLCA.SQLCode = -1 THEN 
			MessageBox("SQL error", SQLCA.SQLErrText)
		END IF
	END IF
NEXT
//to 에서 선택된 경우..
FOR jj = 1 TO 5
	IF jj = 1 THEN
		ls_sms_phone	= sle_recvnumber1.Text
	ELSEIF jj = 2 THEN
		ls_sms_phone	= sle_recvnumber2.Text
	ELSEIF jj = 3 THEN
		ls_sms_phone	= sle_recvnumber3.Text
	ELSEIF jj = 4 THEN
		ls_sms_phone	= sle_recvnumber4.Text
	ELSEIF jj = 5 THEN
		ls_sms_phone	= sle_recvnumber5.Text
	END IF
	
	IF Isnull(ls_sms_phone) OR ls_sms_phone = '' THEN
		continue;
	ELSE
		ll_len = LenA(ls_sms_phone)
		
		IF ll_len < 10 OR ll_len > 11 THEN
			F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_sms_phone)
			ROLLBACK;
		   RETURN
		ELSE
			ls_gubun = MidA(ls_sms_phone, 1, 3)
			
			IF ls_gubun <> '010' AND ls_gubun <> '011' AND ls_gubun <> '016' AND ls_gubun <> '017' AND ls_gubun <> '018' AND ls_gubun <> '019' THEN
				F_MSG_INFO(9000, Title, "수신번호가 이상합니다 :" + ls_sms_phone)
				ROLLBACK;
			   RETURN
			END IF
		END IF
	END IF
	
	INSERT INTO SMS.SC_TRAN
		( TR_NUM, TR_SENDDATE, TR_SENDSTAT, TR_PHONE,
		  TR_CALLBACK, TR_MSG,	TR_MSGTYPE )
	VALUES ( SMS.SC_SEQUENCE.NEXTVAL, SYSDATE, '0', :ls_sms_phone,
				:ls_from, :ls_sms_msg, '0');
									
	IF SQLCA.SQLCode = -1 THEN 
		MessageBox("SQL error", SQLCA.SQLErrText)
	END IF	
NEXT
	
COMMIT;
F_MSG_INFO(3000, Title, "Save")	
end event

on ubs_w_pop_sms_send.create
int iCurrent
call super::create
this.p_save=create p_save
this.st_1=create st_1
this.mle_message=create mle_message
this.sle_1=create sle_1
this.st_2=create st_2
this.st_3=create st_3
this.st_4=create st_4
this.st_5=create st_5
this.st_6=create st_6
this.st_7=create st_7
this.st_8=create st_8
this.st_9=create st_9
this.st_10=create st_10
this.st_11=create st_11
this.st_12=create st_12
this.st_13=create st_13
this.st_14=create st_14
this.st_15=create st_15
this.st_16=create st_16
this.st_17=create st_17
this.st_18=create st_18
this.st_19=create st_19
this.sle_recvnumber1=create sle_recvnumber1
this.sle_recvnumber2=create sle_recvnumber2
this.sle_recvnumber3=create sle_recvnumber3
this.sle_recvnumber4=create sle_recvnumber4
this.sle_recvnumber5=create sle_recvnumber5
this.st_20=create st_20
this.sle_sendnumber=create sle_sendnumber
this.st_21=create st_21
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_save
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.mle_message
this.Control[iCurrent+4]=this.sle_1
this.Control[iCurrent+5]=this.st_2
this.Control[iCurrent+6]=this.st_3
this.Control[iCurrent+7]=this.st_4
this.Control[iCurrent+8]=this.st_5
this.Control[iCurrent+9]=this.st_6
this.Control[iCurrent+10]=this.st_7
this.Control[iCurrent+11]=this.st_8
this.Control[iCurrent+12]=this.st_9
this.Control[iCurrent+13]=this.st_10
this.Control[iCurrent+14]=this.st_11
this.Control[iCurrent+15]=this.st_12
this.Control[iCurrent+16]=this.st_13
this.Control[iCurrent+17]=this.st_14
this.Control[iCurrent+18]=this.st_15
this.Control[iCurrent+19]=this.st_16
this.Control[iCurrent+20]=this.st_17
this.Control[iCurrent+21]=this.st_18
this.Control[iCurrent+22]=this.st_19
this.Control[iCurrent+23]=this.sle_recvnumber1
this.Control[iCurrent+24]=this.sle_recvnumber2
this.Control[iCurrent+25]=this.sle_recvnumber3
this.Control[iCurrent+26]=this.sle_recvnumber4
this.Control[iCurrent+27]=this.sle_recvnumber5
this.Control[iCurrent+28]=this.st_20
this.Control[iCurrent+29]=this.sle_sendnumber
this.Control[iCurrent+30]=this.st_21
end on

on ubs_w_pop_sms_send.destroy
call super::destroy
destroy(this.p_save)
destroy(this.st_1)
destroy(this.mle_message)
destroy(this.sle_1)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.st_4)
destroy(this.st_5)
destroy(this.st_6)
destroy(this.st_7)
destroy(this.st_8)
destroy(this.st_9)
destroy(this.st_10)
destroy(this.st_11)
destroy(this.st_12)
destroy(this.st_13)
destroy(this.st_14)
destroy(this.st_15)
destroy(this.st_16)
destroy(this.st_17)
destroy(this.st_18)
destroy(this.st_19)
destroy(this.sle_recvnumber1)
destroy(this.sle_recvnumber2)
destroy(this.sle_recvnumber3)
destroy(this.sle_recvnumber4)
destroy(this.sle_recvnumber5)
destroy(this.st_20)
destroy(this.sle_sendnumber)
destroy(this.st_21)
end on

event open;call super::open;//=============================================================//
// Desciption : SMS 전송 POP UP											//
// Name       : ubs_w_pop_sms_send								      //
// Contents   : SMS를 전송한다. 									      //
// Data Window: dw - ubs_dw_pop_sms_send					         // 
// 작성일자   : 2011.02.19                                     //
// 작 성 자   : 최재혁 대리                                    //
// 수정일자   :                                                //
// 수 정 자   :                                                //
//=============================================================//

STRING	ls_flag,			ls_partner,			ls_ref_desc,			ls_from
LONG		ll_row

ls_ref_desc = ""
ls_from = fs_get_control("U5", "A100", ls_ref_desc)

sle_sendnumber.Text = ls_from

//==========================================================//
//민원화면에서 sms 버튼 클릭시 넘어오는 값	  					//
//iu_cust_msg 				  = CREATE u_cust_a_msg					//
//iu_cust_msg.is_pgm_name = "SMS"									//
//iu_cust_msg.is_data[1]  = "CloseWithReturn"					//
//iu_cust_msg.is_data[2]  = ls_partner								//
//iu_cust_msg.il_data[1]  = 1					//현재 row			//
//iu_cust_msg.idw_data[1] = dw_master								//
//==========================================================//

This.Title =  iu_cust_help.is_pgm_name 

ls_partner = iu_cust_help.is_data[2]

IF IsNull(ls_partner) OR ls_partner = "" THEN
	ls_flag = '0'
ELSE
	ls_flag = '1'
END IF

dw_hlp.Retrieve(ls_flag, ls_partner)
dw_hlp.SetFocus()
end event

event ue_close;STRING	ls_contractseq
LONG		ll_row

dw_hlp.AcceptText()

iu_cust_help.ib_data[1] = TRUE

CLOSE(THIS)
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_sms_send
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_sms_send
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_sms_send
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_sms_send
integer x = 343
integer y = 1532
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_sms_send
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_sms_send
integer x = 654
integer y = 100
integer width = 1746
integer height = 1392
string dataobject = "ubs_dw_pop_sms_send_mas"
boolean hscrollbar = true
boolean hsplitscroll = false
end type

event dw_hlp::clicked;//If row = 0 then Return
//
//If IsSelected( row ) then
//	SelectRow( row ,FALSE)
//Else
//   SelectRow(0, FALSE )
//	SelectRow( row , TRUE )
//End If

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

type p_save from u_p_save within ubs_w_pop_sms_send
integer x = 37
integer y = 1532
boolean bringtotop = true
boolean originalsize = false
end type

type st_1 from statictext within ubs_w_pop_sms_send
integer x = 32
integer y = 28
integer width = 283
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Message"
boolean focusrectangle = false
end type

type mle_message from multilineedit within ubs_w_pop_sms_send
event ue_keynumb pbm_enchange
integer x = 27
integer y = 100
integer width = 590
integer height = 520
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

event ue_keynumb;String ls_mle_msg
Long   ll_bytes

ls_mle_msg = mle_message.Text

ll_bytes = LenA(ls_mle_msg)

sle_1.Text = String(ll_bytes)

Return 0
end event

type sle_1 from singlelineedit within ubs_w_pop_sms_send
integer x = 192
integer y = 632
integer width = 146
integer height = 72
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 29478337
string text = "0"
boolean border = false
boolean righttoleft = true
end type

type st_2 from statictext within ubs_w_pop_sms_send
event ue_keynumb pbm_enchange
integer x = 338
integer y = 632
integer width = 274
integer height = 72
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16711680
long backcolor = 29478337
string text = "/80 Bytes"
boolean focusrectangle = false
end type

event ue_keynumb;String ls_mle_msg
Long   ll_bytes

ls_mle_msg = mle_message.Text

ll_bytes = LenA(ls_mle_msg)

sle_1.Text = String(ll_bytes)
end event

type st_3 from statictext within ubs_w_pop_sms_send
integer x = 27
integer y = 724
integer width = 78
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "※"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_3.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_4 from statictext within ubs_w_pop_sms_send
integer x = 101
integer y = 724
integer width = 82
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "☆"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_4.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_5 from statictext within ubs_w_pop_sms_send
integer x = 174
integer y = 724
integer width = 82
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "★"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_5.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_6 from statictext within ubs_w_pop_sms_send
integer x = 247
integer y = 724
integer width = 82
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "◎"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_6.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_7 from statictext within ubs_w_pop_sms_send
integer x = 320
integer y = 724
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "♤"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_7.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_8 from statictext within ubs_w_pop_sms_send
integer x = 393
integer y = 724
integer width = 78
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "♠"
alignment alignment = center!
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_8.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_9 from statictext within ubs_w_pop_sms_send
integer x = 466
integer y = 724
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "♡"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_9.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_10 from statictext within ubs_w_pop_sms_send
integer x = 539
integer y = 724
integer width = 78
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "♥"
alignment alignment = center!
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_10.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_11 from statictext within ubs_w_pop_sms_send
integer x = 27
integer y = 784
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "♧"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_11.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_12 from statictext within ubs_w_pop_sms_send
integer x = 101
integer y = 784
integer width = 78
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "♣"
alignment alignment = center!
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_12.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_13 from statictext within ubs_w_pop_sms_send
integer x = 174
integer y = 784
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "⊙"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_13.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_14 from statictext within ubs_w_pop_sms_send
integer x = 247
integer y = 784
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "☏"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_14.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_15 from statictext within ubs_w_pop_sms_send
integer x = 320
integer y = 784
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "☎"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_15.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_16 from statictext within ubs_w_pop_sms_send
integer x = 393
integer y = 784
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "☜"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_16.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_17 from statictext within ubs_w_pop_sms_send
integer x = 466
integer y = 784
integer width = 87
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
string text = "☞"
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_17.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_18 from statictext within ubs_w_pop_sms_send
integer x = 539
integer y = 784
integer width = 78
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 16777215
boolean border = true
boolean focusrectangle = false
end type

event clicked;String ls_string, ls_mle_msg

ls_string = st_18.text

ls_mle_msg = mle_message.Text + ls_string

mle_message.Text = ls_mle_msg
end event

type st_19 from statictext within ubs_w_pop_sms_send
integer x = 32
integer y = 868
integer width = 101
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "To"
boolean focusrectangle = false
end type

type sle_recvnumber1 from singlelineedit within ubs_w_pop_sms_send
integer x = 27
integer y = 936
integer width = 590
integer height = 80
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

type sle_recvnumber2 from singlelineedit within ubs_w_pop_sms_send
integer x = 27
integer y = 1012
integer width = 590
integer height = 80
integer taborder = 50
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

type sle_recvnumber3 from singlelineedit within ubs_w_pop_sms_send
integer x = 27
integer y = 1088
integer width = 590
integer height = 80
integer taborder = 60
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

type sle_recvnumber4 from singlelineedit within ubs_w_pop_sms_send
integer x = 27
integer y = 1164
integer width = 590
integer height = 80
integer taborder = 70
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

type sle_recvnumber5 from singlelineedit within ubs_w_pop_sms_send
integer x = 27
integer y = 1240
integer width = 590
integer height = 80
integer taborder = 80
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
end type

type st_20 from statictext within ubs_w_pop_sms_send
integer x = 32
integer y = 1340
integer width = 165
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "From"
boolean focusrectangle = false
end type

type sle_sendnumber from singlelineedit within ubs_w_pop_sms_send
integer x = 27
integer y = 1412
integer width = 590
integer height = 80
integer taborder = 90
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 15793151
end type

type st_21 from statictext within ubs_w_pop_sms_send
integer x = 672
integer y = 32
integer width = 320
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
string text = "Operator"
boolean focusrectangle = false
end type

