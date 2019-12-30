$PBExportHeader$b5w_prc_reqpgm_v21.srw
$PBExportComments$[parkkh] 청구 작업 절차 처리v20
forward
global type b5w_prc_reqpgm_v21 from w_a_inq_m
end type
type p_select from u_p_select within b5w_prc_reqpgm_v21
end type
end forward

global type b5w_prc_reqpgm_v21 from w_a_inq_m
integer width = 3931
integer height = 2220
string title = "linreq"
boolean minbox = false
windowstate windowstate = normal!
boolean clientedge = true
event ue_select ( )
p_select p_select
end type
global b5w_prc_reqpgm_v21 b5w_prc_reqpgm_v21

type variables
string is_PrebillStart,is_PreBillend
long il_SelRowFrom,il_SelRowTo, il_reqcycle
//청구기준일
Date id_reqdt, id_reqdt_pre
String is_chargedt, is_reqdt, is_unitcycle
String is_useddt_fr,is_useddt_to,is_pre_useddt_fr,is_pre_useddt_to
Date id_useddt_fr,id_useddt_to,id_pre_useddt_fr,id_pre_useddt_to

end variables

forward prototypes
public function long wfl_unfinished_first (datawindow adw_detail)
end prototypes

event ue_select();//*************
String ls_errmsg,ls_pgm_id,ls_chargedt,ls_payid,ls_reqnum_fr,ls_reqnum_to
long ll_return
double lb_count
long ll_currow,ll_rc

//If il_SelRowFrom = il_SelRowTo Then
	

//   ll_currow = dw_detail.GetSelectedRow(0)
//   window lw_temp
//   u_cust_a_msg lu_cust_msg      
//   lu_cust_msg = Create u_cust_a_msg
// 
//   lu_cust_msg.is_pgm_id = dw_detail.object.pgm_id[ll_currow]
//   lu_cust_msg.is_grp_name = this.title
//   lu_cust_msg.is_pgm_name = dw_detail.object.pgm_nm[ll_currow]
//   lu_cust_msg.is_call_name[1] = dw_detail.object.call_nm1[ll_currow]
//   lu_cust_msg.is_pgm_type = 'P'
//   lu_cust_msg.is_data[1] = dw_cond.object.chargedt[1]
//
//   //해당 윈도우를 연다.
//   If OpenWithParm(lw_temp, lu_cust_msg, dw_detail.object.call_nm1[ll_currow], gw_mdi_frame) <> 1 Then
//	   f_msg_usr_err_app(503, This.Title, "'" + dw_detail.object.call_nm1[ll_currow] + "' " + "window is not opened")
//   End If
//
//   destroy 	lu_cust_msg
//Else	
   
	ll_rc = f_msg_ques_yesno2(2050,Title,"", 2)
	
	If ll_rc <> 1 Then
		Return
	End If
	
	
	For ll_currow = il_SelRowFrom TO il_SelRowTo
		ls_reqnum_fr = space(256)
		ls_reqnum_to = space(256)
	   ll_return = -1
	   ls_errmsg = space(256)
	   ls_payid = '00000000'  //초기화
	   ls_pgm_id = trim(dw_detail.object.pgm_id[ll_currow])
	   ls_payid =  trim(dw_detail.object.reqpgm_prcpayid[ll_currow])
	   ls_chargedt = trim(dw_cond.object.chargedt[1])
	   If isnull(ls_payid)  Then
		  ls_payid = '00000000'
	   End IF;
	
	   If ls_payid = '' Then 
		   ls_payid = '00000000'
	   End If	
		
	   CHOOSE CASE Upper(dw_detail.object.call_nm1[ll_currow])
	
		CASE Upper("b5w_prc_InvStart")
			SQLCA.b5InvStart(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
//		CASE Upper("b5w_prc_Itemsale_M")
//			SQLCA.B5ITEMSALE_M(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
		CASE Upper("b5w_prc_Itemsale_M")     //khpark modify 납입고객별처리 수정
			SQLCA.B5ITEMSALE_M_V21(ls_chargedt, ls_payid,ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   			
//		CASE Upper("b5w_prc_Itemsale_M_Pre")   //선불제기본료추가 2005.03.21 khpark add
//			SQLCA.B5ITEMSALE_M_PRE(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)
		CASE Upper("b5w_prc_Itemsale_postV")
			SQLCA.B5ITEMSALE_postV(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)
		//재과금추가사용료 프로세스 추가(2015추가개발) START
		CASE Upper("b5w_prc_Itemsale_Upload")
			SQLCA.B5ITEMSALE_UPLOAD(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)
		//재과금추가사용료 프로세스 추가(2015추가개발) END
		CASE Upper("b5w_prc_discount_customer")
			SQLCA.B5W_PRC_DISCOUNT_CUSTOMER(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)
		//위약금계산 프로세스 추가(2015추가개발) START
		CASE Upper("b5w_prc_Itemsale_penalty")
			SQLCA.B5ITEMSALE_PENALTY(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)
		//위약금계산 프로세스 추가(2015추가개발) END		
		CASE Upper("b5w_prc_CalcItemDiscount")
			SQLCA.B5CALCITEMDISCOUNT(ls_chargedt,ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
      CASE Upper("b5w_prc_conectionfee")  //접속료 추가 ohj 20051010
         SQLCA.B5ITEMSALE_CONECTIONFEE(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id,  ll_return, ls_errmsg, lb_count)   			
		CASE Upper("b5w_prc_itemsaleclose")
			SQLCA.B5ITEMSALECLOSE(ls_chargedt,ls_payid, ls_pgm_id, gs_user_id,ls_reqnum_fr,ls_reqnum_to, ll_return, ls_errmsg, lb_count)   
		CASE Upper("b5w_prc_CalcInvDiscount")
			SQLCA.b5CalcInvDiscount(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
		CASE Upper("b5w_prc_DelayFee")
			SQLCA.b5DelayFee(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
		CASE Upper("b5w_prc_MinusInput")
			SQLCA.b5MinusInput(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
		CASE Upper("b5w_prc_CalcTax")
			SQLCA.b5CalcTax(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
		CASE Upper("b5w_prc_PrePayment")     	//선수금 추가
			SQLCA.b5PrePayment(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 
		CASE Upper("b5w_prc_CalcTrunk")
			SQLCA.b5CalcTrunk(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
	   CASE Upper("b5w_prc_ReqAmtInfo")
			SQLCA.b5ReqAmtInfo(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 
		CASE Upper("b5w_prc_ReqTaxsheet_info")
			SQLCA.b5ReqTaxsheet_info(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)			
		CASE Upper("b5w_prc_InvEnd")
			SQLCA.B5INVEND(ls_chargedt, ls_payid, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   		 			 
		CASE Upper("b5w_prc_CalcPrePay")
			SQLCA.b5PrepayClose(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   	
		//부가세계산 추가(2019/05/01)
		CASE Upper("b5CalcVat")
			SQLCA.b5calc_vat_update(ls_chargedt, ls_pgm_id, gs_user_id, ll_return, ls_errmsg, lb_count)   
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
   
	NEXT

	If ll_Return >= 0 Then
		f_msg_info(3000, This.Title,"")
	End If
//End If


p_ok.TriggerEvent(clicked!)		
end event

public function long wfl_unfinished_first (datawindow adw_detail);Long ll_k,ll_row
ll_row = adw_detail.rowcount()
For ll_k = 1 to ll_row
	If adw_detail.object.close_yn[ll_k] = 'N'  Then
		Return ll_k
	End If
Next

Return 1
end function

on b5w_prc_reqpgm_v21.create
int iCurrent
call super::create
this.p_select=create p_select
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_select
end on

on b5w_prc_reqpgm_v21.destroy
call super::destroy
destroy(this.p_select)
end on

event ue_ok();call super::ue_ok;Long ll_rows,ll_rc
String ls_where
String ls_chargedt
Integer li_ques

b5u_dbmgr_v20 lu_cust_db
u_cust_db_app lu_cust_db_app

//입력 조건 처리 부분
//청구주기
ls_chargedt = Trim(dw_cond.Object.chargedt[1])

//Error 처리부분
If IsNull(ls_chargedt) Then ls_chargedt = ""

If ls_chargedt = "" Then
	f_msg_usr_err(200, Title, "Billing Cycle date")
	dw_cond.SetColumn("chargedt")
	Return
End If

lu_cust_db = Create b5u_dbmgr_v20

//청구절차메뉴copy
lu_cust_db.is_title = This.Title
lu_cust_db.is_caller = "CHECK INV MENU"
lu_cust_db.is_data[1] = ls_chargedt /*청구주기*/
lu_cust_db.uf_prc_db()
ll_rc = lu_cust_db.ii_rc
Destroy lu_cust_db

If ll_rc < 0 Then 	
	Return
ElseIf ll_rc = 3 Then

	f_msg_info(9000,Title,"해당 청구주기에 청구절차메뉴를 먼저 등록해 주세요!")
	
	ReTurn
ElseIf ll_rc = 1  or ll_rc = 2 Then
    
	 li_ques = f_msg_ques_yesno2(2010,This.Title,"관리자에게문의바람",2)
	 If li_ques = 2 Then		 
		 Return
	 Else
		lu_cust_db = Create b5u_dbmgr_v20

      //청구절차메뉴새로생성
      lu_cust_db.is_title = This.Title
      lu_cust_db.is_caller = "REPLACE INV MENU"
      lu_cust_db.is_data[1] = ls_chargedt /*청구주기*/
      lu_cust_db.uf_prc_db()
      ll_rc = lu_cust_db.ii_rc
      Destroy lu_cust_db      
      lu_cust_db_app = Create u_cust_db_app

      If ll_rc < 0 then
	      //ROLLBACK와 동일한 기능
	      lu_cust_db_app.is_caller = "ROLLBACK"
	      lu_cust_db_app.is_title = This.Title

	      lu_cust_db_app.uf_prc_db()
	
	     If lu_cust_db_app.ii_rc = -1 Then		     
			  Destroy lu_cust_db_app      
	        Return 
		  End If
		  f_msg_info(3010,This.Title,"Save")
     Else
	      //COMMIT와 동일한 기능
	     lu_cust_db_app.is_caller = "COMMIT"
	     lu_cust_db_app.is_title = This.Title

	     lu_cust_db_app.uf_prc_db()

	     If lu_cust_db_app.ii_rc = -1 Then
			  Destroy lu_cust_db_app      
	        Return
	     End If
	
	     f_msg_info(3000,This.Title,"Save")
     End If
	  Destroy lu_cust_db_app      
End If  
End If	

ls_where = ""

If ls_chargedt <> "" Then
	If ls_where <> "" Then ls_where += " and "
	ls_where = "chargedt = '" + ls_chargedt + "'"
End If

dw_detail.is_where = ls_where

//자료 읽기 및 관련 처리부분
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
dw_detail.Object.reqpgm_prcpayid.background.Color = &
"0~tIf(getrow() >= number( '" + is_PreBillstart + "')and getrow() <= number('" + is_PreBillEnd + "') ,RGB(255,255,255),RGB(192,192,192))"

dw_cond.enabled = False
p_ok.TriggerEvent("ue_disable")
p_select.TriggerEvent("ue_enable")


end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b5w_prc_reqpgm_v21
	Desc.	: 청구작업 절차 처리.
	Ver.	: 1.0
	Date	: 2006.03.08
	Programer : Park Kyung Hae(khpark)
--------------------------------------------------------------------------*/
String ls_parm,ls_module,ls_ref_desc
String ls_temp[]
Integer li_cnt

ls_ref_desc = This.Title
ls_module = "B5"	//임대고객청구관리

ls_parm = fs_get_control(ls_module, "S102", ls_ref_desc)		//Attendance - Cutoff Time(from)
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

type dw_cond from w_a_inq_m`dw_cond within b5w_prc_reqpgm_v21
integer x = 119
integer y = 56
integer width = 1440
integer height = 404
string dataobject = "b5d_cnd_reg_invcan_per_v21"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_cond::itemchanged;call super::itemchanged;//청구 주기 구하기
String ls_startdt
Date ld_startdt
Date ld_use_fr, ld_use_to
Long ll_cnt

If dwo.Name = "chargedt" THEN 
	
	//처음 시작하는것인지 Check
	Select count(chargedt) 
	Into :ll_cnt
	From reqpgm
	Where close_yn = 'Y'
	  and chargedt = :data;
	
	//청구기준일 구하기
	Select reqdt,unitcycle,reqcycle,
	       useddt_fr,useddt_to,
			 pre_useddt_fr,pre_useddt_to
	Into :id_reqdt,:is_unitcycle,:il_reqcycle,
	     :id_useddt_fr,:id_useddt_to,:id_pre_useddt_fr,:id_pre_useddt_to
	From reqconf 
	Where to_char(chargedt) = :data;	
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, "Select Error(REQCONF)")
		Return 
	End If
	
	//처음 시작하는것.
	If ll_cnt = 0 Then
		IF is_unitcycle = 'M' Then
			id_reqdt = fd_month_next(id_reqdt,il_reqcycle) //청구주기수 달 만큼 더한다
		   id_useddt_fr = relativedate(id_useddt_to,1)
			id_useddt_to = relativedate(fd_month_next(id_useddt_fr,il_reqcycle), -1)
		   id_pre_useddt_fr = relativedate(id_pre_useddt_to,1)
			id_pre_useddt_to = relativedate(fd_month_next(id_pre_useddt_fr,il_reqcycle),-1)
  		ElseIF is_unitcycle = 'D' Then
		   id_reqdt = relativedate(id_reqdt,il_reqcycle)
		   id_useddt_fr = relativedate(id_useddt_to,1)
			id_useddt_to = relativedate(id_useddt_fr,il_reqcycle - 1)
		   id_pre_useddt_fr = relativedate(id_pre_useddt_to,1)
			id_pre_useddt_to = relativedate(id_pre_useddt_fr,il_reqcycle - 1)
    	End IF
	End If
	
	//청구기준일
	is_reqdt = String(id_reqdt, 'yyyy-mm-dd')
	This.object.strdt[1] = is_reqdt
	is_chargedt = data
	
//	IF is_unitcycle = 'M' Then
//		//사용기간 시작일
//		ld_use_fr = fd_month_pre(id_reqdt,il_reqcycle)
//	ElseIF is_unitcycle = 'D' Then
//		//사용기간 시작일
//		ld_use_fr = relativedate(id_reqdt, -il_reqcycle)
//	End IF
//	//사용기간 종료일
//	ld_use_to = relativedate(id_reqdt, -1)	
	
	This.object.usedt[1] = String(id_useddt_fr, 'yyyy-mm-dd') + " ~~ " + String(id_useddt_to, 'yyyy-mm-dd')
	This.object.pre_useddt[1] = String(id_pre_useddt_fr, 'yyyy-mm-dd') + " ~~ " + String(id_pre_useddt_to, 'yyyy-mm-dd')
	
End If
end event

type p_ok from w_a_inq_m`p_ok within b5w_prc_reqpgm_v21
integer x = 1765
integer y = 48
end type

type p_close from w_a_inq_m`p_close within b5w_prc_reqpgm_v21
integer x = 2377
integer y = 48
boolean originalsize = false
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_prc_reqpgm_v21
integer width = 1627
integer height = 496
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_prc_reqpgm_v21
integer y = 512
integer width = 3822
integer height = 1552
string dataobject = "b5d_prc_reqpgm_v20"
boolean hscrollbar = false
end type

event dw_detail::retrieveend;long ll_currow
ll_currow = wfl_unfinished_first(dw_detail)
il_SelRowFrom = ll_currow
il_SelRowTo = ll_currow
SelectRow(0,False)
SelectRow( ll_currow, True )
ScrollToRow(ll_currow)
SetRow(ll_currow)


end event

event dw_detail::clicked;call super::clicked;long ll_currow,ll_delrow

If row > 0 and row >= il_SelRowFrom Then
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

type p_select from u_p_select within b5w_prc_reqpgm_v21
integer x = 2071
integer y = 48
boolean bringtotop = true
boolean originalsize = false
end type

