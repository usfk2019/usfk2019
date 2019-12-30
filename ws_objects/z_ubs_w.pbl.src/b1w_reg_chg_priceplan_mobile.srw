$PBExportHeader$b1w_reg_chg_priceplan_mobile.srw
$PBExportComments$모바일 가격정책변경
forward
global type b1w_reg_chg_priceplan_mobile from w_a_reg_m_m3
end type
type dw_validkey from u_d_base within b1w_reg_chg_priceplan_mobile
end type
type dw_old from datawindow within b1w_reg_chg_priceplan_mobile
end type
type st_horizontal3 from st_horizontal within b1w_reg_chg_priceplan_mobile
end type
type cb_1 from commandbutton within b1w_reg_chg_priceplan_mobile
end type
end forward

global type b1w_reg_chg_priceplan_mobile from w_a_reg_m_m3
integer width = 3186
integer height = 2176
dw_validkey dw_validkey
dw_old dw_old
st_horizontal3 st_horizontal3
cb_1 cb_1
end type
global b1w_reg_chg_priceplan_mobile b1w_reg_chg_priceplan_mobile

type variables
String is_active
String is_term, is_amt_check
end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
public function integer wf_itemcod_chk ()
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기]
	Date	: 2002.10.01
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_customernm
Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
Return 0
end function

public function integer wf_itemcod_chk ();Long    	ll_row, 					ll_gubun[], 	ll_type[], 	ll_cnt, 	ll_cnt_1
Integer 	li_rc, 					i
String  	ls_chk
Boolean 	ib_jon, 					ib_jon_1, &
			lb_check 	= False, &
			lb_check_2 	= False
String 	ls_addition_code[], 	ls_callforward_info

ib_jon   = False
ib_jon_1 = False

ll_cnt 					= 0
//is_callforward_type 	= ''
ls_callforward_info 	= 'N'

For i = 1 To dw_detail.RowCount()
	ll_gubun[i]      = dw_detail.Object.groupno[i]
	ll_type[i]       = dw_detail.Object.grouptype[i]
	ls_chk           = dw_detail.Object.chk[i]	
	If ls_chk = 'Y' Then			ll_cnt ++
	IF ll_type[i] = 1 Then
		ib_jon   = True
	Else
		ib_jon_1 = True
	End If
	
//	//2005-07-06 khpark add start     //착신전환부가서비스 check
//	IF ls_chk = 'Y' Then
//		ls_addition_code[i] = dw_detail.object.itemmst_addition_code[i]
//		CHOOSE CASE ls_addition_code[i]    
//			CASE is_callforward_code[1],is_callforward_code[2],is_callforward_code[3]   //착신전환유형일때 
//				//착신전환부가서비스 품목은 하나만 선택 가능하다.
//				IF ls_callforward_info = 'Y' Then
//					f_msg_info(9000, Title, "품목구성이 올바르지않습니다.(착신전환부가서비스품목하나이상선택)")						
//					return -2
//				End IF
//				is_callforward_type =  ls_addition_code[i]
//				is_addition_itemcod =  dw_detail.object.itemcod[i]
//				ls_callforward_info = 'Y'
//		END CHOOSE	
//   End IF
//   //2005-07-06 khpark add end		
   
Next

If ll_cnt = 0 Then
	f_msg_info(9000, Title, "품목을 선택하여야 합니다.")	
	Return  -2
End If

ll_cnt   = 0
ll_cnt_1 = 0
ls_chk   = ''

//동일 그룹일때 선택유형이 0이면 하나만 선택해야하고 동일 그룹일때 선택유형이 1이면 하나 이상  선택하여야한다.
//선택유형이 0인것중 group이  여러종류로 구성되어있다면..각동일그룹에서 하나씩만 선택되어야한다.
long cnt = 0, t, cnt_group = 0
For i = 1 To UpperBound(ll_gubun)  
	If ll_type[i] = 0 Then 
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If dw_detail.Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group 중 한개 품목은 필수로 선택하셔야 하는 품목이 있습니다.")	
			Return -2	
		ElseIf cnt > 1 Then			
			f_msg_info(9000, Title, "동일Group 중 한개 품목만 필수로 선택하셔야 하는 품목이 있습니다.")	
			Return -2
		End If
		cnt = 0
	ElseIf ll_type[i] = 1 Then
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If dw_detail.Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group중 한 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2		
		End If
		cnt = 0
	ElseIf ll_type[i] = 2 Then
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				If dw_detail.Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt = 0 Then
			f_msg_info(9000, Title, "동일Group중 두 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2			
		ElseIf cnt < 2 Then
			f_msg_info(9000, Title, "동일Group중 두 품목 이상 선택해야하는 품목이 있습니다.")	
			Return -2
		End If
		cnt = 0	
	//2013.04.22 by hmk start
	//동일품목모두선택필수 추가 RQ-UBS-201304-02 근거
	ElseIf ll_type[i] = 8 Then  //동일품목모두선택필수 
		For t = 1 To UpperBound(ll_gubun)  
			If ll_gubun[i] = ll_gubun[t] Then
				cnt_group++
				If dw_detail.Object.chk[t] = 'Y' Then
					cnt ++
				End If
			End If
		Next                                             
		If cnt <> cnt_group Then
			f_msg_info(9000, Title, "동일Group중 모두 선택이 필수인 품목이 있습니다.")	
			Return -2			
		End If
		cnt = 0
		cnt_group = 0
   ElseIf ll_type[i] = 9 Then  //제한없음
	    //액션없음
	//2013.04.22 by hmk end
	End If
Next


return 1   //정상 return
end function

on b1w_reg_chg_priceplan_mobile.create
int iCurrent
call super::create
this.dw_validkey=create dw_validkey
this.dw_old=create dw_old
this.st_horizontal3=create st_horizontal3
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_validkey
this.Control[iCurrent+2]=this.dw_old
this.Control[iCurrent+3]=this.st_horizontal3
this.Control[iCurrent+4]=this.cb_1
end on

on b1w_reg_chg_priceplan_mobile.destroy
call super::destroy
destroy(this.dw_validkey)
destroy(this.dw_old)
destroy(this.st_horizontal3)
destroy(this.cb_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	bw1_reg_chg_priceplan
	Desc	:	가격정책 변경
	Ver.	:	1.0
	Date	:	2002.10.12
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_name[], ls_status
is_active = ""
is_term = ""
is_amt_check = 'N'

//개통 상태코드
ls_ref_desc =""
is_active = fs_get_control("B0", "P223", ls_ref_desc)

//해지 상태코드
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_term = ls_name[2]

PostEvent("resize")

end event

event ue_ok;call super::ue_ok;//조회
String ls_customerid, ls_where
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
If IsNull(ls_customerid) Then ls_customerid = ""
If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	 ll_row = wfi_get_customerid(ls_customerid)  //올바른 고객인지 확인	 
	 If ll_row = -1 Then  Return
End If

ls_where = "con.customerid = '" + ls_customerid + "' "
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
Else
	dw_master.event ue_select()
End If

Return 
	


end event

event ue_extra_save;b1u_dbmgr 	lu_dbmgr
Integer li_rc
String ls_where, ls_contractseq
Long ll_row, ll_row_det
lu_dbmgr = Create b1u_dbmgr

dw_validkey.reset()


//NEW 가격정책 선택시 grouptype 에 따른 제한 사항 설정 제어
ll_row_det  = dw_detail.RowCount()
If ll_row_det > 0 Then
	ai_return = wf_itemcod_chk()
	IF ai_return <= 0 Then
		return
	End IF
End If
//


//khpark add (가격정책 변경 시 변경전 계약건의 조건에 맞는
//			  validkey정보를  update 하기전에 retrieve해서 가지고 있다가 insert 하기 위해)
ls_contractseq = string(dw_detail2.object.contractmst_contractseq[1])

ls_where = " use_yn = 'Y' and status = '" + is_active + "'" + &
		   " and to_char(contractseq) = '" + String(ls_contractseq) + "'"
		   
dw_validkey.is_where = ls_where
ll_row = dw_validkey.Retrieve()
If ll_row < 0 Then
   f_msg_usr_err(2100, Title, "dw_validkey Retrieve()")
   Return
End If

lu_dbmgr.is_caller = "b1w_reg_chg_priceplan_2%save"
lu_dbmgr.is_title = Title
lu_dbmgr.is_data[1] = is_active
lu_dbmgr.is_data[2] = is_term
lu_dbmgr.is_data[3] = gs_user_group
lu_dbmgr.is_data[4] = gs_user_id
lu_dbmgr.is_data[5] = gs_pgm_id[gi_open_win_no]
lu_dbmgr.idw_data[1] = dw_detail2
lu_dbmgr.idw_data[2] = dw_detail
lu_dbmgr.idw_data[3] = dw_validkey   //khpark add
lu_dbmgr.idw_data[4] = dw_old			 //jhchoi add

lu_dbmgr.uf_prc_db_04()
li_rc = lu_dbmgr.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr
	ai_return = li_rc
	Return 
End If

Destroy lu_dbmgr
ai_return = 0

Return 
end event

event type integer ue_save();Int 		li_return, 		i,						ii
LONG		ll_row,			ll_row2
DEC{2}	ldc_total,		ldc_total_old,		ldc_basicamt,	ldc_basicamt_old
STRING	ls_chk,			ls_quota_yn,		ls_onefee,		ls_bil,				ls_itemcod
STRING	ls_chk_old,		ls_quota_yn_old,	ls_onefee_old,	ls_bil_old,			ls_itemcod_old
STRING	ls_priceplan,	ls_priceplan_old,	ls_reqdt,		ls_reqdt_old,		ls_svccod
STRING	ls_customerid
Boolean 	lb_direct

ii_error_chk = -1

IF dw_master.AcceptText() < 0 Then
	dw_master.SetFocus()
	Return -1
END IF

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

ls_svccod			= dw_master.Object.svccod[dw_master.GetRow()]
ls_priceplan_old	= dw_master.Object.priceplan[dw_master.GetRow()]
ls_reqdt_old		= dw_master.Object.bil_dt[dw_master.GetRow()]
ls_priceplan		= dw_detail2.Object.chg_priceplan[dw_detail2.GetRow()]
ls_reqdt				= STRING(dw_detail2.Object.reqdt[dw_detail2.GetRow()], 'yyyymmdd')

This.Trigger Event ue_extra_save(li_return)

IF ls_svccod = '110BS' THEN			//번들만...
	IF li_return = 0 THEN
	//=========================================
	//즉시불 처리 항목 여부 check
	// bilitem_yn = 'N' AND oneoffcharge_yn = 'Y'
	//=========================================
		lb_direct =  False
		iu_cust_msg = Create u_cust_a_msg
		ll_row  = dw_detail.RowCount()
		ll_row2 = dw_old.RowCount()	
		
		ldc_total = 0
		ldc_total_old = 0
		For i = 1 To ll_row
			ls_chk 		= Trim(dw_detail.object.chk[i])
			ls_quota_yn = Trim(dw_detail.object.quota_yn[i])
			ls_onefee 	= Trim(dw_detail.object.ONEOFFCHARGE_YN[i])
			ls_bil 		= Trim(dw_detail.object.bilitem_yn[i])
			ls_itemcod  = Trim(dw_detail.object.itemcod[i])
			
			If ls_chk = "Y" AND ls_onefee = "Y" and ls_bil = 'N' Then
				
				ldc_basicamt = 0
				select unitcharge  INto :ldc_basicamt
				from   priceplan_rate2
				where  priceplan = :ls_priceplan
				AND    itemcod   = :ls_itemcod
				AND    to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
																	FROM   priceplan_rate2
																	WHERE  priceplan = :ls_priceplan
																	AND    itemcod	  = :ls_itemcod
																	AND    to_char(fromdt, 'yyyymmdd') <= :ls_reqdt ) ;
																	
				IF Isnull(ldc_basicamt) THEN ldc_basicamt = 0
				
				ldc_total = ldc_total + ldc_basicamt			
			End If
		Next
		
		For ii = 1 To ll_row2
			ls_chk_old		 = Trim(dw_old.object.chk[ii])
			ls_quota_yn_old = Trim(dw_old.object.quota_yn[ii])
			ls_onefee_old   = Trim(dw_old.object.ONEOFFCHARGE_YN[ii])
			ls_bil_old 		 = Trim(dw_old.object.bilitem_yn[ii])
			ls_itemcod_old  = Trim(dw_old.object.itemcod[ii])
			
			If ls_chk_old = "Y" AND ls_onefee_old = "Y" and ls_bil_old = 'N' Then
				
				ldc_basicamt_old = 0
				select unitcharge  INto :ldc_basicamt_old
				from   priceplan_rate2
				where  priceplan = :ls_priceplan_old
				AND    itemcod   = :ls_itemcod_old
				AND    to_char(fromdt, 'yyyymmdd') = ( select MAX(to_char(fromdt, 'yyyymmdd'))
																	FROM   priceplan_rate2
																	WHERE  priceplan = :ls_priceplan_old
																	AND    itemcod	  = :ls_itemcod_old
																	AND    to_char(fromdt, 'yyyymmdd') <= :ls_reqdt_old ) ;
																	
				IF Isnull(ldc_basicamt_old) THEN ldc_basicamt_old = 0
				
				ldc_total_old = ldc_total_old + ldc_basicamt_old																
				
			End If
		Next			
		
		IF ldc_total <> ldc_total_old THEN
			lb_direct = TRUE
		END IF
		
		If lb_direct Then			//즉시불 처리
			ls_customerid 	= Trim(dw_cond.object.customerid[1])
			iu_cust_msg.is_pgm_name = "가격정책 변경 즉시불 등록"
			iu_cust_msg.is_grp_name = "서비스 신청"
			iu_cust_msg.ib_data[1]  = True
			iu_cust_msg.is_data[1] 	= ls_customerid				//customer ID
			iu_cust_msg.is_data[2] 	= gs_pgm_id[gi_open_win_no]//Pgm ID
			iu_cust_msg.is_data[3] 	= ls_reqdt_old					//member ID
			iu_cust_msg.is_data[4] 	= ls_reqdt 						//
			iu_cust_msg.is_data[5] 	= ls_priceplan_old			//가격정책_old
			iu_cust_msg.is_data[6] 	= ls_priceplan					//가격정책			
			iu_cust_msg.is_data[7] 	= ls_svccod 					//서비스
			iu_cust_msg.idw_data[1] = dw_old
			iu_cust_msg.idw_data[2] = dw_detail		
			OpenWithParm(ubs_w_pop_priceplanpayment, iu_cust_msg)
			
			IF iu_cust_msg.ib_data[1] THEN
				is_amt_check = iu_cust_msg.is_data[1]
			END IF
			
			IF is_amt_check = 'N' THEN
				li_return = -1
			END IF			
		END IF
	END IF
END IF	
	
If li_return = -1  Then
//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return  -1
	End If
	f_msg_info(3010,This.Title,"가격정책 변경")
	Return -1
ElseIf li_return = 0 Then
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If
	f_msg_info(3000,This.Title,"가격정책 변경")
ElseIf li_return  = -2 Then
	Return -1
	
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
ls_customerid = Trim(dw_cond.object.customerid[1])

dw_detail.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.object.customerid[1] = ls_customerid

Trigger Event ue_ok()

ii_error_chk = 0

Return 0
end event

event ue_reset();Int li_rc, li_ret
Long ll_row
String ls_status 
ii_error_chk = -1

ll_row = dw_master.GetSelectedRow(0)
If ll_row <= 0 Then  Return


//상태 코드 
ls_status = Trim(dw_master.object.status[1])


dw_detail.AcceptText()

If ls_status = is_active Then
	If dw_detail.ModifiedCount() > 0 or &
		dw_detail.DeletedCount() > 0 or &
		dw_detail2.ModifiedCount() > 0 or &
		dw_detail2.DeletedCount() > 0 then
		
		li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
		CHOOSE CASE li_ret
			CASE 1
				li_ret = -1 
				li_ret = Event ue_save()
				If Isnull( li_ret ) or li_ret < 0 then return
			CASE 2
	
			CASE ELSE
				Return 
		END CHOOSE
			
	end If

End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_old.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)

//
ii_error_chk = 0
is_amt_check = 'N'

dw_cond.SetFocus()
dw_cond.Enabled = True
dw_cond.SetColumn("memberid")



end event

event resize;call super::resize;CALL w_a_m_master::resize

dw_cond.SetFocus()
dw_cond.Setrow(1)
dw_cond.SetColumn("MEMBERID")

SetRedraw(True)




end event

type dw_cond from w_a_reg_m_m3`dw_cond within b1w_reg_chg_priceplan_mobile
integer x = 37
integer y = 44
integer width = 1527
integer height = 184
integer taborder = 10
string dataobject = "b1dw_cnd_reg_chg_priceplan_mobile"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
			 dw_cond.object.memberid[row] = &
			 dw_cond.iu_cust_help.is_data[4]
		End If
End Choose
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_customerid, ls_customernm
Choose Case dwo.name
	Case "memberid"
		select customerid, customernm INTO :ls_customerid, :ls_customernm
		FROM customerm
		WHERE memberid = :data ;
		
		IF IsNull(ls_customerid) OR sqlca.sqlcode <> 0 THEN ls_customerid = ''
		IF IsNull(ls_customernm) OR sqlca.sqlcode <> 0 THEN ls_customernm = ''
		
		 dw_cond.Object.customerid[row] = ls_customerid
		 dw_cond.object.customernm[row] = ls_customernm
End Choose
end event

type p_ok from w_a_reg_m_m3`p_ok within b1w_reg_chg_priceplan_mobile
integer x = 1728
integer y = 40
end type

type p_close from w_a_reg_m_m3`p_close within b1w_reg_chg_priceplan_mobile
integer x = 2043
integer y = 40
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b1w_reg_chg_priceplan_mobile
integer width = 1577
integer height = 248
integer taborder = 0
end type

type dw_master from w_a_reg_m_m3`dw_master within b1w_reg_chg_priceplan_mobile
integer y = 260
integer width = 3081
integer height = 416
integer taborder = 20
string dataobject = "b1dw_inq_chg_priceplan_mobile"
end type

event dw_master::ue_select();call super::ue_select;Long ll_selected_row 
Integer li_return, li_ret


ll_selected_row = GetSelectedRow( 0 )

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = Parent.Event ue_save()
			If isnull( li_ret ) or li_ret < 0 then return
		CASE 2
		CASE ELSE
			Return
	END CHOOSE
		
end If


//순서 바꿈
dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If
	
//dw_detail.Event ue_retrieve(ll_selected_row,li_return)
//If li_return < 0 Then
//	Return
//End If

end event

event dw_master::clicked;call super::clicked;String ls_status, ls_priceplan, ls_where,	ls_contractseq
Long ll_row

If row = 0 Then Return 0

ls_status      = Trim(dw_master.object.status[row])
ls_priceplan   = Trim(dw_master.object.priceplan[row])
ls_contractseq = STRING(dw_master.object.contractseq[row])

//개통상태가 아니면
If ls_status <> is_active Then
	p_save.TriggerEvent("ue_disable")
Else
	p_save.TriggerEvent("ue_enable")
End If

//가격 정책이 바뀌었을때 변경전 품목을 보여줌
ll_row = dw_old.Retrieve(ls_priceplan, LONG(ls_contractseq))

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "PricePlan(OLD) Retrieve()")
	Return -2
End If


end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::retrieveend;call super::retrieveend;String ls_status, ls_priceplan, ls_where, ls_contractseq
Long ll_row

If rowcount = 0 Then Return 0

ls_status   	= Trim(dw_master.object.status[1])
ls_priceplan	= Trim(dw_master.object.priceplan[1])
ls_contractseq = STRING(dw_master.object.contractseq[1])

//개통상태가 아니면
If ls_status <> is_active Then
	p_save.TriggerEvent("ue_disable")
Else
	p_save.TriggerEvent("ue_enable")
End If

//가격 정책이 바뀌었을때 변경전 품목을 보여줌
ll_row = dw_old.Retrieve(ls_priceplan, LONG(ls_contractseq))

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "PricePlan(OLD) Retrieve()")
	Return -2
End If
end event

type dw_detail from w_a_reg_m_m3`dw_detail within b1w_reg_chg_priceplan_mobile
integer y = 1200
integer width = 3081
integer height = 676
integer taborder = 40
string dataobject = "b1dw_reg_chg_priceplan_mobile_new"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;Long i
String ls_mainitem_yn, ls_quota_yn

If rowcount = 0 Then
	p_save.TriggerEvent("ue_disable")
End If


For i = 1 To rowcount 
	
	ls_mainitem_yn = Trim(dw_detail.object.mainitem_yn[i])
	ls_quota_yn    = Trim(dw_detail.object.quota_yn[i])
	
	If IsNull(ls_mainitem_yn) Or ls_mainitem_yn = "" Then ls_mainitem_yn = "N"
	If IsNull(ls_quota_yn)    Or ls_quota_yn    = "" Then ls_quota_yn    = "N"

	
	
	dw_detail.object.chk[i] = "Y" 
//	If dw_detail.object.mainitem_yn[i] = "Y" Then
//		dw_detail.object.itemcod.Color = RGB(255,0,255)
//		dw_detail.object.itemnm.Color = RGB(255,0,255)
//		dw_detail.object.quota_yn.Color = RGB(255,0,255)
//		dw_detail.object.chk.Color = RGB(255,0,255)
//	Else
//		dw_detail.object.itemcod.Color = RGB(0,0,0)
//		dw_detail.object.itemnm.Color = RGB(0,0,0)
//		dw_detail.object.quota_yn.Color = RGB(0,0,0)
//		dw_detail.object.chk.Color = RGB(0,0,0)
//	End If
dw_detail.SetItemStatus(i, 0 , Primary!,NotModified!)

Next


end event

event dw_detail::itemchanged;call super::itemchanged;String ls_mainitem_yn, ls_quota_yn
Long   i, ll_groupno, ll_grouptype, ll_groupno_1, ll_grouptype_1

If dwo.name = "chk" Then
	ls_mainitem_yn = Trim(This.object.mainitem_yn[row])
	ls_quota_yn    = Trim(This.object.quota_yn[row])
	ll_groupno     = This.object.groupno[row]
	ll_grouptype   = This.object.grouptype[row]
	
	If IsNull(ls_mainitem_yn) 	Or ls_mainitem_yn = "" 	Then ls_mainitem_yn 	= "N"
	If IsNull(ls_quota_yn) 		Or ls_quota_yn = "" 		Then ls_quota_yn 		= "N"
	
	//품목group이 동일할때 선택type이 0이면 한품목만 선택 가능
	If ll_grouptype = 0 Then
		If data = "Y" Then
			For i = 1 To dw_detail.RowCount()
				If i = row Then continue
				
				ll_groupno_1    = This.object.groupno[i]
				ll_grouptype_1  = This.object.grouptype[i]
				
				If ll_groupno = ll_groupno_1  Then					
					IF ll_grouptype_1 = 0 Then
						This.object.chk[i] = "N"
					End If
				End If
				
			Next
		End If
		
	ElseIF ls_mainitem_yn = "Y" and ls_quota_yn = "Y" Then
		If data = "Y" Then
			For i = 1 To dw_detail.RowCount()
				If i = row Then continue
				
				ls_mainitem_yn = Trim(This.object.mainitem_yn[i])
				ls_quota_yn    = Trim(This.object.quota_yn[i])
				
				If ls_mainitem_yn = "Y" And ls_quota_yn = "Y" Then
					This.object.chk[i] = "N"
				End If	
			Next
		End If
	End If	
End If


end event

type p_insert from w_a_reg_m_m3`p_insert within b1w_reg_chg_priceplan_mobile
boolean visible = false
integer y = 1980
end type

type p_delete from w_a_reg_m_m3`p_delete within b1w_reg_chg_priceplan_mobile
boolean visible = false
integer y = 1980
end type

type p_save from w_a_reg_m_m3`p_save within b1w_reg_chg_priceplan_mobile
integer x = 59
integer y = 1924
end type

type p_reset from w_a_reg_m_m3`p_reset within b1w_reg_chg_priceplan_mobile
integer x = 361
integer y = 1924
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b1w_reg_chg_priceplan_mobile
integer y = 708
integer width = 3077
integer height = 460
integer taborder = 30
string dataobject = "b1dw_reg_chg_priceplan_mobile"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail2::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_contractseq, ls_where, ls_status
Long ll_row


If al_select_row = 0 Then Return 
ls_contractseq = String(dw_master.object.contractseq[al_select_row])
ls_status = Trim(dw_master.object.status[al_select_row])

ls_where = ""
ls_where += "to_char(cmt.contractseq) = '" + ls_contractseq + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	ai_return = -1
	Return 
End If

dw_detail2.object.reqdt[1] = relativedate(date(fdt_get_dbserver_now()),1)

dw_detail2.SetItemStatus(1, 0 , Primary!,NotModified!)

//개통상태가 아니면
If ls_status <> is_active Then
	p_save.TriggerEvent("ue_disable")
Else
	p_save.TriggerEvent("ue_enable")
End If

Return 
end event

event dw_detail2::retrieveend;DataWindowChild ldc_priceplan, ldc_svcpromise
LONG		li_exist
STRING	ls_filter,		ls_svccod,		ls_customerid,		ls_currency_type,	&
			ls_partner

If rowcount = 0 Then Return 0

//고객의 납입자의 화폐단위 가져오기
ls_customerid = dw_detail2.object.customerm_customerid[1] 
select currency_type into :ls_currency_type from billinginfo bil, customerm cus
where bil.customerid = cus.payid and  cus.customerid =:ls_customerid;

ls_svccod	= Trim(dw_detail2.object.contractmst_svccod[1])
ls_partner	= Trim(dw_detail2.object.contractmst_partner[1])
li_exist		= dw_detail2.GetChild("chg_priceplan", ldc_priceplan)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Price Plan")
//ls_filter = "svccod = '" + ls_svccod  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' " + &
//             " And currency_type ='" + ls_currency_type + "' "
ls_filter = "svccod = '" + ls_svccod  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' " + &
             " And currency_type ='" + ls_currency_type + "' " + &
				 " And partner ='" + ls_partner + "' "

ldc_priceplan.SetTransObject(SQLCA)
li_exist =ldc_priceplan.Retrieve()
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If  



end event

event dw_detail2::itemchanged;call super::itemchanged;//가격 정책이 바뀌었을때 해당 품목을 보여줌
String ls_where
Long ll_row
IF dwo.name = "chg_priceplan" Then
	ls_where = "det.priceplan = '" + data + "' "
   dw_detail.is_where = ls_where
	ll_row = dw_detail.Retrieve()
	If ll_row  = 0 Then
		p_save.TriggerEvent("ue_disable")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100, Title, "Retrieve()")
		p_save.TriggerEvent("ue_disable")
		Return -2
	End If	
End If 
	
//2013-06-13 BY HMK 
//(grouptype = 9)제한없음일 경우 체크 풀기
SetRedraw(False)

If ll_row >= 0 Then
	
	integer i_chk
	for i_chk = 1 to ll_row
		if dw_detail.object.grouptype[i_chk] = 9 then
			dw_detail.object.chk[i_chk] = 'N'
		end if	
	next
	
	
End If

SetRedraw(True)
dw_detail.Setfocus()
//2013-06-13 BY HMK 
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b1w_reg_chg_priceplan_mobile
integer x = 27
integer y = 676
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within b1w_reg_chg_priceplan_mobile
integer x = 27
integer y = 1168
end type

type dw_validkey from u_d_base within b1w_reg_chg_priceplan_mobile
boolean visible = false
integer x = 64
integer y = 2108
integer width = 3063
integer height = 404
integer taborder = 0
boolean bringtotop = true
string dataobject = "b1dw_inq_chg_priceplan_validkey"
end type

type dw_old from datawindow within b1w_reg_chg_priceplan_mobile
boolean visible = false
integer x = 1897
integer y = 1908
integer width = 1211
integer height = 148
integer taborder = 50
boolean bringtotop = true
string title = "none"
string dataobject = "b1dw_reg_chg_priceplan_old_mobile"
boolean hscrollbar = true
boolean vscrollbar = true
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

event retrieveend;Long i
String ls_mainitem_yn

For i = 1 To rowcount 
	dw_old.object.chk[i] = "Y" 
	dw_old.SetItemStatus(i, 0 , Primary!,NotModified!)
Next


end event

type st_horizontal3 from st_horizontal within b1w_reg_chg_priceplan_mobile
boolean visible = false
integer y = 1544
end type

type cb_1 from commandbutton within b1w_reg_chg_priceplan_mobile
integer x = 1728
integer y = 148
integer width = 599
integer height = 96
integer taborder = 60
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "변경전 품목확인"
end type

event clicked;INTEGER	li_rc
STRING	ls_contractseq,	ls_priceplan
LONG		ll_row

//dw_master.AcceptText()
//dw_detail2.AcceptText()
ll_row = dw_master.RowCount()

If ll_row <= 0 THEN RETURN -1


ls_contractseq = STRING(dw_master.Object.contractseq[dw_master.GetRow()])
ls_priceplan	= dw_master.Object.priceplan[dw_master.GetRow()]

iu_cust_msg 				= CREATE u_cust_a_msg
iu_cust_msg.is_pgm_name = "Item"
iu_cust_msg.is_data[1]  = "CloseWithReturn"
iu_cust_msg.il_data[1]  = 1  		//현재 row
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.is_data[1]  = ls_priceplan
iu_cust_msg.is_data[2]  = ls_contractseq

//계약서 출력을 위한 팝업 연결
OpenWithParm(ubs_w_pop_priceplan_item, iu_cust_msg)

DESTROY iu_cust_msg

RETURN 0


end event

