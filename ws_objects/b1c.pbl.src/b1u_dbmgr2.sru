$PBExportHeader$b1u_dbmgr2.sru
$PBExportComments$[parkkh] DB Manager
forward
global type b1u_dbmgr2 from u_cust_a_db
end type
end forward

global type b1u_dbmgr2 from u_cust_a_db
end type
global b1u_dbmgr2 b1u_dbmgr2

type variables

end variables

forward prototypes
public function integer ufi_other_validinfo (string as_customerid, string as_validkey, string as_fromdt, string as_todt)
public subroutine uf_prc_db_06 ()
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db_04 ()
public subroutine uf_prc_db_05 ()
public subroutine uf_prc_db ()
public function integer uf_prc_date_range (string as_old_start, string as_old_end, string as_start, string as_end)
public subroutine uf_prc_db_03 ()
end prototypes

public function integer ufi_other_validinfo (string as_customerid, string as_validkey, string as_fromdt, string as_todt);/*------------------------------------------------------------------------
	Name	:	ufi_other_validinfo
	Desc	:	같은 기간에 같은 고객에 인증 key가 겹치면 안된다.
	Arg.	:	string as_customerid
				string as_fromdt	as_todt
	Reg.	:  0 성공
				-1 중복 있음
				-2 Error
--------------------------------------------------------------------------*/
String ls_other_fromdt, ls_other_todt
Integer li_return


DECLARE validinfo CURSOR FOR
Select to_char(fromdt, 'yyyymmdd'), to_char(todt, 'yyyymmdd')
From validinfo
Where customerid =  :as_customerid and validkey = :as_validkey;

OPEN validinfo;
Do While(True)
	FETCH validinfo
	INTO :ls_other_fromdt, :ls_other_todt;
	
	If SQLCA.sqlcode < 0 Then
		f_msg_sql_err(is_title, "Cursor validinfo")
		CLOSE validinfo;
		Return -2
	ElseIf SQLCA.SQLCode = 100 Then
		Exit
	End If
	
	li_return = uf_prc_date_range(ls_other_fromdt, ls_other_todt, as_fromdt, as_todt)
	If li_return = - 1 Then
		CLOSE validinfo;
		Return -1
	End If	
	
Loop
CLOSE validinfo;
	

Return 0 
end function

public subroutine uf_prc_db_06 ();
// "b1w_reg_svc_termorder%save"
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_pgm_id, ls_requestactive, ls_termstatus, ls_ref_desc
String ls_act_gu , ls_status, ls_enddt, ls_act_yn, ls_payid, ls_customerid_1
Datetime ldt_crtdt
Long ll_cnt, ll_row, ll_cnt1, ll_cur
Dec ldc_orderno
String ls_contractseq
String ls_check_yn, ls_remark

// "b1w_reg_sn_change%save"
String ls_action, ls_endstatus, ls_daricod, ls_boncod, ls_bonsacod, ls_bulstatus, ls_chagflag
String ls_seq, ls_act_status, ls_bef_adseq, ls_aft_adseq, ls_aft_sale_flag, ls_aft_sn_partner
String ls_aft_status, ls_bef_sn_partner, ls_bef_status, ls_bef_sn, ls_aft_sn, ls_gibul
String ls_bef_modelnm, ls_aft_modelnm
Integer li_i
Datetime ldt_chgdt

// Com-N-Life 

ii_rc = -2

Choose Case is_caller
	Case "b1w_reg_sn_change%save"                     //기기변경
//		lu_dbmgr.is_caller = "b1w_reg_sn_change%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr2.is_data[1] = is_status           //기기변경신청코드
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
	
      idw_data[1].AcceptText()	
		ls_pgm_id = gs_pgm_id[gi_open_win_no]		

		//기기변경코드
		ls_action = fs_get_control("E1","A306", ls_ref_desc)
		//기기변경완료 update
		ls_endstatus = fs_get_control("E1","E201", ls_ref_desc)			
		//대리점재고 상태코드
		ls_daricod = fs_get_control("E1","A102", ls_ref_desc)
		//본사재고 상태코드
		ls_boncod = fs_get_control("E1","A100", ls_ref_desc)
		//본사 대리점코드 
		ls_bonsacod = fs_get_control("A1","C102", ls_ref_desc)
		//기기불량 코드				
		ls_bulstatus = fs_get_control("E1","A201", ls_ref_desc)	
		
		is_data[2] = ""
		is_data[3] = ""
		ii_data[1] = 0
		ii_data[2] = 0		
		ii_data[3] = 0
	
		for li_i = 1 to ll_row

			//변경적용 check 된 것만 처리한다.
			ls_chagflag = idw_data[1].object.chagflag[li_i]
			If Isnull(ls_chagflag) Then ls_chagflag = ""
			If ls_chagflag = 'N' or ls_chagflag = "" then continue
			
			//실시간이라서. 다시 해당 row act_status를 select해서 기기변경신청 상태인 것만 처리한다.
			ls_seq = String(idw_data[1].object.snchgreq_seq[li_i])
			If Isnull(ls_seq) Then ls_seq = ""			
			
			select act_status
			  into :ls_act_status
			  from snchgreq
			 where to_char(seq) = :ls_seq;
			  
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT snchgreq")			
				ii_rc = -1			
				RollBack;
				Return 
			End If	
			
			If ls_act_status <> is_data[1] then continue
			
			ls_bef_adseq = string(idw_data[1].object.snchgreq_bef_adseq[li_i])
			ls_aft_adseq = string(idw_data[1].object.snchgreq_aft_adseq[li_i])			
			
			select sale_flag,
			       sn_partner,
					 status
			  into :ls_aft_sale_flag,
			       :ls_aft_sn_partner,
					 :ls_aft_status
			 from admst
			 where to_char(adseq) = :ls_aft_adseq;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT admst(AFT sale_flag)")			
				ii_rc = -1			
				RollBack;
				Return 
			End If	
			 
			If ls_aft_sale_flag <> '0' then
				ii_data[1] ++
				is_data[2] = is_data[2] + ls_seq + ","
				continue				
//		   	f_msg_info(9000, is_title, "["+string(ll_row) + "번째행]" + "변경할 단말기가 이미 출고된 상태로 기기변경불가")
//				ii_rc = -1			
//				RollBack;
//				Return 
			End if	
			
			select sn_partner, status
			  into :ls_bef_sn_partner,
			  		 :ls_bef_status
			 from admst
			 where to_char(adseq) = :ls_bef_adseq;
			 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT admst(BEF sn_partner)")			
				ii_rc = -1
				RollBack;
				Return 
			End If	
			 
			If ls_bef_sn_partner <> ls_aft_sn_partner then
				ii_data[2] ++
				is_data[3] = is_data[3] + ls_seq + ","
				continue								
//		   	f_msg_info(9000, is_title, "["+string(ll_row) + "번째행]" + "단말기SN가 해당총판에 할당되어 있지 않습니다.")
//				ii_rc = -1			
//				RollBack;
//				Return 
			End if	

			ldt_chgdt = idw_data[1].object.snchgreq_chgdt[li_i]
			If Isnull(ldt_chgdt) then ldt_chgdt = fdt_get_dbserver_now()
			
			Update snchgreq
			Set act_status = :ls_endstatus,
				 chgdt = :ldt_chgdt,
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :ls_pgm_id
			Where to_char(seq) = :ls_seq;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update snchgreq Table")				
				Return 
			End If
		
			ls_customerid = idw_data[1].object.snchgreq_customerid[li_i]
			ls_bef_sn = idw_data[1].object.snchgreq_bef_sn[li_i]		
			ls_aft_sn = idw_data[1].object.snchgreq_aft_sn[li_i]						
			
			//Insert(변경후 단말기 장비이력)
			insert into admstlog
				 ( adseq, seq, action, status, actdt, customerid, fr_partner, remark,
 					crt_user, crtdt, pgm_id )
 			values ( :ls_aft_adseq,
		            seq_admstlog.nextval,
						:ls_action,
						:ls_aft_status,
						sysdate,
						:ls_customerid,
						:ls_aft_sn_partner,
						:ls_bef_sn || '에서 기기변경됨',
						:gs_user_id, sysdate, :ls_pgm_id);
	
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(admstlog-변경후 단말기)")
				Return 
			End If	
			
			//Insert(변경전 단말기 장비이력)
			insert into admstlog
				 ( adseq, seq, action, status, actdt, customerid, fr_partner, remark,
 					crt_user, crtdt, pgm_id )
 			values ( :ls_bef_adseq,
		            seq_admstlog.nextval,
						:ls_action,
						:ls_bef_status,
						sysdate,
						null,
						:ls_bef_sn_partner,
						:ls_aft_sn || '으로 기기변경됨',
						:gs_user_id, sysdate, :ls_pgm_id);
	
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(admstlog-변경전 단말기)")
				Return 
			End If	

			Update admst
			Set (status,saledt,pid,customerid,contractseq,orderno,sale_amt,sale_flag,dlvstat,updt_user,updtdt,pgm_id) =
			    (select status,saledt,pid,customerid,contractseq,orderno,sale_amt,sale_flag,dlvstat,:gs_user_id,sysdate,:ls_pgm_id
				   from admst where to_char(adseq) = :ls_bef_adseq )
    		Where to_char(adseq) = :ls_aft_adseq;
			 
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update admst Table(변경후단말기)")
				Return 
			End If
			
			//고객H/W 정보 Update
			ls_bef_modelnm = Trim(idw_data[1].object.bef_modelnm[li_i])
			ls_aft_modelnm = Trim(idw_data[1].object.aft_modelnm[li_i])
						
			Update customer_hw
			Set    serialno   = :ls_aft_sn,
			       modelnm    = :ls_aft_modelnm,
					 updt_user  = :gs_user_id,
					 updtdt     = sysdate
			Where  customerid = :ls_customerid
			And    serialno   = :ls_bef_sn
			And    modelnm    = :ls_bef_modelnm ;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update customer_hw Table(변경후단말기)")
				Return 
			End If
			
			ls_gibul = idw_data[1].object.snchgreq_badflag[li_i]
			
			If ls_gibul = 'Y' then
				
				Update admst
				Set status = decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
					 saledt = null,
					 pid = null,
					 customerid = null,
					 sale_amt = 0,
					 sale_flag = '0',
					 contractseq = null,
					 orderno = null,
					 dlvstat = null,
					 use_yn='N',
					 adstat = :ls_bulstatus,
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id
				Where to_char(adseq) = :ls_bef_adseq;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;		
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update admst Table(변경전 단말기)")				
					Return 
				End If
		
		 	Else
				
				Update admst
				Set status = decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
					 saledt = null,
					 customerid = null,
					 pid = null,					 
					 sale_amt = 0,
					 sale_flag = '0',
					 contractseq = null,
					 orderno = null,
					 dlvstat = null,
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id
				Where to_char(adseq) = :ls_bef_adseq;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;		
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update admst Table(변경전 단말기)")				
					Return 
				End If
				
			End if			
			
			ii_data[3] ++
	next
   
	Commit;
			
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0


end subroutine

public subroutine uf_prc_db_01 ();//공통
Long ll_rows, ll_insrow

//CDR 조회
String ls_sql, ls_customerid
String ls_workdt_fr, ls_workdt_to, ls_sql_1, ls_rtelnum
String ls_type, ls_tname, ls_nodeno
String ls_where, ls_validkey, ls_seqno
Long   ll_seqno, ll_biltime
DateTime ldt_stime, ldt_etime, ldt_crtdt
Dec ldc_bilamt

ll_insrow = 0
ii_rc = -1

Choose Case is_caller
	Case "P_CDR-YYYYMMDD"
		// 작성자 ; parkkh(2003/01/14)
		//**Call Window : b14w_reg_pps_card
		//**   Argument : 
//							iu_db01.is_caller = "P_CDR-YYYYMMDD"
//							iu_db01.is_title = Title
//							iu_db01.is_data[1] = ls_customerid //고객번호
//							iu_db01.is_data[2] = ls_workdt_fr //이용 시작일
//							iu_db01.is_data[3] = ls_workdt_to //이용 종료일
//							iu_db01.idw_data[1] = tab_1.idw_tabpage[2]
		
		ls_workdt_fr = is_data[2]
		ls_workdt_to = is_data[3]
		
		ll_insrow = 0
				
		DECLARE cur_read_cdr_table DYNAMIC CURSOR FOR SQLSA;
		DECLARE cur_read_cdr DYNAMIC CURSOR FOR SQLSA;
		
		ls_sql = "SELECT tname " + &
					"FROM tab " + &
					"WHERE tabtype = 'TABLE' " + &
					" AND " + "tname >= 'POST_CDR" + is_data[2] + "' " + &
					" AND " + "tname <= 'POST_CDR" + is_data[3] + "' "  + &
					" AND " + "substr(tname,1,8) = 'POST_CDR' " + &
		  		  " ORDER BY tname DESC"
					
		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC cur_read_cdr_table;

		//DW 초기화
		ll_rows = idw_data[1].RowCount()
		If ll_rows > 0 Then idw_data[1].RowsDiscard(1, ll_rows, Primary!)
		ll_rows = 0


		Do While(True)
			FETCH cur_read_cdr_table
			INTO :ls_tname;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_cdr_table")
				CLOSE cur_read_cdr_table;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If

			//검색된 테이블에서 자료를 읽기
			ls_sql_1 = " SELECT STIME, ETIME, BILTIME, stelnum, RTELNUM, BILAMT, VALIDKEY, to_char(SEQNO), CRTDT" + &
						 " FROM " + ls_tname + " " + &
						"WHERE customerid = '" + is_data[1] + "' " + & 
					  " ORDER BY stime DESC "

//			//검색된 테이블에서 자료를 읽기
//			ls_sql_1 = " SELECT STIME, ETIME, BILTIME, NODENO, RTELNUM, BILAMT, VALIDKEY, to_char(SEQNO), CRTDT" + &
//						 " FROM " + ls_tname + " " + &
//						 + ls_where + &
//					  " ORDER BY stime DESC "

			PREPARE SQLSA FROM :ls_sql_1;
			OPEN DYNAMIC cur_read_cdr;
		
			Do While True
				FETCH cur_read_cdr
				INTO :ldt_stime,:ldt_etime, :ll_biltime, :ls_nodeno,
					  :ls_rtelnum, :ldc_bilamt, :ls_validkey, :ls_seqno, :ldt_crtdt;
				 
				If SQLCA.SQLCode < 0 Then
					clipboard(ls_sql)			
					f_msg_sql_err(is_title, "cur_read_cdr")
					CLOSE cur_read_cdr;
					ii_rc = -1
					return
				ElseIf SQLCA.SQLCode = 100 Then
					Exit
				End If
		
				ll_insrow = idw_data[1].InsertRow(0)
				idw_data[1].Object.SEQNO[ll_insrow] = ls_SEQNO   			
				idw_data[1].Object.stime[ll_insrow] = ldt_stime
				idw_data[1].Object.etime[ll_insrow] = ldt_etime
				idw_data[1].Object.biltime[ll_insrow] = ll_biltime
				idw_data[1].Object.sTELNUM[ll_insrow] = ls_nodeno
				idw_data[1].Object.RTELNUM[ll_insrow] = ls_RTELNUM
				idw_data[1].Object.bilamt[ll_insrow] = ldc_bilamt
				idw_data[1].Object.validkey[ll_insrow] = ls_validkey
				idw_data[1].Object.crtdt[ll_insrow] = ldt_crtdt
		//		idw_data[1].SetItemStatus(ll_insrow, 0, Primary!, NotModified!)
				ll_rows++
			Loop
			CLOSE cur_read_cdr ;
		Loop
		CLOSE cur_read_cdr_table;
	
		il_data[1] = ll_insrow 		//총 처리한 열의 갯수
		If ll_insrow > 0 Then
			idw_data[1].SetSort("STIME D")
			idw_data[1].Sort()
		End If
		
   Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		    "Matching statement Not found.(" + String(is_caller) + ")")
		Return
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db_02 ();
// "b1w_reg_svc_termorder%save"
String ls_customerid, ls_svccod, ls_priceplan, ls_prmtype
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_pgm_id, ls_requestactive, ls_termstatus, ls_ref_desc
String ls_act_gu , ls_status, ls_enddt, ls_act_yn, ls_payid, ls_customerid_1
Datetime ldt_crtdt
Long ll_cnt, ll_row, ll_cnt1, ll_cur
Dec ldc_orderno
String ls_contractseq
String ls_check_yn, ls_remark

ii_rc = -2

Choose Case is_caller
	Case "b1w_reg_svc_termorder%save"
//		lu_dbmgr2.is_caller = "b1w_reg_svc_termorder%save"
//		lu_dbmgr2.is_title  = Title
//		lu_dbmgr2.idw_data[1] = dw_detail
//		lu_dbmgr2.is_data[1] = ls_contractseq
//		lu_dbmgr2.is_data[2] = is_termstatus[1]			//해지신청상태코드
//		lu_dbmgr2.is_data[3] = ls_termdt
//		lu_dbmgr2.is_data[4] = ls_partner
//		lu_dbmgr2.is_data[5] = ls_termtype
//		lu_dbmgr2.is_data[6] = ls_prm_check
//		lu_dbmgr2.is_data[7] = is_termstatus[2]        //해지상태코드
//      lu_dbmgr2.idt_data[1] = ldt_termdt

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//해지처리확정일때..
		ls_act_gu = String(idw_data[1].object.act_gu[1])
		ls_enddt = String(idw_data[1].object.enddt[1],'yyyymmdd')
		If IsNull(ls_act_gu) Then ls_act_gu = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		
		If ls_act_gu = 'Y' Then
			If ls_enddt = "" Then
				f_msg_usr_err(200, is_title, "과금종료일")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("enddt")
				Return
			End If

			//modify pkh : 2003-09-29 (과금종료일 <= 해지요청일)
			If ls_enddt > is_data[3] Then
				f_msg_usr_err(200, is_title, "과금종료일은 해지요청일 보다 작아야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("enddt")
				Return
			End If				
			
			ls_status = is_data[7]     //해지상태
		Else
			ls_status = is_data[2]	   //해지신청상태
		End If
		
		
		ll_cnt = 0
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])		
		//해지신청내역 존재 여부 check
		Select count(*)
		 Into :ll_cnt
		 From svcorder
		Where to_char(ref_contractseq) = :is_data[1]
		  and status = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT svcorder")
	  	   ii_rc = -1													 			
			RollBack;
			Return 
		End If	
		
		If ll_cnt > 0 Then
			 f_msg_Usr_err(9000, is_caller, "고객 [" + ls_customerid + "] 계약Seq[" + &
			 										is_data[1] + "]로 이미 해지신청이 있습니다.")
		  	 ii_rc = -2													 
			 return
		End If	
		
		//서비스번호가져 오기
		Select seq_orderno.nextval
		Into :ldc_orderno
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT seq_orderno.nextval")				
	  	   ii_rc = -1													 						
			RollBack;
			Return 
		End If	
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])		
		If IsNull(ls_prmtype) Then ls_prmtype = ""								
		//해지처리확정
		ls_act_gu = Trim(idw_data[1].object.act_gu[1])				
		If IsNull(ls_act_gu) Then ls_act_gu = ""										
		
//		//약정유형이 있을 경우 위약금 check procedure call 
//		IF is_data[6] = '1' and ls_prmtype <> "" Then
//			
//			String ls_errmsg
//			Long ll_return, ll_count
//			Double ld_count
//			
//			ll_return = -1
//			ls_errmsg = space(256)
//			
//			//처리부분...
//			//subroutine B1CALCPANALTY(string P_CUSTOMERID,string P_CONTRACTSEQ,string P_TERMDT,string P_ORDERNO,string P_USER,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"B1CALCPANALTY~""			
//			SQLCA.B1CALCPENALTY(ls_customerid,is_data[1],idt_data[1],string(ldc_orderno),gs_user_id,ls_pgm_id,ll_return,ls_errmsg, ld_count)
//			If SQLCA.SQLCode < 0 Then		//For Programer
//				MessageBox(is_Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
//				ii_rc = -1
//				Return
//			ElseIf ll_return < 0 Then	//For User
//				MessageBox(is_Title, ls_errmsg, StopSign!)
//				ii_rc = -2
//				Return
//			End If
//	
////			//Message표시
////			is_msg_process = "Completed Records: " + String(lb_count)
//	
//			If ll_return <> 0 Then	//실패
//				ii_rc = -1
//				Return 
//			Else				//성공
//				ii_rc = 0
//			End If		
//		END If		
		
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""
		If IsNull(ls_remark) Then ls_remark = ""
		
		//Insert
		insert into svcorder
		    ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt, remark )
	   values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, :idt_data[1], :ls_status, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_data[4],
			   :is_data[1], :is_data[5], :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_remark);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Err(SVCORDER)")				
			ii_rc = -1
			Return 
		End If	
		
		
 		//해지처리루틴
		If ls_act_gu = 'Y' Then 
		
				ls_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
				ls_termstatus = fs_get_control("B0", "P201", ls_ref_desc)
		
				//해지 할 수 있는지 권한 여부 
				Select act_yn
				Into :ls_act_yn
				From partnermst
				Where partner = :gs_user_group;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
					ii_rc = -1
					Return  
				End If
				
				If ls_act_yn = "N" Then
					f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
					Return
				End If
				
				ls_payid = Trim(idw_data[1].object.customerm_payid[1])
				
			  //서비스 개통 상태 갯수 확인	 
			  Select count(*) 
			  Into :ll_cnt
			  From contractmst 
			  Where customerid = :ls_customerid and status <> :is_data[7];
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
				  ii_rc = -1
				  Return
			  End If
			  
			 //마시막 서비스 해지 하려 하면 
			 //가입자로 들어있는 고객 확인
			 If ll_cnt = 1 Then	
				//납입 고객일 경우 
				If ls_customerid = ls_payid  Then
					Select cus.customerid
					Into :ls_customerid_1
					From customerm cus, contractmst cnt
					Where cus.customerid = cnt.customerid And
							cus.payid = :ls_payid and cnt.customerid <> :ls_customerid and
							cnt.status <> :is_data[7] and rownum = 1;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " SELECT Error(CUSTOMERM)")
						ii_rc = -1
						Return  
					End If
					
					If IsNull(ls_customerid_1) Then ls_customerid_1  = ""
					If ls_customerid_1 <> "" Then
						
						
						f_msg_usr_err(9000, is_title , "납입고객 : " + ls_payid + " 에 " + &
																 "포함되는 ~r가입고객 : " + ls_customerid_1 + "이 존재합니다. ~r" + &
																 "먼저 가입고객의 서비스를 해지하십시오.")
						Return
					End If
				End If	
			End If	
				
				//해지처리.
				//contractmst Update
				Update contractmst 
				Set  status = :ls_status,
					 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
					 termtype = :is_data[5],
					 bil_todt = to_date(:ls_enddt, 'yyyy-mm-dd'),
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id
			    Where to_char(contractseq) = :is_data[1];
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
					Rollback;
					ii_rc = -1
					Return  
				End If
				
				//인증 정보 Update
			   Update validinfo
				Set todt = nvl(todt, to_date(:is_data[3], 'yyyy-mm-dd')),
				status = :ls_status,
				use_yn = 'N',
				updt_user = :gs_user_id,
				updtdt = sysdate,
				pgm_id = :ls_pgm_id
				Where to_char(contractseq) = :is_data[1];
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If
			  
			   //서비스 개통 상태 갯수 확인	 
			  Select count(*) 
			  Into :ll_cnt
			  From contractmst 
			  Where customerid = :ls_customerid and status <> :ls_status;
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
				  ii_rc = -1
				  Return  
			  End If
			  
			  //현 신청 상태 확인
			  Select count(*)
			  Into :ll_cnt1
			  From svcorder
			  Where customerid = :ls_customerid and status = :ls_requestactive;
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
				  ii_rc = -1
				  Return  
			  End If
			  
			 //고객 해지 처리
			 If ll_cnt = 0 and ll_cnt1	= 0 Then
					
					Update customerm
					Set status = :ls_termstatus,
						termtype = :is_data[5],
    					termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
						updt_user = :gs_user_id,
						updtdt = sysdate,
						pgm_id = :ls_pgm_id
					Where customerid = :ls_customerid;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMERM)")
						Rollback;
						ii_rc = -1
						Return  
					End If
			End If	
		End If

	Case "b1w_reg_svc_termorder_1%save"
//		lu_dbmgr2.is_caller = "b1w_reg_svc_termorder_1%save"
//		lu_dbmgr2.is_title  = Title
//		lu_dbmgr2.idw_data[1] = dw_detail
//		lu_dbmgr2.is_data[1] = ls_contractseq
//		lu_dbmgr2.is_data[2] = is_termstatus[1]			//해지신청상태코드
//		lu_dbmgr2.is_data[3] = ls_termdt
//		lu_dbmgr2.is_data[4] = ls_partner
//		lu_dbmgr2.is_data[5] = ls_termtype
//		lu_dbmgr2.is_data[6] = ls_prm_check
//		lu_dbmgr2.is_data[7] = is_termstatus[2]        //해지상태코드
//      lu_dbmgr2.idt_data[1] = ldt_termdt

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//해지처리확정일때..
		ls_act_gu = String(idw_data[1].object.act_gu[1])
		ls_enddt = String(idw_data[1].object.enddt[1],'yyyymmdd')
		If IsNull(ls_act_gu) Then ls_act_gu = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		
		If ls_act_gu = 'Y' Then
			If ls_enddt = "" Then
				f_msg_usr_err(200, is_title, "과금종료일")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("enddt")
				Return
			End If
			
			//modify pkh : 2003-09-29 (과금종료일 <= 해지요청일)
			If ls_enddt > is_data[3] Then
				f_msg_usr_err(200, is_title, "과금종료일은 해지요청일 보다 작아야 합니다.")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("enddt")
				Return
			End If				
			
			ls_status = is_data[7]     //해지상태
		Else
			ls_status = is_data[2]	   //해지신청상태
		End If
		
		
		ll_cnt = 0
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])		
		//해지신청내역 존재 여부 check
		Select count(*)
		 Into :ll_cnt
		 From svcorder
		Where to_char(ref_contractseq) = :is_data[1]
		  and status = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_caller, "SELECT svcorder")
	  	   ii_rc = -1													 			
			RollBack;
			Return 
		End If	
		
		If ll_cnt > 0 Then
			 f_msg_Usr_err(9000, is_caller, "고객 [" + ls_customerid + "] 계약Seq[" + &
			 										is_data[1] + "]로 이미 해지신청이 있습니다.")
		  	 ii_rc = -2													 
			 return
		End If	
		
		//서비스번호가져 오기
		Select seq_orderno.nextval
		Into :ldc_orderno
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT seq_orderno.nextval")				
	  	   ii_rc = -1													 						
			RollBack;
			Return 
		End If	
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])		
		If IsNull(ls_prmtype) Then ls_prmtype = ""								
		//해지처리확정
		ls_act_gu = Trim(idw_data[1].object.act_gu[1])				
		If IsNull(ls_act_gu) Then ls_act_gu = ""										
		
		//약정유형이 있을 경우 위약금 check procedure call 
		IF is_data[6] = '1' and ls_prmtype <> "" Then
			
			String ls_errmsg
			Long ll_return, ll_count
			Double ld_count
			
			ll_return = -1
			ls_errmsg = space(256)
			
			//처리부분...
			//subroutine B1CALCPANALTY(string P_CUSTOMERID,string P_CONTRACTSEQ,string P_TERMDT,string P_ORDERNO,string P_USER,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"B1CALCPANALTY~""			
			SQLCA.B1CALCPENALTY(ls_customerid,is_data[1],idt_data[1],string(ldc_orderno),gs_user_id,ls_pgm_id,ll_return,ls_errmsg, ld_count)
			If SQLCA.SQLCode < 0 Then		//For Programer
				MessageBox(is_Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
				ii_rc = -1
				Return
			ElseIf ll_return < 0 Then	//For User
				MessageBox(is_Title, ls_errmsg, StopSign!)
				ii_rc = -2
				Return
			End If
	
//			//Message표시
//			is_msg_process = "Completed Records: " + String(lb_count)
	
			If ll_return <> 0 Then	//실패
				ii_rc = -1
				Return 
			Else				//성공
				ii_rc = 0
			End If		
		END If		
		
		ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""		
		If IsNull(ls_remark) Then ls_remark = ""
		
		//Insert
		insert into svcorder
		    ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt, remark )
	   values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, :idt_data[1], :ls_status, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_data[4],
			   :is_data[1], :is_data[5], :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_remark);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Err(SVCORDER)")				
			ii_rc = -1
			Return 
		End If	
		
		
 		//해지처리루틴
		If ls_act_gu = 'Y' Then 
		
				ls_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
				ls_termstatus = fs_get_control("B0", "P201", ls_ref_desc)
		
				//해지 할 수 있는지 권한 여부 
				Select act_yn
				Into :ls_act_yn
				From partnermst
				Where partner = :gs_user_group;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
					ii_rc = -1
					Return  
				End If
				
				If ls_act_yn = "N" Then
					f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
					Return
				End If
				
				ls_payid = Trim(idw_data[1].object.customerm_payid[1])
				
			  //서비스 개통 상태 갯수 확인	 
			  Select count(*) 
			  Into :ll_cnt
			  From contractmst 
			  Where customerid = :ls_customerid and status <> :is_data[7];
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
				  ii_rc = -1
				  Return
			  End If
			  
			 //마시막 서비스 해지 하려 하면 
			 //가입자로 들어있는 고객 확인
			 If ll_cnt = 1 Then	
				//납입 고객일 경우 
				If ls_customerid = ls_payid  Then
					Select cus.customerid
					Into :ls_customerid_1
					From customerm cus, contractmst cnt
					Where cus.customerid = cnt.customerid And
							cus.payid = :ls_payid and cnt.customerid <> :ls_customerid and
							cnt.status <> :is_data[7] and rownum = 1;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " SELECT Error(CUSTOMERM)")
						ii_rc = -1
						Return  
					End If
					
					If IsNull(ls_customerid_1) Then ls_customerid_1  = ""
					If ls_customerid_1 <> "" Then
						
						
						f_msg_usr_err(9000, is_title , "납입고객 : " + ls_payid + " 에 " + &
																 "포함되는 ~r가입고객 : " + ls_customerid_1 + "이 존재합니다. ~r" + &
																 "먼저 가입고객의 서비스를 해지하십시오.")
						Return
					End If
				End If	
			End If	
				
				//해지처리.
				//contractmst Update
				Update contractmst 
				Set  status = :ls_status,
					 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
					 termtype = :is_data[5],
					 bil_todt = to_date(:ls_enddt, 'yyyy-mm-dd'),
					 updt_user = :gs_user_id,
					 updtdt = sysdate,
					 pgm_id = :ls_pgm_id
			    Where to_char(contractseq) = :is_data[1];
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
					Rollback;
					ii_rc = -1
					Return  
				End If
				
				//인증 정보 Update
			   Update validinfo
				Set todt = nvl(todt, to_date(:is_data[3], 'yyyy-mm-dd')),
				status = :ls_status,
				use_yn = 'N',
				updt_user = :gs_user_id,
				updtdt = sysdate,
				pgm_id = :ls_pgm_id
				Where to_char(contractseq) = :is_data[1];
			  
			  If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
					Rollback;
					ii_rc = -1
					Return  
			  End If
			  
			   //서비스 개통 상태 갯수 확인	 
			  Select count(*) 
			  Into :ll_cnt
			  From contractmst 
			  Where customerid = :ls_customerid and status <> :ls_status;
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
				  ii_rc = -1
				  Return  
			  End If
			  
			  //현 신청 상태 확인
			  Select count(*)
			  Into :ll_cnt1
			  From svcorder
			  Where customerid = :ls_customerid and status = :ls_requestactive;
			  
			  If SQLCA.SQLCode < 0 Then
				  f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
				  ii_rc = -1
				  Return  
			  End If
			  
			 //고객 해지 처리
			 If ll_cnt = 0 and ll_cnt1	= 0 Then
					
					Update customerm
					Set status = :ls_termstatus,
						termtype = :is_data[5],
						 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
						updt_user = :gs_user_id,
						updtdt = sysdate,
						pgm_id = :ls_pgm_id
					Where customerid = :ls_customerid;
					
					If SQLCA.SQLCode < 0 Then
						f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMERM)")
						Rollback;
						ii_rc = -1
						Return  
					End If
			End If	
		End If
		
	Case "b1w_reg_svc_termorder_batch%save"
//		lu_dbmgr2.is_caller = "b1w_reg_svc_termorder_1%save"
//		lu_dbmgr2.is_title  = Title
//		lu_dbmgr2.idw_data[1] = dw_detail
//		lu_dbmgr2.idw_data[2] = dw_ext
//		lu_dbmgr2.is_data[1] = ls_act_gu
//		lu_dbmgr2.is_data[2] = is_termstatus[1]
//		lu_dbmgr2.is_data[3] = ls_termdt
//		lu_dbmgr2.is_data[4] = ls_partner
//		lu_dbmgr2.is_data[5] = ls_termtype
//		lu_dbmgr2.is_data[6] = ls_prm_check
//		lu_dbmgr2.is_data[7] = is_termstatus[2]        //해지상태코드
//		lu_dbmgr2.is_data[8] = ls_enddt
//      lu_dbmgr2.idt_data[1] = ldt_termdt

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//해지처리확정일때..
		ls_act_gu = is_data[1]
		ls_enddt = is_data[8]
		If IsNull(ls_act_gu) Then ls_act_gu = ""
		If IsNull(ls_enddt) Then ls_enddt = ""
		
		If ls_act_gu = 'Y' Then
			If ls_enddt = "" Then
				f_msg_usr_err(200, is_title, "과금종료일")
				idw_data[2].SetFocus()
				idw_data[2].SetColumn("enddt")
				Return
			End If
			
			ls_status = is_data[7]     //해지상태
		Else
			ls_status = is_data[2]	   //해지신청상태
		End If
		
		
		FOR ll_cur=1 TO ll_row
		
			ll_cnt = 0
			ls_check_yn = Trim(idw_data[1].object.check_yn[ll_cur])
			ls_customerid = Trim(idw_data[1].object.contractmst_customerid[ll_cur])
			ls_contractseq = String(idw_data[1].object.contractmst_contractseq[ll_cur])
			
			//체크된 계약만 해지
			IF ls_check_yn = "Y" THEN
			
				//해지신청내역 존재 여부 check
				Select count(*)
				 Into :ll_cnt
				 From svcorder
				Where to_char(ref_contractseq) = :ls_contractseq
				  and status = :is_data[2];
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_caller, "SELECT svcorder")
					ii_rc = -1													 			
					RollBack;
					Return 
				End If	
				
				If ll_cnt > 0 Then
					 f_msg_Usr_err(9000, is_caller, "고객 [" + ls_customerid + "] 계약Seq[" + &
															ls_contractseq + "]로 이미 해지신청이 있습니다.")
					 ii_rc = -2													 
					 return
				End If	
				
				//서비스번호가져 오기
				Select seq_orderno.nextval
				Into :ldc_orderno
				From dual;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + " SELECT seq_orderno.nextval")				
					ii_rc = -1													 						
					RollBack;
					Return 
				End If	
				
				ldt_crtdt = fdt_get_dbserver_now()
				ls_pgm_id = gs_pgm_id[gi_open_win_no]
				//ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])		
				//If IsNull(ls_prmtype) Then ls_prmtype = ""										
				
		//		//약정유형이 있을 경우 위약금 check procedure call 
		//		IF is_data[6] = '1' and ls_prmtype <> "" Then
		//			
		//			String ls_errmsg
		//			Long ll_return, ll_count
		//			Double ld_count
		//			
		//			ll_return = -1
		//			ls_errmsg = space(256)
		//			
		//			//처리부분...
		//			//subroutine B1CALCPANALTY(string P_CUSTOMERID,string P_CONTRACTSEQ,string P_TERMDT,string P_ORDERNO,string P_USER,string P_PGMID,ref long P_RETURN,ref string P_ERR_MSG,ref double P_PRCCOUNT) RPCFUNC ALIAS FOR "~"TNCBIL~".~"B1CALCPANALTY~""			
		//			SQLCA.B1CALCPENALTY(ls_customerid,is_data[1],idt_data[1],string(ldc_orderno),gs_user_id,ls_pgm_id,ll_return,ls_errmsg, ld_count)
		//			If SQLCA.SQLCode < 0 Then		//For Programer
		//				MessageBox(is_Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
		//				ii_rc = -1
		//				Return
		//			ElseIf ll_return < 0 Then	//For User
		//				MessageBox(is_Title, ls_errmsg, StopSign!)
		//				ii_rc = -2
		//				Return
		//			End If
		//	
		////			//Message표시
		////			is_msg_process = "Completed Records: " + String(lb_count)
		//	
		//			If ll_return <> 0 Then	//실패
		//				ii_rc = -1
		//				Return 
		//			Else				//성공
		//				ii_rc = 0
		//			End If		
		//		END If		
				
				ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
				ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
				ls_remark = Trim(idw_data[2].object.remark[1])
	//			ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
	//			ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
	//			ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
	//			ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
				If IsNull(ls_customerid) Then ls_customerid = ""				
				If IsNull(ls_svccod) Then ls_svccod = ""						
				If IsNull(ls_priceplan) Then ls_priceplan = ""
				If IsNull(ls_remark) Then ls_remark = ""
	//			If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
	//			If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
	//			If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
	//			If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
				
				//Insert
	//			insert into svcorder
	//				 ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
	//					prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
	//					ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt )
	//			values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, :idt_data[1], :ls_status, :ls_svccod, :ls_priceplan,
	//					:ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_data[4],
	//					:is_data[1], :is_data[5], :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt);
	//
				insert into svcorder
					 ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
						partner, remark,
						ref_contractseq, termtype,	crt_user, crtdt, pgm_id, updt_user, updtdt )
				values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, :idt_data[1], :ls_status, :ls_svccod, :ls_priceplan,
						:is_data[4], :ls_remark,
						:ls_contractseq, :is_data[5], :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt);
		
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					f_msg_sql_err(is_title, is_caller + " Insert Err(SVCORDER)")				
					ii_rc = -1
					Return 
				End If	
				
				
				////해지처리루틴
				If ls_act_gu = 'Y' Then 
				
						ls_requestactive = fs_get_control("B0", "P220", ls_ref_desc)
						ls_termstatus = fs_get_control("B0", "P201", ls_ref_desc)
				
						//해지 할 수 있는지 권한 여부 
						Select act_yn
						Into :ls_act_yn
						From partnermst
						Where partner = :gs_user_group;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " SELECT Error(PARTNERMST)")
							ii_rc = -1
							Return  
						End If
						
						If ls_act_yn = "N" Then
							f_msg_usr_err(9000, is_title, "해지처리 할 수 없는 수행처입니다.")
							Return
						End If
						
						ls_payid = Trim(idw_data[1].object.customerm_payid[ll_cur])
						
					  //서비스 개통 상태 갯수 확인	 
					  Select count(*) 
					  Into :ll_cnt
					  From contractmst 
					  Where customerid = :ls_customerid and status <> :is_data[7];
					  
					  If SQLCA.SQLCode < 0 Then
						  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
						  ii_rc = -1
						  Return
					  End If
					  
					 //마시막 서비스 해지 하려 하면 
					 //가입자로 들어있는 고객 확인
					 If ll_cnt = 1 Then	
						//납입 고객일 경우 
						If ls_customerid = ls_payid  Then
							Select cus.customerid
							Into :ls_customerid_1
							From customerm cus, contractmst cnt
							Where cus.customerid = cnt.customerid And
									cus.payid = :ls_payid and cnt.customerid <> :ls_customerid and
									cnt.status <> :is_data[7] and rownum = 1;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " SELECT Error(CUSTOMERM)")
								ii_rc = -1
								Return  
							End If
							
							If IsNull(ls_customerid_1) Then ls_customerid_1  = ""
							If ls_customerid_1 <> "" Then
								
								
								f_msg_usr_err(9000, is_title , "납입고객 : " + ls_payid + " 에 " + &
																		 "포함되는 ~r가입고객 : " + ls_customerid_1 + "이 존재합니다. ~r" + &
																		 "먼저 가입고객의 서비스를 해지하십시오.")
								Return
							End If
						End If	
					End If	
						
						//해지처리.
						//contractmst Update
						Update contractmst 
						Set  status = :ls_status,
							 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
							 termtype = :is_data[5],
							 bil_todt = to_date(:ls_enddt, 'yyyy-mm-dd'),
							 updt_user = :gs_user_id,
							 updtdt = sysdate,
							 pgm_id = :ls_pgm_id
						 Where to_char(contractseq) = :ls_contractseq;
						
						If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(CONTRACTMST)")
							Rollback;
							ii_rc = -1
							Return  
						End If
						
						//인증 정보 Update
						Update validinfo
						Set todt = nvl(todt, to_date(:is_data[3], 'yyyy-mm-dd')),
						status = :ls_status,
						use_yn = 'N',
						updt_user = :gs_user_id,
						updtdt = sysdate,
						pgm_id = :ls_pgm_id
						Where to_char(contractseq) = :ls_contractseq;
					  
					  If SQLCA.SQLCode < 0 Then
							f_msg_sql_err(is_title, is_caller + " Update Error(VALIDINFO)")
							Rollback;
							ii_rc = -1
							Return  
					  End If
					  
						//서비스 개통 상태 갯수 확인	 
					  Select count(*) 
					  Into :ll_cnt
					  From contractmst 
					  Where customerid = :ls_customerid and status <> :ls_status;
					  
					  If SQLCA.SQLCode < 0 Then
						  f_msg_sql_err(is_title, is_caller + " SELECT Error(CONTRACTMST)")
						  ii_rc = -1
						  Return  
					  End If
					  
					  //현 신청 상태 확인
					  Select count(*)
					  Into :ll_cnt1
					  From svcorder
					  Where customerid = :ls_customerid and status = :ls_requestactive;
					  
					  If SQLCA.SQLCode < 0 Then
						  f_msg_sql_err(is_title, is_caller + " SELECT Error(SVCORDER)")
						  ii_rc = -1
						  Return  
					  End If
					  
					 //고객 해지 처리
					 If ll_cnt = 0 and ll_cnt1	= 0 Then
							
							Update customerm
							Set status = :ls_termstatus,
								termtype = :is_data[5],
								 termdt = to_date(:is_data[3], 'yyyy-mm-dd'),
								updt_user = :gs_user_id,
								updtdt = sysdate,
								pgm_id = :ls_pgm_id
							Where customerid = :ls_customerid;
							
							If SQLCA.SQLCode < 0 Then
								f_msg_sql_err(is_title, is_caller + " Update Error(CUSTOMERM)")
								Rollback;
								ii_rc = -1
								Return  
							End If
					End If	
				End If
			END IF
		Next
			
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0


end subroutine

public subroutine uf_prc_db_04 ();//공통
String ls_module, ls_ref_no, ls_ref_desc, ls_temp, ls_desc[], ls_result[]
Long ll_rows, ll_row

// "b1w_reg_svcactprc%save"
String ls_next, ls_customerid, ls_activedt, ls_status, ls_svccod, ls_priceplan, ls_prmtype, ls_cus_status
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_requestdt , ls_partner
String ls_validkey, ls_todt_tmp, ls_reg_prefixno, ls_remark
String ls_bil_fromdt, ls_termtype, ls_contractno, ls_orderdt, ls_orderno, ls_pgm_id, ls_user_id, ls_term_status, ls_enter_status
String ls_pricemodel, ls_refilltype[], ls_svctype
Datetime ldt_crtdt
Decimal{0} ldc_contractseq, ldc_orderno
Decimal{2} ldc_first_refill_amt, ldc_first_sale_amt

Long ll_cnt

ii_rc = -2

Choose Case is_caller
	Case "b1w_reg_svc_actprc_pre%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_pre%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//충전type
		ls_ref_desc = ""
		ls_temp = fs_get_control("B1","B600", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_refilltype[])

		//contractseq 가져 오기
		Select seq_contractseq.nextval
		Into :ldc_contractseq
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		idw_data[1].object.contractseq[1] = string(ldc_contractseq)
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt = STring(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt = STring(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark = Trim(idw_data[1].object.remark[1])

		ls_pricemodel = Trim(idw_data[1].object.svcorder_pricemodel[1])
		ldc_first_refill_amt  = idw_data[1].object.svcorder_first_refill_amt[1]
		ldc_first_sale_amt = idw_data[1].object.svcorder_first_sale_amt[1]
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_cus_status) Then ls_cus_status = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""						
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_requestdt) Then ls_requestdt = ""						
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		If IsNull(ls_contractno) Then ls_contractno = ""
		
		If IsNull(ls_pricemodel) Then ls_pricemodel = ""
		If IsNull(ldc_first_refill_amt) Then ldc_first_refill_amt = 0
		If IsNull(ldc_first_sale_amt) Then ldc_first_sale_amt = 0
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
			   crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno,
			   pricemodel, refillsum_amt, salesum_amt, balance, 
			   first_refill_amt, first_sale_amt, last_refill_amt, last_refilldt)
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno,
			   :ls_pricemodel, :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt,
			   :ldc_first_refill_amt, :ldc_first_sale_amt, :ldc_first_refill_amt, to_date(:ls_activedt,'yyyy-mm-dd'));

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			Return 
		End If	
			
		//Insert refilllog
		insert into refilllog
			(  refillseq, contractseq, customerid, refilldt, 
			   refill_type, refill_amt, sale_amt,
			   remark, partner_prefix, crtdt, crt_user)
		values ( seq_refilllogseq.nextval, :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), 
			   :ls_refilltype[1], :ldc_first_refill_amt, :ldc_first_sale_amt,
			   '최초충전', :ls_reg_prefixno, sysdate, :gs_user_id);
			   
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(refilllog)")
			Return 
		End If	

			
		// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
		//해지상태
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		//가입상태
		ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)

		If ls_cus_status = ls_term_status Then
			
			Update customerm
			Set status = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt = :ldt_crtdt
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]

		Update svcorder
		Set status = :ls_status,
		    ref_contractseq = :ldc_contractseq,
			remark = :ls_remark,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
				
		Update contractdet
		Set contractseq = :ldc_contractseq
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
			Return 
		End If

		Update quota_info
		Set contractseq = :ldc_contractseq,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If

		//Valid Key Update
		String ls_itemcod
		String ls_reqactive //개통 신청 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		

		DECLARE cur_validkey_check CURSOR FOR
		Select validkey, to_char(fromdt,'yyyymmdd'), svctype
 		  From validinfo
		Where orderno = :ldc_orderno;
		  
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
			Return 
		End If

		OPEN cur_validkey_check;
		Do While(True)
			FETCH cur_validkey_check
			Into :ls_validkey, :ls_todt_tmp, :ls_svctype;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ll_cnt = 0
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					  ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
						:ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey
			   and  to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and  svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
				Return 
			End If
			
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check;
		
		Update validinfo
		Set  fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			 use_yn = 'Y',												//사용여부
			 status = :ls_status,
			 contractseq = :ldc_contractseq,
			 svccod = :ls_svccod,
       		 priceplan = :ls_priceplan,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;			 
//		Where customerid = :ls_customerid and status = :ls_reqactive and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If
			 
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")

	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db_04()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
		
End Choose

ii_rc = 0


end subroutine

public subroutine uf_prc_db_05 ();// "b1w_reg_act_confirm%save"
String ls_next, ls_customerid, ls_activedt, ls_status, ls_svccod, ls_priceplan, ls_prmtype, ls_cus_status
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_requestdt , ls_partner
String ls_bil_fromdt, ls_termtype, ls_contractno, ls_orderdt, ls_orderno, ls_pgm_id, ls_user_id, ls_term_status, ls_enter_status
String ls_dlvstat,  ls_ref_desc, ls_remark, ls_reg_prefixno, ls_levelcod, ls_daricod, ls_boncod, ls_bonsacod, ls_action
String ls_svc, ls_temp, ls_temp1, ls_validkey, ls_todt_tmp, ls_bitype, ls_sql, ls_result[], ls_status1, ls_svctype
Datetime ldt_crtdt
Long ll_row, ll_cnt
Dec ldc_contractseq, ldc_orderno
Int li_i, li_cnt, li_tmp, li_pos, i
// "b1w_reg_svc_actcancel%save"
String ls_termdt, ls_sql_1, ls_sql_2

// "b1w_reg_svc_actprc_mvno%save"
String ls_banno, ls_vpricecod, ls_acttype
Integer li_insmonths, li_qtamonth


//Com-N-Life 김은미
Choose Case is_caller
	Case "b1w_reg_act_confirm_cl%save"      //구매확인
//		lu_dbmgr.is_caller = "b1w_reg_act_confirm_cl%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = tab_1.idw_tabpage[1]
//		lu_dbmgr2.is_data[1] = ls_actflag
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음

      idw_data[1].AcceptText()
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]
		
		//is_data[1] = '1'(확인완료), '2'(확인실패), '3'(구매재확인)에 따라 처리가 다르다.
		IF is_data[1] = '1' Then

			//구매확인코드
			ls_status = ""		
			ls_status = fs_get_control("B0","P229", ls_ref_desc)
			ls_remark = Trim(idw_data[1].object.svcorder_remark[1])			
			
			Update svcorder
			Set status = :ls_status,
				 remark = :ls_remark,
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :gs_pgm_id[gi_open_win_no]
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
				Return 
			End If
					
			Commit;

		ElseIF is_data[1] = '3' Then

			//구매재확인
			ls_status = ""		
			ls_status = fs_get_control("B0","P228", ls_ref_desc)
			ls_remark = Trim(idw_data[1].object.svcorder_remark[1])
			
			Update svcorder
			Set status = :ls_status,
				 remark = :ls_remark,
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :gs_pgm_id[gi_open_win_no]
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
				Return 
			End If
					
			Commit;
			
		Elseif is_data[1] = '2' Then
			
			//개통취소상태코드			
			ls_ref_desc = ""
			ls_status = ""
			ls_status = fs_get_control("B0","P231", ls_ref_desc)
			ls_remark = Trim(idw_data[1].object.svcorder_remark[1])
			ldt_crtdt = fdt_get_dbserver_now()
			ls_pgm_id = gs_pgm_id[gi_open_win_no]
			ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
			ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])			
			
			Update svcorder
			Set status = :ls_status,
				 remark = :ls_remark,
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :gs_pgm_id[gi_open_win_no]
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
				Return 
			End If
			
			Delete from partner_ardtl
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Delete partner_ardtl Table")				
				Return 
			End If
			
			//대리점재고 상태코드
			ls_daricod = fs_get_control("E1","A102", ls_ref_desc)
			//본사재고 상태코드
			ls_boncod = fs_get_control("E1","A100", ls_ref_desc)
			//본사대리점코드 
			ls_bonsacod = fs_get_control("A1","C102", ls_ref_desc)
			
			Update admst
			Set status = decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
				 saledt = null,
				 customerid = null,
				 sale_amt = null,
				 sale_flag = '0',
				 dlvstat = null,
				 updt_user = :gs_user_id,
				 updtdt = sysdate,
				 pgm_id = :gs_pgm_id[gi_open_win_no]
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update ADMST Table")				
				Return 
			End If
			
			//판매취소코드 
			ls_action = fs_get_control("E1","A302", ls_ref_desc)

			//Insert
			insert into admstlog
				 ( adseq, seq, action, status, actdt, customerid, fr_partner, remark,
 					crt_user, crtdt, pgm_id )
			select adseq,
 	             seq_admstlog.nextval,
					 :ls_action,
					 decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
 					 sysdate,
					 :ls_customerid,
					 mv_partner,
					 '구매확인Call로 신청취소처리',
					 :gs_user_id, 
					 :ldt_crtdt,
					 :ls_pgm_id
   		  from admst where orderno = :ldc_orderno;
	
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(admstlog)")
				Return 
			End If	
			
			//개통상태코드			
			ls_ref_desc = ""
			ls_status = fs_get_control("B0","P223", ls_ref_desc)
			
			ll_cnt = 0
			select count(*) 
			  into :ll_cnt
			  from contractmst
   		 where customerid = :ls_customerid
			   and status = :ls_status;

			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " select count contractmst")
				Return 
			End If	

			If ll_cnt = 0 then
				
				//고객상태(개통실패)
				ls_cus_status = fs_get_control("B0","P203", ls_ref_desc)
				
				Update customerm
				Set status = :ls_cus_status,
					 updt_user = :gs_user_id,
					 updtdt = :ldt_crtdt,
					 pgm_id = :ls_pgm_id
				Where customerid = :ls_customerid;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;		
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update customerm Table")				
					Return 
				End If
			End if
				
			Commit;
			
		End if
		
	Case "b1w_reg_act_confirm_cl%ok"
//			lu_dbmgr2.is_caller = "b1w_reg_act_confirm_cl%ok"
//			lu_dbmgr2.is_title  = Title
//			lu_dbmgr2.is_data[1] = is_beforeopen
//			lu_dbmgr2.is_data[2] = is_openning
//			lu_dbmgr2.is_data[7] = ls_status   //구분
//			//lu_dbmgr2.is_data[3] = is_svcorder
//			//lu_dbmgr2.is_data[4] = is_customerid
//			//lu_dbmgr2.is_data[5] = is_payerid
//			//lu_dbmgr2.is_data[6] = is_svccod
//			lu_dbmgr2.ib_data[1] = ib_ok

	 	//1차확인
		IF is_data[7] = '1' Then
			
			// 구매확인Call 서비스코드 찾아오기
			ls_temp = fs_get_control("B0","P300", ls_ref_desc)
			If ls_temp = "" Then Return 
			
			li_pos  = PosA(ls_temp, ";")
			i = 1
			Do While li_pos > 0 Or i <> -1
				If li_pos = 0 Then
					If i = 1 Then
						ls_temp1 = ls_temp

					ElseIf i > 0 Then
						ls_temp1 = MidA(ls_temp, i)
						i = -1
					End If
						
				Else
					ls_temp1 = MidA(ls_temp, i, (li_pos - i))
					i = 1 + li_pos
				End If

				//1.Cursor
				DECLARE svcorder_c_1	CURSOR FOR
					  SELECT to_char(orderno)
						 FROM svcorder
						WHERE status = :is_data[1]
						  AND svccod = :ls_temp1
					 ORDER BY order_priority, requestdt, orderno;
				OPEN svcorder_c_1;
				FETCH svcorder_c_1 INTO :ls_orderno;
			
				//error
				If SQLCA.SQLCODE < 0 Then
					f_msg_sql_err(is_title ,"Cursor Fetch Error")
					Close svcorder_c_1;
					ii_rc = -1
					Return
				ElseIf SQLCA.SQLCODE = 100 Then
					is_data[3] = ""
					is_data[4] = ""
					is_data[5] = ""
					is_data[6] = ""
					Close svcorder_c_1;
					exit
				Else
					ll_cnt++
					exit
	
				End If
				
				If i = -1 Then
					exit
				End If
				li_pos  = PosA(ls_temp, ";", li_pos+LenA("','"))
				
			Loop
			
			Close svcorder_c_1;
			If ll_cnt <= 0 Then
				MessageBox(is_Title, "구매 1차확인대상 정보가 없습니다.")
				ii_rc = -1
				return
			End If
				

		//2차확인
		ELSE
			//1.Cursor
			DECLARE svcorder_c_2	CURSOR FOR
					  SELECT to_char(orderno)
						 FROM svcorder
						WHERE status = :is_data[1]
					 //ORDER BY to_char(updtdt,'yyyymmdd hh:mm:ss'), requestdt, orderno;
					 ORDER BY updtdt, requestdt, orderno;
			OPEN svcorder_c_2;
			FETCH svcorder_c_2 INTO :ls_orderno;
			
			//error
			If SQLCA.SQLCODE < 0 Then
				f_msg_sql_err(is_title ,"")
				Close svcorder_c_2;
				ii_rc = -1
				Return
			ElseIf SQLCA.SQLCODE = 100 Then
				is_data[3] = ""
				is_data[4] = ""
				is_data[5] = ""
				is_data[6] = ""
				Close svcorder_c_2;	
					MessageBox(is_Title, "구매 재확인대상 정보가 없습니다.")
				ii_rc = -1
				return
			End If
			
			Close svcorder_c_2;
		
		END IF
	

		//2.svcorder update
		UPDATE svcorder
		SET updt_user = :gs_user_id, status = :is_data[2]
		WHERE to_char(orderno) = :ls_orderno ;
		
		IF SQLCA.SqlCode < 0 THEN
			RollBack;
			ii_rc = -1
			return
		Else
			Commit;
			ib_data[1] = TRUE
		END IF
		
		//3.신청내역 Select
		SELECT to_char(odr.orderno), odr.svccod, cust.customerid, cust.payid
		INTO :is_data[3], :is_data[6], :is_data[4], :is_data[5] 
		FROM svcorder odr, customerm cust 
		WHERE odr.customerid = cust.customerid 
		  AND odr.updt_user = :gs_user_id 
		  AND odr.status = :is_data[2]
		  AND to_char(odr.orderno) = :ls_orderno
		ORDER BY order_priority, requestdt, orderno;
		
		IF SQLCA.SqlCode < 0 THEN
			ii_rc = -1
			return
		Else
			ii_rc = 1
		END IF


	Case "b1w_reg_svc_actprc_cl%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc_cl%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//contractseq 가져 오기
		Select seq_contractseq.nextval
		Into :ldc_contractseq
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		idw_data[1].object.contractseq[1] = string(ldc_contractseq)
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		
		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt = String(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt = String(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_cus_status) Then ls_cus_status = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""						
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_requestdt) Then ls_requestdt = ""						
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		If IsNull(ls_contractno) Then ls_contractno = ""
		If IsNull(ls_remark) Then ls_remark = ""
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			Return 
		End If	
			
		// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
		//해지상태
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		//가입상태
		ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)

		If ls_cus_status = ls_term_status Then
			
			Update customerm
			Set status    = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt    = :ldt_crtdt
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]

		Update svcorder
		Set status          = :ls_status,
		    ref_contractseq = :ldc_contractseq,
			 remark          = :ls_remark,
			 updt_user       = :gs_user_id,
			 updtdt          = :ldt_crtdt,
			 pgm_id          = :ls_pgm_id
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
				
		Update contractdet
		Set contractseq = :ldc_contractseq
		Where orderno   = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
			Return 
		End If

		Update quota_info
		Set contractseq = :ldc_contractseq,
			 updt_user   = :gs_user_id,
			 updtdt      = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If
		
		//장비금액을 할부로 안하고 일시불로 처리했을 경우 oncepayment Update
		Update oncepayment
		Set contractseq = :ldc_contractseq,
			 updt_user   = :gs_user_id,
			 updtdt      = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update ONCEPAYMENT Table")				
			Return 
		End If
		
		//배송대기(개통완료)
		ls_dlvstat = fs_get_control("E1", "A410", ls_ref_desc)
		
		Update admst
		Set contractseq = :ldc_contractseq,
		    dlvstat     = :ls_dlvstat
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update ADMST Table")				
			Return 
		End If
		
		//Valid Key Update
		String ls_itemcod
		String ls_reqactive //개통 신청 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		
		DECLARE cur_validkey_check CURSOR FOR
//			Select validkey, to_char(fromdt,'yyyymmdd'), svctype
// 			  From validinfo
//			 Where customerid = :ls_customerid 
//			   and status = :ls_reqactive 
//			   and priceplan = :ls_priceplan;
			   
			Select validkey, to_char(fromdt,'yyyymmdd'), svctype
 			  From validinfo
			 Where orderno = :ldc_orderno;
		  
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
				Return 
			End If

		OPEN cur_validkey_check;
		Do While(True)
			FETCH cur_validkey_check
			Into :ls_validkey, :ls_todt_tmp, :ls_svctype;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ll_cnt = 0
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			  from validinfo
			 where ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					 ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
					 :ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and validkey = :ls_validkey
			   and to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and svctype = :ls_svctype;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
				Return 
			End If
			
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check;
		
		Update validinfo
		Set fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			 use_yn = 'Y',												//사용여부
			 status = :ls_status,
			 contractseq = :ldc_contractseq,
			 svccod = :ls_svccod,
       	     priceplan = :ls_priceplan,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;
//		Where customerid = :ls_customerid and status = :ls_reqactive and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If
		
		//대리점의 여신관리여부가 Y일경우의 처리
 		//총출고금액(tot_samt)에 ADMODEL의 이동기준금액(partner_amt)을 update 한다. 2003.10.31 김은미 수정. (sale_amt)로 변경.
		ls_ref_desc = ""
		ls_levelcod = fs_get_control("A1","C100", ls_ref_desc)
			
		Update partnermst
		Set tot_samt = nvl(tot_samt,0) + nvl((select nvl(a.sale_amt,0)
											             from admodel a, admst b
   													   where a.modelno = b.modelno 
 															  and b.orderno = :ldc_orderno ),0),
			 updt_user = :gs_user_id,
			 updtdt    = sysdate,
			 pgm_id    = :gs_pgm_id[gi_open_win_no]
		Where partner = ( select partner 
    		              from partnermst
								 where levelcod = :ls_levelcod
								   and :ls_reg_prefixno like prefixno||'%'
									and credit_yn = 'Y');

		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update partnermst Table")				
			Return 
		End If		
			 
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")
		
	Case "b1w_reg_svc_actprc_mvno%ok"      // 개통처리(MVNO)를 위한 select
//			lu_dbmgr2.is_caller = "b1w_reg_svc_actprc_cl%ok"
//			lu_dbmgr2.is_title  = Title
//			lu_dbmgr2.is_data[1] = is_beforeopen
//			lu_dbmgr2.is_data[2] = is_openning
//			//lu_dbmgr2.is_data[3] = is_svcorder
//			//lu_dbmgr2.is_data[4] = is_customerid
//			//lu_dbmgr2.is_data[5] = is_payerid
//			//lu_dbmgr2.is_data[6] = is_svccod
//			lu_dbmgr2.ib_data[1] = ib_ok

//			ii_rc- -1:에러, 0:정상, 1:정보없음

		ii_rc = -1
		
		//비과금 후불제 서비스 type
		ls_bitype = fs_get_control("B0", "P103", ls_ref_desc)
		
		//개통신청완료 status
		ls_status1 = fs_get_control("B0", "P220", ls_ref_desc)
		
		// 구매확인Call 서비스코드 찾아오기
		ls_temp = fs_get_control("B0","P300", ls_ref_desc)
		If ls_temp = "" Then Return
		li_cnt = fi_cut_string(ls_temp, ";" , ls_result[])
		
		DECLARE cur_svcorder_cl DYNAMIC CURSOR FOR SQLSA;
		
		ls_sql = " SELECT to_char(a.orderno)      " + &
					"	 FROM svcorder a, svcmst b    " + &
					"	WHERE a.svccod  = b.svccod    "
					
		ls_sql += "	  AND (( a.status  = '" + is_data[1] + "'  "
		
		ls_sql_1 = ""
		For li_tmp = 1 To li_cnt
			If ls_sql_1 = "" Then
				ls_sql_1 += " AND ( "
			Else
				ls_sql_1 += " OR "
			End If
			
			ls_sql_1 += " a.svccod = '" + ls_result[li_tmp] + "' "
		Next
		ls_sql += ls_sql_1 + "))"
		ls_sql += "  Or  " + &
		          "( a.status = '" + ls_status1 + "' "
		
		ls_sql_2 = ""
		For li_tmp = 1 To li_cnt
			If ls_sql_2 = "" Then
				ls_sql_2 += " AND ( "
			Else
				ls_sql_2 += " OR "
			End If
			ls_sql_2 += " a.svccod <> '" + ls_result[li_tmp] + "' "
		Next
		ls_sql += ls_sql_2 + " ) "
		ls_sql += " )) "
						
		ls_sql +="	 AND b.svctype = '" + ls_bitype + "'    " + & 
					" ORDER BY a.updtdt, a.requestdt, a.orderno"

		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC cur_svcorder_cl;
			
		//1.Cursor
		FETCH cur_svcorder_cl INTO :ls_orderno;
		
			Close cur_svcorder_cl;
			//error
			If SQLCA.SQLCODE < 0 Then
				f_msg_sql_err(is_title ,"svcorder Selection Error")	
				ii_rc = -1
				Return
			ElseIf SQLCA.SQLCODE = 100 Then
//				is_data[3] = ""
//				is_data[4] = ""
//				is_data[5] = ""
//				is_data[6] = ""
//				Close svcorder_c;	
//				MessageBox(is_Title, "신규 개통신청 정보가 없습니다.")
//				ii_rc = 0
//				return
			ELSE
				//2.svcorder update
//				messagebox(ls_orderno,is_data[1])
				UPDATE svcorder
				SET updt_user = :gs_user_id, updtdt = sysdate, status = :is_data[2]
				WHERE to_char(orderno) = :ls_orderno;
				
				IF SQLCA.SqlCode < 0 THEN
					RollBack;
					ii_rc = -2
					return
				Else
					Commit;
					ib_data[1] = True
				END IF
			End If
		

		//3.신청내역 Select
		SELECT to_char(odr.orderno), odr.svccod, cust.customerid, cust.payid
		  INTO :is_data[3], :is_data[6], :is_data[4], :is_data[5] 
		  FROM svcorder odr, customerm cust 
		 WHERE odr.customerid = cust.customerid
		   AND odr.updt_user = :gs_user_id 
		   AND odr.status = :is_data[2]
		   AND to_char(odr.orderno) = :ls_orderno
		 ORDER BY odr.updtdt, odr.requestdt, odr.orderno;
		
		
		IF SQLCA.SqlCode < 0 THEN
			ii_rc = -3
			return
		ElseIf SQLCA.SQLCODE = 100 Then
			ii_rc = 1
			return
		//정상처리
		Else
			ii_rc = 0
		END IF
		
Case "b1w_reg_svc_actprc_mvno%save"               //개통처리(MVNO)
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc%save"
//		lu_dbmgr.is_title = Title 
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr2.is_data[1] = ls_phone
//		lu_dbmgr2.is_data[2] = ls_actflag
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
      idw_data[1].AcceptText()		
		//is_data[2] = '1'(개통완료), '2'(개통실패)에 따라 처리가 다르다.
		
		IF is_data[2] = '1' Then
			
			//contractseq 가져 오기
			Select seq_contractseq.nextval
			Into :ldc_contractseq
			From dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
				ii_rc = -1			
				RollBack;
				Return 
			End If	
			
			//개통상태코드			
			ls_ref_desc = ""
			ls_status = fs_get_control("B0","P223", ls_ref_desc)
			//배송대기(개통완료)
			ls_ref_desc = ""
			ls_dlvstat      = fs_get_control("E1","A410", ls_ref_desc)			
			ls_customerid   = Trim(idw_data[1].object.svcorder_customerid[1])
			ls_cus_status   = Trim(idw_data[1].object.customerm_status[1])
			ls_activedt     = string(idw_data[1].object.activedt[1],'yyyymmdd')
			ls_svccod       = Trim(idw_data[1].object.svcorder_svccod[1])
			ls_priceplan    = Trim(idw_data[1].object.svcorder_priceplan[1])
			ls_prmtype      = Trim(idw_data[1].object.svcorder_prmtype[1])
			ls_reg_partner  = Trim(idw_data[1].object.svcorder_reg_partner[1])
			ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
			ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
			ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
			ls_partner      = Trim(idw_data[1].object.svcorder_partner[1])	
			ls_orderdt      = String(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
			ls_requestdt    = String(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
			ls_bil_fromdt   = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
			ls_contractno   = Trim(idw_data[1].object.contract_no[1])
			ls_banno        = Trim(idw_data[1].object.banno[1])
			ls_vpricecod    = Trim(idw_data[1].object.svcorder_vpricecod[1])
		 	ls_acttype      = Trim(idw_data[1].object.svcorder_acttype[1])
			ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
			ls_remark       = Trim(idw_data[1].object.remark[1])
//			//보증보험가입월수
//			li_insmonths = ii_data[1]
			
			If IsNull(ls_status) Then ls_status = ""		
			If IsNull(ls_dlvstat) Then ls_dlvstat = ""					
			If IsNull(ls_customerid) Then ls_customerid = ""				
			If IsNull(ls_cus_status) Then ls_cus_status = ""						
			If IsNull(ls_activedt) Then ls_activedt = ""						
			If IsNull(ls_svccod) Then ls_svccod = ""						
			If IsNull(ls_priceplan) Then ls_priceplan = ""						
			If IsNull(ls_prmtype) Then ls_prmtype = ""						
			If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
			If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
			If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
			If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
			If IsNull(ls_partner) Then ls_partner = ""						
			If IsNull(ls_requestdt) Then ls_requestdt = ""						
			If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
			If IsNull(ls_contractno) Then ls_contractno = ""
			If IsNull(ls_banno) Then ls_banno = ""
			If IsNull(ls_vpricecod) Then ls_vpricecod = ""
			If IsNull(ls_acttype) Then ls_acttype = ""
			If IsNull(ls_reg_prefixno) Then ls_reg_prefixno = ""
			If IsNull(ls_remark) Then ls_remark = ""
			If IsNull(li_insmonths) Then li_insmonths = 0
			
			ldt_crtdt = fdt_get_dbserver_now()
			ls_pgm_id = gs_pgm_id[gi_open_win_no]
			
			//Insert
			insert into contractmst
				 ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
					prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
					orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno, 
					remark, recvcheck, vpricecod, acttype, reg_prefixno, insmonths, banno, crt_user, crtdt, pgm_id, updt_user, updtdt )
			values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
					:ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
					to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
					:ls_remark,	'N', :ls_vpricecod, :ls_acttype, :ls_reg_prefixno, :li_insmonths, :ls_banno, :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt);
	
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
				Return 
			End If	
				
			//가입상태
			ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)
	
			//개통처리하는 고객이 가입상태가 아니면 가입상태로 바꿔준다...
			Update customerm
			Set status    = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt    = :ldt_crtdt,
				 pgm_id    = :ls_pgm_id
			Where customerid = :ls_customerid
			  and status <> :ls_enter_status;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
			ldc_orderno = idw_data[1].object.svcorder_orderno[1]
	
			Update svcorder
			Set status    = :ls_status,
				 ref_contractseq = :ldc_contractseq,
				 remark    = :ls_remark,
				 updt_user = :gs_user_id,
				 updtdt    = sysdate,
				 pgm_id    = :ls_pgm_id
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
				Return 
			End If
					
			Update contractdet
			Set contractseq = :ldc_contractseq
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1	
				f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
				Return 
			End If
	
			//할부정보에따라
			Update quota_info
			Set contractseq = :ldc_contractseq,
				 updt_user   = :gs_user_id,
				 updtdt      = sysdate
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update ONCEPAYMENT or QUOTA_INFO Table")				
				Return 
			End If
			
			//장비금액을 할부로 안하고 일시불로 처리했을 경우 oncepayment Update
			Update oncepayment
			Set contractseq = :ldc_contractseq,
				 updt_user   = :gs_user_id,
				 updtdt      = sysdate
			Where orderno = :ldc_orderno;
		
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update ONCEPAYMENT Table")				
				Return 
			End If
			
			Update admst
			Set contractseq = :ldc_contractseq,
				 pid         = :is_data[1],
				 saledt      = to_date(:ls_activedt,'yyyy-mm-dd'),
				 dlvstat     = :ls_dlvstat,
				 updt_user   = :gs_user_id,
				 updtdt      = :ldt_crtdt,
				 pgm_id      = :ls_pgm_id
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update admst Table")				
				Return 
			End If
			
			
			//대리점의 여신관리여부가 Y일경우의 처리
	 		//총출고금액(tot_samt)에 ADMODEL의 이동기준금액(partner_amt)을 update 한다. 2003.10.31 김은미 수정. (sale_amt)로 변경.
			ls_ref_desc = ""
			ls_levelcod = fs_get_control("A1","C100", ls_ref_desc)
			
			Update partnermst
			Set tot_samt = nvl(tot_samt,0) + nvl((select nvl(a.sale_amt,0)
												             from admodel a, admst b
   														   where a.modelno = b.modelno 
 																  and b.orderno = :ldc_orderno ),0),
				 updt_user = :gs_user_id,
				 updtdt    = sysdate,
				 pgm_id    = :gs_pgm_id[gi_open_win_no]
			Where partner = ( select partner 
   	 		         	     from partnermst
									 where levelcod = :ls_levelcod
									   and :ls_reg_prefixno like prefixno||'%'
										and credit_yn = 'Y');

			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1	
				f_msg_sql_err(is_title, is_caller + " Update partnermst Table")				
				Return 
			End If
		
			idw_data[1].object.contractseq[1] = string(ldc_contractseq)
	
			Commit;
			
			f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")
			
		Elseif is_data[2] = '2' Then
			
			//개통실패상태코드			
			ls_ref_desc = ""
			ls_status = fs_get_control("B0","P232", ls_ref_desc)
			ls_remark = Trim(idw_data[1].object.remark[1])
			ldt_crtdt = fdt_get_dbserver_now()
			ls_pgm_id = gs_pgm_id[gi_open_win_no]
			ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
			ls_customerid   = Trim(idw_data[1].object.svcorder_customerid[1])			
			
			ldc_orderno = idw_data[1].object.svcorder_orderno[1]
	
			Update svcorder
			Set status    = :ls_status,
				 remark    = :ls_remark,
				 updt_user = :gs_user_id,
				 updtdt    = :ldt_crtdt,
				 pgm_id    = :ls_pgm_id
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
				Return 
			End If
			
			Delete from partner_ardtl
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Delete partner_ardtl Table")				
				Return 
			End If
	
			//대리점재고 상태코드
			ls_daricod = fs_get_control("E1","A102", ls_ref_desc)
			//본사재고 상태코드
			ls_boncod = fs_get_control("E1","A100", ls_ref_desc)
			//본사대리점코드 
			ls_bonsacod = fs_get_control("A1","C102", ls_ref_desc)
			
			Update admst
			Set status     = decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
				 saledt     = null,
				 customerid = null,
				 sale_amt   = null,
				 sale_flag  = '0',
				 dlvstat    = null,
				 updt_user  = :gs_user_id,
				 updtdt     = :ldt_crtdt,
				 pgm_id     = :ls_pgm_id
			Where orderno = :ldc_orderno;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
				Return 
			End If
			
			//판매취소코드 
			ls_action = fs_get_control("E1","A302", ls_ref_desc)

			//Insert
			insert into admstlog
				 ( adseq, seq, action, status, actdt, customerid, fr_partner,
 					crt_user, crtdt, pgm_id )
 			select adseq,
		          seq_admstlog.nextval,
					 :ls_action,
					 decode(mv_partner,:ls_bonsacod,:ls_boncod,:ls_daricod),
					 sysdate,
					 :ls_customerid,
					 mv_partner,
					 :gs_user_id, :ldt_crtdt, :ls_pgm_id
				from admst where orderno = :ldc_orderno ;
	
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(admstlog)")
				Return 
			End If	
			
			//개통상태코드			
			ls_ref_desc = ""
			ls_status = fs_get_control("B0","P223", ls_ref_desc)
			
			ll_cnt = 0
			select count(*) 
			  into :ll_cnt
			  from contractmst
   		 where customerid = :ls_customerid
			   and status = :ls_status;

			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " select count contractmst")
				Return 
			End If	

			If ll_cnt = 0 then
				
				//고객상태(개통실패)
				ls_cus_status = fs_get_control("B0","P203", ls_ref_desc)
				
				Update customerm
				Set status = :ls_cus_status,
					 updt_user = :gs_user_id,
					 updtdt = :ldt_crtdt,
					 pgm_id = :ls_pgm_id
				Where customerid = :ls_customerid;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;		
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update customerm Table")				
					Return 
				End If
			End if
				
			Commit;
			
			f_msg_info(3000,is_title,"개통실패처리")			
			
		End if
		   
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0
end subroutine

public subroutine uf_prc_db ();
//"b1dw_inq_inv_detail_t1%tabpage_retrieve"
String ls_module, ls_ref_no, ls_ref_desc, ls_temp, ls_desc[], ls_result[]
Long ll_rows, ll_row
dec ldc_contractseq, ldc_orderno
Int  li_tmp, li_cnt, li_cnt2, li_st, li_st2
String ls_payid,  ls_content[]
String ls_reqnum, ls_reqnumBf, ls_trdt, ls_trdtBf, ls_trcodnm 
String ls_flag, ls_trcod , ls_sql, ls_table
Dec{2} lc0_seqno, lc0_remain, lc0_tramt, lc0_amt[]

// "b1w_reg_svcactprc%save"
String ls_next, ls_customerid, ls_activedt, ls_status, ls_svccod, ls_priceplan, ls_prmtype, ls_cus_status
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_requestdt , ls_partner
String ls_validkey, ls_todt_tmp, ls_reg_prefixno, ls_remark, ls_svctype
String ls_bil_fromdt, ls_termtype, ls_contractno, ls_orderdt, ls_orderno, ls_pgm_id, ls_user_id, ls_term_status, ls_enter_status
Datetime ldt_crtdt
String ls_hotbillflag

Long ll_cnt

// "b1w_reg_svc_reactprc%save"
String ls_act_yn

ii_rc = -2

Choose Case is_caller
	Case "b1dw_inq_inv_detail_t1%tabpage_retrieve"
		// 2002.09.30, Park Kyung Hae: 월별청구내역 청구번호별 sum
		lc0_remain = 0
		ll_rows = 0
		ls_payid = is_data[1]
		idw_data[1].Reset()
		
		// SYSCTL1T의 청구항목 갯수 
		ls_module = "B1"
		ls_ref_no = "H100"
		ls_ref_desc = ""
		ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_result[])
		li_cnt = Integer(ls_result[1])
		
		For li_tmp = 1 To li_cnt
			If li_tmp < li_cnt Then
				ls_ref_no = "H1"
				If li_tmp < 10 Then 
					ls_ref_no = fs_fill_zeroes(ls_ref_no, 3)
				End If
				ls_ref_no += String(li_tmp)
				// SYSCTL1T의 청구항목
				ls_module = "B1"
				ls_ref_desc = ""
				ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
				ls_content[li_tmp] = Trim(ls_temp)
				ls_desc[li_tmp] = ls_ref_desc
				
			ElseIf li_tmp = li_cnt Then 
				// 청구항목 마지막에 청구잔액
				ls_ref_desc = "청구요금"
			End If
			
			// 칼럼이름 셋팅
			Choose Case li_tmp
				Case 1
					idw_data[1].Object.amt_1_t.Text = ls_ref_desc
					idw_data[1].Object.amt_1.Visible = 1
					idw_data[1].Object.amt_1_t.Visible = 1
					idw_data[1].Object.amt_1_s.Visible = 1
				Case 2
					idw_data[1].Object.amt_2_t.Text = ls_ref_desc
					idw_data[1].Object.amt_2.Visible = 1
					idw_data[1].Object.amt_2_t.Visible = 1
					idw_data[1].Object.amt_2_s.Visible = 1
				Case 3
					idw_data[1].Object.amt_3_t.Text = ls_ref_desc
					idw_data[1].Object.amt_3.Visible = 1
					idw_data[1].Object.amt_3_t.Visible = 1
					idw_data[1].Object.amt_3_s.Visible = 1
				Case 4
					idw_data[1].Object.amt_4_t.Text = ls_ref_desc
					idw_data[1].Object.amt_4.Visible = 1
					idw_data[1].Object.amt_4_t.Visible = 1
					idw_data[1].Object.amt_4_s.Visible = 1
				Case 5
					idw_data[1].Object.amt_5_t.Text = ls_ref_desc
					idw_data[1].Object.amt_5.Visible = 1
					idw_data[1].Object.amt_5_t.Visible = 1
					idw_data[1].Object.amt_5_s.Visible = 1
				Case 6
					idw_data[1].Object.amt_6_t.Text = ls_ref_desc
					idw_data[1].Object.amt_6.Visible = 1
					idw_data[1].Object.amt_6_t.Visible = 1
					idw_data[1].Object.amt_6_s.Visible = 1
				Case 7
					idw_data[1].Object.amt_7_t.Text = ls_ref_desc
					idw_data[1].Object.amt_7.Visible = 1
					idw_data[1].Object.amt_7_t.Visible = 1
					idw_data[1].Object.amt_7_s.Visible = 1
				Case 8
					idw_data[1].Object.amt_8_t.Text = ls_ref_desc
					idw_data[1].Object.amt_8.Visible = 1
					idw_data[1].Object.amt_8_t.Visible = 1
					idw_data[1].Object.amt_8_s.Visible = 1
				Case 9
					idw_data[1].Object.amt_9_t.Text = ls_ref_desc
					idw_data[1].Object.amt_9.Visible = 1
					idw_data[1].Object.amt_9_t.Visible = 1
					idw_data[1].Object.amt_9_s.Visible = 1
				Case 10
					idw_data[1].Object.amt_10_t.Text = ls_ref_desc
					idw_data[1].Object.amt_10.Visible = 1
					idw_data[1].Object.amt_10_t.Visible = 1
					idw_data[1].Object.amt_10_s.Visible = 1
				Case 11
					idw_data[1].Object.amt_11_t.Text = ls_ref_desc
					idw_data[1].Object.amt_11.Visible = 1
					idw_data[1].Object.amt_11_t.Visible = 1
					idw_data[1].Object.amt_11_s.Visible = 1
				Case 12
					idw_data[1].Object.amt_12_t.Text = ls_ref_desc
					idw_data[1].Object.amt_12.Visible = 1
					idw_data[1].Object.amt_12_t.Visible = 1
					idw_data[1].Object.amt_12_s.Visible = 1
				Case 13
					idw_data[1].Object.amt_13_t.Text = ls_ref_desc
					idw_data[1].Object.amt_13.Visible = 1
					idw_data[1].Object.amt_13_t.Visible = 1
					idw_data[1].Object.amt_13_s.Visible = 1
				Case 14
					idw_data[1].Object.amt_14_t.Text = ls_ref_desc
					idw_data[1].Object.amt_14.Visible = 1
					idw_data[1].Object.amt_14_t.Visible = 1
					idw_data[1].Object.amt_14_s.Visible = 1
				Case 15
					idw_data[1].Object.amt_15_t.Text = ls_ref_desc
					idw_data[1].Object.amt_15.Visible = 1
					idw_data[1].Object.amt_15_t.Visible = 1
					idw_data[1].Object.amt_15_s.Visible = 1
				Case 16
					idw_data[1].Object.amt_16_t.Text = ls_ref_desc
					idw_data[1].Object.amt_16.Visible = 1
					idw_data[1].Object.amt_16_t.Visible = 1
					idw_data[1].Object.amt_16_s.Visible = 1
				Case 17
					idw_data[1].Object.amt_17_t.Text = ls_ref_desc
					idw_data[1].Object.amt_17.Visible = 1
					idw_data[1].Object.amt_17_t.Visible = 1
					idw_data[1].Object.amt_17_s.Visible = 1
				Case 18
					idw_data[1].Object.amt_18_t.Text = ls_ref_desc
					idw_data[1].Object.amt_18.Visible = 1
					idw_data[1].Object.amt_18_t.Visible = 1
					idw_data[1].Object.amt_18_s.Visible = 1
				Case 19
					idw_data[1].Object.amt_19_t.Text = ls_ref_desc
					idw_data[1].Object.amt_19.Visible = 1
					idw_data[1].Object.amt_19_t.Visible = 1
					idw_data[1].Object.amt_19_s.Visible = 1
				Case 20
					idw_data[1].Object.amt_20_t.Text = ls_ref_desc
					idw_data[1].Object.amt_20.Visible = 1
					idw_data[1].Object.amt_20_t.Visible = 1
					idw_data[1].Object.amt_20_s.Visible = 1
				Case 21
					idw_data[1].Object.amt_21_t.Text = ls_ref_desc
					idw_data[1].Object.amt_21.Visible = 1
					idw_data[1].Object.amt_21_t.Visible = 1
					idw_data[1].Object.amt_21_s.Visible = 1
				Case 22
					idw_data[1].Object.amt_22_t.Text = ls_ref_desc
					idw_data[1].Object.amt_22.Visible = 1
					idw_data[1].Object.amt_22_t.Visible = 1
					idw_data[1].Object.amt_22_s.Visible = 1
				Case 23
					idw_data[1].Object.amt_23_t.Text = ls_ref_desc
					idw_data[1].Object.amt_23.Visible = 1
					idw_data[1].Object.amt_23_t.Visible = 1
					idw_data[1].Object.amt_23_s.Visible = 1
				Case 24
					idw_data[1].Object.amt_24_t.Text = ls_ref_desc
					idw_data[1].Object.amt_24.Visible = 1
					idw_data[1].Object.amt_24_t.Visible = 1
					idw_data[1].Object.amt_24_s.Visible = 1
				Case 25
					idw_data[1].Object.amt_25_t.Text = ls_ref_desc
					idw_data[1].Object.amt_25.Visible = 1
					idw_data[1].Object.amt_25_t.Visible = 1
					idw_data[1].Object.amt_25_s.Visible = 1
				Case 26
					idw_data[1].Object.amt_26_t.Text = ls_ref_desc
					idw_data[1].Object.amt_26.Visible = 1
					idw_data[1].Object.amt_26_t.Visible = 1
					idw_data[1].Object.amt_26_s.Visible = 1
				Case 27
					idw_data[1].Object.amt_27_t.Text = ls_ref_desc
					idw_data[1].Object.amt_27.Visible = 1
					idw_data[1].Object.amt_27_t.Visible = 1
					idw_data[1].Object.amt_27_s.Visible = 1
				Case 28
					idw_data[1].Object.amt_28_t.Text = ls_ref_desc
					idw_data[1].Object.amt_28.Visible = 1
					idw_data[1].Object.amt_28_t.Visible = 1
					idw_data[1].Object.amt_28_s.Visible = 1
				Case 29
					idw_data[1].Object.amt_29_t.Text = ls_ref_desc
					idw_data[1].Object.amt_29.Visible = 1
					idw_data[1].Object.amt_29_t.Visible = 1
					idw_data[1].Object.amt_29_s.Visible = 1
				Case 30
					idw_data[1].Object.amt_30_t.Text = ls_ref_desc
					idw_data[1].Object.amt_30.Visible = 1
					idw_data[1].Object.amt_30_t.Visible = 1
					idw_data[1].Object.amt_30_s.Visible = 1
		End Choose
			lc0_amt[li_tmp] = 0
		Next
		
     //TABLE SETTING : TAB1 일때랑 TAB2 일때 가져오는 테이블이 다르다.
		If is_data[2] = "1" Then
			ls_table = "reqdtl"
		ElseIf is_data[2] = "2" Then
			ls_table = "reqdtlh"
		End if
		
		 
			
		ls_sql = " SELECT a.reqnum, to_char(a.trdt,'yyyymmdd'), a.trcod, b.trcodnm, sum(a.tramt) + sum(nvl(a.taxamt,0)) " + &
					 " FROM " + ls_table + " a, trcode b  " + &
					 " WHERE a.trcod = b.trcod " + &
					 "  AND  a.PAYID = '" + ls_payid + "'" + &
					 "  AND  ( a.mark is null or a.mark <> 'D') " + &
					 " GROUP BY a.reqnum, to_char(a.trdt,'yyyymmdd'), a.trcod, b.trcodnm " + &
					 " ORDER BY 2 DESC, 1 DESC "


		DECLARE cur_read_reqdtl DYNAMIC CURSOR FOR SQLSA;
		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC	cur_read_reqdtl;
		
		If  sqlca.sqlcode = -1 Then
			 clipboard(ls_sql)	 
			 f_msg_sql_err(is_title, is_caller + " : cur_read_reqdtl")
			 Close cur_read_reqdtl;
			 Return 
		End If
		
		DO WHILE TRUE
			Fetch cur_read_reqdtl
			Into :ls_reqnum, :ls_trdt, :ls_trcod, :ls_trcodnm, :lc0_tramt;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_reqdtl")
				Close cur_read_reqdtl;
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				If ll_rows = 0 Then Exit
				
				//이전 청구번호에 해당하는 거래내역 입력
				ll_row = idw_data[1].InsertRow(0)
				idw_data[1].Object.trdt[ll_row] = ls_trdtBf
				idw_data[1].Object.reqnum[ll_row] = ls_reqnumBf
				
				For li_tmp = 1 To li_cnt 
					// 마지막항목은 청구잔액
					If li_tmp = li_cnt Then 
						lc0_amt[li_tmp] = lc0_remain
					End If
					Choose Case li_tmp
						Case 1
							idw_data[1].Object.amt_1[ll_row] = lc0_amt[li_tmp]
						Case 2
							idw_data[1].Object.amt_2[ll_row] = lc0_amt[li_tmp]
						Case 3
							idw_data[1].Object.amt_3[ll_row] = lc0_amt[li_tmp]
						Case 4
							idw_data[1].Object.amt_4[ll_row] = lc0_amt[li_tmp]
						Case 5
							idw_data[1].Object.amt_5[ll_row] = lc0_amt[li_tmp]
						Case 6
							idw_data[1].Object.amt_6[ll_row] = lc0_amt[li_tmp]
						Case 7
							idw_data[1].Object.amt_7[ll_row] = lc0_amt[li_tmp]
						Case 8
							idw_data[1].Object.amt_8[ll_row] = lc0_amt[li_tmp]
						Case 9
							idw_data[1].Object.amt_9[ll_row] = lc0_amt[li_tmp]
						Case 10
							idw_data[1].Object.amt_10[ll_row] = lc0_amt[li_tmp]
						Case 11
							idw_data[1].Object.amt_11[ll_row] = lc0_amt[li_tmp]
						Case 12
							idw_data[1].Object.amt_12[ll_row] = lc0_amt[li_tmp]
						Case 13
							idw_data[1].Object.amt_13[ll_row] = lc0_amt[li_tmp]
						Case 14
							idw_data[1].Object.amt_14[ll_row] = lc0_amt[li_tmp]
						Case 15
							idw_data[1].Object.amt_15[ll_row] = lc0_amt[li_tmp]
						Case 16
							idw_data[1].Object.amt_16[ll_row] = lc0_amt[li_tmp]
						Case 17
							idw_data[1].Object.amt_17[ll_row] = lc0_amt[li_tmp]
						Case 18
							idw_data[1].Object.amt_18[ll_row] = lc0_amt[li_tmp]
						Case 19
							idw_data[1].Object.amt_19[ll_row] = lc0_amt[li_tmp]
						Case 20
							idw_data[1].Object.amt_20[ll_row] = lc0_amt[li_tmp]
						Case 21
							idw_data[1].Object.amt_21[ll_row] = lc0_amt[li_tmp]
						Case 22
							idw_data[1].Object.amt_22[ll_row] = lc0_amt[li_tmp]
						Case 23
							idw_data[1].Object.amt_23[ll_row] = lc0_amt[li_tmp]
						Case 24
							idw_data[1].Object.amt_24[ll_row] = lc0_amt[li_tmp]
						Case 25
							idw_data[1].Object.amt_25[ll_row] = lc0_amt[li_tmp]
						Case 26
							idw_data[1].Object.amt_26[ll_row] = lc0_amt[li_tmp]
						Case 27
							idw_data[1].Object.amt_27[ll_row] = lc0_amt[li_tmp]
						Case 28
							idw_data[1].Object.amt_28[ll_row] = lc0_amt[li_tmp]
						Case 29
							idw_data[1].Object.amt_29[ll_row] = lc0_amt[li_tmp]
						Case 30
							idw_data[1].Object.amt_30[ll_row] = lc0_amt[li_tmp]							
					End Choose
				Next
				Exit
			End If
			
			If ll_rows = 0 Then ls_reqnumBf = ls_reqnum
			If ls_reqnumBf = ls_reqnum Then
				For li_tmp = 1 To li_cnt - 1
					//SYSCTL1T의 청구항목 - 미리 배열에 저장된 값을 읽음
					ls_temp = Trim(ls_content[li_tmp])
					If IsNull(ls_temp) Then ls_temp = ""
					If ls_temp = "" Then Return 
					li_cnt2 = fi_cut_string(ls_temp, ";" , ls_result[])
					For li_st2 = 2 To	li_cnt2
						If ls_trcod = ls_result[li_st2] Then
							lc0_remain += lc0_tramt
							//lc0_amt[li_tmp] += ABS(lc0_tramt)
							lc0_amt[li_tmp] += lc0_tramt
							// For Loop 완전히 빠져 나가도록
							li_tmp = li_cnt
							Exit
						End If
					Next
				Next
			Else
				//이전 청구번호에 해당하는 거래내역 입력
				ll_row = idw_data[1].InsertRow(0)
				idw_data[1].Object.trdt[ll_row] = ls_trdtBf
				idw_data[1].Object.reqnum[ll_row] = ls_reqnumBf
				For li_tmp = 1 To li_cnt
					// 마지막항목은 청구잔액
					If li_tmp = li_cnt Then 
						lc0_amt[li_tmp] = lc0_remain
					End If
					Choose Case li_tmp
						Case 1
							idw_data[1].Object.amt_1[ll_row] = lc0_amt[li_tmp]
						Case 2
							idw_data[1].Object.amt_2[ll_row] = lc0_amt[li_tmp]
						Case 3
							idw_data[1].Object.amt_3[ll_row] = lc0_amt[li_tmp]
						Case 4
							idw_data[1].Object.amt_4[ll_row] = lc0_amt[li_tmp]
						Case 5
							idw_data[1].Object.amt_5[ll_row] = lc0_amt[li_tmp]
						Case 6
							idw_data[1].Object.amt_6[ll_row] = lc0_amt[li_tmp]
						Case 7
							idw_data[1].Object.amt_7[ll_row] = lc0_amt[li_tmp]
						Case 8
							idw_data[1].Object.amt_8[ll_row] = lc0_amt[li_tmp]
						Case 9
							idw_data[1].Object.amt_9[ll_row] = lc0_amt[li_tmp]
						Case 10
							idw_data[1].Object.amt_10[ll_row] = lc0_amt[li_tmp]
						Case 11
							idw_data[1].Object.amt_11[ll_row] = lc0_amt[li_tmp]
						Case 12
							idw_data[1].Object.amt_12[ll_row] = lc0_amt[li_tmp]
						Case 13
							idw_data[1].Object.amt_13[ll_row] = lc0_amt[li_tmp]
						Case 14
							idw_data[1].Object.amt_14[ll_row] = lc0_amt[li_tmp]
						Case 15
							idw_data[1].Object.amt_15[ll_row] = lc0_amt[li_tmp]
						Case 16
							idw_data[1].Object.amt_16[ll_row] = lc0_amt[li_tmp]
						Case 17
							idw_data[1].Object.amt_17[ll_row] = lc0_amt[li_tmp]
						Case 18
							idw_data[1].Object.amt_18[ll_row] = lc0_amt[li_tmp]
						Case 19
							idw_data[1].Object.amt_19[ll_row] = lc0_amt[li_tmp]
						Case 20
							idw_data[1].Object.amt_20[ll_row] = lc0_amt[li_tmp]
						Case 21
							idw_data[1].Object.amt_21[ll_row] = lc0_amt[li_tmp]
						Case 22
							idw_data[1].Object.amt_22[ll_row] = lc0_amt[li_tmp]
						Case 23
							idw_data[1].Object.amt_23[ll_row] = lc0_amt[li_tmp]
						Case 24
							idw_data[1].Object.amt_24[ll_row] = lc0_amt[li_tmp]
						Case 25
							idw_data[1].Object.amt_25[ll_row] = lc0_amt[li_tmp]
						Case 26
							idw_data[1].Object.amt_26[ll_row] = lc0_amt[li_tmp]
						Case 27
							idw_data[1].Object.amt_27[ll_row] = lc0_amt[li_tmp]
						Case 28
							idw_data[1].Object.amt_28[ll_row] = lc0_amt[li_tmp]
						Case 29
							idw_data[1].Object.amt_29[ll_row] = lc0_amt[li_tmp]
						Case 30
							idw_data[1].Object.amt_30[ll_row] = lc0_amt[li_tmp]							
					End Choose
					lc0_amt[li_tmp] = 0					
				Next
				lc0_remain = 0
				
				For li_tmp = 1 To li_cnt - 1
					//SYSCTL1T의 청구항목 - 미리 배열에 저장된 값을 읽음
					ls_temp = Trim(ls_content[li_tmp])
					If IsNull(ls_temp) Then ls_temp = ""
					If ls_temp = "" Then Return 
					li_cnt2 = fi_cut_string(ls_temp, ";" , ls_result[])
					For li_st2 = 2 To	li_cnt2
						If ls_trcod = ls_result[li_st2] Then
							lc0_remain += lc0_tramt
							//lc0_amt[li_tmp] += ABS(lc0_tramt)
							lc0_amt[li_tmp] += lc0_tramt
							// For Loop 완전히 빠져 나가도록
							li_tmp = li_cnt
							Exit
						End If
					Next
				Next
			End If			
			ll_rows++
			ls_reqnumBf = ls_reqnum
			ls_trdtBf = ls_trdt
		Loop	
		Close cur_read_reqdtl;
		
	Case "b1w_reg_svc_actprc%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_actprc%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
        
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		//2004.12.07. khpark modify start
		ls_payid = Trim(idw_data[1].object.customerm_payid[1])
		IF IsNull(ls_payid) Then ls_payid = ""
		
	    Select hotbillflag
         Into :ls_hotbillflag
         From customerm
        Where customerid = :ls_payid;
		
		If SQLCA.SQLCode = 100 Then		//Not Found
		   f_msg_usr_err(201,is_Title, "select not found(payid)")
		   ii_rc = -1
		   Return
		End If

		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT customerm(hotbillflag)")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	

		If IsNull(ls_hotbillflag) Then ls_hotbillflag = ""
		If ls_hotbillflag = 'S' Then    //현재 Hotbilling고객이면 개통신청 못하게 한다.
		   f_msg_usr_err(201, is_Title, "즉시불처리중인고객")
		   ii_rc = -1
		   return
		End If
		//2004.12.07. khpark modify end
		
		//contractseq 가져 오기
		Select seq_contractseq.nextval
		Into :ldc_contractseq
		From dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		idw_data[1].object.contractseq[1] = string(ldc_contractseq)
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		ls_customerid = Trim(idw_data[1].object.svcorder_customerid[1])
		ls_cus_status = Trim(idw_data[1].object.customerm_status[1])
		ls_activedt = string(idw_data[1].object.activedt[1],'yyyymmdd')
		ls_svccod = Trim(idw_data[1].object.svcorder_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.svcorder_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.svcorder_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.svcorder_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.svcorder_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.svcorder_settle_partner[1])
		ls_partner = Trim(idw_data[1].object.svcorder_partner[1])	
		ls_orderdt = STring(idw_data[1].object.svcorder_orderdt[1],'yyyymmdd')		
		ls_requestdt = STring(idw_data[1].object.svcorder_requestdt[1],'yyyymmdd')
		ls_bil_fromdt = string(idw_data[1].object.bil_fromdt[1],'yyyymmdd')
		ls_contractno = Trim(idw_data[1].object.contract_no[1])
		ls_reg_prefixno = Trim(idw_data[1].object.svcorder_reg_prefixno[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_cus_status) Then ls_cus_status = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""						
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_requestdt) Then ls_requestdt = ""						
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		If IsNull(ls_contractno) Then ls_contractno = ""
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//Insert
		insert into contractmst
		    ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
				crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
	   values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
			   to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
				:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
			Return 
		End If	
			
		// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
		//해지상태
		ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
		//가입상태
		ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)

		If ls_cus_status = ls_term_status Then
			
			Update customerm
			Set status = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt = :ldt_crtdt
			Where customerid = :ls_customerid;
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If
			
		End If
		
		ldc_orderno = idw_data[1].object.svcorder_orderno[1]

		Update svcorder
		Set status = :ls_status,
		    ref_contractseq = :ldc_contractseq,
			remark = :ls_remark,
			updt_user = :gs_user_id,
			updtdt = :ldt_crtdt,
			pgm_id = :ls_pgm_id
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If
				
		Update contractdet
		Set contractseq = :ldc_contractseq
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1	
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
			Return 
		End If

		Update quota_info
		Set contractseq = :ldc_contractseq,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt
		Where orderno = :ldc_orderno;
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update QUOTA_INFO Table")				
			Return 
		End If

		//Valid Key Update
		String ls_itemcod
		String ls_reqactive //개통 신청 상태 코드
		ls_reqactive = fs_get_control("B0", "P220", ls_ref_desc)
		
		DECLARE cur_validkey_check CURSOR FOR
		Select validkey, to_char(fromdt,'yyyymmdd'), svctype
 		  From validinfo
		Where orderno = :ldc_orderno;
		
//		Select validkey, to_char(fromdt,'yyyymmdd'), svctype
// 		  From validinfo
//		Where customerid = :ls_customerid 
//		  and status = :ls_reqactive 
//		  and priceplan = :ls_priceplan;

		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
			Return 
		End If

		OPEN cur_validkey_check;
		Do While(True)
			FETCH cur_validkey_check
			Into :ls_validkey, :ls_todt_tmp, :ls_svctype;

			If SQLCA.sqlcode < 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " CURSOR cur_validkey_check")				
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			ll_cnt = 0
			//인증KEY 중복 check  
			//적용시작일과 적용종료일의 중복일자를 막는다. 
			select count(*)
			  into :ll_cnt
			 from validinfo
			where  ( (to_char(fromdt,'yyyymmdd') > :ls_activedt ) Or
					  ( to_char(fromdt,'yyyymmdd') <= :ls_activedt and
						:ls_activedt < nvl(to_char(todt,'yyyymmdd'),'99991231')) )
			   and	validkey = :ls_validkey
			   and  to_char(fromdt,'yyyymmdd') <> :ls_todt_tmp
			   and  svctype = :ls_svctype ;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
				Return 
			End If
			
			If ll_cnt > 0 Then
				f_msg_usr_err(9000, is_title, "인증Key[" + ls_validkey+ "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
				ii_rc = -1
				return 
			End if
			
		Loop
		CLOSE cur_validkey_check;
		
		Update validinfo
		Set  fromdt = to_date(:ls_activedt,'yyyy-mm-dd'),  //개통일
			 use_yn = 'Y',								   //사용여부
			 status = :ls_status,
			 contractseq = :ldc_contractseq,
			 svccod = :ls_svccod,
       		 priceplan = :ls_priceplan,
			 updt_user = :gs_user_id,
			 updtdt = :ldt_crtdt,
			 pgm_id = :ls_pgm_id
 		Where orderno = :ldc_orderno;
//		Where customerid = :ls_customerid and status = :ls_reqactive  and priceplan = :ls_priceplan;
		
		If SQLCA.SQLCode <> 0 Then
			ii_rc = -1
			Rollback;
			f_msg_sql_err(is_title, is_caller + " Update validinfo Table")				
			Return 
		End If
			 
		f_msg_info(9000, is_title, "계약 Seq " + String(ldc_contractseq) + "로 계약마스터에 등록되었습니다.")


	Case "b1w_reg_svc_actprc_batch_cv%save"
//lu_dbmgr2.is_caller = "b1w_reg_svc_actprc_batch_cv%save"
//lu_dbmgr2.is_title  = Title
//lu_dbmgr2.idw_data[1] = dw_detail
//lu_dbmgr2.is_data[1] = ls_activedt
//lu_dbmgr2.is_data[2] = ls_bil_fromdt
        
		int i  
		DataWindow dw_detail
		 
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
		ls_activedt = is_data[1]
		ls_bil_fromdt = is_data[2]
		
		ls_partner = fs_get_control("A1","C102",ls_ref_desc)//본사
		
		SELECT prefixno
		INTO :ls_reg_prefixno
		FROM partnermst
		WHERE partner = :ls_partner;
		
		ls_reg_partner = ls_partner
		ls_sale_partner = ls_partner
		ls_maintain_partner = ls_partner
		ls_settle_partner = ls_partner
		
		If IsNull(ls_status) Then ls_status = ""		
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""						
		If IsNull(ls_partner) Then ls_partner = ""						
		If IsNull(ls_activedt) Then ls_activedt = ""	
		If IsNull(ls_bil_fromdt) or ls_bil_fromdt = "" Then ls_bil_fromdt = ls_activedt						
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		
		//개통상태코드
		ls_ref_desc = ""
		ls_status = fs_get_control("B0","P223", ls_ref_desc)
		
		
		FOR i=1 TO ll_row
			
			ls_act_yn = idw_data[1].object.act_yn[i]
			
			IF ls_act_yn = "Y" THEN
				//contractseq 가져 오기
				Select seq_contractseq.nextval
				Into :ldc_contractseq
				From dual;
				
				If SQLCA.SQLCode < 0 Then
					f_msg_sql_err(is_title, is_caller + "SELECT seq_contractseq.nextval")			
					ii_rc = -1			
					RollBack;
					Return 
				End If	
				
				
				ls_customerid = Trim(idw_data[1].object.svcorder_customerid[i])
				ls_cus_status = Trim(idw_data[1].object.customerm_status[i])
				ls_svccod = Trim(idw_data[1].object.svcorder_svccod[i])
				ls_priceplan = Trim(idw_data[1].object.svcorder_priceplan[i])
				ls_prmtype = ""
				ls_orderdt = String(idw_data[1].object.svcorder_orderdt[i],'yyyymmdd')		
				ls_requestdt = String(idw_data[1].object.svcorder_requestdt[i],'yyyymmdd')
				ls_contractno = ""
				
				If IsNull(ls_customerid) Then ls_customerid = ""				
				If IsNull(ls_cus_status) Then ls_cus_status = ""						
				If IsNull(ls_svccod) Then ls_svccod = ""						
				If IsNull(ls_priceplan) Then ls_priceplan = ""						
				If IsNull(ls_prmtype) Then ls_prmtype = ""						
				If IsNull(ls_requestdt) Then ls_requestdt = ""						
				If IsNull(ls_contractno) Then ls_contractno = ""
				
				//Insert
				insert into contractmst
					 ( contractseq, customerid, activedt, status, termdt, svccod, priceplan,
						prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
						orderdt, requestdt, bil_fromdt, bil_todt, change_flag, termtype, contractno,
						crt_user, crtdt, pgm_id, updt_user, updtdt, reg_prefixno )
				values ( :ldc_contractseq, :ls_customerid, to_date(:ls_activedt,'yyyy-mm-dd'), :ls_status, null, :ls_svccod, :ls_priceplan,
						:ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :ls_partner,
						to_date(:ls_orderdt,'yyyy-mm-dd'), to_date(:ls_requestdt,'yyyy-mm-dd'), to_date(:ls_bil_fromdt,'yyyy-mm-dd'), null, null, null, :ls_contractno,
						:gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_reg_prefixno);
		
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Insert Error(CONTRACTMST)")
					Return 
				End If	
					
				// 해지고객이 개통처리를 하면 가입고객으로 바꿔준다...
				//해지상태
				ls_term_status = fs_get_control("B0", "P201", ls_ref_desc)
				//가입상태
				ls_enter_status = fs_get_control("B0", "P200", ls_ref_desc)
		
				If ls_cus_status = ls_term_status Then
					
					Update customerm
					Set status = :ls_enter_status,
						 updt_user = :gs_user_id,
						 updtdt = :ldt_crtdt
					Where customerid = :ls_customerid;
					
					If SQLCA.SQLCode <> 0 Then
						RollBack;	
						ii_rc = -1
						f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
						Return 
					End If
					
				End If
				
				ldc_orderno = idw_data[1].object.svcorder_orderno[i]
		
				Update svcorder
				Set status = :ls_status,
					 ref_contractseq = :ldc_contractseq,
					 updt_user = :gs_user_id,
					 updtdt = :ldt_crtdt,
					 pgm_id = :ls_pgm_id
				Where orderno = :ldc_orderno;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
					Return 
				End If
						
				Update contractdet
				Set contractseq = :ldc_contractseq
				Where orderno = :ldc_orderno;
				
				If SQLCA.SQLCode <> 0 Then
					RollBack;	
					ii_rc = -1	
					f_msg_sql_err(is_title, is_caller + " Update CONTRACTDET Table")				
					Return 
				End If
			END IF
		NEXT
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
		
End Choose

ii_rc = 0


end subroutine

public function integer uf_prc_date_range (string as_old_start, string as_old_end, string as_start, string as_end);/*-------------------------------------------------------------------------
	name	: uf_prc_date_range()
	desc.	: 날짜의  범위가 곂치지 않게 하기 위해
	ver.	: 1.0
	arg.	: string
				- as_old_start : 기준 시작 날짜
				- as_old_end : 기준 종료 날짜
				- as_start : 시작 날짜
				- as_end   : 종료 되는 날짜
				
	return  : integer
				 - -1 실패  시작
				 - -2 실패 	끝 
				 -  0 성공
	date 	: 2002.09.29
	programer : Choi Bo Ra(ceusee)
--------------------------------------------------------------------------*/
if as_start = "" Then Return -1
If as_end = "" Then as_end = "29991231"		//임의 의 값 
If as_old_end = "" Then as_old_end = "29991231"

 
If ( as_old_start <= as_start and as_old_end >= as_start ) Or &
( as_old_start <= as_end   and as_old_end >= as_end )Then Return -1
Return 0
end function

public subroutine uf_prc_db_03 ();
// "b1w_reg_reactorder%save"
String ls_module, ls_ref_no, ls_ref_desc, ls_temp, ls_desc[], ls_result[],ls_enter_status
String ls_customerid, ls_status, ls_svccod, ls_priceplan, ls_prmtype
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner
String ls_pgm_id, ls_act_yn, ls_act_gu, ls_suspend[], ls_remark, ls_term[]
DateTime ldt_crtdt
Date ld_todt
Long ll_row, ll_cnt
dec ldc_orderno

ii_rc = -2

Choose Case is_caller
	Case "b1w_reg_svc_reactorder%save"
//		lu_dbmgr2.is_caller = "b1w_reg_svc_reactorder%save"
//		lu_dbmgr2.is_title  = Title
//		lu_dbmgr2.idw_data[1] = dw_detail
//		lu_dbmgr2.is_data[1] = ls_contractseq    //계약번호
//		lu_dbmgr2.is_data[2] = is_react_status   //
//		lu_dbmgr2.is_data[3] = ls_actdt
//		lu_dbmgr2.is_data[4] = ls_partner

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음


		ls_act_gu = Trim(idw_data[1].object.act_gu[1])
		If IsNull(ls_act_gu) Then ls_act_gu = ""
		
		If ls_act_gu = 'Y' Then
			//개통 상태코드
			ls_status = fs_get_control("B0", "P223", ls_ref_desc)
			
			//현재 login한 gs_user_group에 해당하는 Partner의 개통허용여부 check
			Select act_yn
			 Into :ls_act_yn
			 From partnermst
			Where partner = :gs_user_group;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " SELECT parnermst")				
				ii_rc = -2			
				RollBack;
				Return 
			End If	
			
			If ls_act_yn <> "Y"  Then
				 f_msg_Usr_err(9000, is_caller, "현재 LOGIN 하신 [" + gs_user_id + "]로는 재개통이 불가능합니다.")
				 ii_rc = -2													 
				 return
			End If	
			
		Else
			//재개통신청상태코드
			ls_status = is_data[2]
		End If
		
		ll_cnt = 0		
		
		ls_customerid = Trim(idw_data[1].object.contractmst_customerid[1])
		//재개통 신청내역 존재 여부 check
		Select count(*)
		 Into :ll_cnt
		 From svcorder
		Where to_char(ref_contractseq) = :is_data[1]
		  and status = :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT svcorder")				
			ii_rc = -1			
			RollBack;
			Return 
		End If	

		If ll_cnt > 0 Then
			 f_msg_Usr_err(9000, is_caller, "고객 [" + ls_customerid + "] 계약Seq[" + &
			 										is_data[1] + "]는 이미 재개통신청이 되어있습니다.")
		  	 ii_rc = -2													 
			 return
		End If	
		
		//서비스신청번호 가져 오기
		Select seq_orderno.nextval
		Into :ldc_orderno
		From dual;
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT seq_orderno.nextval")				
			ii_rc = -1
			RollBack;
			Return 
		End If	
		
	 	ls_svccod = Trim(idw_data[1].object.contractmst_svccod[1])
		ls_priceplan = Trim(idw_data[1].object.contractmst_priceplan[1])
		ls_prmtype = Trim(idw_data[1].object.contractmst_prmtype[1])
		ls_reg_partner = Trim(idw_data[1].object.contractmst_reg_partner[1])
		ls_sale_partner = Trim(idw_data[1].object.contractmst_sale_partner[1])
		ls_maintain_partner = Trim(idw_data[1].object.contractmst_maintain_partner[1])
		ls_settle_partner = Trim(idw_data[1].object.contractmst_settle_partner[1])
		ls_remark = Trim(idw_data[1].object.remark[1])
		If IsNull(ls_customerid) Then ls_customerid = ""				
		If IsNull(ls_svccod) Then ls_svccod = ""						
		If IsNull(ls_priceplan) Then ls_priceplan = ""						
		If IsNull(ls_prmtype) Then ls_prmtype = ""						
		If IsNull(ls_reg_partner) Then ls_reg_partner = ""						
		If IsNull(ls_sale_partner) Then ls_sale_partner = ""						
		If IsNull(ls_maintain_partner) Then ls_maintain_partner = ""						
		If IsNull(ls_settle_partner) Then ls_settle_partner = ""	
		If IsNull(ls_remark) Then ls_remark = ""
		
		ldt_crtdt = fdt_get_dbserver_now()
		ls_pgm_id = gs_pgm_id[gi_open_win_no]
		
		//Insert
		insert into svcorder
		    ( orderno, customerid, orderdt, requestdt, status, svccod, priceplan,
			   prmtype, reg_partner, sale_partner, maintain_partner, settle_partner, partner,
			   ref_contractseq, crt_user, crtdt, pgm_id, updt_user, updtdt, remark, order_type )
	   values ( :ldc_orderno, :ls_customerid, :ldt_crtdt, to_date(:is_data[3],'yyyy-mm-dd'), :ls_status, :ls_svccod, :ls_priceplan,
			   :ls_prmtype, :ls_reg_partner, :ls_sale_partner, :ls_maintain_partner, :ls_settle_partner, :is_data[4],
			   :is_data[1], :gs_user_id, :ldt_crtdt, :ls_pgm_id, :gs_user_id, :ldt_crtdt, :ls_remark, :ls_status);

		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			ii_rc = -1			
			RollBack;
			f_msg_sql_err(is_title, is_caller + " Insert Err(SVCORDER)")				
			Return 
		End If	
			
	 	//재개통처리 루틴
		If ls_act_gu = 'Y' Then
			
			Update contractmst
			  Set status = :ls_status,
				  updt_user = :gs_user_id,
				  updtdt = sysdate
			Where to_char(contractseq) = :is_data[1];
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update CONTRACTMST Table")				
				Return 
			End If
	
			ld_todt = Relativedate(date(idw_data[1].object.actdt[1]),-1)
			
			Update suspendinfo
			  Set todt = :ld_todt,
				  updt_user = :gs_user_id,
				  updtdt = sysdate
			 Where to_char(contractseq) = :is_data[1]
			   And ( todt is null or 
					  to_char(todt,'yyyymmdd') <= '19000000' );
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update SUSPENDINFO Table")				
				Return 
			End If
			
			//일시정지 상태코드
			ls_temp = fs_get_control("B0", "P225", ls_ref_desc)
			fi_cut_string(ls_temp, ";", ls_suspend[])		
	
			Update validinfo
			   Set use_yn = 'Y',
  				   status = :ls_status,
				   updt_user = :gs_user_id,
				   updtdt = sysdate
			 Where to_char(contractseq) = :is_data[1]
			   and status = :ls_suspend[2];
					 
			If SQLCA.SQLCode <> 0 Then
				RollBack;		
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update VALIDINFO Table")				
				Return 
			End If
			
		End If
			
	Case "b1w_reg_svc_reactprc%save"
//		lu_dbmgr.is_caller = "b1w_reg_svc_reactprc%save"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr2.is_data[1] = ls_contractseq   //계약번호
//		lu_dbmgr2.is_data[2] = ls_actdt         //재개통일자
//		lu_dbmgr2.is_data[3] = ls_svccod        //서비스코드
//		lu_dbmgr2.is_data[4] = ls_customerid    //고객코드
//		lu_dbmgr2.is_data[5] = ls_orderno       //서비스신청번호

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음

		//현내 login한 gs_user_group에 해당하는 Partner의 개통허용여부 check
		Select act_yn
		 Into :ls_act_yn
		 From partnermst
		Where partner = :gs_user_group;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " SELECT parnermst")				
			ii_rc = -2			
			RollBack;
			Return 
		End If	
		
		If ls_act_yn <> "Y"  Then
			 f_msg_Usr_err(9000, is_caller, "현재 LOGIN 하신 [" + gs_user_id + "]로는 재개통이 불가능합니다.")
		  	 ii_rc = -2													 
			 return
		End If
		
		ls_remark = Trim(idw_data[1].object.remark[1])

		//개통 상태코드
		ls_status = fs_get_control("B0", "P223", ls_ref_desc)
		Update svcorder
		Set status = :ls_status,
		    remark = :ls_remark,
			 updt_user = :gs_user_id,
			 updtdt = sysdate
		Where to_char(orderno) = :is_data[5];
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SVCORDER Table")				
			Return 
		End If

		// 이미 해지된 계약은 다시 개통 상태로 안하게 하기 위해서 
		//해지 상태코드 addition by hcjung 2007-04-06
		ls_temp = fs_get_control("B0", "P221", ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_term[])		

		Update contractmst
		  Set status = :ls_status,
				 updt_user = :gs_user_id,
				 updtdt = sysdate
		Where to_char(contractseq) = :is_data[1]
	     and status <> :ls_term[2];  // addition by hcjung 2007-04-06
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update CONTRACTMST Table")				
			Return 
		End If

		ld_todt = Relativedate(date(idw_data[1].object.actdt[1]),-1)
		
		Update suspendinfo
		  Set todt = :ld_todt,
			  updt_user = :gs_user_id,
			  updtdt = sysdate
		 Where to_char(contractseq) = :is_data[1]
		   And ( todt is null or 
			      to_char(todt,'yyyymmdd') <= '19000000' );
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;	
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update SUSPENDINFO Table")				
			Return 
		End If

		//일시정지 상태코드
		ls_temp = fs_get_control("B0", "P225", ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_suspend[])		

		Update validinfo
		   Set use_yn = 'Y',
			    status = :ls_status,
				 updt_user = :gs_user_id,
				 updtdt = sysdate
		   Where to_char(contractseq) = :is_data[1]
		     and status = :ls_suspend[2];
				 
		If SQLCA.SQLCode <> 0 Then
			RollBack;		
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Update VALIDINFO Table")				
			Return 
		End If
		
		//가입상태
		ls_enter_status = fs_get_control("B0", "P202", ls_ref_desc)

		// 해지고객뿐 아니라 서비스 재개통시 고객 상태를 무조건 개통으로 변경한다. by hcjung (2007-05-17)
			
			Update customerm
			Set status    = :ls_enter_status,
				 updt_user = :gs_user_id,
				 updtdt    = sysdate
			Where customerid = :is_data[4];
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;	
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update CUSTOMERM Table(STATUS)")				
				Return 
			End If	

	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0


end subroutine

on b1u_dbmgr2.create
call super::create
end on

on b1u_dbmgr2.destroy
call super::destroy
end on

