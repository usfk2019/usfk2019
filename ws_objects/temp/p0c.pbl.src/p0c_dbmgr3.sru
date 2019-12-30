$PBExportHeader$p0c_dbmgr3.sru
$PBExportComments$[victory] 등록 및 프로세스
forward
global type p0c_dbmgr3 from u_cust_a_db
end type
end forward

global type p0c_dbmgr3 from u_cust_a_db
end type
global p0c_dbmgr3 p0c_dbmgr3

forward prototypes
public subroutine uf_prc_db_02 ()
end prototypes

public subroutine uf_prc_db_02 ();String ls_model, ls_contno_fr, ls_contno_to, ls_partner_fr, ls_partner_to
String ls_movedt, ls_remark, ls_lotno, ls_mflag, ls_contno_last, ls_contno_first
String ls_ref_desc, ls_tmp, ls_result[], ls_partner_prefix_fr, ls_partner_prefix_to
String ls_sql, ls_where, ls_pid, ls_contno
Integer li_return
Long  ll_move_seq
Dec{4} lc_amt , lc_cnt

ii_rc = -1
Choose Case is_caller
	Case "Card Move"
		lc_cnt = 0 
		lc_amt = ic_data[1]
		ls_model = is_data[1]
		ls_contno_fr = is_data[2]
		ls_contno_to = is_data[3]
		ls_lotno = is_data[4]
		ls_partner_fr = is_data[5]
		ls_partner_to = is_data[6]
		ls_movedt = is_data[7]
		ls_remark = is_data[8]
		
		//발행 상태 가져오기
	   ls_ref_desc = ""
		ls_tmp = fs_get_control('P0', 'P101', ls_ref_desc)
		If ls_tmp = "" Then Return
		
		li_return = fi_cut_string(ls_tmp, ";", ls_result[])
		If li_return <= 0 Then Return
		ls_mflag = ls_result[1]		//발행
		
 		//Partner Prefix 구하기
		Select prefixno
		Into :ls_partner_prefix_fr
		From partnermst
		Where partner = :ls_partner_fr;
		
		Select prefixno
		Into :ls_partner_prefix_to
		From partnermst
		Where partner = :ls_partner_to;
		
		
		Select seq_moveno.nextval
		Into :ll_move_seq
		From dual;
		
		If ls_contno_fr <> "" And ls_contno_to <> "" Then
			If ls_where <> "" Then ls_where += " And "
		   ls_where += "contno >= '" + ls_contno_fr + "' " + &
							"And contno <= '" + ls_contno_to + "' "
		
		ElseIf ls_contno_fr <> "" And ls_contno_to = "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "contno = '" + ls_contno_fr + "' "
      End If
		
		If ls_lotno <> "" Then
			If ls_where <> "" Then ls_where += " And "
			ls_where += "lotno = '" + ls_lotno + "' "
		End If
		
		
		//해당 조건에 해당하는 pin 찾기
		DECLARE move_pin DYNAMIC CURSOR FOR SQLSA;
		
		ls_sql += "select pid, contno from p_cardmst " + &
				 "where status = '" + ls_mflag + "' " + &
				 "and partner_prefix = '" + ls_partner_prefix_fr + "' "
		If ls_where <> "" Then ls_sql += " And " + ls_where
		ls_sql += " Order by contno, pid"
		

		
		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC move_pin;
		
		Do While(True)
			FETCH move_pin
			INTO :ls_pid, :ls_contno;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : out_pin")
				CLOSE move_pin;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			//P_CARDMST Update
			Update p_cardmst set
				partner_prefix = :ls_partner_prefix_to ,
				moveseq = :ll_move_seq,
				movedt = to_date(:ls_movedt, 'yyyy-mm-dd'),
				remark = :ls_remark,
				crtdt = sysdate,
				updtdt = sysdate,
				updt_user = :gs_user_id,
				crt_user = :gs_user_id,
				pgm_id = :gs_pgm_id[1]
			Where pid = :ls_pid;
			
			
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " Update Error(P_CARDMST)")
				Return
			End If
	      
			lc_cnt += 1
				//초기관리번호
			If lc_cnt = 1 Then ls_contno_first = ls_contno
			ls_contno_last = ls_contno
			
			w_msg_wait.wf_progress_step()
			Loop	
	Close move_pin;
	
	//쟈료가 없을때
   If lc_cnt = 0 Then
		ii_rc = -2
	   Return 
   End If
	
  
	//이동 이력 Insert
	Insert Into p_movlog
		(moveseq, fr_prefix, to_prefix, movedt, pricemodel, 
		 move_qty, contno_fr, contno_to, remark, crtdt, crt_user, lotno)
	Values
	 	(:ll_move_seq, :ls_partner_prefix_fr, :ls_partner_prefix_to,  to_date(:ls_movedt, 'yyyy-mm-dd'), :ls_model,
		 :lc_cnt, :ls_contno_first, :ls_contno_last, :ls_remark, sysdate, :gs_user_Id, :ls_lotno);
	
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(is_title, is_caller + " Insert Error(P_MOVELOG)")
		Return
	End If
	
	ic_data[1] = lc_cnt
	is_data[1] = ls_contno_first
	is_data[2] = ls_contno_last
End Choose
ii_rc = 0
end subroutine

on p0c_dbmgr3.create
call super::create
end on

on p0c_dbmgr3.destroy
call super::destroy
end on

