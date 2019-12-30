$PBExportHeader$b8u_dbmgr.sru
$PBExportComments$[parkkh] DB Manager
forward
global type b8u_dbmgr from u_cust_a_db
end type
end forward

global type b8u_dbmgr from u_cust_a_db
end type
global b8u_dbmgr b8u_dbmgr

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();//"b8w_reg_sn_move%save"
Long ll_cnt, ll_row
Int li_return, li_i
Decimal ldc_requestno
String ls_action, ls_ref_desc, ls_status, ls_bonsa, ls_makercd

Choose Case is_caller
	Case "b8w_reg_sn_move%save"          //대리점S/N할당
//		lu_dbmgr.is_caller = "b8w_reg_sn_move%save"
//		lu_dbmgr.is_title  = Title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = ls_requestdt      //할당일자
//		lu_dbmgr.is_data[2] = ls_serialfrom     //Serial No. (From)
//		lu_dbmgr.is_data[3] = ls_serialto		 //Serial No. (To)
//		lu_dbmgr.is_data[4] = ls_remark			 //비 고
//		lu_dbmgr.is_data[5] = ls_oqman			 //담당자
//		lu_dbmgr.is_data[6] = ls_modelno		    //모델
//		lu_dbmgr.is_data[7] = ls_fr_partner		 //할당대리점
//		lu_dbmgr.ib_data[1] = ib_new	          //무요청S/N할당...
//		lu_dbmgr.is_data[8] = ls_requestno		 //요청번호

		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then Return	   //저장 하지 않음
		
      idw_data[1].AcceptText()		

		ll_cnt = 0
		//contractseq 가져 오기
		Select count(*) 
		 Into :ll_cnt
		 From admst
		Where rtrim(ltrim(sn_partner)) is null
		  And use_yn = 'Y'
		  And modelno = :is_data[6]
		  And sale_flag = '0' 
		  And (rtrim(serialno) >= :is_data[2]
		  And rtrim(serialno) <= :is_data[3]);
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT count admst")
			ii_rc = -1			
			RollBack;
			Return 
		End If	
		
		If ll_cnt = 0 Then
			f_msg_info(9000, is_title, "장비마스터에 S/N 할당가능 개수가 0개입니다.(장비마스터확인)")
			ii_rc = -2
			return
		Elseif ll_cnt > 0 Then	
			li_return = MessageBox(is_title,"S/N 할당가능한 개수가 ("+string(ll_cnt)+")개입니다."+&
										  "~r~nS/N을 할당하시겠습니까?", Question!, YesNo!, 1)
			If li_return = 2 then 
				ii_rc = -2
				return
			End if
		End if		

		//S/N할당코드
		ls_status = fs_get_control("E1","A530", ls_ref_desc)

		If ib_data[1] = True then
			
			//requestno seq 가져 오기
			Select seq_adrequestno.nextval
			Into :ldc_requestno
			From dual;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + "SELECT seq_adrequestno.nextval")			
				ii_rc = -1			
				RollBack;
				Return 
			End If	
			
			ls_bonsa = fs_get_control("A1","C102", ls_ref_desc)
			
//			//makercd 가져 오기
//			Select makercd
//			 Into :ls_makercd
//			 From admodel
//			where modelno = :is_data[6];
//			
//			If SQLCA.SQLCode < 0 Then
//				f_msg_sql_err(is_title, is_caller + "SELECT admoel")			
//				ii_rc = -1			
//				RollBack;
//				Return 
//			End If	
//			
			Insert into admovereq
				( requestno, fr_partner, to_partner, modelno, requestdt, reqqty, oqman, 
				  trdate, trqty, trc_yn, reqstat, crt_user, updt_user, crtdt, updtdt, pgm_id )
			 values ( :ldc_requestno,  :is_data[7], :ls_bonsa, :is_data[6], null, 0, :is_data[5],
			           to_date(:is_data[1],'yyyy-mm-dd'), :ll_cnt, 'Y', :ls_status,
					    :gs_user_id, :gs_user_id, sysdate, sysdate, :gs_pgm_id[gi_open_win_no] );
				
			If SQLCA.SQLCode <> 0 Then
				RollBack;
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + "Insert admovereq Table")
				Return
			End If	
			
		Else
			
			Update admovereq
			 Set trdate = to_date(:is_data[1],'yyyy-mm-dd'),
				  trqty = :ll_cnt,
				  trc_yn = 'Y',
				  oqman = :is_data[5],
				  reqstat = :ls_status,
				  updt_user = :gs_user_id,
				  updtdt = sysdate,
				  pgm_id = :gs_pgm_id[gi_open_win_no]
			Where to_char(requestno) = :is_data[8];
			
			If SQLCA.SQLCode <> 0 Then
				RollBack;
				ii_rc = -1
				f_msg_sql_err(is_title, is_caller + " Update admovereq Table")
				Return
			End If	
			
		End if
			
		//대리점S/N할당코드
		ls_action = fs_get_control("E1","A309", ls_ref_desc)

		//Insert
		insert into admstlog
			 ( adseq, 
			   seq,
				action,
				status, 
				actdt,
				customerid,
				fr_partner,
				to_partner, 
				remark,
				crt_user,
				crtdt, 
				pgm_id )
	 ( select adseq,
				 seq_admstlog.nextval,
				 :ls_action,
				 status,
				 to_date(:is_data[1],'yyyy-mm-dd'),
				 null,
				 :gs_user_group,
				 :is_data[7],
				 :is_data[4],
				 :gs_user_group,
				  sysdate, 
				 :gs_pgm_id[gi_open_win_no]
			from admst 
		  where rtrim(ltrim(sn_partner)) is null
		    and sale_flag = '0'
			 and use_yn = 'Y'
			 and modelno = :is_data[6]
			 and ( rtrim(serialno) >= :is_data[2]
			 and rtrim(serialno) <= :is_data[3] ) );
			 
		//저장 실패 
		If SQLCA.SQLCode < 0 Then
			RollBack;
			ii_rc = -1			
			f_msg_sql_err(is_title, is_caller + " Insert Error(admstlog)")
			Return 
		End If	

		Update admst
		 Set sn_partner = :is_data[7],
			  snmovedt = to_date(:is_data[1],'yyyy-mm-dd'),
			  updt_user = :gs_user_id,
			  updtdt = sysdate,
			  pgm_id = :gs_pgm_id[gi_open_win_no]
		Where rtrim(ltrim(sn_partner)) is null
		  And sale_flag = '0' 
		  And use_yn = 'Y'
		  And modelno = :is_data[6]
		  And ( rtrim(serialno) >= :is_data[2] 
		   And rtrim(serialno) <= :is_data[3] );
		
		If SQLCA.SQLCode <> 0 Then
			RollBack;
			ii_rc = -1
			f_msg_sql_err(is_title, is_caller + " Update admst Table")
			Return
		End If

		Commit;
		
Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
End Choose

ii_rc = 0
end subroutine

on b8u_dbmgr.create
call super::create
end on

on b8u_dbmgr.destroy
call super::destroy
end on

