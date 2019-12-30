$PBExportHeader$b1u_dbmgr11.sru
$PBExportComments$[ohj]대리점 인증key 할당 db
forward
global type b1u_dbmgr11 from u_cust_a_db
end type
end forward

global type b1u_dbmgr11 from u_cust_a_db
end type
global b1u_dbmgr11 b1u_dbmgr11

forward prototypes
public subroutine uf_prc_db_03 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db_03 ();//인증key 이동 처리
String ls_fr_partner, ls_priceplan, ls_remark, ls_status, ls_user_id, ls_pgm_id, &
       ls_to_prefixno, ls_rowid, ls_validkey_type, ls_to_partner, ls_validkey  , &
		 ls_vald_type, ls_st, ls_validkey_fr, ls_validkey_to
Long   ll_moveqty, ll_seqq, ll_seq, ll_seqqq, ll_su, ll_code = 1

ls_fr_partner    = is_data[1]   
ls_to_partner    = is_data[2]
ls_validkey_type = is_data[3] 
ls_priceplan     = is_data[4]  
ls_remark        = is_data[5]   
ls_status        = is_data[6]  //인증key 이동상태 '22'
ls_user_id       = is_data[7]
ls_pgm_id        = is_data[8]

ll_moveqty       = il_data[1]  //이동요청수량
ll_su            = il_data[2]  //이동할당수량
ll_seq           = il_data[3]  //seq_validkey_moveno  인증key 할당log

ii_rc = -1

If IsNull(ls_priceplan) Then ls_priceplan = " "

//SEQ  인증key 할당요청
Select seq_validkey_requestno.nextval 
  into :ll_seqq 
  from dual;
  
//SEQ  인증keymst 로그
Select SEQ_VALIDKEYMSTLOG.nextval 
  into :ll_seqqq
  from dual;  

//대리점 prefix찾기		
SELECT PREFIXNO
  INTO :ls_to_prefixno
  FROM PARTNERMST
 WHERE PARTNER = :ls_to_partner  ;  
 
//인증key 할당요청(VALIDKEY_REQUEST)
INSERT INTO VALIDKEY_REQUEST
          ( REQUESTNO
			 , REQSTAT
			 , FR_PARTNER
			 , TO_PARTNER
			 , VALIDKEY_TYPE
			 , PRICEPLAN
			 , REQQTY
			 , MOVEQTY
			 , OMAN
			 , MOVEDT
			 , ACCEPT_YN
			 , CRT_USER
			 , CRTDT
			 , PGM_ID                    )
	  VALUES 
	       ( :ll_seqq
			 , '11'                   	//처리완료
			 , :ls_fr_partner
			 , :ls_to_partner
			 , :ls_validkey_type
			 , :ls_priceplan
			 , :ll_moveqty        		//이동요청수량
			 , :ll_su            		//이동가능수량
			 , :ls_user_id
			 , sysdate
          , 'Y'
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id                ) ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(VALIDKEY_REQUEST)")
	RollBack;
	Return
End If

DECLARE validkeymst_cu CURSOR FOR
	SELECT VALIDKEY
	     , VALIDKEY_TYPE
		  , STATUS
	     , ROWID
	  FROM VALIDKEYMST
	 WHERE SALE_FLAG           = '0'
	   AND PARTNER             = :ls_fr_partner
		AND VALIDKEY_TYPE       = :ls_validkey_type
		AND NVL(PRICEPLAN, ' ') = :ls_priceplan
	   AND ROWNUM             <= :ll_su
 ORDER BY VALIDKEY            ;
	 
OPEN validkeymst_cu;
	DO WHILE (True)
		Fetch validkeymst_cu
		Into :ls_validkey, :ls_vald_type, :ls_st, :ls_rowid;
				
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
				
		//인증key 시작
		If ls_validkey_fr = '' Then
			ls_validkey_fr = ls_validkey
		End If
		
		//인증key 끝
		ls_validkey_to = ls_validkey
		
		//인증keymst 로그 (validkeymst_log)
		INSERT INTO VALIDKEYMST_LOG
					 ( VALIDKEY
					 , SEQ
					 , STATUS
					 , ACTDT
					 , PARTNER
					 , CRT_USER
					 , CRTDT
					 , PGM_ID     )
			  VALUES
					 ( :ls_validkey
					 , :ll_seqqq
					 , :ls_status		//인증key 이동
					 , sysdate
					 , :ls_to_partner					 
					 , :ls_user_id
					 , sysdate
					 , :ls_pgm_id               ) ;
					 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Insert Error(VALIDKEYMST_LOG)")
			ll_code = 0
			exit
		End If				
				
		//인증key master
		UPDATE VALIDKEYMST
		   SET PARTNER        = :ls_to_partner
			  , PARTNER_PREFIX = :ls_to_prefixno
			  , STATUS         = :ls_status					//인증key 이동
			  , MOVEDT         = sysdate
			  , MOVENO         = :ll_seq                	//인증key 할당log
			  , REMARK         = :ls_remark
			  , UPDT_USER      = :ls_user_id
			  , UPDTDT         = sysdate
	    WHERE ROWID = :ls_rowid    ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Update Error(VALIDKEYMST)")
			ll_code = 0
			exit
		End If
	LOOP
	
	If ll_code = 0 Then
		rollback;
		Return
	End If
			
CLOSE validkeymst_cu;

//인증key 할당log(VALIDKEY_MOVE)
INSERT INTO VALIDKEY_MOVE
          ( MOVENO
			 , FR_PARTNER
			 , TO_PARTNER
			 , VALIDKEY_TYPE
			 , PRICEPLAN
			 , MOVEQTY
			 , FR_VALIDKEY
			 , TO_VALIDKEY
			 , REQUESTNO
			 , REMARK
			 , CRT_USER
			 , CRTDT
			 , PGM_ID                  )
     VALUES
	       ( :ll_seq
		    , :ls_fr_partner
			 , :ls_to_partner
			 , :ls_validkey_type
			 , :ls_priceplan
			 , :ll_su
			 , :ls_validkey_fr
			 , :ls_validkey_to
			 , :ll_seqq                    //인증키 할당 요청번호
			 , :ls_remark
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id              )   ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(VALIDKEY_MOVE)")
	RollBack;
	Return
End If	

ii_rc = 0
Return
end subroutine

public subroutine uf_prc_db_02 ();//인증키 요청할당
String ls_fr_partner, ls_priceplan, ls_remark, ls_status, ls_user_id, ls_pgm_id, ls_prefixno
String ls_rowid, ls_temp, ls_ref_desc, ls_result[], ls_boncod, ls_validkey_type
String ls_validkey, ls_vald_type, ls_st, ls_validkey_fr, ls_validkey_to
Long   ll_reqqty, ll_seqq, ll_seq, ll_seqqq, ll_su, ll_requestno, ll_code = 1

ls_fr_partner    = is_data[1]   
ls_priceplan     = is_data[2]  
ls_remark        = is_data[3]   
ls_status        = is_data[4]		//인증key 할당 상태
ls_prefixno      = is_data[5]
ls_validkey_type = is_data[6]
ls_user_id       = is_data[7]
ls_pgm_id        = is_data[8]

ll_reqqty        = il_data[1]  	//요청수량
ll_seq           = il_data[2]  	//seq_validkey_moveno
ll_requestno     = il_data[3]
ll_su            = il_data[4]  	//할당수량

ii_rc = -1

//SEQ
Select SEQ_VALIDKEYMSTLOG.nextval 
  into :ll_seqqq
  from dual;  
  
//본사 코드
ls_temp = fs_get_control("A1","C102", ls_ref_desc)
		
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

ls_boncod = ls_result[1]

//인증key 할당요청(VALIDKEY_REQUEST)
UPDATE VALIDKEY_REQUEST
   SET REQSTAT   = '11'
	  , MOVEQTY   = :ll_su
	  , ACCEPT_YN = 'Y'
	  , OMAN      = :ls_user_id
	  , MOVEDT    = sysdate
	  , UPDT_USER = :ls_user_id
	  , UPDTDT    = sysdate
 WHERE REQUESTNO = :ll_requestno ;
 
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Update Error(VALIDKEY_REQUEST)")
	RollBack;
	Return
End If

DECLARE validkeymst_cu CURSOR FOR
	SELECT VALIDKEY
	     , VALIDKEY_TYPE
		  , STATUS
	     , ROWID
	  FROM VALIDKEYMST
	 WHERE SALE_FLAG        = '0'
	   AND NVL(PARTNER, '') = '00000000'
		AND VALIDKEY_TYPE    = :ls_validkey_type
	   AND ROWNUM          <= :ll_su
 ORDER BY VALIDKEY                                 ;
	 
OPEN validkeymst_cu;
	DO WHILE (True)
		Fetch validkeymst_cu
		Into :ls_validkey, :ls_vald_type, :ls_st, :ls_rowid;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		//인증key 시작
		If ls_validkey_fr = '' Then
			ls_validkey_fr = ls_validkey
		End If
		
		//인증key 끝
		ls_validkey_to = ls_validkey
		
		//인증keymst 로그 (validkeymst_log)
		INSERT INTO VALIDKEYMST_LOG
					 ( VALIDKEY
					 , SEQ
					 , STATUS
					 , ACTDT
					 , PARTNER
					 , CRT_USER
					 , CRTDT
					 , PGM_ID     )
			  VALUES
					 ( :ls_validkey
					 , :ll_seqqq
					 , :ls_status	//인증key 할당 상태
					 , sysdate
					 , :ls_fr_partner					 
					 , :ls_user_id
					 , sysdate
					 , :ls_pgm_id               ) ;
					 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Insert Error(VALIDKEYMST_LOG)")
			ll_code = 0
			Exit
		End If				
				
		//인증key master
		UPDATE VALIDKEYMST
		   SET PARTNER        = :ls_fr_partner
			  , PARTNER_PREFIX = :ls_prefixno
			  , STATUS         = :ls_status				//인증key 할당			  
			  , MOVEDT         = sysdate
			  , MOVENO         = :ll_seq              //인증key 할당log
			  , PRICEPLAN      = :ls_priceplan
			  , REMARK         = :ls_remark
			  , UPDT_USER      = :ls_user_id
			  , UPDTDT         = sysdate
	    WHERE ROWID = :ls_rowid    ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Update Error(VALIDKEYMST)")
			ll_code = 0
			Exit
		End If
	LOOP
	
	If ll_code = 0 Then
		rollback;
		Return
	End If

CLOSE validkeymst_cu;

//인증key 할당log(VALIDKEY_MOVE)
INSERT INTO VALIDKEY_MOVE
          ( MOVENO
			 , FR_PARTNER
			 , TO_PARTNER
			 , VALIDKEY_TYPE
			 , PRICEPLAN
			 , MOVEQTY
			 , FR_VALIDKEY
			 , TO_VALIDKEY
			 , REQUESTNO
			 , REMARK
			 , CRT_USER
			 , CRTDT
			 , PGM_ID                  )
     VALUES
	       ( :ll_seq
		    , :ls_boncod
			 , :ls_fr_partner
			 , :ls_validkey_type
			 , :ls_priceplan
			 , :ll_su
			 , :ls_validkey_fr
			 , :ls_validkey_to
			 , :ll_requestno      //인증키 할당 요청번호
			 , :ls_remark
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id              )   ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(VALIDKEY_MOVE)")
	RollBack;
	Return
End If	

ii_rc = 0
Return
end subroutine

public subroutine uf_prc_db_01 ();//인증키 무요청 할당
String ls_fr_partner, ls_priceplan, ls_remark, ls_status, ls_user_id, ls_pgm_id, ls_prefixno
String ls_rowid, ls_temp, ls_ref_desc, ls_result[], ls_boncod, ls_validkey_type
String ls_validkey, ls_vald_type, ls_st, ls_validkey_fr, ls_validkey_to
Long   ll_reqqty, ll_seqq, ll_seq, ll_seqqq, ll_su, ll_code = 1

ls_fr_partner    = is_data[1]   
ls_priceplan     = is_data[2]  
ls_remark        = is_data[3]   
ls_status        = is_data[4]  //인증key 할당상태
ls_prefixno      = is_data[5]
ls_validkey_type = is_data[6] 
ls_user_id       = is_data[7]
ls_pgm_id        = is_data[8]

ll_reqqty        = il_data[1]  //요청수량
ll_seq           = il_data[2]  //seq_validkey_moveno
ll_su            = il_data[3]  //할당수량

ii_rc = -1

//SEQ
Select seq_validkey_requestno.nextval 
  into :ll_seqq 
  from dual;
  
//SEQ
Select SEQ_VALIDKEYMSTLOG.nextval 
  into :ll_seqqq
  from dual;  
  
//본사 코드'00000000'
ls_temp = fs_get_control("A1","C102", ls_ref_desc)
		
If ls_temp <> "" Then
	fi_cut_string(ls_temp, ";" , ls_result[])
End if

ls_boncod = ls_result[1]

//인증key 할당요청(VALIDKEY_REQUEST)
INSERT INTO VALIDKEY_REQUEST
          ( REQUESTNO
			 , REQSTAT
			 , FR_PARTNER
			 , TO_PARTNER
			 , VALIDKEY_TYPE
			 , PRICEPLAN
			 , REQQTY
			 , MOVEQTY
			 , OMAN
			 , MOVEDT
			 , ACCEPT_YN
			 , CRT_USER
			 , CRTDT
			 , PGM_ID                    )
	  VALUES 
	       ( :ll_seqq
			 , '11'                   	//처리완료
			 , :ls_boncod
			 , :ls_fr_partner
			 , :ls_validkey_type
			 , :ls_priceplan
			 , :ll_reqqty        		//요청수량
			 , :ll_su            		//할당가능수량
			 , :ls_user_id
			 , sysdate
          , 'Y'
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id                ) ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(VALIDKEY_REQUEST)")
	RollBack;
	Return
End If

DECLARE validkeymst_cu CURSOR FOR
	SELECT VALIDKEY
	     , VALIDKEY_TYPE
		  , STATUS
	     , ROWID
	  FROM VALIDKEYMST
	 WHERE SALE_FLAG        = '0'
	   AND NVL(PARTNER, '') = '00000000'
		AND VALIDKEY_TYPE    = :ls_validkey_type
	   AND ROWNUM          <= :ll_su
 ORDER BY VALIDKEY                                 ;
	 
OPEN validkeymst_cu;
	DO WHILE (True)
		Fetch validkeymst_cu
		Into :ls_validkey, :ls_vald_type, :ls_st, :ls_rowid;
		
		If SQLCA.SQLCode < 0 Then
			ll_code = 0
			Exit
		ElseIf SQLCA.SQLCode = 100 Then
			Exit
   	End If
		
		//인증key 시작
		If ls_validkey_fr = '' Then
			ls_validkey_fr = ls_validkey
		End If
		
		//인증key 끝
		ls_validkey_to = ls_validkey
		
		//인증keymst 로그 (validkeymst_log)
		INSERT INTO VALIDKEYMST_LOG
					 ( VALIDKEY
					 , SEQ
					 , STATUS
					 , ACTDT
					 , PARTNER
					 , CRT_USER
					 , CRTDT
					 , PGM_ID     )
			  VALUES
					 ( :ls_validkey
					 , :ll_seqqq
					 , :ls_status		//인증key 할당
					 , sysdate
					 , :ls_fr_partner					 
					 , :ls_user_id
					 , sysdate
					 , :ls_pgm_id               ) ;
					 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Insert Error(VALIDKEYMST_LOG)")
			ll_code = 0
			Exit
		End If				
				
		//인증key master
		UPDATE VALIDKEYMST
		   SET PARTNER        = :ls_fr_partner
			  , PARTNER_PREFIX = :ls_prefixno
			  , STATUS         = :ls_status					//인증key 할당
			  , MOVEDT         = sysdate
			  , MOVENO         = :ll_seq                	//인증key 할당log
			  , PRICEPLAN      = :ls_priceplan
			  , REMARK         = :ls_remark
			  , UPDT_USER      = :ls_user_id
			  , UPDTDT         = sysdate
	    WHERE ROWID = :ls_rowid    ;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "Update Error(VALIDKEYMST)")
			ll_code = 0
			Exit
		End If
	LOOP
	
	If ll_code = 0 Then
		rollback;
		Return
	End If
	
CLOSE validkeymst_cu;

//인증key 할당log(VALIDKEY_MOVE)
INSERT INTO VALIDKEY_MOVE
          ( MOVENO
			 , FR_PARTNER
			 , TO_PARTNER
			 , VALIDKEY_TYPE
			 , PRICEPLAN
			 , MOVEQTY
			 , FR_VALIDKEY
			 , TO_VALIDKEY
			 , REQUESTNO
			 , REMARK
			 , CRT_USER
			 , CRTDT
			 , PGM_ID                  )
     VALUES
	       ( :ll_seq
		    , :ls_boncod
			 , :ls_fr_partner
			 , :ls_validkey_type
			 , :ls_priceplan
			 , :ll_su
			 , :ls_validkey_fr
			 , :ls_validkey_to
			 , :ll_seqq                    //인증키 할당 요청번호
			 , :ls_remark
			 , :ls_user_id
			 , sysdate
			 , :ls_pgm_id              )   ;
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(is_Title, "Insert Error(VALIDKEY_MOVE)")
	RollBack;
	Return
End If	

ii_rc = 0
Return
end subroutine

on b1u_dbmgr11.create
call super::create
end on

on b1u_dbmgr11.destroy
call super::destroy
end on

