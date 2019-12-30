$PBExportHeader$b3w_reg_crt_discount_customer.srw
$PBExportComments$비정기할인대상등록/생성[Proc] By 변유신 2002.12.30
forward
global type b3w_reg_crt_discount_customer from w_a_reg_m
end type
type cb_create from commandbutton within b3w_reg_crt_discount_customer
end type
type dw_buffer from datawindow within b3w_reg_crt_discount_customer
end type
type p_fileread from u_p_fileread within b3w_reg_crt_discount_customer
end type
type p_filewrite from u_p_filewrite within b3w_reg_crt_discount_customer
end type
end forward

global type b3w_reg_crt_discount_customer from w_a_reg_m
integer width = 3666
integer height = 1844
event ue_filewrite ( )
event ue_fileread ( )
event ue_fileread_complete ( )
cb_create cb_create
dw_buffer dw_buffer
p_fileread p_fileread
p_filewrite p_filewrite
end type
global b3w_reg_crt_discount_customer b3w_reg_crt_discount_customer

event ue_filewrite();Integer li_return

If dw_detail.RowCount() <= 0 Then
	f_msg_info(9000, This.Title, "Download할 Data가 없습니다.")
	Return
End IF

li_return = dw_detail.SaveAs("", Text!, True)

If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User canceled current job.")
Else
	f_msg_info(9000, This.Title, "File Download Complete.")
End If




end event

event ue_fileread();Integer li_return
String ls_dir

SetNull(ls_dir)
li_return = dw_detail.ImportFile(ls_dir)

If li_return > 0 Then
	f_msg_info(9000, This.Title, "File Upload Complete.")
	
	p_delete.TriggerEvent('ue_enable')
	p_save.TriggerEvent('ue_enable')
	
	This.TriggerEvent('ue_fileread_complete')
ElseIf li_return = -9 Then
	f_msg_info(9000, This.Title, "User canceled the job.")
Else
	f_msg_info(9000, This.Title, "File Upload Error")
End If





end event

event ue_fileread_complete();String ls_discountplan
Long ll_row, ll_cnt

ls_discountplan = dw_cond.Object.cddiscount[1]
ll_row = dw_detail.RowCount()

dw_buffer.Retrieve(ls_discountplan)

For ll_cnt = 1 To ll_row
	dw_detail.Object.discountplan[ll_cnt] = ls_discountplan
	dw_detail.Object.trcod[ll_cnt] = dw_buffer.Object.trcod[1]
	dw_detail.Object.crt_user[ll_cnt] = gs_user_id
	dw_detail.Object.crtdt[ll_cnt] = fdt_get_dbserver_now()
Next

end event

on b3w_reg_crt_discount_customer.create
int iCurrent
call super::create
this.cb_create=create cb_create
this.dw_buffer=create dw_buffer
this.p_fileread=create p_fileread
this.p_filewrite=create p_filewrite
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_create
this.Control[iCurrent+2]=this.dw_buffer
this.Control[iCurrent+3]=this.p_fileread
this.Control[iCurrent+4]=this.p_filewrite
end on

on b3w_reg_crt_discount_customer.destroy
call super::destroy
destroy(this.cb_create)
destroy(this.dw_buffer)
destroy(this.p_fileread)
destroy(this.p_filewrite)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b3w_reg_discount_whereitem
	Desc.	: 할인조건항목등록 
	Ver 	: 1.0
	Date	: 2002.12.28
	Progrmaer: Byun Yu Sin
-------------------------------------------------------------------------*/
//p_insert.TriggerEvent("ue_enable")
 p_reset.TriggerEvent("ue_enable")
 p_filewrite.TriggerEvent("ue_disable")
 p_fileread.TriggerEvent("ue_disable")
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;

dw_detail.Object.discountplan[al_insert_row] = dw_cond.Object.cddiscount[1] // 할인유형
dw_detail.Object.fromdt[al_insert_row]       = dw_buffer.Object.fromdt[1]
dw_detail.Object.todt[al_insert_row]  		   = dw_buffer.Object.todt[1]
dw_detail.Object.dcamt[al_insert_row]  		= dw_buffer.Object.dcamt[1]
dw_detail.Object.dcrate[al_insert_row] 		= dw_buffer.Object.dcrate[1]
dw_detail.Object.trcod[al_insert_row]  		= dw_buffer.Object.trcod[1]

//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()

return 0
end event

event ue_ok();call super::ue_ok;Long ll_row
String ls_where
String ls_cddiscount,ls_customerid


//조회시 상단에 입력한 내용으로 조회
ls_cddiscount = Trim(dw_cond.Object.cddiscount[1])
ls_customerid = Trim(dw_cond.Object.customerid[1])

If IsNull(ls_cddiscount) Then ls_cddiscount = ""
If IsNull(ls_customerid) Then ls_customerid = ""

if ls_cddiscount = "" then 
	f_msg_usr_err(200, This.Title, "할인유형")
	dw_cond.Setfocus()
	dw_cond.SetColumn('cddiscount')
	return 
end if

ls_where = ""

If ls_cddiscount <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " discountplan = '" + ls_cddiscount + "' "	
End If

If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " customerid = '" + ls_customerid + "' "	
End If

dw_detail.is_where = ls_where

ll_row = dw_detail.Retrieve()

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If

p_insert.TriggerEvent("ue_enable")
p_filewrite.TriggerEvent("ue_enable")
p_fileread.TriggerEvent("ue_enable")








end event

event type integer ue_insert();call super::ue_insert;p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0 
end event

event ue_extra_save;call super::ue_extra_save;Long ll_row, ll_i
String ls_cdcust, ls_dcamt, ls_dcrate, ls_from, ls_to, ls_witem
real lr_dcamt, lr_dcrate
datetime ld_from, ld_to


//int li_RowCount, li_Count

dw_detail.AcceptText()

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장시 필수입력항목 check
For ll_i = 1 To ll_row
	ls_cdcust = Trim(dw_detail.Object.customerid[ll_i])
	lr_dcamt  = dw_detail.Object.dcamt[ll_i]
	lr_dcrate = dw_detail.Object.dcrate[ll_i]
	ld_from   = dw_detail.Object.fromdt[ll_i]
   ld_to	    = dw_detail.Object.todt[ll_i]
	ls_from   = String(dw_buffer.Object.fromdt[1],"yyyy-mm-dd")
	ls_to     = fs_snvl(String(dw_buffer.Object.todt[1],"yyyy-mm-dd"),'2999-12-31')	
	
	If IsNull(ls_cdcust) Then ls_cdcust  = ""
	If IsNull(lr_dcamt)  Then lr_dcamt   = 0
	If IsNull(lr_dcrate) Then lr_dcrate  = 0
	If IsNull(ls_from)   Then ls_from    = ""
	If IsNull(ls_to)     Then ls_to      = ""
//	If IsNull(ld_to)     Then ld_to      = datetime("2999-12-31 00:00:00")
		
	If ls_cdcust = "" Then 
		f_msg_usr_err(200, Title, "고객번호")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("customerid")
		Return -1
	End If
	
 // 적용시작일,적용종료일 체크
  IF IsNull(ld_to) = False THEN
	  if ld_from > ld_to then
		  f_msg_usr_err(201, THIS.TITLE, "적용종료일 적용시작일보다 적을순 없습니다.")
		  dw_detail.SetFocus()
		  dw_detail.SetRow(ll_i)	 
		  dw_detail.SetColumn('fromdt')
		  return -1
	  end if
  END IF
  // 적용시작일 구간 체크 	
//  if String(ld_from,'yyyy-mm-dd') < ls_from then
//      f_msg_usr_err(201, THIS.TITLE, "적용시작일은 " + ls_from + " 보다 적을수 없습니다.")
//	   dw_detail.SetFocus()
//	  dw_detail.SetRow(ll_i)	 
//	  dw_detail.SetColumn('fromdt')
//	  return -1
//  elseif String(ld_from,'yyyy-mm-dd') > ls_to then
//	  f_msg_usr_err(201, THIS.TITLE, "적용시작일은 " + ls_to + " 보다 클수 없습니다.")
//	  dw_detail.SetFocus()
//	  dw_detail.SetRow(ll_i)	 
//	  dw_detail.SetColumn('fromdt')
//	  return -1
//  end if 
  
//  // 적용종료일 구간 체크 	
//  if String(ld_to,'yyyy-mm-dd') > ls_to then
//	
//	  f_msg_usr_err(201, THIS.TITLE, "적용종료일은 " + ls_to + " 보다 클수 없습니다.")
//		dw_detail.SetFocus()
//	  dw_detail.SetRow(ll_i)	 
//	  dw_detail.SetColumn('todt')
//	  return -1
//  elseif String(ld_to,'yyyy-mm-dd') < ls_from then
//	  f_msg_usr_err(201, THIS.TITLE, "적용종료일은 " + ls_from + " 보다 적을수 없습니다.")
//		dw_detail.SetFocus()
//	  dw_detail.SetRow(ll_i)	 
//	  dw_detail.SetColumn('todt')
//	  return -1
//  end if
		
	
	If lr_dcrate = 0 and lr_dcamt = 0 Then 
		f_msg_usr_err(200, Title, "할인금액,할인율 두값이 0일순 없습니다.")
		dw_detail.SetRow(ll_i)
		dw_detail.ScrollToRow(ll_i)
		dw_detail.SetColumn("dcamt")
		Return -1
	End If
   	
Next

Return 0
	
end event

event type integer ue_reset();call super::ue_reset; cb_create.Enabled = False
 p_filewrite.TriggerEvent("ue_disable")
 p_fileread.TriggerEvent("ue_disable")
 
 p_reset.TriggerEvent("ue_enable")
 Return 0 
				 
end event

type dw_cond from w_a_reg_m`dw_cond within b3w_reg_crt_discount_customer
integer x = 55
integer y = 124
integer width = 1938
integer height = 144
string dataobject = "b3dw_cnd_crt_discount_customer"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_cond.object.customerid
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[1] = This.iu_cust_help.is_data[1]
 			 //This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;
Choose Case dwo.name
		
	case 'cddiscount' 
		       
				 dw_buffer.Retrieve(this.Object.cddiscount[row])
				 cb_create.Enabled = true
				 
				 // <!-- TabOder 설정 Editing 가부 -->
				 if dw_buffer.Object.edit_yn[1] = "Y" then
   				 dw_detail.SetTabOrder("dcamt",1)
					 dw_detail.SetTabOrder("dcrate",2)
				 else 
					 dw_detail.SetTabOrder("dcamt",0)
					 dw_detail.SetTabOrder("dcrate",0)
				 end if					 
end Choose
				 
end event

type p_ok from w_a_reg_m`p_ok within b3w_reg_crt_discount_customer
integer x = 2149
boolean originalsize = false
end type

type p_close from w_a_reg_m`p_close within b3w_reg_crt_discount_customer
integer x = 2437
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b3w_reg_crt_discount_customer
integer x = 37
integer width = 2016
integer height = 360
end type

type p_delete from w_a_reg_m`p_delete within b3w_reg_crt_discount_customer
integer x = 334
integer y = 1612
end type

type p_insert from w_a_reg_m`p_insert within b3w_reg_crt_discount_customer
integer x = 37
integer y = 1612
end type

type p_save from w_a_reg_m`p_save within b3w_reg_crt_discount_customer
integer x = 631
integer y = 1612
end type

type dw_detail from w_a_reg_m`dw_detail within b3w_reg_crt_discount_customer
integer x = 37
integer y = 380
string dataobject = "b3dw_reg_crt_discount_customer"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::doubleclicked;call super::doubleclicked;//Id 값 받기
Choose Case dwo.name
	Case "customerid"
		If This.iu_cust_help.ib_data[1] Then
			 This.Object.customerid[row] = This.iu_cust_help.is_data[1]
 			 //This.Object.customernm[1] = This.iu_cust_help.is_data[2]
		End If
		
End Choose


end event

event dw_detail::ue_init();call super::ue_init;//Customer ID help
This.is_help_win[1] = "b1w_hlp_customerm"
This.idwo_help_col[1] = dw_detail.object.customerid
This.is_data[1] = "CloseWithReturn"


end event

type p_reset from w_a_reg_m`p_reset within b3w_reg_crt_discount_customer
integer x = 1147
integer y = 1612
end type

type cb_create from commandbutton within b3w_reg_crt_discount_customer
integer x = 2149
integer y = 260
integer width = 567
integer height = 92
integer taborder = 11
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "돋움체"
boolean enabled = false
string text = "일괄생성처리"
end type

event clicked;
String ls_parm
Window lw_buffer

ls_parm = dw_cond.Object.cddiscount[1]
iu_cust_msg = Create u_cust_a_msg

iu_cust_msg.is_grp_name = "[할인정책]"
iu_cust_msg.is_pgm_name = "비정기할인대상등록생성"
iu_cust_msg.is_data[1] = ls_parm

OpenWithParm(b3w_reg_crt_discount_customer_popup, iu_cust_msg) 


cb_create.enabled = false


end event

type dw_buffer from datawindow within b3w_reg_crt_discount_customer
boolean visible = false
integer x = 1051
integer y = 852
integer width = 736
integer height = 196
integer taborder = 12
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

type p_fileread from u_p_fileread within b3w_reg_crt_discount_customer
integer x = 2437
integer y = 156
boolean bringtotop = true
boolean originalsize = false
end type

type p_filewrite from u_p_filewrite within b3w_reg_crt_discount_customer
integer x = 2149
integer y = 156
boolean bringtotop = true
boolean originalsize = false
end type

