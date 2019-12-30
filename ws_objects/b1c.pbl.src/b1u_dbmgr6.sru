$PBExportHeader$b1u_dbmgr6.sru
$PBExportComments$[parkkh] DB Manager/인증정보
forward
global type b1u_dbmgr6 from u_cust_a_db
end type
end forward

global type b1u_dbmgr6 from u_cust_a_db
end type
global b1u_dbmgr6 b1u_dbmgr6

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();//b1w_reg_sendemail%save
String ls_mailtype, ls_filenm, ls_atcfile, ls_priority, ls_mtitle, ls_sender, ls_reqdt
String ls_userid, ls_chk, ls_customerid, ls_customernm, ls_email, ls_gubun, ls_reqdt_new
Long   ll_row, ll_len
DateTime ldt_reqdt, ldt_sysdate

//b1w_reg_sendsms%save
String ls_smstype, ls_msg, ls_callback, ls_smsphone
Integer li_pos, i

ii_rc = -1
Choose Case is_caller
	Case "b1w_reg_sendemail%save"    //BroadCating Email
//		lu_dbmgr5.is_caller = "b1w_reg_sendemail%save"
//		lu_dbmgr5.is_title  = Title
//		lu_dbmgr5.idw_data[1] = dw_master
//		lu_dbmgr5.idw_data[2] = dw_detail

				
		ls_mailtype = Trim(idw_data[1].object.mailtype[1])
		ls_filenm   = Trim(idw_data[1].object.filenm[1])
		ls_atcfile  = Trim(idw_data[1].object.atcfile[1])
		ls_priority = Trim(idw_data[1].object.priority[1])
		ls_mtitle   = Trim(idw_data[1].object.mtitle[1])
		ls_sender   = Trim(idw_data[1].object.sender[1])
		ldt_reqdt   = idw_data[1].object.reqdt[1]
		ls_reqdt    = String(idw_data[1].object.reqdt[1], 'yyyymmddhh')
		
		
		If IsNull(ls_mailtype) Then ls_mailtype = ""
		If IsNull(ls_filenm) Then ls_filenm = ""
		If IsNull(ls_atcfile) Then ls_atcfile = ""
		If IsNull(ls_priority) Then ls_priority = ""
		If IsNull(ls_mtitle) Then ls_mtitle = ""
		If IsNull(ls_sender) Then ls_sender = ""
		If IsNull(ls_reqdt) Then ls_reqdt = ""
		
		//필수입력사항 Check
		If ls_mailtype = "" Then
			f_msg_info(200, is_title, "메일유형")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("mailtype")
			ii_rc = -3
			Return
		End If
		
		If ls_filenm = "" Then
			f_msg_info(200, is_title, "FILE명")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("filenm")
			ii_rc = -3
			Return
		End If
		
		If ls_priority = "" Then
			f_msg_info(200, is_title, "우선순위")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("priority")
			ii_rc = -3
			Return
		End If
		
		If ls_mtitle = "" Then
			f_msg_info(200, is_title, "TITLE")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("mtitle")
			ii_rc = -3
			Return
		End If
		
		If ls_sender = "" Then
			f_msg_info(200, is_title, "보내는사람")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("sender")
			ii_rc = -3
			Return
		End If
		
		If ls_reqdt = "" Then
			f_msg_info(200, is_title, "전송예정일")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -3
			Return
		Else
			ldt_reqdt = DateTime(ldt_reqdt)
			ldt_sysdate = fdt_get_dbserver_now()
			
			If ldt_reqdt < ldt_sysdate Then 
				f_msg_info(9000, is_title, "전송예정일이 현재일보다 작습니다.")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("reqdt")
				ii_rc = -3
				Return
			End If
		End If
				
		For ll_row = 1 To idw_data[2].RowCount()
			ls_chk        = Trim(idw_data[2].object.chk[ll_row])
			ls_customerid = Trim(idw_data[2].object.customerid[ll_row])
			ls_customernm = Trim(idw_data[2].object.customernm[ll_row])
			ls_email      = Trim(idw_data[2].object.email1[ll_row])
			
			
			If IsNull(ls_customernm) Then ls_customernm = ""
			If IsNull(ls_email) Then ls_email = ""
			
			IF ls_chk = 'Y' THEN
				If ls_customernm = "" Then
					f_msg_info(200, is_title, "고객명")
					idw_data[2].SetRow(ll_row)
					idw_data[2].ScrollToRow(ll_row)
					idw_data[2].SetFocus()
					idw_data[2].SetColumn("customernm")
					ii_rc = -3
					Return
				End If
			
				If ls_email = "" Then
					f_msg_info(200, is_title, "E-Mail")
					idw_data[2].SetRow(ll_row)
					idw_data[2].ScrollToRow(ll_row)
					idw_data[2].SetFocus()
					idw_data[2].SetColumn("email1")
					ii_rc = -3
					Return
				End If
				
				//Insert contractmst
				insert into emaildata
					( seq                  , 
					  mailtype      , to_name       , to_email     , filenm       , atcfile      ,
					  customerid    , trdt          , chargedt     , use_fromdt   , use_todt     , 
					  priority      , mtitle        ,
					  content       , sender        , reqdt        , senddt       , result       , 
					  resvdt        , flag          ,
					  crt_user      , crtdt         , transdt      , closedt)
				values 
				   ( seq_emaildata.nextval, 
					  :ls_mailtype  , :ls_customernm, :ls_email    , :ls_filenm   , :ls_atcfile  ,
					  :ls_customerid, to_date(null) , to_date(null), to_date(null), to_date(null), 
					  :ls_priority  , :ls_mtitle    ,
					  null          , :ls_sender    , :ldt_reqdt   , to_date(null), null         , 
					  to_date(null) , null          , 
					  :gs_user_id   , sysdate       , to_date(null), to_date(null) );
					   
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Insert Error(EMAILDATA)")
					Return 
				End If	
				
			End If
		Next
		
	Case "b1w_reg_sendsms%save"    //BroadCating SMS
//		lu_dbmgr5.is_caller = "b1w_reg_sendemail%save"
//		lu_dbmgr5.is_title  = Title
//		lu_dbmgr5.idw_data[1] = dw_master
//		lu_dbmgr5.idw_data[2] = dw_detail

				
		ls_smstype  = Trim(idw_data[1].object.smstype[1])
		ls_priority = Trim(idw_data[1].object.priority[1])
		ls_msg      = Trim(idw_data[1].object.msg[1])
		ls_callback = Trim(idw_data[1].object.callback[1])
		ldt_reqdt   = idw_data[1].object.reqdt[1]
		ls_reqdt    = String(idw_data[1].object.reqdt[1], 'yyyymmddhh')
		
		
		If IsNull(ls_smstype) Then ls_smstype = ""
		If IsNull(ls_priority) Then ls_priority = ""
		If IsNull(ls_msg) Then ls_msg = ""
		If IsNull(ls_callback) Then ls_callback = ""
		If IsNull(ls_reqdt) Then ls_reqdt = ""
		
		//필수입력사항 Check
		If ls_smstype = "" Then
			f_msg_info(200, is_title, "SMS유형")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("smstype")
			ii_rc = -3
			Return
		End If
		
		If ls_priority = "" Then
			f_msg_info(200, is_title, "우선순위")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("priority")
			ii_rc = -3
			Return
		End If
		
		If ls_msg = "" Then
			f_msg_info(200, is_title, "메세지")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("msg")
			ii_rc = -3
			Return
		End If
		
		If ls_callback = "" Then
			f_msg_info(200, is_title, "회신번호")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("callback")
			ii_rc = -3
			Return
		Else
			li_pos = PosA(ls_callback, '-')
			Do While li_pos <> 0
				ls_callback = ReplaceA ( ls_callback, li_pos, 1, "" )
				li_pos = PosA(ls_callback, '-')
			Loop
		End If
		
		If ls_reqdt = "" Then
			f_msg_info(200, is_title, "전송예정일")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -3
			Return
		Else
			ldt_reqdt = DateTime(ldt_reqdt)
			ldt_sysdate = fdt_get_dbserver_now()
			
			If ldt_reqdt < ldt_sysdate Then 
				f_msg_info(9000, is_title, "전송예정일이 현재일보다 작습니다.")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("reqdt")
				ii_rc = -3
				Return
			End If
		End If
						
		For ll_row = 1 To idw_data[2].RowCount()
			ls_chk        = Trim(idw_data[2].object.chk[ll_row])
			ls_customerid = Trim(idw_data[2].object.customerid[ll_row])
			ls_customernm = Trim(idw_data[2].object.customernm[ll_row])
			ls_smsphone   = Trim(idw_data[2].object.cellphone[ll_row])
			
			If IsNull(ls_customerid) Then ls_customerid = ""
			If IsNull(ls_customernm) Then ls_customernm = ""
			If IsNull(ls_smsphone) Then ls_smsphone = ""
			
			IF ls_chk = 'Y' THEN		
				If ls_customernm = "" Then
					f_msg_info(200, is_title, "고객명")
					idw_data[2].SetRow(ll_row)
					idw_data[2].ScrollToRow(ll_row)
					idw_data[2].SetFocus()
					idw_data[2].SetColumn("customernm")
					ii_rc = -3
					Return
				End If
				
				If ls_smsphone = "" Then
					f_msg_info(200, is_title, "수신전화번호")
					idw_data[2].SetRow(ll_row)
					idw_data[2].ScrollToRow(ll_row)
					idw_data[2].SetFocus()
					idw_data[2].SetColumn("cellphone")
					ii_rc = -3
					Return
				Else
					li_pos = PosA(ls_smsphone, '-')
					Do While li_pos <> 0
						ls_smsphone = ReplaceA ( ls_smsphone, li_pos, 1, "" )
						li_pos = PosA(ls_smsphone, '-')
					Loop
				End If
				
				//Insert contractmst
				insert into smsdata
					 ( seq          , 
					   smstype      , customerid    , to_smsphone  , callback,
					   msg          , priority      , reqdt        ,        
						senddt       , result        , 
						crt_user     , crtdt         , pgm_id       , transdt)
				values ( seq_smsdata.nextval, 
				      :ls_smstype  , :ls_customerid, :ls_smsphone , :ls_callback,
					   :ls_msg      , :ls_priority  , :ldt_reqdt   , 
						to_date(null), null, 
						:gs_user_id  , sysdate       , :gs_pgm_id[gi_open_win_no], to_date(null));
					   
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Insert Error(SMSDATA)")
					Return 
				End If	
				
			End If
		Next
		
	Case "b1w_reg_sendsms_new%save"    //BroadCating SMS
//		lu_dbmgr5.is_caller = "b1w_reg_sendemail%save"
//		lu_dbmgr5.is_title  = Title
//		lu_dbmgr5.idw_data[1] = dw_master
//		lu_dbmgr5.idw_data[2] = dw_detail

				
		ls_smstype  = Trim(idw_data[1].object.smstype[1])  // 
		ls_priority = Trim(idw_data[1].object.priority[1]) // 우선순위
		ls_msg      = Trim(idw_data[1].object.msg[1])      // 메세지
		ls_callback = Trim(idw_data[1].object.callback[1]) // 회신번호
		ldt_reqdt   = idw_data[1].object.reqdt[1]          // 전송예정일
		ls_reqdt    = String(idw_data[1].object.reqdt[1], 'yyyymmddhhmm')
		
		
		If IsNull(ls_smstype)  Then ls_smstype  = ""
		If IsNull(ls_priority) Then ls_priority = ""
		If IsNull(ls_msg)      Then ls_msg      = ""
		If IsNull(ls_callback) Then ls_callback = ""
		If IsNull(ls_reqdt)    Then ls_reqdt    = ""
		
		//필수입력사항 Check
		If ls_smstype = "" Then
			f_msg_info(200, is_title, "SMS유형")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("smstype")
			ii_rc = -3
			Return
		End If
		
//		If ls_priority = "" Then
//			f_msg_info(200, is_title, "우선순위")
//			idw_data[1].SetRow(1)
//			idw_data[1].ScrollToRow(1)
//			idw_data[1].SetFocus()
//			idw_data[1].SetColumn("priority")
//			ii_rc = -3
//			Return
//		End If
		
		If ls_msg = "" Then
			f_msg_info(200, is_title, "메세지")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("msg")
			ii_rc = -3
			Return
		End If
		
		IF LenA(ls_msg) > 80 THEN
			f_msg_info(200, is_title, "메세지는 최대 80 Bytes 까지 가능합니다.")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("msg")
			ii_rc = -3
			Return
		End If						
			
		If ls_callback = "" Then
			f_msg_info(200, is_title, "회신번호")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("callback")
			ii_rc = -3
			Return
		Else
			li_pos = PosA(ls_callback, '-')
			Do While li_pos <> 0
				ls_callback = ReplaceA ( ls_callback, li_pos, 1, "" )
				li_pos = PosA(ls_callback, '-')
			Loop
		End If
		
		If ls_reqdt = "" Then
			f_msg_info(200, is_title, "전송예정일")
			idw_data[1].SetRow(1)
			idw_data[1].ScrollToRow(1)
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("reqdt")
			ii_rc = -3
			Return
		Else
			ldt_reqdt = DateTime(ldt_reqdt)
			ldt_sysdate = fdt_get_dbserver_now()
			
			If ldt_reqdt < ldt_sysdate Then 
				f_msg_info(9000, is_title, "전송예정일이 현재일보다 작습니다.")
				idw_data[1].SetRow(1)
				idw_data[1].ScrollToRow(1)
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("reqdt")
				ii_rc = -3
				Return
			End If
		End If
		
		ls_reqdt_new = ls_reqdt + '00' // 기존 년월일 시분에 '00'
						
		For ll_row = 1 To idw_data[2].RowCount()
			ls_chk        = Trim(idw_data[2].object.chk[ll_row])
			ls_customerid = Trim(idw_data[2].object.customerid[ll_row])
			ls_customernm = Trim(idw_data[2].object.customernm[ll_row])
			ls_smsphone   = Trim(idw_data[2].object.cellphone[ll_row])
			
			If IsNull(ls_customerid) Then ls_customerid = ""
			If IsNull(ls_customernm) Then ls_customernm = ""
			If IsNull(ls_smsphone)   Then ls_smsphone = ""
			
			IF ls_chk = 'Y' THEN		
				If ls_customernm = "" Then
					f_msg_info(200, is_title, "고객명")
					idw_data[2].SetRow(ll_row)
					idw_data[2].ScrollToRow(ll_row)
					idw_data[2].SetFocus()
					idw_data[2].SetColumn("customernm")
					ii_rc = -3
					Return
				End If
				
				If ls_smsphone = "" Then
					f_msg_info(200, is_title, "수신전화번호")
					idw_data[2].SetRow(ll_row)
					idw_data[2].ScrollToRow(ll_row)
					idw_data[2].SetFocus()
					idw_data[2].SetColumn("cellphone")
					ii_rc = -3
					Return
				Else
					li_pos = PosA(ls_smsphone, '-')
					Do While li_pos <> 0
						ls_smsphone = ReplaceA ( ls_smsphone, li_pos, 1, "" )
						li_pos = PosA(ls_smsphone, '-')
					Loop
					
					ll_len = LenA(ls_smsphone)
					
					IF ll_len < 10 OR ll_len > 11 THEN
						F_MSG_INFO(9000, is_title, "수신번호가 이상합니다 :" + ls_smsphone)
						idw_data[2].SetRow(ll_row)
						idw_data[2].ScrollToRow(ll_row)
						idw_data[2].SetFocus()
						idw_data[2].SetColumn("cellphone")
						ii_rc = -3
						Return
					ELSE
						ls_gubun = MidA(ls_smsphone, 1, 3)
						
						IF ls_gubun <> '070' AND ls_gubun <> '010' AND ls_gubun <> '011' AND ls_gubun <> '016' AND ls_gubun <> '017' AND ls_gubun <> '018' AND ls_gubun <> '019' THEN
							F_MSG_INFO(9000, is_title, "수신번호가 이상합니다 :" + ls_smsphone)
							idw_data[2].SetRow(ll_row)
							idw_data[2].ScrollToRow(ll_row)
							idw_data[2].SetFocus()
							idw_data[2].SetColumn("cellphone")
							ii_rc = -3
							Return
						END IF
					END IF					
				End If
				
				INSERT INTO SMS.SC_TRAN
					( TR_NUM                                      , 
					  TR_SENDDATE                                 , 
					  TR_SENDSTAT                                 , TR_PHONE    ,
					  TR_CALLBACK                                 , TR_MSG      , TR_MSGTYPE )
				VALUES 
				   ( SMS.SC_SEQUENCE.NEXTVAL                     , 
					  TO_DATE(:ls_reqdt_new  , 'yyyymmddhh24miss'), 
					  '0'                                         , :ls_smsphone,
					  :ls_callback                                , :ls_msg     , '0'        );
				
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Insert Error(SMS.SC_TRAN)")
					Return 
				End If	
				
			End If
		Next		

End Choose

ii_rc = 0

Return 
end subroutine

on b1u_dbmgr6.create
call super::create
end on

on b1u_dbmgr6.destroy
call super::destroy
end on

