$PBExportHeader$b1w_reg_validkey_noreq_assign.srw
$PBExportComments$[ohj] 대리점 인증key 할당
forward
global type b1w_reg_validkey_noreq_assign from w_a_reg_m_sql
end type
type p_saveas from u_p_saveas within b1w_reg_validkey_noreq_assign
end type
end forward

global type b1w_reg_validkey_noreq_assign from w_a_reg_m_sql
integer width = 2789
integer height = 2064
event ue_saveas ( )
p_saveas p_saveas
end type
global b1w_reg_validkey_noreq_assign b1w_reg_validkey_noreq_assign

type variables
Long	il_row_before = 0
String  is_hand_refill, is_reward_refill , is_return_status    	//수동충전, 보상충전
String is_lflag
String is_return_dt
String is_status, is_prefixno, is_fr_partner= '', is_validkey_type = '', is_bonsa
Long   il_seq, il_cnt = 0

end variables

event ue_saveas();Boolean lb_return
Integer li_return
String ls_curdir
u_api lu_api

If dw_detail.RowCount() <= 0 Then
	f_msg_info(1000, This.Title, "Data exporting")
	Return
End If

lu_api = Create u_api
ls_curdir = lu_api.uf_getcurrentdirectorya()
If IsNull(ls_curdir) Or ls_curdir = "" Then
	f_msg_info(9000, This.Title, "Can't get the Information of current directory.")
	Destroy lu_api
	Return
End If

li_return = dw_detail.SaveAs("", Excel!, True)

lb_return = lu_api.uf_setcurrentdirectorya(ls_curdir)
If li_return <> 1 Then
	f_msg_info(9000, This.Title, "User cancel current job.")
Else
	f_msg_info(9000, This.Title, "Data export finished.")
End If

Destroy lu_api

end event

on b1w_reg_validkey_noreq_assign.create
int iCurrent
call super::create
this.p_saveas=create p_saveas
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_saveas
end on

on b1w_reg_validkey_noreq_assign.destroy
call super::destroy
destroy(this.p_saveas)
end on

event ue_ok();call super::ue_ok;return
end event

event ue_save();Integer li_return
String  ls_where
dw_detail.ReSet()

If dw_cond.AcceptText() < 1 Then//???
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

li_return = This.Trigger Event ue_save_sql()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
//    ROLLBACK;
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.is_title = This.Title
	
		iu_mdb_app.uf_prc_db()		
		
		If iu_mdb_app.ii_rc = -1 Then Return
		
		f_msg_info(3010, This.Title, "Save")
				
	Case Is >= 0
//		COMMIT;
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"

		iu_mdb_app.uf_prc_db()
		
		If iu_mdb_app.ii_rc = -1 Then Return
		
		f_msg_info(3000, This.Title, "Save")
		
      dw_cond.ReSet()
		dw_cond.InsertRow(0)
		dw_detail.retrieve(il_seq)
End Choose


end event

event type integer ue_save_sql();call super::ue_save_sql;Long    ll_row, ll_count, ll_seq
String  ls_return_type, ls_partner_prefix, ls_validkey_type
String  ls_tmp, ls_ref_desc, ls_result[], ls_partner
Integer li_return, li_ret, li_rc

String  ls_fr_partner, ls_priceplan, ls_remark
Long    ll_reqqty, ll_reqqty_cu=0, ll_su

ls_fr_partner    = dw_cond.Object.fr_partner[1]
ls_validkey_type = dw_cond.Object.validkey_type[1]
ll_reqqty        = dw_cond.Object.reqqty[1]
ls_priceplan     = dw_cond.Object.priceplan[1]
ls_remark        = dw_cond.Object.remark[1]

If IsNull(ls_fr_partner)    Then ls_fr_partner    = ""
If IsNull(ls_validkey_type) Then ls_validkey_type = ""
If IsNull(ll_reqqty)        Then ll_reqqty        = 0
If IsNull(ls_remark)        Then ls_remark        = ""

If ls_fr_partner = "" Then
	f_msg_usr_err(200, Title, "요청대리점")
	dw_cond.SetFocus()
	dw_cond.SetColumn("fr_partner")
	Return -2
End If

If ls_validkey_type = "" Then
	f_msg_usr_err(200, Title, "인증key type")
	dw_cond.SetFocus()
	dw_cond.SetColumn("validkey_type")
	Return -2
End If

If ll_reqqty <= 0 Then
	f_msg_usr_err(200, Title, "요청수량")
	dw_cond.SetFocus()
	dw_cond.SetColumn("reqqty")
	Return -2
End If

If il_cnt = 0 Then
	f_msg_info(3020, Title, "할당할 인증key가 없습니다. 인증key를 생성하십시오.")
	Return -2
End If

If il_cnt < ll_reqqty Then
	If f_msg_ques_yesno2(9000, Title, "할당 가능 수량은 [ " +  string(il_cnt) + " ]입니다. 요청하신 수량만큼 할당이 불가능합니다. ~r~n " + &
	                                  " 할당 가능 수량만큼 할당하시겠습니까?", 1)    = 2 Then
		Return -2
	Else
		//할당가능 수량으로...
		ll_reqqty_cu = il_cnt
	End If
End If

If ll_reqqty_cu <> 0 Then //할당가능수량
	ll_su = ll_reqqty_cu
	
Else //요청수량만큼 할당
	ll_su = ll_reqqty
	
End If

//SEQ
Select seq_validkey_moveno.nextval 
  into :il_seq 
  from dual;
  
//***** 처리부분 *****
b1u_dbmgr11 iu_db

iu_db = Create b1u_dbmgr11

iu_db.is_title = Title
iu_db.is_data[1] = ls_fr_partner
iu_db.is_data[2] = ls_priceplan	 
iu_db.is_data[3] = ls_remark	
iu_db.is_data[4] = is_status		//인증key type
iu_db.is_data[5] = is_prefixno
iu_db.is_data[6] = ls_validkey_type
iu_db.is_data[7] = gs_user_id
iu_db.is_data[8] = gs_pgm_id[gi_open_win_no]

iu_db.il_data[1] = ll_reqqty	
iu_db.il_data[2] = il_seq			//할당log seq
iu_db.il_data[3] = ll_su 		  	//할당수량
iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_01()
li_rc	= iu_db.ii_rc

If li_rc < 0 Then
	dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)	
	Destroy b1u_dbmgr11
	Return -2
End If

dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

Destroy b1u_dbmgr11

Return 0
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1W_reg_validkey_noreq_assign
	Desc.	: 	대리점 인증key 무요청할당
	Ver.	:	1.0
	Date	: 	2004.12.06
	Programer : ohj
--------------------------------------------------------------------------*/
String ls_ref_desc
p_save.TriggerEvent("ue_enable")

is_bonsa = fs_get_control("A1","C102", ls_ref_desc)

end event

type dw_cond from w_a_reg_m_sql`dw_cond within b1w_reg_validkey_noreq_assign
integer x = 55
integer y = 92
integer width = 2181
integer height = 592
string dataobject = "b1dw_cnd_validkey_noreq_assign"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan
Long   li_exist, ll_i, li_return, ll_cnt
String ls_temp, ls_fr_partner, ls_prefixno, ls_ref_desc, ls_result[], ls_filter
String ls_validkey_type
//Boolean lb_check

dw_cond.Accepttext()

Choose Case dwo.name
   Case "fr_partner"
		ls_fr_partner    = Trim(dw_cond.object.fr_partner[1])
		ls_validkey_type = Trim(dw_cond.object.validkey_type[1])
		
		If IsNull(ls_validkey_type) Then ls_validkey_type = ''

		//대리점 prefix찾기		
		SELECT PREFIXNO
		  INTO :is_prefixno
		  FROM PARTNERMST
		 WHERE PARTNER = :ls_fr_partner  ;
		 
		//요청대리점 변경시 가격정책 null
		If is_fr_partner <> "" Then
			If is_fr_partner <> ls_fr_partner Then
				dw_cond.SetItem(1, 'priceplan', '')
			End If
		End If
		
		//상태코드 가져오기 -- 인증key 할당 '11'
		ls_temp = fs_get_control("B1","P400", ls_ref_desc)
				
		If ls_temp <> "" Then
			fi_cut_string(ls_temp, ";" , ls_result[])
		End if
		
		is_status = ls_result[5]
		
		//할당가능한 수량 - 인증key type선택했을떄만... 미할당수량 보임..	
		//인증키 생성시 partner = '00000000'
		//개통 해지시 VALIDKEYMST에 partner 컬럼을 '00000000'로 하는지 확인....  확인ok
		//                          status = '00' , sale_flag = '0'              확인ok
		
		If ls_validkey_type <> '' Then

			SELECT COUNT(*)
			  INTO :il_cnt
			  FROM VALIDKEYMST 
			 WHERE SALE_FLAG        = '0'
				AND NVL(PARTNER, '') = :is_bonsa   
				AND VALIDKEY_TYPE    = :ls_validkey_type ;
				
			dw_cond.SetItem(1, 'cur_qty', il_cnt)
			
			li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
			
			If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
			
			ls_filter = "validkey_type = '" + ls_validkey_type + "'  And partner = '" + ls_fr_partner + "'" 
				
			ldc_priceplan.SetTransObject(SQLCA)
			li_exist =ldc_priceplan.Retrieve()
			ldc_priceplan.SetFilter(ls_filter)			//Filter정함
			ldc_priceplan.Filter()
			
			If li_exist < 0 Then 				
			  f_msg_usr_err(2100, Title, "Retrieve()")
			  Return 1  		//선택 취소 focus는 그곳에
			End If			
		End If
		
		is_fr_partner    = ls_fr_partner
		
	Case "validkey_type"
		ls_fr_partner    = Trim(dw_cond.object.fr_partner[1])		
		ls_validkey_type = Trim(dw_cond.object.validkey_type[1])

		//인증key type 변경시 가격정책 null
		If is_validkey_type <> "" Then
			If is_validkey_type <> ls_validkey_type Then
				dw_cond.SetItem(1, 'priceplan', '')
			End If
		End If
		
		//할당가능한 수량
		SELECT COUNT(*)
		  INTO :il_cnt
		  FROM VALIDKEYMST 
		 WHERE SALE_FLAG        = '0'
			AND NVL(PARTNER, '') = :is_bonsa   
			AND VALIDKEY_TYPE    = :ls_validkey_type ;
			
		dw_cond.SetItem(1, 'cur_qty', il_cnt)			

		//인증key type별 가격정책 dddw
		li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		
		ls_filter = "validkey_type = '" + ls_validkey_type + "'  And partner = '" + ls_fr_partner + "'" 
			
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If
		
		is_validkey_type = ls_validkey_type
		
	Case "priceplan"
		ls_fr_partner    = Trim(dw_cond.object.fr_partner[1])
		ls_validkey_type = Trim(dw_cond.object.validkey_type[1])
		
		If IsNull(ls_fr_partner)    Then ls_fr_partner = ''
		If IsNull(ls_validkey_type) Then ls_validkey_type = ''
		
		If ls_fr_partner = '' Then 
			f_msg_usr_err(200, Title, "요청대리점")
			dw_cond.SetFocus()
			dw_cond.SetColumn("fr_partner")
			Return 1			
		End If
		
		If ls_validkey_type = '' Then 
			f_msg_usr_err(200, Title, "인증key type")
			dw_cond.SetFocus()
			dw_cond.SetColumn("validkey_type")
			Return 1			
		End If
		
End Choose	

/*
DataWindowChild ldc_priceplan
Long li_exist, ll_i, li_return, ll_cnt
String ls_temp, ls_fr_partner, ls_prefixno, ls_ref_desc, ls_result[], ls_filter
Boolean lb_check
Choose Case dwo.name
   Case "fr_partner"
		ls_fr_partner = Trim(dw_cond.object.fr_partner[1])
		
		//대리점 prefix찾기		
		SELECT PREFIXNO
		  INTO :is_prefixno
		  FROM PARTNERMST
		 WHERE PARTNER = :ls_fr_partner  ;
		
		If is_fr_partner <> "" Then
			If is_fr_partner = ls_fr_partner Then
				dw_cond.SetItem(1, 'priceplan', '')
			End If
		End If
		
		//상태코드 가져오기
		ls_temp = fs_get_control("B1","P400", ls_ref_desc)
		
		If ls_temp <> "" Then
			fi_cut_string(ls_temp, ";" , ls_result[])
		End if
		
		is_status = ls_result[1]
		
		//해당 파트너의 현재고 수량		
		SELECT COUNT(*)
		  INTO :ll_cnt
		  FROM VALIDKEYMST 
		 WHERE STATUS = :is_status
			AND PARTNER_PREFIX  = :is_prefixno;
		
		dw_cond.SetItem(1, 'cur_qty', ll_cnt)
		
		//대리점별 가격정책 dddw
		li_exist = dw_cond.GetChild("priceplan", ldc_priceplan)		//DDDW 구함
		
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 가격정책")
		
		ls_filter = "partner = '" + ls_fr_partner + "'" 
				
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		is_fr_partner = ls_fr_partner
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If
		
End Choose	

*/
end event

event dw_cond::clicked;call super::clicked;
If dwo.name = 'priceplan' Then
	
	String ls_fr_partner, ls_validkey_type
	
	ls_fr_partner    = Trim(dw_cond.object.fr_partner[1])
	ls_validkey_type = Trim(dw_cond.object.validkey_type[1])
	
	If IsNull(ls_fr_partner)    Then ls_fr_partner    = ''
	If IsNull(ls_validkey_type) Then ls_validkey_type = ''
	
	If ls_fr_partner = '' Then 
		f_msg_usr_err(200, Title, "요청대리점")
		dw_cond.SetFocus()
		dw_cond.SetColumn("fr_partner")
		Return 1			
	End If
	
	If ls_validkey_type = '' Then 
		f_msg_usr_err(200, Title, "인증key type")
		dw_cond.SetFocus()
		dw_cond.SetColumn("validkey_type")
		Return 1			
	End If	
	
ElseIf dwo.name = 'validkey_type' Then
	
		ls_fr_partner    = Trim(dw_cond.object.fr_partner[1])		
		
      If isnull(ls_fr_partner) Then
			f_msg_usr_err(200, Title, "요청대리점")
			dw_cond.SetFocus()
			Return 1	
		End If	
End If
end event

type p_ok from w_a_reg_m_sql`p_ok within b1w_reg_validkey_noreq_assign
boolean visible = false
integer x = 2775
integer y = 404
boolean enabled = false
end type

type p_close from w_a_reg_m_sql`p_close within b1w_reg_validkey_noreq_assign
integer x = 2382
integer y = 184
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b1w_reg_validkey_noreq_assign
integer y = 28
integer width = 2295
integer height = 692
end type

type p_save from w_a_reg_m_sql`p_save within b1w_reg_validkey_noreq_assign
integer x = 2382
integer y = 68
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b1w_reg_validkey_noreq_assign
integer y = 736
integer width = 2295
integer height = 1172
string dataobject = "b1dw_cnd_reg_validkey_noreq_assign"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.validkeymst_validkey_t
uf_init(ldwo_SORT)
end event

type p_saveas from u_p_saveas within b1w_reg_validkey_noreq_assign
integer x = 2382
integer y = 300
boolean bringtotop = true
boolean originalsize = false
end type

