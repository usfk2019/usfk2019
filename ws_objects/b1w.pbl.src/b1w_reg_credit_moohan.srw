$PBExportHeader$b1w_reg_credit_moohan.srw
$PBExportComments$[kem] 신용정보조회
forward
global type b1w_reg_credit_moohan from w_a_reg_m
end type
end forward

global type b1w_reg_credit_moohan from w_a_reg_m
integer width = 3127
integer height = 1924
end type
global b1w_reg_credit_moohan b1w_reg_credit_moohan

type variables
String is_method, is_custtype, is_method_s
end variables

forward prototypes
public function long wfl_sinyongselect (double ad_seqno, ref string as_retn_code)
public function long wfl_sinyongsave (long al_row, ref double ld_seqno)
end prototypes

public function long wfl_sinyongselect (double ad_seqno, ref string as_retn_code);//2005-08-22 kem 
//보증보험 연동 결과 Table Select
//사전조회(A0)

Long   ll_cnt


// Select sinyong_response
SELECT COUNT(SEQNO)
INTO   :ll_cnt
FROM   SINYONG_RESPONSE
WHERE  SEQNO = :ad_seqno;

										
If SQLCA.Sqlcode < 0 Then
	f_msg_sql_err(Title, 'SINYONG_RESPONSE Select Error')
	Rollback;
	Return -1
ElseIf SQLCA.SQLCode = 100 Then
	Return 0
Else
	SELECT RETN_CODE
	INTO   :as_retn_code
	FROM   SINYONG_RESPONSE
	WHERE  SEQNO = :ad_seqno;
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(Title, 'SINYONG_RESPONSE Return_code Select Error')
		Rollback;
		Return ll_cnt
	End If
	
//	UPDATE CUSTOMERM
//	   SET FINSTATUS = '',
//		    FINCONFDT = SYSDATE
//	 WHERE 
	
End If

Return 0
end function

public function long wfl_sinyongsave (long al_row, ref double ld_seqno);//2005-08-22 kem 
//보증보험 연동 Table Insert
//사전조회(A0)

String ls_cust_divs, ls_custid, ls_cmpnid, ls_custname
String ls_inqreqdt, ls_inqreqtm


ls_inqreqdt = String(dw_detail.Object.inqreqdt[al_row],'yyyymmdd')
ls_inqreqtm = String(fdt_get_dbserver_now(),'hhmmss')
ls_cust_divs = Trim(dw_detail.Object.cust_type[al_row])
ls_custid = dw_detail.Object.reqssno[al_row]
If ls_cust_divs <> is_custtype Then  //고객구분이 개인이 아닌 경우 
	ls_cmpnid = dw_detail.Object.reqssno[al_row]
End If
ls_custname = Trim(dw_detail.Object.reqname[al_row])


If IsNull(ls_inqreqdt) Then ls_inqreqdt = ""
If IsNull(ls_inqreqtm) Then ls_inqreqtm = ""
If IsNull(ls_cust_divs) Then ls_cust_divs = ""
If IsNull(ls_custid) Then ls_custid = ""
If IsNull(ls_cmpnid) Then ls_cmpnid = ""
If IsNull(ls_custname) Then ls_custname = ""


SELECT seq_sinyong_request.nextval
INTO   :ld_seqno
FROM   dual;

// Insert sinyong_request
INSERT INTO SINYONG_REQUEST ( SEQNO, TELE_CODE, FIRM_CODE, RETN_CODE,
                              CUST_DIVS, CUST_ID, CMPN_ID, CUST_NAME,
										TRAN_DATE, TRAN_TIME, IN_DATE, IN_NAME )
							VALUES ( :ld_seqno, 'A0', '029', NULL,
							         :ls_cust_divs, :ls_custid, :ls_cmpnid, :ls_custname,
										:ls_inqreqdt, :ls_inqreqtm, sysdate, :gs_user_id );
										
If SQLCA.Sqlcode < 0 Then
	f_msg_sql_err(Title, 'SINYONG_REQUEST Insert Error')
	Rollback;
	Return -1
End If

Return 0
end function

on b1w_reg_credit_moohan.create
call super::create
end on

on b1w_reg_credit_moohan.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;Long ll_row, ll_i
String ls_where, ls_order_yn
String ls_inqreqdt, ls_inqstat, ls_partner
Datetime ldt_inqdt

ls_inqreqdt = String(dw_cond.Object.inqreqdt[1],'yyyymmdd')
ls_inqstat = dw_cond.Object.inqstat[1]
ls_partner = dw_cond.Object.partner[1]

If IsNull(ls_inqreqdt) Then ls_inqreqdt = ""
If IsNull(ls_inqstat) Then ls_inqstat = ""
If IsNull(ls_partner) Then ls_partner = ""

If ls_inqreqdt = "" Then
	f_msg_info(200, Title, "조회요청일")
	dw_cond.SetColumn("inqreqdt")
	Return
End If

ls_where = ""
If ls_inqreqdt <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(inqreqdt,'yyyymmdd') <= '" + ls_inqreqdt + "'"	
End If

If ls_inqstat <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " inqstat = '" + ls_inqstat + "' "	
End If

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " partner = '" + ls_partner + "' "	
End If

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve(gs_user_id)

If ll_row = 0 Then
	f_msg_info(1000, This.Title, "")
ElseIf ll_row < 0  Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
	Return
End If

ll_row = dw_detail.rowcount()
//retrieve 후 값 셋팅!!
For ll_i = 1 To ll_row
	ls_order_yn = dw_detail.Object.order_yn[ll_i]
	If isNull(ls_order_yn) Then dw_detail.Object.order_yn[ll_i] = 'Y'
	ldt_inqdt = dw_detail.Object.inqdt[ll_i]
	If isNull(ldt_inqdt) Then dw_detail.Object.inqdt[ll_i] = fdt_get_dbserver_now()	
Next
end event

event type integer ue_extra_save();call super::ue_extra_save;Long ll_row, ll_i, ll_return, ll_result_sec, ll_count, i
String ls_countrycod, ls_countrynm, ls_ref_desc, ls_retn_code, ls_inqstat
String ls_customernm, ls_cust_no
Double ld_seqno
Time   lt_now_time, lt_after_time

ll_row = dw_detail.RowCount()
If ll_row < 0 Then Return 0

//저장 시 필수항목 행별로 체크
For ll_i = 1 To ll_row
   //Update한 log 정보
   If dw_detail.GetItemStatus(ll_i, 0, Primary!) = DataModified! THEN
		dw_detail.object.updt_user[ll_i] = gs_user_id
		dw_detail.object.updtdt[ll_i] = fdt_get_dbserver_now()
		dw_detail.object.pgm_id[ll_i] = gs_pgm_id[gi_open_win_no]	
		
		ls_inqstat = Trim(dw_detail.Object.inqstat[ll_i])
		If ls_inqstat = is_method Then
			//Sinyong_Request Table Insert
			ll_return = wfl_SinyongSave(ll_row, ld_seqno)
			
			If ll_return < 0 Then
				f_msg_usr_err(9000, Title, 'Sinyong Request Save Error');
				Return 1
			ElseIf ll_return = 0 Then
				commit;
			End If
			
//			//보증보험처리 결과 대기
//			ll_result_sec = Long(fs_get_control("B1", "P100", ls_ref_desc))  //개통결과 대기초와 동일
//			
//			FOR i = 1 To 1 
//				lt_now_time = Time(fdt_get_dbserver_now())
//				lt_after_time = relativetime(lt_now_time, ll_result_sec)
//				
//				DO WHILE lt_now_time < lt_after_time
//					lt_now_time = Time(fdt_get_dbserver_now())
//				LOOP
//				
//				//Sinyong_Response Table Select
//				ll_count = wfl_SinyongSelect(ld_seqno, ls_retn_code);
//				
//				If ll_count > 0 Then
//					Exit
//				End If	
//					
//			Next
//			
//			If IsNull(ls_retn_code) OR ls_retn_code = '' Then
//				ls_retn_code = is_method
//			End If
//			
//			dw_detail.Object.inqstat[ll_i] = ls_retn_code
//			If ls_retn_code = is_method Then
//				dw_detail.Object.order_yn[ll_i] = 'N'
//				dw_detail.Object.inqstat[ll_i]  = ls_retn_code
//			Else
//				dw_detail.Object.order_yn[ll_i] = 'Y'
//				dw_detail.Object.inqstat[ll_i]  = ls_retn_code
//				dw_detail.Object.inqdt[ll_i]    = Date(fdt_get_dbserver_now())
//			End If
//			
//			//고객정보 Update
//			ls_customernm = Trim(dw_detail.Object.reqname[ll_i])
//			ls_cust_no	  = Trim(dw_detail.Object.reqssno[ll_i])
//			
//			UPDATE CUSTOMERM
//			   SET FINSTATUS = :ls_retn_code,
//				    FINCONFDT = SYSDATE
//		    WHERE (customernm = :ls_customernm or corpnm = :ls_customernm)
//			   AND (ssno = :ls_cust_no or cregno = :ls_cust_no);
//				
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(Title, 'CUSTOMERM Update Error')
//				Rollback;
//				Return 1
//			End If
		End If
		
	ElseIf dw_detail.GetItemStatus(ll_i, 0, Primary!) = NewModified! Then
		
		//Sinyong_Request Table Insert
		ll_return = wfl_SinyongSave(ll_row, ld_seqno)
		
		If ll_return < 0 Then
			f_msg_usr_err(9000, Title, 'Sinyong Request Save Error');
			Return 1
		ElseIf ll_return = 0 Then
			commit;
		End If
		
//		//보증보험처리 결과 대기
//		ll_result_sec = Long(fs_get_control("B1", "P100", ls_ref_desc))  //개통결과 대기초와 동일
//		
//		FOR i = 1 To 1 
//			lt_now_time = Time(fdt_get_dbserver_now())
//			lt_after_time = relativetime(lt_now_time, ll_result_sec)
//			
//			DO WHILE lt_now_time < lt_after_time
//				lt_now_time = Time(fdt_get_dbserver_now())
//			LOOP
//			
//			//Sinyong_Response Table Select
//			ll_count = wfl_SinyongSelect(ld_seqno, ls_retn_code);
//			
//			If ll_count > 0 Then
//				Exit
//			End If				
//				
//		Next
//		
//		If IsNull(ls_retn_code) OR ls_retn_code = '' Then
//			ls_retn_code = is_method
//		End If
//		
//		dw_detail.Object.inqstat[ll_i] = ls_retn_code
//		If ls_retn_code = is_method Then
//			dw_detail.Object.order_yn[ll_i] = 'N'
//			dw_detail.Object.inqstat[ll_i]  = ls_retn_code
//		Else
//			dw_detail.Object.order_yn[ll_i] = 'Y'
//			dw_detail.Object.inqstat[ll_i]  = ls_retn_code
//			dw_detail.Object.inqdt[ll_i]    = Date(fdt_get_dbserver_now())
//		End If
//		
//		//고객정보 Update
//		ls_customernm = Trim(dw_detail.Object.reqname[ll_i])
//		ls_cust_no	  = Trim(dw_detail.Object.reqssno[ll_i])
//		
//		UPDATE CUSTOMERM
//			SET FINSTATUS = :ls_retn_code,
//				 FINCONFDT = SYSDATE
//		 WHERE (customernm = :ls_customernm or corpnm = :ls_customernm)
//			AND (ssno = :ls_cust_no or cregno = :ls_cust_no);
//			
//		If SQLCA.SQLCode < 0 Then
//			f_msg_sql_err(Title, 'CUSTOMERM Update Error')
//			Rollback;
//			Return 1
//		End If
		
   End If
	
Next


Return 0
	
end event

event open;call super::open;/*------------------------------------------------------------------------
	Name 	: b1w_reg_inq_creditstat
	Desc.	: 신용정보조회
	Ver 	: 1.0
	Date	: 2002.11.22
	Progrmaer: Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_ref_desc
ls_ref_desc = ""
is_method = fs_get_control("A1", "C500", ls_ref_desc)
is_method_s = fs_get_control("A1", "C510", ls_ref_desc)

p_insert.TriggerEvent("ue_enable")

dw_cond.object.inqreqdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.inqstat[1]  = is_method

is_custtype = fs_get_control("B0", "P111", ls_ref_desc)  //고객구분 : 개인



end event

event type integer ue_insert();call super::ue_insert;//p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_reset();call super::ue_reset;//초기화
//dw_cond.ReSet()
//dw_cond.InsertRow(0)
dw_cond.SetColumn("inqreqdt")
dw_cond.Object.inqreqdt[1] = date(fdt_get_dbserver_now())
dw_cond.object.inqstat[1] = is_method

p_insert.TriggerEvent("ue_enable")

Return 0
end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;Long  ll_seq

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("inqreqdt")

dw_detail.Object.partner[al_insert_row] = gs_user_group
dw_detail.Object.inqreqdt[al_insert_row] = date(fdt_get_dbserver_now())

//MAX Sequence Select
SELECT seq_creditstat.nextval
INTO   :ll_seq
FROM   dual;

dw_detail.Object.seq[al_insert_row] = ll_seq


//Log 정보
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.updt_user[al_insert_row] = gs_user_id
dw_detail.object.updtdt[al_insert_row] = fdt_get_dbserver_now()
dw_detail.object.pgm_id[al_insert_row] = gs_pgm_id[gi_open_win_no]

Return 0
end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_credit_moohan
integer y = 40
integer width = 2263
integer height = 260
string dataobject = "b1dw_cnd_reg_credit_moohan"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_credit_moohan
integer x = 2450
integer y = 56
end type

type p_close from w_a_reg_m`p_close within b1w_reg_credit_moohan
integer x = 2747
integer y = 56
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_credit_moohan
integer height = 312
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_credit_moohan
boolean visible = false
integer x = 329
integer y = 1696
integer height = 172
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_credit_moohan
integer x = 73
integer y = 1692
end type

type p_save from w_a_reg_m`p_save within b1w_reg_credit_moohan
integer x = 370
integer y = 1692
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_credit_moohan
integer x = 23
integer y = 336
integer width = 3022
integer height = 1324
string dataobject = "b1dw_req_credit_moohan"
boolean livescroll = false
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;//Item Changed
Boolean lb_check
String ls_data 
Choose Case dwo.name
	Case "cust_type"
		If data = is_custtype Then
			dw_detail.Object.reqname_t.text = '고객명'
			dw_detail.Object.reqssno_t.text = '주민등록번호'
		Else
			dw_detail.Object.reqname_t.text = '사업자명'
			dw_detail.Object.reqssno_t.text = '사업자등록번호'
		End If
		
	Case "order_yn"
		 This.Object.inqdt[row] = fdt_get_dbserver_now()	
		
End Choose
	
Return 0
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_credit_moohan
integer x = 667
integer y = 1692
end type

