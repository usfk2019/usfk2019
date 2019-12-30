$PBExportHeader$b5w_reg_hotreqdtl.srw
$PBExportComments$[ceusee] Hot Bill 계산
forward
global type b5w_reg_hotreqdtl from w_a_reg_s
end type
type p_cancel from u_p_cancel within b5w_reg_hotreqdtl
end type
type cb_hotbill from commandbutton within b5w_reg_hotreqdtl
end type
end forward

global type b5w_reg_hotreqdtl from w_a_reg_s
integer width = 2368
event type integer ue_cancel ( )
p_cancel p_cancel
cb_hotbill cb_hotbill
end type
global b5w_reg_hotreqdtl b5w_reg_hotreqdtl

type variables
String is_start[], is_hotflag, is_payid, is_termdt
Boolean ib_save
Integer il_cnt
end variables

forward prototypes
public function integer wfi_preamt_chk (ref long al_preamt)
public function integer wfi_contract_staus_chk (ref long al_cnt, ref string as_bil_todt)
end prototypes

event type integer ue_cancel();Integer li_return, i
Long ll_return
String ls_errmsg

ll_return = -1
ls_errmsg = space(256)

SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
   Return -1
	
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
   Return -1
End If 

f_msg_info(3000, Title, "HotBilling Cancel")

For i =1 To dw_detail.RowCount()
   dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
Next

ib_save = true

TriggerEvent("ue_reset")  //리셋한다.

Return 0
end event

public function integer wfi_preamt_chk (ref long al_preamt);String  ls_chargedt, ls_trdt

//해당납입자 청구주기
SELECT BILCYCLE
  INTO :ls_chargedt
 FROM  billinginfo
WHERE customerid = :is_payid;	

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_preamt_chk(Select billinginfo Error)")
	Return -1
End If	

//해당청구주기의 Hotbilling 해당 청구기준일
SELECT to_char(add_months(reqdt,1),'yyyymmdd')
  Into :ls_trdt
 FROM reqconf
WHERE chargedt = :ls_chargedt;	

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_preamt_chk(Select reqconf Error)")
	Return -1
End If	

//전월미납액이 존재 하는지 check
SELECT nvl(sum(tramt),0)
  INTO :al_Preamt
  FROM reqdtl
 WHERE TO_CHAR(trdt,'yyyymmdd') < :ls_trdt
   AND payid = :is_payid ;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_preamt_chk(Select reqdtl Error)")
	Return -1
End If	
  
Return 0
end function

public function integer wfi_contract_staus_chk (ref long al_cnt, ref string as_bil_todt);String ls_non_svctype, ls_term_status, ls_ref_desc, ls_status, ls_name[]

//해지 상태코드 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
ls_term_status = ls_name[2]

//비과금서비스type 가져오기
ls_ref_desc =""
ls_status = fs_get_control("B0", "P103", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
ls_non_svctype = ls_name[1]
  
SELECT count(a.contractseq)
 INTO  :al_cnt
 FROM  contractmst a ,customerm b, svcmst c
WHERE  a.customerid = b.customerid 
 AND  a.svccod = c.svccod          
 AND  c.svctype <> :ls_non_svctype    
 AND  b.payid = :is_payid	 
 AND  a.status <> :ls_term_status;
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_contract_status_chk(Select Error 1)")
	Return -1
End If	

SELECT to_char(nvl(max(a.bil_todt),sysdate),'yyyymmdd')
 INTO  :as_bil_todt
 FROM  contractmst a ,customerm b, svcmst c
WHERE  a.customerid = b.customerid 
 AND  a.svccod = c.svccod          
 AND  c.svctype <> :ls_non_svctype    
 AND  b.payid = :is_payid	 
 AND  a.status = :ls_term_status;

If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(Title, "wfi_contract_status_chk(Select Error 2)")
	Return -1
End If	

 
return 0
end function

on b5w_reg_hotreqdtl.create
int iCurrent
call super::create
this.p_cancel=create p_cancel
this.cb_hotbill=create cb_hotbill
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_cancel
this.Control[iCurrent+2]=this.cb_hotbill
end on

on b5w_reg_hotreqdtl.destroy
call super::destroy
destroy(this.p_cancel)
destroy(this.cb_hotbill)
end on

event open;call super::open;String ls_format, ls_ref_desc, ls_tmp, ls_useyn

ls_format = fs_get_control("B5", "H200", ls_ref_desc)
If ls_format = "1" Then
	dw_detail.object.tramt.Format = "#,##0.0"
	dw_detail.object.adjamt.Format = "#,##0.0"
	dw_detail.object.preamt.Format = "#,##0.0"	
	dw_detail.object.balance.Format = "#,##0.0"	
	dw_detail.object.totamt.Format = "#,##0.0"	
	dw_detail.object.sum_amt.Format = "#,##0.0"	
ElseIf ls_format = "2" Then
	dw_detail.object.tramt.Format = "#,##0.00"
	dw_detail.object.adjamt.Format = "#,##0.00"
	dw_detail.object.preamt.Format = "#,##0.00"	
	dw_detail.object.balance.Format = "#,##0.00"	
	dw_detail.object.totamt.Format = "#,##0.00"	
	dw_detail.object.sum_amt.Format = "#,##0.0"	
Else
	dw_detail.object.tramt.Format = "#,##0"
	dw_detail.object.adjamt.Format = "#,##0"
	dw_detail.object.preamt.Format = "#,##0"	
	dw_detail.object.balance.Format = "#,##0"	
	dw_detail.object.totamt.Format = "#,##0"	
	dw_detail.object.sum_amt.Format = "#,##0"
End If

//Hotbill 관리 여부 
ls_useyn = fs_get_control("H0", "H101", ls_ref_desc)
If ls_useyn = "Y" Then
	cb_hotbill.Enabled = True
Else
    cb_hotbill.Enabled = False
End If

//HotBill 순서 가져오기
ls_tmp = fs_get_control("H0", "H100", ls_ref_desc)
il_cnt= fi_cut_string(ls_tmp, ";", is_start[])

dw_cond.object.paydt[1] = Date(fdt_get_dbserver_now())
ib_save = False
end event

event type integer ue_reset();Constant Int LI_ERROR = -1

Int li_rc

dw_detail.AcceptText() 

If ib_save = False Then 
	If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0)  or dw_detail.Rowcount() > 0 Then
		li_rc = MessageBox(This.Title, "Hotbill 처리하시거나 취소하십시오.")
		Return 0
	End If
End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()


dw_cond.object.termdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.paydt[1] = date(fdt_get_dbserver_now())
p_cancel.TriggerEvent("ue_disable")
cb_hotbill.Enabled = True

Return 0
end event

event type integer ue_extra_save();call super::ue_extra_save;String ls_paymethod, ls_paydt, ls_sysdate,ls_nextdate
String ls_trdt, ls_reqnum, ls_cus_bil_todt
Long i, ll_seq, ll_max_seq, ll_cnt
Dec ldc_totamt, ldc_adjamt
int li_return, li_message

dw_detail.AcceptText()
ls_sysdate = String(fdt_get_dbserver_now(), 'yyyymmdd')
ldc_totamt = dw_detail.object.totamt[1]
ls_paymethod = dw_cond.object.pay_method[1]
ls_paydt = String(dw_cond.object.paydt[1], 'yyyymmdd')
ls_trdt = String(dw_detail.object.trdt[1], 'yyyymmdd')

If IsNull(ls_paymethod) Then ls_paymethod = ""
If IsNull(ls_paydt) Then ls_paydt = ""

If ls_paymethod = "" Then

	li_message = f_msg_ques_yesno2(9000, this.title,"지불방법을 입력하지 않았습니다. 입금정보를 입력하지 않으시면~r~n~r~n" + &
	                                   "차후 청구모듈 수동입금처리로 수동으로 입금정보를 입력하셔야 합니다.~r~n~r~n"+&
												  "핫빌처리와 함께 입금정보를 입력하시겠습니까?", 1)

	IF li_message = 1 Then
		dw_cond.SetFocus()
		dw_cond.SetColumn("pay_method")
		Return -1
	End If
	
End If

IF ls_paymethod <> "" Then
	If ls_paydt = "" Then
		f_msg_info(200, Title, "지불일자")
		dw_detail.SetFocus()
		dw_detail.SetColumn("paydt")
		Return -1
	ElseIf ls_paydt < ls_sysdate Then
	//	f_msg_usr_err(212, title + "today:" + Mid(ls_sysdate, 1,4) + "-" + &
	//	                            Mid(ls_sysdate,5,2) + "-" + &
	//										 Mid(ls_sysdate,7,2), "지불일자")
	//   dw_cond.SetFocus()
	//	dw_cond.SetColumn("paydt")
	//	Return -1
	End If

End IF

ls_nextdate = string(relativedate(date(fdt_get_dbserver_now()),1),'yyyymmdd')	
If ls_nextdate < is_termdt Then
	f_msg_usr_err(212,Title + "today:" +  MidA(ls_nextdate, 1,4) + "-" + &
										  MidA(ls_nextdate,5,2) + "-" + &
										  MidA(ls_nextdate,7,2),"해지요청일")

	Return -1	
End IF

//해당납입고객으로 해지처리 안된 고객이 있는지 Check 한다.
li_return = wfi_contract_staus_chk(ll_cnt, ls_cus_bil_todt)

IF li_return = 0 Then
    IF ll_cnt > 0 Then
     	f_msg_info(9000, Title, "해당 납입고객에 속한 고객 중 ~r~n해지처리되지 않은 고객이 존재합니다.~r~n모두 해지처리 후 다시 즉시불 처리하세요.")
		return -1
	End IF

    If ls_sysdate < ls_cus_bil_todt Then
		f_msg_usr_err(212,Title + "today:" +  MidA(ls_sysdate, 1,4) + "-" + &
											  MidA(ls_sysdate,5,2) + "-" + &
											  MidA(ls_sysdate,7,2)," 과금종료일")

		Return -1	
	End IF
	
ElseIf li_return = -1 Then
	return li_return
End IF

For i =1 To dw_detail.Rowcount()
	ldc_adjamt = dw_detail.object.adjamt[i]
    ll_seq = dw_detail.object.seq[i]
    ls_reqnum = dw_detail.object.reqnum[i]
		
	//조정 금액 Update
	Update hotreqdtl set adjamt = :ldc_adjamt, remark = :is_termdt
	 where payid = :is_payid and to_char(trdt, 'yyyymmdd') = :ls_trdt and
		   reqnum = :ls_reqnum and  seq = :ll_seq;
		
    If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Update Error(HOTREQDTL)")
		Return -1
	End If	

Next

If ls_paymethod <> "" Then   //지불을 하지 않으면 수동입금처리로 하도록 하기 위해 핫빌링에서는 처리 안한다.
	//입금 내역을 hotreqdtl에 반영한다.
	Select Max(seq) + 1
	Into :ll_max_seq
	from hotreqdtl where payid = :is_payid and to_char(trdt, 'yyyymmdd') = :ls_trdt
	and reqnum = :ls_reqnum;
	
	Insert Into Hotreqdtl (reqnum, seq, payid, trdt, paydt,
						   transdt,trcod, tramt, remark,
						   crtdt, crt_user, updtdt, updt_user, pgm_id)
		   Values(:ls_reqnum, :ll_max_seq, :is_payid, to_date(:ls_trdt, 'yyyymmdd'), to_date(:ls_paydt, 'yyyymmdd'),
				  to_date(:ls_paydt, 'yyyymmdd'), :ls_paymethod, (:ldc_totamt * -1), :is_termdt,
				  sysdate, :gs_user_id, sysdate, :gs_user_id, :gs_pgm_id[gi_open_win_no]);
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "Insert Error(HOTREQDTL)")
		Return -1
	End If	
End IF

//상테 Update
Update customerm set hotbillflag = 'S' where customerid = :is_payid;	

Return 0
end event

event resize;call super::resize;If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0

	p_cancel.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space

Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space

	p_cancel.Y	= newheight - iu_cust_w_resize.ii_button_space

End If
end event

event type integer ue_save();Constant Int LI_ERROR = -1
Integer li_return, i

li_return = This.Trigger Event ue_extra_save()

If li_return  < 0 Then
	dw_cond.SetFocus()
	Return LI_ERROR

Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000, Title, "HotBilling")
	//저장 안되었다고 표시
	For i =1 To dw_detail.RowCount()
		 dw_detail.SetItemStatus(i,0,Primary!,NotModified!)
	Next
	
    p_cancel.triggerevent("ue_disable")
    p_save.triggerevent("ue_disable")
    p_reset.triggerevent("ue_enable")
    ib_save = True
	
End if

Return 0
end event

event closequery;Int li_rc
Long ll_return
String ls_errmsg

dw_detail.AcceptText()
ll_return = -1
ls_errmsg = space(256)

If ib_save = False Then
	If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) or (dw_detail.RowCount() > 0 ) Then
		li_rc = MessageBox(This.Title, "HotBill을 취소 하시겠습니까?",&
			Question!, YesNo!)
		If li_rc =1 Then
			
			ll_return = -1
			ls_errmsg = space(256)
			
			SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				Return 1
				
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				Return 1
			End If 
			
			Close(this)
		Else
			Return 1
		End If
	End If
Else
		Close(This)	
End If
end event

type dw_cond from w_a_reg_s`dw_cond within b5w_reg_hotreqdtl
integer width = 1696
integer height = 308
string dataobject = "b5dw_cnd_reg_hotbill"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b5w_hlp_paymst"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;dwObject ldwo_payid


Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
		
			Object.payid[row] = iu_cust_help.is_data2[1]		//고객번호

		End If		
End Choose



Return 0
end event

event dw_cond::itemchanged;call super::itemchanged;If dwo.name = "payid" Then
	This.object.payid_1[row] = data
End If

Return 0
end event

event dw_cond::ue_key;//조회가 없으므로 막아야 한다.
Choose Case key
//	Case KeyEnter!
//		Parent.TriggerEvent(is_default)
	Case KeyEscape!
		Parent.TriggerEvent(is_close)
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

type p_ok from w_a_reg_s`p_ok within b5w_reg_hotreqdtl
boolean visible = false
integer x = 1682
integer y = 56
end type

type p_close from w_a_reg_s`p_close within b5w_reg_hotreqdtl
integer x = 1888
integer y = 52
end type

type gb_cond from w_a_reg_s`gb_cond within b5w_reg_hotreqdtl
integer width = 1742
integer height = 376
end type

type dw_detail from w_a_reg_s`dw_detail within b5w_reg_hotreqdtl
integer y = 392
integer width = 2254
integer height = 1204
string dataobject = "b5dw_reg_hotbill"
end type

event dw_detail::retrieveend;Int li_return
Long ll_preamt

If rowcount > 0 Then
	cb_hotbill.Enabled = False
	p_save.TriggerEvent("ue_enable")
	p_cancel.TriggerEvent("ue_enable")
    p_reset.TriggerEvent("ue_enable")	
	This.object.t_termdt.Text = MidA(is_termdt, 1,4) + "-" + MidA(is_termdt, 5,2) + "-" + MidA(is_termdt, 7,2)
Else
	cb_hotbill.Enabled = True
	p_save.TriggerEvent("ue_disable")
	p_cancel.TriggerEvent("ue_disable")
	li_return = wfi_preamt_chk(ll_preamt)
	IF li_return = 0 Then
		IF ll_preamt > 0 or ll_preamt < 0 Then
         	f_msg_info(9000, parent.Title, "당월 청구자료가 없습니다.~r~n현재미납액은 "+string(ll_preamt,'#,##0')+"입니다.~r~n수동입금처리로 확인하세요.")
		End IF	
	End IF	
End If

Return 0
end event

type p_delete from w_a_reg_s`p_delete within b5w_reg_hotreqdtl
boolean visible = false
end type

type p_insert from w_a_reg_s`p_insert within b5w_reg_hotreqdtl
boolean visible = false
end type

type p_save from w_a_reg_s`p_save within b5w_reg_hotreqdtl
integer x = 46
end type

type p_reset from w_a_reg_s`p_reset within b5w_reg_hotreqdtl
integer x = 690
end type

type p_cancel from u_p_cancel within b5w_reg_hotreqdtl
integer x = 352
integer y = 1636
integer height = 92
boolean bringtotop = true
end type

type cb_hotbill from commandbutton within b5w_reg_hotreqdtl
integer x = 1888
integer y = 164
integer width = 297
integer height = 92
integer taborder = 11
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "&HotBill"
end type

event clicked;//Hotbill 프로시저를 실행시킨다.
Integer i,li_error
String ls_errmsg,ls_pgm_id,ls_chargedt, ls_hotbillingflag
String ls_reqdt, ls_where, ls_reqdt_add
Date ld_reqdt, ld_reqdt_next
integer li_day
Long ll_return, ll_row

String ls_user_id

ls_user_id = gs_user_id

dw_cond.AcceptText( )
ll_return = -1
ls_errmsg = space(256)


//해당 고객의 청구 주기 
is_payid = Trim(dw_cond.object.payid[1])
If IsNull(is_payid) Then is_payid = ""
If is_payid = "" Then
	f_msg_info(200, Title, "Payer ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	Return -1
End If

is_termdt = String(dw_cond.object.termdt[1], 'yyyymmdd')
If IsNull(is_termdt) Then is_termdt = ""
If is_termdt = "" Then
	f_msg_info(200, Title, "Desired Termination Date")
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	Return -1
End If

//HotBil 사용 가능 여부, 청구주기
Select bil.bilcycle, cus.hotbillflag 
into :ls_chargedt, :ls_hotbillingflag
 from customerm cus, billinginfo bil
 where cus.customerid = bil.customerid
   and bil.customerid = :is_payid;

If Not IsNull(ls_hotbillingflag)  or ls_hotbillingflag <> "" Then
	f_msg_info(100, title, "이미 해지즉시불처리된 납입자 입니다.")
	Return -1
End If

//Select to_char(reqdt, 'yyyymmdd') into :ls_reqdt from reqconf
//where chargedt = :ls_chargedt;
Select reqdt into :ld_reqdt from reqconf
where chargedt = :ls_chargedt;

ls_reqdt = String(ld_reqdt, 'yyyymmdd')
ld_reqdt_next = fd_next_month(ld_reqdt,Integer(MidA(ls_reqdt,7,2)))
ls_reqdt_add = String(ld_reqdt_next,'yyyymmdd')

//해지일이 더 작으면
If ls_reqdt > is_termdt Then
	f_msg_usr_err(212, title+ "today:" +  MidA(ls_reqdt, 1,4)+ "-" + &
	 MidA(ls_reqdt, 5,2)+ "-" + MidA(ls_reqdt, 7,2), "Desired Termination Date")
	Return -1
////ElseIf Mid(ls_reqdt, 5,2) < Mid(is_termdt, 5,2) Then
////	f_msg_usr_err(210, title, "Desired Termination Date")
////	Return -1
////End If
End IF

//Web에서 이상한 오류로 인해 삭제하고 시작 한다.
SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
   Return -1
	
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, "1 " + ls_errmsg)
   Return -1
End If 


For i = 1 To il_cnt
	Choose Case is_start[i]
		Case "1"
			//정액 상품
			ls_errmsg = space(256)
		   SQLCA.HOTITEMSALE_M(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			   li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "1 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
	   Case "2"
			//통화 상품
		   ls_errmsg = space(256)
			SQLCA.HOTITEMSALE_POSTV(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"2 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "2 "+ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "3"
			//할인 대상자 선정
			ls_errmsg = space(256)
			SQLCA.HOTDISCOUNT_CUSTOMER(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
			  MessageBox(Title+'~r~n'+ "3 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "3 " + ls_errmsg)
				
            li_error = -1
				Exit;
			End If
		Case "4"
			//판매 품목 할인
			ls_errmsg = space(256)
			SQLCA.HOTCALCITEMDISCOUNT(is_payid, is_termdt, gs_user_id, ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programe
				MessageBox(Title+'~r~n'+"4 "+ ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "4 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		
		Case "5"
			//청구 Collection
			ls_errmsg = space(256)
			SQLCA.HOTSALECLOSE(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"5 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	    //For User
				MessageBox(Title, "5 " + ls_errmsg)
				li_error = -1
				Exit;
			ElseIF ll_return = 2 Then       //2005.01.10. khpart modify 청구자료collection에서 당월청구내역없으면 
				li_error = 2                //hotbilling처리 안한다. 밑단 프로시저 발생 안시킨다.
				Exit;				        //2005.01.10. khpart modify end
			End If
		Case "6"
			//청구 품목 할인
			ls_errmsg = space(256)
			SQLCA.HOTCALCINVDISCOUNT(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"6 " + ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "6 " + ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "7"
			//연체료
			ls_errmsg = space(256)
			SQLCA.HOTDELAYFEE(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"7 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "7 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "8"
			//기입금 차감액
			ls_errmsg = space(256)
			SQLCA.HOTMINUSINPUT(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"8 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "8 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "9"
			//세금액
			ls_errmsg = space(256)
			SQLCA.HOTCALCTAX(is_payid,is_termdt,  gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"9 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title, "9 " +ls_errmsg)
				li_error = -1
				Exit;
			End If
		Case "10"
			//절삭액
			ls_errmsg = space(256)
			SQLCA.HOTCALCTRUNK(is_payid, is_termdt, gs_user_id, gs_pgm_id[1], ll_return, ls_errmsg)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(Title+'~r~n'+"10 "+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
				li_error = -1
				Exit;
			ElseIf ll_return < 0 Then	//For User
				MessageBox(Title,"10 "+ ls_errmsg)
				li_error = -1
				Exit;
			End If
	End Choose
Next

If li_error = -1  Then
	ll_return = -1
	ls_errmsg = space(256)
	
	SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
		Return -1
	ElseIf ll_return < 0 Then	//For User
		MessageBox(Title, "1 " + ls_errmsg)
		Return -1
	End IF
	
Else

	If li_error = 2 Then   // 2005.01.10.  khpark modify start 청구내역자료collection에 return = 2 추가  

		ll_return = -1
		ls_errmsg = space(256)
		
		SQLCA.HOTCLEAR(is_payid, gs_user_id, ll_return, ls_errmsg)
		If SQLCA.SQLCode < 0 Then		//For Programer
			MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
			Return -1
		ElseIf ll_return < 0 Then	//For User
			MessageBox(Title, "1 " + ls_errmsg)
			Return -1
		End IF
		
   	End IF                // 2005.01.10.  khpark modify end 청구내역자료collection에 return = 2 추가        
	
	ll_row = dw_detail.Retrieve(is_payid)
	If ll_row = 0 Then
		f_msg_info(1000, title, "")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, title, "Retrieve()")
		Return -1
	End If
	
	ib_save = False
	
End If

Return 0
end event

