$PBExportHeader$b5w_prc_reqpgm_repeat.srw
$PBExportComments$[hhm] 청구재작업절차처리
forward
global type b5w_prc_reqpgm_repeat from w_a_inq_m
end type
type p_select from u_p_select within b5w_prc_reqpgm_repeat
end type
end forward

global type b5w_prc_reqpgm_repeat from w_a_inq_m
integer width = 3406
integer height = 1808
event ue_select ( )
p_select p_select
end type
global b5w_prc_reqpgm_repeat b5w_prc_reqpgm_repeat

type variables
string is_parent,is_pgmid,is_PrebillStart,is_PrebillEnd
//청구기준일
Date id_reqdt
String is_chargedt, is_reqdt
long il_SelRowFrom,il_SelRowTo
end variables

forward prototypes
public function long wfl_unfinished_first (datawindow adw_detail)
public function integer wf_settargetterm (ref datawindow adw_cond)
end prototypes

event ue_select();String ls_errmsg,ls_pgm_id,ls_chargedt,ls_payid,ls_reqnum_fr,ls_reqnum_to
long ll_return
double lb_count
long ll_currow,ll_rc

   

ll_rc = f_msg_ques_yesno2(2060,Title,"", 2)

If ll_rc <> 1 Then
	Return
End If


//모래시계표시
SetPointer (HourGlass! )

For ll_currow = il_SelRowFrom TO il_SelRowTo 
	
	ls_reqnum_fr = space(256)
   ls_reqnum_to = space(256)	
   ll_return = -1
   ls_errmsg = space(256)
   ls_pgm_id = trim(dw_detail.object.pgm_id[ll_currow])
   ls_chargedt = trim(dw_cond.object.chargedt[1])
	ls_payid = trim(dw_detail.object.reqpgm_prcpayid[ll_currow])
   If isnull(ls_payid) or ls_payid = '' Then
		ls_payid = '00000000'
	End If	
	
	CHOOSE CASE Upper(dw_detail.object.call_nm1[ll_currow])

//   CASE "b5w_prc_InvStart"
//	    SQLCA.b5InvStart(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
 	 CASE Upper("b5w_prc_Itemsale_M")
          SQLCA.B5ITEMSALE_MRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_Itemsale_M_Pre")   //선불제기본료추가 2005.03.21 khpark add
	    SQLCA.B5ITEMSALE_M_PRERep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)		  
 	CASE Upper("b5w_prc_Itemsale_postV")
        SQLCA.B5ITEMSALE_postVrep(ls_chargedt, ls_payid,ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_discount_customer")
			SQLCA.B5W_PRC_DISCOUNT_REDO(ls_chargedt,gs_user_id,ls_pgm_id,ll_return,ls_errmsg,lb_count)
 	CASE Upper("b5w_prc_CalcItemDiscount")
	    SQLCA.B5CALCITEMDISCOUNTRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_itemsaleclose")
	    SQLCA.B5ITEMSALECLOSERep(ls_chargedt,ls_payid, ls_pgm_id, gs_user_id,ls_reqnum_fr,ls_reqnum_to, ll_return, ls_errmsg, lb_count)   
   CASE Upper("b5w_prc_CalcInvDiscount")
       SQLCA.b5CalcInvDiscountRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_DelayFee")
       SQLCA.b5DelayFeeRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_MinusInput")
	    SQLCA.b5MinusInputRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_CalcTax")
	    SQLCA.b5CalcTaxRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
   CASE Upper("b5w_prc_prepayment")
	    SQLCA.B5PREPAYMENTREP(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	CASE Upper("b5w_prc_CalcTrunk")
	    SQLCA.b5CalcTrunkRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
   CASE Upper("b5w_prc_ReqAmtInfo")
	    SQLCA.b5ReqAmtInfoRep(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 
//	CASE "b5w_prc_InvEnd"
//	    SQLCA.B5INVEND(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 
//		 
CASE "TEST" 
   CASE ELSE
	    ll_return = -1
		 ls_errmsg = "해당프로그램이없습니다. 전산실문의바람"
   END CHOOSE
   //처리부분...
  
  If SQLCA.SQLCode < 0 Then		//For Programer
	   MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	   ll_return = -1
      Exit  
   ElseIf ll_return < 0 Then	//For User
	   MessageBox(This.Title, ls_errmsg,Exclamation!,OK!)
		Exit
   End If
   
NEXT

//모래시계표시 해제
SetPointer (Arrow! )

If ll_Return >= 0 Then
	f_msg_info(3000, This.Title,"")
End If


p_ok.TriggerEvent(clicked!)		




end event

public function long wfl_unfinished_first (datawindow adw_detail);/*------------------------------------------------------------------------
	Name	: wfl_unfinished_first()
	Desc.	: 청구 작업이 재처리작업할   row 선택
	Return	: long 	: 선택 되어질 row 반환
	Arg.	: datawindow
	Ver.	: 1.0
	Date	: 2003.01.06
-------------------------------------------------------------------------*/
Long i , ll_row
ll_row = adw_detail.rowcount()

// Cancel_yn Yes가 첨 나오는 곳
For i = 2  to ll_row - 1 
	If adw_detail.object.reqpgm_cancel_yn[i] = 'Y'  Then
		Return i
	End If
Next

Return 0

end function

public function integer wf_settargetterm (ref datawindow adw_cond);String ls_date,ls_cur_Fr,ls_cur_to,ls_next_fr,ls_next_to,ls_before_fr,ls_before_to
String ls_chargedt
Int li_count, li_rc

ls_Date = b5fs_reqterm(adw_cond.object.chargedt[1],"")

If ls_date = "" Then
	Return -1
End If

ls_cur_fr = MidA(ls_date,1,8) //현월청구시작일
ls_cur_to = MidA(ls_date,9,8) //현월청구마지막일 
ls_next_fr = MidA(ls_date,17,8) //익월청구시작일
ls_next_to = MidA(ls_date,25,8) //익월청구마지막일 
//전월구하기(현월의 call사용시작시간 )
ls_before_fr = String(fd_pre_month(Date(Integer(MidA(ls_cur_fr, 1, 4)), &
						 Integer(MidA(ls_cur_fr, 5, 2)), &
						 Integer(MidA(ls_cur_fr, 7, 2))), 1), "yyyymmdd")

//전일구하기(현월의 call 시용종료시간)
ls_before_to = String(fd_date_pre(Date(Integer(MidA(ls_cur_fr, 1, 4)), &
						 Integer(MidA(ls_cur_fr, 5, 2)), &
						 Integer(MidA(ls_cur_fr, 7, 2))), 1), "yyyymmdd")

adw_cond.object.frdate[1] = date(Integer(MidA(ls_cur_fr,1,4)),Integer(MidA(ls_cur_fr,5,2)), &
                            Integer(MidA(ls_cur_fr,7,2)))
adw_cond.object.todate[1] = date(Integer(MidA(ls_cur_to,1,4)),Integer(MidA(ls_cur_to,5,2)), &
                            Integer(MidA(ls_cur_to,7,2)))
									 
adw_cond.object.frdate_call[1] = date(Integer(MidA(ls_before_fr,1,4)),Integer(MidA(ls_before_fr,5,2)), &
                            Integer(MidA(ls_before_fr,7,2)))
adw_cond.object.todate_call[1] = date(Integer(MidA(ls_before_to,1,4)),Integer(MidA(ls_before_to,5,2)), &
                            Integer(MidA(ls_before_to,7,2)))



return 0

	

end function

on b5w_prc_reqpgm_repeat.create
int iCurrent
call super::create
this.p_select=create p_select
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_select
end on

on b5w_prc_reqpgm_repeat.destroy
call super::destroy
destroy(this.p_select)
end on

event ue_ok();call super::ue_ok;Long ll_rows,ll_rc
String ls_where
String ls_chargedt
Integer li_ques

//청구주기 입력 Check
ls_chargedt = Trim(dw_cond.Object.chargedt[1])
If IsNull(ls_chargedt) Then ls_chargedt = ""

If ls_chargedt = "" Then
	f_msg_usr_err(200, Title, "청구주기")
	dw_cond.SetColumn("chargedt")
	Return
End If

//조회
ls_where = ""
If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where = "chargedt = '" + ls_chargedt + "'"
End If
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If


dw_detail.Object.pgm_nm.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.worker.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.frdate.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.todate.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.reqpgm_cancel_yn.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.close_yn.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.prccnt.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"
dw_detail.Object.prcamt.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"






end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b5w_prc_reqcancel
	Desc.	: 청구 작업 절차 처리
	Ver.	: 1.0
	Date	: 2003.01.03
	Prog.	: Choi Bo Ra (ceusee)
-------------------------------------------------------------------------*/

String ls_parm,ls_module,ls_ref_desc
String ls_temp[]
Integer li_cnt

ls_ref_desc = This.Title
ls_module = "B5"					//청구 관리

ls_parm = fs_get_control(ls_module, "S101", ls_ref_desc)		
If ls_parm = "" Then
	This.X = 1000000
	PostEvent("ue_close")
	Return
End If



//분리자로 나눈다.
li_cnt = fi_cut_string(ls_parm,';',ls_temp[])
If li_cnt <> 3 Then
	f_msg_info(8010,This.TiTle,'Module:B5,Ref No:S101')
	This.X = 1000000
	PostEvent("ue_close")
	Return
End If

If trim(ls_temp[1]) = '' or  trim(ls_temp[2]) = '' or trim(ls_temp[3]) = '' Then
	f_msg_info(8010,This.TiTle,'Module:B5,Ref No:S101')
	This.X = 1000000
	PostEvent("ue_close")
	Return
End If

is_parent = ls_temp[1] /*청구절차메뉴의parent id*/
is_pgmid = ls_temp[2]  /*청구절차메뉴의프로그램id*/

ls_parm = fs_get_control(ls_module, "S102", ls_ref_desc)		
If ls_parm = "" Then
	This.X = 1000000
	PostEvent("ue_close")
	Return
End If

li_cnt = fi_cut_string(ls_parm,';',ls_temp[])
If li_cnt <> 2 Then
	f_msg_info(8010,This.TiTle,'Module:B5,Ref No:S102=>분리자')
	This.X = 1000000
	PostEvent("ue_close")
	Return
End If

If ls_temp[1] = '' Then
	ls_temp[1] = '0'
End If
If ls_temp[2] = '' Then
	ls_temp[2] = '0'
End If

is_prebillStart = ls_temp[1]
is_prebillEnd = ls_temp[2]

p_select.TriggerEvent("ue_disable")


end event

type dw_cond from w_a_inq_m`dw_cond within b5w_prc_reqpgm_repeat
integer x = 55
integer y = 56
integer width = 1426
integer height = 252
string dataobject = "b5d_cnd_prc_reqcancel"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;//청구 주기 구하기
String ls_startdt
Date ld_startdt
Date ld_use_fr, ld_use_to
//Long ll_cnt

If dwo.Name = "chargedt" THEN 
	
	//처음 시작하는것인지 Check
//	Select count(*) 
//	Into :ll_cnt
//	From reqpgm
//	Where close_yn = 'Y';
	
	//청구기준일 구하기
	Select reqdt
	Into :id_reqdt
	From reqconf 
	Where to_char(chargedt) = :data;
	
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select Error(REQCONF)")
		Return 
	End If
	
//	//처음 시작하는것.
//	If ll_cnt = 0 Then
//		id_reqdt = fd_next_month(id_reqdt, 1)   //한달은 더한다.
//	End If
	
	//청구기준일
	is_reqdt = String(id_reqdt, 'yyyy-mm-dd')
	is_chargedt = data
	
	//사용기간 시작일
	ld_use_fr = fd_pre_month(id_reqdt, 1)
	//사용기간 종료일
	ld_use_to = fd_date_pre(id_reqdt, 1)
	dw_cond.object.frdate[1] = ld_use_fr
	dw_cond.object.todate[1] = ld_use_to
	
End If
Return 0
end event

type p_ok from w_a_inq_m`p_ok within b5w_prc_reqpgm_repeat
integer x = 1646
integer y = 56
end type

type p_close from w_a_inq_m`p_close within b5w_prc_reqpgm_repeat
integer x = 2245
integer y = 56
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_prc_reqpgm_repeat
integer width = 1513
integer height = 328
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_prc_reqpgm_repeat
integer x = 32
integer y = 352
integer width = 3291
integer height = 1292
string dataobject = "b5d_prc_reqcancel"
boolean ib_sort_use = false
end type

event dw_detail::retrieveend;long i, ll_row

ll_row = This.RowCount()
i = wfl_unfinished_first(dw_detail)
If i = 1 or i = ll_row or (i <= 0) Then
	SelectRow(0,False)
	MessageBox(Parent.Title, " 재처리할  취소된 작업이  없습니다.")
    p_select.TriggerEvent("ue_disable")
	p_ok.TriggerEvent("ue_enable")
	dw_cond.Enabled = True
Else
	dw_cond.Enabled = False
    SelectRow(0,False)
	SelectRow(i, True )
	ScrollToRow(i)
	SetRow(i)
	p_select.TriggerEvent("ue_enable")
	
    il_SelRowFrom = i
	il_SelRowTo = i
End If


end event

event dw_detail::clicked;long ll_currow,ll_delrow


If row = 0 Then Return
If row >= il_SelRowFrom and This.object.reqpgm_cancel_yn[row] = 'Y'  Then
	 
  	If il_SelRowTo <> il_SelRowFrom Then 
		
		FOR ll_delrow = row + 1 TO il_SelRowTo 
          SelectRow( ll_delrow, False )
	   NEXT 
	End If	
	
	FOR ll_currow = il_SelRowTo + 1  TO row  
	    SelectRow( ll_currow, True )
   NEXT

	il_SelRowTo = row			
End If


end event

type p_select from u_p_select within b5w_prc_reqpgm_repeat
integer x = 1943
integer y = 56
boolean bringtotop = true
boolean originalsize = false
end type

