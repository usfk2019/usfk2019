$PBExportHeader$b3w_reg_crt_discount_customer_popup.srw
$PBExportComments$비정기할인대상등록/생성[Proc] 팝업윈 By 변유신 2002.12.30
forward
global type b3w_reg_crt_discount_customer_popup from w_a_reg_m
end type
type cb_create from commandbutton within b3w_reg_crt_discount_customer_popup
end type
type rb_o from radiobutton within b3w_reg_crt_discount_customer_popup
end type
type rb_a from radiobutton within b3w_reg_crt_discount_customer_popup
end type
type dw_buffer from datawindow within b3w_reg_crt_discount_customer_popup
end type
type dw_buffer2 from datawindow within b3w_reg_crt_discount_customer_popup
end type
type rr_1 from roundrectangle within b3w_reg_crt_discount_customer_popup
end type
end forward

global type b3w_reg_crt_discount_customer_popup from w_a_reg_m
integer width = 2555
integer height = 1696
string title = ""
boolean controlmenu = false
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_create ( )
cb_create cb_create
rb_o rb_o
rb_a rb_a
dw_buffer dw_buffer
dw_buffer2 dw_buffer2
rr_1 rr_1
end type
global b3w_reg_crt_discount_customer_popup b3w_reg_crt_discount_customer_popup

type variables
Long il_seqno
int ii_valid = 0
end variables

forward prototypes
public function integer wf_valid ()
end prototypes

event ue_create();// Argument 순서 
// ['A'/'O']Over/Append 구분,
// 할인유형 
// 거래코드
// 적용개시일
// 적용종료일
// 할인금액
// 할인율
// ldb_Return
// ls_ErrMSG   	
// ldb_prcCount
string ls_OA, ls_tydiscount, ls_trcod
string ls_ErrMSG
datetime  ld_from, ld_to
decimal	 lr_dcamt, lr_dcrate
double ldb_Return, ldb_prcCount
Long ll_total_row
int li_Return, i 
ls_errmsg = space(256)

// <!-- Validation Start-->
li_Return = 0
li_Return = wf_valid()
if li_Return <> 0 then return
// <!-- Validation End-->
ll_total_row = dw_detail.RowCount()
select seq_discount_whereb.nextval
Into :il_seqno
From dual;

For i = 1 To ll_total_row
	dw_detail.object.seqno[i] = il_seqno
Next


If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return 
	End If
   Return
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return
	End If
End If

//Append 인지 Orverwrite인지
if rb_o.Checked = TRUE THEN	
   ls_OA = 'O'
ELSE 
	ls_OA = 'A'
END IF

ls_tydiscount = dw_buffer.Object.discountplan[1]
ls_trcod      = dw_buffer.Object.trcod[1]
ld_from		  = dw_cond.Object.dtfrom[1]
ld_to			  = dw_cond.Object.dtto[1]
lr_dcamt		  = dw_cond.Object.dcamt[1]
lr_dcrate	  = dw_cond.Object.dcrate[1]
ldb_prcCount = 0

//비정기할인대상자생성 
SQLCA.B3W_REG_CRT_DISCOUNT_CUSTOMER(ls_OA,ls_tydiscount,ls_trcod,ld_from,ld_to,lr_dcamt,lr_dcrate, il_seqno, gs_user_id,ldb_Return,ls_ErrMSG,ldb_prcCount);
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	
	// Procedure 의 오류에 따른 Garbage Collection!
	delete from discount_whereb where seqno = :il_seqno
	and discountplan = :ls_tydiscount ;
	commit;
	Return 
ElseIf ldb_Return < 0 Then		//For User
	MessageBox(This.Title, ls_errmsg)
	delete from discount_whereb where seqno = :il_seqno
	and discountplan = :ls_tydiscount ;
	commit;
	Return 
End If

f_msg_info(3000, Title, iu_cust_msg.is_pgm_name +  &
           "~r~n" + "처리건수 : " + String(ldb_prcCount))
Return


end event

public function integer wf_valid ();
datetime ld_from, ld_to
String ls_from, ls_to, ls_witem
double ldb_dcamt, ldb_dcrate
int li_RowCount, li_Count

//MessageBox("valid","v")

dw_cond.AcceptText()
dw_detail.AcceptText()

ld_from    = dw_cond.Object.dtfrom[1]
ld_to	     = dw_cond.Object.dtto[1]
ls_from    = String(dw_buffer.Object.fromdt[1],"yyyy-mm-dd")
ls_to      = String(dw_buffer.Object.todt[1],"yyyy-mm-dd")	
ldb_dcamt  = dw_buffer.Object.dcamt[1]
ldb_dcrate = dw_buffer.Object.dcrate[1]
  
  
  // dw_cond Validation
  // 적용시작일,적용종료일 체크 
  if ld_from > ld_to then
	  f_msg_usr_err(201, THIS.TITLE, "적용종료일 적용시작일보다 적을순 없습니다.")
	  dw_cond.SetFocus()
	  dw_cond.SetColumn('dtfrom')
	  return -1
  end if
  
  // 적용시작일 구간 체크 	
  if String(ld_from,'yyyy-mm-dd') < ls_from then
   
	  f_msg_usr_err(201, THIS.TITLE, "적용시작일은 " + ls_from + " 보다 적을수 없습니다.")
	  dw_cond.SetFocus()
	  dw_cond.SetColumn('dtfrom')
	  return -1
  elseif String(ld_from,'yyyy-mm-dd') > ls_to then
	  f_msg_usr_err(201, THIS.TITLE, "적용시작일은 " + ls_to + " 보다 클수 없습니다.")
	  dw_cond.SetFocus()
	  dw_cond.SetColumn('dtfrom')
	  return -1
	
  end if 
  
  // 적용종료일 구간 체크 	
  if String(ld_to,'yyyy-mm-dd') > ls_to then
   
	  f_msg_usr_err(201, THIS.TITLE, "적용종료일은 " + ls_to + " 보다 클수 없습니다.")
	  dw_cond.SetFocus()
	  dw_cond.SetColumn('dtto')
	  return -1
  elseif String(ld_to,'yyyy-mm-dd') < ls_from then
	  f_msg_usr_err(201, THIS.TITLE, "적용종료일은 " + ls_from + " 보다 적을수 없습니다.")
	  dw_cond.SetFocus()
	  dw_cond.SetColumn('dtto')
	  return -1	
  end if
  
  if ldb_dcrate = 0 and ldb_dcamt = 0 then
	  f_msg_usr_err(201, THIS.TITLE, "할인금액,할인율 두 값이 0 일순 없습니다.")
	  dw_cond.SetFocus()
	  dw_cond.SetColumn('dcamt')
	  return -1	
  end if
  
  // dw_detail Vaildation
  li_RowCount = dw_detail.Rowcount()
  
  //MessageBox("RowC",String(li_RowCount))
  
  if li_RowCount = 0 then 
	  f_msg_usr_err(200, THIS.TITLE, "조건항목을 입력하셔야 합니다.")
	  TriggerEvent('ue_insert')
	  return -1  
  end if	  
  
  for li_Count = 1 to li_RowCount
      
		// 필수입력 Checking 
		if (isNull(dw_detail.Object.wgroup[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "조건그룹을 지정하셔야 합니다.")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('wgroup')
	  	  return -1	
		end if
		
		if (isNull(dw_detail.Object.witem[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "조건항목을 지정하셔야 합니다.")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('witem')
	  	  return -1	
		end if 
		
		if (isNull(dw_detail.Object.operation[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "OPERATION 을 지정하셔야 합니다.")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('operation')
	  	  return -1	
		end if
		
		if (isNull(dw_detail.Object.operand[li_Count])) then
		  f_msg_usr_err(200, THIS.TITLE, "value 을 지정하셔야 합니다.")
	  	  dw_detail.SetFocus()
		  dw_detail.SetRow(li_Count)	 
	  	  dw_detail.SetColumn('operand')
	  	  return -1	
		else
		 ls_witem = dw_detail.Object.witem[li_Count]
		 dw_buffer2.Retrieve(ls_witem)
		 Choose case dw_buffer2.Object.columntype[1]
			
			Case 'VARCHAR2' 
				  
		   Case 'CHAR'
			
			Case 'DATE' 
				      If isDate(dw_detail.Object.operand[li_Count]) =FALSE then 
				      	f_msg_usr_err(201, THIS.TITLE, "value Data 타입이 일치하지 않습니다.~r~n날짜 YYYY-mm-dd 형식을 입력하셔야합니다.")
	  	  					dw_detail.SetFocus()
		  					dw_detail.SetRow(li_Count)	 
	  	  					dw_detail.SetColumn('operand')
	  	  					return -1	   
						End if
			Case 'NUMBER'
				      If isNumber(dw_detail.Object.operand[li_Count]) =FALSE then 
				      	f_msg_usr_err(201, THIS.TITLE, "value Data 타입이 일치하지 않습니다.~r~n~t숫자 형식을 입력하셔야합니다.")
	  	  					dw_detail.SetFocus()
		  					dw_detail.SetRow(li_Count)	 
	  	  					dw_detail.SetColumn('operand')
	  	  					return -1	   
						End if
		End Choose
		end if		
		
  next 	 
  
 return 0
  
					  

		
		            
end function

on b3w_reg_crt_discount_customer_popup.create
int iCurrent
call super::create
this.cb_create=create cb_create
this.rb_o=create rb_o
this.rb_a=create rb_a
this.dw_buffer=create dw_buffer
this.dw_buffer2=create dw_buffer2
this.rr_1=create rr_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_create
this.Control[iCurrent+2]=this.rb_o
this.Control[iCurrent+3]=this.rb_a
this.Control[iCurrent+4]=this.dw_buffer
this.Control[iCurrent+5]=this.dw_buffer2
this.Control[iCurrent+6]=this.rr_1
end on

on b3w_reg_crt_discount_customer_popup.destroy
call super::destroy
destroy(this.cb_create)
destroy(this.rb_o)
destroy(this.rb_a)
destroy(this.dw_buffer)
destroy(this.dw_buffer2)
destroy(this.rr_1)
end on

event open;call super::open;
String ls_parm, ls_discountplan
iu_cust_msg = Message.PowerObjectParm

f_center_window(b3w_reg_crt_discount_customer_popup)
ls_parm = iu_cust_msg.is_data[1]

//is_title = iu_cust_msg.is_pgm_name
dw_buffer.Retrieve(ls_parm)



dw_cond.Object.dtfrom[1] = dw_buffer.Object.fromdt[1]
dw_cond.Object.dtto[1]   = dw_buffer.Object.todt[1]
dw_cond.Object.dcamt[1]  = dw_buffer.Object.dcamt[1]
dw_cond.Object.dcrate[1] = dw_buffer.Object.dcrate[1]


// 금액조정 할인 가능한 경우 
if dw_buffer.Object.edit_yn[1] = 'Y' then
	dw_cond.SetTabOrder("dcamt",30)
	dw_cond.SetTabOrder("dcrate",40)
end if
	
	
	





end event

event type integer ue_reset();p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")

return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;//Setting
//해당 plan과 User에 대한것만 가져온다.


dw_detail.object.discountplan[al_insert_row] = dw_buffer.Object.discountplan[1]
dw_detail.object.crt_user[al_insert_row] = gs_user_id
Return 0 
end event

type dw_cond from w_a_reg_m`dw_cond within b3w_reg_crt_discount_customer_popup
integer x = 18
integer y = 56
integer width = 1513
integer height = 220
integer taborder = 10
string dataobject = "b3dw_cnd_crt_discount_customer_popup"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::losefocus;call super::losefocus;//MESSAGEBOX("Event","losefocus")
//datetime ld_from, ld_to
//String ls_from, ls_to
//
AcceptText()
//
//
//		           MessageBox("change","dtfrom")
//		           ld_from =  dw_cond.Object.dtfrom[1]
//					  
//					  ls_from = String(dw_buffer.Object.fromdt[1],"yyyymmdd")
//					  
//					  if ld_from < dw_buffer.Object.fromdt[1] then
//					      
//						  f_msg_usr_err(201, THIS.TITLE, "적용시작일은" + ls_from + "보다 적을수 없습니다.")
//						 						  
//						  dw_cond.SetFocus()
//						  dw_cond.SetColumn('dtfrom')
//						  return
//					  end if 
//					  
//
//		//			  dw_buffer.Object.todt[1]
//		            
end event

type p_ok from w_a_reg_m`p_ok within b3w_reg_crt_discount_customer_popup
boolean visible = false
integer x = 1632
integer y = 1744
boolean enabled = false
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b3w_reg_crt_discount_customer_popup
integer x = 2222
integer y = 168
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b3w_reg_crt_discount_customer_popup
integer x = 9
integer width = 1577
integer height = 288
end type

type p_delete from w_a_reg_m`p_delete within b3w_reg_crt_discount_customer_popup
integer x = 306
integer y = 1480
boolean enabled = true
end type

type p_insert from w_a_reg_m`p_insert within b3w_reg_crt_discount_customer_popup
integer x = 9
integer y = 1480
boolean enabled = true
end type

type p_save from w_a_reg_m`p_save within b3w_reg_crt_discount_customer_popup
boolean visible = false
end type

type dw_detail from w_a_reg_m`dw_detail within b3w_reg_crt_discount_customer_popup
integer x = 9
integer y = 296
integer width = 2519
integer height = 1108
integer taborder = 40
string dataobject = "b3dw_cnd3_crt_discount_customer_popup"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;

Choose case dwo.name
		
	case 'witem'
		     dw_buffer2.Retrieve(Object.witem[row])
	end choose
end event

type p_reset from w_a_reg_m`p_reset within b3w_reg_crt_discount_customer_popup
boolean visible = false
end type

type cb_create from commandbutton within b3w_reg_crt_discount_customer_popup
integer x = 1637
integer y = 176
integer width = 553
integer height = 92
integer taborder = 50
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "돋움체"
string text = "생성"
end type

event clicked;Parent.TriggerEvent('ue_create')
end event

type rb_o from radiobutton within b3w_reg_crt_discount_customer_popup
integer x = 1998
integer y = 56
integer width = 421
integer height = 64
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "돋움체"
long textcolor = 33554432
long backcolor = 15780518
string text = "Overwrite"
borderstyle borderstyle = stylelowered!
end type

type rb_a from radiobutton within b3w_reg_crt_discount_customer_popup
integer x = 1655
integer y = 56
integer width = 329
integer height = 64
integer taborder = 20
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "돋움체"
long textcolor = 33554432
long backcolor = 15780518
string text = "Append"
boolean checked = true
borderstyle borderstyle = stylelowered!
end type

type dw_buffer from datawindow within b3w_reg_crt_discount_customer_popup
integer x = 114
integer y = 680
integer width = 2162
integer height = 608
boolean bringtotop = true
boolean titlebar = true
string title = "dw_buffer [할인유형 Buffer]"
string dataobject = "b3dw_buffer_discountplan"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
hide()
end event

type dw_buffer2 from datawindow within b3w_reg_crt_discount_customer_popup
boolean visible = false
integer x = 169
integer y = 600
integer width = 654
integer height = 104
boolean bringtotop = true
boolean titlebar = true
string title = "dw_buffer2[할인조건항목마스터]"
string dataobject = "b3dw_buffer_discountwhereitem"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(sqlca)
hide()
end event

type rr_1 from roundrectangle within b3w_reg_crt_discount_customer_popup
integer linethickness = 1
long fillcolor = 15780518
integer x = 1627
integer y = 40
integer width = 823
integer height = 96
integer cornerheight = 40
integer cornerwidth = 55
end type

