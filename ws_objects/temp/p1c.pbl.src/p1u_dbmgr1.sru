$PBExportHeader$p1u_dbmgr1.sru
$PBExportComments$[parkkh] ani# 등록/변경/해지 DBmgr
forward
global type p1u_dbmgr1 from u_cust_a_db
end type
end forward

global type p1u_dbmgr1 from u_cust_a_db
end type
global p1u_dbmgr1 p1u_dbmgr1

forward prototypes
public subroutine uf_prc_db_01 ()
public subroutine uf_prc_db_02 ()
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db_01 ();/*-------------------------------------------------------------------------
	name	: uf_prc_db_01()
	desc.	: Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2003.08.23
	programer : Park Kyung Hae (parkkh)
--------------------------------------------------------------------------*/	

//"p1w_reg_ani_num%ue_term"
String ls_temp, ls_termenable[], ls_ref_desc, ls_svctype
String ls_term_yn
long ll_i

String ls_sysdt, ls_termdt, ls_term_status[]
ii_rc = -1

Choose Case is_caller
	Case "p1w_reg_ani_num%ue_term"
//		iu_check.is_caller = "p1w_reg_ani_num%ue_term"
//		iu_check.is_title = This.Title
//		iu_check.idw_data[1] = dw_cond  		
//		iu_check.is_data[1] = ls_anino  		//Ani#(validkey)

		//해지신청가능상태정보
		ls_temp = fs_get_control("B0","P224", ls_ref_desc)
		If ls_temp <> "" Then
		   fi_cut_string(ls_temp, ";" , ls_termenable[])
		End if

		//선불카드 svctype
		ls_svctype = fs_get_control("P0","P100", ls_ref_desc)

		SELECT svctype, status, to_char(fromdt,'yyyymmdd'), use_yn, svccod
	     INTO :is_data[2], :is_data[3], :is_data[4], :is_data[5], :is_data[6]
		 FROM validinfo
		WHERE validkey = :is_data[1]
		  AND fromdt = ( select max(fromdt)
		  				   from validinfo
						  where validkey = :is_data[1] );
		
		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT svctype, status from validinfo")			
			Return 		
		ELSEIF sqlca.sqlcode = 100 Then
			f_msg_info(1000, is_title, "Ani#[" +is_data[1] +"]")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("anino")			
			Return 	
		End If
		
		//선불카드 서비스Type 만 유효하다.
		If is_data[2] <> ls_svctype Then
			f_msg_usr_err(201, is_title, " Ani#")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("anino")			
			Return 	
		End If
		
		//해지신청가능상태인지 check
		ls_term_yn = 'N'
		For ll_i = 1  to UpperBound(ls_termenable)
			IF is_data[3] = ls_termenable[ll_i] Then
				ls_term_yn = 'Y'
				Exit
			End IF
		NEXT	
		
	    If ls_term_yn = 'N' Then
			f_msg_usr_err(201, is_title, " Ani#")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("anino")			
			Return 	
		End IF		
		
	Case "p1w_reg_term_ani_popup%save"    
//		lu_dbmgr.is_caller = "p1w_reg_term_ani_popup%save"    
//		lu_dbmgr.is_title = is_title
//		lu_dbmgr.idw_data[1] = dw_detail
//		lu_dbmgr.is_data[1] = is_anino		  	//Ani#
//		lu_dbmgr.is_data[2] = is_fromdt		  	//fromdt
//		lu_dbmgr.is_data[3] = is_pgm_id			//pgm_id


		idw_data[1].accepttext()

		ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')

		ls_termdt = String(idw_data[1].object.todt[1],'yyyymmdd')		

		If IsNull(ls_termdt) Then ls_termdt = ""
		
		If ls_termdt = "" Then
			f_msg_info(200, is_title, "해지일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("todt")
			ii_rc = -2
			Return
		End If
		
		If ls_termdt < ls_sysdt Then
			f_msg_usr_err(210, is_title, "해지일은 오늘날짜 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("todt")
			ii_rc = -2
			Return
		End If			
		
		//해지상태코드 가져오기
		ls_ref_desc =""
		ls_temp = fs_get_control("B0", "P221", ls_ref_desc)
		fi_cut_string(ls_temp, ";", ls_term_status[])		

		update validinfo
		  set 	status = :ls_term_status[2],
		   		todt = to_date(:ls_termdt, 'yyyy-mm-dd'),
				use_yn = 'N',
				updt_user = :gs_user_id,
				updtdt = sysdate,
				pgm_id = :is_data[3]
		Where validkey = :is_data[1]
		  And to_char(fromdt,'yyyymmdd') = :is_data[2];
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(Validinfo)")
			ii_rc = -1						
			RollBack;
			Return 
		End If
		
		f_msg_info(3000, is_title, "Ani#[" +is_data[1]+"] TERM")
		
		//w_base를 상속받아서. commit. 해줘야 한다.
		commit;
		
		idw_data[1].enabled = False				
		
End Choose

ii_rc = 0 
end subroutine

public subroutine uf_prc_db_02 ();/*-------------------------------------------------------------------------
	name	: uf_prc_db_02()
	desc.	: Check
	arg.	: none
			  ii_rc  -1 실패
			          0 성공
	Date	: 2003.08.23
	programer : Park Kyung Hae (parkkh)
--------------------------------------------------------------------------*/	

long ll_i, ll_cnt, ll_ani_cnt
String ls_sysdt, ls_svctype, ls_ref_desc, ls_pinstatus, ls_pin_code[]
String ls_pid, ls_priceplan, ls_auth_method, ls_ip_address, ls_h323id
String ls_temp
ii_rc = -1

Choose Case is_caller
	Case "p1w_reg_ani_num%ue_change"
//		iu_check.is_caller = "p1w_reg_ani_num%ue_change"
//		iu_check.is_title = This.Title
//		iu_check.idw_data[1] = dw_cond  		
//		iu_check.is_data[1] = ls_anino  		//Ani#(validkey)

		//선불카드 svctype
		ls_svctype = fs_get_control("P0","P100", ls_ref_desc)

		SELECT svctype, status, to_char(fromdt,'yyyymmdd'), use_yn, svccod
	     INTO :is_data[2], :is_data[3], :is_data[4], :is_data[5], :is_data[6]
		 FROM validinfo
		WHERE validkey = :is_data[1]
		  AND fromdt = ( select max(fromdt)
		  				   from validinfo
						  where validkey = :is_data[1] );
		
		IF sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller + "SELECT svctype, status from validinfo")			
			Return 		
		ELSEIF sqlca.sqlcode = 100 Then
			f_msg_info(1000, is_title, "Ani#[" +is_data[1] +"]")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("anino")			
			Return 	
		End If
		
		//선불카드 서비스Type 만 유효하다.
		If is_data[2] <> ls_svctype Then
			f_msg_usr_err(201, is_title, " Ani#")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("anino")			
			Return 	
		End If
		
		//사용여부 = 'Y' 일때만 변경가능
    	If is_data[5] = 'N' Then
			f_msg_usr_err(201, is_title, " Ani#")	
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("anino")			
			Return 	
		End IF		
		
	Case "p1w_reg_change_ani_popup%save"    
//		lu_dbmgr.is_caller = "p1w_reg_change_ani_popup%save"    
//		lu_dbmgr.is_title = is_title
//		lu_dbmgr.idw_data[1] = dw_cond
//		lu_dbmgr.is_data[1] = is_anino				//ani#(인증Key)
//		lu_dbmgr.is_data[2] = is_fromdt				//fromdt
//		lu_dbmgr.is_data[3] = is_pgm_id				//pgmid
//		lu_dbmgr.is_data[4] = is_ani_syscod[1]      //pid 사용여부
//		lu_dbmgr.is_data[5] = is_ani_syscod[2]		//인증Key 사용여부
//		lu_dbmgr.is_data[6] = is_ani_syscod[4]      //인증Key 갯수
//		lu_dbmgr.is_data[7] = is_pid_ori            //pin# original

		idw_data[1].accepttext()

		ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
		
		ls_pid = Trim(idw_data[1].object.pid[1])
		If IsNull(ls_pid) Then ls_pid = ""

		If is_data[4] = 'Y' or ls_pid <> "" Then

			//선불카드상태(발행;판매;사용;기간만료;잔액부족;일시정지;반품카드)
			ls_ref_desc = ""
			ls_temp = fs_get_control("P0","P101", ls_ref_desc)
			If ls_temp = "" Then Return 
			fi_cut_string(ls_temp, ";" , ls_pin_code[])
			
			If ls_pid = "" Then
				f_msg_info(200, is_title, "Pin")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("pid")
				ii_rc = -2
				Return
			End If
			
			//존재하는 pin인지 확인한다. 
			select priceplan, status
			  into :ls_priceplan, :ls_pinstatus
			 from p_cardmst
			where pid = :ls_pid;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select priceplan (p_cardmst)")				
				Return 
				
			ElseIf sqlca.sqlcode = 100 Then
				
				If isNull(ls_priceplan) or ls_priceplan = "" Then
					f_msg_info(1000, is_title, "Pin#[" + ls_pid + "]")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("pid")
					ii_rc = -2					
					return 
				End if
				
			End If
			
			//pin이 변경되어졌을 때만  Check 한다...
			If ls_pid <> is_data[7]  or isnull(is_data[7]) Then

				If ls_pinstatus = ls_pin_code[2] or ls_pinstatus = ls_pin_code[3] Then
				Else
					f_msg_usr_err(201, is_title, "Pin#[" + ls_pid + "] status")	
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("pid")			
					ii_rc = -2
					Return 	
				End IF				
			
				
				ll_cnt = 0
				Select count(*) 
				  Into :ll_cnt
				  From validinfo
				 Where pid = :ls_pid
				   and to_char(fromdt,'yyyymmdd') <= :ls_sysdt
				   and to_char(nvl(todt, sysdate+1),'yyyymmdd') > :ls_sysdt;
		
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller +"Select validinfo (pid count)")				
					Return 
				End If
	
				//인증Key 갯수가 정해져 있지 않으면 제한 없다.
				If isnull(is_data[6]) or is_data[6]  = "" Then
				Else
					ll_ani_cnt = long(is_data[6])
					
					If ll_cnt >= ll_ani_cnt Then
						f_msg_usr_err(9000, is_title, "PIN#[" + ls_pid + "]에 Ani#갯수는 " + is_data[6]+ "개만 가능합니다.~r~n~r~n다른 PIN#를 입력하세요!!")
						idw_data[1].SetFocus()
						idw_data[1].SetColumn("pid")
						ii_rc = -2					
						return 
					End if
				End if
				
			End if
		Else 
			setnull(ls_pid)
		End If
		
		If is_data[5] = 'Y' Then
	
			ls_auth_method = idw_data[1].object.auth_method[1]			
			If IsNull(ls_auth_method) Then ls_auth_method = ""
			
			If ls_auth_method = "" Then
				f_msg_info(200, is_title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("auth_method")
				ii_rc = -2
				Return
			End If
			
			If LeftA(ls_auth_method,1) = 'S' Then
				ls_ip_address = idw_data[1].object.validitem2[1]
				If IsNull(ls_ip_address) Then ls_ip_address = ""				
				If ls_ip_address = "" Then
					f_msg_info(200, is_title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("validitem2")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				ls_h323id = idw_data[1].object.validitem3[1]
				If IsNull(ls_h323id) Then ls_h323id = ""							
				If ls_h323id = "" Then
					f_msg_info(200, is_title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("validitem3")
					Return 
				End If		
			End if	
			
		End If
		
		
		update validinfo
		  set 	pid = :ls_pid,
		   		auth_method = :ls_auth_method,
				validitem2  = :ls_ip_address,
				validitem3 = :ls_h323id,
				updt_user = :gs_user_id,
				updtdt = sysdate,
				pgm_id = :is_data[3]
		Where validkey = :is_data[1]
		  And to_char(fromdt,'yyyymmdd') = :is_data[2];
		 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Update Error(Validinfo)")
			RollBack;
			Return 
		End If
		
		f_msg_info(3000, is_title, "Ani#[" +is_data[1]+"] CHANGE")

		idw_data[1].enabled = False				
		
End Choose

ii_rc = 0 
end subroutine

public subroutine uf_prc_db ();//전체
String ls_ref_desc, ls_temp

//	Case "p1w_reg_new_ani_popup%save"    
String ls_default_code[], ls_pid, ls_fromdt, ls_auth_method, ls_pin_code[]
String ls_aninum, ls_status_act, ls_status_actorder, ls_status, ls_pinstatus
String ls_ip_address, ls_h323id, ls_sysdt, ls_validkey, ls_pgm_id, ls_priceplan, ls_use_yn
Long ll_cnt, ll_contractseq, ll_ani_cnt


ii_rc = -1
Choose Case is_caller
	Case "p1w_reg_new_ani_popup%save"    
//		lu_dbmgr.is_caller = "p1w_reg_new_ani_popup%save"    
//		lu_dbmgr.is_title = is_title
//		lu_dbmgr.is_data[1] = is_ani_syscod[1]              //pin필수여부
//		lu_dbmgr.is_data[2] = is_ani_syscod[2]				//인증방법사용여부
//		lu_dbmgr.is_data[3] = gs_pgm_id[gi_open_win_no]     //pgmid
//		lu_dbmgr.is_data[4] = is_ani_syscod[4]		        //인증Key갯수

		idw_data[1].accepttext()

		ls_sysdt = String(fdt_get_dbserver_now(),'yyyymmdd')
		
		//선불카드인증정보(상태;고객번호;svctype;계약seq)
		ls_ref_desc = ""
		ls_temp = fs_get_control("P0","P000", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_default_code[])
		
		//선불카드상태(발행;판매;사용;기간만료;잔액부족;일시정지;반품카드)
		ls_ref_desc = ""
		ls_temp = fs_get_control("P0","P101", ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_pin_code[])

		//개통처리 status
		ls_ref_desc = ""
		ls_status_act = fs_get_control("B0","P223", ls_ref_desc)
		
		//개통신청  status
		ls_ref_desc = ""
		ls_status_actorder = fs_get_control("B0","P220", ls_ref_desc)
		
	
		ls_aninum = Trim(idw_data[1].object.aninum[1])
		ls_pid = Trim(idw_data[1].object.pid[1])
		ls_fromdt = String(idw_data[1].object.fromdt[1],'yyyymmdd')

		If IsNull(ls_aninum) Then ls_aninum = ""
		If IsNull(ls_pid) Then ls_pid = ""
		If IsNull(ls_fromdt) Then ls_fromdt = ""

		If ls_aninum = "" Then
			f_msg_info(200, is_title, "Ani#")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("aninum")
			ii_rc = -2
			Return
		End If
		
		If is_data[1] = 'Y'  or ls_pid <> "" Then
			
			If ls_pid = "" Then
				f_msg_info(200, is_title, "Pin")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("pid")
				ii_rc = -2
				Return
			End If
			
			//존재하는 pin인지 확인한다. 
			select priceplan, status
			  into :ls_priceplan, :ls_pinstatus
			 from p_cardmst
			where pid = :ls_pid;
					  
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select priceplan (p_cardmst)")				
				Return 
				
			ElseIf sqlca.sqlcode = 100 Then
				
				If isNull(ls_priceplan) or ls_priceplan = "" Then
					f_msg_info(1000, is_title, "Pin#[" + ls_pid + "]")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("pid")
					ii_rc = -2					
					return 
				End if
				
			End If
			
			If ls_pinstatus = ls_pin_code[2] or ls_pinstatus = ls_pin_code[3] Then
			Else
				f_msg_usr_err(201, is_title, "Pin#[" + ls_pid + "] status")	
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("pid")			
				ii_rc = -2
				Return 	
			End IF				
				
			ll_cnt = 0
			Select count(*) 
			  Into :ll_cnt
			  From validinfo
			 Where pid = :ls_pid
			   and to_char(fromdt,'yyyymmdd') <= :ls_sysdt
			   and to_char(nvl(todt, sysdate+1),'yyyymmdd') > :ls_sysdt;
	
			If sqlca.sqlcode < 0 Then
				f_msg_sql_err(is_title, is_caller +"Select validinfo (pid count)")				
				Return 
			End If

			//인증Key 갯수가 정해져 있지 않으면 제한 없다.
			If isnull(is_data[4]) or is_data[4]  = "" Then
			Else
				ll_ani_cnt = long(is_data[4])
				
				If ll_cnt >= ll_ani_cnt Then
					f_msg_usr_err(9000, is_title, "PIN#[" + ls_pid + "]에 Ani#갯수는 " + is_data[4]+ "개만 가능합니다.~r~n~r~n다른 PIN#를 입력하세요!!")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("pid")
					ii_rc = -2					
					return 
				End if
			End if

			//pid 가  값이 있으면 validinfo.status = '개통'
			ls_status = ls_status_act
			ls_use_yn = 'Y'
		Else
			//pid is null이면 validinfo.status = '개통신청'
			ls_status = ls_status_actorder
			ls_use_yn = 'N'
			setnull(ls_pid)			
		End If

		
		If ls_fromdt = "" Then
			f_msg_info(200, is_title, "개통일")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("fromdt")
			ii_rc = -2
			Return
		End If
		
		If ls_fromdt < ls_sysdt Then
			f_msg_usr_err(210, is_title, "개통일은 오늘날짜 이상이여야 합니다.")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("fromdt")
			ii_rc = -2
			Return
		End If			
		
		//인증KEY 중복 check  
		//적용시작일과 적용종료일의 중복일자를 막는다. 
		ll_cnt = 0
		select count(*)
		  into :ll_cnt
		 from validinfo
		where  ( (to_char(fromdt,'yyyymmdd') > :ls_fromdt ) Or
				  ( to_char(fromdt,'yyyymmdd') <= :ls_fromdt and
					:ls_fromdt <= nvl(to_char(todt,'yyyymmdd'),'99991231')) )
		   and	validkey = :ls_aninum;
				  
		If sqlca.sqlcode < 0 Then
			f_msg_sql_err(is_title, is_caller +"Select validinfo (count)")				
			Return 
		End If
		
		If ll_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "Ani#[" + ls_aninum + "]에 적용시작일과 적용종료일이 중복됩니다.~r~n~r~n다시 입력하세요!!")
			idw_data[1].SetFocus()
			idw_data[1].SetColumn("aninum")
			ii_rc = -2					
			return 
		End if
				
		If is_data[2] = 'Y' Then
	
			ls_auth_method = idw_data[1].object.auth_method[1]			
			If IsNull(ls_auth_method) Then ls_auth_method = ""
			
			
			If ls_auth_method = "" Then
				f_msg_info(200, is_title, "인증방법")
				idw_data[1].SetFocus()
				idw_data[1].SetColumn("auth_method")
				ii_rc = -2
				Return
			End If
			
			If LeftA(ls_auth_method,1) = 'S' Then
				ls_ip_address = idw_data[1].object.ip_address[1]
				If IsNull(ls_ip_address) Then ls_ip_address = ""				
				If ls_ip_address = "" Then
					f_msg_info(200, is_title, "IP ADDRESS")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("ip_address")
					Return
				End If		
			End if
			
			If MidA(ls_auth_method,7,1) <> 'E' Then
				ls_h323id = idw_data[1].object.h323id[1]
				If IsNull(ls_h323id) Then ls_h323id = ""							
				If ls_h323id = "" Then
					f_msg_info(200, is_title, "H323ID")
					idw_data[1].SetFocus()
					idw_data[1].SetColumn("h323id")
					Return 
				End If		
			End if	
			
		End If
		
		ll_contractseq = long(ls_default_code[5])
		
		Insert Into validinfo
			(validkey, pid, fromdt, status, 
			 use_yn, svctype, customerid, 
			 svccod, priceplan, contractseq, 
			 auth_method, validitem2, validitem3,
			 crt_user, updt_user, crtdt, updtdt, pgm_id)
		Values(:ls_aninum, :ls_pid, to_date(:ls_fromdt,'yyyy-mm-dd'), :ls_status,
			   :ls_use_yn, :ls_default_code[4], :ls_default_code[2],
			   :ls_default_code[3], :ls_priceplan, :ll_contractseq, 
			   :ls_auth_method, :ls_ip_address, :ls_h323id,
			   :gs_user_id, :gs_user_id, sysdate, sysdate, :is_data[3]);
				 
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Insert Error(Validinfo)")
			ii_rc = -1						
			RollBack;
			Return 
		End If
		
		f_msg_info(3000, is_title, "Ani#[" +ls_aninum +"] NEW")
		
		idw_data[1].enabled = False
		
End Choose

ii_rc = 0

Return 
end subroutine

on p1u_dbmgr1.create
call super::create
end on

on p1u_dbmgr1.destroy
call super::destroy
end on

