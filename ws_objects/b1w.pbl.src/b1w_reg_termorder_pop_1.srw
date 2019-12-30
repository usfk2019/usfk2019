$PBExportHeader$b1w_reg_termorder_pop_1.srw
$PBExportComments$[parkkh] 납입고객 전체고객 해지신청(위약그포함)
forward
global type b1w_reg_termorder_pop_1 from w_a_reg_m
end type
type p_termorder from commandbutton within b1w_reg_termorder_pop_1
end type
end forward

global type b1w_reg_termorder_pop_1 from w_a_reg_m
integer width = 3977
integer height = 1500
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event type integer ue_hotbill ( )
p_termorder p_termorder
end type
global b1w_reg_termorder_pop_1 b1w_reg_termorder_pop_1

type variables
String is_payid, is_paynm, is_term_where, is_term_status
String is_partner, is_termdt, is_termtype, is_pgm_id, is_return, is_prm_check
String is_act_status, is_enddt, is_act_gu, is_remark
Date id_termdt, id_enddt



end variables

forward prototypes
public function integer wf_svcorder_insert ()
end prototypes

event type integer ue_hotbill();//HotBilling 처리할 수 있는 고객인지 확인
String ls_useyn, ls_ref_desc, ls_hotbillflag, ls_termdt, ls_hotbill
Long li_rc
u_cust_a_msg    lu_cust_msg
dw_cond.AcceptText()

ls_hotbill = Trim(dw_cond.object.hotbill[1])
ls_useyn = fs_get_control("H0", "H101", ls_ref_desc)

Select hotbillflag into :ls_hotbillflag from customerm where customerid  = :is_payid;

If ls_useyn = "Y" and (IsNull(ls_hotbillflag) or ls_hotbillflag = "" ) and ls_hotbill = 'Y' Then
	   ls_termdt = String(dw_cond.object.termdt[1], 'yyyymmdd')
	   //Window Open
		lu_cust_msg = Create u_cust_a_msg
		lu_cust_msg.is_pgm_name = "Hotbilling Procuess"
		lu_cust_msg.is_grp_name = "해지신청"
		lu_cust_msg.is_data[1] = is_payid			   //납입고객 ID
		lu_cust_msg.is_data[2] = ls_termdt           //해지 신청 요청일
		lu_cust_msg.is_data[3] = is_pgm_id		      //프로그램 ID
		OpenWithParm(b1w_reg_hotreqdtl_pop, lu_cust_msg)
		
	//	li_rc = Message.DoubleParm
	
//		If li_rc < 0  Then 
//			Return -1
// 		Else
//			Return 0   //Hotbill 처리 성공
//		End If
		
		
End If

Destroy lu_cust_msg

Return 0
end event

public function integer wf_svcorder_insert ();Long ll_row, i, ll_seq, ll_cnt, ll_pc, ll_cnt1
String ls_contractseq, ls_pgm_id, ls_customerid, ls_svccod, ls_priceplan, ls_prmtype, ls_termtype
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_requestdt, ls_partner
String ls_status, ls_requestactive, ls_ref_desc, ls_termstatus, ls_customerid_1
Datetime ldt_crtdt
Dec{2} lc_amt[], lc_totalamt
Dec lc_basicamt, ldc_orderno
Int li_chk

ll_row = dw_detail.RowCount()
If ll_row = 0 Then Return -1   //error

ll_pc = 0

ls_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
ls_termstatus = fs_get_control("B0", "P201", ls_ref_desc)

If is_act_gu = 'Y' Then
	ls_status = is_act_status			//해지상태코드
Else
	ls_status = is_term_status			//해지신청상태코드
End If

For i =1 To ll_row

	ls_contractseq = string(dw_detail.object.contractmst_contractseq[i])

	ll_cnt = 0
	//해지신청내역 존재 여부 check
	Select count(orderno)
	 Into :ll_cnt
	 From svcorder
	Where to_char(ref_contractseq) = :ls_contractseq
	  and status = :is_term_status;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "SELECT svcorder")
		RollBack;
		Return -1
	End If	
	
	If ll_cnt > 0 Then
//		li_chk =  f_msg_ques_yesno2(9000, Title, "계약Seq [" + ls_contractseq + "]로 이미 해지신청이 등록되어 있습니다. ~R" + &
//		                                          "다음 계약Seq 해지신청을 계속 하시겠습니까?!", 1)
//		
//		If li_chk = 1 Then		//Yes
//			 continue
//		End If		 
		continue
	End If	
	
	//contractseq 가져 오기
	Select seq_orderno.nextval
	Into :ldc_orderno
	From dual;
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, "SELECT seq_orderno.nextval")
		RollBack;
		Return -1
	End If	
	
	ls_customerid = ""
	ls_svccod = ""
	ls_priceplan = ""
	ls_prmtype = ""
	ls_reg_partner = ""
	ls_sale_partner = ""
	ls_maintain_partner = ""
	ls_settle_partner = ""
	ls_prmtype = ""
	ls_customerid = Trim(dw_detail.object.contractmst_customerid[i])
	ls_svccod = Trim(dw_detail.object.contractmst_svccod[i])
	ls_priceplan = Trim(dw_detail.object.contractmst_priceplan[i])
	ls_prmtype = Trim(dw_detail.object.contractmst_prmtype[i])
	ls_reg_partner = Trim(dw_detail.object.contractmst_reg_partner[i])
	ls_sale_partner = Trim(dw_detail.object.contractmst_sale_partner[i])
	ls_maintain_partner = Trim(dw_detail.object.contractmst_maintain_partner[i])
	ls_settle_partner = Trim(dw_detail.object.contractmst_settle_partner[i])
 	ls_prmtype =	Trim(dw_detail.object.contractmst_prmtype[i])
	If IsNull(ls_customerid) Then ls_customerid = ""				
	If IsNull(ls_requestdt) Then ls_requestdt = ""						
	If IsNull(ls_svccod) Then ls_svccod = ""						
	If IsNull(ls_priceplan) Then ls_priceplan = ""						
	If IsNull(ls_prmtype) Then ls_prmtype = ""						
	If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
	If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
	If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
	If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
	If IsNull(ls_partner) Then ls_partner = ""						
	If IsNull(ls_requestdt) Then ls_requestdt = ""						
	
	//약정유형이 있을 경우 위약금 check procedure call 
	IF is_prm_check = '1' and ls_prmtype <> ""  Then
		
		String ls_errmsg
		Long ll_return, ll_count
		Double ld_count
		
		ll_return = -1
		ls_errmsg = space(256)
		
		//처리부분...
		SQLCA.B1CALCPENALTY(ls_customerid,ls_contractseq,datetime(id_termdt),string(ldc_orderno),gs_user_id,is_pgm_id,ll_return,ls_errmsg, ld_count)
		If SQLCA.SQLCode < 0 Then		//For Programer
			MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
			Return -1
		ElseIf ll_return < 0 Then	//For User
			MessageBox(Title, ls_errmsg, StopSign!)
			Return -1
		End If

		If ll_return <> 0 Then	//실패
			Return -1
		End If		
	END If		

	ldt_crtdt = fdt_get_dbserver_now()
	
	//Insert
	insert into svcorder
		 ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
			prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt, remark )
	values ( :ldc_orderno, :ls_customerid, sysdate, to_date(:is_termdt,'yyyy-mm-dd'), :ls_status, :ls_svccod, :ls_priceplan,
			:ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_partner,
			:ls_contractseq, :is_termtype, :gs_user_id, sysdate, :is_pgm_id, :gs_user_id, sysdate, :is_remark);

	//저장 실패 
	If SQLCA.SQLCode < 0 Then
		RollBack;
		f_msg_info(3010, Title,"Svcorder Insert")
		Return -1
	End If	
	
	ll_pc ++
	
	//해지처리루틴
	If is_act_gu = 'Y' Then 
	
		  //서비스 개통 상태 갯수 확인	 
		  Select count(contractseq) 
		   Into :ll_cnt
		   From contractmst 
		  Where customerid = :ls_customerid and status <> :is_act_status;
		  
		  If SQLCA.SQLCode < 0 Then
			  f_msg_sql_err(Title, " SELECT Error(CONTRACTMST)")
			  Return -1
		  End If
		  
		 //마시막 서비스 해지 하려 하면 
		 //가입자로 들어있는 고객 확인
		 If ll_cnt = 1 Then	
			//납입 고객일 경우 
			If ls_customerid = is_payid  Then
				Select cus.customerid
				Into :ls_customerid_1
				From customerm cus, contractmst cnt
				Where cus.customerid = cnt.customerid And
						cus.payid = :is_payid and cnt.customerid <> :ls_customerid and
						cnt.status <> :is_act_status and rownum = 1;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(title, "SELECT Error(CUSTOMERM)")
					Return  -1
				End If
				
				If IsNull(ls_customerid_1) Then ls_customerid_1  = ""
				If ls_customerid_1 <> "" Then
					
					f_msg_usr_err(9000, title , "납입고객 : " + is_payid + " 에 " + &
															 "포함되는 ~r가입고객 : " + ls_customerid_1 + "이 존재합니다. ~r" + &
															 "먼저 가입고객의 서비스를 해지하십시오.")
					Return -1
				End If
			End If	
		End If	
			
			//해지처리.
			//contractmst Update
			Update contractmst 
			Set  status = :ls_status,
				 termdt = to_date(:is_termdt, 'yyyy-mm-dd'),
				 bil_todt = to_date(:is_enddt, 'yyyy-mm-dd'),
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :is_pgm_id
			Where to_char(contractseq) = :ls_contractseq;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " Update Error(CONTRACTMST)")
				Rollback;
				Return  -1
			End If
			
			//인증 정보 Update
		   Update validinfo
			Set todt = nvl(todt,to_date(:is_termdt, 'yyyy-mm-dd')),
				status = :ls_status,
				use_yn = 'N',
				updt_user = :gs_user_id,
				updtdt = sysdate,
				pgm_id = :is_pgm_id
			Where to_char(contractseq) = :ls_contractseq;
		  
		  If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(title, " Update Error(VALIDINFO)")
				Rollback;
				Return  -1
		  End If
		  
		   //서비스 개통 상태 갯수 확인	 
		  Select count(contractseq) 
		  Into :ll_cnt
		  From contractmst 
		  Where customerid = :ls_customerid and status <> :ls_status;
		  
		  If SQLCA.SQLCode < 0 Then
			  f_msg_sql_err(title,  " SELECT Error(CONTRACTMST)")
			  Return -1
		  End If
		  
		  //현 신청 상태 확인
		  Select count(orderno)
		  Into :ll_cnt1
		  From svcorder
		  Where customerid = :ls_customerid and status = :ls_requestactive;
		  
		  If SQLCA.SQLCode < 0 Then
			  f_msg_sql_err(title, " SELECT Error(SVCORDER)")
			  Return -1
		  End If
		  
		 //고객 해지 처리
		 If ll_cnt = 0 and ll_cnt1	= 0 Then
				
				Update customerm
				Set status = :ls_termstatus,
					termtype = :is_termtype,
					updt_user = :gs_user_id,
					updtdt = sysdate,
					pgm_id = :is_pgm_id
				Where customerid = :ls_customerid;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(title, " Update Error(CUSTOMERM)")
					Rollback;
					Return  -1
				End If
		End If	
	End If
Next

If ll_pc > 0 Then
	Commit;
	//Hotbill 처리 루틴
	Trigger Event ue_hotbill()
	f_msg_info(9000, title, "납입고객 [" + is_payid + "] 소속 " + &
								" 총 [" + String(ll_pc) + "]건이 해지신청 완료되었습니다.")
ElseIf ll_pc = 0 Then
	f_msg_info(9000, title, "납입고객 [" + is_payid + "] 소속 " + &
								   "모든 고객이 이미 해지신청 되어 있습니다.")
End if

Return 0
end function

on b1w_reg_termorder_pop_1.create
int iCurrent
call super::create
this.p_termorder=create p_termorder
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_termorder
end on

on b1w_reg_termorder_pop_1.destroy
call super::destroy
destroy(this.p_termorder)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_termorder_pop
	Desc	: 	서비스해지신청
	Ver.	:	1.0
	Date	: 	2002.10.08
	programer : park kyung hae(parkkh)
-------------------------------------------------------------------------*/
Long ll_row
String ls_where

is_payid = ""
is_paynm = ""
is_term_where = ""
is_term_status = ""
is_return = "N"

//window 중앙에
f_center_window(b1w_reg_termorder_pop_1)

is_payid = iu_cust_msg.is_data[1]   		//납입고객ID
is_pgm_id = iu_cust_msg.is_data[2]   		//프로그램 id
is_term_where = iu_cust_msg.is_data[3]   	//해지가능고객 where문
is_term_status = iu_cust_msg.is_data[4]  	//해지신청상태코드
is_act_status  = iu_cust_msg.is_data[9]  	//해지상태코드

dw_cond.object.payid[1] = is_payid
dw_cond.object.paynm[1] = is_payid

If isnull(iu_cust_msg.is_data[5]) or iu_cust_msg.is_data[5] = "" Then
Else

	dw_cond.object.termdt[1] = date(iu_cust_msg.is_data[5])
End if

If isnull(iu_cust_msg.is_data[6]) or iu_cust_msg.is_data[6] = "" Then
Else
	dw_cond.object.termtype[1] = iu_cust_msg.is_data[6]
End if

If isnull(iu_cust_msg.is_data[7]) or iu_cust_msg.is_data[7] = "" Then
Else
	dw_cond.object.partner[1] = iu_cust_msg.is_data[7]
End if

If isnull(iu_cust_msg.is_data[8]) or iu_cust_msg.is_data[8] = "" Then
Else
	dw_cond.object.prm_check[1] = iu_cust_msg.is_data[8]
End if

//과금종료일
If isnull(iu_cust_msg.is_data[10]) or iu_cust_msg.is_data[10] = "" Then
Else
	dw_cond.object.enddt[1] = date(iu_cust_msg.is_data[10])
End if

//과금종료일
If isnull(iu_cust_msg.is_data[11]) or iu_cust_msg.is_data[11] = "" Then
Else
	dw_cond.object.act_gu[1] = iu_cust_msg.is_data[11]
End if

//retrieve
ls_where = " customerm.payid = '" + is_payid + "' And ( " + is_term_where + " ) "  

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
End If

dw_cond.Enabled = True
dw_cond.SetFocus()
end event

event ue_ok();String ls_where
Long ll_row

ls_where = " customerm.payid = '" + is_payid + "' And ( " + is_term_where + " ) "  
	
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")
	Return
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
    Return
End If

dw_cond.Enabled = True
dw_cond.SetFocus()
end event

event resize;call super::resize;//해지신청 버튼 위치 자동조정 추가

//If sizetype = 1 Then Return
//
//SetRedraw(False)
//
//If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
//	p_termorder.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
//Else
//	p_termorder.Y	= newheight - iu_cust_w_resize.ii_button_space
//End If
//
//SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_termorder_pop_1
integer x = 41
integer y = 44
integer width = 3218
integer height = 316
integer taborder = 10
string dataobject = "b1dw_cnd_reg_termorder_pop"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_termorder_pop_1
integer x = 3328
integer y = 64
end type

type p_close from w_a_reg_m`p_close within b1w_reg_termorder_pop_1
integer x = 3634
integer y = 64
boolean originalsize = false
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_termorder_pop_1
integer width = 3246
integer height = 380
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_termorder_pop_1
boolean visible = false
integer x = 50
integer y = 1432
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_termorder_pop_1
boolean visible = false
end type

type p_save from w_a_reg_m`p_save within b1w_reg_termorder_pop_1
boolean visible = false
integer x = 2482
integer y = 132
integer height = 168
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_termorder_pop_1
integer y = 388
integer width = 3904
integer height = 1000
integer taborder = 20
string dataobject = "b1dw_reg_termorder_pop"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_termorder_pop_1
boolean visible = false
integer x = 2757
integer y = 124
boolean enabled = true
end type

type p_termorder from commandbutton within b1w_reg_termorder_pop_1
integer x = 3438
integer y = 200
integer width = 347
integer height = 88
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "해지신청"
end type

event clicked;String ls_where, ls_max_activedt, ls_act_yn, ls_sysdt, ls_hotbill_yn
String ls_nextdate
Long ll_row, ll_cur_row, ll_detail_row
Int li_i, li_rc

SetPointer(HourGlass!)

If dw_cond.AcceptText() < 0 Then
	dw_cond.SetFocus()
	SetPointer(Arrow!)	
	Return -1
End If

is_partner = Trim(dw_cond.object.partner[1])
id_termdt = dw_cond.object.termdt[1]
is_termdt = string(id_termdt,'yyyymmdd')
is_termtype = dw_cond.object.termtype[1]
ls_max_activedt = String(dw_detail.object.max_activedt[1],'yyyymmdd')
is_prm_check = dw_cond.object.prm_check[1]
is_act_gu = dw_cond.Object.act_gu[1]
id_enddt = dw_cond.object.enddt[1]
is_enddt = string(id_enddt,'yyyymmdd')
ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
is_remark = Trim(dw_cond.object.remark[1])
ls_hotbill_yn = dw_cond.Object.hotbill[1]

//Null Check
If IsNull(is_partner) Then is_partner = ""
If IsNull(is_termdt) Then is_termdt = ""
If IsNull(is_termtype) Then is_termtype = ""
If IsNull(is_prm_check) Then is_prm_check = '0'
If IsNull(ls_max_activedt) Then ls_max_activedt = ""
If IsNull(is_enddt) Then is_enddt = ""
If IsNull(is_act_gu) Then is_act_gu = ""
If IsNull(ls_hotbill_yn) Then ls_hotbill_yn = ""

If is_termdt = "" Then
	f_msg_usr_err(200, Title, "해지요청일")
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	SetPointer(Arrow!)	
	Return -1
End If

If is_termdt <= ls_sysdt Then
	f_msg_usr_err(213,Title + "today:" +  MidA(ls_sysdt, 1,4) + "-" + &
															MidA(ls_sysdt,5,2) + "-" + &
															MidA(ls_sysdt,7,2),"해지요청일")

	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	SetPointer(Arrow!)	
	Return -1
End If		

If is_termdt < ls_max_activedt Then
	f_msg_usr_err(210, Title, "'해지요청일은 아래 자료의 개통일 중~r~n~r~n가장 큰 날짜보다는 커야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	SetPointer(Arrow!)	
	Return -1
End If		

If fb_reqdt_check(Title,is_payid,is_termdt,"해지요청일") Then
Else
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")
	Return -1
End If

If is_termtype = "" Then
	f_msg_usr_err(200, Title, "해지사유")
	dw_cond.SetFocus()
	dw_cond.SetColumn("termtype")
	SetPointer(Arrow!)	
	Return -1
End If

If is_partner = "" Then
	f_msg_usr_err(200, Title, "수행처")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	SetPointer(Arrow!)	
	Return -1
End If

If ls_hotbill_yn = 'Y' Then

	If is_act_gu <> 'Y' Then
		f_msg_usr_err(200, Title, "해지처리확정Check(Hotbill처리Check시)")
		dw_cond.SetFocus()
		dw_cond.SetColumn("act_gu")
		SetPointer(Arrow!)	
		Return -1
	End IF
	
    ls_nextdate = string(relativedate(date(fdt_get_dbserver_now()),1),'yyyymmdd')	
    If ls_nextdate < is_termdt Then
		f_msg_usr_err(212,Title + "today:" +  MidA(ls_nextdate, 1,4) + "-" + &
											  MidA(ls_nextdate,5,2) + "-" + &
											  MidA(ls_nextdate,7,2),"해지요청일(during Hotbill Process)")

		dw_cond.SetFocus()
		dw_cond.SetColumn("termdt")
		SetPointer(Arrow!)	
		Return -1	
	End IF
	
	If is_enddt = "" Then
		f_msg_usr_err(200, Title, "과금종료일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("enddt")
		SetPointer(Arrow!)	
		Return -1
	End If
	
    If ls_sysdt < is_enddt Then
		f_msg_usr_err(212,Title + "today:" +  MidA(ls_sysdt, 1,4) + "-" + &
											  MidA(ls_sysdt,5,2) + "-" + &
											  MidA(ls_sysdt,7,2),"과금종료일(during Hotbill Process)")

		dw_cond.SetFocus()
		dw_cond.SetColumn("enddt")
		SetPointer(Arrow!)	
		Return -1	
	End IF
	
End IF

If is_act_gu = 'Y' Then

	If is_enddt = "" Then
		f_msg_usr_err(200, Title, "과금종료일")
		dw_cond.SetFocus()
		dw_cond.SetColumn("enddt")
		SetPointer(Arrow!)	
		Return -1
	End If
	
	//해지 할 수 있는지 권한 여부 
	Select act_yn
	Into :ls_act_yn
	From partnermst
	Where partner = :gs_user_group;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " SELECT Error(PARTNERMST)")
		Return  -1
	End If
				
	If ls_act_yn = "N" Then
		f_msg_usr_err(9000, title, "해지처리 할 수 없는 수행처입니다.")
		Return -1
	End If
				
End If

//Hotbill 처리 루틴
//li_rc = Trigger Event ue_hotbill()

//If li_rc >= 0 Then
	
If wf_svcorder_insert() < 0 Then
	dw_cond.SetFocus()
	dw_cond.SetColumn("termdt")	
	SetPointer(Arrow!)	
	Return -1
End If

dw_cond.object.termdt.protect = 1
dw_cond.object.termtype.protect = 1
dw_cond.object.partner.protect = 1
dw_cond.object.prm_check.protect = 1
dw_cond.object.enddt.protect = 1
dw_cond.object.act_gu.protect = 1

p_termorder.Enabled = False
is_return = "Y"

SetPointer(Arrow!)

//End If

Return 0
end event

