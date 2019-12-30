$PBExportHeader$b5w_prc_reqcancel_v20.srw
$PBExportComments$[ceusee] 청구작업절차별 취소 처리
forward
global type b5w_prc_reqcancel_v20 from w_a_inq_m
end type
type p_select from u_p_select within b5w_prc_reqcancel_v20
end type
end forward

global type b5w_prc_reqcancel_v20 from w_a_inq_m
integer width = 3721
integer height = 1760
windowstate windowstate = normal!
event ue_select ( )
p_select p_select
end type
global b5w_prc_reqcancel_v20 b5w_prc_reqcancel_v20

type variables
string is_PrebillStart,is_PrebillEnd
//청구기준일
Date id_reqdt
String is_chargedt, is_reqdt
long il_SelRowFrom,il_SelRowTo
end variables

forward prototypes
public function long wfl_unfinished_first (datawindow adw_detail)
end prototypes

event ue_select();String ls_errmsg,ls_pgm_id,ls_chargedt,ls_payid,ls_reqnum_fr,ls_reqnum_to
long ll_return
double lb_count
long ll_currow,ll_rc

ll_rc = f_msg_ques_yesno2(2070,Title,"", 2)

If ll_rc <> 1 Then
	Return
End If

For ll_currow = il_SelRowTo TO il_SelRowFROM STEP -1
   ls_reqnum_fr = space(256)
   ls_reqnum_to = space(256)
	
   ll_return = -1
   ls_errmsg = space(256)
   ls_pgm_id = trim(dw_detail.object.pgm_id[ll_currow])
   ls_chargedt = trim(dw_cond.object.chargedt[1])
//   ls_payid = '00000000'
	ls_payid = trim(dw_detail.object.reqpgm_prcpayid[ll_currow])
    If isnull(ls_payid) or ls_payid = '' Then
		ls_payid = '00000000'
	End If		
   
   IF dw_detail.object.reqprocmenu_cancel_yn[ll_currow] = 'Y' Then
	
		CHOOSE CASE Upper(dw_detail.object.call_nm1[ll_currow])
		
		//   CASE "b5w_prc_InvStart"
		//	    SQLCA.b5InvStart(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_Itemsale_M")
				 SQLCA.B5ITEMSALE_MCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_Itemsale_M_Pre")  //선불제기본료추가 2005.03.21 khpark add
				SQLCA.B5ITEMSALE_M_PRECan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)		  		 
			CASE Upper("b5w_prc_Itemsale_postV")
				SQLCA.B5ITEMSALE_postVCan(ls_chargedt,ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_discount_customer")
			   SQLCA.B5W_PRC_DISCOUNT_CANCLE(ls_chargedt,gs_user_id,ls_pgm_id,ll_return,ls_errmsg,lb_count)
			CASE Upper("b5w_prc_CalcItemDiscount")
				SQLCA.B5CALCITEMDISCOUNTCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_conectionfee")  //접속료취소 추가 ohj 20051109
	         SQLCA.B5ITEMSALE_CONECTIONFEEcan(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id,  ll_return, ls_errmsg, lb_count)   			
			CASE Upper("b5w_prc_penalty") //위약금집계취소 juede 2006.03.16 (Temporary)
				SQLCA.B5ITEMSALE_PENALTYCAN(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id,  ll_return, ls_errmsg, lb_count)
		  	CASE Upper("b5w_prc_itemsaleclose")
				SQLCA.B5ITEMSALECLOSECan(ls_chargedt,ls_payid, ls_pgm_id, gs_user_id,ls_reqnum_fr,ls_reqnum_to, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_CalcInvDiscount")
				SQLCA.b5CalcInvDiscountCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_DelayFee")
				  SQLCA.b5DelayFeeCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_MinusInput")
				SQLCA.b5MinusInputCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_CalcTax")
			   SQLCA.b5CalcTaxCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			//선수금 취소2005.01.28
			CASE Upper("b5w_prc_PrePayment")
			   SQLCA.b5PrePaymentCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_CalcTrunk")
				SQLCA.b5CalcTrunkCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
			CASE Upper("b5w_prc_ReqAmtInfo")
				SQLCA.b5ReqAmtInfoCan(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 
		//	CASE "b5w_prc_InvEnd"
		//	    SQLCA.B5INVEND(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 
		//		 
			CASE ELSE
				ll_return = -1
				 ls_errmsg = "해당프로그램이없습니다.전산실문의바람"
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
	  
	End IF
   
NEXT
If ll_Return >= 0 Then

	f_msg_info(3000, Title, &
					"~r~n" + "(Process number of case : " + string(lb_count) + " Hit(s))")
End If


p_ok.TriggerEvent(clicked!)		




end event

public function long wfl_unfinished_first (datawindow adw_detail);/*------------------------------------------------------------------------
	Name	: wfl_unfinished_first()
	Desc.	: 청구 작업이 취속되어야 할   row 선택
	Return	: long 	: 선택 되어질 row 반환
	Arg.	: datawindow
	Ver.	: 1.0
	Date	: 2003.01.06
-------------------------------------------------------------------------*/
Long i , ll_row
ll_row = adw_detail.rowcount()

//마직막부터 Yes가 첨 나오는 곳
For i = ll_row  to 1 STEP -1
	If adw_detail.object.close_yn[i] = 'Y' and  adw_detail.object.reqpgm_cancel_yn[i] = 'N' and &
       adw_detail.object.reqprocmenu_cancel_yn[i] = 'Y' Then
		Return i
	End If
Next

Return 0

end function

on b5w_prc_reqcancel_v20.create
int iCurrent
call super::create
this.p_select=create p_select
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_select
end on

on b5w_prc_reqcancel_v20.destroy
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
	f_msg_usr_err(200, Title, "Billing Cycle date")
	dw_cond.SetColumn("chargedt")
	Return
End If

//조회
ls_where = ""
If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where = "reqpgm.chargedt = '" + ls_chargedt + "' and B.chargedt = '" + ls_chargedt + "'"
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

dw_cond.enabled = False
//p_ok.TriggerEvent("ue_disable")
//p_select.TriggerEvent("ue_enable")
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b5w_prc_reqcancel_v20
	Desc.	: 청구 작업 절차 처리 V20
	Ver.	: 2.0
	Date	: 2005.05.18.
	Prog.	: Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_parm,ls_module,ls_ref_desc
String ls_temp[]
Integer li_cnt

ls_ref_desc = This.Title
ls_module = "B5"					//청구 관리
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

type dw_cond from w_a_inq_m`dw_cond within b5w_prc_reqcancel_v20
integer x = 55
integer y = 52
integer width = 1472
integer height = 260
string dataobject = "b5d_cnd_prc_reqcancel_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;//청구 주기 구하기
String ls_startdt
Date ld_startdt
Date ld_use_fr, ld_use_to
//Long ll_cnt

If dwo.Name = "chargedt" THEN 
	
	//청구기준일 구하기
	Select reqdt,useddt_fr,useddt_to
	Into :id_reqdt,:ld_use_fr,:ld_use_to
	From reqconf 
	Where to_char(chargedt) = :data;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select Error(REQCONF)")
		Return 
	End If
	
	//청구기준일
	is_reqdt = String(id_reqdt, 'yyyy-mm-dd')
	is_chargedt = data
	
	dw_cond.object.frdate[1] = ld_use_fr
	dw_cond.object.todate[1] = ld_use_to
	
End If
Return 0
end event

type p_ok from w_a_inq_m`p_ok within b5w_prc_reqcancel_v20
integer x = 1705
integer y = 52
end type

type p_close from w_a_inq_m`p_close within b5w_prc_reqcancel_v20
integer x = 2304
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_prc_reqcancel_v20
integer y = 8
integer width = 1577
integer height = 348
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_prc_reqcancel_v20
integer x = 32
integer y = 376
integer width = 3616
integer height = 1216
string dataobject = "b5d_prc_reqcancel_v20"
end type

event dw_detail::retrieveend;long i, ll_row

ll_row = This.RowCount()

//If This.object.close_yn[ll_row] = 'Y' or This.object.close_yn[1] = 'N'  Then 
//	MessageBox(Parent.Title, "청구작업 취소 할수 없습니다.")
//   p_select.TriggerEvent("ue_disable")
//	p_ok.TriggerEvent("ue_enable")
//	dw_cond.Enabled = True
//End If
 
i = wfl_unfinished_first(dw_detail)
If i <= 0 Then
	SelectRow(0,False)
	MessageBox(Parent.Title, "청구작업 취소 할수 없습니다.")
    p_select.TriggerEvent("ue_disable")
	p_ok.TriggerEvent("ue_enable")
	dw_cond.Enabled = True
Else	
   //If i > 0 Then 
	SelectRow(0,False)
	SelectRow( i, True )
	ScrollToRow(i)
	SetRow(i)
	p_select.TriggerEvent("ue_enable")
	
    il_SelRowFrom = i
	il_SelRowTo = i
 //Else
//MessageBox(Parent.Title, "청구작업 취소 대상 작업이 없습니다.")
End If


end event

event dw_detail::clicked;call super::clicked;long ll_currow,ll_delrow

IF row > 0 Then
	IF this.object.reqprocmenu_cancel_yn[row] = 'Y' Then
	
		If il_SelRowTo <> il_SelRowFrom Then 
			FOR ll_delrow = row - 1 TO il_SelRowFrom STEP -1
				SelectRow( ll_delrow, False )
			NEXT 
		End If	
		
		FOR ll_currow = il_SelRowFrom - 1  TO row STEP -1  
			SelectRow(ll_currow, True )
			IF this.object.reqprocmenu_cancel_yn[ll_currow] = 'N' Then
				SelectRow( ll_currow, False )
			End IF
		NEXT
	
		il_SelRowFrom = row			
	End If
End IF

end event

type p_select from u_p_select within b5w_prc_reqcancel_v20
integer x = 2002
integer y = 52
boolean bringtotop = true
boolean originalsize = false
end type

